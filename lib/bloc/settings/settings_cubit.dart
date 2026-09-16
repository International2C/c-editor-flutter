import 'package:c_editor/utils/document_lang.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'settings_state.dart';

class SettingsCubit extends Cubit<SettingsState> {
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
    emit(state.copyWith(themeMode: next));
    _prefs.setString('theme_mode', next == ThemeMode.dark ? 'dark' : 'light');
  }

  void setUiScale(double scale) {
    emit(state.copyWith(uiScale: scale));
    _prefs.setDouble('ui_scale', scale);
  }
}
