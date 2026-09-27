part of 'settings_cubit.dart';

final class SettingsState extends Equatable {
  const SettingsState({
    required this.locale,
    required this.themeMode,
    required this.uiScale,
    this.autosaveTargets = const {},
  });

  final Locale locale;
  final ThemeMode themeMode;
  final double uiScale;

  final Set<AutosaveTarget> autosaveTargets;

  bool get autosave => autosaveTargets.contains(AutosaveTarget.level);
  bool get hasAutosave => autosaveTargets.isNotEmpty;

  SettingsState copyWith({
    Locale? locale,
    ThemeMode? themeMode,
    double? uiScale,
    Set<AutosaveTarget>? autosaveTargets,
  }) {
    return SettingsState(
      locale: locale ?? this.locale,
      themeMode: themeMode ?? this.themeMode,
      uiScale: uiScale ?? this.uiScale,
      autosaveTargets: autosaveTargets ?? this.autosaveTargets,
    );
  }

  @override
  List<Object?> get props => [locale, themeMode, uiScale, autosaveTargets];
}
