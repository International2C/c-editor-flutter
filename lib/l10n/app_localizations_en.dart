// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get error => 'Error';

  @override
  String get warning => 'Warning';

  @override
  String get info => 'Info';

  @override
  String get success => 'Success';

  @override
  String get previewTabPlants => 'Plants';

  @override
  String get previewTabZombies => 'Zombies';

  @override
  String get previewTabGridItems => 'Grid Items';

  @override
  String get overviewPresetPlants => 'Preset plants';

  @override
  String get overviewPresetZombies => 'Preset zombies';

  @override
  String get overviewConveyorPlants => 'Conveyor plants';

  @override
  String get overviewLawn => 'Lawn';

  @override
  String get overviewWhitelist => 'Whitelist';

  @override
  String get overviewBlacklist => 'Blacklist';

  @override
  String get overviewPlantBlacklist => 'Plant blacklist';

  @override
  String get overviewZombieWhitelist => 'Zombie whitelist';

  @override
  String get overviewSeedChooser => 'Choose your seeds';

  @override
  String get overviewReservedColumns => 'Reserved columns';

  @override
  String get sunBombFalling => 'Sun Bombs';

  @override
  String get sunDroppingActive => 'Sun falls from the sky';

  @override
  String get sunDroppingInactive => 'Sun doesn\'t fall from the sky';

  @override
  String get conveyorChanges => 'Changes in the conveyor';

  @override
  String get willBeAdded => 'will be added';

  @override
  String get willBeRemoved => 'will be removed';

  @override
  String get waveNumberLegend => 'Number indicates the wave number';

  @override
  String get expand => 'Expand';

  @override
  String get allZombiesInLevel => 'All zombies in the level';

  @override
  String get allObjectsInLevel => 'All grid items in the level';

  @override
  String get allEventsInLevel => 'All events in the level';

  @override
  String get overwhelmLabel => 'Column Like You See \'Em';

  @override
  String get fastEntryLabel => 'Fast Entry';

  @override
  String get zombieRushLabel => 'Level Timer';

  @override
  String get spermWhaleLabel => 'Whale Approaching';

  @override
  String get witchLabel => 'Fright Witch';

  @override
  String get lawnMowerTypeLabel => 'Lawn mower type';

  @override
  String get renaissanceStatues => 'Renaissance Statues and Mable Mounds';

  @override
  String get zomboss => 'Zomboss Mech';

  @override
  String get boss => 'Non-mech Zomboss';

  @override
  String get zombossData => 'Zomboss Data';

  @override
  String get contentsLabel => 'Contents:';

  @override
  String get vaseSpawnArea => 'Vase spawn area';

  @override
  String get guessWhoIAm => 'Guess Who I Am';

  @override
  String get plantBlackList => 'Plant blacklist';

  @override
  String get zombieWhiteList => 'Zombie whitelist';

  @override
  String get zombieWeight => 'Zombie weight';

  @override
  String get rainContent => 'Rain content';

  @override
  String get heianWind => 'Heian Divine Wind';

  @override
  String get all => 'All';

  @override
  String get impLv => 'Imp level';

  @override
  String get sortByLabel => 'Sort';

  @override
  String get sortByName => 'Sort: By Name';

  @override
  String get sortByCreationDate => 'Sort: By Creation Date';

  @override
  String get sortByModificationDate => 'Sort: By Modification Date';

  @override
  String get sortBySize => 'Sort: By File Size';

  @override
  String get sortByFileType => 'Sort: By File Type';

  @override
  String impsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Imps',
      one: '1 Imp',
    );
    return '$_temp0';
  }

  @override
  String get dropShip => 'Drop Ship';

  @override
  String get totalLabel => 'Total';

  @override
  String get totalPlantFoodTooltip =>
      'Total drops (including Plant Food, seed packet, etc.)';

  @override
  String get appTitle => 'My Workspace';

  @override
  String get about => 'About';

  @override
  String get refresh => 'Refresh';

  @override
  String get toggleTheme => 'Toggle theme';

  @override
  String get switchFolder => 'Switch folder';

  @override
  String get clearCache => 'Clear cache';

  @override
  String get autosave => 'Autosave';

  @override
  String get autosaveOn => 'Autosave: on';

  @override
  String get autosaveOff => 'Autosave: off';

  @override
  String get autosaveSubtitle =>
      'Save changes automatically when leaving a level';

  @override
  String get ultra => 'Ultra';

  @override
  String get uiSize => 'UI size';

  @override
  String get aboutSoftware => 'About';

  @override
  String get pluginsTitle => 'Plugins';

  @override
  String get pluginInstallNew => 'Install New Plugin';

  @override
  String get pluginInstallFromDevice => 'Install from device';

  @override
  String get pluginInstallFromUrl => 'Install from URL';

  @override
  String get pluginInstallFromFolder => 'Compile plugin folder (debug)';

  @override
  String get pluginUrlHint => 'https://example.com/my_plugin.cplugin';

  @override
  String get pluginDownload => 'Download';

  @override
  String get pluginInstalling => 'Installing plugin…';

  @override
  String pluginDownloadProgress(String received, String total) {
    return 'Downloading $received / $total';
  }

  @override
  String pluginDownloadProgressUnknown(String received) {
    return 'Downloading $received';
  }

  @override
  String pluginInstallSuccess(String name) {
    return 'Installed $name';
  }

  @override
  String pluginInstallFailed(String error) {
    return 'Install failed: $error';
  }

  @override
  String pluginInvalidFile(String reason) {
    return 'Not a valid plugin: $reason';
  }

  @override
  String get pluginInvalidUrl => 'Enter a valid http(s) URL';

  @override
  String get pluginReadFailed => 'Could not read the selected file';

  @override
  String get pluginTrustWarningTitle => 'Safety Notice';

  @override
  String get pluginTrustWarningBody =>
      'Plugins can run code within C-Editor to add more fun and useful features. By default, their access to files and the network is restricted by a sandbox, but malicious plugins may still cause harm. Please install plugins from trusted sources only.';

  @override
  String get pluginEmpty =>
      'No plugins installed yet. Install a .cplugin file from your device or a download link.';

  @override
  String get pluginNoScreens =>
      'This plugin has no features or screens you can jump to directly.';

  @override
  String get pluginUninstall => 'Uninstall';

  @override
  String get pluginUninstallTitle => 'Uninstall plugin';

  @override
  String pluginUninstallConfirm(String name) {
    return 'Remove $name from this device?';
  }

  @override
  String get pluginLoadError => 'Failed to load';

  @override
  String get pluginBundledBadge => 'Built-in';

  @override
  String get pluginImportedBadge => 'Imported';

  @override
  String get pluginsFolderReserved =>
      'The \".plugins\" and \".plugin_config\" folder names are reserved for editor plugins. Please choose a different name.';

  @override
  String get pluginNoLibraryForInstall =>
      'Select a workspace folder before installing plugins.';

  @override
  String pluginShowingCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count installed plugins',
      one: '1 installed plugin',
    );
    return '$_temp0';
  }

  @override
  String get pluginSearchHint => 'Search plugins';

  @override
  String get pluginSelectHint =>
      'Select a plugin to view details, settings, and features.';

  @override
  String get pluginEnabled => 'Enabled';

  @override
  String get pluginDisabled => 'Disabled';

  @override
  String get pluginAuthors => 'Authors';

  @override
  String get pluginContributors => 'Contributors';

  @override
  String pluginByAuthors(String authors) {
    return 'By $authors';
  }

  @override
  String get pluginLicense => 'License';

  @override
  String pluginVersionLabel(String version) {
    return 'v$version';
  }

  @override
  String get pluginIdLabel => 'ID';

  @override
  String get pluginLinkWebsite => 'Website';

  @override
  String get pluginLinkIssues => 'Issues';

  @override
  String get pluginLinkSource => 'Source';

  @override
  String get pluginLinkDiscord => 'Discord';

  @override
  String get pluginIncompatibleWith => 'Incompatible with';

  @override
  String get pluginOpenScreen => 'Open';

  @override
  String get pluginOpenSettings => 'Settings';

  @override
  String get pluginInstallAction => 'Install';

  @override
  String get pluginConfigurable => 'Configurable';

  @override
  String get pluginFeaturesSection => 'Features & screens';

  @override
  String get pluginNoDescription => 'No description provided.';

  @override
  String get pluginSettingsUnavailable => 'This plugin has no settings screen.';

  @override
  String get share => 'Share';

  @override
  String shareLevelFileText(String name) {
    return 'Level file: $name';
  }

  @override
  String get shareLevelFailed => 'Could not share level file';

  @override
  String get storagePermissionDialogTitle => 'Storage Permission Required';

  @override
  String get storagePermissionDialogMessage =>
      'This app requires external storage access to open and save level files. Please turn on \"Allow access to manage all files\" in Settings.';

  @override
  String get storagePermissionGoToSettings => 'Go to settings';

  @override
  String get storagePermissionDeny => 'Deny';

  @override
  String get initSetup => 'Initial setup';

  @override
  String get selectFolderPrompt =>
      'Please select a folder as the level storage directory.';

  @override
  String get selectFolderButton => 'Select folder';

  @override
  String get importFiles => 'Import files';

  @override
  String get importFolder => 'Import folder';

  @override
  String get importFolderEmpty => 'No level files found in the selected folder';

  @override
  String importFolderSuccess(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Imported $count files',
      one: 'Imported 1 file',
    );
    return '$_temp0';
  }

  @override
  String get importFilesUnreadable =>
      'Could not read the selected file(s). Try smaller files or a different browser.';

  @override
  String get importFolderUnsupported =>
      'Folder import is not supported in this browser.';

  @override
  String get smartUploadTitle => 'Duplicate file';

  @override
  String smartUploadFileMessage(String fileName) {
    return 'This file already exists in your workspace:\n\n$fileName\n\nWhat should be done?';
  }

  @override
  String get smartUploadSkip => 'Don\'t upload';

  @override
  String get smartUploadOverwrite => 'Overwrite';

  @override
  String get smartUploadAsCopy => 'Upload as copy';

  @override
  String get smartUploadSkipAll => 'Skip all';

  @override
  String get smartUploadOverwriteAll => 'Overwrite all';

  @override
  String get smartUploadCopyAll => 'Copy all';

  @override
  String get openFolder => 'Open folder';

  @override
  String get useDefaultLibraryFolder => 'Use default folder';

  @override
  String get emptyFolder => 'Folder is empty';

  @override
  String get newFolder => 'New folder';

  @override
  String get newLevel => 'New level';

  @override
  String get rename => 'Rename';

  @override
  String get delete => 'Delete';

  @override
  String get copy => 'Copy';

  @override
  String get download => 'Download';

  @override
  String get downloadAllLevels => 'Download all levels';

  @override
  String get downloadFolder => 'Download this directory';

  @override
  String get exportLevels => 'Level testing mod';

  @override
  String get exportSelectLevels => 'Select levels to test';

  @override
  String get exportSelectFile =>
      'Select a game data package for the testing mod (.rsb.smf)';

  @override
  String get backupRecommendationTitle => 'Backup Recommendation';

  @override
  String get backupRecommendationBody =>
      'It is recommended to back up your game data package before testing. This can help prevent data loss if the process is interrupted or an error occurs.';

  @override
  String get backupAndProceed => 'Backup and Proceed';

  @override
  String get proceedWithoutBackup => 'Proceed Without Backup';

  @override
  String get backupSuffix => '_copy';

  @override
  String get exportNoFilesFound =>
      'No compatible data packages found (.rsb.smf).';

  @override
  String get exportDownloadExternalDynamic => 'Download data package';

  @override
  String get cancelExportTitle => 'Cancel Build';

  @override
  String get cancelExportMessage =>
      'Are you sure you want to cancel building the level testing mod?';

  @override
  String get exportDisclaimerTitle => 'Risk Warning & Disclaimer';

  @override
  String get exportDisclaimerBody =>
      'This feature generates level testing mods by injecting level files into the game\'s data packages (SMF/RSB container files). This process directly modifies the game data of Plants vs. Zombies 2.\n\n• Using this feature to modify game data may violate the game\'s terms of service.\n• It may result in temporary or permanent suspension of your game account.\n• It may lead to game save corruption or data loss.\n• All operations are chosen by the user at their own risk.\n\nThe developes hereby explicitly state:\n\n1. This feature is for learning and research purposes only; any form of game cheating is discouraged.\n2. All consequences resulting from the use of this feature, including but not limited to account bans, data loss, and impaired game experience, are solely the responsibility of the user. The developers assume no direct or indirect liability.\n3. Users should fully understand the associated risks before using this feature and decide for themselves whether to assume these risks.\n4. Continued use indicates that you have read, understood, and agreed to all terms of this disclaimer.';

  @override
  String get exportDisclaimerDoNotShowAgain => 'Do not show by default';

  @override
  String get importProgressTitle => 'Importing files…';

  @override
  String get exportProgressTitle => 'Exporting files…';

  @override
  String get exportPackageProgressTitle => 'Exporting data package…';

  @override
  String get backupProgressTitle => 'Creating backup…';

  @override
  String get favorite => 'Favorite';

  @override
  String get move => 'Move';

  @override
  String get cancel => 'Cancel';

  @override
  String get confirm => 'Confirm';

  @override
  String get convert => 'Convert';

  @override
  String get convertHelpTooltip => 'Convert';

  @override
  String get create => 'Create';

  @override
  String get newName => 'New name';

  @override
  String get folderName => 'Folder name';

  @override
  String get confirmDelete => 'Confirm delete';

  @override
  String confirmDeleteMessage(String name, String detail) {
    return 'Are you sure you want to delete \"$name\"? $detail';
  }

  @override
  String get folderDeleteDetail =>
      'If it is a folder, its contents will also be deleted.';

  @override
  String get levelDeleteDetail => 'This action cannot be undone.';

  @override
  String get confirmDeleteCheckbox => 'I confirm permanent deletion';

  @override
  String get renameSuccess => 'Successfully renamed';

  @override
  String get renameFail => 'Rename failed, file already exists';

  @override
  String get uploadLevel => 'Upload to Creative Courtyard';

  @override
  String get uploadLevelConfirm =>
      'You are about to leave the editor and open the official Advanced Creative Courtyard Creator Hub website. After signing in with your email account, you can upload JSON level files from the workspace folder to the in-game Creative Courtyard for other players to enjoy. Do you want to continue?';

  @override
  String get back => 'Back';

  @override
  String get noLevelsFound => 'No levels found';

  @override
  String get searchLevel => 'Search levels...';

  @override
  String get proceed => 'Proceed';

  @override
  String get exportProceed => 'Proceed';

  @override
  String get exportBegin => 'Begin';

  @override
  String get exportStatusCreatingRton => 'Creating RTON levels...';

  @override
  String get exportStatusUnpackingRsb => 'Unpacking RSB...';

  @override
  String get exportStatusUnpackingRsg => 'Unpacking Packages.rsg...';

  @override
  String get exportStatusInjecting => 'Injecting levels...';

  @override
  String get exportStatusRepackingRsg => 'Repacking RSG...';

  @override
  String get exportStatusRepackingRsb => 'Repacking RSB...';

  @override
  String get exportStatusFinalizing => 'Finalizing...';

  @override
  String get exportAssignmentProposalTitle => 'Level Distribution';

  @override
  String get exportDifficultyReplacementNotice =>
      'If the Normal Mode and Hard/Expert Mode in the target level slot are actually different levels, the editor replaces only the Normal Mode level.';

  @override
  String get exportWorld => 'World';

  @override
  String get exportLevelNumber => 'Level Number';

  @override
  String exportLevelShort(int level) {
    return 'Lvl. $level';
  }

  @override
  String get exportFinish => 'Finish';

  @override
  String get exportSuccessTitle => 'Build Successful';

  @override
  String exportSuccessMessage(String file) {
    return 'The level testing mod has been successfully built at $file.\nReplace the corresponding game file with the generated data package, then enter your custom level from the original level slot that was replaced.\nNote: 1. Before replacing the file, fully close the game process.\n2. After the replacement and before entering the game, fully close the editor and any file manager currently accessing the target directory.';
  }

  @override
  String get exportCancelled => 'Build cancelled.';

  @override
  String exportDuplicateAssignment(String world, int level) {
    return 'Duplicate assignment: $world $level';
  }

  @override
  String get exportAssignmentIncomplete => 'Not all levels assigned';

  @override
  String get exportConfirmationTitle => 'Confirm assignments';

  @override
  String get exportConfirmationBody =>
      'Please verify your assignments before proceeding.';

  @override
  String get exportFinalCheckTitle => 'Final Check';

  @override
  String get exportFinalCheckBody =>
      'The following levels will be added to the data package under new names:';

  @override
  String exportTargetArchive(String file) {
    return 'The selected levels will be written to $file';
  }

  @override
  String get exportStart => 'Build Testing Mod';

  @override
  String get exportAssignmentProposalBody =>
      'The selected levels are validated. Now you should choose which adventure slot each level will occupy in the game.';

  @override
  String get copyReferenceOrDeep => 'Copy reference or make a deep copy?';

  @override
  String get copyReference => 'Copy reference';

  @override
  String get deepCopy => 'Deep copy';

  @override
  String get comingSoon => 'Coming soon';

  @override
  String get allLevelsCategory => 'All';

  @override
  String get favoritesCategory => 'Favorites';

  @override
  String get newFolderNameHint => 'Leave empty for default name';

  @override
  String get emptyFavorites => 'You don\'t have any favorite levels yet';

  @override
  String get copyEventTarget => 'Select target waves';

  @override
  String get targetWaveAlreadyContainsEvent => 'Already contains this event';

  @override
  String get targetWaveIndexHelper =>
      'When copying references, waves that already contain this event are automatically skipped.';

  @override
  String get moveToWaveIndex => 'Move to wave number';

  @override
  String get invalidWaveIndex => 'Invalid wave number';

  @override
  String get renamingFailed => 'Renaming failed';

  @override
  String get deleted => 'Deleted';

  @override
  String get copyLevel => 'Copy level';

  @override
  String get newFileName => 'New file name';

  @override
  String get copySuccess => 'Copied successfully';

  @override
  String get copyFail => 'Copy failed';

  @override
  String moving(String name) {
    return 'Moving: $name';
  }

  @override
  String get movePrompt => 'Navigate to target folder, then tap Paste';

  @override
  String get paste => 'Paste';

  @override
  String get movingSuccess => 'Moved successfully';

  @override
  String get movingFail => 'Move failed';

  @override
  String get moveSameFolder => 'Source and destination folders are the same';

  @override
  String get moveFileExistsTitle => 'File already exists';

  @override
  String get moveFileExistsMessage =>
      'A file with this name already exists in the destination folder.';

  @override
  String get moveOverwrite => 'Overwrite';

  @override
  String fileOverwritten(String name) {
    return 'File was overwritten: $name';
  }

  @override
  String get moveSaveAsCopy => 'Save as copy';

  @override
  String get moveCancelled => 'Operation cancelled';

  @override
  String movedAs(String name) {
    return 'Moved and saved as $name';
  }

  @override
  String get folderCreated => 'Folder created';

  @override
  String get createFail => 'Create failed';

  @override
  String get noTemplates => 'No templates found';

  @override
  String get newLevelTemplate => 'New level - Select template';

  @override
  String get nameLevel => 'Name level';

  @override
  String get levelCreated => 'Level created';

  @override
  String get levelCreateFail => 'Create failed, file already exists';

  @override
  String get templateLoadFail => 'Could not load the selected level template';

  @override
  String get adjustUiSize => 'Adjust UI size';

  @override
  String currentScale(String percent) {
    return 'Current scale: $percent%';
  }

  @override
  String get small => 'Small';

  @override
  String get standard => 'Standard';

  @override
  String get large => 'Large';

  @override
  String get done => 'Done';

  @override
  String get reset => 'Reset';

  @override
  String cacheCleared(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Cleared $count cached files',
      one: 'Cleared 1 cached file',
    );
    return '$_temp0';
  }

  @override
  String get returnUp => 'Back';

  @override
  String get convertToJson => 'Convert to JSON';

  @override
  String get convertToHotUpdateJson => 'Convert to hot update json';

  @override
  String get convertToEncryptedRton => 'Convert to encrypted rton';

  @override
  String get hujsonFormatDescription =>
      'Hot-update readable format. Before importing it into the game, please manually change the file extension from .hujson back to .json.';

  @override
  String get rtonFormatDescription =>
      'Used as level data inside the game\'s data package (dynamic.rsb.smf).';

  @override
  String get conversionRequiredTitle => 'Conversion required';

  @override
  String get conversionRequiredMessage =>
      'This file must be converted to JSON before it can be opened in the editor.';

  @override
  String get convertAction => 'Convert';

  @override
  String get conversionFailed => 'Conversion failed';

  @override
  String convertedMessage(String name) {
    return 'Converted: $name';
  }

  @override
  String get softwareIntro => 'Software intro';

  @override
  String get cEditor => 'C-Editor';

  @override
  String get pvzEditorSubtitle => 'PvZ2C Visual Level Editor';

  @override
  String get introSection => 'Introduction';

  @override
  String get introText =>
      'C-Editor is a visual level editing tool designed for Plants vs. Zombies 2 (Chinese Version). It aims to simplify editing level JSON files with an intuitive interface.';

  @override
  String get featuresSection => 'Core features';

  @override
  String get feature1 =>
      'Modular editing: Organize level modules and events in a modular interface for quick configuration.';

  @override
  String get feature2 =>
      'Multi-mode support: Edit I, Zombie, Vasebreaker, Last Stand, Zomboss Battle, and many other level modes.';

  @override
  String get feature3 =>
      'Custom injection: Inject and manage custom zombies, custom lawns, and custom Zomboss mechs within a level, including their core properties.';

  @override
  String get feature4 =>
      'Smart validation: Automatically detect missing module dependencies, broken references, and other issues to help prevent level crashes.';

  @override
  String get feature5 =>
      'Resource previews: Built-in icons for plants, zombies, and grid items provide a clearer, what-you-see-is-what-you-get editing experience.';

  @override
  String get usageSection => 'Usage';

  @override
  String get usageTextDesktop =>
      '1. Directory Setup: On first launch, click the folder icon in the upper-right corner and choose the folder that stores your level JSON files.\n2. Open/Create: Click a level in the list to edit it, or use the button below to create a new level from a template.\n3. Modules: In the editor, use \"Add New Module\" to extend the level with additional features.\n4. Save: When editing is complete, click the save button in the upper-right corner to write the changes back to the original JSON file automatically.\n5. Convert level files: JSON can be converted into hot-update-readable HUJSON (manually change the file extension from .hujson back to .json before importing) or encrypted RTON (used to replace level data in dynamic.rsb.smf).\n6. Plugins: Plugins can run additional code to provide new features and interfaces, enriching the editor experience. In addition to built-in plugins, new plugins can be obtained by installing a local .cplugin file or entering a URL. Features provided by plugins can be enabled or disabled independently.\n7. Click the \"Upload to Creative Courtyard\" button to open the official Plants vs. Zombies 2 Advanced Creative Courtyard Creator Hub. The button is only visible when the level list is at the top.\n8. You can view past officially recommended level IDs and the reasons they were selected on the \"Creative Courtyard · Recommended Levels Showcase\" webpage. Playing these levels not only supports talented level creators but also helps improve your own level design skills.\n9. If you have any questions or need help with advanced level creation, feel free to join the Plants vs. Zombies Discord server and ask in the PvZ2C-Modding channel thread.';

  @override
  String get usageTextMobile =>
      '1. Directory Setup: On first launch, tap the folder icon in the upper-right corner and choose the folder that stores your level JSON files.\n2. Open/Create: Tap a level in the list to edit it, or use the button below to create a new level from a template.\n3. Modules: In the editor, use \"Add New Module\" to extend the level with additional features.\n4. Save: When editing is complete, tap the save button in the upper-right corner to write the changes back to the original JSON file automatically.\n5. Convert level files: JSON can be converted into hot-update-readable HUJSON (manually change the file extension from .hujson back to .json before importing) or encrypted RTON (used to replace level data in dynamic.rsb.smf).\n6. Plugins: Plugins can run additional code to provide new features and interfaces, enriching the editor experience. In addition to built-in plugins, new plugins can be obtained by installing a local .cplugin file or entering a URL. Features provided by plugins can be enabled or disabled independently.\n7. Tap the \"Upload to Creative Courtyard\" button to open the official Plants vs. Zombies 2 Advanced Creative Courtyard Creator Hub. The button is only visible when the level list is at the top.\n8. You can view past officially recommended level IDs and the reasons they were selected on the \"Creative Courtyard · Recommended Levels Showcase\" webpage. Playing these levels not only supports talented level creators but also helps improve your own level design skills.\n9. If you have any questions or need help with advanced level creation, feel free to join the Plants vs. Zombies Discord server and ask in the PvZ2C-Modding channel thread.';

  @override
  String get usageRecommendedLevelsLabel =>
      'Creative Courtyard · Recommended Levels Showcase:';

  @override
  String get discordInviteLabel =>
      'Plants vs. Zombies Discord server invite link:';

  @override
  String get cEditorInviteLabel => 'C-Editor Discord server invite link:';

  @override
  String get creditsSection => 'Credits';

  @override
  String get authorLabel => 'Authors:';

  @override
  String get authorName => 'CyberSteve777, Devourdoom, Chara';

  @override
  String get thanksLabel => 'Special thanks:';

  @override
  String get thanksNames =>
      'Evilhack28, Rebus, KL12, vi_i_guess, Haruma, nineteendo';

  @override
  String get sourceLabel => 'GitHub Repository:';

  @override
  String get issuesLabel => 'Report Issues:';

  @override
  String get zEditorAcknowledgment =>
      'We would also like to express our sincere gratitude to the creators of Z-Editor. The development of this tool would not have been possible without the foundation they established.';

  @override
  String get zEditorCreditsSubsection => 'Z-Editor credits';

  @override
  String get zEditorAuthorLabel => 'Author:';

  @override
  String get zEditorAuthorName => '降维打击';

  @override
  String get zEditorThanksLabel => 'Special thanks:';

  @override
  String get zEditorThanksNames =>
      '星寻、metal海枣、超越自我3333、桃酱、凉沈、小小师、顾小言、PhiLia093、咖啡、不留名';

  @override
  String get zEditorQqGroupLabel => 'Z-Editor QQ group:';

  @override
  String get tagline => 'Create infinite possibilities';

  @override
  String editorVersion(String version) {
    return 'Editor version: $version';
  }

  @override
  String supportedGameVersion(String version) {
    return 'Supported game version: $version';
  }

  @override
  String get language => 'Language';

  @override
  String get languageEnglish => 'English';

  @override
  String get languageChinese => '中文';

  @override
  String get languageRussian => 'Русский';

  @override
  String get templateBlankLevel => 'Blank level';

  @override
  String get templateCardPickExample => 'Regular level template';

  @override
  String get templateConveyorExample => 'Conveyor-belt level template';

  @override
  String get templateLastStandExample => 'Last Stand level template';

  @override
  String get templateIZombieExample => 'I, Zombie level template';

  @override
  String get templateVaseBreakerExample => 'Vasebreaker level template';

  @override
  String get templateZombossMechExample => 'Zomboss Mech Battle level template';

  @override
  String get templateZombossBattleExample =>
      'Non-mech Zomboss Battle level template';

  @override
  String get templateCustomZombieExample => 'Custom zombie level template';

  @override
  String get templateIPlantExample => 'I, Plant level template';

  @override
  String get templateOldStyleExample => 'Wave Generator level template';

  @override
  String get templateCustomLawnExample => 'Custom lawn level template';

  @override
  String get unsavedChanges => 'Unsaved changes';

  @override
  String get saveBeforeLeaving => 'Save before leaving?';

  @override
  String get discard => 'Discard';

  @override
  String get stayInEditor => 'Stay';

  @override
  String get saved => 'Saved';

  @override
  String get failedToLoadLevel =>
      'Failed to load the level.\nWe recommend checking whether the level file is encrypted (for example, a JSON file used by hot updates).';

  @override
  String get noLevelDefinition => 'No level definition';

  @override
  String get noLevelDefinitionHint =>
      'Level definition module (LevelDefinition) was not found. This is the base node of the level file. Try adding it manually.';

  @override
  String get levelBasicInfo => 'Basic Information';

  @override
  String get levelBasicInfoSubtitle => 'Name, Index, Description, Lawn';

  @override
  String get removeModule => 'Remove module';

  @override
  String get zombieCategoryMain => 'By World';

  @override
  String get zombieCategorySize => 'By Size';

  @override
  String get zombieCategoryOther => 'Other';

  @override
  String get zombieCategoryCollection => 'My Collection';

  @override
  String get zombieTagAll => 'All Zombies';

  @override
  String get zombieTagEgyptPirate => 'Ancient Egypt / Pirate Seas';

  @override
  String get zombieTagWestFuture => 'Wild West / Far Future';

  @override
  String get zombieTagDarkBeach => 'Dark Ages / Big Wave Beach';

  @override
  String get zombieTagIceageLostcity => 'Frostbite Caves / Lost City';

  @override
  String get zombieTagKongfuSkycity => 'Kongfu World / Sky City';

  @override
  String get zombieTagEightiesDino => 'Neon Mixtape Tour / Jurassic Marsh';

  @override
  String get zombieTagModernPvz1 => 'Modern Day / PvZ1';

  @override
  String get zombieTagSteamRenai => 'Steam Ages / Renaissance Ages';

  @override
  String get zombieTagHeianAtlantis => 'Heian Ages / Underwater World';

  @override
  String get zombieTagMoon => 'Moon BaseZ';

  @override
  String get zombieTagTaleZCorp => 'Fairy Forest / Zombie Corporation';

  @override
  String get zombieTagParkourSpeed => 'Parkour Party / Speed Racing';

  @override
  String get zombieTagTothewest => 'Journey to the West / Underground Palace';

  @override
  String get zombieTagMemory => 'Memory Lane';

  @override
  String get zombieTagUniverse => 'Parallel Universe';

  @override
  String get zombieTagFestival1 => 'Festival 1';

  @override
  String get zombieTagFestival2 => 'Festival 2';

  @override
  String get zombieTagRoman => 'Roman Empire';

  @override
  String get zombieTagCustom => 'Memory Lane Variants';

  @override
  String get zombieTagExpedition => 'Expedition Gate Variants';

  @override
  String get zombieTagPvp => 'Two-Player Mode Variants';

  @override
  String get zombieTagPet => 'Pet';

  @override
  String get zombieTagImp => 'Imp';

  @override
  String get zombieTagBasic => 'Basic';

  @override
  String get zombieTagFat => 'Fat';

  @override
  String get zombieTagStrong => 'Bully';

  @override
  String get zombieTagGargantuar => 'Gargantuar';

  @override
  String get zombieTagElite => 'Elite';

  @override
  String get zombieTagEvildave => 'Compatible with IZ';

  @override
  String get plantCategoryQuality => 'By Quality';

  @override
  String get plantCategoryRole => 'By Role';

  @override
  String get plantCategoryAttribute => 'By Attribute';

  @override
  String get plantCategoryWorld => 'By World';

  @override
  String get plantCategoryOther => 'Other';

  @override
  String get plantCategoryCollection => 'My Favorites';

  @override
  String get plantTagAll => 'All Plants';

  @override
  String get plantTagWhite => 'White Quality';

  @override
  String get plantTagGreen => 'Green Quality';

  @override
  String get plantTagBlue => 'Blue Quality';

  @override
  String get plantTagPurple => 'Purple Quality';

  @override
  String get plantTagOrange => 'Orange Quality';

  @override
  String get plantTagRed => 'Red Quality';

  @override
  String get plantTagSupport => 'Support';

  @override
  String get plantTagRanger => 'Ranged';

  @override
  String get plantTagSunProducer => 'Sun';

  @override
  String get plantTagDefence => 'Tough';

  @override
  String get plantTagVanguard => 'Vanguard';

  @override
  String get plantTagTrapper => 'Special';

  @override
  String get plantTagFire => 'Fire';

  @override
  String get plantTagIce => 'Ice';

  @override
  String get plantTagMagic => 'Magic';

  @override
  String get plantTagPoison => 'Poison';

  @override
  String get plantTagElectric => 'Electric';

  @override
  String get plantTagPhysical => 'Physical';

  @override
  String get plantTagWorldTutorial => 'Tutorial';

  @override
  String get plantTagWorldEgypt => 'Ancient Egypt';

  @override
  String get plantTagWorldPirate => 'Pirate Seas';

  @override
  String get plantTagWorldWildWest => 'Wild West';

  @override
  String get plantTagWorldKongfu => 'Kongfu World';

  @override
  String get plantTagWorldFuture => 'Far Future';

  @override
  String get plantTagWorldDarkAges => 'Dark Ages';

  @override
  String get plantTagWorldBeach => 'Big Wave Beach';

  @override
  String get plantTagWorldIceage => 'Frostbite Caves';

  @override
  String get plantTagWorldSkycity => 'Sky City';

  @override
  String get plantTagWorldLostCity => 'Lost City';

  @override
  String get plantTagWorldEighties => 'Neon Mixtape Tour';

  @override
  String get plantTagWorldDino => 'Jurassic Marsh';

  @override
  String get plantTagWorldModern => 'Modern Day';

  @override
  String get plantTagWorldSteam => 'Steam Ages';

  @override
  String get plantTagWorldRenai => 'Renaissance Ages';

  @override
  String get plantTagWorldHeian => 'Heian Ages';

  @override
  String get plantTagWorldAtlantis => 'Underwater World';

  @override
  String get plantTagWorldMoon => 'Moon BaseZ';

  @override
  String get plantTagWorldFairytale => 'Fairy Forest';

  @override
  String get plantTagWorldZcorp => 'Zombie Corporation';

  @override
  String get plantTagWorldMausoleum => 'Underground Palace';

  @override
  String get plantTagOriginal => 'PvZ1 Plants';

  @override
  String get plantTagParallel => 'Parallel Universe';

  @override
  String get plantTagSpecial => 'Magic Hats';

  @override
  String get plantTagHidden => 'Hidden Plants';

  @override
  String get plantTagTier4 => 'Level 4 Village';

  @override
  String get plantTagInternational => 'International';

  @override
  String get plantTagChinese => 'China Only';

  @override
  String get removeModuleConfirm =>
      'Remove this module? Local custom modules (@CurrentLevel) and their data will be deleted permanently.';

  @override
  String get confirmRemove => 'Remove';

  @override
  String get settings => 'Settings';

  @override
  String get timeline => 'Wave Timeline';

  @override
  String get iZombie => 'I, Zombie';

  @override
  String get vaseBreaker => 'Vasebreaker';

  @override
  String get zombossMech => 'Zomboss Mech Battle';

  @override
  String get zombossBattle => 'Non-mech Zomboss Battle';

  @override
  String get rootFolder => 'Root';

  @override
  String get createEmptyWaveContainer => 'Create empty wave container';

  @override
  String get deleteEmptyContainer => 'Delete empty container';

  @override
  String get deleteWaveContainerTitle => 'Delete wave container';

  @override
  String get deleteWaveContainerConfirm =>
      'Are you sure you want to delete the empty wave container? You can create a new one later.';

  @override
  String get noWaveManager => 'Wave Container Not Found';

  @override
  String get noWaveManagerHint =>
      'Wave management is enabled, but the entity object (WaveManagerProperties) is missing. Please create an empty wave container.';

  @override
  String get waveTimelineGuideTitle => 'Operation Guide';

  @override
  String get waveTimelineGuideBodyDesktop =>
      'Left-click a wave: Manage wave events\nLong-press an event: Drag to reorder or move waves\nClick points: View spawn expectations';

  @override
  String get waveTimelineGuideBodyMobile =>
      'Tap a wave: Manage events\nLong-press an event: Drag to reorder or move waves\nTap points: View spawn expectations';

  @override
  String get waveDeadLinksTitle => 'Broken References';

  @override
  String get waveDeadLinksClear => 'Clear dead links';

  @override
  String get customZombieManagerTitle => 'Custom Zombie Management';

  @override
  String get customZombieEmpty => 'No custom zombie data';

  @override
  String get switchCustomZombie => 'Switch custom zombie';

  @override
  String get switchProperties => 'Switch properties';

  @override
  String get defaultPropertiesLabel => 'Default';

  @override
  String get addNewVariation => '+ Add new variation';

  @override
  String editCustomZombieAlias(String alias) {
    return 'Edit $alias';
  }

  @override
  String get switchZombie => 'Switch zombie';

  @override
  String get customZombieAppearanceLocation => 'Location:';

  @override
  String get customZombieNotUsed =>
      'This custom zombie is currently not used by any wave or module.';

  @override
  String customZombieWaveItem(int n) {
    return 'Wave $n';
  }

  @override
  String get customZombieDeleteConfirm =>
      'Remove this custom zombie entity and its property data.';

  @override
  String get customZombieOrphanDeleteTitle =>
      'Erase custom properties from level?';

  @override
  String customZombieOrphanDeleteMessage(String alias) {
    return '\"$alias\" will have no remaining uses in this level. Remove its zombie type and property objects from the level file? This cannot be undone.';
  }

  @override
  String get customZombieOrphanDeleteKeep => 'Keep in level';

  @override
  String get customZombieOrphanDeleteErase => 'Erase from level';

  @override
  String get customLabel => 'Custom';

  @override
  String get moduleTitle_WaveManagerProperties =>
      'Linked Wave Parameters (WaveManagerProps)';

  @override
  String waveManagerPropsCurrent(String value) {
    return 'Current: $value';
  }

  @override
  String get waveManagerGlobalParams => 'Wave Manager Parameters';

  @override
  String get waveContainerAliasSection => 'Wave container alias';

  @override
  String get waveContainerAliasHint =>
      'The alias used in the level file for the WaveManagerProperties object that stores wave data. It generally does not need to be changed manually.';

  @override
  String waveManagerGlobalSummary(
    int interval,
    int minPercent,
    int maxPercent,
  ) {
    return 'Flag interval: $interval, Next wave health threshold: $minPercent% - $maxPercent%';
  }

  @override
  String get waveEmptyTitle => 'No waves yet';

  @override
  String get waveEmptySubtitle =>
      'Add the first wave, or remove this empty container.';

  @override
  String get waveHeaderPreview => 'Content & Points Preview';

  @override
  String waveTotalLabel(int total) {
    return 'Total: $total';
  }

  @override
  String get waveEmptyRowHintDesktop =>
      'Empty wave (click to manage, drop events here)';

  @override
  String get waveEmptyRowHintMobile =>
      'Empty wave (tap to manage, drop events here)';

  @override
  String get removeFromWave => 'Remove from wave';

  @override
  String waveEventsTitle(int wave) {
    return 'Wave $wave events';
  }

  @override
  String get waveManagerSettings => 'Wave Manager Settings';

  @override
  String get flagInterval => 'Flag interval';

  @override
  String get waveManagerHelpTitle => 'Wave Manager module';

  @override
  String get waveManagerHelpOverviewTitle => 'Overview';

  @override
  String get waveManagerHelpOverviewBody =>
      'The wave event container organizes level events by wave order. Most levels use it to control zombie spawning. This page allows you to adjust its global settings.';

  @override
  String get waveManagerHelpFlagTitle => 'Flag interval';

  @override
  String get waveManagerHelpFlagBody =>
      'The flag interval determines how often a flag wave appears. The final wave is always a flag wave. Flag waves receive bonus points and have a separate spawn interval.';

  @override
  String get waveManagerHelpTimeTitle => 'Time control';

  @override
  String get waveManagerHelpTimeBody =>
      'The delay before the first wave depends on whether the level uses a conveyor belt: 5 seconds with a conveyor, or 12 seconds without. Flag wave delay refers to the time between the red warning message and zombie spawn.';

  @override
  String get waveManagerFirstWaveDelayConveyorOnlyHint =>
      'Currently, editing first wave delay only affects conveyor belt levels; regular levels use the default value.';

  @override
  String get waveManagerFirstWaveDelayConveyorOnlyHelp =>
      'Currently, editing first wave delay only affects conveyor belt evels; regular levels use the default value.';

  @override
  String get waveManagerHelpMusicTitle => 'Level Jam';

  @override
  String get waveManagerHelpMusicBody =>
      'This setting applies only to the Modern Day world. It sets a fixed global background track that enables abilities for certain Neon Mixtape Tour zombies.';

  @override
  String get waveManagerBasicParams => 'Basic parameters';

  @override
  String get waveManagerMaxHealthThreshold => 'Max next wave health threshold';

  @override
  String get waveManagerMinHealthThreshold => 'Min next wave health threshold';

  @override
  String get waveManagerThresholdHint =>
      'Threshold must be between 0 and 1. When the total remaining health of zombies in the current wave falls below this value, the next wave will spawn automatically.';

  @override
  String get waveManagerTimeControl => 'Time control';

  @override
  String get waveManagerFirstWaveDelayConveyor =>
      'First wave delay (conveyor; seconds)';

  @override
  String get waveManagerFirstWaveDelayNormal =>
      'First wave delay (normal; seconds)';

  @override
  String get waveManagerFlagWaveDelay => 'Flag wave delay (seconds)';

  @override
  String get waveManagerConveyorDetected =>
      'Conveyor module detected; conveyor delay applied.';

  @override
  String get waveManagerConveyorNotDetected =>
      'No conveyor module; normal delay applied.';

  @override
  String get waveManagerSpecial => 'Special';

  @override
  String get waveManagerSuppressFlagZombieTitle => 'Suppress flag zombie';

  @override
  String get waveManagerSuppressFlagZombieField => 'SuppressFlagZombie';

  @override
  String get waveManagerSuppressFlagZombieHint =>
      'When enabled, flag waves won’t spawn a flag zombie.';

  @override
  String get waveManagerLevelJam => 'Level Jam';

  @override
  String get waveManagerLevelJamHint =>
      'Only applies to Modern Day; provides fixed global background track.';

  @override
  String get jamNone => 'None';

  @override
  String get jamPop => 'Pop';

  @override
  String get jamRap => 'Rap';

  @override
  String get jamMetal => 'Metal';

  @override
  String get jamPunk => 'Punk';

  @override
  String get jam8Bit => '8-Bit';

  @override
  String get deleteWave => 'Delete wave';

  @override
  String deleteWaveConfirm(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'This will remove this wave and its $count events.',
      one: 'This will remove this wave and its 1 event.',
    );
    return '$_temp0';
  }

  @override
  String get deleteWaveConfirmCheckbox =>
      'I confirm permanent deletion of this wave';

  @override
  String get addEvent => 'Add event';

  @override
  String get reuseExistingEvent => 'Reuse event';

  @override
  String reuseExistingEventForWave(int wave) {
    return 'Reuse event for wave $wave';
  }

  @override
  String get reuseExistingEventEmpty => 'No events in this level yet';

  @override
  String get reuseExistingEventUnused => 'Not used in any wave';

  @override
  String reuseExistingEventUsedInWaves(String waves) {
    return 'Waves: $waves';
  }

  @override
  String get emptyWave => 'Empty wave';

  @override
  String get addWave => 'Add wave';

  @override
  String get expectation => 'Expectation';

  @override
  String get close => 'Close';

  @override
  String get levelOverview => 'Level Overview';

  @override
  String get levelOverviewOpenLevel => 'Open level';

  @override
  String get previewStartingPlantFood => 'Starting Plant Food';

  @override
  String get previewPrePlaced => 'Preset Layout';

  @override
  String get previewRegularPlants => 'Regular Plants';

  @override
  String get previewFrozenPlants => 'Frozen Plants';

  @override
  String get previewLevelContent => 'Level Content';

  @override
  String get previewSeedBank => 'Seed Bank';

  @override
  String get previewIZombieSeedBank => 'Seed Bank (I, Zombie)';

  @override
  String get previewFeatures => 'Level Features';

  @override
  String get previewActiveModules => 'Active Modules';

  @override
  String get previewInitial => 'Initial Grid Items';

  @override
  String get previewGenerateImagePreview => 'Generate preview image';

  @override
  String get editProperties => 'Edit properties';

  @override
  String get deleteEntity => 'Delete entity';

  @override
  String get deleteObjectTitle => 'Delete object?';

  @override
  String get deleteObjectConfirmMessage =>
      'Remove this object from the level file? This action cannot be undone.';

  @override
  String get objectDeleted => 'Object deleted';

  @override
  String get moduleEditorInProgress => 'Module editor in development';

  @override
  String get saveFail => 'Save failed';

  @override
  String get confirmRemoveRef => 'Remove reference';

  @override
  String get confirmRemoveRefMessage =>
      'Remove this reference? The entity data will remain until all references are removed.';

  @override
  String get code => 'Code';

  @override
  String get name => 'Level name';

  @override
  String get levelNumber => 'Level number';

  @override
  String get startingSun => 'Starting Sun';

  @override
  String get startingPlantfood => 'Starting Plant Food';

  @override
  String get stageModule => 'Lawn module';

  @override
  String get musicType => 'Music type';

  @override
  String get loot => 'Loot';

  @override
  String get victoryModule => 'Victory module';

  @override
  String get basicInfoSection => 'Basic info';

  @override
  String get sceneSettingsSection => 'Scene Settings';

  @override
  String get restrictionsSection => 'Restrictions';

  @override
  String get victoryModuleWarning =>
      'Using non-default victory modules may cause level crashes due to module conflicts. Use with caution.';

  @override
  String get beatTheLevelDialogHint =>
      'Supports Chinese; for multi-line text enter newlines directly, no need for \\n. Note: hints cannot be viewed in Creative Courtyard on iOS.';

  @override
  String get missingModules => 'Missing modules';

  @override
  String get conflictTitle_ModuleLogic => 'Module logic conflict';

  @override
  String conflictDefaultDescription(String module1, String module2) {
    return '$module1 and $module2 conflict logically. It is recommended to keep only one.';
  }

  @override
  String get conflictDesc_SeedBankConveyor =>
      'Seed Bank and Conveyor modules interfere with each other\'s UI and may cause crashes. Ensure Seed Bank is in Preset mode.';

  @override
  String get conflictDesc_VaseBreakerIntro =>
      'Vasebreaker mode does not need an opening intro.';

  @override
  String get conflictDesc_LastStandIntro =>
      'Last Stand mode does not need an opening intro.';

  @override
  String get conflictDesc_CowboyIntro =>
      'Not OK Corral conflicts with the Intro Animation module. Using them together will cause the zombie preview and transition effect at the start of the level to behave incorrectly.';

  @override
  String get conflictDesc_SingleHandedIntro =>
      'All by Oneself conflicts with the Intro Animation module. Using them together will cause the transition effect at the start of the level to behave incorrectly.';

  @override
  String get conflictDesc_SingleHandedTutorialIntro =>
      'The All by Oneself Tutorial conflicts with the Intro Animation module. Using them together will cause the transition effect at the start of the level to behave incorrectly.';

  @override
  String get conflictDesc_EvilDaveZombieDrop =>
      'I, Zombie mode cannot have Zombie Drop module.';

  @override
  String get conflictDesc_EvilDaveVictory =>
      'I, Zombie mode cannot have Zombie Victory Condition.';

  @override
  String get conflictDesc_ZombossDeathDrop =>
      'Loot Drop in Zomboss Mech Battle mode will prevent proper level completion.';

  @override
  String get conflictDesc_WinConditionExclusive =>
      'Loot Drop and Bronze Matrix Loot Drop do not need to be used together. It is recommended to remove one of them.';

  @override
  String get conflictDesc_ZombossTwoIntros =>
      'Two level opening intros cannot coexist, otherwise Zomboss health bar will not display correctly.';

  @override
  String get conflictDesc_InitialPlantEntryRoof =>
      'Pre-place plants on the roof will cause a crash.';

  @override
  String get conflictDesc_InitialPlantRoof =>
      'Legacy preset plants on the roof will cause a crash.';

  @override
  String get conflictDesc_ProtectPlantRoof =>
      'Endangered plants on the roof will cause a crash.';

  @override
  String get conflictDesc_LawnMowerYard =>
      'Lawn mowers are ineffective when the Creative Courtyard module is enabled.';

  @override
  String get conflictDesc_MoonExpertYard =>
      'The Moon Expert module has no effect when the Creative Courtyard module is enabled.';

  @override
  String get conflictDesc_WaveGeneratorWaveManagerModule =>
      'Wave Generator and Wave Manager module cannot coexist — they are two different wave systems.';

  @override
  String get conflictDesc_WaveGeneratorWaveManager =>
      'Wave Generator embeds waves directly and cannot be used with a separate Wave Manager container.';

  @override
  String conflictDesc_CamelMinigameNonTouchZombies(String zombies) {
    return 'Mummy Memory only supports the special Mummy Memory Camel Zombies. Other zombies were detected: $zombies. Their appearance in the level will crash the game. Replace or remove them.';
  }

  @override
  String get targetZombieRequiresOakTrain =>
      'Oak Archery’s exclusive zombies work best with their dedicated module. Add Oak Archery to the level.';

  @override
  String get conflictDesc_CamelMinigameIntro =>
      'Mummy Memory conflicts with the Standard Intro module. Using both causes abnormal transition effects at the start of the level.';

  @override
  String get targetZombieInWaveManagerWarningTitle =>
      'Zombie compatibility warning';

  @override
  String get targetZombieInWaveManagerWarning =>
      'Oak Archery’s exclusive zombies cannot use their abilities in regular Wave Manager events such as Basic Spawner and Underwater Spawner. Use Ground Spawner or custom zombies to achieve similar effects.';

  @override
  String get oakTrainUnderwaterWarningTitle => 'Lawn compatibility warning';

  @override
  String get oakTrainUnderwaterWarning =>
      'The base lawn is set to Underwater World or Moon BaseZ, so the Oak Archer provided by Oak Archery may not survive. Pre-place Oxygen Algae or Moss Tiles as needed.';

  @override
  String get waveGeneratorRiseFromGroundWarningTitle =>
      'Spawn behavior warning';

  @override
  String get waveGeneratorRiseFromGroundWarning =>
      'With Rise from Ground (IsRiseFromGroundMode) enabled, most spawned zombies cannot move or use their abilities. If only a row is specified without a spawn position, that row is ignored and the zombie always spawns in the first tile of the first row. Use random rows or set explicit spawn positions.';

  @override
  String get missingPlantModuleWarningTitle =>
      'Missing module for parallel universe plants';

  @override
  String get editableModules => 'Editable modules';

  @override
  String get parameterModules => 'Parameter modules';

  @override
  String get addNewModule => 'Add new module';

  @override
  String get selectStage => 'Select lawn';

  @override
  String get searchStage => 'Search by lawn name or codename';

  @override
  String get noStageFound => 'No lawn found';

  @override
  String get stageTypeAll => 'All';

  @override
  String get stageTypeMain => 'Main';

  @override
  String get stageTypeExtra => 'Extra';

  @override
  String get stageTypeSeasons => 'Seasons';

  @override
  String get stageTypeSpecial => 'Special';

  @override
  String get stageTypeCustomPresets => 'Custom Presets';

  @override
  String get search => 'Search';

  @override
  String get disablePeavine => 'Disable Pea Vine\'s Pea Symbiosis';

  @override
  String get disableArtifact =>
      'Disable Artifact (auto-applied when Creative Courtyard module is enabled)';

  @override
  String get selectPlant => 'Select plant';

  @override
  String get selectAll => 'Select ALL';

  @override
  String get searchPlant => 'Search plant';

  @override
  String get noPlantFound => 'No plant found';

  @override
  String noResultsFor(String query) {
    return 'No results for \"$query\"';
  }

  @override
  String get noModulesInCategory => 'No modules in this category';

  @override
  String get noEventsInCategory => 'No events in this category';

  @override
  String get eventCategoryZombieSpawn => 'Zombie spawn';

  @override
  String get eventCategoryGridItemSpawn => 'Grid item spawn';

  @override
  String get eventCategoryEnvironmental => 'Environmental';

  @override
  String get eventCategoryOther => 'Other';

  @override
  String addEventForWave(int wave) {
    return 'Add event for wave $wave';
  }

  @override
  String get waveLabel => 'Wave';

  @override
  String get pointsLabel => 'Points';

  @override
  String wavePointsShort(int points) {
    return '$points pts.';
  }

  @override
  String get noDynamicZombies => 'No dynamic zombies';

  @override
  String get moduleTitle_WaveManagerModuleProperties => 'Wave Manager';

  @override
  String get moduleDesc_WaveManagerModuleProperties =>
      'Manages overall wave event configuration for the level';

  @override
  String get moduleTitle_WaveGeneratorProperties => 'Wave Generator';

  @override
  String get moduleDesc_WaveGeneratorProperties =>
      'Legacy wave format used by Kongfu World and other early levels';

  @override
  String get moduleTitle_CustomLevelModuleProperties =>
      'Creative Courtyard Module';

  @override
  String get moduleDesc_CustomLevelModuleProperties =>
      'Enables Creative Courtyard features (likes, rewards, costume feature disabling, etc.)';

  @override
  String get powerTileModuleRequiredTitle => 'Power Tiles module required';

  @override
  String get powerTileModuleRequiredBody =>
      'Adding Power Tile tool packets requires the level to include the Power Tile module. Add the module and continue?';

  @override
  String get conveyorPlantWearCostume =>
      'Display costume (iAvatar; no longer works)';

  @override
  String get conveyorPlantWearCostumeTooltip =>
      'When enabled, this plant’s packet on the conveyor belt will display its costume. This feature does not work in the current version.';

  @override
  String get modifyConveyorAddPoolTitle => 'Add to Conveyor Pool';

  @override
  String get modifyConveyorAddPoolEmpty =>
      'The list is empty. Please add plants or tool packets.';

  @override
  String get modifyConveyorRemovePoolTitle =>
      'Remove from Conveyor Pool (doesn\'t work when Creative Courtyard module is enabled)';

  @override
  String get modifyConveyorEntryEditTitle => 'Edit parameters';

  @override
  String plantModuleRequiredMessage(String moduleName) {
    return 'In order to select this plant, $moduleName needs to be added.';
  }

  @override
  String zombieModuleRequiredMessage(String moduleName) {
    return 'In order to select this zombie, $moduleName needs to be added.';
  }

  @override
  String get realmExclusivePlantChooserBlockedTitle =>
      'Cannot select this plant';

  @override
  String get realmExclusivePlantChooserBlockedMessage =>
      'Realm-exclusive plants cannot be selected in Chooser Mode. To use them, please refer to other methods such as Preset Mode, Conveyor Belt, or Packet Drops.';

  @override
  String get hiddenPlantChooserBlockedTitle => 'Cannot select this plant';

  @override
  String get hiddenPlantChooserBlockedMessage =>
      'Hidden plants cannot be selected in Chooser Mode. Use Preset Mode, Conveyor Belt, Packet Drops, or other methods instead.\nExcept for certain plants such as Priest Puff-shroom and P-Mech Assembler - Flame Star, all other hidden plants appear as Sunflowers in the in-game seed bank; plants such as Mini Cactus Ball and Magic Beanstalk also have some abnormal interactions that may affect the level\'s overall presentation, so use them with caution.';

  @override
  String get comingSoonPlantBlockedLabel => 'To Be Continued';

  @override
  String get comingSoonPlantBlockedTitle => 'To Be Continued';

  @override
  String get comingSoonPlantBlockedMessage =>
      'The plants are still growing strong. Stay tuned for future updates!';

  @override
  String get stayTunedMoonZombieBlockedTitle => 'A Message from Space';

  @override
  String get stayTunedMoonZombieBlockedMessage =>
      'Moon BaseZ Part 2 is coming soon. Keep a lookout!';

  @override
  String get stayTunedTaleZCorpZombieBlockedTitle => 'Under Construction';

  @override
  String get stayTunedTaleZCorpZombieBlockedMessage =>
      'Part 2 of ZCorp Secret Realm is coming. Stay tuned!';

  @override
  String get stayTunedZombieBlockedTitle => 'To Be Continued';

  @override
  String get stayTunedZombieBlockedMessage =>
      'More zombies are approaching. keep an eye out on upcoming updates!';

  @override
  String missingModuleForPlantsWarning(String moduleName, String plantList) {
    return 'Missing module $moduleName for plants: $plantList';
  }

  @override
  String get moduleTitle_StandardLevelIntroProperties => 'Intro Animation';

  @override
  String get moduleDesc_StandardLevelIntroProperties =>
      'Camera pan at the start of the level';

  @override
  String get moduleTitle_ZombiesAteYourBrainsProperties => 'Loss Condition';

  @override
  String get moduleDesc_ZombiesAteYourBrainsProperties =>
      'Position where zombies entering the house triggers defeat';

  @override
  String get moduleTitle_ZombiesDeadWinConProperties => 'Loot Drop';

  @override
  String get moduleDesc_ZombiesDeadWinConProperties =>
      'Performs level settlement after zombies die';

  @override
  String get moduleTitle_BronzeDeadWinConProperties =>
      'Bronze Matrix Loot Drop';

  @override
  String get moduleDesc_BronzeDeadWinConProperties =>
      'Instantly eliminates all other zombies on the lawn once all bronze statues and gargantuar bronzes are defeated';

  @override
  String get moduleTitle_SpermWhaleModuleProperties => 'Whale Approaching';

  @override
  String get moduleDesc_SpermWhaleModuleProperties =>
      'Configures whale-related parameters for Underwater World levels, requires krill to be present on the lawn to take effect';

  @override
  String get spermWhaleModuleTitle => 'Whale Approaching Settings';

  @override
  String get spermWhaleModuleHelpTitle => 'Whale Approaching module';

  @override
  String get spermWhaleModuleParameters => 'Parameters';

  @override
  String get spermWhaleModuleHelpOverview => 'Overview';

  @override
  String get spermWhaleModuleHelpOverviewBody =>
      'This module is used to configure parameters related to the special marine creature \"Whale\", and is typically used in Underwater World levels. As krill begin appearing, the whale will circle above the lawn and trigger the corresponding red subtitle warning. Once at least 3 krill are present on the lawn, the whale will officially appear in the upper-left corner of the lawn. The whale will prioritize swallowing existing krill before continuously sucking up and swallowing plants on the lawn. The rotenone released by Puffy Derris can be inhaled by the whale; after the first inhalation, the whale’s swallowing speed will decrease. Once the number of inhalations reaches the configured rotenone trigger count, the whale will be forced to retreat. Note that the whale can only appear once per level.';

  @override
  String get spermWhaleModuleHelpFieldsTitle => 'Parameter Overview';

  @override
  String get spermWhaleModuleHelpFieldsBody =>
      'Swallow Interval (SwallowInterval) refers to the interval between the whale’s swallowing actions under normal conditions.\nPoisoned Swallow Interval (PoisonSwallowInterval) refers to the interval between swallowing actions after the whale inhales rotenone once.\nSwallow Duration (SwallowDuration) refers to the total amount of time the whale remains on the lawn sucking up and swallowing plants.\nPoison Trigger Count (PoisonTriggerCount) refers to the number of rotenone inhalations required to force the whale to retreat.';

  @override
  String get spermWhaleModuleSwallowInterval =>
      'Swallow Interval (SwallowInterval, seconds)';

  @override
  String get spermWhaleModuleHelpSwallowInterval =>
      'The interval between two swallowing actions under normal conditions.';

  @override
  String get spermWhaleModulePoisonSwallowInterval =>
      'Rotenone Swallow Interval (PoisonSwallowInterval, seconds)';

  @override
  String get spermWhaleModuleHelpPoisonSwallowInterval =>
      'The interval between two swallowing actions after the whale inhales rotenone.';

  @override
  String get spermWhaleModuleSwallowDuration =>
      'Swallow Duration (SwallowDuration, seconds)';

  @override
  String get spermWhaleModuleHelpSwallowDuration =>
      'The total duration the whale remains on the lawn sucking up and swallowing plants.';

  @override
  String get spermWhaleModulePoisonTriggerCount =>
      'Rotenone trigger count (PoisonTriggerCount)';

  @override
  String get spermWhaleModuleHelpPoisonTriggerCount =>
      'The cumulative number of rotenone inhalations required to force the whale to retreat.';

  @override
  String get spermWhaleModuleNotDeepSeaWarning =>
      'This module is recommended for Underwater World lawns. Using it on lawns other than 20,000 Leagues Under the Sea/Atlantis may cause compatibility issues.';

  @override
  String get moduleTitle_PennyClassroomModuleProperties => 'Tier Definition';

  @override
  String get moduleDesc_PennyClassroomModuleProperties =>
      'Globally defines plant tiers, overrides other modules';

  @override
  String get moduleTitle_SeedBankProperties => 'Seed Bank';

  @override
  String get moduleDesc_SeedBankProperties =>
      'Presets seed slots and seed selection mode';

  @override
  String get moduleTitle_ConveyorSeedBankProperties => 'Conveyor Belt';

  @override
  String get moduleDesc_ConveyorSeedBankProperties =>
      'Presets conveyor belt plant types and weights';

  @override
  String get moduleTitle_SunDropperProperties => 'Sun Dropper';

  @override
  String get moduleDesc_SunDropperProperties =>
      'Controls falling sun frequency';

  @override
  String get moduleTitle_LevelMutatorMaxSunProps => 'Max Sun Limit';

  @override
  String get moduleDesc_LevelMutatorMaxSunProps =>
      'Overrides the maximum sun limit value';

  @override
  String get moduleTitle_MoonExpertProperties => 'Moon Expert';

  @override
  String get moduleDesc_MoonExpertProperties =>
      'Sets fixed plant and zombie levels (doesn\'t work in Creative Courtyard)';

  @override
  String get moduleTitle_LevelMutatorStartingPlantfoodProps =>
      'Starting Plant Food';

  @override
  String get moduleDesc_LevelMutatorStartingPlantfoodProps =>
      'Overrides starting Plant Food amount';

  @override
  String get moduleTitle_StarChallengeModuleProperties => 'Challenge Module';

  @override
  String get moduleDesc_StarChallengeModuleProperties =>
      'Sets level restrictions and objectives';

  @override
  String get starChallengeNoConfigTitle => 'Challenge';

  @override
  String get starChallengeNoConfigMessage =>
      'This challenge has no configurable parameters.';

  @override
  String get starChallengeSaveMowersTitle => 'Don\'t lose any lawn mowers';

  @override
  String get starChallengeSaveMowersNoConfigMessage =>
      'This challenge has no configurable parameters.\n\nTo complete it, all lawn mowers must remain intact. Note that lawn mowers are not available by default when the Creative Courtyard module is enabled.';

  @override
  String get starChallengePlantFoodNonuseTitle => 'Don\'t use Plant Food';

  @override
  String get starChallengePlantFoodNonuseNoConfigMessage =>
      'This challenge has no configurable parameters.\n\nPlant Food cannot be used.';

  @override
  String get moduleTitle_LevelScoringModuleProperties => 'Scoring Module';

  @override
  String get moduleDesc_LevelScoringModuleProperties =>
      'Enables scoring system based on zombie kills';

  @override
  String get moduleTitle_SouDaCheDamageTextModuleProperties =>
      'Damage Number Display';

  @override
  String get moduleDesc_SouDaCheDamageTextModuleProperties =>
      'Shows the damage value dealt by each plant attack during the level';

  @override
  String get moduleTitle_BowlingMinigameProperties => 'Bulb Bowling';

  @override
  String get moduleDesc_BowlingMinigameProperties =>
      'Sets no-planting line and disable shovel';

  @override
  String get moduleTitle_NewBowlingMinigameProperties => 'Wall-nut Bowling';

  @override
  String get moduleDesc_NewBowlingMinigameProperties =>
      'Draws bowling warning line at a fixed position';

  @override
  String get moduleTitle_VaseBreakerPresetProperties => 'Vase Layout';

  @override
  String get moduleDesc_VaseBreakerPresetProperties =>
      'Configures vase contents (requires 2 additional modules to function)';

  @override
  String get moduleTitle_VaseBreakerArcadeModuleProperties =>
      'Vasebreaker Mode';

  @override
  String get moduleDesc_VaseBreakerArcadeModuleProperties =>
      'Enable environment and UI for Vasebreaker';

  @override
  String get moduleTitle_VaseBreakerFlowModuleProperties => 'Vase Animation';

  @override
  String get moduleDesc_VaseBreakerFlowModuleProperties =>
      'Controls the falling animation of vases at start';

  @override
  String get moduleTitle_EvilDaveProperties => 'I, Zombie Mode';

  @override
  String get moduleDesc_EvilDaveProperties =>
      'Enable I, Zombie mode (requires zombie bank and preset plants)';

  @override
  String get moduleTitle_ZombossBattleModuleProperties => 'Zomboss Mech Battle';

  @override
  String get moduleDesc_ZombossBattleModuleProperties =>
      'Configures Zomboss Mech types and parameters';

  @override
  String get moduleTitle_ZombossBattleIntroProperties => 'Zomboss Mech Intro';

  @override
  String get moduleDesc_ZombossBattleIntroProperties =>
      'Controls Zomboss Mech Battle cutscenes and health bar display';

  @override
  String get moduleTitle_ZombossLastStandMinigameProperties =>
      'Non-mech Zomboss Battle';

  @override
  String get moduleDesc_ZombossLastStandMinigameProperties =>
      'Configures non-mech Zomboss Battles such as Qigong Master';

  @override
  String get moduleTitle_SeedRainProperties => 'It\'s Raining Seeds';

  @override
  String get moduleDesc_SeedRainProperties =>
      'Controls plants, zombies or Plant Food falling from the sky';

  @override
  String get moduleTitle_LastStandMinigameProperties => 'Last Stand';

  @override
  String get moduleDesc_LastStandMinigameProperties =>
      'Sets initial resources and enables setup phase';

  @override
  String get moduleTitle_CowboyMinigameProperties => 'Not OK Corral';

  @override
  String get moduleDesc_CowboyMinigameProperties =>
      'Starts each zombie wave only after a plant from the conveyor belt is planted';

  @override
  String get moduleTitle_SingleHandedProperties => 'All by Oneself';

  @override
  String get moduleDesc_SingleHandedProperties =>
      'Configures the basic properties of the All by Oneself minigame';

  @override
  String get moduleTitle_IntroSingleHandedProperties =>
      'All by Oneself Tutorial';

  @override
  String get moduleDesc_IntroSingleHandedProperties =>
      'Configures tutorial prompts for the All by Oneself minigame';

  @override
  String get moduleTitle_PVZ1OverwhelmModuleProperties =>
      'Column Like You See \'Em';

  @override
  String get moduleDesc_PVZ1OverwhelmModuleProperties =>
      'Planting a seed packet fills its column (best used with conveyor belt)';

  @override
  String get moduleTitle_SunBombChallengeProperties => 'Sun Bombs';

  @override
  String get moduleDesc_SunBombChallengeProperties =>
      'Configures explosion range and damage of falling sun';

  @override
  String get moduleTitle_IncreasedCostModuleProperties => 'Inflation';

  @override
  String get moduleDesc_IncreasedCostModuleProperties =>
      'Sun cost increases each time the same plant is planted';

  @override
  String get moduleTitle_DeathHoleModuleProperties => 'Death Craters';

  @override
  String get moduleDesc_DeathHoleModuleProperties =>
      'Plants leave craters when destroyed';

  @override
  String get moduleTitle_ZombieMoveFastModuleProperties => 'Fast Entry';

  @override
  String get moduleDesc_ZombieMoveFastModuleProperties =>
      'Zombies move faster on entry';

  @override
  String get moduleTitle_InitialPlantProperties => 'Legacy Preset Plants';

  @override
  String get moduleDesc_InitialPlantProperties =>
      'The legacy method for preset plants, supports placing frozen plants';

  @override
  String get moduleTitle_InitialPlantEntryProperties => 'Preset Plants';

  @override
  String get moduleDesc_InitialPlantEntryProperties =>
      'Plants existing on the lawn at the start';

  @override
  String get frozenPlantPlacementLastStand => 'Intensive Battle mode';

  @override
  String get frozenPlantPlacementSelectedPosition => 'Selected position';

  @override
  String get frozenPlantPlacementPlantList => 'Plant(s) in selected tile';

  @override
  String frozenPlantPlacementEditPlant(String name) {
    return 'Edit $name';
  }

  @override
  String get frozenPlantPlacementLevel => 'Level';

  @override
  String get frozenPlantPlacementCondition => 'Condition';

  @override
  String get frozenPlantPlacementConditionNull => 'None (null)';

  @override
  String get noConditions => 'No conditions';

  @override
  String get frozenPlantPlacementHelpTitle => 'Legacy Preset Plants module';

  @override
  String get frozenPlantPlacementHelpOverviewTitle => 'Overview';

  @override
  String get frozenPlantPlacementHelpOverviewBody =>
      'This module configures plant layout before the level starts. Similar to preset plant layout but with a different structure and special state support.';

  @override
  String get frozenPlantPlacementHelpConditionTitle => 'Special State';

  @override
  String get frozenPlantPlacementHelpConditionBody =>
      'Plants can be set to frozen state (icecubed), commonly used in Frostbite Caves levels.';

  @override
  String get frozenPlantPlacementHelpLastStandTitle => 'Intensive Battle Mode';

  @override
  String get frozenPlantPlacementHelpLastStandBody =>
      'When Intensive Battle mode is enabled, initial plants will be incinerated after the game starts. Note that Chinese version does not have the burn animation.';

  @override
  String get save => 'Save';

  @override
  String get moduleTitle_InitialZombieProperties => 'Preset Zombies';

  @override
  String get moduleDesc_InitialZombieProperties =>
      'Zombies existing on the lawn at the start';

  @override
  String get moduleTitle_InitialGridItemProperties => 'Preset Grid Items';

  @override
  String get moduleDesc_InitialGridItemProperties =>
      'Grid items existing on the lawn at the start';

  @override
  String get moduleTitle_ProtectThePlantChallengeProperties => 'Save Our Seeds';

  @override
  String get moduleDesc_ProtectThePlantChallengeProperties =>
      'Sets specific plants that must be protected';

  @override
  String get moduleTitle_ProtectTheGridItemChallengeProperties =>
      'Save Our Items';

  @override
  String get moduleDesc_ProtectTheGridItemChallengeProperties =>
      'Sets grid items that must be protected from destruction';

  @override
  String get moduleTitle_MoldColonyChallengeProps => 'Mold Zone';

  @override
  String get moduleDesc_MoldColonyChallengeProps =>
      'Sets the lawn tiles covered by mold colonies';

  @override
  String get moldColonyLocationsTitle => 'Mold colonies layout (Locations)';

  @override
  String moldColonyLocationsValue(String value) {
    return 'Current value: $value';
  }

  @override
  String get moldColonyLevelModulesError =>
      'Error: the mold colonies layout reference uses LevelModules. Switch it to a current-level object.';

  @override
  String get moldColonyInvalidLinkError =>
      'Error: Locations must reference a BoardGridMapProps object in the current level for the mold colonies layout.';

  @override
  String moldColonyRepairLink(String alias) {
    return 'Repair link to: $alias';
  }

  @override
  String get moldColonies => 'Mold colonies';

  @override
  String get moldColonyEmpty => 'Empty';

  @override
  String get moldColonyHelpOverview =>
      'Configures the lawn tiles covered by mold colonies. Mold colonies prevent the player from planting on the corresponding tiles.';

  @override
  String get moldColonyHelpGridTitle => 'Grid controls';

  @override
  String get moldColonyHelpGridBody =>
      'Tap a tile to switch between empty (plantable) and mold colonies (not plantable). The selected row and column are shown above the grid.';

  @override
  String get moduleTitle_ZombiePotionModuleProperties => 'Dark Alchemy';

  @override
  String get moduleDesc_ZombiePotionModuleProperties =>
      'Dark Ages potion generation mechanics';

  @override
  String get moduleTitle_PiratePlankProperties => 'Pirate Planks';

  @override
  String get moduleDesc_PiratePlankProperties =>
      'Configures plank rows for Pirate Seas lawn';

  @override
  String get moduleTitle_RailcartProperties => 'Minecart and Rail';

  @override
  String get moduleDesc_RailcartProperties =>
      'Configures the initial layout of minecarts and rails';

  @override
  String get moduleTitle_MechanismPlankProperties => 'Connected Minecart';

  @override
  String get moduleDesc_MechanismPlankProperties =>
      'Configures the initial layout of Kongfu World minecarts and rails';

  @override
  String get moduleTitle_PowerTileProperties => 'Power Tiles';

  @override
  String get moduleDesc_PowerTileProperties =>
      'Configures Plant Food link effects and tile layout';

  @override
  String get moduleTitle_ManholePipelineModuleProperties => 'Manhole Pipeline';

  @override
  String get moduleDesc_ManholePipelineModuleProperties =>
      'Configures Steam Ages transportation sewers';

  @override
  String get moduleTitle_SmokePollutionModuleProperties => 'Steam Manhole';

  @override
  String get moduleDesc_SmokePollutionModuleProperties =>
      'Configures Steam Ages steam sewers';

  @override
  String get moduleTitle_RoofProperties => 'Roof Pots';

  @override
  String get moduleDesc_RoofProperties =>
      'Configures preset Flower Pots for Roof levels';

  @override
  String get moduleTitle_TideProperties => 'Tide System';

  @override
  String get moduleDesc_TideProperties =>
      'Enable tide system (should be added last)';

  @override
  String get moduleTitle_BombProperties => 'Powder Keg';

  @override
  String get moduleDesc_BombProperties =>
      'Configures the fuse length and burn rate of Kongfu World powder kegs';

  @override
  String get moduleTitle_BronzeProperties => 'Bronze Matrix Statues';

  @override
  String get moduleDesc_BronzeProperties =>
      'Configures Kongfu World bronze statues';

  @override
  String get moduleTitle_ArmrackProperties => 'Weapon Stands';

  @override
  String get moduleDesc_ArmrackProperties =>
      'Configures the spawning of Kongfu World weapon stands';

  @override
  String get moduleTitle_EnergyGridProperties => 'Taiji Tiles';

  @override
  String get moduleDesc_EnergyGridProperties =>
      'Configures the spawning of Kongfu World Taiji tiles';

  @override
  String get bronzeModuleHelpTitle => 'Bronze Matrix Statues module';

  @override
  String get bronzeModuleHelpOverview => 'Overview';

  @override
  String get bronzeModuleHelpOverviewBody =>
      'This module is used to place bronze statue grid items on the lawn that exist at the start of the level, commonly used in the Kongfu World brain buster \"Bronze Matrix\". Bronze statues gradually lose their copper coating over time and will revive as gargantuar bronzes when the specified countdown ends. The HP of a bronze statue is the same as the corresponding Level 1 Gargantuar Bronze.\nShake offset (shakeOffset) indicates the center offset of the revive animation’s shaking; adjusting this value has no practical effect.\nNote: This module itself does not include the effect of instantly eliminating remaining zombies after all bronze statues and gargantuar bronzes on the lawn are destroyed. To achieve that effect, the Bronze Matrix Loot Drop module must be added.';

  @override
  String get bronzeModuleHelpBatches => 'Revival Logic';

  @override
  String get bronzeModuleHelpBatchesBody =>
      'Each bronze statue added generates a corresponding entry in the level file. Revival timing is determined by the spawn time (spawnTime), in seconds, and is independent of waves. Bronze statues with the same spawn time will revive simultaneously.\nThe revival countdown for subsequent batches is offset from the first batch. For example, if the first batch is set to 30s, the second to 45s, and the third to 50s, then the second batch will revive 15s after the first, and the third batch 5s after the second.';

  @override
  String get bronzeModuleShakeOffset => 'Animation';

  @override
  String get bronzeModuleShakeOffsetLabel => 'Shake offset';

  @override
  String get bronzeModuleInCell => 'Bronze statue(s) in selected tile';

  @override
  String get bronzeModuleAddTitle => 'Add bronze statue';

  @override
  String get bronzeModuleSpawnTimeLabel => 'Revival time (seconds)';

  @override
  String get moduleTitle_WarMistProperties => 'Fog System';

  @override
  String get moduleDesc_WarMistProperties =>
      'Configures Dark Ages fog coverage and interaction';

  @override
  String get moduleTitle_RainDarkProperties => 'Weather';

  @override
  String get moduleDesc_RainDarkProperties =>
      'Sets rain, snow, and lightning effects';

  @override
  String get eventTitle_SpawnZombiesFromGroundSpawnerProps => 'Ground Spawner';

  @override
  String get eventDesc_SpawnZombiesFromGroundSpawnerProps =>
      'Spawns zombies from underground';

  @override
  String get eventTitle_SpawnZombiesJitteredWaveActionProps => 'Basic Spawner';

  @override
  String get eventDesc_SpawnZombiesJitteredWaveActionProps =>
      'Standard natural zombie spawning event';

  @override
  String get eventTitle_FrostWindWaveActionProps => 'Freezing Wind';

  @override
  String get eventDesc_FrostWindWaveActionProps =>
      'Blows freezing wind on specific rows';

  @override
  String get eventTitle_BeachStageEventZombieSpawnerProps => 'Low Tide';

  @override
  String get eventDesc_BeachStageEventZombieSpawnerProps =>
      'Zombies emerge during low tide';

  @override
  String get eventTitle_TidalChangeWaveActionProps => 'Tide Change';

  @override
  String get eventDesc_TidalChangeWaveActionProps =>
      'Changes the tide position';

  @override
  String get eventTitle_TideWaveWaveActionProps => 'Ocean Current';

  @override
  String get eventDesc_TideWaveWaveActionProps =>
      'Moves submarine and affects zombie movement speed';

  @override
  String get eventTitle_SpawnZombiesFishWaveActionProps => 'Underwater Spawner';

  @override
  String get eventDesc_SpawnZombiesFishWaveActionProps =>
      'Spawns zombies or sea creatures from the left or right side of the lawn; can only be used in Underwater World';

  @override
  String get eventTitle_ModifyConveyorWaveActionProps => 'Conveyor Change';

  @override
  String get eventDesc_ModifyConveyorWaveActionProps =>
      'Dynamically adds or removes conveyor plants';

  @override
  String get eventTitle_DinoWaveActionProps => 'Dino Summon';

  @override
  String get eventDesc_DinoWaveActionProps =>
      'Summons a dinosaur to assist zombies';

  @override
  String get eventTitle_DinoTreadActionProps => 'Dino Stomp';

  @override
  String get eventDesc_DinoTreadActionProps =>
      'Brachiosaurus stomps within a set area, dealing damage';

  @override
  String get eventTitle_DinoRunActionProps => 'Dino Stampede';

  @override
  String get eventDesc_DinoRunActionProps =>
      'Dinosaurs charge down their lane, trampling plants and zombies';

  @override
  String get eventTitle_SpawnModernPortalsWaveActionProps => 'Spacetime Portal';

  @override
  String get eventDesc_SpawnModernPortalsWaveActionProps =>
      'Summons spacetime portals at set locations';

  @override
  String get eventTitle_StormZombieSpawnerProps => 'Storm Raid';

  @override
  String get eventDesc_StormZombieSpawnerProps =>
      'Sandstorms or snowstorms bring in zombies';

  @override
  String get eventTitle_RaidingPartyZombieSpawnerProps => 'Raiding Party';

  @override
  String get eventDesc_RaidingPartyZombieSpawnerProps =>
      'Summons multiple Swashbuckler Zombies';

  @override
  String get eventTitle_ZombiePotionActionProps => 'Potion Drop';

  @override
  String get eventDesc_ZombiePotionActionProps =>
      'Force spawns grid items at set positions';

  @override
  String get eventTitle_ZombieAtlantisShellActionProps => 'Seashell Spawn';

  @override
  String get eventDesc_ZombieAtlantisShellActionProps =>
      'Spawns atlantis seashells at set positions';

  @override
  String get eventTitle_SpawnEagleFlagsWaveActionProps =>
      'Eagle Standard Spawn';

  @override
  String get eventDesc_SpawnEagleFlagsWaveActionProps =>
      'Spawn Eagle Standards at specified positions';

  @override
  String get eventHelpEagleStandardBody =>
      'This event spawns Eagle Standards at specified positions. Zombies that pass by can pick up the Eagle Standard. When the carrier is defeated, the standard drops to the ground, allowing subsequent zombies to pick it up again repeatedly. A zombie carrying the Eagle Standard grants zombies within a 3×3 area damage reduction and immunity to control effects.\nRegular plants cannot attack the Eagle Standard. Once it has been dropped, Magnet-shroom and Gold Magnet can destroy it.';

  @override
  String get eventHelpEagleStandardEligibleZombiesTitle => 'Eligible zombies';

  @override
  String get eventHelpEagleStandardEligibleZombiesBody =>
      'In the current version, only Roman Zombies, Roman Coneheads, Roman Bucketheads, Centurion Zombies, Bust Head Zombies, Roman Flag Zombies, and Roman Imps can pick up the Eagle Standard. Other zombies ignore the Standard and continue past it, but can still benefit from the bonuses granted by its carrier.';

  @override
  String get eventHelpEagleStandardUsage =>
      'Select a grid cell and tap \"+\" to add an Eagle Standard. Multiple standards can be placed on the same tile and removed using the cards below. The grid adapts to the current lawn, and standards outside the lawn are listed separately.';

  @override
  String get eventTitle_PumpkinHouseActionProps => 'Pumpkin House Spawn';

  @override
  String get eventDesc_PumpkinHouseActionProps =>
      'Spawns pumpkin houses on the lawn at set positions';

  @override
  String get eventTitle_WaveActionZombieTentProps => 'Zombie Tent Spawn';

  @override
  String get eventDesc_WaveActionZombieTentProps =>
      'Spawn zombie tents at specified positions and configure the zombies they summon';

  @override
  String get eventTitle_SpawnGravestonesWaveActionProps => 'Grid Item Spawn';

  @override
  String get eventDesc_SpawnGravestonesWaveActionProps =>
      'Spawns grid items on empty tiles';

  @override
  String get eventTitle_SpawnZombiesFromGridItemSpawnerProps =>
      'Grid Item Spawner';

  @override
  String get eventDesc_SpawnZombiesFromGridItemSpawnerProps =>
      'Spawns zombies from specific grid items';

  @override
  String get eventTitle_FairyTaleFogWaveActionProps => 'Magic Fog';

  @override
  String get eventDesc_FairyTaleFogWaveActionProps =>
      'Creates fog that covers the lawn and grants shields to zombies';

  @override
  String get eventTitle_FairyTaleWindWaveActionProps => 'Fairytale Breeze';

  @override
  String get eventDesc_FairyTaleWindWaveActionProps =>
      'Blows away all Magic Fog on the lawn';

  @override
  String get eventTitle_SpiderRainZombieSpawnerProps => 'Imp Rain';

  @override
  String get eventDesc_SpiderRainZombieSpawnerProps =>
      'Imps drop in from above';

  @override
  String get eventTitle_ParachuteRainZombieSpawnerProps => 'Parachute Rain';

  @override
  String get eventDesc_ParachuteRainZombieSpawnerProps =>
      'Zombies drop in by parachute';

  @override
  String get eventTitle_BassRainZombieSpawnerProps => 'Bass/Jetpack Rain';

  @override
  String get eventDesc_BassRainZombieSpawnerProps =>
      'Jetpack or Bass Zombies drop in from above';

  @override
  String get eventTitle_BlackHoleWaveActionProps => 'Black Hole';

  @override
  String get eventDesc_BlackHoleWaveActionProps =>
      'Generates a black hole to pull all plants';

  @override
  String get eventTitle_BarrelWaveActionProps => 'Barrel Crisis';

  @override
  String get eventDesc_BarrelWaveActionProps =>
      'Spawns barrels with different abilities in set lanes';

  @override
  String get eventTitle_SchoolBusWaveActionProps => 'Ice Cream Van Spawn';

  @override
  String get eventDesc_SchoolBusWaveActionProps =>
      'Spawns an ice cream van in a lane and configures the zombies inside';

  @override
  String get eventTitle_HamsterZombieSpawnerProps => 'Zombie Hamsterball';

  @override
  String get eventDesc_HamsterZombieSpawnerProps =>
      'Rolls hamsterballs that carry zombies onto the lawn';

  @override
  String get eventTitle_BungeeWaveActionProps => 'Bungee Drop';

  @override
  String get eventDesc_BungeeWaveActionProps =>
      'Drops a zombie by bungee to the lawn';

  @override
  String get eventTitle_ThunderWaveActionProps => 'Thundercloud Storm';

  @override
  String get eventDesc_ThunderWaveActionProps =>
      'Lightning strikes, applying positive or negative charges to plants';

  @override
  String get eventTitle_MagicMirrorWaveActionProps => 'Magic Mirror';

  @override
  String get eventDesc_MagicMirrorWaveActionProps =>
      'Generates paired teleportation mirrors';

  @override
  String get weatherOption_DefaultSnow_label =>
      'Glacial Snowfall (DefaultSnow)';

  @override
  String get weatherOption_DefaultSnow_desc =>
      'Snowfall effect used in Frostbite Caves Resurgence';

  @override
  String get weatherOption_LightningRain_label =>
      'Thunderstorm (LightningRain)';

  @override
  String get weatherOption_LightningRain_desc =>
      'Rain with lightning strikes that are purely visual';

  @override
  String get weatherOption_DefaultRainDark_label =>
      'Dark Rain (DefaultRainDark)';

  @override
  String get weatherOption_DefaultRainDark_desc =>
      'Briefly covers the lawn in darkness before returning to normal';

  @override
  String get iZombiePlantReserveLabel =>
      'Reserved Plant Column (PlantDistance)';

  @override
  String get column => 'Column(s)';

  @override
  String get iZombieInfoText =>
      'In I, Zombie Mode, preset plants and zombies must be configured in the Preset Plants and Seed Bank modules respectively.';

  @override
  String get vaseRangeTitle => 'Vase Spawn Range & Disabled Tiles';

  @override
  String get startColumnLabel => 'Start Col (Min)';

  @override
  String get endColumnLabel => 'End Col (Max)';

  @override
  String get toggleBlacklistHint =>
      'Tap tiles to toggle disabled status (vases will not spawn on disabled tiles)';

  @override
  String get vaseCapacityTitle => 'Vase Capacity';

  @override
  String vaseCapacitySummary(String current, String total) {
    return 'Assigned: $current / Total Slots: $total';
  }

  @override
  String get vaseListTitle => 'Vase List';

  @override
  String get addVaseTitle => 'Add Vase';

  @override
  String get plantVaseOption => 'Plant Vase (Green)';

  @override
  String get zombieVaseOption => 'Zombie Vase (Purple)';

  @override
  String get searchZombie => 'Search zombie';

  @override
  String get noZombieFound => 'No zombie found';

  @override
  String get unknownVaseLabel => 'Unknown Vase';

  @override
  String get plantLabel => 'Plant';

  @override
  String get zombieLabel => 'Zombie';

  @override
  String get itemLabel => 'Item';

  @override
  String get railcartType => 'Minecart type';

  @override
  String get layRails => 'Lay rails';

  @override
  String get placeCarts => 'Place minecarts';

  @override
  String get railSegments => 'Rail segment';

  @override
  String get railcartCount => 'Railcart count';

  @override
  String get clearAll => 'Clear all';

  @override
  String get moduleCategoryBase => 'Basic';

  @override
  String get moduleCategoryMode => 'Special Modes';

  @override
  String get moduleCategoryScene => 'Scene Config';

  @override
  String get moduleCategoryGimmick => 'Gimmick Config';

  @override
  String get moduleTitle_RocketZombieFlickModuleProperties => 'Rocket Flick';

  @override
  String get moduleDesc_RocketZombieFlickModuleProperties =>
      'Enables swiping to knock Rocket Imps off their rockets';

  @override
  String get kongfuRocketFlickDialogTitle => 'This Module Can Be Added';

  @override
  String get kongfuRocketFlickDialogMessage =>
      'The \"Rocket Flick\" module lets you swipe rockets on the screen to knock Rocket Imps off them. Add this module?';

  @override
  String get customZombie => 'Custom zombie';

  @override
  String get customZombieProperties => 'Custom Zombie Properties';

  @override
  String get zombieTypeNotFound => 'Zombie type object not found.';

  @override
  String get propertyObjectNotFound => 'Property object not found';

  @override
  String propertyObjectNotFoundHint(String alias) {
    return 'The custom zombie\'s property object ($alias) was not found in the level. The property definition does not point to level internals, so it cannot be edited here.';
  }

  @override
  String get baseStats => 'Base stats';

  @override
  String get hitpoints => 'Health (Hitpoints)';

  @override
  String get speed => 'Movement speed (Speed)';

  @override
  String get speedVariance => 'Speed variance (Variance)';

  @override
  String get eatDPS => 'Bite damage per second (EatDPS)';

  @override
  String get hitPosition => 'Hit & Position';

  @override
  String get hitRect => 'Hitbox (HitRect)';

  @override
  String get editHitRect => 'Edit Hitbox (HitRect)';

  @override
  String get attackRect => 'Eating Range (AttackRect)';

  @override
  String get editAttackRect => 'Edit Eating Range (AttackRect)';

  @override
  String get artCenter => 'Sprite Center (ArtCenter)';

  @override
  String get editArtCenter => 'Edit Sprite Center (ArtCenter)';

  @override
  String get shadowOffset => 'Shadow Offset (ShadowOffset)';

  @override
  String get editShadowOffset => 'Edit Shadow Offset (ShadowOffset)';

  @override
  String get groundTrackName => 'Movement Track (GroundTrackName)';

  @override
  String get groundTrackNormal => 'Normal ground (ground_swatch)';

  @override
  String get groundTrackNone => 'None (null)';

  @override
  String get appearanceBehavior => 'Appearance & Behavior';

  @override
  String get sizeType => 'Zombie Size (SizeType)';

  @override
  String get selectSize => 'Select size';

  @override
  String get disableDropFractions => 'Disable corpse HP (headDropFraction)';

  @override
  String get immuneToKnockback => 'Immune to knockback (CanBeLaunchedByPlants)';

  @override
  String get showHealthBarOnDamage =>
      'Show health bar on damage (EnableShowHealthBar)';

  @override
  String get drawHealthBarTime =>
      'Health bar duration (DrawHealthBarTime; seconds)';

  @override
  String get enableEliteScale => 'Enable elite scaling (EnableEliteScale)';

  @override
  String get eliteScale => 'Scale (EliteScale)';

  @override
  String get enableEliteImmunities =>
      'Enable elite immunities (EnableEliteImmunities)';

  @override
  String get canSpawnPlantFood => 'Can drop Plant Food (CanSpawnPlantFood)';

  @override
  String get canSurrender =>
      'Can die immediately at the end if no other zombies remain (CanSurrender)';

  @override
  String get canTriggerZombieWin =>
      'Can trigger game over when reaching the house (CanTriggerZombieWin)';

  @override
  String get resilience => 'Resistances (Resistences)';

  @override
  String get resilienceArmor => 'Resilience Shield';

  @override
  String get enableResilience => 'Enable resilience';

  @override
  String get resiliencePresetSelect => 'Selected resilience shield';

  @override
  String get resilienceAmount => 'Resilience value (Amount)';

  @override
  String get resilienceWeakType => 'Resilience type (WeakType)';

  @override
  String get resilienceRecoverSpeed =>
      'Resilience bar recovery speed (RecoverSpeed)';

  @override
  String get resilienceDamageThresholdPerSecond =>
      'Zombie damage threshold per second (DamageThresholdPerSecond)';

  @override
  String get resilienceBaseDamageThreshold =>
      'Resilience base damage threshold (ResilienceBaseDamageThreshold)';

  @override
  String get resilienceExtraDamageThreshold =>
      'Resilience extra damage threshold (ResilienceExtraDamageThreshold)';

  @override
  String get resilienceCodename =>
      'Resilience codename (aliases; English letters only; no spaces)';

  @override
  String get resilienceCodenameHint => 'e.g. CustomResilience0';

  @override
  String get instantKillResistance =>
      'Instant kill resistance (chance to ignore instant kill effects)';

  @override
  String get resiliencePhysics => 'Physics';

  @override
  String get resiliencePoison => 'Poison';

  @override
  String get resilienceElectric => 'Electric';

  @override
  String get resilienceMagic => 'Magic';

  @override
  String get resilienceIce => 'Ice';

  @override
  String get resilienceFire => 'Fire';

  @override
  String get resilienceHint =>
      'Value range: 0.0–1.0 (0.0 = no resistance, 1.0 = full immunity)';

  @override
  String get resilienceSelectedShieldLabel => 'Selected Resilience Shield:';

  @override
  String get selectionFilterBySource => 'By source';

  @override
  String get selectionFilterByType => 'By type';

  @override
  String get selectionPreMade => 'Pre-made';

  @override
  String get selectionDefinedByUser => 'Custom';

  @override
  String get aliasAlreadyTakenTitle => 'Alias already taken';

  @override
  String get aliasRenameConfirmTitle => 'Rename alias?';

  @override
  String aliasRenameConfirmMessage(String oldAlias, String newAlias) {
    return 'Rename \"$oldAlias\" to \"$newAlias\"? All references in this level will be updated.';
  }

  @override
  String get resilienceSelectShield => 'Select resilience shield';

  @override
  String get resilienceCreateCustom => 'New custom shield';

  @override
  String get resilienceEditCustom => 'Edit custom shield';

  @override
  String get resilienceTypeAll => 'All types';

  @override
  String get resilienceNoShieldsFound => 'No resilience shields found';

  @override
  String get resilienceShieldInUseCannotDelete =>
      'Cannot delete — this shield is used by zombies in this level.';

  @override
  String get resilienceShieldDeleteTitle => 'Delete custom resilience shield?';

  @override
  String resilienceShieldDeleteMessage(String alias) {
    return 'Delete \"$alias\" from this level?';
  }

  @override
  String get aliasAlreadyExists => 'Alias already exists in this level.';

  @override
  String zombieTypeLabel(String type) {
    return 'Zombie type: $type';
  }

  @override
  String propertyAliasLabel(String alias) {
    return 'Property alias: $alias';
  }

  @override
  String get ok => 'OK';

  @override
  String get helpDialogGotIt => 'Got it';

  @override
  String get width => 'Width';

  @override
  String get height => 'Height';

  @override
  String get customZombieHelpIntro => 'Brief introduction';

  @override
  String get customZombieHelpIntroBody =>
      'This screen edits custom zombie parameters injected into the level. Only common properties are supported; many special attributes require manual JSON editing.';

  @override
  String get customZombieHelpBase => 'Base properties';

  @override
  String get customZombieHelpBaseBody =>
      'Custom zombies can modify base stats (HP, speed, eat damage). Custom zombies do not appear in the level preview pool.';

  @override
  String get customZombieHelpHit => 'Hit/position';

  @override
  String get customZombieHelpHitBody =>
      'X and Y are offsets; W and H are width and height. Offsetting ArtCenter can hide the zombie sprite. Leaving ground track as none lets the zombie walk in place.';

  @override
  String get customZombieHelpManual => 'Manual editing';

  @override
  String get customZombieHelpManualBody =>
      'When injecting a custom zombie, the editor automatically fills in the original zombie\'s relevant properties from the corresponding game files. You can further edit the JSON file manually if needed.';

  @override
  String editAlias(String alias) {
    return 'Edit $alias';
  }

  @override
  String editNamedEvent(String name) {
    return 'Edit $name event';
  }

  @override
  String editNamedModule(String name) {
    return 'Edit $name module';
  }

  @override
  String get addEventAliasTitle => 'Add event';

  @override
  String get addModuleAliasTitle => 'Add module';

  @override
  String get aliasLabel => 'Alias (English letters only; no spaces)';

  @override
  String get add => 'Add';

  @override
  String get overview => 'Overview';

  @override
  String get left => 'Left';

  @override
  String get right => 'Right';

  @override
  String get weight => 'Weight';

  @override
  String get maxCount => 'Max count';

  @override
  String get startColumn => 'Start column';

  @override
  String get endColumn => 'End column';

  @override
  String get removeItem => 'Remove item';

  @override
  String removeItemConfirm(String name) {
    return 'Remove $name?';
  }

  @override
  String groupN(int n) {
    return 'Group $n';
  }

  @override
  String rowN(int n) {
    return 'Row $n';
  }

  @override
  String get addWind => 'Add wind';

  @override
  String get addDropItem => 'Add drop item';

  @override
  String get addMirrorGroup => 'Add a mirror group above';

  @override
  String pipeN(int n) {
    return 'Pipe $n';
  }

  @override
  String get setStart => 'Set entrance sewer';

  @override
  String get setEnd => 'Set exit sewer';

  @override
  String get collectable => 'Collectible (Plant Food)';

  @override
  String get plantFood => 'Plant Food';

  @override
  String get initialPlantLayout => 'Initial plant layout';

  @override
  String get gridItemLayout => 'Grid item layout';

  @override
  String get zombieCount => 'Total count (Total)';

  @override
  String get timeBeforeSpawn => 'Time before full spawn (seconds)';

  @override
  String get waterBoundaryColumn => 'Column Offset (ChangeAmount)';

  @override
  String get columnsDragged => 'Columns dragged (ColNumPlantIsDragged)';

  @override
  String get typeIndex => 'Mirror Appearance (TypeIndex)';

  @override
  String get noStyle => 'No style';

  @override
  String styleN(int n) {
    return 'Style $n';
  }

  @override
  String get existDurationSec => 'Exist duration (sec)';

  @override
  String get mirror1 => 'Mirror 1';

  @override
  String get mirror2 => 'Mirror 2';

  @override
  String get ignoreGravestone => 'Ignore tombstone (IgnoreGraveStone)';

  @override
  String zombiePreview(String name) {
    return '$name - Zombie preview';
  }

  @override
  String get zombiePreviewTooltip => 'Zombie preview';

  @override
  String get weatherSettings => 'Weather Settings';

  @override
  String get holeLifetimeSeconds => 'Crater duration (seconds)';

  @override
  String get startingWaveLocation =>
      'Initial tide position (StartingWaveLocation)';

  @override
  String get rainIntervalSeconds => 'Drop interval (seconds)';

  @override
  String get bowlingFoulLine => 'No-planting line (BowlingFoulLine)';

  @override
  String get bowlingFoulLinePreview => 'No-planting line preview';

  @override
  String get bowlingMinigameParams => 'Parameters';

  @override
  String get bowlingMinigameHelpOverview =>
      'A legacy configuration module for Bulb Bowling that sets the no-planting line and disables the shovel. It can also be used in regular levels. Plants cannot be placed on or to the right of the no-planting line.';

  @override
  String get bowlingMinigameHelpFoulLine =>
      'Sets the column boundary for the no-planting area. Its value is counted from the left edge of the lawn starting at 0. For example, the left boundary of the first tile from the left is 0, while its right boundary is 1. Lower boundary values leave less usable space on the left.\nOn Underwater World lawns, the game automatically adds 1 to this value. For example, a value of 0 leaves column 1 plantable and blocks planting from column 2 onward; the minimum value available in the editor is therefore -1.';

  @override
  String get stopColumn => 'Stop Column';

  @override
  String get speedUp => 'Speed Multiplier';

  @override
  String get baseCostIncreased =>
      'Sun cost increase per planting (BaseCostIncreased)';

  @override
  String get maxIncreasedCount => 'Max Cost Increase Count (MaxIncreasedCount)';

  @override
  String get initialMistPositionX => 'Initial fog column';

  @override
  String get normalValueX =>
      'Extension distance to the right (1 tile = 64 units)';

  @override
  String get bloverEffectInterval => 'Blover effect interval (seconds)';

  @override
  String get dinoType => 'Dinosaur type';

  @override
  String get dinoRowTitle => 'Row';

  @override
  String dinoRow(int n) {
    return 'Row: $n';
  }

  @override
  String get dinoWaveDuration => 'Stay duration (waves)';

  @override
  String get eventHelpDinoRow =>
      'The row where the dinosaur appears, counted from 0. On Underwater World lawns, this can be set to 5 for the sixth row.';

  @override
  String get eventHelpDinoWaveDuration =>
      'The number of waves a dinosaur remains on the lawn. The dinosaur will leave after staying for the specified number of waves or after interacting with a certain number of zombies. When set to 0, there is no wave limit, and the dinosaur will leave after completing its interactions by default.';

  @override
  String get unknownModuleTitle => 'Module editor in development';

  @override
  String get unknownModuleHelpTitle => 'Unknown module';

  @override
  String get noEditorForModule => 'No editor available for this module';

  @override
  String get noEditorForModuleBody =>
      'This module is not registered in the level interpreter, so no editor is available. It may also be due to the module\'s objclass being manually modified, preventing it from being read correctly.';

  @override
  String get invalidEventTitle => 'Invalid event';

  @override
  String get invalidReference => 'Invalid reference';

  @override
  String aliasNotFound(String alias) {
    return 'Alias \"$alias\" not found';
  }

  @override
  String invalidRefBody(int wave) {
    return 'Wave $wave references this event, but no corresponding entity definition was found in the level. This is usually caused by accidental deletion or manual renaming. Keeping it in the level may cause the game to crash.';
  }

  @override
  String get removeInvalidRef =>
      'Remove this invalid reference from the wave container';

  @override
  String get spawnCount => 'Spawn count';

  @override
  String get columnRangeTiming => 'Column range & timing';

  @override
  String get waveStartMessage => 'Red warning message';

  @override
  String get optional =>
      'Shown at the center when the event starts; Chinese input not supported';

  @override
  String get eventHelpBeachStageBody =>
      'Zombies emerge from beneath the water. Commonly used for Snorkel Zombies in Big Wave Beach or for zombies that appear during low tide.\nSimilar to Parachute Rain, zombies will spawn in batches. You can specify the total number and spawn range.\nOnly one type of zombie can be used per event. To include multiple types, you need to add multiple events.';

  @override
  String get eventHelpTidalChangeBody =>
      'This event is used to change the tide position during the selected wave. The range of tide changes cannot exceed the bounds of the lawn.';

  @override
  String get eventTideWave => 'Event: Ocean Currents';

  @override
  String get eventHelpTideWaveBody =>
      'Creates ocean currents that push the submarine and grant speed boosts to zombies. Commonly used in Underwater World – 20,000 Leagues Under the Sea levels.';

  @override
  String get tideWaveHelpType => 'Direction';

  @override
  String get eventHelpTideWaveType =>
      'Left: Currents come from the left, pushing the submarine right and speeding up zombies on the left side.\nRight: Currents come from the right, pushing the submarine left and speeding up zombies on the right side.';

  @override
  String get tideWaveHelpParams => 'Notes';

  @override
  String get eventHelpTideWaveParams =>
      'Unless otherwise specified, the submarine returns to its original position after the duration ends. Plants cannot be planted on the submarine while it is moving.';

  @override
  String get tideWaveType => 'Direction (Type)';

  @override
  String get tideWaveTypeLeft => 'Left';

  @override
  String get tideWaveTypeRight => 'Right';

  @override
  String get tideWaveDuration => 'Duration (seconds)';

  @override
  String get tideWaveSubmarineMovingDistance =>
      'Submarine moving distance (columns)';

  @override
  String get tideWaveSpeedUpDuration => 'Speed boost duration (seconds)';

  @override
  String get tideWaveSpeedUpIncreased =>
      'Speed boost multiplier (tideWaveSpeedUpIncreased)';

  @override
  String get tideWaveSubmarineMovingTime => 'Submarine moving time (seconds)';

  @override
  String get tideWaveZombieMovingSpeed =>
      'Zombie speed in current (tideWaveZombieMovingSpeed; 1 tile = 64 units)';

  @override
  String get eventZombieFishWave => 'Event: Underwater Spawner';

  @override
  String get eventHelpZombieFishWaveBody =>
      'Configures the zombies and sea creatures used in Two-Sided Attack, and can only be used in Underwater World levels. Coordinates are 0-based: row 1 = 0, column 10 = 9.';

  @override
  String get eventHelpZombieFishWaveFish =>
      'Use the \"Add sea creature properties\" button to place sea creatures on the lawn. Size of the lawn varies by level: 6×10 in Underwater World, 5×9 in other levels. Rows correspond to Y, columns to X.';

  @override
  String get eventHelpBatchLevel =>
      'Sets all zombies in this wave to the specified level. Elite zombies are unaffected and retain their default level.';

  @override
  String get eventHelpDropConfig =>
      'If the number of plants in the drop list equals the number of Plant Food drops, the drops will become seed packets.';

  @override
  String get fishPropertiesEntryHelp =>
      'Tap a tile to select it, then add sea creatures. Tap \"+\" to add built-in sea creatures. Tap a creature\'s icon for more options such as duplicate, delete, or customize. Customized creatures are marked with a blue \"C\". A warning is shown if a creature is placed outside the lawn.';

  @override
  String get makeFishAsCustom => 'Make sea creature as custom';

  @override
  String get switchCustomFish => 'Switch custom sea creature';

  @override
  String get selectCustomFish => 'Select custom sea creature';

  @override
  String get editCustomFishProperties => 'Edit custom sea creature properties';

  @override
  String get fishPropertiesButton => 'Sea creature properties';

  @override
  String get addFishProperties => 'Add sea creature properties';

  @override
  String get editFishProperties => 'Edit sea creature properties';

  @override
  String get fishPropertiesGrid =>
      'Sea Creature placement (row = Y, column = X)';

  @override
  String get fishSelectedPosition => 'Selected:';

  @override
  String get fishRow => 'Row';

  @override
  String get fishColumn => 'Column';

  @override
  String get fishAtPosition => 'Sea creature at position';

  @override
  String get searchFish => 'Search sea creature';

  @override
  String get noFishFound => 'No sea creature found';

  @override
  String get customFishManagerTitle => 'Custom sea creature';

  @override
  String get customFishAppearanceLocation => 'Spawn location:';

  @override
  String get customFishNotUsed =>
      'This custom sea creature is not used by any wave.';

  @override
  String customFishWaveItem(int n) {
    return 'Wave $n';
  }

  @override
  String get customFishDeleteConfirm =>
      'Remove this custom sea creature and its property data.';

  @override
  String get customFish => 'Custom sea creature';

  @override
  String get customFishProperties => 'Custom sea creature properties';

  @override
  String get fishTypeNotFound => 'Sea creature type object not found.';

  @override
  String fishTypeLabel(String type) {
    return 'Sea creature type: $type';
  }

  @override
  String get customFishHelpIntro => 'Overview';

  @override
  String get customFishHelpIntroBody =>
      'This screen allows you to edit custom sea creature parameters. Only common properties are supported; animation and special attributes require manual JSON editing.';

  @override
  String get customFishHelpProps => 'Properties';

  @override
  String get customFishHelpPropsBody =>
      'HitRect, AttackRect and ScareRect define collision areas. Speed and ScareSpeed control movement. ArtCenter defines center of the sprite.';

  @override
  String get noEditableFishProps => 'No editable properties found.';

  @override
  String get fishPropSpeed => 'Movement Speed (Speed)';

  @override
  String get fishPropScareSpeed => 'Speed When Scared (ScareSpeed)';

  @override
  String get fishPropDamage => 'Damage';

  @override
  String get fishPropHitpoints => 'Health (Hitpoints)';

  @override
  String get fishPropHitPoints => 'Health (Hitpoints)';

  @override
  String get fishPropHitRect => 'Hitbox (HitRect)';

  @override
  String get fishPropAttackRect => 'Attack Range (AttackRect)';

  @override
  String get fishPropScareRect => 'Scare area (ScareRect)';

  @override
  String get fishPropScarerect => 'Scare area (Sacrerect)';

  @override
  String get fishPropArtCenter => 'Sprite Center (ArtCenter)';

  @override
  String get edit => 'Edit';

  @override
  String get eventHelpTidalChangePosition =>
      'Sets the tide position after the change. The rightmost column is 0, and the leftmost is 9. Accepts integers, including negative values.';

  @override
  String get eventHelpBlackHoleBody =>
      'A event commonly seen in Kongfu World. A black hole will spawn and pull all plants to the right.';

  @override
  String get eventHelpBlackHoleColumns =>
      'You can specify how many columns plants are dragged, indicating how many tiles they will be pulled to the right by the black hole.';

  @override
  String get eventHelpMagicMirrorBody =>
      'Spawns paired mirrors on the lawn. Each pair consists of an entrance and an exit, both sharing the same appearance.';

  @override
  String get eventHelpMagicMirrorType =>
      'You can change the mirror’s appearance to distinguish them. There are 3 different types of Magic Mirrors in this event.';

  @override
  String get eventHelpParachuteRainBody =>
      'Zombies will parachute in from above for a surprise attack. Commonly used for Bug Bot Imp, Lost Pilot Zombie, Bass Zombie, ZCorp Helpdesk, and more. Zombie levels follow the lawn’s level sequence.';

  @override
  String get eventHelpParachuteRainLogic =>
      'Zombies drop in batches. You can control the total number and the interval between each batch. Zombies will land randomly within the selected columns. If the total pre-drop delay is reached, any remaining zombies will spawn immediately.\nA red warning message will appear before the event starts. Entering Chinese text in the message may result in garbled characters. You can leave the zombie type empty to use this event purely for message display.';

  @override
  String get eventHelpModernPortalsBody =>
      'Spawns a fixed type of spacetime portal on the lawn, commonly seen in Modern Day and Memory Lane.\nOnly one spacetime portal can be configured per event. To have multiple portals appear simultaneously, add multiple Spacetime Portal events within the wave.';

  @override
  String get eventHelpModernPortalsType =>
      'There are many types of spacetime portals in the game. You can select a specific type and preview the spawned zombies.';

  @override
  String get eventHelpModernPortalsIgnore =>
      'When enabled, spacetime portals will still spawn even if blocked by grid items such as tombstones or surfboards.';

  @override
  String get eventHelpFrostWindBody =>
      'A common event in Frostbite Caves. Freezing wind is generated on specified rows, freezing plants into ice blocks.';

  @override
  String get eventHelpFrostWindDirection =>
      'You can set the direction of the wind (from left or right). Note that there is an interval between each wind. To make them occur simultaneously, try adding multiple Freezing Wind events.';

  @override
  String get eventHelpModifyConveyorBody =>
      'This event allows you to modify conveyor belt plants during gameplay. Parameters are similar to the conveyor belt module. Make sure the conveyor belt module is already included in the level.';

  @override
  String get eventHelpModifyConveyorAdd =>
      'Adds new plants or tool packets to the conveyor belt. If the plant already exists, its previous data will be overwritten.';

  @override
  String get eventHelpModifyConveyorRemove =>
      'Removing does not work when the Creative Courtyard module is enabled. Instead, set the plant’s weight to 0 to achieve the same effect.';

  @override
  String get eventHelpDinoBody =>
      'A common event in Jurassic Marsh. Summons a specified dinosaur into a chosen row. The dinosaur will assist zombies in attacking.\nOnly one dinosaur can be configured per event. To have multiple dinosaurs appear simultaneously, add multiple Dino Summon events within the wave.';

  @override
  String get eventHelpDinoDuration =>
      'The duration the dinosaur stays on the lawn, measured in waves. It will leave after the time expires or after interacting with enough zombies.';

  @override
  String get eventDinoTread => 'Event: Dino Stomp';

  @override
  String get eventDinoRun => 'Event: Dino Stampede';

  @override
  String get eventHelpDinoTreadBody =>
      'Brontosaurus moves its foot into the designated area and stomps after a few seconds, dealing damage to all plants and zombies within range. It leaves a footprint lasting about 7 seconds, during which planting is not allowed in that area.';

  @override
  String get eventHelpDinoTreadRowCol =>
      'GridY is the stomp center row; GridXMin and GridXMax bound the possible center columns (all 0-based). Each stomp covers a 3×3 area around its center. The preview highlights every cell that can be stomped across those positions. Underwater World: rows 0–5, columns 0–9.';

  @override
  String get dinoTreadPreview => 'Possible stomp area preview';

  @override
  String get dinoTreadRowLabel => 'Row (GridY)';

  @override
  String get dinoTreadColMinLabel => 'Leftmost Column (GridXMin)';

  @override
  String get dinoTreadColMaxLabel => 'Rightmost Column (GridXMax)';

  @override
  String get dinoTreadTimeIntervalLabel =>
      'Entry delay (TimeInterval; seconds)';

  @override
  String get columnStartLabel => 'Start Column (ColumnStart)';

  @override
  String get columnEndLabel => 'End Column (ColumnEnd)';

  @override
  String get eventHelpDinoRunBody =>
      'When triggered, dinosaurs gather across 2–3 rows. They do not use their abilities, but instead charge into the lawn, trampling plants or zombies. The number of targets they can trample depends on the dinosaur type.';

  @override
  String get eventHelpDinoRunRow =>
      'DinoRow defines the center row of the dino rush (red in the preview). Stampede dinosaurs may also spawn on the rows directly above and below (yellow). Rows are 0-based. Underwater World supports up to 5.';

  @override
  String get dinoRunPreview => 'Stampede preview';

  @override
  String get positionAndArea => 'Position & area';

  @override
  String get positionAndDuration => 'Position & timing';

  @override
  String get rowCol0Index => 'Row/column (0-based)';

  @override
  String get timeInterval => 'Time interval';

  @override
  String get eventHelpZombiePotionBody =>
      'Force-spawns potions on the lawn, ignoring plants. Can be used as an alternative to grid item spawn events.';

  @override
  String get eventHelpZombiePotionUsage =>
      'Unlike the preset pools used for grid item spawning, this event forces grid items to spawn on specific tiles and displaces plants. \nNote that on lawns without tombstone spawn effects, sun textures may appear incorrectly. Use with caution.';

  @override
  String get eventHelpShellBody =>
      'Spawns atlantis seashells at specified positions. Seashells start in a closed state. When a zombie steps on a seashell, it opens, launches the zombie forward, and closes again after 10 seconds. While open, seashells can be attacked by plants and block straight-shot projectiles. Each time a seashell opens, it generates a random item, including a Plant Food, a Cuttlefish, a plant seed packet, or a Relic Imp. After being triggered by zombies 3 times, the seashell will swim toward the seed bank and replace a random seed slot with a seashell seed packet. After the seashell has been planted 3 times, the seed slot will revert to its original plant.';

  @override
  String get eventHelpShellUsage =>
      'Select a tile, then tap \"+\" to place a seashell. Lawn size varies by level: 6 rows × 10 columns in Underwater World, and 5 rows × 9 columns in other levels.';

  @override
  String get eventHelpPumpkinHouseBody =>
      'Spawns pumpkin houses at specified positions. Zombies that pass through the Pumpkin House are transformed into Pumpkin House Ghosts. Pumpkin House Ghosts have a separate health pool and can only be damaged by lobbed plants. When their health is depleted, they revert to their original zombie form. The Pumpkin House itself also has its own health and can be destroyed by concentrated fire.';

  @override
  String get eventHelpPumpkinHouseUsage =>
      'Select a tile, then tap \"+\" to place a pumpkin house. Lawn size varies by level: 6 rows × 10 columns in Underwater World, and 5 rows × 9 columns in other levels.';

  @override
  String get eventHelpZombieTentBody =>
      'This event force spawns zombie tents from Memory Lane directly on the lawn. Unlike the tents carried by Imp Porters, these tents do not require Gold Tiles. They appear at the specified positions and continually summon zombies until destroyed. The level can only be won after every zombie tent on the lawn has been destroyed.';

  @override
  String get eventHelpZombieTentUsage =>
      'Select a grid cell and tap \"+\" to place a tent. You can then configure each tent’s type, hitpoints, zombie spawn weights, and spawn interval individually.';

  @override
  String get eventHelpZombieTentFieldsTitle => 'Parameter Description';

  @override
  String get eventHelpZombieTentFields =>
      'Regular tents and New Year tents function identically; only their appearance differs.\nA higher weight gives a zombie a greater chance of being selected. For example, weights of 10 and 30 give the two zombies an approximately 1:3 chance ratio.\nZombie level 0 uses the lawn’s default level, which is level 1 in Creative Courtyard.\nWhen editing the JSON manually, note that tent columns (Column) and rows (Row) are numbered from 1. For example, \"Column\": 7 means the seventh column.';

  @override
  String get eventZombieTentSpawn => 'Event: Zombie Tent Spawn';

  @override
  String get zombieTentSectionTitle => 'Tents at selected tile';

  @override
  String get zombieTentTypeLabel => 'Tent type (TentType)';

  @override
  String get zombieTentTypeNormal => 'Regular tent';

  @override
  String get zombieTentTypeFestival => 'New Year tent';

  @override
  String get zombieTentHitpoints => 'Tent hitpoints (Hitpoints)';

  @override
  String get zombieTentProductionInterval =>
      'Production interval (ProductionInterval, seconds)';

  @override
  String get zombieTentZombiesSection =>
      'Possible zombie spawns (ZombieTypesToSpawn)';

  @override
  String get zombieTentWeight => 'Spawn weight (Weight)';

  @override
  String get zombieTentAddZombie => 'Add zombie';

  @override
  String get zombieTentAddTent => 'Add tent';

  @override
  String get zombieTentDeleteTitle => 'Delete tent';

  @override
  String get zombieTentDeleteConfirm =>
      'Are you sure you want to delete this tent?';

  @override
  String get eventHelpFairyFogBody =>
      'Creates magic fog that covers the lawn and grants shields to zombies. Commonly used in Fairy Forest levels. Can only be cleared by the Fairtyale Breeze event.\nHigher-tier fog grants stronger shields and increased control immunity to zombies. Tiers, from lowest to highest, are White, Blue, and Purple.';

  @override
  String get eventHelpFairyFogRange =>
      'mX and mY define the center point. mWidth and mHeight define how far the area extends to the right and downward from the center.';

  @override
  String get eventHelpFairyWindBody =>
      'Generates a continuous breeze that clears magical fog. Commonly used in Fairy Forest levels.';

  @override
  String get eventHelpFairyWindVelocity =>
      'This event affects projectile speed while active. 1.0 = normal speed; higher values increase projectile speed.';

  @override
  String get eventHelpRaidingPartyBody =>
      'Commonly seen in Pirate Seas levels. Spawns groups of Swashbuckler Zombies in batches. TimeBetweenGroups defines the interval between each group.';

  @override
  String get eventHelpRaidingPartyGroup => 'Zombies per group.';

  @override
  String get eventHelpRaidingPartyCount =>
      'Total Swashbuckler Zombies spawned.';

  @override
  String get eventHelpGravestoneBody =>
      'Randomly spawns grid items during a wave (e.g., Dark Ages tombstones).';

  @override
  String get eventHelpGravestoneLogic =>
      'Selects valid tiles from the pool above to spawn grid items. The total number of grid items cannot exceed the number of available tiles, or excess spawns will fail.';

  @override
  String get eventHelpGravestoneMissingAssets =>
      'Some lawns without tombstone spawn effects may show sun textures instead. Use with caution.';

  @override
  String get eventHelpBarrelWaveBody =>
      'Spawns the three barrel types from the Memory Lane \"Barrel Crisis\" gimmick. Barrels roll in from the right and crush all plants in their path.';

  @override
  String get barrelWaveHelpTypes => 'Barrel types';

  @override
  String get eventHelpBarrelWaveTypes =>
      'Empty Barrel: Breaks with no effect.\nImp Barrel: Releases zombies (usually Imps) when destroyed.\nExplosive Barrel: Explodes on contact or when destroyed, damaging plants and zombies in a 3×3 area.';

  @override
  String get barrelWaveHelpRows => 'Row';

  @override
  String get eventHelpBarrelWaveRows =>
      'Rows are 1-based: Row 1 = top lane, Row 5/6 = bottom lane. Standard lawns: 5 rows. Underwater World lawns: 6 rows.';

  @override
  String get eventHelpSchoolBusBody =>
      'Spawns an Ice Cream Van in the specified lane. Ice Cream Van slowly enters from the right side while carrying zombies, occupying 2 lanes. Any plants run over by the van are instantly crushed.\nIf the van is displayed with Bubble Gun Imps and Lollipop Zombies (i.e. the schoolbus_special variant) and at least one plant is present on the lawn, they will continuously use their respective abilities while the van is moving.\nPlants like Spikeweed and Spikerock can puncture the van\'s tires. After its tires are punctured, the Ice Cream Van gradually slows down and enters a gliding state. After a short period of time, it comes to a stop and breaks down.';

  @override
  String get schoolBusHelpRows => 'Row';

  @override
  String get eventHelpSchoolBusRows =>
      'Rows are 1-based: Row 1 = top lane, Row 5/6 = bottom lane. Standard lawns: 5 rows. Underwater World lawns: 6 rows.';

  @override
  String get eventHelpSchoolBusType =>
      'Type selects the ice cream van variant. Normal (schoolbus_normal) is the standard van. Special (schoolbus_special) shows Bubble Gun Imps and Lollipop Zombies on the van; while at least one plant is present on the lawn, they use their abilities as the van moves.';

  @override
  String get schoolBusHelpZombies => 'Zombies';

  @override
  String get eventHelpSchoolBusZombies =>
      'Ice Cream Van has its own health pool. Once destroyed, the zombies inside will exit the vehicle and continue advancing. Each zombie\'s level can be configured individually (Level 0 follows the lawn’s default level, which is Level 1 in Creative Courtyard).';

  @override
  String get schoolBusRow => 'Row';

  @override
  String get schoolBusType => 'Type';

  @override
  String get schoolBusTypeNormal => 'Normal';

  @override
  String get schoolBusTypeSpecial => 'Special';

  @override
  String get schoolBusHitPoints => ' Van health (SchoolBusHitPoints)';

  @override
  String get schoolBusSpeed => 'Van speed (SchoolBusSpeed)';

  @override
  String get schoolBusZombies => 'Contained zombies (Zombies)';

  @override
  String get schoolBusZombieLevel => 'Zombie level (Level)';

  @override
  String get schoolBusAddZombie => 'Add zombie';

  @override
  String get eventHelpThunderWaveBody =>
      'Lightning strikes during the wave, hitting plants adjacent to other plants. Commonly used in Sky City levels. Each strike applies either a positive or negative charge to plants.';

  @override
  String get thunderWaveHelpTypes => 'Charge effects';

  @override
  String get eventHelpThunderWaveTypes =>
      'Two positive charges cause continuous percentage damage from an overhead energy orb.\nTwo negative charges paralyze the plant for a short duration.\nOne positive and one negative charge permanently slow the plant.\nPlants can still receive charges while affected, but no additional effects will be applied.';

  @override
  String get thunderWaveHelpKillRate => 'Kill rate';

  @override
  String get eventHelpThunderWaveKillRate =>
      'The chance for lightning to instantly kill a plant on hit (0.0–1.0). Anthurium is unaffected. This applies to both positive and negative lightning.';

  @override
  String get thunderWaveTypePositive => 'Positive';

  @override
  String get thunderWaveTypeNegative => 'Negative';

  @override
  String get thunderWaveKillRate => 'Kill rate';

  @override
  String get thunderWaveKillRateHint =>
      'Probability of killing plants on lightning strike (0.0–1.0), Anthurium is unaffected';

  @override
  String get thunderWaveThunders => 'Lightnings';

  @override
  String get thunderWaveAddThunder => 'Add lightning';

  @override
  String get thunderWaveThunder => 'Lightning';

  @override
  String get barrelWaveTypeEmpty => 'Empty Barrel (barrelempty)';

  @override
  String get barrelWaveTypeZombie => 'Imp Barrel (barrelmoster)';

  @override
  String get barrelWaveTypeExplosive => 'Explosive Barrel (barrelpowder)';

  @override
  String get barrelWaveRowsHint =>
      'Rows are 1-based: Row 1 = top lane, Row 5/6 = bottom lane.';

  @override
  String get barrelWaveAddBarrel => 'Add barrel';

  @override
  String get barrelWaveBarrel => 'Barrel';

  @override
  String get barrelWaveRow => 'Row';

  @override
  String get barrelWaveType => 'Type';

  @override
  String get barrelWaveHitPoints => 'Barrel health (BarrelHitPoints)';

  @override
  String get barrelWaveSpeed => 'Barrel speed (BarrelSpeed)';

  @override
  String get barrelWaveZombies => 'Contained zombies (Zombies)';

  @override
  String get barrelWaveZombieLevel => 'Zombie level (Level)';

  @override
  String get barrelWaveAddZombie => 'Add zombie';

  @override
  String get barrelWaveExplosionDamage =>
      'Explosion damage (BarrelBlowDamageAmount)';

  @override
  String get barrelWaveDeleteTitle => 'Delete barrel';

  @override
  String get barrelWaveDeleteConfirm => 'Delete this barrel?';

  @override
  String get barrelWaveDeleteLastHint =>
      'This is the last barrel. Deleting it will leave this event without any barrels. Continue?';

  @override
  String get moduleHelpDeathHoleBody =>
      'When a plant is shoveled, eaten, or otherwise removed, it leaves an unplantable crater on the tile it occupied for a period of time.';

  @override
  String get moduleHelpZombieMoveFastBody =>
      'Makes zombies move quickly as they enter the lawn, returning to normal speed after they reach the specified column. Commonly used in the Zombie Elimination Initiative levels.';

  @override
  String get moduleHelpSeedRainBody =>
      'At fixed intervals, this module causes item cards to fall from the sky.';

  @override
  String get moduleHelpSeedRainParameters => 'Parameter settings';

  @override
  String get moduleHelpSeedRainParametersBody =>
      'Weight determines an item\'s chance of dropping, while Max count limits how many copies may be present on the lawn at once. Note that most zombies do not have matching zombie card icons.';

  @override
  String get moduleHelpSeedRainPlantLevels => 'Plant levels';

  @override
  String get seedRainAddContentTitle => 'Add rain content';

  @override
  String get moduleHelpRailcartBody =>
      'Configure the positions of minecarts and rails and select the minecart style. Tap a tile once to place an item, and tap it again to remove it.';

  @override
  String get moduleHelpRailcartRailsBody =>
      'In Lay rails mode, tap tiles to lay rails. The editor automatically combines consecutive tiles in the same column into a single rail segment.';

  @override
  String get moduleHelpRailcartCartsBody =>
      'Tap tiles to place or remove minecarts. Note that minecarts on the same rail segment can easily stack.';

  @override
  String get moduleHelpTideBody =>
      'Enables the tide system for the level, allowing tide-related events to be used. Note that this module must be added last; otherwise, it may cause the level to crash.';

  @override
  String get moduleHelpTidePosition =>
      'Sets the position of the tide at the start of the level, i.e., the position of the tide line within the level. The rightmost column is 0 and the leftmost is 9. Accepts integers, including negative values.';

  @override
  String get initialTidePosition => 'Tide line configuration';

  @override
  String get moduleHelpWeatherBody =>
      'Controls global environmental effects such as rain and snow.';

  @override
  String get moduleHelpWeatherRef =>
      'These modules are typically referenced directly from LevelModules and do not require custom configuration.';

  @override
  String get moduleHelpZombiePotionBody =>
      'This module periodically spawns specified grid item types in random rows, moving from right to left.';

  @override
  String get moduleHelpZombiePotionMechanism => 'Spawn Mechanism';

  @override
  String get moduleHelpZombiePotionMechanismBody =>
      'Grid items spawn randomly within the configured time interval. If the number of matching grid items on the lawn reaches the limit, spawning pauses.';

  @override
  String get moduleHelpZombiePotionPotionTypes => 'Potion Types';

  @override
  String get moduleHelpZombiePotionTypes =>
      'One type is randomly selected from the configured list. To spawn multiple grid items at fixed intervals, add this module multiple times in the level.';

  @override
  String get moduleHelpUnknownBody =>
      'A level file consists of a root node and multiple modules, known as PVZ2Object. Each object has aliases, a type (objclass), and data (objdata). The root node has no aliases.';

  @override
  String get moduleHelpUnknownEvents =>
      'This software determines module types by reading objclass. The objclass of the current module is not registered in the module list, so no matching editor is available. Support may be added in a future update.';

  @override
  String get eventHelpInvalidBody =>
      'This event is referenced in the wave container, but the parser cannot find its entity definition in the level, leaving the RTID block unresolved.';

  @override
  String get eventHelpInvalidImpact =>
      'Keeping this invalid entry in the level will prevent it from being read correctly and may cause a crash. It should be removed manually.';

  @override
  String get position => 'Selected position';

  @override
  String get editing => 'Editing';

  @override
  String get logic => 'Logic';

  @override
  String get impact => 'Impact';

  @override
  String get events => 'Events';

  @override
  String get referenceModules => 'Reference modules';

  @override
  String get portalType => 'Portal type (PortalType)';

  @override
  String get selectPortalType => 'Select Portal Type';

  @override
  String get noPortalTypesFound => 'No portal types found.';

  @override
  String get noPortalTypeSelected => 'No portal type selected.';

  @override
  String get direction => 'Direction';

  @override
  String get windDirectionLabel => 'Direction';

  @override
  String get velocityScale => 'Speed multiplier (VelocityScale)';

  @override
  String get range => 'Range';

  @override
  String get columnRange => 'Column range';

  @override
  String get eventColumnRangeBoundaryHint =>
      'The lawn’s left edge is column 0 and the right edge is column 9. The start column must be less than the end column.';

  @override
  String get eventColumnRangeExampleHint =>
      'To spawn from columns X through Y, enter X - 1 for the start column and Y for the end column.';

  @override
  String get zombieLevels => 'Zombie level';

  @override
  String get missingAssets => 'Missing assets';

  @override
  String get usage => 'Usage';

  @override
  String get types => 'Types';

  @override
  String get eventBlackHole => 'Event: Black Hole';

  @override
  String get attractionConfig => 'Attraction config';

  @override
  String get plantList => 'Plant(s) in selected tile';

  @override
  String get firstCostume => 'Wears primary costume (Avatar)';

  @override
  String get costumeOn => 'Costume: on';

  @override
  String get costumeOff => 'Costume: off';

  @override
  String get outsideLawnItems => 'Item(s) outside the lawn';

  @override
  String get zombieFromLeft => 'From left';

  @override
  String get eventMagicMirror => 'Event: Magic Mirror';

  @override
  String get eventParachuteRain => 'Event: Parachute/Bass/Jetpack/Imp rain';

  @override
  String get selectZombie => 'Select zombie';

  @override
  String get manholePipeline => 'Manhole Pipeline module';

  @override
  String get manholePipelineHelpTitle => 'Manhole Pipeline';

  @override
  String get manholePipelineHelpOverview =>
      'Defines an underground pipe system. Commonly used in Steam Ages levels. Pipes connect two sewers, allowing zombies to travel between them.';

  @override
  String get manholePipelineHelpEditing =>
      'Select a pipe group from the list above. The grid below shows the layout. Use \"Set Start\" or \"Set End\", then tap a tile to place it.';

  @override
  String get smokePollutionModuleHelpTitle => 'Steam Manhole module';

  @override
  String get smokePollutionModuleHelpOverview => 'Overview';

  @override
  String get smokePollutionModuleHelpOverviewBody =>
      'Pre-place covered sewer manholes on the lawn, commonly used in Steam Ages levels. After the specified time, toxic steam blasts the covers off and spreads across a 3×3 area centered on each manhole. Plants caught in the steam take 30 damage per second.';

  @override
  String get smokePollutionModuleHelpManholes => 'Usage';

  @override
  String get smokePollutionModuleHelpManholesBody =>
      'Select a tile, then tap \"+\" to place a sewer manhole. Each manhole can have its eruption time (StartTime) configured independently, determining how long after the level begins its cover is blasted off and toxic steam is released.';

  @override
  String get smokePollutionModuleStartTimeLabel => 'Eruption time (seconds)';

  @override
  String manholePipelineStartEndFormat(int sx, int sy, int ex, int ey) {
    return 'Start: ($sx, $sy)  End: ($ex, $ey)';
  }

  @override
  String get piratePlank => 'Pirate Plank module';

  @override
  String get weatherModule => 'Environmental Weather module';

  @override
  String get zombiePotion => 'Dark Alchemy module';

  @override
  String get zombiePotionHelpTitle => 'Zombie Potion module';

  @override
  String get eventTimeRift => 'Event: Spacetime Portal';

  @override
  String get seedRain => 'It\'s Raining Seeds module';

  @override
  String get eventFrostWind => 'Event: Freezing Wind';

  @override
  String get lastStandInitialResourceSettings => 'Initial Resource Settings';

  @override
  String get lastStandManualStartupHint =>
      'After adding the Last Stand module, the editor automatically enables Manual Startup in the Wave Manager module.';

  @override
  String get lastStandHelpTitle => 'Last Stand module';

  @override
  String get lastStandHelpOverviewBody =>
      'When this module is enabled, the level starts in a setup phase instead of immediately spawning zombies. Players can spend the starting sun to place plants, and waves begin only after they tap \"LET\'S ROCK!\".';

  @override
  String get lastStandHelpNotes => 'Notes';

  @override
  String get lastStandHelpNotesBody =>
      'Last Stand requires Manual Startup to be enabled in the Wave Manager; otherwise zombies will appear automatically. The editor manages this switch automatically when the Last Stand module is added or removed.';

  @override
  String moduleDependencyRequiredMessage(String moduleName) {
    return 'To select this module, add the \"$moduleName\" module first.';
  }

  @override
  String get cowboyMinigameSettings => 'Not OK Corral settings';

  @override
  String get cowboyMinigameBeginString => 'Prompt text';

  @override
  String get cowboyMinigameBeginStringDefault => 'Default text';

  @override
  String get cowboyMinigameBeginStringCustom =>
      'Custom text (Chinese supported)';

  @override
  String get cowboyMinigameCustomTextInput => 'Custom prompt text';

  @override
  String get cowboyMinigameShowTutorial => 'Show tutorial dialogue';

  @override
  String get cowboyMinigameBeginStringHint =>
      'Adding the Not OK Corral module automatically enables Manual Packet Spawning in the Conveyor Belt module.';

  @override
  String get cowboyMinigameHelpTitle => 'Not OK Corral module';

  @override
  String get cowboyMinigameHelpOverviewBody =>
      'A Wild West-exclusive minigame. Before each wave, the player receives a randomly selected seed packet. Planting it starts a zombie wave, and defeating every zombie completes the level.\nBefore planting each seed packet, the player can preview the types, counts, and positions of zombies in each row, allowing them to plan where to place the plant.';

  @override
  String get cowboyMinigameHelpBeginStringBody =>
      'The prompt text appears together with the zombie preview before every plant placement. The in-game default message is “Plant a plant from the conveyor belt to begin!”. The text can also be replaced with custom text.';

  @override
  String get cowboyMinigameHelpTutorialBody =>
      'When Show Tutorial Dialogue is enabled, Crazy Dave and Penny appear before the level and explain the minigame through dialogue based on the first-play conversation from Wild West - Day 4.';

  @override
  String get singleHandedTabLabel => 'All by Oneself';

  @override
  String get singleHandedBasicParameters => 'Basic Parameters';

  @override
  String get singleHandedOverviewBasicConfiguration => 'Basic Configuration';

  @override
  String get singleHandedMissileCount => 'Missiles per launch';

  @override
  String get singleHandedMissileInterval => 'Missile launch interval';

  @override
  String get singleHandedWarningTime => 'Warning time';

  @override
  String get singleHandedRocketSpeed => 'Missile speed';

  @override
  String get singleHandedZombieSpeedMultiplier => 'Zombie speed multiplier';

  @override
  String get singleHandedZombieHealthMultiplier => 'Zombie health multiplier';

  @override
  String get singleHandedSpecialMultiplierHint =>
      'Speed and health in special waves are multiplied again from these base values.';

  @override
  String get singleHandedPlantConfiguration => 'Plant Configuration';

  @override
  String get singleHandedPlantConfigurationInfo =>
      'The initial plant is the starting weapon and upgrades automatically after the required number of kills.\nThe initial plant appears in the upper-left tile. A minecart must be placed there, or the game immediately counts the level as failed.';

  @override
  String singleHandedInitialPlantSubtitle(String interval) {
    return 'Initial plant · Attack interval: $interval';
  }

  @override
  String get singleHandedAttackInterval => 'Attack interval';

  @override
  String get singleHandedAttackIntervalHint =>
      'A smaller attack interval means a faster attack speed.';

  @override
  String get singleHandedAddUpgradePlant => 'Add Upgrade Plant';

  @override
  String get singleHandedNoUpgradePlants =>
      'No upgrade plants yet. Add one to begin.';

  @override
  String get singleHandedRequiredKills => 'Required kills';

  @override
  String singleHandedEditUpgradePlant(String plantName) {
    return 'Edit: $plantName';
  }

  @override
  String singleHandedUpgradePlantSubtitle(int kills, String interval) {
    return 'Kills: $kills · Attack interval: $interval';
  }

  @override
  String get singleHandedSpecialWaves => 'Special Waves';

  @override
  String get singleHandedSpecialWavesInfo =>
      'Use these for Boss waves. Speed and health multipliers are applied on top of the base values above.';

  @override
  String get singleHandedAddSpecialWave => 'Add Special Wave';

  @override
  String get singleHandedNoSpecialWaves =>
      'No special waves yet. Add one to begin.';

  @override
  String get singleHandedSpecialWave => 'Special Wave';

  @override
  String get singleHandedWave => 'Wave';

  @override
  String get singleHandedSpeedMultiplier => 'Speed multiplier';

  @override
  String get singleHandedHealthMultiplier => 'Health multiplier';

  @override
  String get singleHandedShowHealthBar => 'Show health bar';

  @override
  String singleHandedWaveNumber(int wave) {
    return 'Wave $wave';
  }

  @override
  String get singleHandedHealthBarEnabled => 'Health bar on';

  @override
  String get singleHandedHealthBarDisabled => 'Health bar off';

  @override
  String singleHandedSpecialWaveSubtitle(String speed, String health) {
    return 'Speed x$speed · Health x$health';
  }

  @override
  String get singleHandedAddTutorial => 'Add All by Oneself Tutorial';

  @override
  String get singleHandedConfigureTutorial =>
      'Configure All by Oneself Tutorial';

  @override
  String get singleHandedTutorialWaveForStartRocket =>
      'Missiles start from wave';

  @override
  String get singleHandedTutorialHelpTitle => 'All by Oneself Tutorial';

  @override
  String get singleHandedTutorialHelpPromptsTitle => 'Tutorial Prompts';

  @override
  String get singleHandedTutorialHelpPromptsBody =>
      'After this module is added, matching tutorial prompts appear at the start of the level, when a plant is upgraded for the first time, and when the first missile warning occurs.';

  @override
  String get singleHandedTutorialHelpWaveTitle => 'Missile Starting Wave';

  @override
  String get singleHandedTutorialHelpWaveBody =>
      'You can choose the wave from which missiles begin appearing; the launch interval is counted starting from that wave. For example, with a 30-second missile interval and a starting wave of 7, the first missiles launch 30 seconds after wave 7 begins.\nNote that adding this module by itself does not make missiles fall on the configured wave. The missile starting-wave setting only takes effect together with the All by Oneself module.';

  @override
  String get hamsterballGeneration => 'Spawn Logic';

  @override
  String get hamsterballTimeBeforeFullSpawn =>
      'Time to full spawn (TimeBeforeFullSpawn; seconds)';

  @override
  String get hamsterballZombies => 'Zombies inside hamsterballs (Zombies)';

  @override
  String get hamsterballAddZombie => 'Add zombie';

  @override
  String get hamsterballEmptyZombies => 'No zombies in the list';

  @override
  String get hamsterballZombieLevel => 'Zombie level';

  @override
  String get hamsterballInitialSpeed => 'Initial speed';

  @override
  String get hamsterballBehavior => 'Behavior';

  @override
  String get hamsterballBehaviorUniform => 'Constant speed';

  @override
  String get hamsterballBehaviorSlowdown => 'Fast, then slow';

  @override
  String get hamsterballBehaviorChangeLane => 'Change lane on impact';

  @override
  String get hamsterballBehaviorDetailUniform => 'moves at a constant speed';

  @override
  String get hamsterballBehaviorDetailSlowdown =>
      'starts fast, then slows down after hitting a plant';

  @override
  String get hamsterballBehaviorDetailChangeLane =>
      'changes lane after hitting a plant';

  @override
  String hamsterballBehaviorSummary(String value) {
    return 'Behavior: $value';
  }

  @override
  String get hamsterballHasPlantfood => 'Carries Plant Food (HasPlantfood)';

  @override
  String get hamsterballHelpTitle => 'Hamsterball Event Help';

  @override
  String get hamsterballHelpOverviewTitle => 'Overview';

  @override
  String get hamsterballHelpOverviewBody =>
      'Introduced to the Chinese version in the 12th Anniversary Secret Realm, this ambush event summons rolling hamsterballs that carry zombies onto the lawn. Hamsterballs have three behavior modes, and plants run over along the way are destroyed immediately.\nHamsterballs have their own health. When broken, they release the zombies inside so they can continue advancing. Spikeweed, Spikerock, and similar plants can puncture hamsterballs and release their passengers.';

  @override
  String get hamsterballHelpRangeTitle => 'Rolling Range';

  @override
  String get hamsterballHelpRangeBody =>
      'The hamsterball rolling range is fixed from column 0 through column 8. These fields do not affect the editable content and are written silently by the editor.';

  @override
  String get hamsterballHelpGenerationTitle => 'Spawn Logic';

  @override
  String get hamsterballHelpGenerationBody =>
      'Group size controls how many hamsterballs appear in each group, while the group interval controls the delay between adjacent groups. Once the full-spawn time is reached, no extra groups are formed and all remaining hamsterballs spawn immediately.';

  @override
  String get cowboyMinigameDependencyWarningTitle => 'Required module missing';

  @override
  String get cowboyMinigameConveyorWarning =>
      'The Not OK Corral module must be used together with the Conveyor Belt module; otherwise, the level will crash.';

  @override
  String customGravestoneReplacePrompt(String gridItemName) {
    return 'Only one custom tombstone can be added to a level. Replace the level\'s existing custom tombstone with \"$gridItemName\"?';
  }

  @override
  String get customGravestoneResourceGroupPrompt =>
      'To display the Player\'s House tombstone correctly and prevent it from using the Sun texture, the lawn must include the \"Modern_Gravestone\" resource group. Open the custom lawn screen to add it? You can use the \"Modern Graveyard\" preset as a base.';

  @override
  String get openCustomStageSelection => 'Open custom lawns';

  @override
  String get customGridItemReplaceAction => 'Replace';

  @override
  String get roofFlowerPotColumns => 'Flower Pot Range';

  @override
  String get roofFlowerPotStartColumn => 'Start column (StartColumn)';

  @override
  String get roofFlowerPotEndColumn => 'End column (EndColumn)';

  @override
  String get roofFlowerPotPreview => 'Flower pot preview';

  @override
  String get roofFlowerPotLawnMismatchWarning =>
      'The current lawn is not a Roof lawn. This module may not work in-game and could cause the level to crash.';

  @override
  String get eventConveyorModify => 'Event: Conveyor Change';

  @override
  String get bowlingMinigame => 'Bulb Bowling module';

  @override
  String get eventPotionDrop => 'Event: Potion Drop';

  @override
  String get eventShellSpawn => 'Event: Seashell Spawn';

  @override
  String get eventPumpkinHouseSpawn => 'Event: Pumpkin House Spawn';

  @override
  String get duration => 'Duration';

  @override
  String get eventFairyWind => 'Event: Fairytale Breeze';

  @override
  String get eventFairyFog => 'Event: Magic Fog';

  @override
  String get eventRaidingParty => 'Event: Raiding Party';

  @override
  String get swashbucklerCount => 'Swashbuckler count';

  @override
  String get sunBomb => 'Sun Bombs module';

  @override
  String get eventSpawnGravestones => 'Event: Grid Item Spawn';

  @override
  String get eventBarrelWave => 'Event: Barrel Crisis';

  @override
  String get eventThunderWave => 'Event: Thundercloud Storm';

  @override
  String get eventGraveSpawn => 'Event: Grid Item Spawner';

  @override
  String get zombieSpawnWait => 'Zombie spawn delay';

  @override
  String get change => 'Change';

  @override
  String get autoLevel => 'Auto-Set level';

  @override
  String get apply => 'Apply';

  @override
  String get applyBatchLevel => 'Apply batch level?';

  @override
  String get starChallenges => 'Challenge Module Settings';

  @override
  String get addChallenge => 'Add challenge';

  @override
  String get unknownChallengeType => 'Unknown challenge type';

  @override
  String get protectedPlants => 'Endangered plants';

  @override
  String get addPlant => 'Add plant';

  @override
  String get protectedGridItems => 'Grid items to protect';

  @override
  String get addGridItem => 'Add grid item';

  @override
  String get scope => 'Scope';

  @override
  String get applyBatch => 'Batch apply';

  @override
  String get addPlants => 'Add plants to the list';

  @override
  String get noPlantsConfigured =>
      'No plants configured. Please add plants to the list.';

  @override
  String batchLevelFormat(int level) {
    return 'Batch level: $level';
  }

  @override
  String get protectPlants => 'Save Our Seeds';

  @override
  String get autoCount => 'Auto count';

  @override
  String get startingPlantfoodOverride =>
      'Starting Plant Food (StartingPlantfoodOverride)';

  @override
  String get iconText => 'Icon Text';

  @override
  String get iconImage => 'Icon Image';

  @override
  String get maxSunOverride => 'Max sun limit (MaxSunOverride)';

  @override
  String get maxSunHelpTitle => 'Max Sun Limit module';

  @override
  String get maxSunHelpOverview =>
      'Originally used for Penny’s Pursuit difficulty settings. This module overrides the maximum amount of sun that can be stored in a level.';

  @override
  String get moonExpertZombieLevel => 'Zombie level (ZombieLevel)';

  @override
  String get moonExpertZombieLevelTooltip =>
      'When this module is enabled, all zombie levels defined in the level are overridden by the level set here.';

  @override
  String get moonExpertHelpTitle => 'Moon Expert';

  @override
  String get moonExpertHelpOverview =>
      'This module is commonly used in Moon BaseZ Expert Mode. When enabled, every zombie in the level uses the specified level, and all plants are forced to Level 1. \nThese settings override other plant and zombie level settings, including those in the Tier Definition module. Note that this module has no effect in Creative Courtyard.';

  @override
  String get startingPlantfoodHelpTitle => 'Starting Plant Food module';

  @override
  String get startingPlantfoodHelpOverview =>
      'Originally used for Penny’s Pursuit difficulty settings. This module overrides the amount of Plant Food available at the start of a level.';

  @override
  String get starChallengeHelpTitle => 'Challenge Module';

  @override
  String get starChallengeHelpOverview =>
      'Select the challenge modules to apply to the level. Multiple challenges can be enabled at once, and the same challenge can be applied multiple times.';

  @override
  String get starChallengeHelpSuggestionTitle => 'Tips';

  @override
  String get starChallengeHelpSuggestion =>
      'Some challenges display progress using an on-screen tracker. If too many challenges are enabled, the tracker may be overlapped.';

  @override
  String get remove => 'Remove';

  @override
  String get plant => 'Plant';

  @override
  String get zombie => 'Zombie';

  @override
  String get initialZombieLayout => 'Initial zombie layout';

  @override
  String get manualInput => 'Manual input';

  @override
  String get waveManagerModule => 'Wave Manager Module';

  @override
  String get points => 'Points';

  @override
  String get row => 'Row';

  @override
  String get addType => 'Add';

  @override
  String get availableZombies => 'Available zombies';

  @override
  String get presetPlants => 'Preset plants (PresetPlantList)';

  @override
  String get whiteList => 'White list (WhiteList)';

  @override
  String get blackList => 'Black list (BlackList)';

  @override
  String get chooser => 'Choose Your Seeds (Chooser)';

  @override
  String get preset => 'Locked and Loaded (Preset)';

  @override
  String get seedBankHelp => 'Seed Bank';

  @override
  String get conveyorBeltHelp => 'Conveyor Belt';

  @override
  String get dropDelayConditions => 'Seed packets delay (DropDelayConditions)';

  @override
  String get unitSeconds => 'Unit: seconds';

  @override
  String propertyLabelSeconds(String name, String code) {
    return '$name ($code; seconds)';
  }

  @override
  String get speedConditions => 'Conveyor speed (SpeedConditions)';

  @override
  String get speedConditionsSubtitle =>
      'Default is 100; higher values increase speed';

  @override
  String get addPlantConveyor => 'Add plant';

  @override
  String get addTool => 'Add tool packet';

  @override
  String get powerTile => 'Power Tiles';

  @override
  String get powerTileGridSection => 'Current lawn';

  @override
  String get powerTileGridHelpPrimary =>
      'Tap a cell to place a tile, and tap again to remove it. Placing a tile on an occupied cell will replace the existing one. Tiles from other groups are shown dimmed to indicate they are not in the selected group.';

  @override
  String get powerTileGridHelpSecondaryMobile =>
      'Long press a cell to quickly set a group or adjust the propagation delay.';

  @override
  String get powerTileGridHelpSecondaryDesktop =>
      'Right-click a cell to quickly set a group or adjust its propagation delay.';

  @override
  String get powerTileLinkedTilesSection => 'Tile list';

  @override
  String get powerTilePropagationDelayLabel => 'Propagation delay (seconds)';

  @override
  String get powerTilePropagationDelayTooltip =>
      'The delay before power begins to propagate to other tiles (0–5 seconds). This does not include the transmission time itself. The default propagation delay is 1.5 seconds.';

  @override
  String get powerTileDialogEditCell => 'Edit cell';

  @override
  String get powerTileDialogTileGroup => 'Tile group';

  @override
  String get powerTileDialogNone => 'None';

  @override
  String get powerTileDialogPropagationDelay => 'Propagation delay (seconds)';

  @override
  String get powerTileHelpOverview =>
      'Power Tiles are divided into five groups. When a plant on a tile activates its Plant Food effect, power is propagated to other tiles in the same group, causing those plants to activate their Plant Food effect as well. The initial delay before propagation can be configured. ';

  @override
  String get powerTileHelpGridSize =>
      'Lawn size varies by level: 6 rows × 10 columns in Underwater World, and 5 rows × 9 columns in other levels.';

  @override
  String powerTileHelpQuickEdit(String interaction) {
    return 'Quick edit: $interaction';
  }

  @override
  String get eventEditorInDevelopment => 'Event editor in development';

  @override
  String get level => 'Level';

  @override
  String get missingTideModule => 'Missing Tide System module';

  @override
  String get levelHasNoTideProperties =>
      'This level has no Tide System module (TideProperties). This event may not function correctly and could cause a crash.';

  @override
  String get changePositionChangeAmount => 'Column Offset (ChangeAmount)';

  @override
  String get preview => 'Tide preview';

  @override
  String get fogPreview => 'Fog preview';

  @override
  String get water => 'Water';

  @override
  String get land => 'Land';

  @override
  String get tidePositionOrderHint =>
      'The rightmost lawn coordinate is 0 and the leftmost is 9. The Tide System module must be added last, or the level may crash.';

  @override
  String groupConfigN(int n) {
    return 'Group $n config';
  }

  @override
  String get globalParameters => 'Global parameters';

  @override
  String get timePerGrid => 'Transfer time (seconds per tile)';

  @override
  String get damagePerSecond => 'Damage per second';

  @override
  String get stageMismatch => 'Lawn Type Mismatch';

  @override
  String get currentStageNotPirate =>
      'The current lawn is not Pirate Seas. This module may not work correctly and could cause a crash.';

  @override
  String get plankPreview => 'Plank preview';

  @override
  String get plankRows => 'Plank rows';

  @override
  String get plankRowsDeepSea => 'Plank rows (Underwater World)';

  @override
  String get selectWeatherType => 'Select weather type';

  @override
  String get counts => 'Quantity Control';

  @override
  String get initialCount => 'Initial Count';

  @override
  String get maximumCount => 'Maximum Count';

  @override
  String get spawnInterval => 'Spawn Interval';

  @override
  String get minimumIntervalSeconds => 'Minimum Interval (seconds)';

  @override
  String get maximumIntervalSeconds => 'Maximum Interval (seconds)';

  @override
  String get potionTypeList => 'Potion Type List';

  @override
  String get max => 'Max count (MaxPotionCount)';

  @override
  String get ignoreGravestoneSubtitle =>
      'Enable to spawn regardless of grid items';

  @override
  String get thisPortalSpawns => 'This portal can spawn:';

  @override
  String get noItemsAddHint =>
      'No items. Add plants, zombies, or collectibles.';

  @override
  String get zombieTypeSpiderZombieName => 'Zombie type (SpiderZombieName)';

  @override
  String get noneSelected => 'None selected';

  @override
  String get totalSpiderCount => 'Total count (SpiderCount)';

  @override
  String get perBatchGroupSize => 'Per batch count (GroupSize)';

  @override
  String get fallTime => 'Fall time (ZombieFallTime; seconds)';

  @override
  String get waveStartMessageLabel => 'Red warning message (WaveStartMessage)';

  @override
  String get optionalWarningText =>
      'Optional warning text shown at the center of the screen when the drop begins; Chinese is not supported';

  @override
  String rowNShort(int n) {
    return 'Row $n';
  }

  @override
  String weightMaxFormat(int weight, int max) {
    return 'Weight: $weight, Max: $max';
  }

  @override
  String seedRainTypeLabel(String type) {
    return 'Type: $type';
  }

  @override
  String seedRainWeightLabel(int weight) {
    return 'Weight: $weight';
  }

  @override
  String seedRainMaxLabel(int max) {
    return 'Max: $max';
  }

  @override
  String get random => 'Random';

  @override
  String get noChallengesConfigured => 'No challenges configured';

  @override
  String get whiteListBlackListHint =>
      'If the whitelist is empty, no restrictions are applied.\nParallel Universe plants are ignored by the whitelist unless the corresponding module is enabled.\nThe blacklist explicitly disables plants and takes priority over the whitelist.';

  @override
  String get conveyorBeltHelpIntro =>
      'Conveyor-belt delivers seed packets randomly based on configured weights. Requires a plant pool and drop delay settings.';

  @override
  String get conveyorBeltHelpPool =>
      'Plant pool & weight: Probability = weight / total weight. Use thresholds to adjust dynamically.';

  @override
  String get conveyorBeltHelpDropDelay =>
      'Seed packets delay: Controls the interval between seed packet generation. The interval can scale based on the number of queued plants: more backlog usually results in slower generation.';

  @override
  String get conveyorBeltHelpSpeed =>
      'Conveyor speed: Controls the movement speed of cards on the conveyor belt. Default speed is 100. Speed can scale dynamically based on backlog size.';

  @override
  String get cannotAddEliteZombies => 'Cannot add elite zombies';

  @override
  String get eliteZombiesNotAllowed => 'Elite zombies are not allowed here';

  @override
  String get yetiZombiesNotAllowed => 'Yetis are not allowed here';

  @override
  String fixToAlias(String alias) {
    return 'Fix to $alias';
  }

  @override
  String editPresetZombie(String name) {
    return 'Edit preset zombie: $name';
  }

  @override
  String get missingZombossMechModule =>
      'Missing Zomboss Mech Battle module (ZombossBattleModuleProperties)';

  @override
  String get missingZombossBattleModule =>
      'Missing Non-mech Zomboss Battle module (ZombossLastStandMinigameProperties)';

  @override
  String get challengeNoConfig =>
      'This challenge doesn\'t support configuration.';

  @override
  String get maxPotionCount => 'Max Potion Count';

  @override
  String potionTypesConfigured(int count) {
    return 'Potion types: $count configured';
  }

  @override
  String pipelinesCount(int count) {
    return 'Pipelines: $count';
  }

  @override
  String windN(int n) {
    return 'Freezing Wind #$n';
  }

  @override
  String get zombieList => 'Zombie list';

  @override
  String get positionPoolSpawnPositions => 'Position pool (SpawnPositionsPool)';

  @override
  String get tapCellsSelectDeselect =>
      'Tap tiles to select/deselect spawn positions';

  @override
  String get gravestonePool => 'Item pool (GravestonePool)';

  @override
  String get current => 'Current';

  @override
  String get eliteZombiesUseDefaultLevel => 'Elite zombies use default level.';

  @override
  String get basicParameters => 'Basic parameters';

  @override
  String get zombieSpawnWaitSec => 'Spawn delay (seconds) ';

  @override
  String get gridTypes => 'Grid item types';

  @override
  String zombiesCount(int count) {
    return 'Zombies ($count)';
  }

  @override
  String stormCarriedZombiesCount(int count) {
    return 'Carried zombies ($count total)';
  }

  @override
  String get eventHelpGraveSpawnBody =>
      'Spawns zombies from specific grid item types. Commonly used for Dark Ages Necromancy ambushes.';

  @override
  String get eventHelpGraveSpawnZombieWait =>
      'Delay between wave start and zombie spawn. Zombies won\'t spawn if the next wave has already begun.';

  @override
  String get eventHelpStormOverview =>
      'Creates sandstorms or snowstorms that rapidly transport zombies to the front lines. Can spawn in groups. Freezing Storm from Memory Lane can freeze plants it passes through.';

  @override
  String get eventHelpStormColumnRange =>
      'The left boundary is column 0 and the right boundary is column 9 (or column 10 in Underwater World). Start column must be less than end column, or the storm will not spawn.';

  @override
  String get spawnParameters => 'Spawn parameters';

  @override
  String get sandstorm => 'Sandstorm';

  @override
  String get snowstorm => 'Snowstorm';

  @override
  String get excoldStorm => 'Freezing Storm';

  @override
  String get columnStart => 'Start column (ColumnStart)';

  @override
  String get columnEnd => 'End column (ColumnEnd)';

  @override
  String get groupSize => 'Zombies per group (GroupSize)';

  @override
  String get timeBetweenGroups => 'Group Interval (TimeBetweenGroups; seconds)';

  @override
  String applyBatchLevelContent(int level) {
    return 'Set all zombies in this wave to level $level (elite zombies unaffected)';
  }

  @override
  String get randomRow => 'Random row';

  @override
  String levelFormat(int level) {
    return 'Level: $level';
  }

  @override
  String get levelAccount => 'Level: follows account';

  @override
  String levelDisplay(String value) {
    return 'Level: $value';
  }

  @override
  String get eventStandardSpawnTitle => 'Basic Spawner';

  @override
  String get eventGroundSpawnTitle => 'Ground Spawner';

  @override
  String get eventHelpStandardOverview =>
      'Basic event for spawning zombies. Allows configuring the level and row for each zombie. Level 0 follows the lawn’s default level (which is Level 1 in Creative Courtyard).\nBy default, the Drop config specifies the number of zombies that carry Plant Food. After adding a plant, it will randomly assign a zombie to drop a seed packet of the selected plant.';

  @override
  String get eventHelpStandardRow =>
      'Zombies can spawn in any row from 1–5, or in a random row.';

  @override
  String get eventHelpStandardRowDeepSea =>
      'Zombies can spawn in any row from 1–6, or in a random row.';

  @override
  String get ztPerksSectionTitle => 'Zombie Perks';

  @override
  String get ztPerksSectionHint =>
      'A zombie cannot have multiple perks of the same type.';

  @override
  String get ztPerksNone => 'No perks have been added yet.';

  @override
  String get ztPerksAdd => 'Add';

  @override
  String get ztPerksAddTitle => 'Add Zombie Perks';

  @override
  String get eventHelpJitteredZtPerks =>
      'Assign Ztalemate Escape perks to individual zombies. Zombies with perks receive additional bonuses. Perks are saved in the zombie\'s Titles array. Only one perk of each type may be used on the same zombie (for example, Crystal I and Crystal II cannot both be applied).';

  @override
  String get ztPerkCategoryCrystal => 'Crystallization';

  @override
  String get ztPerkCategoryAttack => 'Strength';

  @override
  String get ztPerkCategorySpeed => 'Rapidity';

  @override
  String get ztPerkCategoryShield => 'Energy-Shield';

  @override
  String get ztPerkCategoryGravity => 'Hypergravity';

  @override
  String get ztPerkCategoryImmuneControl => 'Unyielding';

  @override
  String get ztPerkCategoryAntiControl => 'Concentration';

  @override
  String get ztPerksViewStats => 'View Stats';

  @override
  String get ztPerkPropDamageTakenInterval => 'Damage interval (seconds)';

  @override
  String get ztPerkPropDamageTotalTaken => 'Cumulative damage instances taken';

  @override
  String get ztPerkPropDamageTakenPerTime => 'Damage per hit';

  @override
  String get ztPerkPropHpReduced => 'Health reduction';

  @override
  String get ztPerkPropShieldNum => 'Shield charges';

  @override
  String get ztPerkPropReducedControlPercent => 'Control effect reduction';

  @override
  String get ztPerkPropReducedDamagePercent => 'Damage reduction';

  @override
  String get ztPerkPropImprovedDamagePercent => 'Attack power increase';

  @override
  String get ztPerkPropImprovedSpeedPercent => 'Walking speed increase';

  @override
  String ztPerkDescCrystal(
    String interval,
    String damageCount,
    String damagePerHit,
    String hpReduced,
  ) {
    return 'Grants immunity to instant-kill effects, allows damage to be taken only $damageCount times every $interval seconds, reduces each instance of damage taken to $damagePerHit, and reduces health by $hpReduced.';
  }

  @override
  String get ztPerkDescGravity => 'Immune to knockback and knockoff effects.';

  @override
  String ztPerkDescShield(String shieldNum) {
    return 'Negates the first $shieldNum instances of damage and grants immunity to instant-kill effects for the perk\'s duration.';
  }

  @override
  String ztPerkDescImmuneControl(String percent) {
    return 'Grants $percent more resistance against control effects.';
  }

  @override
  String ztPerkDescAntiControl(String percent) {
    return 'When under the influence of a control effect, damage taken is reduced by $percent.';
  }

  @override
  String ztPerkDescAttack(String percent) {
    return 'Attack power increased by $percent.';
  }

  @override
  String ztPerkDescSpeed(String percent) {
    return 'Walking speed increased by $percent.';
  }

  @override
  String get ztPerksCategoryInfoTitle => 'Perk Descriptions';

  @override
  String get ztPerkCategoryDescNumericHint =>
      'A, B, X, N, and P represent values that vary by perk tier.';

  @override
  String get ztPerkCategoryDescCrystal =>
      'Grants immunity to instant-kill effects, allows damage to be taken only N times every A seconds, reduces each instance of damage taken to B, and reduces health by X.';

  @override
  String get ztPerkCategoryDescGravity =>
      'Immune to knockback and knockoff effects.';

  @override
  String get ztPerkCategoryDescShield =>
      'Negates the first N instances of damage and grants immunity to instant-kill effects for the perk\'s duration.';

  @override
  String get ztPerkCategoryDescImmuneControl =>
      'Grants P% more resistance against control effects.';

  @override
  String get ztPerkCategoryDescAntiControl =>
      'When under the influence of a control effect, damage taken is reduced by P%.';

  @override
  String get ztPerkCategoryDescAttack => 'Attack power increased by P%.';

  @override
  String get ztPerkCategoryDescSpeed => 'Walking speed increased by P%.';

  @override
  String get warningStageSwitchedTo5Rows =>
      'The lawn only has 5 rows, but some data references row 6. These objects may not appear correctly in-game.';

  @override
  String warningObjectsOutsideArea(int rows, int cols) {
    return 'Some objects are placed outside the lawn ($rows rows × $cols cols).';
  }

  @override
  String get izombieModeTitle => 'I, Zombie Mode';

  @override
  String get izombieModeSubtitle =>
      'Switches to zombie placement gameplay. Seed selection will be locked.';

  @override
  String get reverseZombieFactionTitle => 'Invert Zombie Faction';

  @override
  String get reverseZombieFactionSubtitle =>
      'When enabled, placed zombies belong to the plant faction and can be used in \"Zombie Wars\" (ZvZ) gameplay.';

  @override
  String get initialWeight => 'Initial weight';

  @override
  String get plantLevelLabel => 'Plant level';

  @override
  String get missingIntroModule => 'Missing Intro Module';

  @override
  String get missingIntroModuleHint =>
      'Level is missing Zomboss Mech Intro module (ZombossBattleIntroProperties). The level may not function correctly. Please add the module and reselect the ZombossMech.';

  @override
  String get zombossMechType => 'Zomboss Mech type';

  @override
  String get zombossMechSelection => 'Zomboss mech selection';

  @override
  String get zombossMechBaseHint =>
      'Zombots built and piloted by Dr. Zomboss himself, commonly encountered as the ultimate challenge of a world or game mode. Changing the base mech will also change the available variations below.';

  @override
  String get zombossMechSelectBaseTitle => 'Select base Zomboss mech';

  @override
  String get zombossMechUsedProperties => 'Used properties';

  @override
  String get zombossMechVariationLabel => 'Variation';

  @override
  String get zombossMechVariationHint =>
      'The specific mech type used in the level (ZombossMechType). Available options depend on the base mech selected above; changing the type will also update the mech\'s number of phases and spawn position accordingly.';

  @override
  String get zombossBattleSelection => 'Zomboss selection';

  @override
  String get zombossBattleSelectBaseTitle => 'Select base Zomboss';

  @override
  String get zombossBattleLeaveUndergroundTitle => 'Switch base Zomboss';

  @override
  String zombossBattleLeaveUndergroundBody(String zombossName) {
    return 'You are about to switch from $zombossName to another base Zomboss. The Finisher Countdown module will be removed from the level automatically. Remove the Underground Palace Pathways module as well?';
  }

  @override
  String get zombossBattleKeepTunnelDefend => 'Keep pathways';

  @override
  String get zombossBattleRemoveTunnelDefend => 'Remove pathways too';

  @override
  String get zombossBattleBaseHint =>
      'Zombie bosses who hold sway in a world or realm that Dr. Zomboss has yet to visit, with phase and spawn mechanics similar to those of Zomboss mechs. Changing the base Zomboss will also change its corresponding resource group.';

  @override
  String get zombossBattleVariationLabel => 'Variation';

  @override
  String get zombossBattleVariationHint =>
      'The specific Zomboss type used in the level (ZombossTypeName). Available options depend on the base Zomboss selected above.';

  @override
  String get zombossBattleStartingSunLabel => 'Starting Sun (StartingSun)';

  @override
  String get zombossBattleStartingSunHint =>
      'The amount of sun available when entering the level.';

  @override
  String get zombossBattleStartingPlantfoodLabel =>
      'Starting Plant Food (StartingPlantfood)';

  @override
  String get zombossBattleStartingPlantfoodHint =>
      'The amount of Plant Food available when entering the level.';

  @override
  String get zombossBattleInitialGridColLabel =>
      'Starting Column (ZombossInitialGridCol)';

  @override
  String get zombossBattleInitialGridColHint =>
      'Sets which column the Zomboss initially appears in.';

  @override
  String get zombossBattleInitialGridRowLabel =>
      'Starting Row (ZombossInitialGridRow)';

  @override
  String get zombossBattleInitialGridRowHint =>
      'Sets which row the Zomboss initially appears in.';

  @override
  String get zombossBattleSkipPlantingLabel =>
      'Skip Setup Phase (SkipPlanting)';

  @override
  String get zombossBattleSkipPlantingHint =>
      'When enabled, the preparation phase used in Last Stand will not appear before the Zomboss battle.';

  @override
  String get parameters => 'Parameters';

  @override
  String get reservedColumnCount => 'Reserved Columns (ReservedColumnCount)';

  @override
  String get reservedColumnCountHint =>
      'Number of columns reserved on the right where planting is disabled. Typically 2 or more columns are reserved.';

  @override
  String get reservedColumnPreview => 'Reserved column preview';

  @override
  String get protectedList => 'Protected Targets';

  @override
  String get plantLevelsFollowGlobal =>
      'Plants in this module follow their respective levels from the player’s account. You can standardize their levels using the Tier Definition module.';

  @override
  String get protectPlantsOverview =>
      'Defines plants that must be protected. The level fails if any of them are eaten or destroyed.';

  @override
  String get protectPlantsAutoCount =>
      'The required count updates automatically based on the number of plants added.';

  @override
  String positionsCount(int count) {
    return 'Positions: $count';
  }

  @override
  String totalItemsCount(int count) {
    return 'Total items to be spawned: $count';
  }

  @override
  String get itemCountExceedsPositionsWarning =>
      'Warning: Total grid items exceed available positions. Some grid items will not spawn!';

  @override
  String get gravestoneBlockedInfo =>
      'Grid items like tombstones cannot spawn if blocked by plants. Use other methods to force spawn them, such as the Potion Drop event.';

  @override
  String get enterConditionValue => 'Enter condition value';

  @override
  String get customInputHint => 'Custom input must be accurate';

  @override
  String get presetConditions => 'Preset conditions';

  @override
  String get selectFromPresetHint => 'Select from preset condition list';

  @override
  String get potionTypes => 'Potion Types (PotionTypes)';

  @override
  String get noPotionTypes =>
      'No potion types configured. Add a potion type to continue.';

  @override
  String get conveyorCardPool => 'Conveyor Pool';

  @override
  String get maxLimits => 'Max limits';

  @override
  String get maxCountThreshold => 'Max count threshold';

  @override
  String get weightFactor => 'Post-threshold weight multiplier';

  @override
  String get minLimits => 'Min limits';

  @override
  String get minCountThreshold => 'Min count threshold';

  @override
  String get followAccountLevel =>
      'Level 0 plants use their corresponding tier from the player\'s account.';

  @override
  String get enablePointSpawning => 'Enable Point-Based Spawning';

  @override
  String get pointSpawningEnabledDesc =>
      'Enabled (uses points to spawn extra zombies)';

  @override
  String get pointSpawningDisabledDesc =>
      'Disabled (event-based spawning only)';

  @override
  String get pointSettings => 'Point settings';

  @override
  String get startingWave => 'Starting wave';

  @override
  String get startingPoints => 'Starting points';

  @override
  String get pointIncrement => 'Point increase per wave';

  @override
  String get zombiePool => 'Zombie pool';

  @override
  String get protectGridItems => 'Event: Save Our Items';

  @override
  String get waveManagerHelpOverview =>
      'Wave Manager defines the wave event container. Wave editing is only available after adding this module.';

  @override
  String get waveManagerHelpPoints =>
      'Point-based spawning generates additional zombies during valid waves based on point cost.\nNormal waves have a cap of 60,000 points, while flag waves use a 2.5× multiplier.\nWhen points are positive, zombies are selected from the zombie pool. Expected spawn values for each zombie can be viewed in the wave event container.\nWhen points are negative, zombies with equivalent point value are removed from natural spawns.\nDo not include Elite Zombies, Yetis, or custom zombies in the point-based spawning pool.';

  @override
  String get pointsSection => 'Points';

  @override
  String get globalPlantLevels => 'Global plant levels';

  @override
  String get globalPlantLevelsOverview =>
      'Defines plant levels globally within the level. This setting overrides seed packet levels and allows individual customization for specific plants.';

  @override
  String get globalPlantLevelsScope =>
      'Applies to all instances of the plant used in the level, including endangered plants and packet drops.';

  @override
  String get noWaveManagerPropsFound =>
      'Wave Manager module (WaveManagerProperties) not found.';

  @override
  String get itemsSortedByRow => 'Item(s) in selected tile';

  @override
  String get stormEvent => 'Storm Raid';

  @override
  String get zombieLevelsBody =>
      'Zombie level and row cannot be set independently within storms. Manually editing zombie levels has no effect; zombie levels follow the lawn’s level sequence by default.';

  @override
  String get batchLevel => 'Batch level';

  @override
  String get start => 'Start';

  @override
  String get end => 'End';

  @override
  String get backgroundMusicLevelJam =>
      'Neon Mixtape Tour music switch (LevelJam)';

  @override
  String get onlyAppliesRockEra =>
      'Switches the background music when triggered. Only applies to Neon Mixtape Tour levels.';

  @override
  String get appliesToAllNonElite =>
      'Sets all zombies in this wave to the specified level (elite zombies are unaffected and retain their default level).';

  @override
  String get dropConfigPlants => 'Drop configuration (seed packet)';

  @override
  String get dropConfigPlantFood => 'Drop configuration (Plant Food)';

  @override
  String get waveDropConfigTitle => 'Drop configuration';

  @override
  String get waveDropPlantSelectionLabel =>
      'Specified seed packet drops (SpawnPlantName)';

  @override
  String get waveDropTotalLabel => 'Total drops (AdditionalPlantfood)';

  @override
  String get waveDropAddZombiesFirst =>
      'Add zombies to this wave before configuring drops.';

  @override
  String get waveDropIncreaseTotalBeforePlants =>
      'Increase total drops before adding seed packets.';

  @override
  String waveDropPlantFoodOnlyCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Plant Foods',
      one: '1 Plant Food',
    );
    return '$_temp0';
  }

  @override
  String waveDropPlantsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count seed packets',
      one: '1 seed packet',
    );
    return '$_temp0';
  }

  @override
  String get description => 'Level description';

  @override
  String get descriptiveName => 'Descriptive Name';

  @override
  String get count => 'Count';

  @override
  String get targetDistance => 'Flowerbed Distance (TargetDistance)';

  @override
  String get starChallengeTargetDistanceHint =>
      'The value is the number of columns from the left edge; larger values are farther from the house. Decimals are supported.';

  @override
  String get targetSun => 'Target Sun';

  @override
  String get maximumSun => 'Sun Cap (MaximumSun)';

  @override
  String get holdoutSeconds => 'Duration (HoldoutSeconds)';

  @override
  String get zombiesToKill => 'Zombies to Kill (ZombiesToKill)';

  @override
  String get timeSeconds => 'Time Limit (seconds)';

  @override
  String get speedModifier => 'Speed Multiplier (SpeedModifier)';

  @override
  String get starChallengeSpeedModifierHint =>
      'Entering 0.5 increases zombie movement speed by 50%.';

  @override
  String get sunModifier => 'Sun Reduction (SunModifier)';

  @override
  String get starChallengeSunModifierHint =>
      'Entering 0.2 reduces Sun gained by 20%.';

  @override
  String get starChallengeChineseUnsupportedHint =>
      'Chinese characters are not supported.';

  @override
  String get maximumPlantsLost => 'Maximum Plants Lost';

  @override
  String get maximumPlants => 'Maximum Plants on the Lawn';

  @override
  String get targetScore => 'Target Score';

  @override
  String get plantBombRadius => 'Plant explosion radius';

  @override
  String get plantType => 'Plant Type';

  @override
  String get gridX => 'Grid X';

  @override
  String get gridY => 'Grid Y';

  @override
  String get noCardsYetAddPlants =>
      'No seed packets yet. Add plants or tool packets.';

  @override
  String get mustProtectCountAll => 'Required to Protect (0 = protect all)';

  @override
  String get gridItemType => 'Grid item type';

  @override
  String get zombieBombRadius => 'Zombie explosion radius';

  @override
  String get plantDamage => 'Damage to plants';

  @override
  String get zombieDamage => 'Damage to zombies';

  @override
  String get initialPotionCount => 'Initial count (InitialPotionCount)';

  @override
  String get operationTimePerGrid => 'Transfer time (seconds per tile)';

  @override
  String get levelLabel => 'Level: ';

  @override
  String get fairyFogType => 'Fog level (FogType)';

  @override
  String fairyFogLevel(int level) {
    return 'Level $level';
  }

  @override
  String get fairyFogMovingTime => 'Moving time (MovingTime; seconds)';

  @override
  String get fairyFogRangeX => 'Starting column (mX; 0-based)';

  @override
  String get fairyFogRangeY => 'Starting row (mY; 0-based)';

  @override
  String get fairyFogRangeWidth => 'Width (mWidth; tiles)';

  @override
  String get fairyFogRangeHeight => 'Height (mHeight; tiles)';

  @override
  String get fairyWindParameters => 'Wind parameters';

  @override
  String get fairyWindDuration => 'Duration (Duration; seconds)';

  @override
  String get modifyConveyorMissingModule =>
      'Conveyor Belt module wasn\'t detected in the level, so this event may not take effect.';

  @override
  String get renaiWavePreviewEmpty =>
      'No statue or marble mound data is configured in the module';

  @override
  String get decompressZlib => 'Decompress ZLib';

  @override
  String get compressWithZlib => 'Compress with ZLib';

  @override
  String get seedRainUnknownItem => 'Unknown item';

  @override
  String get mistParameters => 'Fog parameters';

  @override
  String get increasePerSun => 'Increase per sun (SunCountdownIncreasePerSun)';

  @override
  String get inflationParams => 'Inflation parameters';

  @override
  String get baseCostIncreaseLabel =>
      'Cost increase per planting (BaseCostIncreased)';

  @override
  String get maxIncreaseCountLabel => 'Max Increase Count (MaxIncreasedCount)';

  @override
  String get inflationMaxIncreaseCountWarning =>
      'Due to an issue with the module itself, changing the maximum increase count currently has no effect. The game only reads the default value of 10.';

  @override
  String get inflationHelpTitle => 'Inflation module';

  @override
  String get inflationHelpOverview =>
      'Each time a plant is planted, its sun cost increases, similar to how upgrade plants work in Survival: Endless in the original game.';

  @override
  String get inflationHelpParametersTitle => 'Parameter description';

  @override
  String get inflationHelpParametersBody =>
      'Configure the amount of sun cost added after each planting and the maximum number of price increases.';

  @override
  String get selectGroup => 'Select group';

  @override
  String get sunBombHelpOverview => 'Overview';

  @override
  String get sunBombHelpBody =>
      'Required for the Far Future brain buster \"Sun Bomb\". When enabled, falling sun will turn into purple, detonatable Sun Bombs. Damage dealt by Sun Bombs can be configured separately for different factions.';

  @override
  String get bombProperties => 'Powder Keg module';

  @override
  String get bombPropertiesHelpBody =>
      'Required for configuring the Kongfu World brain buster \"Powder Keg\". When enabled, Powder Kegs will appear at lawn mower positions and spawn a fuse that can be ignited. If a flame travels along the fuse and reaches the Powder Keg, it will explode, destroying plants within a 3×3 area centered on itself.';

  @override
  String get bombPropertiesHelpFuse => 'Fuse lengths';

  @override
  String get bombPropertiesHelpFuseBody =>
      'Fuse length is configured per row, starting from row 1 (top to bottom). Each row corresponds to a value in the array, representing how many tiles the fuse extends to the right. Standard lawns have 5 rows, while Underwater World lawns have 6. The array length will automatically adjust based on the current lawn when opening this panel.';

  @override
  String get bombPropertiesFlameSpeed => 'Fuse Burn Speed (FlameSpeed)';

  @override
  String get bombPropertiesFuseLengths => 'Fuse Lengths (FuseLengths)';

  @override
  String get bombPropertiesFuseLengthsHint =>
      'Set how many tiles the fuse extends to the right for each row (one value per row)';

  @override
  String get damage => 'Explosion Damage';

  @override
  String get explosionRadius => 'Explosion Radius';

  @override
  String get plantRadius => 'Plant explosion radius';

  @override
  String get zombieRadius => 'Zombie explosion radius';

  @override
  String get radiusPixelsHint =>
      'Explosion radius is measured in pixels (1 tile ≈ 60 pixels).';

  @override
  String get enterMaxSunHint => 'Enter the level’s maximum sun cap (e.g. 9900)';

  @override
  String get enterStartingPlantfoodHint =>
      'Enter the starting Plant Food amount (0 or more)';

  @override
  String get threshold => 'Threshold';

  @override
  String get delay => 'Delay';

  @override
  String get seedBankLetsPlayersChoose =>
      'Seed Bank lets players choose from available plants. In Creative Courtyard, it supports setting a global tier and enables access to all plants.';

  @override
  String get iZombieModePresetHint =>
      'When I, Zombie Mode is enabled, available zombies must be preset. Selection mode will be forced to Preset. If both plant and zombie seed packets are used, they must be locked to the same level.';

  @override
  String get invalidIdsHint =>
      'Invalid IDs will appear as empty slots in the Seed Bank. In I, Zombie Mode, plant IDs are invalid, and vice versa. This can be used to create two Seed Banks in one level and combine both modes. Make sure the Zombie Seed Bank is placed first.';

  @override
  String get seedBankWhiteAndBlacklistTitle => 'Whitelist and blacklist';

  @override
  String get seedBankIZombieHelpTitle => 'I, Zombie mode';

  @override
  String get seedBankSlotOccupancyTitle => 'Slot occupancy';

  @override
  String get seedBankAdvancedGameplayTitle => 'Advanced gameplay';

  @override
  String get seedBankAdvancedGameplayBody =>
      'When selection mode is Preset, placing the Seed Bank before the Conveyor Belt makes conveyor plants cost sun, while placing it after allows preset plants to be planted without sun cost.';

  @override
  String get basicRules => 'Basic Rules';

  @override
  String get selectionMethod => 'Selection Mode';

  @override
  String get emptyList => 'The list is empty';

  @override
  String get plantsAvailableAtStart => 'Plants pre-selected at the start';

  @override
  String get presetPlantListReorderHint =>
      'Long press the ⋮⋮ handle and drag to reorder';

  @override
  String get presetPlantListReorderHintDesktop =>
      'Drag the ⋮⋮ handle to reorder';

  @override
  String get whiteListDescription =>
      'Only these plants can be selected (no restriction if empty)';

  @override
  String get blackListDescription => 'These plants cannot be selected';

  @override
  String get availableZombiesDescription =>
      'Zombies available for I, Zombie Mode';

  @override
  String get izombieCardSlotsHint =>
      'Only certain zombies have dedicate seed packets and sun costs in I, Zombie (IZ) Mode. These zombies can be found under the \"Other\" category in the zombie selection screen.';

  @override
  String get seedBankPresetModeHint =>
      'When Preset mode is enabled, the level starts immediately regardless of how many plants are pre-selected.';

  @override
  String get seedBankPlantLevelLabel => 'Plant level (0-5)';

  @override
  String get seedBankSlotCountLabel => 'Slot count (0-9)';

  @override
  String get seedBankCourtyardSlotsHint =>
      'In Creative Courtyard, changes to the number of seed slots have no effect. Chooser mode is fixed at 8 slots.';

  @override
  String get seedBankAddGridItemsTitle => 'Add Grid Items';

  @override
  String get seedBankAddGridItemsSubtitle =>
      'Add plantable grid items to the preset plant list. Duplicates are allowed.';

  @override
  String seedBankGridItemCount(int count) {
    return 'The preset list already contains $count';
  }

  @override
  String get seedBankGridItemsPresetOnlySwitchWarning =>
      'The \"Add Grid Items\" feature only works in Preset mode. Switching to Chooser mode will turn it off. Continue switching?';

  @override
  String get starChallengeSelectConditions => 'Select conditions';

  @override
  String get starChallengeEditConditions => 'Edit conditions';

  @override
  String get selectToolCard => 'Select tool packets';

  @override
  String get searchGridItems => 'Search grid items';

  @override
  String get searchStatues => 'Search renaissance statues or marble mounds';

  @override
  String get noItems => 'No items';

  @override
  String get addedToFavorites => 'Added to favorites';

  @override
  String get removedFromFavorites => 'Removed from favorites';

  @override
  String selectedCountTapToSearch(int count) {
    return 'Selected $count, tap to search';
  }

  @override
  String get noFavoritesLongPress => 'No favorites. Long-press to favorite.';

  @override
  String get gridItemCategoryAll => 'All Items';

  @override
  String get gridItemCategoryScene => 'Scenery';

  @override
  String get gridItemCategoryTrap => 'Interactive Traps';

  @override
  String get gridItemCategorySpawnableObjects => 'Spawnable Objects';

  @override
  String get customLocalParams => 'Custom local parameters';

  @override
  String get currentModeLocal => 'Current: local (@CurrentLevel)';

  @override
  String get currentModeSystem => 'Current: system default (@LevelModules)';

  @override
  String get paramAdjust => 'Parameter adjustment';

  @override
  String get firstDropDelay =>
      'Initial drop delay (InitialSunDropDelay; seconds)';

  @override
  String get initialDropInterval =>
      'Initial drop interval (SunCountdownBase; seconds)';

  @override
  String get maxDropInterval => 'Max drop interval (SunCountdownMax; seconds)';

  @override
  String get intervalFloatRange =>
      'Interval variation range (SunCountdownRange; seconds)';

  @override
  String get sunDropperHelpTitle => 'Sun Dropper module';

  @override
  String get sunDropperHelpIntro =>
      'Configures falling sun in a level. For night lawns, this module is usually not needed.';

  @override
  String get sunDropperHelpParams => 'Parameter configuration';

  @override
  String get sunDropperHelpParamsBody =>
      'By default, this module uses the game’s built-in values. You can enable custom settings to edit detailed parameters.';

  @override
  String get noZombossMechFound => 'No Zomboss Mech found';

  @override
  String get noZombossBattleFound => 'No Zomboss definitions found';

  @override
  String get searchChallengeNameOrCode =>
      'Search by challenge name or codename';

  @override
  String get deleteChallengeTitle => 'Delete challenge?';

  @override
  String deleteChallengeConfirmLocal(String name) {
    return 'Remove \"$name\"? This will permanently delete the local challenge data.';
  }

  @override
  String deleteChallengeConfirmRef(String name) {
    return 'Remove reference to \"$name\"? The challenge will remain in LevelModules.';
  }

  @override
  String get missingModulesRecommended =>
      'The level might not function correctly. Recommended to add the following modules:';

  @override
  String get recommendedTunnelDefendTitle =>
      'Underground Palace Pathways module strongly recommended';

  @override
  String get recommendedTunnelDefendBody =>
      'The tiles in Underground Palace Secret Realm lawns must be placed through the \"Underground Palace Pathways\" module. If this module is not added, the lawns may appear overly empty in-game.';

  @override
  String get recommendedExpeditionTilesTitle =>
      'Works with the \"Expedition Tiles\" module';

  @override
  String get recommendedExpeditionTilesBody =>
      'Add the \"Expedition Tiles\" module to work around the lawn\'s missing tiles and create an experience that more closely matches Expedition Gate.';

  @override
  String get selectedPosition => 'Selected position';

  @override
  String get addItem => 'Add item';

  @override
  String get itemListRowFirst => 'Item(s) in selected tile';

  @override
  String get railcartCowboy => 'Wild West mine cart';

  @override
  String get railcartFuture => 'Far Future mine cart';

  @override
  String get railcartEgypt => 'Ancient Egypt mine cart';

  @override
  String get railcartPirate => 'Pirate Seas mine cart';

  @override
  String get railcartWorldcup => 'Ice Hockey mine cart';

  @override
  String get clearUnusedTitle => 'Clear unused objects?';

  @override
  String get clearUnusedMessage =>
      'This will permanently delete all unused objects from the level file, including custom zombies, their properties, and any other unreferenced data. This action cannot be undone. Continue?';

  @override
  String get clearUnusedNone => 'No unused objects found.';

  @override
  String clearUnusedDone(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Removed $count unused objects.',
      one: 'Removed 1 unused object.',
    );
    return '$_temp0';
  }

  @override
  String get lawnMowerTitle => 'Lawn Mowers';

  @override
  String get lawnMowerNotes => 'Notes';

  @override
  String get lawnMowerHelpOverview =>
      'Controls the appearance of lawn mowers in a level. This module does not work when the Creative Courtyard module is enabled.';

  @override
  String get lawnMowerHelpNotes =>
      'This module is typically referenced from LevelModules and does not require custom configuration within the level.';

  @override
  String get lawnMowerSelectType => 'Select mower type';

  @override
  String get zombieRushTitle => 'Level Timer module';

  @override
  String get zombieRushHelpOverview =>
      'A countdown module from Zombie Elimination Initiative. The level ends and results are calculated when the timer reaches zero.';

  @override
  String get zombieRushHelpNotes => 'Notes';

  @override
  String get zombieRushHelpIncompat =>
      'Penny’s Pursuit timer module is incompatible with Creative Courtyard and may cause crashes. It is recommended to use the Zombie Elimination Initiative timer module instead.';

  @override
  String get zombieRushTimeSettings => 'Time Settings';

  @override
  String get levelCountdown => 'Level countdown (seconds)';

  @override
  String get tunnelDefendTitle => 'Underground Palace Pathway Settings';

  @override
  String get tunnelDefendHelpOverview =>
      'Use this module to add pathways from the Underground Palace secret realm to the level. Certain zombies have their interactions with plants affected by pathways.';

  @override
  String get tunnelDefendHelpUsage => 'Usage';

  @override
  String get tunnelDefendHelpUsageBody =>
      'Select a pathway component from the list below, then click on the grid above to place it. Tapping an existing component of the same type removes it, while selecting a different component will replace it directly.';

  @override
  String get tunnelDefendSelectComponent => 'Select component';

  @override
  String get tunnelDefendPlacedCount => 'Placed components';

  @override
  String get tunnelDefendClearAll => 'Clear all';

  @override
  String get tunnelDefendClearConfirmTitle => 'Clear all pathway components?';

  @override
  String get tunnelDefendClearConfirmMessage =>
      'This will remove all placed pathway components from the lawn. This action cannot be undone.';

  @override
  String get tunnelDefendPathOutsideLawn =>
      'Pathway components outside the lawn: ';

  @override
  String get tunnelDefendDeleteOutside =>
      'Remove pathway components outside the lawn';

  @override
  String get tunnelDefendDeleteOutsideConfirmTitle =>
      'Remove pathway components outside the lawn?';

  @override
  String get tunnelDefendDeleteOutsideConfirmMessage =>
      'This will remove all pathway components outside the 5×9 lawn. This action cannot be undone.';

  @override
  String get tunnelDefendTileStylePreset => 'Tile style preset';

  @override
  String get tunnelDefendTileStylePart1 =>
      'Underground Palace Ruins (Chapter 1)';

  @override
  String get tunnelDefendTileStylePart2 =>
      'Underground Palace Spirit Supression (Chapter 2)';

  @override
  String get tunnelDefendSequenceInterval =>
      'Pathway Generation Interval (TunnelSequenceInterval, seconds)';

  @override
  String get tunnelDefendHelpSequenceInterval => 'Pathway Generation Interval';

  @override
  String get tunnelDefendHelpSequenceIntervalBody =>
      'The interval between the appearance of each pathway components when Lord of the Underground Palace generates a pathway. Lower values make pathway components appear more quickly.';

  @override
  String get tunnelDefendHelpSodPromptBody =>
      'The \"Sod Planting Prompt\" controls whether a \"Plant a Sod first\" prompt appears when planting on restricted tiles. Underground Palace Pathways module enables this prompt by default.';

  @override
  String get sodPlantingPromptTitle => 'Sod Planting Prompt';

  @override
  String get expeditionTilesSodPromptBody =>
      'Whether to show a Sod requirement prompt when planting. Disabled by default.';

  @override
  String get tunnelDefendSodPromptBody =>
      'Whether to show a Sod requirement prompt when planting. Enabled by default.';

  @override
  String get expeditionTilesPresetLayout => 'Preset Layout';

  @override
  String get expeditionTilesPresetFloor1 => 'Expedition Gate – Floor 1';

  @override
  String get expeditionTilesPresetFloor2 => 'Expedition Gate – Floor 2';

  @override
  String get expeditionTilesPresetFloor3 => 'Expedition Gate – Floor 3';

  @override
  String get customLayout => 'Custom layout';

  @override
  String get switchAction => 'Switch';

  @override
  String get expeditionTilesSwitchPresetTitle => 'Switch preset layout';

  @override
  String get expeditionTilesSwitchPresetMessage =>
      'Switch to the preset layout? This will remove all placed non-plantable tiles from the lawn and cannot be undone.';

  @override
  String expeditionTilesSwitchPresetBetweenMessage(String from, String to) {
    return 'Switch from \"$from\" to \"$to\"? ';
  }

  @override
  String get expeditionTilesUnderwaterMismatchWarning =>
      'The current lawn uses an Underwater World appearance, which is incompatible with the Expedition Tiles module and will cause the level to crash.';

  @override
  String get expeditionTilesBlockedCount => 'Non-plantable tiles';

  @override
  String get expeditionTilesClearConfirmTitle =>
      'Clear all non-plantable tiles?';

  @override
  String get expeditionTilesClearConfirmMessage =>
      'This will remove all placed non-plantable tiles from the lawn. This action cannot be undone.';

  @override
  String get expeditionTilesHelpTitle => 'Expedition Tiles module';

  @override
  String get expeditionTilesHelpOverview =>
      'The Expedition Tiles module configures non-plantable areas on the Expedition Gate lawn. It uses the same tile data structure as Underground Palace Pathways and displays restricted areas with Expedition-specific tile art. Planting Sod on a non-plantable tile can restore that tile\'s planting function.';

  @override
  String get expeditionTilesHelpEditing => 'Tile Editing';

  @override
  String get expeditionTilesHelpEditingBody =>
      'Tap any tile on the lawn to add or remove a non-plantable tile. Non-plantable tiles cover the original floor and cannot be planted on in-game. Swirly tiles and blank tiles are both plantable areas; the Swirly tiles here only recreate the initial lawn layout used by this module.';

  @override
  String get expeditionTilesHelpPresets => 'Preset Layouts';

  @override
  String get expeditionTilesHelpPresetsBody =>
      'The editor includes the three official Expedition Gate layouts for Floor 1, Floor 2, and Floor 3. Switching presets replaces all placed non-plantable tiles and cannot be undone; after applying a preset, you can still adjust tiles manually.';

  @override
  String get expeditionTilesHelpSodPrompt => 'Planting Prompt';

  @override
  String get expeditionTilesHelpSodPromptBody =>
      'The \"Sod Planting Prompt\" controls whether a \"Plant a Sod first\" prompt appears when planting on restricted tiles. Expedition Tiles module disables this prompt by default.';

  @override
  String get expeditionTilesHelpNotesBody =>
      'Expedition Tiles is intended for 5-row lawns such as Expedition Gate. Do not use it with 6-row Underwater World appearances such as 20,000 Leagues Under the Sea or Atlantis, or the level will crash.';

  @override
  String get tunnelExpeditionCompatibilityWarningTitle =>
      'Module compatibility warning';

  @override
  String get tunnelExpeditionCompatibilityWarningBody =>
      'Using the \"Underground Palace Pathways\" module together with the \"Expedition Tiles\" module can cause tile textures to overlap and may affect the level\'s overall appearance. If you must use both, be extremely careful.';

  @override
  String get moduleTitle_ZombossFinalStageTimeLimitedChallengeProperties =>
      'Finisher Countdown';

  @override
  String get moduleDesc_ZombossFinalStageTimeLimitedChallengeProperties =>
      'Required module for the Lord of the Underground Palace Zomboss battle';

  @override
  String get finalStageTimeLimitedChallengeHelpTitle =>
      'Finisher Countdown module';

  @override
  String get finalStageTimeLimitedChallengeHelpIntro =>
      'Adds a timed defeat challenge to the final stage of the Lord of the Underground Palace Zomboss battle. If its remaining health is not depleted within the time limit, Lord of the Underground Palace will swing its sword.';

  @override
  String get finalStageTimeLimitedChallengeHelpParams => 'Parameters';

  @override
  String get finalStageTimeLimitedChallengeHelpParamsBody =>
      'For now, this module only needs to be referenced directly in LevelModules. The actual countdown duration is determined by ZombossFinalStageTimeLimited in the Zomboss properties rather than the ZombossTimeLimit field in this module, so customizing this module has no practical effect.';

  @override
  String get finalStageTimeLimitedChallengeTimeLimit =>
      'Sword Swing Countdown (ZombossTimeLimit, seconds)';

  @override
  String get moduleTitle_LawnMowerProperties => 'Lawn Mowers';

  @override
  String get moduleDesc_LawnMowerProperties =>
      'Sets mower styles (doesn\'t work in Creative Courtyard)';

  @override
  String get moduleTitle_TunnelDefendModuleProperties =>
      'Underground Palace Pathways';

  @override
  String get moduleDesc_TunnelDefendModuleProperties =>
      'Configures pathways and tile styles for Underground Palace secret realm levels';

  @override
  String get moduleTitle_SouDaCheTunnelDefendDefault => 'Expedition Tiles';

  @override
  String get moduleDesc_SouDaCheTunnelDefendDefault =>
      'Configures non-plantable areas on the Expedition Gate lawn';

  @override
  String get moduleTitle_WitchModuleProperties => 'Fright Witch';

  @override
  String get moduleDesc_WitchModuleProperties =>
      'Fright Witches periodically sweep across the lawn, scattering magical potions';

  @override
  String get moduleTitle_InitialGridItemGulliverTunnelProperties =>
      'Gulliver Tunnels';

  @override
  String get moduleDesc_InitialGridItemGulliverTunnelProperties =>
      'Places pre-set Gulliver tunnels on the lawn';

  @override
  String get witchModuleHelpTitle => 'Fright Witch module';

  @override
  String get witchModuleHelpIntro =>
      'Enabling this module adds 2 Fright Witches to the level. After the level begins, Fright Witch will periodically enter from either the left or right side of the lawn, randomly choosing a lane and flying across it on a magic broomstick while scattering magical potions along the way. After a period of time, she returns and repeats the process.\nDifferent potions have different effects: Orange Explosion Potions deal percentage-based damage in a 3×3 area around the landing point; Green Transmutation Potions transform single-tile plants into a sheep, frog, or chicken, and may also turn them into Tall-nut seed packets; Blue Necromancy Potions continuously revive zombies that die within a 3×3 area around the landing point for a duration; Red Berserk Potions grant zombies increased health and movement speed.\nFright Witch cannot be targeted by plants. Planting a Tall-nut in her path will knock her off the lawn; if the Tall-nut has previously used Plant Food, it will shatter the witch permanently, preventing her from returning.';

  @override
  String get witchModuleHelpParams => 'Parameter configuration';

  @override
  String get witchModuleHelpParamsBody =>
      'By default, this module uses the values defined in the game files. Alternatively, you may enable custom local parameters and modify the interval between witch appearances.';

  @override
  String get witchModuleSpawnInterval =>
      'Witch spawn interval (WitchSpawnInterval, seconds)';

  @override
  String get gulliverTunnelTitle => 'Gulliver Tunnels';

  @override
  String get gulliverTunnelHelpOverview =>
      'This module is used to place Gulliver Tunnels on the lawn before the level begins. Depending on their orientation, Gulliver Tunnels come in two forms: a small opening on the right and a large opening on the left, or a small opening on the left and a large opening on the right.\nImps entering through the small opening become Giant Imps with increased health. Regular zombies entering through the large opening become Mini Zombies, gaining increased movement speed and the ability to avoid some higher-flying straight projectiles.\nStraight-flying plant projectiles can also enter through the large opening and emerge from the small opening after being shrunk, dealing reduced damage. Lobbed projectiles can pass over the tunnel and attack zombies normally.';

  @override
  String get gulliverTunnelHelpUsage => 'Usage';

  @override
  String get gulliverTunnelHelpUsageBody =>
      'Select a tunnel orientation below, then click a tile to place it. Clicking a tile containing an existing tunnel removes it. Selecting a different orientation and clicking an existing tunnel replaces its orientation.';

  @override
  String get gulliverTunnelOrientationBigOnLeft =>
      'Small Opening on Right, Large Opening on Left';

  @override
  String get gulliverTunnelOrientationBigOnRight =>
      'Small Opening on Left, Large Opening on Right';

  @override
  String get gulliverTunnelPlacedCount => 'Placed';

  @override
  String get gulliverTunnelClearAll => 'Clear all';

  @override
  String get gulliverTunnelClearConfirmTitle => 'Clear all Gulliver Tunnels?';

  @override
  String get gulliverTunnelClearConfirmMessage =>
      'This will removbe all placed Gulliver Tunnels from the lawn. This action cannot be undone.';

  @override
  String get gulliverTunnelSelectOrientation => 'Select orientation';

  @override
  String get gulliverTunnelOutsideLawn => 'Tunnels outside the lawn: ';

  @override
  String get gulliverTunnelDeleteOutside =>
      'Remove Gulliver Tunnels outside the lawn';

  @override
  String get gulliverTunnelDeleteOutsideConfirmTitle =>
      'Remove Gulliver Tunnels outside the lawn?';

  @override
  String get gulliverTunnelDeleteOutsideConfirmMessage =>
      'This will remove all Gulliver Tunnels outside the 5×9 lawn. This action cannot be undone.';

  @override
  String get moduleTitle_RiftThemeDemoModuleProperties => 'Theme Configuration';

  @override
  String get moduleDesc_RiftThemeDemoModuleProperties =>
      'Adds theme effects from Penny\'s Pursuit, Memory Lane, and other game modes to the level';

  @override
  String get riftThemeHelpTitle => 'Theme Configuration module';

  @override
  String get riftThemeHelpOverview =>
      'This module defines a list of themes for the level. Themes are global conditions found in modes such as Penny\'s Pursuit, Memory Lane, and Secret Realm. Each theme provides unique effects. Long-press or right-click a theme card to view a brief description of its effects and the related plant and zombie lists.';

  @override
  String get riftThemeHelpUsage => 'Usage';

  @override
  String get riftThemeHelpUsageBody =>
      'Click the button in the lower-right corner to open the theme selection screen. Themes can be added to or removed from the theme list by clicking them. Once all settings are complete, click the button again to confirm. Themes take effect in the order they appear in the list.';

  @override
  String get riftThemeHelpUnique => 'Addition Rules';

  @override
  String get riftThemeHelpUniqueBody =>
      'Each theme can only appear once in the list. Adding an excessive number of themes may cause the level to crash.';

  @override
  String get riftThemeEmpty =>
      'No themes selected. Tap the button in the lower-right corner to choose themes.';

  @override
  String get riftThemeSelectThemes => 'Select themes';

  @override
  String get riftThemeNoSearchResults => 'No matching themes';

  @override
  String get moduleTitle_ZombieRushModuleProperties => 'Level Timer';

  @override
  String get moduleDesc_ZombieRushModuleProperties =>
      'Level ends when the timer reaches zero';

  @override
  String get moduleTitle_PVZ1PassageModuleProperties => 'Portal Combat';

  @override
  String get moduleDesc_PVZ1PassageModuleProperties =>
      'Configures the spawning of PvZ1-style portals';

  @override
  String get moduleTitle_PVZ1CopycatsModuleProperties => 'Guess Who I Am';

  @override
  String get moduleDesc_PVZ1CopycatsModuleProperties =>
      'Configures Magic Hat summons, enables Magic Hat selection';

  @override
  String get pvz1CopycatsModuleTitle => 'Guess Who I Am';

  @override
  String get pvz1CopycatsSectionParams => 'Parameters';

  @override
  String get pvz1CopycatsFieldZombieWeightLabel =>
      'Zombie weight (ZombieWeight)';

  @override
  String get pvz1CopycatsHelpZombieWeight =>
      'The probability of summoning a zombie per attempt (0–1). The probability of summoning a plant is 1 minus this value.';

  @override
  String get pvz1CopycatsFieldSpawnPlantLevelLabel =>
      'Plant level (SpawnPlantLevel)';

  @override
  String get pvz1CopycatsHelpSpawnPlantLevel =>
      'The level of plants summoned by the Magic Hat.';

  @override
  String get pvz1CopycatsSectionPlantBlackList =>
      'Plant blacklist (PlantBlackList)';

  @override
  String get pvz1CopycatsHelpPlantBlackList =>
      'Each type of Magic Hat has its own plant pool. This pool is not affected by the blacklist, so modifying the blacklist has no effect.';

  @override
  String get pvz1CopycatsSectionZombieWhiteList =>
      'Zombie whitelist (ZombieWhiteList)';

  @override
  String get pvz1CopycatsHelpZombieWhiteList =>
      'Only zombies in the whitelist can be summoned by the Magic Hat.';

  @override
  String get pvz1CopycatsHelpTip =>
      'After adding this module, remember to pre-select Magic Hats in the Seed Bank or Conveyor Belt module. Long press or right-click the Magic Hat in the plant selection screen to preview the plants it can summon.';

  @override
  String get pvz1CopycatsHelpOverview =>
      'This module configures the summon behavior of Magic Hats that can be planted in the seed slots, commonly used in the Memory Lane mini-game \"Guess Who I Am\". Without this module, Magic Hats will not function properly. Different types of Magic Hat vary in sun cost and cooldown time. After being planted, a Magic Hat will transform into a random plant or zombie. Plants are selected from the Magic Hat’s own plant pool, while zombies are selected only from the whitelist. The weights of individual entries in the plant or zombie pools cannot be adjusted.';

  @override
  String get pvz1CopycatsHelpFieldsTitle => 'Parameter details';

  @override
  String get pvz1CopycatsPlantListEmpty => 'Blacklist is empty';

  @override
  String get pvz1CopycatsZombieListEmpty => 'Whitelist is empty';

  @override
  String get pvz1CopycatsAddPlant => 'Add plant to blacklist';

  @override
  String get pvz1CopycatsAddZombie => 'Add zombie to whitelist';

  @override
  String get moduleTitle_PVZ1SeeingStarsModuleProperties => 'Seeing Stars';

  @override
  String get moduleDesc_PVZ1SeeingStarsModuleProperties =>
      'Configures target plants and wave loop for the Seeing Stars minigame';

  @override
  String get pvz1SeeingStarsModuleTitle => 'Seeing Stars';

  @override
  String get pvz1SeeingStarsSectionParams => 'Parameters';

  @override
  String get pvz1SeeingStarsSectionMatchPlants => 'Target plants (MatchPlants)';

  @override
  String get pvz1SeeingStarsHelpMatchPlants =>
      'Select a cell on the grid and add a plant. If the cell already has a plant, the new one replaces it. These plants appear as transparent guides in the level. The level is won when every target cell contains the matching plant. Target cells only allow the matching target plant and vine plants; other plants cannot be planted there.';

  @override
  String get pvz1SeeingStarsFieldCycleIndexLabel => 'Cycle wave (CycleIndex)';

  @override
  String get pvz1SeeingStarsHelpCycleIndex =>
      'The zero-based index of the first wave to repeat after the final wave. For example, in a 15-wave level with a value of 5, wave 15 is followed by wave 6. Waves keep looping until the pattern is complete.';

  @override
  String get pvz1SeeingStarsFieldSettlementDurationLabel =>
      'Settlement delay (SettlementDuration)';

  @override
  String get pvz1SeeingStarsHelpSettlementDuration =>
      'After the pattern is complete, the specified delay begins. When it ends, the level is won even if the target cells no longer contain the matching plants. The delay only applies when neither Loot Drop nor Bronze Matrix Loot Drop is present.';

  @override
  String get pvz1SeeingStarsHelpOverview =>
      'Configures the Memory Lane minigame Seeing Stars. The name comes from the original game\'s level, where players had to plant Starfruit in a star-shaped pattern. Follow the guides on the lawn and plant the matching plants in the indicated cells to win. Meanwhile, the configured zombie waves repeat, disrupting the player\'s planting.';

  @override
  String get pvz1SeeingStarsHelpFieldsTitle => 'Parameter details';

  @override
  String get pvz1SeeingStarsHelpWinCon =>
      'Do not combine this module with Loot Drop, Bronze Matrix Loot Drop, Level Timer, Bemarbled, or other modules with their own end conditions. They may override or interfere with Seeing Stars\' win condition and disrupt the minigame.\nSeeing Stars is also incompatible with Wave Generator and will crash the level if both are used. Use with caution.';

  @override
  String get pvz1SeeingStarsMatchPlantsEmpty =>
      'No pattern configured yet. Select any cell on the grid and add a plant.';

  @override
  String get seeingStarsWinConWarningTitle => 'Conflicting win conditions';

  @override
  String get seeingStarsWinConWarning =>
      'Seeing Stars ends the level when the pattern is complete. Do not combine it with Loot Drop, Bronze Matrix Loot Drop, Level Timer, Bemarbled, or other modules with their own end conditions, as they may override or interfere with its win condition.';

  @override
  String get seeingStarsCycleWaveLabel => 'Cycle wave (CycleIndex, 0-based)';

  @override
  String get seeingStarsSettlementLabel =>
      'Settlement delay (SettlementDuration, seconds)';

  @override
  String get pvz1SeeingStarsHelpTipsTitle => 'Friendly Reminder';

  @override
  String get seeingStarsCompatibilityWarningTitle =>
      'Module compatibility warning';

  @override
  String get seeingStarsCompatibilityWarning =>
      'Seeing Stars is incompatible with Wave Generator and will cause the level to crash. Use with caution.';

  @override
  String get seeingStarsCycleWaveBadge => 'Wave loop';

  @override
  String seeingStarsCycleWaveInfo(int wave) {
    return 'After the final wave, zombies start spawning again from wave $wave. Waves repeat until every target cell contains the matching plant.';
  }

  @override
  String get seeingStarsMatchPlants => 'Target plants';

  @override
  String get magicHatSpawnPreviewTitle => 'Possible plants from Magic Hat';

  @override
  String get magicHatSpawnPreviewEmpty => 'No plants match this blacklist.';

  @override
  String get pvz1PassageModuleTitle => 'Portal Combat';

  @override
  String get pvz1PassageSectionParams => 'Portal parameters';

  @override
  String get pvz1PassageHelpOverview =>
      'This module configures PvZ1-style portals, commonly used in the Memory Lane mini-game \"Portal Combat\". Portals appear in groups and affect the movement paths of plant projectiles and zombies, and will periodically change positions. Note that portals do not affect plant targeting. Plants will not attack zombies on the other end of a portal ahead of them, and will only attack if there are zombies in their lane.';

  @override
  String get pvz1PassageHelpFieldsTitle => 'Parameter Overview';

  @override
  String get pvz1PassageFieldGroupAmount => 'Portal types (GroupAmount)';

  @override
  String get pvz1PassageHelpGroupAmount =>
      'The number of portal types that appear in the level. PvZ1-style portals have two types: square and circular. If set to 1, only square portals will appear. If set to 2, both square and circular portals will appear. If set to 3 or higher, the extra portal types will display as sun textures; these portals do not change position, but can still teleport zombies.';

  @override
  String get pvz1PassageFieldPassageAmount =>
      'Portals per type (PassageAmount)';

  @override
  String get pvz1PassageHelpPassageAmount =>
      'The number of portals within each type. For example, if set to 2, each type will have 2 portals. The total number of portals cannot exceed the number of tiles in the spawn area. If multiple valid destination portals exist within the same type, zombies will always teleport to the designated one.';

  @override
  String get pvz1PassageFieldGridXMin => 'Minimum spawn column (GridXMin)';

  @override
  String pvz1PassageHelpGridXMin(int maxIndex) {
    return 'The leftmost column where portals may spawn. The left boundary of this lawn is column 0, and the right boundary is column $maxIndex. This value must be less than the maximum column value.';
  }

  @override
  String get pvz1PassageFieldGridXMax => 'Maximum spawn column (GridXMax)';

  @override
  String pvz1PassageHelpGridXMax(int maxIndex) {
    return 'The rightmost column where portals may spawn. The left boundary of this lawn is column 0, and the right boundary is column $maxIndex. This value must be greater than the minimum column value.';
  }

  @override
  String pvz1PassageGridColumnRange(int maxIndex) {
    return '0–$maxIndex';
  }

  @override
  String get pvz1PassageFieldTransferCooldown =>
      'Same-zombie teleport cooldown (transferCooldown, seconds)';

  @override
  String get pvz1PassageHelpTransferCooldown =>
      'The minimum time between two teleports of the same zombie. If set too low, a zombie that fails to leave the portal tile within the interval may be teleported back to the original portal again once the cooldown ends.';

  @override
  String get pvz1PassageFieldRefreshTime =>
      'Portal reposition interval (refreshTime, seconds)';

  @override
  String get pvz1PassageHelpRefreshTime =>
      'The interval at which portal positions are regenerated. Portals are refreshed one at a time, meaning each refresh only changes the position of one portal within the same type.';

  @override
  String get pvz1PassagePortalSpawnPreview => 'Portal spawn column preview';

  @override
  String get pvz1PassageHelpPreview => 'Spawn Range Preview';

  @override
  String pvz1PassageHelpPreviewBody(int maxIndex) {
    return 'The orange highlighted area indicates which columns portals may appear in. The column range of the current lawn is 0–$maxIndex (including both lawn boundaries). This module cannot restrict the row range where portals spawn.';
  }

  @override
  String get moduleWaveIndexZeroBasedHint => '0 = Wave 1, 1 = Wave 2, ...';

  @override
  String get moduleWaveFieldZeroBased => 'Wave (0 = Wave 1, 1 = Wave 2, ...)';

  @override
  String get moduleTitle_RenaiModuleProperties => 'Renaissance Module';

  @override
  String get moduleDesc_RenaiModuleProperties =>
      'Enables the Vitruvian Wheel and day–night cycle, configures Renaissance Statues and Marble Mounds';

  @override
  String get renaiModuleHelpTitle => 'Renaissance Module';

  @override
  String get renaiModuleHelpOverview => 'Overview';

  @override
  String get renaiModuleHelpOverviewBody =>
      'This module is used to make the Vitruvian Wheel respond to Floor-de-Lis tiles; configure day–night cycle waves; and, at night, revive Renaissance Statues and Marble Mounds, and spawn grid items based on settings. Typically used in Renaissance Ages levels.';

  @override
  String get renaiModuleHelpStatues => 'Notes';

  @override
  String get renaiModuleHelpStatuesBody =>
      'Initial grid items refer to statues and Marble Mounds present at the start of the level, which revive into zombies at specified waves. Night grid items are generated after night begins; if a plant occupies the target tile, they will not spawn. Night start wave uses a 0-based index (e.g., 0 = first wave, 1 = second wave).';

  @override
  String get renaiModuleEnableNight => 'Enable Day–Night Cycle';

  @override
  String get renaiModuleEnableNightSubtitle =>
      'Allows setting the wave when night begins and configuring night grid items';

  @override
  String get renaiModuleNightStart => 'Night Start Wave';

  @override
  String get renaiModuleDayStatues => 'Initial grid items';

  @override
  String get renaiModuleNightStatues => 'Night grid items';

  @override
  String get renaiModuleNightStatuesDisabledHint =>
      'Please enable the day–night cycle first';

  @override
  String get renaiModuleCarveWave => 'Statue revival wave';

  @override
  String get renaiModuleStatuesInCell => 'Item(s) in selected tile';

  @override
  String get renaiModuleExpectationLabel => 'Renaissance event preview';

  @override
  String get renaiModuleNightStarts => 'Night begins';

  @override
  String get renaiModulePreviewNightStatues =>
      'Night grid items to be spawned this wave:';

  @override
  String get renaiModulePreviewRevivingStatues =>
      'Statues to be revived this wave:';

  @override
  String get moduleTitle_DropShipProperties => 'Transport Boat Assault';

  @override
  String get moduleDesc_DropShipProperties =>
      'Airdrops Flying Imp Zombies onto the lawn';

  @override
  String get airDropShipModuleHelpTitle => 'Transport Boat Assault module';

  @override
  String get airDropShipModuleHelpOverview => 'Overview';

  @override
  String get airDropShipModuleHelpOverviewBody =>
      'This module is used to configure Transport Boats that appear during waves in a level, commonly seen in Sky City levels. Transport Boats cannot be damaged. A set number of Flying Imp Zombies will drop sequentially into the designated drop area.';

  @override
  String get airDropShipModuleHelpImps => 'Parameters';

  @override
  String get airDropShipModuleHelpImpsBody =>
      'Each entry’s wave index is 0-based (e.g., 0 = first wave, 1 = second wave). Each Transport Boat drops at least one Flying Imp Zombie. The extra imp count specifies how many additional imps are dropped on top of the initial one for that wave.';

  @override
  String get airDropShipModuleAppearances => 'Assault Groups';

  @override
  String get airDropShipModuleExtraImpCount => 'Extra imp count (Imp)';

  @override
  String get airDropShipModuleDropArea => 'Drop area';

  @override
  String get airDropShipModuleDropAreaPreview => 'Drop area preview';

  @override
  String get airDropShipModuleAreaDropPreviewLabel => 'Area drop preview:';

  @override
  String get airDropShipModuleExpectationLabel => 'Airdropped Imps';

  @override
  String get airDropShipModuleImpLevel => 'Imp level (ImpLv)';

  @override
  String get airDropShipModuleRowMin => 'Start row';

  @override
  String get airDropShipModuleRowMax => 'End row';

  @override
  String get airDropShipModuleColMin => 'Start column';

  @override
  String get airDropShipModuleColMax => 'End column';

  @override
  String get openModuleSettings => 'Open Module Settings';

  @override
  String get moduleTitle_GlacierModuleProperties => 'Ice Chunk Module';

  @override
  String get moduleDesc_GlacierModuleProperties =>
      'Configures the zombies hidden inside Ice Chunks created by the Frostbite Caves Zomboss';

  @override
  String get glacierModuleTitle => 'Ice Chunk module';

  @override
  String get glacierModuleHelpTitle => 'Ice Chunk module';

  @override
  String get glacierModuleHelpOverviewBody =>
      'The Frostbite Caves Zomboss summons zombies differently from other Zomboss mechs: it spits out blasts of ice from bottom to top to create Ice Chunks, which release the zombies hidden inside when they break. This module is used to configure which zombies may appear inside the Ice Chunks.';

  @override
  String get glacierModuleHelpColumnsTitle => 'Parameters';

  @override
  String get glacierModuleHelpColumnsBody =>
      'This module consists of 6 content groups, with each group corresponding to one column of Ice Chunks. Counting starts from the column farthest from Zomboss, which is the leftmost column on a standard lawn. After selecting Add content, you can add either a zombie or the empty outcome \"No zombie appears.\" Every item has its own appearance weight; only zombie items can switch zombie type and set a level of up to Level 4, while the empty outcome only has a weight.';

  @override
  String get glacierModuleHelpRequirementsTitle => 'Notes';

  @override
  String get glacierModuleHelpRequirementsBody =>
      'This module must be used together with the Zomboss Mech Battle module, and the selected base Zomboss mech must be \"Frostbite Caves Zomboss (Zombot Tuskmaster 10,000 BC)\"; otherwise, it will have no effect.\nIn addition, using the Frostbite Caves Zomboss and the Ice Chunk Module on an Underwater World lawn is not recommended, as it negatively affects the overall appearance of the level.';

  @override
  String get glacierModuleHelpPresetsTitle => 'Preset configurations';

  @override
  String get glacierModuleHelpPresetsBody =>
      'The editor includes the Ice Chunk configurations used by each Frostbite Caves Zomboss variation in the original game. Applying a preset replaces all six Ice Chunk groups and cannot be undone; you can still adjust the entries manually afterward. The Beplanted variation does not need the Ice Chunk Module and therefore has no preset. The custom variation uses a blank preset by default.';

  @override
  String get glacierModulePresetSectionTitle => 'Ice Chunk presets';

  @override
  String get glacierModulePresetBlankCustom =>
      'Custom variation (blank preset)';

  @override
  String get glacierModulePresetCustomConfiguration => 'Custom configuration';

  @override
  String get glacierModuleSwitchPresetTitle => 'Switch Ice Chunk preset';

  @override
  String glacierModuleSwitchPresetMessage(String from, String to) {
    return 'Switch from \"$from\" to \"$to\"? All six current Ice Chunk groups will be replaced and this cannot be undone.';
  }

  @override
  String get glacierModuleVariationPresetPromptTitle =>
      'Enable the matching Ice Chunk preset';

  @override
  String get glacierModuleVariationPresetPrompt =>
      'The Frostbite Caves Zomboss summons zombies by filling Ice Chunks. The zombies released from those chunks are configured by the dedicated Ice Chunk Module. You are about to switch to another Frostbite Caves Zomboss variation. Also enable the Ice Chunk Module preset used by that variation in the original game?';

  @override
  String get glacierModuleCustomVariationPresetPrompt =>
      'The custom variation uses a blank Ice Chunk preset by default. Also switch the Ice Chunk Module to the blank preset?';

  @override
  String get zombossMechSwitchVariationOnly => 'Switch variation only';

  @override
  String get glacierModuleEnablePreset => 'Enable preset too';

  @override
  String get iceAgePlantPuzzleVariationWarningTitle =>
      'Beplanted does not need Ice Chunks';

  @override
  String get iceAgePlantPuzzleVariationWarning =>
      'The Beplanted variant of Zombot Tuskmaster 10,000 BC was designed specifically for the Beplanted minigame in Frostbite Caves. Its abilities do not require the Ice Chunk Module.';

  @override
  String get glacierModuleCompatibilityWarningTitle =>
      'Ice Chunk Module requirements';

  @override
  String get glacierModuleCompatibilityWarning =>
      'Ice Chunk Module must be used together with the Zomboss Mech Battle module, and the selected base Zomboss mech must be \"Frostbite Caves Zomboss (Zombot Tuskmaster 10,000 BC)\"; otherwise, it will have no effect. If you do not intend to use the Frostbite Caves Zomboss in this level, it is recommended to remove this module.';

  @override
  String get glacierModuleUnderwaterWarningTitle =>
      'Underwater World appearance incompatibility';

  @override
  String get glacierModuleUnderwaterWarning =>
      'Avoid using the Frostbite Caves Zomboss and the Ice Chunk Module on an Underwater World lawn. This combination can harm the level appearance.';

  @override
  String glacierModuleColumn(int columnIndex) {
    return 'Column $columnIndex from the Left';
  }

  @override
  String glacierModuleEntryCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count items configured',
      one: '1 item configured',
    );
    return '$_temp0';
  }

  @override
  String get glacierModuleNoEntries =>
      'No content has been configured in this group yet.';

  @override
  String get glacierModuleAddEntry => 'Add content';

  @override
  String get glacierModuleAddContentTitle => 'Add Ice Chunk content';

  @override
  String get glacierModuleAddZombieContent => 'Add zombie';

  @override
  String get glacierModuleEmptyType => 'No zombie appears';

  @override
  String get glacierModuleWeight => 'Weight';

  @override
  String get glacierModuleWeightTooltip =>
      'Sets the weight of this zombie appearing in Ice Chunks in this column.';

  @override
  String get glacierModuleEmptyWeightTooltip =>
      'Sets the weight of the outcome in which the Ice Chunk releases no zombie.';

  @override
  String get glacierModuleLevel => 'Zombie level';

  @override
  String get glacierModuleLevelTooltip =>
      'Sets the zombie\'s level, 0-based to 4. Level 0 follows the lawn’s default level, which is Level 1 in Creative Courtyard.';

  @override
  String get moduleTitle_HeianWindModuleProperties => 'Heian Divine Wind';

  @override
  String get moduleDesc_HeianWindModuleProperties =>
      'Wind that pushes zombies and knocks plants into the air';

  @override
  String get heianWindModuleHelpTitle => 'Heian Divine Wind module';

  @override
  String get heianWindModuleHelpOverview => 'Overview';

  @override
  String get heianWindModuleHelpOverviewBody =>
      'This module is used to summon Divine Wind at specified waves, commonly seen in Heian Ages levels. The wind pushes a set number of small and medium zombies within its range horizontally. After all winds in a wave finish, rows affected by single-row winds will generate a whirlwind (one per row). The whirlwind carries zombies forward and knocks plants into the air on contact before disappearing.';

  @override
  String get heianWindModuleHelpDistance => 'Distance';

  @override
  String get heianWindModuleHelpDistanceBody =>
      '1 tile = 50 distance units. Negative values push zombies to the left, while positive values push them to the right.';

  @override
  String get heianWindModuleHelpRow => 'Coverage';

  @override
  String get heianWindModuleHelpRowBody =>
      'Each entry’s wave index is 0-based (e.g., 0 = first wave, 1 = second wave). Target rows are also indexed from 0. You can specify a single row or set it to -1 to affect all rows; in this case, no whirlwind will be generated.';

  @override
  String get heianWindModuleWaves => 'Appear waves (WaveNumber)';

  @override
  String get heianWindModuleWavesHint => 'starts from 0';

  @override
  String get heianWindModuleAppearances => 'Summon Batches';

  @override
  String get heianWindModuleWindDelay =>
      'Time between wind spawns (WindDelay; seconds)';

  @override
  String get heianWindModuleWindDelayHint => 'seconds';

  @override
  String get heianWindModuleWindEntries => 'Wind configurations';

  @override
  String get heianWindModuleAddWind => 'Add wind';

  @override
  String get heianWindModuleRow => 'Affected row (Row)';

  @override
  String get heianWindModuleAllRows => 'All rows (-1)';

  @override
  String get heianWindModuleAffectZombies =>
      'Affected zombie count (AffectZombies)';

  @override
  String get heianWindModuleDistance => 'Push Distance (Distance)';

  @override
  String get heianWindModuleDistanceHint => '1 tile = 50 units';

  @override
  String get heianWindModuleMoveTime => 'Move duration (MoveTime; seconds)';

  @override
  String get heianWindModuleMoveTimeHint => 'seconds';

  @override
  String get heianWindModuleExpectationLabel => 'Divine Wind Settings';

  @override
  String get jsonViewerModeReading => '(plain text view)';

  @override
  String get jsonViewerModeObjectReading => '(structured view)';

  @override
  String get jsonViewerModeEdit => '(edit mode)';

  @override
  String get jsonViewerFontSize => 'Font size';

  @override
  String get jsonViewerSearchHint => 'Search';

  @override
  String get jsonViewerReplaceHint => 'Replace';

  @override
  String get jsonViewerSearchHistory => 'Recent searches';

  @override
  String get jsonViewerReplaceHistory => 'Recent replacements';

  @override
  String get jsonViewerInsertNewline => 'Insert newline';

  @override
  String get jsonViewerMatchCase => 'Match case';

  @override
  String get jsonViewerWholeWords => 'Words';

  @override
  String get jsonViewerRegex => 'Regex';

  @override
  String get jsonViewerPreviousMatch => 'Previous match';

  @override
  String get jsonViewerNextMatch => 'Next match';

  @override
  String get jsonViewerReplaceOne => 'Replace';

  @override
  String get jsonViewerReplaceAll => 'Replace all';

  @override
  String jsonViewerMatchCounter(int current, int total) {
    return '$current of $total';
  }

  @override
  String get tooltipAboutModule => 'About this module';

  @override
  String get tooltipAboutSection => 'About this section';

  @override
  String get tooltipAboutEvent => 'About this event';

  @override
  String get tooltipSave => 'Save';

  @override
  String get tooltipEdit => 'Edit';

  @override
  String get tooltipClose => 'Close';

  @override
  String get tooltipToggleObjectView => 'Toggle plain text / structured view';

  @override
  String get tooltipClearUnused => 'Clear unused objects';

  @override
  String get tooltipCopyJson => 'Copy level JSON';

  @override
  String get tooltipCopyObject => 'Copy object JSON';

  @override
  String get tooltipMore => 'More';

  @override
  String get jsonViewerCopied => 'JSON copied to clipboard';

  @override
  String get tooltipJsonViewer => 'View/edit JSON';

  @override
  String get bungeeWaveEventHelpTitle => 'Bungee Drop';

  @override
  String get bungeeWaveEventHelpOverview =>
      'Configures the zombie type and drop position for Bungee Zombie deployment. Each event can drop only one zombie.';

  @override
  String get bungeeWaveEventHelpGrid => 'Coordinates';

  @override
  String get bungeeWaveEventHelpGridBody =>
      'Tap a cell in the grid to set where the Bungee Zombie will land.';

  @override
  String get bungeeWaveCurrentTarget => 'Current target';

  @override
  String get bungeeWaveCol => 'Column';

  @override
  String get bungeeWaveRow => 'Row';

  @override
  String get bungeeWavePropertiesConfig => 'Properties';

  @override
  String get bungeeWaveZombieLevel => 'Zombie level (Level)';

  @override
  String get bungeeWaveRoofWarning =>
      'In Roof levels, if a Bungee Zombie spawned by this event is blocked by Umbrella Leaf, it may immediately trigger a loss. Use with caution.';

  @override
  String get moduleTitle_LevelMutatorRiftTimedSunProps => 'Zombie Sun Drop';

  @override
  String get moduleDesc_LevelMutatorRiftTimedSunProps =>
      'Zombies drop sun when defeated';

  @override
  String get zombieSunDropHelpTitle => 'Zombie Sun Drop module';

  @override
  String get zombieSunDropHelpOverview =>
      'This module is used to configure how much sun specific zombies drop in a level, mainly for Penny\'s Pursuit Level 5. As a side effect, the Sun Shovel becomes ineffective.';

  @override
  String get zombieSunDropHelpValues => 'Values';

  @override
  String get zombieSunDropHelpValuesBody =>
      'Six integer values correspond to sun dropped at levels 1–6. For levels above 6, the value for level 1 will be used.';

  @override
  String get zombieSunDropEmpty =>
      'No configuration yet. Tap the \"+\" button in the bottom right to add.';

  @override
  String get zombieSunDropDefaultDrop => 'Default drop';

  @override
  String get zombieSunDropSun => 'sun';

  @override
  String get zombieSunDropEditTitle => 'Edit values';

  @override
  String get zombieSunDropEditHint =>
      'Configure this zombie\'s sun drops for levels 1–6; for levels above 6, the level 1 value will be used';

  @override
  String zombieSunDropTierLabel(int tier) {
    return 'Level $tier';
  }

  @override
  String get moduleTitle_PickupCollectableTutorialProperties =>
      'Pickup Collectible Tutorial';

  @override
  String get moduleDesc_PickupCollectableTutorialProperties =>
      'Shows tutorial dialog boxes when specific zombies are defeated';

  @override
  String get pickupCollectableTutorialHelpTitle =>
      'Pickup Collectible Tutorial module';

  @override
  String get pickupCollectableTutorialHelpBasic => 'Overview';

  @override
  String get pickupCollectableTutorialHelpBasicBody =>
      'Configures zombies that drop specific items and the guidance text shown before and after picking them up. A dialog box will appear when this type of zombie (including custom zombies) is defeated for the first time in the level.';

  @override
  String get pickupCollectableTutorialHelpDialogs => 'Dialogs';

  @override
  String get pickupCollectableTutorialHelpDialogsBody =>
      'Dialogs will appear before and after picking up the item. These dialogs pause level progression and delay the next wave.';

  @override
  String get pickupCollectableTutorialCoreConfig => 'Core configuration';

  @override
  String get pickupCollectableTutorialZombieLabel => 'Item-carrying zombie';

  @override
  String get pickupCollectableTutorialLootType => 'Item type';

  @override
  String get pickupCollectableTutorialGuideText => 'Guidance text';

  @override
  String get pickupCollectableTutorialPickupAdvice =>
      'Pre-pickup dialog (PickupAdvice)';

  @override
  String get pickupCollectableTutorialPostPickupAdvice =>
      'Post-pickup dialog (PostPickupAdvice)';

  @override
  String get pickupCollectableTutorialNotSet => 'Not set';

  @override
  String get pickupCollectableLootGoldCoin => 'Coin';

  @override
  String get invalidRtonMagic => 'Invalid RTON file: magic must be \"RTON\".';

  @override
  String get invalidRtonVersion => 'Invalid RTON version (expected 1).';

  @override
  String get invalidRtonEnd => 'Invalid RTON file: must end with \"DONE\".';

  @override
  String get invalidRtonArrayEnd => 'Invalid RTON array delimiter.';

  @override
  String get invalidRtid => 'Invalid RTID value.';

  @override
  String get invalidValueType => 'Invalid value type for RTON.';

  @override
  String get musicSuffix => 'Music settings';

  @override
  String get ambientAudioSuffix => 'Ambient audio settings';

  @override
  String get selectMusicSuffix => 'Select music settings';

  @override
  String get searchMusicSuffix => 'Search by name or codename';

  @override
  String get noMusicSuffixFound => 'No music settings found';

  @override
  String get jsonViewerLineContinuation => '↳';

  @override
  String get zombossMechCustomVariation => 'Custom';

  @override
  String get editCustomZombossMech => 'Edit';

  @override
  String get customZombossMechProperties => 'Custom Zomboss Mech properties';

  @override
  String get customZombossMechScalars => 'Movement Parameters';

  @override
  String get customZombossMechStages => 'Mech Phases';

  @override
  String get customZombossMechEditHint =>
      'Edit the properties of the custom mech variation (memo) used in the level. Custom Zomboss mechs are commonly found in Memory Lane levels.';

  @override
  String get zombossMechMinColumn => 'Min column';

  @override
  String get zombossMechMaxColumn => 'Max column';

  @override
  String get zombossMechSquashZombies => 'Can squash zombies';

  @override
  String get zombossMechSquashGridItems => 'Can squash grid items';

  @override
  String get zombossMultipleModuleSelectionHint =>
      'Multiple Boss modules were found. Select the instance to edit from the module list in Level Settings.';

  @override
  String get zombossMechActions => 'Actions';

  @override
  String get zombossMechPropertiesLabel => 'Properties';

  @override
  String get zombossMechAliasLabel => 'Alias (English letters only; no spaces)';

  @override
  String get zombossMechDeletePhase => 'Delete phase';

  @override
  String zombossMechDeletePhaseTitle(int number) {
    return 'Delete phase $number?';
  }

  @override
  String get zombossMechDeletePhaseMessage =>
      'This removes the phase and its action list. This cannot be undone.';

  @override
  String get zombossMechDeleteEightiesPhaseMessage =>
      'This removes the phase, its action list, and the corresponding music and Zomboss animation. This cannot be undone.';

  @override
  String get zombossMechStageJamOrder => 'Music playback order (StageJamOrder)';

  @override
  String get zombossMechZombossAnimOrder =>
      'Zomboss animation order (ZombossAnimOrder)';

  @override
  String get zombossMechAddEightiesPhaseTitle =>
      'Choose music and Zomboss animation for the new phase';

  @override
  String get zombossMechEightiesPhaseSelectionRequired =>
      'Select both the music played during this phase and the Zomboss animation it uses before creating the phase.';

  @override
  String get zombossMechCreatePhase => 'Create phase';

  @override
  String get zombossAnimNewWave => 'New Wave';

  @override
  String get zombossAnimHipHop => 'Hip-Hop';

  @override
  String get zombossMechOrphanActionDeleteTitle => 'Remove custom action data?';

  @override
  String zombossMechOrphanActionDeleteMessage(String alias) {
    return '\"$alias\" is no longer used in this level. Remove its action object from the level file?';
  }

  @override
  String get zombossMechPhasesHelp =>
      'Each phase can be configured independently with parameters such as the mech\'s health, available actions, and the retreat action performed when transitioning between phases. Actions in the list are executed based on the weights and repeat counts defined in their individual action properties; they are not executed sequentially in list order.';

  @override
  String get zombossMechPhasesHelpTitle => 'Phase contents';

  @override
  String get zombossMechAddAction => 'Add action';

  @override
  String get zombossMechNoStageActions => 'No actions yet';

  @override
  String get zombossMechSelectAction => 'Select action';

  @override
  String get zombossMechSummonJump => 'Summon jump';

  @override
  String get zombossMechSelectRetreatAction => 'Select retreat action';

  @override
  String get zombossMechCreateCustomAction => 'New custom action';

  @override
  String get zombossMechEditCustomAction => 'Edit custom action';

  @override
  String get zombossMechActionCategoryAll => 'All';

  @override
  String get zombossMechActionCategoryMovement => 'Movement';

  @override
  String get zombossMechActionCategoryAttack => 'Attack';

  @override
  String get zombossMechActionCategorySpecial => 'Special';

  @override
  String get zombossMechActionCategorySpawn => 'Summon';

  @override
  String get zombossMechActionCategoryCustom => 'Custom';

  @override
  String get zombossMechActionCategoryRetreat => 'Retreat';

  @override
  String get zombossMechNoActionsFound => 'No actions found';

  @override
  String zombossCustomActionBaseAction(String action) {
    return 'Base Action: $action';
  }

  @override
  String zombossPresetDerivedBaseAction(String action) {
    return 'Based on Preset Custom Action: $action';
  }

  @override
  String get zombossMechActionAliasHint =>
      'The reference name used for a custom action within the level. It is used to form RTID(Name@CurrentLevel) references for related entries in the mech properties. This name can be changed at any time, and any existing related RTID references in the properties will be updated automatically.';

  @override
  String get zombossMechActionBaseObjclass => 'Action Type (objclass)';

  @override
  String get zombossMechActionBaseAction => 'Base Action';

  @override
  String get zombossMechActionTemplateHint =>
      'Pick a built-in action to copy its type and default values. You can edit everything after creating.';

  @override
  String get zombossMechRecreateFromTemplate => 'Recreate from template';

  @override
  String get zombossMechRecreateFromTemplateTitle => 'Replace this action?';

  @override
  String get zombossMechRecreateFromTemplateMessage =>
      'This replaces the action type (objclass) and all field values with the selected template. Your current values will be lost.';

  @override
  String get zombossMechBaseActionAliasSyncTitle =>
      'Update the action codename?';

  @override
  String zombossMechBaseActionAliasSyncMessage(String alias) {
    return 'After changing the base action, also update the action codename to \"$alias\"?';
  }

  @override
  String get zombossMechBaseActionAliasKeep => 'Keep Current Codename';

  @override
  String get zombossMechBaseActionAliasUpdate => 'Update Codename';

  @override
  String get zombossMechActionDetails => 'Action Details';

  @override
  String get zombossMechActionRtid => 'RTID';

  @override
  String get zombossMechActionFields => 'Action Fields';

  @override
  String get zombossMechPropertiesViewTitle => 'Zomboss Mech Properties';

  @override
  String get viewZombossMechProperties => 'View properties';

  @override
  String get zombossMechEditRetreatAction => 'Choose retreat action';

  @override
  String get zombossMechAddZombie => 'Add zombie';

  @override
  String get zombossMechPickZombie => 'Pick zombie';

  @override
  String get zombossMechNoZombiesInList => 'No zombies in list';

  @override
  String get zombossMechSpawnBallSettings =>
      'Drop Configuration (ZombieDropProps)';

  @override
  String get zombossMechAwardDropInvalidTitle => 'Invalid SpawnBall reference';

  @override
  String zombossMechAwardDropInvalidBody(String rtid) {
    return 'AwardDrop points to \"$rtid\", but it is not a valid CurrentLevel ZombieDropProps object. The game may fail to load this action.';
  }

  @override
  String get zombossMechAwardDropClearInvalid =>
      'Clear invalid value and restore default';

  @override
  String get zombossMechOpenGlacierModule => 'Go to Ice Chunk Module settings';

  @override
  String get zombossMechConfigureInitialGridItems =>
      'Configure preset grid items';

  @override
  String get zombossMechEightiesSpeakerPresetPromptTitle =>
      'Pre-place the Zomboss\' speakers?';

  @override
  String get zombossMechEightiesSpeakerPresetPrompt =>
      'The first phase of the Neon Mixtape Tour Zomboss usually relies on dedicated speakers on the lawn to support its abilities, so official levels pre-place speakers at specific positions on the lawn.\nYou are about to switch to the Neon Mixtape Tour Zomboss. Would you like to place these speakers at the same positions used in the official levels?';

  @override
  String get zombossMechSwitchBaseOnly => 'Switch mech only';

  @override
  String get zombossMechPreplaceSpeakers => 'Pre-place speakers';

  @override
  String get zombossMechEightiesSpeakerRemovePromptTitle =>
      'Remove the Zomboss\' speakers?';

  @override
  String get zombossMechEightiesSpeakerRemovePrompt =>
      'You are about to switch from the Neon Mixtape Tour Zomboss to another base mech. Would you like to remove the dedicated speakers that were previously placed at the official positions? \nOnly speakers that are still Zomboss speakers at those positions will be removed; anything you later replaced them with will be left unchanged.';

  @override
  String get zombossMechKeepSpeakers => 'Keep speakers';

  @override
  String get zombossMechRemoveSpeakers => 'Remove speakers';

  @override
  String get zombossMechRobotSpawnRow => 'Row';

  @override
  String get zombossMechRobotSpawnRowRandom => 'Random (-1)';

  @override
  String get zombossMechRobotSpawnLevel => 'Level';

  @override
  String get zombossMechRobotSpawnWeight => 'Weight';

  @override
  String get zombossMechRobotSpawnPlantfood => 'Carries Plant Food';

  @override
  String get zombossMechRetreatAction => 'Retreat action';

  @override
  String zombossMechPhaseNumber(int number) {
    return 'Phase $number';
  }

  @override
  String get zombossMechAddPhase => 'Add phase';

  @override
  String get zombossMechHitPoints => 'Health (HitPoints)';

  @override
  String get continueAnyway => 'Continue anyway';

  @override
  String get armrackModuleHelpTitle => 'Weapon Stands module';

  @override
  String get armrackModuleHelpOverview => 'Overview';

  @override
  String get armrackModuleHelpOverviewBody =>
      'Places weapon stands from Kongfu World at specified positions on the lawn. Kongfu Zombies and Monk Zombies that pass by a Weapon Stand will pick up the weapon on it, transform into the corresponding special zombie, and fully restore their health. The weapon stand will break and disappear either when its own health is depleted or when the weapon on it is picked up.\nThis module also ensures that Weapon Stands display correctly in both the editor and the game, preventing them from incorrectly appearing with a sun texture.';

  @override
  String get armrackModuleHelpPlacement => 'Placement';

  @override
  String get armrackModuleHelpPlacementBody =>
      'Select a weapon stand type, then click an empty tile to place the selected Weapon Stand. Only one can be placed on each tile. Right-click on desktop or long-press on mobile to remove the weapon stand from that tile.';

  @override
  String get armrackModuleTypePalette => 'Weapon Stand Type';

  @override
  String get armrackModuleExpectationLabel => 'Weapon Stands';

  @override
  String armrackModuleRequiredMessage(String moduleName) {
    return 'For weapon stands to display properly without showing sun textures, $moduleName needs to be added.';
  }

  @override
  String renaiGridItemModuleRequiredMessage(String moduleName) {
    return 'The Vitruvian Wheel requires the \"$moduleName\" to work correctly. Add it?';
  }

  @override
  String get energyGridModuleHelpTitle => 'Taiji Tiles module';

  @override
  String get energyGridModuleHelpOverview => 'Overview';

  @override
  String get energyGridModuleHelpOverviewBody =>
      'Generates Taiji Tiles at specified positions on the lawn, commonly used in Kongfu World. When a plant is placed on a Taiji Tile, the Taiji emblem begins to flash and generates one Plant Food after 1000 ÷ the plant\'s sun cost seconds, then disappears. If the plant\'s sun cost is 0, no Plant Food will be generated.';

  @override
  String get energyGridModuleHelpPlacement => 'Placement';

  @override
  String get energyGridModuleHelpPlacementBody =>
      'Click an empty tile to place a Taiji Tile. Only one can be placed on each tile. Right-click on desktop or long-press on mobile to remove the Taiji Tile from that tile.';

  @override
  String get energyGridModuleTapToPlace =>
      'Click an empty tile to place a Taiji Tile.';

  @override
  String get energyGridModuleExpectationLabel => 'Taiji Tiles';

  @override
  String get energyGridModuleWarningMessage =>
      'Due to a game-side issue, generated Taiji Tiles may appear as purple X markers, but this does not affect their actual functionality.';

  @override
  String get gridOverrideModuleAppearances => 'Wave groups';

  @override
  String get gridOverrideModuleWaveFieldOneBased => 'Wave index';

  @override
  String get gridOverrideModuleInitialWaveNote =>
      'This group is used for preset grid items. Added grid items will appear on the lawn before the level starts.';

  @override
  String gridOverrideModuleWaveSpawnNote(int waveGeneratorWave) {
    return 'Grid items in this group will spawn when Wave Generator wave $waveGeneratorWave begins.';
  }

  @override
  String get gridOverrideModuleWaveSpawnTimelineNote =>
      'Due to incompatibilities between the old and new implementations, Wave Manager cannot spawn Grid Items by wave using this module. Please use events such as Grid Item Spawn instead.';

  @override
  String get gridOverrideModuleHelpWaveNumbering => 'Wave index';

  @override
  String get gridOverrideModuleHelpWaveNumberingBody =>
      'Wave index 1 is used for preset grid items, and added grid items will appear on the lawn before the level starts. Starting from wave index 2, the numbering corresponds directly to Wave Generator waves. For example, wave number 2 corresponds to Wave Generator wave 1, and wave index 3 corresponds to Wave Generator wave 2.';

  @override
  String get gridOverridePreviewArmrackTitle => 'Weapon stand layout preview';

  @override
  String get gridOverridePreviewEnergyGridTitle => 'Taiji tile layout preview';

  @override
  String get waveGeneratorInitialGridOverridesTitle =>
      'Manage Initial Kongfu World Grid Items';

  @override
  String get waveGeneratorPreviewInitialArmrack => 'Initial Weapon Stands';

  @override
  String get waveGeneratorPreviewInitialEnergyGrid => 'Initial Taiji Tiles';

  @override
  String waveGeneratorGridOverrideWavePreviewTitle(int wave, String label) {
    return 'Wave $wave - $label';
  }

  @override
  String get mechanismPlankStartColumn => 'Starting column (mx)';

  @override
  String get mechanismPlankTrackLength => 'Track length (mWidth)';

  @override
  String get mechanismPlankEditNotice =>
      'This interface only supports editing the starting column and track length. All other parameters use preset values, as modifying them may cause Connected Minecarts to malfunction. For further customization, please edit the JSON file manually.\nAdditionally, Connected Minecarts are not recommended outside of Kongfu World, as they are more likely to appear as purple X markers. This does not affect their actual functionality, but it may impact the level\'s visual presentation.';

  @override
  String get mechanismPlankOutOfAreaWarning =>
      'The current rail range may go outside the lawn.';

  @override
  String get portalTypeEgypt => 'Ancient Egypt';

  @override
  String get portalTypeEgypt2 => 'Ancient Egypt 2';

  @override
  String get portalTypePirate => 'Pirate Seas';

  @override
  String get portalTypeWest => 'Wild West';

  @override
  String get portalTypeFuture => 'Far Future';

  @override
  String get portalTypeFuture2 => 'Far Future 2';

  @override
  String get portalTypeDark => 'Dark Ages';

  @override
  String get portalTypeBeach => 'Big Wave Beach';

  @override
  String get portalTypeIceAge => 'Frostbite Caves';

  @override
  String get portalTypeLostCity => 'Lost City';

  @override
  String get portalTypeEighties => 'Neon Mixtape Tour';

  @override
  String get portalTypeDino => 'Jurassic Marsh';

  @override
  String get portalTypeEndlessEgypt => 'Ancient Egypt (Endless)';

  @override
  String get portalTypeEndlessPirate => 'Pirate Seas (Endless)';

  @override
  String get portalTypeEndlessWest => 'Wild West (Endless)';

  @override
  String get portalTypeEndlessKongfu => 'Kongfu World (Endless)';

  @override
  String get portalTypeEndlessFuture => 'Far Future (Endless)';

  @override
  String get portalTypeEndlessDark => 'Dark Ages (Endless)';

  @override
  String get portalTypeEndlessBeach => 'Big Wave Beach (Endless)';

  @override
  String get portalTypeEndlessIceAge => 'Frostbite Caves (Endless)';

  @override
  String get portalTypeEndlessSkyCity => 'Sky City (Endless)';

  @override
  String get portalTypeEndlessLostCity => 'Lost City (Endless)';

  @override
  String get portalTypeEndlessEighties => 'Neon Mixtape Tour (Endless)';

  @override
  String get portalTypeEndlessDino => 'Jurassic Marsh (Endless)';

  @override
  String get portalTypeEndlessModern => 'Modern Day (Endless)';

  @override
  String get portalTypeMemoryLane1 => 'Memory Lane 1';

  @override
  String get portalTypeMemoryLane2 => 'Memory Lane 2';

  @override
  String get portalTypeMemoryLane3 => 'Memory Lane 3';

  @override
  String get portalTypeShieldGenerator => 'Shield Generator';

  @override
  String get portalTypeGlacialNianSkill => 'Glacial Nian Skill';

  @override
  String get portalTypeZombotany => 'Zombotany';

  @override
  String get portalTypeSlimeZombies => 'Zom-Blob';

  @override
  String get portalTypeUniverse42 => 'Parallel Universe No. 42';

  @override
  String get portalTypeUniverse41 => 'Parallel Universe No. 41';

  @override
  String get portalTypeEliteHealerNormal => 'Elite Healer (Normal)';

  @override
  String get portalTypeEliteElectricNormal => 'Elite Lightning Gun (Normal)';

  @override
  String get portalTypeEliteBallistaNormal => 'Elite Zcorpion (Normal)';

  @override
  String get portalTypeEliteOnmyojiNormal => 'Elite Onmyoji (Normal)';

  @override
  String get portalTypeEliteHealerHard => 'Elite Healer (Hard)';

  @override
  String get portalTypeEliteElectricHard => 'Elite Lightning Gun (Hard)';

  @override
  String get portalTypeEliteBallistaHard => 'Elite Zcorpion (Hard)';

  @override
  String get portalTypeEliteOnmyojiHard => 'Elite Onmyoji (Hard)';

  @override
  String get portalTypeRomeoHard => 'Romeo (Memory Lane)';

  @override
  String get portalTypeRomeoHard2 => 'Romeo 2 (Memory Lane)';

  @override
  String get portalTypeJulietHard => 'Juliet (Memory Lane)';

  @override
  String get portalTypeJulietHard2 => 'Juliet 2 (Memory Lane)';

  @override
  String get portalTypeSherlockHard => 'Sherlock (Memory Lane)';

  @override
  String get portalTypeEliteHunter => 'Elite Hunter';

  @override
  String get portalTypeEliteChief => 'Elite Chief';

  @override
  String get portalTypeEliteWeasel => 'Elite Weasel Hoarder';

  @override
  String get portalTypeEliteBumperCar => 'Elite Bumper Car';

  @override
  String get portalTypeGlacialNian => 'Glacial Nian';

  @override
  String get portalTypeEliteWizard => 'Elite Wizard';

  @override
  String get portalTypeEliteKing => 'Elite King';

  @override
  String get portalTypeEliteMirrorQueen => 'Elite Mirror Queen';

  @override
  String get waveGeneratorTabLabel => 'Generator Timeline';

  @override
  String get waveGeneratorModuleHelpTitle => 'Wave Generator module';

  @override
  String get waveGeneratorModuleHelpOverview => 'Overview';

  @override
  String get waveGeneratorModuleHelpOverviewBody =>
      'Wave Generator is an early wave system used by Kongfu World, Daily Challenge, and other older levels. Each wave is stored directly in the module instead of using separate wave events.\nGroups in the Weapon Stands and Taiji Tiles modules can correspond one-to-one with Wave Generator waves to produce effects similar to wave events. The Wave Timeline shows where these Kongfu World grid items appear.';

  @override
  String get waveGeneratorModuleHelpSpending => 'Point-based spawning';

  @override
  String get waveGeneratorModuleHelpSpendingBody =>
      'Random spawns use the points available to the current wave. The game selects by weight from zombies affordable with the remaining points, deducts the selected cost, and filters the candidates again until none are eligible. Unused points do not carry over to the next wave, and fixed spawns consume none of these points.';

  @override
  String get waveGeneratorModuleHelpPointTrajectory => 'Parameters';

  @override
  String get waveGeneratorModuleHelpPointTrajectoryBody =>
      'Wave 1 uses Initial random-spawn points (WaveSpendingPoints). Points then increase by Points added per wave (WaveSpendingPointIncrement) by default, even across waves where random spawning is disabled.\nThe current-wave random spawn points (WavePointStart) setting changes the points for the current wave, current-wave point increment (WavePointIncrement) changes the increment used by later waves, and Reset point trajectory (WavePointOverride) determines whether the next wave returns to the points calculated from its original position or continues from the current wave\'s current-wave points as a new starting point.';

  @override
  String get waveGeneratorModuleHelpPool => 'Zombie pool';

  @override
  String get waveGeneratorModuleHelpPoolBody =>
      'The random-spawn zombie pool expands as waves progress. The initial pool is used when the level starts, and zombies added on each wave remain available to that wave and every later wave. Zombies added on a wave still enter the pool even if random spawning is disabled for that wave.';

  @override
  String get waveGeneratorModuleHelpIncompat => 'Module compatibility';

  @override
  String get waveGeneratorModuleHelpIncompatBody =>
      'Wave Generator may be incompatible with modules such as Seeing Stars and cause the level to crash. Use with caution.\nGladiatorial Row does not work with Wave Generator. Use Wave Manager instead.';

  @override
  String get waveGeneratorModuleHelpRow => 'Row numbers';

  @override
  String get waveGeneratorModuleHelpRowBody =>
      'Fixed-spawn rows are numbered from 1: enter \"1\" for Row 1, \"2\" for Row 2, and so on. Enter \"?\" to let the game choose a row at random.';

  @override
  String get waveGeneratorModuleGlobalParams => 'Global parameters';

  @override
  String get waveGeneratorGlobalParams => 'Wave Generator parameters';

  @override
  String get waveGeneratorFlagIntervalHint =>
      'Marks every Nth wave as a flag wave. This does not change its random-spawn points.';

  @override
  String get flagWaveInterval => 'Flag wave interval (FlagWaveInterval)';

  @override
  String get waveGeneratorSpendingPoints =>
      'Initial random-spawn points (WaveSpendingPoints)';

  @override
  String get waveGeneratorSpendingPointIncrement =>
      'Points added per wave (WaveSpendingPointIncrement)';

  @override
  String get waveGeneratorSpendingCompatibilityWarning =>
      'The initial random-spawn points exceed the current-wave increment and may cause the level to crash while loading.';

  @override
  String get waveGeneratorRiseFromGround =>
      'Rise from Ground (IsRiseFromGroundMode)';

  @override
  String get waveGeneratorRiseFromGroundHint =>
      'When enabled, zombies emerge from the ground by default instead of walking in from the right';

  @override
  String get waveGeneratorWaveSpawnTime =>
      'Wave spawn delay (WaveSpawnTime; time: seconds)';

  @override
  String get waveGeneratorWaveSpawnTimeHint =>
      'The minimum wait between the previous wave’s spawns and this wave’s spawns. Only applies with Rise from Ground (IsRiseFromGroundMode) enabled. After the previous wave finishes spawning, the game starts a countdown using this wave’s delay. This wave spawns when the countdown ends.\nIf WaitUntilAllZombiesDie is also enabled, both conditions must be met. A Spacetime Black Hole at the end of the previous wave overrides this delay; the next spawning steps begin about 8 seconds after the black hole triggers.';

  @override
  String get waveGeneratorZombieTargetValidTime =>
      'Target lifetime (TargetValidTime; time: seconds)';

  @override
  String get waveGeneratorZombieTargetValidTimeHint =>
      'How long a Power Sphere remains on the lawn after appearing. Leave empty for it to disappear after the default 1.5 seconds.';

  @override
  String get waveGeneratorZombieRiseGridX => 'Spawn column (Rise_GridX)';

  @override
  String get waveGeneratorZombieRiseGridXHint =>
      'The column where this zombie emerges from the ground.';

  @override
  String get waveGeneratorZombieRiseGridY => 'Spawn row (Rise_GridY)';

  @override
  String get waveGeneratorZombieRiseGridYHint =>
      'The row where this zombie emerges from the ground. Overrides the Wave Generator’s Row setting.';

  @override
  String waveGeneratorWaveCountSummary(int count) {
    return 'Total waves: $count';
  }

  @override
  String get waveGeneratorInitialPool =>
      'Initial zombie pool (AddToZombiePool)';

  @override
  String get waveGeneratorEmptyPool => 'The initial zombie pool is empty.';

  @override
  String get waveGeneratorCustomZombieBlocked =>
      'Custom zombies cannot be added here';

  @override
  String get waveGeneratorTabMissingModule =>
      'Add a Wave Generator module to configure additional groups here.';

  @override
  String waveGeneratorTabSummary(int interval, int points, int increment) {
    return 'Flag every $interval waves · Initial points $points · Increase by $increment per wave';
  }

  @override
  String get waveGeneratorNoWaves => 'No waves have been configured.';

  @override
  String waveGeneratorDeleteWaveConfirm(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'This will remove the wave and its $count fixed spawns.',
      one: 'This will remove the wave and its 1 fixed spawn.',
    );
    return '$_temp0';
  }

  @override
  String get waveGeneratorEmptyWaveRow => 'No fixed spawns';

  @override
  String get waveGeneratorRandomZombiesLabel => 'Current random-spawn pool';

  @override
  String get waveGeneratorDisableRandomSpawns =>
      'Disable random spawns (DisableRandomSpawns)';

  @override
  String get waveGeneratorDisableRandomSpawnsHint =>
      'Skips point-based random spawning on this wave only. Points still increase with wave progress, and zombie-pool changes are preserved for later waves.';

  @override
  String get waveGeneratorWaitUntilAllDie =>
      'Wait until all zombies from the previous wave are defeated before spawning this wave (WaitUntilAllZombiesDie)';

  @override
  String get waveGeneratorSpawnPlantFood =>
      'Number of zombies carrying Plant Food (SpawnPlantFoodCount)';

  @override
  String get waveGeneratorWavePointStart =>
      'Current-wave random spawn points (WavePointStart)';

  @override
  String get waveGeneratorWavePointStartHint =>
      'Sets the random-spawn points used by this wave only. Leave empty to use the points calculated by default.';

  @override
  String get waveGeneratorWavePointIncrement =>
      'New point increment (WavePointIncrement)';

  @override
  String get waveGeneratorWavePointIncrementHint =>
      'Changes the point increment used by later waves. It only takes effect when current-wave random spawn points (WavePointStart) is set.';

  @override
  String get waveGeneratorWavePointOverride =>
      'Reset point trajectory (WavePointOverride)';

  @override
  String get waveGeneratorWavePointOverrideHint =>
      'When disabled, current-wave random spawn points (WavePointStart) affects only the current wave, and the next wave returns to the points calculated from its original wave position. When enabled, the current wave\'s spawn points become the new starting point for later waves. In both cases, later waves continue with the effective point increment.';

  @override
  String get waveGeneratorPointTrajectory => 'Point trajectory preview';

  @override
  String get waveGeneratorPointTrajectoryTemporary =>
      'Current-wave random spawn points affect only this wave. The next wave returns to the points calculated from its original position and continues with the effective increment.';

  @override
  String get waveGeneratorPointTrajectoryReset =>
      'The current wave\'s random spawn points become the new starting point for later waves, which continue with the effective increment.';

  @override
  String waveGeneratorPointTrajectoryWaveValue(int wave, int points) {
    return 'W$wave · $points pts.';
  }

  @override
  String get waveGeneratorBlackHoleFieldHint =>
      'Enter a column count to summon a spacetime black hole at the end of this wave and pull all plants to the right.\nThe black hole appears only when this is not the level\'s final wave and Wait until all zombies from the previous wave are defeated before spawning this wave (WaitUntilAllZombiesDie) is enabled.';

  @override
  String waveGeneratorBlackHoleWaveHint(int cols) {
    return 'A spacetime black hole appears at the end of this wave and pulls plants $cols columns to the right';
  }

  @override
  String get waveGeneratorCurrentPool => 'Current effective zombie pool';

  @override
  String get waveGeneratorCurrentPoolEmpty =>
      'The effective zombie pool is empty.';

  @override
  String get waveGeneratorWavePoolAdd =>
      'Added to the pool on this wave (AddToZombiePool)';

  @override
  String get waveGeneratorWavePoolNoChanges =>
      'This wave does not extend the zombie pool.';

  @override
  String get waveGeneratorWaveScreenSubtitle => 'Wave Generator module';

  @override
  String get waveGeneratorRandomSpawnsSectionTitle => 'Random Spawns';

  @override
  String get waveGeneratorZombiePoolSectionTitle => 'Zombie Pool';

  @override
  String get waveGeneratorWaveSettingsTitle => 'Wave Settings';

  @override
  String get waveGeneratorFixedSpawnsHelpTitle => 'Fixed Spawns section';

  @override
  String get waveGeneratorRandomSpawnsHelpTitle => 'Random Spawns section';

  @override
  String get waveGeneratorZombiePoolHelpTitle => 'Zombie Pool section';

  @override
  String get waveGeneratorWaveSettingsHelpTitle => 'Wave Settings section';

  @override
  String get waveGeneratorFixedSpawnsHelpBody =>
      'Fixed spawns are added directly to the current wave, consume no random-spawn points, and can be used together with random spawns.';

  @override
  String get waveGeneratorPointTrajectoryHelpBody =>
      'The point trajectory preview shows the effective random-spawn points calculated by the editor for each wave. It does not represent the number of fixed spawns.';

  @override
  String get waveGeneratorWavePoolAddHelpBody =>
      'Zombies added on this wave enter the effective pool immediately and continue to affect later waves. The additions still take effect when random spawning is disabled for this wave.';

  @override
  String get waveGeneratorPoolCompatibilityTitle => 'Type restrictions';

  @override
  String get waveGeneratorPoolCompatibilityHelpBody =>
      'Wave Generator zombie pools support only standard in-game zombie types, not custom zombies defined in the level.';

  @override
  String get waveGeneratorWaitUntilAllDieHelpBody =>
      'Controls whether this wave waits for every zombie from the previous wave to be defeated before it begins spawning.';

  @override
  String get waveGeneratorSpawnPlantFoodHelpBody =>
      'Sets the number of zombies in this wave that carry and drop Plant Food.';

  @override
  String waveGeneratorFixedSummary(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count zombies are guaranteed to appear',
      one: '1 zombie is guaranteed to appear',
    );
    return '$_temp0';
  }

  @override
  String get waveGeneratorFixedSummaryEmpty => 'No fixed spawns';

  @override
  String waveGeneratorRandomSummary(int points) {
    String _temp0 = intl.Intl.pluralLogic(
      points,
      locale: localeName,
      other: 'Enabled · $points points',
      one: 'Enabled · 1 point',
    );
    return '$_temp0';
  }

  @override
  String waveGeneratorRandomLocalSummary(int points) {
    String _temp0 = intl.Intl.pluralLogic(
      points,
      locale: localeName,
      other: 'Enabled · $points points · Current-wave points',
      one: 'Enabled · 1 point · Current-wave points',
    );
    return '$_temp0';
  }

  @override
  String get waveGeneratorRandomSummaryDisabled =>
      'No random spawns on this wave';

  @override
  String waveGeneratorPoolSummary(int current, int added) {
    String _temp0 = intl.Intl.pluralLogic(
      current,
      locale: localeName,
      other: '$current current types',
      one: '1 current type',
    );
    String _temp1 = intl.Intl.pluralLogic(
      added,
      locale: localeName,
      other: '$added added on this wave',
      one: '1 added on this wave',
    );
    return '$_temp0 · $_temp1';
  }

  @override
  String waveGeneratorPoolSummaryNoAdditions(int current) {
    String _temp0 = intl.Intl.pluralLogic(
      current,
      locale: localeName,
      other: '$current current types · No additions on this wave',
      one: '1 current type · No additions on this wave',
    );
    return '$_temp0';
  }

  @override
  String get waveGeneratorWaveSettingsDefaultSummary => 'Default settings';

  @override
  String waveGeneratorWaveSettingsPlantFoodSummary(int count) {
    return 'Plant Food ×$count';
  }

  @override
  String waveGeneratorWaveSettingsBlackHoleSummary(int cols) {
    return 'Spacetime black hole · $cols columns';
  }

  @override
  String get waveGeneratorExpectationTapHint =>
      'View the random spawn estimate for this wave';

  @override
  String get waveGeneratorStatisticalPreview => 'Random-spawn preview';

  @override
  String get waveGeneratorExpectationEmpty =>
      'This wave\'s zombie pool has no zombies eligible for random spawning.';

  @override
  String get waveGeneratorExpectationPoolNote =>
      'The preview estimates spawn counts by repeatedly simulating weighted selections. Results can vary with selection order even when the point budget is unchanged, so it cannot precisely predict the game\'s actual spawns.';

  @override
  String waveGeneratorExpectationTitle(int wave) {
    return 'Wave $wave random-spawn preview';
  }

  @override
  String waveGeneratorEffectiveRandomPoints(int points) {
    return 'Random-spawn points: $points';
  }

  @override
  String waveGeneratorFixedSpawnCount(int count) {
    return 'Fixed spawns: $count';
  }

  @override
  String get waveGeneratorFixedSpawns => 'Fixed Spawns';

  @override
  String waveGeneratorPoolAddedCount(int count) {
    return 'Pool additions this wave: $count';
  }

  @override
  String get waveGeneratorWaitStatus => 'Waits for the previous wave';

  @override
  String get waveGeneratorExpectationDisabled =>
      'Random spawning is disabled on this wave.';

  @override
  String waveGeneratorExpectationMissingData(String types) {
    return 'Random-spawn preview unavailable because these zombies are missing reliable WavePointCost or Weight data: $types';
  }

  @override
  String waveGeneratorExpectationEstimatedTotal(String count) {
    return 'Average random spawns: about $count';
  }

  @override
  String waveGeneratorExpectationCommonRange(int minimum, int maximum) {
    return 'Estimated count range: $minimum–$maximum';
  }

  @override
  String waveGeneratorExpectationCostWeight(int cost, String weight) {
    return 'Cost $cost · Weight $weight';
  }

  @override
  String waveGeneratorExpectationAverageCount(String count) {
    return 'Average $count';
  }

  @override
  String get protectItems => 'Save Our Items';

  @override
  String get protectGridItemChallengeHelpTitle => 'Save Our Items module';

  @override
  String get briefOverview => 'Overview';

  @override
  String get automaticCount => 'Automatic Count';

  @override
  String get operationGuide => 'Operation Guide';

  @override
  String get protectGridItemChallengeHelpOverview =>
      'Specify the grid items that must be protected in the level. The level will immediately fail if any of them are destroyed.';

  @override
  String get protectGridItemChallengeHelpAutoCountBody =>
      'The editor will automatically update the number of grid items that need to be protected based on the number of items you add.';

  @override
  String get protectGridItemChallengeHelpOperationGuide =>
      'Click a position in the grid above, then click the \"Add item\" button to select the type of item to protect.';

  @override
  String mustProtectCount(int count) {
    return 'Current protected target count: $count';
  }

  @override
  String get customStageProperties => 'Custom lawn properties';

  @override
  String get customStageNotFound => 'Custom lawn object not found.';

  @override
  String get customStageSectionGeneral => 'General';

  @override
  String get customStageSectionZombies => 'Zombie Types';

  @override
  String get customStageSectionResourceGroups => 'Resource Groups';

  @override
  String get customStageSectionMusicAndOther => 'Basic Elements';

  @override
  String get customStageSectionAdvanced => 'Advanced Settings';

  @override
  String get customStageAlias =>
      'Stage alias (English letters only; no spaces)';

  @override
  String get customStageNoResourceGroups => 'No resource groups in list';

  @override
  String get customStageMissingBackgroundWarning =>
      'Import at least one DelayLoad_Background group listed in the stage helper, or the lawn may appear completely black.';

  @override
  String get customStageEnableAmbient => 'Enable ambient audio';

  @override
  String get customStageDisabledCellsEmpty => 'Leave empty';

  @override
  String get customStageDisabledCellsDefault => 'Default';

  @override
  String get customStageEnableSubmarine => 'Enable submarine';

  @override
  String get customStageSubmarineHitpoints => 'Submarine health';

  @override
  String get customStageBeachMinigame => 'Use minigame version';

  @override
  String get customStageOnePerLevelLimit =>
      'This level already has a custom lawn. Delete it before adding another.';

  @override
  String get selectStageBackground => 'Select lawn appearance';

  @override
  String get searchStageBackground => 'Search lawn';

  @override
  String get noStageBackgroundFound => 'No lawn appearance found';

  @override
  String get stageBackgroundNeedMorePromptTitle =>
      'Need another lawn appearance?';

  @override
  String get stageBackgroundNeedMorePromptMessage =>
      'Import resource groups from another stage to unlock more lawn appearances here.';

  @override
  String get stageBackgroundAddFromStage => 'Add another lawn appearance';

  @override
  String get customStageNameSuffix => ' (Custom)';

  @override
  String get customStageLawnAppearance => 'Lawn appearance';

  @override
  String get customStageBaseStage => 'Base stage';

  @override
  String get selectCustomStageBase => 'Select base lawn';

  @override
  String get noStageBaseFound => 'No lawn found';

  @override
  String get importResourceGroup => 'Import resource group';

  @override
  String get importResourceGroupGlobal => 'From global list';

  @override
  String get importResourceGroupFromStage => 'From stage';

  @override
  String get searchResourceGroup => 'Search resource group';

  @override
  String get noResourceGroupFound => 'No resource group found';

  @override
  String get importResourceGroupsFromStageTitle =>
      'Add resource groups from stage?';

  @override
  String importResourceGroupsFromStageMessage(String stageName) {
    return 'The following resource groups from $stageName will be added:';
  }

  @override
  String importResourceGroupsFromStageSkipped(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count resource groups already in this level will be skipped.',
      one: '1 resource group already in this level will be skipped.',
    );
    return '$_temp0';
  }

  @override
  String get importResourceGroupsFromStageAllPresent =>
      'All resource groups from this stage are already in this level.';

  @override
  String get importResourceGroupsApplySourceLawnAppearance =>
      'Also use this stage\'s lawn appearance';

  @override
  String get createCustomStage => 'Create custom lawn';

  @override
  String get createCustomStageHint =>
      'Pick a base lawn appearance and edit it locally in this level.';

  @override
  String get customStageAliasPromptTitle => 'Custom lawn alias';

  @override
  String get customStageAliasTaken =>
      'That alias is already used in this level.';

  @override
  String get stageSelectionTabBuiltin => 'Built-in';

  @override
  String get stageSelectionTabCustom => 'Custom';

  @override
  String get customStageSelectionEmpty => 'No custom lawn in this level yet.';

  @override
  String get customStageSelectionInLevel => 'Custom lawns in this level';

  @override
  String get customStageSwitchToBuiltinTitle => 'Switch to built-in lawn?';

  @override
  String get customStageSwitchToBuiltinMessage =>
      'This permanently removes the custom lawn data from this level. This cannot be undone.';

  @override
  String get customStageDeleteTitle => 'Delete custom lawn?';

  @override
  String get customStageDeleteMessage =>
      'This permanently removes the custom lawn data from this level. If it is the active lawn, the level will switch to the default built-in lawn.';

  @override
  String get customStagePresetSectionTitle => 'Preset custom lawns';

  @override
  String get startupLoadingLocalization => 'Localization';

  @override
  String get startupLoadingStages => 'Lawns';

  @override
  String get startupLoadingAudio => 'Audio';

  @override
  String get startupLoadingGridItems => 'Grid items';

  @override
  String get startupLoadingZomboss => 'Zomboss';

  @override
  String get startupLoadingReference => 'Reference data';

  @override
  String get startupLoadingZombies => 'Zombies';

  @override
  String get startupLoadingPlants => 'Plants';

  @override
  String get startupLoadingFish => 'Sea Creatures';

  @override
  String get startupLoadingImages => 'Images';

  @override
  String get startupLoadingPlugins => 'Plugins';

  @override
  String startupLoadingCategoryProgress(String category) {
    return 'Loading $category...';
  }

  @override
  String get reselectFiles => 'Re-select files';

  @override
  String get validationReviewRequest =>
      'Please review the validation results for the selected levels.';

  @override
  String get validationRecommendation =>
      'We recommend editing these levels to fix the issues before exporting, or choosing different files.';

  @override
  String get customPortalAdd => 'New Custom Portal';

  @override
  String get customPortalSingleName => 'Custom Portal';

  @override
  String get customPortalCreateTitle => 'Create Custom Portal';

  @override
  String get customPortalEditTitle => 'Edit Custom Portal';

  @override
  String get customPortalSelectBaseTitle => 'Select a Base Portal';

  @override
  String get customPortalBlankTemplate => 'Blank Portal Template';

  @override
  String get customPortalBlankTemplateSubtitle =>
      'Start with the standard portal structure and no zombies.';

  @override
  String get customPortalBuiltInBases => 'Built-in Portals';

  @override
  String get customPortalUnusedTitle => 'Remove Unused Custom Portal?';

  @override
  String get customPortalUnusedSingleMessage =>
      'The custom portal is no longer used. Remove its associated data objects from this level?';

  @override
  String get customPortalAppearanceSection => 'Portal Appearance';

  @override
  String get customPortalSpawnSection => 'Zombie Spawning';

  @override
  String get customPortalWorld => 'World Appearance';

  @override
  String get customPortalWorldTwister => 'Blank';

  @override
  String get customPortalPopAnimation => 'Portal Animation';

  @override
  String get customPortalAnimationModern => 'Modern Day\'s Portal';

  @override
  String get customPortalAnimationMemoryLane => 'Memory Lane\'s Portal';

  @override
  String get customPortalAnimationHydra => 'Zombot Spell Chanter\'s Mirror';

  @override
  String get customPortalSpawnMethod => 'Zombie Spawn Method';

  @override
  String get customPortalSpawnMethodShuffled => 'Shuffled Sequence';

  @override
  String get customPortalSpawnMethodInOrder => 'In Order';

  @override
  String get customPortalSpawnMethodHydra =>
      'Zombot Spell Chanter\'s Random Spawn';

  @override
  String get customPortalZombieTypes => 'Spawnable Zombie Types';

  @override
  String get customPortalSpawnInterval => 'Zombie Spawn Interval';

  @override
  String get customPortalSpawnIntervalSubtitle =>
      'Optionally set the minimum and maximum time between zombie spawns.';

  @override
  String get moduleTitle_MoonLifeSupportSystemProperties =>
      'Life Support System';

  @override
  String get moduleDesc_MoonLifeSupportSystemProperties =>
      'Configures the Moon BaseZ power capacity and overload protocols';

  @override
  String get moduleTitle_LunarTerminalModuleProperties => 'Lunar Terminal';

  @override
  String get moduleDesc_LunarTerminalModuleProperties =>
      'Deploys mining robots to collect crystal energy and increase the power capacity limit';

  @override
  String get moduleTitle_LunarMineVeinModuleProperties => 'Crystal Veins';

  @override
  String get moduleDesc_LunarMineVeinModuleProperties =>
      'Places Lunar Energy Crystal Veins and sets their growth waves';

  @override
  String get moduleTitle_RadiationMeteorModuleProperties =>
      'Radioactive Meteorite';

  @override
  String get moduleDesc_RadiationMeteorModuleProperties =>
      'Drops meteorites that destroy units and contaminate surrounding tiles';

  @override
  String get eventTitle_SpawnRocketLandingWaveActionProps => 'Rocket Landing';

  @override
  String get eventDesc_SpawnRocketLandingWaveActionProps =>
      'Spawns capturable Moon rockets at set positions';

  @override
  String get moonLifeSupportHelpTitle => 'Life Support System';

  @override
  String get moonLifeSupportHelpOverview =>
      'An economy system commonly used in Moon BaseZ levels. After this module is added, planting does not cost Sun. Instead, plants occupy a portion of the Life Support System\'s power capacity in real time. When a plant is shoveled, destroyed by zombies, or removed by a special mechanic, all capacity it occupied is immediately restored.\nNote that this module also prevents Level 4 and higher plants from automatically using their Plant Food ability when planted.';

  @override
  String get moonLifeSupportHelpProtocolsTitle => 'Overload protocols';

  @override
  String get moonLifeSupportHelpProtocols =>
      'When the Life Support System\'s power usage exceeds its initial power capacity, the system enters an overloaded state and activates the Power-Saving Protocol, reducing the attack speed of plants on the lawn and the recharge speed of seed slots.\nWhen power usage exceeds (initial power capacity × required hibernation ratio), the system forcibly activates the Hibernation Protocol after the configured countdown, putting every plant on the lawn into hibernation. Seed slots and the Cosmic Plant Food meter are also locked and cannot be used.';

  @override
  String get moonLifeSupportHelpPlantFoodTitle => 'Independent cooldowns';

  @override
  String get moonLifeSupportHelpPlantFood =>
      'The module defines a dedicated list of plants with independent cooldowns. The cooldowns of plants in this list are not affected by the Power-Saving Protocol, but those plants still cannot be planted under the Hibernation Protocol.';

  @override
  String get moonLifeSupportPowerSettings => 'Power settings';

  @override
  String get moonInitialCapacity => 'Initial power capacity (InitialCapacity)';

  @override
  String get moonBufferOverloadRatio =>
      'Required hibernation ratio (BufferOverloadRatio)';

  @override
  String get moonPenaltyCountdown =>
      'Hibernation countdown (PenaltyCountdown, seconds)';

  @override
  String get moonPlantImmunityList =>
      'Plants with independent cooldowns (PlantImmunityList)';

  @override
  String get moonPlantImmunityListHint =>
      'The cooldowns of plants in this list are not affected by the Power-Saving Protocol, but those plants still cannot be planted under the Hibernation Protocol.';

  @override
  String get moonSelectImmunePlants => 'Select plants to add to the list';

  @override
  String get lunarTerminalHelpTitle => 'Lunar Terminal';

  @override
  String get lunarTerminalHelpOverview =>
      'An Artifact commonly used in Moon BaseZ levels. It remains at a fixed position on the lawn, similar to the cannon in Sky City. After tapping the collection terminal, select one of three mining robots and drag it onto the lawn. Robots automatically collect energy from Lunar Energy Crystals and Radioactive Meteorites within range, permanently increasing the base Life Support System\'s available power capacity for the current level and allowing stronger lineups. Robots have health and can be attacked and destroyed by zombies, Radioactive Meteorites, and other targets.';

  @override
  String get lunarTerminalHelpFixedTitle => 'Deployment cooldown';

  @override
  String get lunarTerminalHelpFixed =>
      'After deploying a robot, the Lunar Energy Collection Terminal enters a cooldown period. The cooldown duration can be customized in the level.';

  @override
  String get lunarTerminalCollectorCooldown =>
      'Robot deployment cooldown (CollectorCooldown, seconds)';

  @override
  String get lunarMineVeinHelpTitle => 'Crystal Veins';

  @override
  String get lunarMineVeinHelpOverview =>
      'Places Lunar Energy Crystal Veins on the lawn at the start of the level, as commonly seen in Moon Base. Veins initially provide no energy. Once the configured wave begins, a crystal of the corresponding type grows at the same position and can be mined according to its properties. Select a vein type, then tap a grid cell to place it. Right-click on desktop or long-press on mobile to remove it.';

  @override
  String get lunarMineVeinTypePalette => 'Crystal vein type';

  @override
  String get lunarMineVeinHelpHardened =>
      'Protected by a sturdy outer layer of rock. The shell must first be destroyed by plant attacks before the crystal can be mined normally. Hard-Shell Crystal Veins always grow the 3,000 HP version of the Hard-Shell Crystal.';

  @override
  String get lunarMineVeinHelpFragile =>
      'Mining continuously consumes its durability until the crystal shatters. Special Fragile Crystal Veins containing Cosmic Plant Food can also be placed.';

  @override
  String get lunarMineVeinHelpRadiation =>
      'Periodically releases radiation in all directions. Plants exposed to the radiation will randomly transform into other plants, while irradiated zombies will either take damage or mutate into a Cosmic Radiation Gargantuar. Cosmic Radiation Gargantuars have extremely high health and will also irradiate nearby plants and zombies when defeated.';

  @override
  String get lunarMineVeinHelpWaveTitle => 'Wave numbering';

  @override
  String get lunarMineVeinHelpWave =>
      'Growth wave (EmergenceWave) is numbered from 1. Enter 1 to grow on the first wave, 2 to grow on the second wave, and so on.';

  @override
  String get lunarMineVeinPlacements => 'Vein placements (VeinPlacements)';

  @override
  String get lunarMineVeinModuleExpectationLabel => 'Crystal Veins';

  @override
  String get lunarMineVeinModulePreviewEmerging =>
      'Lunar Energy Crystals emerging this wave:';

  @override
  String get lunarMineEmergenceWave => 'Growth wave (EmergenceWave, 1-based)';

  @override
  String get moonPlacementGestureHint =>
      'Tap an empty tile to add an entry. Right-click or long-press an occupied tile to remove it.';

  @override
  String get moduleTitle_GladiatorRowModuleProperties => 'Gladiatorial Row';

  @override
  String get moduleDesc_GladiatorRowModuleProperties =>
      'Temporarily seal off five tiles in a row, with rewards or penalties based on the duel’s outcome';

  @override
  String get gladiatorSettings => 'Global duel, reward and penalty settings';

  @override
  String get gladiatorArenaDuration => 'Duel duration (ArenaDuration, seconds)';

  @override
  String get gladiatorRewardCount =>
      'Plant Food reward (PlantWinPlantfoodCount)';

  @override
  String get gladiatorPunishmentCount =>
      'Penalty cage count (ZombieWinPunishmentCageCount)';

  @override
  String get gladiatorPunishmentDuration =>
      'Penalty drop duration (ZombieWinPunishmentDuration, seconds)';

  @override
  String get gladiatorPunishmentLevel =>
      'Penalty zombie level (ZombieWinPunishmentZombieLevel)';

  @override
  String get gladiatorEncounters => 'Duel schedule (Encounters)';

  @override
  String get gladiatorWave => 'Trigger wave (Wave, starts at 0)';

  @override
  String get gladiatorRow => 'Row (Row, starts at 0)';

  @override
  String get gladiatorWarningDuration =>
      'Zomboss arrival warning time (WarningDuration, seconds)';

  @override
  String get gladiatorFirstCageDelay =>
      'First cage drop delay (FirstCageDelay, seconds)';

  @override
  String get gladiatorPreviewTitle => 'Gladiatorial Row area preview';

  @override
  String get gladiatorPreviewLegend =>
      'The green tile marks the trophy fixed in column 5; red tiles mark the rest of the arena. Zombie icons show cage spawn positions, and each tile’s number shows the zombie count. Tap the grid to select a row.';

  @override
  String get gladiatorSpawns => 'Cage spawn schedule (Spawns)';

  @override
  String get gladiatorAddSpawn => 'Add cage spawn';

  @override
  String get gladiatorSpawnTime =>
      'Spawn delay after the duel begins (Time, seconds)';

  @override
  String get gladiatorSpawnColumn => 'Spawn column (GridX, starts at 0)';

  @override
  String get gladiatorSpawnCount => 'Spawn count (Count)';

  @override
  String get gladiatorSpawnInterval => 'Spawn interval (Interval, seconds)';

  @override
  String get gladiatorSpawnLevel => 'Zombie level (Level)';

  @override
  String get gladiatorPunishmentPool =>
      'Defeat penalty zombie pool (ZombieWinPunishmentZombiePool)';

  @override
  String get gladiatorPunishmentHint =>
      'After a defeat, penalty cages select zombies from this list by weight. Higher weights increase the chance of being chosen.';

  @override
  String get gladiatorAddPunishment => 'Add penalty zombie';

  @override
  String get gladiatorWeight => 'Spawn weight (Weight)';

  @override
  String get gladiatorCompatibilityWarningTitle =>
      'Module compatibility warning';

  @override
  String get gladiatorWaveGeneratorCompatibilityWarning =>
      'Gladiatorial Row does not work with Wave Generator. Use Wave Manager instead.';

  @override
  String get gladiatorUnderwaterMismatchWarning =>
      'The current lawn uses a six-row Underwater World appearance. Gladiatorial Rows will not appear on this lawn. Use a five-row lawn instead.';

  @override
  String get gladiatorLegacyModeWarning =>
      'This module’s duel mode (GameplayVersion) is not set to 1. It may be using the retired legacy mode instead of trophy duel mode, so the Gladiatorial Row area cannot be previewed.';

  @override
  String get gladiatorUseTrophyMode => 'Switch to trophy duel mode';

  @override
  String get gladiatorHelpTipsTitle => 'Friendly Reminder';

  @override
  String get gladiatorHelpOverview =>
      'This module configures the wave-triggered Gladiatorial Row mechanic commonly seen in the Roman Glory Secret Realm. On the specified wave, Roman Zomboss appears in the selected row and temporarily seals off five consecutive tiles. Existing plants and zombies inside those tiles are destroyed, while plants and zombies outside them stop moving and acting.\nA trophy rises in the center of the arena. Zombies arrive in cages airdropped on the right. Protect the trophy until the timer expires to win. Winning grants a large Plant Food reward; losing causes cages to drop across the lawn and release many zombies. After the duel, all plants and zombies remaining inside the arena are destroyed.';

  @override
  String get gladiatorHelpUsage =>
      'The duel duration, Plant Food reward and penalty drop settings above, along with the penalty zombie pool and weights below, are global settings shared by every duel in this module. Select “Add duel” to configure an individual duel. When you add a zombie, its resource groups are automatically added to the module. The wave (Wave), row (Row) and spawn column (GridX) are all numbered from 0: Wave 0 corresponds to timeline wave 1, and Wave 4 to wave 5. The editor defaults to trophy duel mode (GameplayVersion 1). Setting it to 0 enables a different, retired duel mode, which you can explore through manual editing.';

  @override
  String get gladiatorHelpTips =>
      'During a duel, planting no longer costs sun, but plants still occupy the Life Support System’s power capacity.\nInstant-kill attacks from Gargantuars and similar zombies cannot damage the trophy.\nPlant projectiles leaving the arena are blocked by its fences. Zombies that leave the arena, and zombies using certain abilities aimed outside the arena, become frozen in place. They are released when the duel timer ends and resume attacking.\nGladiatorial Rows do not appear on six-row lawns with an Underwater World appearance, such as 20,000 Leagues Under the Sea or Atlantis. The Gladiatorial Row module also does not work with Wave Generator.';

  @override
  String get radiationMeteorHelpTitle => 'Radioactive Meteorite';

  @override
  String get radiationMeteorHelpOverview =>
      'Drops special Radioactive Meteorites on specified waves, as commonly seen in Moon BaseZ. Before a meteorite lands, a red-text warning appears in the level and a crosshair marks its expected landing tile. After the configured warning duration, the meteorite falls straight down, instantly destroying units on its landing tile, then slowly contaminates surrounding tiles clockwise.\nZombies on contaminated tiles gain increased movement speed and health regeneration, while Cosmic plants continuously take damage.';

  @override
  String get radiationMeteorHelpWaveTitle => 'Wave numbering';

  @override
  String get radiationMeteorHelpWave =>
      'Radioactive Meteorite landing waves use a 0-based index: enter 0 for the first wave, 1 for the second wave, and so on. When a landing schedule group is added in the editor, Group 1 defaults to 0, Group 2 to 1, and so forth.';

  @override
  String get radiationMeteorHelpMiningTitle => 'Mining to destroy';

  @override
  String get radiationMeteorHelpMining =>
      'Lunar Energy Collection Units can mine Radioactive Meteorites and destroy them after a period of time. After a meteorite is destroyed, the terminal grants the player a permanent power-capacity increase for the current level and removes the contamination effects.';

  @override
  String get radiationMeteorParameters => 'Meteor parameters';

  @override
  String get radiationMeteorWarningDuration =>
      'Warning duration (WarningDuration, seconds)';

  @override
  String get radiationMeteorPollutionInterval =>
      'Contamination interval (PollutionInterval, seconds)';

  @override
  String get radiationMeteorMiningDuration =>
      'Required mining duration (MiningDurationRequired, seconds)';

  @override
  String get radiationMeteorPowerReward =>
      'Power reward on destruction (PowerRewardOnDestroy)';

  @override
  String get radiationMeteorSpawnSchedule => 'Landing schedule (SpawnSchedule)';

  @override
  String get radiationMeteorWave => 'Wave (Wave, 0-based)';

  @override
  String get radiationMeteorModuleExpectationLabel => 'Radioactive Meteorite';

  @override
  String get radiationMeteorModulePreviewLanding =>
      'Meteorites landing this wave:';

  @override
  String get eventTitle_GravityGeneratorWaveActionProps => 'Gravity Generator';

  @override
  String get eventDesc_GravityGeneratorWaveActionProps =>
      'Applies different Gravity states to plants or grid cells';

  @override
  String get gravityLevel => 'Gravity state (GravityLevel)';

  @override
  String get gravityAnti => 'Anti-Gravity (anti)';

  @override
  String get gravityHeavy => 'Hypergravity (heavy)';

  @override
  String get gravityTargetType => 'Target type (TargetType)';

  @override
  String get gravityTargetPlant => 'Random plant (plant)';

  @override
  String get gravityTargetGrid => 'Fixed grid cell (grid)';

  @override
  String get gravityRangeX => 'Horizontal offset (Range.mX)';

  @override
  String get gravityRangeY => 'Vertical offset (Range.mY)';

  @override
  String get gravityRangeWidth => 'Range width (Range.mWidth, cells)';

  @override
  String get gravityRangeHeight => 'Range height (Range.mHeight, cells)';

  @override
  String get gravityTargetX => 'Target column (TargetGrid.mX, 0-based)';

  @override
  String get gravityTargetY => 'Target row (TargetGrid.mY, 0-based)';

  @override
  String get gravityPreviewTitle => 'Gravity field range preview';

  @override
  String get gravityPlantRangeHint =>
      'Choose a random plant on the lawn as the reference point and affect plants and zombies within the range. The cross marks the chosen plant. The range extends right and down from its offset position, including the starting tile. Negative offsets move the range origin left or up.';

  @override
  String get gravityGridRangeHint =>
      'Rows and columns start at 0. Tap the grid to select the reference tile. Add the horizontal and vertical offsets to that tile to find the range origin, then extend right and down. Width and height include the starting tile. With zero offsets, a width of 3 and height of 1 cover the target tile and the two tiles to its right.';

  @override
  String get gravityCenterLegend => 'Cross: reference point';

  @override
  String get gravityRestrictions =>
      'Unaffected plants and zombies (TargetRestriction)';

  @override
  String get gravityRestrictionHint =>
      'Plants and zombies in this list are unaffected by the gravity field. Leave it empty to exclude no additional types.';

  @override
  String get gravityAddPlantRestriction => 'Add unaffected plants';

  @override
  String get gravityAddZombieRestriction => 'Add unaffected zombies';

  @override
  String get gravityAdvancedSettings => 'Action and timing parameters';

  @override
  String get gravityActivationDelay =>
      'Activation delay (ActivationDelay, seconds)';

  @override
  String get gravityDuration => 'Gravity state duration (Duration, seconds)';

  @override
  String get gravityDeployDuration =>
      'Device deployment time (DeployDuration, seconds)';

  @override
  String get gravityChargeDuration =>
      'Charge time before applying gravity (ChargeDuration, seconds)';

  @override
  String get gravityRetractDuration =>
      'Device retraction cooldown (RetractDuration, seconds)';

  @override
  String get gravityPlantExitDelay =>
      'Time until a floating plant disappears (PlantExitDelay, seconds)';

  @override
  String get gravityZombieRiseDuration =>
      'Zombie ascent time (ZombieRiseDuration, seconds)';

  @override
  String get gravityZombieTranslateDuration =>
      'Airborne zombie travel time (ZombieTranslateDuration, seconds)';

  @override
  String get gravityZombieFallDuration =>
      'Zombie landing time at its destination (ZombieFallDuration, seconds)';

  @override
  String get gravityZombieLiftHeight => 'Zombie lift height (ZombieLiftHeight)';

  @override
  String get gravityZombieForwardDistance =>
      'Zombie forward distance (ZombieForwardDistance, 64 pixels = 1 tile)';

  @override
  String get gravityHeavyPlantSinkDuration =>
      'Plant sinking duration (HeavyPlantSinkDuration, seconds)';

  @override
  String get gravityHelpParametersTitle => 'Parameter Description';

  @override
  String get gravityHelpParameters =>
      'By default, this event includes all parameters for both Anti-Gravity and Hypergravity. The action settings show only the parameters used by the selected state. Values entered for the other mode are retained when switching.';

  @override
  String get gravityHelpTipsTitle => 'Friendly Reminder';

  @override
  String get gravitySequentialNotice =>
      'Gravity Generator events cannot run simultaneously. The previous Anti-Gravity or Hypergravity sequence must finish before the next one can run. Space out their trigger times.';

  @override
  String get gravityHelpOverview =>
      'A device located at the zombie base that triggers as a preset battlefield event during designated waves. Once it emerges from the base, it locks onto plants or zombies within a fixed area on the lawn and fires a gravitational beam, applying different Gravity states and disrupting plants’ attack rhythm and zombies’ movement patterns.';

  @override
  String get gravityHelpAnti =>
      'Targeted plants slowly float upward and eventually drift off the battlefield and disappear. Targeted zombies rise and move forward, becoming immune to straight-shot attacks while airborne.\nWhen a plant under Anti-Gravity is within Gravitree’s attack range, Gravitree attacks and clears Anti-Gravity from plants within its range. Gravitree itself is immune to the Gravity Generator: it cannot be lifted into the air or pressed into the ground.';

  @override
  String get gravityHelpHeavy =>
      'Targeted plants are pressed halfway into the ground. While in this state, they cannot attack but can still be eaten by zombies. Targeted zombies advance steadily and become immune to knockback effects.\nCosmic Saucer can remove Hypergravity from zombies and put them into the Floating state instead. It can also remove Hypergravity from plants, restoring them to normal.';

  @override
  String get rocketLandingHelpTitle => 'Rocket Landing';

  @override
  String get rocketLandingHelpOverview =>
      'An event commonly used in Moon BaseZ. It spawns rockets at specified positions as objectives contested by both plants and zombies.';

  @override
  String get rocketLandingHelpPlantsTitle => 'Plants take control';

  @override
  String get rocketLandingHelpPlants =>
      'Plant a designated Cosmic plant inside a rocket. After a short time, the rocket launches, locks onto a high-threat zombie on the lawn, and bombards it for massive damage. Cosmic Pea releases ricocheting Cosmic projectiles; Cosmic Mushroom summons Mushroom Wormholes in the area; Cosmic Nut creates a short-lived small black hole that pulls and continuously damages nearby zombies.';

  @override
  String get rocketLandingHelpZombiesTitle => 'Zombies take control';

  @override
  String get rocketLandingHelpZombies =>
      'When a zombie enters a rocket, it launches after a short delay and lands farther back on the lawn, transporting the zombie to that tile. Some zombies cannot enter rockets.';

  @override
  String get rocketLandingSettings => 'Rocket settings';

  @override
  String get rocketSpawnInterval => 'Spawn interval (SpawnInterval, seconds)';

  @override
  String get moduleTitle_LevelPowerupModuleProperties => 'Power Ups';

  @override
  String get moduleDesc_LevelPowerupModuleProperties =>
      'Enables the wonderfully interesting gesture system';

  @override
  String get powerUpsHelpTitle => 'Power Ups';

  @override
  String get powerUpsHelpOverview =>
      'This wonderfully interesting mechanic makes a major return in the 13th Anniversary Secret Realm, allowing players to defeat zombies with specific gestures while a Power Up is active. Enabling this module lets you set the exact number of free uses for each Power Up in the level. Note that Power Snow and Power Flame from the international version do not exist in the Chinese version, and the Power Ups used in Vasebreaker and Beghouled cannot be added through this module.';

  @override
  String get powerUpsAddTitle => 'Add Power Up';

  @override
  String get powerUpsOrder => 'Order';

  @override
  String get powerUpsOrderInfo =>
      'Power Ups appear in the game in the order shown here. Drag the ⋮⋮ handles to reorder them. Removing a Power Up from the list prevents it from appearing in the game; it can be added back in this module whenever needed.';

  @override
  String get powerUpsFreeUseCount => 'Free uses (FreeUseCount)';

  @override
  String get powerZap => 'Power Zap';

  @override
  String get powerZapInfo =>
      'Tap or drag across zombies to unleash a powerful electric shock that continuously damages every zombie it touches.';

  @override
  String get powerToss => 'Power Toss';

  @override
  String get powerTossInfo =>
      'Swipe quickly across a zombie to fling it into the air. Swipe again to throw it completely off the lawn.';

  @override
  String get powerPinch => 'Power Pinch';

  @override
  String get powerPinchInfo =>
      'Pinch a zombie with two fingers like a pair of scissors to snip off its head and quickly remove the threat.';

  @override
  String get moduleTitle_StatueMazeModuleProperties => 'Bemarbled';

  @override
  String get moduleDesc_StatueMazeModuleProperties =>
      'Find every hidden zombie in the statue array after it rotates';

  @override
  String get moduleHelpStatueMazeOverviewBody =>
      'A Renaissance Ages-exclusive minigame. This minigame consists of several rounds, each with an array of statues, some of which conceal Aristocrat Zombies. At the start of each round, the locations of the hidden zombies are revealed. The entire array then rotates several times to challenge the player’s memory. Once the rotations finish, the player must use their limited supply of tools to smash every statue hiding a zombie. The level is lost if any zombies remain undiscovered when all attempts have been used. The player can also spend diamonds to buy extra attempts when they run out.';

  @override
  String get moduleHelpStatueMazeTimingTitle => 'Timing parameters';

  @override
  String get moduleHelpStatueMazeTimingBody =>
      'Initial reveal time (DisplayTime): The time between revealing the statues that hide zombies and the start of the first rotation.\nTotal step duration (WaitDuration): The total time from the start of the current rotation to the start of the next. The final rotation step in each round also runs for this full duration before the player can act.\nRotation duration (RotateTime): The duration of the current 90° rotation animation.\nThe actual pause between rotations is therefore the total step duration minus the rotation duration. If the rotation duration exceeds the total step duration, the next rotation starts before the previous one finishes and resets the statues’ movement parameters. This may cause abnormal movement paths or animations.\nThe black-screen transition between rounds has a fixed duration and cannot be customized in the level.';

  @override
  String get statueMazeDisplayTime =>
      'Initial reveal time (DisplayTime; seconds)';

  @override
  String get statueMazeTargetNum => 'Zombie count (TargetNum)';

  @override
  String get statueMazeBonusLife => 'Extra attempts (BonusLife)';

  @override
  String get statueMazeWaitDuration =>
      'Total step duration (WaitDuration; seconds)';

  @override
  String get statueMazeRotateTime => 'Rotation duration (RotateTime; seconds)';

  @override
  String get statueMazeAddSet => 'Add round';

  @override
  String get statueMazeSets => 'Rotation rounds';

  @override
  String get statueMazeRotations => 'Rotation steps';

  @override
  String get statueMazeGridSize => 'Array size';

  @override
  String get statueMazeNoRotations => 'No rotation steps added';

  @override
  String get moduleHelpStatueMazeRotationsBody =>
      'Each round can contain multiple rotation steps. Each step rotates the entire array by 90°. “C” means clockwise and “AC” means counterclockwise. Tap the play button below the grid to preview all rotation steps in the current round.';

  @override
  String get statueMazeRotationsHint =>
      'Tap the arrow to switch rotation direction. Tap a card to edit that step’s parameters. Long-press a card to delete the step.';

  @override
  String get statueMazeRemoveRotationConfirm => 'Remove this rotation step?';

  @override
  String get camelGenerationParameters => 'Spawn parameters';

  @override
  String get camelSpawnDistance => 'Spawn distance';

  @override
  String get camelSpawnPreview => 'Spawn distance preview';

  @override
  String get camelSpawnCoordinatesHint =>
      'Horizontal coordinates start at 0 at the left edge of column 1, with 64 units per tile. Colored lines mark the spawn distance parameters. The extra backward offset only applies when zombies already occupy the spawn position.';

  @override
  String get camelCompatibilityWarning =>
      'This module only supports levels that use the special Mummy Memory Camel Zombies and a Seed Bank in Preset mode. The game will crash if other zombies appear or the Seed Bank uses Chooser mode.';

  @override
  String get camelHelpSpawningTitle => 'Spawn behavior';

  @override
  String get camelHelpTutorialTitle => 'Show tutorial dialogue';

  @override
  String get camelHelpTipsTitle => 'Friendly Reminder';

  @override
  String get moduleHelpCamelTutorialBody =>
      'Enable “Show tutorial dialogue” to have Crazy Dave and Penny explain how to win by matching pairs before the level starts. The dialogue is fixed to the story shown when playing Ancient Egypt - Day 7 for the first time.';

  @override
  String get moduleHelpCamelTipsBody =>
      'This module only supports levels that use the special Mummy Memory Camel Zombies and a Seed Bank in Preset mode. The game will crash if other zombies appear or the Seed Bank uses Chooser mode.\nPlants can interact with Mummy Memory Camel Zombies normally, but these zombies may have animation issues when hypnotized or defeated, among other situations.';

  @override
  String get conflictDesc_CamelMinigameChooser =>
      'Mummy Memory conflicts with the Seed Bank’s Chooser mode and will crash the level. Switch the Seed Bank to Preset mode.';

  @override
  String get moduleTitle_CamelMinigameProperties => 'Mummy Memory';

  @override
  String get moduleDesc_CamelMinigameProperties =>
      'Configures the spawn range and parameters of Camel Zombies in Mummy Memory';

  @override
  String get moduleHelpCamelOverviewBody =>
      'An Ancient Egypt-exclusive minigame. Special Mummy Memory Camel Zombies emerge from the ground. Tap a zombie to flip its sign and reveal a symbol, then find its match. Matching two symbols immediately defeats both zombies. If the symbols differ, the signs flip back and the zombies keep moving. If only one zombie remains, or the last two have different symbols, they are defeated as soon as their signs are flipped.';

  @override
  String get moduleHelpCamelSpawningBody =>
      'With this module, zombies from regular spawn events, including Basic Spawner and Underwater Spawner, emerge directly from the ground. Adjust the parameters to set their spawn range. Horizontal coordinates start at 0 at the left edge of column 1, with 64 units per tile. This spawn behavior does not affect zombies generated through other events or modules, such as Sandstorm, Transport Boat Assault, or Grid Item Spawn.';

  @override
  String get camelAdditionalXBuffer =>
      'Extra backward offset for occupied spawn positions (AdditionalXBufferBetweenChains)';

  @override
  String get camelRiseStagger =>
      'Rise interval between adjacent Camel Zombies in a group (CamelSegmentRiseStagger; seconds)';

  @override
  String get camelCardMatchTime =>
      'Response time after a successful match (CardMatchTime; seconds)';

  @override
  String get camelCardMatchingTime =>
      'Sign flip time (CardMatchingTime; seconds)';

  @override
  String get camelCardNoMatchTime =>
      'Idle time after mismatched symbols or a single flipped sign (CardNoMatchTime; seconds)';

  @override
  String get camelCardTypesUsed => 'Symbol types (CardTypesUsed)';

  @override
  String get camelTutorialRiseDelay =>
      'Time to emerge from the ground (InitialTutorialZombieRiseDelay; seconds)';

  @override
  String get camelMaxSpawnX => 'Maximum spawn distance (MaxSpawnX)';

  @override
  String get camelMinSpawnXEnd =>
      'Maximum spawn distance end position (MinSpawnXEnd)';

  @override
  String get camelMinSpawnXStart =>
      'Minimum spawn distance start position (MinSpawnXStart)';

  @override
  String get camelShowTutorial => 'Show tutorial dialogue (ShowTutorial)';

  @override
  String get moduleTitle_OakTrainProperties => 'Oak Archery';

  @override
  String get moduleDesc_OakTrainProperties =>
      'Uses Oak Archer\'s arrows to land headshots and earn points';

  @override
  String get moduleHelpOakTrainOverviewBody =>
      'A Dark Ages-exclusive minigame. An Oak Archer is placed in column 1, row 3. Control him and use three types of arrows to land headshots on targets and win. The game is lost if Oak Archer runs out of health or a zombie reaches the house.';

  @override
  String get moduleHelpOakTrainScoresBody =>
      'Defeating different zombie types awards different scores, which are converted into coins when the level is completed. Collecting these coins has no effect when the Creative Courtyard module is in use. This score is calculated separately from the score awarded for defeating zombies by the Level Scoring module and does not count toward score challenges.';

  @override
  String get moduleHelpOakTrainArrowsBody =>
      'Oak Archer can fire three types of arrows: normal arrows hit a single target, power arrows deal double damage in a small area, and scatter arrows fire seven individual shots in a spread. When normal arrows run out, 12 are automatically reloaded after 10 seconds. Other arrows are obtained by shooting the colored Power Spheres on the lawn. Scatter arrows can also be purchased with diamonds during the level.';

  @override
  String get oakTrainTotalLife => 'Total HP (TotalLife)';

  @override
  String get oakTrainArrowScore => 'Base attack score (ArrowScore)';

  @override
  String get oakTrainWizardScore => 'Wizard kill score (WizardScore)';

  @override
  String get oakTrainArchmageScore => 'Archmage kill score (ArchmageScore)';

  @override
  String get oakTrainBossScore => 'Gargantuar boss kill score (BossScore)';

  @override
  String get oakTrainHealNum =>
      'Health restored by Green Health Spheres (HealNum)';

  @override
  String get oakTrainArrowPowerNum =>
      'Power arrows supplied by Blue Power Spheres (ArrowPowerNum)';

  @override
  String get oakTrainArrowMultipleNum =>
      'Scatter arrows supplied by Yellow Power Spheres (ArrowMultipleNum)';

  @override
  String get oakTrainInitArrowsNum => 'Initial arrow counts';

  @override
  String get oakTrainInitArrowNormal => 'Normal arrows';

  @override
  String get oakTrainInitArrowPower => 'Power arrows';

  @override
  String get oakTrainInitArrowSplit => 'Scatter arrows';

  @override
  String get moduleTitle_OakTrainIntroProperties => 'Oak Archery Tutorial';

  @override
  String get moduleDesc_OakTrainIntroProperties =>
      'Introduces the basics of Oak Archery before the level begins';

  @override
  String get moduleTitle_GoldRoadProperties => 'Golden Road';

  @override
  String get moduleDesc_GoldRoadProperties =>
      'Turns the first and fifth rows into unsodded areas';

  @override
  String get goldRoadNonLostCityLawnWarningTitle => 'Lawn appearance notice';

  @override
  String get goldRoadNonLostCityLawnWarning =>
      'Golden Road is a Lost City minigame module, so its unsodded areas feature the sun pattern specific to the Lost City lawn. Using it with other lawn appearances may affect the overall look of the level.';

  @override
  String get goldRoadDeepseaLawnWarningTitle => 'Lawn compatibility notice';

  @override
  String get goldRoadDeepseaLawnWarning =>
      'Golden Road only turns the first and fifth rows into unsodded areas. This also applies to six-row lawns with an Underwater World appearance, so keep this in mind when using the module.';

  @override
  String get moduleHelpOakTrainZombiesBody =>
      'The zombies designed for this module are dedicated variants with abilities that differ from their regular tower-defense counterparts. They appear through the Wave Generator with Rise from Ground enabled. Their abilities do not work in regular Wave Manager events such as Basic Spawner and Underwater Spawner. Use Ground Spawner or custom zombies to achieve similar effects.\nThe Power Spheres that supply arrows are also zombies internally. Their abilities depend on both Oak Archery and Rise from Ground; spawning them outside these conditions may cause missing textures or effects.';

  @override
  String get oakTrainHealthTitle => 'Oak Archer health';

  @override
  String get oakTrainScoresTitle => 'Scoring';

  @override
  String get oakTrainArrowsTitle => 'Arrow supplies';

  @override
  String get oakTrainHelpArrowsTitle => 'Arrow types';

  @override
  String get oakTrainHelpScoresTitle => 'Scoring rules';

  @override
  String get oakTrainHelpZombiesTitle => 'Special zombies';

  @override
  String waveGeneratorColumnOption(int number, String index) {
    return 'Column $number ($index)';
  }

  @override
  String waveGeneratorRowOption(int number, String index) {
    return 'Row $number ($index)';
  }

  @override
  String waveGeneratorDelaySummary(String seconds) {
    return 'This wave spawns after a ${seconds}s delay';
  }

  @override
  String waveGeneratorDelayInactiveSummary(String seconds) {
    return 'Spawn delay: ${seconds}s (inactive without Rise from Ground)';
  }

  @override
  String waveGeneratorPositionSummary(String column, String row) {
    return 'Spawn position: $column, $row';
  }

  @override
  String get waveGeneratorPositionUnset => 'Not set';

  @override
  String get oakTrainTutorialIntroWarningTitle =>
      'Module compatibility warning';

  @override
  String get oakTrainTutorialIntroWarning =>
      'Oak Archery Tutorial conflicts with the Intro Animation module. Using them together causes zombies to spawn before the tutorial ends.';

  @override
  String statueMazeMissingRotationsWarning(String rounds) {
    return 'Bemarbled rounds $rounds have no rotation steps, which will crash the level. Add at least one rotation step to each round.';
  }

  @override
  String get moduleHelpStatueMazeCompatibilityTitle => 'Compatibility';

  @override
  String get moduleHelpStatueMazeCompatibilityBody =>
      'Bemarbled can coexist with many modules. Normally, the level will not end until Bemarbled\'s win condition is also met. However, certain modules, such as Level Timer, may trigger an earlier ending. Keep this in mind when combining them.';

  @override
  String get autosaveZombossAction =>
      'Save changes automatically when leaving custom Zomboss mech actions';

  @override
  String get autosavePortal =>
      'Save changes automatically when leaving custom portals';

  @override
  String get autosaveResilienceShield =>
      'Save changes automatically when leaving custom resilience shields';

  @override
  String get autosavePreviewImage =>
      'Save the image automatically when leaving the preview generator';

  @override
  String get autosaveExit => 'Exit';

  @override
  String get automaticallySaved => 'Automatically saved';

  @override
  String automaticallySavedTo(String path) {
    return 'Automatically saved to: $path';
  }
}
