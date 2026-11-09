import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:c_editor/app.dart';
import 'package:c_editor/bloc/app_navigation/app_navigation_cubit.dart';
import 'package:c_editor/bloc/settings/settings_cubit.dart';
import 'package:c_editor/data/app_bootstrap.dart';
import 'package:c_editor/data/repository/level_repository.dart';
import 'package:c_editor/plugins/plugin_manager.dart';
import 'package:c_editor/screens/startup_loading_screen.dart';
import 'package:c_editor/utils/document_lang.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Allow portrait and landscape on phones/tablets (native + mobile web).
  if (defaultTargetPlatform == TargetPlatform.android ||
      defaultTargetPlatform == TargetPlatform.iOS) {
    await SystemChrome.setPreferredOrientations(const [
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
  }

  final previousOnError = FlutterError.onError;
  FlutterError.onError = (details) {
    final message = details.exceptionAsString();
    final isKnownHardwareKeyboardAssertion =
        (message.contains('A KeyDownEvent is dispatched') &&
            message.contains('physical key is already pressed')) ||
        (message.contains('Attempted to send a key down event') &&
            message.contains('no keys are in keysPressed'));
    if (isKnownHardwareKeyboardAssertion) {
      debugPrint('Ignored known Flutter keyboard assertion: $message');
      return;
    }
    if (previousOnError != null) {
      previousOnError(details);
    } else {
      FlutterError.presentError(details);
    }
  };

  final prefs = await SharedPreferences.getInstance();

  runApp(BootstrapApp(prefs: prefs));
}

Locale resolveStartupLocale(SharedPreferences prefs) {
  final savedLocale = prefs.getString('locale');
  if (savedLocale != null) {
    return Locale(savedLocale);
  }

  const supported = ['en', 'ru', 'zh'];
  final systemCode =
      WidgetsBinding.instance.platformDispatcher.locale.languageCode;
  final code = supported.contains(systemCode) ? systemCode : 'en';
  return Locale(code);
}

class BootstrapApp extends StatefulWidget {
  const BootstrapApp({super.key, required this.prefs});

  final SharedPreferences prefs;

  @override
  State<BootstrapApp> createState() => _BootstrapAppState();
}

class _BootstrapAppState extends State<BootstrapApp> {
  double _progress = 0;
  BootstrapLoadingCategory? _loadingCategory;
  bool _ready = false;
  int? _pluginResourcesCompleted;
  int? _pluginResourcesTotal;
  late final Locale _startupLocale = resolveStartupLocale(widget.prefs);

  late final ThemeMode _startupThemeMode = _resolveThemeMode(widget.prefs);

  ThemeMode _resolveThemeMode(SharedPreferences prefs) {
    final mode = prefs.getString('theme_mode');
    if (mode == 'dark') return ThemeMode.dark;
    if (mode == 'light') return ThemeMode.light;
    return ThemeMode.system;
  }

  @override
  void initState() {
    super.initState();
    setDocumentLanguage(_startupLocale.languageCode);
    _load();
  }

  Future<void> _load() async {
    await LevelRepository.preloadLibrarySettings(widget.prefs);
    await AppBootstrap.load(
      onProgress: (progress, category) {
        if (!mounted) return;
        setState(() {
          _progress = progress * 0.92;
          if (category != null) {
            _loadingCategory = category;
          }
        });
      },
    );
    if (!mounted) return;
    setState(() {
      _progress = 0.92;
      _loadingCategory = BootstrapLoadingCategory.plugins;
    });
    final progressClock = Stopwatch()..start();
    var lastUpdateMs = -100;
    await PluginManager.init(
      widget.prefs,
      onResourceProgress: (completed, total) {
        if (!mounted) return;
        final now = progressClock.elapsedMilliseconds;
        if (completed != total && now - lastUpdateMs < 100) return;
        lastUpdateMs = now;
        setState(() {
          _pluginResourcesCompleted = completed;
          _pluginResourcesTotal = total;
          // Reserve the final 1% for storage and plugin entrypoints.
          _progress = 0.92 + (total == 0 ? 0 : completed / total) * 0.07;
        });
      },
    );
    if (!mounted) return;
    setState(() {
      _progress = 1.0;
      _ready = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!_ready) {
      return StartupLoadingScreen(
        progress: _progress,
        locale: _startupLocale,
        themeMode: _startupThemeMode,
        loadingCategory: _loadingCategory,
        pluginResourcesCompleted: _pluginResourcesCompleted,
        pluginResourcesTotal: _pluginResourcesTotal,
      );
    }

    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => SettingsCubit(widget.prefs)),
        BlocProvider(create: (_) => AppNavigationCubit()),
      ],
      child: const ZEditorApp(),
    );
  }
}
