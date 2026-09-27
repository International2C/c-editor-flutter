import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_ru.dart';
import 'app_localizations_zh.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('ru'),
    Locale('zh'),
  ];

  /// No description provided for @error.
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get error;

  /// No description provided for @warning.
  ///
  /// In en, this message translates to:
  /// **'Warning'**
  String get warning;

  /// No description provided for @info.
  ///
  /// In en, this message translates to:
  /// **'Info'**
  String get info;

  /// No description provided for @success.
  ///
  /// In en, this message translates to:
  /// **'Success'**
  String get success;

  /// No description provided for @previewTabPlants.
  ///
  /// In en, this message translates to:
  /// **'Plants'**
  String get previewTabPlants;

  /// No description provided for @previewTabZombies.
  ///
  /// In en, this message translates to:
  /// **'Zombies'**
  String get previewTabZombies;

  /// No description provided for @previewTabGridItems.
  ///
  /// In en, this message translates to:
  /// **'Grid Items'**
  String get previewTabGridItems;

  /// No description provided for @overviewPresetPlants.
  ///
  /// In en, this message translates to:
  /// **'Preset plants'**
  String get overviewPresetPlants;

  /// No description provided for @overviewPresetZombies.
  ///
  /// In en, this message translates to:
  /// **'Preset zombies'**
  String get overviewPresetZombies;

  /// No description provided for @overviewConveyorPlants.
  ///
  /// In en, this message translates to:
  /// **'Conveyor plants'**
  String get overviewConveyorPlants;

  /// No description provided for @overviewLawn.
  ///
  /// In en, this message translates to:
  /// **'Lawn'**
  String get overviewLawn;

  /// No description provided for @overviewWhitelist.
  ///
  /// In en, this message translates to:
  /// **'Whitelist'**
  String get overviewWhitelist;

  /// No description provided for @overviewBlacklist.
  ///
  /// In en, this message translates to:
  /// **'Blacklist'**
  String get overviewBlacklist;

  /// No description provided for @overviewPlantBlacklist.
  ///
  /// In en, this message translates to:
  /// **'Plant blacklist'**
  String get overviewPlantBlacklist;

  /// No description provided for @overviewZombieWhitelist.
  ///
  /// In en, this message translates to:
  /// **'Zombie whitelist'**
  String get overviewZombieWhitelist;

  /// No description provided for @overviewSeedChooser.
  ///
  /// In en, this message translates to:
  /// **'Choose your seeds'**
  String get overviewSeedChooser;

  /// No description provided for @overviewReservedColumns.
  ///
  /// In en, this message translates to:
  /// **'Reserved columns'**
  String get overviewReservedColumns;

  /// No description provided for @sunBombFalling.
  ///
  /// In en, this message translates to:
  /// **'Sun Bombs'**
  String get sunBombFalling;

  /// No description provided for @sunDroppingActive.
  ///
  /// In en, this message translates to:
  /// **'Sun falls from the sky'**
  String get sunDroppingActive;

  /// No description provided for @sunDroppingInactive.
  ///
  /// In en, this message translates to:
  /// **'Sun doesn\'t fall from the sky'**
  String get sunDroppingInactive;

  /// No description provided for @conveyorChanges.
  ///
  /// In en, this message translates to:
  /// **'Changes in the conveyor'**
  String get conveyorChanges;

  /// No description provided for @willBeAdded.
  ///
  /// In en, this message translates to:
  /// **'will be added'**
  String get willBeAdded;

  /// No description provided for @willBeRemoved.
  ///
  /// In en, this message translates to:
  /// **'will be removed'**
  String get willBeRemoved;

  /// No description provided for @waveNumberLegend.
  ///
  /// In en, this message translates to:
  /// **'Number indicates the wave number'**
  String get waveNumberLegend;

  /// No description provided for @expand.
  ///
  /// In en, this message translates to:
  /// **'Expand'**
  String get expand;

  /// No description provided for @allZombiesInLevel.
  ///
  /// In en, this message translates to:
  /// **'All zombies in the level'**
  String get allZombiesInLevel;

  /// No description provided for @allObjectsInLevel.
  ///
  /// In en, this message translates to:
  /// **'All grid items in the level'**
  String get allObjectsInLevel;

  /// No description provided for @allEventsInLevel.
  ///
  /// In en, this message translates to:
  /// **'All events in the level'**
  String get allEventsInLevel;

  /// No description provided for @overwhelmLabel.
  ///
  /// In en, this message translates to:
  /// **'Column Like You See \'Em'**
  String get overwhelmLabel;

  /// No description provided for @fastEntryLabel.
  ///
  /// In en, this message translates to:
  /// **'Fast Entry'**
  String get fastEntryLabel;

  /// No description provided for @zombieRushLabel.
  ///
  /// In en, this message translates to:
  /// **'Level Timer'**
  String get zombieRushLabel;

  /// No description provided for @spermWhaleLabel.
  ///
  /// In en, this message translates to:
  /// **'Whale Approaching'**
  String get spermWhaleLabel;

  /// No description provided for @witchLabel.
  ///
  /// In en, this message translates to:
  /// **'Fright Witch'**
  String get witchLabel;

  /// No description provided for @lawnMowerTypeLabel.
  ///
  /// In en, this message translates to:
  /// **'Lawn mower type'**
  String get lawnMowerTypeLabel;

  /// No description provided for @renaissanceStatues.
  ///
  /// In en, this message translates to:
  /// **'Renaissance Statues and Mable Mounds'**
  String get renaissanceStatues;

  /// No description provided for @zomboss.
  ///
  /// In en, this message translates to:
  /// **'Zomboss Mech'**
  String get zomboss;

  /// No description provided for @boss.
  ///
  /// In en, this message translates to:
  /// **'Non-mech Zomboss'**
  String get boss;

  /// No description provided for @zombossData.
  ///
  /// In en, this message translates to:
  /// **'Zomboss Data'**
  String get zombossData;

  /// No description provided for @contentsLabel.
  ///
  /// In en, this message translates to:
  /// **'Contents:'**
  String get contentsLabel;

  /// No description provided for @vaseSpawnArea.
  ///
  /// In en, this message translates to:
  /// **'Vase spawn area'**
  String get vaseSpawnArea;

  /// No description provided for @guessWhoIAm.
  ///
  /// In en, this message translates to:
  /// **'Guess Who I Am'**
  String get guessWhoIAm;

  /// No description provided for @plantBlackList.
  ///
  /// In en, this message translates to:
  /// **'Plant blacklist'**
  String get plantBlackList;

  /// No description provided for @zombieWhiteList.
  ///
  /// In en, this message translates to:
  /// **'Zombie whitelist'**
  String get zombieWhiteList;

  /// No description provided for @zombieWeight.
  ///
  /// In en, this message translates to:
  /// **'Zombie weight'**
  String get zombieWeight;

  /// No description provided for @rainContent.
  ///
  /// In en, this message translates to:
  /// **'Rain content'**
  String get rainContent;

  /// No description provided for @heianWind.
  ///
  /// In en, this message translates to:
  /// **'Heian Divine Wind'**
  String get heianWind;

  /// No description provided for @all.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get all;

  /// No description provided for @impLv.
  ///
  /// In en, this message translates to:
  /// **'Imp level'**
  String get impLv;

  /// No description provided for @sortByLabel.
  ///
  /// In en, this message translates to:
  /// **'Sort'**
  String get sortByLabel;

  /// No description provided for @sortByName.
  ///
  /// In en, this message translates to:
  /// **'Sort: By Name'**
  String get sortByName;

  /// No description provided for @sortByCreationDate.
  ///
  /// In en, this message translates to:
  /// **'Sort: By Creation Date'**
  String get sortByCreationDate;

  /// No description provided for @sortByModificationDate.
  ///
  /// In en, this message translates to:
  /// **'Sort: By Modification Date'**
  String get sortByModificationDate;

  /// No description provided for @sortBySize.
  ///
  /// In en, this message translates to:
  /// **'Sort: By File Size'**
  String get sortBySize;

  /// No description provided for @sortByFileType.
  ///
  /// In en, this message translates to:
  /// **'Sort: By File Type'**
  String get sortByFileType;

  /// No description provided for @impsCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 Imp} other{{count} Imps}}'**
  String impsCount(int count);

  /// No description provided for @dropShip.
  ///
  /// In en, this message translates to:
  /// **'Drop Ship'**
  String get dropShip;

  /// No description provided for @totalLabel.
  ///
  /// In en, this message translates to:
  /// **'Total'**
  String get totalLabel;

  /// No description provided for @totalPlantFoodTooltip.
  ///
  /// In en, this message translates to:
  /// **'Total drops (including Plant Food, seed packet, etc.)'**
  String get totalPlantFoodTooltip;

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'My Workspace'**
  String get appTitle;

  /// No description provided for @about.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get about;

  /// No description provided for @refresh.
  ///
  /// In en, this message translates to:
  /// **'Refresh'**
  String get refresh;

  /// No description provided for @toggleTheme.
  ///
  /// In en, this message translates to:
  /// **'Toggle theme'**
  String get toggleTheme;

  /// No description provided for @switchFolder.
  ///
  /// In en, this message translates to:
  /// **'Switch folder'**
  String get switchFolder;

  /// No description provided for @clearCache.
  ///
  /// In en, this message translates to:
  /// **'Clear cache'**
  String get clearCache;

  /// No description provided for @autosave.
  ///
  /// In en, this message translates to:
  /// **'Autosave'**
  String get autosave;

  /// No description provided for @autosaveOn.
  ///
  /// In en, this message translates to:
  /// **'Autosave: on'**
  String get autosaveOn;

  /// No description provided for @autosaveOff.
  ///
  /// In en, this message translates to:
  /// **'Autosave: off'**
  String get autosaveOff;

  /// No description provided for @autosaveSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Save changes automatically when leaving a level'**
  String get autosaveSubtitle;

  /// No description provided for @ultra.
  ///
  /// In en, this message translates to:
  /// **'Ultra'**
  String get ultra;

  /// No description provided for @uiSize.
  ///
  /// In en, this message translates to:
  /// **'UI size'**
  String get uiSize;

  /// No description provided for @aboutSoftware.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get aboutSoftware;

  /// No description provided for @pluginsTitle.
  ///
  /// In en, this message translates to:
  /// **'Plugins'**
  String get pluginsTitle;

  /// No description provided for @pluginInstallNew.
  ///
  /// In en, this message translates to:
  /// **'Install New Plugin'**
  String get pluginInstallNew;

  /// No description provided for @pluginInstallFromDevice.
  ///
  /// In en, this message translates to:
  /// **'Install from device'**
  String get pluginInstallFromDevice;

  /// No description provided for @pluginInstallFromUrl.
  ///
  /// In en, this message translates to:
  /// **'Install from URL'**
  String get pluginInstallFromUrl;

  /// No description provided for @pluginInstallFromFolder.
  ///
  /// In en, this message translates to:
  /// **'Compile plugin folder (debug)'**
  String get pluginInstallFromFolder;

  /// No description provided for @pluginUrlHint.
  ///
  /// In en, this message translates to:
  /// **'https://example.com/my_plugin.cplugin'**
  String get pluginUrlHint;

  /// No description provided for @pluginDownload.
  ///
  /// In en, this message translates to:
  /// **'Download'**
  String get pluginDownload;

  /// No description provided for @pluginInstalling.
  ///
  /// In en, this message translates to:
  /// **'Installing plugin…'**
  String get pluginInstalling;

  /// No description provided for @pluginDownloadProgress.
  ///
  /// In en, this message translates to:
  /// **'Downloading {received} / {total}'**
  String pluginDownloadProgress(String received, String total);

  /// No description provided for @pluginDownloadProgressUnknown.
  ///
  /// In en, this message translates to:
  /// **'Downloading {received}'**
  String pluginDownloadProgressUnknown(String received);

  /// No description provided for @pluginInstallSuccess.
  ///
  /// In en, this message translates to:
  /// **'Installed {name}'**
  String pluginInstallSuccess(String name);

  /// No description provided for @pluginInstallFailed.
  ///
  /// In en, this message translates to:
  /// **'Install failed: {error}'**
  String pluginInstallFailed(String error);

  /// No description provided for @pluginInvalidFile.
  ///
  /// In en, this message translates to:
  /// **'Not a valid plugin: {reason}'**
  String pluginInvalidFile(String reason);

  /// No description provided for @pluginInvalidUrl.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid http(s) URL'**
  String get pluginInvalidUrl;

  /// No description provided for @pluginReadFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not read the selected file'**
  String get pluginReadFailed;

  /// No description provided for @pluginTrustWarningTitle.
  ///
  /// In en, this message translates to:
  /// **'Safety Notice'**
  String get pluginTrustWarningTitle;

  /// No description provided for @pluginTrustWarningBody.
  ///
  /// In en, this message translates to:
  /// **'Plugins can run code within C-Editor to add more fun and useful features. By default, their access to files and the network is restricted by a sandbox, but malicious plugins may still cause harm. Please install plugins from trusted sources only.'**
  String get pluginTrustWarningBody;

  /// No description provided for @pluginEmpty.
  ///
  /// In en, this message translates to:
  /// **'No plugins installed yet. Install a .cplugin file from your device or a download link.'**
  String get pluginEmpty;

  /// No description provided for @pluginNoScreens.
  ///
  /// In en, this message translates to:
  /// **'This plugin has no features or screens you can jump to directly.'**
  String get pluginNoScreens;

  /// No description provided for @pluginUninstall.
  ///
  /// In en, this message translates to:
  /// **'Uninstall'**
  String get pluginUninstall;

  /// No description provided for @pluginUninstallTitle.
  ///
  /// In en, this message translates to:
  /// **'Uninstall plugin'**
  String get pluginUninstallTitle;

  /// No description provided for @pluginUninstallConfirm.
  ///
  /// In en, this message translates to:
  /// **'Remove {name} from this device?'**
  String pluginUninstallConfirm(String name);

  /// No description provided for @pluginLoadError.
  ///
  /// In en, this message translates to:
  /// **'Failed to load'**
  String get pluginLoadError;

  /// No description provided for @pluginBundledBadge.
  ///
  /// In en, this message translates to:
  /// **'Built-in'**
  String get pluginBundledBadge;

  /// No description provided for @pluginImportedBadge.
  ///
  /// In en, this message translates to:
  /// **'Imported'**
  String get pluginImportedBadge;

  /// No description provided for @pluginsFolderReserved.
  ///
  /// In en, this message translates to:
  /// **'The \".plugins\" and \".plugin_config\" folder names are reserved for editor plugins. Please choose a different name.'**
  String get pluginsFolderReserved;

  /// No description provided for @pluginNoLibraryForInstall.
  ///
  /// In en, this message translates to:
  /// **'Select a workspace folder before installing plugins.'**
  String get pluginNoLibraryForInstall;

  /// No description provided for @pluginShowingCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 installed plugin} other{{count} installed plugins}}'**
  String pluginShowingCount(int count);

  /// No description provided for @pluginSearchHint.
  ///
  /// In en, this message translates to:
  /// **'Search plugins'**
  String get pluginSearchHint;

  /// No description provided for @pluginSelectHint.
  ///
  /// In en, this message translates to:
  /// **'Select a plugin to view details, settings, and features.'**
  String get pluginSelectHint;

  /// No description provided for @pluginEnabled.
  ///
  /// In en, this message translates to:
  /// **'Enabled'**
  String get pluginEnabled;

  /// No description provided for @pluginDisabled.
  ///
  /// In en, this message translates to:
  /// **'Disabled'**
  String get pluginDisabled;

  /// No description provided for @pluginAuthors.
  ///
  /// In en, this message translates to:
  /// **'Authors'**
  String get pluginAuthors;

  /// No description provided for @pluginContributors.
  ///
  /// In en, this message translates to:
  /// **'Contributors'**
  String get pluginContributors;

  /// No description provided for @pluginByAuthors.
  ///
  /// In en, this message translates to:
  /// **'By {authors}'**
  String pluginByAuthors(String authors);

  /// No description provided for @pluginLicense.
  ///
  /// In en, this message translates to:
  /// **'License'**
  String get pluginLicense;

  /// No description provided for @pluginVersionLabel.
  ///
  /// In en, this message translates to:
  /// **'v{version}'**
  String pluginVersionLabel(String version);

  /// No description provided for @pluginIdLabel.
  ///
  /// In en, this message translates to:
  /// **'ID'**
  String get pluginIdLabel;

  /// No description provided for @pluginLinkWebsite.
  ///
  /// In en, this message translates to:
  /// **'Website'**
  String get pluginLinkWebsite;

  /// No description provided for @pluginLinkIssues.
  ///
  /// In en, this message translates to:
  /// **'Issues'**
  String get pluginLinkIssues;

  /// No description provided for @pluginLinkSource.
  ///
  /// In en, this message translates to:
  /// **'Source'**
  String get pluginLinkSource;

  /// No description provided for @pluginLinkDiscord.
  ///
  /// In en, this message translates to:
  /// **'Discord'**
  String get pluginLinkDiscord;

  /// No description provided for @pluginIncompatibleWith.
  ///
  /// In en, this message translates to:
  /// **'Incompatible with'**
  String get pluginIncompatibleWith;

  /// No description provided for @pluginOpenScreen.
  ///
  /// In en, this message translates to:
  /// **'Open'**
  String get pluginOpenScreen;

  /// No description provided for @pluginOpenSettings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get pluginOpenSettings;

  /// No description provided for @pluginInstallAction.
  ///
  /// In en, this message translates to:
  /// **'Install'**
  String get pluginInstallAction;

  /// No description provided for @pluginConfigurable.
  ///
  /// In en, this message translates to:
  /// **'Configurable'**
  String get pluginConfigurable;

  /// No description provided for @pluginFeaturesSection.
  ///
  /// In en, this message translates to:
  /// **'Features & screens'**
  String get pluginFeaturesSection;

  /// No description provided for @pluginNoDescription.
  ///
  /// In en, this message translates to:
  /// **'No description provided.'**
  String get pluginNoDescription;

  /// No description provided for @pluginSettingsUnavailable.
  ///
  /// In en, this message translates to:
  /// **'This plugin has no settings screen.'**
  String get pluginSettingsUnavailable;

  /// No description provided for @share.
  ///
  /// In en, this message translates to:
  /// **'Share'**
  String get share;

  /// The caption text included when sharing a level file via the system share sheet
  ///
  /// In en, this message translates to:
  /// **'Level file: {name}'**
  String shareLevelFileText(String name);

  /// No description provided for @shareLevelFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not share level file'**
  String get shareLevelFailed;

  /// No description provided for @storagePermissionDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Storage Permission Required'**
  String get storagePermissionDialogTitle;

  /// No description provided for @storagePermissionDialogMessage.
  ///
  /// In en, this message translates to:
  /// **'This app requires external storage access to open and save level files. Please turn on \"Allow access to manage all files\" in Settings.'**
  String get storagePermissionDialogMessage;

  /// No description provided for @storagePermissionGoToSettings.
  ///
  /// In en, this message translates to:
  /// **'Go to settings'**
  String get storagePermissionGoToSettings;

  /// No description provided for @storagePermissionDeny.
  ///
  /// In en, this message translates to:
  /// **'Deny'**
  String get storagePermissionDeny;

  /// No description provided for @initSetup.
  ///
  /// In en, this message translates to:
  /// **'Initial setup'**
  String get initSetup;

  /// No description provided for @selectFolderPrompt.
  ///
  /// In en, this message translates to:
  /// **'Please select a folder as the level storage directory.'**
  String get selectFolderPrompt;

  /// No description provided for @selectFolderButton.
  ///
  /// In en, this message translates to:
  /// **'Select folder'**
  String get selectFolderButton;

  /// No description provided for @importFiles.
  ///
  /// In en, this message translates to:
  /// **'Import files'**
  String get importFiles;

  /// No description provided for @importFolder.
  ///
  /// In en, this message translates to:
  /// **'Import folder'**
  String get importFolder;

  /// No description provided for @importFolderEmpty.
  ///
  /// In en, this message translates to:
  /// **'No level files found in the selected folder'**
  String get importFolderEmpty;

  /// No description provided for @importFolderSuccess.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{Imported 1 file} other{Imported {count} files}}'**
  String importFolderSuccess(int count);

  /// No description provided for @importFilesUnreadable.
  ///
  /// In en, this message translates to:
  /// **'Could not read the selected file(s). Try smaller files or a different browser.'**
  String get importFilesUnreadable;

  /// No description provided for @importFolderUnsupported.
  ///
  /// In en, this message translates to:
  /// **'Folder import is not supported in this browser.'**
  String get importFolderUnsupported;

  /// No description provided for @smartUploadTitle.
  ///
  /// In en, this message translates to:
  /// **'Duplicate file'**
  String get smartUploadTitle;

  /// No description provided for @smartUploadFileMessage.
  ///
  /// In en, this message translates to:
  /// **'This file already exists in your workspace:\n\n{fileName}\n\nWhat should be done?'**
  String smartUploadFileMessage(String fileName);

  /// No description provided for @smartUploadSkip.
  ///
  /// In en, this message translates to:
  /// **'Don\'t upload'**
  String get smartUploadSkip;

  /// No description provided for @smartUploadOverwrite.
  ///
  /// In en, this message translates to:
  /// **'Overwrite'**
  String get smartUploadOverwrite;

  /// No description provided for @smartUploadAsCopy.
  ///
  /// In en, this message translates to:
  /// **'Upload as copy'**
  String get smartUploadAsCopy;

  /// No description provided for @smartUploadSkipAll.
  ///
  /// In en, this message translates to:
  /// **'Skip all'**
  String get smartUploadSkipAll;

  /// No description provided for @smartUploadOverwriteAll.
  ///
  /// In en, this message translates to:
  /// **'Overwrite all'**
  String get smartUploadOverwriteAll;

  /// No description provided for @smartUploadCopyAll.
  ///
  /// In en, this message translates to:
  /// **'Copy all'**
  String get smartUploadCopyAll;

  /// No description provided for @openFolder.
  ///
  /// In en, this message translates to:
  /// **'Open folder'**
  String get openFolder;

  /// No description provided for @useDefaultLibraryFolder.
  ///
  /// In en, this message translates to:
  /// **'Use default folder'**
  String get useDefaultLibraryFolder;

  /// No description provided for @emptyFolder.
  ///
  /// In en, this message translates to:
  /// **'Folder is empty'**
  String get emptyFolder;

  /// No description provided for @newFolder.
  ///
  /// In en, this message translates to:
  /// **'New folder'**
  String get newFolder;

  /// No description provided for @newLevel.
  ///
  /// In en, this message translates to:
  /// **'New level'**
  String get newLevel;

  /// No description provided for @rename.
  ///
  /// In en, this message translates to:
  /// **'Rename'**
  String get rename;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @copy.
  ///
  /// In en, this message translates to:
  /// **'Copy'**
  String get copy;

  /// No description provided for @download.
  ///
  /// In en, this message translates to:
  /// **'Download'**
  String get download;

  /// No description provided for @downloadAllLevels.
  ///
  /// In en, this message translates to:
  /// **'Download all levels'**
  String get downloadAllLevels;

  /// No description provided for @downloadFolder.
  ///
  /// In en, this message translates to:
  /// **'Download this directory'**
  String get downloadFolder;

  /// No description provided for @exportLevels.
  ///
  /// In en, this message translates to:
  /// **'Level testing mod'**
  String get exportLevels;

  /// No description provided for @exportSelectLevels.
  ///
  /// In en, this message translates to:
  /// **'Select levels to test'**
  String get exportSelectLevels;

  /// No description provided for @exportSelectFile.
  ///
  /// In en, this message translates to:
  /// **'Select a game data package for the testing mod (.rsb.smf)'**
  String get exportSelectFile;

  /// No description provided for @backupRecommendationTitle.
  ///
  /// In en, this message translates to:
  /// **'Backup Recommendation'**
  String get backupRecommendationTitle;

  /// No description provided for @backupRecommendationBody.
  ///
  /// In en, this message translates to:
  /// **'It is recommended to back up your game data package before testing. This can help prevent data loss if the process is interrupted or an error occurs.'**
  String get backupRecommendationBody;

  /// No description provided for @backupAndProceed.
  ///
  /// In en, this message translates to:
  /// **'Backup and Proceed'**
  String get backupAndProceed;

  /// No description provided for @proceedWithoutBackup.
  ///
  /// In en, this message translates to:
  /// **'Proceed Without Backup'**
  String get proceedWithoutBackup;

  /// No description provided for @backupSuffix.
  ///
  /// In en, this message translates to:
  /// **'_copy'**
  String get backupSuffix;

  /// No description provided for @exportNoFilesFound.
  ///
  /// In en, this message translates to:
  /// **'No compatible data packages found (.rsb.smf).'**
  String get exportNoFilesFound;

  /// No description provided for @exportDownloadExternalDynamic.
  ///
  /// In en, this message translates to:
  /// **'Download data package'**
  String get exportDownloadExternalDynamic;

  /// No description provided for @cancelExportTitle.
  ///
  /// In en, this message translates to:
  /// **'Cancel Build'**
  String get cancelExportTitle;

  /// No description provided for @cancelExportMessage.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to cancel building the level testing mod?'**
  String get cancelExportMessage;

  /// No description provided for @exportDisclaimerTitle.
  ///
  /// In en, this message translates to:
  /// **'Risk Warning & Disclaimer'**
  String get exportDisclaimerTitle;

  /// No description provided for @exportDisclaimerBody.
  ///
  /// In en, this message translates to:
  /// **'This feature generates level testing mods by injecting level files into the game\'s data packages (SMF/RSB container files). This process directly modifies the game data of Plants vs. Zombies 2.\n\n• Using this feature to modify game data may violate the game\'s terms of service.\n• It may result in temporary or permanent suspension of your game account.\n• It may lead to game save corruption or data loss.\n• All operations are chosen by the user at their own risk.\n\nThe developes hereby explicitly state:\n\n1. This feature is for learning and research purposes only; any form of game cheating is discouraged.\n2. All consequences resulting from the use of this feature, including but not limited to account bans, data loss, and impaired game experience, are solely the responsibility of the user. The developers assume no direct or indirect liability.\n3. Users should fully understand the associated risks before using this feature and decide for themselves whether to assume these risks.\n4. Continued use indicates that you have read, understood, and agreed to all terms of this disclaimer.'**
  String get exportDisclaimerBody;

  /// No description provided for @exportDisclaimerDoNotShowAgain.
  ///
  /// In en, this message translates to:
  /// **'Do not show by default'**
  String get exportDisclaimerDoNotShowAgain;

  /// No description provided for @importProgressTitle.
  ///
  /// In en, this message translates to:
  /// **'Importing files…'**
  String get importProgressTitle;

  /// No description provided for @exportProgressTitle.
  ///
  /// In en, this message translates to:
  /// **'Exporting files…'**
  String get exportProgressTitle;

  /// No description provided for @exportPackageProgressTitle.
  ///
  /// In en, this message translates to:
  /// **'Exporting data package…'**
  String get exportPackageProgressTitle;

  /// No description provided for @backupProgressTitle.
  ///
  /// In en, this message translates to:
  /// **'Creating backup…'**
  String get backupProgressTitle;

  /// No description provided for @favorite.
  ///
  /// In en, this message translates to:
  /// **'Favorite'**
  String get favorite;

  /// No description provided for @move.
  ///
  /// In en, this message translates to:
  /// **'Move'**
  String get move;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @confirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get confirm;

  /// No description provided for @convert.
  ///
  /// In en, this message translates to:
  /// **'Convert'**
  String get convert;

  /// No description provided for @convertHelpTooltip.
  ///
  /// In en, this message translates to:
  /// **'Convert'**
  String get convertHelpTooltip;

  /// No description provided for @create.
  ///
  /// In en, this message translates to:
  /// **'Create'**
  String get create;

  /// No description provided for @newName.
  ///
  /// In en, this message translates to:
  /// **'New name'**
  String get newName;

  /// No description provided for @folderName.
  ///
  /// In en, this message translates to:
  /// **'Folder name'**
  String get folderName;

  /// No description provided for @confirmDelete.
  ///
  /// In en, this message translates to:
  /// **'Confirm delete'**
  String get confirmDelete;

  /// No description provided for @confirmDeleteMessage.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete \"{name}\"? {detail}'**
  String confirmDeleteMessage(String name, String detail);

  /// No description provided for @folderDeleteDetail.
  ///
  /// In en, this message translates to:
  /// **'If it is a folder, its contents will also be deleted.'**
  String get folderDeleteDetail;

  /// No description provided for @levelDeleteDetail.
  ///
  /// In en, this message translates to:
  /// **'This action cannot be undone.'**
  String get levelDeleteDetail;

  /// No description provided for @confirmDeleteCheckbox.
  ///
  /// In en, this message translates to:
  /// **'I confirm permanent deletion'**
  String get confirmDeleteCheckbox;

  /// No description provided for @renameSuccess.
  ///
  /// In en, this message translates to:
  /// **'Successfully renamed'**
  String get renameSuccess;

  /// No description provided for @renameFail.
  ///
  /// In en, this message translates to:
  /// **'Rename failed, file already exists'**
  String get renameFail;

  /// No description provided for @uploadLevel.
  ///
  /// In en, this message translates to:
  /// **'Upload to Creative Courtyard'**
  String get uploadLevel;

  /// No description provided for @uploadLevelConfirm.
  ///
  /// In en, this message translates to:
  /// **'You are about to leave the editor and open the official Advanced Creative Courtyard Creator Hub website. After signing in with your email account, you can upload JSON level files from the workspace folder to the in-game Creative Courtyard for other players to enjoy. Do you want to continue?'**
  String get uploadLevelConfirm;

  /// No description provided for @back.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get back;

  /// No description provided for @noLevelsFound.
  ///
  /// In en, this message translates to:
  /// **'No levels found'**
  String get noLevelsFound;

  /// No description provided for @searchLevel.
  ///
  /// In en, this message translates to:
  /// **'Search levels...'**
  String get searchLevel;

  /// No description provided for @proceed.
  ///
  /// In en, this message translates to:
  /// **'Proceed'**
  String get proceed;

  /// No description provided for @exportProceed.
  ///
  /// In en, this message translates to:
  /// **'Proceed'**
  String get exportProceed;

  /// No description provided for @exportBegin.
  ///
  /// In en, this message translates to:
  /// **'Begin'**
  String get exportBegin;

  /// No description provided for @exportStatusCreatingRton.
  ///
  /// In en, this message translates to:
  /// **'Creating RTON levels...'**
  String get exportStatusCreatingRton;

  /// No description provided for @exportStatusUnpackingRsb.
  ///
  /// In en, this message translates to:
  /// **'Unpacking RSB...'**
  String get exportStatusUnpackingRsb;

  /// No description provided for @exportStatusUnpackingRsg.
  ///
  /// In en, this message translates to:
  /// **'Unpacking Packages.rsg...'**
  String get exportStatusUnpackingRsg;

  /// No description provided for @exportStatusInjecting.
  ///
  /// In en, this message translates to:
  /// **'Injecting levels...'**
  String get exportStatusInjecting;

  /// No description provided for @exportStatusRepackingRsg.
  ///
  /// In en, this message translates to:
  /// **'Repacking RSG...'**
  String get exportStatusRepackingRsg;

  /// No description provided for @exportStatusRepackingRsb.
  ///
  /// In en, this message translates to:
  /// **'Repacking RSB...'**
  String get exportStatusRepackingRsb;

  /// No description provided for @exportStatusFinalizing.
  ///
  /// In en, this message translates to:
  /// **'Finalizing...'**
  String get exportStatusFinalizing;

  /// No description provided for @exportAssignmentProposalTitle.
  ///
  /// In en, this message translates to:
  /// **'Level Distribution'**
  String get exportAssignmentProposalTitle;

  /// No description provided for @exportDifficultyReplacementNotice.
  ///
  /// In en, this message translates to:
  /// **'If the Normal Mode and Hard/Expert Mode in the target level slot are actually different levels, the editor replaces only the Normal Mode level.'**
  String get exportDifficultyReplacementNotice;

  /// No description provided for @exportWorld.
  ///
  /// In en, this message translates to:
  /// **'World'**
  String get exportWorld;

  /// No description provided for @exportLevelNumber.
  ///
  /// In en, this message translates to:
  /// **'Level Number'**
  String get exportLevelNumber;

  /// No description provided for @exportLevelShort.
  ///
  /// In en, this message translates to:
  /// **'Lvl. {level}'**
  String exportLevelShort(int level);

  /// No description provided for @exportFinish.
  ///
  /// In en, this message translates to:
  /// **'Finish'**
  String get exportFinish;

  /// No description provided for @exportSuccessTitle.
  ///
  /// In en, this message translates to:
  /// **'Build Successful'**
  String get exportSuccessTitle;

  /// No description provided for @exportSuccessMessage.
  ///
  /// In en, this message translates to:
  /// **'The level testing mod has been successfully built at {file}.\nReplace the corresponding game file with the generated data package, then enter your custom level from the original level slot that was replaced.\nNote: 1. Before replacing the file, fully close the game process.\n2. After the replacement and before entering the game, fully close the editor and any file manager currently accessing the target directory.'**
  String exportSuccessMessage(String file);

  /// No description provided for @exportCancelled.
  ///
  /// In en, this message translates to:
  /// **'Build cancelled.'**
  String get exportCancelled;

  /// No description provided for @exportDuplicateAssignment.
  ///
  /// In en, this message translates to:
  /// **'Duplicate assignment: {world} {level}'**
  String exportDuplicateAssignment(String world, int level);

  /// No description provided for @exportAssignmentIncomplete.
  ///
  /// In en, this message translates to:
  /// **'Not all levels assigned'**
  String get exportAssignmentIncomplete;

  /// No description provided for @exportConfirmationTitle.
  ///
  /// In en, this message translates to:
  /// **'Confirm assignments'**
  String get exportConfirmationTitle;

  /// No description provided for @exportConfirmationBody.
  ///
  /// In en, this message translates to:
  /// **'Please verify your assignments before proceeding.'**
  String get exportConfirmationBody;

  /// No description provided for @exportFinalCheckTitle.
  ///
  /// In en, this message translates to:
  /// **'Final Check'**
  String get exportFinalCheckTitle;

  /// No description provided for @exportFinalCheckBody.
  ///
  /// In en, this message translates to:
  /// **'The following levels will be added to the data package under new names:'**
  String get exportFinalCheckBody;

  /// No description provided for @exportTargetArchive.
  ///
  /// In en, this message translates to:
  /// **'The selected levels will be written to {file}'**
  String exportTargetArchive(String file);

  /// No description provided for @exportStart.
  ///
  /// In en, this message translates to:
  /// **'Build Testing Mod'**
  String get exportStart;

  /// No description provided for @exportAssignmentProposalBody.
  ///
  /// In en, this message translates to:
  /// **'The selected levels are validated. Now you should choose which adventure slot each level will occupy in the game.'**
  String get exportAssignmentProposalBody;

  /// No description provided for @copyReferenceOrDeep.
  ///
  /// In en, this message translates to:
  /// **'Copy reference or make a deep copy?'**
  String get copyReferenceOrDeep;

  /// No description provided for @copyReference.
  ///
  /// In en, this message translates to:
  /// **'Copy reference'**
  String get copyReference;

  /// No description provided for @deepCopy.
  ///
  /// In en, this message translates to:
  /// **'Deep copy'**
  String get deepCopy;

  /// No description provided for @comingSoon.
  ///
  /// In en, this message translates to:
  /// **'Coming soon'**
  String get comingSoon;

  /// No description provided for @allLevelsCategory.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get allLevelsCategory;

  /// No description provided for @favoritesCategory.
  ///
  /// In en, this message translates to:
  /// **'Favorites'**
  String get favoritesCategory;

  /// No description provided for @newFolderNameHint.
  ///
  /// In en, this message translates to:
  /// **'Leave empty for default name'**
  String get newFolderNameHint;

  /// No description provided for @emptyFavorites.
  ///
  /// In en, this message translates to:
  /// **'You don\'t have any favorite levels yet'**
  String get emptyFavorites;

  /// No description provided for @copyEventTarget.
  ///
  /// In en, this message translates to:
  /// **'Select target waves'**
  String get copyEventTarget;

  /// No description provided for @targetWaveAlreadyContainsEvent.
  ///
  /// In en, this message translates to:
  /// **'Already contains this event'**
  String get targetWaveAlreadyContainsEvent;

  /// No description provided for @targetWaveIndexHelper.
  ///
  /// In en, this message translates to:
  /// **'When copying references, waves that already contain this event are automatically skipped.'**
  String get targetWaveIndexHelper;

  /// No description provided for @moveToWaveIndex.
  ///
  /// In en, this message translates to:
  /// **'Move to wave number'**
  String get moveToWaveIndex;

  /// No description provided for @invalidWaveIndex.
  ///
  /// In en, this message translates to:
  /// **'Invalid wave number'**
  String get invalidWaveIndex;

  /// No description provided for @renamingFailed.
  ///
  /// In en, this message translates to:
  /// **'Renaming failed'**
  String get renamingFailed;

  /// No description provided for @deleted.
  ///
  /// In en, this message translates to:
  /// **'Deleted'**
  String get deleted;

  /// No description provided for @copyLevel.
  ///
  /// In en, this message translates to:
  /// **'Copy level'**
  String get copyLevel;

  /// No description provided for @newFileName.
  ///
  /// In en, this message translates to:
  /// **'New file name'**
  String get newFileName;

  /// No description provided for @copySuccess.
  ///
  /// In en, this message translates to:
  /// **'Copied successfully'**
  String get copySuccess;

  /// No description provided for @copyFail.
  ///
  /// In en, this message translates to:
  /// **'Copy failed'**
  String get copyFail;

  /// No description provided for @moving.
  ///
  /// In en, this message translates to:
  /// **'Moving: {name}'**
  String moving(String name);

  /// No description provided for @movePrompt.
  ///
  /// In en, this message translates to:
  /// **'Navigate to target folder, then tap Paste'**
  String get movePrompt;

  /// No description provided for @paste.
  ///
  /// In en, this message translates to:
  /// **'Paste'**
  String get paste;

  /// No description provided for @movingSuccess.
  ///
  /// In en, this message translates to:
  /// **'Moved successfully'**
  String get movingSuccess;

  /// No description provided for @movingFail.
  ///
  /// In en, this message translates to:
  /// **'Move failed'**
  String get movingFail;

  /// No description provided for @moveSameFolder.
  ///
  /// In en, this message translates to:
  /// **'Source and destination folders are the same'**
  String get moveSameFolder;

  /// No description provided for @moveFileExistsTitle.
  ///
  /// In en, this message translates to:
  /// **'File already exists'**
  String get moveFileExistsTitle;

  /// No description provided for @moveFileExistsMessage.
  ///
  /// In en, this message translates to:
  /// **'A file with this name already exists in the destination folder.'**
  String get moveFileExistsMessage;

  /// No description provided for @moveOverwrite.
  ///
  /// In en, this message translates to:
  /// **'Overwrite'**
  String get moveOverwrite;

  /// No description provided for @fileOverwritten.
  ///
  /// In en, this message translates to:
  /// **'File was overwritten: {name}'**
  String fileOverwritten(String name);

  /// No description provided for @moveSaveAsCopy.
  ///
  /// In en, this message translates to:
  /// **'Save as copy'**
  String get moveSaveAsCopy;

  /// No description provided for @moveCancelled.
  ///
  /// In en, this message translates to:
  /// **'Operation cancelled'**
  String get moveCancelled;

  /// No description provided for @movedAs.
  ///
  /// In en, this message translates to:
  /// **'Moved and saved as {name}'**
  String movedAs(String name);

  /// No description provided for @folderCreated.
  ///
  /// In en, this message translates to:
  /// **'Folder created'**
  String get folderCreated;

  /// No description provided for @createFail.
  ///
  /// In en, this message translates to:
  /// **'Create failed'**
  String get createFail;

  /// No description provided for @noTemplates.
  ///
  /// In en, this message translates to:
  /// **'No templates found'**
  String get noTemplates;

  /// No description provided for @newLevelTemplate.
  ///
  /// In en, this message translates to:
  /// **'New level - Select template'**
  String get newLevelTemplate;

  /// No description provided for @nameLevel.
  ///
  /// In en, this message translates to:
  /// **'Name level'**
  String get nameLevel;

  /// No description provided for @levelCreated.
  ///
  /// In en, this message translates to:
  /// **'Level created'**
  String get levelCreated;

  /// No description provided for @levelCreateFail.
  ///
  /// In en, this message translates to:
  /// **'Create failed, file already exists'**
  String get levelCreateFail;

  /// No description provided for @templateLoadFail.
  ///
  /// In en, this message translates to:
  /// **'Could not load the selected level template'**
  String get templateLoadFail;

  /// No description provided for @adjustUiSize.
  ///
  /// In en, this message translates to:
  /// **'Adjust UI size'**
  String get adjustUiSize;

  /// No description provided for @currentScale.
  ///
  /// In en, this message translates to:
  /// **'Current scale: {percent}%'**
  String currentScale(String percent);

  /// No description provided for @small.
  ///
  /// In en, this message translates to:
  /// **'Small'**
  String get small;

  /// No description provided for @standard.
  ///
  /// In en, this message translates to:
  /// **'Standard'**
  String get standard;

  /// No description provided for @large.
  ///
  /// In en, this message translates to:
  /// **'Large'**
  String get large;

  /// No description provided for @done.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get done;

  /// No description provided for @reset.
  ///
  /// In en, this message translates to:
  /// **'Reset'**
  String get reset;

  /// No description provided for @cacheCleared.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{Cleared 1 cached file} other{Cleared {count} cached files}}'**
  String cacheCleared(int count);

  /// No description provided for @returnUp.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get returnUp;

  /// No description provided for @convertToJson.
  ///
  /// In en, this message translates to:
  /// **'Convert to JSON'**
  String get convertToJson;

  /// No description provided for @convertToHotUpdateJson.
  ///
  /// In en, this message translates to:
  /// **'Convert to hot update json'**
  String get convertToHotUpdateJson;

  /// No description provided for @convertToEncryptedRton.
  ///
  /// In en, this message translates to:
  /// **'Convert to encrypted rton'**
  String get convertToEncryptedRton;

  /// No description provided for @hujsonFormatDescription.
  ///
  /// In en, this message translates to:
  /// **'Hot-update readable format. Before importing it into the game, please manually change the file extension from .hujson back to .json.'**
  String get hujsonFormatDescription;

  /// No description provided for @rtonFormatDescription.
  ///
  /// In en, this message translates to:
  /// **'Used as level data inside the game\'s data package (dynamic.rsb.smf).'**
  String get rtonFormatDescription;

  /// No description provided for @conversionRequiredTitle.
  ///
  /// In en, this message translates to:
  /// **'Conversion required'**
  String get conversionRequiredTitle;

  /// No description provided for @conversionRequiredMessage.
  ///
  /// In en, this message translates to:
  /// **'This file must be converted to JSON before it can be opened in the editor.'**
  String get conversionRequiredMessage;

  /// No description provided for @convertAction.
  ///
  /// In en, this message translates to:
  /// **'Convert'**
  String get convertAction;

  /// No description provided for @conversionFailed.
  ///
  /// In en, this message translates to:
  /// **'Conversion failed'**
  String get conversionFailed;

  /// No description provided for @convertedMessage.
  ///
  /// In en, this message translates to:
  /// **'Converted: {name}'**
  String convertedMessage(String name);

  /// No description provided for @softwareIntro.
  ///
  /// In en, this message translates to:
  /// **'Software intro'**
  String get softwareIntro;

  /// No description provided for @cEditor.
  ///
  /// In en, this message translates to:
  /// **'C-Editor'**
  String get cEditor;

  /// No description provided for @pvzEditorSubtitle.
  ///
  /// In en, this message translates to:
  /// **'PvZ2C Visual Level Editor'**
  String get pvzEditorSubtitle;

  /// No description provided for @introSection.
  ///
  /// In en, this message translates to:
  /// **'Introduction'**
  String get introSection;

  /// No description provided for @introText.
  ///
  /// In en, this message translates to:
  /// **'C-Editor is a visual level editing tool designed for Plants vs. Zombies 2 (Chinese Version). It aims to simplify editing level JSON files with an intuitive interface.'**
  String get introText;

  /// No description provided for @featuresSection.
  ///
  /// In en, this message translates to:
  /// **'Core features'**
  String get featuresSection;

  /// No description provided for @feature1.
  ///
  /// In en, this message translates to:
  /// **'Modular editing: Organize level modules and events in a modular interface for quick configuration.'**
  String get feature1;

  /// No description provided for @feature2.
  ///
  /// In en, this message translates to:
  /// **'Multi-mode support: Edit I, Zombie, Vasebreaker, Last Stand, Zomboss Battle, and many other level modes.'**
  String get feature2;

  /// No description provided for @feature3.
  ///
  /// In en, this message translates to:
  /// **'Custom injection: Inject and manage custom zombies, custom lawns, and custom Zomboss mechs within a level, including their core properties.'**
  String get feature3;

  /// No description provided for @feature4.
  ///
  /// In en, this message translates to:
  /// **'Smart validation: Automatically detect missing module dependencies, broken references, and other issues to help prevent level crashes.'**
  String get feature4;

  /// No description provided for @feature5.
  ///
  /// In en, this message translates to:
  /// **'Resource previews: Built-in icons for plants, zombies, and grid items provide a clearer, what-you-see-is-what-you-get editing experience.'**
  String get feature5;

  /// No description provided for @usageSection.
  ///
  /// In en, this message translates to:
  /// **'Usage'**
  String get usageSection;

  /// No description provided for @usageTextDesktop.
  ///
  /// In en, this message translates to:
  /// **'1. Directory Setup: On first launch, click the folder icon in the upper-right corner and choose the folder that stores your level JSON files.\n2. Open/Create: Click a level in the list to edit it, or use the button below to create a new level from a template.\n3. Modules: In the editor, use \"Add New Module\" to extend the level with additional features.\n4. Save: When editing is complete, click the save button in the upper-right corner to write the changes back to the original JSON file automatically.\n5. Convert level files: JSON can be converted into hot-update-readable HUJSON (manually change the file extension from .hujson back to .json before importing) or encrypted RTON (used to replace level data in dynamic.rsb.smf).\n6. Plugins: Plugins can run additional code to provide new features and interfaces, enriching the editor experience. In addition to built-in plugins, new plugins can be obtained by installing a local .cplugin file or entering a URL. Features provided by plugins can be enabled or disabled independently.\n7. Click the \"Upload to Creative Courtyard\" button to open the official Plants vs. Zombies 2 Advanced Creative Courtyard Creator Hub. The button is only visible when the level list is at the top.\n8. You can view past officially recommended level IDs and the reasons they were selected on the \"Creative Courtyard · Recommended Levels Showcase\" webpage. Playing these levels not only supports talented level creators but also helps improve your own level design skills.\n9. If you have any questions or need help with advanced level creation, feel free to join the Plants vs. Zombies Discord server and ask in the PvZ2C-Modding channel thread.'**
  String get usageTextDesktop;

  /// No description provided for @usageTextMobile.
  ///
  /// In en, this message translates to:
  /// **'1. Directory Setup: On first launch, tap the folder icon in the upper-right corner and choose the folder that stores your level JSON files.\n2. Open/Create: Tap a level in the list to edit it, or use the button below to create a new level from a template.\n3. Modules: In the editor, use \"Add New Module\" to extend the level with additional features.\n4. Save: When editing is complete, tap the save button in the upper-right corner to write the changes back to the original JSON file automatically.\n5. Convert level files: JSON can be converted into hot-update-readable HUJSON (manually change the file extension from .hujson back to .json before importing) or encrypted RTON (used to replace level data in dynamic.rsb.smf).\n6. Plugins: Plugins can run additional code to provide new features and interfaces, enriching the editor experience. In addition to built-in plugins, new plugins can be obtained by installing a local .cplugin file or entering a URL. Features provided by plugins can be enabled or disabled independently.\n7. Tap the \"Upload to Creative Courtyard\" button to open the official Plants vs. Zombies 2 Advanced Creative Courtyard Creator Hub. The button is only visible when the level list is at the top.\n8. You can view past officially recommended level IDs and the reasons they were selected on the \"Creative Courtyard · Recommended Levels Showcase\" webpage. Playing these levels not only supports talented level creators but also helps improve your own level design skills.\n9. If you have any questions or need help with advanced level creation, feel free to join the Plants vs. Zombies Discord server and ask in the PvZ2C-Modding channel thread.'**
  String get usageTextMobile;

  /// No description provided for @usageRecommendedLevelsLabel.
  ///
  /// In en, this message translates to:
  /// **'Creative Courtyard · Recommended Levels Showcase:'**
  String get usageRecommendedLevelsLabel;

  /// No description provided for @discordInviteLabel.
  ///
  /// In en, this message translates to:
  /// **'Plants vs. Zombies Discord server invite link:'**
  String get discordInviteLabel;

  /// No description provided for @cEditorInviteLabel.
  ///
  /// In en, this message translates to:
  /// **'C-Editor Discord server invite link:'**
  String get cEditorInviteLabel;

  /// No description provided for @creditsSection.
  ///
  /// In en, this message translates to:
  /// **'Credits'**
  String get creditsSection;

  /// No description provided for @authorLabel.
  ///
  /// In en, this message translates to:
  /// **'Authors:'**
  String get authorLabel;

  /// No description provided for @authorName.
  ///
  /// In en, this message translates to:
  /// **'CyberSteve777, Devourdoom, Chara'**
  String get authorName;

  /// No description provided for @thanksLabel.
  ///
  /// In en, this message translates to:
  /// **'Special thanks:'**
  String get thanksLabel;

  /// No description provided for @thanksNames.
  ///
  /// In en, this message translates to:
  /// **'Evilhack28, Rebus, KL12, vi_i_guess, Haruma, nineteendo'**
  String get thanksNames;

  /// No description provided for @sourceLabel.
  ///
  /// In en, this message translates to:
  /// **'GitHub Repository:'**
  String get sourceLabel;

  /// No description provided for @issuesLabel.
  ///
  /// In en, this message translates to:
  /// **'Report Issues:'**
  String get issuesLabel;

  /// No description provided for @zEditorAcknowledgment.
  ///
  /// In en, this message translates to:
  /// **'We would also like to express our sincere gratitude to the creators of Z-Editor. The development of this tool would not have been possible without the foundation they established.'**
  String get zEditorAcknowledgment;

  /// No description provided for @zEditorCreditsSubsection.
  ///
  /// In en, this message translates to:
  /// **'Z-Editor credits'**
  String get zEditorCreditsSubsection;

  /// No description provided for @zEditorAuthorLabel.
  ///
  /// In en, this message translates to:
  /// **'Author:'**
  String get zEditorAuthorLabel;

  /// No description provided for @zEditorAuthorName.
  ///
  /// In en, this message translates to:
  /// **'降维打击'**
  String get zEditorAuthorName;

  /// No description provided for @zEditorThanksLabel.
  ///
  /// In en, this message translates to:
  /// **'Special thanks:'**
  String get zEditorThanksLabel;

  /// No description provided for @zEditorThanksNames.
  ///
  /// In en, this message translates to:
  /// **'星寻、metal海枣、超越自我3333、桃酱、凉沈、小小师、顾小言、PhiLia093、咖啡、不留名'**
  String get zEditorThanksNames;

  /// No description provided for @zEditorQqGroupLabel.
  ///
  /// In en, this message translates to:
  /// **'Z-Editor QQ group:'**
  String get zEditorQqGroupLabel;

  /// No description provided for @tagline.
  ///
  /// In en, this message translates to:
  /// **'Create infinite possibilities'**
  String get tagline;

  /// No description provided for @editorVersion.
  ///
  /// In en, this message translates to:
  /// **'Editor version: {version}'**
  String editorVersion(String version);

  /// No description provided for @supportedGameVersion.
  ///
  /// In en, this message translates to:
  /// **'Supported game version: {version}'**
  String supportedGameVersion(String version);

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @languageEnglish.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get languageEnglish;

  /// No description provided for @languageChinese.
  ///
  /// In en, this message translates to:
  /// **'中文'**
  String get languageChinese;

  /// No description provided for @languageRussian.
  ///
  /// In en, this message translates to:
  /// **'Русский'**
  String get languageRussian;

  /// No description provided for @templateBlankLevel.
  ///
  /// In en, this message translates to:
  /// **'Blank level'**
  String get templateBlankLevel;

  /// No description provided for @templateCardPickExample.
  ///
  /// In en, this message translates to:
  /// **'Regular level template'**
  String get templateCardPickExample;

  /// No description provided for @templateConveyorExample.
  ///
  /// In en, this message translates to:
  /// **'Conveyor-belt level template'**
  String get templateConveyorExample;

  /// No description provided for @templateLastStandExample.
  ///
  /// In en, this message translates to:
  /// **'Last Stand level template'**
  String get templateLastStandExample;

  /// No description provided for @templateIZombieExample.
  ///
  /// In en, this message translates to:
  /// **'I, Zombie level template'**
  String get templateIZombieExample;

  /// No description provided for @templateVaseBreakerExample.
  ///
  /// In en, this message translates to:
  /// **'Vasebreaker level template'**
  String get templateVaseBreakerExample;

  /// No description provided for @templateZombossMechExample.
  ///
  /// In en, this message translates to:
  /// **'Zomboss Mech Battle level template'**
  String get templateZombossMechExample;

  /// No description provided for @templateZombossBattleExample.
  ///
  /// In en, this message translates to:
  /// **'Non-mech Zomboss Battle level template'**
  String get templateZombossBattleExample;

  /// No description provided for @templateCustomZombieExample.
  ///
  /// In en, this message translates to:
  /// **'Custom zombie level template'**
  String get templateCustomZombieExample;

  /// No description provided for @templateIPlantExample.
  ///
  /// In en, this message translates to:
  /// **'I, Plant level template'**
  String get templateIPlantExample;

  /// No description provided for @templateOldStyleExample.
  ///
  /// In en, this message translates to:
  /// **'Wave Generator level template'**
  String get templateOldStyleExample;

  /// No description provided for @templateCustomLawnExample.
  ///
  /// In en, this message translates to:
  /// **'Custom lawn level template'**
  String get templateCustomLawnExample;

  /// No description provided for @unsavedChanges.
  ///
  /// In en, this message translates to:
  /// **'Unsaved changes'**
  String get unsavedChanges;

  /// No description provided for @saveBeforeLeaving.
  ///
  /// In en, this message translates to:
  /// **'Save before leaving?'**
  String get saveBeforeLeaving;

  /// No description provided for @discard.
  ///
  /// In en, this message translates to:
  /// **'Discard'**
  String get discard;

  /// No description provided for @stayInEditor.
  ///
  /// In en, this message translates to:
  /// **'Stay'**
  String get stayInEditor;

  /// No description provided for @saved.
  ///
  /// In en, this message translates to:
  /// **'Saved'**
  String get saved;

  /// No description provided for @failedToLoadLevel.
  ///
  /// In en, this message translates to:
  /// **'Failed to load the level.\nWe recommend checking whether the level file is encrypted (for example, a JSON file used by hot updates).'**
  String get failedToLoadLevel;

  /// No description provided for @noLevelDefinition.
  ///
  /// In en, this message translates to:
  /// **'No level definition'**
  String get noLevelDefinition;

  /// No description provided for @noLevelDefinitionHint.
  ///
  /// In en, this message translates to:
  /// **'Level definition module (LevelDefinition) was not found. This is the base node of the level file. Try adding it manually.'**
  String get noLevelDefinitionHint;

  /// No description provided for @levelBasicInfo.
  ///
  /// In en, this message translates to:
  /// **'Basic Information'**
  String get levelBasicInfo;

  /// No description provided for @levelBasicInfoSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Name, Index, Description, Lawn'**
  String get levelBasicInfoSubtitle;

  /// No description provided for @removeModule.
  ///
  /// In en, this message translates to:
  /// **'Remove module'**
  String get removeModule;

  /// No description provided for @zombieCategoryMain.
  ///
  /// In en, this message translates to:
  /// **'By World'**
  String get zombieCategoryMain;

  /// No description provided for @zombieCategorySize.
  ///
  /// In en, this message translates to:
  /// **'By Size'**
  String get zombieCategorySize;

  /// No description provided for @zombieCategoryOther.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get zombieCategoryOther;

  /// No description provided for @zombieCategoryCollection.
  ///
  /// In en, this message translates to:
  /// **'My Collection'**
  String get zombieCategoryCollection;

  /// No description provided for @zombieTagAll.
  ///
  /// In en, this message translates to:
  /// **'All Zombies'**
  String get zombieTagAll;

  /// No description provided for @zombieTagEgyptPirate.
  ///
  /// In en, this message translates to:
  /// **'Ancient Egypt / Pirate Seas'**
  String get zombieTagEgyptPirate;

  /// No description provided for @zombieTagWestFuture.
  ///
  /// In en, this message translates to:
  /// **'Wild West / Far Future'**
  String get zombieTagWestFuture;

  /// No description provided for @zombieTagDarkBeach.
  ///
  /// In en, this message translates to:
  /// **'Dark Ages / Big Wave Beach'**
  String get zombieTagDarkBeach;

  /// No description provided for @zombieTagIceageLostcity.
  ///
  /// In en, this message translates to:
  /// **'Frostbite Caves / Lost City'**
  String get zombieTagIceageLostcity;

  /// No description provided for @zombieTagKongfuSkycity.
  ///
  /// In en, this message translates to:
  /// **'Kongfu World / Sky City'**
  String get zombieTagKongfuSkycity;

  /// No description provided for @zombieTagEightiesDino.
  ///
  /// In en, this message translates to:
  /// **'Neon Mixtape Tour / Jurassic Marsh'**
  String get zombieTagEightiesDino;

  /// No description provided for @zombieTagModernPvz1.
  ///
  /// In en, this message translates to:
  /// **'Modern Day / PvZ1'**
  String get zombieTagModernPvz1;

  /// No description provided for @zombieTagSteamRenai.
  ///
  /// In en, this message translates to:
  /// **'Steam Ages / Renaissance Ages'**
  String get zombieTagSteamRenai;

  /// No description provided for @zombieTagHeianAtlantis.
  ///
  /// In en, this message translates to:
  /// **'Heian Ages / Underwater World'**
  String get zombieTagHeianAtlantis;

  /// No description provided for @zombieTagMoon.
  ///
  /// In en, this message translates to:
  /// **'Moon BaseZ'**
  String get zombieTagMoon;

  /// No description provided for @zombieTagTaleZCorp.
  ///
  /// In en, this message translates to:
  /// **'Fairy Forest / Zombie Corporation'**
  String get zombieTagTaleZCorp;

  /// No description provided for @zombieTagParkourSpeed.
  ///
  /// In en, this message translates to:
  /// **'Parkour Party / Speed Racing'**
  String get zombieTagParkourSpeed;

  /// No description provided for @zombieTagTothewest.
  ///
  /// In en, this message translates to:
  /// **'Journey to the West / Underground Palace'**
  String get zombieTagTothewest;

  /// No description provided for @zombieTagMemory.
  ///
  /// In en, this message translates to:
  /// **'Memory Lane'**
  String get zombieTagMemory;

  /// No description provided for @zombieTagUniverse.
  ///
  /// In en, this message translates to:
  /// **'Parallel Universe'**
  String get zombieTagUniverse;

  /// No description provided for @zombieTagFestival1.
  ///
  /// In en, this message translates to:
  /// **'Festival 1'**
  String get zombieTagFestival1;

  /// No description provided for @zombieTagFestival2.
  ///
  /// In en, this message translates to:
  /// **'Festival 2'**
  String get zombieTagFestival2;

  /// No description provided for @zombieTagRoman.
  ///
  /// In en, this message translates to:
  /// **'Roman Empire'**
  String get zombieTagRoman;

  /// No description provided for @zombieTagCustom.
  ///
  /// In en, this message translates to:
  /// **'Memory Lane Variants'**
  String get zombieTagCustom;

  /// No description provided for @zombieTagExpedition.
  ///
  /// In en, this message translates to:
  /// **'Expedition Gate Variants'**
  String get zombieTagExpedition;

  /// No description provided for @zombieTagPvp.
  ///
  /// In en, this message translates to:
  /// **'Two-Player Mode Variants'**
  String get zombieTagPvp;

  /// No description provided for @zombieTagPet.
  ///
  /// In en, this message translates to:
  /// **'Pet'**
  String get zombieTagPet;

  /// No description provided for @zombieTagImp.
  ///
  /// In en, this message translates to:
  /// **'Imp'**
  String get zombieTagImp;

  /// No description provided for @zombieTagBasic.
  ///
  /// In en, this message translates to:
  /// **'Basic'**
  String get zombieTagBasic;

  /// No description provided for @zombieTagFat.
  ///
  /// In en, this message translates to:
  /// **'Fat'**
  String get zombieTagFat;

  /// No description provided for @zombieTagStrong.
  ///
  /// In en, this message translates to:
  /// **'Bully'**
  String get zombieTagStrong;

  /// No description provided for @zombieTagGargantuar.
  ///
  /// In en, this message translates to:
  /// **'Gargantuar'**
  String get zombieTagGargantuar;

  /// No description provided for @zombieTagElite.
  ///
  /// In en, this message translates to:
  /// **'Elite'**
  String get zombieTagElite;

  /// No description provided for @zombieTagEvildave.
  ///
  /// In en, this message translates to:
  /// **'Compatible with IZ'**
  String get zombieTagEvildave;

  /// No description provided for @plantCategoryQuality.
  ///
  /// In en, this message translates to:
  /// **'By Quality'**
  String get plantCategoryQuality;

  /// No description provided for @plantCategoryRole.
  ///
  /// In en, this message translates to:
  /// **'By Role'**
  String get plantCategoryRole;

  /// No description provided for @plantCategoryAttribute.
  ///
  /// In en, this message translates to:
  /// **'By Attribute'**
  String get plantCategoryAttribute;

  /// No description provided for @plantCategoryWorld.
  ///
  /// In en, this message translates to:
  /// **'By World'**
  String get plantCategoryWorld;

  /// No description provided for @plantCategoryOther.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get plantCategoryOther;

  /// No description provided for @plantCategoryCollection.
  ///
  /// In en, this message translates to:
  /// **'My Favorites'**
  String get plantCategoryCollection;

  /// No description provided for @plantTagAll.
  ///
  /// In en, this message translates to:
  /// **'All Plants'**
  String get plantTagAll;

  /// No description provided for @plantTagWhite.
  ///
  /// In en, this message translates to:
  /// **'White Quality'**
  String get plantTagWhite;

  /// No description provided for @plantTagGreen.
  ///
  /// In en, this message translates to:
  /// **'Green Quality'**
  String get plantTagGreen;

  /// No description provided for @plantTagBlue.
  ///
  /// In en, this message translates to:
  /// **'Blue Quality'**
  String get plantTagBlue;

  /// No description provided for @plantTagPurple.
  ///
  /// In en, this message translates to:
  /// **'Purple Quality'**
  String get plantTagPurple;

  /// No description provided for @plantTagOrange.
  ///
  /// In en, this message translates to:
  /// **'Orange Quality'**
  String get plantTagOrange;

  /// No description provided for @plantTagRed.
  ///
  /// In en, this message translates to:
  /// **'Red Quality'**
  String get plantTagRed;

  /// No description provided for @plantTagSupport.
  ///
  /// In en, this message translates to:
  /// **'Support'**
  String get plantTagSupport;

  /// No description provided for @plantTagRanger.
  ///
  /// In en, this message translates to:
  /// **'Ranged'**
  String get plantTagRanger;

  /// No description provided for @plantTagSunProducer.
  ///
  /// In en, this message translates to:
  /// **'Sun'**
  String get plantTagSunProducer;

  /// No description provided for @plantTagDefence.
  ///
  /// In en, this message translates to:
  /// **'Tough'**
  String get plantTagDefence;

  /// No description provided for @plantTagVanguard.
  ///
  /// In en, this message translates to:
  /// **'Vanguard'**
  String get plantTagVanguard;

  /// No description provided for @plantTagTrapper.
  ///
  /// In en, this message translates to:
  /// **'Special'**
  String get plantTagTrapper;

  /// No description provided for @plantTagFire.
  ///
  /// In en, this message translates to:
  /// **'Fire'**
  String get plantTagFire;

  /// No description provided for @plantTagIce.
  ///
  /// In en, this message translates to:
  /// **'Ice'**
  String get plantTagIce;

  /// No description provided for @plantTagMagic.
  ///
  /// In en, this message translates to:
  /// **'Magic'**
  String get plantTagMagic;

  /// No description provided for @plantTagPoison.
  ///
  /// In en, this message translates to:
  /// **'Poison'**
  String get plantTagPoison;

  /// No description provided for @plantTagElectric.
  ///
  /// In en, this message translates to:
  /// **'Electric'**
  String get plantTagElectric;

  /// No description provided for @plantTagPhysical.
  ///
  /// In en, this message translates to:
  /// **'Physical'**
  String get plantTagPhysical;

  /// No description provided for @plantTagWorldTutorial.
  ///
  /// In en, this message translates to:
  /// **'Tutorial'**
  String get plantTagWorldTutorial;

  /// No description provided for @plantTagWorldEgypt.
  ///
  /// In en, this message translates to:
  /// **'Ancient Egypt'**
  String get plantTagWorldEgypt;

  /// No description provided for @plantTagWorldPirate.
  ///
  /// In en, this message translates to:
  /// **'Pirate Seas'**
  String get plantTagWorldPirate;

  /// No description provided for @plantTagWorldWildWest.
  ///
  /// In en, this message translates to:
  /// **'Wild West'**
  String get plantTagWorldWildWest;

  /// No description provided for @plantTagWorldKongfu.
  ///
  /// In en, this message translates to:
  /// **'Kongfu World'**
  String get plantTagWorldKongfu;

  /// No description provided for @plantTagWorldFuture.
  ///
  /// In en, this message translates to:
  /// **'Far Future'**
  String get plantTagWorldFuture;

  /// No description provided for @plantTagWorldDarkAges.
  ///
  /// In en, this message translates to:
  /// **'Dark Ages'**
  String get plantTagWorldDarkAges;

  /// No description provided for @plantTagWorldBeach.
  ///
  /// In en, this message translates to:
  /// **'Big Wave Beach'**
  String get plantTagWorldBeach;

  /// No description provided for @plantTagWorldIceage.
  ///
  /// In en, this message translates to:
  /// **'Frostbite Caves'**
  String get plantTagWorldIceage;

  /// No description provided for @plantTagWorldSkycity.
  ///
  /// In en, this message translates to:
  /// **'Sky City'**
  String get plantTagWorldSkycity;

  /// No description provided for @plantTagWorldLostCity.
  ///
  /// In en, this message translates to:
  /// **'Lost City'**
  String get plantTagWorldLostCity;

  /// No description provided for @plantTagWorldEighties.
  ///
  /// In en, this message translates to:
  /// **'Neon Mixtape Tour'**
  String get plantTagWorldEighties;

  /// No description provided for @plantTagWorldDino.
  ///
  /// In en, this message translates to:
  /// **'Jurassic Marsh'**
  String get plantTagWorldDino;

  /// No description provided for @plantTagWorldModern.
  ///
  /// In en, this message translates to:
  /// **'Modern Day'**
  String get plantTagWorldModern;

  /// No description provided for @plantTagWorldSteam.
  ///
  /// In en, this message translates to:
  /// **'Steam Ages'**
  String get plantTagWorldSteam;

  /// No description provided for @plantTagWorldRenai.
  ///
  /// In en, this message translates to:
  /// **'Renaissance Ages'**
  String get plantTagWorldRenai;

  /// No description provided for @plantTagWorldHeian.
  ///
  /// In en, this message translates to:
  /// **'Heian Ages'**
  String get plantTagWorldHeian;

  /// No description provided for @plantTagWorldAtlantis.
  ///
  /// In en, this message translates to:
  /// **'Underwater World'**
  String get plantTagWorldAtlantis;

  /// No description provided for @plantTagWorldMoon.
  ///
  /// In en, this message translates to:
  /// **'Moon BaseZ'**
  String get plantTagWorldMoon;

  /// No description provided for @plantTagWorldFairytale.
  ///
  /// In en, this message translates to:
  /// **'Fairy Forest'**
  String get plantTagWorldFairytale;

  /// No description provided for @plantTagWorldZcorp.
  ///
  /// In en, this message translates to:
  /// **'Zombie Corporation'**
  String get plantTagWorldZcorp;

  /// No description provided for @plantTagWorldMausoleum.
  ///
  /// In en, this message translates to:
  /// **'Underground Palace'**
  String get plantTagWorldMausoleum;

  /// No description provided for @plantTagOriginal.
  ///
  /// In en, this message translates to:
  /// **'PvZ1 Plants'**
  String get plantTagOriginal;

  /// No description provided for @plantTagParallel.
  ///
  /// In en, this message translates to:
  /// **'Parallel Universe'**
  String get plantTagParallel;

  /// No description provided for @plantTagSpecial.
  ///
  /// In en, this message translates to:
  /// **'Magic Hats'**
  String get plantTagSpecial;

  /// No description provided for @plantTagHidden.
  ///
  /// In en, this message translates to:
  /// **'Hidden Plants'**
  String get plantTagHidden;

  /// No description provided for @plantTagTier4.
  ///
  /// In en, this message translates to:
  /// **'Level 4 Village'**
  String get plantTagTier4;

  /// No description provided for @plantTagInternational.
  ///
  /// In en, this message translates to:
  /// **'International'**
  String get plantTagInternational;

  /// No description provided for @plantTagChinese.
  ///
  /// In en, this message translates to:
  /// **'China Only'**
  String get plantTagChinese;

  /// No description provided for @removeModuleConfirm.
  ///
  /// In en, this message translates to:
  /// **'Remove this module? Local custom modules (@CurrentLevel) and their data will be deleted permanently.'**
  String get removeModuleConfirm;

  /// No description provided for @confirmRemove.
  ///
  /// In en, this message translates to:
  /// **'Remove'**
  String get confirmRemove;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @timeline.
  ///
  /// In en, this message translates to:
  /// **'Wave Timeline'**
  String get timeline;

  /// No description provided for @iZombie.
  ///
  /// In en, this message translates to:
  /// **'I, Zombie'**
  String get iZombie;

  /// No description provided for @vaseBreaker.
  ///
  /// In en, this message translates to:
  /// **'Vasebreaker'**
  String get vaseBreaker;

  /// No description provided for @zombossMech.
  ///
  /// In en, this message translates to:
  /// **'Zomboss Mech Battle'**
  String get zombossMech;

  /// No description provided for @zombossBattle.
  ///
  /// In en, this message translates to:
  /// **'Non-mech Zomboss Battle'**
  String get zombossBattle;

  /// No description provided for @rootFolder.
  ///
  /// In en, this message translates to:
  /// **'Root'**
  String get rootFolder;

  /// No description provided for @createEmptyWaveContainer.
  ///
  /// In en, this message translates to:
  /// **'Create empty wave container'**
  String get createEmptyWaveContainer;

  /// No description provided for @deleteEmptyContainer.
  ///
  /// In en, this message translates to:
  /// **'Delete empty container'**
  String get deleteEmptyContainer;

  /// No description provided for @deleteWaveContainerTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete wave container'**
  String get deleteWaveContainerTitle;

  /// No description provided for @deleteWaveContainerConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete the empty wave container? You can create a new one later.'**
  String get deleteWaveContainerConfirm;

  /// No description provided for @noWaveManager.
  ///
  /// In en, this message translates to:
  /// **'Wave Container Not Found'**
  String get noWaveManager;

  /// No description provided for @noWaveManagerHint.
  ///
  /// In en, this message translates to:
  /// **'Wave management is enabled, but the entity object (WaveManagerProperties) is missing. Please create an empty wave container.'**
  String get noWaveManagerHint;

  /// No description provided for @waveTimelineGuideTitle.
  ///
  /// In en, this message translates to:
  /// **'Operation Guide'**
  String get waveTimelineGuideTitle;

  /// No description provided for @waveTimelineGuideBodyDesktop.
  ///
  /// In en, this message translates to:
  /// **'Left-click a wave: Manage wave events\nLong-press an event: Drag to reorder or move waves\nClick points: View spawn expectations'**
  String get waveTimelineGuideBodyDesktop;

  /// No description provided for @waveTimelineGuideBodyMobile.
  ///
  /// In en, this message translates to:
  /// **'Tap a wave: Manage events\nLong-press an event: Drag to reorder or move waves\nTap points: View spawn expectations'**
  String get waveTimelineGuideBodyMobile;

  /// No description provided for @waveDeadLinksTitle.
  ///
  /// In en, this message translates to:
  /// **'Broken References'**
  String get waveDeadLinksTitle;

  /// No description provided for @waveDeadLinksClear.
  ///
  /// In en, this message translates to:
  /// **'Clear dead links'**
  String get waveDeadLinksClear;

  /// No description provided for @customZombieManagerTitle.
  ///
  /// In en, this message translates to:
  /// **'Custom Zombie Management'**
  String get customZombieManagerTitle;

  /// No description provided for @customZombieEmpty.
  ///
  /// In en, this message translates to:
  /// **'No custom zombie data'**
  String get customZombieEmpty;

  /// No description provided for @switchCustomZombie.
  ///
  /// In en, this message translates to:
  /// **'Switch custom zombie'**
  String get switchCustomZombie;

  /// No description provided for @switchProperties.
  ///
  /// In en, this message translates to:
  /// **'Switch properties'**
  String get switchProperties;

  /// No description provided for @defaultPropertiesLabel.
  ///
  /// In en, this message translates to:
  /// **'Default'**
  String get defaultPropertiesLabel;

  /// No description provided for @addNewVariation.
  ///
  /// In en, this message translates to:
  /// **'+ Add new variation'**
  String get addNewVariation;

  /// No description provided for @editCustomZombieAlias.
  ///
  /// In en, this message translates to:
  /// **'Edit {alias}'**
  String editCustomZombieAlias(String alias);

  /// No description provided for @switchZombie.
  ///
  /// In en, this message translates to:
  /// **'Switch zombie'**
  String get switchZombie;

  /// No description provided for @customZombieAppearanceLocation.
  ///
  /// In en, this message translates to:
  /// **'Location:'**
  String get customZombieAppearanceLocation;

  /// No description provided for @customZombieNotUsed.
  ///
  /// In en, this message translates to:
  /// **'This custom zombie is currently not used by any wave or module.'**
  String get customZombieNotUsed;

  /// No description provided for @customZombieWaveItem.
  ///
  /// In en, this message translates to:
  /// **'Wave {n}'**
  String customZombieWaveItem(int n);

  /// No description provided for @customZombieDeleteConfirm.
  ///
  /// In en, this message translates to:
  /// **'Remove this custom zombie entity and its property data.'**
  String get customZombieDeleteConfirm;

  /// No description provided for @customZombieOrphanDeleteTitle.
  ///
  /// In en, this message translates to:
  /// **'Erase custom properties from level?'**
  String get customZombieOrphanDeleteTitle;

  /// No description provided for @customZombieOrphanDeleteMessage.
  ///
  /// In en, this message translates to:
  /// **'\"{alias}\" will have no remaining uses in this level. Remove its zombie type and property objects from the level file? This cannot be undone.'**
  String customZombieOrphanDeleteMessage(String alias);

  /// No description provided for @customZombieOrphanDeleteKeep.
  ///
  /// In en, this message translates to:
  /// **'Keep in level'**
  String get customZombieOrphanDeleteKeep;

  /// No description provided for @customZombieOrphanDeleteErase.
  ///
  /// In en, this message translates to:
  /// **'Erase from level'**
  String get customZombieOrphanDeleteErase;

  /// No description provided for @customLabel.
  ///
  /// In en, this message translates to:
  /// **'Custom'**
  String get customLabel;

  /// No description provided for @moduleTitle_WaveManagerProperties.
  ///
  /// In en, this message translates to:
  /// **'Linked Wave Parameters (WaveManagerProps)'**
  String get moduleTitle_WaveManagerProperties;

  /// No description provided for @waveManagerPropsCurrent.
  ///
  /// In en, this message translates to:
  /// **'Current: {value}'**
  String waveManagerPropsCurrent(String value);

  /// No description provided for @waveManagerGlobalParams.
  ///
  /// In en, this message translates to:
  /// **'Wave Manager Parameters'**
  String get waveManagerGlobalParams;

  /// No description provided for @waveContainerAliasSection.
  ///
  /// In en, this message translates to:
  /// **'Wave container alias'**
  String get waveContainerAliasSection;

  /// No description provided for @waveContainerAliasHint.
  ///
  /// In en, this message translates to:
  /// **'The alias used in the level file for the WaveManagerProperties object that stores wave data. It generally does not need to be changed manually.'**
  String get waveContainerAliasHint;

  /// No description provided for @waveManagerGlobalSummary.
  ///
  /// In en, this message translates to:
  /// **'Flag interval: {interval}, Next wave health threshold: {minPercent}% - {maxPercent}%'**
  String waveManagerGlobalSummary(int interval, int minPercent, int maxPercent);

  /// No description provided for @waveEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No waves yet'**
  String get waveEmptyTitle;

  /// No description provided for @waveEmptySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Add the first wave, or remove this empty container.'**
  String get waveEmptySubtitle;

  /// No description provided for @waveHeaderPreview.
  ///
  /// In en, this message translates to:
  /// **'Content & Points Preview'**
  String get waveHeaderPreview;

  /// No description provided for @waveTotalLabel.
  ///
  /// In en, this message translates to:
  /// **'Total: {total}'**
  String waveTotalLabel(int total);

  /// No description provided for @waveEmptyRowHintDesktop.
  ///
  /// In en, this message translates to:
  /// **'Empty wave (click to manage, drop events here)'**
  String get waveEmptyRowHintDesktop;

  /// No description provided for @waveEmptyRowHintMobile.
  ///
  /// In en, this message translates to:
  /// **'Empty wave (tap to manage, drop events here)'**
  String get waveEmptyRowHintMobile;

  /// No description provided for @removeFromWave.
  ///
  /// In en, this message translates to:
  /// **'Remove from wave'**
  String get removeFromWave;

  /// No description provided for @waveEventsTitle.
  ///
  /// In en, this message translates to:
  /// **'Wave {wave} events'**
  String waveEventsTitle(int wave);

  /// No description provided for @waveManagerSettings.
  ///
  /// In en, this message translates to:
  /// **'Wave Manager Settings'**
  String get waveManagerSettings;

  /// No description provided for @flagInterval.
  ///
  /// In en, this message translates to:
  /// **'Flag interval'**
  String get flagInterval;

  /// No description provided for @waveManagerHelpTitle.
  ///
  /// In en, this message translates to:
  /// **'Wave Manager module'**
  String get waveManagerHelpTitle;

  /// No description provided for @waveManagerHelpOverviewTitle.
  ///
  /// In en, this message translates to:
  /// **'Overview'**
  String get waveManagerHelpOverviewTitle;

  /// No description provided for @waveManagerHelpOverviewBody.
  ///
  /// In en, this message translates to:
  /// **'The wave event container organizes level events by wave order. Most levels use it to control zombie spawning. This page allows you to adjust its global settings.'**
  String get waveManagerHelpOverviewBody;

  /// No description provided for @waveManagerHelpFlagTitle.
  ///
  /// In en, this message translates to:
  /// **'Flag interval'**
  String get waveManagerHelpFlagTitle;

  /// No description provided for @waveManagerHelpFlagBody.
  ///
  /// In en, this message translates to:
  /// **'The flag interval determines how often a flag wave appears. The final wave is always a flag wave. Flag waves receive bonus points and have a separate spawn interval.'**
  String get waveManagerHelpFlagBody;

  /// No description provided for @waveManagerHelpTimeTitle.
  ///
  /// In en, this message translates to:
  /// **'Time control'**
  String get waveManagerHelpTimeTitle;

  /// No description provided for @waveManagerHelpTimeBody.
  ///
  /// In en, this message translates to:
  /// **'The delay before the first wave depends on whether the level uses a conveyor belt: 5 seconds with a conveyor, or 12 seconds without. Flag wave delay refers to the time between the red warning message and zombie spawn.'**
  String get waveManagerHelpTimeBody;

  /// No description provided for @waveManagerFirstWaveDelayConveyorOnlyHint.
  ///
  /// In en, this message translates to:
  /// **'Currently, editing first wave delay only affects conveyor belt levels; regular levels use the default value.'**
  String get waveManagerFirstWaveDelayConveyorOnlyHint;

  /// No description provided for @waveManagerFirstWaveDelayConveyorOnlyHelp.
  ///
  /// In en, this message translates to:
  /// **'Currently, editing first wave delay only affects conveyor belt evels; regular levels use the default value.'**
  String get waveManagerFirstWaveDelayConveyorOnlyHelp;

  /// No description provided for @waveManagerHelpMusicTitle.
  ///
  /// In en, this message translates to:
  /// **'Level Jam'**
  String get waveManagerHelpMusicTitle;

  /// No description provided for @waveManagerHelpMusicBody.
  ///
  /// In en, this message translates to:
  /// **'This setting applies only to the Modern Day world. It sets a fixed global background track that enables abilities for certain Neon Mixtape Tour zombies.'**
  String get waveManagerHelpMusicBody;

  /// No description provided for @waveManagerBasicParams.
  ///
  /// In en, this message translates to:
  /// **'Basic parameters'**
  String get waveManagerBasicParams;

  /// No description provided for @waveManagerMaxHealthThreshold.
  ///
  /// In en, this message translates to:
  /// **'Max next wave health threshold'**
  String get waveManagerMaxHealthThreshold;

  /// No description provided for @waveManagerMinHealthThreshold.
  ///
  /// In en, this message translates to:
  /// **'Min next wave health threshold'**
  String get waveManagerMinHealthThreshold;

  /// No description provided for @waveManagerThresholdHint.
  ///
  /// In en, this message translates to:
  /// **'Threshold must be between 0 and 1. When the total remaining health of zombies in the current wave falls below this value, the next wave will spawn automatically.'**
  String get waveManagerThresholdHint;

  /// No description provided for @waveManagerTimeControl.
  ///
  /// In en, this message translates to:
  /// **'Time control'**
  String get waveManagerTimeControl;

  /// No description provided for @waveManagerFirstWaveDelayConveyor.
  ///
  /// In en, this message translates to:
  /// **'First wave delay (conveyor; seconds)'**
  String get waveManagerFirstWaveDelayConveyor;

  /// No description provided for @waveManagerFirstWaveDelayNormal.
  ///
  /// In en, this message translates to:
  /// **'First wave delay (normal; seconds)'**
  String get waveManagerFirstWaveDelayNormal;

  /// No description provided for @waveManagerFlagWaveDelay.
  ///
  /// In en, this message translates to:
  /// **'Flag wave delay (seconds)'**
  String get waveManagerFlagWaveDelay;

  /// No description provided for @waveManagerConveyorDetected.
  ///
  /// In en, this message translates to:
  /// **'Conveyor module detected; conveyor delay applied.'**
  String get waveManagerConveyorDetected;

  /// No description provided for @waveManagerConveyorNotDetected.
  ///
  /// In en, this message translates to:
  /// **'No conveyor module; normal delay applied.'**
  String get waveManagerConveyorNotDetected;

  /// No description provided for @waveManagerSpecial.
  ///
  /// In en, this message translates to:
  /// **'Special'**
  String get waveManagerSpecial;

  /// No description provided for @waveManagerSuppressFlagZombieTitle.
  ///
  /// In en, this message translates to:
  /// **'Suppress flag zombie'**
  String get waveManagerSuppressFlagZombieTitle;

  /// No description provided for @waveManagerSuppressFlagZombieField.
  ///
  /// In en, this message translates to:
  /// **'SuppressFlagZombie'**
  String get waveManagerSuppressFlagZombieField;

  /// No description provided for @waveManagerSuppressFlagZombieHint.
  ///
  /// In en, this message translates to:
  /// **'When enabled, flag waves won’t spawn a flag zombie.'**
  String get waveManagerSuppressFlagZombieHint;

  /// No description provided for @waveManagerLevelJam.
  ///
  /// In en, this message translates to:
  /// **'Level Jam'**
  String get waveManagerLevelJam;

  /// No description provided for @waveManagerLevelJamHint.
  ///
  /// In en, this message translates to:
  /// **'Only applies to Modern Day; provides fixed global background track.'**
  String get waveManagerLevelJamHint;

  /// No description provided for @jamNone.
  ///
  /// In en, this message translates to:
  /// **'None'**
  String get jamNone;

  /// No description provided for @jamPop.
  ///
  /// In en, this message translates to:
  /// **'Pop'**
  String get jamPop;

  /// No description provided for @jamRap.
  ///
  /// In en, this message translates to:
  /// **'Rap'**
  String get jamRap;

  /// No description provided for @jamMetal.
  ///
  /// In en, this message translates to:
  /// **'Metal'**
  String get jamMetal;

  /// No description provided for @jamPunk.
  ///
  /// In en, this message translates to:
  /// **'Punk'**
  String get jamPunk;

  /// No description provided for @jam8Bit.
  ///
  /// In en, this message translates to:
  /// **'8-Bit'**
  String get jam8Bit;

  /// No description provided for @deleteWave.
  ///
  /// In en, this message translates to:
  /// **'Delete wave'**
  String get deleteWave;

  /// No description provided for @deleteWaveConfirm.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{This will remove this wave and its 1 event.} other{This will remove this wave and its {count} events.}}'**
  String deleteWaveConfirm(int count);

  /// No description provided for @deleteWaveConfirmCheckbox.
  ///
  /// In en, this message translates to:
  /// **'I confirm permanent deletion of this wave'**
  String get deleteWaveConfirmCheckbox;

  /// No description provided for @addEvent.
  ///
  /// In en, this message translates to:
  /// **'Add event'**
  String get addEvent;

  /// No description provided for @reuseExistingEvent.
  ///
  /// In en, this message translates to:
  /// **'Reuse event'**
  String get reuseExistingEvent;

  /// No description provided for @reuseExistingEventForWave.
  ///
  /// In en, this message translates to:
  /// **'Reuse event for wave {wave}'**
  String reuseExistingEventForWave(int wave);

  /// No description provided for @reuseExistingEventEmpty.
  ///
  /// In en, this message translates to:
  /// **'No events in this level yet'**
  String get reuseExistingEventEmpty;

  /// No description provided for @reuseExistingEventUnused.
  ///
  /// In en, this message translates to:
  /// **'Not used in any wave'**
  String get reuseExistingEventUnused;

  /// No description provided for @reuseExistingEventUsedInWaves.
  ///
  /// In en, this message translates to:
  /// **'Waves: {waves}'**
  String reuseExistingEventUsedInWaves(String waves);

  /// No description provided for @emptyWave.
  ///
  /// In en, this message translates to:
  /// **'Empty wave'**
  String get emptyWave;

  /// No description provided for @addWave.
  ///
  /// In en, this message translates to:
  /// **'Add wave'**
  String get addWave;

  /// No description provided for @expectation.
  ///
  /// In en, this message translates to:
  /// **'Expectation'**
  String get expectation;

  /// No description provided for @close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// No description provided for @levelOverview.
  ///
  /// In en, this message translates to:
  /// **'Level Overview'**
  String get levelOverview;

  /// No description provided for @levelOverviewOpenLevel.
  ///
  /// In en, this message translates to:
  /// **'Open level'**
  String get levelOverviewOpenLevel;

  /// No description provided for @previewStartingPlantFood.
  ///
  /// In en, this message translates to:
  /// **'Starting Plant Food'**
  String get previewStartingPlantFood;

  /// No description provided for @previewPrePlaced.
  ///
  /// In en, this message translates to:
  /// **'Preset Layout'**
  String get previewPrePlaced;

  /// No description provided for @previewRegularPlants.
  ///
  /// In en, this message translates to:
  /// **'Regular Plants'**
  String get previewRegularPlants;

  /// No description provided for @previewFrozenPlants.
  ///
  /// In en, this message translates to:
  /// **'Frozen Plants'**
  String get previewFrozenPlants;

  /// No description provided for @previewLevelContent.
  ///
  /// In en, this message translates to:
  /// **'Level Content'**
  String get previewLevelContent;

  /// No description provided for @previewSeedBank.
  ///
  /// In en, this message translates to:
  /// **'Seed Bank'**
  String get previewSeedBank;

  /// No description provided for @previewIZombieSeedBank.
  ///
  /// In en, this message translates to:
  /// **'Seed Bank (I, Zombie)'**
  String get previewIZombieSeedBank;

  /// No description provided for @previewFeatures.
  ///
  /// In en, this message translates to:
  /// **'Level Features'**
  String get previewFeatures;

  /// No description provided for @previewActiveModules.
  ///
  /// In en, this message translates to:
  /// **'Active Modules'**
  String get previewActiveModules;

  /// No description provided for @previewInitial.
  ///
  /// In en, this message translates to:
  /// **'Initial Grid Items'**
  String get previewInitial;

  /// No description provided for @previewGenerateImagePreview.
  ///
  /// In en, this message translates to:
  /// **'Generate preview image'**
  String get previewGenerateImagePreview;

  /// No description provided for @editProperties.
  ///
  /// In en, this message translates to:
  /// **'Edit properties'**
  String get editProperties;

  /// No description provided for @deleteEntity.
  ///
  /// In en, this message translates to:
  /// **'Delete entity'**
  String get deleteEntity;

  /// No description provided for @deleteObjectTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete object?'**
  String get deleteObjectTitle;

  /// No description provided for @deleteObjectConfirmMessage.
  ///
  /// In en, this message translates to:
  /// **'Remove this object from the level file? This action cannot be undone.'**
  String get deleteObjectConfirmMessage;

  /// No description provided for @objectDeleted.
  ///
  /// In en, this message translates to:
  /// **'Object deleted'**
  String get objectDeleted;

  /// No description provided for @moduleEditorInProgress.
  ///
  /// In en, this message translates to:
  /// **'Module editor in development'**
  String get moduleEditorInProgress;

  /// No description provided for @saveFail.
  ///
  /// In en, this message translates to:
  /// **'Save failed'**
  String get saveFail;

  /// No description provided for @confirmRemoveRef.
  ///
  /// In en, this message translates to:
  /// **'Remove reference'**
  String get confirmRemoveRef;

  /// No description provided for @confirmRemoveRefMessage.
  ///
  /// In en, this message translates to:
  /// **'Remove this reference? The entity data will remain until all references are removed.'**
  String get confirmRemoveRefMessage;

  /// No description provided for @code.
  ///
  /// In en, this message translates to:
  /// **'Code'**
  String get code;

  /// No description provided for @name.
  ///
  /// In en, this message translates to:
  /// **'Level name'**
  String get name;

  /// No description provided for @levelNumber.
  ///
  /// In en, this message translates to:
  /// **'Level number'**
  String get levelNumber;

  /// No description provided for @startingSun.
  ///
  /// In en, this message translates to:
  /// **'Starting Sun'**
  String get startingSun;

  /// No description provided for @startingPlantfood.
  ///
  /// In en, this message translates to:
  /// **'Starting Plant Food'**
  String get startingPlantfood;

  /// No description provided for @stageModule.
  ///
  /// In en, this message translates to:
  /// **'Lawn module'**
  String get stageModule;

  /// No description provided for @musicType.
  ///
  /// In en, this message translates to:
  /// **'Music type'**
  String get musicType;

  /// No description provided for @loot.
  ///
  /// In en, this message translates to:
  /// **'Loot'**
  String get loot;

  /// No description provided for @victoryModule.
  ///
  /// In en, this message translates to:
  /// **'Victory module'**
  String get victoryModule;

  /// No description provided for @basicInfoSection.
  ///
  /// In en, this message translates to:
  /// **'Basic info'**
  String get basicInfoSection;

  /// No description provided for @sceneSettingsSection.
  ///
  /// In en, this message translates to:
  /// **'Scene Settings'**
  String get sceneSettingsSection;

  /// No description provided for @restrictionsSection.
  ///
  /// In en, this message translates to:
  /// **'Restrictions'**
  String get restrictionsSection;

  /// No description provided for @victoryModuleWarning.
  ///
  /// In en, this message translates to:
  /// **'Using non-default victory modules may cause level crashes due to module conflicts. Use with caution.'**
  String get victoryModuleWarning;

  /// No description provided for @beatTheLevelDialogHint.
  ///
  /// In en, this message translates to:
  /// **'Supports Chinese; for multi-line text enter newlines directly, no need for \\n. Note: hints cannot be viewed in Creative Courtyard on iOS.'**
  String get beatTheLevelDialogHint;

  /// No description provided for @missingModules.
  ///
  /// In en, this message translates to:
  /// **'Missing modules'**
  String get missingModules;

  /// No description provided for @conflictTitle_ModuleLogic.
  ///
  /// In en, this message translates to:
  /// **'Module logic conflict'**
  String get conflictTitle_ModuleLogic;

  /// No description provided for @conflictDefaultDescription.
  ///
  /// In en, this message translates to:
  /// **'{module1} and {module2} conflict logically. It is recommended to keep only one.'**
  String conflictDefaultDescription(String module1, String module2);

  /// No description provided for @conflictDesc_SeedBankConveyor.
  ///
  /// In en, this message translates to:
  /// **'Seed Bank and Conveyor modules interfere with each other\'s UI and may cause crashes. Ensure Seed Bank is in Preset mode.'**
  String get conflictDesc_SeedBankConveyor;

  /// No description provided for @conflictDesc_VaseBreakerIntro.
  ///
  /// In en, this message translates to:
  /// **'Vasebreaker mode does not need an opening intro.'**
  String get conflictDesc_VaseBreakerIntro;

  /// No description provided for @conflictDesc_LastStandIntro.
  ///
  /// In en, this message translates to:
  /// **'Last Stand mode does not need an opening intro.'**
  String get conflictDesc_LastStandIntro;

  /// No description provided for @conflictDesc_CowboyIntro.
  ///
  /// In en, this message translates to:
  /// **'Not OK Corral conflicts with the Intro Animation module. Using them together will cause the zombie preview and transition effect at the start of the level to behave incorrectly.'**
  String get conflictDesc_CowboyIntro;

  /// No description provided for @conflictDesc_SingleHandedIntro.
  ///
  /// In en, this message translates to:
  /// **'All by Oneself conflicts with the Intro Animation module. Using them together will cause the transition effect at the start of the level to behave incorrectly.'**
  String get conflictDesc_SingleHandedIntro;

  /// No description provided for @conflictDesc_SingleHandedTutorialIntro.
  ///
  /// In en, this message translates to:
  /// **'The All by Oneself Tutorial conflicts with the Intro Animation module. Using them together will cause the transition effect at the start of the level to behave incorrectly.'**
  String get conflictDesc_SingleHandedTutorialIntro;

  /// No description provided for @conflictDesc_EvilDaveZombieDrop.
  ///
  /// In en, this message translates to:
  /// **'I, Zombie mode cannot have Zombie Drop module.'**
  String get conflictDesc_EvilDaveZombieDrop;

  /// No description provided for @conflictDesc_EvilDaveVictory.
  ///
  /// In en, this message translates to:
  /// **'I, Zombie mode cannot have Zombie Victory Condition.'**
  String get conflictDesc_EvilDaveVictory;

  /// No description provided for @conflictDesc_ZombossDeathDrop.
  ///
  /// In en, this message translates to:
  /// **'Loot Drop in Zomboss Mech Battle mode will prevent proper level completion.'**
  String get conflictDesc_ZombossDeathDrop;

  /// No description provided for @conflictDesc_WinConditionExclusive.
  ///
  /// In en, this message translates to:
  /// **'Loot Drop and Bronze Matrix Loot Drop do not need to be used together. It is recommended to remove one of them.'**
  String get conflictDesc_WinConditionExclusive;

  /// No description provided for @conflictDesc_ZombossTwoIntros.
  ///
  /// In en, this message translates to:
  /// **'Two level opening intros cannot coexist, otherwise Zomboss health bar will not display correctly.'**
  String get conflictDesc_ZombossTwoIntros;

  /// No description provided for @conflictDesc_InitialPlantEntryRoof.
  ///
  /// In en, this message translates to:
  /// **'Pre-place plants on the roof will cause a crash.'**
  String get conflictDesc_InitialPlantEntryRoof;

  /// No description provided for @conflictDesc_InitialPlantRoof.
  ///
  /// In en, this message translates to:
  /// **'Legacy preset plants on the roof will cause a crash.'**
  String get conflictDesc_InitialPlantRoof;

  /// No description provided for @conflictDesc_ProtectPlantRoof.
  ///
  /// In en, this message translates to:
  /// **'Endangered plants on the roof will cause a crash.'**
  String get conflictDesc_ProtectPlantRoof;

  /// No description provided for @conflictDesc_LawnMowerYard.
  ///
  /// In en, this message translates to:
  /// **'Lawn mowers are ineffective when the Creative Courtyard module is enabled.'**
  String get conflictDesc_LawnMowerYard;

  /// No description provided for @conflictDesc_MoonExpertYard.
  ///
  /// In en, this message translates to:
  /// **'The Moon Expert module has no effect when the Creative Courtyard module is enabled.'**
  String get conflictDesc_MoonExpertYard;

  /// No description provided for @conflictDesc_WaveGeneratorWaveManagerModule.
  ///
  /// In en, this message translates to:
  /// **'Wave Generator and Wave Manager module cannot coexist — they are two different wave systems.'**
  String get conflictDesc_WaveGeneratorWaveManagerModule;

  /// No description provided for @conflictDesc_WaveGeneratorWaveManager.
  ///
  /// In en, this message translates to:
  /// **'Wave Generator embeds waves directly and cannot be used with a separate Wave Manager container.'**
  String get conflictDesc_WaveGeneratorWaveManager;

  /// No description provided for @conflictDesc_CamelMinigameNonTouchZombies.
  ///
  /// In en, this message translates to:
  /// **'Mummy Memory only supports the special Mummy Memory Camel Zombies. Other zombies were detected: {zombies}. Their appearance in the level will crash the game. Replace or remove them.'**
  String conflictDesc_CamelMinigameNonTouchZombies(String zombies);

  /// No description provided for @targetZombieRequiresOakTrain.
  ///
  /// In en, this message translates to:
  /// **'Oak Archery’s exclusive zombies work best with their dedicated module. Add Oak Archery to the level.'**
  String get targetZombieRequiresOakTrain;

  /// No description provided for @conflictDesc_CamelMinigameIntro.
  ///
  /// In en, this message translates to:
  /// **'Mummy Memory conflicts with the Standard Intro module. Using both causes abnormal transition effects at the start of the level.'**
  String get conflictDesc_CamelMinigameIntro;

  /// No description provided for @targetZombieInWaveManagerWarningTitle.
  ///
  /// In en, this message translates to:
  /// **'Zombie compatibility warning'**
  String get targetZombieInWaveManagerWarningTitle;

  /// No description provided for @targetZombieInWaveManagerWarning.
  ///
  /// In en, this message translates to:
  /// **'Oak Archery’s exclusive zombies cannot use their abilities in regular Wave Manager events such as Basic Spawner and Underwater Spawner. Use Ground Spawner or custom zombies to achieve similar effects.'**
  String get targetZombieInWaveManagerWarning;

  /// No description provided for @oakTrainUnderwaterWarningTitle.
  ///
  /// In en, this message translates to:
  /// **'Lawn compatibility warning'**
  String get oakTrainUnderwaterWarningTitle;

  /// No description provided for @oakTrainUnderwaterWarning.
  ///
  /// In en, this message translates to:
  /// **'The base lawn is set to Underwater World or Moon BaseZ, so the Oak Archer provided by Oak Archery may not survive. Pre-place Oxygen Algae or Moss Tiles as needed.'**
  String get oakTrainUnderwaterWarning;

  /// No description provided for @waveGeneratorRiseFromGroundWarningTitle.
  ///
  /// In en, this message translates to:
  /// **'Spawn behavior warning'**
  String get waveGeneratorRiseFromGroundWarningTitle;

  /// No description provided for @waveGeneratorRiseFromGroundWarning.
  ///
  /// In en, this message translates to:
  /// **'With Rise from Ground (IsRiseFromGroundMode) enabled, most spawned zombies cannot move or use their abilities. If only a row is specified without a spawn position, that row is ignored and the zombie always spawns in the first tile of the first row. Use random rows or set explicit spawn positions.'**
  String get waveGeneratorRiseFromGroundWarning;

  /// No description provided for @missingPlantModuleWarningTitle.
  ///
  /// In en, this message translates to:
  /// **'Missing module for parallel universe plants'**
  String get missingPlantModuleWarningTitle;

  /// No description provided for @editableModules.
  ///
  /// In en, this message translates to:
  /// **'Editable modules'**
  String get editableModules;

  /// No description provided for @parameterModules.
  ///
  /// In en, this message translates to:
  /// **'Parameter modules'**
  String get parameterModules;

  /// No description provided for @addNewModule.
  ///
  /// In en, this message translates to:
  /// **'Add new module'**
  String get addNewModule;

  /// No description provided for @selectStage.
  ///
  /// In en, this message translates to:
  /// **'Select lawn'**
  String get selectStage;

  /// No description provided for @searchStage.
  ///
  /// In en, this message translates to:
  /// **'Search by lawn name or codename'**
  String get searchStage;

  /// No description provided for @noStageFound.
  ///
  /// In en, this message translates to:
  /// **'No lawn found'**
  String get noStageFound;

  /// No description provided for @stageTypeAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get stageTypeAll;

  /// No description provided for @stageTypeMain.
  ///
  /// In en, this message translates to:
  /// **'Main'**
  String get stageTypeMain;

  /// No description provided for @stageTypeExtra.
  ///
  /// In en, this message translates to:
  /// **'Extra'**
  String get stageTypeExtra;

  /// No description provided for @stageTypeSeasons.
  ///
  /// In en, this message translates to:
  /// **'Seasons'**
  String get stageTypeSeasons;

  /// No description provided for @stageTypeSpecial.
  ///
  /// In en, this message translates to:
  /// **'Special'**
  String get stageTypeSpecial;

  /// No description provided for @stageTypeCustomPresets.
  ///
  /// In en, this message translates to:
  /// **'Custom Presets'**
  String get stageTypeCustomPresets;

  /// No description provided for @search.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get search;

  /// No description provided for @disablePeavine.
  ///
  /// In en, this message translates to:
  /// **'Disable Pea Vine\'s Pea Symbiosis'**
  String get disablePeavine;

  /// No description provided for @disableArtifact.
  ///
  /// In en, this message translates to:
  /// **'Disable Artifact (auto-applied when Creative Courtyard module is enabled)'**
  String get disableArtifact;

  /// No description provided for @selectPlant.
  ///
  /// In en, this message translates to:
  /// **'Select plant'**
  String get selectPlant;

  /// No description provided for @selectAll.
  ///
  /// In en, this message translates to:
  /// **'Select ALL'**
  String get selectAll;

  /// No description provided for @searchPlant.
  ///
  /// In en, this message translates to:
  /// **'Search plant'**
  String get searchPlant;

  /// No description provided for @noPlantFound.
  ///
  /// In en, this message translates to:
  /// **'No plant found'**
  String get noPlantFound;

  /// No description provided for @noResultsFor.
  ///
  /// In en, this message translates to:
  /// **'No results for \"{query}\"'**
  String noResultsFor(String query);

  /// No description provided for @noModulesInCategory.
  ///
  /// In en, this message translates to:
  /// **'No modules in this category'**
  String get noModulesInCategory;

  /// No description provided for @noEventsInCategory.
  ///
  /// In en, this message translates to:
  /// **'No events in this category'**
  String get noEventsInCategory;

  /// No description provided for @eventCategoryZombieSpawn.
  ///
  /// In en, this message translates to:
  /// **'Zombie spawn'**
  String get eventCategoryZombieSpawn;

  /// No description provided for @eventCategoryGridItemSpawn.
  ///
  /// In en, this message translates to:
  /// **'Grid item spawn'**
  String get eventCategoryGridItemSpawn;

  /// No description provided for @eventCategoryEnvironmental.
  ///
  /// In en, this message translates to:
  /// **'Environmental'**
  String get eventCategoryEnvironmental;

  /// No description provided for @eventCategoryOther.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get eventCategoryOther;

  /// No description provided for @addEventForWave.
  ///
  /// In en, this message translates to:
  /// **'Add event for wave {wave}'**
  String addEventForWave(int wave);

  /// No description provided for @waveLabel.
  ///
  /// In en, this message translates to:
  /// **'Wave'**
  String get waveLabel;

  /// No description provided for @pointsLabel.
  ///
  /// In en, this message translates to:
  /// **'Points'**
  String get pointsLabel;

  /// No description provided for @wavePointsShort.
  ///
  /// In en, this message translates to:
  /// **'{points} pts.'**
  String wavePointsShort(int points);

  /// No description provided for @noDynamicZombies.
  ///
  /// In en, this message translates to:
  /// **'No dynamic zombies'**
  String get noDynamicZombies;

  /// No description provided for @moduleTitle_WaveManagerModuleProperties.
  ///
  /// In en, this message translates to:
  /// **'Wave Manager'**
  String get moduleTitle_WaveManagerModuleProperties;

  /// No description provided for @moduleDesc_WaveManagerModuleProperties.
  ///
  /// In en, this message translates to:
  /// **'Manages overall wave event configuration for the level'**
  String get moduleDesc_WaveManagerModuleProperties;

  /// No description provided for @moduleTitle_WaveGeneratorProperties.
  ///
  /// In en, this message translates to:
  /// **'Wave Generator'**
  String get moduleTitle_WaveGeneratorProperties;

  /// No description provided for @moduleDesc_WaveGeneratorProperties.
  ///
  /// In en, this message translates to:
  /// **'Legacy wave format used by Kongfu World and other early levels'**
  String get moduleDesc_WaveGeneratorProperties;

  /// No description provided for @moduleTitle_CustomLevelModuleProperties.
  ///
  /// In en, this message translates to:
  /// **'Creative Courtyard Module'**
  String get moduleTitle_CustomLevelModuleProperties;

  /// No description provided for @moduleDesc_CustomLevelModuleProperties.
  ///
  /// In en, this message translates to:
  /// **'Enables Creative Courtyard features (likes, rewards, costume feature disabling, etc.)'**
  String get moduleDesc_CustomLevelModuleProperties;

  /// No description provided for @powerTileModuleRequiredTitle.
  ///
  /// In en, this message translates to:
  /// **'Power Tiles module required'**
  String get powerTileModuleRequiredTitle;

  /// No description provided for @powerTileModuleRequiredBody.
  ///
  /// In en, this message translates to:
  /// **'Adding Power Tile tool packets requires the level to include the Power Tile module. Add the module and continue?'**
  String get powerTileModuleRequiredBody;

  /// No description provided for @conveyorPlantWearCostume.
  ///
  /// In en, this message translates to:
  /// **'Display costume (iAvatar; no longer works)'**
  String get conveyorPlantWearCostume;

  /// No description provided for @conveyorPlantWearCostumeTooltip.
  ///
  /// In en, this message translates to:
  /// **'When enabled, this plant’s packet on the conveyor belt will display its costume. This feature does not work in the current version.'**
  String get conveyorPlantWearCostumeTooltip;

  /// No description provided for @modifyConveyorAddPoolTitle.
  ///
  /// In en, this message translates to:
  /// **'Add to Conveyor Pool'**
  String get modifyConveyorAddPoolTitle;

  /// No description provided for @modifyConveyorAddPoolEmpty.
  ///
  /// In en, this message translates to:
  /// **'The list is empty. Please add plants or tool packets.'**
  String get modifyConveyorAddPoolEmpty;

  /// No description provided for @modifyConveyorRemovePoolTitle.
  ///
  /// In en, this message translates to:
  /// **'Remove from Conveyor Pool (doesn\'t work when Creative Courtyard module is enabled)'**
  String get modifyConveyorRemovePoolTitle;

  /// No description provided for @modifyConveyorEntryEditTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit parameters'**
  String get modifyConveyorEntryEditTitle;

  /// No description provided for @plantModuleRequiredMessage.
  ///
  /// In en, this message translates to:
  /// **'In order to select this plant, {moduleName} needs to be added.'**
  String plantModuleRequiredMessage(String moduleName);

  /// No description provided for @zombieModuleRequiredMessage.
  ///
  /// In en, this message translates to:
  /// **'In order to select this zombie, {moduleName} needs to be added.'**
  String zombieModuleRequiredMessage(String moduleName);

  /// No description provided for @realmExclusivePlantChooserBlockedTitle.
  ///
  /// In en, this message translates to:
  /// **'Cannot select this plant'**
  String get realmExclusivePlantChooserBlockedTitle;

  /// No description provided for @realmExclusivePlantChooserBlockedMessage.
  ///
  /// In en, this message translates to:
  /// **'Realm-exclusive plants cannot be selected in Chooser Mode. To use them, please refer to other methods such as Preset Mode, Conveyor Belt, or Packet Drops.'**
  String get realmExclusivePlantChooserBlockedMessage;

  /// No description provided for @hiddenPlantChooserBlockedTitle.
  ///
  /// In en, this message translates to:
  /// **'Cannot select this plant'**
  String get hiddenPlantChooserBlockedTitle;

  /// No description provided for @hiddenPlantChooserBlockedMessage.
  ///
  /// In en, this message translates to:
  /// **'Hidden plants cannot be selected in Chooser Mode. Use Preset Mode, Conveyor Belt, Packet Drops, or other methods instead.\nExcept for certain plants such as Priest Puff-shroom and P-Mech Assembler - Flame Star, all other hidden plants appear as Sunflowers in the in-game seed bank; plants such as Mini Cactus Ball and Magic Beanstalk also have some abnormal interactions that may affect the level\'s overall presentation, so use them with caution.'**
  String get hiddenPlantChooserBlockedMessage;

  /// No description provided for @comingSoonPlantBlockedLabel.
  ///
  /// In en, this message translates to:
  /// **'To Be Continued'**
  String get comingSoonPlantBlockedLabel;

  /// No description provided for @comingSoonPlantBlockedTitle.
  ///
  /// In en, this message translates to:
  /// **'To Be Continued'**
  String get comingSoonPlantBlockedTitle;

  /// No description provided for @comingSoonPlantBlockedMessage.
  ///
  /// In en, this message translates to:
  /// **'The plants are still growing strong. Stay tuned for future updates!'**
  String get comingSoonPlantBlockedMessage;

  /// No description provided for @stayTunedMoonZombieBlockedTitle.
  ///
  /// In en, this message translates to:
  /// **'A Message from Space'**
  String get stayTunedMoonZombieBlockedTitle;

  /// No description provided for @stayTunedMoonZombieBlockedMessage.
  ///
  /// In en, this message translates to:
  /// **'Moon BaseZ Part 2 is coming soon. Keep a lookout!'**
  String get stayTunedMoonZombieBlockedMessage;

  /// No description provided for @stayTunedTaleZCorpZombieBlockedTitle.
  ///
  /// In en, this message translates to:
  /// **'Under Construction'**
  String get stayTunedTaleZCorpZombieBlockedTitle;

  /// No description provided for @stayTunedTaleZCorpZombieBlockedMessage.
  ///
  /// In en, this message translates to:
  /// **'Part 2 of ZCorp Secret Realm is coming. Stay tuned!'**
  String get stayTunedTaleZCorpZombieBlockedMessage;

  /// No description provided for @stayTunedZombieBlockedTitle.
  ///
  /// In en, this message translates to:
  /// **'To Be Continued'**
  String get stayTunedZombieBlockedTitle;

  /// No description provided for @stayTunedZombieBlockedMessage.
  ///
  /// In en, this message translates to:
  /// **'More zombies are approaching. keep an eye out on upcoming updates!'**
  String get stayTunedZombieBlockedMessage;

  /// No description provided for @missingModuleForPlantsWarning.
  ///
  /// In en, this message translates to:
  /// **'Missing module {moduleName} for plants: {plantList}'**
  String missingModuleForPlantsWarning(String moduleName, String plantList);

  /// No description provided for @moduleTitle_StandardLevelIntroProperties.
  ///
  /// In en, this message translates to:
  /// **'Intro Animation'**
  String get moduleTitle_StandardLevelIntroProperties;

  /// No description provided for @moduleDesc_StandardLevelIntroProperties.
  ///
  /// In en, this message translates to:
  /// **'Camera pan at the start of the level'**
  String get moduleDesc_StandardLevelIntroProperties;

  /// No description provided for @moduleTitle_ZombiesAteYourBrainsProperties.
  ///
  /// In en, this message translates to:
  /// **'Loss Condition'**
  String get moduleTitle_ZombiesAteYourBrainsProperties;

  /// No description provided for @moduleDesc_ZombiesAteYourBrainsProperties.
  ///
  /// In en, this message translates to:
  /// **'Position where zombies entering the house triggers defeat'**
  String get moduleDesc_ZombiesAteYourBrainsProperties;

  /// No description provided for @moduleTitle_ZombiesDeadWinConProperties.
  ///
  /// In en, this message translates to:
  /// **'Loot Drop'**
  String get moduleTitle_ZombiesDeadWinConProperties;

  /// No description provided for @moduleDesc_ZombiesDeadWinConProperties.
  ///
  /// In en, this message translates to:
  /// **'Performs level settlement after zombies die'**
  String get moduleDesc_ZombiesDeadWinConProperties;

  /// No description provided for @moduleTitle_BronzeDeadWinConProperties.
  ///
  /// In en, this message translates to:
  /// **'Bronze Matrix Loot Drop'**
  String get moduleTitle_BronzeDeadWinConProperties;

  /// No description provided for @moduleDesc_BronzeDeadWinConProperties.
  ///
  /// In en, this message translates to:
  /// **'Instantly eliminates all other zombies on the lawn once all bronze statues and gargantuar bronzes are defeated'**
  String get moduleDesc_BronzeDeadWinConProperties;

  /// No description provided for @moduleTitle_SpermWhaleModuleProperties.
  ///
  /// In en, this message translates to:
  /// **'Whale Approaching'**
  String get moduleTitle_SpermWhaleModuleProperties;

  /// No description provided for @moduleDesc_SpermWhaleModuleProperties.
  ///
  /// In en, this message translates to:
  /// **'Configures whale-related parameters for Underwater World levels, requires krill to be present on the lawn to take effect'**
  String get moduleDesc_SpermWhaleModuleProperties;

  /// No description provided for @spermWhaleModuleTitle.
  ///
  /// In en, this message translates to:
  /// **'Whale Approaching Settings'**
  String get spermWhaleModuleTitle;

  /// No description provided for @spermWhaleModuleHelpTitle.
  ///
  /// In en, this message translates to:
  /// **'Whale Approaching module'**
  String get spermWhaleModuleHelpTitle;

  /// No description provided for @spermWhaleModuleParameters.
  ///
  /// In en, this message translates to:
  /// **'Parameters'**
  String get spermWhaleModuleParameters;

  /// No description provided for @spermWhaleModuleHelpOverview.
  ///
  /// In en, this message translates to:
  /// **'Overview'**
  String get spermWhaleModuleHelpOverview;

  /// No description provided for @spermWhaleModuleHelpOverviewBody.
  ///
  /// In en, this message translates to:
  /// **'This module is used to configure parameters related to the special marine creature \"Whale\", and is typically used in Underwater World levels. As krill begin appearing, the whale will circle above the lawn and trigger the corresponding red subtitle warning. Once at least 3 krill are present on the lawn, the whale will officially appear in the upper-left corner of the lawn. The whale will prioritize swallowing existing krill before continuously sucking up and swallowing plants on the lawn. The rotenone released by Puffy Derris can be inhaled by the whale; after the first inhalation, the whale’s swallowing speed will decrease. Once the number of inhalations reaches the configured rotenone trigger count, the whale will be forced to retreat. Note that the whale can only appear once per level.'**
  String get spermWhaleModuleHelpOverviewBody;

  /// No description provided for @spermWhaleModuleHelpFieldsTitle.
  ///
  /// In en, this message translates to:
  /// **'Parameter Overview'**
  String get spermWhaleModuleHelpFieldsTitle;

  /// No description provided for @spermWhaleModuleHelpFieldsBody.
  ///
  /// In en, this message translates to:
  /// **'Swallow Interval (SwallowInterval) refers to the interval between the whale’s swallowing actions under normal conditions.\nPoisoned Swallow Interval (PoisonSwallowInterval) refers to the interval between swallowing actions after the whale inhales rotenone once.\nSwallow Duration (SwallowDuration) refers to the total amount of time the whale remains on the lawn sucking up and swallowing plants.\nPoison Trigger Count (PoisonTriggerCount) refers to the number of rotenone inhalations required to force the whale to retreat.'**
  String get spermWhaleModuleHelpFieldsBody;

  /// No description provided for @spermWhaleModuleSwallowInterval.
  ///
  /// In en, this message translates to:
  /// **'Swallow Interval (SwallowInterval, seconds)'**
  String get spermWhaleModuleSwallowInterval;

  /// No description provided for @spermWhaleModuleHelpSwallowInterval.
  ///
  /// In en, this message translates to:
  /// **'The interval between two swallowing actions under normal conditions.'**
  String get spermWhaleModuleHelpSwallowInterval;

  /// No description provided for @spermWhaleModulePoisonSwallowInterval.
  ///
  /// In en, this message translates to:
  /// **'Rotenone Swallow Interval (PoisonSwallowInterval, seconds)'**
  String get spermWhaleModulePoisonSwallowInterval;

  /// No description provided for @spermWhaleModuleHelpPoisonSwallowInterval.
  ///
  /// In en, this message translates to:
  /// **'The interval between two swallowing actions after the whale inhales rotenone.'**
  String get spermWhaleModuleHelpPoisonSwallowInterval;

  /// No description provided for @spermWhaleModuleSwallowDuration.
  ///
  /// In en, this message translates to:
  /// **'Swallow Duration (SwallowDuration, seconds)'**
  String get spermWhaleModuleSwallowDuration;

  /// No description provided for @spermWhaleModuleHelpSwallowDuration.
  ///
  /// In en, this message translates to:
  /// **'The total duration the whale remains on the lawn sucking up and swallowing plants.'**
  String get spermWhaleModuleHelpSwallowDuration;

  /// No description provided for @spermWhaleModulePoisonTriggerCount.
  ///
  /// In en, this message translates to:
  /// **'Rotenone trigger count (PoisonTriggerCount)'**
  String get spermWhaleModulePoisonTriggerCount;

  /// No description provided for @spermWhaleModuleHelpPoisonTriggerCount.
  ///
  /// In en, this message translates to:
  /// **'The cumulative number of rotenone inhalations required to force the whale to retreat.'**
  String get spermWhaleModuleHelpPoisonTriggerCount;

  /// No description provided for @spermWhaleModuleNotDeepSeaWarning.
  ///
  /// In en, this message translates to:
  /// **'This module is recommended for Underwater World lawns. Using it on lawns other than 20,000 Leagues Under the Sea/Atlantis may cause compatibility issues.'**
  String get spermWhaleModuleNotDeepSeaWarning;

  /// No description provided for @moduleTitle_PennyClassroomModuleProperties.
  ///
  /// In en, this message translates to:
  /// **'Tier Definition'**
  String get moduleTitle_PennyClassroomModuleProperties;

  /// No description provided for @moduleDesc_PennyClassroomModuleProperties.
  ///
  /// In en, this message translates to:
  /// **'Globally defines plant tiers, overrides other modules'**
  String get moduleDesc_PennyClassroomModuleProperties;

  /// No description provided for @moduleTitle_SeedBankProperties.
  ///
  /// In en, this message translates to:
  /// **'Seed Bank'**
  String get moduleTitle_SeedBankProperties;

  /// No description provided for @moduleDesc_SeedBankProperties.
  ///
  /// In en, this message translates to:
  /// **'Presets seed slots and seed selection mode'**
  String get moduleDesc_SeedBankProperties;

  /// No description provided for @moduleTitle_ConveyorSeedBankProperties.
  ///
  /// In en, this message translates to:
  /// **'Conveyor Belt'**
  String get moduleTitle_ConveyorSeedBankProperties;

  /// No description provided for @moduleDesc_ConveyorSeedBankProperties.
  ///
  /// In en, this message translates to:
  /// **'Presets conveyor belt plant types and weights'**
  String get moduleDesc_ConveyorSeedBankProperties;

  /// No description provided for @moduleTitle_SunDropperProperties.
  ///
  /// In en, this message translates to:
  /// **'Sun Dropper'**
  String get moduleTitle_SunDropperProperties;

  /// No description provided for @moduleDesc_SunDropperProperties.
  ///
  /// In en, this message translates to:
  /// **'Controls falling sun frequency'**
  String get moduleDesc_SunDropperProperties;

  /// No description provided for @moduleTitle_LevelMutatorMaxSunProps.
  ///
  /// In en, this message translates to:
  /// **'Max Sun Limit'**
  String get moduleTitle_LevelMutatorMaxSunProps;

  /// No description provided for @moduleDesc_LevelMutatorMaxSunProps.
  ///
  /// In en, this message translates to:
  /// **'Overrides the maximum sun limit value'**
  String get moduleDesc_LevelMutatorMaxSunProps;

  /// No description provided for @moduleTitle_MoonExpertProperties.
  ///
  /// In en, this message translates to:
  /// **'Moon Expert'**
  String get moduleTitle_MoonExpertProperties;

  /// No description provided for @moduleDesc_MoonExpertProperties.
  ///
  /// In en, this message translates to:
  /// **'Sets fixed plant and zombie levels (doesn\'t work in Creative Courtyard)'**
  String get moduleDesc_MoonExpertProperties;

  /// No description provided for @moduleTitle_LevelMutatorStartingPlantfoodProps.
  ///
  /// In en, this message translates to:
  /// **'Starting Plant Food'**
  String get moduleTitle_LevelMutatorStartingPlantfoodProps;

  /// No description provided for @moduleDesc_LevelMutatorStartingPlantfoodProps.
  ///
  /// In en, this message translates to:
  /// **'Overrides starting Plant Food amount'**
  String get moduleDesc_LevelMutatorStartingPlantfoodProps;

  /// No description provided for @moduleTitle_StarChallengeModuleProperties.
  ///
  /// In en, this message translates to:
  /// **'Challenge Module'**
  String get moduleTitle_StarChallengeModuleProperties;

  /// No description provided for @moduleDesc_StarChallengeModuleProperties.
  ///
  /// In en, this message translates to:
  /// **'Sets level restrictions and objectives'**
  String get moduleDesc_StarChallengeModuleProperties;

  /// No description provided for @starChallengeNoConfigTitle.
  ///
  /// In en, this message translates to:
  /// **'Challenge'**
  String get starChallengeNoConfigTitle;

  /// No description provided for @starChallengeNoConfigMessage.
  ///
  /// In en, this message translates to:
  /// **'This challenge has no configurable parameters.'**
  String get starChallengeNoConfigMessage;

  /// No description provided for @starChallengeSaveMowersTitle.
  ///
  /// In en, this message translates to:
  /// **'Don\'t lose any lawn mowers'**
  String get starChallengeSaveMowersTitle;

  /// No description provided for @starChallengeSaveMowersNoConfigMessage.
  ///
  /// In en, this message translates to:
  /// **'This challenge has no configurable parameters.\n\nTo complete it, all lawn mowers must remain intact. Note that lawn mowers are not available by default when the Creative Courtyard module is enabled.'**
  String get starChallengeSaveMowersNoConfigMessage;

  /// No description provided for @starChallengePlantFoodNonuseTitle.
  ///
  /// In en, this message translates to:
  /// **'Don\'t use Plant Food'**
  String get starChallengePlantFoodNonuseTitle;

  /// No description provided for @starChallengePlantFoodNonuseNoConfigMessage.
  ///
  /// In en, this message translates to:
  /// **'This challenge has no configurable parameters.\n\nPlant Food cannot be used.'**
  String get starChallengePlantFoodNonuseNoConfigMessage;

  /// No description provided for @moduleTitle_LevelScoringModuleProperties.
  ///
  /// In en, this message translates to:
  /// **'Scoring Module'**
  String get moduleTitle_LevelScoringModuleProperties;

  /// No description provided for @moduleDesc_LevelScoringModuleProperties.
  ///
  /// In en, this message translates to:
  /// **'Enables scoring system based on zombie kills'**
  String get moduleDesc_LevelScoringModuleProperties;

  /// No description provided for @moduleTitle_SouDaCheDamageTextModuleProperties.
  ///
  /// In en, this message translates to:
  /// **'Damage Number Display'**
  String get moduleTitle_SouDaCheDamageTextModuleProperties;

  /// No description provided for @moduleDesc_SouDaCheDamageTextModuleProperties.
  ///
  /// In en, this message translates to:
  /// **'Shows the damage value dealt by each plant attack during the level'**
  String get moduleDesc_SouDaCheDamageTextModuleProperties;

  /// No description provided for @moduleTitle_BowlingMinigameProperties.
  ///
  /// In en, this message translates to:
  /// **'Bulb Bowling'**
  String get moduleTitle_BowlingMinigameProperties;

  /// No description provided for @moduleDesc_BowlingMinigameProperties.
  ///
  /// In en, this message translates to:
  /// **'Sets no-planting line and disable shovel'**
  String get moduleDesc_BowlingMinigameProperties;

  /// No description provided for @moduleTitle_NewBowlingMinigameProperties.
  ///
  /// In en, this message translates to:
  /// **'Wall-nut Bowling'**
  String get moduleTitle_NewBowlingMinigameProperties;

  /// No description provided for @moduleDesc_NewBowlingMinigameProperties.
  ///
  /// In en, this message translates to:
  /// **'Draws bowling warning line at a fixed position'**
  String get moduleDesc_NewBowlingMinigameProperties;

  /// No description provided for @moduleTitle_VaseBreakerPresetProperties.
  ///
  /// In en, this message translates to:
  /// **'Vase Layout'**
  String get moduleTitle_VaseBreakerPresetProperties;

  /// No description provided for @moduleDesc_VaseBreakerPresetProperties.
  ///
  /// In en, this message translates to:
  /// **'Configures vase contents (requires 2 additional modules to function)'**
  String get moduleDesc_VaseBreakerPresetProperties;

  /// No description provided for @moduleTitle_VaseBreakerArcadeModuleProperties.
  ///
  /// In en, this message translates to:
  /// **'Vasebreaker Mode'**
  String get moduleTitle_VaseBreakerArcadeModuleProperties;

  /// No description provided for @moduleDesc_VaseBreakerArcadeModuleProperties.
  ///
  /// In en, this message translates to:
  /// **'Enable environment and UI for Vasebreaker'**
  String get moduleDesc_VaseBreakerArcadeModuleProperties;

  /// No description provided for @moduleTitle_VaseBreakerFlowModuleProperties.
  ///
  /// In en, this message translates to:
  /// **'Vase Animation'**
  String get moduleTitle_VaseBreakerFlowModuleProperties;

  /// No description provided for @moduleDesc_VaseBreakerFlowModuleProperties.
  ///
  /// In en, this message translates to:
  /// **'Controls the falling animation of vases at start'**
  String get moduleDesc_VaseBreakerFlowModuleProperties;

  /// No description provided for @moduleTitle_EvilDaveProperties.
  ///
  /// In en, this message translates to:
  /// **'I, Zombie Mode'**
  String get moduleTitle_EvilDaveProperties;

  /// No description provided for @moduleDesc_EvilDaveProperties.
  ///
  /// In en, this message translates to:
  /// **'Enable I, Zombie mode (requires zombie bank and preset plants)'**
  String get moduleDesc_EvilDaveProperties;

  /// No description provided for @moduleTitle_ZombossBattleModuleProperties.
  ///
  /// In en, this message translates to:
  /// **'Zomboss Mech Battle'**
  String get moduleTitle_ZombossBattleModuleProperties;

  /// No description provided for @moduleDesc_ZombossBattleModuleProperties.
  ///
  /// In en, this message translates to:
  /// **'Configures Zomboss Mech types and parameters'**
  String get moduleDesc_ZombossBattleModuleProperties;

  /// No description provided for @moduleTitle_ZombossBattleIntroProperties.
  ///
  /// In en, this message translates to:
  /// **'Zomboss Mech Intro'**
  String get moduleTitle_ZombossBattleIntroProperties;

  /// No description provided for @moduleDesc_ZombossBattleIntroProperties.
  ///
  /// In en, this message translates to:
  /// **'Controls Zomboss Mech Battle cutscenes and health bar display'**
  String get moduleDesc_ZombossBattleIntroProperties;

  /// No description provided for @moduleTitle_ZombossLastStandMinigameProperties.
  ///
  /// In en, this message translates to:
  /// **'Non-mech Zomboss Battle'**
  String get moduleTitle_ZombossLastStandMinigameProperties;

  /// No description provided for @moduleDesc_ZombossLastStandMinigameProperties.
  ///
  /// In en, this message translates to:
  /// **'Configures non-mech Zomboss Battles such as Qigong Master'**
  String get moduleDesc_ZombossLastStandMinigameProperties;

  /// No description provided for @moduleTitle_SeedRainProperties.
  ///
  /// In en, this message translates to:
  /// **'It\'s Raining Seeds'**
  String get moduleTitle_SeedRainProperties;

  /// No description provided for @moduleDesc_SeedRainProperties.
  ///
  /// In en, this message translates to:
  /// **'Controls plants, zombies or Plant Food falling from the sky'**
  String get moduleDesc_SeedRainProperties;

  /// No description provided for @moduleTitle_LastStandMinigameProperties.
  ///
  /// In en, this message translates to:
  /// **'Last Stand'**
  String get moduleTitle_LastStandMinigameProperties;

  /// No description provided for @moduleDesc_LastStandMinigameProperties.
  ///
  /// In en, this message translates to:
  /// **'Sets initial resources and enables setup phase'**
  String get moduleDesc_LastStandMinigameProperties;

  /// No description provided for @moduleTitle_CowboyMinigameProperties.
  ///
  /// In en, this message translates to:
  /// **'Not OK Corral'**
  String get moduleTitle_CowboyMinigameProperties;

  /// No description provided for @moduleDesc_CowboyMinigameProperties.
  ///
  /// In en, this message translates to:
  /// **'Starts each zombie wave only after a plant from the conveyor belt is planted'**
  String get moduleDesc_CowboyMinigameProperties;

  /// No description provided for @moduleTitle_SingleHandedProperties.
  ///
  /// In en, this message translates to:
  /// **'All by Oneself'**
  String get moduleTitle_SingleHandedProperties;

  /// No description provided for @moduleDesc_SingleHandedProperties.
  ///
  /// In en, this message translates to:
  /// **'Configures the basic properties of the All by Oneself minigame'**
  String get moduleDesc_SingleHandedProperties;

  /// No description provided for @moduleTitle_IntroSingleHandedProperties.
  ///
  /// In en, this message translates to:
  /// **'All by Oneself Tutorial'**
  String get moduleTitle_IntroSingleHandedProperties;

  /// No description provided for @moduleDesc_IntroSingleHandedProperties.
  ///
  /// In en, this message translates to:
  /// **'Configures tutorial prompts for the All by Oneself minigame'**
  String get moduleDesc_IntroSingleHandedProperties;

  /// No description provided for @moduleTitle_PVZ1OverwhelmModuleProperties.
  ///
  /// In en, this message translates to:
  /// **'Column Like You See \'Em'**
  String get moduleTitle_PVZ1OverwhelmModuleProperties;

  /// No description provided for @moduleDesc_PVZ1OverwhelmModuleProperties.
  ///
  /// In en, this message translates to:
  /// **'Planting a seed packet fills its column (best used with conveyor belt)'**
  String get moduleDesc_PVZ1OverwhelmModuleProperties;

  /// No description provided for @moduleTitle_SunBombChallengeProperties.
  ///
  /// In en, this message translates to:
  /// **'Sun Bombs'**
  String get moduleTitle_SunBombChallengeProperties;

  /// No description provided for @moduleDesc_SunBombChallengeProperties.
  ///
  /// In en, this message translates to:
  /// **'Configures explosion range and damage of falling sun'**
  String get moduleDesc_SunBombChallengeProperties;

  /// No description provided for @moduleTitle_IncreasedCostModuleProperties.
  ///
  /// In en, this message translates to:
  /// **'Inflation'**
  String get moduleTitle_IncreasedCostModuleProperties;

  /// No description provided for @moduleDesc_IncreasedCostModuleProperties.
  ///
  /// In en, this message translates to:
  /// **'Sun cost increases each time the same plant is planted'**
  String get moduleDesc_IncreasedCostModuleProperties;

  /// No description provided for @moduleTitle_DeathHoleModuleProperties.
  ///
  /// In en, this message translates to:
  /// **'Death Craters'**
  String get moduleTitle_DeathHoleModuleProperties;

  /// No description provided for @moduleDesc_DeathHoleModuleProperties.
  ///
  /// In en, this message translates to:
  /// **'Plants leave craters when destroyed'**
  String get moduleDesc_DeathHoleModuleProperties;

  /// No description provided for @moduleTitle_ZombieMoveFastModuleProperties.
  ///
  /// In en, this message translates to:
  /// **'Fast Entry'**
  String get moduleTitle_ZombieMoveFastModuleProperties;

  /// No description provided for @moduleDesc_ZombieMoveFastModuleProperties.
  ///
  /// In en, this message translates to:
  /// **'Zombies move faster on entry'**
  String get moduleDesc_ZombieMoveFastModuleProperties;

  /// No description provided for @moduleTitle_InitialPlantProperties.
  ///
  /// In en, this message translates to:
  /// **'Legacy Preset Plants'**
  String get moduleTitle_InitialPlantProperties;

  /// No description provided for @moduleDesc_InitialPlantProperties.
  ///
  /// In en, this message translates to:
  /// **'The legacy method for preset plants, supports placing frozen plants'**
  String get moduleDesc_InitialPlantProperties;

  /// No description provided for @moduleTitle_InitialPlantEntryProperties.
  ///
  /// In en, this message translates to:
  /// **'Preset Plants'**
  String get moduleTitle_InitialPlantEntryProperties;

  /// No description provided for @moduleDesc_InitialPlantEntryProperties.
  ///
  /// In en, this message translates to:
  /// **'Plants existing on the lawn at the start'**
  String get moduleDesc_InitialPlantEntryProperties;

  /// No description provided for @frozenPlantPlacementLastStand.
  ///
  /// In en, this message translates to:
  /// **'Intensive Battle mode'**
  String get frozenPlantPlacementLastStand;

  /// No description provided for @frozenPlantPlacementSelectedPosition.
  ///
  /// In en, this message translates to:
  /// **'Selected position'**
  String get frozenPlantPlacementSelectedPosition;

  /// No description provided for @frozenPlantPlacementPlantList.
  ///
  /// In en, this message translates to:
  /// **'Plant(s) in selected tile'**
  String get frozenPlantPlacementPlantList;

  /// No description provided for @frozenPlantPlacementEditPlant.
  ///
  /// In en, this message translates to:
  /// **'Edit {name}'**
  String frozenPlantPlacementEditPlant(String name);

  /// No description provided for @frozenPlantPlacementLevel.
  ///
  /// In en, this message translates to:
  /// **'Level'**
  String get frozenPlantPlacementLevel;

  /// No description provided for @frozenPlantPlacementCondition.
  ///
  /// In en, this message translates to:
  /// **'Condition'**
  String get frozenPlantPlacementCondition;

  /// No description provided for @frozenPlantPlacementConditionNull.
  ///
  /// In en, this message translates to:
  /// **'None (null)'**
  String get frozenPlantPlacementConditionNull;

  /// No description provided for @noConditions.
  ///
  /// In en, this message translates to:
  /// **'No conditions'**
  String get noConditions;

  /// No description provided for @frozenPlantPlacementHelpTitle.
  ///
  /// In en, this message translates to:
  /// **'Legacy Preset Plants module'**
  String get frozenPlantPlacementHelpTitle;

  /// No description provided for @frozenPlantPlacementHelpOverviewTitle.
  ///
  /// In en, this message translates to:
  /// **'Overview'**
  String get frozenPlantPlacementHelpOverviewTitle;

  /// No description provided for @frozenPlantPlacementHelpOverviewBody.
  ///
  /// In en, this message translates to:
  /// **'This module configures plant layout before the level starts. Similar to preset plant layout but with a different structure and special state support.'**
  String get frozenPlantPlacementHelpOverviewBody;

  /// No description provided for @frozenPlantPlacementHelpConditionTitle.
  ///
  /// In en, this message translates to:
  /// **'Special State'**
  String get frozenPlantPlacementHelpConditionTitle;

  /// No description provided for @frozenPlantPlacementHelpConditionBody.
  ///
  /// In en, this message translates to:
  /// **'Plants can be set to frozen state (icecubed), commonly used in Frostbite Caves levels.'**
  String get frozenPlantPlacementHelpConditionBody;

  /// No description provided for @frozenPlantPlacementHelpLastStandTitle.
  ///
  /// In en, this message translates to:
  /// **'Intensive Battle Mode'**
  String get frozenPlantPlacementHelpLastStandTitle;

  /// No description provided for @frozenPlantPlacementHelpLastStandBody.
  ///
  /// In en, this message translates to:
  /// **'When Intensive Battle mode is enabled, initial plants will be incinerated after the game starts. Note that Chinese version does not have the burn animation.'**
  String get frozenPlantPlacementHelpLastStandBody;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @moduleTitle_InitialZombieProperties.
  ///
  /// In en, this message translates to:
  /// **'Preset Zombies'**
  String get moduleTitle_InitialZombieProperties;

  /// No description provided for @moduleDesc_InitialZombieProperties.
  ///
  /// In en, this message translates to:
  /// **'Zombies existing on the lawn at the start'**
  String get moduleDesc_InitialZombieProperties;

  /// No description provided for @moduleTitle_InitialGridItemProperties.
  ///
  /// In en, this message translates to:
  /// **'Preset Grid Items'**
  String get moduleTitle_InitialGridItemProperties;

  /// No description provided for @moduleDesc_InitialGridItemProperties.
  ///
  /// In en, this message translates to:
  /// **'Grid items existing on the lawn at the start'**
  String get moduleDesc_InitialGridItemProperties;

  /// No description provided for @moduleTitle_ProtectThePlantChallengeProperties.
  ///
  /// In en, this message translates to:
  /// **'Save Our Seeds'**
  String get moduleTitle_ProtectThePlantChallengeProperties;

  /// No description provided for @moduleDesc_ProtectThePlantChallengeProperties.
  ///
  /// In en, this message translates to:
  /// **'Sets specific plants that must be protected'**
  String get moduleDesc_ProtectThePlantChallengeProperties;

  /// No description provided for @moduleTitle_ProtectTheGridItemChallengeProperties.
  ///
  /// In en, this message translates to:
  /// **'Save Our Items'**
  String get moduleTitle_ProtectTheGridItemChallengeProperties;

  /// No description provided for @moduleDesc_ProtectTheGridItemChallengeProperties.
  ///
  /// In en, this message translates to:
  /// **'Sets grid items that must be protected from destruction'**
  String get moduleDesc_ProtectTheGridItemChallengeProperties;

  /// No description provided for @moduleTitle_MoldColonyChallengeProps.
  ///
  /// In en, this message translates to:
  /// **'Mold Zone'**
  String get moduleTitle_MoldColonyChallengeProps;

  /// No description provided for @moduleDesc_MoldColonyChallengeProps.
  ///
  /// In en, this message translates to:
  /// **'Sets the lawn tiles covered by mold colonies'**
  String get moduleDesc_MoldColonyChallengeProps;

  /// No description provided for @moldColonyLocationsTitle.
  ///
  /// In en, this message translates to:
  /// **'Mold colonies layout (Locations)'**
  String get moldColonyLocationsTitle;

  /// No description provided for @moldColonyLocationsValue.
  ///
  /// In en, this message translates to:
  /// **'Current value: {value}'**
  String moldColonyLocationsValue(String value);

  /// No description provided for @moldColonyLevelModulesError.
  ///
  /// In en, this message translates to:
  /// **'Error: the mold colonies layout reference uses LevelModules. Switch it to a current-level object.'**
  String get moldColonyLevelModulesError;

  /// No description provided for @moldColonyInvalidLinkError.
  ///
  /// In en, this message translates to:
  /// **'Error: Locations must reference a BoardGridMapProps object in the current level for the mold colonies layout.'**
  String get moldColonyInvalidLinkError;

  /// No description provided for @moldColonyRepairLink.
  ///
  /// In en, this message translates to:
  /// **'Repair link to: {alias}'**
  String moldColonyRepairLink(String alias);

  /// No description provided for @moldColonies.
  ///
  /// In en, this message translates to:
  /// **'Mold colonies'**
  String get moldColonies;

  /// No description provided for @moldColonyEmpty.
  ///
  /// In en, this message translates to:
  /// **'Empty'**
  String get moldColonyEmpty;

  /// No description provided for @moldColonyHelpOverview.
  ///
  /// In en, this message translates to:
  /// **'Configures the lawn tiles covered by mold colonies. Mold colonies prevent the player from planting on the corresponding tiles.'**
  String get moldColonyHelpOverview;

  /// No description provided for @moldColonyHelpGridTitle.
  ///
  /// In en, this message translates to:
  /// **'Grid controls'**
  String get moldColonyHelpGridTitle;

  /// No description provided for @moldColonyHelpGridBody.
  ///
  /// In en, this message translates to:
  /// **'Tap a tile to switch between empty (plantable) and mold colonies (not plantable). The selected row and column are shown above the grid.'**
  String get moldColonyHelpGridBody;

  /// No description provided for @moduleTitle_ZombiePotionModuleProperties.
  ///
  /// In en, this message translates to:
  /// **'Dark Alchemy'**
  String get moduleTitle_ZombiePotionModuleProperties;

  /// No description provided for @moduleDesc_ZombiePotionModuleProperties.
  ///
  /// In en, this message translates to:
  /// **'Dark Ages potion generation mechanics'**
  String get moduleDesc_ZombiePotionModuleProperties;

  /// No description provided for @moduleTitle_PiratePlankProperties.
  ///
  /// In en, this message translates to:
  /// **'Pirate Planks'**
  String get moduleTitle_PiratePlankProperties;

  /// No description provided for @moduleDesc_PiratePlankProperties.
  ///
  /// In en, this message translates to:
  /// **'Configures plank rows for Pirate Seas lawn'**
  String get moduleDesc_PiratePlankProperties;

  /// No description provided for @moduleTitle_RailcartProperties.
  ///
  /// In en, this message translates to:
  /// **'Minecart and Rail'**
  String get moduleTitle_RailcartProperties;

  /// No description provided for @moduleDesc_RailcartProperties.
  ///
  /// In en, this message translates to:
  /// **'Configures the initial layout of minecarts and rails'**
  String get moduleDesc_RailcartProperties;

  /// No description provided for @moduleTitle_MechanismPlankProperties.
  ///
  /// In en, this message translates to:
  /// **'Connected Minecart'**
  String get moduleTitle_MechanismPlankProperties;

  /// No description provided for @moduleDesc_MechanismPlankProperties.
  ///
  /// In en, this message translates to:
  /// **'Configures the initial layout of Kongfu World minecarts and rails'**
  String get moduleDesc_MechanismPlankProperties;

  /// No description provided for @moduleTitle_PowerTileProperties.
  ///
  /// In en, this message translates to:
  /// **'Power Tiles'**
  String get moduleTitle_PowerTileProperties;

  /// No description provided for @moduleDesc_PowerTileProperties.
  ///
  /// In en, this message translates to:
  /// **'Configures Plant Food link effects and tile layout'**
  String get moduleDesc_PowerTileProperties;

  /// No description provided for @moduleTitle_ManholePipelineModuleProperties.
  ///
  /// In en, this message translates to:
  /// **'Manhole Pipeline'**
  String get moduleTitle_ManholePipelineModuleProperties;

  /// No description provided for @moduleDesc_ManholePipelineModuleProperties.
  ///
  /// In en, this message translates to:
  /// **'Configures Steam Ages transportation sewers'**
  String get moduleDesc_ManholePipelineModuleProperties;

  /// No description provided for @moduleTitle_SmokePollutionModuleProperties.
  ///
  /// In en, this message translates to:
  /// **'Steam Manhole'**
  String get moduleTitle_SmokePollutionModuleProperties;

  /// No description provided for @moduleDesc_SmokePollutionModuleProperties.
  ///
  /// In en, this message translates to:
  /// **'Configures Steam Ages steam sewers'**
  String get moduleDesc_SmokePollutionModuleProperties;

  /// No description provided for @moduleTitle_RoofProperties.
  ///
  /// In en, this message translates to:
  /// **'Roof Pots'**
  String get moduleTitle_RoofProperties;

  /// No description provided for @moduleDesc_RoofProperties.
  ///
  /// In en, this message translates to:
  /// **'Configures preset Flower Pots for Roof levels'**
  String get moduleDesc_RoofProperties;

  /// No description provided for @moduleTitle_TideProperties.
  ///
  /// In en, this message translates to:
  /// **'Tide System'**
  String get moduleTitle_TideProperties;

  /// No description provided for @moduleDesc_TideProperties.
  ///
  /// In en, this message translates to:
  /// **'Enable tide system (should be added last)'**
  String get moduleDesc_TideProperties;

  /// No description provided for @moduleTitle_BombProperties.
  ///
  /// In en, this message translates to:
  /// **'Powder Keg'**
  String get moduleTitle_BombProperties;

  /// No description provided for @moduleDesc_BombProperties.
  ///
  /// In en, this message translates to:
  /// **'Configures the fuse length and burn rate of Kongfu World powder kegs'**
  String get moduleDesc_BombProperties;

  /// No description provided for @moduleTitle_BronzeProperties.
  ///
  /// In en, this message translates to:
  /// **'Bronze Matrix Statues'**
  String get moduleTitle_BronzeProperties;

  /// No description provided for @moduleDesc_BronzeProperties.
  ///
  /// In en, this message translates to:
  /// **'Configures Kongfu World bronze statues'**
  String get moduleDesc_BronzeProperties;

  /// No description provided for @moduleTitle_ArmrackProperties.
  ///
  /// In en, this message translates to:
  /// **'Weapon Stands'**
  String get moduleTitle_ArmrackProperties;

  /// No description provided for @moduleDesc_ArmrackProperties.
  ///
  /// In en, this message translates to:
  /// **'Configures the spawning of Kongfu World weapon stands'**
  String get moduleDesc_ArmrackProperties;

  /// No description provided for @moduleTitle_EnergyGridProperties.
  ///
  /// In en, this message translates to:
  /// **'Taiji Tiles'**
  String get moduleTitle_EnergyGridProperties;

  /// No description provided for @moduleDesc_EnergyGridProperties.
  ///
  /// In en, this message translates to:
  /// **'Configures the spawning of Kongfu World Taiji tiles'**
  String get moduleDesc_EnergyGridProperties;

  /// No description provided for @bronzeModuleHelpTitle.
  ///
  /// In en, this message translates to:
  /// **'Bronze Matrix Statues module'**
  String get bronzeModuleHelpTitle;

  /// No description provided for @bronzeModuleHelpOverview.
  ///
  /// In en, this message translates to:
  /// **'Overview'**
  String get bronzeModuleHelpOverview;

  /// No description provided for @bronzeModuleHelpOverviewBody.
  ///
  /// In en, this message translates to:
  /// **'This module is used to place bronze statue grid items on the lawn that exist at the start of the level, commonly used in the Kongfu World brain buster \"Bronze Matrix\". Bronze statues gradually lose their copper coating over time and will revive as gargantuar bronzes when the specified countdown ends. The HP of a bronze statue is the same as the corresponding Level 1 Gargantuar Bronze.\nShake offset (shakeOffset) indicates the center offset of the revive animation’s shaking; adjusting this value has no practical effect.\nNote: This module itself does not include the effect of instantly eliminating remaining zombies after all bronze statues and gargantuar bronzes on the lawn are destroyed. To achieve that effect, the Bronze Matrix Loot Drop module must be added.'**
  String get bronzeModuleHelpOverviewBody;

  /// No description provided for @bronzeModuleHelpBatches.
  ///
  /// In en, this message translates to:
  /// **'Revival Logic'**
  String get bronzeModuleHelpBatches;

  /// No description provided for @bronzeModuleHelpBatchesBody.
  ///
  /// In en, this message translates to:
  /// **'Each bronze statue added generates a corresponding entry in the level file. Revival timing is determined by the spawn time (spawnTime), in seconds, and is independent of waves. Bronze statues with the same spawn time will revive simultaneously.\nThe revival countdown for subsequent batches is offset from the first batch. For example, if the first batch is set to 30s, the second to 45s, and the third to 50s, then the second batch will revive 15s after the first, and the third batch 5s after the second.'**
  String get bronzeModuleHelpBatchesBody;

  /// No description provided for @bronzeModuleShakeOffset.
  ///
  /// In en, this message translates to:
  /// **'Animation'**
  String get bronzeModuleShakeOffset;

  /// No description provided for @bronzeModuleShakeOffsetLabel.
  ///
  /// In en, this message translates to:
  /// **'Shake offset'**
  String get bronzeModuleShakeOffsetLabel;

  /// No description provided for @bronzeModuleInCell.
  ///
  /// In en, this message translates to:
  /// **'Bronze statue(s) in selected tile'**
  String get bronzeModuleInCell;

  /// No description provided for @bronzeModuleAddTitle.
  ///
  /// In en, this message translates to:
  /// **'Add bronze statue'**
  String get bronzeModuleAddTitle;

  /// No description provided for @bronzeModuleSpawnTimeLabel.
  ///
  /// In en, this message translates to:
  /// **'Revival time (seconds)'**
  String get bronzeModuleSpawnTimeLabel;

  /// No description provided for @moduleTitle_WarMistProperties.
  ///
  /// In en, this message translates to:
  /// **'Fog System'**
  String get moduleTitle_WarMistProperties;

  /// No description provided for @moduleDesc_WarMistProperties.
  ///
  /// In en, this message translates to:
  /// **'Configures Dark Ages fog coverage and interaction'**
  String get moduleDesc_WarMistProperties;

  /// No description provided for @moduleTitle_RainDarkProperties.
  ///
  /// In en, this message translates to:
  /// **'Weather'**
  String get moduleTitle_RainDarkProperties;

  /// No description provided for @moduleDesc_RainDarkProperties.
  ///
  /// In en, this message translates to:
  /// **'Sets rain, snow, and lightning effects'**
  String get moduleDesc_RainDarkProperties;

  /// No description provided for @eventTitle_SpawnZombiesFromGroundSpawnerProps.
  ///
  /// In en, this message translates to:
  /// **'Ground Spawner'**
  String get eventTitle_SpawnZombiesFromGroundSpawnerProps;

  /// No description provided for @eventDesc_SpawnZombiesFromGroundSpawnerProps.
  ///
  /// In en, this message translates to:
  /// **'Spawns zombies from underground'**
  String get eventDesc_SpawnZombiesFromGroundSpawnerProps;

  /// No description provided for @eventTitle_SpawnZombiesJitteredWaveActionProps.
  ///
  /// In en, this message translates to:
  /// **'Basic Spawner'**
  String get eventTitle_SpawnZombiesJitteredWaveActionProps;

  /// No description provided for @eventDesc_SpawnZombiesJitteredWaveActionProps.
  ///
  /// In en, this message translates to:
  /// **'Standard natural zombie spawning event'**
  String get eventDesc_SpawnZombiesJitteredWaveActionProps;

  /// No description provided for @eventTitle_FrostWindWaveActionProps.
  ///
  /// In en, this message translates to:
  /// **'Freezing Wind'**
  String get eventTitle_FrostWindWaveActionProps;

  /// No description provided for @eventDesc_FrostWindWaveActionProps.
  ///
  /// In en, this message translates to:
  /// **'Blows freezing wind on specific rows'**
  String get eventDesc_FrostWindWaveActionProps;

  /// No description provided for @eventTitle_BeachStageEventZombieSpawnerProps.
  ///
  /// In en, this message translates to:
  /// **'Low Tide'**
  String get eventTitle_BeachStageEventZombieSpawnerProps;

  /// No description provided for @eventDesc_BeachStageEventZombieSpawnerProps.
  ///
  /// In en, this message translates to:
  /// **'Zombies emerge during low tide'**
  String get eventDesc_BeachStageEventZombieSpawnerProps;

  /// No description provided for @eventTitle_TidalChangeWaveActionProps.
  ///
  /// In en, this message translates to:
  /// **'Tide Change'**
  String get eventTitle_TidalChangeWaveActionProps;

  /// No description provided for @eventDesc_TidalChangeWaveActionProps.
  ///
  /// In en, this message translates to:
  /// **'Changes the tide position'**
  String get eventDesc_TidalChangeWaveActionProps;

  /// No description provided for @eventTitle_TideWaveWaveActionProps.
  ///
  /// In en, this message translates to:
  /// **'Ocean Current'**
  String get eventTitle_TideWaveWaveActionProps;

  /// No description provided for @eventDesc_TideWaveWaveActionProps.
  ///
  /// In en, this message translates to:
  /// **'Moves submarine and affects zombie movement speed'**
  String get eventDesc_TideWaveWaveActionProps;

  /// No description provided for @eventTitle_SpawnZombiesFishWaveActionProps.
  ///
  /// In en, this message translates to:
  /// **'Underwater Spawner'**
  String get eventTitle_SpawnZombiesFishWaveActionProps;

  /// No description provided for @eventDesc_SpawnZombiesFishWaveActionProps.
  ///
  /// In en, this message translates to:
  /// **'Spawns zombies or sea creatures from the left or right side of the lawn; can only be used in Underwater World'**
  String get eventDesc_SpawnZombiesFishWaveActionProps;

  /// No description provided for @eventTitle_ModifyConveyorWaveActionProps.
  ///
  /// In en, this message translates to:
  /// **'Conveyor Change'**
  String get eventTitle_ModifyConveyorWaveActionProps;

  /// No description provided for @eventDesc_ModifyConveyorWaveActionProps.
  ///
  /// In en, this message translates to:
  /// **'Dynamically adds or removes conveyor plants'**
  String get eventDesc_ModifyConveyorWaveActionProps;

  /// No description provided for @eventTitle_DinoWaveActionProps.
  ///
  /// In en, this message translates to:
  /// **'Dino Summon'**
  String get eventTitle_DinoWaveActionProps;

  /// No description provided for @eventDesc_DinoWaveActionProps.
  ///
  /// In en, this message translates to:
  /// **'Summons a dinosaur to assist zombies'**
  String get eventDesc_DinoWaveActionProps;

  /// No description provided for @eventTitle_DinoTreadActionProps.
  ///
  /// In en, this message translates to:
  /// **'Dino Stomp'**
  String get eventTitle_DinoTreadActionProps;

  /// No description provided for @eventDesc_DinoTreadActionProps.
  ///
  /// In en, this message translates to:
  /// **'Brachiosaurus stomps within a set area, dealing damage'**
  String get eventDesc_DinoTreadActionProps;

  /// No description provided for @eventTitle_DinoRunActionProps.
  ///
  /// In en, this message translates to:
  /// **'Dino Stampede'**
  String get eventTitle_DinoRunActionProps;

  /// No description provided for @eventDesc_DinoRunActionProps.
  ///
  /// In en, this message translates to:
  /// **'Dinosaurs charge down their lane, trampling plants and zombies'**
  String get eventDesc_DinoRunActionProps;

  /// No description provided for @eventTitle_SpawnModernPortalsWaveActionProps.
  ///
  /// In en, this message translates to:
  /// **'Spacetime Portal'**
  String get eventTitle_SpawnModernPortalsWaveActionProps;

  /// No description provided for @eventDesc_SpawnModernPortalsWaveActionProps.
  ///
  /// In en, this message translates to:
  /// **'Summons spacetime portals at set locations'**
  String get eventDesc_SpawnModernPortalsWaveActionProps;

  /// No description provided for @eventTitle_StormZombieSpawnerProps.
  ///
  /// In en, this message translates to:
  /// **'Storm Raid'**
  String get eventTitle_StormZombieSpawnerProps;

  /// No description provided for @eventDesc_StormZombieSpawnerProps.
  ///
  /// In en, this message translates to:
  /// **'Sandstorms or snowstorms bring in zombies'**
  String get eventDesc_StormZombieSpawnerProps;

  /// No description provided for @eventTitle_RaidingPartyZombieSpawnerProps.
  ///
  /// In en, this message translates to:
  /// **'Raiding Party'**
  String get eventTitle_RaidingPartyZombieSpawnerProps;

  /// No description provided for @eventDesc_RaidingPartyZombieSpawnerProps.
  ///
  /// In en, this message translates to:
  /// **'Summons multiple Swashbuckler Zombies'**
  String get eventDesc_RaidingPartyZombieSpawnerProps;

  /// No description provided for @eventTitle_ZombiePotionActionProps.
  ///
  /// In en, this message translates to:
  /// **'Potion Drop'**
  String get eventTitle_ZombiePotionActionProps;

  /// No description provided for @eventDesc_ZombiePotionActionProps.
  ///
  /// In en, this message translates to:
  /// **'Force spawns grid items at set positions'**
  String get eventDesc_ZombiePotionActionProps;

  /// No description provided for @eventTitle_ZombieAtlantisShellActionProps.
  ///
  /// In en, this message translates to:
  /// **'Seashell Spawn'**
  String get eventTitle_ZombieAtlantisShellActionProps;

  /// No description provided for @eventDesc_ZombieAtlantisShellActionProps.
  ///
  /// In en, this message translates to:
  /// **'Spawns atlantis seashells at set positions'**
  String get eventDesc_ZombieAtlantisShellActionProps;

  /// No description provided for @eventTitle_SpawnEagleFlagsWaveActionProps.
  ///
  /// In en, this message translates to:
  /// **'Eagle Standard Spawn'**
  String get eventTitle_SpawnEagleFlagsWaveActionProps;

  /// No description provided for @eventDesc_SpawnEagleFlagsWaveActionProps.
  ///
  /// In en, this message translates to:
  /// **'Spawn Eagle Standards at specified positions'**
  String get eventDesc_SpawnEagleFlagsWaveActionProps;

  /// No description provided for @eventHelpEagleStandardBody.
  ///
  /// In en, this message translates to:
  /// **'This event spawns Eagle Standards at specified positions. Zombies that pass by can pick up the Eagle Standard. When the carrier is defeated, the standard drops to the ground, allowing subsequent zombies to pick it up again repeatedly. A zombie carrying the Eagle Standard grants zombies within a 3×3 area damage reduction and immunity to control effects.\nRegular plants cannot attack the Eagle Standard. Once it has been dropped, Magnet-shroom and Gold Magnet can destroy it.'**
  String get eventHelpEagleStandardBody;

  /// No description provided for @eventHelpEagleStandardEligibleZombiesTitle.
  ///
  /// In en, this message translates to:
  /// **'Eligible zombies'**
  String get eventHelpEagleStandardEligibleZombiesTitle;

  /// No description provided for @eventHelpEagleStandardEligibleZombiesBody.
  ///
  /// In en, this message translates to:
  /// **'In the current version, only Roman Zombies, Roman Coneheads, Roman Bucketheads, Centurion Zombies, Bust Head Zombies, Roman Flag Zombies, and Roman Imps can pick up the Eagle Standard. Other zombies ignore the Standard and continue past it, but can still benefit from the bonuses granted by its carrier.'**
  String get eventHelpEagleStandardEligibleZombiesBody;

  /// No description provided for @eventHelpEagleStandardUsage.
  ///
  /// In en, this message translates to:
  /// **'Select a grid cell and tap \"+\" to add an Eagle Standard. Multiple standards can be placed on the same tile and removed using the cards below. The grid adapts to the current lawn, and standards outside the lawn are listed separately.'**
  String get eventHelpEagleStandardUsage;

  /// No description provided for @eventTitle_PumpkinHouseActionProps.
  ///
  /// In en, this message translates to:
  /// **'Pumpkin House Spawn'**
  String get eventTitle_PumpkinHouseActionProps;

  /// No description provided for @eventDesc_PumpkinHouseActionProps.
  ///
  /// In en, this message translates to:
  /// **'Spawns pumpkin houses on the lawn at set positions'**
  String get eventDesc_PumpkinHouseActionProps;

  /// No description provided for @eventTitle_WaveActionZombieTentProps.
  ///
  /// In en, this message translates to:
  /// **'Zombie Tent Spawn'**
  String get eventTitle_WaveActionZombieTentProps;

  /// No description provided for @eventDesc_WaveActionZombieTentProps.
  ///
  /// In en, this message translates to:
  /// **'Spawn zombie tents at specified positions and configure the zombies they summon'**
  String get eventDesc_WaveActionZombieTentProps;

  /// No description provided for @eventTitle_SpawnGravestonesWaveActionProps.
  ///
  /// In en, this message translates to:
  /// **'Grid Item Spawn'**
  String get eventTitle_SpawnGravestonesWaveActionProps;

  /// No description provided for @eventDesc_SpawnGravestonesWaveActionProps.
  ///
  /// In en, this message translates to:
  /// **'Spawns grid items on empty tiles'**
  String get eventDesc_SpawnGravestonesWaveActionProps;

  /// No description provided for @eventTitle_SpawnZombiesFromGridItemSpawnerProps.
  ///
  /// In en, this message translates to:
  /// **'Grid Item Spawner'**
  String get eventTitle_SpawnZombiesFromGridItemSpawnerProps;

  /// No description provided for @eventDesc_SpawnZombiesFromGridItemSpawnerProps.
  ///
  /// In en, this message translates to:
  /// **'Spawns zombies from specific grid items'**
  String get eventDesc_SpawnZombiesFromGridItemSpawnerProps;

  /// No description provided for @eventTitle_FairyTaleFogWaveActionProps.
  ///
  /// In en, this message translates to:
  /// **'Magic Fog'**
  String get eventTitle_FairyTaleFogWaveActionProps;

  /// No description provided for @eventDesc_FairyTaleFogWaveActionProps.
  ///
  /// In en, this message translates to:
  /// **'Creates fog that covers the lawn and grants shields to zombies'**
  String get eventDesc_FairyTaleFogWaveActionProps;

  /// No description provided for @eventTitle_FairyTaleWindWaveActionProps.
  ///
  /// In en, this message translates to:
  /// **'Fairytale Breeze'**
  String get eventTitle_FairyTaleWindWaveActionProps;

  /// No description provided for @eventDesc_FairyTaleWindWaveActionProps.
  ///
  /// In en, this message translates to:
  /// **'Blows away all Magic Fog on the lawn'**
  String get eventDesc_FairyTaleWindWaveActionProps;

  /// No description provided for @eventTitle_SpiderRainZombieSpawnerProps.
  ///
  /// In en, this message translates to:
  /// **'Imp Rain'**
  String get eventTitle_SpiderRainZombieSpawnerProps;

  /// No description provided for @eventDesc_SpiderRainZombieSpawnerProps.
  ///
  /// In en, this message translates to:
  /// **'Imps drop in from above'**
  String get eventDesc_SpiderRainZombieSpawnerProps;

  /// No description provided for @eventTitle_ParachuteRainZombieSpawnerProps.
  ///
  /// In en, this message translates to:
  /// **'Parachute Rain'**
  String get eventTitle_ParachuteRainZombieSpawnerProps;

  /// No description provided for @eventDesc_ParachuteRainZombieSpawnerProps.
  ///
  /// In en, this message translates to:
  /// **'Zombies drop in by parachute'**
  String get eventDesc_ParachuteRainZombieSpawnerProps;

  /// No description provided for @eventTitle_BassRainZombieSpawnerProps.
  ///
  /// In en, this message translates to:
  /// **'Bass/Jetpack Rain'**
  String get eventTitle_BassRainZombieSpawnerProps;

  /// No description provided for @eventDesc_BassRainZombieSpawnerProps.
  ///
  /// In en, this message translates to:
  /// **'Jetpack or Bass Zombies drop in from above'**
  String get eventDesc_BassRainZombieSpawnerProps;

  /// No description provided for @eventTitle_BlackHoleWaveActionProps.
  ///
  /// In en, this message translates to:
  /// **'Black Hole'**
  String get eventTitle_BlackHoleWaveActionProps;

  /// No description provided for @eventDesc_BlackHoleWaveActionProps.
  ///
  /// In en, this message translates to:
  /// **'Generates a black hole to pull all plants'**
  String get eventDesc_BlackHoleWaveActionProps;

  /// No description provided for @eventTitle_BarrelWaveActionProps.
  ///
  /// In en, this message translates to:
  /// **'Barrel Crisis'**
  String get eventTitle_BarrelWaveActionProps;

  /// No description provided for @eventDesc_BarrelWaveActionProps.
  ///
  /// In en, this message translates to:
  /// **'Spawns barrels with different abilities in set lanes'**
  String get eventDesc_BarrelWaveActionProps;

  /// No description provided for @eventTitle_SchoolBusWaveActionProps.
  ///
  /// In en, this message translates to:
  /// **'Ice Cream Van Spawn'**
  String get eventTitle_SchoolBusWaveActionProps;

  /// No description provided for @eventDesc_SchoolBusWaveActionProps.
  ///
  /// In en, this message translates to:
  /// **'Spawns an ice cream van in a lane and configures the zombies inside'**
  String get eventDesc_SchoolBusWaveActionProps;

  /// No description provided for @eventTitle_HamsterZombieSpawnerProps.
  ///
  /// In en, this message translates to:
  /// **'Zombie Hamsterball'**
  String get eventTitle_HamsterZombieSpawnerProps;

  /// No description provided for @eventDesc_HamsterZombieSpawnerProps.
  ///
  /// In en, this message translates to:
  /// **'Rolls hamsterballs that carry zombies onto the lawn'**
  String get eventDesc_HamsterZombieSpawnerProps;

  /// No description provided for @eventTitle_BungeeWaveActionProps.
  ///
  /// In en, this message translates to:
  /// **'Bungee Drop'**
  String get eventTitle_BungeeWaveActionProps;

  /// No description provided for @eventDesc_BungeeWaveActionProps.
  ///
  /// In en, this message translates to:
  /// **'Drops a zombie by bungee to the lawn'**
  String get eventDesc_BungeeWaveActionProps;

  /// No description provided for @eventTitle_ThunderWaveActionProps.
  ///
  /// In en, this message translates to:
  /// **'Thundercloud Storm'**
  String get eventTitle_ThunderWaveActionProps;

  /// No description provided for @eventDesc_ThunderWaveActionProps.
  ///
  /// In en, this message translates to:
  /// **'Lightning strikes, applying positive or negative charges to plants'**
  String get eventDesc_ThunderWaveActionProps;

  /// No description provided for @eventTitle_MagicMirrorWaveActionProps.
  ///
  /// In en, this message translates to:
  /// **'Magic Mirror'**
  String get eventTitle_MagicMirrorWaveActionProps;

  /// No description provided for @eventDesc_MagicMirrorWaveActionProps.
  ///
  /// In en, this message translates to:
  /// **'Generates paired teleportation mirrors'**
  String get eventDesc_MagicMirrorWaveActionProps;

  /// No description provided for @weatherOption_DefaultSnow_label.
  ///
  /// In en, this message translates to:
  /// **'Glacial Snowfall (DefaultSnow)'**
  String get weatherOption_DefaultSnow_label;

  /// No description provided for @weatherOption_DefaultSnow_desc.
  ///
  /// In en, this message translates to:
  /// **'Snowfall effect used in Frostbite Caves Resurgence'**
  String get weatherOption_DefaultSnow_desc;

  /// No description provided for @weatherOption_LightningRain_label.
  ///
  /// In en, this message translates to:
  /// **'Thunderstorm (LightningRain)'**
  String get weatherOption_LightningRain_label;

  /// No description provided for @weatherOption_LightningRain_desc.
  ///
  /// In en, this message translates to:
  /// **'Rain with lightning strikes that are purely visual'**
  String get weatherOption_LightningRain_desc;

  /// No description provided for @weatherOption_DefaultRainDark_label.
  ///
  /// In en, this message translates to:
  /// **'Dark Rain (DefaultRainDark)'**
  String get weatherOption_DefaultRainDark_label;

  /// No description provided for @weatherOption_DefaultRainDark_desc.
  ///
  /// In en, this message translates to:
  /// **'Briefly covers the lawn in darkness before returning to normal'**
  String get weatherOption_DefaultRainDark_desc;

  /// No description provided for @iZombiePlantReserveLabel.
  ///
  /// In en, this message translates to:
  /// **'Reserved Plant Column (PlantDistance)'**
  String get iZombiePlantReserveLabel;

  /// No description provided for @column.
  ///
  /// In en, this message translates to:
  /// **'Column(s)'**
  String get column;

  /// No description provided for @iZombieInfoText.
  ///
  /// In en, this message translates to:
  /// **'In I, Zombie Mode, preset plants and zombies must be configured in the Preset Plants and Seed Bank modules respectively.'**
  String get iZombieInfoText;

  /// No description provided for @vaseRangeTitle.
  ///
  /// In en, this message translates to:
  /// **'Vase Spawn Range & Disabled Tiles'**
  String get vaseRangeTitle;

  /// No description provided for @startColumnLabel.
  ///
  /// In en, this message translates to:
  /// **'Start Col (Min)'**
  String get startColumnLabel;

  /// No description provided for @endColumnLabel.
  ///
  /// In en, this message translates to:
  /// **'End Col (Max)'**
  String get endColumnLabel;

  /// No description provided for @toggleBlacklistHint.
  ///
  /// In en, this message translates to:
  /// **'Tap tiles to toggle disabled status (vases will not spawn on disabled tiles)'**
  String get toggleBlacklistHint;

  /// No description provided for @vaseCapacityTitle.
  ///
  /// In en, this message translates to:
  /// **'Vase Capacity'**
  String get vaseCapacityTitle;

  /// No description provided for @vaseCapacitySummary.
  ///
  /// In en, this message translates to:
  /// **'Assigned: {current} / Total Slots: {total}'**
  String vaseCapacitySummary(String current, String total);

  /// No description provided for @vaseListTitle.
  ///
  /// In en, this message translates to:
  /// **'Vase List'**
  String get vaseListTitle;

  /// No description provided for @addVaseTitle.
  ///
  /// In en, this message translates to:
  /// **'Add Vase'**
  String get addVaseTitle;

  /// No description provided for @plantVaseOption.
  ///
  /// In en, this message translates to:
  /// **'Plant Vase (Green)'**
  String get plantVaseOption;

  /// No description provided for @zombieVaseOption.
  ///
  /// In en, this message translates to:
  /// **'Zombie Vase (Purple)'**
  String get zombieVaseOption;

  /// No description provided for @searchZombie.
  ///
  /// In en, this message translates to:
  /// **'Search zombie'**
  String get searchZombie;

  /// No description provided for @noZombieFound.
  ///
  /// In en, this message translates to:
  /// **'No zombie found'**
  String get noZombieFound;

  /// No description provided for @unknownVaseLabel.
  ///
  /// In en, this message translates to:
  /// **'Unknown Vase'**
  String get unknownVaseLabel;

  /// No description provided for @plantLabel.
  ///
  /// In en, this message translates to:
  /// **'Plant'**
  String get plantLabel;

  /// No description provided for @zombieLabel.
  ///
  /// In en, this message translates to:
  /// **'Zombie'**
  String get zombieLabel;

  /// No description provided for @itemLabel.
  ///
  /// In en, this message translates to:
  /// **'Item'**
  String get itemLabel;

  /// No description provided for @railcartType.
  ///
  /// In en, this message translates to:
  /// **'Minecart type'**
  String get railcartType;

  /// No description provided for @layRails.
  ///
  /// In en, this message translates to:
  /// **'Lay rails'**
  String get layRails;

  /// No description provided for @placeCarts.
  ///
  /// In en, this message translates to:
  /// **'Place minecarts'**
  String get placeCarts;

  /// No description provided for @railSegments.
  ///
  /// In en, this message translates to:
  /// **'Rail segment'**
  String get railSegments;

  /// No description provided for @railcartCount.
  ///
  /// In en, this message translates to:
  /// **'Railcart count'**
  String get railcartCount;

  /// No description provided for @clearAll.
  ///
  /// In en, this message translates to:
  /// **'Clear all'**
  String get clearAll;

  /// No description provided for @moduleCategoryBase.
  ///
  /// In en, this message translates to:
  /// **'Basic'**
  String get moduleCategoryBase;

  /// No description provided for @moduleCategoryMode.
  ///
  /// In en, this message translates to:
  /// **'Special Modes'**
  String get moduleCategoryMode;

  /// No description provided for @moduleCategoryScene.
  ///
  /// In en, this message translates to:
  /// **'Scene Config'**
  String get moduleCategoryScene;

  /// No description provided for @moduleCategoryGimmick.
  ///
  /// In en, this message translates to:
  /// **'Gimmick Config'**
  String get moduleCategoryGimmick;

  /// No description provided for @moduleTitle_RocketZombieFlickModuleProperties.
  ///
  /// In en, this message translates to:
  /// **'Rocket Flick'**
  String get moduleTitle_RocketZombieFlickModuleProperties;

  /// No description provided for @moduleDesc_RocketZombieFlickModuleProperties.
  ///
  /// In en, this message translates to:
  /// **'Enables swiping to knock Rocket Imps off their rockets'**
  String get moduleDesc_RocketZombieFlickModuleProperties;

  /// No description provided for @kongfuRocketFlickDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'This Module Can Be Added'**
  String get kongfuRocketFlickDialogTitle;

  /// No description provided for @kongfuRocketFlickDialogMessage.
  ///
  /// In en, this message translates to:
  /// **'The \"Rocket Flick\" module lets you swipe rockets on the screen to knock Rocket Imps off them. Add this module?'**
  String get kongfuRocketFlickDialogMessage;

  /// No description provided for @customZombie.
  ///
  /// In en, this message translates to:
  /// **'Custom zombie'**
  String get customZombie;

  /// No description provided for @customZombieProperties.
  ///
  /// In en, this message translates to:
  /// **'Custom Zombie Properties'**
  String get customZombieProperties;

  /// No description provided for @zombieTypeNotFound.
  ///
  /// In en, this message translates to:
  /// **'Zombie type object not found.'**
  String get zombieTypeNotFound;

  /// No description provided for @propertyObjectNotFound.
  ///
  /// In en, this message translates to:
  /// **'Property object not found'**
  String get propertyObjectNotFound;

  /// No description provided for @propertyObjectNotFoundHint.
  ///
  /// In en, this message translates to:
  /// **'The custom zombie\'s property object ({alias}) was not found in the level. The property definition does not point to level internals, so it cannot be edited here.'**
  String propertyObjectNotFoundHint(String alias);

  /// No description provided for @baseStats.
  ///
  /// In en, this message translates to:
  /// **'Base stats'**
  String get baseStats;

  /// No description provided for @hitpoints.
  ///
  /// In en, this message translates to:
  /// **'Health (Hitpoints)'**
  String get hitpoints;

  /// No description provided for @speed.
  ///
  /// In en, this message translates to:
  /// **'Movement speed (Speed)'**
  String get speed;

  /// No description provided for @speedVariance.
  ///
  /// In en, this message translates to:
  /// **'Speed variance (Variance)'**
  String get speedVariance;

  /// No description provided for @eatDPS.
  ///
  /// In en, this message translates to:
  /// **'Bite damage per second (EatDPS)'**
  String get eatDPS;

  /// No description provided for @hitPosition.
  ///
  /// In en, this message translates to:
  /// **'Hit & Position'**
  String get hitPosition;

  /// No description provided for @hitRect.
  ///
  /// In en, this message translates to:
  /// **'Hitbox (HitRect)'**
  String get hitRect;

  /// No description provided for @editHitRect.
  ///
  /// In en, this message translates to:
  /// **'Edit Hitbox (HitRect)'**
  String get editHitRect;

  /// No description provided for @attackRect.
  ///
  /// In en, this message translates to:
  /// **'Eating Range (AttackRect)'**
  String get attackRect;

  /// No description provided for @editAttackRect.
  ///
  /// In en, this message translates to:
  /// **'Edit Eating Range (AttackRect)'**
  String get editAttackRect;

  /// No description provided for @artCenter.
  ///
  /// In en, this message translates to:
  /// **'Sprite Center (ArtCenter)'**
  String get artCenter;

  /// No description provided for @editArtCenter.
  ///
  /// In en, this message translates to:
  /// **'Edit Sprite Center (ArtCenter)'**
  String get editArtCenter;

  /// No description provided for @shadowOffset.
  ///
  /// In en, this message translates to:
  /// **'Shadow Offset (ShadowOffset)'**
  String get shadowOffset;

  /// No description provided for @editShadowOffset.
  ///
  /// In en, this message translates to:
  /// **'Edit Shadow Offset (ShadowOffset)'**
  String get editShadowOffset;

  /// No description provided for @groundTrackName.
  ///
  /// In en, this message translates to:
  /// **'Movement Track (GroundTrackName)'**
  String get groundTrackName;

  /// No description provided for @groundTrackNormal.
  ///
  /// In en, this message translates to:
  /// **'Normal ground (ground_swatch)'**
  String get groundTrackNormal;

  /// No description provided for @groundTrackNone.
  ///
  /// In en, this message translates to:
  /// **'None (null)'**
  String get groundTrackNone;

  /// No description provided for @appearanceBehavior.
  ///
  /// In en, this message translates to:
  /// **'Appearance & Behavior'**
  String get appearanceBehavior;

  /// No description provided for @sizeType.
  ///
  /// In en, this message translates to:
  /// **'Zombie Size (SizeType)'**
  String get sizeType;

  /// No description provided for @selectSize.
  ///
  /// In en, this message translates to:
  /// **'Select size'**
  String get selectSize;

  /// No description provided for @disableDropFractions.
  ///
  /// In en, this message translates to:
  /// **'Disable corpse HP (headDropFraction)'**
  String get disableDropFractions;

  /// No description provided for @immuneToKnockback.
  ///
  /// In en, this message translates to:
  /// **'Immune to knockback (CanBeLaunchedByPlants)'**
  String get immuneToKnockback;

  /// No description provided for @showHealthBarOnDamage.
  ///
  /// In en, this message translates to:
  /// **'Show health bar on damage (EnableShowHealthBar)'**
  String get showHealthBarOnDamage;

  /// No description provided for @drawHealthBarTime.
  ///
  /// In en, this message translates to:
  /// **'Health bar duration (DrawHealthBarTime; seconds)'**
  String get drawHealthBarTime;

  /// No description provided for @enableEliteScale.
  ///
  /// In en, this message translates to:
  /// **'Enable elite scaling (EnableEliteScale)'**
  String get enableEliteScale;

  /// No description provided for @eliteScale.
  ///
  /// In en, this message translates to:
  /// **'Scale (EliteScale)'**
  String get eliteScale;

  /// No description provided for @enableEliteImmunities.
  ///
  /// In en, this message translates to:
  /// **'Enable elite immunities (EnableEliteImmunities)'**
  String get enableEliteImmunities;

  /// No description provided for @canSpawnPlantFood.
  ///
  /// In en, this message translates to:
  /// **'Can drop Plant Food (CanSpawnPlantFood)'**
  String get canSpawnPlantFood;

  /// No description provided for @canSurrender.
  ///
  /// In en, this message translates to:
  /// **'Can die immediately at the end if no other zombies remain (CanSurrender)'**
  String get canSurrender;

  /// No description provided for @canTriggerZombieWin.
  ///
  /// In en, this message translates to:
  /// **'Can trigger game over when reaching the house (CanTriggerZombieWin)'**
  String get canTriggerZombieWin;

  /// No description provided for @resilience.
  ///
  /// In en, this message translates to:
  /// **'Resistances (Resistences)'**
  String get resilience;

  /// No description provided for @resilienceArmor.
  ///
  /// In en, this message translates to:
  /// **'Resilience Shield'**
  String get resilienceArmor;

  /// No description provided for @enableResilience.
  ///
  /// In en, this message translates to:
  /// **'Enable resilience'**
  String get enableResilience;

  /// No description provided for @resiliencePresetSelect.
  ///
  /// In en, this message translates to:
  /// **'Selected resilience shield'**
  String get resiliencePresetSelect;

  /// No description provided for @resilienceAmount.
  ///
  /// In en, this message translates to:
  /// **'Resilience value (Amount)'**
  String get resilienceAmount;

  /// No description provided for @resilienceWeakType.
  ///
  /// In en, this message translates to:
  /// **'Resilience type (WeakType)'**
  String get resilienceWeakType;

  /// No description provided for @resilienceRecoverSpeed.
  ///
  /// In en, this message translates to:
  /// **'Resilience bar recovery speed (RecoverSpeed)'**
  String get resilienceRecoverSpeed;

  /// No description provided for @resilienceDamageThresholdPerSecond.
  ///
  /// In en, this message translates to:
  /// **'Zombie damage threshold per second (DamageThresholdPerSecond)'**
  String get resilienceDamageThresholdPerSecond;

  /// No description provided for @resilienceBaseDamageThreshold.
  ///
  /// In en, this message translates to:
  /// **'Resilience base damage threshold (ResilienceBaseDamageThreshold)'**
  String get resilienceBaseDamageThreshold;

  /// No description provided for @resilienceExtraDamageThreshold.
  ///
  /// In en, this message translates to:
  /// **'Resilience extra damage threshold (ResilienceExtraDamageThreshold)'**
  String get resilienceExtraDamageThreshold;

  /// No description provided for @resilienceCodename.
  ///
  /// In en, this message translates to:
  /// **'Resilience codename (aliases; English letters only; no spaces)'**
  String get resilienceCodename;

  /// No description provided for @resilienceCodenameHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. CustomResilience0'**
  String get resilienceCodenameHint;

  /// No description provided for @instantKillResistance.
  ///
  /// In en, this message translates to:
  /// **'Instant kill resistance (chance to ignore instant kill effects)'**
  String get instantKillResistance;

  /// No description provided for @resiliencePhysics.
  ///
  /// In en, this message translates to:
  /// **'Physics'**
  String get resiliencePhysics;

  /// No description provided for @resiliencePoison.
  ///
  /// In en, this message translates to:
  /// **'Poison'**
  String get resiliencePoison;

  /// No description provided for @resilienceElectric.
  ///
  /// In en, this message translates to:
  /// **'Electric'**
  String get resilienceElectric;

  /// No description provided for @resilienceMagic.
  ///
  /// In en, this message translates to:
  /// **'Magic'**
  String get resilienceMagic;

  /// No description provided for @resilienceIce.
  ///
  /// In en, this message translates to:
  /// **'Ice'**
  String get resilienceIce;

  /// No description provided for @resilienceFire.
  ///
  /// In en, this message translates to:
  /// **'Fire'**
  String get resilienceFire;

  /// No description provided for @resilienceHint.
  ///
  /// In en, this message translates to:
  /// **'Value range: 0.0–1.0 (0.0 = no resistance, 1.0 = full immunity)'**
  String get resilienceHint;

  /// No description provided for @resilienceSelectedShieldLabel.
  ///
  /// In en, this message translates to:
  /// **'Selected Resilience Shield:'**
  String get resilienceSelectedShieldLabel;

  /// No description provided for @selectionFilterBySource.
  ///
  /// In en, this message translates to:
  /// **'By source'**
  String get selectionFilterBySource;

  /// No description provided for @selectionFilterByType.
  ///
  /// In en, this message translates to:
  /// **'By type'**
  String get selectionFilterByType;

  /// No description provided for @selectionPreMade.
  ///
  /// In en, this message translates to:
  /// **'Pre-made'**
  String get selectionPreMade;

  /// No description provided for @selectionDefinedByUser.
  ///
  /// In en, this message translates to:
  /// **'Custom'**
  String get selectionDefinedByUser;

  /// No description provided for @aliasAlreadyTakenTitle.
  ///
  /// In en, this message translates to:
  /// **'Alias already taken'**
  String get aliasAlreadyTakenTitle;

  /// No description provided for @aliasRenameConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Rename alias?'**
  String get aliasRenameConfirmTitle;

  /// No description provided for @aliasRenameConfirmMessage.
  ///
  /// In en, this message translates to:
  /// **'Rename \"{oldAlias}\" to \"{newAlias}\"? All references in this level will be updated.'**
  String aliasRenameConfirmMessage(String oldAlias, String newAlias);

  /// No description provided for @resilienceSelectShield.
  ///
  /// In en, this message translates to:
  /// **'Select resilience shield'**
  String get resilienceSelectShield;

  /// No description provided for @resilienceCreateCustom.
  ///
  /// In en, this message translates to:
  /// **'New custom shield'**
  String get resilienceCreateCustom;

  /// No description provided for @resilienceEditCustom.
  ///
  /// In en, this message translates to:
  /// **'Edit custom shield'**
  String get resilienceEditCustom;

  /// No description provided for @resilienceTypeAll.
  ///
  /// In en, this message translates to:
  /// **'All types'**
  String get resilienceTypeAll;

  /// No description provided for @resilienceNoShieldsFound.
  ///
  /// In en, this message translates to:
  /// **'No resilience shields found'**
  String get resilienceNoShieldsFound;

  /// No description provided for @resilienceShieldInUseCannotDelete.
  ///
  /// In en, this message translates to:
  /// **'Cannot delete — this shield is used by zombies in this level.'**
  String get resilienceShieldInUseCannotDelete;

  /// No description provided for @resilienceShieldDeleteTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete custom resilience shield?'**
  String get resilienceShieldDeleteTitle;

  /// No description provided for @resilienceShieldDeleteMessage.
  ///
  /// In en, this message translates to:
  /// **'Delete \"{alias}\" from this level?'**
  String resilienceShieldDeleteMessage(String alias);

  /// No description provided for @aliasAlreadyExists.
  ///
  /// In en, this message translates to:
  /// **'Alias already exists in this level.'**
  String get aliasAlreadyExists;

  /// No description provided for @zombieTypeLabel.
  ///
  /// In en, this message translates to:
  /// **'Zombie type: {type}'**
  String zombieTypeLabel(String type);

  /// No description provided for @propertyAliasLabel.
  ///
  /// In en, this message translates to:
  /// **'Property alias: {alias}'**
  String propertyAliasLabel(String alias);

  /// No description provided for @ok.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get ok;

  /// No description provided for @helpDialogGotIt.
  ///
  /// In en, this message translates to:
  /// **'Got it'**
  String get helpDialogGotIt;

  /// No description provided for @width.
  ///
  /// In en, this message translates to:
  /// **'Width'**
  String get width;

  /// No description provided for @height.
  ///
  /// In en, this message translates to:
  /// **'Height'**
  String get height;

  /// No description provided for @customZombieHelpIntro.
  ///
  /// In en, this message translates to:
  /// **'Brief introduction'**
  String get customZombieHelpIntro;

  /// No description provided for @customZombieHelpIntroBody.
  ///
  /// In en, this message translates to:
  /// **'This screen edits custom zombie parameters injected into the level. Only common properties are supported; many special attributes require manual JSON editing.'**
  String get customZombieHelpIntroBody;

  /// No description provided for @customZombieHelpBase.
  ///
  /// In en, this message translates to:
  /// **'Base properties'**
  String get customZombieHelpBase;

  /// No description provided for @customZombieHelpBaseBody.
  ///
  /// In en, this message translates to:
  /// **'Custom zombies can modify base stats (HP, speed, eat damage). Custom zombies do not appear in the level preview pool.'**
  String get customZombieHelpBaseBody;

  /// No description provided for @customZombieHelpHit.
  ///
  /// In en, this message translates to:
  /// **'Hit/position'**
  String get customZombieHelpHit;

  /// No description provided for @customZombieHelpHitBody.
  ///
  /// In en, this message translates to:
  /// **'X and Y are offsets; W and H are width and height. Offsetting ArtCenter can hide the zombie sprite. Leaving ground track as none lets the zombie walk in place.'**
  String get customZombieHelpHitBody;

  /// No description provided for @customZombieHelpManual.
  ///
  /// In en, this message translates to:
  /// **'Manual editing'**
  String get customZombieHelpManual;

  /// No description provided for @customZombieHelpManualBody.
  ///
  /// In en, this message translates to:
  /// **'When injecting a custom zombie, the editor automatically fills in the original zombie\'s relevant properties from the corresponding game files. You can further edit the JSON file manually if needed.'**
  String get customZombieHelpManualBody;

  /// No description provided for @editAlias.
  ///
  /// In en, this message translates to:
  /// **'Edit {alias}'**
  String editAlias(String alias);

  /// No description provided for @editNamedEvent.
  ///
  /// In en, this message translates to:
  /// **'Edit {name} event'**
  String editNamedEvent(String name);

  /// No description provided for @editNamedModule.
  ///
  /// In en, this message translates to:
  /// **'Edit {name} module'**
  String editNamedModule(String name);

  /// No description provided for @addEventAliasTitle.
  ///
  /// In en, this message translates to:
  /// **'Add event'**
  String get addEventAliasTitle;

  /// No description provided for @addModuleAliasTitle.
  ///
  /// In en, this message translates to:
  /// **'Add module'**
  String get addModuleAliasTitle;

  /// No description provided for @aliasLabel.
  ///
  /// In en, this message translates to:
  /// **'Alias (English letters only; no spaces)'**
  String get aliasLabel;

  /// No description provided for @add.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get add;

  /// No description provided for @overview.
  ///
  /// In en, this message translates to:
  /// **'Overview'**
  String get overview;

  /// No description provided for @left.
  ///
  /// In en, this message translates to:
  /// **'Left'**
  String get left;

  /// No description provided for @right.
  ///
  /// In en, this message translates to:
  /// **'Right'**
  String get right;

  /// No description provided for @weight.
  ///
  /// In en, this message translates to:
  /// **'Weight'**
  String get weight;

  /// No description provided for @maxCount.
  ///
  /// In en, this message translates to:
  /// **'Max count'**
  String get maxCount;

  /// No description provided for @startColumn.
  ///
  /// In en, this message translates to:
  /// **'Start column'**
  String get startColumn;

  /// No description provided for @endColumn.
  ///
  /// In en, this message translates to:
  /// **'End column'**
  String get endColumn;

  /// No description provided for @removeItem.
  ///
  /// In en, this message translates to:
  /// **'Remove item'**
  String get removeItem;

  /// No description provided for @removeItemConfirm.
  ///
  /// In en, this message translates to:
  /// **'Remove {name}?'**
  String removeItemConfirm(String name);

  /// No description provided for @groupN.
  ///
  /// In en, this message translates to:
  /// **'Group {n}'**
  String groupN(int n);

  /// No description provided for @rowN.
  ///
  /// In en, this message translates to:
  /// **'Row {n}'**
  String rowN(int n);

  /// No description provided for @addWind.
  ///
  /// In en, this message translates to:
  /// **'Add wind'**
  String get addWind;

  /// No description provided for @addDropItem.
  ///
  /// In en, this message translates to:
  /// **'Add drop item'**
  String get addDropItem;

  /// No description provided for @addMirrorGroup.
  ///
  /// In en, this message translates to:
  /// **'Add a mirror group above'**
  String get addMirrorGroup;

  /// No description provided for @pipeN.
  ///
  /// In en, this message translates to:
  /// **'Pipe {n}'**
  String pipeN(int n);

  /// No description provided for @setStart.
  ///
  /// In en, this message translates to:
  /// **'Set entrance sewer'**
  String get setStart;

  /// No description provided for @setEnd.
  ///
  /// In en, this message translates to:
  /// **'Set exit sewer'**
  String get setEnd;

  /// No description provided for @collectable.
  ///
  /// In en, this message translates to:
  /// **'Collectible (Plant Food)'**
  String get collectable;

  /// No description provided for @plantFood.
  ///
  /// In en, this message translates to:
  /// **'Plant Food'**
  String get plantFood;

  /// No description provided for @initialPlantLayout.
  ///
  /// In en, this message translates to:
  /// **'Initial plant layout'**
  String get initialPlantLayout;

  /// No description provided for @gridItemLayout.
  ///
  /// In en, this message translates to:
  /// **'Grid item layout'**
  String get gridItemLayout;

  /// No description provided for @zombieCount.
  ///
  /// In en, this message translates to:
  /// **'Total count (Total)'**
  String get zombieCount;

  /// No description provided for @timeBeforeSpawn.
  ///
  /// In en, this message translates to:
  /// **'Time before full spawn (seconds)'**
  String get timeBeforeSpawn;

  /// No description provided for @waterBoundaryColumn.
  ///
  /// In en, this message translates to:
  /// **'Column Offset (ChangeAmount)'**
  String get waterBoundaryColumn;

  /// No description provided for @columnsDragged.
  ///
  /// In en, this message translates to:
  /// **'Columns dragged (ColNumPlantIsDragged)'**
  String get columnsDragged;

  /// No description provided for @typeIndex.
  ///
  /// In en, this message translates to:
  /// **'Mirror Appearance (TypeIndex)'**
  String get typeIndex;

  /// No description provided for @noStyle.
  ///
  /// In en, this message translates to:
  /// **'No style'**
  String get noStyle;

  /// No description provided for @styleN.
  ///
  /// In en, this message translates to:
  /// **'Style {n}'**
  String styleN(int n);

  /// No description provided for @existDurationSec.
  ///
  /// In en, this message translates to:
  /// **'Exist duration (sec)'**
  String get existDurationSec;

  /// No description provided for @mirror1.
  ///
  /// In en, this message translates to:
  /// **'Mirror 1'**
  String get mirror1;

  /// No description provided for @mirror2.
  ///
  /// In en, this message translates to:
  /// **'Mirror 2'**
  String get mirror2;

  /// No description provided for @ignoreGravestone.
  ///
  /// In en, this message translates to:
  /// **'Ignore tombstone (IgnoreGraveStone)'**
  String get ignoreGravestone;

  /// No description provided for @zombiePreview.
  ///
  /// In en, this message translates to:
  /// **'{name} - Zombie preview'**
  String zombiePreview(String name);

  /// No description provided for @zombiePreviewTooltip.
  ///
  /// In en, this message translates to:
  /// **'Zombie preview'**
  String get zombiePreviewTooltip;

  /// No description provided for @weatherSettings.
  ///
  /// In en, this message translates to:
  /// **'Weather Settings'**
  String get weatherSettings;

  /// No description provided for @holeLifetimeSeconds.
  ///
  /// In en, this message translates to:
  /// **'Crater duration (seconds)'**
  String get holeLifetimeSeconds;

  /// No description provided for @startingWaveLocation.
  ///
  /// In en, this message translates to:
  /// **'Initial tide position (StartingWaveLocation)'**
  String get startingWaveLocation;

  /// No description provided for @rainIntervalSeconds.
  ///
  /// In en, this message translates to:
  /// **'Drop interval (seconds)'**
  String get rainIntervalSeconds;

  /// No description provided for @bowlingFoulLine.
  ///
  /// In en, this message translates to:
  /// **'No-planting line (BowlingFoulLine)'**
  String get bowlingFoulLine;

  /// No description provided for @bowlingFoulLinePreview.
  ///
  /// In en, this message translates to:
  /// **'No-planting line preview'**
  String get bowlingFoulLinePreview;

  /// No description provided for @bowlingMinigameParams.
  ///
  /// In en, this message translates to:
  /// **'Parameters'**
  String get bowlingMinigameParams;

  /// No description provided for @bowlingMinigameHelpOverview.
  ///
  /// In en, this message translates to:
  /// **'A legacy configuration module for Bulb Bowling that sets the no-planting line and disables the shovel. It can also be used in regular levels. Plants cannot be placed on or to the right of the no-planting line.'**
  String get bowlingMinigameHelpOverview;

  /// No description provided for @bowlingMinigameHelpFoulLine.
  ///
  /// In en, this message translates to:
  /// **'Sets the column boundary for the no-planting area. Its value is counted from the left edge of the lawn starting at 0. For example, the left boundary of the first tile from the left is 0, while its right boundary is 1. Lower boundary values leave less usable space on the left.\nOn Underwater World lawns, the game automatically adds 1 to this value. For example, a value of 0 leaves column 1 plantable and blocks planting from column 2 onward; the minimum value available in the editor is therefore -1.'**
  String get bowlingMinigameHelpFoulLine;

  /// No description provided for @stopColumn.
  ///
  /// In en, this message translates to:
  /// **'Stop Column'**
  String get stopColumn;

  /// No description provided for @speedUp.
  ///
  /// In en, this message translates to:
  /// **'Speed Multiplier'**
  String get speedUp;

  /// No description provided for @baseCostIncreased.
  ///
  /// In en, this message translates to:
  /// **'Sun cost increase per planting (BaseCostIncreased)'**
  String get baseCostIncreased;

  /// No description provided for @maxIncreasedCount.
  ///
  /// In en, this message translates to:
  /// **'Max Cost Increase Count (MaxIncreasedCount)'**
  String get maxIncreasedCount;

  /// No description provided for @initialMistPositionX.
  ///
  /// In en, this message translates to:
  /// **'Initial fog column'**
  String get initialMistPositionX;

  /// No description provided for @normalValueX.
  ///
  /// In en, this message translates to:
  /// **'Extension distance to the right (1 tile = 64 units)'**
  String get normalValueX;

  /// No description provided for @bloverEffectInterval.
  ///
  /// In en, this message translates to:
  /// **'Blover effect interval (seconds)'**
  String get bloverEffectInterval;

  /// No description provided for @dinoType.
  ///
  /// In en, this message translates to:
  /// **'Dinosaur type'**
  String get dinoType;

  /// No description provided for @dinoRowTitle.
  ///
  /// In en, this message translates to:
  /// **'Row'**
  String get dinoRowTitle;

  /// No description provided for @dinoRow.
  ///
  /// In en, this message translates to:
  /// **'Row: {n}'**
  String dinoRow(int n);

  /// No description provided for @dinoWaveDuration.
  ///
  /// In en, this message translates to:
  /// **'Stay duration (waves)'**
  String get dinoWaveDuration;

  /// No description provided for @eventHelpDinoRow.
  ///
  /// In en, this message translates to:
  /// **'The row where the dinosaur appears, counted from 0. On Underwater World lawns, this can be set to 5 for the sixth row.'**
  String get eventHelpDinoRow;

  /// No description provided for @eventHelpDinoWaveDuration.
  ///
  /// In en, this message translates to:
  /// **'The number of waves a dinosaur remains on the lawn. The dinosaur will leave after staying for the specified number of waves or after interacting with a certain number of zombies. When set to 0, there is no wave limit, and the dinosaur will leave after completing its interactions by default.'**
  String get eventHelpDinoWaveDuration;

  /// No description provided for @unknownModuleTitle.
  ///
  /// In en, this message translates to:
  /// **'Module editor in development'**
  String get unknownModuleTitle;

  /// No description provided for @unknownModuleHelpTitle.
  ///
  /// In en, this message translates to:
  /// **'Unknown module'**
  String get unknownModuleHelpTitle;

  /// No description provided for @noEditorForModule.
  ///
  /// In en, this message translates to:
  /// **'No editor available for this module'**
  String get noEditorForModule;

  /// No description provided for @noEditorForModuleBody.
  ///
  /// In en, this message translates to:
  /// **'This module is not registered in the level interpreter, so no editor is available. It may also be due to the module\'s objclass being manually modified, preventing it from being read correctly.'**
  String get noEditorForModuleBody;

  /// No description provided for @invalidEventTitle.
  ///
  /// In en, this message translates to:
  /// **'Invalid event'**
  String get invalidEventTitle;

  /// No description provided for @invalidReference.
  ///
  /// In en, this message translates to:
  /// **'Invalid reference'**
  String get invalidReference;

  /// No description provided for @aliasNotFound.
  ///
  /// In en, this message translates to:
  /// **'Alias \"{alias}\" not found'**
  String aliasNotFound(String alias);

  /// No description provided for @invalidRefBody.
  ///
  /// In en, this message translates to:
  /// **'Wave {wave} references this event, but no corresponding entity definition was found in the level. This is usually caused by accidental deletion or manual renaming. Keeping it in the level may cause the game to crash.'**
  String invalidRefBody(int wave);

  /// No description provided for @removeInvalidRef.
  ///
  /// In en, this message translates to:
  /// **'Remove this invalid reference from the wave container'**
  String get removeInvalidRef;

  /// No description provided for @spawnCount.
  ///
  /// In en, this message translates to:
  /// **'Spawn count'**
  String get spawnCount;

  /// No description provided for @columnRangeTiming.
  ///
  /// In en, this message translates to:
  /// **'Column range & timing'**
  String get columnRangeTiming;

  /// No description provided for @waveStartMessage.
  ///
  /// In en, this message translates to:
  /// **'Red warning message'**
  String get waveStartMessage;

  /// No description provided for @optional.
  ///
  /// In en, this message translates to:
  /// **'Shown at the center when the event starts; Chinese input not supported'**
  String get optional;

  /// No description provided for @eventHelpBeachStageBody.
  ///
  /// In en, this message translates to:
  /// **'Zombies emerge from beneath the water. Commonly used for Snorkel Zombies in Big Wave Beach or for zombies that appear during low tide.\nSimilar to Parachute Rain, zombies will spawn in batches. You can specify the total number and spawn range.\nOnly one type of zombie can be used per event. To include multiple types, you need to add multiple events.'**
  String get eventHelpBeachStageBody;

  /// No description provided for @eventHelpTidalChangeBody.
  ///
  /// In en, this message translates to:
  /// **'This event is used to change the tide position during the selected wave. The range of tide changes cannot exceed the bounds of the lawn.'**
  String get eventHelpTidalChangeBody;

  /// No description provided for @eventTideWave.
  ///
  /// In en, this message translates to:
  /// **'Event: Ocean Currents'**
  String get eventTideWave;

  /// No description provided for @eventHelpTideWaveBody.
  ///
  /// In en, this message translates to:
  /// **'Creates ocean currents that push the submarine and grant speed boosts to zombies. Commonly used in Underwater World – 20,000 Leagues Under the Sea levels.'**
  String get eventHelpTideWaveBody;

  /// No description provided for @tideWaveHelpType.
  ///
  /// In en, this message translates to:
  /// **'Direction'**
  String get tideWaveHelpType;

  /// No description provided for @eventHelpTideWaveType.
  ///
  /// In en, this message translates to:
  /// **'Left: Currents come from the left, pushing the submarine right and speeding up zombies on the left side.\nRight: Currents come from the right, pushing the submarine left and speeding up zombies on the right side.'**
  String get eventHelpTideWaveType;

  /// No description provided for @tideWaveHelpParams.
  ///
  /// In en, this message translates to:
  /// **'Notes'**
  String get tideWaveHelpParams;

  /// No description provided for @eventHelpTideWaveParams.
  ///
  /// In en, this message translates to:
  /// **'Unless otherwise specified, the submarine returns to its original position after the duration ends. Plants cannot be planted on the submarine while it is moving.'**
  String get eventHelpTideWaveParams;

  /// No description provided for @tideWaveType.
  ///
  /// In en, this message translates to:
  /// **'Direction (Type)'**
  String get tideWaveType;

  /// No description provided for @tideWaveTypeLeft.
  ///
  /// In en, this message translates to:
  /// **'Left'**
  String get tideWaveTypeLeft;

  /// No description provided for @tideWaveTypeRight.
  ///
  /// In en, this message translates to:
  /// **'Right'**
  String get tideWaveTypeRight;

  /// No description provided for @tideWaveDuration.
  ///
  /// In en, this message translates to:
  /// **'Duration (seconds)'**
  String get tideWaveDuration;

  /// No description provided for @tideWaveSubmarineMovingDistance.
  ///
  /// In en, this message translates to:
  /// **'Submarine moving distance (columns)'**
  String get tideWaveSubmarineMovingDistance;

  /// No description provided for @tideWaveSpeedUpDuration.
  ///
  /// In en, this message translates to:
  /// **'Speed boost duration (seconds)'**
  String get tideWaveSpeedUpDuration;

  /// No description provided for @tideWaveSpeedUpIncreased.
  ///
  /// In en, this message translates to:
  /// **'Speed boost multiplier (tideWaveSpeedUpIncreased)'**
  String get tideWaveSpeedUpIncreased;

  /// No description provided for @tideWaveSubmarineMovingTime.
  ///
  /// In en, this message translates to:
  /// **'Submarine moving time (seconds)'**
  String get tideWaveSubmarineMovingTime;

  /// No description provided for @tideWaveZombieMovingSpeed.
  ///
  /// In en, this message translates to:
  /// **'Zombie speed in current (tideWaveZombieMovingSpeed; 1 tile = 64 units)'**
  String get tideWaveZombieMovingSpeed;

  /// No description provided for @eventZombieFishWave.
  ///
  /// In en, this message translates to:
  /// **'Event: Underwater Spawner'**
  String get eventZombieFishWave;

  /// No description provided for @eventHelpZombieFishWaveBody.
  ///
  /// In en, this message translates to:
  /// **'Configures the zombies and sea creatures used in Two-Sided Attack, and can only be used in Underwater World levels. Coordinates are 0-based: row 1 = 0, column 10 = 9.'**
  String get eventHelpZombieFishWaveBody;

  /// No description provided for @eventHelpZombieFishWaveFish.
  ///
  /// In en, this message translates to:
  /// **'Use the \"Add sea creature properties\" button to place sea creatures on the lawn. Size of the lawn varies by level: 6×10 in Underwater World, 5×9 in other levels. Rows correspond to Y, columns to X.'**
  String get eventHelpZombieFishWaveFish;

  /// No description provided for @eventHelpBatchLevel.
  ///
  /// In en, this message translates to:
  /// **'Sets all zombies in this wave to the specified level. Elite zombies are unaffected and retain their default level.'**
  String get eventHelpBatchLevel;

  /// No description provided for @eventHelpDropConfig.
  ///
  /// In en, this message translates to:
  /// **'If the number of plants in the drop list equals the number of Plant Food drops, the drops will become seed packets.'**
  String get eventHelpDropConfig;

  /// No description provided for @fishPropertiesEntryHelp.
  ///
  /// In en, this message translates to:
  /// **'Tap a tile to select it, then add sea creatures. Tap \"+\" to add built-in sea creatures. Tap a creature\'s icon for more options such as duplicate, delete, or customize. Customized creatures are marked with a blue \"C\". A warning is shown if a creature is placed outside the lawn.'**
  String get fishPropertiesEntryHelp;

  /// No description provided for @makeFishAsCustom.
  ///
  /// In en, this message translates to:
  /// **'Make sea creature as custom'**
  String get makeFishAsCustom;

  /// No description provided for @switchCustomFish.
  ///
  /// In en, this message translates to:
  /// **'Switch custom sea creature'**
  String get switchCustomFish;

  /// No description provided for @selectCustomFish.
  ///
  /// In en, this message translates to:
  /// **'Select custom sea creature'**
  String get selectCustomFish;

  /// No description provided for @editCustomFishProperties.
  ///
  /// In en, this message translates to:
  /// **'Edit custom sea creature properties'**
  String get editCustomFishProperties;

  /// No description provided for @fishPropertiesButton.
  ///
  /// In en, this message translates to:
  /// **'Sea creature properties'**
  String get fishPropertiesButton;

  /// No description provided for @addFishProperties.
  ///
  /// In en, this message translates to:
  /// **'Add sea creature properties'**
  String get addFishProperties;

  /// No description provided for @editFishProperties.
  ///
  /// In en, this message translates to:
  /// **'Edit sea creature properties'**
  String get editFishProperties;

  /// No description provided for @fishPropertiesGrid.
  ///
  /// In en, this message translates to:
  /// **'Sea Creature placement (row = Y, column = X)'**
  String get fishPropertiesGrid;

  /// No description provided for @fishSelectedPosition.
  ///
  /// In en, this message translates to:
  /// **'Selected:'**
  String get fishSelectedPosition;

  /// No description provided for @fishRow.
  ///
  /// In en, this message translates to:
  /// **'Row'**
  String get fishRow;

  /// No description provided for @fishColumn.
  ///
  /// In en, this message translates to:
  /// **'Column'**
  String get fishColumn;

  /// No description provided for @fishAtPosition.
  ///
  /// In en, this message translates to:
  /// **'Sea creature at position'**
  String get fishAtPosition;

  /// No description provided for @searchFish.
  ///
  /// In en, this message translates to:
  /// **'Search sea creature'**
  String get searchFish;

  /// No description provided for @noFishFound.
  ///
  /// In en, this message translates to:
  /// **'No sea creature found'**
  String get noFishFound;

  /// No description provided for @customFishManagerTitle.
  ///
  /// In en, this message translates to:
  /// **'Custom sea creature'**
  String get customFishManagerTitle;

  /// No description provided for @customFishAppearanceLocation.
  ///
  /// In en, this message translates to:
  /// **'Spawn location:'**
  String get customFishAppearanceLocation;

  /// No description provided for @customFishNotUsed.
  ///
  /// In en, this message translates to:
  /// **'This custom sea creature is not used by any wave.'**
  String get customFishNotUsed;

  /// No description provided for @customFishWaveItem.
  ///
  /// In en, this message translates to:
  /// **'Wave {n}'**
  String customFishWaveItem(int n);

  /// No description provided for @customFishDeleteConfirm.
  ///
  /// In en, this message translates to:
  /// **'Remove this custom sea creature and its property data.'**
  String get customFishDeleteConfirm;

  /// No description provided for @customFish.
  ///
  /// In en, this message translates to:
  /// **'Custom sea creature'**
  String get customFish;

  /// No description provided for @customFishProperties.
  ///
  /// In en, this message translates to:
  /// **'Custom sea creature properties'**
  String get customFishProperties;

  /// No description provided for @fishTypeNotFound.
  ///
  /// In en, this message translates to:
  /// **'Sea creature type object not found.'**
  String get fishTypeNotFound;

  /// No description provided for @fishTypeLabel.
  ///
  /// In en, this message translates to:
  /// **'Sea creature type: {type}'**
  String fishTypeLabel(String type);

  /// No description provided for @customFishHelpIntro.
  ///
  /// In en, this message translates to:
  /// **'Overview'**
  String get customFishHelpIntro;

  /// No description provided for @customFishHelpIntroBody.
  ///
  /// In en, this message translates to:
  /// **'This screen allows you to edit custom sea creature parameters. Only common properties are supported; animation and special attributes require manual JSON editing.'**
  String get customFishHelpIntroBody;

  /// No description provided for @customFishHelpProps.
  ///
  /// In en, this message translates to:
  /// **'Properties'**
  String get customFishHelpProps;

  /// No description provided for @customFishHelpPropsBody.
  ///
  /// In en, this message translates to:
  /// **'HitRect, AttackRect and ScareRect define collision areas. Speed and ScareSpeed control movement. ArtCenter defines center of the sprite.'**
  String get customFishHelpPropsBody;

  /// No description provided for @noEditableFishProps.
  ///
  /// In en, this message translates to:
  /// **'No editable properties found.'**
  String get noEditableFishProps;

  /// No description provided for @fishPropSpeed.
  ///
  /// In en, this message translates to:
  /// **'Movement Speed (Speed)'**
  String get fishPropSpeed;

  /// No description provided for @fishPropScareSpeed.
  ///
  /// In en, this message translates to:
  /// **'Speed When Scared (ScareSpeed)'**
  String get fishPropScareSpeed;

  /// No description provided for @fishPropDamage.
  ///
  /// In en, this message translates to:
  /// **'Damage'**
  String get fishPropDamage;

  /// No description provided for @fishPropHitpoints.
  ///
  /// In en, this message translates to:
  /// **'Health (Hitpoints)'**
  String get fishPropHitpoints;

  /// No description provided for @fishPropHitPoints.
  ///
  /// In en, this message translates to:
  /// **'Health (Hitpoints)'**
  String get fishPropHitPoints;

  /// No description provided for @fishPropHitRect.
  ///
  /// In en, this message translates to:
  /// **'Hitbox (HitRect)'**
  String get fishPropHitRect;

  /// No description provided for @fishPropAttackRect.
  ///
  /// In en, this message translates to:
  /// **'Attack Range (AttackRect)'**
  String get fishPropAttackRect;

  /// No description provided for @fishPropScareRect.
  ///
  /// In en, this message translates to:
  /// **'Scare area (ScareRect)'**
  String get fishPropScareRect;

  /// No description provided for @fishPropScarerect.
  ///
  /// In en, this message translates to:
  /// **'Scare area (Sacrerect)'**
  String get fishPropScarerect;

  /// No description provided for @fishPropArtCenter.
  ///
  /// In en, this message translates to:
  /// **'Sprite Center (ArtCenter)'**
  String get fishPropArtCenter;

  /// No description provided for @edit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get edit;

  /// No description provided for @eventHelpTidalChangePosition.
  ///
  /// In en, this message translates to:
  /// **'Sets the tide position after the change. The rightmost column is 0, and the leftmost is 9. Accepts integers, including negative values.'**
  String get eventHelpTidalChangePosition;

  /// No description provided for @eventHelpBlackHoleBody.
  ///
  /// In en, this message translates to:
  /// **'A event commonly seen in Kongfu World. A black hole will spawn and pull all plants to the right.'**
  String get eventHelpBlackHoleBody;

  /// No description provided for @eventHelpBlackHoleColumns.
  ///
  /// In en, this message translates to:
  /// **'You can specify how many columns plants are dragged, indicating how many tiles they will be pulled to the right by the black hole.'**
  String get eventHelpBlackHoleColumns;

  /// No description provided for @eventHelpMagicMirrorBody.
  ///
  /// In en, this message translates to:
  /// **'Spawns paired mirrors on the lawn. Each pair consists of an entrance and an exit, both sharing the same appearance.'**
  String get eventHelpMagicMirrorBody;

  /// No description provided for @eventHelpMagicMirrorType.
  ///
  /// In en, this message translates to:
  /// **'You can change the mirror’s appearance to distinguish them. There are 3 different types of Magic Mirrors in this event.'**
  String get eventHelpMagicMirrorType;

  /// No description provided for @eventHelpParachuteRainBody.
  ///
  /// In en, this message translates to:
  /// **'Zombies will parachute in from above for a surprise attack. Commonly used for Bug Bot Imp, Lost Pilot Zombie, Bass Zombie, ZCorp Helpdesk, and more. Zombie levels follow the lawn’s level sequence.'**
  String get eventHelpParachuteRainBody;

  /// No description provided for @eventHelpParachuteRainLogic.
  ///
  /// In en, this message translates to:
  /// **'Zombies drop in batches. You can control the total number and the interval between each batch. Zombies will land randomly within the selected columns. If the total pre-drop delay is reached, any remaining zombies will spawn immediately.\nA red warning message will appear before the event starts. Entering Chinese text in the message may result in garbled characters. You can leave the zombie type empty to use this event purely for message display.'**
  String get eventHelpParachuteRainLogic;

  /// No description provided for @eventHelpModernPortalsBody.
  ///
  /// In en, this message translates to:
  /// **'Spawns a fixed type of spacetime portal on the lawn, commonly seen in Modern Day and Memory Lane.\nOnly one spacetime portal can be configured per event. To have multiple portals appear simultaneously, add multiple Spacetime Portal events within the wave.'**
  String get eventHelpModernPortalsBody;

  /// No description provided for @eventHelpModernPortalsType.
  ///
  /// In en, this message translates to:
  /// **'There are many types of spacetime portals in the game. You can select a specific type and preview the spawned zombies.'**
  String get eventHelpModernPortalsType;

  /// No description provided for @eventHelpModernPortalsIgnore.
  ///
  /// In en, this message translates to:
  /// **'When enabled, spacetime portals will still spawn even if blocked by grid items such as tombstones or surfboards.'**
  String get eventHelpModernPortalsIgnore;

  /// No description provided for @eventHelpFrostWindBody.
  ///
  /// In en, this message translates to:
  /// **'A common event in Frostbite Caves. Freezing wind is generated on specified rows, freezing plants into ice blocks.'**
  String get eventHelpFrostWindBody;

  /// No description provided for @eventHelpFrostWindDirection.
  ///
  /// In en, this message translates to:
  /// **'You can set the direction of the wind (from left or right). Note that there is an interval between each wind. To make them occur simultaneously, try adding multiple Freezing Wind events.'**
  String get eventHelpFrostWindDirection;

  /// No description provided for @eventHelpModifyConveyorBody.
  ///
  /// In en, this message translates to:
  /// **'This event allows you to modify conveyor belt plants during gameplay. Parameters are similar to the conveyor belt module. Make sure the conveyor belt module is already included in the level.'**
  String get eventHelpModifyConveyorBody;

  /// No description provided for @eventHelpModifyConveyorAdd.
  ///
  /// In en, this message translates to:
  /// **'Adds new plants or tool packets to the conveyor belt. If the plant already exists, its previous data will be overwritten.'**
  String get eventHelpModifyConveyorAdd;

  /// No description provided for @eventHelpModifyConveyorRemove.
  ///
  /// In en, this message translates to:
  /// **'Removing does not work when the Creative Courtyard module is enabled. Instead, set the plant’s weight to 0 to achieve the same effect.'**
  String get eventHelpModifyConveyorRemove;

  /// No description provided for @eventHelpDinoBody.
  ///
  /// In en, this message translates to:
  /// **'A common event in Jurassic Marsh. Summons a specified dinosaur into a chosen row. The dinosaur will assist zombies in attacking.\nOnly one dinosaur can be configured per event. To have multiple dinosaurs appear simultaneously, add multiple Dino Summon events within the wave.'**
  String get eventHelpDinoBody;

  /// No description provided for @eventHelpDinoDuration.
  ///
  /// In en, this message translates to:
  /// **'The duration the dinosaur stays on the lawn, measured in waves. It will leave after the time expires or after interacting with enough zombies.'**
  String get eventHelpDinoDuration;

  /// No description provided for @eventDinoTread.
  ///
  /// In en, this message translates to:
  /// **'Event: Dino Stomp'**
  String get eventDinoTread;

  /// No description provided for @eventDinoRun.
  ///
  /// In en, this message translates to:
  /// **'Event: Dino Stampede'**
  String get eventDinoRun;

  /// No description provided for @eventHelpDinoTreadBody.
  ///
  /// In en, this message translates to:
  /// **'Brontosaurus moves its foot into the designated area and stomps after a few seconds, dealing damage to all plants and zombies within range. It leaves a footprint lasting about 7 seconds, during which planting is not allowed in that area.'**
  String get eventHelpDinoTreadBody;

  /// No description provided for @eventHelpDinoTreadRowCol.
  ///
  /// In en, this message translates to:
  /// **'GridY is the stomp center row; GridXMin and GridXMax bound the possible center columns (all 0-based). Each stomp covers a 3×3 area around its center. The preview highlights every cell that can be stomped across those positions. Underwater World: rows 0–5, columns 0–9.'**
  String get eventHelpDinoTreadRowCol;

  /// No description provided for @dinoTreadPreview.
  ///
  /// In en, this message translates to:
  /// **'Possible stomp area preview'**
  String get dinoTreadPreview;

  /// No description provided for @dinoTreadRowLabel.
  ///
  /// In en, this message translates to:
  /// **'Row (GridY)'**
  String get dinoTreadRowLabel;

  /// No description provided for @dinoTreadColMinLabel.
  ///
  /// In en, this message translates to:
  /// **'Leftmost Column (GridXMin)'**
  String get dinoTreadColMinLabel;

  /// No description provided for @dinoTreadColMaxLabel.
  ///
  /// In en, this message translates to:
  /// **'Rightmost Column (GridXMax)'**
  String get dinoTreadColMaxLabel;

  /// No description provided for @dinoTreadTimeIntervalLabel.
  ///
  /// In en, this message translates to:
  /// **'Entry delay (TimeInterval; seconds)'**
  String get dinoTreadTimeIntervalLabel;

  /// No description provided for @columnStartLabel.
  ///
  /// In en, this message translates to:
  /// **'Start Column (ColumnStart)'**
  String get columnStartLabel;

  /// No description provided for @columnEndLabel.
  ///
  /// In en, this message translates to:
  /// **'End Column (ColumnEnd)'**
  String get columnEndLabel;

  /// No description provided for @eventHelpDinoRunBody.
  ///
  /// In en, this message translates to:
  /// **'When triggered, dinosaurs gather across 2–3 rows. They do not use their abilities, but instead charge into the lawn, trampling plants or zombies. The number of targets they can trample depends on the dinosaur type.'**
  String get eventHelpDinoRunBody;

  /// No description provided for @eventHelpDinoRunRow.
  ///
  /// In en, this message translates to:
  /// **'DinoRow defines the center row of the dino rush (red in the preview). Stampede dinosaurs may also spawn on the rows directly above and below (yellow). Rows are 0-based. Underwater World supports up to 5.'**
  String get eventHelpDinoRunRow;

  /// No description provided for @dinoRunPreview.
  ///
  /// In en, this message translates to:
  /// **'Stampede preview'**
  String get dinoRunPreview;

  /// No description provided for @positionAndArea.
  ///
  /// In en, this message translates to:
  /// **'Position & area'**
  String get positionAndArea;

  /// No description provided for @positionAndDuration.
  ///
  /// In en, this message translates to:
  /// **'Position & timing'**
  String get positionAndDuration;

  /// No description provided for @rowCol0Index.
  ///
  /// In en, this message translates to:
  /// **'Row/column (0-based)'**
  String get rowCol0Index;

  /// No description provided for @timeInterval.
  ///
  /// In en, this message translates to:
  /// **'Time interval'**
  String get timeInterval;

  /// No description provided for @eventHelpZombiePotionBody.
  ///
  /// In en, this message translates to:
  /// **'Force-spawns potions on the lawn, ignoring plants. Can be used as an alternative to grid item spawn events.'**
  String get eventHelpZombiePotionBody;

  /// No description provided for @eventHelpZombiePotionUsage.
  ///
  /// In en, this message translates to:
  /// **'Unlike the preset pools used for grid item spawning, this event forces grid items to spawn on specific tiles and displaces plants. \nNote that on lawns without tombstone spawn effects, sun textures may appear incorrectly. Use with caution.'**
  String get eventHelpZombiePotionUsage;

  /// No description provided for @eventHelpShellBody.
  ///
  /// In en, this message translates to:
  /// **'Spawns atlantis seashells at specified positions. Seashells start in a closed state. When a zombie steps on a seashell, it opens, launches the zombie forward, and closes again after 10 seconds. While open, seashells can be attacked by plants and block straight-shot projectiles. Each time a seashell opens, it generates a random item, including a Plant Food, a Cuttlefish, a plant seed packet, or a Relic Imp. After being triggered by zombies 3 times, the seashell will swim toward the seed bank and replace a random seed slot with a seashell seed packet. After the seashell has been planted 3 times, the seed slot will revert to its original plant.'**
  String get eventHelpShellBody;

  /// No description provided for @eventHelpShellUsage.
  ///
  /// In en, this message translates to:
  /// **'Select a tile, then tap \"+\" to place a seashell. Lawn size varies by level: 6 rows × 10 columns in Underwater World, and 5 rows × 9 columns in other levels.'**
  String get eventHelpShellUsage;

  /// No description provided for @eventHelpPumpkinHouseBody.
  ///
  /// In en, this message translates to:
  /// **'Spawns pumpkin houses at specified positions. Zombies that pass through the Pumpkin House are transformed into Pumpkin House Ghosts. Pumpkin House Ghosts have a separate health pool and can only be damaged by lobbed plants. When their health is depleted, they revert to their original zombie form. The Pumpkin House itself also has its own health and can be destroyed by concentrated fire.'**
  String get eventHelpPumpkinHouseBody;

  /// No description provided for @eventHelpPumpkinHouseUsage.
  ///
  /// In en, this message translates to:
  /// **'Select a tile, then tap \"+\" to place a pumpkin house. Lawn size varies by level: 6 rows × 10 columns in Underwater World, and 5 rows × 9 columns in other levels.'**
  String get eventHelpPumpkinHouseUsage;

  /// No description provided for @eventHelpZombieTentBody.
  ///
  /// In en, this message translates to:
  /// **'This event force spawns zombie tents from Memory Lane directly on the lawn. Unlike the tents carried by Imp Porters, these tents do not require Gold Tiles. They appear at the specified positions and continually summon zombies until destroyed. The level can only be won after every zombie tent on the lawn has been destroyed.'**
  String get eventHelpZombieTentBody;

  /// No description provided for @eventHelpZombieTentUsage.
  ///
  /// In en, this message translates to:
  /// **'Select a grid cell and tap \"+\" to place a tent. You can then configure each tent’s type, hitpoints, zombie spawn weights, and spawn interval individually.'**
  String get eventHelpZombieTentUsage;

  /// No description provided for @eventHelpZombieTentFieldsTitle.
  ///
  /// In en, this message translates to:
  /// **'Parameter Description'**
  String get eventHelpZombieTentFieldsTitle;

  /// No description provided for @eventHelpZombieTentFields.
  ///
  /// In en, this message translates to:
  /// **'Regular tents and New Year tents function identically; only their appearance differs.\nA higher weight gives a zombie a greater chance of being selected. For example, weights of 10 and 30 give the two zombies an approximately 1:3 chance ratio.\nZombie level 0 uses the lawn’s default level, which is level 1 in Creative Courtyard.\nWhen editing the JSON manually, note that tent columns (Column) and rows (Row) are numbered from 1. For example, \"Column\": 7 means the seventh column.'**
  String get eventHelpZombieTentFields;

  /// No description provided for @eventZombieTentSpawn.
  ///
  /// In en, this message translates to:
  /// **'Event: Zombie Tent Spawn'**
  String get eventZombieTentSpawn;

  /// No description provided for @zombieTentSectionTitle.
  ///
  /// In en, this message translates to:
  /// **'Tents at selected tile'**
  String get zombieTentSectionTitle;

  /// No description provided for @zombieTentTypeLabel.
  ///
  /// In en, this message translates to:
  /// **'Tent type (TentType)'**
  String get zombieTentTypeLabel;

  /// No description provided for @zombieTentTypeNormal.
  ///
  /// In en, this message translates to:
  /// **'Regular tent'**
  String get zombieTentTypeNormal;

  /// No description provided for @zombieTentTypeFestival.
  ///
  /// In en, this message translates to:
  /// **'New Year tent'**
  String get zombieTentTypeFestival;

  /// No description provided for @zombieTentHitpoints.
  ///
  /// In en, this message translates to:
  /// **'Tent hitpoints (Hitpoints)'**
  String get zombieTentHitpoints;

  /// No description provided for @zombieTentProductionInterval.
  ///
  /// In en, this message translates to:
  /// **'Production interval (ProductionInterval, seconds)'**
  String get zombieTentProductionInterval;

  /// No description provided for @zombieTentZombiesSection.
  ///
  /// In en, this message translates to:
  /// **'Possible zombie spawns (ZombieTypesToSpawn)'**
  String get zombieTentZombiesSection;

  /// No description provided for @zombieTentWeight.
  ///
  /// In en, this message translates to:
  /// **'Spawn weight (Weight)'**
  String get zombieTentWeight;

  /// No description provided for @zombieTentAddZombie.
  ///
  /// In en, this message translates to:
  /// **'Add zombie'**
  String get zombieTentAddZombie;

  /// No description provided for @zombieTentAddTent.
  ///
  /// In en, this message translates to:
  /// **'Add tent'**
  String get zombieTentAddTent;

  /// No description provided for @zombieTentDeleteTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete tent'**
  String get zombieTentDeleteTitle;

  /// No description provided for @zombieTentDeleteConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this tent?'**
  String get zombieTentDeleteConfirm;

  /// No description provided for @eventHelpFairyFogBody.
  ///
  /// In en, this message translates to:
  /// **'Creates magic fog that covers the lawn and grants shields to zombies. Commonly used in Fairy Forest levels. Can only be cleared by the Fairtyale Breeze event.\nHigher-tier fog grants stronger shields and increased control immunity to zombies. Tiers, from lowest to highest, are White, Blue, and Purple.'**
  String get eventHelpFairyFogBody;

  /// No description provided for @eventHelpFairyFogRange.
  ///
  /// In en, this message translates to:
  /// **'mX and mY define the center point. mWidth and mHeight define how far the area extends to the right and downward from the center.'**
  String get eventHelpFairyFogRange;

  /// No description provided for @eventHelpFairyWindBody.
  ///
  /// In en, this message translates to:
  /// **'Generates a continuous breeze that clears magical fog. Commonly used in Fairy Forest levels.'**
  String get eventHelpFairyWindBody;

  /// No description provided for @eventHelpFairyWindVelocity.
  ///
  /// In en, this message translates to:
  /// **'This event affects projectile speed while active. 1.0 = normal speed; higher values increase projectile speed.'**
  String get eventHelpFairyWindVelocity;

  /// No description provided for @eventHelpRaidingPartyBody.
  ///
  /// In en, this message translates to:
  /// **'Commonly seen in Pirate Seas levels. Spawns groups of Swashbuckler Zombies in batches. TimeBetweenGroups defines the interval between each group.'**
  String get eventHelpRaidingPartyBody;

  /// No description provided for @eventHelpRaidingPartyGroup.
  ///
  /// In en, this message translates to:
  /// **'Zombies per group.'**
  String get eventHelpRaidingPartyGroup;

  /// No description provided for @eventHelpRaidingPartyCount.
  ///
  /// In en, this message translates to:
  /// **'Total Swashbuckler Zombies spawned.'**
  String get eventHelpRaidingPartyCount;

  /// No description provided for @eventHelpGravestoneBody.
  ///
  /// In en, this message translates to:
  /// **'Randomly spawns grid items during a wave (e.g., Dark Ages tombstones).'**
  String get eventHelpGravestoneBody;

  /// No description provided for @eventHelpGravestoneLogic.
  ///
  /// In en, this message translates to:
  /// **'Selects valid tiles from the pool above to spawn grid items. The total number of grid items cannot exceed the number of available tiles, or excess spawns will fail.'**
  String get eventHelpGravestoneLogic;

  /// No description provided for @eventHelpGravestoneMissingAssets.
  ///
  /// In en, this message translates to:
  /// **'Some lawns without tombstone spawn effects may show sun textures instead. Use with caution.'**
  String get eventHelpGravestoneMissingAssets;

  /// No description provided for @eventHelpBarrelWaveBody.
  ///
  /// In en, this message translates to:
  /// **'Spawns the three barrel types from the Memory Lane \"Barrel Crisis\" gimmick. Barrels roll in from the right and crush all plants in their path.'**
  String get eventHelpBarrelWaveBody;

  /// No description provided for @barrelWaveHelpTypes.
  ///
  /// In en, this message translates to:
  /// **'Barrel types'**
  String get barrelWaveHelpTypes;

  /// No description provided for @eventHelpBarrelWaveTypes.
  ///
  /// In en, this message translates to:
  /// **'Empty Barrel: Breaks with no effect.\nImp Barrel: Releases zombies (usually Imps) when destroyed.\nExplosive Barrel: Explodes on contact or when destroyed, damaging plants and zombies in a 3×3 area.'**
  String get eventHelpBarrelWaveTypes;

  /// No description provided for @barrelWaveHelpRows.
  ///
  /// In en, this message translates to:
  /// **'Row'**
  String get barrelWaveHelpRows;

  /// No description provided for @eventHelpBarrelWaveRows.
  ///
  /// In en, this message translates to:
  /// **'Rows are 1-based: Row 1 = top lane, Row 5/6 = bottom lane. Standard lawns: 5 rows. Underwater World lawns: 6 rows.'**
  String get eventHelpBarrelWaveRows;

  /// No description provided for @eventHelpSchoolBusBody.
  ///
  /// In en, this message translates to:
  /// **'Spawns an Ice Cream Van in the specified lane. Ice Cream Van slowly enters from the right side while carrying zombies, occupying 2 lanes. Any plants run over by the van are instantly crushed.\nIf the van is displayed with Bubble Gun Imps and Lollipop Zombies (i.e. the schoolbus_special variant) and at least one plant is present on the lawn, they will continuously use their respective abilities while the van is moving.\nPlants like Spikeweed and Spikerock can puncture the van\'s tires. After its tires are punctured, the Ice Cream Van gradually slows down and enters a gliding state. After a short period of time, it comes to a stop and breaks down.'**
  String get eventHelpSchoolBusBody;

  /// No description provided for @schoolBusHelpRows.
  ///
  /// In en, this message translates to:
  /// **'Row'**
  String get schoolBusHelpRows;

  /// No description provided for @eventHelpSchoolBusRows.
  ///
  /// In en, this message translates to:
  /// **'Rows are 1-based: Row 1 = top lane, Row 5/6 = bottom lane. Standard lawns: 5 rows. Underwater World lawns: 6 rows.'**
  String get eventHelpSchoolBusRows;

  /// No description provided for @eventHelpSchoolBusType.
  ///
  /// In en, this message translates to:
  /// **'Type selects the ice cream van variant. Normal (schoolbus_normal) is the standard van. Special (schoolbus_special) shows Bubble Gun Imps and Lollipop Zombies on the van; while at least one plant is present on the lawn, they use their abilities as the van moves.'**
  String get eventHelpSchoolBusType;

  /// No description provided for @schoolBusHelpZombies.
  ///
  /// In en, this message translates to:
  /// **'Zombies'**
  String get schoolBusHelpZombies;

  /// No description provided for @eventHelpSchoolBusZombies.
  ///
  /// In en, this message translates to:
  /// **'Ice Cream Van has its own health pool. Once destroyed, the zombies inside will exit the vehicle and continue advancing. Each zombie\'s level can be configured individually (Level 0 follows the lawn’s default level, which is Level 1 in Creative Courtyard).'**
  String get eventHelpSchoolBusZombies;

  /// No description provided for @schoolBusRow.
  ///
  /// In en, this message translates to:
  /// **'Row'**
  String get schoolBusRow;

  /// No description provided for @schoolBusType.
  ///
  /// In en, this message translates to:
  /// **'Type'**
  String get schoolBusType;

  /// No description provided for @schoolBusTypeNormal.
  ///
  /// In en, this message translates to:
  /// **'Normal'**
  String get schoolBusTypeNormal;

  /// No description provided for @schoolBusTypeSpecial.
  ///
  /// In en, this message translates to:
  /// **'Special'**
  String get schoolBusTypeSpecial;

  /// No description provided for @schoolBusHitPoints.
  ///
  /// In en, this message translates to:
  /// **' Van health (SchoolBusHitPoints)'**
  String get schoolBusHitPoints;

  /// No description provided for @schoolBusSpeed.
  ///
  /// In en, this message translates to:
  /// **'Van speed (SchoolBusSpeed)'**
  String get schoolBusSpeed;

  /// No description provided for @schoolBusZombies.
  ///
  /// In en, this message translates to:
  /// **'Contained zombies (Zombies)'**
  String get schoolBusZombies;

  /// No description provided for @schoolBusZombieLevel.
  ///
  /// In en, this message translates to:
  /// **'Zombie level (Level)'**
  String get schoolBusZombieLevel;

  /// No description provided for @schoolBusAddZombie.
  ///
  /// In en, this message translates to:
  /// **'Add zombie'**
  String get schoolBusAddZombie;

  /// No description provided for @eventHelpThunderWaveBody.
  ///
  /// In en, this message translates to:
  /// **'Lightning strikes during the wave, hitting plants adjacent to other plants. Commonly used in Sky City levels. Each strike applies either a positive or negative charge to plants.'**
  String get eventHelpThunderWaveBody;

  /// No description provided for @thunderWaveHelpTypes.
  ///
  /// In en, this message translates to:
  /// **'Charge effects'**
  String get thunderWaveHelpTypes;

  /// No description provided for @eventHelpThunderWaveTypes.
  ///
  /// In en, this message translates to:
  /// **'Two positive charges cause continuous percentage damage from an overhead energy orb.\nTwo negative charges paralyze the plant for a short duration.\nOne positive and one negative charge permanently slow the plant.\nPlants can still receive charges while affected, but no additional effects will be applied.'**
  String get eventHelpThunderWaveTypes;

  /// No description provided for @thunderWaveHelpKillRate.
  ///
  /// In en, this message translates to:
  /// **'Kill rate'**
  String get thunderWaveHelpKillRate;

  /// No description provided for @eventHelpThunderWaveKillRate.
  ///
  /// In en, this message translates to:
  /// **'The chance for lightning to instantly kill a plant on hit (0.0–1.0). Anthurium is unaffected. This applies to both positive and negative lightning.'**
  String get eventHelpThunderWaveKillRate;

  /// No description provided for @thunderWaveTypePositive.
  ///
  /// In en, this message translates to:
  /// **'Positive'**
  String get thunderWaveTypePositive;

  /// No description provided for @thunderWaveTypeNegative.
  ///
  /// In en, this message translates to:
  /// **'Negative'**
  String get thunderWaveTypeNegative;

  /// No description provided for @thunderWaveKillRate.
  ///
  /// In en, this message translates to:
  /// **'Kill rate'**
  String get thunderWaveKillRate;

  /// No description provided for @thunderWaveKillRateHint.
  ///
  /// In en, this message translates to:
  /// **'Probability of killing plants on lightning strike (0.0–1.0), Anthurium is unaffected'**
  String get thunderWaveKillRateHint;

  /// No description provided for @thunderWaveThunders.
  ///
  /// In en, this message translates to:
  /// **'Lightnings'**
  String get thunderWaveThunders;

  /// No description provided for @thunderWaveAddThunder.
  ///
  /// In en, this message translates to:
  /// **'Add lightning'**
  String get thunderWaveAddThunder;

  /// No description provided for @thunderWaveThunder.
  ///
  /// In en, this message translates to:
  /// **'Lightning'**
  String get thunderWaveThunder;

  /// No description provided for @barrelWaveTypeEmpty.
  ///
  /// In en, this message translates to:
  /// **'Empty Barrel (barrelempty)'**
  String get barrelWaveTypeEmpty;

  /// No description provided for @barrelWaveTypeZombie.
  ///
  /// In en, this message translates to:
  /// **'Imp Barrel (barrelmoster)'**
  String get barrelWaveTypeZombie;

  /// No description provided for @barrelWaveTypeExplosive.
  ///
  /// In en, this message translates to:
  /// **'Explosive Barrel (barrelpowder)'**
  String get barrelWaveTypeExplosive;

  /// No description provided for @barrelWaveRowsHint.
  ///
  /// In en, this message translates to:
  /// **'Rows are 1-based: Row 1 = top lane, Row 5/6 = bottom lane.'**
  String get barrelWaveRowsHint;

  /// No description provided for @barrelWaveAddBarrel.
  ///
  /// In en, this message translates to:
  /// **'Add barrel'**
  String get barrelWaveAddBarrel;

  /// No description provided for @barrelWaveBarrel.
  ///
  /// In en, this message translates to:
  /// **'Barrel'**
  String get barrelWaveBarrel;

  /// No description provided for @barrelWaveRow.
  ///
  /// In en, this message translates to:
  /// **'Row'**
  String get barrelWaveRow;

  /// No description provided for @barrelWaveType.
  ///
  /// In en, this message translates to:
  /// **'Type'**
  String get barrelWaveType;

  /// No description provided for @barrelWaveHitPoints.
  ///
  /// In en, this message translates to:
  /// **'Barrel health (BarrelHitPoints)'**
  String get barrelWaveHitPoints;

  /// No description provided for @barrelWaveSpeed.
  ///
  /// In en, this message translates to:
  /// **'Barrel speed (BarrelSpeed)'**
  String get barrelWaveSpeed;

  /// No description provided for @barrelWaveZombies.
  ///
  /// In en, this message translates to:
  /// **'Contained zombies (Zombies)'**
  String get barrelWaveZombies;

  /// No description provided for @barrelWaveZombieLevel.
  ///
  /// In en, this message translates to:
  /// **'Zombie level (Level)'**
  String get barrelWaveZombieLevel;

  /// No description provided for @barrelWaveAddZombie.
  ///
  /// In en, this message translates to:
  /// **'Add zombie'**
  String get barrelWaveAddZombie;

  /// No description provided for @barrelWaveExplosionDamage.
  ///
  /// In en, this message translates to:
  /// **'Explosion damage (BarrelBlowDamageAmount)'**
  String get barrelWaveExplosionDamage;

  /// No description provided for @barrelWaveDeleteTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete barrel'**
  String get barrelWaveDeleteTitle;

  /// No description provided for @barrelWaveDeleteConfirm.
  ///
  /// In en, this message translates to:
  /// **'Delete this barrel?'**
  String get barrelWaveDeleteConfirm;

  /// No description provided for @barrelWaveDeleteLastHint.
  ///
  /// In en, this message translates to:
  /// **'This is the last barrel. Deleting it will leave this event without any barrels. Continue?'**
  String get barrelWaveDeleteLastHint;

  /// No description provided for @moduleHelpDeathHoleBody.
  ///
  /// In en, this message translates to:
  /// **'When a plant is shoveled, eaten, or otherwise removed, it leaves an unplantable crater on the tile it occupied for a period of time.'**
  String get moduleHelpDeathHoleBody;

  /// No description provided for @moduleHelpZombieMoveFastBody.
  ///
  /// In en, this message translates to:
  /// **'Makes zombies move quickly as they enter the lawn, returning to normal speed after they reach the specified column. Commonly used in the Zombie Elimination Initiative levels.'**
  String get moduleHelpZombieMoveFastBody;

  /// No description provided for @moduleHelpSeedRainBody.
  ///
  /// In en, this message translates to:
  /// **'At fixed intervals, this module causes item cards to fall from the sky.'**
  String get moduleHelpSeedRainBody;

  /// No description provided for @moduleHelpSeedRainParameters.
  ///
  /// In en, this message translates to:
  /// **'Parameter settings'**
  String get moduleHelpSeedRainParameters;

  /// No description provided for @moduleHelpSeedRainParametersBody.
  ///
  /// In en, this message translates to:
  /// **'Weight determines an item\'s chance of dropping, while Max count limits how many copies may be present on the lawn at once. Note that most zombies do not have matching zombie card icons.'**
  String get moduleHelpSeedRainParametersBody;

  /// No description provided for @moduleHelpSeedRainPlantLevels.
  ///
  /// In en, this message translates to:
  /// **'Plant levels'**
  String get moduleHelpSeedRainPlantLevels;

  /// No description provided for @seedRainAddContentTitle.
  ///
  /// In en, this message translates to:
  /// **'Add rain content'**
  String get seedRainAddContentTitle;

  /// No description provided for @moduleHelpRailcartBody.
  ///
  /// In en, this message translates to:
  /// **'Configure the positions of minecarts and rails and select the minecart style. Tap a tile once to place an item, and tap it again to remove it.'**
  String get moduleHelpRailcartBody;

  /// No description provided for @moduleHelpRailcartRailsBody.
  ///
  /// In en, this message translates to:
  /// **'In Lay rails mode, tap tiles to lay rails. The editor automatically combines consecutive tiles in the same column into a single rail segment.'**
  String get moduleHelpRailcartRailsBody;

  /// No description provided for @moduleHelpRailcartCartsBody.
  ///
  /// In en, this message translates to:
  /// **'Tap tiles to place or remove minecarts. Note that minecarts on the same rail segment can easily stack.'**
  String get moduleHelpRailcartCartsBody;

  /// No description provided for @moduleHelpTideBody.
  ///
  /// In en, this message translates to:
  /// **'Enables the tide system for the level, allowing tide-related events to be used. Note that this module must be added last; otherwise, it may cause the level to crash.'**
  String get moduleHelpTideBody;

  /// No description provided for @moduleHelpTidePosition.
  ///
  /// In en, this message translates to:
  /// **'Sets the position of the tide at the start of the level, i.e., the position of the tide line within the level. The rightmost column is 0 and the leftmost is 9. Accepts integers, including negative values.'**
  String get moduleHelpTidePosition;

  /// No description provided for @initialTidePosition.
  ///
  /// In en, this message translates to:
  /// **'Tide line configuration'**
  String get initialTidePosition;

  /// No description provided for @moduleHelpWeatherBody.
  ///
  /// In en, this message translates to:
  /// **'Controls global environmental effects such as rain and snow.'**
  String get moduleHelpWeatherBody;

  /// No description provided for @moduleHelpWeatherRef.
  ///
  /// In en, this message translates to:
  /// **'These modules are typically referenced directly from LevelModules and do not require custom configuration.'**
  String get moduleHelpWeatherRef;

  /// No description provided for @moduleHelpZombiePotionBody.
  ///
  /// In en, this message translates to:
  /// **'This module periodically spawns specified grid item types in random rows, moving from right to left.'**
  String get moduleHelpZombiePotionBody;

  /// No description provided for @moduleHelpZombiePotionMechanism.
  ///
  /// In en, this message translates to:
  /// **'Spawn Mechanism'**
  String get moduleHelpZombiePotionMechanism;

  /// No description provided for @moduleHelpZombiePotionMechanismBody.
  ///
  /// In en, this message translates to:
  /// **'Grid items spawn randomly within the configured time interval. If the number of matching grid items on the lawn reaches the limit, spawning pauses.'**
  String get moduleHelpZombiePotionMechanismBody;

  /// No description provided for @moduleHelpZombiePotionPotionTypes.
  ///
  /// In en, this message translates to:
  /// **'Potion Types'**
  String get moduleHelpZombiePotionPotionTypes;

  /// No description provided for @moduleHelpZombiePotionTypes.
  ///
  /// In en, this message translates to:
  /// **'One type is randomly selected from the configured list. To spawn multiple grid items at fixed intervals, add this module multiple times in the level.'**
  String get moduleHelpZombiePotionTypes;

  /// No description provided for @moduleHelpUnknownBody.
  ///
  /// In en, this message translates to:
  /// **'A level file consists of a root node and multiple modules, known as PVZ2Object. Each object has aliases, a type (objclass), and data (objdata). The root node has no aliases.'**
  String get moduleHelpUnknownBody;

  /// No description provided for @moduleHelpUnknownEvents.
  ///
  /// In en, this message translates to:
  /// **'This software determines module types by reading objclass. The objclass of the current module is not registered in the module list, so no matching editor is available. Support may be added in a future update.'**
  String get moduleHelpUnknownEvents;

  /// No description provided for @eventHelpInvalidBody.
  ///
  /// In en, this message translates to:
  /// **'This event is referenced in the wave container, but the parser cannot find its entity definition in the level, leaving the RTID block unresolved.'**
  String get eventHelpInvalidBody;

  /// No description provided for @eventHelpInvalidImpact.
  ///
  /// In en, this message translates to:
  /// **'Keeping this invalid entry in the level will prevent it from being read correctly and may cause a crash. It should be removed manually.'**
  String get eventHelpInvalidImpact;

  /// No description provided for @position.
  ///
  /// In en, this message translates to:
  /// **'Selected position'**
  String get position;

  /// No description provided for @editing.
  ///
  /// In en, this message translates to:
  /// **'Editing'**
  String get editing;

  /// No description provided for @logic.
  ///
  /// In en, this message translates to:
  /// **'Logic'**
  String get logic;

  /// No description provided for @impact.
  ///
  /// In en, this message translates to:
  /// **'Impact'**
  String get impact;

  /// No description provided for @events.
  ///
  /// In en, this message translates to:
  /// **'Events'**
  String get events;

  /// No description provided for @referenceModules.
  ///
  /// In en, this message translates to:
  /// **'Reference modules'**
  String get referenceModules;

  /// No description provided for @portalType.
  ///
  /// In en, this message translates to:
  /// **'Portal type (PortalType)'**
  String get portalType;

  /// No description provided for @selectPortalType.
  ///
  /// In en, this message translates to:
  /// **'Select Portal Type'**
  String get selectPortalType;

  /// No description provided for @noPortalTypesFound.
  ///
  /// In en, this message translates to:
  /// **'No portal types found.'**
  String get noPortalTypesFound;

  /// No description provided for @noPortalTypeSelected.
  ///
  /// In en, this message translates to:
  /// **'No portal type selected.'**
  String get noPortalTypeSelected;

  /// No description provided for @direction.
  ///
  /// In en, this message translates to:
  /// **'Direction'**
  String get direction;

  /// No description provided for @windDirectionLabel.
  ///
  /// In en, this message translates to:
  /// **'Direction'**
  String get windDirectionLabel;

  /// No description provided for @velocityScale.
  ///
  /// In en, this message translates to:
  /// **'Speed multiplier (VelocityScale)'**
  String get velocityScale;

  /// No description provided for @range.
  ///
  /// In en, this message translates to:
  /// **'Range'**
  String get range;

  /// No description provided for @columnRange.
  ///
  /// In en, this message translates to:
  /// **'Column range'**
  String get columnRange;

  /// No description provided for @eventColumnRangeBoundaryHint.
  ///
  /// In en, this message translates to:
  /// **'The lawn’s left edge is column 0 and the right edge is column 9. The start column must be less than the end column.'**
  String get eventColumnRangeBoundaryHint;

  /// No description provided for @eventColumnRangeExampleHint.
  ///
  /// In en, this message translates to:
  /// **'To spawn from columns X through Y, enter X - 1 for the start column and Y for the end column.'**
  String get eventColumnRangeExampleHint;

  /// No description provided for @zombieLevels.
  ///
  /// In en, this message translates to:
  /// **'Zombie level'**
  String get zombieLevels;

  /// No description provided for @missingAssets.
  ///
  /// In en, this message translates to:
  /// **'Missing assets'**
  String get missingAssets;

  /// No description provided for @usage.
  ///
  /// In en, this message translates to:
  /// **'Usage'**
  String get usage;

  /// No description provided for @types.
  ///
  /// In en, this message translates to:
  /// **'Types'**
  String get types;

  /// No description provided for @eventBlackHole.
  ///
  /// In en, this message translates to:
  /// **'Event: Black Hole'**
  String get eventBlackHole;

  /// No description provided for @attractionConfig.
  ///
  /// In en, this message translates to:
  /// **'Attraction config'**
  String get attractionConfig;

  /// No description provided for @plantList.
  ///
  /// In en, this message translates to:
  /// **'Plant(s) in selected tile'**
  String get plantList;

  /// No description provided for @firstCostume.
  ///
  /// In en, this message translates to:
  /// **'Wears primary costume (Avatar)'**
  String get firstCostume;

  /// No description provided for @costumeOn.
  ///
  /// In en, this message translates to:
  /// **'Costume: on'**
  String get costumeOn;

  /// No description provided for @costumeOff.
  ///
  /// In en, this message translates to:
  /// **'Costume: off'**
  String get costumeOff;

  /// No description provided for @outsideLawnItems.
  ///
  /// In en, this message translates to:
  /// **'Item(s) outside the lawn'**
  String get outsideLawnItems;

  /// No description provided for @zombieFromLeft.
  ///
  /// In en, this message translates to:
  /// **'From left'**
  String get zombieFromLeft;

  /// No description provided for @eventMagicMirror.
  ///
  /// In en, this message translates to:
  /// **'Event: Magic Mirror'**
  String get eventMagicMirror;

  /// No description provided for @eventParachuteRain.
  ///
  /// In en, this message translates to:
  /// **'Event: Parachute/Bass/Jetpack/Imp rain'**
  String get eventParachuteRain;

  /// No description provided for @selectZombie.
  ///
  /// In en, this message translates to:
  /// **'Select zombie'**
  String get selectZombie;

  /// No description provided for @manholePipeline.
  ///
  /// In en, this message translates to:
  /// **'Manhole Pipeline module'**
  String get manholePipeline;

  /// No description provided for @manholePipelineHelpTitle.
  ///
  /// In en, this message translates to:
  /// **'Manhole Pipeline'**
  String get manholePipelineHelpTitle;

  /// No description provided for @manholePipelineHelpOverview.
  ///
  /// In en, this message translates to:
  /// **'Defines an underground pipe system. Commonly used in Steam Ages levels. Pipes connect two sewers, allowing zombies to travel between them.'**
  String get manholePipelineHelpOverview;

  /// No description provided for @manholePipelineHelpEditing.
  ///
  /// In en, this message translates to:
  /// **'Select a pipe group from the list above. The grid below shows the layout. Use \"Set Start\" or \"Set End\", then tap a tile to place it.'**
  String get manholePipelineHelpEditing;

  /// No description provided for @smokePollutionModuleHelpTitle.
  ///
  /// In en, this message translates to:
  /// **'Steam Manhole module'**
  String get smokePollutionModuleHelpTitle;

  /// No description provided for @smokePollutionModuleHelpOverview.
  ///
  /// In en, this message translates to:
  /// **'Overview'**
  String get smokePollutionModuleHelpOverview;

  /// No description provided for @smokePollutionModuleHelpOverviewBody.
  ///
  /// In en, this message translates to:
  /// **'Pre-place covered sewer manholes on the lawn, commonly used in Steam Ages levels. After the specified time, toxic steam blasts the covers off and spreads across a 3×3 area centered on each manhole. Plants caught in the steam take 30 damage per second.'**
  String get smokePollutionModuleHelpOverviewBody;

  /// No description provided for @smokePollutionModuleHelpManholes.
  ///
  /// In en, this message translates to:
  /// **'Usage'**
  String get smokePollutionModuleHelpManholes;

  /// No description provided for @smokePollutionModuleHelpManholesBody.
  ///
  /// In en, this message translates to:
  /// **'Select a tile, then tap \"+\" to place a sewer manhole. Each manhole can have its eruption time (StartTime) configured independently, determining how long after the level begins its cover is blasted off and toxic steam is released.'**
  String get smokePollutionModuleHelpManholesBody;

  /// No description provided for @smokePollutionModuleStartTimeLabel.
  ///
  /// In en, this message translates to:
  /// **'Eruption time (seconds)'**
  String get smokePollutionModuleStartTimeLabel;

  /// No description provided for @manholePipelineStartEndFormat.
  ///
  /// In en, this message translates to:
  /// **'Start: ({sx}, {sy})  End: ({ex}, {ey})'**
  String manholePipelineStartEndFormat(int sx, int sy, int ex, int ey);

  /// No description provided for @piratePlank.
  ///
  /// In en, this message translates to:
  /// **'Pirate Plank module'**
  String get piratePlank;

  /// No description provided for @weatherModule.
  ///
  /// In en, this message translates to:
  /// **'Environmental Weather module'**
  String get weatherModule;

  /// No description provided for @zombiePotion.
  ///
  /// In en, this message translates to:
  /// **'Dark Alchemy module'**
  String get zombiePotion;

  /// No description provided for @zombiePotionHelpTitle.
  ///
  /// In en, this message translates to:
  /// **'Zombie Potion module'**
  String get zombiePotionHelpTitle;

  /// No description provided for @eventTimeRift.
  ///
  /// In en, this message translates to:
  /// **'Event: Spacetime Portal'**
  String get eventTimeRift;

  /// No description provided for @seedRain.
  ///
  /// In en, this message translates to:
  /// **'It\'s Raining Seeds module'**
  String get seedRain;

  /// No description provided for @eventFrostWind.
  ///
  /// In en, this message translates to:
  /// **'Event: Freezing Wind'**
  String get eventFrostWind;

  /// No description provided for @lastStandInitialResourceSettings.
  ///
  /// In en, this message translates to:
  /// **'Initial Resource Settings'**
  String get lastStandInitialResourceSettings;

  /// No description provided for @lastStandManualStartupHint.
  ///
  /// In en, this message translates to:
  /// **'After adding the Last Stand module, the editor automatically enables Manual Startup in the Wave Manager module.'**
  String get lastStandManualStartupHint;

  /// No description provided for @lastStandHelpTitle.
  ///
  /// In en, this message translates to:
  /// **'Last Stand module'**
  String get lastStandHelpTitle;

  /// No description provided for @lastStandHelpOverviewBody.
  ///
  /// In en, this message translates to:
  /// **'When this module is enabled, the level starts in a setup phase instead of immediately spawning zombies. Players can spend the starting sun to place plants, and waves begin only after they tap \"LET\'S ROCK!\".'**
  String get lastStandHelpOverviewBody;

  /// No description provided for @lastStandHelpNotes.
  ///
  /// In en, this message translates to:
  /// **'Notes'**
  String get lastStandHelpNotes;

  /// No description provided for @lastStandHelpNotesBody.
  ///
  /// In en, this message translates to:
  /// **'Last Stand requires Manual Startup to be enabled in the Wave Manager; otherwise zombies will appear automatically. The editor manages this switch automatically when the Last Stand module is added or removed.'**
  String get lastStandHelpNotesBody;

  /// No description provided for @moduleDependencyRequiredMessage.
  ///
  /// In en, this message translates to:
  /// **'To select this module, add the \"{moduleName}\" module first.'**
  String moduleDependencyRequiredMessage(String moduleName);

  /// No description provided for @cowboyMinigameSettings.
  ///
  /// In en, this message translates to:
  /// **'Not OK Corral settings'**
  String get cowboyMinigameSettings;

  /// No description provided for @cowboyMinigameBeginString.
  ///
  /// In en, this message translates to:
  /// **'Prompt text'**
  String get cowboyMinigameBeginString;

  /// No description provided for @cowboyMinigameBeginStringDefault.
  ///
  /// In en, this message translates to:
  /// **'Default text'**
  String get cowboyMinigameBeginStringDefault;

  /// No description provided for @cowboyMinigameBeginStringCustom.
  ///
  /// In en, this message translates to:
  /// **'Custom text (Chinese supported)'**
  String get cowboyMinigameBeginStringCustom;

  /// No description provided for @cowboyMinigameCustomTextInput.
  ///
  /// In en, this message translates to:
  /// **'Custom prompt text'**
  String get cowboyMinigameCustomTextInput;

  /// No description provided for @cowboyMinigameShowTutorial.
  ///
  /// In en, this message translates to:
  /// **'Show tutorial dialogue'**
  String get cowboyMinigameShowTutorial;

  /// No description provided for @cowboyMinigameBeginStringHint.
  ///
  /// In en, this message translates to:
  /// **'Adding the Not OK Corral module automatically enables Manual Packet Spawning in the Conveyor Belt module.'**
  String get cowboyMinigameBeginStringHint;

  /// No description provided for @cowboyMinigameHelpTitle.
  ///
  /// In en, this message translates to:
  /// **'Not OK Corral module'**
  String get cowboyMinigameHelpTitle;

  /// No description provided for @cowboyMinigameHelpOverviewBody.
  ///
  /// In en, this message translates to:
  /// **'A Wild West-exclusive minigame. Before each wave, the player receives a randomly selected seed packet. Planting it starts a zombie wave, and defeating every zombie completes the level.\nBefore planting each seed packet, the player can preview the types, counts, and positions of zombies in each row, allowing them to plan where to place the plant.'**
  String get cowboyMinigameHelpOverviewBody;

  /// No description provided for @cowboyMinigameHelpBeginStringBody.
  ///
  /// In en, this message translates to:
  /// **'The prompt text appears together with the zombie preview before every plant placement. The in-game default message is “Plant a plant from the conveyor belt to begin!”. The text can also be replaced with custom text.'**
  String get cowboyMinigameHelpBeginStringBody;

  /// No description provided for @cowboyMinigameHelpTutorialBody.
  ///
  /// In en, this message translates to:
  /// **'When Show Tutorial Dialogue is enabled, Crazy Dave and Penny appear before the level and explain the minigame through dialogue based on the first-play conversation from Wild West - Day 4.'**
  String get cowboyMinigameHelpTutorialBody;

  /// No description provided for @singleHandedTabLabel.
  ///
  /// In en, this message translates to:
  /// **'All by Oneself'**
  String get singleHandedTabLabel;

  /// No description provided for @singleHandedBasicParameters.
  ///
  /// In en, this message translates to:
  /// **'Basic Parameters'**
  String get singleHandedBasicParameters;

  /// No description provided for @singleHandedOverviewBasicConfiguration.
  ///
  /// In en, this message translates to:
  /// **'Basic Configuration'**
  String get singleHandedOverviewBasicConfiguration;

  /// No description provided for @singleHandedMissileCount.
  ///
  /// In en, this message translates to:
  /// **'Missiles per launch'**
  String get singleHandedMissileCount;

  /// No description provided for @singleHandedMissileInterval.
  ///
  /// In en, this message translates to:
  /// **'Missile launch interval'**
  String get singleHandedMissileInterval;

  /// No description provided for @singleHandedWarningTime.
  ///
  /// In en, this message translates to:
  /// **'Warning time'**
  String get singleHandedWarningTime;

  /// No description provided for @singleHandedRocketSpeed.
  ///
  /// In en, this message translates to:
  /// **'Missile speed'**
  String get singleHandedRocketSpeed;

  /// No description provided for @singleHandedZombieSpeedMultiplier.
  ///
  /// In en, this message translates to:
  /// **'Zombie speed multiplier'**
  String get singleHandedZombieSpeedMultiplier;

  /// No description provided for @singleHandedZombieHealthMultiplier.
  ///
  /// In en, this message translates to:
  /// **'Zombie health multiplier'**
  String get singleHandedZombieHealthMultiplier;

  /// No description provided for @singleHandedSpecialMultiplierHint.
  ///
  /// In en, this message translates to:
  /// **'Speed and health in special waves are multiplied again from these base values.'**
  String get singleHandedSpecialMultiplierHint;

  /// No description provided for @singleHandedPlantConfiguration.
  ///
  /// In en, this message translates to:
  /// **'Plant Configuration'**
  String get singleHandedPlantConfiguration;

  /// No description provided for @singleHandedPlantConfigurationInfo.
  ///
  /// In en, this message translates to:
  /// **'The initial plant is the starting weapon and upgrades automatically after the required number of kills.\nThe initial plant appears in the upper-left tile. A minecart must be placed there, or the game immediately counts the level as failed.'**
  String get singleHandedPlantConfigurationInfo;

  /// No description provided for @singleHandedInitialPlantSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Initial plant · Attack interval: {interval}'**
  String singleHandedInitialPlantSubtitle(String interval);

  /// No description provided for @singleHandedAttackInterval.
  ///
  /// In en, this message translates to:
  /// **'Attack interval'**
  String get singleHandedAttackInterval;

  /// No description provided for @singleHandedAttackIntervalHint.
  ///
  /// In en, this message translates to:
  /// **'A smaller attack interval means a faster attack speed.'**
  String get singleHandedAttackIntervalHint;

  /// No description provided for @singleHandedAddUpgradePlant.
  ///
  /// In en, this message translates to:
  /// **'Add Upgrade Plant'**
  String get singleHandedAddUpgradePlant;

  /// No description provided for @singleHandedNoUpgradePlants.
  ///
  /// In en, this message translates to:
  /// **'No upgrade plants yet. Add one to begin.'**
  String get singleHandedNoUpgradePlants;

  /// No description provided for @singleHandedRequiredKills.
  ///
  /// In en, this message translates to:
  /// **'Required kills'**
  String get singleHandedRequiredKills;

  /// No description provided for @singleHandedEditUpgradePlant.
  ///
  /// In en, this message translates to:
  /// **'Edit: {plantName}'**
  String singleHandedEditUpgradePlant(String plantName);

  /// No description provided for @singleHandedUpgradePlantSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Kills: {kills} · Attack interval: {interval}'**
  String singleHandedUpgradePlantSubtitle(int kills, String interval);

  /// No description provided for @singleHandedSpecialWaves.
  ///
  /// In en, this message translates to:
  /// **'Special Waves'**
  String get singleHandedSpecialWaves;

  /// No description provided for @singleHandedSpecialWavesInfo.
  ///
  /// In en, this message translates to:
  /// **'Use these for Boss waves. Speed and health multipliers are applied on top of the base values above.'**
  String get singleHandedSpecialWavesInfo;

  /// No description provided for @singleHandedAddSpecialWave.
  ///
  /// In en, this message translates to:
  /// **'Add Special Wave'**
  String get singleHandedAddSpecialWave;

  /// No description provided for @singleHandedNoSpecialWaves.
  ///
  /// In en, this message translates to:
  /// **'No special waves yet. Add one to begin.'**
  String get singleHandedNoSpecialWaves;

  /// No description provided for @singleHandedSpecialWave.
  ///
  /// In en, this message translates to:
  /// **'Special Wave'**
  String get singleHandedSpecialWave;

  /// No description provided for @singleHandedWave.
  ///
  /// In en, this message translates to:
  /// **'Wave'**
  String get singleHandedWave;

  /// No description provided for @singleHandedSpeedMultiplier.
  ///
  /// In en, this message translates to:
  /// **'Speed multiplier'**
  String get singleHandedSpeedMultiplier;

  /// No description provided for @singleHandedHealthMultiplier.
  ///
  /// In en, this message translates to:
  /// **'Health multiplier'**
  String get singleHandedHealthMultiplier;

  /// No description provided for @singleHandedShowHealthBar.
  ///
  /// In en, this message translates to:
  /// **'Show health bar'**
  String get singleHandedShowHealthBar;

  /// No description provided for @singleHandedWaveNumber.
  ///
  /// In en, this message translates to:
  /// **'Wave {wave}'**
  String singleHandedWaveNumber(int wave);

  /// No description provided for @singleHandedHealthBarEnabled.
  ///
  /// In en, this message translates to:
  /// **'Health bar on'**
  String get singleHandedHealthBarEnabled;

  /// No description provided for @singleHandedHealthBarDisabled.
  ///
  /// In en, this message translates to:
  /// **'Health bar off'**
  String get singleHandedHealthBarDisabled;

  /// No description provided for @singleHandedSpecialWaveSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Speed x{speed} · Health x{health}'**
  String singleHandedSpecialWaveSubtitle(String speed, String health);

  /// No description provided for @singleHandedAddTutorial.
  ///
  /// In en, this message translates to:
  /// **'Add All by Oneself Tutorial'**
  String get singleHandedAddTutorial;

  /// No description provided for @singleHandedConfigureTutorial.
  ///
  /// In en, this message translates to:
  /// **'Configure All by Oneself Tutorial'**
  String get singleHandedConfigureTutorial;

  /// No description provided for @singleHandedTutorialWaveForStartRocket.
  ///
  /// In en, this message translates to:
  /// **'Missiles start from wave'**
  String get singleHandedTutorialWaveForStartRocket;

  /// No description provided for @singleHandedTutorialHelpTitle.
  ///
  /// In en, this message translates to:
  /// **'All by Oneself Tutorial'**
  String get singleHandedTutorialHelpTitle;

  /// No description provided for @singleHandedTutorialHelpPromptsTitle.
  ///
  /// In en, this message translates to:
  /// **'Tutorial Prompts'**
  String get singleHandedTutorialHelpPromptsTitle;

  /// No description provided for @singleHandedTutorialHelpPromptsBody.
  ///
  /// In en, this message translates to:
  /// **'After this module is added, matching tutorial prompts appear at the start of the level, when a plant is upgraded for the first time, and when the first missile warning occurs.'**
  String get singleHandedTutorialHelpPromptsBody;

  /// No description provided for @singleHandedTutorialHelpWaveTitle.
  ///
  /// In en, this message translates to:
  /// **'Missile Starting Wave'**
  String get singleHandedTutorialHelpWaveTitle;

  /// No description provided for @singleHandedTutorialHelpWaveBody.
  ///
  /// In en, this message translates to:
  /// **'You can choose the wave from which missiles begin appearing; the launch interval is counted starting from that wave. For example, with a 30-second missile interval and a starting wave of 7, the first missiles launch 30 seconds after wave 7 begins.\nNote that adding this module by itself does not make missiles fall on the configured wave. The missile starting-wave setting only takes effect together with the All by Oneself module.'**
  String get singleHandedTutorialHelpWaveBody;

  /// No description provided for @hamsterballGeneration.
  ///
  /// In en, this message translates to:
  /// **'Spawn Logic'**
  String get hamsterballGeneration;

  /// No description provided for @hamsterballTimeBeforeFullSpawn.
  ///
  /// In en, this message translates to:
  /// **'Time to full spawn (TimeBeforeFullSpawn; seconds)'**
  String get hamsterballTimeBeforeFullSpawn;

  /// No description provided for @hamsterballZombies.
  ///
  /// In en, this message translates to:
  /// **'Zombies inside hamsterballs (Zombies)'**
  String get hamsterballZombies;

  /// No description provided for @hamsterballAddZombie.
  ///
  /// In en, this message translates to:
  /// **'Add zombie'**
  String get hamsterballAddZombie;

  /// No description provided for @hamsterballEmptyZombies.
  ///
  /// In en, this message translates to:
  /// **'No zombies in the list'**
  String get hamsterballEmptyZombies;

  /// No description provided for @hamsterballZombieLevel.
  ///
  /// In en, this message translates to:
  /// **'Zombie level'**
  String get hamsterballZombieLevel;

  /// No description provided for @hamsterballInitialSpeed.
  ///
  /// In en, this message translates to:
  /// **'Initial speed'**
  String get hamsterballInitialSpeed;

  /// No description provided for @hamsterballBehavior.
  ///
  /// In en, this message translates to:
  /// **'Behavior'**
  String get hamsterballBehavior;

  /// No description provided for @hamsterballBehaviorUniform.
  ///
  /// In en, this message translates to:
  /// **'Constant speed'**
  String get hamsterballBehaviorUniform;

  /// No description provided for @hamsterballBehaviorSlowdown.
  ///
  /// In en, this message translates to:
  /// **'Fast, then slow'**
  String get hamsterballBehaviorSlowdown;

  /// No description provided for @hamsterballBehaviorChangeLane.
  ///
  /// In en, this message translates to:
  /// **'Change lane on impact'**
  String get hamsterballBehaviorChangeLane;

  /// No description provided for @hamsterballBehaviorDetailUniform.
  ///
  /// In en, this message translates to:
  /// **'moves at a constant speed'**
  String get hamsterballBehaviorDetailUniform;

  /// No description provided for @hamsterballBehaviorDetailSlowdown.
  ///
  /// In en, this message translates to:
  /// **'starts fast, then slows down after hitting a plant'**
  String get hamsterballBehaviorDetailSlowdown;

  /// No description provided for @hamsterballBehaviorDetailChangeLane.
  ///
  /// In en, this message translates to:
  /// **'changes lane after hitting a plant'**
  String get hamsterballBehaviorDetailChangeLane;

  /// No description provided for @hamsterballBehaviorSummary.
  ///
  /// In en, this message translates to:
  /// **'Behavior: {value}'**
  String hamsterballBehaviorSummary(String value);

  /// No description provided for @hamsterballHasPlantfood.
  ///
  /// In en, this message translates to:
  /// **'Carries Plant Food (HasPlantfood)'**
  String get hamsterballHasPlantfood;

  /// No description provided for @hamsterballHelpTitle.
  ///
  /// In en, this message translates to:
  /// **'Hamsterball Event Help'**
  String get hamsterballHelpTitle;

  /// No description provided for @hamsterballHelpOverviewTitle.
  ///
  /// In en, this message translates to:
  /// **'Overview'**
  String get hamsterballHelpOverviewTitle;

  /// No description provided for @hamsterballHelpOverviewBody.
  ///
  /// In en, this message translates to:
  /// **'Introduced to the Chinese version in the 12th Anniversary Secret Realm, this ambush event summons rolling hamsterballs that carry zombies onto the lawn. Hamsterballs have three behavior modes, and plants run over along the way are destroyed immediately.\nHamsterballs have their own health. When broken, they release the zombies inside so they can continue advancing. Spikeweed, Spikerock, and similar plants can puncture hamsterballs and release their passengers.'**
  String get hamsterballHelpOverviewBody;

  /// No description provided for @hamsterballHelpRangeTitle.
  ///
  /// In en, this message translates to:
  /// **'Rolling Range'**
  String get hamsterballHelpRangeTitle;

  /// No description provided for @hamsterballHelpRangeBody.
  ///
  /// In en, this message translates to:
  /// **'The hamsterball rolling range is fixed from column 0 through column 8. These fields do not affect the editable content and are written silently by the editor.'**
  String get hamsterballHelpRangeBody;

  /// No description provided for @hamsterballHelpGenerationTitle.
  ///
  /// In en, this message translates to:
  /// **'Spawn Logic'**
  String get hamsterballHelpGenerationTitle;

  /// No description provided for @hamsterballHelpGenerationBody.
  ///
  /// In en, this message translates to:
  /// **'Group size controls how many hamsterballs appear in each group, while the group interval controls the delay between adjacent groups. Once the full-spawn time is reached, no extra groups are formed and all remaining hamsterballs spawn immediately.'**
  String get hamsterballHelpGenerationBody;

  /// No description provided for @cowboyMinigameDependencyWarningTitle.
  ///
  /// In en, this message translates to:
  /// **'Required module missing'**
  String get cowboyMinigameDependencyWarningTitle;

  /// No description provided for @cowboyMinigameConveyorWarning.
  ///
  /// In en, this message translates to:
  /// **'The Not OK Corral module must be used together with the Conveyor Belt module; otherwise, the level will crash.'**
  String get cowboyMinigameConveyorWarning;

  /// No description provided for @customGravestoneReplacePrompt.
  ///
  /// In en, this message translates to:
  /// **'Only one custom tombstone can be added to a level. Replace the level\'s existing custom tombstone with \"{gridItemName}\"?'**
  String customGravestoneReplacePrompt(String gridItemName);

  /// No description provided for @customGravestoneResourceGroupPrompt.
  ///
  /// In en, this message translates to:
  /// **'To display the Player\'s House tombstone correctly and prevent it from using the Sun texture, the lawn must include the \"Modern_Gravestone\" resource group. Open the custom lawn screen to add it? You can use the \"Modern Graveyard\" preset as a base.'**
  String get customGravestoneResourceGroupPrompt;

  /// No description provided for @openCustomStageSelection.
  ///
  /// In en, this message translates to:
  /// **'Open custom lawns'**
  String get openCustomStageSelection;

  /// No description provided for @customGridItemReplaceAction.
  ///
  /// In en, this message translates to:
  /// **'Replace'**
  String get customGridItemReplaceAction;

  /// No description provided for @roofFlowerPotColumns.
  ///
  /// In en, this message translates to:
  /// **'Flower Pot Range'**
  String get roofFlowerPotColumns;

  /// No description provided for @roofFlowerPotStartColumn.
  ///
  /// In en, this message translates to:
  /// **'Start column (StartColumn)'**
  String get roofFlowerPotStartColumn;

  /// No description provided for @roofFlowerPotEndColumn.
  ///
  /// In en, this message translates to:
  /// **'End column (EndColumn)'**
  String get roofFlowerPotEndColumn;

  /// No description provided for @roofFlowerPotPreview.
  ///
  /// In en, this message translates to:
  /// **'Flower pot preview'**
  String get roofFlowerPotPreview;

  /// No description provided for @roofFlowerPotLawnMismatchWarning.
  ///
  /// In en, this message translates to:
  /// **'The current lawn is not a Roof lawn. This module may not work in-game and could cause the level to crash.'**
  String get roofFlowerPotLawnMismatchWarning;

  /// No description provided for @eventConveyorModify.
  ///
  /// In en, this message translates to:
  /// **'Event: Conveyor Change'**
  String get eventConveyorModify;

  /// No description provided for @bowlingMinigame.
  ///
  /// In en, this message translates to:
  /// **'Bulb Bowling module'**
  String get bowlingMinigame;

  /// No description provided for @eventPotionDrop.
  ///
  /// In en, this message translates to:
  /// **'Event: Potion Drop'**
  String get eventPotionDrop;

  /// No description provided for @eventShellSpawn.
  ///
  /// In en, this message translates to:
  /// **'Event: Seashell Spawn'**
  String get eventShellSpawn;

  /// No description provided for @eventPumpkinHouseSpawn.
  ///
  /// In en, this message translates to:
  /// **'Event: Pumpkin House Spawn'**
  String get eventPumpkinHouseSpawn;

  /// No description provided for @duration.
  ///
  /// In en, this message translates to:
  /// **'Duration'**
  String get duration;

  /// No description provided for @eventFairyWind.
  ///
  /// In en, this message translates to:
  /// **'Event: Fairytale Breeze'**
  String get eventFairyWind;

  /// No description provided for @eventFairyFog.
  ///
  /// In en, this message translates to:
  /// **'Event: Magic Fog'**
  String get eventFairyFog;

  /// No description provided for @eventRaidingParty.
  ///
  /// In en, this message translates to:
  /// **'Event: Raiding Party'**
  String get eventRaidingParty;

  /// No description provided for @swashbucklerCount.
  ///
  /// In en, this message translates to:
  /// **'Swashbuckler count'**
  String get swashbucklerCount;

  /// No description provided for @sunBomb.
  ///
  /// In en, this message translates to:
  /// **'Sun Bombs module'**
  String get sunBomb;

  /// No description provided for @eventSpawnGravestones.
  ///
  /// In en, this message translates to:
  /// **'Event: Grid Item Spawn'**
  String get eventSpawnGravestones;

  /// No description provided for @eventBarrelWave.
  ///
  /// In en, this message translates to:
  /// **'Event: Barrel Crisis'**
  String get eventBarrelWave;

  /// No description provided for @eventThunderWave.
  ///
  /// In en, this message translates to:
  /// **'Event: Thundercloud Storm'**
  String get eventThunderWave;

  /// No description provided for @eventGraveSpawn.
  ///
  /// In en, this message translates to:
  /// **'Event: Grid Item Spawner'**
  String get eventGraveSpawn;

  /// No description provided for @zombieSpawnWait.
  ///
  /// In en, this message translates to:
  /// **'Zombie spawn delay'**
  String get zombieSpawnWait;

  /// No description provided for @change.
  ///
  /// In en, this message translates to:
  /// **'Change'**
  String get change;

  /// No description provided for @autoLevel.
  ///
  /// In en, this message translates to:
  /// **'Auto-Set level'**
  String get autoLevel;

  /// No description provided for @apply.
  ///
  /// In en, this message translates to:
  /// **'Apply'**
  String get apply;

  /// No description provided for @applyBatchLevel.
  ///
  /// In en, this message translates to:
  /// **'Apply batch level?'**
  String get applyBatchLevel;

  /// No description provided for @starChallenges.
  ///
  /// In en, this message translates to:
  /// **'Challenge Module Settings'**
  String get starChallenges;

  /// No description provided for @addChallenge.
  ///
  /// In en, this message translates to:
  /// **'Add challenge'**
  String get addChallenge;

  /// No description provided for @unknownChallengeType.
  ///
  /// In en, this message translates to:
  /// **'Unknown challenge type'**
  String get unknownChallengeType;

  /// No description provided for @protectedPlants.
  ///
  /// In en, this message translates to:
  /// **'Endangered plants'**
  String get protectedPlants;

  /// No description provided for @addPlant.
  ///
  /// In en, this message translates to:
  /// **'Add plant'**
  String get addPlant;

  /// No description provided for @protectedGridItems.
  ///
  /// In en, this message translates to:
  /// **'Grid items to protect'**
  String get protectedGridItems;

  /// No description provided for @addGridItem.
  ///
  /// In en, this message translates to:
  /// **'Add grid item'**
  String get addGridItem;

  /// No description provided for @scope.
  ///
  /// In en, this message translates to:
  /// **'Scope'**
  String get scope;

  /// No description provided for @applyBatch.
  ///
  /// In en, this message translates to:
  /// **'Batch apply'**
  String get applyBatch;

  /// No description provided for @addPlants.
  ///
  /// In en, this message translates to:
  /// **'Add plants to the list'**
  String get addPlants;

  /// No description provided for @noPlantsConfigured.
  ///
  /// In en, this message translates to:
  /// **'No plants configured. Please add plants to the list.'**
  String get noPlantsConfigured;

  /// No description provided for @batchLevelFormat.
  ///
  /// In en, this message translates to:
  /// **'Batch level: {level}'**
  String batchLevelFormat(int level);

  /// No description provided for @protectPlants.
  ///
  /// In en, this message translates to:
  /// **'Save Our Seeds'**
  String get protectPlants;

  /// No description provided for @autoCount.
  ///
  /// In en, this message translates to:
  /// **'Auto count'**
  String get autoCount;

  /// No description provided for @startingPlantfoodOverride.
  ///
  /// In en, this message translates to:
  /// **'Starting Plant Food (StartingPlantfoodOverride)'**
  String get startingPlantfoodOverride;

  /// No description provided for @iconText.
  ///
  /// In en, this message translates to:
  /// **'Icon Text'**
  String get iconText;

  /// No description provided for @iconImage.
  ///
  /// In en, this message translates to:
  /// **'Icon Image'**
  String get iconImage;

  /// No description provided for @maxSunOverride.
  ///
  /// In en, this message translates to:
  /// **'Max sun limit (MaxSunOverride)'**
  String get maxSunOverride;

  /// No description provided for @maxSunHelpTitle.
  ///
  /// In en, this message translates to:
  /// **'Max Sun Limit module'**
  String get maxSunHelpTitle;

  /// No description provided for @maxSunHelpOverview.
  ///
  /// In en, this message translates to:
  /// **'Originally used for Penny’s Pursuit difficulty settings. This module overrides the maximum amount of sun that can be stored in a level.'**
  String get maxSunHelpOverview;

  /// No description provided for @moonExpertZombieLevel.
  ///
  /// In en, this message translates to:
  /// **'Zombie level (ZombieLevel)'**
  String get moonExpertZombieLevel;

  /// No description provided for @moonExpertZombieLevelTooltip.
  ///
  /// In en, this message translates to:
  /// **'When this module is enabled, all zombie levels defined in the level are overridden by the level set here.'**
  String get moonExpertZombieLevelTooltip;

  /// No description provided for @moonExpertHelpTitle.
  ///
  /// In en, this message translates to:
  /// **'Moon Expert'**
  String get moonExpertHelpTitle;

  /// No description provided for @moonExpertHelpOverview.
  ///
  /// In en, this message translates to:
  /// **'This module is commonly used in Moon BaseZ Expert Mode. When enabled, every zombie in the level uses the specified level, and all plants are forced to Level 1. \nThese settings override other plant and zombie level settings, including those in the Tier Definition module. Note that this module has no effect in Creative Courtyard.'**
  String get moonExpertHelpOverview;

  /// No description provided for @startingPlantfoodHelpTitle.
  ///
  /// In en, this message translates to:
  /// **'Starting Plant Food module'**
  String get startingPlantfoodHelpTitle;

  /// No description provided for @startingPlantfoodHelpOverview.
  ///
  /// In en, this message translates to:
  /// **'Originally used for Penny’s Pursuit difficulty settings. This module overrides the amount of Plant Food available at the start of a level.'**
  String get startingPlantfoodHelpOverview;

  /// No description provided for @starChallengeHelpTitle.
  ///
  /// In en, this message translates to:
  /// **'Challenge Module'**
  String get starChallengeHelpTitle;

  /// No description provided for @starChallengeHelpOverview.
  ///
  /// In en, this message translates to:
  /// **'Select the challenge modules to apply to the level. Multiple challenges can be enabled at once, and the same challenge can be applied multiple times.'**
  String get starChallengeHelpOverview;

  /// No description provided for @starChallengeHelpSuggestionTitle.
  ///
  /// In en, this message translates to:
  /// **'Tips'**
  String get starChallengeHelpSuggestionTitle;

  /// No description provided for @starChallengeHelpSuggestion.
  ///
  /// In en, this message translates to:
  /// **'Some challenges display progress using an on-screen tracker. If too many challenges are enabled, the tracker may be overlapped.'**
  String get starChallengeHelpSuggestion;

  /// No description provided for @remove.
  ///
  /// In en, this message translates to:
  /// **'Remove'**
  String get remove;

  /// No description provided for @plant.
  ///
  /// In en, this message translates to:
  /// **'Plant'**
  String get plant;

  /// No description provided for @zombie.
  ///
  /// In en, this message translates to:
  /// **'Zombie'**
  String get zombie;

  /// No description provided for @initialZombieLayout.
  ///
  /// In en, this message translates to:
  /// **'Initial zombie layout'**
  String get initialZombieLayout;

  /// No description provided for @manualInput.
  ///
  /// In en, this message translates to:
  /// **'Manual input'**
  String get manualInput;

  /// No description provided for @waveManagerModule.
  ///
  /// In en, this message translates to:
  /// **'Wave Manager Module'**
  String get waveManagerModule;

  /// No description provided for @points.
  ///
  /// In en, this message translates to:
  /// **'Points'**
  String get points;

  /// No description provided for @row.
  ///
  /// In en, this message translates to:
  /// **'Row'**
  String get row;

  /// No description provided for @addType.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get addType;

  /// No description provided for @availableZombies.
  ///
  /// In en, this message translates to:
  /// **'Available zombies'**
  String get availableZombies;

  /// No description provided for @presetPlants.
  ///
  /// In en, this message translates to:
  /// **'Preset plants (PresetPlantList)'**
  String get presetPlants;

  /// No description provided for @whiteList.
  ///
  /// In en, this message translates to:
  /// **'White list (WhiteList)'**
  String get whiteList;

  /// No description provided for @blackList.
  ///
  /// In en, this message translates to:
  /// **'Black list (BlackList)'**
  String get blackList;

  /// No description provided for @chooser.
  ///
  /// In en, this message translates to:
  /// **'Choose Your Seeds (Chooser)'**
  String get chooser;

  /// No description provided for @preset.
  ///
  /// In en, this message translates to:
  /// **'Locked and Loaded (Preset)'**
  String get preset;

  /// No description provided for @seedBankHelp.
  ///
  /// In en, this message translates to:
  /// **'Seed Bank'**
  String get seedBankHelp;

  /// No description provided for @conveyorBeltHelp.
  ///
  /// In en, this message translates to:
  /// **'Conveyor Belt'**
  String get conveyorBeltHelp;

  /// No description provided for @dropDelayConditions.
  ///
  /// In en, this message translates to:
  /// **'Seed packets delay (DropDelayConditions)'**
  String get dropDelayConditions;

  /// No description provided for @unitSeconds.
  ///
  /// In en, this message translates to:
  /// **'Unit: seconds'**
  String get unitSeconds;

  /// No description provided for @propertyLabelSeconds.
  ///
  /// In en, this message translates to:
  /// **'{name} ({code}; seconds)'**
  String propertyLabelSeconds(String name, String code);

  /// No description provided for @speedConditions.
  ///
  /// In en, this message translates to:
  /// **'Conveyor speed (SpeedConditions)'**
  String get speedConditions;

  /// No description provided for @speedConditionsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Default is 100; higher values increase speed'**
  String get speedConditionsSubtitle;

  /// No description provided for @addPlantConveyor.
  ///
  /// In en, this message translates to:
  /// **'Add plant'**
  String get addPlantConveyor;

  /// No description provided for @addTool.
  ///
  /// In en, this message translates to:
  /// **'Add tool packet'**
  String get addTool;

  /// No description provided for @powerTile.
  ///
  /// In en, this message translates to:
  /// **'Power Tiles'**
  String get powerTile;

  /// No description provided for @powerTileGridSection.
  ///
  /// In en, this message translates to:
  /// **'Current lawn'**
  String get powerTileGridSection;

  /// No description provided for @powerTileGridHelpPrimary.
  ///
  /// In en, this message translates to:
  /// **'Tap a cell to place a tile, and tap again to remove it. Placing a tile on an occupied cell will replace the existing one. Tiles from other groups are shown dimmed to indicate they are not in the selected group.'**
  String get powerTileGridHelpPrimary;

  /// No description provided for @powerTileGridHelpSecondaryMobile.
  ///
  /// In en, this message translates to:
  /// **'Long press a cell to quickly set a group or adjust the propagation delay.'**
  String get powerTileGridHelpSecondaryMobile;

  /// No description provided for @powerTileGridHelpSecondaryDesktop.
  ///
  /// In en, this message translates to:
  /// **'Right-click a cell to quickly set a group or adjust its propagation delay.'**
  String get powerTileGridHelpSecondaryDesktop;

  /// No description provided for @powerTileLinkedTilesSection.
  ///
  /// In en, this message translates to:
  /// **'Tile list'**
  String get powerTileLinkedTilesSection;

  /// No description provided for @powerTilePropagationDelayLabel.
  ///
  /// In en, this message translates to:
  /// **'Propagation delay (seconds)'**
  String get powerTilePropagationDelayLabel;

  /// No description provided for @powerTilePropagationDelayTooltip.
  ///
  /// In en, this message translates to:
  /// **'The delay before power begins to propagate to other tiles (0–5 seconds). This does not include the transmission time itself. The default propagation delay is 1.5 seconds.'**
  String get powerTilePropagationDelayTooltip;

  /// No description provided for @powerTileDialogEditCell.
  ///
  /// In en, this message translates to:
  /// **'Edit cell'**
  String get powerTileDialogEditCell;

  /// No description provided for @powerTileDialogTileGroup.
  ///
  /// In en, this message translates to:
  /// **'Tile group'**
  String get powerTileDialogTileGroup;

  /// No description provided for @powerTileDialogNone.
  ///
  /// In en, this message translates to:
  /// **'None'**
  String get powerTileDialogNone;

  /// No description provided for @powerTileDialogPropagationDelay.
  ///
  /// In en, this message translates to:
  /// **'Propagation delay (seconds)'**
  String get powerTileDialogPropagationDelay;

  /// No description provided for @powerTileHelpOverview.
  ///
  /// In en, this message translates to:
  /// **'Power Tiles are divided into five groups. When a plant on a tile activates its Plant Food effect, power is propagated to other tiles in the same group, causing those plants to activate their Plant Food effect as well. The initial delay before propagation can be configured. '**
  String get powerTileHelpOverview;

  /// No description provided for @powerTileHelpGridSize.
  ///
  /// In en, this message translates to:
  /// **'Lawn size varies by level: 6 rows × 10 columns in Underwater World, and 5 rows × 9 columns in other levels.'**
  String get powerTileHelpGridSize;

  /// No description provided for @powerTileHelpQuickEdit.
  ///
  /// In en, this message translates to:
  /// **'Quick edit: {interaction}'**
  String powerTileHelpQuickEdit(String interaction);

  /// No description provided for @eventEditorInDevelopment.
  ///
  /// In en, this message translates to:
  /// **'Event editor in development'**
  String get eventEditorInDevelopment;

  /// No description provided for @level.
  ///
  /// In en, this message translates to:
  /// **'Level'**
  String get level;

  /// No description provided for @missingTideModule.
  ///
  /// In en, this message translates to:
  /// **'Missing Tide System module'**
  String get missingTideModule;

  /// No description provided for @levelHasNoTideProperties.
  ///
  /// In en, this message translates to:
  /// **'This level has no Tide System module (TideProperties). This event may not function correctly and could cause a crash.'**
  String get levelHasNoTideProperties;

  /// No description provided for @changePositionChangeAmount.
  ///
  /// In en, this message translates to:
  /// **'Column Offset (ChangeAmount)'**
  String get changePositionChangeAmount;

  /// No description provided for @preview.
  ///
  /// In en, this message translates to:
  /// **'Tide preview'**
  String get preview;

  /// No description provided for @fogPreview.
  ///
  /// In en, this message translates to:
  /// **'Fog preview'**
  String get fogPreview;

  /// No description provided for @water.
  ///
  /// In en, this message translates to:
  /// **'Water'**
  String get water;

  /// No description provided for @land.
  ///
  /// In en, this message translates to:
  /// **'Land'**
  String get land;

  /// No description provided for @tidePositionOrderHint.
  ///
  /// In en, this message translates to:
  /// **'The rightmost lawn coordinate is 0 and the leftmost is 9. The Tide System module must be added last, or the level may crash.'**
  String get tidePositionOrderHint;

  /// No description provided for @groupConfigN.
  ///
  /// In en, this message translates to:
  /// **'Group {n} config'**
  String groupConfigN(int n);

  /// No description provided for @globalParameters.
  ///
  /// In en, this message translates to:
  /// **'Global parameters'**
  String get globalParameters;

  /// No description provided for @timePerGrid.
  ///
  /// In en, this message translates to:
  /// **'Transfer time (seconds per tile)'**
  String get timePerGrid;

  /// No description provided for @damagePerSecond.
  ///
  /// In en, this message translates to:
  /// **'Damage per second'**
  String get damagePerSecond;

  /// No description provided for @stageMismatch.
  ///
  /// In en, this message translates to:
  /// **'Lawn Type Mismatch'**
  String get stageMismatch;

  /// No description provided for @currentStageNotPirate.
  ///
  /// In en, this message translates to:
  /// **'The current lawn is not Pirate Seas. This module may not work correctly and could cause a crash.'**
  String get currentStageNotPirate;

  /// No description provided for @plankPreview.
  ///
  /// In en, this message translates to:
  /// **'Plank preview'**
  String get plankPreview;

  /// No description provided for @plankRows.
  ///
  /// In en, this message translates to:
  /// **'Plank rows'**
  String get plankRows;

  /// No description provided for @plankRowsDeepSea.
  ///
  /// In en, this message translates to:
  /// **'Plank rows (Underwater World)'**
  String get plankRowsDeepSea;

  /// No description provided for @selectWeatherType.
  ///
  /// In en, this message translates to:
  /// **'Select weather type'**
  String get selectWeatherType;

  /// No description provided for @counts.
  ///
  /// In en, this message translates to:
  /// **'Quantity Control'**
  String get counts;

  /// No description provided for @initialCount.
  ///
  /// In en, this message translates to:
  /// **'Initial Count'**
  String get initialCount;

  /// No description provided for @maximumCount.
  ///
  /// In en, this message translates to:
  /// **'Maximum Count'**
  String get maximumCount;

  /// No description provided for @spawnInterval.
  ///
  /// In en, this message translates to:
  /// **'Spawn Interval'**
  String get spawnInterval;

  /// No description provided for @minimumIntervalSeconds.
  ///
  /// In en, this message translates to:
  /// **'Minimum Interval (seconds)'**
  String get minimumIntervalSeconds;

  /// No description provided for @maximumIntervalSeconds.
  ///
  /// In en, this message translates to:
  /// **'Maximum Interval (seconds)'**
  String get maximumIntervalSeconds;

  /// No description provided for @potionTypeList.
  ///
  /// In en, this message translates to:
  /// **'Potion Type List'**
  String get potionTypeList;

  /// No description provided for @max.
  ///
  /// In en, this message translates to:
  /// **'Max count (MaxPotionCount)'**
  String get max;

  /// No description provided for @ignoreGravestoneSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Enable to spawn regardless of grid items'**
  String get ignoreGravestoneSubtitle;

  /// No description provided for @thisPortalSpawns.
  ///
  /// In en, this message translates to:
  /// **'This portal can spawn:'**
  String get thisPortalSpawns;

  /// No description provided for @noItemsAddHint.
  ///
  /// In en, this message translates to:
  /// **'No items. Add plants, zombies, or collectibles.'**
  String get noItemsAddHint;

  /// No description provided for @zombieTypeSpiderZombieName.
  ///
  /// In en, this message translates to:
  /// **'Zombie type (SpiderZombieName)'**
  String get zombieTypeSpiderZombieName;

  /// No description provided for @noneSelected.
  ///
  /// In en, this message translates to:
  /// **'None selected'**
  String get noneSelected;

  /// No description provided for @totalSpiderCount.
  ///
  /// In en, this message translates to:
  /// **'Total count (SpiderCount)'**
  String get totalSpiderCount;

  /// No description provided for @perBatchGroupSize.
  ///
  /// In en, this message translates to:
  /// **'Per batch count (GroupSize)'**
  String get perBatchGroupSize;

  /// No description provided for @fallTime.
  ///
  /// In en, this message translates to:
  /// **'Fall time (ZombieFallTime; seconds)'**
  String get fallTime;

  /// No description provided for @waveStartMessageLabel.
  ///
  /// In en, this message translates to:
  /// **'Red warning message (WaveStartMessage)'**
  String get waveStartMessageLabel;

  /// No description provided for @optionalWarningText.
  ///
  /// In en, this message translates to:
  /// **'Optional warning text shown at the center of the screen when the drop begins; Chinese is not supported'**
  String get optionalWarningText;

  /// No description provided for @rowNShort.
  ///
  /// In en, this message translates to:
  /// **'Row {n}'**
  String rowNShort(int n);

  /// No description provided for @weightMaxFormat.
  ///
  /// In en, this message translates to:
  /// **'Weight: {weight}, Max: {max}'**
  String weightMaxFormat(int weight, int max);

  /// No description provided for @seedRainTypeLabel.
  ///
  /// In en, this message translates to:
  /// **'Type: {type}'**
  String seedRainTypeLabel(String type);

  /// No description provided for @seedRainWeightLabel.
  ///
  /// In en, this message translates to:
  /// **'Weight: {weight}'**
  String seedRainWeightLabel(int weight);

  /// No description provided for @seedRainMaxLabel.
  ///
  /// In en, this message translates to:
  /// **'Max: {max}'**
  String seedRainMaxLabel(int max);

  /// No description provided for @random.
  ///
  /// In en, this message translates to:
  /// **'Random'**
  String get random;

  /// No description provided for @noChallengesConfigured.
  ///
  /// In en, this message translates to:
  /// **'No challenges configured'**
  String get noChallengesConfigured;

  /// No description provided for @whiteListBlackListHint.
  ///
  /// In en, this message translates to:
  /// **'If the whitelist is empty, no restrictions are applied.\nParallel Universe plants are ignored by the whitelist unless the corresponding module is enabled.\nThe blacklist explicitly disables plants and takes priority over the whitelist.'**
  String get whiteListBlackListHint;

  /// No description provided for @conveyorBeltHelpIntro.
  ///
  /// In en, this message translates to:
  /// **'Conveyor-belt delivers seed packets randomly based on configured weights. Requires a plant pool and drop delay settings.'**
  String get conveyorBeltHelpIntro;

  /// No description provided for @conveyorBeltHelpPool.
  ///
  /// In en, this message translates to:
  /// **'Plant pool & weight: Probability = weight / total weight. Use thresholds to adjust dynamically.'**
  String get conveyorBeltHelpPool;

  /// No description provided for @conveyorBeltHelpDropDelay.
  ///
  /// In en, this message translates to:
  /// **'Seed packets delay: Controls the interval between seed packet generation. The interval can scale based on the number of queued plants: more backlog usually results in slower generation.'**
  String get conveyorBeltHelpDropDelay;

  /// No description provided for @conveyorBeltHelpSpeed.
  ///
  /// In en, this message translates to:
  /// **'Conveyor speed: Controls the movement speed of cards on the conveyor belt. Default speed is 100. Speed can scale dynamically based on backlog size.'**
  String get conveyorBeltHelpSpeed;

  /// No description provided for @cannotAddEliteZombies.
  ///
  /// In en, this message translates to:
  /// **'Cannot add elite zombies'**
  String get cannotAddEliteZombies;

  /// No description provided for @eliteZombiesNotAllowed.
  ///
  /// In en, this message translates to:
  /// **'Elite zombies are not allowed here'**
  String get eliteZombiesNotAllowed;

  /// No description provided for @yetiZombiesNotAllowed.
  ///
  /// In en, this message translates to:
  /// **'Yetis are not allowed here'**
  String get yetiZombiesNotAllowed;

  /// No description provided for @fixToAlias.
  ///
  /// In en, this message translates to:
  /// **'Fix to {alias}'**
  String fixToAlias(String alias);

  /// No description provided for @editPresetZombie.
  ///
  /// In en, this message translates to:
  /// **'Edit preset zombie: {name}'**
  String editPresetZombie(String name);

  /// No description provided for @missingZombossMechModule.
  ///
  /// In en, this message translates to:
  /// **'Missing Zomboss Mech Battle module (ZombossBattleModuleProperties)'**
  String get missingZombossMechModule;

  /// No description provided for @missingZombossBattleModule.
  ///
  /// In en, this message translates to:
  /// **'Missing Non-mech Zomboss Battle module (ZombossLastStandMinigameProperties)'**
  String get missingZombossBattleModule;

  /// No description provided for @challengeNoConfig.
  ///
  /// In en, this message translates to:
  /// **'This challenge doesn\'t support configuration.'**
  String get challengeNoConfig;

  /// No description provided for @maxPotionCount.
  ///
  /// In en, this message translates to:
  /// **'Max Potion Count'**
  String get maxPotionCount;

  /// No description provided for @potionTypesConfigured.
  ///
  /// In en, this message translates to:
  /// **'Potion types: {count} configured'**
  String potionTypesConfigured(int count);

  /// No description provided for @pipelinesCount.
  ///
  /// In en, this message translates to:
  /// **'Pipelines: {count}'**
  String pipelinesCount(int count);

  /// No description provided for @windN.
  ///
  /// In en, this message translates to:
  /// **'Freezing Wind #{n}'**
  String windN(int n);

  /// No description provided for @zombieList.
  ///
  /// In en, this message translates to:
  /// **'Zombie list'**
  String get zombieList;

  /// No description provided for @positionPoolSpawnPositions.
  ///
  /// In en, this message translates to:
  /// **'Position pool (SpawnPositionsPool)'**
  String get positionPoolSpawnPositions;

  /// No description provided for @tapCellsSelectDeselect.
  ///
  /// In en, this message translates to:
  /// **'Tap tiles to select/deselect spawn positions'**
  String get tapCellsSelectDeselect;

  /// No description provided for @gravestonePool.
  ///
  /// In en, this message translates to:
  /// **'Item pool (GravestonePool)'**
  String get gravestonePool;

  /// No description provided for @current.
  ///
  /// In en, this message translates to:
  /// **'Current'**
  String get current;

  /// No description provided for @eliteZombiesUseDefaultLevel.
  ///
  /// In en, this message translates to:
  /// **'Elite zombies use default level.'**
  String get eliteZombiesUseDefaultLevel;

  /// No description provided for @basicParameters.
  ///
  /// In en, this message translates to:
  /// **'Basic parameters'**
  String get basicParameters;

  /// No description provided for @zombieSpawnWaitSec.
  ///
  /// In en, this message translates to:
  /// **'Spawn delay (seconds) '**
  String get zombieSpawnWaitSec;

  /// No description provided for @gridTypes.
  ///
  /// In en, this message translates to:
  /// **'Grid item types'**
  String get gridTypes;

  /// No description provided for @zombiesCount.
  ///
  /// In en, this message translates to:
  /// **'Zombies ({count})'**
  String zombiesCount(int count);

  /// No description provided for @stormCarriedZombiesCount.
  ///
  /// In en, this message translates to:
  /// **'Carried zombies ({count} total)'**
  String stormCarriedZombiesCount(int count);

  /// No description provided for @eventHelpGraveSpawnBody.
  ///
  /// In en, this message translates to:
  /// **'Spawns zombies from specific grid item types. Commonly used for Dark Ages Necromancy ambushes.'**
  String get eventHelpGraveSpawnBody;

  /// No description provided for @eventHelpGraveSpawnZombieWait.
  ///
  /// In en, this message translates to:
  /// **'Delay between wave start and zombie spawn. Zombies won\'t spawn if the next wave has already begun.'**
  String get eventHelpGraveSpawnZombieWait;

  /// No description provided for @eventHelpStormOverview.
  ///
  /// In en, this message translates to:
  /// **'Creates sandstorms or snowstorms that rapidly transport zombies to the front lines. Can spawn in groups. Freezing Storm from Memory Lane can freeze plants it passes through.'**
  String get eventHelpStormOverview;

  /// No description provided for @eventHelpStormColumnRange.
  ///
  /// In en, this message translates to:
  /// **'The left boundary is column 0 and the right boundary is column 9 (or column 10 in Underwater World). Start column must be less than end column, or the storm will not spawn.'**
  String get eventHelpStormColumnRange;

  /// No description provided for @spawnParameters.
  ///
  /// In en, this message translates to:
  /// **'Spawn parameters'**
  String get spawnParameters;

  /// No description provided for @sandstorm.
  ///
  /// In en, this message translates to:
  /// **'Sandstorm'**
  String get sandstorm;

  /// No description provided for @snowstorm.
  ///
  /// In en, this message translates to:
  /// **'Snowstorm'**
  String get snowstorm;

  /// No description provided for @excoldStorm.
  ///
  /// In en, this message translates to:
  /// **'Freezing Storm'**
  String get excoldStorm;

  /// No description provided for @columnStart.
  ///
  /// In en, this message translates to:
  /// **'Start column (ColumnStart)'**
  String get columnStart;

  /// No description provided for @columnEnd.
  ///
  /// In en, this message translates to:
  /// **'End column (ColumnEnd)'**
  String get columnEnd;

  /// No description provided for @groupSize.
  ///
  /// In en, this message translates to:
  /// **'Zombies per group (GroupSize)'**
  String get groupSize;

  /// No description provided for @timeBetweenGroups.
  ///
  /// In en, this message translates to:
  /// **'Group Interval (TimeBetweenGroups; seconds)'**
  String get timeBetweenGroups;

  /// No description provided for @applyBatchLevelContent.
  ///
  /// In en, this message translates to:
  /// **'Set all zombies in this wave to level {level} (elite zombies unaffected)'**
  String applyBatchLevelContent(int level);

  /// No description provided for @randomRow.
  ///
  /// In en, this message translates to:
  /// **'Random row'**
  String get randomRow;

  /// No description provided for @levelFormat.
  ///
  /// In en, this message translates to:
  /// **'Level: {level}'**
  String levelFormat(int level);

  /// No description provided for @levelAccount.
  ///
  /// In en, this message translates to:
  /// **'Level: follows account'**
  String get levelAccount;

  /// No description provided for @levelDisplay.
  ///
  /// In en, this message translates to:
  /// **'Level: {value}'**
  String levelDisplay(String value);

  /// No description provided for @eventStandardSpawnTitle.
  ///
  /// In en, this message translates to:
  /// **'Basic Spawner'**
  String get eventStandardSpawnTitle;

  /// No description provided for @eventGroundSpawnTitle.
  ///
  /// In en, this message translates to:
  /// **'Ground Spawner'**
  String get eventGroundSpawnTitle;

  /// No description provided for @eventHelpStandardOverview.
  ///
  /// In en, this message translates to:
  /// **'Basic event for spawning zombies. Allows configuring the level and row for each zombie. Level 0 follows the lawn’s default level (which is Level 1 in Creative Courtyard).\nBy default, the Drop config specifies the number of zombies that carry Plant Food. After adding a plant, it will randomly assign a zombie to drop a seed packet of the selected plant.'**
  String get eventHelpStandardOverview;

  /// No description provided for @eventHelpStandardRow.
  ///
  /// In en, this message translates to:
  /// **'Zombies can spawn in any row from 1–5, or in a random row.'**
  String get eventHelpStandardRow;

  /// No description provided for @eventHelpStandardRowDeepSea.
  ///
  /// In en, this message translates to:
  /// **'Zombies can spawn in any row from 1–6, or in a random row.'**
  String get eventHelpStandardRowDeepSea;

  /// No description provided for @ztPerksSectionTitle.
  ///
  /// In en, this message translates to:
  /// **'Zombie Perks'**
  String get ztPerksSectionTitle;

  /// No description provided for @ztPerksSectionHint.
  ///
  /// In en, this message translates to:
  /// **'A zombie cannot have multiple perks of the same type.'**
  String get ztPerksSectionHint;

  /// No description provided for @ztPerksNone.
  ///
  /// In en, this message translates to:
  /// **'No perks have been added yet.'**
  String get ztPerksNone;

  /// No description provided for @ztPerksAdd.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get ztPerksAdd;

  /// No description provided for @ztPerksAddTitle.
  ///
  /// In en, this message translates to:
  /// **'Add Zombie Perks'**
  String get ztPerksAddTitle;

  /// No description provided for @eventHelpJitteredZtPerks.
  ///
  /// In en, this message translates to:
  /// **'Assign Ztalemate Escape perks to individual zombies. Zombies with perks receive additional bonuses. Perks are saved in the zombie\'s Titles array. Only one perk of each type may be used on the same zombie (for example, Crystal I and Crystal II cannot both be applied).'**
  String get eventHelpJitteredZtPerks;

  /// No description provided for @ztPerkCategoryCrystal.
  ///
  /// In en, this message translates to:
  /// **'Crystallization'**
  String get ztPerkCategoryCrystal;

  /// No description provided for @ztPerkCategoryAttack.
  ///
  /// In en, this message translates to:
  /// **'Strength'**
  String get ztPerkCategoryAttack;

  /// No description provided for @ztPerkCategorySpeed.
  ///
  /// In en, this message translates to:
  /// **'Rapidity'**
  String get ztPerkCategorySpeed;

  /// No description provided for @ztPerkCategoryShield.
  ///
  /// In en, this message translates to:
  /// **'Energy-Shield'**
  String get ztPerkCategoryShield;

  /// No description provided for @ztPerkCategoryGravity.
  ///
  /// In en, this message translates to:
  /// **'Hypergravity'**
  String get ztPerkCategoryGravity;

  /// No description provided for @ztPerkCategoryImmuneControl.
  ///
  /// In en, this message translates to:
  /// **'Unyielding'**
  String get ztPerkCategoryImmuneControl;

  /// No description provided for @ztPerkCategoryAntiControl.
  ///
  /// In en, this message translates to:
  /// **'Concentration'**
  String get ztPerkCategoryAntiControl;

  /// No description provided for @ztPerksViewStats.
  ///
  /// In en, this message translates to:
  /// **'View Stats'**
  String get ztPerksViewStats;

  /// No description provided for @ztPerkPropDamageTakenInterval.
  ///
  /// In en, this message translates to:
  /// **'Damage interval (seconds)'**
  String get ztPerkPropDamageTakenInterval;

  /// No description provided for @ztPerkPropDamageTotalTaken.
  ///
  /// In en, this message translates to:
  /// **'Cumulative damage instances taken'**
  String get ztPerkPropDamageTotalTaken;

  /// No description provided for @ztPerkPropDamageTakenPerTime.
  ///
  /// In en, this message translates to:
  /// **'Damage per hit'**
  String get ztPerkPropDamageTakenPerTime;

  /// No description provided for @ztPerkPropHpReduced.
  ///
  /// In en, this message translates to:
  /// **'Health reduction'**
  String get ztPerkPropHpReduced;

  /// No description provided for @ztPerkPropShieldNum.
  ///
  /// In en, this message translates to:
  /// **'Shield charges'**
  String get ztPerkPropShieldNum;

  /// No description provided for @ztPerkPropReducedControlPercent.
  ///
  /// In en, this message translates to:
  /// **'Control effect reduction'**
  String get ztPerkPropReducedControlPercent;

  /// No description provided for @ztPerkPropReducedDamagePercent.
  ///
  /// In en, this message translates to:
  /// **'Damage reduction'**
  String get ztPerkPropReducedDamagePercent;

  /// No description provided for @ztPerkPropImprovedDamagePercent.
  ///
  /// In en, this message translates to:
  /// **'Attack power increase'**
  String get ztPerkPropImprovedDamagePercent;

  /// No description provided for @ztPerkPropImprovedSpeedPercent.
  ///
  /// In en, this message translates to:
  /// **'Walking speed increase'**
  String get ztPerkPropImprovedSpeedPercent;

  /// No description provided for @ztPerkDescCrystal.
  ///
  /// In en, this message translates to:
  /// **'Grants immunity to instant-kill effects, allows damage to be taken only {damageCount} times every {interval} seconds, reduces each instance of damage taken to {damagePerHit}, and reduces health by {hpReduced}.'**
  String ztPerkDescCrystal(
    String interval,
    String damageCount,
    String damagePerHit,
    String hpReduced,
  );

  /// No description provided for @ztPerkDescGravity.
  ///
  /// In en, this message translates to:
  /// **'Immune to knockback and knockoff effects.'**
  String get ztPerkDescGravity;

  /// No description provided for @ztPerkDescShield.
  ///
  /// In en, this message translates to:
  /// **'Negates the first {shieldNum} instances of damage and grants immunity to instant-kill effects for the perk\'s duration.'**
  String ztPerkDescShield(String shieldNum);

  /// No description provided for @ztPerkDescImmuneControl.
  ///
  /// In en, this message translates to:
  /// **'Grants {percent} more resistance against control effects.'**
  String ztPerkDescImmuneControl(String percent);

  /// No description provided for @ztPerkDescAntiControl.
  ///
  /// In en, this message translates to:
  /// **'When under the influence of a control effect, damage taken is reduced by {percent}.'**
  String ztPerkDescAntiControl(String percent);

  /// No description provided for @ztPerkDescAttack.
  ///
  /// In en, this message translates to:
  /// **'Attack power increased by {percent}.'**
  String ztPerkDescAttack(String percent);

  /// No description provided for @ztPerkDescSpeed.
  ///
  /// In en, this message translates to:
  /// **'Walking speed increased by {percent}.'**
  String ztPerkDescSpeed(String percent);

  /// No description provided for @ztPerksCategoryInfoTitle.
  ///
  /// In en, this message translates to:
  /// **'Perk Descriptions'**
  String get ztPerksCategoryInfoTitle;

  /// No description provided for @ztPerkCategoryDescNumericHint.
  ///
  /// In en, this message translates to:
  /// **'A, B, X, N, and P represent values that vary by perk tier.'**
  String get ztPerkCategoryDescNumericHint;

  /// No description provided for @ztPerkCategoryDescCrystal.
  ///
  /// In en, this message translates to:
  /// **'Grants immunity to instant-kill effects, allows damage to be taken only N times every A seconds, reduces each instance of damage taken to B, and reduces health by X.'**
  String get ztPerkCategoryDescCrystal;

  /// No description provided for @ztPerkCategoryDescGravity.
  ///
  /// In en, this message translates to:
  /// **'Immune to knockback and knockoff effects.'**
  String get ztPerkCategoryDescGravity;

  /// No description provided for @ztPerkCategoryDescShield.
  ///
  /// In en, this message translates to:
  /// **'Negates the first N instances of damage and grants immunity to instant-kill effects for the perk\'s duration.'**
  String get ztPerkCategoryDescShield;

  /// No description provided for @ztPerkCategoryDescImmuneControl.
  ///
  /// In en, this message translates to:
  /// **'Grants P% more resistance against control effects.'**
  String get ztPerkCategoryDescImmuneControl;

  /// No description provided for @ztPerkCategoryDescAntiControl.
  ///
  /// In en, this message translates to:
  /// **'When under the influence of a control effect, damage taken is reduced by P%.'**
  String get ztPerkCategoryDescAntiControl;

  /// No description provided for @ztPerkCategoryDescAttack.
  ///
  /// In en, this message translates to:
  /// **'Attack power increased by P%.'**
  String get ztPerkCategoryDescAttack;

  /// No description provided for @ztPerkCategoryDescSpeed.
  ///
  /// In en, this message translates to:
  /// **'Walking speed increased by P%.'**
  String get ztPerkCategoryDescSpeed;

  /// No description provided for @warningStageSwitchedTo5Rows.
  ///
  /// In en, this message translates to:
  /// **'The lawn only has 5 rows, but some data references row 6. These objects may not appear correctly in-game.'**
  String get warningStageSwitchedTo5Rows;

  /// No description provided for @warningObjectsOutsideArea.
  ///
  /// In en, this message translates to:
  /// **'Some objects are placed outside the lawn ({rows} rows × {cols} cols).'**
  String warningObjectsOutsideArea(int rows, int cols);

  /// No description provided for @izombieModeTitle.
  ///
  /// In en, this message translates to:
  /// **'I, Zombie Mode'**
  String get izombieModeTitle;

  /// No description provided for @izombieModeSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Switches to zombie placement gameplay. Seed selection will be locked.'**
  String get izombieModeSubtitle;

  /// No description provided for @reverseZombieFactionTitle.
  ///
  /// In en, this message translates to:
  /// **'Invert Zombie Faction'**
  String get reverseZombieFactionTitle;

  /// No description provided for @reverseZombieFactionSubtitle.
  ///
  /// In en, this message translates to:
  /// **'When enabled, placed zombies belong to the plant faction and can be used in \"Zombie Wars\" (ZvZ) gameplay.'**
  String get reverseZombieFactionSubtitle;

  /// No description provided for @initialWeight.
  ///
  /// In en, this message translates to:
  /// **'Initial weight'**
  String get initialWeight;

  /// No description provided for @plantLevelLabel.
  ///
  /// In en, this message translates to:
  /// **'Plant level'**
  String get plantLevelLabel;

  /// No description provided for @missingIntroModule.
  ///
  /// In en, this message translates to:
  /// **'Missing Intro Module'**
  String get missingIntroModule;

  /// No description provided for @missingIntroModuleHint.
  ///
  /// In en, this message translates to:
  /// **'Level is missing Zomboss Mech Intro module (ZombossBattleIntroProperties). The level may not function correctly. Please add the module and reselect the ZombossMech.'**
  String get missingIntroModuleHint;

  /// No description provided for @zombossMechType.
  ///
  /// In en, this message translates to:
  /// **'Zomboss Mech type'**
  String get zombossMechType;

  /// No description provided for @zombossMechSelection.
  ///
  /// In en, this message translates to:
  /// **'Zomboss mech selection'**
  String get zombossMechSelection;

  /// No description provided for @zombossMechBaseHint.
  ///
  /// In en, this message translates to:
  /// **'Zombots built and piloted by Dr. Zomboss himself, commonly encountered as the ultimate challenge of a world or game mode. Changing the base mech will also change the available variations below.'**
  String get zombossMechBaseHint;

  /// No description provided for @zombossMechSelectBaseTitle.
  ///
  /// In en, this message translates to:
  /// **'Select base Zomboss mech'**
  String get zombossMechSelectBaseTitle;

  /// No description provided for @zombossMechUsedProperties.
  ///
  /// In en, this message translates to:
  /// **'Used properties'**
  String get zombossMechUsedProperties;

  /// No description provided for @zombossMechVariationLabel.
  ///
  /// In en, this message translates to:
  /// **'Variation'**
  String get zombossMechVariationLabel;

  /// No description provided for @zombossMechVariationHint.
  ///
  /// In en, this message translates to:
  /// **'The specific mech type used in the level (ZombossMechType). Available options depend on the base mech selected above; changing the type will also update the mech\'s number of phases and spawn position accordingly.'**
  String get zombossMechVariationHint;

  /// No description provided for @zombossBattleSelection.
  ///
  /// In en, this message translates to:
  /// **'Zomboss selection'**
  String get zombossBattleSelection;

  /// No description provided for @zombossBattleSelectBaseTitle.
  ///
  /// In en, this message translates to:
  /// **'Select base Zomboss'**
  String get zombossBattleSelectBaseTitle;

  /// No description provided for @zombossBattleLeaveUndergroundTitle.
  ///
  /// In en, this message translates to:
  /// **'Switch base Zomboss'**
  String get zombossBattleLeaveUndergroundTitle;

  /// No description provided for @zombossBattleLeaveUndergroundBody.
  ///
  /// In en, this message translates to:
  /// **'You are about to switch from {zombossName} to another base Zomboss. The Finisher Countdown module will be removed from the level automatically. Remove the Underground Palace Pathways module as well?'**
  String zombossBattleLeaveUndergroundBody(String zombossName);

  /// No description provided for @zombossBattleKeepTunnelDefend.
  ///
  /// In en, this message translates to:
  /// **'Keep pathways'**
  String get zombossBattleKeepTunnelDefend;

  /// No description provided for @zombossBattleRemoveTunnelDefend.
  ///
  /// In en, this message translates to:
  /// **'Remove pathways too'**
  String get zombossBattleRemoveTunnelDefend;

  /// No description provided for @zombossBattleBaseHint.
  ///
  /// In en, this message translates to:
  /// **'Zombie bosses who hold sway in a world or realm that Dr. Zomboss has yet to visit, with phase and spawn mechanics similar to those of Zomboss mechs. Changing the base Zomboss will also change its corresponding resource group.'**
  String get zombossBattleBaseHint;

  /// No description provided for @zombossBattleVariationLabel.
  ///
  /// In en, this message translates to:
  /// **'Variation'**
  String get zombossBattleVariationLabel;

  /// No description provided for @zombossBattleVariationHint.
  ///
  /// In en, this message translates to:
  /// **'The specific Zomboss type used in the level (ZombossTypeName). Available options depend on the base Zomboss selected above.'**
  String get zombossBattleVariationHint;

  /// No description provided for @zombossBattleStartingSunLabel.
  ///
  /// In en, this message translates to:
  /// **'Starting Sun (StartingSun)'**
  String get zombossBattleStartingSunLabel;

  /// No description provided for @zombossBattleStartingSunHint.
  ///
  /// In en, this message translates to:
  /// **'The amount of sun available when entering the level.'**
  String get zombossBattleStartingSunHint;

  /// No description provided for @zombossBattleStartingPlantfoodLabel.
  ///
  /// In en, this message translates to:
  /// **'Starting Plant Food (StartingPlantfood)'**
  String get zombossBattleStartingPlantfoodLabel;

  /// No description provided for @zombossBattleStartingPlantfoodHint.
  ///
  /// In en, this message translates to:
  /// **'The amount of Plant Food available when entering the level.'**
  String get zombossBattleStartingPlantfoodHint;

  /// No description provided for @zombossBattleInitialGridColLabel.
  ///
  /// In en, this message translates to:
  /// **'Starting Column (ZombossInitialGridCol)'**
  String get zombossBattleInitialGridColLabel;

  /// No description provided for @zombossBattleInitialGridColHint.
  ///
  /// In en, this message translates to:
  /// **'Sets which column the Zomboss initially appears in.'**
  String get zombossBattleInitialGridColHint;

  /// No description provided for @zombossBattleInitialGridRowLabel.
  ///
  /// In en, this message translates to:
  /// **'Starting Row (ZombossInitialGridRow)'**
  String get zombossBattleInitialGridRowLabel;

  /// No description provided for @zombossBattleInitialGridRowHint.
  ///
  /// In en, this message translates to:
  /// **'Sets which row the Zomboss initially appears in.'**
  String get zombossBattleInitialGridRowHint;

  /// No description provided for @zombossBattleSkipPlantingLabel.
  ///
  /// In en, this message translates to:
  /// **'Skip Setup Phase (SkipPlanting)'**
  String get zombossBattleSkipPlantingLabel;

  /// No description provided for @zombossBattleSkipPlantingHint.
  ///
  /// In en, this message translates to:
  /// **'When enabled, the preparation phase used in Last Stand will not appear before the Zomboss battle.'**
  String get zombossBattleSkipPlantingHint;

  /// No description provided for @parameters.
  ///
  /// In en, this message translates to:
  /// **'Parameters'**
  String get parameters;

  /// No description provided for @reservedColumnCount.
  ///
  /// In en, this message translates to:
  /// **'Reserved Columns (ReservedColumnCount)'**
  String get reservedColumnCount;

  /// No description provided for @reservedColumnCountHint.
  ///
  /// In en, this message translates to:
  /// **'Number of columns reserved on the right where planting is disabled. Typically 2 or more columns are reserved.'**
  String get reservedColumnCountHint;

  /// No description provided for @reservedColumnPreview.
  ///
  /// In en, this message translates to:
  /// **'Reserved column preview'**
  String get reservedColumnPreview;

  /// No description provided for @protectedList.
  ///
  /// In en, this message translates to:
  /// **'Protected Targets'**
  String get protectedList;

  /// No description provided for @plantLevelsFollowGlobal.
  ///
  /// In en, this message translates to:
  /// **'Plants in this module follow their respective levels from the player’s account. You can standardize their levels using the Tier Definition module.'**
  String get plantLevelsFollowGlobal;

  /// No description provided for @protectPlantsOverview.
  ///
  /// In en, this message translates to:
  /// **'Defines plants that must be protected. The level fails if any of them are eaten or destroyed.'**
  String get protectPlantsOverview;

  /// No description provided for @protectPlantsAutoCount.
  ///
  /// In en, this message translates to:
  /// **'The required count updates automatically based on the number of plants added.'**
  String get protectPlantsAutoCount;

  /// No description provided for @positionsCount.
  ///
  /// In en, this message translates to:
  /// **'Positions: {count}'**
  String positionsCount(int count);

  /// No description provided for @totalItemsCount.
  ///
  /// In en, this message translates to:
  /// **'Total items to be spawned: {count}'**
  String totalItemsCount(int count);

  /// No description provided for @itemCountExceedsPositionsWarning.
  ///
  /// In en, this message translates to:
  /// **'Warning: Total grid items exceed available positions. Some grid items will not spawn!'**
  String get itemCountExceedsPositionsWarning;

  /// No description provided for @gravestoneBlockedInfo.
  ///
  /// In en, this message translates to:
  /// **'Grid items like tombstones cannot spawn if blocked by plants. Use other methods to force spawn them, such as the Potion Drop event.'**
  String get gravestoneBlockedInfo;

  /// No description provided for @enterConditionValue.
  ///
  /// In en, this message translates to:
  /// **'Enter condition value'**
  String get enterConditionValue;

  /// No description provided for @customInputHint.
  ///
  /// In en, this message translates to:
  /// **'Custom input must be accurate'**
  String get customInputHint;

  /// No description provided for @presetConditions.
  ///
  /// In en, this message translates to:
  /// **'Preset conditions'**
  String get presetConditions;

  /// No description provided for @selectFromPresetHint.
  ///
  /// In en, this message translates to:
  /// **'Select from preset condition list'**
  String get selectFromPresetHint;

  /// No description provided for @potionTypes.
  ///
  /// In en, this message translates to:
  /// **'Potion Types (PotionTypes)'**
  String get potionTypes;

  /// No description provided for @noPotionTypes.
  ///
  /// In en, this message translates to:
  /// **'No potion types configured. Add a potion type to continue.'**
  String get noPotionTypes;

  /// No description provided for @conveyorCardPool.
  ///
  /// In en, this message translates to:
  /// **'Conveyor Pool'**
  String get conveyorCardPool;

  /// No description provided for @maxLimits.
  ///
  /// In en, this message translates to:
  /// **'Max limits'**
  String get maxLimits;

  /// No description provided for @maxCountThreshold.
  ///
  /// In en, this message translates to:
  /// **'Max count threshold'**
  String get maxCountThreshold;

  /// No description provided for @weightFactor.
  ///
  /// In en, this message translates to:
  /// **'Post-threshold weight multiplier'**
  String get weightFactor;

  /// No description provided for @minLimits.
  ///
  /// In en, this message translates to:
  /// **'Min limits'**
  String get minLimits;

  /// No description provided for @minCountThreshold.
  ///
  /// In en, this message translates to:
  /// **'Min count threshold'**
  String get minCountThreshold;

  /// No description provided for @followAccountLevel.
  ///
  /// In en, this message translates to:
  /// **'Level 0 plants use their corresponding tier from the player\'s account.'**
  String get followAccountLevel;

  /// No description provided for @enablePointSpawning.
  ///
  /// In en, this message translates to:
  /// **'Enable Point-Based Spawning'**
  String get enablePointSpawning;

  /// No description provided for @pointSpawningEnabledDesc.
  ///
  /// In en, this message translates to:
  /// **'Enabled (uses points to spawn extra zombies)'**
  String get pointSpawningEnabledDesc;

  /// No description provided for @pointSpawningDisabledDesc.
  ///
  /// In en, this message translates to:
  /// **'Disabled (event-based spawning only)'**
  String get pointSpawningDisabledDesc;

  /// No description provided for @pointSettings.
  ///
  /// In en, this message translates to:
  /// **'Point settings'**
  String get pointSettings;

  /// No description provided for @startingWave.
  ///
  /// In en, this message translates to:
  /// **'Starting wave'**
  String get startingWave;

  /// No description provided for @startingPoints.
  ///
  /// In en, this message translates to:
  /// **'Starting points'**
  String get startingPoints;

  /// No description provided for @pointIncrement.
  ///
  /// In en, this message translates to:
  /// **'Point increase per wave'**
  String get pointIncrement;

  /// No description provided for @zombiePool.
  ///
  /// In en, this message translates to:
  /// **'Zombie pool'**
  String get zombiePool;

  /// No description provided for @protectGridItems.
  ///
  /// In en, this message translates to:
  /// **'Event: Save Our Items'**
  String get protectGridItems;

  /// No description provided for @waveManagerHelpOverview.
  ///
  /// In en, this message translates to:
  /// **'Wave Manager defines the wave event container. Wave editing is only available after adding this module.'**
  String get waveManagerHelpOverview;

  /// No description provided for @waveManagerHelpPoints.
  ///
  /// In en, this message translates to:
  /// **'Point-based spawning generates additional zombies during valid waves based on point cost.\nNormal waves have a cap of 60,000 points, while flag waves use a 2.5× multiplier.\nWhen points are positive, zombies are selected from the zombie pool. Expected spawn values for each zombie can be viewed in the wave event container.\nWhen points are negative, zombies with equivalent point value are removed from natural spawns.\nDo not include Elite Zombies, Yetis, or custom zombies in the point-based spawning pool.'**
  String get waveManagerHelpPoints;

  /// No description provided for @pointsSection.
  ///
  /// In en, this message translates to:
  /// **'Points'**
  String get pointsSection;

  /// No description provided for @globalPlantLevels.
  ///
  /// In en, this message translates to:
  /// **'Global plant levels'**
  String get globalPlantLevels;

  /// No description provided for @globalPlantLevelsOverview.
  ///
  /// In en, this message translates to:
  /// **'Defines plant levels globally within the level. This setting overrides seed packet levels and allows individual customization for specific plants.'**
  String get globalPlantLevelsOverview;

  /// No description provided for @globalPlantLevelsScope.
  ///
  /// In en, this message translates to:
  /// **'Applies to all instances of the plant used in the level, including endangered plants and packet drops.'**
  String get globalPlantLevelsScope;

  /// No description provided for @noWaveManagerPropsFound.
  ///
  /// In en, this message translates to:
  /// **'Wave Manager module (WaveManagerProperties) not found.'**
  String get noWaveManagerPropsFound;

  /// No description provided for @itemsSortedByRow.
  ///
  /// In en, this message translates to:
  /// **'Item(s) in selected tile'**
  String get itemsSortedByRow;

  /// No description provided for @stormEvent.
  ///
  /// In en, this message translates to:
  /// **'Storm Raid'**
  String get stormEvent;

  /// No description provided for @zombieLevelsBody.
  ///
  /// In en, this message translates to:
  /// **'Zombie level and row cannot be set independently within storms. Manually editing zombie levels has no effect; zombie levels follow the lawn’s level sequence by default.'**
  String get zombieLevelsBody;

  /// No description provided for @batchLevel.
  ///
  /// In en, this message translates to:
  /// **'Batch level'**
  String get batchLevel;

  /// No description provided for @start.
  ///
  /// In en, this message translates to:
  /// **'Start'**
  String get start;

  /// No description provided for @end.
  ///
  /// In en, this message translates to:
  /// **'End'**
  String get end;

  /// No description provided for @backgroundMusicLevelJam.
  ///
  /// In en, this message translates to:
  /// **'Neon Mixtape Tour music switch (LevelJam)'**
  String get backgroundMusicLevelJam;

  /// No description provided for @onlyAppliesRockEra.
  ///
  /// In en, this message translates to:
  /// **'Switches the background music when triggered. Only applies to Neon Mixtape Tour levels.'**
  String get onlyAppliesRockEra;

  /// No description provided for @appliesToAllNonElite.
  ///
  /// In en, this message translates to:
  /// **'Sets all zombies in this wave to the specified level (elite zombies are unaffected and retain their default level).'**
  String get appliesToAllNonElite;

  /// No description provided for @dropConfigPlants.
  ///
  /// In en, this message translates to:
  /// **'Drop configuration (seed packet)'**
  String get dropConfigPlants;

  /// No description provided for @dropConfigPlantFood.
  ///
  /// In en, this message translates to:
  /// **'Drop configuration (Plant Food)'**
  String get dropConfigPlantFood;

  /// No description provided for @waveDropConfigTitle.
  ///
  /// In en, this message translates to:
  /// **'Drop configuration'**
  String get waveDropConfigTitle;

  /// No description provided for @waveDropPlantSelectionLabel.
  ///
  /// In en, this message translates to:
  /// **'Specified seed packet drops (SpawnPlantName)'**
  String get waveDropPlantSelectionLabel;

  /// No description provided for @waveDropTotalLabel.
  ///
  /// In en, this message translates to:
  /// **'Total drops (AdditionalPlantfood)'**
  String get waveDropTotalLabel;

  /// No description provided for @waveDropAddZombiesFirst.
  ///
  /// In en, this message translates to:
  /// **'Add zombies to this wave before configuring drops.'**
  String get waveDropAddZombiesFirst;

  /// No description provided for @waveDropIncreaseTotalBeforePlants.
  ///
  /// In en, this message translates to:
  /// **'Increase total drops before adding seed packets.'**
  String get waveDropIncreaseTotalBeforePlants;

  /// No description provided for @waveDropPlantFoodOnlyCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 Plant Food} other{{count} Plant Foods}}'**
  String waveDropPlantFoodOnlyCount(int count);

  /// No description provided for @waveDropPlantsCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 seed packet} other{{count} seed packets}}'**
  String waveDropPlantsCount(int count);

  /// No description provided for @description.
  ///
  /// In en, this message translates to:
  /// **'Level description'**
  String get description;

  /// No description provided for @descriptiveName.
  ///
  /// In en, this message translates to:
  /// **'Descriptive Name'**
  String get descriptiveName;

  /// No description provided for @count.
  ///
  /// In en, this message translates to:
  /// **'Count'**
  String get count;

  /// No description provided for @targetDistance.
  ///
  /// In en, this message translates to:
  /// **'Flowerbed Distance (TargetDistance)'**
  String get targetDistance;

  /// No description provided for @starChallengeTargetDistanceHint.
  ///
  /// In en, this message translates to:
  /// **'The value is the number of columns from the left edge; larger values are farther from the house. Decimals are supported.'**
  String get starChallengeTargetDistanceHint;

  /// No description provided for @targetSun.
  ///
  /// In en, this message translates to:
  /// **'Target Sun'**
  String get targetSun;

  /// No description provided for @maximumSun.
  ///
  /// In en, this message translates to:
  /// **'Sun Cap (MaximumSun)'**
  String get maximumSun;

  /// No description provided for @holdoutSeconds.
  ///
  /// In en, this message translates to:
  /// **'Duration (HoldoutSeconds)'**
  String get holdoutSeconds;

  /// No description provided for @zombiesToKill.
  ///
  /// In en, this message translates to:
  /// **'Zombies to Kill (ZombiesToKill)'**
  String get zombiesToKill;

  /// No description provided for @timeSeconds.
  ///
  /// In en, this message translates to:
  /// **'Time Limit (seconds)'**
  String get timeSeconds;

  /// No description provided for @speedModifier.
  ///
  /// In en, this message translates to:
  /// **'Speed Multiplier (SpeedModifier)'**
  String get speedModifier;

  /// No description provided for @starChallengeSpeedModifierHint.
  ///
  /// In en, this message translates to:
  /// **'Entering 0.5 increases zombie movement speed by 50%.'**
  String get starChallengeSpeedModifierHint;

  /// No description provided for @sunModifier.
  ///
  /// In en, this message translates to:
  /// **'Sun Reduction (SunModifier)'**
  String get sunModifier;

  /// No description provided for @starChallengeSunModifierHint.
  ///
  /// In en, this message translates to:
  /// **'Entering 0.2 reduces Sun gained by 20%.'**
  String get starChallengeSunModifierHint;

  /// No description provided for @starChallengeChineseUnsupportedHint.
  ///
  /// In en, this message translates to:
  /// **'Chinese characters are not supported.'**
  String get starChallengeChineseUnsupportedHint;

  /// No description provided for @maximumPlantsLost.
  ///
  /// In en, this message translates to:
  /// **'Maximum Plants Lost'**
  String get maximumPlantsLost;

  /// No description provided for @maximumPlants.
  ///
  /// In en, this message translates to:
  /// **'Maximum Plants on the Lawn'**
  String get maximumPlants;

  /// No description provided for @targetScore.
  ///
  /// In en, this message translates to:
  /// **'Target Score'**
  String get targetScore;

  /// No description provided for @plantBombRadius.
  ///
  /// In en, this message translates to:
  /// **'Plant explosion radius'**
  String get plantBombRadius;

  /// No description provided for @plantType.
  ///
  /// In en, this message translates to:
  /// **'Plant Type'**
  String get plantType;

  /// No description provided for @gridX.
  ///
  /// In en, this message translates to:
  /// **'Grid X'**
  String get gridX;

  /// No description provided for @gridY.
  ///
  /// In en, this message translates to:
  /// **'Grid Y'**
  String get gridY;

  /// No description provided for @noCardsYetAddPlants.
  ///
  /// In en, this message translates to:
  /// **'No seed packets yet. Add plants or tool packets.'**
  String get noCardsYetAddPlants;

  /// No description provided for @mustProtectCountAll.
  ///
  /// In en, this message translates to:
  /// **'Required to Protect (0 = protect all)'**
  String get mustProtectCountAll;

  /// No description provided for @gridItemType.
  ///
  /// In en, this message translates to:
  /// **'Grid item type'**
  String get gridItemType;

  /// No description provided for @zombieBombRadius.
  ///
  /// In en, this message translates to:
  /// **'Zombie explosion radius'**
  String get zombieBombRadius;

  /// No description provided for @plantDamage.
  ///
  /// In en, this message translates to:
  /// **'Damage to plants'**
  String get plantDamage;

  /// No description provided for @zombieDamage.
  ///
  /// In en, this message translates to:
  /// **'Damage to zombies'**
  String get zombieDamage;

  /// No description provided for @initialPotionCount.
  ///
  /// In en, this message translates to:
  /// **'Initial count (InitialPotionCount)'**
  String get initialPotionCount;

  /// No description provided for @operationTimePerGrid.
  ///
  /// In en, this message translates to:
  /// **'Transfer time (seconds per tile)'**
  String get operationTimePerGrid;

  /// No description provided for @levelLabel.
  ///
  /// In en, this message translates to:
  /// **'Level: '**
  String get levelLabel;

  /// No description provided for @fairyFogType.
  ///
  /// In en, this message translates to:
  /// **'Fog level (FogType)'**
  String get fairyFogType;

  /// No description provided for @fairyFogLevel.
  ///
  /// In en, this message translates to:
  /// **'Level {level}'**
  String fairyFogLevel(int level);

  /// No description provided for @fairyFogMovingTime.
  ///
  /// In en, this message translates to:
  /// **'Moving time (MovingTime; seconds)'**
  String get fairyFogMovingTime;

  /// No description provided for @fairyFogRangeX.
  ///
  /// In en, this message translates to:
  /// **'Starting column (mX; 0-based)'**
  String get fairyFogRangeX;

  /// No description provided for @fairyFogRangeY.
  ///
  /// In en, this message translates to:
  /// **'Starting row (mY; 0-based)'**
  String get fairyFogRangeY;

  /// No description provided for @fairyFogRangeWidth.
  ///
  /// In en, this message translates to:
  /// **'Width (mWidth; tiles)'**
  String get fairyFogRangeWidth;

  /// No description provided for @fairyFogRangeHeight.
  ///
  /// In en, this message translates to:
  /// **'Height (mHeight; tiles)'**
  String get fairyFogRangeHeight;

  /// No description provided for @fairyWindParameters.
  ///
  /// In en, this message translates to:
  /// **'Wind parameters'**
  String get fairyWindParameters;

  /// No description provided for @fairyWindDuration.
  ///
  /// In en, this message translates to:
  /// **'Duration (Duration; seconds)'**
  String get fairyWindDuration;

  /// No description provided for @modifyConveyorMissingModule.
  ///
  /// In en, this message translates to:
  /// **'Conveyor Belt module wasn\'t detected in the level, so this event may not take effect.'**
  String get modifyConveyorMissingModule;

  /// No description provided for @renaiWavePreviewEmpty.
  ///
  /// In en, this message translates to:
  /// **'No statue or marble mound data is configured in the module'**
  String get renaiWavePreviewEmpty;

  /// No description provided for @decompressZlib.
  ///
  /// In en, this message translates to:
  /// **'Decompress ZLib'**
  String get decompressZlib;

  /// No description provided for @compressWithZlib.
  ///
  /// In en, this message translates to:
  /// **'Compress with ZLib'**
  String get compressWithZlib;

  /// No description provided for @seedRainUnknownItem.
  ///
  /// In en, this message translates to:
  /// **'Unknown item'**
  String get seedRainUnknownItem;

  /// No description provided for @mistParameters.
  ///
  /// In en, this message translates to:
  /// **'Fog parameters'**
  String get mistParameters;

  /// No description provided for @increasePerSun.
  ///
  /// In en, this message translates to:
  /// **'Increase per sun (SunCountdownIncreasePerSun)'**
  String get increasePerSun;

  /// No description provided for @inflationParams.
  ///
  /// In en, this message translates to:
  /// **'Inflation parameters'**
  String get inflationParams;

  /// No description provided for @baseCostIncreaseLabel.
  ///
  /// In en, this message translates to:
  /// **'Cost increase per planting (BaseCostIncreased)'**
  String get baseCostIncreaseLabel;

  /// No description provided for @maxIncreaseCountLabel.
  ///
  /// In en, this message translates to:
  /// **'Max Increase Count (MaxIncreasedCount)'**
  String get maxIncreaseCountLabel;

  /// No description provided for @inflationMaxIncreaseCountWarning.
  ///
  /// In en, this message translates to:
  /// **'Due to an issue with the module itself, changing the maximum increase count currently has no effect. The game only reads the default value of 10.'**
  String get inflationMaxIncreaseCountWarning;

  /// No description provided for @inflationHelpTitle.
  ///
  /// In en, this message translates to:
  /// **'Inflation module'**
  String get inflationHelpTitle;

  /// No description provided for @inflationHelpOverview.
  ///
  /// In en, this message translates to:
  /// **'Each time a plant is planted, its sun cost increases, similar to how upgrade plants work in Survival: Endless in the original game.'**
  String get inflationHelpOverview;

  /// No description provided for @inflationHelpParametersTitle.
  ///
  /// In en, this message translates to:
  /// **'Parameter description'**
  String get inflationHelpParametersTitle;

  /// No description provided for @inflationHelpParametersBody.
  ///
  /// In en, this message translates to:
  /// **'Configure the amount of sun cost added after each planting and the maximum number of price increases.'**
  String get inflationHelpParametersBody;

  /// No description provided for @selectGroup.
  ///
  /// In en, this message translates to:
  /// **'Select group'**
  String get selectGroup;

  /// No description provided for @sunBombHelpOverview.
  ///
  /// In en, this message translates to:
  /// **'Overview'**
  String get sunBombHelpOverview;

  /// No description provided for @sunBombHelpBody.
  ///
  /// In en, this message translates to:
  /// **'Required for the Far Future brain buster \"Sun Bomb\". When enabled, falling sun will turn into purple, detonatable Sun Bombs. Damage dealt by Sun Bombs can be configured separately for different factions.'**
  String get sunBombHelpBody;

  /// No description provided for @bombProperties.
  ///
  /// In en, this message translates to:
  /// **'Powder Keg module'**
  String get bombProperties;

  /// No description provided for @bombPropertiesHelpBody.
  ///
  /// In en, this message translates to:
  /// **'Required for configuring the Kongfu World brain buster \"Powder Keg\". When enabled, Powder Kegs will appear at lawn mower positions and spawn a fuse that can be ignited. If a flame travels along the fuse and reaches the Powder Keg, it will explode, destroying plants within a 3×3 area centered on itself.'**
  String get bombPropertiesHelpBody;

  /// No description provided for @bombPropertiesHelpFuse.
  ///
  /// In en, this message translates to:
  /// **'Fuse lengths'**
  String get bombPropertiesHelpFuse;

  /// No description provided for @bombPropertiesHelpFuseBody.
  ///
  /// In en, this message translates to:
  /// **'Fuse length is configured per row, starting from row 1 (top to bottom). Each row corresponds to a value in the array, representing how many tiles the fuse extends to the right. Standard lawns have 5 rows, while Underwater World lawns have 6. The array length will automatically adjust based on the current lawn when opening this panel.'**
  String get bombPropertiesHelpFuseBody;

  /// No description provided for @bombPropertiesFlameSpeed.
  ///
  /// In en, this message translates to:
  /// **'Fuse Burn Speed (FlameSpeed)'**
  String get bombPropertiesFlameSpeed;

  /// No description provided for @bombPropertiesFuseLengths.
  ///
  /// In en, this message translates to:
  /// **'Fuse Lengths (FuseLengths)'**
  String get bombPropertiesFuseLengths;

  /// No description provided for @bombPropertiesFuseLengthsHint.
  ///
  /// In en, this message translates to:
  /// **'Set how many tiles the fuse extends to the right for each row (one value per row)'**
  String get bombPropertiesFuseLengthsHint;

  /// No description provided for @damage.
  ///
  /// In en, this message translates to:
  /// **'Explosion Damage'**
  String get damage;

  /// No description provided for @explosionRadius.
  ///
  /// In en, this message translates to:
  /// **'Explosion Radius'**
  String get explosionRadius;

  /// No description provided for @plantRadius.
  ///
  /// In en, this message translates to:
  /// **'Plant explosion radius'**
  String get plantRadius;

  /// No description provided for @zombieRadius.
  ///
  /// In en, this message translates to:
  /// **'Zombie explosion radius'**
  String get zombieRadius;

  /// No description provided for @radiusPixelsHint.
  ///
  /// In en, this message translates to:
  /// **'Explosion radius is measured in pixels (1 tile ≈ 60 pixels).'**
  String get radiusPixelsHint;

  /// No description provided for @enterMaxSunHint.
  ///
  /// In en, this message translates to:
  /// **'Enter the level’s maximum sun cap (e.g. 9900)'**
  String get enterMaxSunHint;

  /// No description provided for @enterStartingPlantfoodHint.
  ///
  /// In en, this message translates to:
  /// **'Enter the starting Plant Food amount (0 or more)'**
  String get enterStartingPlantfoodHint;

  /// No description provided for @threshold.
  ///
  /// In en, this message translates to:
  /// **'Threshold'**
  String get threshold;

  /// No description provided for @delay.
  ///
  /// In en, this message translates to:
  /// **'Delay'**
  String get delay;

  /// No description provided for @seedBankLetsPlayersChoose.
  ///
  /// In en, this message translates to:
  /// **'Seed Bank lets players choose from available plants. In Creative Courtyard, it supports setting a global tier and enables access to all plants.'**
  String get seedBankLetsPlayersChoose;

  /// No description provided for @iZombieModePresetHint.
  ///
  /// In en, this message translates to:
  /// **'When I, Zombie Mode is enabled, available zombies must be preset. Selection mode will be forced to Preset. If both plant and zombie seed packets are used, they must be locked to the same level.'**
  String get iZombieModePresetHint;

  /// No description provided for @invalidIdsHint.
  ///
  /// In en, this message translates to:
  /// **'Invalid IDs will appear as empty slots in the Seed Bank. In I, Zombie Mode, plant IDs are invalid, and vice versa. This can be used to create two Seed Banks in one level and combine both modes. Make sure the Zombie Seed Bank is placed first.'**
  String get invalidIdsHint;

  /// No description provided for @seedBankWhiteAndBlacklistTitle.
  ///
  /// In en, this message translates to:
  /// **'Whitelist and blacklist'**
  String get seedBankWhiteAndBlacklistTitle;

  /// No description provided for @seedBankIZombieHelpTitle.
  ///
  /// In en, this message translates to:
  /// **'I, Zombie mode'**
  String get seedBankIZombieHelpTitle;

  /// No description provided for @seedBankSlotOccupancyTitle.
  ///
  /// In en, this message translates to:
  /// **'Slot occupancy'**
  String get seedBankSlotOccupancyTitle;

  /// No description provided for @seedBankAdvancedGameplayTitle.
  ///
  /// In en, this message translates to:
  /// **'Advanced gameplay'**
  String get seedBankAdvancedGameplayTitle;

  /// No description provided for @seedBankAdvancedGameplayBody.
  ///
  /// In en, this message translates to:
  /// **'When selection mode is Preset, placing the Seed Bank before the Conveyor Belt makes conveyor plants cost sun, while placing it after allows preset plants to be planted without sun cost.'**
  String get seedBankAdvancedGameplayBody;

  /// No description provided for @basicRules.
  ///
  /// In en, this message translates to:
  /// **'Basic Rules'**
  String get basicRules;

  /// No description provided for @selectionMethod.
  ///
  /// In en, this message translates to:
  /// **'Selection Mode'**
  String get selectionMethod;

  /// No description provided for @emptyList.
  ///
  /// In en, this message translates to:
  /// **'The list is empty'**
  String get emptyList;

  /// No description provided for @plantsAvailableAtStart.
  ///
  /// In en, this message translates to:
  /// **'Plants pre-selected at the start'**
  String get plantsAvailableAtStart;

  /// No description provided for @presetPlantListReorderHint.
  ///
  /// In en, this message translates to:
  /// **'Long press the ⋮⋮ handle and drag to reorder'**
  String get presetPlantListReorderHint;

  /// No description provided for @presetPlantListReorderHintDesktop.
  ///
  /// In en, this message translates to:
  /// **'Drag the ⋮⋮ handle to reorder'**
  String get presetPlantListReorderHintDesktop;

  /// No description provided for @whiteListDescription.
  ///
  /// In en, this message translates to:
  /// **'Only these plants can be selected (no restriction if empty)'**
  String get whiteListDescription;

  /// No description provided for @blackListDescription.
  ///
  /// In en, this message translates to:
  /// **'These plants cannot be selected'**
  String get blackListDescription;

  /// No description provided for @availableZombiesDescription.
  ///
  /// In en, this message translates to:
  /// **'Zombies available for I, Zombie Mode'**
  String get availableZombiesDescription;

  /// No description provided for @izombieCardSlotsHint.
  ///
  /// In en, this message translates to:
  /// **'Only certain zombies have dedicate seed packets and sun costs in I, Zombie (IZ) Mode. These zombies can be found under the \"Other\" category in the zombie selection screen.'**
  String get izombieCardSlotsHint;

  /// No description provided for @seedBankPresetModeHint.
  ///
  /// In en, this message translates to:
  /// **'When Preset mode is enabled, the level starts immediately regardless of how many plants are pre-selected.'**
  String get seedBankPresetModeHint;

  /// No description provided for @seedBankPlantLevelLabel.
  ///
  /// In en, this message translates to:
  /// **'Plant level (0-5)'**
  String get seedBankPlantLevelLabel;

  /// No description provided for @seedBankSlotCountLabel.
  ///
  /// In en, this message translates to:
  /// **'Slot count (0-9)'**
  String get seedBankSlotCountLabel;

  /// No description provided for @seedBankCourtyardSlotsHint.
  ///
  /// In en, this message translates to:
  /// **'In Creative Courtyard, changes to the number of seed slots have no effect. Chooser mode is fixed at 8 slots.'**
  String get seedBankCourtyardSlotsHint;

  /// No description provided for @seedBankAddGridItemsTitle.
  ///
  /// In en, this message translates to:
  /// **'Add Grid Items'**
  String get seedBankAddGridItemsTitle;

  /// No description provided for @seedBankAddGridItemsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Add plantable grid items to the preset plant list. Duplicates are allowed.'**
  String get seedBankAddGridItemsSubtitle;

  /// No description provided for @seedBankGridItemCount.
  ///
  /// In en, this message translates to:
  /// **'The preset list already contains {count}'**
  String seedBankGridItemCount(int count);

  /// No description provided for @seedBankGridItemsPresetOnlySwitchWarning.
  ///
  /// In en, this message translates to:
  /// **'The \"Add Grid Items\" feature only works in Preset mode. Switching to Chooser mode will turn it off. Continue switching?'**
  String get seedBankGridItemsPresetOnlySwitchWarning;

  /// No description provided for @starChallengeSelectConditions.
  ///
  /// In en, this message translates to:
  /// **'Select conditions'**
  String get starChallengeSelectConditions;

  /// No description provided for @starChallengeEditConditions.
  ///
  /// In en, this message translates to:
  /// **'Edit conditions'**
  String get starChallengeEditConditions;

  /// No description provided for @selectToolCard.
  ///
  /// In en, this message translates to:
  /// **'Select tool packets'**
  String get selectToolCard;

  /// No description provided for @searchGridItems.
  ///
  /// In en, this message translates to:
  /// **'Search grid items'**
  String get searchGridItems;

  /// No description provided for @searchStatues.
  ///
  /// In en, this message translates to:
  /// **'Search renaissance statues or marble mounds'**
  String get searchStatues;

  /// No description provided for @noItems.
  ///
  /// In en, this message translates to:
  /// **'No items'**
  String get noItems;

  /// No description provided for @addedToFavorites.
  ///
  /// In en, this message translates to:
  /// **'Added to favorites'**
  String get addedToFavorites;

  /// No description provided for @removedFromFavorites.
  ///
  /// In en, this message translates to:
  /// **'Removed from favorites'**
  String get removedFromFavorites;

  /// No description provided for @selectedCountTapToSearch.
  ///
  /// In en, this message translates to:
  /// **'Selected {count}, tap to search'**
  String selectedCountTapToSearch(int count);

  /// No description provided for @noFavoritesLongPress.
  ///
  /// In en, this message translates to:
  /// **'No favorites. Long-press to favorite.'**
  String get noFavoritesLongPress;

  /// No description provided for @gridItemCategoryAll.
  ///
  /// In en, this message translates to:
  /// **'All Items'**
  String get gridItemCategoryAll;

  /// No description provided for @gridItemCategoryScene.
  ///
  /// In en, this message translates to:
  /// **'Scenery'**
  String get gridItemCategoryScene;

  /// No description provided for @gridItemCategoryTrap.
  ///
  /// In en, this message translates to:
  /// **'Interactive Traps'**
  String get gridItemCategoryTrap;

  /// No description provided for @gridItemCategorySpawnableObjects.
  ///
  /// In en, this message translates to:
  /// **'Spawnable Objects'**
  String get gridItemCategorySpawnableObjects;

  /// No description provided for @customLocalParams.
  ///
  /// In en, this message translates to:
  /// **'Custom local parameters'**
  String get customLocalParams;

  /// No description provided for @currentModeLocal.
  ///
  /// In en, this message translates to:
  /// **'Current: local (@CurrentLevel)'**
  String get currentModeLocal;

  /// No description provided for @currentModeSystem.
  ///
  /// In en, this message translates to:
  /// **'Current: system default (@LevelModules)'**
  String get currentModeSystem;

  /// No description provided for @paramAdjust.
  ///
  /// In en, this message translates to:
  /// **'Parameter adjustment'**
  String get paramAdjust;

  /// No description provided for @firstDropDelay.
  ///
  /// In en, this message translates to:
  /// **'Initial drop delay (InitialSunDropDelay; seconds)'**
  String get firstDropDelay;

  /// No description provided for @initialDropInterval.
  ///
  /// In en, this message translates to:
  /// **'Initial drop interval (SunCountdownBase; seconds)'**
  String get initialDropInterval;

  /// No description provided for @maxDropInterval.
  ///
  /// In en, this message translates to:
  /// **'Max drop interval (SunCountdownMax; seconds)'**
  String get maxDropInterval;

  /// No description provided for @intervalFloatRange.
  ///
  /// In en, this message translates to:
  /// **'Interval variation range (SunCountdownRange; seconds)'**
  String get intervalFloatRange;

  /// No description provided for @sunDropperHelpTitle.
  ///
  /// In en, this message translates to:
  /// **'Sun Dropper module'**
  String get sunDropperHelpTitle;

  /// No description provided for @sunDropperHelpIntro.
  ///
  /// In en, this message translates to:
  /// **'Configures falling sun in a level. For night lawns, this module is usually not needed.'**
  String get sunDropperHelpIntro;

  /// No description provided for @sunDropperHelpParams.
  ///
  /// In en, this message translates to:
  /// **'Parameter configuration'**
  String get sunDropperHelpParams;

  /// No description provided for @sunDropperHelpParamsBody.
  ///
  /// In en, this message translates to:
  /// **'By default, this module uses the game’s built-in values. You can enable custom settings to edit detailed parameters.'**
  String get sunDropperHelpParamsBody;

  /// No description provided for @noZombossMechFound.
  ///
  /// In en, this message translates to:
  /// **'No Zomboss Mech found'**
  String get noZombossMechFound;

  /// No description provided for @noZombossBattleFound.
  ///
  /// In en, this message translates to:
  /// **'No Zomboss definitions found'**
  String get noZombossBattleFound;

  /// No description provided for @searchChallengeNameOrCode.
  ///
  /// In en, this message translates to:
  /// **'Search by challenge name or codename'**
  String get searchChallengeNameOrCode;

  /// No description provided for @deleteChallengeTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete challenge?'**
  String get deleteChallengeTitle;

  /// No description provided for @deleteChallengeConfirmLocal.
  ///
  /// In en, this message translates to:
  /// **'Remove \"{name}\"? This will permanently delete the local challenge data.'**
  String deleteChallengeConfirmLocal(String name);

  /// No description provided for @deleteChallengeConfirmRef.
  ///
  /// In en, this message translates to:
  /// **'Remove reference to \"{name}\"? The challenge will remain in LevelModules.'**
  String deleteChallengeConfirmRef(String name);

  /// No description provided for @missingModulesRecommended.
  ///
  /// In en, this message translates to:
  /// **'The level might not function correctly. Recommended to add the following modules:'**
  String get missingModulesRecommended;

  /// No description provided for @recommendedTunnelDefendTitle.
  ///
  /// In en, this message translates to:
  /// **'Underground Palace Pathways module strongly recommended'**
  String get recommendedTunnelDefendTitle;

  /// No description provided for @recommendedTunnelDefendBody.
  ///
  /// In en, this message translates to:
  /// **'The tiles in Underground Palace Secret Realm lawns must be placed through the \"Underground Palace Pathways\" module. If this module is not added, the lawns may appear overly empty in-game.'**
  String get recommendedTunnelDefendBody;

  /// No description provided for @recommendedExpeditionTilesTitle.
  ///
  /// In en, this message translates to:
  /// **'Works with the \"Expedition Tiles\" module'**
  String get recommendedExpeditionTilesTitle;

  /// No description provided for @recommendedExpeditionTilesBody.
  ///
  /// In en, this message translates to:
  /// **'Add the \"Expedition Tiles\" module to work around the lawn\'s missing tiles and create an experience that more closely matches Expedition Gate.'**
  String get recommendedExpeditionTilesBody;

  /// No description provided for @selectedPosition.
  ///
  /// In en, this message translates to:
  /// **'Selected position'**
  String get selectedPosition;

  /// No description provided for @addItem.
  ///
  /// In en, this message translates to:
  /// **'Add item'**
  String get addItem;

  /// No description provided for @itemListRowFirst.
  ///
  /// In en, this message translates to:
  /// **'Item(s) in selected tile'**
  String get itemListRowFirst;

  /// No description provided for @railcartCowboy.
  ///
  /// In en, this message translates to:
  /// **'Wild West mine cart'**
  String get railcartCowboy;

  /// No description provided for @railcartFuture.
  ///
  /// In en, this message translates to:
  /// **'Far Future mine cart'**
  String get railcartFuture;

  /// No description provided for @railcartEgypt.
  ///
  /// In en, this message translates to:
  /// **'Ancient Egypt mine cart'**
  String get railcartEgypt;

  /// No description provided for @railcartPirate.
  ///
  /// In en, this message translates to:
  /// **'Pirate Seas mine cart'**
  String get railcartPirate;

  /// No description provided for @railcartWorldcup.
  ///
  /// In en, this message translates to:
  /// **'Ice Hockey mine cart'**
  String get railcartWorldcup;

  /// No description provided for @clearUnusedTitle.
  ///
  /// In en, this message translates to:
  /// **'Clear unused objects?'**
  String get clearUnusedTitle;

  /// No description provided for @clearUnusedMessage.
  ///
  /// In en, this message translates to:
  /// **'This will permanently delete all unused objects from the level file, including custom zombies, their properties, and any other unreferenced data. This action cannot be undone. Continue?'**
  String get clearUnusedMessage;

  /// No description provided for @clearUnusedNone.
  ///
  /// In en, this message translates to:
  /// **'No unused objects found.'**
  String get clearUnusedNone;

  /// No description provided for @clearUnusedDone.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{Removed 1 unused object.} other{Removed {count} unused objects.}}'**
  String clearUnusedDone(int count);

  /// No description provided for @lawnMowerTitle.
  ///
  /// In en, this message translates to:
  /// **'Lawn Mowers'**
  String get lawnMowerTitle;

  /// No description provided for @lawnMowerNotes.
  ///
  /// In en, this message translates to:
  /// **'Notes'**
  String get lawnMowerNotes;

  /// No description provided for @lawnMowerHelpOverview.
  ///
  /// In en, this message translates to:
  /// **'Controls the appearance of lawn mowers in a level. This module does not work when the Creative Courtyard module is enabled.'**
  String get lawnMowerHelpOverview;

  /// No description provided for @lawnMowerHelpNotes.
  ///
  /// In en, this message translates to:
  /// **'This module is typically referenced from LevelModules and does not require custom configuration within the level.'**
  String get lawnMowerHelpNotes;

  /// No description provided for @lawnMowerSelectType.
  ///
  /// In en, this message translates to:
  /// **'Select mower type'**
  String get lawnMowerSelectType;

  /// No description provided for @zombieRushTitle.
  ///
  /// In en, this message translates to:
  /// **'Level Timer module'**
  String get zombieRushTitle;

  /// No description provided for @zombieRushHelpOverview.
  ///
  /// In en, this message translates to:
  /// **'A countdown module from Zombie Elimination Initiative. The level ends and results are calculated when the timer reaches zero.'**
  String get zombieRushHelpOverview;

  /// No description provided for @zombieRushHelpNotes.
  ///
  /// In en, this message translates to:
  /// **'Notes'**
  String get zombieRushHelpNotes;

  /// No description provided for @zombieRushHelpIncompat.
  ///
  /// In en, this message translates to:
  /// **'Penny’s Pursuit timer module is incompatible with Creative Courtyard and may cause crashes. It is recommended to use the Zombie Elimination Initiative timer module instead.'**
  String get zombieRushHelpIncompat;

  /// No description provided for @zombieRushTimeSettings.
  ///
  /// In en, this message translates to:
  /// **'Time Settings'**
  String get zombieRushTimeSettings;

  /// No description provided for @levelCountdown.
  ///
  /// In en, this message translates to:
  /// **'Level countdown (seconds)'**
  String get levelCountdown;

  /// No description provided for @tunnelDefendTitle.
  ///
  /// In en, this message translates to:
  /// **'Underground Palace Pathway Settings'**
  String get tunnelDefendTitle;

  /// No description provided for @tunnelDefendHelpOverview.
  ///
  /// In en, this message translates to:
  /// **'Use this module to add pathways from the Underground Palace secret realm to the level. Certain zombies have their interactions with plants affected by pathways.'**
  String get tunnelDefendHelpOverview;

  /// No description provided for @tunnelDefendHelpUsage.
  ///
  /// In en, this message translates to:
  /// **'Usage'**
  String get tunnelDefendHelpUsage;

  /// No description provided for @tunnelDefendHelpUsageBody.
  ///
  /// In en, this message translates to:
  /// **'Select a pathway component from the list below, then click on the grid above to place it. Tapping an existing component of the same type removes it, while selecting a different component will replace it directly.'**
  String get tunnelDefendHelpUsageBody;

  /// No description provided for @tunnelDefendSelectComponent.
  ///
  /// In en, this message translates to:
  /// **'Select component'**
  String get tunnelDefendSelectComponent;

  /// No description provided for @tunnelDefendPlacedCount.
  ///
  /// In en, this message translates to:
  /// **'Placed components'**
  String get tunnelDefendPlacedCount;

  /// No description provided for @tunnelDefendClearAll.
  ///
  /// In en, this message translates to:
  /// **'Clear all'**
  String get tunnelDefendClearAll;

  /// No description provided for @tunnelDefendClearConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Clear all pathway components?'**
  String get tunnelDefendClearConfirmTitle;

  /// No description provided for @tunnelDefendClearConfirmMessage.
  ///
  /// In en, this message translates to:
  /// **'This will remove all placed pathway components from the lawn. This action cannot be undone.'**
  String get tunnelDefendClearConfirmMessage;

  /// No description provided for @tunnelDefendPathOutsideLawn.
  ///
  /// In en, this message translates to:
  /// **'Pathway components outside the lawn: '**
  String get tunnelDefendPathOutsideLawn;

  /// No description provided for @tunnelDefendDeleteOutside.
  ///
  /// In en, this message translates to:
  /// **'Remove pathway components outside the lawn'**
  String get tunnelDefendDeleteOutside;

  /// No description provided for @tunnelDefendDeleteOutsideConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Remove pathway components outside the lawn?'**
  String get tunnelDefendDeleteOutsideConfirmTitle;

  /// No description provided for @tunnelDefendDeleteOutsideConfirmMessage.
  ///
  /// In en, this message translates to:
  /// **'This will remove all pathway components outside the 5×9 lawn. This action cannot be undone.'**
  String get tunnelDefendDeleteOutsideConfirmMessage;

  /// No description provided for @tunnelDefendTileStylePreset.
  ///
  /// In en, this message translates to:
  /// **'Tile style preset'**
  String get tunnelDefendTileStylePreset;

  /// No description provided for @tunnelDefendTileStylePart1.
  ///
  /// In en, this message translates to:
  /// **'Underground Palace Ruins (Chapter 1)'**
  String get tunnelDefendTileStylePart1;

  /// No description provided for @tunnelDefendTileStylePart2.
  ///
  /// In en, this message translates to:
  /// **'Underground Palace Spirit Supression (Chapter 2)'**
  String get tunnelDefendTileStylePart2;

  /// No description provided for @tunnelDefendSequenceInterval.
  ///
  /// In en, this message translates to:
  /// **'Pathway Generation Interval (TunnelSequenceInterval, seconds)'**
  String get tunnelDefendSequenceInterval;

  /// No description provided for @tunnelDefendHelpSequenceInterval.
  ///
  /// In en, this message translates to:
  /// **'Pathway Generation Interval'**
  String get tunnelDefendHelpSequenceInterval;

  /// No description provided for @tunnelDefendHelpSequenceIntervalBody.
  ///
  /// In en, this message translates to:
  /// **'The interval between the appearance of each pathway components when Lord of the Underground Palace generates a pathway. Lower values make pathway components appear more quickly.'**
  String get tunnelDefendHelpSequenceIntervalBody;

  /// No description provided for @tunnelDefendHelpSodPromptBody.
  ///
  /// In en, this message translates to:
  /// **'The \"Sod Planting Prompt\" controls whether a \"Plant a Sod first\" prompt appears when planting on restricted tiles. Underground Palace Pathways module enables this prompt by default.'**
  String get tunnelDefendHelpSodPromptBody;

  /// No description provided for @sodPlantingPromptTitle.
  ///
  /// In en, this message translates to:
  /// **'Sod Planting Prompt'**
  String get sodPlantingPromptTitle;

  /// No description provided for @expeditionTilesSodPromptBody.
  ///
  /// In en, this message translates to:
  /// **'Whether to show a Sod requirement prompt when planting. Disabled by default.'**
  String get expeditionTilesSodPromptBody;

  /// No description provided for @tunnelDefendSodPromptBody.
  ///
  /// In en, this message translates to:
  /// **'Whether to show a Sod requirement prompt when planting. Enabled by default.'**
  String get tunnelDefendSodPromptBody;

  /// No description provided for @expeditionTilesPresetLayout.
  ///
  /// In en, this message translates to:
  /// **'Preset Layout'**
  String get expeditionTilesPresetLayout;

  /// No description provided for @expeditionTilesPresetFloor1.
  ///
  /// In en, this message translates to:
  /// **'Expedition Gate – Floor 1'**
  String get expeditionTilesPresetFloor1;

  /// No description provided for @expeditionTilesPresetFloor2.
  ///
  /// In en, this message translates to:
  /// **'Expedition Gate – Floor 2'**
  String get expeditionTilesPresetFloor2;

  /// No description provided for @expeditionTilesPresetFloor3.
  ///
  /// In en, this message translates to:
  /// **'Expedition Gate – Floor 3'**
  String get expeditionTilesPresetFloor3;

  /// No description provided for @customLayout.
  ///
  /// In en, this message translates to:
  /// **'Custom layout'**
  String get customLayout;

  /// No description provided for @switchAction.
  ///
  /// In en, this message translates to:
  /// **'Switch'**
  String get switchAction;

  /// No description provided for @expeditionTilesSwitchPresetTitle.
  ///
  /// In en, this message translates to:
  /// **'Switch preset layout'**
  String get expeditionTilesSwitchPresetTitle;

  /// No description provided for @expeditionTilesSwitchPresetMessage.
  ///
  /// In en, this message translates to:
  /// **'Switch to the preset layout? This will remove all placed non-plantable tiles from the lawn and cannot be undone.'**
  String get expeditionTilesSwitchPresetMessage;

  /// No description provided for @expeditionTilesSwitchPresetBetweenMessage.
  ///
  /// In en, this message translates to:
  /// **'Switch from \"{from}\" to \"{to}\"? '**
  String expeditionTilesSwitchPresetBetweenMessage(String from, String to);

  /// No description provided for @expeditionTilesUnderwaterMismatchWarning.
  ///
  /// In en, this message translates to:
  /// **'The current lawn uses an Underwater World appearance, which is incompatible with the Expedition Tiles module and will cause the level to crash.'**
  String get expeditionTilesUnderwaterMismatchWarning;

  /// No description provided for @expeditionTilesBlockedCount.
  ///
  /// In en, this message translates to:
  /// **'Non-plantable tiles'**
  String get expeditionTilesBlockedCount;

  /// No description provided for @expeditionTilesClearConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Clear all non-plantable tiles?'**
  String get expeditionTilesClearConfirmTitle;

  /// No description provided for @expeditionTilesClearConfirmMessage.
  ///
  /// In en, this message translates to:
  /// **'This will remove all placed non-plantable tiles from the lawn. This action cannot be undone.'**
  String get expeditionTilesClearConfirmMessage;

  /// No description provided for @expeditionTilesHelpTitle.
  ///
  /// In en, this message translates to:
  /// **'Expedition Tiles module'**
  String get expeditionTilesHelpTitle;

  /// No description provided for @expeditionTilesHelpOverview.
  ///
  /// In en, this message translates to:
  /// **'The Expedition Tiles module configures non-plantable areas on the Expedition Gate lawn. It uses the same tile data structure as Underground Palace Pathways and displays restricted areas with Expedition-specific tile art. Planting Sod on a non-plantable tile can restore that tile\'s planting function.'**
  String get expeditionTilesHelpOverview;

  /// No description provided for @expeditionTilesHelpEditing.
  ///
  /// In en, this message translates to:
  /// **'Tile Editing'**
  String get expeditionTilesHelpEditing;

  /// No description provided for @expeditionTilesHelpEditingBody.
  ///
  /// In en, this message translates to:
  /// **'Tap any tile on the lawn to add or remove a non-plantable tile. Non-plantable tiles cover the original floor and cannot be planted on in-game. Swirly tiles and blank tiles are both plantable areas; the Swirly tiles here only recreate the initial lawn layout used by this module.'**
  String get expeditionTilesHelpEditingBody;

  /// No description provided for @expeditionTilesHelpPresets.
  ///
  /// In en, this message translates to:
  /// **'Preset Layouts'**
  String get expeditionTilesHelpPresets;

  /// No description provided for @expeditionTilesHelpPresetsBody.
  ///
  /// In en, this message translates to:
  /// **'The editor includes the three official Expedition Gate layouts for Floor 1, Floor 2, and Floor 3. Switching presets replaces all placed non-plantable tiles and cannot be undone; after applying a preset, you can still adjust tiles manually.'**
  String get expeditionTilesHelpPresetsBody;

  /// No description provided for @expeditionTilesHelpSodPrompt.
  ///
  /// In en, this message translates to:
  /// **'Planting Prompt'**
  String get expeditionTilesHelpSodPrompt;

  /// No description provided for @expeditionTilesHelpSodPromptBody.
  ///
  /// In en, this message translates to:
  /// **'The \"Sod Planting Prompt\" controls whether a \"Plant a Sod first\" prompt appears when planting on restricted tiles. Expedition Tiles module disables this prompt by default.'**
  String get expeditionTilesHelpSodPromptBody;

  /// No description provided for @expeditionTilesHelpNotesBody.
  ///
  /// In en, this message translates to:
  /// **'Expedition Tiles is intended for 5-row lawns such as Expedition Gate. Do not use it with 6-row Underwater World appearances such as 20,000 Leagues Under the Sea or Atlantis, or the level will crash.'**
  String get expeditionTilesHelpNotesBody;

  /// No description provided for @tunnelExpeditionCompatibilityWarningTitle.
  ///
  /// In en, this message translates to:
  /// **'Module compatibility warning'**
  String get tunnelExpeditionCompatibilityWarningTitle;

  /// No description provided for @tunnelExpeditionCompatibilityWarningBody.
  ///
  /// In en, this message translates to:
  /// **'Using the \"Underground Palace Pathways\" module together with the \"Expedition Tiles\" module can cause tile textures to overlap and may affect the level\'s overall appearance. If you must use both, be extremely careful.'**
  String get tunnelExpeditionCompatibilityWarningBody;

  /// No description provided for @moduleTitle_ZombossFinalStageTimeLimitedChallengeProperties.
  ///
  /// In en, this message translates to:
  /// **'Finisher Countdown'**
  String get moduleTitle_ZombossFinalStageTimeLimitedChallengeProperties;

  /// No description provided for @moduleDesc_ZombossFinalStageTimeLimitedChallengeProperties.
  ///
  /// In en, this message translates to:
  /// **'Required module for the Lord of the Underground Palace Zomboss battle'**
  String get moduleDesc_ZombossFinalStageTimeLimitedChallengeProperties;

  /// No description provided for @finalStageTimeLimitedChallengeHelpTitle.
  ///
  /// In en, this message translates to:
  /// **'Finisher Countdown module'**
  String get finalStageTimeLimitedChallengeHelpTitle;

  /// No description provided for @finalStageTimeLimitedChallengeHelpIntro.
  ///
  /// In en, this message translates to:
  /// **'Adds a timed defeat challenge to the final stage of the Lord of the Underground Palace Zomboss battle. If its remaining health is not depleted within the time limit, Lord of the Underground Palace will swing its sword.'**
  String get finalStageTimeLimitedChallengeHelpIntro;

  /// No description provided for @finalStageTimeLimitedChallengeHelpParams.
  ///
  /// In en, this message translates to:
  /// **'Parameters'**
  String get finalStageTimeLimitedChallengeHelpParams;

  /// No description provided for @finalStageTimeLimitedChallengeHelpParamsBody.
  ///
  /// In en, this message translates to:
  /// **'For now, this module only needs to be referenced directly in LevelModules. The actual countdown duration is determined by ZombossFinalStageTimeLimited in the Zomboss properties rather than the ZombossTimeLimit field in this module, so customizing this module has no practical effect.'**
  String get finalStageTimeLimitedChallengeHelpParamsBody;

  /// No description provided for @finalStageTimeLimitedChallengeTimeLimit.
  ///
  /// In en, this message translates to:
  /// **'Sword Swing Countdown (ZombossTimeLimit, seconds)'**
  String get finalStageTimeLimitedChallengeTimeLimit;

  /// No description provided for @moduleTitle_LawnMowerProperties.
  ///
  /// In en, this message translates to:
  /// **'Lawn Mowers'**
  String get moduleTitle_LawnMowerProperties;

  /// No description provided for @moduleDesc_LawnMowerProperties.
  ///
  /// In en, this message translates to:
  /// **'Sets mower styles (doesn\'t work in Creative Courtyard)'**
  String get moduleDesc_LawnMowerProperties;

  /// No description provided for @moduleTitle_TunnelDefendModuleProperties.
  ///
  /// In en, this message translates to:
  /// **'Underground Palace Pathways'**
  String get moduleTitle_TunnelDefendModuleProperties;

  /// No description provided for @moduleDesc_TunnelDefendModuleProperties.
  ///
  /// In en, this message translates to:
  /// **'Configures pathways and tile styles for Underground Palace secret realm levels'**
  String get moduleDesc_TunnelDefendModuleProperties;

  /// No description provided for @moduleTitle_SouDaCheTunnelDefendDefault.
  ///
  /// In en, this message translates to:
  /// **'Expedition Tiles'**
  String get moduleTitle_SouDaCheTunnelDefendDefault;

  /// No description provided for @moduleDesc_SouDaCheTunnelDefendDefault.
  ///
  /// In en, this message translates to:
  /// **'Configures non-plantable areas on the Expedition Gate lawn'**
  String get moduleDesc_SouDaCheTunnelDefendDefault;

  /// No description provided for @moduleTitle_WitchModuleProperties.
  ///
  /// In en, this message translates to:
  /// **'Fright Witch'**
  String get moduleTitle_WitchModuleProperties;

  /// No description provided for @moduleDesc_WitchModuleProperties.
  ///
  /// In en, this message translates to:
  /// **'Fright Witches periodically sweep across the lawn, scattering magical potions'**
  String get moduleDesc_WitchModuleProperties;

  /// No description provided for @moduleTitle_InitialGridItemGulliverTunnelProperties.
  ///
  /// In en, this message translates to:
  /// **'Gulliver Tunnels'**
  String get moduleTitle_InitialGridItemGulliverTunnelProperties;

  /// No description provided for @moduleDesc_InitialGridItemGulliverTunnelProperties.
  ///
  /// In en, this message translates to:
  /// **'Places pre-set Gulliver tunnels on the lawn'**
  String get moduleDesc_InitialGridItemGulliverTunnelProperties;

  /// No description provided for @witchModuleHelpTitle.
  ///
  /// In en, this message translates to:
  /// **'Fright Witch module'**
  String get witchModuleHelpTitle;

  /// No description provided for @witchModuleHelpIntro.
  ///
  /// In en, this message translates to:
  /// **'Enabling this module adds 2 Fright Witches to the level. After the level begins, Fright Witch will periodically enter from either the left or right side of the lawn, randomly choosing a lane and flying across it on a magic broomstick while scattering magical potions along the way. After a period of time, she returns and repeats the process.\nDifferent potions have different effects: Orange Explosion Potions deal percentage-based damage in a 3×3 area around the landing point; Green Transmutation Potions transform single-tile plants into a sheep, frog, or chicken, and may also turn them into Tall-nut seed packets; Blue Necromancy Potions continuously revive zombies that die within a 3×3 area around the landing point for a duration; Red Berserk Potions grant zombies increased health and movement speed.\nFright Witch cannot be targeted by plants. Planting a Tall-nut in her path will knock her off the lawn; if the Tall-nut has previously used Plant Food, it will shatter the witch permanently, preventing her from returning.'**
  String get witchModuleHelpIntro;

  /// No description provided for @witchModuleHelpParams.
  ///
  /// In en, this message translates to:
  /// **'Parameter configuration'**
  String get witchModuleHelpParams;

  /// No description provided for @witchModuleHelpParamsBody.
  ///
  /// In en, this message translates to:
  /// **'By default, this module uses the values defined in the game files. Alternatively, you may enable custom local parameters and modify the interval between witch appearances.'**
  String get witchModuleHelpParamsBody;

  /// No description provided for @witchModuleSpawnInterval.
  ///
  /// In en, this message translates to:
  /// **'Witch spawn interval (WitchSpawnInterval, seconds)'**
  String get witchModuleSpawnInterval;

  /// No description provided for @gulliverTunnelTitle.
  ///
  /// In en, this message translates to:
  /// **'Gulliver Tunnels'**
  String get gulliverTunnelTitle;

  /// No description provided for @gulliverTunnelHelpOverview.
  ///
  /// In en, this message translates to:
  /// **'This module is used to place Gulliver Tunnels on the lawn before the level begins. Depending on their orientation, Gulliver Tunnels come in two forms: a small opening on the right and a large opening on the left, or a small opening on the left and a large opening on the right.\nImps entering through the small opening become Giant Imps with increased health. Regular zombies entering through the large opening become Mini Zombies, gaining increased movement speed and the ability to avoid some higher-flying straight projectiles.\nStraight-flying plant projectiles can also enter through the large opening and emerge from the small opening after being shrunk, dealing reduced damage. Lobbed projectiles can pass over the tunnel and attack zombies normally.'**
  String get gulliverTunnelHelpOverview;

  /// No description provided for @gulliverTunnelHelpUsage.
  ///
  /// In en, this message translates to:
  /// **'Usage'**
  String get gulliverTunnelHelpUsage;

  /// No description provided for @gulliverTunnelHelpUsageBody.
  ///
  /// In en, this message translates to:
  /// **'Select a tunnel orientation below, then click a tile to place it. Clicking a tile containing an existing tunnel removes it. Selecting a different orientation and clicking an existing tunnel replaces its orientation.'**
  String get gulliverTunnelHelpUsageBody;

  /// No description provided for @gulliverTunnelOrientationBigOnLeft.
  ///
  /// In en, this message translates to:
  /// **'Small Opening on Right, Large Opening on Left'**
  String get gulliverTunnelOrientationBigOnLeft;

  /// No description provided for @gulliverTunnelOrientationBigOnRight.
  ///
  /// In en, this message translates to:
  /// **'Small Opening on Left, Large Opening on Right'**
  String get gulliverTunnelOrientationBigOnRight;

  /// No description provided for @gulliverTunnelPlacedCount.
  ///
  /// In en, this message translates to:
  /// **'Placed'**
  String get gulliverTunnelPlacedCount;

  /// No description provided for @gulliverTunnelClearAll.
  ///
  /// In en, this message translates to:
  /// **'Clear all'**
  String get gulliverTunnelClearAll;

  /// No description provided for @gulliverTunnelClearConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Clear all Gulliver Tunnels?'**
  String get gulliverTunnelClearConfirmTitle;

  /// No description provided for @gulliverTunnelClearConfirmMessage.
  ///
  /// In en, this message translates to:
  /// **'This will removbe all placed Gulliver Tunnels from the lawn. This action cannot be undone.'**
  String get gulliverTunnelClearConfirmMessage;

  /// No description provided for @gulliverTunnelSelectOrientation.
  ///
  /// In en, this message translates to:
  /// **'Select orientation'**
  String get gulliverTunnelSelectOrientation;

  /// No description provided for @gulliverTunnelOutsideLawn.
  ///
  /// In en, this message translates to:
  /// **'Tunnels outside the lawn: '**
  String get gulliverTunnelOutsideLawn;

  /// No description provided for @gulliverTunnelDeleteOutside.
  ///
  /// In en, this message translates to:
  /// **'Remove Gulliver Tunnels outside the lawn'**
  String get gulliverTunnelDeleteOutside;

  /// No description provided for @gulliverTunnelDeleteOutsideConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Remove Gulliver Tunnels outside the lawn?'**
  String get gulliverTunnelDeleteOutsideConfirmTitle;

  /// No description provided for @gulliverTunnelDeleteOutsideConfirmMessage.
  ///
  /// In en, this message translates to:
  /// **'This will remove all Gulliver Tunnels outside the 5×9 lawn. This action cannot be undone.'**
  String get gulliverTunnelDeleteOutsideConfirmMessage;

  /// No description provided for @moduleTitle_RiftThemeDemoModuleProperties.
  ///
  /// In en, this message translates to:
  /// **'Theme Configuration'**
  String get moduleTitle_RiftThemeDemoModuleProperties;

  /// No description provided for @moduleDesc_RiftThemeDemoModuleProperties.
  ///
  /// In en, this message translates to:
  /// **'Adds theme effects from Penny\'s Pursuit, Memory Lane, and other game modes to the level'**
  String get moduleDesc_RiftThemeDemoModuleProperties;

  /// No description provided for @riftThemeHelpTitle.
  ///
  /// In en, this message translates to:
  /// **'Theme Configuration module'**
  String get riftThemeHelpTitle;

  /// No description provided for @riftThemeHelpOverview.
  ///
  /// In en, this message translates to:
  /// **'This module defines a list of themes for the level. Themes are global conditions found in modes such as Penny\'s Pursuit, Memory Lane, and Secret Realm. Each theme provides unique effects. Long-press or right-click a theme card to view a brief description of its effects and the related plant and zombie lists.'**
  String get riftThemeHelpOverview;

  /// No description provided for @riftThemeHelpUsage.
  ///
  /// In en, this message translates to:
  /// **'Usage'**
  String get riftThemeHelpUsage;

  /// No description provided for @riftThemeHelpUsageBody.
  ///
  /// In en, this message translates to:
  /// **'Click the button in the lower-right corner to open the theme selection screen. Themes can be added to or removed from the theme list by clicking them. Once all settings are complete, click the button again to confirm. Themes take effect in the order they appear in the list.'**
  String get riftThemeHelpUsageBody;

  /// No description provided for @riftThemeHelpUnique.
  ///
  /// In en, this message translates to:
  /// **'Addition Rules'**
  String get riftThemeHelpUnique;

  /// No description provided for @riftThemeHelpUniqueBody.
  ///
  /// In en, this message translates to:
  /// **'Each theme can only appear once in the list. Adding an excessive number of themes may cause the level to crash.'**
  String get riftThemeHelpUniqueBody;

  /// No description provided for @riftThemeEmpty.
  ///
  /// In en, this message translates to:
  /// **'No themes selected. Tap the button in the lower-right corner to choose themes.'**
  String get riftThemeEmpty;

  /// No description provided for @riftThemeSelectThemes.
  ///
  /// In en, this message translates to:
  /// **'Select themes'**
  String get riftThemeSelectThemes;

  /// No description provided for @riftThemeNoSearchResults.
  ///
  /// In en, this message translates to:
  /// **'No matching themes'**
  String get riftThemeNoSearchResults;

  /// No description provided for @moduleTitle_ZombieRushModuleProperties.
  ///
  /// In en, this message translates to:
  /// **'Level Timer'**
  String get moduleTitle_ZombieRushModuleProperties;

  /// No description provided for @moduleDesc_ZombieRushModuleProperties.
  ///
  /// In en, this message translates to:
  /// **'Level ends when the timer reaches zero'**
  String get moduleDesc_ZombieRushModuleProperties;

  /// No description provided for @moduleTitle_PVZ1PassageModuleProperties.
  ///
  /// In en, this message translates to:
  /// **'Portal Combat'**
  String get moduleTitle_PVZ1PassageModuleProperties;

  /// No description provided for @moduleDesc_PVZ1PassageModuleProperties.
  ///
  /// In en, this message translates to:
  /// **'Configures the spawning of PvZ1-style portals'**
  String get moduleDesc_PVZ1PassageModuleProperties;

  /// No description provided for @moduleTitle_PVZ1CopycatsModuleProperties.
  ///
  /// In en, this message translates to:
  /// **'Guess Who I Am'**
  String get moduleTitle_PVZ1CopycatsModuleProperties;

  /// No description provided for @moduleDesc_PVZ1CopycatsModuleProperties.
  ///
  /// In en, this message translates to:
  /// **'Configures Magic Hat summons, enables Magic Hat selection'**
  String get moduleDesc_PVZ1CopycatsModuleProperties;

  /// No description provided for @pvz1CopycatsModuleTitle.
  ///
  /// In en, this message translates to:
  /// **'Guess Who I Am'**
  String get pvz1CopycatsModuleTitle;

  /// No description provided for @pvz1CopycatsSectionParams.
  ///
  /// In en, this message translates to:
  /// **'Parameters'**
  String get pvz1CopycatsSectionParams;

  /// No description provided for @pvz1CopycatsFieldZombieWeightLabel.
  ///
  /// In en, this message translates to:
  /// **'Zombie weight (ZombieWeight)'**
  String get pvz1CopycatsFieldZombieWeightLabel;

  /// No description provided for @pvz1CopycatsHelpZombieWeight.
  ///
  /// In en, this message translates to:
  /// **'The probability of summoning a zombie per attempt (0–1). The probability of summoning a plant is 1 minus this value.'**
  String get pvz1CopycatsHelpZombieWeight;

  /// No description provided for @pvz1CopycatsFieldSpawnPlantLevelLabel.
  ///
  /// In en, this message translates to:
  /// **'Plant level (SpawnPlantLevel)'**
  String get pvz1CopycatsFieldSpawnPlantLevelLabel;

  /// No description provided for @pvz1CopycatsHelpSpawnPlantLevel.
  ///
  /// In en, this message translates to:
  /// **'The level of plants summoned by the Magic Hat.'**
  String get pvz1CopycatsHelpSpawnPlantLevel;

  /// No description provided for @pvz1CopycatsSectionPlantBlackList.
  ///
  /// In en, this message translates to:
  /// **'Plant blacklist (PlantBlackList)'**
  String get pvz1CopycatsSectionPlantBlackList;

  /// No description provided for @pvz1CopycatsHelpPlantBlackList.
  ///
  /// In en, this message translates to:
  /// **'Each type of Magic Hat has its own plant pool. This pool is not affected by the blacklist, so modifying the blacklist has no effect.'**
  String get pvz1CopycatsHelpPlantBlackList;

  /// No description provided for @pvz1CopycatsSectionZombieWhiteList.
  ///
  /// In en, this message translates to:
  /// **'Zombie whitelist (ZombieWhiteList)'**
  String get pvz1CopycatsSectionZombieWhiteList;

  /// No description provided for @pvz1CopycatsHelpZombieWhiteList.
  ///
  /// In en, this message translates to:
  /// **'Only zombies in the whitelist can be summoned by the Magic Hat.'**
  String get pvz1CopycatsHelpZombieWhiteList;

  /// No description provided for @pvz1CopycatsHelpTip.
  ///
  /// In en, this message translates to:
  /// **'After adding this module, remember to pre-select Magic Hats in the Seed Bank or Conveyor Belt module. Long press or right-click the Magic Hat in the plant selection screen to preview the plants it can summon.'**
  String get pvz1CopycatsHelpTip;

  /// No description provided for @pvz1CopycatsHelpOverview.
  ///
  /// In en, this message translates to:
  /// **'This module configures the summon behavior of Magic Hats that can be planted in the seed slots, commonly used in the Memory Lane mini-game \"Guess Who I Am\". Without this module, Magic Hats will not function properly. Different types of Magic Hat vary in sun cost and cooldown time. After being planted, a Magic Hat will transform into a random plant or zombie. Plants are selected from the Magic Hat’s own plant pool, while zombies are selected only from the whitelist. The weights of individual entries in the plant or zombie pools cannot be adjusted.'**
  String get pvz1CopycatsHelpOverview;

  /// No description provided for @pvz1CopycatsHelpFieldsTitle.
  ///
  /// In en, this message translates to:
  /// **'Parameter details'**
  String get pvz1CopycatsHelpFieldsTitle;

  /// No description provided for @pvz1CopycatsPlantListEmpty.
  ///
  /// In en, this message translates to:
  /// **'Blacklist is empty'**
  String get pvz1CopycatsPlantListEmpty;

  /// No description provided for @pvz1CopycatsZombieListEmpty.
  ///
  /// In en, this message translates to:
  /// **'Whitelist is empty'**
  String get pvz1CopycatsZombieListEmpty;

  /// No description provided for @pvz1CopycatsAddPlant.
  ///
  /// In en, this message translates to:
  /// **'Add plant to blacklist'**
  String get pvz1CopycatsAddPlant;

  /// No description provided for @pvz1CopycatsAddZombie.
  ///
  /// In en, this message translates to:
  /// **'Add zombie to whitelist'**
  String get pvz1CopycatsAddZombie;

  /// No description provided for @moduleTitle_PVZ1SeeingStarsModuleProperties.
  ///
  /// In en, this message translates to:
  /// **'Seeing Stars'**
  String get moduleTitle_PVZ1SeeingStarsModuleProperties;

  /// No description provided for @moduleDesc_PVZ1SeeingStarsModuleProperties.
  ///
  /// In en, this message translates to:
  /// **'Configures target plants and wave loop for the Seeing Stars minigame'**
  String get moduleDesc_PVZ1SeeingStarsModuleProperties;

  /// No description provided for @pvz1SeeingStarsModuleTitle.
  ///
  /// In en, this message translates to:
  /// **'Seeing Stars'**
  String get pvz1SeeingStarsModuleTitle;

  /// No description provided for @pvz1SeeingStarsSectionParams.
  ///
  /// In en, this message translates to:
  /// **'Parameters'**
  String get pvz1SeeingStarsSectionParams;

  /// No description provided for @pvz1SeeingStarsSectionMatchPlants.
  ///
  /// In en, this message translates to:
  /// **'Target plants (MatchPlants)'**
  String get pvz1SeeingStarsSectionMatchPlants;

  /// No description provided for @pvz1SeeingStarsHelpMatchPlants.
  ///
  /// In en, this message translates to:
  /// **'Select a cell on the grid and add a plant. If the cell already has a plant, the new one replaces it. These plants appear as transparent guides in the level. The level is won when every target cell contains the matching plant. Target cells only allow the matching target plant and vine plants; other plants cannot be planted there.'**
  String get pvz1SeeingStarsHelpMatchPlants;

  /// No description provided for @pvz1SeeingStarsFieldCycleIndexLabel.
  ///
  /// In en, this message translates to:
  /// **'Cycle wave (CycleIndex)'**
  String get pvz1SeeingStarsFieldCycleIndexLabel;

  /// No description provided for @pvz1SeeingStarsHelpCycleIndex.
  ///
  /// In en, this message translates to:
  /// **'The zero-based index of the first wave to repeat after the final wave. For example, in a 15-wave level with a value of 5, wave 15 is followed by wave 6. Waves keep looping until the pattern is complete.'**
  String get pvz1SeeingStarsHelpCycleIndex;

  /// No description provided for @pvz1SeeingStarsFieldSettlementDurationLabel.
  ///
  /// In en, this message translates to:
  /// **'Settlement delay (SettlementDuration)'**
  String get pvz1SeeingStarsFieldSettlementDurationLabel;

  /// No description provided for @pvz1SeeingStarsHelpSettlementDuration.
  ///
  /// In en, this message translates to:
  /// **'After the pattern is complete, the specified delay begins. When it ends, the level is won even if the target cells no longer contain the matching plants. The delay only applies when neither Loot Drop nor Bronze Matrix Loot Drop is present.'**
  String get pvz1SeeingStarsHelpSettlementDuration;

  /// No description provided for @pvz1SeeingStarsHelpOverview.
  ///
  /// In en, this message translates to:
  /// **'Configures the Memory Lane minigame Seeing Stars. The name comes from the original game\'s level, where players had to plant Starfruit in a star-shaped pattern. Follow the guides on the lawn and plant the matching plants in the indicated cells to win. Meanwhile, the configured zombie waves repeat, disrupting the player\'s planting.'**
  String get pvz1SeeingStarsHelpOverview;

  /// No description provided for @pvz1SeeingStarsHelpFieldsTitle.
  ///
  /// In en, this message translates to:
  /// **'Parameter details'**
  String get pvz1SeeingStarsHelpFieldsTitle;

  /// No description provided for @pvz1SeeingStarsHelpWinCon.
  ///
  /// In en, this message translates to:
  /// **'Do not combine this module with Loot Drop, Bronze Matrix Loot Drop, Level Timer, Bemarbled, or other modules with their own end conditions. They may override or interfere with Seeing Stars\' win condition and disrupt the minigame.\nSeeing Stars is also incompatible with Wave Generator and will crash the level if both are used. Use with caution.'**
  String get pvz1SeeingStarsHelpWinCon;

  /// No description provided for @pvz1SeeingStarsMatchPlantsEmpty.
  ///
  /// In en, this message translates to:
  /// **'No pattern configured yet. Select any cell on the grid and add a plant.'**
  String get pvz1SeeingStarsMatchPlantsEmpty;

  /// No description provided for @seeingStarsWinConWarningTitle.
  ///
  /// In en, this message translates to:
  /// **'Conflicting win conditions'**
  String get seeingStarsWinConWarningTitle;

  /// No description provided for @seeingStarsWinConWarning.
  ///
  /// In en, this message translates to:
  /// **'Seeing Stars ends the level when the pattern is complete. Do not combine it with Loot Drop, Bronze Matrix Loot Drop, Level Timer, Bemarbled, or other modules with their own end conditions, as they may override or interfere with its win condition.'**
  String get seeingStarsWinConWarning;

  /// No description provided for @seeingStarsCycleWaveLabel.
  ///
  /// In en, this message translates to:
  /// **'Cycle wave (CycleIndex, 0-based)'**
  String get seeingStarsCycleWaveLabel;

  /// No description provided for @seeingStarsSettlementLabel.
  ///
  /// In en, this message translates to:
  /// **'Settlement delay (SettlementDuration, seconds)'**
  String get seeingStarsSettlementLabel;

  /// No description provided for @pvz1SeeingStarsHelpTipsTitle.
  ///
  /// In en, this message translates to:
  /// **'Friendly Reminder'**
  String get pvz1SeeingStarsHelpTipsTitle;

  /// No description provided for @seeingStarsCompatibilityWarningTitle.
  ///
  /// In en, this message translates to:
  /// **'Module compatibility warning'**
  String get seeingStarsCompatibilityWarningTitle;

  /// No description provided for @seeingStarsCompatibilityWarning.
  ///
  /// In en, this message translates to:
  /// **'Seeing Stars is incompatible with Wave Generator and will cause the level to crash. Use with caution.'**
  String get seeingStarsCompatibilityWarning;

  /// No description provided for @seeingStarsCycleWaveBadge.
  ///
  /// In en, this message translates to:
  /// **'Wave loop'**
  String get seeingStarsCycleWaveBadge;

  /// No description provided for @seeingStarsCycleWaveInfo.
  ///
  /// In en, this message translates to:
  /// **'After the final wave, zombies start spawning again from wave {wave}. Waves repeat until every target cell contains the matching plant.'**
  String seeingStarsCycleWaveInfo(int wave);

  /// No description provided for @seeingStarsMatchPlants.
  ///
  /// In en, this message translates to:
  /// **'Target plants'**
  String get seeingStarsMatchPlants;

  /// No description provided for @magicHatSpawnPreviewTitle.
  ///
  /// In en, this message translates to:
  /// **'Possible plants from Magic Hat'**
  String get magicHatSpawnPreviewTitle;

  /// No description provided for @magicHatSpawnPreviewEmpty.
  ///
  /// In en, this message translates to:
  /// **'No plants match this blacklist.'**
  String get magicHatSpawnPreviewEmpty;

  /// No description provided for @pvz1PassageModuleTitle.
  ///
  /// In en, this message translates to:
  /// **'Portal Combat'**
  String get pvz1PassageModuleTitle;

  /// No description provided for @pvz1PassageSectionParams.
  ///
  /// In en, this message translates to:
  /// **'Portal parameters'**
  String get pvz1PassageSectionParams;

  /// No description provided for @pvz1PassageHelpOverview.
  ///
  /// In en, this message translates to:
  /// **'This module configures PvZ1-style portals, commonly used in the Memory Lane mini-game \"Portal Combat\". Portals appear in groups and affect the movement paths of plant projectiles and zombies, and will periodically change positions. Note that portals do not affect plant targeting. Plants will not attack zombies on the other end of a portal ahead of them, and will only attack if there are zombies in their lane.'**
  String get pvz1PassageHelpOverview;

  /// No description provided for @pvz1PassageHelpFieldsTitle.
  ///
  /// In en, this message translates to:
  /// **'Parameter Overview'**
  String get pvz1PassageHelpFieldsTitle;

  /// No description provided for @pvz1PassageFieldGroupAmount.
  ///
  /// In en, this message translates to:
  /// **'Portal types (GroupAmount)'**
  String get pvz1PassageFieldGroupAmount;

  /// No description provided for @pvz1PassageHelpGroupAmount.
  ///
  /// In en, this message translates to:
  /// **'The number of portal types that appear in the level. PvZ1-style portals have two types: square and circular. If set to 1, only square portals will appear. If set to 2, both square and circular portals will appear. If set to 3 or higher, the extra portal types will display as sun textures; these portals do not change position, but can still teleport zombies.'**
  String get pvz1PassageHelpGroupAmount;

  /// No description provided for @pvz1PassageFieldPassageAmount.
  ///
  /// In en, this message translates to:
  /// **'Portals per type (PassageAmount)'**
  String get pvz1PassageFieldPassageAmount;

  /// No description provided for @pvz1PassageHelpPassageAmount.
  ///
  /// In en, this message translates to:
  /// **'The number of portals within each type. For example, if set to 2, each type will have 2 portals. The total number of portals cannot exceed the number of tiles in the spawn area. If multiple valid destination portals exist within the same type, zombies will always teleport to the designated one.'**
  String get pvz1PassageHelpPassageAmount;

  /// No description provided for @pvz1PassageFieldGridXMin.
  ///
  /// In en, this message translates to:
  /// **'Minimum spawn column (GridXMin)'**
  String get pvz1PassageFieldGridXMin;

  /// No description provided for @pvz1PassageHelpGridXMin.
  ///
  /// In en, this message translates to:
  /// **'The leftmost column where portals may spawn. The left boundary of this lawn is column 0, and the right boundary is column {maxIndex}. This value must be less than the maximum column value.'**
  String pvz1PassageHelpGridXMin(int maxIndex);

  /// No description provided for @pvz1PassageFieldGridXMax.
  ///
  /// In en, this message translates to:
  /// **'Maximum spawn column (GridXMax)'**
  String get pvz1PassageFieldGridXMax;

  /// No description provided for @pvz1PassageHelpGridXMax.
  ///
  /// In en, this message translates to:
  /// **'The rightmost column where portals may spawn. The left boundary of this lawn is column 0, and the right boundary is column {maxIndex}. This value must be greater than the minimum column value.'**
  String pvz1PassageHelpGridXMax(int maxIndex);

  /// No description provided for @pvz1PassageGridColumnRange.
  ///
  /// In en, this message translates to:
  /// **'0–{maxIndex}'**
  String pvz1PassageGridColumnRange(int maxIndex);

  /// No description provided for @pvz1PassageFieldTransferCooldown.
  ///
  /// In en, this message translates to:
  /// **'Same-zombie teleport cooldown (transferCooldown, seconds)'**
  String get pvz1PassageFieldTransferCooldown;

  /// No description provided for @pvz1PassageHelpTransferCooldown.
  ///
  /// In en, this message translates to:
  /// **'The minimum time between two teleports of the same zombie. If set too low, a zombie that fails to leave the portal tile within the interval may be teleported back to the original portal again once the cooldown ends.'**
  String get pvz1PassageHelpTransferCooldown;

  /// No description provided for @pvz1PassageFieldRefreshTime.
  ///
  /// In en, this message translates to:
  /// **'Portal reposition interval (refreshTime, seconds)'**
  String get pvz1PassageFieldRefreshTime;

  /// No description provided for @pvz1PassageHelpRefreshTime.
  ///
  /// In en, this message translates to:
  /// **'The interval at which portal positions are regenerated. Portals are refreshed one at a time, meaning each refresh only changes the position of one portal within the same type.'**
  String get pvz1PassageHelpRefreshTime;

  /// No description provided for @pvz1PassagePortalSpawnPreview.
  ///
  /// In en, this message translates to:
  /// **'Portal spawn column preview'**
  String get pvz1PassagePortalSpawnPreview;

  /// No description provided for @pvz1PassageHelpPreview.
  ///
  /// In en, this message translates to:
  /// **'Spawn Range Preview'**
  String get pvz1PassageHelpPreview;

  /// No description provided for @pvz1PassageHelpPreviewBody.
  ///
  /// In en, this message translates to:
  /// **'The orange highlighted area indicates which columns portals may appear in. The column range of the current lawn is 0–{maxIndex} (including both lawn boundaries). This module cannot restrict the row range where portals spawn.'**
  String pvz1PassageHelpPreviewBody(int maxIndex);

  /// No description provided for @moduleWaveIndexZeroBasedHint.
  ///
  /// In en, this message translates to:
  /// **'0 = Wave 1, 1 = Wave 2, ...'**
  String get moduleWaveIndexZeroBasedHint;

  /// No description provided for @moduleWaveFieldZeroBased.
  ///
  /// In en, this message translates to:
  /// **'Wave (0 = Wave 1, 1 = Wave 2, ...)'**
  String get moduleWaveFieldZeroBased;

  /// No description provided for @moduleTitle_RenaiModuleProperties.
  ///
  /// In en, this message translates to:
  /// **'Renaissance Module'**
  String get moduleTitle_RenaiModuleProperties;

  /// No description provided for @moduleDesc_RenaiModuleProperties.
  ///
  /// In en, this message translates to:
  /// **'Enables the Vitruvian Wheel and day–night cycle, configures Renaissance Statues and Marble Mounds'**
  String get moduleDesc_RenaiModuleProperties;

  /// No description provided for @renaiModuleHelpTitle.
  ///
  /// In en, this message translates to:
  /// **'Renaissance Module'**
  String get renaiModuleHelpTitle;

  /// No description provided for @renaiModuleHelpOverview.
  ///
  /// In en, this message translates to:
  /// **'Overview'**
  String get renaiModuleHelpOverview;

  /// No description provided for @renaiModuleHelpOverviewBody.
  ///
  /// In en, this message translates to:
  /// **'This module is used to make the Vitruvian Wheel respond to Floor-de-Lis tiles; configure day–night cycle waves; and, at night, revive Renaissance Statues and Marble Mounds, and spawn grid items based on settings. Typically used in Renaissance Ages levels.'**
  String get renaiModuleHelpOverviewBody;

  /// No description provided for @renaiModuleHelpStatues.
  ///
  /// In en, this message translates to:
  /// **'Notes'**
  String get renaiModuleHelpStatues;

  /// No description provided for @renaiModuleHelpStatuesBody.
  ///
  /// In en, this message translates to:
  /// **'Initial grid items refer to statues and Marble Mounds present at the start of the level, which revive into zombies at specified waves. Night grid items are generated after night begins; if a plant occupies the target tile, they will not spawn. Night start wave uses a 0-based index (e.g., 0 = first wave, 1 = second wave).'**
  String get renaiModuleHelpStatuesBody;

  /// No description provided for @renaiModuleEnableNight.
  ///
  /// In en, this message translates to:
  /// **'Enable Day–Night Cycle'**
  String get renaiModuleEnableNight;

  /// No description provided for @renaiModuleEnableNightSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Allows setting the wave when night begins and configuring night grid items'**
  String get renaiModuleEnableNightSubtitle;

  /// No description provided for @renaiModuleNightStart.
  ///
  /// In en, this message translates to:
  /// **'Night Start Wave'**
  String get renaiModuleNightStart;

  /// No description provided for @renaiModuleDayStatues.
  ///
  /// In en, this message translates to:
  /// **'Initial grid items'**
  String get renaiModuleDayStatues;

  /// No description provided for @renaiModuleNightStatues.
  ///
  /// In en, this message translates to:
  /// **'Night grid items'**
  String get renaiModuleNightStatues;

  /// No description provided for @renaiModuleNightStatuesDisabledHint.
  ///
  /// In en, this message translates to:
  /// **'Please enable the day–night cycle first'**
  String get renaiModuleNightStatuesDisabledHint;

  /// No description provided for @renaiModuleCarveWave.
  ///
  /// In en, this message translates to:
  /// **'Statue revival wave'**
  String get renaiModuleCarveWave;

  /// No description provided for @renaiModuleStatuesInCell.
  ///
  /// In en, this message translates to:
  /// **'Item(s) in selected tile'**
  String get renaiModuleStatuesInCell;

  /// No description provided for @renaiModuleExpectationLabel.
  ///
  /// In en, this message translates to:
  /// **'Renaissance event preview'**
  String get renaiModuleExpectationLabel;

  /// No description provided for @renaiModuleNightStarts.
  ///
  /// In en, this message translates to:
  /// **'Night begins'**
  String get renaiModuleNightStarts;

  /// No description provided for @renaiModulePreviewNightStatues.
  ///
  /// In en, this message translates to:
  /// **'Night grid items to be spawned this wave:'**
  String get renaiModulePreviewNightStatues;

  /// No description provided for @renaiModulePreviewRevivingStatues.
  ///
  /// In en, this message translates to:
  /// **'Statues to be revived this wave:'**
  String get renaiModulePreviewRevivingStatues;

  /// No description provided for @moduleTitle_DropShipProperties.
  ///
  /// In en, this message translates to:
  /// **'Transport Boat Assault'**
  String get moduleTitle_DropShipProperties;

  /// No description provided for @moduleDesc_DropShipProperties.
  ///
  /// In en, this message translates to:
  /// **'Airdrops Flying Imp Zombies onto the lawn'**
  String get moduleDesc_DropShipProperties;

  /// No description provided for @airDropShipModuleHelpTitle.
  ///
  /// In en, this message translates to:
  /// **'Transport Boat Assault module'**
  String get airDropShipModuleHelpTitle;

  /// No description provided for @airDropShipModuleHelpOverview.
  ///
  /// In en, this message translates to:
  /// **'Overview'**
  String get airDropShipModuleHelpOverview;

  /// No description provided for @airDropShipModuleHelpOverviewBody.
  ///
  /// In en, this message translates to:
  /// **'This module is used to configure Transport Boats that appear during waves in a level, commonly seen in Sky City levels. Transport Boats cannot be damaged. A set number of Flying Imp Zombies will drop sequentially into the designated drop area.'**
  String get airDropShipModuleHelpOverviewBody;

  /// No description provided for @airDropShipModuleHelpImps.
  ///
  /// In en, this message translates to:
  /// **'Parameters'**
  String get airDropShipModuleHelpImps;

  /// No description provided for @airDropShipModuleHelpImpsBody.
  ///
  /// In en, this message translates to:
  /// **'Each entry’s wave index is 0-based (e.g., 0 = first wave, 1 = second wave). Each Transport Boat drops at least one Flying Imp Zombie. The extra imp count specifies how many additional imps are dropped on top of the initial one for that wave.'**
  String get airDropShipModuleHelpImpsBody;

  /// No description provided for @airDropShipModuleAppearances.
  ///
  /// In en, this message translates to:
  /// **'Assault Groups'**
  String get airDropShipModuleAppearances;

  /// No description provided for @airDropShipModuleExtraImpCount.
  ///
  /// In en, this message translates to:
  /// **'Extra imp count (Imp)'**
  String get airDropShipModuleExtraImpCount;

  /// No description provided for @airDropShipModuleDropArea.
  ///
  /// In en, this message translates to:
  /// **'Drop area'**
  String get airDropShipModuleDropArea;

  /// No description provided for @airDropShipModuleDropAreaPreview.
  ///
  /// In en, this message translates to:
  /// **'Drop area preview'**
  String get airDropShipModuleDropAreaPreview;

  /// No description provided for @airDropShipModuleAreaDropPreviewLabel.
  ///
  /// In en, this message translates to:
  /// **'Area drop preview:'**
  String get airDropShipModuleAreaDropPreviewLabel;

  /// No description provided for @airDropShipModuleExpectationLabel.
  ///
  /// In en, this message translates to:
  /// **'Airdropped Imps'**
  String get airDropShipModuleExpectationLabel;

  /// No description provided for @airDropShipModuleImpLevel.
  ///
  /// In en, this message translates to:
  /// **'Imp level (ImpLv)'**
  String get airDropShipModuleImpLevel;

  /// No description provided for @airDropShipModuleRowMin.
  ///
  /// In en, this message translates to:
  /// **'Start row'**
  String get airDropShipModuleRowMin;

  /// No description provided for @airDropShipModuleRowMax.
  ///
  /// In en, this message translates to:
  /// **'End row'**
  String get airDropShipModuleRowMax;

  /// No description provided for @airDropShipModuleColMin.
  ///
  /// In en, this message translates to:
  /// **'Start column'**
  String get airDropShipModuleColMin;

  /// No description provided for @airDropShipModuleColMax.
  ///
  /// In en, this message translates to:
  /// **'End column'**
  String get airDropShipModuleColMax;

  /// No description provided for @openModuleSettings.
  ///
  /// In en, this message translates to:
  /// **'Open Module Settings'**
  String get openModuleSettings;

  /// No description provided for @moduleTitle_GlacierModuleProperties.
  ///
  /// In en, this message translates to:
  /// **'Ice Chunk Module'**
  String get moduleTitle_GlacierModuleProperties;

  /// No description provided for @moduleDesc_GlacierModuleProperties.
  ///
  /// In en, this message translates to:
  /// **'Configures the zombies hidden inside Ice Chunks created by the Frostbite Caves Zomboss'**
  String get moduleDesc_GlacierModuleProperties;

  /// No description provided for @glacierModuleTitle.
  ///
  /// In en, this message translates to:
  /// **'Ice Chunk module'**
  String get glacierModuleTitle;

  /// No description provided for @glacierModuleHelpTitle.
  ///
  /// In en, this message translates to:
  /// **'Ice Chunk module'**
  String get glacierModuleHelpTitle;

  /// No description provided for @glacierModuleHelpOverviewBody.
  ///
  /// In en, this message translates to:
  /// **'The Frostbite Caves Zomboss summons zombies differently from other Zomboss mechs: it spits out blasts of ice from bottom to top to create Ice Chunks, which release the zombies hidden inside when they break. This module is used to configure which zombies may appear inside the Ice Chunks.'**
  String get glacierModuleHelpOverviewBody;

  /// No description provided for @glacierModuleHelpColumnsTitle.
  ///
  /// In en, this message translates to:
  /// **'Parameters'**
  String get glacierModuleHelpColumnsTitle;

  /// No description provided for @glacierModuleHelpColumnsBody.
  ///
  /// In en, this message translates to:
  /// **'This module consists of 6 content groups, with each group corresponding to one column of Ice Chunks. Counting starts from the column farthest from Zomboss, which is the leftmost column on a standard lawn. After selecting Add content, you can add either a zombie or the empty outcome \"No zombie appears.\" Every item has its own appearance weight; only zombie items can switch zombie type and set a level of up to Level 4, while the empty outcome only has a weight.'**
  String get glacierModuleHelpColumnsBody;

  /// No description provided for @glacierModuleHelpRequirementsTitle.
  ///
  /// In en, this message translates to:
  /// **'Notes'**
  String get glacierModuleHelpRequirementsTitle;

  /// No description provided for @glacierModuleHelpRequirementsBody.
  ///
  /// In en, this message translates to:
  /// **'This module must be used together with the Zomboss Mech Battle module, and the selected base Zomboss mech must be \"Frostbite Caves Zomboss (Zombot Tuskmaster 10,000 BC)\"; otherwise, it will have no effect.\nIn addition, using the Frostbite Caves Zomboss and the Ice Chunk Module on an Underwater World lawn is not recommended, as it negatively affects the overall appearance of the level.'**
  String get glacierModuleHelpRequirementsBody;

  /// No description provided for @glacierModuleHelpPresetsTitle.
  ///
  /// In en, this message translates to:
  /// **'Preset configurations'**
  String get glacierModuleHelpPresetsTitle;

  /// No description provided for @glacierModuleHelpPresetsBody.
  ///
  /// In en, this message translates to:
  /// **'The editor includes the Ice Chunk configurations used by each Frostbite Caves Zomboss variation in the original game. Applying a preset replaces all six Ice Chunk groups and cannot be undone; you can still adjust the entries manually afterward. The Beplanted variation does not need the Ice Chunk Module and therefore has no preset. The custom variation uses a blank preset by default.'**
  String get glacierModuleHelpPresetsBody;

  /// No description provided for @glacierModulePresetSectionTitle.
  ///
  /// In en, this message translates to:
  /// **'Ice Chunk presets'**
  String get glacierModulePresetSectionTitle;

  /// No description provided for @glacierModulePresetBlankCustom.
  ///
  /// In en, this message translates to:
  /// **'Custom variation (blank preset)'**
  String get glacierModulePresetBlankCustom;

  /// No description provided for @glacierModulePresetCustomConfiguration.
  ///
  /// In en, this message translates to:
  /// **'Custom configuration'**
  String get glacierModulePresetCustomConfiguration;

  /// No description provided for @glacierModuleSwitchPresetTitle.
  ///
  /// In en, this message translates to:
  /// **'Switch Ice Chunk preset'**
  String get glacierModuleSwitchPresetTitle;

  /// No description provided for @glacierModuleSwitchPresetMessage.
  ///
  /// In en, this message translates to:
  /// **'Switch from \"{from}\" to \"{to}\"? All six current Ice Chunk groups will be replaced and this cannot be undone.'**
  String glacierModuleSwitchPresetMessage(String from, String to);

  /// No description provided for @glacierModuleVariationPresetPromptTitle.
  ///
  /// In en, this message translates to:
  /// **'Enable the matching Ice Chunk preset'**
  String get glacierModuleVariationPresetPromptTitle;

  /// No description provided for @glacierModuleVariationPresetPrompt.
  ///
  /// In en, this message translates to:
  /// **'The Frostbite Caves Zomboss summons zombies by filling Ice Chunks. The zombies released from those chunks are configured by the dedicated Ice Chunk Module. You are about to switch to another Frostbite Caves Zomboss variation. Also enable the Ice Chunk Module preset used by that variation in the original game?'**
  String get glacierModuleVariationPresetPrompt;

  /// No description provided for @glacierModuleCustomVariationPresetPrompt.
  ///
  /// In en, this message translates to:
  /// **'The custom variation uses a blank Ice Chunk preset by default. Also switch the Ice Chunk Module to the blank preset?'**
  String get glacierModuleCustomVariationPresetPrompt;

  /// No description provided for @zombossMechSwitchVariationOnly.
  ///
  /// In en, this message translates to:
  /// **'Switch variation only'**
  String get zombossMechSwitchVariationOnly;

  /// No description provided for @glacierModuleEnablePreset.
  ///
  /// In en, this message translates to:
  /// **'Enable preset too'**
  String get glacierModuleEnablePreset;

  /// No description provided for @iceAgePlantPuzzleVariationWarningTitle.
  ///
  /// In en, this message translates to:
  /// **'Beplanted does not need Ice Chunks'**
  String get iceAgePlantPuzzleVariationWarningTitle;

  /// No description provided for @iceAgePlantPuzzleVariationWarning.
  ///
  /// In en, this message translates to:
  /// **'The Beplanted variant of Zombot Tuskmaster 10,000 BC was designed specifically for the Beplanted minigame in Frostbite Caves. Its abilities do not require the Ice Chunk Module.'**
  String get iceAgePlantPuzzleVariationWarning;

  /// No description provided for @glacierModuleCompatibilityWarningTitle.
  ///
  /// In en, this message translates to:
  /// **'Ice Chunk Module requirements'**
  String get glacierModuleCompatibilityWarningTitle;

  /// No description provided for @glacierModuleCompatibilityWarning.
  ///
  /// In en, this message translates to:
  /// **'Ice Chunk Module must be used together with the Zomboss Mech Battle module, and the selected base Zomboss mech must be \"Frostbite Caves Zomboss (Zombot Tuskmaster 10,000 BC)\"; otherwise, it will have no effect. If you do not intend to use the Frostbite Caves Zomboss in this level, it is recommended to remove this module.'**
  String get glacierModuleCompatibilityWarning;

  /// No description provided for @glacierModuleUnderwaterWarningTitle.
  ///
  /// In en, this message translates to:
  /// **'Underwater World appearance incompatibility'**
  String get glacierModuleUnderwaterWarningTitle;

  /// No description provided for @glacierModuleUnderwaterWarning.
  ///
  /// In en, this message translates to:
  /// **'Avoid using the Frostbite Caves Zomboss and the Ice Chunk Module on an Underwater World lawn. This combination can harm the level appearance.'**
  String get glacierModuleUnderwaterWarning;

  /// No description provided for @glacierModuleColumn.
  ///
  /// In en, this message translates to:
  /// **'Column {columnIndex} from the Left'**
  String glacierModuleColumn(int columnIndex);

  /// No description provided for @glacierModuleEntryCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 item configured} other{{count} items configured}}'**
  String glacierModuleEntryCount(int count);

  /// No description provided for @glacierModuleNoEntries.
  ///
  /// In en, this message translates to:
  /// **'No content has been configured in this group yet.'**
  String get glacierModuleNoEntries;

  /// No description provided for @glacierModuleAddEntry.
  ///
  /// In en, this message translates to:
  /// **'Add content'**
  String get glacierModuleAddEntry;

  /// No description provided for @glacierModuleAddContentTitle.
  ///
  /// In en, this message translates to:
  /// **'Add Ice Chunk content'**
  String get glacierModuleAddContentTitle;

  /// No description provided for @glacierModuleAddZombieContent.
  ///
  /// In en, this message translates to:
  /// **'Add zombie'**
  String get glacierModuleAddZombieContent;

  /// No description provided for @glacierModuleEmptyType.
  ///
  /// In en, this message translates to:
  /// **'No zombie appears'**
  String get glacierModuleEmptyType;

  /// No description provided for @glacierModuleWeight.
  ///
  /// In en, this message translates to:
  /// **'Weight'**
  String get glacierModuleWeight;

  /// No description provided for @glacierModuleWeightTooltip.
  ///
  /// In en, this message translates to:
  /// **'Sets the weight of this zombie appearing in Ice Chunks in this column.'**
  String get glacierModuleWeightTooltip;

  /// No description provided for @glacierModuleEmptyWeightTooltip.
  ///
  /// In en, this message translates to:
  /// **'Sets the weight of the outcome in which the Ice Chunk releases no zombie.'**
  String get glacierModuleEmptyWeightTooltip;

  /// No description provided for @glacierModuleLevel.
  ///
  /// In en, this message translates to:
  /// **'Zombie level'**
  String get glacierModuleLevel;

  /// No description provided for @glacierModuleLevelTooltip.
  ///
  /// In en, this message translates to:
  /// **'Sets the zombie\'s level, 0-based to 4. Level 0 follows the lawn’s default level, which is Level 1 in Creative Courtyard.'**
  String get glacierModuleLevelTooltip;

  /// No description provided for @moduleTitle_HeianWindModuleProperties.
  ///
  /// In en, this message translates to:
  /// **'Heian Divine Wind'**
  String get moduleTitle_HeianWindModuleProperties;

  /// No description provided for @moduleDesc_HeianWindModuleProperties.
  ///
  /// In en, this message translates to:
  /// **'Wind that pushes zombies and knocks plants into the air'**
  String get moduleDesc_HeianWindModuleProperties;

  /// No description provided for @heianWindModuleHelpTitle.
  ///
  /// In en, this message translates to:
  /// **'Heian Divine Wind module'**
  String get heianWindModuleHelpTitle;

  /// No description provided for @heianWindModuleHelpOverview.
  ///
  /// In en, this message translates to:
  /// **'Overview'**
  String get heianWindModuleHelpOverview;

  /// No description provided for @heianWindModuleHelpOverviewBody.
  ///
  /// In en, this message translates to:
  /// **'This module is used to summon Divine Wind at specified waves, commonly seen in Heian Ages levels. The wind pushes a set number of small and medium zombies within its range horizontally. After all winds in a wave finish, rows affected by single-row winds will generate a whirlwind (one per row). The whirlwind carries zombies forward and knocks plants into the air on contact before disappearing.'**
  String get heianWindModuleHelpOverviewBody;

  /// No description provided for @heianWindModuleHelpDistance.
  ///
  /// In en, this message translates to:
  /// **'Distance'**
  String get heianWindModuleHelpDistance;

  /// No description provided for @heianWindModuleHelpDistanceBody.
  ///
  /// In en, this message translates to:
  /// **'1 tile = 50 distance units. Negative values push zombies to the left, while positive values push them to the right.'**
  String get heianWindModuleHelpDistanceBody;

  /// No description provided for @heianWindModuleHelpRow.
  ///
  /// In en, this message translates to:
  /// **'Coverage'**
  String get heianWindModuleHelpRow;

  /// No description provided for @heianWindModuleHelpRowBody.
  ///
  /// In en, this message translates to:
  /// **'Each entry’s wave index is 0-based (e.g., 0 = first wave, 1 = second wave). Target rows are also indexed from 0. You can specify a single row or set it to -1 to affect all rows; in this case, no whirlwind will be generated.'**
  String get heianWindModuleHelpRowBody;

  /// No description provided for @heianWindModuleWaves.
  ///
  /// In en, this message translates to:
  /// **'Appear waves (WaveNumber)'**
  String get heianWindModuleWaves;

  /// No description provided for @heianWindModuleWavesHint.
  ///
  /// In en, this message translates to:
  /// **'starts from 0'**
  String get heianWindModuleWavesHint;

  /// No description provided for @heianWindModuleAppearances.
  ///
  /// In en, this message translates to:
  /// **'Summon Batches'**
  String get heianWindModuleAppearances;

  /// No description provided for @heianWindModuleWindDelay.
  ///
  /// In en, this message translates to:
  /// **'Time between wind spawns (WindDelay; seconds)'**
  String get heianWindModuleWindDelay;

  /// No description provided for @heianWindModuleWindDelayHint.
  ///
  /// In en, this message translates to:
  /// **'seconds'**
  String get heianWindModuleWindDelayHint;

  /// No description provided for @heianWindModuleWindEntries.
  ///
  /// In en, this message translates to:
  /// **'Wind configurations'**
  String get heianWindModuleWindEntries;

  /// No description provided for @heianWindModuleAddWind.
  ///
  /// In en, this message translates to:
  /// **'Add wind'**
  String get heianWindModuleAddWind;

  /// No description provided for @heianWindModuleRow.
  ///
  /// In en, this message translates to:
  /// **'Affected row (Row)'**
  String get heianWindModuleRow;

  /// No description provided for @heianWindModuleAllRows.
  ///
  /// In en, this message translates to:
  /// **'All rows (-1)'**
  String get heianWindModuleAllRows;

  /// No description provided for @heianWindModuleAffectZombies.
  ///
  /// In en, this message translates to:
  /// **'Affected zombie count (AffectZombies)'**
  String get heianWindModuleAffectZombies;

  /// No description provided for @heianWindModuleDistance.
  ///
  /// In en, this message translates to:
  /// **'Push Distance (Distance)'**
  String get heianWindModuleDistance;

  /// No description provided for @heianWindModuleDistanceHint.
  ///
  /// In en, this message translates to:
  /// **'1 tile = 50 units'**
  String get heianWindModuleDistanceHint;

  /// No description provided for @heianWindModuleMoveTime.
  ///
  /// In en, this message translates to:
  /// **'Move duration (MoveTime; seconds)'**
  String get heianWindModuleMoveTime;

  /// No description provided for @heianWindModuleMoveTimeHint.
  ///
  /// In en, this message translates to:
  /// **'seconds'**
  String get heianWindModuleMoveTimeHint;

  /// No description provided for @heianWindModuleExpectationLabel.
  ///
  /// In en, this message translates to:
  /// **'Divine Wind Settings'**
  String get heianWindModuleExpectationLabel;

  /// No description provided for @jsonViewerModeReading.
  ///
  /// In en, this message translates to:
  /// **'(plain text view)'**
  String get jsonViewerModeReading;

  /// No description provided for @jsonViewerModeObjectReading.
  ///
  /// In en, this message translates to:
  /// **'(structured view)'**
  String get jsonViewerModeObjectReading;

  /// No description provided for @jsonViewerModeEdit.
  ///
  /// In en, this message translates to:
  /// **'(edit mode)'**
  String get jsonViewerModeEdit;

  /// No description provided for @jsonViewerFontSize.
  ///
  /// In en, this message translates to:
  /// **'Font size'**
  String get jsonViewerFontSize;

  /// No description provided for @jsonViewerSearchHint.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get jsonViewerSearchHint;

  /// No description provided for @jsonViewerReplaceHint.
  ///
  /// In en, this message translates to:
  /// **'Replace'**
  String get jsonViewerReplaceHint;

  /// No description provided for @jsonViewerSearchHistory.
  ///
  /// In en, this message translates to:
  /// **'Recent searches'**
  String get jsonViewerSearchHistory;

  /// No description provided for @jsonViewerReplaceHistory.
  ///
  /// In en, this message translates to:
  /// **'Recent replacements'**
  String get jsonViewerReplaceHistory;

  /// No description provided for @jsonViewerInsertNewline.
  ///
  /// In en, this message translates to:
  /// **'Insert newline'**
  String get jsonViewerInsertNewline;

  /// No description provided for @jsonViewerMatchCase.
  ///
  /// In en, this message translates to:
  /// **'Match case'**
  String get jsonViewerMatchCase;

  /// No description provided for @jsonViewerWholeWords.
  ///
  /// In en, this message translates to:
  /// **'Words'**
  String get jsonViewerWholeWords;

  /// No description provided for @jsonViewerRegex.
  ///
  /// In en, this message translates to:
  /// **'Regex'**
  String get jsonViewerRegex;

  /// No description provided for @jsonViewerPreviousMatch.
  ///
  /// In en, this message translates to:
  /// **'Previous match'**
  String get jsonViewerPreviousMatch;

  /// No description provided for @jsonViewerNextMatch.
  ///
  /// In en, this message translates to:
  /// **'Next match'**
  String get jsonViewerNextMatch;

  /// No description provided for @jsonViewerReplaceOne.
  ///
  /// In en, this message translates to:
  /// **'Replace'**
  String get jsonViewerReplaceOne;

  /// No description provided for @jsonViewerReplaceAll.
  ///
  /// In en, this message translates to:
  /// **'Replace all'**
  String get jsonViewerReplaceAll;

  /// No description provided for @jsonViewerMatchCounter.
  ///
  /// In en, this message translates to:
  /// **'{current} of {total}'**
  String jsonViewerMatchCounter(int current, int total);

  /// No description provided for @tooltipAboutModule.
  ///
  /// In en, this message translates to:
  /// **'About this module'**
  String get tooltipAboutModule;

  /// No description provided for @tooltipAboutSection.
  ///
  /// In en, this message translates to:
  /// **'About this section'**
  String get tooltipAboutSection;

  /// No description provided for @tooltipAboutEvent.
  ///
  /// In en, this message translates to:
  /// **'About this event'**
  String get tooltipAboutEvent;

  /// No description provided for @tooltipSave.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get tooltipSave;

  /// No description provided for @tooltipEdit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get tooltipEdit;

  /// No description provided for @tooltipClose.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get tooltipClose;

  /// No description provided for @tooltipToggleObjectView.
  ///
  /// In en, this message translates to:
  /// **'Toggle plain text / structured view'**
  String get tooltipToggleObjectView;

  /// No description provided for @tooltipClearUnused.
  ///
  /// In en, this message translates to:
  /// **'Clear unused objects'**
  String get tooltipClearUnused;

  /// No description provided for @tooltipCopyJson.
  ///
  /// In en, this message translates to:
  /// **'Copy level JSON'**
  String get tooltipCopyJson;

  /// No description provided for @tooltipCopyObject.
  ///
  /// In en, this message translates to:
  /// **'Copy object JSON'**
  String get tooltipCopyObject;

  /// No description provided for @tooltipMore.
  ///
  /// In en, this message translates to:
  /// **'More'**
  String get tooltipMore;

  /// No description provided for @jsonViewerCopied.
  ///
  /// In en, this message translates to:
  /// **'JSON copied to clipboard'**
  String get jsonViewerCopied;

  /// No description provided for @tooltipJsonViewer.
  ///
  /// In en, this message translates to:
  /// **'View/edit JSON'**
  String get tooltipJsonViewer;

  /// No description provided for @bungeeWaveEventHelpTitle.
  ///
  /// In en, this message translates to:
  /// **'Bungee Drop'**
  String get bungeeWaveEventHelpTitle;

  /// No description provided for @bungeeWaveEventHelpOverview.
  ///
  /// In en, this message translates to:
  /// **'Configures the zombie type and drop position for Bungee Zombie deployment. Each event can drop only one zombie.'**
  String get bungeeWaveEventHelpOverview;

  /// No description provided for @bungeeWaveEventHelpGrid.
  ///
  /// In en, this message translates to:
  /// **'Coordinates'**
  String get bungeeWaveEventHelpGrid;

  /// No description provided for @bungeeWaveEventHelpGridBody.
  ///
  /// In en, this message translates to:
  /// **'Tap a cell in the grid to set where the Bungee Zombie will land.'**
  String get bungeeWaveEventHelpGridBody;

  /// No description provided for @bungeeWaveCurrentTarget.
  ///
  /// In en, this message translates to:
  /// **'Current target'**
  String get bungeeWaveCurrentTarget;

  /// No description provided for @bungeeWaveCol.
  ///
  /// In en, this message translates to:
  /// **'Column'**
  String get bungeeWaveCol;

  /// No description provided for @bungeeWaveRow.
  ///
  /// In en, this message translates to:
  /// **'Row'**
  String get bungeeWaveRow;

  /// No description provided for @bungeeWavePropertiesConfig.
  ///
  /// In en, this message translates to:
  /// **'Properties'**
  String get bungeeWavePropertiesConfig;

  /// No description provided for @bungeeWaveZombieLevel.
  ///
  /// In en, this message translates to:
  /// **'Zombie level (Level)'**
  String get bungeeWaveZombieLevel;

  /// No description provided for @bungeeWaveRoofWarning.
  ///
  /// In en, this message translates to:
  /// **'In Roof levels, if a Bungee Zombie spawned by this event is blocked by Umbrella Leaf, it may immediately trigger a loss. Use with caution.'**
  String get bungeeWaveRoofWarning;

  /// No description provided for @moduleTitle_LevelMutatorRiftTimedSunProps.
  ///
  /// In en, this message translates to:
  /// **'Zombie Sun Drop'**
  String get moduleTitle_LevelMutatorRiftTimedSunProps;

  /// No description provided for @moduleDesc_LevelMutatorRiftTimedSunProps.
  ///
  /// In en, this message translates to:
  /// **'Zombies drop sun when defeated'**
  String get moduleDesc_LevelMutatorRiftTimedSunProps;

  /// No description provided for @zombieSunDropHelpTitle.
  ///
  /// In en, this message translates to:
  /// **'Zombie Sun Drop module'**
  String get zombieSunDropHelpTitle;

  /// No description provided for @zombieSunDropHelpOverview.
  ///
  /// In en, this message translates to:
  /// **'This module is used to configure how much sun specific zombies drop in a level, mainly for Penny\'s Pursuit Level 5. As a side effect, the Sun Shovel becomes ineffective.'**
  String get zombieSunDropHelpOverview;

  /// No description provided for @zombieSunDropHelpValues.
  ///
  /// In en, this message translates to:
  /// **'Values'**
  String get zombieSunDropHelpValues;

  /// No description provided for @zombieSunDropHelpValuesBody.
  ///
  /// In en, this message translates to:
  /// **'Six integer values correspond to sun dropped at levels 1–6. For levels above 6, the value for level 1 will be used.'**
  String get zombieSunDropHelpValuesBody;

  /// No description provided for @zombieSunDropEmpty.
  ///
  /// In en, this message translates to:
  /// **'No configuration yet. Tap the \"+\" button in the bottom right to add.'**
  String get zombieSunDropEmpty;

  /// No description provided for @zombieSunDropDefaultDrop.
  ///
  /// In en, this message translates to:
  /// **'Default drop'**
  String get zombieSunDropDefaultDrop;

  /// No description provided for @zombieSunDropSun.
  ///
  /// In en, this message translates to:
  /// **'sun'**
  String get zombieSunDropSun;

  /// No description provided for @zombieSunDropEditTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit values'**
  String get zombieSunDropEditTitle;

  /// No description provided for @zombieSunDropEditHint.
  ///
  /// In en, this message translates to:
  /// **'Configure this zombie\'s sun drops for levels 1–6; for levels above 6, the level 1 value will be used'**
  String get zombieSunDropEditHint;

  /// No description provided for @zombieSunDropTierLabel.
  ///
  /// In en, this message translates to:
  /// **'Level {tier}'**
  String zombieSunDropTierLabel(int tier);

  /// No description provided for @moduleTitle_PickupCollectableTutorialProperties.
  ///
  /// In en, this message translates to:
  /// **'Pickup Collectible Tutorial'**
  String get moduleTitle_PickupCollectableTutorialProperties;

  /// No description provided for @moduleDesc_PickupCollectableTutorialProperties.
  ///
  /// In en, this message translates to:
  /// **'Shows tutorial dialog boxes when specific zombies are defeated'**
  String get moduleDesc_PickupCollectableTutorialProperties;

  /// No description provided for @pickupCollectableTutorialHelpTitle.
  ///
  /// In en, this message translates to:
  /// **'Pickup Collectible Tutorial module'**
  String get pickupCollectableTutorialHelpTitle;

  /// No description provided for @pickupCollectableTutorialHelpBasic.
  ///
  /// In en, this message translates to:
  /// **'Overview'**
  String get pickupCollectableTutorialHelpBasic;

  /// No description provided for @pickupCollectableTutorialHelpBasicBody.
  ///
  /// In en, this message translates to:
  /// **'Configures zombies that drop specific items and the guidance text shown before and after picking them up. A dialog box will appear when this type of zombie (including custom zombies) is defeated for the first time in the level.'**
  String get pickupCollectableTutorialHelpBasicBody;

  /// No description provided for @pickupCollectableTutorialHelpDialogs.
  ///
  /// In en, this message translates to:
  /// **'Dialogs'**
  String get pickupCollectableTutorialHelpDialogs;

  /// No description provided for @pickupCollectableTutorialHelpDialogsBody.
  ///
  /// In en, this message translates to:
  /// **'Dialogs will appear before and after picking up the item. These dialogs pause level progression and delay the next wave.'**
  String get pickupCollectableTutorialHelpDialogsBody;

  /// No description provided for @pickupCollectableTutorialCoreConfig.
  ///
  /// In en, this message translates to:
  /// **'Core configuration'**
  String get pickupCollectableTutorialCoreConfig;

  /// No description provided for @pickupCollectableTutorialZombieLabel.
  ///
  /// In en, this message translates to:
  /// **'Item-carrying zombie'**
  String get pickupCollectableTutorialZombieLabel;

  /// No description provided for @pickupCollectableTutorialLootType.
  ///
  /// In en, this message translates to:
  /// **'Item type'**
  String get pickupCollectableTutorialLootType;

  /// No description provided for @pickupCollectableTutorialGuideText.
  ///
  /// In en, this message translates to:
  /// **'Guidance text'**
  String get pickupCollectableTutorialGuideText;

  /// No description provided for @pickupCollectableTutorialPickupAdvice.
  ///
  /// In en, this message translates to:
  /// **'Pre-pickup dialog (PickupAdvice)'**
  String get pickupCollectableTutorialPickupAdvice;

  /// No description provided for @pickupCollectableTutorialPostPickupAdvice.
  ///
  /// In en, this message translates to:
  /// **'Post-pickup dialog (PostPickupAdvice)'**
  String get pickupCollectableTutorialPostPickupAdvice;

  /// No description provided for @pickupCollectableTutorialNotSet.
  ///
  /// In en, this message translates to:
  /// **'Not set'**
  String get pickupCollectableTutorialNotSet;

  /// No description provided for @pickupCollectableLootGoldCoin.
  ///
  /// In en, this message translates to:
  /// **'Coin'**
  String get pickupCollectableLootGoldCoin;

  /// No description provided for @invalidRtonMagic.
  ///
  /// In en, this message translates to:
  /// **'Invalid RTON file: magic must be \"RTON\".'**
  String get invalidRtonMagic;

  /// No description provided for @invalidRtonVersion.
  ///
  /// In en, this message translates to:
  /// **'Invalid RTON version (expected 1).'**
  String get invalidRtonVersion;

  /// No description provided for @invalidRtonEnd.
  ///
  /// In en, this message translates to:
  /// **'Invalid RTON file: must end with \"DONE\".'**
  String get invalidRtonEnd;

  /// No description provided for @invalidRtonArrayEnd.
  ///
  /// In en, this message translates to:
  /// **'Invalid RTON array delimiter.'**
  String get invalidRtonArrayEnd;

  /// No description provided for @invalidRtid.
  ///
  /// In en, this message translates to:
  /// **'Invalid RTID value.'**
  String get invalidRtid;

  /// No description provided for @invalidValueType.
  ///
  /// In en, this message translates to:
  /// **'Invalid value type for RTON.'**
  String get invalidValueType;

  /// No description provided for @musicSuffix.
  ///
  /// In en, this message translates to:
  /// **'Music settings'**
  String get musicSuffix;

  /// No description provided for @ambientAudioSuffix.
  ///
  /// In en, this message translates to:
  /// **'Ambient audio settings'**
  String get ambientAudioSuffix;

  /// No description provided for @selectMusicSuffix.
  ///
  /// In en, this message translates to:
  /// **'Select music settings'**
  String get selectMusicSuffix;

  /// No description provided for @searchMusicSuffix.
  ///
  /// In en, this message translates to:
  /// **'Search by name or codename'**
  String get searchMusicSuffix;

  /// No description provided for @noMusicSuffixFound.
  ///
  /// In en, this message translates to:
  /// **'No music settings found'**
  String get noMusicSuffixFound;

  /// No description provided for @jsonViewerLineContinuation.
  ///
  /// In en, this message translates to:
  /// **'↳'**
  String get jsonViewerLineContinuation;

  /// No description provided for @zombossMechCustomVariation.
  ///
  /// In en, this message translates to:
  /// **'Custom'**
  String get zombossMechCustomVariation;

  /// No description provided for @editCustomZombossMech.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get editCustomZombossMech;

  /// No description provided for @customZombossMechProperties.
  ///
  /// In en, this message translates to:
  /// **'Custom Zomboss Mech properties'**
  String get customZombossMechProperties;

  /// No description provided for @customZombossMechScalars.
  ///
  /// In en, this message translates to:
  /// **'Movement Parameters'**
  String get customZombossMechScalars;

  /// No description provided for @customZombossMechStages.
  ///
  /// In en, this message translates to:
  /// **'Mech Phases'**
  String get customZombossMechStages;

  /// No description provided for @customZombossMechEditHint.
  ///
  /// In en, this message translates to:
  /// **'Edit the properties of the custom mech variation (memo) used in the level. Custom Zomboss mechs are commonly found in Memory Lane levels.'**
  String get customZombossMechEditHint;

  /// No description provided for @zombossMechMinColumn.
  ///
  /// In en, this message translates to:
  /// **'Min column'**
  String get zombossMechMinColumn;

  /// No description provided for @zombossMechMaxColumn.
  ///
  /// In en, this message translates to:
  /// **'Max column'**
  String get zombossMechMaxColumn;

  /// No description provided for @zombossMechSquashZombies.
  ///
  /// In en, this message translates to:
  /// **'Can squash zombies'**
  String get zombossMechSquashZombies;

  /// No description provided for @zombossMechSquashGridItems.
  ///
  /// In en, this message translates to:
  /// **'Can squash grid items'**
  String get zombossMechSquashGridItems;

  /// No description provided for @zombossMultipleModuleSelectionHint.
  ///
  /// In en, this message translates to:
  /// **'Multiple Boss modules were found. Select the instance to edit from the module list in Level Settings.'**
  String get zombossMultipleModuleSelectionHint;

  /// No description provided for @zombossMechActions.
  ///
  /// In en, this message translates to:
  /// **'Actions'**
  String get zombossMechActions;

  /// No description provided for @zombossMechPropertiesLabel.
  ///
  /// In en, this message translates to:
  /// **'Properties'**
  String get zombossMechPropertiesLabel;

  /// No description provided for @zombossMechAliasLabel.
  ///
  /// In en, this message translates to:
  /// **'Alias (English letters only; no spaces)'**
  String get zombossMechAliasLabel;

  /// No description provided for @zombossMechDeletePhase.
  ///
  /// In en, this message translates to:
  /// **'Delete phase'**
  String get zombossMechDeletePhase;

  /// No description provided for @zombossMechDeletePhaseTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete phase {number}?'**
  String zombossMechDeletePhaseTitle(int number);

  /// No description provided for @zombossMechDeletePhaseMessage.
  ///
  /// In en, this message translates to:
  /// **'This removes the phase and its action list. This cannot be undone.'**
  String get zombossMechDeletePhaseMessage;

  /// No description provided for @zombossMechDeleteEightiesPhaseMessage.
  ///
  /// In en, this message translates to:
  /// **'This removes the phase, its action list, and the corresponding music and Zomboss animation. This cannot be undone.'**
  String get zombossMechDeleteEightiesPhaseMessage;

  /// No description provided for @zombossMechStageJamOrder.
  ///
  /// In en, this message translates to:
  /// **'Music playback order (StageJamOrder)'**
  String get zombossMechStageJamOrder;

  /// No description provided for @zombossMechZombossAnimOrder.
  ///
  /// In en, this message translates to:
  /// **'Zomboss animation order (ZombossAnimOrder)'**
  String get zombossMechZombossAnimOrder;

  /// No description provided for @zombossMechAddEightiesPhaseTitle.
  ///
  /// In en, this message translates to:
  /// **'Choose music and Zomboss animation for the new phase'**
  String get zombossMechAddEightiesPhaseTitle;

  /// No description provided for @zombossMechEightiesPhaseSelectionRequired.
  ///
  /// In en, this message translates to:
  /// **'Select both the music played during this phase and the Zomboss animation it uses before creating the phase.'**
  String get zombossMechEightiesPhaseSelectionRequired;

  /// No description provided for @zombossMechCreatePhase.
  ///
  /// In en, this message translates to:
  /// **'Create phase'**
  String get zombossMechCreatePhase;

  /// No description provided for @zombossAnimNewWave.
  ///
  /// In en, this message translates to:
  /// **'New Wave'**
  String get zombossAnimNewWave;

  /// No description provided for @zombossAnimHipHop.
  ///
  /// In en, this message translates to:
  /// **'Hip-Hop'**
  String get zombossAnimHipHop;

  /// No description provided for @zombossMechOrphanActionDeleteTitle.
  ///
  /// In en, this message translates to:
  /// **'Remove custom action data?'**
  String get zombossMechOrphanActionDeleteTitle;

  /// No description provided for @zombossMechOrphanActionDeleteMessage.
  ///
  /// In en, this message translates to:
  /// **'\"{alias}\" is no longer used in this level. Remove its action object from the level file?'**
  String zombossMechOrphanActionDeleteMessage(String alias);

  /// No description provided for @zombossMechPhasesHelp.
  ///
  /// In en, this message translates to:
  /// **'Each phase can be configured independently with parameters such as the mech\'s health, available actions, and the retreat action performed when transitioning between phases. Actions in the list are executed based on the weights and repeat counts defined in their individual action properties; they are not executed sequentially in list order.'**
  String get zombossMechPhasesHelp;

  /// No description provided for @zombossMechPhasesHelpTitle.
  ///
  /// In en, this message translates to:
  /// **'Phase contents'**
  String get zombossMechPhasesHelpTitle;

  /// No description provided for @zombossMechAddAction.
  ///
  /// In en, this message translates to:
  /// **'Add action'**
  String get zombossMechAddAction;

  /// No description provided for @zombossMechNoStageActions.
  ///
  /// In en, this message translates to:
  /// **'No actions yet'**
  String get zombossMechNoStageActions;

  /// No description provided for @zombossMechSelectAction.
  ///
  /// In en, this message translates to:
  /// **'Select action'**
  String get zombossMechSelectAction;

  /// No description provided for @zombossMechSummonJump.
  ///
  /// In en, this message translates to:
  /// **'Summon jump'**
  String get zombossMechSummonJump;

  /// No description provided for @zombossMechSelectRetreatAction.
  ///
  /// In en, this message translates to:
  /// **'Select retreat action'**
  String get zombossMechSelectRetreatAction;

  /// No description provided for @zombossMechCreateCustomAction.
  ///
  /// In en, this message translates to:
  /// **'New custom action'**
  String get zombossMechCreateCustomAction;

  /// No description provided for @zombossMechEditCustomAction.
  ///
  /// In en, this message translates to:
  /// **'Edit custom action'**
  String get zombossMechEditCustomAction;

  /// No description provided for @zombossMechActionCategoryAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get zombossMechActionCategoryAll;

  /// No description provided for @zombossMechActionCategoryMovement.
  ///
  /// In en, this message translates to:
  /// **'Movement'**
  String get zombossMechActionCategoryMovement;

  /// No description provided for @zombossMechActionCategoryAttack.
  ///
  /// In en, this message translates to:
  /// **'Attack'**
  String get zombossMechActionCategoryAttack;

  /// No description provided for @zombossMechActionCategorySpecial.
  ///
  /// In en, this message translates to:
  /// **'Special'**
  String get zombossMechActionCategorySpecial;

  /// No description provided for @zombossMechActionCategorySpawn.
  ///
  /// In en, this message translates to:
  /// **'Summon'**
  String get zombossMechActionCategorySpawn;

  /// No description provided for @zombossMechActionCategoryCustom.
  ///
  /// In en, this message translates to:
  /// **'Custom'**
  String get zombossMechActionCategoryCustom;

  /// No description provided for @zombossMechActionCategoryRetreat.
  ///
  /// In en, this message translates to:
  /// **'Retreat'**
  String get zombossMechActionCategoryRetreat;

  /// No description provided for @zombossMechNoActionsFound.
  ///
  /// In en, this message translates to:
  /// **'No actions found'**
  String get zombossMechNoActionsFound;

  /// No description provided for @zombossCustomActionBaseAction.
  ///
  /// In en, this message translates to:
  /// **'Base Action: {action}'**
  String zombossCustomActionBaseAction(String action);

  /// No description provided for @zombossPresetDerivedBaseAction.
  ///
  /// In en, this message translates to:
  /// **'Based on Preset Custom Action: {action}'**
  String zombossPresetDerivedBaseAction(String action);

  /// No description provided for @zombossMechActionAliasHint.
  ///
  /// In en, this message translates to:
  /// **'The reference name used for a custom action within the level. It is used to form RTID(Name@CurrentLevel) references for related entries in the mech properties. This name can be changed at any time, and any existing related RTID references in the properties will be updated automatically.'**
  String get zombossMechActionAliasHint;

  /// No description provided for @zombossMechActionBaseObjclass.
  ///
  /// In en, this message translates to:
  /// **'Action Type (objclass)'**
  String get zombossMechActionBaseObjclass;

  /// No description provided for @zombossMechActionBaseAction.
  ///
  /// In en, this message translates to:
  /// **'Base Action'**
  String get zombossMechActionBaseAction;

  /// No description provided for @zombossMechActionTemplateHint.
  ///
  /// In en, this message translates to:
  /// **'Pick a built-in action to copy its type and default values. You can edit everything after creating.'**
  String get zombossMechActionTemplateHint;

  /// No description provided for @zombossMechRecreateFromTemplate.
  ///
  /// In en, this message translates to:
  /// **'Recreate from template'**
  String get zombossMechRecreateFromTemplate;

  /// No description provided for @zombossMechRecreateFromTemplateTitle.
  ///
  /// In en, this message translates to:
  /// **'Replace this action?'**
  String get zombossMechRecreateFromTemplateTitle;

  /// No description provided for @zombossMechRecreateFromTemplateMessage.
  ///
  /// In en, this message translates to:
  /// **'This replaces the action type (objclass) and all field values with the selected template. Your current values will be lost.'**
  String get zombossMechRecreateFromTemplateMessage;

  /// No description provided for @zombossMechBaseActionAliasSyncTitle.
  ///
  /// In en, this message translates to:
  /// **'Update the action codename?'**
  String get zombossMechBaseActionAliasSyncTitle;

  /// No description provided for @zombossMechBaseActionAliasSyncMessage.
  ///
  /// In en, this message translates to:
  /// **'After changing the base action, also update the action codename to \"{alias}\"?'**
  String zombossMechBaseActionAliasSyncMessage(String alias);

  /// No description provided for @zombossMechBaseActionAliasKeep.
  ///
  /// In en, this message translates to:
  /// **'Keep Current Codename'**
  String get zombossMechBaseActionAliasKeep;

  /// No description provided for @zombossMechBaseActionAliasUpdate.
  ///
  /// In en, this message translates to:
  /// **'Update Codename'**
  String get zombossMechBaseActionAliasUpdate;

  /// No description provided for @zombossMechActionDetails.
  ///
  /// In en, this message translates to:
  /// **'Action Details'**
  String get zombossMechActionDetails;

  /// No description provided for @zombossMechActionRtid.
  ///
  /// In en, this message translates to:
  /// **'RTID'**
  String get zombossMechActionRtid;

  /// No description provided for @zombossMechActionFields.
  ///
  /// In en, this message translates to:
  /// **'Action Fields'**
  String get zombossMechActionFields;

  /// No description provided for @zombossMechPropertiesViewTitle.
  ///
  /// In en, this message translates to:
  /// **'Zomboss Mech Properties'**
  String get zombossMechPropertiesViewTitle;

  /// No description provided for @viewZombossMechProperties.
  ///
  /// In en, this message translates to:
  /// **'View properties'**
  String get viewZombossMechProperties;

  /// No description provided for @zombossMechEditRetreatAction.
  ///
  /// In en, this message translates to:
  /// **'Choose retreat action'**
  String get zombossMechEditRetreatAction;

  /// No description provided for @zombossMechAddZombie.
  ///
  /// In en, this message translates to:
  /// **'Add zombie'**
  String get zombossMechAddZombie;

  /// No description provided for @zombossMechPickZombie.
  ///
  /// In en, this message translates to:
  /// **'Pick zombie'**
  String get zombossMechPickZombie;

  /// No description provided for @zombossMechNoZombiesInList.
  ///
  /// In en, this message translates to:
  /// **'No zombies in list'**
  String get zombossMechNoZombiesInList;

  /// No description provided for @zombossMechSpawnBallSettings.
  ///
  /// In en, this message translates to:
  /// **'Drop Configuration (ZombieDropProps)'**
  String get zombossMechSpawnBallSettings;

  /// No description provided for @zombossMechAwardDropInvalidTitle.
  ///
  /// In en, this message translates to:
  /// **'Invalid SpawnBall reference'**
  String get zombossMechAwardDropInvalidTitle;

  /// No description provided for @zombossMechAwardDropInvalidBody.
  ///
  /// In en, this message translates to:
  /// **'AwardDrop points to \"{rtid}\", but it is not a valid CurrentLevel ZombieDropProps object. The game may fail to load this action.'**
  String zombossMechAwardDropInvalidBody(String rtid);

  /// No description provided for @zombossMechAwardDropClearInvalid.
  ///
  /// In en, this message translates to:
  /// **'Clear invalid value and restore default'**
  String get zombossMechAwardDropClearInvalid;

  /// No description provided for @zombossMechOpenGlacierModule.
  ///
  /// In en, this message translates to:
  /// **'Go to Ice Chunk Module settings'**
  String get zombossMechOpenGlacierModule;

  /// No description provided for @zombossMechConfigureInitialGridItems.
  ///
  /// In en, this message translates to:
  /// **'Configure preset grid items'**
  String get zombossMechConfigureInitialGridItems;

  /// No description provided for @zombossMechEightiesSpeakerPresetPromptTitle.
  ///
  /// In en, this message translates to:
  /// **'Pre-place the Zomboss\' speakers?'**
  String get zombossMechEightiesSpeakerPresetPromptTitle;

  /// No description provided for @zombossMechEightiesSpeakerPresetPrompt.
  ///
  /// In en, this message translates to:
  /// **'The first phase of the Neon Mixtape Tour Zomboss usually relies on dedicated speakers on the lawn to support its abilities, so official levels pre-place speakers at specific positions on the lawn.\nYou are about to switch to the Neon Mixtape Tour Zomboss. Would you like to place these speakers at the same positions used in the official levels?'**
  String get zombossMechEightiesSpeakerPresetPrompt;

  /// No description provided for @zombossMechSwitchBaseOnly.
  ///
  /// In en, this message translates to:
  /// **'Switch mech only'**
  String get zombossMechSwitchBaseOnly;

  /// No description provided for @zombossMechPreplaceSpeakers.
  ///
  /// In en, this message translates to:
  /// **'Pre-place speakers'**
  String get zombossMechPreplaceSpeakers;

  /// No description provided for @zombossMechEightiesSpeakerRemovePromptTitle.
  ///
  /// In en, this message translates to:
  /// **'Remove the Zomboss\' speakers?'**
  String get zombossMechEightiesSpeakerRemovePromptTitle;

  /// No description provided for @zombossMechEightiesSpeakerRemovePrompt.
  ///
  /// In en, this message translates to:
  /// **'You are about to switch from the Neon Mixtape Tour Zomboss to another base mech. Would you like to remove the dedicated speakers that were previously placed at the official positions? \nOnly speakers that are still Zomboss speakers at those positions will be removed; anything you later replaced them with will be left unchanged.'**
  String get zombossMechEightiesSpeakerRemovePrompt;

  /// No description provided for @zombossMechKeepSpeakers.
  ///
  /// In en, this message translates to:
  /// **'Keep speakers'**
  String get zombossMechKeepSpeakers;

  /// No description provided for @zombossMechRemoveSpeakers.
  ///
  /// In en, this message translates to:
  /// **'Remove speakers'**
  String get zombossMechRemoveSpeakers;

  /// No description provided for @zombossMechRobotSpawnRow.
  ///
  /// In en, this message translates to:
  /// **'Row'**
  String get zombossMechRobotSpawnRow;

  /// No description provided for @zombossMechRobotSpawnRowRandom.
  ///
  /// In en, this message translates to:
  /// **'Random (-1)'**
  String get zombossMechRobotSpawnRowRandom;

  /// No description provided for @zombossMechRobotSpawnLevel.
  ///
  /// In en, this message translates to:
  /// **'Level'**
  String get zombossMechRobotSpawnLevel;

  /// No description provided for @zombossMechRobotSpawnWeight.
  ///
  /// In en, this message translates to:
  /// **'Weight'**
  String get zombossMechRobotSpawnWeight;

  /// No description provided for @zombossMechRobotSpawnPlantfood.
  ///
  /// In en, this message translates to:
  /// **'Carries Plant Food'**
  String get zombossMechRobotSpawnPlantfood;

  /// No description provided for @zombossMechRetreatAction.
  ///
  /// In en, this message translates to:
  /// **'Retreat action'**
  String get zombossMechRetreatAction;

  /// No description provided for @zombossMechPhaseNumber.
  ///
  /// In en, this message translates to:
  /// **'Phase {number}'**
  String zombossMechPhaseNumber(int number);

  /// No description provided for @zombossMechAddPhase.
  ///
  /// In en, this message translates to:
  /// **'Add phase'**
  String get zombossMechAddPhase;

  /// No description provided for @zombossMechHitPoints.
  ///
  /// In en, this message translates to:
  /// **'Health (HitPoints)'**
  String get zombossMechHitPoints;

  /// No description provided for @continueAnyway.
  ///
  /// In en, this message translates to:
  /// **'Continue anyway'**
  String get continueAnyway;

  /// No description provided for @armrackModuleHelpTitle.
  ///
  /// In en, this message translates to:
  /// **'Weapon Stands module'**
  String get armrackModuleHelpTitle;

  /// No description provided for @armrackModuleHelpOverview.
  ///
  /// In en, this message translates to:
  /// **'Overview'**
  String get armrackModuleHelpOverview;

  /// No description provided for @armrackModuleHelpOverviewBody.
  ///
  /// In en, this message translates to:
  /// **'Places weapon stands from Kongfu World at specified positions on the lawn. Kongfu Zombies and Monk Zombies that pass by a Weapon Stand will pick up the weapon on it, transform into the corresponding special zombie, and fully restore their health. The weapon stand will break and disappear either when its own health is depleted or when the weapon on it is picked up.\nThis module also ensures that Weapon Stands display correctly in both the editor and the game, preventing them from incorrectly appearing with a sun texture.'**
  String get armrackModuleHelpOverviewBody;

  /// No description provided for @armrackModuleHelpPlacement.
  ///
  /// In en, this message translates to:
  /// **'Placement'**
  String get armrackModuleHelpPlacement;

  /// No description provided for @armrackModuleHelpPlacementBody.
  ///
  /// In en, this message translates to:
  /// **'Select a weapon stand type, then click an empty tile to place the selected Weapon Stand. Only one can be placed on each tile. Right-click on desktop or long-press on mobile to remove the weapon stand from that tile.'**
  String get armrackModuleHelpPlacementBody;

  /// No description provided for @armrackModuleTypePalette.
  ///
  /// In en, this message translates to:
  /// **'Weapon Stand Type'**
  String get armrackModuleTypePalette;

  /// No description provided for @armrackModuleExpectationLabel.
  ///
  /// In en, this message translates to:
  /// **'Weapon Stands'**
  String get armrackModuleExpectationLabel;

  /// No description provided for @armrackModuleRequiredMessage.
  ///
  /// In en, this message translates to:
  /// **'For weapon stands to display properly without showing sun textures, {moduleName} needs to be added.'**
  String armrackModuleRequiredMessage(String moduleName);

  /// No description provided for @renaiGridItemModuleRequiredMessage.
  ///
  /// In en, this message translates to:
  /// **'The Vitruvian Wheel requires the \"{moduleName}\" to work correctly. Add it?'**
  String renaiGridItemModuleRequiredMessage(String moduleName);

  /// No description provided for @energyGridModuleHelpTitle.
  ///
  /// In en, this message translates to:
  /// **'Taiji Tiles module'**
  String get energyGridModuleHelpTitle;

  /// No description provided for @energyGridModuleHelpOverview.
  ///
  /// In en, this message translates to:
  /// **'Overview'**
  String get energyGridModuleHelpOverview;

  /// No description provided for @energyGridModuleHelpOverviewBody.
  ///
  /// In en, this message translates to:
  /// **'Generates Taiji Tiles at specified positions on the lawn, commonly used in Kongfu World. When a plant is placed on a Taiji Tile, the Taiji emblem begins to flash and generates one Plant Food after 1000 ÷ the plant\'s sun cost seconds, then disappears. If the plant\'s sun cost is 0, no Plant Food will be generated.'**
  String get energyGridModuleHelpOverviewBody;

  /// No description provided for @energyGridModuleHelpPlacement.
  ///
  /// In en, this message translates to:
  /// **'Placement'**
  String get energyGridModuleHelpPlacement;

  /// No description provided for @energyGridModuleHelpPlacementBody.
  ///
  /// In en, this message translates to:
  /// **'Click an empty tile to place a Taiji Tile. Only one can be placed on each tile. Right-click on desktop or long-press on mobile to remove the Taiji Tile from that tile.'**
  String get energyGridModuleHelpPlacementBody;

  /// No description provided for @energyGridModuleTapToPlace.
  ///
  /// In en, this message translates to:
  /// **'Click an empty tile to place a Taiji Tile.'**
  String get energyGridModuleTapToPlace;

  /// No description provided for @energyGridModuleExpectationLabel.
  ///
  /// In en, this message translates to:
  /// **'Taiji Tiles'**
  String get energyGridModuleExpectationLabel;

  /// No description provided for @energyGridModuleWarningMessage.
  ///
  /// In en, this message translates to:
  /// **'Due to a game-side issue, generated Taiji Tiles may appear as purple X markers, but this does not affect their actual functionality.'**
  String get energyGridModuleWarningMessage;

  /// No description provided for @gridOverrideModuleAppearances.
  ///
  /// In en, this message translates to:
  /// **'Wave groups'**
  String get gridOverrideModuleAppearances;

  /// No description provided for @gridOverrideModuleWaveFieldOneBased.
  ///
  /// In en, this message translates to:
  /// **'Wave index'**
  String get gridOverrideModuleWaveFieldOneBased;

  /// No description provided for @gridOverrideModuleInitialWaveNote.
  ///
  /// In en, this message translates to:
  /// **'This group is used for preset grid items. Added grid items will appear on the lawn before the level starts.'**
  String get gridOverrideModuleInitialWaveNote;

  /// No description provided for @gridOverrideModuleWaveSpawnNote.
  ///
  /// In en, this message translates to:
  /// **'Grid items in this group will spawn when Wave Generator wave {waveGeneratorWave} begins.'**
  String gridOverrideModuleWaveSpawnNote(int waveGeneratorWave);

  /// No description provided for @gridOverrideModuleWaveSpawnTimelineNote.
  ///
  /// In en, this message translates to:
  /// **'Due to incompatibilities between the old and new implementations, Wave Manager cannot spawn Grid Items by wave using this module. Please use events such as Grid Item Spawn instead.'**
  String get gridOverrideModuleWaveSpawnTimelineNote;

  /// No description provided for @gridOverrideModuleHelpWaveNumbering.
  ///
  /// In en, this message translates to:
  /// **'Wave index'**
  String get gridOverrideModuleHelpWaveNumbering;

  /// No description provided for @gridOverrideModuleHelpWaveNumberingBody.
  ///
  /// In en, this message translates to:
  /// **'Wave index 1 is used for preset grid items, and added grid items will appear on the lawn before the level starts. Starting from wave index 2, the numbering corresponds directly to Wave Generator waves. For example, wave number 2 corresponds to Wave Generator wave 1, and wave index 3 corresponds to Wave Generator wave 2.'**
  String get gridOverrideModuleHelpWaveNumberingBody;

  /// No description provided for @gridOverridePreviewArmrackTitle.
  ///
  /// In en, this message translates to:
  /// **'Weapon stand layout preview'**
  String get gridOverridePreviewArmrackTitle;

  /// No description provided for @gridOverridePreviewEnergyGridTitle.
  ///
  /// In en, this message translates to:
  /// **'Taiji tile layout preview'**
  String get gridOverridePreviewEnergyGridTitle;

  /// No description provided for @waveGeneratorInitialGridOverridesTitle.
  ///
  /// In en, this message translates to:
  /// **'Manage Initial Kongfu World Grid Items'**
  String get waveGeneratorInitialGridOverridesTitle;

  /// No description provided for @waveGeneratorPreviewInitialArmrack.
  ///
  /// In en, this message translates to:
  /// **'Initial Weapon Stands'**
  String get waveGeneratorPreviewInitialArmrack;

  /// No description provided for @waveGeneratorPreviewInitialEnergyGrid.
  ///
  /// In en, this message translates to:
  /// **'Initial Taiji Tiles'**
  String get waveGeneratorPreviewInitialEnergyGrid;

  /// No description provided for @waveGeneratorGridOverrideWavePreviewTitle.
  ///
  /// In en, this message translates to:
  /// **'Wave {wave} - {label}'**
  String waveGeneratorGridOverrideWavePreviewTitle(int wave, String label);

  /// No description provided for @mechanismPlankStartColumn.
  ///
  /// In en, this message translates to:
  /// **'Starting column (mx)'**
  String get mechanismPlankStartColumn;

  /// No description provided for @mechanismPlankTrackLength.
  ///
  /// In en, this message translates to:
  /// **'Track length (mWidth)'**
  String get mechanismPlankTrackLength;

  /// No description provided for @mechanismPlankEditNotice.
  ///
  /// In en, this message translates to:
  /// **'This interface only supports editing the starting column and track length. All other parameters use preset values, as modifying them may cause Connected Minecarts to malfunction. For further customization, please edit the JSON file manually.\nAdditionally, Connected Minecarts are not recommended outside of Kongfu World, as they are more likely to appear as purple X markers. This does not affect their actual functionality, but it may impact the level\'s visual presentation.'**
  String get mechanismPlankEditNotice;

  /// No description provided for @mechanismPlankOutOfAreaWarning.
  ///
  /// In en, this message translates to:
  /// **'The current rail range may go outside the lawn.'**
  String get mechanismPlankOutOfAreaWarning;

  /// No description provided for @portalTypeEgypt.
  ///
  /// In en, this message translates to:
  /// **'Ancient Egypt'**
  String get portalTypeEgypt;

  /// No description provided for @portalTypeEgypt2.
  ///
  /// In en, this message translates to:
  /// **'Ancient Egypt 2'**
  String get portalTypeEgypt2;

  /// No description provided for @portalTypePirate.
  ///
  /// In en, this message translates to:
  /// **'Pirate Seas'**
  String get portalTypePirate;

  /// No description provided for @portalTypeWest.
  ///
  /// In en, this message translates to:
  /// **'Wild West'**
  String get portalTypeWest;

  /// No description provided for @portalTypeFuture.
  ///
  /// In en, this message translates to:
  /// **'Far Future'**
  String get portalTypeFuture;

  /// No description provided for @portalTypeFuture2.
  ///
  /// In en, this message translates to:
  /// **'Far Future 2'**
  String get portalTypeFuture2;

  /// No description provided for @portalTypeDark.
  ///
  /// In en, this message translates to:
  /// **'Dark Ages'**
  String get portalTypeDark;

  /// No description provided for @portalTypeBeach.
  ///
  /// In en, this message translates to:
  /// **'Big Wave Beach'**
  String get portalTypeBeach;

  /// No description provided for @portalTypeIceAge.
  ///
  /// In en, this message translates to:
  /// **'Frostbite Caves'**
  String get portalTypeIceAge;

  /// No description provided for @portalTypeLostCity.
  ///
  /// In en, this message translates to:
  /// **'Lost City'**
  String get portalTypeLostCity;

  /// No description provided for @portalTypeEighties.
  ///
  /// In en, this message translates to:
  /// **'Neon Mixtape Tour'**
  String get portalTypeEighties;

  /// No description provided for @portalTypeDino.
  ///
  /// In en, this message translates to:
  /// **'Jurassic Marsh'**
  String get portalTypeDino;

  /// No description provided for @portalTypeEndlessEgypt.
  ///
  /// In en, this message translates to:
  /// **'Ancient Egypt (Endless)'**
  String get portalTypeEndlessEgypt;

  /// No description provided for @portalTypeEndlessPirate.
  ///
  /// In en, this message translates to:
  /// **'Pirate Seas (Endless)'**
  String get portalTypeEndlessPirate;

  /// No description provided for @portalTypeEndlessWest.
  ///
  /// In en, this message translates to:
  /// **'Wild West (Endless)'**
  String get portalTypeEndlessWest;

  /// No description provided for @portalTypeEndlessKongfu.
  ///
  /// In en, this message translates to:
  /// **'Kongfu World (Endless)'**
  String get portalTypeEndlessKongfu;

  /// No description provided for @portalTypeEndlessFuture.
  ///
  /// In en, this message translates to:
  /// **'Far Future (Endless)'**
  String get portalTypeEndlessFuture;

  /// No description provided for @portalTypeEndlessDark.
  ///
  /// In en, this message translates to:
  /// **'Dark Ages (Endless)'**
  String get portalTypeEndlessDark;

  /// No description provided for @portalTypeEndlessBeach.
  ///
  /// In en, this message translates to:
  /// **'Big Wave Beach (Endless)'**
  String get portalTypeEndlessBeach;

  /// No description provided for @portalTypeEndlessIceAge.
  ///
  /// In en, this message translates to:
  /// **'Frostbite Caves (Endless)'**
  String get portalTypeEndlessIceAge;

  /// No description provided for @portalTypeEndlessSkyCity.
  ///
  /// In en, this message translates to:
  /// **'Sky City (Endless)'**
  String get portalTypeEndlessSkyCity;

  /// No description provided for @portalTypeEndlessLostCity.
  ///
  /// In en, this message translates to:
  /// **'Lost City (Endless)'**
  String get portalTypeEndlessLostCity;

  /// No description provided for @portalTypeEndlessEighties.
  ///
  /// In en, this message translates to:
  /// **'Neon Mixtape Tour (Endless)'**
  String get portalTypeEndlessEighties;

  /// No description provided for @portalTypeEndlessDino.
  ///
  /// In en, this message translates to:
  /// **'Jurassic Marsh (Endless)'**
  String get portalTypeEndlessDino;

  /// No description provided for @portalTypeEndlessModern.
  ///
  /// In en, this message translates to:
  /// **'Modern Day (Endless)'**
  String get portalTypeEndlessModern;

  /// No description provided for @portalTypeMemoryLane1.
  ///
  /// In en, this message translates to:
  /// **'Memory Lane 1'**
  String get portalTypeMemoryLane1;

  /// No description provided for @portalTypeMemoryLane2.
  ///
  /// In en, this message translates to:
  /// **'Memory Lane 2'**
  String get portalTypeMemoryLane2;

  /// No description provided for @portalTypeMemoryLane3.
  ///
  /// In en, this message translates to:
  /// **'Memory Lane 3'**
  String get portalTypeMemoryLane3;

  /// No description provided for @portalTypeShieldGenerator.
  ///
  /// In en, this message translates to:
  /// **'Shield Generator'**
  String get portalTypeShieldGenerator;

  /// No description provided for @portalTypeGlacialNianSkill.
  ///
  /// In en, this message translates to:
  /// **'Glacial Nian Skill'**
  String get portalTypeGlacialNianSkill;

  /// No description provided for @portalTypeZombotany.
  ///
  /// In en, this message translates to:
  /// **'Zombotany'**
  String get portalTypeZombotany;

  /// No description provided for @portalTypeSlimeZombies.
  ///
  /// In en, this message translates to:
  /// **'Zom-Blob'**
  String get portalTypeSlimeZombies;

  /// No description provided for @portalTypeUniverse42.
  ///
  /// In en, this message translates to:
  /// **'Parallel Universe No. 42'**
  String get portalTypeUniverse42;

  /// No description provided for @portalTypeUniverse41.
  ///
  /// In en, this message translates to:
  /// **'Parallel Universe No. 41'**
  String get portalTypeUniverse41;

  /// No description provided for @portalTypeEliteHealerNormal.
  ///
  /// In en, this message translates to:
  /// **'Elite Healer (Normal)'**
  String get portalTypeEliteHealerNormal;

  /// No description provided for @portalTypeEliteElectricNormal.
  ///
  /// In en, this message translates to:
  /// **'Elite Lightning Gun (Normal)'**
  String get portalTypeEliteElectricNormal;

  /// No description provided for @portalTypeEliteBallistaNormal.
  ///
  /// In en, this message translates to:
  /// **'Elite Zcorpion (Normal)'**
  String get portalTypeEliteBallistaNormal;

  /// No description provided for @portalTypeEliteOnmyojiNormal.
  ///
  /// In en, this message translates to:
  /// **'Elite Onmyoji (Normal)'**
  String get portalTypeEliteOnmyojiNormal;

  /// No description provided for @portalTypeEliteHealerHard.
  ///
  /// In en, this message translates to:
  /// **'Elite Healer (Hard)'**
  String get portalTypeEliteHealerHard;

  /// No description provided for @portalTypeEliteElectricHard.
  ///
  /// In en, this message translates to:
  /// **'Elite Lightning Gun (Hard)'**
  String get portalTypeEliteElectricHard;

  /// No description provided for @portalTypeEliteBallistaHard.
  ///
  /// In en, this message translates to:
  /// **'Elite Zcorpion (Hard)'**
  String get portalTypeEliteBallistaHard;

  /// No description provided for @portalTypeEliteOnmyojiHard.
  ///
  /// In en, this message translates to:
  /// **'Elite Onmyoji (Hard)'**
  String get portalTypeEliteOnmyojiHard;

  /// No description provided for @portalTypeRomeoHard.
  ///
  /// In en, this message translates to:
  /// **'Romeo (Memory Lane)'**
  String get portalTypeRomeoHard;

  /// No description provided for @portalTypeRomeoHard2.
  ///
  /// In en, this message translates to:
  /// **'Romeo 2 (Memory Lane)'**
  String get portalTypeRomeoHard2;

  /// No description provided for @portalTypeJulietHard.
  ///
  /// In en, this message translates to:
  /// **'Juliet (Memory Lane)'**
  String get portalTypeJulietHard;

  /// No description provided for @portalTypeJulietHard2.
  ///
  /// In en, this message translates to:
  /// **'Juliet 2 (Memory Lane)'**
  String get portalTypeJulietHard2;

  /// No description provided for @portalTypeSherlockHard.
  ///
  /// In en, this message translates to:
  /// **'Sherlock (Memory Lane)'**
  String get portalTypeSherlockHard;

  /// No description provided for @portalTypeEliteHunter.
  ///
  /// In en, this message translates to:
  /// **'Elite Hunter'**
  String get portalTypeEliteHunter;

  /// No description provided for @portalTypeEliteChief.
  ///
  /// In en, this message translates to:
  /// **'Elite Chief'**
  String get portalTypeEliteChief;

  /// No description provided for @portalTypeEliteWeasel.
  ///
  /// In en, this message translates to:
  /// **'Elite Weasel Hoarder'**
  String get portalTypeEliteWeasel;

  /// No description provided for @portalTypeEliteBumperCar.
  ///
  /// In en, this message translates to:
  /// **'Elite Bumper Car'**
  String get portalTypeEliteBumperCar;

  /// No description provided for @portalTypeGlacialNian.
  ///
  /// In en, this message translates to:
  /// **'Glacial Nian'**
  String get portalTypeGlacialNian;

  /// No description provided for @portalTypeEliteWizard.
  ///
  /// In en, this message translates to:
  /// **'Elite Wizard'**
  String get portalTypeEliteWizard;

  /// No description provided for @portalTypeEliteKing.
  ///
  /// In en, this message translates to:
  /// **'Elite King'**
  String get portalTypeEliteKing;

  /// No description provided for @portalTypeEliteMirrorQueen.
  ///
  /// In en, this message translates to:
  /// **'Elite Mirror Queen'**
  String get portalTypeEliteMirrorQueen;

  /// No description provided for @waveGeneratorTabLabel.
  ///
  /// In en, this message translates to:
  /// **'Generator Timeline'**
  String get waveGeneratorTabLabel;

  /// No description provided for @waveGeneratorModuleHelpTitle.
  ///
  /// In en, this message translates to:
  /// **'Wave Generator module'**
  String get waveGeneratorModuleHelpTitle;

  /// No description provided for @waveGeneratorModuleHelpOverview.
  ///
  /// In en, this message translates to:
  /// **'Overview'**
  String get waveGeneratorModuleHelpOverview;

  /// No description provided for @waveGeneratorModuleHelpOverviewBody.
  ///
  /// In en, this message translates to:
  /// **'Wave Generator is an early wave system used by Kongfu World, Daily Challenge, and other older levels. Each wave is stored directly in the module instead of using separate wave events.\nGroups in the Weapon Stands and Taiji Tiles modules can correspond one-to-one with Wave Generator waves to produce effects similar to wave events. The Wave Timeline shows where these Kongfu World grid items appear.'**
  String get waveGeneratorModuleHelpOverviewBody;

  /// No description provided for @waveGeneratorModuleHelpSpending.
  ///
  /// In en, this message translates to:
  /// **'Point-based spawning'**
  String get waveGeneratorModuleHelpSpending;

  /// No description provided for @waveGeneratorModuleHelpSpendingBody.
  ///
  /// In en, this message translates to:
  /// **'Random spawns use the points available to the current wave. The game selects by weight from zombies affordable with the remaining points, deducts the selected cost, and filters the candidates again until none are eligible. Unused points do not carry over to the next wave, and fixed spawns consume none of these points.'**
  String get waveGeneratorModuleHelpSpendingBody;

  /// No description provided for @waveGeneratorModuleHelpPointTrajectory.
  ///
  /// In en, this message translates to:
  /// **'Parameters'**
  String get waveGeneratorModuleHelpPointTrajectory;

  /// No description provided for @waveGeneratorModuleHelpPointTrajectoryBody.
  ///
  /// In en, this message translates to:
  /// **'Wave 1 uses Initial random-spawn points (WaveSpendingPoints). Points then increase by Points added per wave (WaveSpendingPointIncrement) by default, even across waves where random spawning is disabled.\nThe current-wave random spawn points (WavePointStart) setting changes the points for the current wave, current-wave point increment (WavePointIncrement) changes the increment used by later waves, and Reset point trajectory (WavePointOverride) determines whether the next wave returns to the points calculated from its original position or continues from the current wave\'s current-wave points as a new starting point.'**
  String get waveGeneratorModuleHelpPointTrajectoryBody;

  /// No description provided for @waveGeneratorModuleHelpPool.
  ///
  /// In en, this message translates to:
  /// **'Zombie pool'**
  String get waveGeneratorModuleHelpPool;

  /// No description provided for @waveGeneratorModuleHelpPoolBody.
  ///
  /// In en, this message translates to:
  /// **'The random-spawn zombie pool expands as waves progress. The initial pool is used when the level starts, and zombies added on each wave remain available to that wave and every later wave. Zombies added on a wave still enter the pool even if random spawning is disabled for that wave.'**
  String get waveGeneratorModuleHelpPoolBody;

  /// No description provided for @waveGeneratorModuleHelpIncompat.
  ///
  /// In en, this message translates to:
  /// **'Module compatibility'**
  String get waveGeneratorModuleHelpIncompat;

  /// No description provided for @waveGeneratorModuleHelpIncompatBody.
  ///
  /// In en, this message translates to:
  /// **'Wave Generator may be incompatible with modules such as Seeing Stars and cause the level to crash. Use with caution.\nGladiatorial Row does not work with Wave Generator. Use Wave Manager instead.'**
  String get waveGeneratorModuleHelpIncompatBody;

  /// No description provided for @waveGeneratorModuleHelpRow.
  ///
  /// In en, this message translates to:
  /// **'Row numbers'**
  String get waveGeneratorModuleHelpRow;

  /// No description provided for @waveGeneratorModuleHelpRowBody.
  ///
  /// In en, this message translates to:
  /// **'Fixed-spawn rows are numbered from 1: enter \"1\" for Row 1, \"2\" for Row 2, and so on. Enter \"?\" to let the game choose a row at random.'**
  String get waveGeneratorModuleHelpRowBody;

  /// No description provided for @waveGeneratorModuleGlobalParams.
  ///
  /// In en, this message translates to:
  /// **'Global parameters'**
  String get waveGeneratorModuleGlobalParams;

  /// No description provided for @waveGeneratorGlobalParams.
  ///
  /// In en, this message translates to:
  /// **'Wave Generator parameters'**
  String get waveGeneratorGlobalParams;

  /// No description provided for @waveGeneratorFlagIntervalHint.
  ///
  /// In en, this message translates to:
  /// **'Marks every Nth wave as a flag wave. This does not change its random-spawn points.'**
  String get waveGeneratorFlagIntervalHint;

  /// No description provided for @flagWaveInterval.
  ///
  /// In en, this message translates to:
  /// **'Flag wave interval (FlagWaveInterval)'**
  String get flagWaveInterval;

  /// No description provided for @waveGeneratorSpendingPoints.
  ///
  /// In en, this message translates to:
  /// **'Initial random-spawn points (WaveSpendingPoints)'**
  String get waveGeneratorSpendingPoints;

  /// No description provided for @waveGeneratorSpendingPointIncrement.
  ///
  /// In en, this message translates to:
  /// **'Points added per wave (WaveSpendingPointIncrement)'**
  String get waveGeneratorSpendingPointIncrement;

  /// No description provided for @waveGeneratorSpendingCompatibilityWarning.
  ///
  /// In en, this message translates to:
  /// **'The initial random-spawn points exceed the current-wave increment and may cause the level to crash while loading.'**
  String get waveGeneratorSpendingCompatibilityWarning;

  /// No description provided for @waveGeneratorRiseFromGround.
  ///
  /// In en, this message translates to:
  /// **'Rise from Ground (IsRiseFromGroundMode)'**
  String get waveGeneratorRiseFromGround;

  /// No description provided for @waveGeneratorRiseFromGroundHint.
  ///
  /// In en, this message translates to:
  /// **'When enabled, zombies emerge from the ground by default instead of walking in from the right'**
  String get waveGeneratorRiseFromGroundHint;

  /// No description provided for @waveGeneratorWaveSpawnTime.
  ///
  /// In en, this message translates to:
  /// **'Wave spawn delay (WaveSpawnTime; time: seconds)'**
  String get waveGeneratorWaveSpawnTime;

  /// No description provided for @waveGeneratorWaveSpawnTimeHint.
  ///
  /// In en, this message translates to:
  /// **'The minimum wait between the previous wave’s spawns and this wave’s spawns. Only applies with Rise from Ground (IsRiseFromGroundMode) enabled. After the previous wave finishes spawning, the game starts a countdown using this wave’s delay. This wave spawns when the countdown ends.\nIf WaitUntilAllZombiesDie is also enabled, both conditions must be met. A Spacetime Black Hole at the end of the previous wave overrides this delay; the next spawning steps begin about 8 seconds after the black hole triggers.'**
  String get waveGeneratorWaveSpawnTimeHint;

  /// No description provided for @waveGeneratorZombieTargetValidTime.
  ///
  /// In en, this message translates to:
  /// **'Target lifetime (TargetValidTime; time: seconds)'**
  String get waveGeneratorZombieTargetValidTime;

  /// No description provided for @waveGeneratorZombieTargetValidTimeHint.
  ///
  /// In en, this message translates to:
  /// **'How long a Power Sphere remains on the lawn after appearing. Leave empty for it to disappear after the default 1.5 seconds.'**
  String get waveGeneratorZombieTargetValidTimeHint;

  /// No description provided for @waveGeneratorZombieRiseGridX.
  ///
  /// In en, this message translates to:
  /// **'Spawn column (Rise_GridX)'**
  String get waveGeneratorZombieRiseGridX;

  /// No description provided for @waveGeneratorZombieRiseGridXHint.
  ///
  /// In en, this message translates to:
  /// **'The column where this zombie emerges from the ground.'**
  String get waveGeneratorZombieRiseGridXHint;

  /// No description provided for @waveGeneratorZombieRiseGridY.
  ///
  /// In en, this message translates to:
  /// **'Spawn row (Rise_GridY)'**
  String get waveGeneratorZombieRiseGridY;

  /// No description provided for @waveGeneratorZombieRiseGridYHint.
  ///
  /// In en, this message translates to:
  /// **'The row where this zombie emerges from the ground. Overrides the Wave Generator’s Row setting.'**
  String get waveGeneratorZombieRiseGridYHint;

  /// No description provided for @waveGeneratorWaveCountSummary.
  ///
  /// In en, this message translates to:
  /// **'Total waves: {count}'**
  String waveGeneratorWaveCountSummary(int count);

  /// No description provided for @waveGeneratorInitialPool.
  ///
  /// In en, this message translates to:
  /// **'Initial zombie pool (AddToZombiePool)'**
  String get waveGeneratorInitialPool;

  /// No description provided for @waveGeneratorEmptyPool.
  ///
  /// In en, this message translates to:
  /// **'The initial zombie pool is empty.'**
  String get waveGeneratorEmptyPool;

  /// No description provided for @waveGeneratorCustomZombieBlocked.
  ///
  /// In en, this message translates to:
  /// **'Custom zombies cannot be added here'**
  String get waveGeneratorCustomZombieBlocked;

  /// No description provided for @waveGeneratorTabMissingModule.
  ///
  /// In en, this message translates to:
  /// **'Add a Wave Generator module to configure additional groups here.'**
  String get waveGeneratorTabMissingModule;

  /// No description provided for @waveGeneratorTabSummary.
  ///
  /// In en, this message translates to:
  /// **'Flag every {interval} waves · Initial points {points} · Increase by {increment} per wave'**
  String waveGeneratorTabSummary(int interval, int points, int increment);

  /// No description provided for @waveGeneratorNoWaves.
  ///
  /// In en, this message translates to:
  /// **'No waves have been configured.'**
  String get waveGeneratorNoWaves;

  /// No description provided for @waveGeneratorDeleteWaveConfirm.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{This will remove the wave and its 1 fixed spawn.} other{This will remove the wave and its {count} fixed spawns.}}'**
  String waveGeneratorDeleteWaveConfirm(int count);

  /// No description provided for @waveGeneratorEmptyWaveRow.
  ///
  /// In en, this message translates to:
  /// **'No fixed spawns'**
  String get waveGeneratorEmptyWaveRow;

  /// No description provided for @waveGeneratorRandomZombiesLabel.
  ///
  /// In en, this message translates to:
  /// **'Current random-spawn pool'**
  String get waveGeneratorRandomZombiesLabel;

  /// No description provided for @waveGeneratorDisableRandomSpawns.
  ///
  /// In en, this message translates to:
  /// **'Disable random spawns (DisableRandomSpawns)'**
  String get waveGeneratorDisableRandomSpawns;

  /// No description provided for @waveGeneratorDisableRandomSpawnsHint.
  ///
  /// In en, this message translates to:
  /// **'Skips point-based random spawning on this wave only. Points still increase with wave progress, and zombie-pool changes are preserved for later waves.'**
  String get waveGeneratorDisableRandomSpawnsHint;

  /// No description provided for @waveGeneratorWaitUntilAllDie.
  ///
  /// In en, this message translates to:
  /// **'Wait until all zombies from the previous wave are defeated before spawning this wave (WaitUntilAllZombiesDie)'**
  String get waveGeneratorWaitUntilAllDie;

  /// No description provided for @waveGeneratorSpawnPlantFood.
  ///
  /// In en, this message translates to:
  /// **'Number of zombies carrying Plant Food (SpawnPlantFoodCount)'**
  String get waveGeneratorSpawnPlantFood;

  /// No description provided for @waveGeneratorWavePointStart.
  ///
  /// In en, this message translates to:
  /// **'Current-wave random spawn points (WavePointStart)'**
  String get waveGeneratorWavePointStart;

  /// No description provided for @waveGeneratorWavePointStartHint.
  ///
  /// In en, this message translates to:
  /// **'Sets the random-spawn points used by this wave only. Leave empty to use the points calculated by default.'**
  String get waveGeneratorWavePointStartHint;

  /// No description provided for @waveGeneratorWavePointIncrement.
  ///
  /// In en, this message translates to:
  /// **'New point increment (WavePointIncrement)'**
  String get waveGeneratorWavePointIncrement;

  /// No description provided for @waveGeneratorWavePointIncrementHint.
  ///
  /// In en, this message translates to:
  /// **'Changes the point increment used by later waves. It only takes effect when current-wave random spawn points (WavePointStart) is set.'**
  String get waveGeneratorWavePointIncrementHint;

  /// No description provided for @waveGeneratorWavePointOverride.
  ///
  /// In en, this message translates to:
  /// **'Reset point trajectory (WavePointOverride)'**
  String get waveGeneratorWavePointOverride;

  /// No description provided for @waveGeneratorWavePointOverrideHint.
  ///
  /// In en, this message translates to:
  /// **'When disabled, current-wave random spawn points (WavePointStart) affects only the current wave, and the next wave returns to the points calculated from its original wave position. When enabled, the current wave\'s spawn points become the new starting point for later waves. In both cases, later waves continue with the effective point increment.'**
  String get waveGeneratorWavePointOverrideHint;

  /// No description provided for @waveGeneratorPointTrajectory.
  ///
  /// In en, this message translates to:
  /// **'Point trajectory preview'**
  String get waveGeneratorPointTrajectory;

  /// No description provided for @waveGeneratorPointTrajectoryTemporary.
  ///
  /// In en, this message translates to:
  /// **'Current-wave random spawn points affect only this wave. The next wave returns to the points calculated from its original position and continues with the effective increment.'**
  String get waveGeneratorPointTrajectoryTemporary;

  /// No description provided for @waveGeneratorPointTrajectoryReset.
  ///
  /// In en, this message translates to:
  /// **'The current wave\'s random spawn points become the new starting point for later waves, which continue with the effective increment.'**
  String get waveGeneratorPointTrajectoryReset;

  /// No description provided for @waveGeneratorPointTrajectoryWaveValue.
  ///
  /// In en, this message translates to:
  /// **'W{wave} · {points} pts.'**
  String waveGeneratorPointTrajectoryWaveValue(int wave, int points);

  /// No description provided for @waveGeneratorBlackHoleFieldHint.
  ///
  /// In en, this message translates to:
  /// **'Enter a column count to summon a spacetime black hole at the end of this wave and pull all plants to the right.\nThe black hole appears only when this is not the level\'s final wave and Wait until all zombies from the previous wave are defeated before spawning this wave (WaitUntilAllZombiesDie) is enabled.'**
  String get waveGeneratorBlackHoleFieldHint;

  /// No description provided for @waveGeneratorBlackHoleWaveHint.
  ///
  /// In en, this message translates to:
  /// **'A spacetime black hole appears at the end of this wave and pulls plants {cols} columns to the right'**
  String waveGeneratorBlackHoleWaveHint(int cols);

  /// No description provided for @waveGeneratorCurrentPool.
  ///
  /// In en, this message translates to:
  /// **'Current effective zombie pool'**
  String get waveGeneratorCurrentPool;

  /// No description provided for @waveGeneratorCurrentPoolEmpty.
  ///
  /// In en, this message translates to:
  /// **'The effective zombie pool is empty.'**
  String get waveGeneratorCurrentPoolEmpty;

  /// No description provided for @waveGeneratorWavePoolAdd.
  ///
  /// In en, this message translates to:
  /// **'Added to the pool on this wave (AddToZombiePool)'**
  String get waveGeneratorWavePoolAdd;

  /// No description provided for @waveGeneratorWavePoolNoChanges.
  ///
  /// In en, this message translates to:
  /// **'This wave does not extend the zombie pool.'**
  String get waveGeneratorWavePoolNoChanges;

  /// No description provided for @waveGeneratorWaveScreenSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Wave Generator module'**
  String get waveGeneratorWaveScreenSubtitle;

  /// No description provided for @waveGeneratorRandomSpawnsSectionTitle.
  ///
  /// In en, this message translates to:
  /// **'Random Spawns'**
  String get waveGeneratorRandomSpawnsSectionTitle;

  /// No description provided for @waveGeneratorZombiePoolSectionTitle.
  ///
  /// In en, this message translates to:
  /// **'Zombie Pool'**
  String get waveGeneratorZombiePoolSectionTitle;

  /// No description provided for @waveGeneratorWaveSettingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Wave Settings'**
  String get waveGeneratorWaveSettingsTitle;

  /// No description provided for @waveGeneratorFixedSpawnsHelpTitle.
  ///
  /// In en, this message translates to:
  /// **'Fixed Spawns section'**
  String get waveGeneratorFixedSpawnsHelpTitle;

  /// No description provided for @waveGeneratorRandomSpawnsHelpTitle.
  ///
  /// In en, this message translates to:
  /// **'Random Spawns section'**
  String get waveGeneratorRandomSpawnsHelpTitle;

  /// No description provided for @waveGeneratorZombiePoolHelpTitle.
  ///
  /// In en, this message translates to:
  /// **'Zombie Pool section'**
  String get waveGeneratorZombiePoolHelpTitle;

  /// No description provided for @waveGeneratorWaveSettingsHelpTitle.
  ///
  /// In en, this message translates to:
  /// **'Wave Settings section'**
  String get waveGeneratorWaveSettingsHelpTitle;

  /// No description provided for @waveGeneratorFixedSpawnsHelpBody.
  ///
  /// In en, this message translates to:
  /// **'Fixed spawns are added directly to the current wave, consume no random-spawn points, and can be used together with random spawns.'**
  String get waveGeneratorFixedSpawnsHelpBody;

  /// No description provided for @waveGeneratorPointTrajectoryHelpBody.
  ///
  /// In en, this message translates to:
  /// **'The point trajectory preview shows the effective random-spawn points calculated by the editor for each wave. It does not represent the number of fixed spawns.'**
  String get waveGeneratorPointTrajectoryHelpBody;

  /// No description provided for @waveGeneratorWavePoolAddHelpBody.
  ///
  /// In en, this message translates to:
  /// **'Zombies added on this wave enter the effective pool immediately and continue to affect later waves. The additions still take effect when random spawning is disabled for this wave.'**
  String get waveGeneratorWavePoolAddHelpBody;

  /// No description provided for @waveGeneratorPoolCompatibilityTitle.
  ///
  /// In en, this message translates to:
  /// **'Type restrictions'**
  String get waveGeneratorPoolCompatibilityTitle;

  /// No description provided for @waveGeneratorPoolCompatibilityHelpBody.
  ///
  /// In en, this message translates to:
  /// **'Wave Generator zombie pools support only standard in-game zombie types, not custom zombies defined in the level.'**
  String get waveGeneratorPoolCompatibilityHelpBody;

  /// No description provided for @waveGeneratorWaitUntilAllDieHelpBody.
  ///
  /// In en, this message translates to:
  /// **'Controls whether this wave waits for every zombie from the previous wave to be defeated before it begins spawning.'**
  String get waveGeneratorWaitUntilAllDieHelpBody;

  /// No description provided for @waveGeneratorSpawnPlantFoodHelpBody.
  ///
  /// In en, this message translates to:
  /// **'Sets the number of zombies in this wave that carry and drop Plant Food.'**
  String get waveGeneratorSpawnPlantFoodHelpBody;

  /// No description provided for @waveGeneratorFixedSummary.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 zombie is guaranteed to appear} other{{count} zombies are guaranteed to appear}}'**
  String waveGeneratorFixedSummary(int count);

  /// No description provided for @waveGeneratorFixedSummaryEmpty.
  ///
  /// In en, this message translates to:
  /// **'No fixed spawns'**
  String get waveGeneratorFixedSummaryEmpty;

  /// No description provided for @waveGeneratorRandomSummary.
  ///
  /// In en, this message translates to:
  /// **'{points, plural, =1{Enabled · 1 point} other{Enabled · {points} points}}'**
  String waveGeneratorRandomSummary(int points);

  /// No description provided for @waveGeneratorRandomLocalSummary.
  ///
  /// In en, this message translates to:
  /// **'{points, plural, =1{Enabled · 1 point · Current-wave points} other{Enabled · {points} points · Current-wave points}}'**
  String waveGeneratorRandomLocalSummary(int points);

  /// No description provided for @waveGeneratorRandomSummaryDisabled.
  ///
  /// In en, this message translates to:
  /// **'No random spawns on this wave'**
  String get waveGeneratorRandomSummaryDisabled;

  /// No description provided for @waveGeneratorPoolSummary.
  ///
  /// In en, this message translates to:
  /// **'{current, plural, =1{1 current type} other{{current} current types}} · {added, plural, =1{1 added on this wave} other{{added} added on this wave}}'**
  String waveGeneratorPoolSummary(int current, int added);

  /// No description provided for @waveGeneratorPoolSummaryNoAdditions.
  ///
  /// In en, this message translates to:
  /// **'{current, plural, =1{1 current type · No additions on this wave} other{{current} current types · No additions on this wave}}'**
  String waveGeneratorPoolSummaryNoAdditions(int current);

  /// No description provided for @waveGeneratorWaveSettingsDefaultSummary.
  ///
  /// In en, this message translates to:
  /// **'Default settings'**
  String get waveGeneratorWaveSettingsDefaultSummary;

  /// No description provided for @waveGeneratorWaveSettingsPlantFoodSummary.
  ///
  /// In en, this message translates to:
  /// **'Plant Food ×{count}'**
  String waveGeneratorWaveSettingsPlantFoodSummary(int count);

  /// No description provided for @waveGeneratorWaveSettingsBlackHoleSummary.
  ///
  /// In en, this message translates to:
  /// **'Spacetime black hole · {cols} columns'**
  String waveGeneratorWaveSettingsBlackHoleSummary(int cols);

  /// No description provided for @waveGeneratorExpectationTapHint.
  ///
  /// In en, this message translates to:
  /// **'View the random spawn estimate for this wave'**
  String get waveGeneratorExpectationTapHint;

  /// No description provided for @waveGeneratorStatisticalPreview.
  ///
  /// In en, this message translates to:
  /// **'Random-spawn preview'**
  String get waveGeneratorStatisticalPreview;

  /// No description provided for @waveGeneratorExpectationEmpty.
  ///
  /// In en, this message translates to:
  /// **'This wave\'s zombie pool has no zombies eligible for random spawning.'**
  String get waveGeneratorExpectationEmpty;

  /// No description provided for @waveGeneratorExpectationPoolNote.
  ///
  /// In en, this message translates to:
  /// **'The preview estimates spawn counts by repeatedly simulating weighted selections. Results can vary with selection order even when the point budget is unchanged, so it cannot precisely predict the game\'s actual spawns.'**
  String get waveGeneratorExpectationPoolNote;

  /// No description provided for @waveGeneratorExpectationTitle.
  ///
  /// In en, this message translates to:
  /// **'Wave {wave} random-spawn preview'**
  String waveGeneratorExpectationTitle(int wave);

  /// No description provided for @waveGeneratorEffectiveRandomPoints.
  ///
  /// In en, this message translates to:
  /// **'Random-spawn points: {points}'**
  String waveGeneratorEffectiveRandomPoints(int points);

  /// No description provided for @waveGeneratorFixedSpawnCount.
  ///
  /// In en, this message translates to:
  /// **'Fixed spawns: {count}'**
  String waveGeneratorFixedSpawnCount(int count);

  /// No description provided for @waveGeneratorFixedSpawns.
  ///
  /// In en, this message translates to:
  /// **'Fixed Spawns'**
  String get waveGeneratorFixedSpawns;

  /// No description provided for @waveGeneratorPoolAddedCount.
  ///
  /// In en, this message translates to:
  /// **'Pool additions this wave: {count}'**
  String waveGeneratorPoolAddedCount(int count);

  /// No description provided for @waveGeneratorWaitStatus.
  ///
  /// In en, this message translates to:
  /// **'Waits for the previous wave'**
  String get waveGeneratorWaitStatus;

  /// No description provided for @waveGeneratorExpectationDisabled.
  ///
  /// In en, this message translates to:
  /// **'Random spawning is disabled on this wave.'**
  String get waveGeneratorExpectationDisabled;

  /// No description provided for @waveGeneratorExpectationMissingData.
  ///
  /// In en, this message translates to:
  /// **'Random-spawn preview unavailable because these zombies are missing reliable WavePointCost or Weight data: {types}'**
  String waveGeneratorExpectationMissingData(String types);

  /// No description provided for @waveGeneratorExpectationEstimatedTotal.
  ///
  /// In en, this message translates to:
  /// **'Average random spawns: about {count}'**
  String waveGeneratorExpectationEstimatedTotal(String count);

  /// No description provided for @waveGeneratorExpectationCommonRange.
  ///
  /// In en, this message translates to:
  /// **'Estimated count range: {minimum}–{maximum}'**
  String waveGeneratorExpectationCommonRange(int minimum, int maximum);

  /// No description provided for @waveGeneratorExpectationCostWeight.
  ///
  /// In en, this message translates to:
  /// **'Cost {cost} · Weight {weight}'**
  String waveGeneratorExpectationCostWeight(int cost, String weight);

  /// No description provided for @waveGeneratorExpectationAverageCount.
  ///
  /// In en, this message translates to:
  /// **'Average {count}'**
  String waveGeneratorExpectationAverageCount(String count);

  /// No description provided for @protectItems.
  ///
  /// In en, this message translates to:
  /// **'Save Our Items'**
  String get protectItems;

  /// No description provided for @protectGridItemChallengeHelpTitle.
  ///
  /// In en, this message translates to:
  /// **'Save Our Items module'**
  String get protectGridItemChallengeHelpTitle;

  /// No description provided for @briefOverview.
  ///
  /// In en, this message translates to:
  /// **'Overview'**
  String get briefOverview;

  /// No description provided for @automaticCount.
  ///
  /// In en, this message translates to:
  /// **'Automatic Count'**
  String get automaticCount;

  /// No description provided for @operationGuide.
  ///
  /// In en, this message translates to:
  /// **'Operation Guide'**
  String get operationGuide;

  /// No description provided for @protectGridItemChallengeHelpOverview.
  ///
  /// In en, this message translates to:
  /// **'Specify the grid items that must be protected in the level. The level will immediately fail if any of them are destroyed.'**
  String get protectGridItemChallengeHelpOverview;

  /// No description provided for @protectGridItemChallengeHelpAutoCountBody.
  ///
  /// In en, this message translates to:
  /// **'The editor will automatically update the number of grid items that need to be protected based on the number of items you add.'**
  String get protectGridItemChallengeHelpAutoCountBody;

  /// No description provided for @protectGridItemChallengeHelpOperationGuide.
  ///
  /// In en, this message translates to:
  /// **'Click a position in the grid above, then click the \"Add item\" button to select the type of item to protect.'**
  String get protectGridItemChallengeHelpOperationGuide;

  /// No description provided for @mustProtectCount.
  ///
  /// In en, this message translates to:
  /// **'Current protected target count: {count}'**
  String mustProtectCount(int count);

  /// No description provided for @customStageProperties.
  ///
  /// In en, this message translates to:
  /// **'Custom lawn properties'**
  String get customStageProperties;

  /// No description provided for @customStageNotFound.
  ///
  /// In en, this message translates to:
  /// **'Custom lawn object not found.'**
  String get customStageNotFound;

  /// No description provided for @customStageSectionGeneral.
  ///
  /// In en, this message translates to:
  /// **'General'**
  String get customStageSectionGeneral;

  /// No description provided for @customStageSectionZombies.
  ///
  /// In en, this message translates to:
  /// **'Zombie Types'**
  String get customStageSectionZombies;

  /// No description provided for @customStageSectionResourceGroups.
  ///
  /// In en, this message translates to:
  /// **'Resource Groups'**
  String get customStageSectionResourceGroups;

  /// No description provided for @customStageSectionMusicAndOther.
  ///
  /// In en, this message translates to:
  /// **'Basic Elements'**
  String get customStageSectionMusicAndOther;

  /// No description provided for @customStageSectionAdvanced.
  ///
  /// In en, this message translates to:
  /// **'Advanced Settings'**
  String get customStageSectionAdvanced;

  /// No description provided for @customStageAlias.
  ///
  /// In en, this message translates to:
  /// **'Stage alias (English letters only; no spaces)'**
  String get customStageAlias;

  /// No description provided for @customStageNoResourceGroups.
  ///
  /// In en, this message translates to:
  /// **'No resource groups in list'**
  String get customStageNoResourceGroups;

  /// No description provided for @customStageMissingBackgroundWarning.
  ///
  /// In en, this message translates to:
  /// **'Import at least one DelayLoad_Background group listed in the stage helper, or the lawn may appear completely black.'**
  String get customStageMissingBackgroundWarning;

  /// No description provided for @customStageEnableAmbient.
  ///
  /// In en, this message translates to:
  /// **'Enable ambient audio'**
  String get customStageEnableAmbient;

  /// No description provided for @customStageDisabledCellsEmpty.
  ///
  /// In en, this message translates to:
  /// **'Leave empty'**
  String get customStageDisabledCellsEmpty;

  /// No description provided for @customStageDisabledCellsDefault.
  ///
  /// In en, this message translates to:
  /// **'Default'**
  String get customStageDisabledCellsDefault;

  /// No description provided for @customStageEnableSubmarine.
  ///
  /// In en, this message translates to:
  /// **'Enable submarine'**
  String get customStageEnableSubmarine;

  /// No description provided for @customStageSubmarineHitpoints.
  ///
  /// In en, this message translates to:
  /// **'Submarine health'**
  String get customStageSubmarineHitpoints;

  /// No description provided for @customStageBeachMinigame.
  ///
  /// In en, this message translates to:
  /// **'Use minigame version'**
  String get customStageBeachMinigame;

  /// No description provided for @customStageOnePerLevelLimit.
  ///
  /// In en, this message translates to:
  /// **'This level already has a custom lawn. Delete it before adding another.'**
  String get customStageOnePerLevelLimit;

  /// No description provided for @selectStageBackground.
  ///
  /// In en, this message translates to:
  /// **'Select lawn appearance'**
  String get selectStageBackground;

  /// No description provided for @searchStageBackground.
  ///
  /// In en, this message translates to:
  /// **'Search lawn'**
  String get searchStageBackground;

  /// No description provided for @noStageBackgroundFound.
  ///
  /// In en, this message translates to:
  /// **'No lawn appearance found'**
  String get noStageBackgroundFound;

  /// No description provided for @stageBackgroundNeedMorePromptTitle.
  ///
  /// In en, this message translates to:
  /// **'Need another lawn appearance?'**
  String get stageBackgroundNeedMorePromptTitle;

  /// No description provided for @stageBackgroundNeedMorePromptMessage.
  ///
  /// In en, this message translates to:
  /// **'Import resource groups from another stage to unlock more lawn appearances here.'**
  String get stageBackgroundNeedMorePromptMessage;

  /// No description provided for @stageBackgroundAddFromStage.
  ///
  /// In en, this message translates to:
  /// **'Add another lawn appearance'**
  String get stageBackgroundAddFromStage;

  /// No description provided for @customStageNameSuffix.
  ///
  /// In en, this message translates to:
  /// **' (Custom)'**
  String get customStageNameSuffix;

  /// No description provided for @customStageLawnAppearance.
  ///
  /// In en, this message translates to:
  /// **'Lawn appearance'**
  String get customStageLawnAppearance;

  /// No description provided for @customStageBaseStage.
  ///
  /// In en, this message translates to:
  /// **'Base stage'**
  String get customStageBaseStage;

  /// No description provided for @selectCustomStageBase.
  ///
  /// In en, this message translates to:
  /// **'Select base lawn'**
  String get selectCustomStageBase;

  /// No description provided for @noStageBaseFound.
  ///
  /// In en, this message translates to:
  /// **'No lawn found'**
  String get noStageBaseFound;

  /// No description provided for @importResourceGroup.
  ///
  /// In en, this message translates to:
  /// **'Import resource group'**
  String get importResourceGroup;

  /// No description provided for @importResourceGroupGlobal.
  ///
  /// In en, this message translates to:
  /// **'From global list'**
  String get importResourceGroupGlobal;

  /// No description provided for @importResourceGroupFromStage.
  ///
  /// In en, this message translates to:
  /// **'From stage'**
  String get importResourceGroupFromStage;

  /// No description provided for @searchResourceGroup.
  ///
  /// In en, this message translates to:
  /// **'Search resource group'**
  String get searchResourceGroup;

  /// No description provided for @noResourceGroupFound.
  ///
  /// In en, this message translates to:
  /// **'No resource group found'**
  String get noResourceGroupFound;

  /// No description provided for @importResourceGroupsFromStageTitle.
  ///
  /// In en, this message translates to:
  /// **'Add resource groups from stage?'**
  String get importResourceGroupsFromStageTitle;

  /// No description provided for @importResourceGroupsFromStageMessage.
  ///
  /// In en, this message translates to:
  /// **'The following resource groups from {stageName} will be added:'**
  String importResourceGroupsFromStageMessage(String stageName);

  /// No description provided for @importResourceGroupsFromStageSkipped.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 resource group already in this level will be skipped.} other{{count} resource groups already in this level will be skipped.}}'**
  String importResourceGroupsFromStageSkipped(int count);

  /// No description provided for @importResourceGroupsFromStageAllPresent.
  ///
  /// In en, this message translates to:
  /// **'All resource groups from this stage are already in this level.'**
  String get importResourceGroupsFromStageAllPresent;

  /// No description provided for @importResourceGroupsApplySourceLawnAppearance.
  ///
  /// In en, this message translates to:
  /// **'Also use this stage\'s lawn appearance'**
  String get importResourceGroupsApplySourceLawnAppearance;

  /// No description provided for @createCustomStage.
  ///
  /// In en, this message translates to:
  /// **'Create custom lawn'**
  String get createCustomStage;

  /// No description provided for @createCustomStageHint.
  ///
  /// In en, this message translates to:
  /// **'Pick a base lawn appearance and edit it locally in this level.'**
  String get createCustomStageHint;

  /// No description provided for @customStageAliasPromptTitle.
  ///
  /// In en, this message translates to:
  /// **'Custom lawn alias'**
  String get customStageAliasPromptTitle;

  /// No description provided for @customStageAliasTaken.
  ///
  /// In en, this message translates to:
  /// **'That alias is already used in this level.'**
  String get customStageAliasTaken;

  /// No description provided for @stageSelectionTabBuiltin.
  ///
  /// In en, this message translates to:
  /// **'Built-in'**
  String get stageSelectionTabBuiltin;

  /// No description provided for @stageSelectionTabCustom.
  ///
  /// In en, this message translates to:
  /// **'Custom'**
  String get stageSelectionTabCustom;

  /// No description provided for @customStageSelectionEmpty.
  ///
  /// In en, this message translates to:
  /// **'No custom lawn in this level yet.'**
  String get customStageSelectionEmpty;

  /// No description provided for @customStageSelectionInLevel.
  ///
  /// In en, this message translates to:
  /// **'Custom lawns in this level'**
  String get customStageSelectionInLevel;

  /// No description provided for @customStageSwitchToBuiltinTitle.
  ///
  /// In en, this message translates to:
  /// **'Switch to built-in lawn?'**
  String get customStageSwitchToBuiltinTitle;

  /// No description provided for @customStageSwitchToBuiltinMessage.
  ///
  /// In en, this message translates to:
  /// **'This permanently removes the custom lawn data from this level. This cannot be undone.'**
  String get customStageSwitchToBuiltinMessage;

  /// No description provided for @customStageDeleteTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete custom lawn?'**
  String get customStageDeleteTitle;

  /// No description provided for @customStageDeleteMessage.
  ///
  /// In en, this message translates to:
  /// **'This permanently removes the custom lawn data from this level. If it is the active lawn, the level will switch to the default built-in lawn.'**
  String get customStageDeleteMessage;

  /// No description provided for @customStagePresetSectionTitle.
  ///
  /// In en, this message translates to:
  /// **'Preset custom lawns'**
  String get customStagePresetSectionTitle;

  /// No description provided for @startupLoadingLocalization.
  ///
  /// In en, this message translates to:
  /// **'Localization'**
  String get startupLoadingLocalization;

  /// No description provided for @startupLoadingStages.
  ///
  /// In en, this message translates to:
  /// **'Lawns'**
  String get startupLoadingStages;

  /// No description provided for @startupLoadingAudio.
  ///
  /// In en, this message translates to:
  /// **'Audio'**
  String get startupLoadingAudio;

  /// No description provided for @startupLoadingGridItems.
  ///
  /// In en, this message translates to:
  /// **'Grid items'**
  String get startupLoadingGridItems;

  /// No description provided for @startupLoadingZomboss.
  ///
  /// In en, this message translates to:
  /// **'Zomboss'**
  String get startupLoadingZomboss;

  /// No description provided for @startupLoadingReference.
  ///
  /// In en, this message translates to:
  /// **'Reference data'**
  String get startupLoadingReference;

  /// No description provided for @startupLoadingZombies.
  ///
  /// In en, this message translates to:
  /// **'Zombies'**
  String get startupLoadingZombies;

  /// No description provided for @startupLoadingPlants.
  ///
  /// In en, this message translates to:
  /// **'Plants'**
  String get startupLoadingPlants;

  /// No description provided for @startupLoadingFish.
  ///
  /// In en, this message translates to:
  /// **'Sea Creatures'**
  String get startupLoadingFish;

  /// No description provided for @startupLoadingImages.
  ///
  /// In en, this message translates to:
  /// **'Images'**
  String get startupLoadingImages;

  /// No description provided for @startupLoadingPlugins.
  ///
  /// In en, this message translates to:
  /// **'Plugins'**
  String get startupLoadingPlugins;

  /// No description provided for @startupLoadingCategoryProgress.
  ///
  /// In en, this message translates to:
  /// **'Loading {category}...'**
  String startupLoadingCategoryProgress(String category);

  /// No description provided for @reselectFiles.
  ///
  /// In en, this message translates to:
  /// **'Re-select files'**
  String get reselectFiles;

  /// No description provided for @validationReviewRequest.
  ///
  /// In en, this message translates to:
  /// **'Please review the validation results for the selected levels.'**
  String get validationReviewRequest;

  /// No description provided for @validationRecommendation.
  ///
  /// In en, this message translates to:
  /// **'We recommend editing these levels to fix the issues before exporting, or choosing different files.'**
  String get validationRecommendation;

  /// No description provided for @customPortalAdd.
  ///
  /// In en, this message translates to:
  /// **'New Custom Portal'**
  String get customPortalAdd;

  /// No description provided for @customPortalSingleName.
  ///
  /// In en, this message translates to:
  /// **'Custom Portal'**
  String get customPortalSingleName;

  /// No description provided for @customPortalCreateTitle.
  ///
  /// In en, this message translates to:
  /// **'Create Custom Portal'**
  String get customPortalCreateTitle;

  /// No description provided for @customPortalEditTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit Custom Portal'**
  String get customPortalEditTitle;

  /// No description provided for @customPortalSelectBaseTitle.
  ///
  /// In en, this message translates to:
  /// **'Select a Base Portal'**
  String get customPortalSelectBaseTitle;

  /// No description provided for @customPortalBlankTemplate.
  ///
  /// In en, this message translates to:
  /// **'Blank Portal Template'**
  String get customPortalBlankTemplate;

  /// No description provided for @customPortalBlankTemplateSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Start with the standard portal structure and no zombies.'**
  String get customPortalBlankTemplateSubtitle;

  /// No description provided for @customPortalBuiltInBases.
  ///
  /// In en, this message translates to:
  /// **'Built-in Portals'**
  String get customPortalBuiltInBases;

  /// No description provided for @customPortalUnusedTitle.
  ///
  /// In en, this message translates to:
  /// **'Remove Unused Custom Portal?'**
  String get customPortalUnusedTitle;

  /// No description provided for @customPortalUnusedSingleMessage.
  ///
  /// In en, this message translates to:
  /// **'The custom portal is no longer used. Remove its associated data objects from this level?'**
  String get customPortalUnusedSingleMessage;

  /// No description provided for @customPortalAppearanceSection.
  ///
  /// In en, this message translates to:
  /// **'Portal Appearance'**
  String get customPortalAppearanceSection;

  /// No description provided for @customPortalSpawnSection.
  ///
  /// In en, this message translates to:
  /// **'Zombie Spawning'**
  String get customPortalSpawnSection;

  /// No description provided for @customPortalWorld.
  ///
  /// In en, this message translates to:
  /// **'World Appearance'**
  String get customPortalWorld;

  /// No description provided for @customPortalWorldTwister.
  ///
  /// In en, this message translates to:
  /// **'Blank'**
  String get customPortalWorldTwister;

  /// No description provided for @customPortalPopAnimation.
  ///
  /// In en, this message translates to:
  /// **'Portal Animation'**
  String get customPortalPopAnimation;

  /// No description provided for @customPortalAnimationModern.
  ///
  /// In en, this message translates to:
  /// **'Modern Day\'s Portal'**
  String get customPortalAnimationModern;

  /// No description provided for @customPortalAnimationMemoryLane.
  ///
  /// In en, this message translates to:
  /// **'Memory Lane\'s Portal'**
  String get customPortalAnimationMemoryLane;

  /// No description provided for @customPortalAnimationHydra.
  ///
  /// In en, this message translates to:
  /// **'Zombot Spell Chanter\'s Mirror'**
  String get customPortalAnimationHydra;

  /// No description provided for @customPortalSpawnMethod.
  ///
  /// In en, this message translates to:
  /// **'Zombie Spawn Method'**
  String get customPortalSpawnMethod;

  /// No description provided for @customPortalSpawnMethodShuffled.
  ///
  /// In en, this message translates to:
  /// **'Shuffled Sequence'**
  String get customPortalSpawnMethodShuffled;

  /// No description provided for @customPortalSpawnMethodInOrder.
  ///
  /// In en, this message translates to:
  /// **'In Order'**
  String get customPortalSpawnMethodInOrder;

  /// No description provided for @customPortalSpawnMethodHydra.
  ///
  /// In en, this message translates to:
  /// **'Zombot Spell Chanter\'s Random Spawn'**
  String get customPortalSpawnMethodHydra;

  /// No description provided for @customPortalZombieTypes.
  ///
  /// In en, this message translates to:
  /// **'Spawnable Zombie Types'**
  String get customPortalZombieTypes;

  /// No description provided for @customPortalSpawnInterval.
  ///
  /// In en, this message translates to:
  /// **'Zombie Spawn Interval'**
  String get customPortalSpawnInterval;

  /// No description provided for @customPortalSpawnIntervalSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Optionally set the minimum and maximum time between zombie spawns.'**
  String get customPortalSpawnIntervalSubtitle;

  /// No description provided for @moduleTitle_MoonLifeSupportSystemProperties.
  ///
  /// In en, this message translates to:
  /// **'Life Support System'**
  String get moduleTitle_MoonLifeSupportSystemProperties;

  /// No description provided for @moduleDesc_MoonLifeSupportSystemProperties.
  ///
  /// In en, this message translates to:
  /// **'Configures the Moon BaseZ power capacity and overload protocols'**
  String get moduleDesc_MoonLifeSupportSystemProperties;

  /// No description provided for @moduleTitle_LunarTerminalModuleProperties.
  ///
  /// In en, this message translates to:
  /// **'Lunar Terminal'**
  String get moduleTitle_LunarTerminalModuleProperties;

  /// No description provided for @moduleDesc_LunarTerminalModuleProperties.
  ///
  /// In en, this message translates to:
  /// **'Deploys mining robots to collect crystal energy and increase the power capacity limit'**
  String get moduleDesc_LunarTerminalModuleProperties;

  /// No description provided for @moduleTitle_LunarMineVeinModuleProperties.
  ///
  /// In en, this message translates to:
  /// **'Crystal Veins'**
  String get moduleTitle_LunarMineVeinModuleProperties;

  /// No description provided for @moduleDesc_LunarMineVeinModuleProperties.
  ///
  /// In en, this message translates to:
  /// **'Places Lunar Energy Crystal Veins and sets their growth waves'**
  String get moduleDesc_LunarMineVeinModuleProperties;

  /// No description provided for @moduleTitle_RadiationMeteorModuleProperties.
  ///
  /// In en, this message translates to:
  /// **'Radioactive Meteorite'**
  String get moduleTitle_RadiationMeteorModuleProperties;

  /// No description provided for @moduleDesc_RadiationMeteorModuleProperties.
  ///
  /// In en, this message translates to:
  /// **'Drops meteorites that destroy units and contaminate surrounding tiles'**
  String get moduleDesc_RadiationMeteorModuleProperties;

  /// No description provided for @eventTitle_SpawnRocketLandingWaveActionProps.
  ///
  /// In en, this message translates to:
  /// **'Rocket Landing'**
  String get eventTitle_SpawnRocketLandingWaveActionProps;

  /// No description provided for @eventDesc_SpawnRocketLandingWaveActionProps.
  ///
  /// In en, this message translates to:
  /// **'Spawns capturable Moon rockets at set positions'**
  String get eventDesc_SpawnRocketLandingWaveActionProps;

  /// No description provided for @moonLifeSupportHelpTitle.
  ///
  /// In en, this message translates to:
  /// **'Life Support System'**
  String get moonLifeSupportHelpTitle;

  /// No description provided for @moonLifeSupportHelpOverview.
  ///
  /// In en, this message translates to:
  /// **'An economy system commonly used in Moon BaseZ levels. After this module is added, planting does not cost Sun. Instead, plants occupy a portion of the Life Support System\'s power capacity in real time. When a plant is shoveled, destroyed by zombies, or removed by a special mechanic, all capacity it occupied is immediately restored.\nNote that this module also prevents Level 4 and higher plants from automatically using their Plant Food ability when planted.'**
  String get moonLifeSupportHelpOverview;

  /// No description provided for @moonLifeSupportHelpProtocolsTitle.
  ///
  /// In en, this message translates to:
  /// **'Overload protocols'**
  String get moonLifeSupportHelpProtocolsTitle;

  /// No description provided for @moonLifeSupportHelpProtocols.
  ///
  /// In en, this message translates to:
  /// **'When the Life Support System\'s power usage exceeds its initial power capacity, the system enters an overloaded state and activates the Power-Saving Protocol, reducing the attack speed of plants on the lawn and the recharge speed of seed slots.\nWhen power usage exceeds (initial power capacity × required hibernation ratio), the system forcibly activates the Hibernation Protocol after the configured countdown, putting every plant on the lawn into hibernation. Seed slots and the Cosmic Plant Food meter are also locked and cannot be used.'**
  String get moonLifeSupportHelpProtocols;

  /// No description provided for @moonLifeSupportHelpPlantFoodTitle.
  ///
  /// In en, this message translates to:
  /// **'Independent cooldowns'**
  String get moonLifeSupportHelpPlantFoodTitle;

  /// No description provided for @moonLifeSupportHelpPlantFood.
  ///
  /// In en, this message translates to:
  /// **'The module defines a dedicated list of plants with independent cooldowns. The cooldowns of plants in this list are not affected by the Power-Saving Protocol, but those plants still cannot be planted under the Hibernation Protocol.'**
  String get moonLifeSupportHelpPlantFood;

  /// No description provided for @moonLifeSupportPowerSettings.
  ///
  /// In en, this message translates to:
  /// **'Power settings'**
  String get moonLifeSupportPowerSettings;

  /// No description provided for @moonInitialCapacity.
  ///
  /// In en, this message translates to:
  /// **'Initial power capacity (InitialCapacity)'**
  String get moonInitialCapacity;

  /// No description provided for @moonBufferOverloadRatio.
  ///
  /// In en, this message translates to:
  /// **'Required hibernation ratio (BufferOverloadRatio)'**
  String get moonBufferOverloadRatio;

  /// No description provided for @moonPenaltyCountdown.
  ///
  /// In en, this message translates to:
  /// **'Hibernation countdown (PenaltyCountdown, seconds)'**
  String get moonPenaltyCountdown;

  /// No description provided for @moonPlantImmunityList.
  ///
  /// In en, this message translates to:
  /// **'Plants with independent cooldowns (PlantImmunityList)'**
  String get moonPlantImmunityList;

  /// No description provided for @moonPlantImmunityListHint.
  ///
  /// In en, this message translates to:
  /// **'The cooldowns of plants in this list are not affected by the Power-Saving Protocol, but those plants still cannot be planted under the Hibernation Protocol.'**
  String get moonPlantImmunityListHint;

  /// No description provided for @moonSelectImmunePlants.
  ///
  /// In en, this message translates to:
  /// **'Select plants to add to the list'**
  String get moonSelectImmunePlants;

  /// No description provided for @lunarTerminalHelpTitle.
  ///
  /// In en, this message translates to:
  /// **'Lunar Terminal'**
  String get lunarTerminalHelpTitle;

  /// No description provided for @lunarTerminalHelpOverview.
  ///
  /// In en, this message translates to:
  /// **'An Artifact commonly used in Moon BaseZ levels. It remains at a fixed position on the lawn, similar to the cannon in Sky City. After tapping the collection terminal, select one of three mining robots and drag it onto the lawn. Robots automatically collect energy from Lunar Energy Crystals and Radioactive Meteorites within range, permanently increasing the base Life Support System\'s available power capacity for the current level and allowing stronger lineups. Robots have health and can be attacked and destroyed by zombies, Radioactive Meteorites, and other targets.'**
  String get lunarTerminalHelpOverview;

  /// No description provided for @lunarTerminalHelpFixedTitle.
  ///
  /// In en, this message translates to:
  /// **'Deployment cooldown'**
  String get lunarTerminalHelpFixedTitle;

  /// No description provided for @lunarTerminalHelpFixed.
  ///
  /// In en, this message translates to:
  /// **'After deploying a robot, the Lunar Energy Collection Terminal enters a cooldown period. The cooldown duration can be customized in the level.'**
  String get lunarTerminalHelpFixed;

  /// No description provided for @lunarTerminalCollectorCooldown.
  ///
  /// In en, this message translates to:
  /// **'Robot deployment cooldown (CollectorCooldown, seconds)'**
  String get lunarTerminalCollectorCooldown;

  /// No description provided for @lunarMineVeinHelpTitle.
  ///
  /// In en, this message translates to:
  /// **'Crystal Veins'**
  String get lunarMineVeinHelpTitle;

  /// No description provided for @lunarMineVeinHelpOverview.
  ///
  /// In en, this message translates to:
  /// **'Places Lunar Energy Crystal Veins on the lawn at the start of the level, as commonly seen in Moon Base. Veins initially provide no energy. Once the configured wave begins, a crystal of the corresponding type grows at the same position and can be mined according to its properties. Select a vein type, then tap a grid cell to place it. Right-click on desktop or long-press on mobile to remove it.'**
  String get lunarMineVeinHelpOverview;

  /// No description provided for @lunarMineVeinTypePalette.
  ///
  /// In en, this message translates to:
  /// **'Crystal vein type'**
  String get lunarMineVeinTypePalette;

  /// No description provided for @lunarMineVeinHelpHardened.
  ///
  /// In en, this message translates to:
  /// **'Protected by a sturdy outer layer of rock. The shell must first be destroyed by plant attacks before the crystal can be mined normally. Hard-Shell Crystal Veins always grow the 3,000 HP version of the Hard-Shell Crystal.'**
  String get lunarMineVeinHelpHardened;

  /// No description provided for @lunarMineVeinHelpFragile.
  ///
  /// In en, this message translates to:
  /// **'Mining continuously consumes its durability until the crystal shatters. Special Fragile Crystal Veins containing Cosmic Plant Food can also be placed.'**
  String get lunarMineVeinHelpFragile;

  /// No description provided for @lunarMineVeinHelpRadiation.
  ///
  /// In en, this message translates to:
  /// **'Periodically releases radiation in all directions. Plants exposed to the radiation will randomly transform into other plants, while irradiated zombies will either take damage or mutate into a Cosmic Radiation Gargantuar. Cosmic Radiation Gargantuars have extremely high health and will also irradiate nearby plants and zombies when defeated.'**
  String get lunarMineVeinHelpRadiation;

  /// No description provided for @lunarMineVeinHelpWaveTitle.
  ///
  /// In en, this message translates to:
  /// **'Wave numbering'**
  String get lunarMineVeinHelpWaveTitle;

  /// No description provided for @lunarMineVeinHelpWave.
  ///
  /// In en, this message translates to:
  /// **'Growth wave (EmergenceWave) is numbered from 1. Enter 1 to grow on the first wave, 2 to grow on the second wave, and so on.'**
  String get lunarMineVeinHelpWave;

  /// No description provided for @lunarMineVeinPlacements.
  ///
  /// In en, this message translates to:
  /// **'Vein placements (VeinPlacements)'**
  String get lunarMineVeinPlacements;

  /// No description provided for @lunarMineVeinModuleExpectationLabel.
  ///
  /// In en, this message translates to:
  /// **'Crystal Veins'**
  String get lunarMineVeinModuleExpectationLabel;

  /// No description provided for @lunarMineVeinModulePreviewEmerging.
  ///
  /// In en, this message translates to:
  /// **'Lunar Energy Crystals emerging this wave:'**
  String get lunarMineVeinModulePreviewEmerging;

  /// No description provided for @lunarMineEmergenceWave.
  ///
  /// In en, this message translates to:
  /// **'Growth wave (EmergenceWave, 1-based)'**
  String get lunarMineEmergenceWave;

  /// No description provided for @moonPlacementGestureHint.
  ///
  /// In en, this message translates to:
  /// **'Tap an empty tile to add an entry. Right-click or long-press an occupied tile to remove it.'**
  String get moonPlacementGestureHint;

  /// No description provided for @moduleTitle_GladiatorRowModuleProperties.
  ///
  /// In en, this message translates to:
  /// **'Gladiatorial Row'**
  String get moduleTitle_GladiatorRowModuleProperties;

  /// No description provided for @moduleDesc_GladiatorRowModuleProperties.
  ///
  /// In en, this message translates to:
  /// **'Temporarily seal off five tiles in a row, with rewards or penalties based on the duel’s outcome'**
  String get moduleDesc_GladiatorRowModuleProperties;

  /// No description provided for @gladiatorSettings.
  ///
  /// In en, this message translates to:
  /// **'Global duel, reward and penalty settings'**
  String get gladiatorSettings;

  /// No description provided for @gladiatorArenaDuration.
  ///
  /// In en, this message translates to:
  /// **'Duel duration (ArenaDuration, seconds)'**
  String get gladiatorArenaDuration;

  /// No description provided for @gladiatorRewardCount.
  ///
  /// In en, this message translates to:
  /// **'Plant Food reward (PlantWinPlantfoodCount)'**
  String get gladiatorRewardCount;

  /// No description provided for @gladiatorPunishmentCount.
  ///
  /// In en, this message translates to:
  /// **'Penalty cage count (ZombieWinPunishmentCageCount)'**
  String get gladiatorPunishmentCount;

  /// No description provided for @gladiatorPunishmentDuration.
  ///
  /// In en, this message translates to:
  /// **'Penalty drop duration (ZombieWinPunishmentDuration, seconds)'**
  String get gladiatorPunishmentDuration;

  /// No description provided for @gladiatorPunishmentLevel.
  ///
  /// In en, this message translates to:
  /// **'Penalty zombie level (ZombieWinPunishmentZombieLevel)'**
  String get gladiatorPunishmentLevel;

  /// No description provided for @gladiatorEncounters.
  ///
  /// In en, this message translates to:
  /// **'Duel schedule (Encounters)'**
  String get gladiatorEncounters;

  /// No description provided for @gladiatorWave.
  ///
  /// In en, this message translates to:
  /// **'Trigger wave (Wave, starts at 0)'**
  String get gladiatorWave;

  /// No description provided for @gladiatorRow.
  ///
  /// In en, this message translates to:
  /// **'Row (Row, starts at 0)'**
  String get gladiatorRow;

  /// No description provided for @gladiatorWarningDuration.
  ///
  /// In en, this message translates to:
  /// **'Zomboss arrival warning time (WarningDuration, seconds)'**
  String get gladiatorWarningDuration;

  /// No description provided for @gladiatorFirstCageDelay.
  ///
  /// In en, this message translates to:
  /// **'First cage drop delay (FirstCageDelay, seconds)'**
  String get gladiatorFirstCageDelay;

  /// No description provided for @gladiatorPreviewTitle.
  ///
  /// In en, this message translates to:
  /// **'Gladiatorial Row area preview'**
  String get gladiatorPreviewTitle;

  /// No description provided for @gladiatorPreviewLegend.
  ///
  /// In en, this message translates to:
  /// **'The green tile marks the trophy fixed in column 5; red tiles mark the rest of the arena. Zombie icons show cage spawn positions, and each tile’s number shows the zombie count. Tap the grid to select a row.'**
  String get gladiatorPreviewLegend;

  /// No description provided for @gladiatorSpawns.
  ///
  /// In en, this message translates to:
  /// **'Cage spawn schedule (Spawns)'**
  String get gladiatorSpawns;

  /// No description provided for @gladiatorAddSpawn.
  ///
  /// In en, this message translates to:
  /// **'Add cage spawn'**
  String get gladiatorAddSpawn;

  /// No description provided for @gladiatorSpawnTime.
  ///
  /// In en, this message translates to:
  /// **'Spawn delay after the duel begins (Time, seconds)'**
  String get gladiatorSpawnTime;

  /// No description provided for @gladiatorSpawnColumn.
  ///
  /// In en, this message translates to:
  /// **'Spawn column (GridX, starts at 0)'**
  String get gladiatorSpawnColumn;

  /// No description provided for @gladiatorSpawnCount.
  ///
  /// In en, this message translates to:
  /// **'Spawn count (Count)'**
  String get gladiatorSpawnCount;

  /// No description provided for @gladiatorSpawnInterval.
  ///
  /// In en, this message translates to:
  /// **'Spawn interval (Interval, seconds)'**
  String get gladiatorSpawnInterval;

  /// No description provided for @gladiatorSpawnLevel.
  ///
  /// In en, this message translates to:
  /// **'Zombie level (Level)'**
  String get gladiatorSpawnLevel;

  /// No description provided for @gladiatorPunishmentPool.
  ///
  /// In en, this message translates to:
  /// **'Defeat penalty zombie pool (ZombieWinPunishmentZombiePool)'**
  String get gladiatorPunishmentPool;

  /// No description provided for @gladiatorPunishmentHint.
  ///
  /// In en, this message translates to:
  /// **'After a defeat, penalty cages select zombies from this list by weight. Higher weights increase the chance of being chosen.'**
  String get gladiatorPunishmentHint;

  /// No description provided for @gladiatorAddPunishment.
  ///
  /// In en, this message translates to:
  /// **'Add penalty zombie'**
  String get gladiatorAddPunishment;

  /// No description provided for @gladiatorWeight.
  ///
  /// In en, this message translates to:
  /// **'Spawn weight (Weight)'**
  String get gladiatorWeight;

  /// No description provided for @gladiatorCompatibilityWarningTitle.
  ///
  /// In en, this message translates to:
  /// **'Module compatibility warning'**
  String get gladiatorCompatibilityWarningTitle;

  /// No description provided for @gladiatorWaveGeneratorCompatibilityWarning.
  ///
  /// In en, this message translates to:
  /// **'Gladiatorial Row does not work with Wave Generator. Use Wave Manager instead.'**
  String get gladiatorWaveGeneratorCompatibilityWarning;

  /// No description provided for @gladiatorUnderwaterMismatchWarning.
  ///
  /// In en, this message translates to:
  /// **'The current lawn uses a six-row Underwater World appearance. Gladiatorial Rows will not appear on this lawn. Use a five-row lawn instead.'**
  String get gladiatorUnderwaterMismatchWarning;

  /// No description provided for @gladiatorLegacyModeWarning.
  ///
  /// In en, this message translates to:
  /// **'This module’s duel mode (GameplayVersion) is not set to 1. It may be using the retired legacy mode instead of trophy duel mode, so the Gladiatorial Row area cannot be previewed.'**
  String get gladiatorLegacyModeWarning;

  /// No description provided for @gladiatorUseTrophyMode.
  ///
  /// In en, this message translates to:
  /// **'Switch to trophy duel mode'**
  String get gladiatorUseTrophyMode;

  /// No description provided for @gladiatorHelpTipsTitle.
  ///
  /// In en, this message translates to:
  /// **'Friendly Reminder'**
  String get gladiatorHelpTipsTitle;

  /// No description provided for @gladiatorHelpOverview.
  ///
  /// In en, this message translates to:
  /// **'This module configures the wave-triggered Gladiatorial Row mechanic commonly seen in the Roman Glory Secret Realm. On the specified wave, Roman Zomboss appears in the selected row and temporarily seals off five consecutive tiles. Existing plants and zombies inside those tiles are destroyed, while plants and zombies outside them stop moving and acting.\nA trophy rises in the center of the arena. Zombies arrive in cages airdropped on the right. Protect the trophy until the timer expires to win. Winning grants a large Plant Food reward; losing causes cages to drop across the lawn and release many zombies. After the duel, all plants and zombies remaining inside the arena are destroyed.'**
  String get gladiatorHelpOverview;

  /// No description provided for @gladiatorHelpUsage.
  ///
  /// In en, this message translates to:
  /// **'The duel duration, Plant Food reward and penalty drop settings above, along with the penalty zombie pool and weights below, are global settings shared by every duel in this module. Select “Add duel” to configure an individual duel. When you add a zombie, its resource groups are automatically added to the module. The wave (Wave), row (Row) and spawn column (GridX) are all numbered from 0: Wave 0 corresponds to timeline wave 1, and Wave 4 to wave 5. The editor defaults to trophy duel mode (GameplayVersion 1). Setting it to 0 enables a different, retired duel mode, which you can explore through manual editing.'**
  String get gladiatorHelpUsage;

  /// No description provided for @gladiatorHelpTips.
  ///
  /// In en, this message translates to:
  /// **'During a duel, planting no longer costs sun, but plants still occupy the Life Support System’s power capacity.\nInstant-kill attacks from Gargantuars and similar zombies cannot damage the trophy.\nPlant projectiles leaving the arena are blocked by its fences. Zombies that leave the arena, and zombies using certain abilities aimed outside the arena, become frozen in place. They are released when the duel timer ends and resume attacking.\nGladiatorial Rows do not appear on six-row lawns with an Underwater World appearance, such as 20,000 Leagues Under the Sea or Atlantis. The Gladiatorial Row module also does not work with Wave Generator.'**
  String get gladiatorHelpTips;

  /// No description provided for @radiationMeteorHelpTitle.
  ///
  /// In en, this message translates to:
  /// **'Radioactive Meteorite'**
  String get radiationMeteorHelpTitle;

  /// No description provided for @radiationMeteorHelpOverview.
  ///
  /// In en, this message translates to:
  /// **'Drops special Radioactive Meteorites on specified waves, as commonly seen in Moon BaseZ. Before a meteorite lands, a red-text warning appears in the level and a crosshair marks its expected landing tile. After the configured warning duration, the meteorite falls straight down, instantly destroying units on its landing tile, then slowly contaminates surrounding tiles clockwise.\nZombies on contaminated tiles gain increased movement speed and health regeneration, while Cosmic plants continuously take damage.'**
  String get radiationMeteorHelpOverview;

  /// No description provided for @radiationMeteorHelpWaveTitle.
  ///
  /// In en, this message translates to:
  /// **'Wave numbering'**
  String get radiationMeteorHelpWaveTitle;

  /// No description provided for @radiationMeteorHelpWave.
  ///
  /// In en, this message translates to:
  /// **'Radioactive Meteorite landing waves use a 0-based index: enter 0 for the first wave, 1 for the second wave, and so on. When a landing schedule group is added in the editor, Group 1 defaults to 0, Group 2 to 1, and so forth.'**
  String get radiationMeteorHelpWave;

  /// No description provided for @radiationMeteorHelpMiningTitle.
  ///
  /// In en, this message translates to:
  /// **'Mining to destroy'**
  String get radiationMeteorHelpMiningTitle;

  /// No description provided for @radiationMeteorHelpMining.
  ///
  /// In en, this message translates to:
  /// **'Lunar Energy Collection Units can mine Radioactive Meteorites and destroy them after a period of time. After a meteorite is destroyed, the terminal grants the player a permanent power-capacity increase for the current level and removes the contamination effects.'**
  String get radiationMeteorHelpMining;

  /// No description provided for @radiationMeteorParameters.
  ///
  /// In en, this message translates to:
  /// **'Meteor parameters'**
  String get radiationMeteorParameters;

  /// No description provided for @radiationMeteorWarningDuration.
  ///
  /// In en, this message translates to:
  /// **'Warning duration (WarningDuration, seconds)'**
  String get radiationMeteorWarningDuration;

  /// No description provided for @radiationMeteorPollutionInterval.
  ///
  /// In en, this message translates to:
  /// **'Contamination interval (PollutionInterval, seconds)'**
  String get radiationMeteorPollutionInterval;

  /// No description provided for @radiationMeteorMiningDuration.
  ///
  /// In en, this message translates to:
  /// **'Required mining duration (MiningDurationRequired, seconds)'**
  String get radiationMeteorMiningDuration;

  /// No description provided for @radiationMeteorPowerReward.
  ///
  /// In en, this message translates to:
  /// **'Power reward on destruction (PowerRewardOnDestroy)'**
  String get radiationMeteorPowerReward;

  /// No description provided for @radiationMeteorSpawnSchedule.
  ///
  /// In en, this message translates to:
  /// **'Landing schedule (SpawnSchedule)'**
  String get radiationMeteorSpawnSchedule;

  /// No description provided for @radiationMeteorWave.
  ///
  /// In en, this message translates to:
  /// **'Wave (Wave, 0-based)'**
  String get radiationMeteorWave;

  /// No description provided for @radiationMeteorModuleExpectationLabel.
  ///
  /// In en, this message translates to:
  /// **'Radioactive Meteorite'**
  String get radiationMeteorModuleExpectationLabel;

  /// No description provided for @radiationMeteorModulePreviewLanding.
  ///
  /// In en, this message translates to:
  /// **'Meteorites landing this wave:'**
  String get radiationMeteorModulePreviewLanding;

  /// No description provided for @eventTitle_GravityGeneratorWaveActionProps.
  ///
  /// In en, this message translates to:
  /// **'Gravity Generator'**
  String get eventTitle_GravityGeneratorWaveActionProps;

  /// No description provided for @eventDesc_GravityGeneratorWaveActionProps.
  ///
  /// In en, this message translates to:
  /// **'Applies different Gravity states to plants or grid cells'**
  String get eventDesc_GravityGeneratorWaveActionProps;

  /// No description provided for @gravityLevel.
  ///
  /// In en, this message translates to:
  /// **'Gravity state (GravityLevel)'**
  String get gravityLevel;

  /// No description provided for @gravityAnti.
  ///
  /// In en, this message translates to:
  /// **'Anti-Gravity (anti)'**
  String get gravityAnti;

  /// No description provided for @gravityHeavy.
  ///
  /// In en, this message translates to:
  /// **'Hypergravity (heavy)'**
  String get gravityHeavy;

  /// No description provided for @gravityTargetType.
  ///
  /// In en, this message translates to:
  /// **'Target type (TargetType)'**
  String get gravityTargetType;

  /// No description provided for @gravityTargetPlant.
  ///
  /// In en, this message translates to:
  /// **'Random plant (plant)'**
  String get gravityTargetPlant;

  /// No description provided for @gravityTargetGrid.
  ///
  /// In en, this message translates to:
  /// **'Fixed grid cell (grid)'**
  String get gravityTargetGrid;

  /// No description provided for @gravityRangeX.
  ///
  /// In en, this message translates to:
  /// **'Horizontal offset (Range.mX)'**
  String get gravityRangeX;

  /// No description provided for @gravityRangeY.
  ///
  /// In en, this message translates to:
  /// **'Vertical offset (Range.mY)'**
  String get gravityRangeY;

  /// No description provided for @gravityRangeWidth.
  ///
  /// In en, this message translates to:
  /// **'Range width (Range.mWidth, cells)'**
  String get gravityRangeWidth;

  /// No description provided for @gravityRangeHeight.
  ///
  /// In en, this message translates to:
  /// **'Range height (Range.mHeight, cells)'**
  String get gravityRangeHeight;

  /// No description provided for @gravityTargetX.
  ///
  /// In en, this message translates to:
  /// **'Target column (TargetGrid.mX, 0-based)'**
  String get gravityTargetX;

  /// No description provided for @gravityTargetY.
  ///
  /// In en, this message translates to:
  /// **'Target row (TargetGrid.mY, 0-based)'**
  String get gravityTargetY;

  /// No description provided for @gravityPreviewTitle.
  ///
  /// In en, this message translates to:
  /// **'Gravity field range preview'**
  String get gravityPreviewTitle;

  /// No description provided for @gravityPlantRangeHint.
  ///
  /// In en, this message translates to:
  /// **'Choose a random plant on the lawn as the reference point and affect plants and zombies within the range. The cross marks the chosen plant. The range extends right and down from its offset position, including the starting tile. Negative offsets move the range origin left or up.'**
  String get gravityPlantRangeHint;

  /// No description provided for @gravityGridRangeHint.
  ///
  /// In en, this message translates to:
  /// **'Rows and columns start at 0. Tap the grid to select the reference tile. Add the horizontal and vertical offsets to that tile to find the range origin, then extend right and down. Width and height include the starting tile. With zero offsets, a width of 3 and height of 1 cover the target tile and the two tiles to its right.'**
  String get gravityGridRangeHint;

  /// No description provided for @gravityCenterLegend.
  ///
  /// In en, this message translates to:
  /// **'Cross: reference point'**
  String get gravityCenterLegend;

  /// No description provided for @gravityRestrictions.
  ///
  /// In en, this message translates to:
  /// **'Unaffected plants and zombies (TargetRestriction)'**
  String get gravityRestrictions;

  /// No description provided for @gravityRestrictionHint.
  ///
  /// In en, this message translates to:
  /// **'Plants and zombies in this list are unaffected by the gravity field. Leave it empty to exclude no additional types.'**
  String get gravityRestrictionHint;

  /// No description provided for @gravityAddPlantRestriction.
  ///
  /// In en, this message translates to:
  /// **'Add unaffected plants'**
  String get gravityAddPlantRestriction;

  /// No description provided for @gravityAddZombieRestriction.
  ///
  /// In en, this message translates to:
  /// **'Add unaffected zombies'**
  String get gravityAddZombieRestriction;

  /// No description provided for @gravityAdvancedSettings.
  ///
  /// In en, this message translates to:
  /// **'Action and timing parameters'**
  String get gravityAdvancedSettings;

  /// No description provided for @gravityActivationDelay.
  ///
  /// In en, this message translates to:
  /// **'Activation delay (ActivationDelay, seconds)'**
  String get gravityActivationDelay;

  /// No description provided for @gravityDuration.
  ///
  /// In en, this message translates to:
  /// **'Gravity state duration (Duration, seconds)'**
  String get gravityDuration;

  /// No description provided for @gravityDeployDuration.
  ///
  /// In en, this message translates to:
  /// **'Device deployment time (DeployDuration, seconds)'**
  String get gravityDeployDuration;

  /// No description provided for @gravityChargeDuration.
  ///
  /// In en, this message translates to:
  /// **'Charge time before applying gravity (ChargeDuration, seconds)'**
  String get gravityChargeDuration;

  /// No description provided for @gravityRetractDuration.
  ///
  /// In en, this message translates to:
  /// **'Device retraction cooldown (RetractDuration, seconds)'**
  String get gravityRetractDuration;

  /// No description provided for @gravityPlantExitDelay.
  ///
  /// In en, this message translates to:
  /// **'Time until a floating plant disappears (PlantExitDelay, seconds)'**
  String get gravityPlantExitDelay;

  /// No description provided for @gravityZombieRiseDuration.
  ///
  /// In en, this message translates to:
  /// **'Zombie ascent time (ZombieRiseDuration, seconds)'**
  String get gravityZombieRiseDuration;

  /// No description provided for @gravityZombieTranslateDuration.
  ///
  /// In en, this message translates to:
  /// **'Airborne zombie travel time (ZombieTranslateDuration, seconds)'**
  String get gravityZombieTranslateDuration;

  /// No description provided for @gravityZombieFallDuration.
  ///
  /// In en, this message translates to:
  /// **'Zombie landing time at its destination (ZombieFallDuration, seconds)'**
  String get gravityZombieFallDuration;

  /// No description provided for @gravityZombieLiftHeight.
  ///
  /// In en, this message translates to:
  /// **'Zombie lift height (ZombieLiftHeight)'**
  String get gravityZombieLiftHeight;

  /// No description provided for @gravityZombieForwardDistance.
  ///
  /// In en, this message translates to:
  /// **'Zombie forward distance (ZombieForwardDistance, 64 pixels = 1 tile)'**
  String get gravityZombieForwardDistance;

  /// No description provided for @gravityHeavyPlantSinkDuration.
  ///
  /// In en, this message translates to:
  /// **'Plant sinking duration (HeavyPlantSinkDuration, seconds)'**
  String get gravityHeavyPlantSinkDuration;

  /// No description provided for @gravityHelpParametersTitle.
  ///
  /// In en, this message translates to:
  /// **'Parameter Description'**
  String get gravityHelpParametersTitle;

  /// No description provided for @gravityHelpParameters.
  ///
  /// In en, this message translates to:
  /// **'By default, this event includes all parameters for both Anti-Gravity and Hypergravity. The action settings show only the parameters used by the selected state. Values entered for the other mode are retained when switching.'**
  String get gravityHelpParameters;

  /// No description provided for @gravityHelpTipsTitle.
  ///
  /// In en, this message translates to:
  /// **'Friendly Reminder'**
  String get gravityHelpTipsTitle;

  /// No description provided for @gravitySequentialNotice.
  ///
  /// In en, this message translates to:
  /// **'Gravity Generator events cannot run simultaneously. The previous Anti-Gravity or Hypergravity sequence must finish before the next one can run. Space out their trigger times.'**
  String get gravitySequentialNotice;

  /// No description provided for @gravityHelpOverview.
  ///
  /// In en, this message translates to:
  /// **'A device located at the zombie base that triggers as a preset battlefield event during designated waves. Once it emerges from the base, it locks onto plants or zombies within a fixed area on the lawn and fires a gravitational beam, applying different Gravity states and disrupting plants’ attack rhythm and zombies’ movement patterns.'**
  String get gravityHelpOverview;

  /// No description provided for @gravityHelpAnti.
  ///
  /// In en, this message translates to:
  /// **'Targeted plants slowly float upward and eventually drift off the battlefield and disappear. Targeted zombies rise and move forward, becoming immune to straight-shot attacks while airborne.\nWhen a plant under Anti-Gravity is within Gravitree’s attack range, Gravitree attacks and clears Anti-Gravity from plants within its range. Gravitree itself is immune to the Gravity Generator: it cannot be lifted into the air or pressed into the ground.'**
  String get gravityHelpAnti;

  /// No description provided for @gravityHelpHeavy.
  ///
  /// In en, this message translates to:
  /// **'Targeted plants are pressed halfway into the ground. While in this state, they cannot attack but can still be eaten by zombies. Targeted zombies advance steadily and become immune to knockback effects.\nCosmic Saucer can remove Hypergravity from zombies and put them into the Floating state instead. It can also remove Hypergravity from plants, restoring them to normal.'**
  String get gravityHelpHeavy;

  /// No description provided for @rocketLandingHelpTitle.
  ///
  /// In en, this message translates to:
  /// **'Rocket Landing'**
  String get rocketLandingHelpTitle;

  /// No description provided for @rocketLandingHelpOverview.
  ///
  /// In en, this message translates to:
  /// **'An event commonly used in Moon BaseZ. It spawns rockets at specified positions as objectives contested by both plants and zombies.'**
  String get rocketLandingHelpOverview;

  /// No description provided for @rocketLandingHelpPlantsTitle.
  ///
  /// In en, this message translates to:
  /// **'Plants take control'**
  String get rocketLandingHelpPlantsTitle;

  /// No description provided for @rocketLandingHelpPlants.
  ///
  /// In en, this message translates to:
  /// **'Plant a designated Cosmic plant inside a rocket. After a short time, the rocket launches, locks onto a high-threat zombie on the lawn, and bombards it for massive damage. Cosmic Pea releases ricocheting Cosmic projectiles; Cosmic Mushroom summons Mushroom Wormholes in the area; Cosmic Nut creates a short-lived small black hole that pulls and continuously damages nearby zombies.'**
  String get rocketLandingHelpPlants;

  /// No description provided for @rocketLandingHelpZombiesTitle.
  ///
  /// In en, this message translates to:
  /// **'Zombies take control'**
  String get rocketLandingHelpZombiesTitle;

  /// No description provided for @rocketLandingHelpZombies.
  ///
  /// In en, this message translates to:
  /// **'When a zombie enters a rocket, it launches after a short delay and lands farther back on the lawn, transporting the zombie to that tile. Some zombies cannot enter rockets.'**
  String get rocketLandingHelpZombies;

  /// No description provided for @rocketLandingSettings.
  ///
  /// In en, this message translates to:
  /// **'Rocket settings'**
  String get rocketLandingSettings;

  /// No description provided for @rocketSpawnInterval.
  ///
  /// In en, this message translates to:
  /// **'Spawn interval (SpawnInterval, seconds)'**
  String get rocketSpawnInterval;

  /// No description provided for @moduleTitle_LevelPowerupModuleProperties.
  ///
  /// In en, this message translates to:
  /// **'Power Ups'**
  String get moduleTitle_LevelPowerupModuleProperties;

  /// No description provided for @moduleDesc_LevelPowerupModuleProperties.
  ///
  /// In en, this message translates to:
  /// **'Enables the wonderfully interesting gesture system'**
  String get moduleDesc_LevelPowerupModuleProperties;

  /// No description provided for @powerUpsHelpTitle.
  ///
  /// In en, this message translates to:
  /// **'Power Ups'**
  String get powerUpsHelpTitle;

  /// No description provided for @powerUpsHelpOverview.
  ///
  /// In en, this message translates to:
  /// **'This wonderfully interesting mechanic makes a major return in the 13th Anniversary Secret Realm, allowing players to defeat zombies with specific gestures while a Power Up is active. Enabling this module lets you set the exact number of free uses for each Power Up in the level. Note that Power Snow and Power Flame from the international version do not exist in the Chinese version, and the Power Ups used in Vasebreaker and Beghouled cannot be added through this module.'**
  String get powerUpsHelpOverview;

  /// No description provided for @powerUpsAddTitle.
  ///
  /// In en, this message translates to:
  /// **'Add Power Up'**
  String get powerUpsAddTitle;

  /// No description provided for @powerUpsOrder.
  ///
  /// In en, this message translates to:
  /// **'Order'**
  String get powerUpsOrder;

  /// No description provided for @powerUpsOrderInfo.
  ///
  /// In en, this message translates to:
  /// **'Power Ups appear in the game in the order shown here. Drag the ⋮⋮ handles to reorder them. Removing a Power Up from the list prevents it from appearing in the game; it can be added back in this module whenever needed.'**
  String get powerUpsOrderInfo;

  /// No description provided for @powerUpsFreeUseCount.
  ///
  /// In en, this message translates to:
  /// **'Free uses (FreeUseCount)'**
  String get powerUpsFreeUseCount;

  /// No description provided for @powerZap.
  ///
  /// In en, this message translates to:
  /// **'Power Zap'**
  String get powerZap;

  /// No description provided for @powerZapInfo.
  ///
  /// In en, this message translates to:
  /// **'Tap or drag across zombies to unleash a powerful electric shock that continuously damages every zombie it touches.'**
  String get powerZapInfo;

  /// No description provided for @powerToss.
  ///
  /// In en, this message translates to:
  /// **'Power Toss'**
  String get powerToss;

  /// No description provided for @powerTossInfo.
  ///
  /// In en, this message translates to:
  /// **'Swipe quickly across a zombie to fling it into the air. Swipe again to throw it completely off the lawn.'**
  String get powerTossInfo;

  /// No description provided for @powerPinch.
  ///
  /// In en, this message translates to:
  /// **'Power Pinch'**
  String get powerPinch;

  /// No description provided for @powerPinchInfo.
  ///
  /// In en, this message translates to:
  /// **'Pinch a zombie with two fingers like a pair of scissors to snip off its head and quickly remove the threat.'**
  String get powerPinchInfo;

  /// No description provided for @moduleTitle_StatueMazeModuleProperties.
  ///
  /// In en, this message translates to:
  /// **'Bemarbled'**
  String get moduleTitle_StatueMazeModuleProperties;

  /// No description provided for @moduleDesc_StatueMazeModuleProperties.
  ///
  /// In en, this message translates to:
  /// **'Find every hidden zombie in the statue array after it rotates'**
  String get moduleDesc_StatueMazeModuleProperties;

  /// No description provided for @moduleHelpStatueMazeOverviewBody.
  ///
  /// In en, this message translates to:
  /// **'A Renaissance Ages-exclusive minigame. This minigame consists of several rounds, each with an array of statues, some of which conceal Aristocrat Zombies. At the start of each round, the locations of the hidden zombies are revealed. The entire array then rotates several times to challenge the player’s memory. Once the rotations finish, the player must use their limited supply of tools to smash every statue hiding a zombie. The level is lost if any zombies remain undiscovered when all attempts have been used. The player can also spend diamonds to buy extra attempts when they run out.'**
  String get moduleHelpStatueMazeOverviewBody;

  /// No description provided for @moduleHelpStatueMazeTimingTitle.
  ///
  /// In en, this message translates to:
  /// **'Timing parameters'**
  String get moduleHelpStatueMazeTimingTitle;

  /// No description provided for @moduleHelpStatueMazeTimingBody.
  ///
  /// In en, this message translates to:
  /// **'Initial reveal time (DisplayTime): The time between revealing the statues that hide zombies and the start of the first rotation.\nTotal step duration (WaitDuration): The total time from the start of the current rotation to the start of the next. The final rotation step in each round also runs for this full duration before the player can act.\nRotation duration (RotateTime): The duration of the current 90° rotation animation.\nThe actual pause between rotations is therefore the total step duration minus the rotation duration. If the rotation duration exceeds the total step duration, the next rotation starts before the previous one finishes and resets the statues’ movement parameters. This may cause abnormal movement paths or animations.\nThe black-screen transition between rounds has a fixed duration and cannot be customized in the level.'**
  String get moduleHelpStatueMazeTimingBody;

  /// No description provided for @statueMazeDisplayTime.
  ///
  /// In en, this message translates to:
  /// **'Initial reveal time (DisplayTime; seconds)'**
  String get statueMazeDisplayTime;

  /// No description provided for @statueMazeTargetNum.
  ///
  /// In en, this message translates to:
  /// **'Zombie count (TargetNum)'**
  String get statueMazeTargetNum;

  /// No description provided for @statueMazeBonusLife.
  ///
  /// In en, this message translates to:
  /// **'Extra attempts (BonusLife)'**
  String get statueMazeBonusLife;

  /// No description provided for @statueMazeWaitDuration.
  ///
  /// In en, this message translates to:
  /// **'Total step duration (WaitDuration; seconds)'**
  String get statueMazeWaitDuration;

  /// No description provided for @statueMazeRotateTime.
  ///
  /// In en, this message translates to:
  /// **'Rotation duration (RotateTime; seconds)'**
  String get statueMazeRotateTime;

  /// No description provided for @statueMazeAddSet.
  ///
  /// In en, this message translates to:
  /// **'Add round'**
  String get statueMazeAddSet;

  /// No description provided for @statueMazeSets.
  ///
  /// In en, this message translates to:
  /// **'Rotation rounds'**
  String get statueMazeSets;

  /// No description provided for @statueMazeRotations.
  ///
  /// In en, this message translates to:
  /// **'Rotation steps'**
  String get statueMazeRotations;

  /// No description provided for @statueMazeGridSize.
  ///
  /// In en, this message translates to:
  /// **'Array size'**
  String get statueMazeGridSize;

  /// No description provided for @statueMazeNoRotations.
  ///
  /// In en, this message translates to:
  /// **'No rotation steps added'**
  String get statueMazeNoRotations;

  /// No description provided for @moduleHelpStatueMazeRotationsBody.
  ///
  /// In en, this message translates to:
  /// **'Each round can contain multiple rotation steps. Each step rotates the entire array by 90°. “C” means clockwise and “AC” means counterclockwise. Tap the play button below the grid to preview all rotation steps in the current round.'**
  String get moduleHelpStatueMazeRotationsBody;

  /// No description provided for @statueMazeRotationsHint.
  ///
  /// In en, this message translates to:
  /// **'Tap the arrow to switch rotation direction. Tap a card to edit that step’s parameters. Long-press a card to delete the step.'**
  String get statueMazeRotationsHint;

  /// No description provided for @statueMazeRemoveRotationConfirm.
  ///
  /// In en, this message translates to:
  /// **'Remove this rotation step?'**
  String get statueMazeRemoveRotationConfirm;

  /// No description provided for @camelGenerationParameters.
  ///
  /// In en, this message translates to:
  /// **'Spawn parameters'**
  String get camelGenerationParameters;

  /// No description provided for @camelSpawnDistance.
  ///
  /// In en, this message translates to:
  /// **'Spawn distance'**
  String get camelSpawnDistance;

  /// No description provided for @camelSpawnPreview.
  ///
  /// In en, this message translates to:
  /// **'Spawn distance preview'**
  String get camelSpawnPreview;

  /// No description provided for @camelSpawnCoordinatesHint.
  ///
  /// In en, this message translates to:
  /// **'Horizontal coordinates start at 0 at the left edge of column 1, with 64 units per tile. Colored lines mark the spawn distance parameters. The extra backward offset only applies when zombies already occupy the spawn position.'**
  String get camelSpawnCoordinatesHint;

  /// No description provided for @camelCompatibilityWarning.
  ///
  /// In en, this message translates to:
  /// **'This module only supports levels that use the special Mummy Memory Camel Zombies and a Seed Bank in Preset mode. The game will crash if other zombies appear or the Seed Bank uses Chooser mode.'**
  String get camelCompatibilityWarning;

  /// No description provided for @camelHelpSpawningTitle.
  ///
  /// In en, this message translates to:
  /// **'Spawn behavior'**
  String get camelHelpSpawningTitle;

  /// No description provided for @camelHelpTutorialTitle.
  ///
  /// In en, this message translates to:
  /// **'Show tutorial dialogue'**
  String get camelHelpTutorialTitle;

  /// No description provided for @camelHelpTipsTitle.
  ///
  /// In en, this message translates to:
  /// **'Friendly Reminder'**
  String get camelHelpTipsTitle;

  /// No description provided for @moduleHelpCamelTutorialBody.
  ///
  /// In en, this message translates to:
  /// **'Enable “Show tutorial dialogue” to have Crazy Dave and Penny explain how to win by matching pairs before the level starts. The dialogue is fixed to the story shown when playing Ancient Egypt - Day 7 for the first time.'**
  String get moduleHelpCamelTutorialBody;

  /// No description provided for @moduleHelpCamelTipsBody.
  ///
  /// In en, this message translates to:
  /// **'This module only supports levels that use the special Mummy Memory Camel Zombies and a Seed Bank in Preset mode. The game will crash if other zombies appear or the Seed Bank uses Chooser mode.\nPlants can interact with Mummy Memory Camel Zombies normally, but these zombies may have animation issues when hypnotized or defeated, among other situations.'**
  String get moduleHelpCamelTipsBody;

  /// No description provided for @conflictDesc_CamelMinigameChooser.
  ///
  /// In en, this message translates to:
  /// **'Mummy Memory conflicts with the Seed Bank’s Chooser mode and will crash the level. Switch the Seed Bank to Preset mode.'**
  String get conflictDesc_CamelMinigameChooser;

  /// No description provided for @moduleTitle_CamelMinigameProperties.
  ///
  /// In en, this message translates to:
  /// **'Mummy Memory'**
  String get moduleTitle_CamelMinigameProperties;

  /// No description provided for @moduleDesc_CamelMinigameProperties.
  ///
  /// In en, this message translates to:
  /// **'Configures the spawn range and parameters of Camel Zombies in Mummy Memory'**
  String get moduleDesc_CamelMinigameProperties;

  /// No description provided for @moduleHelpCamelOverviewBody.
  ///
  /// In en, this message translates to:
  /// **'An Ancient Egypt-exclusive minigame. Special Mummy Memory Camel Zombies emerge from the ground. Tap a zombie to flip its sign and reveal a symbol, then find its match. Matching two symbols immediately defeats both zombies. If the symbols differ, the signs flip back and the zombies keep moving. If only one zombie remains, or the last two have different symbols, they are defeated as soon as their signs are flipped.'**
  String get moduleHelpCamelOverviewBody;

  /// No description provided for @moduleHelpCamelSpawningBody.
  ///
  /// In en, this message translates to:
  /// **'With this module, zombies from regular spawn events, including Basic Spawner and Underwater Spawner, emerge directly from the ground. Adjust the parameters to set their spawn range. Horizontal coordinates start at 0 at the left edge of column 1, with 64 units per tile. This spawn behavior does not affect zombies generated through other events or modules, such as Sandstorm, Transport Boat Assault, or Grid Item Spawn.'**
  String get moduleHelpCamelSpawningBody;

  /// No description provided for @camelAdditionalXBuffer.
  ///
  /// In en, this message translates to:
  /// **'Extra backward offset for occupied spawn positions (AdditionalXBufferBetweenChains)'**
  String get camelAdditionalXBuffer;

  /// No description provided for @camelRiseStagger.
  ///
  /// In en, this message translates to:
  /// **'Rise interval between adjacent Camel Zombies in a group (CamelSegmentRiseStagger; seconds)'**
  String get camelRiseStagger;

  /// No description provided for @camelCardMatchTime.
  ///
  /// In en, this message translates to:
  /// **'Response time after a successful match (CardMatchTime; seconds)'**
  String get camelCardMatchTime;

  /// No description provided for @camelCardMatchingTime.
  ///
  /// In en, this message translates to:
  /// **'Sign flip time (CardMatchingTime; seconds)'**
  String get camelCardMatchingTime;

  /// No description provided for @camelCardNoMatchTime.
  ///
  /// In en, this message translates to:
  /// **'Idle time after mismatched symbols or a single flipped sign (CardNoMatchTime; seconds)'**
  String get camelCardNoMatchTime;

  /// No description provided for @camelCardTypesUsed.
  ///
  /// In en, this message translates to:
  /// **'Symbol types (CardTypesUsed)'**
  String get camelCardTypesUsed;

  /// No description provided for @camelTutorialRiseDelay.
  ///
  /// In en, this message translates to:
  /// **'Time to emerge from the ground (InitialTutorialZombieRiseDelay; seconds)'**
  String get camelTutorialRiseDelay;

  /// No description provided for @camelMaxSpawnX.
  ///
  /// In en, this message translates to:
  /// **'Maximum spawn distance (MaxSpawnX)'**
  String get camelMaxSpawnX;

  /// No description provided for @camelMinSpawnXEnd.
  ///
  /// In en, this message translates to:
  /// **'Maximum spawn distance end position (MinSpawnXEnd)'**
  String get camelMinSpawnXEnd;

  /// No description provided for @camelMinSpawnXStart.
  ///
  /// In en, this message translates to:
  /// **'Minimum spawn distance start position (MinSpawnXStart)'**
  String get camelMinSpawnXStart;

  /// No description provided for @camelShowTutorial.
  ///
  /// In en, this message translates to:
  /// **'Show tutorial dialogue (ShowTutorial)'**
  String get camelShowTutorial;

  /// No description provided for @moduleTitle_OakTrainProperties.
  ///
  /// In en, this message translates to:
  /// **'Oak Archery'**
  String get moduleTitle_OakTrainProperties;

  /// No description provided for @moduleDesc_OakTrainProperties.
  ///
  /// In en, this message translates to:
  /// **'Uses Oak Archer\'s arrows to land headshots and earn points'**
  String get moduleDesc_OakTrainProperties;

  /// No description provided for @moduleHelpOakTrainOverviewBody.
  ///
  /// In en, this message translates to:
  /// **'A Dark Ages-exclusive minigame. An Oak Archer is placed in column 1, row 3. Control him and use three types of arrows to land headshots on targets and win. The game is lost if Oak Archer runs out of health or a zombie reaches the house.'**
  String get moduleHelpOakTrainOverviewBody;

  /// No description provided for @moduleHelpOakTrainScoresBody.
  ///
  /// In en, this message translates to:
  /// **'Defeating different zombie types awards different scores, which are converted into coins when the level is completed. Collecting these coins has no effect when the Creative Courtyard module is in use. This score is calculated separately from the score awarded for defeating zombies by the Level Scoring module and does not count toward score challenges.'**
  String get moduleHelpOakTrainScoresBody;

  /// No description provided for @moduleHelpOakTrainArrowsBody.
  ///
  /// In en, this message translates to:
  /// **'Oak Archer can fire three types of arrows: normal arrows hit a single target, power arrows deal double damage in a small area, and scatter arrows fire seven individual shots in a spread. When normal arrows run out, 12 are automatically reloaded after 10 seconds. Other arrows are obtained by shooting the colored Power Spheres on the lawn. Scatter arrows can also be purchased with diamonds during the level.'**
  String get moduleHelpOakTrainArrowsBody;

  /// No description provided for @oakTrainTotalLife.
  ///
  /// In en, this message translates to:
  /// **'Total HP (TotalLife)'**
  String get oakTrainTotalLife;

  /// No description provided for @oakTrainArrowScore.
  ///
  /// In en, this message translates to:
  /// **'Base attack score (ArrowScore)'**
  String get oakTrainArrowScore;

  /// No description provided for @oakTrainWizardScore.
  ///
  /// In en, this message translates to:
  /// **'Wizard kill score (WizardScore)'**
  String get oakTrainWizardScore;

  /// No description provided for @oakTrainArchmageScore.
  ///
  /// In en, this message translates to:
  /// **'Archmage kill score (ArchmageScore)'**
  String get oakTrainArchmageScore;

  /// No description provided for @oakTrainBossScore.
  ///
  /// In en, this message translates to:
  /// **'Gargantuar boss kill score (BossScore)'**
  String get oakTrainBossScore;

  /// No description provided for @oakTrainHealNum.
  ///
  /// In en, this message translates to:
  /// **'Health restored by Green Health Spheres (HealNum)'**
  String get oakTrainHealNum;

  /// No description provided for @oakTrainArrowPowerNum.
  ///
  /// In en, this message translates to:
  /// **'Power arrows supplied by Blue Power Spheres (ArrowPowerNum)'**
  String get oakTrainArrowPowerNum;

  /// No description provided for @oakTrainArrowMultipleNum.
  ///
  /// In en, this message translates to:
  /// **'Scatter arrows supplied by Yellow Power Spheres (ArrowMultipleNum)'**
  String get oakTrainArrowMultipleNum;

  /// No description provided for @oakTrainInitArrowsNum.
  ///
  /// In en, this message translates to:
  /// **'Initial arrow counts'**
  String get oakTrainInitArrowsNum;

  /// No description provided for @oakTrainInitArrowNormal.
  ///
  /// In en, this message translates to:
  /// **'Normal arrows'**
  String get oakTrainInitArrowNormal;

  /// No description provided for @oakTrainInitArrowPower.
  ///
  /// In en, this message translates to:
  /// **'Power arrows'**
  String get oakTrainInitArrowPower;

  /// No description provided for @oakTrainInitArrowSplit.
  ///
  /// In en, this message translates to:
  /// **'Scatter arrows'**
  String get oakTrainInitArrowSplit;

  /// No description provided for @moduleTitle_OakTrainIntroProperties.
  ///
  /// In en, this message translates to:
  /// **'Oak Archery Tutorial'**
  String get moduleTitle_OakTrainIntroProperties;

  /// No description provided for @moduleDesc_OakTrainIntroProperties.
  ///
  /// In en, this message translates to:
  /// **'Introduces the basics of Oak Archery before the level begins'**
  String get moduleDesc_OakTrainIntroProperties;

  /// No description provided for @moduleTitle_GoldRoadProperties.
  ///
  /// In en, this message translates to:
  /// **'Golden Road'**
  String get moduleTitle_GoldRoadProperties;

  /// No description provided for @moduleDesc_GoldRoadProperties.
  ///
  /// In en, this message translates to:
  /// **'Turns the first and fifth rows into unsodded areas'**
  String get moduleDesc_GoldRoadProperties;

  /// No description provided for @goldRoadNonLostCityLawnWarningTitle.
  ///
  /// In en, this message translates to:
  /// **'Lawn appearance notice'**
  String get goldRoadNonLostCityLawnWarningTitle;

  /// No description provided for @goldRoadNonLostCityLawnWarning.
  ///
  /// In en, this message translates to:
  /// **'Golden Road is a Lost City minigame module, so its unsodded areas feature the sun pattern specific to the Lost City lawn. Using it with other lawn appearances may affect the overall look of the level.'**
  String get goldRoadNonLostCityLawnWarning;

  /// No description provided for @goldRoadDeepseaLawnWarningTitle.
  ///
  /// In en, this message translates to:
  /// **'Lawn compatibility notice'**
  String get goldRoadDeepseaLawnWarningTitle;

  /// No description provided for @goldRoadDeepseaLawnWarning.
  ///
  /// In en, this message translates to:
  /// **'Golden Road only turns the first and fifth rows into unsodded areas. This also applies to six-row lawns with an Underwater World appearance, so keep this in mind when using the module.'**
  String get goldRoadDeepseaLawnWarning;

  /// No description provided for @moduleHelpOakTrainZombiesBody.
  ///
  /// In en, this message translates to:
  /// **'The zombies designed for this module are dedicated variants with abilities that differ from their regular tower-defense counterparts. They appear through the Wave Generator with Rise from Ground enabled. Their abilities do not work in regular Wave Manager events such as Basic Spawner and Underwater Spawner. Use Ground Spawner or custom zombies to achieve similar effects.\nThe Power Spheres that supply arrows are also zombies internally. Their abilities depend on both Oak Archery and Rise from Ground; spawning them outside these conditions may cause missing textures or effects.'**
  String get moduleHelpOakTrainZombiesBody;

  /// No description provided for @oakTrainHealthTitle.
  ///
  /// In en, this message translates to:
  /// **'Oak Archer health'**
  String get oakTrainHealthTitle;

  /// No description provided for @oakTrainScoresTitle.
  ///
  /// In en, this message translates to:
  /// **'Scoring'**
  String get oakTrainScoresTitle;

  /// No description provided for @oakTrainArrowsTitle.
  ///
  /// In en, this message translates to:
  /// **'Arrow supplies'**
  String get oakTrainArrowsTitle;

  /// No description provided for @oakTrainHelpArrowsTitle.
  ///
  /// In en, this message translates to:
  /// **'Arrow types'**
  String get oakTrainHelpArrowsTitle;

  /// No description provided for @oakTrainHelpScoresTitle.
  ///
  /// In en, this message translates to:
  /// **'Scoring rules'**
  String get oakTrainHelpScoresTitle;

  /// No description provided for @oakTrainHelpZombiesTitle.
  ///
  /// In en, this message translates to:
  /// **'Special zombies'**
  String get oakTrainHelpZombiesTitle;

  /// No description provided for @waveGeneratorColumnOption.
  ///
  /// In en, this message translates to:
  /// **'Column {number} ({index})'**
  String waveGeneratorColumnOption(int number, String index);

  /// No description provided for @waveGeneratorRowOption.
  ///
  /// In en, this message translates to:
  /// **'Row {number} ({index})'**
  String waveGeneratorRowOption(int number, String index);

  /// No description provided for @waveGeneratorDelaySummary.
  ///
  /// In en, this message translates to:
  /// **'This wave spawns after a {seconds}s delay'**
  String waveGeneratorDelaySummary(String seconds);

  /// No description provided for @waveGeneratorDelayInactiveSummary.
  ///
  /// In en, this message translates to:
  /// **'Spawn delay: {seconds}s (inactive without Rise from Ground)'**
  String waveGeneratorDelayInactiveSummary(String seconds);

  /// No description provided for @waveGeneratorPositionSummary.
  ///
  /// In en, this message translates to:
  /// **'Spawn position: {column}, {row}'**
  String waveGeneratorPositionSummary(String column, String row);

  /// No description provided for @waveGeneratorPositionUnset.
  ///
  /// In en, this message translates to:
  /// **'Not set'**
  String get waveGeneratorPositionUnset;

  /// No description provided for @oakTrainTutorialIntroWarningTitle.
  ///
  /// In en, this message translates to:
  /// **'Module compatibility warning'**
  String get oakTrainTutorialIntroWarningTitle;

  /// No description provided for @oakTrainTutorialIntroWarning.
  ///
  /// In en, this message translates to:
  /// **'Oak Archery Tutorial conflicts with the Intro Animation module. Using them together causes zombies to spawn before the tutorial ends.'**
  String get oakTrainTutorialIntroWarning;

  /// No description provided for @statueMazeMissingRotationsWarning.
  ///
  /// In en, this message translates to:
  /// **'Bemarbled rounds {rounds} have no rotation steps, which will crash the level. Add at least one rotation step to each round.'**
  String statueMazeMissingRotationsWarning(String rounds);

  /// No description provided for @moduleHelpStatueMazeCompatibilityTitle.
  ///
  /// In en, this message translates to:
  /// **'Compatibility'**
  String get moduleHelpStatueMazeCompatibilityTitle;

  /// No description provided for @moduleHelpStatueMazeCompatibilityBody.
  ///
  /// In en, this message translates to:
  /// **'Bemarbled can coexist with many modules. Normally, the level will not end until Bemarbled\'s win condition is also met. However, certain modules, such as Level Timer, may trigger an earlier ending. Keep this in mind when combining them.'**
  String get moduleHelpStatueMazeCompatibilityBody;

  /// No description provided for @autosaveZombossAction.
  ///
  /// In en, this message translates to:
  /// **'Save changes automatically when leaving custom Zomboss mech actions'**
  String get autosaveZombossAction;

  /// No description provided for @autosavePortal.
  ///
  /// In en, this message translates to:
  /// **'Save changes automatically when leaving custom portals'**
  String get autosavePortal;

  /// No description provided for @autosaveResilienceShield.
  ///
  /// In en, this message translates to:
  /// **'Save changes automatically when leaving custom resilience shields'**
  String get autosaveResilienceShield;

  /// No description provided for @autosavePreviewImage.
  ///
  /// In en, this message translates to:
  /// **'Save the image automatically when leaving the preview generator'**
  String get autosavePreviewImage;

  /// No description provided for @autosaveExit.
  ///
  /// In en, this message translates to:
  /// **'Exit'**
  String get autosaveExit;

  /// No description provided for @automaticallySaved.
  ///
  /// In en, this message translates to:
  /// **'Automatically saved'**
  String get automaticallySaved;

  /// No description provided for @automaticallySavedTo.
  ///
  /// In en, this message translates to:
  /// **'Automatically saved to: {path}'**
  String automaticallySavedTo(String path);
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'ru', 'zh'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'ru':
      return AppLocalizationsRu();
    case 'zh':
      return AppLocalizationsZh();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
