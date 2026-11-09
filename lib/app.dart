import 'package:flutter/material.dart';
import 'package:c_editor/widgets/browser_leave_protection.dart';
import 'package:c_editor/widgets/app_update_prompt.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:c_editor/escape_override.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:c_editor/l10n/app_localizations.dart';
import 'package:c_editor/bloc/app_navigation/app_navigation_cubit.dart';
import 'package:c_editor/bloc/settings/settings_cubit.dart';
import 'package:c_editor/bloc/editor/editor_cubit.dart';
import 'package:c_editor/plugins/active_editor_session.dart';
import 'package:c_editor/screens/about_screen.dart';
import 'package:c_editor/screens/editor_screen.dart';
import 'package:c_editor/screens/level_list_screen.dart';
import 'package:c_editor/screens/plugins_screen.dart';
import 'package:c_editor/theme/app_theme.dart';
import 'package:c_editor/widgets/app_ui_scaler.dart';
import 'package:c_editor/widgets/locale_flag_icon.dart';
import 'package:c_editor/widgets/persistent_scrollbar_scroll_behavior.dart';
import 'package:c_editor/widgets/editor_components.dart' show EditorOptionTile;

/// Wraps child and handles Escape key on desktop to trigger back/pop.
/// Uses HardwareKeyboard.addHandler for immediate, global Escape handling.
class _DesktopEscapeHandler extends StatefulWidget {
  const _DesktopEscapeHandler({
    required this.child,
    required this.currentScreen,
    required this.onEscapeNoRouteToPop,
  });

  final Widget child;
  final AppScreen currentScreen;
  final VoidCallback? onEscapeNoRouteToPop;

  @override
  State<_DesktopEscapeHandler> createState() => _DesktopEscapeHandlerState();
}

class _DesktopEscapeHandlerState extends State<_DesktopEscapeHandler> {
  late final KeyEventCallback _keyHandler;

  @override
  void initState() {
    super.initState();
    _keyHandler = _handleKeyEvent;
    HardwareKeyboard.instance.addHandler(_keyHandler);
  }

  @override
  void dispose() {
    HardwareKeyboard.instance.removeHandler(_keyHandler);
    super.dispose();
  }

  bool _handleKeyEvent(KeyEvent event) {
    if (event is KeyRepeatEvent) return false;
    if (event is! KeyDownEvent) return false;
    if (event.logicalKey != LogicalKeyboardKey.escape) return false;
    if (!mounted) return false;

    final platform = Theme.of(context).platform;
    if (platform != TargetPlatform.windows &&
        platform != TargetPlatform.macOS &&
        platform != TargetPlatform.linux) {
      return false;
    }

    if (EscapeOverride.tryHandle?.call() == true) return true;
    if (ModalGate.tryAbsorb()) return true;

    // Credits/about/plugins use cubit navigation, not the Navigator stack.
    if (widget.currentScreen == AppScreen.about ||
        widget.currentScreen == AppScreen.plugins) {
      widget.onEscapeNoRouteToPop?.call();
      return true;
    }

    if (popRouteAbove(context)) return true;

    final nav = Navigator.maybeOf(context, rootNavigator: true);
    if (nav != null && nav.canPop()) {
      nav.pop();
      return true;
    }

    widget.onEscapeNoRouteToPop?.call();
    return true;
  }

  @override
  Widget build(BuildContext context) => widget.child;
}

class ZEditorApp extends StatefulWidget {
  const ZEditorApp({super.key});

  @override
  State<ZEditorApp> createState() => _ZEditorAppState();
}

class _ZEditorAppState extends State<ZEditorApp> {
  final _leaveObserver = BrowserLeaveProtectionObserver();
  final _editorLeaveOwner = Object();

  @override
  void dispose() {
    _leaveObserver.dispose();
    BrowserLeaveProtection.instance.setActive(_editorLeaveOwner, false);
    super.dispose();
  }

  Future<bool> Function()? _editorBackHandler;

