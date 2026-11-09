import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dart_eval/dart_eval.dart';
import 'package:c_editor/bundled_plugins/bundled_plugins.dart';
import 'package:c_editor/plugins/c_plugin_manifest.dart';
import 'package:c_editor/plugins/c_plugin_validator.dart';
import 'package:c_editor/plugins/plugin_downloader.dart';
import 'package:c_editor/plugins/plugin_host_hooks.dart';
import 'package:c_editor/plugins/plugin_host_impl.dart';
import 'package:c_editor/plugins/plugin_kind.dart';
import 'package:c_editor/plugins/plugin_package.dart';
import 'package:c_editor/plugins/plugin_runtime.dart';
import 'package:c_editor/plugins/plugin_screen_registry.dart';
import 'package:c_editor/plugins/plugin_source_compiler.dart';
import 'package:c_editor/plugins/plugin_storage.dart';
import 'package:c_editor/plugins/plugin_storage_factory.dart';

const _prefsDisabledKey = 'cplugin_disabled_ids';

/// Coordinates install, enable/disable, and runtime loading of plugins.
class PluginManager extends ChangeNotifier {
  PluginManager._({
    required PluginStorage storage,
    required SharedPreferences prefs,
    required this.screenRegistry,
  }) : _storage = storage,
       _prefs = prefs;

  static PluginManager? _instance;

  static PluginManager get instance {
    final current = _instance;
    if (current == null) {
      throw StateError('PluginManager.init() has not been called');
    }
    return current;
  }

  static bool get isInitialized => _instance != null;

  static Future<PluginManager> init(
    SharedPreferences prefs, {
    void Function(int completed, int total)? onResourceProgress,
  }) async {
    if (_instance != null) return _instance!;
    final manager = PluginManager._(
      storage: createPluginStorage(prefs),
      prefs: prefs,
      screenRegistry: PluginScreenRegistry(),
    );
    _instance = manager;
    await manager.reload(onResourceProgress: onResourceProgress);
    if (kCpluginDebugPathDefine.trim().isNotEmpty) {
      try {
        final path = kCpluginDebugPathDefine.trim();
        debugPrint('CPLUGIN_DEBUG_PATH: compiling & installing $path');
        await manager.installFromSourceDirectory(path);
      } catch (e, st) {
        debugPrint('CPLUGIN_DEBUG_PATH failed: $e\n$st');
      }
    }
    return manager;
  }

  final PluginStorage _storage;
  final SharedPreferences _prefs;
  final PluginScreenRegistry screenRegistry;
  final PluginDownloader _downloader = PluginDownloader();
  final CPluginValidator _validator = const CPluginValidator();

  List<InstalledPluginRecord> _installed = [];
  final Map<String, Runtime> _runtimes = {};

  List<InstalledPluginRecord> get installed => List.unmodifiable(_installed);

  Set<String> _disabledIds() {
    final list = _prefs.getStringList(_prefsDisabledKey) ?? const [];
    final ids = list.toSet();
    // Migrate pre-rename Data Package Download plugin id.
    if (ids.remove('team.international2c.dynamic_fetch')) {
      ids.add('team.international2c.level_testing_mod');
    }
    return ids;
  }

  Future<void> _setDisabledIds(Set<String> ids) async {
    await _prefs.setStringList(_prefsDisabledKey, ids.toList()..sort());
  }

