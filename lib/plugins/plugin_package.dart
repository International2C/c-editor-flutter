import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:c_editor/plugin_api/c_plugin_host.dart';
import 'package:c_editor/plugins/c_plugin_manifest.dart';
import 'package:c_editor/plugins/plugin_kind.dart';
import 'package:c_editor/plugins/plugin_storage.dart';

/// Shared package contract for both bundled (in-process) and imported plugins.
///
/// Bundled plugins ship the same layout as a `.cplugin` author tree
/// (`manifest.json`, `initialize`, `assets/`) and call the same
/// [CPluginHost] entrypoint. They are loaded as Dart instead of EVC.
class CPluginPackageSpec {
  const CPluginPackageSpec({
    required this.id,
    required this.packageRoot,
    required this.initialize,
  });

  /// Must match `manifest.json` `id`.
  final String id;

  /// Repo / Flutter asset root, e.g.
  /// `lib/bundled_plugins/preview_img_cplugin`.
  ///
  /// Expected children (same layout as `plugin_example/hello_cplugin`):
  /// - `manifest.json`
  /// - `lib/main.dart` (`initialize`; host entry via `package:c_editor/.../lib/main.dart`)
  /// - `assets/**` (plugin asset paths relative to `assets/`)
  final String packageRoot;

  /// Same entrypoint as an external `.cplugin`: `void initialize(CPluginHost)`.
  final void Function(CPluginHost host) initialize;

  String get manifestAssetPath => '$packageRoot/manifest.json';

  String get assetsFlutterRoot => '$packageRoot/assets';
}

/// Loads [CPluginManifest] from a Flutter asset path.
Future<CPluginManifest> loadPluginManifestAsset(String assetPath) async {
  final raw = await rootBundle.loadString(assetPath);
  return CPluginManifest.fromJson(jsonDecode(raw) as Map<String, dynamic>);
}

/// Loads plugin `assets/` files registered under [assetsFlutterRoot].
Future<Map<String, Uint8List>> loadPluginAssetsFromFlutter(
  String assetsFlutterRoot, {
  List<String>? assetPaths,
  void Function()? onAssetLoaded,
}) async {
  final prefix = assetsFlutterRoot.endsWith('/')
      ? assetsFlutterRoot
      : '$assetsFlutterRoot/';
  final paths =
      assetPaths ??
      (await AssetManifest.loadFromAssetBundle(rootBundle)).listAssets();
  final out = <String, Uint8List>{};
  for (final key in paths) {
    if (!key.startsWith(prefix)) continue;
    final relative = key.substring(prefix.length);
    if (relative.isEmpty) continue;
    final data = await rootBundle.load(key);
    out[relative] = data.buffer.asUint8List(
      data.offsetInBytes,
      data.lengthInBytes,
    );
    onAssetLoaded?.call();
  }
  return out;
}

/// Builds an [InstalledPluginRecord] for a bundled in-process plugin.
InstalledPluginRecord bundledPluginRecord({
  required CPluginManifest manifest,
  required Map<String, Uint8List> assets,
  required bool enabled,
}) {
  return InstalledPluginRecord(
    manifest: manifest,
    evcBytes: Uint8List(0),
    assets: assets,
    enabled: enabled,
    kind: PluginKind.bundled,
  );
}
