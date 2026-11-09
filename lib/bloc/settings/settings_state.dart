part of 'settings_cubit.dart';

final class SettingsState extends Equatable {
  const SettingsState({
    required this.locale,
    required this.themeMode,
    required this.uiScale,
    this.interfaceMenuActions = const {},
    this.autosaveTargets = const {},
    this.promptForAliasOnCreate = false,
    this.checkForUpdates = true,
  });

  final Locale locale;
  final ThemeMode themeMode;
  final double uiScale;

  final Map<InterfaceMenuSurface, List<InterfaceMenuActionPreference>>
  interfaceMenuActions;

  final Set<AutosaveTarget> autosaveTargets;
  final bool promptForAliasOnCreate;
  final bool checkForUpdates;

  bool get autosave => autosaveTargets.contains(AutosaveTarget.level);
  bool get hasAutosave => autosaveTargets.isNotEmpty;

  List<InterfaceMenuActionPreference> interfaceMenuActionsFor(
    InterfaceMenuSurface surface,
  ) => interfaceMenuActions[surface] ?? defaultInterfaceMenuActions(surface);

  SettingsState copyWith({
    Locale? locale,
    ThemeMode? themeMode,
    double? uiScale,
    Map<InterfaceMenuSurface, List<InterfaceMenuActionPreference>>?
    interfaceMenuActions,
    Set<AutosaveTarget>? autosaveTargets,
    bool? promptForAliasOnCreate,
    bool? checkForUpdates,
  }) {
    return SettingsState(
      locale: locale ?? this.locale,
      themeMode: themeMode ?? this.themeMode,
      uiScale: uiScale ?? this.uiScale,
      interfaceMenuActions: interfaceMenuActions ?? this.interfaceMenuActions,
      autosaveTargets: autosaveTargets ?? this.autosaveTargets,
      promptForAliasOnCreate:
          promptForAliasOnCreate ?? this.promptForAliasOnCreate,
      checkForUpdates: checkForUpdates ?? this.checkForUpdates,
    );
  }

  @override
  List<Object?> get props => [
    locale,
    themeMode,
    uiScale,
    interfaceMenuActions,
    autosaveTargets,
    promptForAliasOnCreate,
    checkForUpdates,
  ];
}