  Future<void> reload({
    void Function(int completed, int total)? onResourceProgress,
  }) async {
    screenRegistry.clearAll();
    _runtimes.clear();
    PluginHostHooks.openPreviewImageGenerator = null;
    PluginHostHooks.offerExternalDynamic = null;

    final disabled = _disabledIds();
    final records = <InstalledPluginRecord>[];

    final assetPaths = onResourceProgress == null
        ? null
        : (await AssetManifest.loadFromAssetBundle(rootBundle)).listAssets();
    final totalResources =
        assetPaths
            ?.where(
              (path) => bundledPlugins.any(
                (plugin) => path.startsWith(plugin.assetsFlutterRoot + '/'),
              ),
            )
            .length ??
        0;
    var completedResources = 0;
    onResourceProgress?.call(0, totalResources);
    for (final bundled in bundledPlugins) {
      final enabled = !disabled.contains(bundled.id);
      try {
        final manifest = await loadPluginManifestAsset(
          bundled.manifestAssetPath,
        );
        if (manifest.id != bundled.id) {
          throw StateError(
            'Bundled plugin id mismatch: catalog=${bundled.id} '
            'manifest=${manifest.id}',
          );
        }
        final assets = await loadPluginAssetsFromFlutter(
          bundled.assetsFlutterRoot,
          assetPaths: assetPaths,
          onAssetLoaded: () {
            onResourceProgress?.call(++completedResources, totalResources);
          },
        );
        records.add(
          bundledPluginRecord(
            manifest: manifest,
            assets: assets,
            enabled: enabled,
          ),
        );
      } catch (e, st) {
        debugPrint('Failed to load bundled plugin ${bundled.id}: $e\n$st');
        records.add(
          InstalledPluginRecord(
            manifest: CPluginManifest(
              format: CPluginManifest.expectedFormat,
              formatVersion: CPluginManifest.supportedFormatVersion,
              id: bundled.id,
              version: '0',
              entryLibrary: 'package:c_editor/bundled/${bundled.id}',
              entryFunction: 'initialize',
            ),
            evcBytes: Uint8List(0),
            assets: const {},
            enabled: enabled,
            kind: PluginKind.bundled,
            loadError: e.toString(),
          ),
        );
      }
    }

    final imported = await _storage.listInstalled();
    for (final plugin in imported) {
      if (records.any((r) => r.id == plugin.id)) continue;
      final enabled = !disabled.contains(plugin.id);
      records.add(plugin.copyWith(enabled: enabled));
    }

    records.sort((a, b) {
      if (a.kind != b.kind) {
        return a.kind == PluginKind.bundled ? -1 : 1;
      }
      return a.localizedName('en').compareTo(b.localizedName('en'));
    });
    _installed = records;

    for (var i = 0; i < _installed.length; i++) {
      final record = _installed[i];
      if (!record.enabled || record.loadError != null) continue;
      final conflict = findPluginConflictMessage(
        record.manifest,
        _installed
            .where((p) => p.enabled && p.id != record.id)
            .map((p) => p.manifest),
      );
      if (conflict != null) {
        _installed[i] = record.copyWith(loadError: conflict);
      }
    }

    for (final bundled in bundledPlugins) {
      final record = _installed.firstWhere((p) => p.id == bundled.id);
      if (!record.enabled || record.loadError != null) continue;
      try {
        final host = PluginHostImpl(
          pluginId: bundled.id,
          assets: MemoryCPluginAssets(record.assets),
          registry: screenRegistry,
        );
        bundled.initialize(host);
      } catch (e, st) {
        debugPrint(
          'Failed to initialize bundled plugin ${bundled.id}: $e\n$st',
        );
        final index = _installed.indexWhere((p) => p.id == bundled.id);
        if (index >= 0) {
          _installed[index] = _installed[index].copyWith(
            loadError: e.toString(),
          );
        }
      }
    }

    for (final record in _installed.where(
      (p) => p.kind == PluginKind.imported && p.enabled && p.loadError == null,
    )) {
      await _loadImported(record);
    }

    notifyListeners();
  }

  Future<InstalledPluginRecord> installBytes(
    Uint8List bytes, {
    bool enable = true,
  }) async {
    final package = _validator.validate(bytes);
    if (bundledPlugins.any((b) => b.id == package.manifest.id)) {
      throw CPluginValidationException(
        'Plugin id "${package.manifest.id}" is reserved for a bundled plugin',
      );
    }
    final conflict = findPluginConflictMessage(
      package.manifest,
      _installed.map((r) => r.manifest),
    );
    if (conflict != null) {
      throw CPluginValidationException(conflict);
    }
    await _checkMinEditorVersion(package.manifest.minEditorVersion);

    try {
      executePluginEntrypoint(
        evcBytes: package.evcBytes,
        manifest: package.manifest,
        pluginId: package.manifest.id,
        assets: package.assets,
      );
    } catch (e) {
      throw CPluginValidationException(
        'Plugin bytecode failed to execute initialize(): $e',
      );
    }

    await _storage.savePackage(package, enabled: enable);
    final disabled = _disabledIds();
    if (enable) {
      disabled.remove(package.manifest.id);
    } else {
      disabled.add(package.manifest.id);
    }
    await _setDisabledIds(disabled);
    await reload();
    return _installed.firstWhere((p) => p.id == package.manifest.id);
  }