  void _backToLevelList(BuildContext context) {
    context.read<AppNavigationCubit>().backToLevelList();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SettingsCubit, SettingsState>(
      builder: (context, settings) {
        return MaterialApp(
          navigatorObservers: [_leaveObserver],
          title: 'C-Editor',
          debugShowCheckedModeBanner: false,
          scrollBehavior: const PersistentScrollbarScrollBehavior(),
          theme: lightTheme,
          darkTheme: darkTheme,
          themeMode: settings.themeMode,
          locale: settings.locale,
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          builder: (context, child) {
            return AppUiScaler(
              scale: settings.uiScale,
              applyCompactViewportScale: true,
              child: child!,
            );
          },
          home: BlocBuilder<AppNavigationCubit, AppNavigationState>(
            builder: (context, nav) {
              // Editor subtools may hold changes not yet committed to its cubit.
              BrowserLeaveProtection.instance.setActive(
                _editorLeaveOwner,
                nav.screen == AppScreen.editor,
              );
              final appNav = context.read<AppNavigationCubit>();
              return _DesktopEscapeHandler(
                currentScreen: nav.screen,
                onEscapeNoRouteToPop: () {
                  if (nav.screen == AppScreen.levelList) {
                    SystemNavigator.pop();
                  } else if (nav.screen == AppScreen.editor &&
                      _editorBackHandler != null) {
                    _editorBackHandler!().then((leave) {
                      if (leave && mounted) {
                        appNav.backToLevelList();
                      }
                    });
                  } else if (mounted) {
                    appNav.backToLevelList();
                  }
                },
                child: PopScope(
                  canPop: false,
                  onPopInvokedWithResult: (didPop, _) async {
                    if (didPop) return;
                    if (EscapeOverride.tryHandle?.call() == true) return;
                    if (ModalGate.tryAbsorb()) return;
                    if (popRouteAbove(context)) return;
                    final navigator = Navigator.of(
                      context,
                      rootNavigator: true,
                    );
                    if (navigator.canPop()) {
                      navigator.pop();
                      return;
                    }
                    if (nav.screen == AppScreen.levelList) {
                      SystemNavigator.pop();
                    } else if (nav.screen == AppScreen.editor &&
                        _editorBackHandler != null) {
                      final shouldLeave = await _editorBackHandler!();
                      if (shouldLeave && mounted) {
                        appNav.backToLevelList();
                      }
                    } else if (mounted) {
                      appNav.backToLevelList();
                    }
                  },
                  child: _buildCurrentScreen(context, nav),
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildCurrentScreen(BuildContext context, AppNavigationState nav) {
    switch (nav.screen) {
      case AppScreen.levelList:
        return AutomaticAppUpdateCheck(
          child: LevelListScreen(
            returnToLevelPath: nav.lastOpenedLevelPath,
            returnToScrollOffset: nav.levelListScrollOffset,
            returnToViewMode: nav.levelListFavoritesView
                ? LevelViewMode.favorites
                : LevelViewMode.all,
            returnToSearchQuery: nav.levelListSearchQuery,
            showUploadAfterLevelReturn: nav.showUploadAfterLevelReturn,
            onLevelClick:
                (fileName, filePath, scrollOffset, viewMode, searchQuery) {
                  context.read<AppNavigationCubit>().openLevel(
                    fileName,
                    filePath,
                    levelListScrollOffset: scrollOffset,
                    levelListFavoritesView: viewMode == LevelViewMode.favorites,
                    levelListSearchQuery: searchQuery,
                  );
                },
            onAboutClick: () => context.read<AppNavigationCubit>().openAbout(),
            onPluginsClick: () =>
                context.read<AppNavigationCubit>().openPlugins(),
            onLanguageTap: _showLanguageSelector,
          ),
        );
      case AppScreen.editor:
        return BlocProvider(
          key: ValueKey(nav.editorFilePath),
          create: (_) => EditorCubit(
            fileName: nav.editorFileName,
            filePath: nav.editorFilePath,
          )..loadLevel(),
          child: Builder(
            builder: (context) {
              final cubit = context.read<EditorCubit>();
              return _BindActiveEditorSession(
                cubit: cubit,
                child: EditorScreen(
                  onBack: () => _backToLevelList(context),
                  onRegisterBackHandler: (handler) {
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      if (mounted) {
                        setState(() => _editorBackHandler = handler);
                      }
                    });
                  },
                  onLanguageTap: _showLanguageSelector,
                ),
              );
            },
          ),
        );
      case AppScreen.about:
        return AboutScreen(onBack: () => _backToLevelList(context));
      case AppScreen.plugins:
        return PluginsScreen(onBack: () => _backToLevelList(context));
    }
  }

  void _showLanguageSelector(BuildContext context) {
    showAppLanguageSelector(context);
  }
}

/// The language choices remain scrollable even on a short landscape screen.
Future<void> showAppLanguageSelector(BuildContext context) async {
  final l10n = AppLocalizations.of(context);
  final languageTitle = l10n?.language ?? 'Language';
  final languageEnglish = l10n?.languageEnglish ?? 'English';
  final languageChinese = l10n?.languageChinese ?? '中文';
  final languageRussian = l10n?.languageRussian ?? 'Русский';
  await showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    constraints: BoxConstraints(
      maxHeight: MediaQuery.sizeOf(context).height * 0.9,
    ),
    builder: (ctx) => SafeArea(
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                languageTitle,
                style: Theme.of(ctx).textTheme.titleLarge,
              ),
            ),
            EditorOptionTile(
              key: const ValueKey('appLanguage_en'),
              leading: const LocaleFlagIcon('en'),
              title: Text(languageEnglish),
              onTap: () {
                context.read<SettingsCubit>().setLocale(const Locale('en'));
                Navigator.pop(ctx);
              },
            ),
            EditorOptionTile(
              key: const ValueKey('appLanguage_zh'),
              leading: const LocaleFlagIcon('zh'),
              title: Text(languageChinese),
              onTap: () {
                context.read<SettingsCubit>().setLocale(const Locale('zh'));
                Navigator.pop(ctx);
              },
            ),
            EditorOptionTile(
              key: const ValueKey('appLanguage_ru'),
              leading: const LocaleFlagIcon('ru'),
              title: Text(languageRussian),
              onTap: () {
                context.read<SettingsCubit>().setLocale(const Locale('ru'));
                Navigator.pop(ctx);
              },
            ),
          ],
        ),
      ),
    ),
  );
}

/// Binds [EditorCubit] to [ActiveEditorSession] for the plugin host API.
class _BindActiveEditorSession extends StatefulWidget {
  const _BindActiveEditorSession({required this.cubit, required this.child});

  final EditorCubit cubit;
  final Widget child;

  @override
  State<_BindActiveEditorSession> createState() =>
      _BindActiveEditorSessionState();
}

class _BindActiveEditorSessionState extends State<_BindActiveEditorSession> {
  @override
  void initState() {
    super.initState();
    ActiveEditorSession.instance.bind(widget.cubit);
  }

  @override
  void didUpdateWidget(covariant _BindActiveEditorSession oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.cubit != widget.cubit) {
      ActiveEditorSession.instance.clearIf(oldWidget.cubit);
      ActiveEditorSession.instance.bind(widget.cubit);
    }
  }

  @override
  void dispose() {
    ActiveEditorSession.instance.clearIf(widget.cubit);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
