import 'package:c_editor/utils/document_lang.dart';
import 'package:c_editor/data/interface_menu_config.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'settings_state.dart';

enum AutosaveTarget {
  level('autosave'),
  zombossAction('autosave_zomboss_action'),
  portal('autosave_portal'),
  resilienceShield('autosave_resilience_shield'),
  previewImage('autosave_preview_image');

  const AutosaveTarget(this.preferenceKey);
  final String preferenceKey;
}

class SettingsCubit extends Cubit<SettingsState> {
  static const promptForAliasOnCreatePreferenceKey =
      'prompt_for_alias_on_create';
  static const checkForUpdatesPreferenceKey = 'check_for_updates';

  SettingsCubit(this._prefs) : super(_initialState(_prefs)) {
    setDocumentLanguage(state.locale.languageCode);
  }

  final SharedPreferences _prefs;

  static SettingsState _initialState(SharedPreferences prefs) {
    final savedLocale = prefs.getString('locale');
    final locale = savedLocale != null
        ? Locale(savedLocale)
        : () {
            const supported = ['en', 'ru', 'zh'];
            final systemCode =
                WidgetsBinding.instance.platformDispatcher.locale.languageCode;
            final code = supported.contains(systemCode) ? systemCode : 'en';
            return Locale(code);
          }();

    final themeModeStr = prefs.getString('theme_mode');
    final ThemeMode themeMode;
    if (themeModeStr == 'dark') {
      themeMode = ThemeMode.dark;
    } else if (themeModeStr == 'light') {
      themeMode = ThemeMode.light;
    } else {
      final brightness =
          WidgetsBinding.instance.platformDispatcher.platformBrightness;
      themeMode = brightness == Brightness.dark
          ? ThemeMode.dark
          : ThemeMode.light;
      prefs.setString(
        'theme_mode',
        themeMode == ThemeMode.dark ? 'dark' : 'light',
      );
    }
    final uiScale = prefs.getDouble('ui_scale') ?? 1.0;
    return SettingsState(
      locale: locale,
      themeMode: themeMode,
      uiScale: uiScale,
      interfaceMenuActions: Map.unmodifiable({
        for (final surface in InterfaceMenuSurface.values)
          surface: decodeInterfaceMenuActions(
            surface,
            prefs.getStringList(interfaceMenuPreferenceKey(surface)),
          ),
      }),
      autosaveTargets: Set.unmodifiable({
        for (final target in AutosaveTarget.values)
          if (prefs.getBool(target.preferenceKey) ?? false) target,
      }),
      promptForAliasOnCreate:
          prefs.getBool(promptForAliasOnCreatePreferenceKey) ?? false,
      checkForUpdates: prefs.getBool(checkForUpdatesPreferenceKey) ?? true,
    );
  }

  void setLocale(Locale locale) {
    emit(state.copyWith(locale: locale));
    _prefs.setString('locale', locale.languageCode);
    setDocumentLanguage(locale.languageCode);
  }

  void cycleTheme() {
    final next = state.themeMode == ThemeMode.dark
        ? ThemeMode.light
        : ThemeMode.dark;
    setThemeMode(next);
  }

  void setThemeMode(ThemeMode mode) {
    if (mode == ThemeMode.system) return;
    emit(state.copyWith(themeMode: mode));
    _prefs.setString('theme_mode', mode == ThemeMode.dark ? 'dark' : 'light');
  }

  void setUiScale(double scale) {
    emit(state.copyWith(uiScale: scale));
    _prefs.setDouble('ui_scale', scale);
  }

  void setAutosave(bool enabled) {
    final targets = {...state.autosaveTargets};
    enabled
        ? targets.add(AutosaveTarget.level)
        : targets.remove(AutosaveTarget.level);
    setAutosaveTargets(targets);
  }

  void setAutosaveTargets(Set<AutosaveTarget> targets) {
    emit(state.copyWith(autosaveTargets: Set.unmodifiable(targets)));
    for (final target in AutosaveTarget.values) {
      _prefs.setBool(target.preferenceKey, targets.contains(target));
    }
  }

  void setPromptForAliasOnCreate(bool enabled) {
    emit(state.copyWith(promptForAliasOnCreate: enabled));
    _prefs.setBool(promptForAliasOnCreatePreferenceKey, enabled);
  }

  void setCheckForUpdates(bool enabled) {
    emit(state.copyWith(checkForUpdates: enabled));
    _prefs.setBool(checkForUpdatesPreferenceKey, enabled);
  }

  void setInterfaceMenuActions(
    InterfaceMenuSurface surface,
    List<InterfaceMenuActionPreference> actions,
  ) {
    final normalized = decodeInterfaceMenuActions(
      surface,
      encodeInterfaceMenuActions(actions),
    );
    emit(
      state.copyWith(
        interfaceMenuActions: Map.unmodifiable({
          ...state.interfaceMenuActions,
          surface: normalized,
        }),
      ),
    );
    _prefs.setStringList(
      interfaceMenuPreferenceKey(surface),
      encodeInterfaceMenuActions(normalized),
    );
  }

  void setInterfaceMenuActionPlacement(
    InterfaceMenuSurface surface,
    String id,
    InterfaceMenuPlacement placement,
  ) {
    final actions = state
        .interfaceMenuActionsFor(surface)
        .map(
          (action) =>
              action.id == id ? action.copyWith(placement: placement) : action,
        )
        .toList(growable: false);
    setInterfaceMenuActions(surface, actions);
  }

  void reorderInterfaceMenuAction(
    InterfaceMenuSurface surface,
    int oldIndex,
    int newIndex,
  ) {
    final actions = state.interfaceMenuActionsFor(surface).toList();
    if (oldIndex < newIndex) newIndex--;
    final item = actions.removeAt(oldIndex);
    actions.insert(newIndex, item);
    setInterfaceMenuActions(surface, actions);
  }

  void resetInterfaceMenuActions(InterfaceMenuSurface surface) {
    setInterfaceMenuActions(surface, defaultInterfaceMenuActions(surface));
  }
}