  Future<InstalledPluginRecord> installFromUrl(
    Uri uri, {
    PluginDownloadProgress? onProgress,
    bool enable = true,
  }) async {
    final bytes = await _downloader.download(uri, onProgress: onProgress);
    return installBytes(bytes, enable: enable);
  }

  Future<InstalledPluginRecord> installFromSourceDirectory(
    String directoryPath, {
    bool enable = true,
  }) async {
    if (kIsWeb) {
      throw UnsupportedError(
        'Loading plugins from a folder is not supported on web',
      );
    }
    final package = compilePluginDirectory(directoryPath);
    return installBytes(package.rawZipBytes, enable: enable);
  }

  Future<void> setEnabled(String pluginId, bool enabled) async {
    final recordIndex = _installed.indexWhere(
      (record) => record.id == pluginId,
    );
    final previousRecord = recordIndex >= 0 ? _installed[recordIndex] : null;
    if (previousRecord != null && previousRecord.enabled != enabled) {
      _installed[recordIndex] = previousRecord.copyWith(enabled: enabled);
      notifyListeners();
    }

    try {
      final disabled = _disabledIds();
      if (enabled) {
        disabled.remove(pluginId);
      } else {
        disabled.add(pluginId);
      }
      await _setDisabledIds(disabled);

      final record = _installed.where((p) => p.id == pluginId).firstOrNull;
      if (record != null && record.kind == PluginKind.imported) {
        await _storage.setEnabled(pluginId, enabled);
      }
      await reload();
    } catch (_) {
      final currentIndex = _installed.indexWhere(
        (record) => record.id == pluginId,
      );
      if (previousRecord != null && currentIndex >= 0) {
        _installed[currentIndex] = previousRecord;
        notifyListeners();
      }
      rethrow;
    }
  }

  Future<void> uninstall(String pluginId) async {
    final record = _installed.where((p) => p.id == pluginId).firstOrNull;
    if (record != null && !record.canUninstall) {
      throw StateError('Bundled plugins cannot be uninstalled');
    }
    screenRegistry.clearForPlugin(pluginId);
    _runtimes.remove(pluginId);
    await _storage.uninstall(pluginId);
    final disabled = _disabledIds()..remove(pluginId);
    await _setDisabledIds(disabled);
    await reload();
  }

  Future<void> _loadImported(InstalledPluginRecord record) async {
    screenRegistry.clearForPlugin(record.id);
    try {
      final runtime = executePluginEntrypoint(
        evcBytes: record.evcBytes,
        manifest: record.manifest,
        pluginId: record.id,
        assets: record.assets,
        registry: screenRegistry,
      );
      _runtimes[record.id] = runtime;
      final index = _installed.indexWhere((p) => p.id == record.id);
      if (index >= 0) {
        _installed[index] = record.copyWith(clearLoadError: true);
      }
    } catch (e, st) {
      debugPrint('Failed to load plugin ${record.id}: $e\n$st');
      final index = _installed.indexWhere((p) => p.id == record.id);
      if (index >= 0) {
        _installed[index] = record.copyWith(loadError: e.toString());
      }
    }
  }

  Future<void> _checkMinEditorVersion(String? minVersion) async {
    if (minVersion == null || minVersion.isEmpty) return;
    final info = await PackageInfo.fromPlatform();
    if (!_isVersionAtLeast(info.version, minVersion)) {
      throw CPluginValidationException(
        'Plugin requires C-Editor $minVersion or newer '
        '(current: ${info.version})',
      );
    }
  }

  static bool _isVersionAtLeast(String current, String minimum) {
    List<int> parts(String v) {
      final core = v.split(RegExp(r'[-+]')).first;
      return core.split('.').map((p) => int.tryParse(p) ?? 0).toList();
    }

    final a = parts(current);
    final b = parts(minimum);
    final len = a.length > b.length ? a.length : b.length;
    for (var i = 0; i < len; i++) {
      final ai = i < a.length ? a[i] : 0;
      final bi = i < b.length ? b[i] : 0;
      if (ai > bi) return true;
      if (ai < bi) return false;
    }
    return true;
  }
}
