// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Russian (`ru`).
class AppLocalizationsRu extends AppLocalizations {
  AppLocalizationsRu([String locale = 'ru']) : super(locale);

  @override
  String get error => 'Ошибка';

  @override
  String get warning => 'Предупреждение';

  @override
  String get info => 'Информация';

  @override
  String get success => 'Успех';

  @override
  String get previewTabPlants => 'Растения';

  @override
  String get previewTabZombies => 'Зомби';

  @override
  String get previewTabGridItems => 'Объекты';

  @override
  String get overviewPresetPlants => 'Предустановленные растения';

  @override
  String get overviewPresetZombies => 'Предустановленные зомби';

  @override
  String get overviewConveyorPlants => 'Растения конвейера';

  @override
  String get overviewLawn => 'Поле';

  @override
  String get overviewWhitelist => 'Белый список';

  @override
  String get overviewBlacklist => 'Чёрный список';

  @override
  String get overviewPlantBlacklist => 'Чёрный список растений';

  @override
  String get overviewZombieWhitelist => 'Белый список зомби';

  @override
  String get overviewSeedChooser => 'Выбор семян';

  @override
  String get overviewReservedColumns => 'Зарезервированные столбцы';

  @override
  String get sunBombFalling => 'Падают солнечные бомбы';

  @override
  String get sunDroppingActive => 'Солнце падает с неба';

  @override
  String get sunDroppingInactive => 'Солнце не падает с неба';

  @override
  String get conveyorChanges => 'Изменения в конвейере';

  @override
  String get willBeAdded => 'добавится';

  @override
  String get willBeRemoved => 'удалится';

  @override
  String get waveNumberLegend => 'Цифра — номер волны';

  @override
  String get expand => 'Развернуть';

  @override
  String get obtainableInLevel => 'Можно получить на уровне';

  @override
  String get allZombiesInLevel => 'Все зомби на уровне';

  @override
  String get allObjectsInLevel => 'Все объекты на уровне';

  @override
  String get allEventsInLevel => 'Все события на уровне';

  @override
  String get overwhelmLabel => 'Заполнение колонн';

  @override
  String get fastEntryLabel => 'Быстрый вход';

  @override
  String get zombieRushLabel => 'Таймер уровня';

  @override
  String get spermWhaleLabel => 'Приближение кита';

  @override
  String get witchLabel => 'Появление тыквенных ведьм';

  @override
  String get lawnMowerLabel => 'Газонокосилки';

  @override
  String get lawnMowerTypeLabel => 'Тип газонокосилок';

  @override
  String get renaissanceStatues => 'Статуи Ренессанса';

  @override
  String get zomboss => 'Зомбот';

  @override
  String get boss => 'Зомбосс';

  @override
  String get zombossData => 'Данные Зомбота';

  @override
  String get contentsLabel => 'Содержимое:';

  @override
  String get vaseSpawnArea => 'Зона появления ваз';

  @override
  String get guessWhoIAm => 'Угадай, кто я';

  @override
  String get plantBlackList => 'Чёрный список растений';

  @override
  String get zombieWhiteList => 'Белый список зомби';

  @override
  String get zombieWeight => 'Вес зомби';

  @override
  String get rainContent => 'Содержимое дождя';

  @override
  String get heianWind => 'Ветер Хэйан';

  @override
  String get all => 'Все';

  @override
  String get impLv => 'Ур. импа';

  @override
  String get sortByLabel => 'Сортировка';

  @override
  String get sortByName => 'Сортировка: по имени';

  @override
  String get sortByCreationDate => 'Сортировка: по дате создания';

  @override
  String get sortByModificationDate => 'Сортировка: по дате изменения';

  @override
  String get sortBySize => 'Сортировка: по размеру';

  @override
  String get sortByFileType => 'Сортировка: по типу файла';

  @override
  String impsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count импов',
      many: '$count импов',
      few: '$count импа',
      one: '1 имп',
    );
    return '$_temp0';
  }

  @override
  String get dropShip => 'Воздушный сброс';

  @override
  String get totalLabel => 'Всего';

  @override
  String get totalPlantFoodTooltip =>
      'Всего подкормки на уровне (включая дроп и события)';

  @override
  String get appTitle => 'Моё рабочее пространство';

  @override
  String get about => 'О программе';

  @override
  String get refresh => 'Обновить';

  @override
  String get toggleTheme => 'Переключить тему';

  @override
  String get switchFolder => 'Сменить папку';

  @override
  String get clearCache => 'Очистить кэш';

  @override
  String get autosave => 'Автосохранение';

  @override
  String get autosaveOn => 'Автосохранение: вкл.';

  @override
  String get autosaveOff => 'Автосохранение: выкл.';

  @override
  String get autosaveSubtitle =>
      'Сохранять автоматически при выходе из редактора';

  @override
  String get ultra => 'Ультра';

  @override
  String get uiSize => 'Размер интерфейса';

  @override
  String get aboutSoftware => 'О программе';

  @override
  String get pluginsTitle => 'Плагины';

  @override
  String get pluginInstallNew => 'Установить новый плагин';

  @override
  String get pluginInstallFromDevice => 'Установить с устройства';

  @override
  String get pluginInstallFromUrl => 'Установить по URL';

  @override
  String get pluginInstallFromFolder => 'Загрузить папку (отладка)';

  @override
  String get pluginUrlHint => 'https://example.com/my_plugin.cplugin';

  @override
  String get pluginDownload => 'Скачать';

  @override
  String get pluginInstalling => 'Установка плагина…';

  @override
  String pluginDownloadProgress(String received, String total) {
    return 'Загрузка $received / $total';
  }

  @override
  String pluginDownloadProgressUnknown(String received) {
    return 'Загрузка $received';
  }

  @override
  String pluginInstallSuccess(String name) {
    return 'Установлен $name';
  }

  @override
  String pluginInstallFailed(String error) {
    return 'Ошибка установки: $error';
  }

  @override
  String pluginInvalidFile(String reason) {
    return 'Неверный плагин: $reason';
  }

  @override
  String get pluginInvalidUrl => 'Введите корректный http(s) URL';

  @override
  String get pluginReadFailed => 'Не удалось прочитать выбранный файл';

  @override
  String get pluginTrustWarningTitle => 'Предупреждение';

  @override
  String get pluginTrustWarningBody =>
      'Плагины выполняют код внутри C-Editor. Устанавливайте плагины только из доверенных источников. Доступ к файлам и сети по умолчанию ограничен, но вредоносные плагины всё ещё могут нарушить работу интерфейса редактора.';

  @override
  String get pluginInstalledSection => 'Установленные плагины';

  @override
  String get pluginScreensSection => 'Функции и экраны';

  @override
  String get pluginEmpty =>
      'Плагины ещё не установлены. Установите файл .cplugin с устройства или по ссылке.';

  @override
  String get pluginNoScreens => 'Этот плагин не регистрирует экраны.';

  @override
  String get pluginUninstall => 'Удалить';

  @override
  String get pluginUninstallTitle => 'Удалить плагин';

  @override
  String pluginUninstallConfirm(String name) {
    return 'Удалить $name с этого устройства?';
  }

  @override
  String get pluginLoadError => 'Ошибка загрузки';

  @override
  String get pluginBundledBadge => 'Встроенный';

  @override
  String get pluginImportedBadge => 'Установленный';

  @override
  String get pluginsFolderReserved =>
      'Имя папки \".plugins\" зарезервировано для плагинов редактора. Выберите другое имя.';

  @override
  String get pluginNoLibraryForInstall =>
      'Сначала выберите папку рабочего пространства, затем установите плагины.';

  @override
  String pluginShowingCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Показано $count плагинов',
      many: 'Показано $count плагинов',
      few: 'Показано $count плагина',
      one: 'Показан $count плагин',
    );
    return '$_temp0';
  }

  @override
  String get pluginSearchHint => 'Поиск плагинов';

  @override
  String get pluginSelectHint =>
      'Выберите плагин, чтобы увидеть сведения, настройки и функции.';

  @override
  String get pluginEnabled => 'Включён';

  @override
  String get pluginDisabled => 'Выключен';

  @override
  String get pluginAuthors => 'Авторы';

  @override
  String get pluginContributors => 'Участники';

  @override
  String pluginByAuthors(String authors) {
    return 'Авторы: $authors';
  }

  @override
  String get pluginLicense => 'Лицензия';

  @override
  String pluginVersionLabel(String version) {
    return 'v$version';
  }

  @override
  String get pluginIdLabel => 'ID';

  @override
  String get pluginLinks => 'Ссылки';

  @override
  String get pluginLinkWebsite => 'Сайт';

  @override
  String get pluginLinkIssues => 'Issues';

  @override
  String get pluginLinkSource => 'Исходный код';

  @override
  String get pluginLinkDiscord => 'Discord';

  @override
  String get pluginIncompatibleWith => 'Несовместим с';

  @override
  String get pluginOpenScreen => 'Открыть';

  @override
  String get pluginOpenSettings => 'Настройки';

  @override
  String get pluginInstallAction => 'Установить';

  @override
  String get pluginConfigurable => 'Настраиваемый';

  @override
  String get pluginFeaturesSection => 'Функции и экраны';

  @override
  String get pluginNoDescription => 'Описание не указано.';

  @override
  String get pluginSettingsUnavailable =>
      'У этого плагина нет экрана настроек.';

  @override
  String get share => 'Поделиться';

  @override
  String shareLevelFileText(String name) {
    return 'Файл уровня: $name';
  }

  @override
  String get shareLevelFailed => 'Не удалось поделиться файлом уровня';

  @override
  String get shareAsFile => 'Поделиться файлом';

  @override
  String get shareAsPreview => 'Поделиться превью';

  @override
  String get selectBackground => 'Выберите фон';

  @override
  String get autoSelectBackground => 'Автоподбор';

  @override
  String get customBackground => 'Свой фон';

  @override
  String get selectPlantList => 'Выберите список растений';

  @override
  String get levelContainsCustomZombies =>
      'В уровне присутствуют кастомные зомби';

  @override
  String get generatingPreview => 'Создание превью...';

  @override
  String get saveToGallery => 'Сохранить в галерею';

  @override
  String get imageSavedSuccessfully => 'Изображение успешно сохранено';

  @override
  String get shareOptionTitle => 'Как поделиться?';

  @override
  String get selectLevelType => 'Выберите тип уровня';

  @override
  String get autoSelectLevelType => 'Выбор заранее';

  @override
  String get manualSelectLevelType => 'Выбор игроком';

  @override
  String get levelTypeAdventure => 'Приключение';

  @override
  String get levelTypeLastStand => 'Последний рубеж';

  @override
  String get levelTypeConveyor => 'Конвейер';

  @override
  String get levelTypeSeedRain => 'Дождь из семян';

  @override
  String get levelTypeIPlant => 'Я растение';

  @override
  String get levelTypeOldStyle => 'Старый тип';

  @override
  String get levelTypeUnknown => 'Неизвестно';

  @override
  String get selectFolder => 'Выбрать папку';

  @override
  String get storagePermissionHint =>
      'Требуется разрешение на доступ к хранилищу. Включите «Разрешить управление всеми файлами» в настройках.';

  @override
  String get storagePermissionDialogTitle =>
      'Требуется разрешение на хранилище';

  @override
  String get storagePermissionDialogMessage =>
      'Приложению необходим доступ к внешнему хранилищу для открытия и сохранения файлов уровней. Пожалуйста, предоставьте разрешение «Управление всеми файлами» в настройках.';

  @override
  String get storagePermissionGoToSettings => 'Перейти в настройки';

  @override
  String get storagePermissionDeny => 'Отказать';

  @override
  String get initSetup => 'Начальная настройка';

  @override
  String get selectFolderPrompt => 'Выберите папку для хранения уровней.';

  @override
  String get selectFolderButton => 'Выбрать папку';

  @override
  String get uploadToWebsite => 'Загрузить на сайт';

  @override
  String get importFiles => 'Импортировать файлы';

  @override
  String get importFolder => 'Импортировать папку';

  @override
  String get importFolderEmpty => 'В выбранной папке нет файлов уровней';

  @override
  String importFolderSuccess(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Импортировано $count уровней',
      many: 'Импортировано $count уровней',
      few: 'Импортировано $count уровня',
      one: 'Импортирован $count уровень',
    );
    return '$_temp0';
  }

  @override
  String get importFilesUnreadable =>
      'Не удалось прочитать выбранные файлы. Попробуйте меньшие файлы или другой браузер.';

  @override
  String get importFolderUnsupported =>
      'Импорт папки не поддерживается в этом браузере.';

  @override
  String get uploadLevelPickerTitle =>
      'Выберите один или несколько уровней для загрузки';

  @override
  String get smartUploadTitle => 'Дубликат файла';

  @override
  String smartUploadFileMessage(String fileName) {
    return 'Этот файл уже есть в вашем рабочем пространстве:\n\n$fileName\n\nЧто сделать?';
  }

  @override
  String get smartUploadSkip => 'Не загружать';

  @override
  String get smartUploadOverwrite => 'Перезаписать';

  @override
  String get smartUploadAsCopy => 'Загрузить как копию';

  @override
  String get smartUploadSkipAll => 'Не загружать все';

  @override
  String get smartUploadOverwriteAll => 'Перезаписать все';

  @override
  String get smartUploadCopyAll => 'Загрузить все как копии';

  @override
  String get localFileKeepTitle => 'Сохранить уровень из браузера?';

  @override
  String localFileKeepMessage(String fileName) {
    return 'Этот уровень хранится только в браузере:\n\n$fileName\n\nСохранить его при подключении локальной папки?';
  }

  @override
  String get localFileKeep => 'Сохранить';

  @override
  String get localFileDiscard => 'Удалить';

  @override
  String get localFileKeepAll => 'Сохранить все';

  @override
  String get localFileDiscardAll => 'Удалить все';

  @override
  String get openFolder => 'Открыть папку';

  @override
  String get levelLibraryPath => 'Папка рабочего пространства';

  @override
  String get levelLibraryPathHint =>
      'Уровни хранятся в этой папке. На iOS можно выбрать любую папку — доступ сохраняется после перезапуска.';

  @override
  String get pathCopied => 'Путь скопирован в буфер обмена';

  @override
  String get useDefaultLibraryFolder => 'Использовать папку по умолчанию';

  @override
  String get emptyFolder => 'Папка пуста';

  @override
  String get newFolder => 'Новая папка';

  @override
  String get newLevel => 'Новый уровень';

  @override
  String get rename => 'Переименовать';

  @override
  String get delete => 'Удалить';

  @override
  String get copy => 'Копировать';

  @override
  String get download => 'Скачать';

  @override
  String get downloadAllLevels => 'Экспорт рабочей области';

  @override
  String get downloadFolder => 'Скачать эту папку';

  @override
  String get exportLevels => 'Экспорт уровней';

  @override
  String get exportSelectLevels => 'Выберите уровни для экспорта';

  @override
  String get exportSelectFile =>
      'Выберите архив уровней для экспорта (.rsb.smf)';

  @override
  String exportSelectedFile(String path) {
    return 'Выбранный файл: $path';
  }

  @override
  String get backupRecommendationTitle =>
      'Рекомендация по резервному копированию';

  @override
  String get backupRecommendationBody =>
      'Настоятельно рекомендуется создать резервную копию архива уровней перед экспортом. Это поможет избежать потери данных в случае прерывания операции.';

  @override
  String get backupAndProceed => 'Создать копию и продолжить';

  @override
  String get proceedWithoutBackup => 'Продолжить без копии';

  @override
  String get backupSuffix => '_копия';

  @override
  String get exportNoFilesFound => 'Нужные файлы не найдены (.rsb.smf).';

  @override
  String get exportDownloadExternalDynamic => 'Скачать dynamic…';

  @override
  String get cancelExportTitle => 'Отмена экспорта';

  @override
  String get cancelExportMessage =>
      'Вы уверены, что хотите прервать процесс экспорта?';

  @override
  String get exportDisclaimerTitle =>
      'Предупреждение о рисках и отказ от ответственности';

  @override
  String get exportDisclaimerBody =>
      'Данный инструмент предназначен для прямого изменения данных игры «Plants vs. Zombies 2».\n\n• Использование этого инструмента для изменения игровых данных может нарушать условия обслуживания игры.\n• Это может привести к временной или постоянной блокировке вашей игровой учетной записи.\n• Это может привести к повреждению игровых сохранений или потере данных.\n• Все действия совершаются пользователем добрововольно, на свой страх и риск.\n\nОтказ от ответственности:\n\nРазработчик настоящим заявляет:\n1. Данный инструмент предназначен только для ознакомления и исследований; любые формы читерства в игре не поощряются.\n2. Все последствия использования данного инструмента, включая, помимо прочего, блокировку аккаунта, потерю данных и ухудшение игрового процесса, ложатся исключительно на пользователя. Разработчик не несет никакой прямой или косвенной ответственности.\n3. Пользователи должны полностью осознавать связанные с этим риски перед использованием данного инструмента и самостоятельно принимать решение о принятии этих рисков.\n4. Дальнейшее использование означает, что вы прочитали, поняли и согласны со всеми условиями данного отказа от ответственности.';

  @override
  String get exportDisclaimerDoNotShowAgain =>
      'Больше не показывать по умолчанию';

  @override
  String get importProgressTitle => 'Импорт файлов…';

  @override
  String get exportProgressTitle => 'Подготовка экспорта…';

  @override
  String get exportPackageProgressTitle => 'Экспорт пакета данных…';

  @override
  String get backupProgressTitle => 'Создание резервной копии…';

  @override
  String transferProgressCount(int completed, int total) {
    return '$completed / $total';
  }

  @override
  String get folderAccessError =>
      'Выбранная папка доступна только для чтения или недоступна. Пожалуйста, выберите другую папку.';

  @override
  String get webFolderImportNotice =>
      'Папка импортирована в хранилище браузера. В этом браузере изменения не записываются на диск автоматически — используйте «Экспорт».';

  @override
  String get favorite => 'В избранное';

  @override
  String get unfavorite => 'Убрать из избранного';

  @override
  String get move => 'Переместить';

  @override
  String get cancel => 'Отмена';

  @override
  String get confirm => 'Подтвердить';

  @override
  String get convert => 'Преобразовать';

  @override
  String get convertHelpTooltip =>
      'Преобразование между JSON, HUJSON (хот-апдейт) и зашифрованным RTON (dynamic.rsb.smf).';

  @override
  String get create => 'Создать';

  @override
  String get newName => 'Новое имя';

  @override
  String get folderName => 'Имя папки';

  @override
  String get confirmDelete => 'Подтвердить удаление';

  @override
  String confirmDeleteMessage(String name, String detail) {
    return 'Вы уверены, что хотите удалить «$name»? $detail';
  }

  @override
  String get folderDeleteDetail =>
      'Если это папка, её содержимое также будет удалено.';

  @override
  String get levelDeleteDetail => 'Это действие нельзя отменить.';

  @override
  String get confirmDeleteCheckbox => 'Я подтверждаю безвозвратное удаление';

  @override
  String get renameSuccess => 'Успешно переименовано';

  @override
  String get renameFail => 'Ошибка переименования, файл уже существует';

  @override
  String get uploadLevel => 'Опубликовать на Креаторскую Площадку';

  @override
  String get uploadLevelConfirm =>
      'Сейчас вы покинете редактор и перейдёте на официальный сайт продвинутой Креаторской Площадки. После регистрации/входа через эл. почту, вы сможете загружать JSON файлы уровней из редактора прямо в игровую Креаторскую Площадку, чтобы другие люди могли сыграть в ваш уровень. Хотите продолжить?';

  @override
  String get back => 'Назад';

  @override
  String get noLevelsFound => 'Уровни не найдены';

  @override
  String get searchLevel => 'Поиск уровней...';

  @override
  String get proceed => 'Продолжить';

  @override
  String get startExport => 'Приступить';

  @override
  String get exportProceed => 'Продолжить';

  @override
  String get exportBegin => 'Приступить';

  @override
  String get exportStatusCreatingRton => 'Создание RTON уровней...';

  @override
  String get exportStatusUnpackingRsb => 'Распаковка RSB...';

  @override
  String get exportStatusUnpackingRsg => 'Распаковка Packages.rsg...';

  @override
  String get exportStatusInjecting => 'Инъекция уровней...';

  @override
  String get exportStatusRepackingRsg => 'Запаковка RSG...';

  @override
  String get exportStatusRepackingRsb => 'Запаковка RSB...';

  @override
  String get exportStatusFinalizing => 'Завершение...';

  @override
  String get exportAssignmentProposalTitle => 'Распределение уровней';

  @override
  String get exportDifficultyReplacementNotice =>
      'Если в целевом слоте обычный режим и сложный/экспертный режим фактически используют разные уровни, редактор заменит только уровень обычного режима.';

  @override
  String get exportWorld => 'Мир';

  @override
  String get exportLevelNumber => 'Номер уровня';

  @override
  String exportLevelShort(int level) {
    return 'ур. $level';
  }

  @override
  String get exportFinish => 'Завершить';

  @override
  String get exportSuccessTitle => 'Экспорт завершён';

  @override
  String exportSuccessMessage(String file) {
    return 'Мод для тестирования уровня успешно создан: $file.\nЗамените соответствующий файл игры созданным пакетом данных, затем откройте свой уровень через слот исходного уровня, который был заменён.\nПримечание: 1. Перед заменой полностью завершите процесс игры.\n2. После замены, но до запуска игры, полностью закройте редактор и все файловые менеджеры, использующие целевую папку.';
  }

  @override
  String get exportCancelled => 'Экспорт отменён.';

  @override
  String exportDuplicateAssignment(String world, int level) {
    return 'Повторяющееся распределение: $world $level';
  }

  @override
  String get exportAssignmentIncomplete => 'Не все уровни распределены';

  @override
  String get exportConfirmationTitle => 'Подтвердите выбор';

  @override
  String get exportConfirmationBody =>
      'Пожалуйста, проверьте распределение перед продолжением.';

  @override
  String get exportFinalCheckTitle => 'Финальная проверка';

  @override
  String get exportFinalCheckBody =>
      'Следующие уровни будут экспортированы с новыми именами:';

  @override
  String exportTargetArchive(String file) {
    return 'Все уровни будут экспортированы в $file';
  }

  @override
  String get exportStart => 'Начать экспорт';

  @override
  String get exportAssignmentProposalBody =>
      'Выбранные уровни проверены. Теперь необходимо выбрать, какой слот в приключении будет занимать каждый из них.';

  @override
  String get copyReferenceOrDeep =>
      'Скопировать ссылку или создать полную копию?';

  @override
  String get copyReference => 'Скопировать ссылку';

  @override
  String get deepCopy => 'Полная копия';

  @override
  String get discordLabel => 'Наш Discord сервер:';

  @override
  String get comingSoon => 'Скоро';

  @override
  String get allLevelsCategory => 'Все';

  @override
  String get favoritesCategory => 'Избранное';

  @override
  String get newFolderNameHint => 'Оставьте пустым для имени по умолчанию';

  @override
  String get emptyFavorites => 'У вас пока нет избранных уровней';

  @override
  String get copyEventTarget => 'Целевая волна';

  @override
  String get targetWaveIndex => 'Номер целевой волны';

  @override
  String get targetWaveAlreadyContainsEvent =>
      'Эта волна уже содержит это событие';

  @override
  String get targetWaveIndexHelper =>
      'При копировании ссылок волны, которые уже содержат это событие, пропускаются автоматически.';

  @override
  String get moveToWaveIndex => 'Переместить в волну №';

  @override
  String get invalidWaveIndex => 'Неверный номер волны';

  @override
  String get renamingFailed => 'Ошибка переименования';

  @override
  String get deleted => 'Удалено';

  @override
  String get copyLevel => 'Копировать уровень';

  @override
  String get newFileName => 'Новое имя файла';

  @override
  String get copySuccess => 'Копирование выполнено';

  @override
  String get copyFail => 'Ошибка копирования';

  @override
  String moving(String name) {
    return 'Перемещение: $name';
  }

  @override
  String get movePrompt => 'Перейдите в целевую папку и нажмите «Вставить»';

  @override
  String get paste => 'Вставить';

  @override
  String get movingSuccess => 'Файл перемещён';

  @override
  String get movingFail => 'Ошибка перемещения';

  @override
  String get moveSameFolder => 'Исходная и целевая папки совпадают';

  @override
  String get moveFileExistsTitle => 'Файл уже существует';

  @override
  String get moveFileExistsMessage =>
      'В целевой папке уже есть файл с таким именем.';

  @override
  String get moveOverwrite => 'Перезаписать';

  @override
  String fileOverwritten(String name) {
    return 'Файл перезаписан: $name';
  }

  @override
  String get moveSaveAsCopy => 'Сохранить как копию';

  @override
  String get moveCancelled => 'Операция отменена';

  @override
  String movedAs(String name) {
    return 'Перемещено и сохранено как $name';
  }

  @override
  String get folderCreated => 'Папка создана';

  @override
  String get createFail => 'Ошибка создания';

  @override
  String get noTemplates => 'Шаблоны не найдены';

  @override
  String get newLevelTemplate => 'Новый уровень — выбор шаблона';

  @override
  String get nameLevel => 'Название уровня';

  @override
  String get levelCreated => 'Уровень создан';

  @override
  String get levelCreateFail => 'Ошибка создания, файл уже существует';

  @override
  String get templateLoadFail => 'Не удалось загрузить выбранный шаблон уровня';

  @override
  String get adjustUiSize => 'Настроить размер интерфейса';

  @override
  String currentScale(String percent) {
    return 'Текущий масштаб: $percent%';
  }

  @override
  String get small => 'Малый';

  @override
  String get standard => 'Стандартный';

  @override
  String get large => 'Большой';

  @override
  String get done => 'Готово';

  @override
  String get reset => 'Сброс';

  @override
  String cacheCleared(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Очищено $count файлов в кэше',
      many: 'Очищено $count файлов в кэше',
      few: 'Очищено $count файла в кэше',
      one: 'Очищен $count файл в кэше',
    );
    return '$_temp0';
  }

  @override
  String get returnUp => 'Назад';

  @override
  String get jsonFile => 'JSON-файл';

  @override
  String get convertToJson => 'Преобразовать в JSON';

  @override
  String get convertToHotUpdateJson => 'Преобразовать в hot update json';

  @override
  String get convertToEncryptedRton => 'Преобразовать в зашифрованный rton';

  @override
  String get hujsonFormatDescription =>
      'Формат для хот-апдейта. Внутри использует PopCap CompiledText (JSON уровня с zlib-сжатием и шифрованием Rijndael). Перед импортом в игру переименуйте расширение с .hujson на .json.';

  @override
  String get rtonFormatDescription =>
      'Бинарный формат PopCap RTON (шифрование Rijndael). Используется для данных уровней в dynamic.rsb.smf.';

  @override
  String get conversionRequiredTitle => 'Требуется преобразование';

  @override
  String get conversionRequiredMessage =>
      'Этот файл нужно преобразовать в JSON, прежде чем его можно открыть в редакторе.';

  @override
  String get convertAction => 'Преобразовать';

  @override
  String get conversionFailed => 'Преобразование не удалось';

  @override
  String convertedMessage(String name) {
    return 'Преобразовано: $name';
  }

  @override
  String get softwareIntro => 'О программе';

  @override
  String get cEditor => 'C-Editor';

  @override
  String get pvzEditorSubtitle => 'Визуальный редактор уровней PVZ2';

  @override
  String get introSection => 'Введение';

  @override
  String get introText =>
      'C-Editor — визуальный редактор уровней для китайской версии Plants vs. Zombies 2. Упрощает редактирование JSON-файлов уровней с помощью интуитивного интерфейса.';

  @override
  String get featuresSection => 'Основные возможности';

  @override
  String get feature1 =>
      'Модульное редактирование: управление модулями и событиями уровня в едином интерфейсе для быстрой настройки.';

  @override
  String get feature2 =>
      'Поддержка режимов: редактирование «Я зомби», «Разбей горшки», «Несокрушимый», боёв с Зомбоссом и других режимов.';

  @override
  String get feature3 =>
      'Пользовательские объекты: добавление и управление пользовательскими зомби, полями и мехами Зомбосса внутри уровня, включая их основные свойства.';

  @override
  String get feature4 =>
      'Умная проверка: автоматическое обнаружение отсутствующих зависимостей модулей, неверных ссылок и других проблем для предотвращения сбоев уровня.';

  @override
  String get feature5 =>
      'Предпросмотр ресурсов: встроенные значки растений, зомби и объектов поля делают редактирование нагляднее.';

  @override
  String get usageSection => 'Использование';

  @override
  String get usageText =>
      '1. Папка: при первом запуске нажмите значок папки в правом верхнем углу и выберите каталог с JSON-файлами уровней.\n2. Открыть/Создать: нажмите уровень в списке для редактирования или используйте кнопку ниже, чтобы создать новый уровень из шаблона.\n3. Модули: используйте «Добавить новый модуль» в редакторе, чтобы расширять возможности уровня.\n4. Сохранить: после редактирования нажмите кнопку сохранения в правом верхнем углу — изменения автоматически запишутся в исходный JSON-файл.\n5. Преобразование файлов уровней: JSON можно конвертировать в HUJSON для хот-апдейта (перед импортом вручную смените расширение с .hujson на .json) или в зашифрованный RTON для использования в dynamic.rsb.smf.\n6. Плагины: плагины запускают дополнительный код и добавляют новые функции и интерфейсы, расширяя возможности редактора. Помимо встроенных плагинов, новые можно получить, установив локальный файл .cplugin или введя URL. Функции плагинов можно включать и отключать независимо.\n7. Загружайте JSON-уровни на официальном портале авторов «Продвинутого творческого двора» Plants vs. Zombies 2 (требуется вход).\n8. На странице «Creative Courtyard · Recommended Levels Showcase» можно посмотреть идентификаторы ранее рекомендованных официальных уровней и причины их выбора. Игра в эти уровни поддерживает их авторов и помогает улучшить собственные навыки проектирования.\n9. Если у вас есть вопросы или нужна помощь с продвинутым созданием уровней, присоединяйтесь к Discord-серверу Plants vs. Zombies и пишите в ветке канала PvZ2C-Modding.';

  @override
  String get usageTextDesktop =>
      '1. Папка: при первом запуске щёлкните значок папки в правом верхнем углу и выберите каталог с JSON-файлами уровней.\n2. Открыть/Создать: щёлкните уровень в списке для редактирования или используйте кнопку ниже, чтобы создать новый уровень из шаблона.\n3. Модули: используйте «Добавить новый модуль» в редакторе, чтобы расширять возможности уровня.\n4. Сохранить: после редактирования щёлкните кнопку сохранения в правом верхнем углу — изменения автоматически запишутся в исходный JSON-файл.\n5. Преобразование файлов уровней: JSON можно конвертировать в HUJSON для хот-апдейта (перед импортом вручную смените расширение с .hujson на .json) или в зашифрованный RTON для использования в dynamic.rsb.smf.\n6. Плагины: плагины запускают дополнительный код и добавляют новые функции и интерфейсы, расширяя возможности редактора. Помимо встроенных плагинов, новые можно получить, установив локальный файл .cplugin или введя URL. Функции плагинов можно включать и отключать независимо.\n7. Загружайте JSON-уровни на официальном портале авторов «Продвинутого творческого двора» Plants vs. Zombies 2 (требуется вход).\n8. На странице «Creative Courtyard · Recommended Levels Showcase» можно посмотреть идентификаторы ранее рекомендованных официальных уровней и причины их выбора. Игра в эти уровни поддерживает их авторов и помогает улучшить собственные навыки проектирования.\n9. Если у вас есть вопросы или нужна помощь с продвинутым созданием уровней, присоединяйтесь к Discord-серверу Plants vs. Zombies и пишите в ветке канала PvZ2C-Modding.';

  @override
  String get usageTextMobile =>
      '1. Папка: при первом запуске нажмите значок папки в правом верхнем углу и выберите каталог с JSON-файлами уровней.\n2. Открыть/Создать: нажмите уровень в списке для редактирования или используйте кнопку ниже, чтобы создать новый уровень из шаблона.\n3. Модули: используйте «Добавить новый модуль» в редакторе, чтобы расширять возможности уровня.\n4. Сохранить: после редактирования нажмите кнопку сохранения в правом верхнем углу — изменения автоматически запишутся в исходный JSON-файл.\n5. Преобразование файлов уровней: JSON можно конвертировать в HUJSON для хот-апдейта (перед импортом вручную смените расширение с .hujson на .json) или в зашифрованный RTON для использования в dynamic.rsb.smf.\n6. Плагины: плагины запускают дополнительный код и добавляют новые функции и интерфейсы, расширяя возможности редактора. Помимо встроенных плагинов, новые можно получить, установив локальный файл .cplugin или введя URL. Функции плагинов можно включать и отключать независимо.\n7. Загружайте JSON-уровни на официальном портале авторов «Продвинутого творческого двора» Plants vs. Zombies 2 (требуется вход).\n8. На странице «Creative Courtyard · Recommended Levels Showcase» можно посмотреть идентификаторы ранее рекомендованных официальных уровней и причины их выбора. Игра в эти уровни поддерживает их авторов и помогает улучшить собственные навыки проектирования.\n9. Если у вас есть вопросы или нужна помощь с продвинутым созданием уровней, присоединяйтесь к Discord-серверу Plants vs. Zombies и пишите в ветке канала PvZ2C-Modding.';

  @override
  String get usageRecommendedLevelsLabel =>
      'Creative Courtyard · Recommended Levels Showcase:';

  @override
  String get discordInviteLabel =>
      'Ссылка-приглашение на Discord-сервер Plants vs. Zombies:';

  @override
  String get cEditorInviteLabel =>
      'Ссылка-приглашение на Discord-сервер C-Editor:';

  @override
  String get linksSubsection => 'Ссылки';

  @override
  String get creditsSection => 'Благодарности';

  @override
  String get authorLabel => 'Авторы:';

  @override
  String get authorName => 'CyberSteve777, Devourdoom, Chara';

  @override
  String get thanksLabel => 'Особая благодарность:';

  @override
  String get thanksNames =>
      'Evilhack28, Rebus, KL12, vi_i_guess, Haruma, nineteendo';

  @override
  String get sourceLabel => 'Исходный код:';

  @override
  String get issuesLabel => 'Проблемы:';

  @override
  String get zEditorAcknowledgment =>
      'Без создателей Z-Editor создание этого инструмента было бы невозможным.';

  @override
  String get zEditorCreditsSubsection => 'Благодарности Z-Editor';

  @override
  String get zEditorAuthorLabel => 'Автор:';

  @override
  String get zEditorAuthorName => '降维打击';

  @override
  String get zEditorThanksLabel => 'Благодарность:';

  @override
  String get zEditorThanksNames =>
      '星寻、metal海枣、超越自我3333、桃酱、凉沈、小小师、顾小言、PhiLia093、咖啡、不留名';

  @override
  String get zEditorQqGroupLabel => 'Z-Editor QQ-группа:';

  @override
  String get tagline => 'Создавайте бесконечные возможности';

  @override
  String editorVersion(String version) {
    return 'Версия редактора: $version';
  }

  @override
  String supportedGameVersion(String version) {
    return 'Поддерживаемая версия игры: $version';
  }

  @override
  String get language => 'Язык';

  @override
  String get languageEnglish => 'English';

  @override
  String get languageChinese => '中文';

  @override
  String get languageRussian => 'Русский';

  @override
  String get templateBlankLevel => 'Пустой уровень';

  @override
  String get templateCardPickExample => 'Пример выбора карт';

  @override
  String get templateConveyorExample => 'Пример конвейера';

  @override
  String get templateLastStandExample => 'Пример «Последнего Выжившего»';

  @override
  String get templateIZombieExample => 'Пример «Я зомби»';

  @override
  String get templateVaseBreakerExample => 'Пример «Вазобоя»';

  @override
  String get templateZombossMechExample => 'Пример боя с Зомбоссом';

  @override
  String get templateZombossBattleExample => 'Пример боя с Боссом';

  @override
  String get templateCustomZombieExample => 'Пример пользовательского зомби';

  @override
  String get templateIPlantExample => 'Пример «Я растение»';

  @override
  String get templateOldStyleExample => 'Уровень старого типа';

  @override
  String get templateCustomLawnExample => 'Пример пользовательской лужайки';

  @override
  String get unsavedChanges => 'Несохранённые изменения';

  @override
  String get saveBeforeLeaving => 'Сохранить перед выходом?';

  @override
  String get discard => 'Не сохранять';

  @override
  String get stayInEditor => 'Остаться';

  @override
  String get saved => 'Сохранено';

  @override
  String get failedToLoadLevel =>
      'Не удалось загрузить уровень.\nРекомендуется проверить, не зашифрован ли файл уровня (например, JSON-файл из горячего обновления).';

  @override
  String get noLevelDefinition => 'Определение уровня не найдено';

  @override
  String get noLevelDefinitionHint =>
      'Модуль определения уровня (LevelDefinition) не найден. Это базовый узел файла уровня. Попробуйте добавить его вручную.';

  @override
  String get levelBasicInfo => 'Основные данные уровня';

  @override
  String get levelBasicInfoSubtitle => 'Название, номер, описание, лужайка';

  @override
  String get removeModule => 'Удалить модуль';

  @override
  String get zombieCategoryMain => 'По миру';

  @override
  String get zombieCategorySize => 'По размеру';

  @override
  String get zombieCategoryOther => 'Прочее';

  @override
  String get zombieCategoryCollection => 'Моя коллекция';

  @override
  String get zombieTagAll => 'Все зомби';

  @override
  String get zombieTagEgyptPirate => 'Древний Египет/Пиратские Моря';

  @override
  String get zombieTagWestFuture => 'Дикий Запад/Далёкое Будущее';

  @override
  String get zombieTagDarkBeach => 'Тёмные Века/Пляж Большой Волны';

  @override
  String get zombieTagIceageLostcity => 'Ледниковые Пещеры/Затерянный Город';

  @override
  String get zombieTagKongfuSkycity => 'Кунг-фу Мир/Небесный город';

  @override
  String get zombieTagEightiesDino => 'Неоновый Микстейп Тур/Юрское Болото';

  @override
  String get zombieTagModernPvz1 => 'Современный День';

  @override
  String get zombieTagSteamRenai => 'Паровые Века/Эпоха Возрождения';

  @override
  String get zombieTagHeianAtlantis => 'Эпоха Хэйан/Подводный Мир';

  @override
  String get zombieTagMoon => 'Лунная База';

  @override
  String get zombieTagTaleZCorp => 'Сказочный Лес/Корпорация ZCorp';

  @override
  String get zombieTagParkourSpeed =>
      'Коллаборации (Subway Surfers и Need For Speed)';

  @override
  String get zombieTagTothewest => 'Путешествие на Запад';

  @override
  String get zombieTagMemory => 'Дорога Воспоминаний';

  @override
  String get zombieTagUniverse => 'Параллельные вселенные';

  @override
  String get zombieTagFestival1 => 'Праздники и реалмы (1)';

  @override
  String get zombieTagFestival2 => 'Праздники и реалмы (2)';

  @override
  String get zombieTagRoman => 'Римская Империя';

  @override
  String get zombieTagCustom => 'Готовые пользовательские';

  @override
  String get zombieTagExpedition => 'Варианты режима «Врата Экспедиции»';

  @override
  String get zombieTagPvp => 'Варианты PvP режима';

  @override
  String get zombieTagPet => 'Имеет питомцев (животных)';

  @override
  String get zombieTagImp => 'Бесята (импы)';

  @override
  String get zombieTagBasic => 'Базовое телосложение';

  @override
  String get zombieTagFat => 'Толстые';

  @override
  String get zombieTagStrong => 'Крепкое телосложение';

  @override
  String get zombieTagGargantuar => 'Гаргантюа';

  @override
  String get zombieTagElite => 'Элитные';

  @override
  String get zombieTagEvildave => 'Работающие в режиме «Я Зомби»';

  @override
  String get plantCategoryQuality => 'По качеству';

  @override
  String get plantCategoryRole => 'По классу';

  @override
  String get plantCategoryAttribute => 'По элементу';

  @override
  String get plantCategoryWorld => 'По миру';

  @override
  String get plantCategoryOther => 'Прочее';

  @override
  String get plantCategoryCollection => 'Моя коллекция';

  @override
  String get plantTagAll => 'Все растения';

  @override
  String get plantTagWhite => 'Обычная редкость';

  @override
  String get plantTagGreen => 'Необычная редкость';

  @override
  String get plantTagBlue => 'Редкая редкость';

  @override
  String get plantTagPurple => 'Эпическая редкость';

  @override
  String get plantTagOrange => 'Легендарная редкость';

  @override
  String get plantTagRed => 'Особая редкость';

  @override
  String get plantTagSupport => 'Поддержка';

  @override
  String get plantTagRanger => 'Дальние';

  @override
  String get plantTagSunProducer => 'Солнцедающие';

  @override
  String get plantTagDefence => 'Защитные';

  @override
  String get plantTagVanguard => 'Ближние';

  @override
  String get plantTagTrapper => 'Ловушки';

  @override
  String get plantTagFire => 'Огненные';

  @override
  String get plantTagIce => 'Ледяные';

  @override
  String get plantTagMagic => 'Магические';

  @override
  String get plantTagPoison => 'Ядовитые';

  @override
  String get plantTagElectric => 'Электрические';

  @override
  String get plantTagPhysical => 'Физический урон';

  @override
  String get plantTagWorldTutorial => 'Ваш Дом';

  @override
  String get plantTagWorldEgypt => 'Древний Египет';

  @override
  String get plantTagWorldPirate => 'Пиратские Моря';

  @override
  String get plantTagWorldWildWest => 'Дикий Запад';

  @override
  String get plantTagWorldKongfu => 'Кунг-фу Мир';

  @override
  String get plantTagWorldFuture => 'Далёкое Будущее';

  @override
  String get plantTagWorldDarkAges => 'Тёмные Века';

  @override
  String get plantTagWorldBeach => 'Пляж Большой Волны';

  @override
  String get plantTagWorldIceage => 'Ледниковые Пещеры';

  @override
  String get plantTagWorldSkycity => 'Небесный Город';

  @override
  String get plantTagWorldLostCity => 'Затерянный Город';

  @override
  String get plantTagWorldEighties => 'Неоновый Микстейп Тур';

  @override
  String get plantTagWorldDino => 'Юрские Болота';

  @override
  String get plantTagWorldModern => 'Современный День';

  @override
  String get plantTagWorldSteam => 'Паровой Век';

  @override
  String get plantTagWorldRenai => 'Эпоха Возрождения';

  @override
  String get plantTagWorldHeian => 'Эпоха Хэйан';

  @override
  String get plantTagWorldAtlantis => 'Подводный Мир';

  @override
  String get plantTagWorldMoon => 'Лунная База';

  @override
  String get plantTagWorldFairytale => 'Сказочный Лес';

  @override
  String get plantTagWorldZcorp => 'Корпорация ZCorp';

  @override
  String get plantTagWorldMausoleum => 'Подземный Дворец';

  @override
  String get plantTagOriginal => 'Есть в PvZ1';

  @override
  String get plantTagParallel => 'Параллельные Вселенные';

  @override
  String get plantTagSpecial => 'Особые';

  @override
  String get plantTagHidden => 'Скрытые';

  @override
  String get plantTagTier4 => 'Деревня 4-го уровня';

  @override
  String get plantTagInternational => 'Интернациональные';

  @override
  String get plantTagChinese => 'Китайские';

  @override
  String get removeModuleConfirm =>
      'Удалить этот модуль? Локальные модули (@CurrentLevel) и их данные будут удалены безвозвратно.';

  @override
  String get confirmRemove => 'Удалить';

  @override
  String get addModule => 'Добавить модуль';

  @override
  String get settings => 'Настройки';

  @override
  String get timeline => 'Волны';

  @override
  String get iZombie => 'Я-зомби';

  @override
  String get vaseBreaker => 'Вазобой';

  @override
  String get zombossMech => 'Бой с Зомботом';

  @override
  String get zombossBattle => 'Бой с Зомбоссом';

  @override
  String get moveSourceSameAsDest => 'Исходная и целевая папки совпадают';

  @override
  String get moveSuccess => 'Перемещение выполнено';

  @override
  String get moveFail => 'Ошибка перемещения';

  @override
  String get rootFolder => 'Корень';

  @override
  String get createEmptyWave => 'Добавить пустую волну';

  @override
  String get createEmptyWaveContainer => 'Создать пустой контейнер волн';

  @override
  String get deleteEmptyContainer => 'Удалить пустой контейнер';

  @override
  String get deleteWaveContainerTitle => 'Удалить контейнер волн?';

  @override
  String get deleteWaveContainerConfirm =>
      'Вы уверены, что хотите удалить пустой контейнер волн? Позже вы можете создать новый.';

  @override
  String get noWaveManager => 'Менеджер волн не найден';

  @override
  String get noWaveManagerHint =>
      'У уровня есть модуль волн, но отсутствует объект WaveManagerProperties.';

  @override
  String get waveTimelineHint =>
      'Нажмите на событие для редактирования. Нажмите + для добавления.';

  @override
  String get waveTimelineHintDetail => 'Смахните влево для удаления волны.';

  @override
  String get waveTimelineGuideTitle => 'Инструкция';

  @override
  String get waveTimelineGuideBody =>
      'Нажмите на волну: управление событиями\nСвайп влево: удалить волну\nНажмите на очки: ожидание по зомби';

  @override
  String get waveTimelineGuideBodyDesktop =>
      'Клик левой кнопокой мыши по волне: управление событиями\nКнопка удаления: убрать волну\nКлик по очкам: ожидание по зомби';

  @override
  String get waveTimelineGuideBodyMobile =>
      'Нажмите на волну: управление событиями\nСвайп влево: удалить волну\nНажмите на очки: ожидание по зомби';

  @override
  String get waveDeadLinksTitle => 'Неверные ссылки';

  @override
  String get waveDeadLinksClear => 'Очистить неверные ссылки';

  @override
  String get customZombieManagerTitle => 'Управление пользовательскими зомби';

  @override
  String get customZombieEmpty => 'Нет данных о пользовательских зомби';

  @override
  String get switchCustomZombie => 'Сменить пользовательского зомби';

  @override
  String get switchProperties => 'Сменить свойства';

  @override
  String get defaultPropertiesLabel => 'По умолчанию';

  @override
  String get addNewVariation => '+ Добавить вариант';

  @override
  String editCustomZombieAlias(String alias) {
    return 'Редактировать $alias';
  }

  @override
  String get switchZombie => 'Сменить зомби';

  @override
  String get customZombieAppearanceLocation => 'Появление:';

  @override
  String get customZombieNotUsed =>
      'Этот кастомный зомби не используется ни в одной волне.';

  @override
  String customZombieWaveItem(int n) {
    return 'Волна $n';
  }

  @override
  String get customZombieDeleteConfirm =>
      'Удалить этого кастомного зомби и его данные.';

  @override
  String get customZombieOrphanDeleteTitle =>
      'Удалить пользовательские свойства из уровня?';

  @override
  String customZombieOrphanDeleteMessage(String alias) {
    return '«$alias» больше не будет использоваться в этом уровне. Удалить объект типа зомби и его свойства из файла уровня? Это действие нельзя отменить.';
  }

  @override
  String get customZombieOrphanDeleteKeep => 'Оставить в уровне';

  @override
  String get customZombieOrphanDeleteErase => 'Удалить из уровня';

  @override
  String get editCustomZombieProperties =>
      'Редактировать свойства кастомного зомби';

  @override
  String get makeZombieAsCustom => 'Сделать зомби кастомным';

  @override
  String get customLabel => 'Пользовательский';

  @override
  String get moduleTitle_WaveManagerProperties =>
      'Параметры менеджера волн (WaveManagerProps)';

  @override
  String waveManagerPropsCurrent(String value) {
    return 'Текущее значение: $value';
  }

  @override
  String get waveManagerGlobalParams => 'Глобальные параметры волн';

  @override
  String get waveContainerAliasSection => 'Псевдоним контейнера волн';

  @override
  String get waveContainerAliasHint =>
      'Псевдоним объекта WaveManagerProperties, в котором хранятся данные волн.';

  @override
  String waveManagerGlobalSummary(
    int interval,
    int minPercent,
    int maxPercent,
  ) {
    return 'Интервал флага: $interval, порог здоровья: $minPercent% - $maxPercent%';
  }

  @override
  String get waveEmptyTitle => 'Список волн пуст';

  @override
  String get waveEmptySubtitle =>
      'Добавьте первую волну или удалите этот пустой контейнер.';

  @override
  String get waveHeaderPreview => 'Содержимое и очки';

  @override
  String waveTotalLabel(int total) {
    return 'Всего: $total';
  }

  @override
  String get waveEmptyRowHint =>
      'Пустая волна (нажмите для управления, перетащите сюда события)';

  @override
  String get waveEmptyRowHintDesktop =>
      'Пустая волна (нажмите для управления, перетащите сюда события)';

  @override
  String get waveEmptyRowHintMobile =>
      'Пустая волна (нажмите для управления, перетащите сюда события)';

  @override
  String get removeFromWave => 'Удалить из волны';

  @override
  String get deleteEventEntityTitle => 'Удалить объект события?';

  @override
  String get deleteEventEntityBody => 'Это удалит объект события из уровня.';

  @override
  String waveEventsTitle(int wave) {
    return 'События волны $wave';
  }

  @override
  String get waveManagerSettings => 'Настройки менеджера волн';

  @override
  String get flagInterval => 'Интервал флага';

  @override
  String get waveManagerHelpTitle => 'Менеджер волн';

  @override
  String get waveManagerHelpOverviewTitle => 'Обзор';

  @override
  String get waveManagerHelpOverviewBody =>
      'Глобальные параметры волн и пороги здоровья.';

  @override
  String get waveManagerHelpFlagTitle => 'Интервал флага';

  @override
  String get waveManagerHelpFlagBody =>
      'Каждые N волн — флаговая; последняя волна всегда флаговая.';

  @override
  String get waveManagerHelpTimeTitle => 'Контроль времени';

  @override
  String get waveManagerHelpTimeBody =>
      'Задержка первой волны зависит от наличия конвейера.';

  @override
  String get waveManagerFirstWaveDelayConveyorOnlyHint =>
      'Изменение текущей задержки первой волны действует только на уровни с конвейером; обычные уровни используют значение по умолчанию';

  @override
  String get waveManagerFirstWaveDelayConveyorOnlyHelp =>
      'Изменение текущей задержки первой волны действует только на уровни с конвейером; обычные уровни используют значение по умолчанию.';

  @override
  String get waveManagerHelpMusicTitle => 'Тип музыки';

  @override
  String get waveManagerHelpMusicBody =>
      'Только Modern; задает фиксированный фон.';

  @override
  String get waveManagerBasicParams => 'Базовые параметры';

  @override
  String get waveManagerMaxHealthThreshold => 'Макс. порог здоровья';

  @override
  String get waveManagerMinHealthThreshold => 'Мин. порог здоровья';

  @override
  String get waveManagerThresholdHint => 'Порог должен быть от 0 до 1.';

  @override
  String get waveManagerTimeControl => 'Контроль времени';

  @override
  String get waveManagerFirstWaveDelayConveyor =>
      'Задержка первой волны (конвейер; секунды)';

  @override
  String get waveManagerFirstWaveDelayNormal =>
      'Задержка первой волны (обычно; секунды)';

  @override
  String get waveManagerFlagWaveDelay => 'Задержка флаговой волны (секунды)';

  @override
  String get waveManagerConveyorDetected =>
      'Обнаружен конвейер; применена задержка конвейера.';

  @override
  String get waveManagerConveyorNotDetected =>
      'Конвейер не найден; применена обычная задержка.';

  @override
  String get waveManagerSpecial => 'Особое';

  @override
  String get waveManagerSuppressFlagZombieTitle => 'Отключить зомби с флагом';

  @override
  String get waveManagerSuppressFlagZombieField => 'SuppressFlagZombie';

  @override
  String get waveManagerSuppressFlagZombieHint =>
      'При включении флаговые волны не спавнят зомби с флагом.';

  @override
  String get waveManagerLevelJam => 'Фоновая музыка Неонового Микстейп Тура';

  @override
  String get waveManagerLevelJamHint =>
      'Только Modern; фиксированная фоновая музыка.';

  @override
  String get jamNone => 'Нет';

  @override
  String get jamPop => 'Поп';

  @override
  String get jamRap => 'Рэп';

  @override
  String get jamMetal => 'Метал';

  @override
  String get jamPunk => 'Панк';

  @override
  String get jam8Bit => '8-бит';

  @override
  String get noWaves => 'Нет волн';

  @override
  String get addFirstWave => 'Добавьте первую волну.';

  @override
  String get deleteWave => 'Удалить волну';

  @override
  String deleteWaveConfirm(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Будет удалена эта волна и её $count событий.',
      many: 'Будет удалена эта волна и её $count событий.',
      few: 'Будет удалена эта волна и её $count события.',
      one: 'Будет удалена эта волна и её $count событие.',
    );
    return '$_temp0';
  }

  @override
  String get deleteWaveConfirmCheckbox =>
      'Подтвердить безвозвратное удаление этой волны';

  @override
  String get addEvent => 'Добавить событие';

  @override
  String get reuseExistingEvent => 'Использовать существующее событие';

  @override
  String reuseExistingEventForWave(int wave) {
    return 'Использовать существующее событие для волны $wave';
  }

  @override
  String get reuseExistingEventEmpty => 'В этом уровне ещё нет событий';

  @override
  String get reuseExistingEventUnused => 'Не используется ни в одной волне';

  @override
  String reuseExistingEventUsedInWaves(String waves) {
    return 'Волны: $waves';
  }

  @override
  String get emptyWave => 'Пустая волна';

  @override
  String get addWave => 'Добавить волну';

  @override
  String get expectation => 'Ожидание';

  @override
  String get close => 'Закрыть';

  @override
  String get levelOverview => 'Обзор уровня';

  @override
  String get levelOverviewOpenLevel => 'Открыть уровень';

  @override
  String get previewStartingPlantFood => 'Начальная подкормка';

  @override
  String get previewPrePlaced => 'Расстановка';

  @override
  String get previewRegularPlants => 'Обычные';

  @override
  String get previewFrozenPlants => 'Замороженные';

  @override
  String get previewLevelContent => 'Содержимое уровня';

  @override
  String get previewSeedBank => 'Банк семян';

  @override
  String get previewIZombieSeedBank => 'Банк семян (I, Zombie)';

  @override
  String get previewFeatures => 'Особенности';

  @override
  String get previewActiveModules => 'Активные модули';

  @override
  String get previewInitial => 'Начальные';

  @override
  String get previewGenerateImagePreview => 'Создать превью изображения';

  @override
  String get editProperties => 'Редактировать свойства';

  @override
  String get deleteEntity => 'Удалить объект';

  @override
  String get deleteObjectTitle => 'Удалить объект?';

  @override
  String get deleteObjectConfirmMessage =>
      'Удалить этот объект из файла уровня? Это действие нельзя отменить.';

  @override
  String get objectDeleted => 'Объект удалён';

  @override
  String get moduleEditorInProgress => 'Редактор модуля в разработке';

  @override
  String get dataEmpty => 'Данные пусты';

  @override
  String get saveSuccess => 'Сохранено успешно';

  @override
  String get saveFail => 'Ошибка сохранения';

  @override
  String get confirmRemoveRef => 'Удалить ссылку';

  @override
  String get confirmRemoveRefMessage =>
      'Удалить эту ссылку? Данные объекта останутся до удаления всех ссылок.';

  @override
  String get deleteEventConfirmCheckbox =>
      'Я понимаю, что это действие нельзя отменить';

  @override
  String get noZombiesInLane => 'Нет зомби на этой полосе';

  @override
  String get code => 'Код';

  @override
  String get name => 'Название';

  @override
  String get levelNumber => 'Номер уровня';

  @override
  String get startingSun => 'Начальное солнце';

  @override
  String get startingPlantfood => 'Начальная подкормка';

  @override
  String get stageModule => 'Стадия';

  @override
  String get musicType => 'Тип музыки';

  @override
  String get loot => 'Добыча';

  @override
  String get victoryModule => 'Условие победы';

  @override
  String get basicInfoSection => 'Основная информация';

  @override
  String get sceneSettingsSection => 'Настройки сцены';

  @override
  String get restrictionsSection => 'Ограничения';

  @override
  String get victoryModuleWarning =>
      'Использование нестандартных условий победы может вызвать сбой уровня из-за конфликтов модулей. Используйте с осторожностью.';

  @override
  String get hintTextDisplay => 'Текст подсказки (Description)';

  @override
  String get beatTheLevelDialogIntro =>
      'Показывать текст подсказки во всплывающем окне в начале уровня.';

  @override
  String get beatTheLevelDialogHint =>
      'Поддерживает китайский; для многострочного текста вводите переносы напрямую, \\n не нужен. Примечание: подсказки не отображаются в iOS courtyard.';

  @override
  String get levelHintText => 'Текст подсказки уровня';

  @override
  String get missingModules => 'Отсутствующие модули';

  @override
  String get moduleConflict => 'Конфликт модулей';

  @override
  String get conflictTitle_ModuleLogic => 'Логический конфликт модулей';

  @override
  String conflictDefaultDescription(String module1, String module2) {
    return '«$module1» и «$module2» конфликтуют. Рекомендуется оставить только один.';
  }

  @override
  String get conflictDesc_SeedBankConveyor =>
      'Модули Seed Bank и Conveyor конфликтуют в интерфейсе и могут вызвать сбой. Убедитесь, что Seed Bank в режиме предвыбора.';

  @override
  String get conflictDesc_VaseBreakerIntro =>
      'Режиму Vase Breaker не нужна вступительная заставка.';

  @override
  String get conflictDesc_LastStandIntro =>
      'Режиму Last Stand не нужна вступительная заставка.';

  @override
  String get conflictDesc_CowboyIntro =>
      '«Неудачный загон» конфликтует с модулем вступительной заставки. Их совместное использование нарушает предпросмотр зомби и эффект перехода в начале уровня.';

  @override
  String get conflictDesc_SingleHandedIntro =>
      '«В одиночку» конфликтует с модулем вступительной заставки. Их совместное использование нарушает эффект перехода в начале уровня.';

  @override
  String get conflictDesc_SingleHandedTutorialIntro =>
      'Обучение «В одиночку» конфликтует с модулем вступительной заставки. Их совместное использование нарушает эффект перехода в начале уровня.';

  @override
  String get conflictDesc_EvilDaveZombieDrop =>
      'В режиме I, Zombie нельзя использовать модуль Zombie Drop.';

  @override
  String get conflictDesc_EvilDaveVictory =>
      'В режиме I, Zombie нельзя использовать условие победы зомби.';

  @override
  String get conflictDesc_ZombossDeathDrop =>
      'Уничтожение всех зомби до последнего в режиме зомбот помешают корректному завершению уровня.';

  @override
  String get conflictDesc_WinConditionExclusive =>
      'В LevelModules должно быть только одно условие победы/поражения из: смертельные капли, победа за бронзу или стандартное «съели мозги». Удалите лишние модули.';

  @override
  String get conflictDesc_ZombossTwoIntros =>
      'Две вступительные заставки не могут сосуществовать, иначе шкала здоровья Zomboss отображается неверно.';

  @override
  String get conflictDesc_InitialPlantEntryRoof =>
      'Предустановленные растения на крыше вызовут сбой.';

  @override
  String get conflictDesc_InitialPlantRoof =>
      'Легаси-растения на крыше вызовут сбой.';

  @override
  String get conflictDesc_ProtectPlantRoof =>
      'Защищаемые растения на крыше вызовут сбой.';

  @override
  String get conflictDesc_LawnMowerYard =>
      'Газонокосилки неэффективны в модуле Yard.';

  @override
  String get conflictDesc_MoonExpertYard =>
      'Лунный экспертный режим конфликтует с модулем лужайки. Рекомендуется оставить только один из них.';

  @override
  String get conflictDesc_WaveGeneratorWaveManagerModule =>
      'Генератор волн и модуль менеджера волн нельзя использовать одновременно: это две разные системы волн.';

  @override
  String get conflictDesc_WaveGeneratorWaveManager =>
      'Генератор волн хранит данные волн внутри модуля и не может использоваться вместе с отдельным контейнером менеджера волн.';

  @override
  String conflictDesc_StatueMazeIncompatible(String module) {
    return 'Лабиринт статуэток конфликтует с модулем «$module». Их одновременное использование приведёт к некорректной работе игры. Не рекомендуется использовать лабиринт статуэток вместе с модулем «$module».';
  }

  @override
  String conflictDesc_CamelMinigameNonTouchZombies(String zombies) {
    return 'Карточная игра «Верблюд» работает только с касательными зомби-верблюдами. Некасательные зомби обнаружены в Wave Generator: $zombies. Замените их на касательных зомби-верблюдов, чтобы восстановить работоспособность уровня.';
  }

  @override
  String get targetZombieWithoutOakTrainWarning =>
      'Зомби-мишени (zombie_target_*) требуют модуль OakTrain для корректной работы. Их использование без OakTrain приведёт к некорректной работе игры.';

  @override
  String get targetZombieRequiresOakTrain =>
      'Зомби-мишени требуют модуль OakTrain. Пожалуйста, сначала добавьте OakTrain в уровень.';

  @override
  String targetZombieRequiresOakTrainDialog(String module) {
    return 'Этот зомби требует модуль «$module». Хотите добавить его в уровень?';
  }

  @override
  String get conflictDesc_CamelMinigameIntro =>
      'Карточная игра «Верблюд» конфликтует с модулем Standard Level Intro (вступительная заставка). Они вместе работают некорректно. Рекомендуется отказаться от модуля заставки в пользу карточной игры «Верблюд», так как в ней встроена своя заставка.';

  @override
  String get targetZombieInWaveManagerWarningTitle =>
      'Зомби-мишени + Wave Manager';

  @override
  String get targetZombieInWaveManagerWarning =>
      'Зомби-мишени (zombie_target_*) некорректно работают с Wave Manager. Рекомендуется использовать Wave Generator с включённым режимом появления из-под земли для полноценной работы этих зомби.';

  @override
  String get camelMinigameWaveManagerHintTitle =>
      'Карточная игра «Верблюд» + Wave Manager';

  @override
  String get camelMinigameWaveManagerHint =>
      'После уничтожения всех касательных зомби-верблюдов в финальной волне игра автоматически убьёт остальных зомби и завершит уровень. Учитывайте это при использовании карточной игры «Верблюд» с Wave Manager.';

  @override
  String get oakTrainUnderwaterWarningTitle =>
      'Лучник Дуба + подводная лужайка';

  @override
  String get oakTrainUnderwaterWarning =>
      'Лучнику Дуба не хватает кислорода на лужайках подводного мира (включая их кастомные вариации). Он автоматически погибнет, и уровень будет засчитан как проигранный.';

  @override
  String get camelRiseFromGroundOnlyCamelTouch =>
      'Появление из-под земли работает только с касательными зомби-верблюдами. Другие зомби не могут использовать этот режим спавна в карточной игре «Верблюд».';

  @override
  String get waveGeneratorRiseFromGroundWarningTitle =>
      'Режим появления из-под земли';

  @override
  String get waveGeneratorRiseFromGroundWarning =>
      'Большинство зомби не сможет передвигаться и использовать свои способности в режиме появления из-под земли. Если задать конкретную линию без клетки спавна, зомби всегда будут спавниться на первой клетке первой линии. Рекомендуется задавать зомби случайную линию или выбирать клетку спавна вручную.';

  @override
  String get missingPlantModuleWarningTitle =>
      'Отсутствует модуль для параллельных растений';

  @override
  String get editableModules => 'Редактируемые модули';

  @override
  String get parameterModules => 'Модули параметров';

  @override
  String get addNewModule => 'Добавить модуль';

  @override
  String get selectStage => 'Выбрать лужайку';

  @override
  String get searchStage => 'Поиск лужайки';

  @override
  String get noStageFound => 'Лужайка не найдена';

  @override
  String get stageTypeAll => 'Все';

  @override
  String get stageTypeMain => 'Основные';

  @override
  String get stageTypeExtra => 'Дополнительные';

  @override
  String get stageTypeSeasons => 'Сезоны';

  @override
  String get stageTypeSpecial => 'Мини-игры';

  @override
  String get stageTypeCustomPresets => 'Пользовательские шаблоны';

  @override
  String get search => 'Поиск';

  @override
  String get disablePeavine => 'Отключить гороховую лозу';

  @override
  String get disableArtifact => 'Отключить артефакты';

  @override
  String get selectPlant => 'Выбрать растение';

  @override
  String get selectAll => 'Выбрать все';

  @override
  String get searchPlant => 'Поиск растения';

  @override
  String get noPlantFound => 'Растение не найдено';

  @override
  String noResultsFor(String query) {
    return 'Нет результатов для «$query»';
  }

  @override
  String get noModulesInCategory => 'Нет модулей в этой категории';

  @override
  String get noEventsInCategory => 'Нет событий в этой категории';

  @override
  String get eventCategoryZombieSpawn => 'Появление зомби';

  @override
  String get eventCategoryGridItemSpawn => 'Появление предметов на поле';

  @override
  String get eventCategoryEnvironmental => 'Окружение';

  @override
  String get eventCategoryOther => 'Прочее';

  @override
  String addEventForWave(int wave) {
    return 'Добавить событие для волны $wave';
  }

  @override
  String get waveLabel => 'Волна';

  @override
  String get pointsLabel => 'Очки';

  @override
  String wavePointsShort(int points) {
    return '$points очк.';
  }

  @override
  String get noDynamicZombies => 'Нет динамически-заданных зомби';

  @override
  String get moduleTitle_WaveManagerModuleProperties => 'Менеджер волн';

  @override
  String get moduleDesc_WaveManagerModuleProperties =>
      'Управление волнами уровня';

  @override
  String get moduleTitle_WaveGeneratorProperties => 'Генератор волн';

  @override
  String get moduleDesc_WaveGeneratorProperties =>
      'Старый формат волн, используемый в Кунг-Фу мире и других ранних уровнях';

  @override
  String get moduleTitle_CustomLevelModuleProperties => 'Модуль лужайки';

  @override
  String get moduleDesc_CustomLevelModuleProperties =>
      'Включает режим творческого двора. Костюмы растений в этом режиме недоступны.';

  @override
  String get powerTileModuleRequiredTitle => 'Нужен модуль силовых плиток';

  @override
  String get powerTileModuleRequiredBody =>
      'Инструменты силовых плиток требуют модуль Power Tiles в уровне. Добавить модуль по умолчанию?';

  @override
  String get conveyorPlantWearCostume => 'Костюм (iAvatar)';

  @override
  String get conveyorPlantWearCostumeTooltip =>
      'Если включено, на карточке может отображаться костюм. Недоступно при модуле творческого двора.';

  @override
  String get modifyConveyorAddPoolTitle => 'Добавить в пул конвейера';

  @override
  String get modifyConveyorAddPoolEmpty =>
      'Пусто. Добавьте растение или инструмент и настройте веса.';

  @override
  String get modifyConveyorRemovePoolTitle => 'Убрать с конвейера';

  @override
  String get modifyConveyorEntryEditTitle => 'Параметры записи конвейера';

  @override
  String get moduleTitle_UnchartedModeNo42UniverseModule =>
      'Модуль вселенной 42';

  @override
  String get moduleDesc_UnchartedModeNo42UniverseModule =>
      'Включает растения параллельной вселенной No 42';

  @override
  String get moduleTitle_PVZ2MausoleumModuleUnchartedMode =>
      'Модуль Подземного Дворца';

  @override
  String get moduleDesc_PVZ2MausoleumModuleUnchartedMode =>
      'Включает растения Подземного Дворца';

  @override
  String plantModuleRequiredMessage(String moduleName) {
    return 'Чтобы выбрать это растение, нужно добавить модуль «$moduleName».';
  }

  @override
  String zombieModuleRequiredMessage(String moduleName) {
    return 'Чтобы выбрать этого зомби, нужно добавить модуль «$moduleName».';
  }

  @override
  String get realmExclusivePlantChooserBlockedTitle =>
      'Нельзя выбрать растение';

  @override
  String get realmExclusivePlantChooserBlockedMessage =>
      'Растения некоторых реалмов нельзя выбрать в режиме выбора. Используйте предустановку, конвейер, выпадение карт и другие способы.';

  @override
  String get hiddenPlantChooserBlockedLabel => 'Нельзя выбрать растение';

  @override
  String get hiddenPlantChooserBlockedTitle => 'Нельзя выбрать растение';

  @override
  String get hiddenPlantChooserBlockedMessage =>
      'Скрытые растения нельзя выбирать в режиме выбора карт. Используйте предустановленный режим, конвейер, выпадение карт или другие способы.\nЗа исключением некоторых растений, таких как Жрец-пухомор и Сборщик растеброни - Огненная звезда, все остальные скрытые растения отображаются в игровом банке семян значком подсолнуха; у таких растений, как Мини-шар кактуса и Волшебный бобовый стебель, также встречаются необычные взаимодействия, которые могут повлиять на общее восприятие уровня, поэтому используйте их с осторожностью.';

  @override
  String get comingSoonPlantBlockedLabel => 'Продолжение следует';

  @override
  String get comingSoonPlantBlockedTitle => 'Продолжение следует';

  @override
  String get comingSoonPlantBlockedMessage =>
      'Растения продолжают расти и крепнуть. Следите за будущими обновлениями!';

  @override
  String get stayTunedMoonZombieBlockedLabel => 'Послание из космоса';

  @override
  String get stayTunedMoonZombieBlockedTitle => 'Послание из космоса';

  @override
  String get stayTunedMoonZombieBlockedMessage =>
      'Вторая часть «Лунной Базы» скоро выйдет. Следите за новостями!';

  @override
  String get stayTunedTaleZCorpZombieBlockedLabel =>
      'История ZCorp еще не закончена';

  @override
  String get stayTunedTaleZCorpZombieBlockedTitle => 'Продолжение следует';

  @override
  String get stayTunedTaleZCorpZombieBlockedMessage =>
      'Вторая глава ZCorp скоро выйдет. Следите за новостями!';

  @override
  String get stayTunedZombieBlockedLabel => 'Следите за новостями';

  @override
  String get stayTunedZombieBlockedTitle => 'Продолжение следует';

  @override
  String get stayTunedZombieBlockedMessage =>
      'Впереди ещё больше зомби. Следите за будущими обновлениями!';

  @override
  String missingModuleForPlantsWarning(String moduleName, String plantList) {
    return 'Отсутствует модуль «$moduleName» для растений: $plantList';
  }

  @override
  String get moduleTitle_StandardLevelIntroProperties => 'Заставка';

  @override
  String get moduleDesc_StandardLevelIntroProperties =>
      'Прокрутка камеры в начале уровня';

  @override
  String get moduleTitle_ZombiesAteYourBrainsProperties => 'Условие поражения';

  @override
  String get moduleDesc_ZombiesAteYourBrainsProperties => 'Зомби дошёл до дома';

  @override
  String get moduleTitle_ZombiesDeadWinConProperties => 'Полная зачистка';

  @override
  String get moduleDesc_ZombiesDeadWinConProperties =>
      'Для победы нужно убить всех зомби';

  @override
  String get moduleTitle_BronzeDeadWinConProperties => 'Разгром Бронзы';

  @override
  String get moduleDesc_BronzeDeadWinConProperties =>
      'Победа при уничтожении всех бронзовых статуй и гаргантюа. Несовместимо с «Полной зачисткой» и другими модулями условия победы — оставьте один.';

  @override
  String get moduleTitle_SpermWhaleModuleProperties => 'Кит';

  @override
  String get moduleDesc_SpermWhaleModuleProperties =>
      'Параметры глотания кита в Атлантиде; в игре нужны креветки и растения';

  @override
  String get spermWhaleModuleTitle => 'Модуль кита';

  @override
  String get spermWhaleModuleHelpTitle => 'Модуль кита';

  @override
  String get spermWhaleModuleParameters => 'Параметры';

  @override
  String get spermWhaleModuleHelpOverview => 'Обзор';

  @override
  String get spermWhaleModuleHelpOverviewBody =>
      'Настройка глотания растений китом: интервалы в обычном и отравленном режиме, длительность фазы, порог срабатывания яда. Обычно для глубоководной сцены с крилем (часто нужно ≥3).';

  @override
  String get spermWhaleModuleHelpFieldsTitle => 'Поля';

  @override
  String get spermWhaleModuleHelpFieldsBody =>
      'SwallowInterval — пауза между глотаниями. PoisonSwallowInterval — при активном яде. SwallowDuration — длительность фазы глотания. PoisonTriggerCount — сколько раз должен сработать дебафф яда, чтобы использовать отравленный интервал.';

  @override
  String get spermWhaleModuleSwallowInterval =>
      'Интервал глотания (SwallowInterval; секунды)';

  @override
  String get spermWhaleModuleHelpSwallowInterval =>
      'Секунды между глотаниями в обычном режиме.';

  @override
  String get spermWhaleModulePoisonSwallowInterval =>
      'Интервал при яде (PoisonSwallowInterval; секунды)';

  @override
  String get spermWhaleModuleHelpPoisonSwallowInterval =>
      'Секунды между глотаниями, пока действует яд.';

  @override
  String get spermWhaleModuleSwallowDuration =>
      'Длительность глотания (SwallowDuration; секунды)';

  @override
  String get spermWhaleModuleHelpSwallowDuration =>
      'Длительность фазы глотания в секундах.';

  @override
  String get spermWhaleModulePoisonTriggerCount =>
      'Счётчик яда (PoisonTriggerCount)';

  @override
  String get spermWhaleModuleHelpPoisonTriggerCount =>
      'Сколько срабатываний негативного эффекта яда нужно, чтобы перейти на интервалы при яде.';

  @override
  String get spermWhaleModuleNotDeepSeaWarning =>
      'Рекомендуется использовать этот модуль на лужайках Подводного мира. На лужайках, отличных от «20 000 лье под водой»/Атлантиды, возможны проблемы совместимости.';

  @override
  String get spermWhaleModuleLawnPreview => 'Сетка газона (ориентир)';

  @override
  String get spermWhaleModuleLawnPreviewHint =>
      'Глубоководный газон 6×10; обычный 5×9.';

  @override
  String get moduleTitle_PennyClassroomModuleProperties => 'Уровень растений';

  @override
  String get moduleDesc_PennyClassroomModuleProperties =>
      'Позволяет точечно настраивать уровни растениям (у ненастроенных растений будет автоматически первый уровень)';

  @override
  String get moduleTitle_SeedBankProperties => 'Банк семян';

  @override
  String get moduleDesc_SeedBankProperties => 'Набор растений и способ выбора';

  @override
  String get moduleTitle_ConveyorSeedBankProperties => 'Конвейер';

  @override
  String get moduleDesc_ConveyorSeedBankProperties =>
      'Растения на конвейере и веса';

  @override
  String get moduleTitle_SunDropperProperties => 'Падающее солнце';

  @override
  String get moduleDesc_SunDropperProperties => 'Частота падения солнца';

  @override
  String get moduleTitle_LevelMutatorMaxSunProps => 'Макс. солнце';

  @override
  String get moduleDesc_LevelMutatorMaxSunProps => 'Лимит солнца';

  @override
  String get moduleTitle_MoonExpertProperties => 'Лунный экспертный режим';

  @override
  String get moduleDesc_MoonExpertProperties =>
      'Задаёт единый уровень зомби для уровня и ставит все растения на 1 уровень';

  @override
  String get moduleTitle_LevelMutatorStartingPlantfoodProps =>
      'Стартовая подкормка';

  @override
  String get moduleDesc_LevelMutatorStartingPlantfoodProps =>
      'Начальная подкормка';

  @override
  String get moduleTitle_StarChallengeModuleProperties => 'Звёздные испытания';

  @override
  String get moduleDesc_StarChallengeModuleProperties =>
      'Ограничения и цели уровня';

  @override
  String get starChallengeNoConfigTitle => 'Испытание';

  @override
  String get starChallengeNoConfigMessage =>
      'У этого испытания нет настраиваемых параметров.';

  @override
  String get starChallengeSaveMowersTitle => 'Не потерять газонокосилки';

  @override
  String get starChallengeSaveMowersNoConfigMessage =>
      'У этого испытания нет настраиваемых параметров.\n\nВсе газонокосилки должны остаться целыми. Примечание: в модуле двора газонокосилок по умолчанию нет.';

  @override
  String get starChallengePlantFoodNonuseTitle => 'Не использовать подкормку';

  @override
  String get starChallengePlantFoodNonuseNoConfigMessage =>
      'У этого испытания нет настраиваемых параметров.\n\nИспользование подкормки запрещено.';

  @override
  String get moduleTitle_LevelScoringModuleProperties => 'Набрать очки';

  @override
  String get moduleDesc_LevelScoringModuleProperties =>
      'Очки за убийства зомби';

  @override
  String get moduleTitle_SouDaCheDamageTextModuleProperties =>
      'Отображение урона';

  @override
  String get moduleDesc_SouDaCheDamageTextModuleProperties =>
      'Показывает урон, нанесенный каждой атакой растения во время уровня';

  @override
  String get moduleTitle_BowlingMinigameProperties => 'Боулинг';

  @override
  String get moduleDesc_BowlingMinigameProperties =>
      'Линия и отключение лопаты';

  @override
  String get moduleTitle_NewBowlingMinigameProperties =>
      'Боулинг с стенорехами';

  @override
  String get moduleDesc_NewBowlingMinigameProperties =>
      'Настройка линии боулинга';

  @override
  String get moduleTitle_VaseBreakerPresetProperties => 'Расклад ваз';

  @override
  String get moduleDesc_VaseBreakerPresetProperties => 'Содержимое ваз';

  @override
  String get moduleTitle_VaseBreakerArcadeModuleProperties => 'Режим «Вазобой»';

  @override
  String get moduleDesc_VaseBreakerArcadeModuleProperties =>
      'Включить интерфейс режима';

  @override
  String get moduleTitle_VaseBreakerFlowModuleProperties => 'Анимация ваз';

  @override
  String get moduleDesc_VaseBreakerFlowModuleProperties =>
      'Анимация падения ваз';

  @override
  String get moduleTitle_EvilDaveProperties => 'Я зомби';

  @override
  String get moduleDesc_EvilDaveProperties => 'Включить режим «Я зомби»';

  @override
  String get moduleTitle_ZombossBattleModuleProperties => 'Бой с Зомботом';

  @override
  String get moduleDesc_ZombossBattleModuleProperties => 'Параметры Зомбота';

  @override
  String get moduleTitle_ZombossBattleIntroProperties => 'Заставка Зомбота';

  @override
  String get moduleDesc_ZombossBattleIntroProperties =>
      'Заставка и полоска здоровья Зомбота';

  @override
  String get moduleTitle_ZombossLastStandMinigameProperties =>
      'Бой с Зомбоссом';

  @override
  String get moduleDesc_ZombossLastStandMinigameProperties =>
      'Параметры боя с Зомбоссами (Мастер Цигун, Пиродьявол и т.д.)';

  @override
  String get moduleTitle_SeedRainProperties => 'Дождь из семян';

  @override
  String get moduleDesc_SeedRainProperties =>
      'Падающие растения/зомби/предметы';

  @override
  String get moduleTitle_LastStandMinigameProperties => 'Последний Выживший';

  @override
  String get moduleDesc_LastStandMinigameProperties =>
      'Стартовые ресурсы и фаза подготовки';

  @override
  String get moduleTitle_CowboyMinigameProperties => 'Электрический загон';

  @override
  String get moduleDesc_CowboyMinigameProperties =>
      'Запускает волну зомби после посадки растения с конвейера';

  @override
  String get moduleTitle_SingleHandedProperties => 'Сам за себя';

  @override
  String get moduleDesc_SingleHandedProperties =>
      'Настраивает основные параметры мини-игры «Сам за себя»';

  @override
  String get moduleTitle_IntroSingleHandedProperties =>
      'Обучение мини-игры «Сам за себя»';

  @override
  String get moduleDesc_IntroSingleHandedProperties =>
      'Настраивает обучающие подсказки мини-игры «Сам за себя»';

  @override
  String get moduleTitle_PVZ1OverwhelmModuleProperties =>
      'Высадка по 5-ти линиям';

  @override
  String get moduleDesc_PVZ1OverwhelmModuleProperties =>
      'Мини-игра «Колонна, как вы её видите»';

  @override
  String get moduleTitle_SunBombChallengeProperties => 'Солнечные бомбы';

  @override
  String get moduleDesc_SunBombChallengeProperties =>
      'Настройка падающих солнечных бомб';

  @override
  String get moduleTitle_IncreasedCostModuleProperties => 'Инфляция';

  @override
  String get moduleDesc_IncreasedCostModuleProperties =>
      'Рост стоимости солнца при посадке';

  @override
  String get moduleTitle_DeathHoleModuleProperties => 'Кратеры';

  @override
  String get moduleDesc_DeathHoleModuleProperties =>
      'Растения оставляют непосадочные ямы после смерти';

  @override
  String get moduleTitle_ZombieMoveFastModuleProperties => 'Быстрый вход';

  @override
  String get moduleDesc_ZombieMoveFastModuleProperties =>
      'Зомби быстрее выходят на лужайку';

  @override
  String get moduleTitle_InitialPlantProperties =>
      'Начальные растения (устаревший модуль)';

  @override
  String get moduleDesc_InitialPlantProperties =>
      'Предустановленные растения (замороженные)';

  @override
  String get moduleTitle_InitialPlantEntryProperties => 'Начальные растения';

  @override
  String get moduleDesc_InitialPlantEntryProperties =>
      'Растения в начале уровня';

  @override
  String get frozenPlantPlacementTitle =>
      'Растения в начале уровня (устаревший модуль с возможностью сделать замороженные растения)';

  @override
  String get frozenPlantPlacementLastStand =>
      'Сжигание всех растений при старте уровня';

  @override
  String get frozenPlantPlacementSelectedPosition => 'Выбранная позиция';

  @override
  String get frozenPlantPlacementPlaceHere => 'Разместить растение';

  @override
  String get frozenPlantPlacementPlantList => 'Список растений (по рядам)';

  @override
  String frozenPlantPlacementEditPlant(String name) {
    return 'Редактировать $name';
  }

  @override
  String get frozenPlantPlacementLevel => 'Уровень';

  @override
  String get frozenPlantPlacementCondition => 'Состояние';

  @override
  String get frozenPlantPlacementConditionNull => 'Нет (null)';

  @override
  String get noConditions => 'Нет условий';

  @override
  String get frozenPlantPlacementHelpTitle =>
      'Устаревшие предустановленные растения - Справка';

  @override
  String get frozenPlantPlacementHelpOverviewTitle => 'Обзор';

  @override
  String get frozenPlantPlacementHelpOverviewBody =>
      'Этот модуль настраивает раскладку растений до начала уровня. Похож на предустановленную раскладку, но с другой структурой и поддержкой особых состояний.';

  @override
  String get frozenPlantPlacementHelpConditionTitle => 'Особое состояние';

  @override
  String get frozenPlantPlacementHelpConditionBody =>
      'Растения можно установить в замороженное состояние, часто используется на уровнях Ледникового периода.';

  @override
  String get frozenPlantPlacementHelpLastStandTitle =>
      'Режим \'Последний выживший\'';

  @override
  String get frozenPlantPlacementHelpLastStandBody =>
      'При включении Последнего Выжившего начальные растения будут уничтожены после старта игры. Примечание: в китайской версии не отображается эффект огня при уничтожении растений.';

  @override
  String get save => 'Сохранить';

  @override
  String get moduleTitle_InitialZombieProperties => 'Начальные зомби';

  @override
  String get moduleDesc_InitialZombieProperties => 'Зомби в начале уровня';

  @override
  String get moduleTitle_InitialGridItemProperties => 'Начальные объекты сетки';

  @override
  String get moduleDesc_InitialGridItemProperties =>
      'Объекты сетки в начале уровня';

  @override
  String get moduleTitle_ProtectThePlantChallengeProperties =>
      'Защитить растения';

  @override
  String get moduleDesc_ProtectThePlantChallengeProperties =>
      'Растения, которые нужно защитить';

  @override
  String get moduleTitle_ProtectTheGridItemChallengeProperties =>
      'Защитить предметы';

  @override
  String get moduleDesc_ProtectTheGridItemChallengeProperties =>
      'Предметы, которые нужно защитить';

  @override
  String get moduleTitle_MoldColonyChallengeProps => 'Зона плесени';

  @override
  String get moduleDesc_MoldColonyChallengeProps =>
      'Настраивает клетки газона с колониями плесени, на которых нельзя сажать растения';

  @override
  String get moldColonyLocationsTitle => 'Схема колоний плесени (Locations)';

  @override
  String moldColonyLocationsValue(String value) {
    return 'Текущее значение: $value';
  }

  @override
  String get moldColonyLevelModulesError =>
      'Ошибка: ссылка на схему колоний плесени использует LevelModules. Переключите её на объект текущего уровня.';

  @override
  String get moldColonyInvalidLinkError =>
      'Ошибка: Locations должен ссылаться на объект BoardGridMapProps текущего уровня со схемой колоний плесени.';

  @override
  String moldColonyRepairLink(String alias) {
    return 'Исправить ссылку на: $alias';
  }

  @override
  String get moldColonies => 'Колонии плесени';

  @override
  String get moldColonyEmpty => 'Пусто';

  @override
  String get moldColonyHelpOverview =>
      'Настраивает клетки газона, покрытые колониями плесени. На таких клетках игрок не может сажать растения.';

  @override
  String get moldColonyHelpGridTitle => 'Управление сеткой';

  @override
  String get moldColonyHelpGridBody =>
      'Нажмите клетку, чтобы переключить её между пустой (можно сажать) и колониями плесени (сажать нельзя). Выбранные строка и столбец показаны над сеткой.';

  @override
  String get moduleTitle_ZombiePotionModuleProperties => 'Зелья зомби';

  @override
  String get moduleDesc_ZombiePotionModuleProperties =>
      'Генерация зелий в Тёмных веках';

  @override
  String get moduleTitle_PiratePlankProperties => 'Пиратские доски';

  @override
  String get moduleDesc_PiratePlankProperties => 'Ряды досок в Пиратских Морях';

  @override
  String get moduleTitle_RailcartProperties => 'Вагонетки';

  @override
  String get moduleDesc_RailcartProperties => 'Вагонетки и рельсы';

  @override
  String get moduleTitle_MechanismPlankProperties => 'Объединённые вагонетки';

  @override
  String get moduleDesc_MechanismPlankProperties =>
      'Редактирование распложения вагонеток и рельс Кунг-Фу Мира';

  @override
  String get moduleTitle_PowerTileProperties => 'Силовые плитки';

  @override
  String get moduleDesc_PowerTileProperties =>
      'Расположение разноцветных плиток из Далёкого Будущего';

  @override
  String get moduleTitle_ManholePipelineModuleProperties => 'Проходные люки';

  @override
  String get moduleDesc_ManholePipelineModuleProperties =>
      'Настраивает проходы для зомби в виде люков';

  @override
  String get moduleTitle_SmokePollutionModuleProperties => 'Дымовые люки';

  @override
  String get moduleDesc_SmokePollutionModuleProperties =>
      'Настраивает люки с ядовитым паром на газоне';

  @override
  String get moduleTitle_RoofProperties => 'Горшки крыши';

  @override
  String get moduleDesc_RoofProperties => 'Колонки горшков на крыше';

  @override
  String get moduleTitle_TideProperties => 'Система прилива';

  @override
  String get moduleDesc_TideProperties => 'Включить прилив';

  @override
  String get moduleTitle_BombProperties => 'Взрывоопасные бочки';

  @override
  String get moduleDesc_BombProperties =>
      'Длина фитиля взрывоопасной бочки по рядам';

  @override
  String get moduleTitle_BronzeProperties => 'Бронзовые статуи';

  @override
  String get moduleDesc_BronzeProperties =>
      'Мини-игра бронзовых статуй Кунг-Фу Мира: размещение статуй и настройка времени пробуждения (не привязано к волнам)';

  @override
  String get moduleTitle_ArmrackProperties => 'Оружейные стойки';

  @override
  String get moduleDesc_ArmrackProperties =>
      'Настройка отображения оружейных стоек на газоне (только волна 1)';

  @override
  String get moduleTitle_EnergyGridProperties => 'Плитки с подкормкой';

  @override
  String get moduleDesc_EnergyGridProperties =>
      'Настройка отображения плиток с подкормкой на газоне (только волна 1)';

  @override
  String get bronzeModuleTitle => 'Бронзовые статуи';

  @override
  String get bronzeModuleHelpTitle => 'Бронзовые статуи';

  @override
  String get bronzeModuleHelpOverview => 'Обзор';

  @override
  String get bronzeModuleHelpOverviewBody =>
      'Размещает бронзовые статуи Гаргантюа на газоне в начале уровня. Время пробуждения задаётся в секундах (spawnTime). Каждая группа волн — отдельная запись в массиве data; в игре действует только волна 1.';

  @override
  String get bronzeModuleHelpBatches => 'Пакеты и время';

  @override
  String get bronzeModuleHelpBatchesBody =>
      'Статуи с одинаковым временем пробуждения появляются вместе. Последующие пакеты могут продолжать отсчёт. Выберите клетку, тип и секунды до пробуждения.';

  @override
  String get bronzeModuleShakeOffset => 'Анимация';

  @override
  String get bronzeModuleShakeOffsetLabel => 'Смещение тряски при пробуждении';

  @override
  String get bronzeModuleInCell => 'Статуи в выбранной клетке';

  @override
  String get bronzeModuleAddTitle => 'Добавить тип статуи';

  @override
  String get bronzeModuleTypeLabel => 'Тип';

  @override
  String get bronzeModuleSpawnTimeLabel => 'Время пробуждения (с)';

  @override
  String get moduleTitle_WarMistProperties => 'Туман';

  @override
  String get moduleDesc_WarMistProperties => 'Система тумана';

  @override
  String get moduleTitle_RainDarkProperties => 'Погода';

  @override
  String get moduleDesc_RainDarkProperties => 'Дождь, снег, буря';

  @override
  String get eventTitle_SpawnZombiesFromGroundSpawnerProps =>
      'Спавн из-под земли';

  @override
  String get eventDesc_SpawnZombiesFromGroundSpawnerProps =>
      'Зомби появляются из-под земли';

  @override
  String get eventTitle_SpawnZombiesJitteredWaveActionProps => 'Обычная волна';

  @override
  String get eventDesc_SpawnZombiesJitteredWaveActionProps =>
      'Обычное появление зомби с правого края лужайки';

  @override
  String get eventTitle_FrostWindWaveActionProps => 'Морозный ветер';

  @override
  String get eventDesc_FrostWindWaveActionProps => 'Холодный ветер по рядам';

  @override
  String get eventTitle_BeachStageEventZombieSpawnerProps =>
      'Появление утопленников';

  @override
  String get eventDesc_BeachStageEventZombieSpawnerProps =>
      'Зомби выныривают из воды';

  @override
  String get eventTitle_TidalChangeWaveActionProps => 'Смена прилива';

  @override
  String get eventDesc_TidalChangeWaveActionProps => 'Изменение уровня прилива';

  @override
  String get eventTitle_TideWaveWaveActionProps => 'Подводные волны';

  @override
  String get eventDesc_TideWaveWaveActionProps =>
      'Подводная волна, смещающие подлодку (влево/вправо)';

  @override
  String get eventTitle_SpawnZombiesFishWaveActionProps => 'Волна с рыбами';

  @override
  String get eventDesc_SpawnZombiesFishWaveActionProps =>
      'Появление зомби и рыб';

  @override
  String get eventTitle_ModifyConveyorWaveActionProps => 'Изменение конвейера';

  @override
  String get eventDesc_ModifyConveyorWaveActionProps =>
      'Динамическое добавление/удаление карт';

  @override
  String get eventTitle_DinoWaveActionProps => 'Призыв динозавра';

  @override
  String get eventDesc_DinoWaveActionProps => 'Призвать динозавра на ряд';

  @override
  String get eventTitle_DinoTreadActionProps => 'Топот динозавра';

  @override
  String get eventDesc_DinoTreadActionProps =>
      'Динозавр наступает на область сетки';

  @override
  String get eventTitle_DinoRunActionProps => 'Бег динозавров';

  @override
  String get eventDesc_DinoRunActionProps => 'Динозавры бегут по лужайке';

  @override
  String get eventTitle_SpawnModernPortalsWaveActionProps =>
      'Появление порталов';

  @override
  String get eventDesc_SpawnModernPortalsWaveActionProps =>
      'Создать порталы с зомби из других эпох';

  @override
  String get eventTitle_StormZombieSpawnerProps => 'Буря';

  @override
  String get eventDesc_StormZombieSpawnerProps => 'Песчаная буря или метель';

  @override
  String get eventTitle_RaidingPartyZombieSpawnerProps => 'Рейд пиратов';

  @override
  String get eventDesc_RaidingPartyZombieSpawnerProps =>
      'Зомби-головорезы летят толпами на лужайку';

  @override
  String get eventTitle_ZombiePotionActionProps => 'Расстановка зелий';

  @override
  String get eventDesc_ZombiePotionActionProps => 'Появление зелий на сетке';

  @override
  String get eventTitle_ZombieAtlantisShellActionProps => 'Ракушки';

  @override
  String get eventDesc_ZombieAtlantisShellActionProps =>
      'Появление атлантических ракушек на сетке';

  @override
  String get eventTitle_SpawnEagleFlagsWaveActionProps =>
      'Появление орлиных штандартов';

  @override
  String get eventDesc_SpawnEagleFlagsWaveActionProps =>
      'Размещает орлиные штандарты в указанных клетках';

  @override
  String get eventHelpEagleStandardBody =>
      'Проходящие мимо зомби могут подобрать орлиный штандарт. После гибели носителя штандарт падает на землю, и другие зомби могут подбирать его снова и снова. Зомби со штандартом снижает получаемый урон и даёт невосприимчивость к эффектам контроля всем зомби в области 3×3.\n\nОбычные растения не могут атаковать штандарт. Когда он лежит на земле, Магнитогриб и Золотой Магнитогриб могут его уничтожить.';

  @override
  String get eventHelpEagleStandardUsage =>
      'Выберите клетку и нажмите «+», чтобы добавить орлиный штандарт. В одной клетке можно разместить несколько штандартов и удалять их с помощью карточек ниже. Размер сетки зависит от текущего газона; штандарты за его пределами отображаются отдельно.';

  @override
  String get eventTitle_PumpkinHouseActionProps =>
      'Появление тыквенных домиков';

  @override
  String get eventDesc_PumpkinHouseActionProps =>
      'Размещает тыквенные домики в указанных клетках';

  @override
  String get eventTitle_WaveActionZombieTentProps => 'Появление палаток зомби';

  @override
  String get eventDesc_WaveActionZombieTentProps =>
      'Размещает палатки зомби, периодически призывающие зомби из взвешенного пула';

  @override
  String get eventTitle_SpawnGravestonesWaveActionProps => 'Появление могил';

  @override
  String get eventDesc_SpawnGravestonesWaveActionProps => 'Создать могилы';

  @override
  String get eventTitle_SpawnZombiesFromGridItemSpawnerProps =>
      'Вылезание из могил';

  @override
  String get eventDesc_SpawnZombiesFromGridItemSpawnerProps =>
      'Появление зомби из могил';

  @override
  String get eventTitle_FairyTaleFogWaveActionProps => 'Сказочный туман';

  @override
  String get eventDesc_FairyTaleFogWaveActionProps => 'Породить туман';

  @override
  String get eventTitle_FairyTaleWindWaveActionProps => 'Сказочный ветер';

  @override
  String get eventDesc_FairyTaleWindWaveActionProps => 'Сдуть туман';

  @override
  String get eventTitle_SpiderRainZombieSpawnerProps =>
      'Дождь из зомби (импов)';

  @override
  String get eventDesc_SpiderRainZombieSpawnerProps =>
      'Зомби (импы) падают с неба';

  @override
  String get eventTitle_ParachuteRainZombieSpawnerProps => 'Парашютный дождь';

  @override
  String get eventDesc_ParachuteRainZombieSpawnerProps =>
      'Зомби падают с парашютами';

  @override
  String get eventTitle_BassRainZombieSpawnerProps => 'Дождь из басистов';

  @override
  String get eventDesc_BassRainZombieSpawnerProps => 'Падают басисты';

  @override
  String get eventTitle_BlackHoleWaveActionProps => 'Чёрная дыра';

  @override
  String get eventDesc_BlackHoleWaveActionProps =>
      'Чёрная дыра притягивает растения';

  @override
  String get eventTitle_BarrelWaveActionProps => 'Бочки';

  @override
  String get eventDesc_BarrelWaveActionProps =>
      'Катящиеся бочки по рядам (пустые, с зомби, взрывные)';

  @override
  String get eventTitle_SchoolBusWaveActionProps => 'Фургон с мороженым';

  @override
  String get eventDesc_SchoolBusWaveActionProps =>
      'Фургон с мороженым в ряду с настраиваемыми зомби внутри';

  @override
  String get eventTitle_HamsterZombieSpawnerProps => 'Зомби в хомячьем шаре';

  @override
  String get eventDesc_HamsterZombieSpawnerProps =>
      'Выкатывает на поле шары с зомби внутри';

  @override
  String get eventTitle_BungeeWaveActionProps => 'Тарзаночное размещение';

  @override
  String get eventDesc_BungeeWaveActionProps =>
      'Зомби на тарзанке сбрасывает одного зомби на лужайку (тип, уровень, клетка)';

  @override
  String get eventTitle_ThunderWaveActionProps => 'Гром';

  @override
  String get eventDesc_ThunderWaveActionProps =>
      'Молнии во время волны (с положительными/отрицательными зарядами)';

  @override
  String get eventTitle_MagicMirrorWaveActionProps => 'Волшебное зеркало';

  @override
  String get eventDesc_MagicMirrorWaveActionProps => 'Зеркальные порталы';

  @override
  String get weatherOption_DefaultSnow_label => 'Снег';

  @override
  String get weatherOption_DefaultSnow_desc => 'Эффект снега из Ледяных пещер';

  @override
  String get weatherOption_LightningRain_label => 'Дождь с грозой';

  @override
  String get weatherOption_LightningRain_desc =>
      'Дождь и молнии из Тёмных Веков';

  @override
  String get weatherOption_DefaultRainDark_label => 'Дождь';

  @override
  String get weatherOption_DefaultRainDark_desc =>
      'Эффект дождя из Тёмных Веков';

  @override
  String get iZombiePlantReserveLabel =>
      'Граница, зарезервированная под растения (PlantDistance)';

  @override
  String get column => 'Колонна';

  @override
  String get iZombieInfoText =>
      'В режиме «Я Зомби» предварительные растения и зомби необходимо настроить в модуле уровня (Preset Plants) и в банке семян.';

  @override
  String get vaseRangeTitle => 'Диапазон генерации ваз и черный список';

  @override
  String get startColumnLabel => 'Начальная колонна (мин.)';

  @override
  String get endColumnLabel => 'Конечная колонна (макс.)';

  @override
  String get toggleBlacklistHint => 'Нажмите, чтобы переключить черный список';

  @override
  String get vaseCapacityTitle => 'Вместимость ваз';

  @override
  String vaseCapacitySummary(String current, String total) {
    return 'Назначено: $current / Всего ячеек: $total';
  }

  @override
  String get vaseListTitle => 'Список ваз';

  @override
  String get addVaseTitle => 'Добавить вазу';

  @override
  String get plantVaseOption => 'Ваза с растением';

  @override
  String get zombieVaseOption => 'Ваза с зомби';

  @override
  String get plantVaseOptionDescription =>
      'Выберите карточку растения для зелёной вазы.';

  @override
  String get zombieVaseOptionDescription =>
      'Выберите зомби для фиолетовой вазы.';

  @override
  String get collectableVaseOptionDescription =>
      'Выберите предмет, который будет находиться внутри вазы.';

  @override
  String get searchZombie => 'Поиск зомби';

  @override
  String get noZombieFound => 'Зомби не найден';

  @override
  String get unknownVaseLabel => 'Неизвестная ваза';

  @override
  String get plantLabel => 'Растение';

  @override
  String get zombieLabel => 'Зомби';

  @override
  String get itemLabel => 'Предмет';

  @override
  String get railcartSettings => 'Настройки рельсов';

  @override
  String get railcartType => 'Тип вагонетки';

  @override
  String get layRails => 'Уложить рельсы';

  @override
  String get placeCarts => 'Разместить вагонетки';

  @override
  String get railSegments => 'Сегменты рельсов';

  @override
  String get railcartCount => 'Количество вагонеток';

  @override
  String get clearAll => 'Очистить всё';

  @override
  String get moduleCategoryBase => 'Базовые';

  @override
  String get moduleCategoryMode => 'Режимы';

  @override
  String get moduleCategoryScene => 'Сетка лужайки';

  @override
  String get moduleCategoryGimmick => 'Гиммики';

  @override
  String get moduleTitle_RocketZombieFlickModuleProperties =>
      'Смахивание импов на ракетах';

  @override
  String get moduleDesc_RocketZombieFlickModuleProperties =>
      'Позволяет смахивать импов с ракет на землю.';

  @override
  String get kongfuRocketFlickDialogTitle => 'Смахивание импа на ракете';

  @override
  String get kongfuRocketFlickDialogMessage =>
      'Позволяет движением пальца смахивать импа с ракеты на землю';

  @override
  String get customZombie => 'Пользовательский зомби';

  @override
  String get customZombieProperties => 'Свойства пользовательского зомби';

  @override
  String get zombieTypeNotFound => 'Объект типа зомби не найден.';

  @override
  String get propertyObjectNotFound => 'Объект свойств не найден';

  @override
  String propertyObjectNotFoundHint(String alias) {
    return 'Объект свойств пользовательского зомби ($alias) не найден в уровне. Определение свойств не указывает на внутренние данные уровня, поэтому его нельзя редактировать здесь.';
  }

  @override
  String get baseStats => 'Базовые параметры';

  @override
  String get hitpoints => 'Очки здоровья';

  @override
  String get speed => 'Скорость';

  @override
  String get speedVariance => 'Вариация скорости';

  @override
  String get eatDPS => 'Урон поедания';

  @override
  String get hitPosition => 'Попадание / позиция';

  @override
  String get hitRect => 'Радиус попадания';

  @override
  String get editHitRect => 'Редактировать радиус попадания';

  @override
  String get attackRect => 'Радиус атаки';

  @override
  String get editAttackRect => 'Редактировать радиус атаки';

  @override
  String get artCenter => 'Центр отрисовки';

  @override
  String get editArtCenter => 'Редактировать центр отрисовки';

  @override
  String get shadowOffset => 'Смещение тени';

  @override
  String get editShadowOffset => 'Редактировать смещение тени';

  @override
  String get groundTrackName => 'Траектория движения';

  @override
  String get groundTrackNormal => 'Обычная земля (ground_swatch)';

  @override
  String get groundTrackNone => 'Нет (null)';

  @override
  String get appearanceBehavior => 'Внешний вид и поведение';

  @override
  String get sizeType => 'Размер';

  @override
  String get selectSize => 'Выбрать размер';

  @override
  String get disableDropFractions => 'Отключить доли дропа';

  @override
  String get immuneToKnockback => 'Иммунитет к отбрасыванию';

  @override
  String get showHealthBarOnDamage => 'Показывать полоску здоровья при уроне';

  @override
  String get drawHealthBarTime =>
      'Время отображения полоски (DrawHealthBarTime; секунды)';

  @override
  String get enableEliteScale => 'Включить масштаб для элитных зомби';

  @override
  String get eliteScale => 'Масштаб для элитных зомби';

  @override
  String get enableEliteImmunities => 'Включить элитный иммунитет';

  @override
  String get canSpawnPlantFood => 'Может выпадать подкормка';

  @override
  String get canSurrender => 'Может сдаться';

  @override
  String get canTriggerZombieWin => 'Может вызвать победу зомби';

  @override
  String get resilience => 'Устойчивость';

  @override
  String get resilienceArmor => 'Устойчивость (броня)';

  @override
  String get enableResilience => 'Включить устойчивость';

  @override
  String get resilienceSource => 'Источник';

  @override
  String get resiliencePreset => 'Существующий';

  @override
  String get resilienceCustom => 'Свой';

  @override
  String get resiliencePresetSelect => 'Выбранный щит устойчивости';

  @override
  String get resilienceAmount => 'Количество';

  @override
  String get resilienceWeakType => 'Слабый тип';

  @override
  String get resilienceRecoverSpeed => 'Скорость восстановления';

  @override
  String get resilienceDamageThresholdPerSecond => 'Порог урона в секунду';

  @override
  String get resilienceBaseDamageThreshold =>
      'Базовый порог урона устойчивости';

  @override
  String get resilienceExtraDamageThreshold => 'Доп. порог урона устойчивости';

  @override
  String get resilienceCodename =>
      'Кодовое имя (только английские буквы; без пробелов)';

  @override
  String get resilienceCodenameHint => 'напр. CustomResilience0';

  @override
  String get resistances => 'Сопротивления';

  @override
  String get zombieResilience => 'Броня / Устойчивость';

  @override
  String get resilienceEnable => 'Включить броню';

  @override
  String get weakTypeExplosive => 'Взрыв';

  @override
  String get instantKillResistance => 'Устойчивость к мгновенной смерти';

  @override
  String get resiliencePhysics => 'Физ.урон';

  @override
  String get resiliencePoison => 'Яд';

  @override
  String get resilienceElectric => 'Электричество';

  @override
  String get resilienceMagic => 'Магия';

  @override
  String get resilienceIce => 'Лёд';

  @override
  String get resilienceFire => 'Огонь';

  @override
  String get resilienceHint => '0.0 = нет, 1.0 = полный иммунитет';

  @override
  String get resilienceSelectedShieldLabel => 'Выбранный щит стойкости:';

  @override
  String get selectionFilterBySource => 'По источнику';

  @override
  String get selectionFilterByType => 'По типу';

  @override
  String get selectionPreMade => 'Готовые';

  @override
  String get selectionDefinedByUser => 'Пользовательские';

  @override
  String get aliasAlreadyTakenTitle => 'Псевдоним уже занят';

  @override
  String get aliasRenameConfirmTitle => 'Переименовать псевдоним?';

  @override
  String aliasRenameConfirmMessage(String oldAlias, String newAlias) {
    return 'Переименовать «$oldAlias» в «$newAlias»? Все ссылки на этом уровне будут обновлены.';
  }

  @override
  String get resilienceSelectShield => 'Выбрать щит неуязвимости';

  @override
  String get resilienceCreateCustom => 'Новый пользовательский щит';

  @override
  String get resilienceEditCustom => 'Редактировать щит';

  @override
  String get resilienceSourceResilienceConfig => 'ResilienceConfig';

  @override
  String get resilienceSourceCurrentLevel => 'CurrentLevel';

  @override
  String get resilienceTypeAll => 'Все типы';

  @override
  String get resilienceNoShieldsFound => 'Щиты неуязвимости не найдены';

  @override
  String get resilienceShieldInUseCannotDelete =>
      'Нельзя удалить — этот щит используется зомби на уровне.';

  @override
  String get resilienceShieldDeleteTitle =>
      'Удалить пользовательский щит неуязвимости?';

  @override
  String resilienceShieldDeleteMessage(String alias) {
    return 'Удалить «$alias» из этого уровня?';
  }

  @override
  String get aliasAlreadyExists => 'Такой псевдоним уже есть на этом уровне.';

  @override
  String zombieTypeLabel(String type) {
    return 'Тип зомби: $type';
  }

  @override
  String propertyAliasLabel(String alias) {
    return 'Псевдоним свойств: $alias';
  }

  @override
  String get ok => 'ОК';

  @override
  String get helpDialogGotIt => 'Понятно';

  @override
  String get width => 'Ширина';

  @override
  String get height => 'Высота';

  @override
  String get customZombieHelpIntro => 'Краткое введение';

  @override
  String get customZombieHelpIntroBody =>
      'На этом экране редактируются параметры своего зомби, внедрённого в уровень. Поддерживаются только общие свойства; многие специальные атрибуты требуют ручного редактирования JSON.';

  @override
  String get customZombieHelpBase => 'Базовые свойства';

  @override
  String get customZombieHelpBaseBody =>
      'Свои зомби могут изменять базовые параметры (HP, скорость, урон поедания). Свои зомби не отображаются в пуле предпросмотра уровня.';

  @override
  String get customZombieHelpHit => 'Попадание/позиция';

  @override
  String get customZombieHelpHitBody =>
      'X и Y — смещения; W и H — ширина и высота. Смещение ArtCenter может скрыть спрайт зомби. Оставьте траекторию пустой, чтобы зомби ходил на месте.';

  @override
  String get customZombieHelpManual => 'Ручное редактирование';

  @override
  String get customZombieHelpManualBody =>
      'Пользовательская инъекция автоматически заполняет все свойства из файлов игры. При необходимости можно дополнительно отредактировать JSON-файл вручную.';

  @override
  String editAlias(String alias) {
    return 'Редактировать $alias';
  }

  @override
  String editNamedEvent(String name) {
    return 'Редактировать событие «$name»';
  }

  @override
  String editNamedModule(String name) {
    return 'Редактировать модуль «$name»';
  }

  @override
  String get addEventAliasTitle => 'Добавить событие';

  @override
  String get addModuleAliasTitle => 'Добавить модуль';

  @override
  String get aliasLabel => 'Псевдоним (только английские буквы; без пробелов)';

  @override
  String get add => 'Добавить';

  @override
  String get overview => 'Обзор';

  @override
  String get left => 'Влево';

  @override
  String get right => 'Вправо';

  @override
  String get weight => 'Вес';

  @override
  String get maxCount => 'Макс. количество';

  @override
  String get startColumn => 'Начальная колонка';

  @override
  String get endColumn => 'Конечная колонка';

  @override
  String get removeItem => 'Удалить предмет';

  @override
  String removeItemConfirm(String name) {
    return 'Удалить $name?';
  }

  @override
  String groupN(int n) {
    return 'Группа $n';
  }

  @override
  String rowN(int n) {
    return 'Ряд $n';
  }

  @override
  String get addWind => 'Добавить ветер';

  @override
  String get addDropItem => 'Добавить дроп';

  @override
  String get addMirrorGroup => 'Добавить группу зеркал выше';

  @override
  String pipeN(int n) {
    return 'Труба $n';
  }

  @override
  String get setStart => 'Установить начало';

  @override
  String get setEnd => 'Установить конец';

  @override
  String get collectable => 'Собираемый (подкормка)';

  @override
  String get plantFood => 'Подкормка';

  @override
  String get selectGridItem => 'Выбрать предмет';

  @override
  String get addItemTitle => 'Добавить препятствие';

  @override
  String get initialPlantLayout => 'Начальная расстановка растений';

  @override
  String get gridItemLayout => 'Расположение предметов';

  @override
  String get zombieCount => 'Количество зомби';

  @override
  String get timeBeforeSpawn => 'Время до появления (с)';

  @override
  String get waterBoundaryColumn => 'Колонка границы воды';

  @override
  String get columnsDragged => 'Перетаскиваемые колонки (ColNumPlantIsDragged)';

  @override
  String get typeIndex => 'Индекс типа';

  @override
  String get noStyle => 'Без стиля';

  @override
  String styleN(int n) {
    return 'Стиль $n';
  }

  @override
  String get existDurationSec => 'Время существования (сек)';

  @override
  String get mirror1 => 'Зеркало 1';

  @override
  String get mirror2 => 'Зеркало 2';

  @override
  String get ignoreGravestone => 'Игнорировать надгробия (IgnoreGraveStone)';

  @override
  String zombiePreview(String name) {
    return '$name - Превью зомби';
  }

  @override
  String get zombiePreviewTooltip => 'Предпросмотр зомби';

  @override
  String get weatherSettings => 'Настройки погоды';

  @override
  String get holeLifetimeSeconds => 'Время жизни ямы (сек)';

  @override
  String get startingWaveLocation => 'Начальная волна';

  @override
  String get rainIntervalSeconds => 'Интервал падения (сек)';

  @override
  String get startingPlantFood => 'Начальная подкормка';

  @override
  String get bowlingFoulLine => 'Линия запрета посадки';

  @override
  String get bowlingFoulLinePreview => 'Предпросмотр линии запрета посадки';

  @override
  String get bowlingMinigameParams => 'Параметры';

  @override
  String get bowlingMinigameHelpOverview =>
      'Задаёт столбец линии, за которой нельзя сажать растения в режиме боулинга с луковицей.';

  @override
  String get bowlingMinigameHelpFoulLine =>
      'BowlingFoulLine — индекс столбца слева (с 0). Растения нельзя ставить на этой линии и правее неё.\nНа газонах Подводного мира игра автоматически прибавляет к этому значению 1. Например, при значении 0 в первом столбце сажать можно, а со второго — нельзя; поэтому минимальное значение в редакторе равно -1.';

  @override
  String get stopColumn => 'Стоп-колонка';

  @override
  String get speedUp => 'Множитель скорости';

  @override
  String get baseCostIncreased =>
      'Базовое увеличение стоимости (BaseCostIncreased)';

  @override
  String get maxIncreasedCount =>
      'Макс. количество увеличений (MaxIncreasedCount)';

  @override
  String get initialMistPositionX => 'Начальная позиция тумана X';

  @override
  String get normalValueX => 'Нормальное значение X';

  @override
  String get bloverEffectInterval => 'Интервал эффекта травинки (сек)';

  @override
  String get dinoType => 'Тип динозавра';

  @override
  String get dinoRowTitle => 'Ряд';

  @override
  String dinoRow(int n) {
    return 'Ряд: $n';
  }

  @override
  String get dinoWaveDuration => 'Время на поле (волны)';

  @override
  String get eventHelpDinoType =>
      'Какой динозавр появится на поле. У каждого вида своё поведение при помощи зомби.';

  @override
  String get eventHelpDinoRow =>
      'Ряд появления динозавра (с 0). На картах глубокого моря доступен ряд 5.';

  @override
  String get eventHelpDinoWaveDuration =>
      'Сколько волн динозавр остаётся на поле перед уходом.';

  @override
  String get unknownModuleTitle => 'Редактор модуля в разработке';

  @override
  String get unknownModuleHelpTitle => 'Неизвестный модуль';

  @override
  String get unknownModuleHelpBody =>
      'Модуль не зарегистрирован в интерпретаторе уровней.';

  @override
  String get noEditorForModule => 'Редактор для этого модуля недоступен';

  @override
  String get noEditorForModuleBody =>
      'Модуль не зарегистрирован. Возможно добавлен вручную или objclass изменён.';

  @override
  String get invalidEventTitle => 'Недействительное событие';

  @override
  String get invalidEventBody => 'Объект события не удалось разобрать.';

  @override
  String get invalidReference => 'Недействительная ссылка';

  @override
  String aliasNotFound(String alias) {
    return 'Псевдоним \"$alias\" не найден';
  }

  @override
  String invalidRefBody(int wave) {
    return 'Волна $wave ссылается на событие, но объект не найден. Игра упадёт.';
  }

  @override
  String get removeInvalidRef => 'Удалить недействительную ссылку из волны';

  @override
  String get spawnCount => 'Количество появления';

  @override
  String get columnRangeTiming => 'Диапазон колонок и время';

  @override
  String get waveStartMessage => 'Сообщение при старте волны';

  @override
  String get zombieTypeZombieName => 'Тип зомби (ZombieName)';

  @override
  String get optional => 'Необязательно';

  @override
  String get eventHelpBeachStageBody =>
      'Зомби появляются при отливе. Используется в Пиратских морях.';

  @override
  String get eventHelpTidalChangeBody =>
      'Это событие меняет позицию прилива во время волны.';

  @override
  String get eventTideWave => 'Событие: подводные волны';

  @override
  String get eventHelpTideWaveBody =>
      'Сместить подлодку. Направление: влево или вправо.';

  @override
  String get tideWaveHelpType => 'Направление';

  @override
  String get eventHelpTideWaveType =>
      'Влево: прилив влево. Вправо: прилив вправо.';

  @override
  String get tideWaveHelpParams => 'Параметры';

  @override
  String get eventHelpTideWaveParams =>
      'Длительность, расстояние движения подлодки, ускорение.';

  @override
  String get tideWaveType => 'Направление';

  @override
  String get tideWaveTypeLeft => 'Влево';

  @override
  String get tideWaveTypeRight => 'Вправо';

  @override
  String get tideWaveDuration => 'Длительность (секунды)';

  @override
  String get tideWaveSubmarineMovingDistance => 'Длина перемещения';

  @override
  String get tideWaveSpeedUpDuration => 'Длительность ускорения (секунды)';

  @override
  String get tideWaveSpeedUpIncreased => 'Ускорение увел.';

  @override
  String get tideWaveSubmarineMovingTime => 'Время движения подлодки (секунды)';

  @override
  String get tideWaveZombieMovingSpeed => 'Скорость зомби';

  @override
  String get eventZombieFishWave => 'Cпавн зомби и рыб';

  @override
  String get eventHelpZombieFishWaveBody =>
      'Настройка зомби и рыб. Строка и столбец с 0.';

  @override
  String get eventHelpZombieFishWaveFish =>
      'Размещение рыб на сетке. Размер зависит от стадии: Глубокое море 6×10, обычная 5×9. Строка=Y, Столбец=X.';

  @override
  String get eventHelpBatchLevel =>
      'Установить уровень для всех неэлитных зомби в этой волне. Элитные сохраняют уровень по умолчанию.';

  @override
  String get eventHelpDropConfig =>
      'Подкормка или семена растений, которые несут зомби. Добавьте растения для выпадения карт.';

  @override
  String get fishPropertiesEntryHelp =>
      'Нажмите на ячейку, затем добавьте рыб. Нажмите + для встроенной рыбы. Нажмите на карточку рыбы для копирования, удаления, переключения варианта или создания кастомной. Кастомные рыбы отображают синий значок C. Рыбы вне газона показываются с предупреждением.';

  @override
  String get fishAddCustom => 'Добавить пользовательскую рыбу';

  @override
  String get addFishLabel => 'Добавить рыбу';

  @override
  String get addBuiltInFishLabel => 'Добавить встроенную рыбу';

  @override
  String get makeFishAsCustom => 'Сделать пользовательской';

  @override
  String get switchCustomFish => 'Переключить';

  @override
  String get selectCustomFish => 'Выбрать пользовательскую рыбу';

  @override
  String get editCustomFishProperties =>
      'Редактировать свойства пользовательской рыбы';

  @override
  String get fishPropertiesButton => 'Свойства рыб';

  @override
  String get addFishProperties => 'Добавить рыб';

  @override
  String get editFishProperties => 'Редактировать рыб';

  @override
  String get fishPropertiesGrid => 'Размещение рыб (строка Y, столбец X)';

  @override
  String get fishSelectedPosition => 'Выбрано:';

  @override
  String get fishRow => 'Строка';

  @override
  String get fishColumn => 'Столбец';

  @override
  String get fishAtPosition => 'Рыбы здесь:';

  @override
  String get searchFish => 'Поиск рыб';

  @override
  String get noFishFound => 'Рыбы не найдены';

  @override
  String get customFishManagerTitle => 'Пользовательские рыбы';

  @override
  String get customFishAppearanceLocation => 'Место появления:';

  @override
  String get customFishNotUsed =>
      'Эта пользовательская рыба не используется ни в одной волне.';

  @override
  String customFishWaveItem(int n) {
    return 'Волна $n';
  }

  @override
  String get customFishDeleteConfirm =>
      'Удалить эту пользовательскую рыбу и её данные свойств.';

  @override
  String get customFish => 'Пользовательская рыба';

  @override
  String get customFishProperties => 'Свойства пользовательской рыбы';

  @override
  String get fishTypeNotFound => 'Объект типа рыбы не найден.';

  @override
  String fishTypeLabel(String type) {
    return 'Тип рыбы: $type';
  }

  @override
  String get customFishHelpIntro => 'Краткое введение';

  @override
  String get customFishHelpIntroBody =>
      'На этом экране редактируются параметры пользовательской рыбы. Поддерживаются только общие свойства; анимацию и специальные атрибуты нужно редактировать вручную в JSON.';

  @override
  String get customFishHelpProps => 'Свойства';

  @override
  String get customFishHelpPropsBody =>
      'HitRect, AttackRect, ScareRect определяют области столкновения. Speed и ScareSpeed управляют движением. ArtCenter — якорь отрисовки.';

  @override
  String get noEditableFishProps => 'Редактируемые свойства не найдены.';

  @override
  String get fishPropSpeed => 'Скорость';

  @override
  String get fishPropScareSpeed => 'Скорость при испуге';

  @override
  String get fishPropDamage => 'Урон';

  @override
  String get fishPropHitpoints => 'Прочность';

  @override
  String get fishPropHitPoints => 'Очки здоровья';

  @override
  String get fishPropHitRect => 'Область попадания';

  @override
  String get fishPropAttackRect => 'Область атаки';

  @override
  String get fishPropScareRect => 'Область испуга';

  @override
  String get fishPropScarerect => 'Область испуга';

  @override
  String get fishPropArtCenter => 'Центр отрисовки';

  @override
  String get edit => 'Редактировать';

  @override
  String get eventHelpTidalChangePosition =>
      'Колонка 0 — справа, 9 — слева. ChangeAmount задаёт границу воды.';

  @override
  String get eventHelpBlackHoleBody =>
      'Событие мира Кунг-фу. Чёрная дыра притягивает растения вправо.';

  @override
  String get eventHelpBlackHoleColumns =>
      'Количество колонок, на которые притягиваются растения.';

  @override
  String get eventHelpMagicMirrorBody =>
      'Волшебные зеркала создают парные порталы на поле.';

  @override
  String get eventHelpMagicMirrorType =>
      'Индекс типа меняет вид зеркала. 3 стиля.';

  @override
  String get eventHelpParachuteRainBody =>
      'Зомби падают с неба во время волны.';

  @override
  String get eventHelpParachuteRainLogic =>
      'Зомби появляются группами. Контроль количества, размера группы, колонок.';

  @override
  String get eventHelpModernPortalsBody =>
      'Создаёт временные порталы на поле, типично для Modern world.';

  @override
  String get eventHelpModernPortalsType =>
      'Много типов порталов; выберите нужный.';

  @override
  String get eventHelpModernPortalsIgnore =>
      'Включено — порталы появятся даже при блокировке надгробиями.';

  @override
  String get eventHelpFrostWindBody =>
      'Событие Ice Age. Морозный ветер замораживает растения.';

  @override
  String get eventHelpFrostWindDirection =>
      'Направление ветра: слева или справа.';

  @override
  String get eventHelpModifyConveyorBody =>
      'Изменяет конвейер во время волны. Добавить или удалить растения.';

  @override
  String get eventHelpModifyConveyorAdd => 'Добавить растения на конвейер.';

  @override
  String get eventHelpModifyConveyorRemove => 'Удалить растения с конвейера.';

  @override
  String get eventHelpDinoBody =>
      'Событие появления динозавра. Вызов динозавра на указанный ряд.';

  @override
  String get eventHelpDinoDuration => 'Время пребывания динозавра, в волнах.';

  @override
  String get eventDinoTread => 'Событие: Шаг динозавра';

  @override
  String get eventDinoRun => 'Событие: Бег динозавров';

  @override
  String get eventHelpDinoTreadBody =>
      'Динозавр наступает на область сетки (ряд Y, столбцы XMin–XMax), уничтожая растения.';

  @override
  String get eventHelpDinoTreadRowCol =>
      'GridY — ряд центра удара; GridXMin и GridXMax задают диапазон возможных центральных столбцов (с 0). Каждый удар покрывает область 3×3 вокруг центра. На предпросмотре выделены все клетки, которые могут быть затронуты. Глубокое море: ряды 0–5, столбцы 0–9.';

  @override
  String get dinoTreadPreview => 'Предпросмотр возможной области удара';

  @override
  String get dinoTreadRowLabel => 'Ряд [GridY]';

  @override
  String get dinoTreadColMinLabel => 'Столбец мин [GridXMin]';

  @override
  String get dinoTreadColMaxLabel => 'Столбец макс [GridXMax]';

  @override
  String get dinoTreadTimeIntervalLabel =>
      'Интервал появления (TimeInterval; секунды)';

  @override
  String get columnStartLabel => 'Начало [ColumnStart]';

  @override
  String get columnEndLabel => 'Конец [ColumnEnd]';

  @override
  String get eventHelpDinoRunBody =>
      'Динозавры бегут по лужайке, сметая растения на пути.';

  @override
  String get eventHelpDinoRunRow =>
      'DinoRow — центральный ряд бега (красный на предпросмотре). Стадо может появиться и в соседних рядах сверху и снизу (жёлтые). Нумерация с 0. Глубокое море поддерживает ряд 5.';

  @override
  String get dinoRunPreview => 'Предпросмотр стада';

  @override
  String get positionAndArea => 'Позиция и область';

  @override
  String get positionAndDuration => 'Позиция и время';

  @override
  String get rowCol0Index => 'Ряд/столбец (с 0)';

  @override
  String get timeInterval => 'Интервал времени';

  @override
  String get eventHelpZombiePotionBody =>
      'Создаёт зелья на сетке, может перекрывать растения.';

  @override
  String get eventHelpZombiePotionUsage =>
      'Выберите клетку, нажмите добавить, выберите тип зелья.';

  @override
  String get eventHelpShellBody =>
      'Создаёт атлантические ракушки на сетке в указанных позициях.';

  @override
  String get eventHelpShellUsage =>
      'Выберите клетку, нажмите добавить для размещения ракушки (5×9 или 6×10 в зависимости от этапа).';

  @override
  String get eventHelpPumpkinHouseBody =>
      'Размещает тыквенные домики в указанных клетках во время волны.';

  @override
  String get eventHelpPumpkinHouseUsage =>
      'Выберите клетку и нажмите «+», чтобы разместить тыквенный домик (5×9 или 6×10 в зависимости от этапа).';

  @override
  String get eventHelpZombieTentBody =>
      'Размещает палатки зомби на выбранных клетках. У каждой палатки своё здоровье; она периодически призывает зомби из взвешенного пула (ZombieTypesToSpawn). Для праздничной палатки используйте TentType=zombie_festival_tent, для обычной — zombie_tent.';

  @override
  String get eventHelpZombieTentUsage =>
      'Выберите клетку и нажмите «+», затем настройте тип палатки, здоровье, интервал производства и добавьте зомби с весом и уровнем. В JSON уровня Column и Row нумеруются с 1.';

  @override
  String get eventHelpZombieTentFieldsTitle => 'Описание параметров';

  @override
  String get eventHelpZombieTentFields =>
      'TentType: zombie_tent или zombie_festival_tent.\nHitpoints: прочность палатки.\nProductionInterval: секунды между попытками призыва.\nZombieTypesToSpawn: ZombieTypeName, Weight (относительный шанс), Level (0 = уровень лужайки по умолчанию).';

  @override
  String get eventZombieTentSpawn => 'Событие: появление палаток зомби';

  @override
  String get zombieTentSectionTitle => 'Палатки на выбранной клетке';

  @override
  String get zombieTentTypeLabel => 'Тип палатки (TentType)';

  @override
  String get zombieTentTypeNormal => 'Обычная палатка';

  @override
  String get zombieTentTypeFestival => 'Праздничная палатка';

  @override
  String get zombieTentHitpoints => 'Прочность';

  @override
  String get zombieTentProductionInterval => 'Интервал производства (с)';

  @override
  String get zombieTentZombiesSection => 'Зомби для призыва';

  @override
  String get zombieTentWeight => 'Вес';

  @override
  String get zombieTentAddZombie => 'Добавить зомби';

  @override
  String get zombieTentAddTent => 'Добавить палатку';

  @override
  String get zombieTentDeleteTitle => 'Удалить палатку';

  @override
  String get zombieTentDeleteConfirm => 'Удалить эту палатку?';

  @override
  String get eventHelpFairyFogBody =>
      'Создаёт туман, дающий зомби щиты. Только ветер развеивает.';

  @override
  String get eventHelpFairyFogRange =>
      'mX, mY — центр; mWidth, mHeight — вправо и вниз.';

  @override
  String get eventHelpFairyWindBody =>
      'Создаёт ветер, разгоняющий сказочный туман.';

  @override
  String get eventHelpFairyWindVelocity =>
      'Меняет скорость снарядов. 1.0 — базовая.';

  @override
  String get eventHelpRaidingPartyBody =>
      'Событие Pirate. Пиратские зомби появляются группами.';

  @override
  String get eventHelpRaidingPartyGroup => 'Зомби в группе.';

  @override
  String get eventHelpRaidingPartyCount => 'Всего пиратских зомби.';

  @override
  String get eventHelpGravestoneBody =>
      'Случайно создаёт препятствия во время волны.';

  @override
  String get eventHelpGravestoneLogic =>
      'Выбор из пула позиций. Предметов не больше позиций.';

  @override
  String get eventHelpGravestoneMissingAssets =>
      'На картах без эффекта надгробий могут отображаться текстуры солнца.';

  @override
  String get eventHelpBarrelWaveBody =>
      'Катящиеся бочки по рядам. Три типа: пустая (без награды), зомби (внутри зомби), взрывная (взрывается при попадании). Ряды с 1.';

  @override
  String get barrelWaveHelpTypes => 'Типы бочек';

  @override
  String get eventHelpBarrelWaveTypes =>
      'Пустая: бочка без зомби. Бочка с зомби: при поломке выпускает зомбиж; используйте выбор зомби. Взрывная: бочка взрывается при попадании; задайте урон взрыва.';

  @override
  String get barrelWaveHelpRows => 'Ряды';

  @override
  String get eventHelpBarrelWaveRows =>
      'Ряды с 1: ряд 1 = сверху, 5/6 = снизу. Стандарт: 5 рядов. Глубокое море: 6 рядов.';

  @override
  String get eventHelpSchoolBusBody =>
      'Спавнит фургон с мороженым в выбранном ряду. Фургон выезжает справа, занимает два ряда и раздавливает растения на пути. Тип «Особый» (schoolbus_special) — с зомби на кузове, которые при наличии растений на поле используют способности во время движения. Тип «Обычный» (schoolbus_normal) — стандартный вариант. После уничтожения выпускает настроенных зомби.';

  @override
  String get schoolBusHelpRows => 'Ряд';

  @override
  String get eventHelpSchoolBusRows =>
      'Ряды с 1: ряд 1 = сверху, 5/6 = снизу. Стандарт: 5 рядов. Глубокое море: 6 рядов.';

  @override
  String get eventHelpSchoolBusType =>
      'Тип выбирает вариант фургона. Обычный (schoolbus_normal) — стандартный фургон. Особый (schoolbus_special) — с пузырными и леденцовыми зомби на кузове; при наличии растений на поле они используют способности во время движения.';

  @override
  String get schoolBusHelpZombies => 'Зомби';

  @override
  String get eventHelpSchoolBusZombies =>
      'Зомби, выпускаемые при уничтожении фургона. Уровень от 0 до 10 (0 = без бонуса уровня).';

  @override
  String get schoolBusRow => 'Ряд';

  @override
  String get schoolBusType => 'Тип';

  @override
  String get schoolBusTypeNormal => 'Обычный';

  @override
  String get schoolBusTypeSpecial => 'Особый';

  @override
  String get schoolBusHitPoints => 'Здоровье фургона (SchoolBusHitPoints)';

  @override
  String get schoolBusSpeed => 'Скорость фургона (SchoolBusSpeed)';

  @override
  String get schoolBusZombies => 'Зомби внутри (Zombies)';

  @override
  String get schoolBusZombieLevel => 'Уровень зомби (Level)';

  @override
  String get schoolBusAddZombie => 'Добавить зомби';

  @override
  String get schoolBusRowsHint => 'Ряды с 1: ряд 1 = сверху, 5/6 = снизу.';

  @override
  String get eventHelpThunderWaveBody =>
      'Молнии случайно бьют во время волны. Каждая молния может быть положительной (полезной) или отрицательной (вредной для растений).';

  @override
  String get thunderWaveHelpTypes => 'Типы молний';

  @override
  String get eventHelpThunderWaveTypes =>
      'Положительная: полезная молния. Отрицательная: вредная молния, может убивать растения по вероятности Kill rate.';

  @override
  String get thunderWaveHelpKillRate => 'Вероятность убийства';

  @override
  String get eventHelpThunderWaveKillRate =>
      'Вероятность (0.0–1.0) того, что отрицательная молния убьёт растения на поражённой клетке.';

  @override
  String get thunderWaveTypePositive => 'Положительная';

  @override
  String get thunderWaveTypeNegative => 'Отрицательная';

  @override
  String get thunderWaveKillRate => 'Вероятность убийства';

  @override
  String get thunderWaveKillRateHint =>
      'Вероятность убийства растений при ударе молнии (0.0–1.0)';

  @override
  String get thunderWaveThunders => 'Молнии';

  @override
  String get thunderWaveAddThunder => 'Добавить молнию';

  @override
  String get thunderWaveThunder => 'Молния';

  @override
  String get barrelWaveTypeEmpty => 'Пустая';

  @override
  String get barrelWaveTypeZombie => 'С зомби';

  @override
  String get barrelWaveTypeExplosive => 'Взрывная';

  @override
  String get barrelWaveRowsHint =>
      'Ряды с 1 (5 стандарт, 6 для подводного мира).';

  @override
  String get barrelWaveAddBarrel => 'Добавить бочку';

  @override
  String get barrelWaveBarrel => 'Бочка';

  @override
  String get barrelWaveRow => 'Ряд';

  @override
  String get barrelWaveType => 'Тип';

  @override
  String get barrelWaveHitPoints => 'Прочность';

  @override
  String get barrelWaveSpeed => 'Скорость';

  @override
  String get barrelWaveZombies => 'Зомби';

  @override
  String get barrelWaveZombieLevel => 'Уровень зомби';

  @override
  String get barrelWaveAddZombie => 'Добавить зомби';

  @override
  String get barrelWaveExplosionDamage => 'Урон взрыва';

  @override
  String get barrelWaveDeleteTitle => 'Удалить бочку';

  @override
  String get barrelWaveDeleteConfirm => 'Удалить эту бочку?';

  @override
  String get barrelWaveDeleteLastHint =>
      'Это последняя бочка. У события не останется бочек. Продолжить?';

  @override
  String get eventHelpGraveSpawnWait =>
      'Задержка от начала волны до появления зомби.';

  @override
  String get eventHelpStormBody =>
      'Песчаная буря или метель телепортирует зомби вперёд.';

  @override
  String get eventHelpStormColumns =>
      'Колонка 0 — слева, 9 — справа. Начало < конец.';

  @override
  String get eventHelpStormLevels =>
      'Уровень и ряд зомби внутри бури нельзя задавать независимо. Ручное изменение уровня зомби не действует: уровень по умолчанию определяется последовательностью уровней газона.';

  @override
  String get eventHelpGroundSpawnBody => 'Настройка зомби этой волны.';

  @override
  String get moduleHelpDeathHoleBody =>
      'После того как растение выкопано или съедено, на его клетке на некоторое время остаётся непригодная для посадки яма.';

  @override
  String get moduleHelpZombieMoveFastBody =>
      'Зомби быстро перемещаются при выходе на поле и возвращаются к обычной скорости после достижения указанного столбца. Этот модуль используется в Zombie Elimination Initiative.';

  @override
  String get moduleHelpSeedRainBody =>
      'Этот модуль через заданные интервалы сбрасывает с неба карточки предметов.';

  @override
  String get moduleHelpSeedRainParameters => 'Настройка параметров';

  @override
  String get moduleHelpSeedRainParametersBody =>
      'Вес определяет вероятность выпадения, а максимальное количество — сколько одинаковых предметов может одновременно находиться на поле. Для большинства зомби нет подходящих значков карточек.';

  @override
  String get moduleHelpSeedRainPlantLevels => 'Уровни растений';

  @override
  String get seedRainAddContentTitle => 'Добавить содержимое дождя из семян';

  @override
  String get seedRainAddPlantDescription =>
      'Выберите одну или несколько карточек растений, которые будут падать с неба.';

  @override
  String get seedRainAddZombieDescription =>
      'Выберите одну или несколько карточек зомби, которые будут падать с неба.';

  @override
  String get seedRainAddPlantFoodDescription =>
      'Добавьте подкормку как возможный выпадающий предмет.';

  @override
  String get moduleHelpRailcartBody =>
      'Здесь можно размещать вагонетки и рельсы и выбирать вид вагонетки. Нажмите клетку один раз для размещения и ещё раз для удаления.';

  @override
  String get moduleHelpRailcartRailsBody =>
      'В режиме укладки рельсов нажимайте клетки сетки. Редактор автоматически объединяет соседние клетки одного столбца в единый сегмент рельсов.';

  @override
  String get moduleHelpRailcartCartsBody =>
      'Нажимайте клетки, чтобы размещать или удалять вагонетки. Вагонетки на одном сегменте рельсов могут накладываться друг на друга.';

  @override
  String get moduleHelpTideBody =>
      'Включает систему приливов и начальную позицию.';

  @override
  String get moduleHelpTidePosition =>
      'Правая граница 0, левая 9. Отрицательные допустимы.';

  @override
  String get initialTidePosition => 'Начальная позиция прилива';

  @override
  String get moduleHelpManholeBody => 'Определяет подземные трубы Steam Age.';

  @override
  String get moduleHelpManholeEdit => 'Режим начало/конец, затем тап по сетке.';

  @override
  String get moduleHelpWeatherBody =>
      'Глобальные погодные эффекты (дождь, снег, темнота).';

  @override
  String get moduleHelpWeatherRef => 'Эти опции ссылаются на LevelModules.';

  @override
  String get moduleHelpZombiePotionBody =>
      'Этот модуль периодически создаёт указанные препятствия в случайных рядах справа налево.';

  @override
  String get moduleHelpZombiePotionMechanism => 'Механика появления';

  @override
  String get moduleHelpZombiePotionMechanismBody =>
      'Препятствия появляются случайно в заданном интервале времени. Если их количество на поле достигло предела, генерация приостанавливается.';

  @override
  String get moduleHelpZombiePotionPotionTypes => 'Типы зелий';

  @override
  String get moduleHelpZombiePotionTypes =>
      'Тип выбирается случайно из настроенного списка. Чтобы через фиксированный интервал создавать несколько препятствий, добавьте этот модуль в уровень несколько раз.';

  @override
  String get moduleHelpUnknownBody =>
      'Уровни состоят из корня и модулей. У каждого — aliases, objclass, objdata.';

  @override
  String get moduleHelpUnknownEvents =>
      'Приложение парсит по objclass. Модуль не зарегистрирован.';

  @override
  String get eventHelpInvalidBody =>
      'Событие указано, но парсер не находит объект.';

  @override
  String get eventHelpInvalidImpact =>
      'Сохранять ссылку — игра упадёт. Удалите вручную.';

  @override
  String get position => 'Позиция';

  @override
  String get editing => 'Редактирование';

  @override
  String get logic => 'Логика';

  @override
  String get impact => 'Влияние';

  @override
  String get events => 'События';

  @override
  String get referenceModules => 'Ссылки на модули';

  @override
  String get portalType => 'Тип портала (PortalType)';

  @override
  String get selectPortalType => 'Выберите тип портала';

  @override
  String get noPortalTypesFound => 'Типы порталов не найдены.';

  @override
  String get noPortalTypeSelected => 'Тип портала не выбран.';

  @override
  String get direction => 'Направление';

  @override
  String get windDirectionLabel => 'Направление ветра';

  @override
  String get velocityScale => 'Масштаб скорости';

  @override
  String get range => 'Диапазон';

  @override
  String get columnRange => 'Диапазон колонок';

  @override
  String get eventColumnRangeBoundaryHint =>
      'Левая граница газона — столбец 0, правая — столбец 9. Начальная колонка должна быть меньше конечной.';

  @override
  String get eventColumnRangeExampleHint =>
      'Чтобы спавнить с n-й по m-ю колонку, укажите n - 1 в начальной колонке и m в конечной.';

  @override
  String get zombieLevels => 'Уровни зомби';

  @override
  String get missingAssets => 'Отсутствуют ресурсы';

  @override
  String get usage => 'Использование';

  @override
  String get types => 'Типы';

  @override
  String get eventBlackHole => 'Событие чёрной дыры';

  @override
  String get attractionConfig => 'Настройка притяжения';

  @override
  String get placePlant => 'Разместить растение';

  @override
  String get plantList => 'Список растений (строки сначала)';

  @override
  String get firstCostume => 'Первый костюм (Avatar)';

  @override
  String get costumeOn => 'Костюм: надет';

  @override
  String get costumeOff => 'Костюм: не надет';

  @override
  String get outsideLawnItems => 'Объекты вне газона';

  @override
  String get zombieFromLeft => 'Слева';

  @override
  String get eventMagicMirror => 'Событие волшебного зеркала';

  @override
  String get eventParachuteRain =>
      'Событие парашютного/басового/паучьего дождя';

  @override
  String get selectZombie => 'Выбрать зомби';

  @override
  String get manholePipeline => 'Люковая труба';

  @override
  String get manholePipelines => 'Люковые трубы';

  @override
  String get manholePipelineHelpTitle => 'Люковый трубопровод';

  @override
  String get manholePipelineHelpOverview =>
      'Определяет подземные соединения труб в Паровых Веках.';

  @override
  String get manholePipelineHelpEditing =>
      'Переключайте режим начала/конца, затем нажмите на сетку для размещения.';

  @override
  String get smokePollutionModuleTitle => 'Модуль дымовых люков';

  @override
  String get smokePollutionModuleHelpTitle => 'Справка: дымовые люки';

  @override
  String get smokePollutionModuleHelpOverview => 'Обзор';

  @override
  String get smokePollutionModuleHelpOverviewBody =>
      'Размещает на газоне дымовые люки, которые через заданное время выбрасывают ядовитый пар. Часто используется в уровнях Парового века.';

  @override
  String get smokePollutionModuleHelpManholes => 'Проходные люки';

  @override
  String get smokePollutionModuleHelpManholesBody =>
      'Выберите клетку на сетке и добавьте люки в этой позиции. У каждого люка есть стартовое время — секунды от начала уровня до выброса ядовитого пара.';

  @override
  String get smokePollutionModuleStartTimeLabel => 'Стартовое время (с)';

  @override
  String manholePipelineStartEndFormat(int sx, int sy, int ex, int ey) {
    return 'Начало: ($sx, $sy)  Конец: ($ex, $ey)';
  }

  @override
  String get piratePlank => 'Пиратская доска';

  @override
  String get weatherModule => 'Модуль погоды';

  @override
  String get zombiePotion => 'Зелье зомби';

  @override
  String get zombiePotionSettings => 'Настройки зелий зомби';

  @override
  String get zombiePotionHelpTitle => 'Справка по модулю зелий зомби';

  @override
  String get eventTimeRift => 'Событие временного разлома';

  @override
  String get deathHole => 'Дыра смерти';

  @override
  String get seedRain => 'Семенной дождь';

  @override
  String get eventFrostWind => 'Событие ледяного ветра';

  @override
  String get lastStandSettings => 'Настройки последнего рубежа';

  @override
  String get lastStandInitialResourceSettings => 'Начальные ресурсы';

  @override
  String get lastStandManualStartupHint =>
      'После добавления модуля Last Stand редактор автоматически включает Manual Startup в модуле Wave Manager.';

  @override
  String get lastStandHelpTitle => 'Справка по модулю Last Stand';

  @override
  String get lastStandHelpOverviewBody =>
      'Когда этот модуль включён, уровень начинается с фазы подготовки: зомби не появляются сразу, а игрок может тратить начальное солнце на размещение растений. Волны начнутся только после нажатия кнопки начала боя.';

  @override
  String get lastStandHelpNotes => 'Примечания';

  @override
  String get lastStandHelpNotesBody =>
      'Для Last Stand нужно включить Manual Startup в Wave Manager, иначе зомби появятся автоматически. Редактор сам управляет этим переключателем при добавлении или удалении модуля Last Stand.';

  @override
  String moduleDependencyRequiredMessage(String moduleName) {
    return 'Чтобы выбрать этот модуль, сначала добавьте модуль «$moduleName».';
  }

  @override
  String get conveyorManualPacketSpawning => 'Ручное создание карточек';

  @override
  String get cowboyMinigameSettings => 'Настройки мини-игры «Неудачный загон»';

  @override
  String get cowboyMinigameBeginString => 'Текст подсказки';

  @override
  String get cowboyMinigameBeginStringHidden => 'Не показывать текст';

  @override
  String get cowboyMinigameBeginStringDefault => 'Стандартный текст';

  @override
  String get cowboyMinigameBeginStringCustom =>
      'Свой текст (поддерживает китайский)';

  @override
  String get cowboyMinigameCustomTextInput => 'Свой текст подсказки';

  @override
  String get cowboyMinigameShowTutorial => 'Показывать обучающий диалог';

  @override
  String get cowboyMinigameBeginStringHint =>
      'При добавлении модуля «Электрический загон» (Not ok corral) в модуле конвейера автоматически включается переключатель «Ручное создание карточек».';

  @override
  String get cowboyMinigameHelpTitle =>
      'Модуль мини-игры «Электрический загон»';

  @override
  String get cowboyMinigameHelpOverviewBody =>
      'Мини-игра Дикого Запада. Перед каждой волной игрок получает случайную карточку растения. После посадки начинается волна зомби; для победы нужно уничтожить всех зомби.\nПеред каждой посадкой показываются типы, количество и позиции зомби на каждой линии, что позволяет выбрать место для растения.';

  @override
  String get cowboyMinigameHelpBeginStringBody =>
      'Текст подсказки появляется вместе с предпросмотром зомби перед каждой посадкой. Стандартный текст в игре: «Посадите растение с конвейера, чтобы начать уровень!». Текст можно заменить своим.';

  @override
  String get cowboyMinigameHelpTutorialBody =>
      'Если включить обучающий диалог, Безумный Дейв и Пенни появятся перед началом уровня и объяснят сюжет мини-игры. Диалог основан на первом прохождении 4-го дня Дикого Запада.';

  @override
  String get singleHandedTabLabel => 'Сам за себя';

  @override
  String get singleHandedBasicParameters => 'Основные параметры';

  @override
  String get singleHandedOverviewBasicConfiguration => 'Базовая конфигурация';

  @override
  String get singleHandedMissileCount => 'Количество ракет за запуск';

  @override
  String get singleHandedMissileInterval => 'Интервал запуска ракет';

  @override
  String get singleHandedWarningTime => 'Время предупреждения';

  @override
  String get singleHandedRocketSpeed => 'Скорость ракеты';

  @override
  String get singleHandedZombieSpeedMultiplier => 'Множитель скорости зомби';

  @override
  String get singleHandedZombieHealthMultiplier => 'Множитель здоровья зомби';

  @override
  String get singleHandedSpecialMultiplierHint =>
      'В особых волнах скорость и здоровье дополнительно умножаются от этих базовых значений.';

  @override
  String get singleHandedPlantConfiguration => 'Настройка растений';

  @override
  String get singleHandedPlantConfigurationInfo =>
      'Начальное растение служит стартовым оружием и улучшается после нужного числа убийств.\nОно появляется в верхней левой клетке. Там должна стоять вагонетка, иначе уровень сразу считается проигранным.';

  @override
  String singleHandedInitialPlantSubtitle(String interval) {
    return 'Начальное растение · Интервал атаки: $interval';
  }

  @override
  String get singleHandedAttackInterval => 'Интервал атаки';

  @override
  String get singleHandedAttackIntervalHint =>
      'Чем меньше интервал, тем выше скорость атаки.';

  @override
  String get singleHandedAddUpgradePlant => 'Добавить улучшенное растение';

  @override
  String get singleHandedNoUpgradePlants => 'Улучшенных растений пока нет.';

  @override
  String get singleHandedRequiredKills => 'Требуется убийств';

  @override
  String singleHandedEditUpgradePlant(String plantName) {
    return 'Изменить: $plantName';
  }

  @override
  String singleHandedUpgradePlantSubtitle(int kills, String interval) {
    return 'Убийств: $kills · Интервал атаки: $interval';
  }

  @override
  String get singleHandedSpecialWaves => 'Особые волны';

  @override
  String get singleHandedSpecialWavesInfo =>
      'Используются для волн с боссами. Множители скорости и здоровья применяются поверх базовых значений выше.';

  @override
  String get singleHandedAddSpecialWave => 'Добавить особую волну';

  @override
  String get singleHandedNoSpecialWaves => 'Особых волн пока нет.';

  @override
  String get singleHandedSpecialWave => 'Особая волна';

  @override
  String get singleHandedWave => 'Волна';

  @override
  String get singleHandedSpeedMultiplier => 'Множитель скорости';

  @override
  String get singleHandedHealthMultiplier => 'Множитель здоровья';

  @override
  String get singleHandedShowHealthBar => 'Показывать шкалу здоровья';

  @override
  String singleHandedWaveNumber(int wave) {
    return 'Волна $wave';
  }

  @override
  String get singleHandedHealthBarEnabled => 'Шкала здоровья включена';

  @override
  String get singleHandedHealthBarDisabled => 'Шкала здоровья выключена';

  @override
  String singleHandedSpecialWaveSubtitle(String speed, String health) {
    return 'Скорость x$speed · Здоровье x$health';
  }

  @override
  String get singleHandedAddTutorial =>
      'Добавить обучение мини-игры «Сам за себя»';

  @override
  String get singleHandedConfigureTutorial =>
      'Настроить обучение мини-игры «Сам за себя»';

  @override
  String get singleHandedTutorialSettings =>
      'Настройки обучения мини-игры «Сам за себя»';

  @override
  String get singleHandedTutorialWaveForStartRocket => 'Волна появления ракет';

  @override
  String get singleHandedTutorialHelpTitle => 'Обучение «В одиночку»';

  @override
  String get singleHandedTutorialHelpPromptsTitle => 'Обучающие подсказки';

  @override
  String get singleHandedTutorialHelpPromptsBody =>
      'После добавления этого модуля соответствующие обучающие подсказки появляются в начале уровня, при первом улучшении растения и при первом предупреждении о ракетах.';

  @override
  String get singleHandedTutorialHelpWaveTitle => 'Волна появления ракет';

  @override
  String get singleHandedTutorialHelpWaveBody =>
      'Можно указать волну, с которой начинают появляться ракеты; отсчёт интервала запуска начинается с этой волны. Например, при интервале 30 секунд и начальной волне 7 первая группа ракет будет запущена через 30 секунд после начала волны 7.\nСам по себе этот модуль не вызывает падение ракет на заданной волне. Настройка начальной волны действует только вместе с модулем «В одиночку».';

  @override
  String get hamsterballGeneration => 'Логика появления';

  @override
  String get hamsterballTimeBeforeFullSpawn =>
      'Время до полного появления (TimeBeforeFullSpawn; секунды)';

  @override
  String get hamsterballZombies => 'Зомби внутри шаров (Zombies)';

  @override
  String get hamsterballAddZombie => 'Добавить зомби';

  @override
  String get hamsterballEmptyZombies => 'В списке нет зомби';

  @override
  String get hamsterballZombieLevel => 'Уровень зомби';

  @override
  String get hamsterballInitialSpeed => 'Начальная скорость';

  @override
  String get hamsterballBehavior => 'Поведение';

  @override
  String get hamsterballBehaviorUniform => 'Постоянная скорость';

  @override
  String get hamsterballBehaviorSlowdown => 'Сначала быстро, затем медленно';

  @override
  String get hamsterballBehaviorChangeLane => 'Смена ряда при столкновении';

  @override
  String get hamsterballBehaviorDetailUniform =>
      'движется с постоянной скоростью';

  @override
  String get hamsterballBehaviorDetailSlowdown =>
      'сначала движется быстро, а после столкновения с растением замедляется';

  @override
  String get hamsterballBehaviorDetailChangeLane =>
      'после столкновения с растением меняет ряд';

  @override
  String hamsterballBehaviorSummary(String value) {
    return 'Поведение (Behavior): $value';
  }

  @override
  String get hamsterballHasPlantfood => 'Несёт подкормку (HasPlantfood)';

  @override
  String get hamsterballHelpTitle => 'Описание события с хомячьими шарами';

  @override
  String get hamsterballHelpOverviewTitle => 'Краткое описание';

  @override
  String get hamsterballHelpOverviewBody =>
      'Это событие-засада появилось в китайской версии в Тайном мире 12-летия. Оно вызывает катящиеся хомячьи шары, которые доставляют зомби на поле. У шаров есть три режима поведения, а растения на пути мгновенно уничтожаются.\nУ хомячьих шаров есть собственный запас здоровья. После разрушения они выпускают находившихся внутри зомби, и те продолжают движение. Шип-трава, Каменный шип и похожие растения могут проколоть шар и освободить зомби.';

  @override
  String get hamsterballHelpRangeTitle => 'Диапазон движения';

  @override
  String get hamsterballHelpRangeBody =>
      'Диапазон движения шаров фиксирован: от столбца 0 до столбца 8. Эти поля не влияют на редактируемое содержимое и записываются редактором автоматически.';

  @override
  String get hamsterballHelpGenerationTitle => 'Логика появления';

  @override
  String get hamsterballHelpGenerationBody =>
      'Размер группы задаёт число шаров в группе, а интервал — задержку между соседними группами. После достижения времени полного появления дополнительные группы не создаются, и все оставшиеся шары появляются сразу.';

  @override
  String get cowboyMinigameDependencyWarningTitle =>
      'Отсутствует обязательный модуль';

  @override
  String get cowboyMinigameConveyorWarning =>
      'Модуль «Электрический загон» должен использоваться вместе с модулем конвейера, иначе уровень завершится с ошибкой.';

  @override
  String customGravestoneReplacePrompt(String gridItemName) {
    return 'На уровень можно добавить только одно пользовательское надгробие. Заменить существующее пользовательское надгробие на «$gridItemName»?';
  }

  @override
  String get customGravestoneResourceGroupPrompt =>
      'Чтобы надгробие дома игрока отображалось правильно и не использовало текстуру солнца, на газон нужно добавить группу ресурсов \"Modern_Gravestone\". Перейти к пользовательским газонам и добавить её? За основу можно взять шаблон «Современное кладбище».';

  @override
  String get openCustomStageSelection => 'Открыть пользовательские газоны';

  @override
  String get customGridItemReplaceAction => 'Заменить';

  @override
  String get roofFlowerPot => 'Цветочный горшок на крыше';

  @override
  String get roofFlowerPotColumns => 'Диапазон цветочных горшков';

  @override
  String get roofFlowerPotStartColumn => 'Начальная колонка (StartColumn)';

  @override
  String get roofFlowerPotEndColumn => 'Конечная колонка (EndColumn)';

  @override
  String get roofFlowerPotPreview => 'Предпросмотр горшков';

  @override
  String get roofFlowerPotLawnMismatchWarning =>
      'Текущий газон не является крышей. Модуль может не сработать в игре и даже вызвать сбой уровня.';

  @override
  String get eventConveyorModify => 'Событие изменения конвейера';

  @override
  String get bowlingMinigame => 'Мини-игра в боулинг';

  @override
  String get zombieMoveFast => 'Быстрое движение зомби';

  @override
  String get eventPotionDrop => 'Событие падения зелья';

  @override
  String get eventShellSpawn => 'Событие спавна ракушек';

  @override
  String get eventPumpkinHouseSpawn => 'Событие: тыквенные домики';

  @override
  String get eventSchoolBusSpawn => 'Событие: фургон с мороженым';

  @override
  String get warMist => 'Военный туман';

  @override
  String get eventDino => 'Событие динозавра';

  @override
  String get duration => 'Длительность';

  @override
  String get sunDropper => 'Солнечный дождь';

  @override
  String get eventFairyWind => 'Событие сказочного ветра';

  @override
  String get eventFairyFog => 'Событие сказочного тумана';

  @override
  String get eventRaidingParty => 'Событие пиратского рейда';

  @override
  String get swashbucklerCount => 'Количество пиратов';

  @override
  String get sunBomb => 'Солнечная бомба';

  @override
  String get eventSpawnGravestones => 'Событие спавна надгробий';

  @override
  String get eventBarrelWave => 'Событие: бочки';

  @override
  String get eventThunderWave => 'Событие: гром';

  @override
  String get eventGraveSpawn => 'Событие спавна из могил';

  @override
  String get zombieSpawnWait => 'Ожидание спавна зомби';

  @override
  String get selectCustomZombie => 'Выбрать кастомного зомби';

  @override
  String get change => 'Изменить';

  @override
  String get autoLevel => 'Автоуровень';

  @override
  String get apply => 'Применить';

  @override
  String get applyBatchLevel => 'Применить групповой уровень?';

  @override
  String get conveyorBelt => 'Конвейер';

  @override
  String get starChallenges => 'Звёздные испытания';

  @override
  String get addChallenge => 'Добавить испытание';

  @override
  String get unknownChallengeType => 'Неизвестный тип испытания';

  @override
  String get protectedPlants => 'Защищаемые растения';

  @override
  String get addPlant => 'Разместить растение';

  @override
  String get protectedGridItems => 'Защищаемые предметы';

  @override
  String get addGridItem => 'Разместить препятствие';

  @override
  String get plantLevels => 'Уровни растений';

  @override
  String get scope => 'Область';

  @override
  String get applyBatch => 'Применить группу';

  @override
  String get addPlants => 'Добавить растения';

  @override
  String get noPlantsConfigured => 'Растения не настроены';

  @override
  String batchLevelFormat(int level) {
    return 'Групповой уровень: $level';
  }

  @override
  String get protectPlants => 'Защищать растения';

  @override
  String get autoCount => 'Автосчёт';

  @override
  String get overrideStartingPlantfood => 'Переопределить начальную еду';

  @override
  String get startingPlantfoodOverride => 'Переопределение начальной еды';

  @override
  String get iconText => 'Текст иконки';

  @override
  String get iconImage => 'Изображение иконки';

  @override
  String get overrideMaxSun => 'Переопределить максимум солнца';

  @override
  String get maxSunOverride => 'Переопределение макс. солнца';

  @override
  String get maxSunHelpTitle => 'Модуль макс. солнца';

  @override
  String get maxSunHelpOverview =>
      'Этот модуль изначально использовался для настройки уровней сложности. Используйте его для переопределения максимального количества солнца в уровне.';

  @override
  String get moonExpertZombieLevel => 'Уровень зомби (ZombieLevel)';

  @override
  String get moonExpertZombieLevelTooltip =>
      'Перезаписывает все уровни зомби в уровне значением ZombieLevel и ставит все растения на 1 уровень, независимо от настроек уровней растений в других модулях.';

  @override
  String get moonExpertHelpTitle => 'Лунный экспертный режим';

  @override
  String get moonExpertHelpOverview =>
      'Задаёт единый уровень зомби для всего уровня и сбрасывает все растения на 1 уровень, перекрывая другие настройки уровней растений и зомби.';

  @override
  String get enterMoonExpertZombieLevelHint => 'Введите уровень зомби (0–10)';

  @override
  String get startingPlantfoodHelpTitle => 'Модуль начальной еды';

  @override
  String get startingPlantfoodHelpOverview =>
      'Этот модуль изначально использовался для настройки уровней сложности. Используйте его для переопределения начального количества подкормки в уровне.';

  @override
  String get starChallengeHelpTitle => 'Модуль звёздных испытаний';

  @override
  String get starChallengeHelpOverview =>
      'Выберите модули испытаний для уровня. Можно задать несколько целей и использовать один тип испытания несколько раз.';

  @override
  String get starChallengeHelpSuggestionTitle => 'Рекомендации';

  @override
  String get starChallengeHelpSuggestion =>
      'У некоторых испытаний есть окна прогресса в игре. При большом количестве модулей они могут перекрываться.';

  @override
  String get remove => 'Удалить';

  @override
  String get plant => 'Растение';

  @override
  String get zombie => 'Зомби';

  @override
  String get initialZombieLayout => 'Начальная расстановка зомби';

  @override
  String get placeZombie => 'Разместить зомби';

  @override
  String get manualInput => 'Ручной ввод';

  @override
  String get waveManagerModule => 'Модуль менеджера волн';

  @override
  String get points => 'Очки';

  @override
  String get eventStorm => 'Событие бури';

  @override
  String get row => 'Ряд';

  @override
  String get addType => 'Добавить тип';

  @override
  String get plantFunExperimental => 'Растение (Развлечение/Эксп.)';

  @override
  String get availableZombies => 'Доступные зомби';

  @override
  String get presetPlants => 'Предвыбранные растения (PresetPlantList)';

  @override
  String get whiteList => 'Белый список (WhiteList)';

  @override
  String get blackList => 'Чёрный список (BlackList)';

  @override
  String get chooser => 'Выбор';

  @override
  String get preset => 'Пресет';

  @override
  String get seedBankHelp => 'Справка по банку семян';

  @override
  String get conveyorBeltHelp => 'Справка по конвейеру';

  @override
  String get dropDelayConditions => 'Задержка падения (DropDelayConditions)';

  @override
  String get unitSeconds => 'Ед.: секунды';

  @override
  String propertyLabelSeconds(String name, String code) {
    return '$name ($code; секунды)';
  }

  @override
  String get speedConditions => 'Скорость (SpeedConditions)';

  @override
  String get speedConditionsSubtitle => 'Станд. 100, выше — быстрее';

  @override
  String get addPlantConveyor => 'Добавить растение';

  @override
  String get addTool => 'Добавить инструмент';

  @override
  String get increasedCost => 'Повышенная стоимость';

  @override
  String get powerTile => 'Силовая плитка';

  @override
  String get powerTileGridSection => 'Сетка силовых плиток';

  @override
  String get powerTileGridHelpPrimary =>
      'Нажмите клетку, чтобы поставить выбранную группу. Повторное нажатие снимает плитку той же группы. Если там другая группа — она заменяется.';

  @override
  String get powerTileGridHelpSecondaryMobile =>
      'Долгое нажатие на клетку: выбор группы, очистка или задержка распространения.';

  @override
  String get powerTileGridHelpSecondaryDesktop =>
      'Правый щелчок по клетке: выбор группы, очистка или задержка распространения.';

  @override
  String get powerTileLinkedTilesSection => 'Связанные плитки';

  @override
  String get powerTilePropagationDelayLabel => 'Задержка распространения (с)';

  @override
  String get powerTilePropagationDelayTooltip =>
      'Задержка в секундах перед распространением эффекта по связи (0–5).';

  @override
  String get powerTileDialogEditCell => 'Редактировать клетку';

  @override
  String get powerTileDialogTileGroup => 'Группа плитки';

  @override
  String get powerTileDialogNone => 'Нет';

  @override
  String get powerTileDialogPropagationDelay => 'Задержка распространения (с)';

  @override
  String get powerTileHelpOverview =>
      'Размещайте силовые плитки по группам (α–ε). Для каждой можно задать задержку распространения. Плитки не из выбранной группы в сетке отображаются полупрозрачными.';

  @override
  String get powerTileHelpGridSize =>
      'На лужайках «Подводный Мир» / Атлантида сетка 10×6; на остальных — 9×5.';

  @override
  String powerTileHelpQuickEdit(String interaction) {
    return 'Быстрое редактирование: $interaction';
  }

  @override
  String get eventStandardSpawn => 'Событие: обычная волна';

  @override
  String get eventGroundSpawn => 'Событие: появление из-под земли';

  @override
  String get eventEditorInDevelopment => 'Редактор событий в разработке';

  @override
  String get level => 'Уровень';

  @override
  String get missingTideModule => 'Отсутствует модуль приливов';

  @override
  String get levelHasNoTideProperties =>
      'В уровне нет TideProperties. Событие может не работать.';

  @override
  String get changePosition => 'Изменить позицию';

  @override
  String get changePositionChangeAmount => 'Изменить позицию (ChangeAmount)';

  @override
  String get preview => 'Предпросмотр';

  @override
  String get fogPreview => 'Предпросмотр тумана';

  @override
  String get water => 'Вода';

  @override
  String get land => 'Суша';

  @override
  String get tidePositionOrderHint =>
      'Крайняя правая координата поля — 0, крайняя левая — 9. Модуль приливов необходимо добавлять последним, иначе уровень может аварийно завершиться.';

  @override
  String groupConfigN(int n) {
    return 'Конфигурация группы $n';
  }

  @override
  String get globalParameters => 'Глобальные параметры';

  @override
  String get timePerGrid => 'Время на клетку (секунды)';

  @override
  String get damagePerSecond => 'Урон в секунду';

  @override
  String get pipe => 'Труба';

  @override
  String get stageMismatch => 'Несовпадение этапа';

  @override
  String get currentStageNotPirate =>
      'Текущая лужайка не является Пиратскими Морями. Модуль может не работать.';

  @override
  String get plankPreview => 'Предпросмотр досок';

  @override
  String get plankRows => 'Ряды досок (0–4)';

  @override
  String get plankRowsDeepSea => 'Ряды досок (0–5)';

  @override
  String get selectedRows => 'Выбранные ряды';

  @override
  String get indexLabel => 'Индекс';

  @override
  String get selectWeatherType => 'Выбрать тип погоды';

  @override
  String get counts => 'Управление количеством';

  @override
  String get initialCount => 'Начальное количество';

  @override
  String get maximumCount => 'Максимальное количество';

  @override
  String get spawnInterval => 'Интервал появления';

  @override
  String get minimumIntervalSeconds => 'Минимальный интервал (секунды)';

  @override
  String get maximumIntervalSeconds => 'Максимальный интервал (секунды)';

  @override
  String get potionTypeList => 'Список типов зелий';

  @override
  String get initial => 'Начальное';

  @override
  String get max => 'Макс';

  @override
  String get spawnTimerShort => 'Интервал появления';

  @override
  String get minSec => 'Мин (сек)';

  @override
  String get maxSec => 'Макс (сек)';

  @override
  String get ignoreGravestoneSubtitle =>
      'Разрешить спавн несмотря на препятствия';

  @override
  String get thisPortalSpawns => 'Этот портал создаёт:';

  @override
  String startEndFormat(int sx, int sy, int ex, int ey) {
    return 'Начало: ($sx, $sy)  Конец: ($ex, $ey)';
  }

  @override
  String indexN(int n) {
    return 'Индекс: $n';
  }

  @override
  String get noItemsAddHint =>
      'Нет предметов. Добавьте растения, зомби или коллекционные.';

  @override
  String get zombieTypeSpiderZombieName => 'Тип зомби (SpiderZombieName)';

  @override
  String get noneSelected => 'Не выбрано';

  @override
  String get totalSpiderCount => 'Всего (SpiderCount)';

  @override
  String get perBatchGroupSize => 'В группе (GroupSize)';

  @override
  String get fallTime => 'Время падения (с)';

  @override
  String get waveStartMessageLabel => 'Красный подзаголовок (WaveStartMessage)';

  @override
  String get optionalWarningText => 'Необязательный текст предупреждения';

  @override
  String rowNShort(int n) {
    return 'Ряд $n';
  }

  @override
  String weightMaxFormat(int weight, int max) {
    return 'Вес: $weight, Макс: $max';
  }

  @override
  String seedRainTypeLabel(String type) {
    return 'Тип: $type';
  }

  @override
  String seedRainWeightLabel(int weight) {
    return 'Вес: $weight';
  }

  @override
  String seedRainMaxLabel(int max) {
    return 'Макс: $max';
  }

  @override
  String get random => 'Случайно';

  @override
  String get noChallengesConfigured => 'Нет настроенных испытаний';

  @override
  String get whiteListBlackListHint =>
      'Белый список: пусто = без ограничений. Чёрный список имеет приоритет.';

  @override
  String get conveyorBeltHelpIntro =>
      'Режим конвейера случайно генерирует карты по весу. Настройте пул растений и задержку.';

  @override
  String get conveyorBeltHelpPool =>
      'Пул растений и вес: вероятность = вес / общий вес.';

  @override
  String get conveyorBeltHelpDropDelay =>
      'Задержка падения: интервал появления карт. Больше растений — медленнее.';

  @override
  String get conveyorBeltHelpSpeed =>
      'Скорость: физическая скорость ленты. Станд. = 100.';

  @override
  String get cannotAddEliteZombies => 'Нельзя добавить элитных зомби';

  @override
  String get eliteZombiesNotAllowed => 'Элитные зомби здесь не доступны';

  @override
  String get yetiZombiesNotAllowed => 'Йети здесь не доступны';

  @override
  String fixToAlias(String alias) {
    return 'Исправить на $alias';
  }

  @override
  String editPresetZombie(String name) {
    return 'Редактировать пресет зомби: $name';
  }

  @override
  String get missingZombossMechModule =>
      'Отсутствует ZombossBattleModuleProperties';

  @override
  String get missingZombossBattleModule =>
      'Отсутствует ZombossLastStandMinigameProperties';

  @override
  String get challengeNoConfig => 'Это испытание не поддерживает настройку.';

  @override
  String get maxPotionCount => 'Макс. кол-во зелий';

  @override
  String potionTypesConfigured(int count) {
    return 'Типов зелий настроено: $count';
  }

  @override
  String pipelinesCount(int count) {
    return 'Трубы: $count';
  }

  @override
  String windN(int n) {
    return 'Ветер #$n';
  }

  @override
  String get zombieList => 'Список зомби (строки сначала)';

  @override
  String get positionPoolSpawnPositions => 'Пул позиций (SpawnPositionsPool)';

  @override
  String get tapCellsSelectDeselect =>
      'Нажмите клетки для выбора позиций призыва';

  @override
  String get gravestonePool => 'Пул надгробий (GravestonePool)';

  @override
  String get removePlants => 'Удалить растения';

  @override
  String get current => 'Текущий';

  @override
  String get eliteZombiesUseDefaultLevel =>
      'Элитные зомби используют уровень по умолчанию.';

  @override
  String get basicParameters => 'Основные параметры';

  @override
  String get zombieSpawnWaitSec => 'Ожидание призыва зомби (сек)';

  @override
  String get gridTypes => 'Типы препятствий';

  @override
  String zombiesCount(int count) {
    return 'Зомби ($count)';
  }

  @override
  String stormCarriedZombiesCount(int count) {
    return 'Переносимые зомби (всего: $count)';
  }

  @override
  String get eventGraveSpawnSubtitle => 'Событие: вылезание из препятствий';

  @override
  String get eventStormSpawnSubtitle => 'Событие: появление бури';

  @override
  String get eventHelpGraveSpawnBody =>
      'Событие призывает зомби из определённых препятствий, например из могил Тёмных Веков.';

  @override
  String get eventHelpGraveSpawnZombieWait =>
      'Задержка от начала волны до призыва. Если волна уже сменилась — зомби не появятся.';

  @override
  String get eventHelpStormOverview =>
      'Песчаная или снежная буря быстро доставляет зомби на переднюю линию. Ледяная замораживает растения.';

  @override
  String get eventHelpStormColumnRange =>
      'Колонки 0–9. Левый край — 0, правый — 9. Начальная колонка меньше конечной.';

  @override
  String get eventHelpStormZombieLevels =>
      'Уровень и ряд зомби внутри бури нельзя задавать независимо. Ручное изменение уровня зомби не действует: уровень по умолчанию определяется последовательностью уровней газона.';

  @override
  String get spawnParameters => 'Параметры появления';

  @override
  String get sandstorm => 'Песчаная буря';

  @override
  String get snowstorm => 'Снежная буря';

  @override
  String get excoldStorm => 'Ледяная буря';

  @override
  String get columnStart => 'Начальная колонка';

  @override
  String get columnEnd => 'Конечная колонка';

  @override
  String get groupSize => 'Размер группы';

  @override
  String get timeBetweenGroups =>
      'Время между группами (TimeBetweenGroups; секунды)';

  @override
  String applyBatchLevelContent(int level) {
    return 'Установить всем зомби этой волны уровень $level (элитные без изменений).';
  }

  @override
  String get randomRow => 'Случайный ряд';

  @override
  String levelFormat(int level) {
    return 'Уровень: $level';
  }

  @override
  String get levelAccount => 'Уровень: учётная запись';

  @override
  String levelDisplay(String value) {
    return 'Уровень: $value';
  }

  @override
  String get eventStandardSpawnTitle => 'Событие стандартной волны';

  @override
  String get eventGroundSpawnTitle => 'Событие вылезания из под земли';

  @override
  String get eventHelpStandardOverview =>
      'Настройка зомби этой волны. Уровень 0 — по уровню карты.';

  @override
  String get eventHelpStandardRow => 'Ряды 0–4. Пусто — случайный ряд.';

  @override
  String get eventHelpStandardRowDeepSea =>
      'Ряды 0–5 (6 рядов). Пусто — случайный ряд.';

  @override
  String get ztPerksSectionTitle => 'Баффы Побега из Тупика';

  @override
  String get ztPerksSectionHint =>
      'Каждый тип баффа можно назначить зомби только один раз.';

  @override
  String get ztPerksNone => 'Баффы не назначены.';

  @override
  String get ztPerksAdd => 'Добавить бафф';

  @override
  String get ztPerksAddTitle => 'Добавить баффы зомби';

  @override
  String get ztPerksTypeAlreadyAssigned => 'Бафф этого типа уже назначен.';

  @override
  String get eventHelpJitteredZtPerks =>
      'Назначайте баффы Побега из Тупика отдельным зомби. Они сохраняются в массиве Titles. На одного зомби можно назначить только один бафф каждого типа (например, Кристаллизация I и Кристаллизация II вместе нельзя).';

  @override
  String get ztPerkCategoryCrystal => 'Кристаллизация';

  @override
  String get ztPerkCategoryAttack => 'Сила';

  @override
  String get ztPerkCategorySpeed => 'Стремительность';

  @override
  String get ztPerkCategoryShield => 'Энергощит';

  @override
  String get ztPerkCategoryGravity => 'Гипергравитация';

  @override
  String get ztPerkCategoryImmuneControl => 'Непреклонность';

  @override
  String get ztPerkCategoryAntiControl => 'Концентрация';

  @override
  String get ztPerksViewStats => 'Показать параметры';

  @override
  String get ztPerkPropDamageTakenInterval =>
      'Интервал получения урона (секунды)';

  @override
  String get ztPerkPropDamageTotalTaken => 'Суммарное число получений урона';

  @override
  String get ztPerkPropDamageTakenPerTime => 'Урон за удар';

  @override
  String get ztPerkPropHpReduced => 'Снижение здоровья';

  @override
  String get ztPerkPropShieldNum => 'Заряды щита';

  @override
  String get ztPerkPropReducedControlPercent => 'Снижение эффектов контроля';

  @override
  String get ztPerkPropReducedDamagePercent => 'Снижение урона';

  @override
  String get ztPerkPropImprovedDamagePercent => 'Усиление силы атаки';

  @override
  String get ztPerkPropImprovedSpeedPercent => 'Усиление скорости передвижения';

  @override
  String ztPerkDescCrystal(
    String interval,
    String damageCount,
    String damagePerHit,
    String hpReduced,
  ) {
    return 'Даёт иммунитет к мгновенному убийству, позволяет получать урон не более $damageCount раз за каждые $interval с, снижает каждый полученный урон до $damagePerHit и уменьшает здоровье на $hpReduced.';
  }

  @override
  String get ztPerkDescGravity =>
      'Иммунитет к эффектам отбрасывания и подбрасывания.';

  @override
  String ztPerkDescShield(String shieldNum) {
    return 'Аннулирует первые $shieldNum получения урона и даёт иммунитет к мгновенному убийству на всё время действия баффа.';
  }

  @override
  String ztPerkDescImmuneControl(String percent) {
    return 'Сопротивление эффектам контроля увеличено на $percent.';
  }

  @override
  String ztPerkDescAntiControl(String percent) {
    return 'Под действием эффекта контроля получаемый урон снижается на $percent.';
  }

  @override
  String ztPerkDescAttack(String percent) {
    return 'Сила атаки увеличена на $percent.';
  }

  @override
  String ztPerkDescSpeed(String percent) {
    return 'Скорость передвижения увеличена на $percent.';
  }

  @override
  String get ztPerksCategoryInfoTitle => 'Описание баффов';

  @override
  String get ztPerkCategoryDescNumericHint =>
      'Буквы A, B, X, N, P и т. п. обозначают числовые значения, которые меняются по уровню баффа.';

  @override
  String get ztPerkCategoryDescCrystal =>
      'Даёт иммунитет к мгновенному убийству, позволяет получать урон не более N раз за каждые A секунд, снижает каждый полученный урон до B и уменьшает здоровье на X.';

  @override
  String get ztPerkCategoryDescGravity =>
      'Иммунитет к эффектам отбрасывания и подбрасывания.';

  @override
  String get ztPerkCategoryDescShield =>
      'Аннулирует первые N получений урона и даёт иммунитет к мгновенному убийству на всё время действия баффа.';

  @override
  String get ztPerkCategoryDescImmuneControl =>
      'Сопротивление эффектам контроля увеличено на P%.';

  @override
  String get ztPerkCategoryDescAntiControl =>
      'Под действием эффекта контроля получаемый урон снижается на P%.';

  @override
  String get ztPerkCategoryDescAttack => 'Сила атаки увеличена на P%.';

  @override
  String get ztPerkCategoryDescSpeed =>
      'Скорость передвижения увеличена на P%.';

  @override
  String get warningStageSwitchedTo5Rows =>
      'Этап использует 5 рядов, но часть данных ссылается на 6-й ряд. Объекты могут отображаться некорректно.';

  @override
  String warningObjectsOutsideArea(int rows, int cols) {
    return 'Некоторые объекты вне игровой области ($rows×$cols).';
  }

  @override
  String get izombieModeTitle => 'Режим «Я — зомби»';

  @override
  String get izombieModeSubtitle =>
      'Включить для расстановки зомби. Блокирует способ выбора.';

  @override
  String get reverseZombieFactionTitle => 'Союзный режим';

  @override
  String get reverseZombieFactionSubtitle =>
      'Зомби переходят на сторону растений';

  @override
  String get initialWeight => 'Начальный вес';

  @override
  String get plantLevelLabel => 'Уровень растения';

  @override
  String get missingIntroModule => 'Отсутствует модуль интро';

  @override
  String get missingIntroModuleHint =>
      'Уровню не хватает ZombossBattleIntroProperties. Добавьте модуль и выберите зомботf снова.';

  @override
  String get zombossMechType => 'Тип зомбота';

  @override
  String get unknownZombossMech => 'Неизвестный зомбот';

  @override
  String get zombossMechSelection => 'Выбор зомбота';

  @override
  String get zombossMechBaseLabel => 'Базовый зомбот';

  @override
  String get zombossMechBaseHint =>
      'Семейство зомботов (Древний Египет, Далёкое Будущее, зомбот PvZ 1 и т.д.). При смене обновляется список вариантов ниже.';

  @override
  String get zombossMechSelectBaseTitle => 'Выбор базового зомбота';

  @override
  String get zombossMechChangeBase => 'Сменить базовый зомбота';

  @override
  String get zombossMechUsedProperties => 'Используемые свойства';

  @override
  String get zombossMechVariationLabel => 'Вариант';

  @override
  String get zombossMechVariationHint =>
      'Конкретный тип меха в уровне (ZombossMechType). Список зависит от выбранного базового зомбота. Фазы и позиция появления синхронизируются автоматически.';

  @override
  String get zombossBattleSelection => 'Выбор Зомбосса';

  @override
  String get zombossBattleSelectBaseTitle => 'Выбор базового Зомбосса';

  @override
  String get zombossBattleLeaveUndergroundTitle => 'Смена базового Зомбосса';

  @override
  String zombossBattleLeaveUndergroundBody(String zombossName) {
    return 'Вы собираетесь сменить $zombossName на другого базового Зомбосса. Модуль «Лимит времени финальной фазы» будет автоматически удалён из уровня. Удалить также модуль «Тоннели Подземного Дворца»?';
  }

  @override
  String get zombossBattleKeepTunnelDefend => 'Сохранить тоннели';

  @override
  String get zombossBattleRemoveTunnelDefend => 'Удалить и тоннели';

  @override
  String get zombossBattleChangeBase => 'Сменить базового Зомбосса';

  @override
  String get zombossBattleBaseLabel => 'Базовый Зомбосс';

  @override
  String get zombossBattleBaseHint =>
      'Семейство боссов (Кунг-фу, Цинь Шихуанди и т.д.). При смене автоматически обновляются группы ресурсов.';

  @override
  String get zombossBattleVariationLabel => 'Вариант';

  @override
  String get zombossBattleVariationHint =>
      'Конкретный тип Зомбосса в уровне (ZombossTypeName). Список зависит от выбранного базового Зомбосса.';

  @override
  String get zombossBattleStartingSunLabel => 'Начальное солнце (StartingSun)';

  @override
  String get zombossBattleStartingSunHint => 'Солнце в начале боя.';

  @override
  String get zombossBattleStartingPlantfoodLabel =>
      'Начальная удобр. (StartingPlantfood)';

  @override
  String get zombossBattleStartingPlantfoodHint => 'Удобрения в начале боя.';

  @override
  String get zombossBattleInitialGridColLabel =>
      'Колонка появления (ZombossInitialGridCol)';

  @override
  String get zombossBattleInitialGridColHint =>
      'Колонка сетки, где появляется Зомбосс.';

  @override
  String get zombossBattleInitialGridRowLabel =>
      'Строка появления (ZombossInitialGridRow)';

  @override
  String get zombossBattleInitialGridRowHint =>
      'Строка сетки, где появляется Зомбосс.';

  @override
  String get zombossBattleStartStageIndexLabel =>
      'Начальная фаза (ZombossStartStageIndex)';

  @override
  String get zombossBattleStartStageIndexHint =>
      'С какой фазы босса начинается бой (0 — первая фаза).';

  @override
  String get zombossBattleSkipPlantingLabel =>
      'Пропустить посадку (SkipPlanting)';

  @override
  String get zombossBattleSkipPlantingHint =>
      'Если включено, фаза посадки перед боем с боссом пропускается.';

  @override
  String get parameters => 'Параметры';

  @override
  String get reservedColumnCount => 'Зарезервировано колонок';

  @override
  String get reservedColumnCountHint =>
      'Колонки справа, где нельзя сажать растения.';

  @override
  String get reservedColumnPreview => 'Предпросмотр зарезервированных колонок';

  @override
  String get protectedList => 'Список защищаемых';

  @override
  String get plantLevelsFollowGlobal =>
      'Уровни растений следуют глобальным настройкам. Уровни банка семян переопределяются.';

  @override
  String get protectPlantsOverview =>
      'Растения в списке должны выжить; потеря — провал уровня.';

  @override
  String get protectPlantsAutoCount =>
      'Требуемое количество соответствует числу растений в списке.';

  @override
  String get protectItemsOverview =>
      'Предметы в списке должны выжить; потеря — провал уровня.';

  @override
  String get protectItemsAutoCount =>
      'Требуемое количество соответствует числу предметов в списке.';

  @override
  String positionsCount(int count) {
    return 'Позиций: $count';
  }

  @override
  String totalItemsCount(int count) {
    return 'Предметов: $count';
  }

  @override
  String get itemCountExceedsPositionsWarning =>
      'Внимание: предметов больше, чем позиций. Часть не появится.';

  @override
  String get gravestoneBlockedInfo =>
      'Надгробия и подобные объекты, заблокированные растениями, не появятся. Используйте другие методы.';

  @override
  String get enterConditionValue => 'Введите значение условия';

  @override
  String get customInputHint => 'Пользовательский ввод должен быть точным';

  @override
  String get presetConditions => 'Предустановленные условия';

  @override
  String get selectFromPresetHint => 'Выберите из списка условий';

  @override
  String get spawnTimer => 'Таймер призыва';

  @override
  String get potionTypes => 'Типы зелий';

  @override
  String get noPotionTypes =>
      'Типы зелий не настроены. Добавьте тип зелья, чтобы продолжить.';

  @override
  String get conveyorCardPool => 'Пул карт конвейера';

  @override
  String get toolCardsUseFixedLevel =>
      'Инструментальные карты используют фиксированный уровень';

  @override
  String get maxLimits => 'Верхние пределы';

  @override
  String get maxCountThreshold => 'Порог макс. количества';

  @override
  String get weightFactor => 'Весовой коэффициент';

  @override
  String get minLimits => 'Нижние пределы';

  @override
  String get minCountThreshold => 'Порог мин. количества';

  @override
  String get followAccountLevel =>
      'Растения 0 уровня используют соответствующий ранг из аккаунта игрока.';

  @override
  String get enablePointSpawning => 'Включить очки призыва';

  @override
  String get pointSpawningEnabledDesc =>
      'Включено (использует доп. очки для призыва)';

  @override
  String get pointSpawningDisabledDesc => 'Выключено (только события волн)';

  @override
  String get pointSettings => 'Настройки очков';

  @override
  String get startingWave => 'Начальная волна';

  @override
  String get startingPoints => 'Начальные очки';

  @override
  String get pointIncrement => 'Прирост очков';

  @override
  String get zombiePool => 'Пул зомби';

  @override
  String plantLevelsCount(int count) {
    return 'Уровни растений: $count';
  }

  @override
  String lvN(int n) {
    return 'Ур. $n';
  }

  @override
  String get protectGridItems => 'Защищать объекты сетки';

  @override
  String get waveManagerHelpOverview =>
      'Включает менеджер волн. Без этого модуля редактирование волн отключено.';

  @override
  String get waveManagerHelpPoints =>
      'Спавн по очкам использует этот пул. Избегайте элитных и кастомных зомби.';

  @override
  String get pointsSection => 'Очки';

  @override
  String get globalPlantLevels => 'Глобальные уровни растений';

  @override
  String get globalPlantLevelsOverview =>
      'Определяет глобальные уровни для указанных растений.';

  @override
  String get globalPlantLevelsScope =>
      'Применяется к защите растений, семенному дождю и другим модулям.';

  @override
  String mustProtectCountFormat(int count) {
    return 'Нужно защитить: $count';
  }

  @override
  String get noWaveManagerPropsFound =>
      'Объект WaveManagerProperties не найден.';

  @override
  String get itemsSortedByRow => 'Предметы (по рядам)';

  @override
  String get eventStormSpawn => 'Событие: штормовой спавн';

  @override
  String get stormEvent => 'Штормовое событие';

  @override
  String get makeCustom => 'Сделать кастомным';

  @override
  String get zombieLevelsBody =>
      'Уровень и ряд зомби внутри бури нельзя задавать независимо. Ручное изменение уровня зомби не действует: уровень по умолчанию определяется последовательностью уровней газона.';

  @override
  String get batchLevel => 'Пакетный уровень';

  @override
  String get start => 'Начало';

  @override
  String get end => 'Конец';

  @override
  String get backgroundMusicLevelJam => 'Фоновая музыка (LevelJam)';

  @override
  String get onlyAppliesRockEra => 'Только для карт эры рока.';

  @override
  String get appliesToAllNonElite =>
      'Применяется ко всем неэлитным зомби в этой волне.';

  @override
  String get dropConfigPlants => 'Настройка дропа (пакеты семян)';

  @override
  String get dropConfigPlantFood => 'Настройка дропа (подкормка)';

  @override
  String get waveDropConfigTitle => 'Настройка дропа';

  @override
  String get waveDropPlantSelectionLabel =>
      'Указанные пакеты семян для выпадения (SpawnPlantName)';

  @override
  String get waveDropTotalLabel => 'Всего зомби с дропом (AdditionalPlantfood)';

  @override
  String get waveDropAddZombiesFirst =>
      'Добавьте зомби в эту волну перед настройкой дропа.';

  @override
  String get waveDropIncreaseTotalBeforePlants =>
      'Увеличьте общее число дропов перед добавлением пакетов семян.';

  @override
  String waveDropPlantFoodOnlyCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count подкормок',
      many: '$count подкормок',
      few: '$count подкормки',
      one: '1 подкормка',
    );
    return '$_temp0';
  }

  @override
  String waveDropPlantsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count пакета семян',
      many: '$count пакетов семян',
      few: '$count пакета семян',
      one: '1 пакет семян',
    );
    return '$_temp0';
  }

  @override
  String get zombiesCarryingPlants => 'Зомби с пакетами семян';

  @override
  String get zombiesCarryingPlantFood => 'Зомби с подкормкой';

  @override
  String get description => 'Описание';

  @override
  String get descriptiveName => 'Описательное имя';

  @override
  String get count => 'Количество';

  @override
  String get targetDistance => 'Расстояние до цветника (TargetDistance)';

  @override
  String get starChallengeTargetDistanceHint =>
      'Значение задаёт число столбцов от левого края; чем оно больше, тем дальше от дома. Поддерживаются дробные числа.';

  @override
  String get targetSun => 'Целевое солнце';

  @override
  String get maximumSun => 'Максимум солнца';

  @override
  String get holdoutSeconds => 'Секунды удержания';

  @override
  String get zombiesToKill => 'Зомби для убийства';

  @override
  String get timeSeconds => 'Время (секунды)';

  @override
  String get speedModifier => 'Множитель скорости (SpeedModifier)';

  @override
  String get starChallengeSpeedModifierHint =>
      'Значение 0,5 увеличивает скорость передвижения зомби на 50 %.';

  @override
  String get sunModifier => 'Снижение солнца (SunModifier)';

  @override
  String get starChallengeSunModifierHint =>
      'Значение 0,2 уменьшает получение солнца на 20 %.';

  @override
  String get starChallengeChineseUnsupportedHint =>
      'Китайские символы не поддерживаются.';

  @override
  String get maximumPlantsLost => 'Макс. потерянных растений';

  @override
  String get maximumPlants => 'Максимум растений';

  @override
  String get targetScore => 'Целевой счёт';

  @override
  String get plantBombRadius => 'Радиус бомбы растения';

  @override
  String get plantType => 'Тип растения';

  @override
  String get gridX => 'Сетка X';

  @override
  String get gridY => 'Сетка Y';

  @override
  String get noCardsYetAddPlants =>
      'Карт пока нет. Добавьте растения или инструменты.';

  @override
  String get mustProtectCountAll => 'Обязательно защитить (0 = все)';

  @override
  String get gridItemType => 'Тип объекта сетки';

  @override
  String get zombieBombRadius => 'Радиус бомбы зомби';

  @override
  String get plantDamage => 'Урон растения';

  @override
  String get zombieDamage => 'Урон зомби';

  @override
  String get initialPotionCount => 'Начальное кол-во зелий';

  @override
  String get operationTimePerGrid => 'Время на ячейку (секунды)';

  @override
  String get levelLabel => 'Уровень: ';

  @override
  String get mistParameters => 'Параметры тумана';

  @override
  String get sunDropParameters => 'Параметры падения солнца';

  @override
  String get initialDropDelay =>
      'Начальная задержка падения (InitialSunDropDelay; секунды)';

  @override
  String get baseCountdown => 'Базовый обратный отсчёт';

  @override
  String get maxCountdown => 'Макс. обратный отсчёт';

  @override
  String get countdownRange => 'Диапазон отсчёта';

  @override
  String get increasePerSun => 'Увеличение за солнце';

  @override
  String get inflationParams => 'Параметры инфляции';

  @override
  String get baseCostIncreaseLabel =>
      'Увеличение базовой стоимости (BaseCostIncreased)';

  @override
  String get maxIncreaseCountLabel =>
      'Макс. кол-во увеличений (MaxIncreasedCount)';

  @override
  String get inflationMaxIncreaseCountWarning =>
      'Из-за проблемы самого модуля изменение максимального количества увеличений пока не действует. Игра считывает только значение по умолчанию — 10.';

  @override
  String get inflationHelpTitle => 'Инфляция';

  @override
  String get inflationHelpOverview =>
      'После каждой посадки растения его стоимость в солнцах увеличивается — подобно механике улучшающих растений в бесконечном режиме первой Plants vs. Zombies.';

  @override
  String get inflationHelpParametersTitle => 'Описание параметров';

  @override
  String get inflationHelpParametersBody =>
      'Можно настроить прибавку стоимости в солнцах после каждой посадки и максимальное количество повышений цены.';

  @override
  String get selectGroup => 'Выбрать группу';

  @override
  String get gridTapAddRemove =>
      'Сетка (нажмите — добавить/изменить, долгое нажатие — удалить)';

  @override
  String get sunBombHelpOverview => 'Обзор';

  @override
  String get sunBombHelpBody =>
      'Превращает падающее солнце в взрывные бомбы. Настройте радиус и урон.';

  @override
  String get bombProperties => 'Свойства бомб';

  @override
  String get bombPropertiesHelpBody =>
      'Настройка длины фитиля бочки и вишни для каждого ряда. Используется в Kongfu/мини-играх. Размер массива соответствует рядам газона (5 или 6).';

  @override
  String get bombPropertiesHelpFuse => 'Длина фитиля';

  @override
  String get bombPropertiesHelpFuseBody =>
      'FuseLengths: одно значение на ряд. Длина в игровых единицах. Стандартный газон: 5 рядов. Глубокое море: 6 рядов. Массив автоматически подстраивается при открытии экрана.';

  @override
  String get bombPropertiesFlameSpeed => 'Скорость огня';

  @override
  String get bombPropertiesFuseLengths => 'Длина фитиля';

  @override
  String get bombPropertiesFuseLengthsHint =>
      'Одно значение на ряд (0–4 стандарт, 0–5 глубокое море). Размер массива подстраивается при открытии.';

  @override
  String get bombPropertiesFuseLength => 'Длина';

  @override
  String get damage => 'Урон';

  @override
  String get explosionRadius => 'Радиус взрыва';

  @override
  String get plantRadius => 'Радиус растения';

  @override
  String get zombieRadius => 'Радиус зомби';

  @override
  String get radiusPixelsHint => 'Радиус в пикселях. Одна клетка ≈ 60 px.';

  @override
  String get enterMaxSunHint => 'Введите макс. солнце (напр., 9900)';

  @override
  String get optionalLabelHint => 'Необязательная подпись';

  @override
  String get imageResourceIdHint => 'ID ресурса IMAGE_...';

  @override
  String get enterStartingPlantfoodHint =>
      'Введите начальное кол-во подкормки (0+)';

  @override
  String get threshold => 'Порог';

  @override
  String get delay => 'Задержка';

  @override
  String get seedBankLetsPlayersChoose =>
      'Банк семян позволяет игрокам выбирать растения. В режиме двора можно задать глобальный уровень и все растения.';

  @override
  String get iZombieModePresetHint =>
      'Режим «Я, зомби»: предустановленные зомби для игрока. Выбор заблокирован предустановкой.';

  @override
  String get invalidIdsHint =>
      'Неверные ID оставляют пустые слоты. ID зомби в режиме растений и наоборот. Сначала разместите слоты зомби.';

  @override
  String get seedBankWhiteAndBlacklistTitle => 'Белый и чёрный списки';

  @override
  String get seedBankIZombieHelpTitle => 'Режим «Я, зомби»';

  @override
  String get seedBankSlotOccupancyTitle => 'Заполнение слотов';

  @override
  String get seedBankAdvancedGameplayTitle => 'Продвинутая игра';

  @override
  String get seedBankAdvancedGameplayBody =>
      'В режиме предустановленного выбора Банк семян перед Конвейером заставляет растения с конвейера расходовать солнце, а Банк семян после Конвейера позволяет высаживать предустановленные растения бесплатно.';

  @override
  String get seedBankIZombie => 'Банк семян (Я, зомби)';

  @override
  String get basicRules => 'Основные правила';

  @override
  String get selectionMethod => 'Метод выбора';

  @override
  String get emptyList => 'Пустой список';

  @override
  String get plantsAvailableAtStart => 'Растения в начале';

  @override
  String get presetPlantListReorderHint =>
      'Удерживайте ручку ⋮⋮ и перетаскивайте для изменения порядка';

  @override
  String get presetPlantListReorderHintDesktop =>
      'Перетащите ручку ⋮⋮ для изменения порядка';

  @override
  String get whiteListDescription =>
      'Только эти растения (пусто = без ограничений)';

  @override
  String get blackListDescription => 'Эти растения запрещены';

  @override
  String get availableZombiesDescription => 'Зомби для режима «Я, зомби»';

  @override
  String get izombieCardSlotsHint =>
      'Только некоторые зомби имеют слоты карт IZ. Проверьте категорию «Другое» в выборе зомби.';

  @override
  String get seedBankPresetModeHint =>
      'Режим предустановки запускает игру сразу, независимо от числа карт.';

  @override
  String get seedBankPlantLevelLabel => 'Уровень растений (0–5)';

  @override
  String get seedBankSlotCountLabel => 'Число слотов (0–9)';

  @override
  String get seedBankCourtyardSlotsHint =>
      'В режиме двора число слотов не учитывается. При выборе фиксируется 8 слотов.';

  @override
  String get seedBankAddGridItemsTitle => 'Добавить предметы сетки';

  @override
  String get seedBankAddGridItemsSubtitle =>
      'Добавляет предметы сетки в PresetPlantList. Дубликаты разрешены.';

  @override
  String seedBankGridItemCount(int count) {
    return 'В списке пресетов уже есть: $count';
  }

  @override
  String get seedBankGridItemsPresetOnlySwitchWarning =>
      'Функция добавления объектов работает только в режиме предустановки. При переходе в режим выбора она будет отключена. Продолжить переключение?';

  @override
  String get starChallengeSelectConditions => 'Выбор состояний';

  @override
  String get starChallengeEditConditions => 'Изменить состояния';

  @override
  String get selectToolCard => 'Выбрать карту инструмента';

  @override
  String get searchGridItems => 'Поиск объектов сетки';

  @override
  String get searchStatues => 'Поиск статуй';

  @override
  String get noItems => 'Нет объектов';

  @override
  String get addedToFavorites => 'Добавлено в избранное';

  @override
  String get removedFromFavorites => 'Удалено из избранного';

  @override
  String selectedCountTapToSearch(int count) {
    return 'Выбрано: $count, нажмите для поиска';
  }

  @override
  String get noFavoritesLongPress =>
      'Нет избранных. Долгое нажатие — добавить.';

  @override
  String get gridItemCategoryAll => 'Все';

  @override
  String get gridItemCategoryScene => 'Сетка лужайки';

  @override
  String get gridItemCategoryTrap => 'Ловушки';

  @override
  String get gridItemCategorySpawnableObjects => 'Появляющиеся препятствия';

  @override
  String get sunDropperConfigTitle => 'Настройка падения солнца';

  @override
  String get customLocalParams => 'Пользовательские локальные параметры';

  @override
  String get currentModeLocal => 'Текущий: локальный (@CurrentLevel)';

  @override
  String get currentModeSystem => 'Текущий: системный (@LevelModules)';

  @override
  String get paramAdjust => 'Настройка параметров';

  @override
  String get firstDropDelay =>
      'Задержка первого падения (InitialSunDropDelay; секунды)';

  @override
  String get initialDropInterval =>
      'Начальный интервал падения (SunCountdownBase; секунды)';

  @override
  String get maxDropInterval =>
      'Макс. интервал падения (SunCountdownMax; секунды)';

  @override
  String get intervalFloatRange =>
      'Диапазон интервала (SunCountdownRange; секунды)';

  @override
  String get sunDropperHelpTitle => 'Модуль падающего солнца';

  @override
  String get sunDropperHelpIntro =>
      'Модуль настраивает параметры падения солнца. Для ночных уровней можно не добавлять.';

  @override
  String get sunDropperHelpParams => 'Параметры';

  @override
  String get sunDropperHelpParamsBody =>
      'По умолчанию используются игровые значения. Можно включить пользовательский режим для редактирования.';

  @override
  String get noZombossMechFound => 'зомбот не найден';

  @override
  String get noZombossBattleFound => 'Данные Зомбосса не найдены';

  @override
  String get searchChallengeNameOrCode =>
      'Поиск по названию или коду испытания';

  @override
  String get deleteChallengeTitle => 'Удалить испытание?';

  @override
  String deleteChallengeConfirmLocal(String name) {
    return 'Удалить «$name»? Локальные данные испытания будут удалены безвозвратно.';
  }

  @override
  String deleteChallengeConfirmRef(String name) {
    return 'Удалить ссылку на «$name»? Испытание останется в LevelModules.';
  }

  @override
  String get missingModulesRecommended =>
      'Уровень может работать некорректно. Рекомендуется добавить:';

  @override
  String get recommendedTunnelDefendTitle =>
      'Рекомендуется модуль тоннелей Подземного Дворца';

  @override
  String get recommendedTunnelDefendBody =>
      'Арены Подземного дворца рассчитаны на визуал тоннелей. Настоятельно рекомендуется добавить модуль тоннелей Подземного Дворца — иначе газон в игре может выглядеть пустым.';

  @override
  String get recommendedExpeditionTilesTitle =>
      'Можно использовать с модулем «Плитки Врат Экспедиции»';

  @override
  String get recommendedExpeditionTilesBody =>
      'Добавьте модуль «Плитки Врат Экспедиции», чтобы обойти отсутствие плиток на лужайке и получить опыт, ближе соответствующий режиму Врат Экспедиции.';

  @override
  String get selectedPosition => 'Выбранная позиция';

  @override
  String get addItem => 'Добавить препятствие';

  @override
  String get itemListRowFirst => 'Список препятствий (по строкам)';

  @override
  String get railcartCowboy => 'Вагонетка Дикого Запада';

  @override
  String get railcartFuture => 'Вагонетка Далёкого Будущего';

  @override
  String get railcartEgypt => 'Вагонетка Древнего Египта';

  @override
  String get railcartPirate => 'Вагонетка Пиратских Морей';

  @override
  String get railcartWorldcup => 'Чемпионат Дейва';

  @override
  String get clearUnusedTitle => 'Удалить неиспользуемые объекты?';

  @override
  String get clearUnusedMessage =>
      'Будут безвозвратно удалены все неиспользуемые объекты из файла уровня, включая пользовательских зомби, их свойства и другие неиспользуемые данные. Действие нельзя отменить. Продолжить?';

  @override
  String get clearUnusedNone => 'Неиспользуемые объекты не найдены.';

  @override
  String clearUnusedDone(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Удалено $count неиспользуемых объектов.',
      many: 'Удалено $count неиспользуемых объектов.',
      few: 'Удалено $count неиспользуемых объекта.',
      one: 'Удалён $count неиспользуемый объект.',
    );
    return '$_temp0';
  }

  @override
  String get lawnMowerTitle => 'Стиль газонокосилок';

  @override
  String get lawnMowerNotes => 'Заметки';

  @override
  String get lawnMowerHelpOverview =>
      'Управляет внешним видом газонокосилок. В режиме двора газонокосилки неэффективны.';

  @override
  String get lawnMowerHelpNotes =>
      'Модуль газонокосилок обычно ссылается на LevelModules напрямую.';

  @override
  String get lawnMowerSelectType => 'Выбрать тип газонокосилки';

  @override
  String get zombieRushTitle => 'Таймер уровня';

  @override
  String get zombieRushHelpOverview =>
      'Таймер обратного отсчёта для Zombie Rush. Уровень заканчивается по истечении времени.';

  @override
  String get zombieRushHelpNotes => 'Заметки';

  @override
  String get zombieRushHelpIncompat =>
      'Модуль таймера несовместим с режимом двора и может вызвать сбой. Используйте таймер Zombie Rush.';

  @override
  String get zombieRushTimeSettings => 'Настройки времени';

  @override
  String get levelCountdown => 'Обратный отсчёт уровня';

  @override
  String get tunnelDefendTitle => 'Тоннели Подземного Дворца';

  @override
  String get tunnelDefendHelpOverview =>
      'Добавление путей тоннелей Подземного Дворца. Некоторые зомби и растения взаимодействуют с тоннелями.';

  @override
  String get tunnelDefendHelpUsage => 'Использование';

  @override
  String get tunnelDefendHelpUsageBody =>
      'Выберите элемент тоннеля ниже, затем нажмите на сетку для размещения. Нажмите тот же элемент снова, чтобы удалить. Нажмите другой элемент для замены.';

  @override
  String get tunnelDefendSelectComponent => 'Выбрать компонент';

  @override
  String get tunnelDefendPlacedCount => 'Размещено';

  @override
  String get tunnelDefendClearAll => 'Очистить всё';

  @override
  String get tunnelDefendClearConfirmTitle =>
      'Очистить все компоненты тоннелей?';

  @override
  String get tunnelDefendClearConfirmMessage =>
      'Удалить все размещённые компоненты тоннелей из сетки. Действие нельзя отменить.';

  @override
  String get tunnelDefendPathOutsideLawn => 'Элементы путей вне газона: ';

  @override
  String get tunnelDefendDeleteOutside => 'Удалить элементы путей вне газона';

  @override
  String get tunnelDefendDeleteOutsideConfirmTitle =>
      'Удалить элементы путей вне газона?';

  @override
  String get tunnelDefendDeleteOutsideConfirmMessage =>
      'Удалить элементы путей за пределами сетки газона 5×9. Действие нельзя отменить.';

  @override
  String get tunnelDefendTileStylePreset => 'Пресет стиля плитки';

  @override
  String get tunnelDefendTileStylePart1 => 'часть 1';

  @override
  String get tunnelDefendTileStylePart2 => 'часть 2';

  @override
  String get tunnelDefendSequenceInterval =>
      'Интервал последовательности тоннелей (TunnelSequenceInterval, сек.)';

  @override
  String get tunnelDefendHelpSequenceInterval => 'Интервал последовательности';

  @override
  String get tunnelDefendHelpSequenceIntervalBody =>
      'Задержка между шагами последовательности тоннелей. Меньшие значения ускоряют появление путей.';

  @override
  String get tunnelDefendHelpSodPromptBody =>
      '\"Подсказка о посадке почвы\" может быть включена, чтобы просить игрока посадить почву перед посадкой растения на тоннель';

  @override
  String get sodPlantingPromptTitle => 'Подсказка о посадке почвы';

  @override
  String get expeditionTilesSodPromptBody =>
      'Показывает подсказку, которая просит посадить почву перед посадкой растения';

  @override
  String get tunnelDefendSodPromptBody =>
      'Показывает подсказку, которая просит посадить почву перед посадкой растения. Включено по умолчанию';

  @override
  String get expeditionTilesPresetLayout => 'Заготовленная расстановка';

  @override
  String get expeditionTilesPresetFloor1 => 'Врата Экспедиции - Первый Этаж';

  @override
  String get expeditionTilesPresetFloor2 => 'Врата Экспедиции - Второй Этаж';

  @override
  String get expeditionTilesPresetFloor3 => 'Врата Экспедиции - Третий Этаж';

  @override
  String get customLayout => 'Своя расстановка';

  @override
  String get switchAction => 'Изменить';

  @override
  String get expeditionTilesSwitchPresetTitle =>
      'Изменить заготовленную расстановку';

  @override
  String get expeditionTilesSwitchPresetMessage =>
      'Изменить заготовленную расстановку? Это заменит текущие непосадочные плиты и не может быть отменено';

  @override
  String expeditionTilesSwitchPresetBetweenMessage(String from, String to) {
    return 'Изменить \"$from\" на \"$to\"? Это заменит текущие непосадочные плиты и не может быть отменено';
  }

  @override
  String get expeditionTilesUnderwaterMismatchWarning =>
      'Лужайки на основе подводного мира несовместимы с плитками Врат Экспедиции (рогалика). Измените лужайку на другую или уровень не запустится.';

  @override
  String get expeditionTilesBlockedCount => 'Непосадочные плитки';

  @override
  String get expeditionTilesClearConfirmTitle =>
      'Удалить все непосадочные плиты?';

  @override
  String get expeditionTilesClearConfirmMessage =>
      'Это удалит все непосадочные плитки с лужайки. Не может быть отменено';

  @override
  String get expeditionTilesHelpTitle => 'Модуль плиток Врат Экспедиции';

  @override
  String get expeditionTilesHelpOverview =>
      'Показывает доступные плитки для посадки, как в режиме Врат Экспедиции (остальные являются непосадочными). Несовместим с сеткой 6x10. На непосадочные плитки можно сажать почву, чтобы можно было потом сажать на неё растительность.';

  @override
  String get expeditionTilesHelpEditing => 'Редактирование плиток';

  @override
  String get expeditionTilesHelpEditingBody =>
      'Позволяет выбирать и ставить непосадочные плитки на лужайку. На сетке отображаются только плитки с водоворотом - те, на которые растения сажать можно.';

  @override
  String get expeditionTilesHelpPresets => 'Заготовленные расстановки';

  @override
  String get expeditionTilesHelpPresetsBody =>
      'Редактор содержит три официальные расстановки непосадочных плит, которые используются в рогалике. После выбора одной из этих расстановок все непосадочные плитки перепишутся. Откат процесса невозможен, однако вы можете вручную редактировать расстановку непосадочных плиток.';

  @override
  String get expeditionTilesHelpSodPrompt => 'Подсказка о высадке';

  @override
  String get expeditionTilesHelpSodPromptBody =>
      '\"Подсказка о высадке почвы\" контролирует появление подсказки о посадке почвы в тоннель перед посадкой растения. Плитки Врат Экспедиции отключают эту подсказку по умолчанию.';

  @override
  String get expeditionTilesHelpNotesBody =>
      'Плитки Врат Экспедиции рассчитаны на сетку 5x9. Не используйте лужайки 6x10 вместе с ними, иначе игра вылетит при запуске уровня.';

  @override
  String get tunnelExpeditionCompatibilityWarningTitle =>
      'Предупреждение о совместимости модулей';

  @override
  String get tunnelExpeditionCompatibilityWarningBody =>
      'Использование \"Тоннелей Подземного Дворца\" вместе с \"Плитками Врат Экспедиции\" может вызвать наслаивание текстур и повлиять на внешний вид лужайки. Если вам необходимо использовать оба модуля одновременно, будьте предельно осторожны.';

  @override
  String get moduleTitle_ZombossFinalStageTimeLimitedChallengeProperties =>
      'Лимит времени финальной фазы';

  @override
  String get moduleDesc_ZombossFinalStageTimeLimitedChallengeProperties =>
      'Включает таймер отчаяния на финальной фазе Босса. Только добавление/удаление — значение таймера берётся из листа свойств Босса (напр. ZombossFinalStageTimeLimited у Цинь Шихуанди), а не из параметров модуля.';

  @override
  String get finalStageTimeLimitedChallengeTitle =>
      'Лимит времени финальной фазы';

  @override
  String get finalStageTimeLimitedChallengeHelpTitle =>
      'Модуль лимита времени финальной фазы';

  @override
  String get finalStageTimeLimitedChallengeHelpIntro =>
      'Добавляет ограничение по времени на финальной фазе боя с Боссом (часто используется в боях с Цинь Шихуанди). Фактический таймер читается из листа свойств Босса (ZombossFinalStageTimeLimited), а не из поля ZombossTimeLimit этого модуля.';

  @override
  String get finalStageTimeLimitedChallengeHelpParams => 'Параметры';

  @override
  String get finalStageTimeLimitedChallengeHelpParamsBody =>
      'Этот экран редактора сейчас отключён. Уровни должны ссылаться только на RTID(FinalStageTimeLimitedChallenge@LevelModules). Пользовательские переопределения @CurrentLevel не поддерживаются, пока игра их не читает.';

  @override
  String get finalStageTimeLimitedChallengeTimeLimit =>
      'Лимит времени Босса (ZombossTimeLimit, сек.)';

  @override
  String get moduleTitle_LawnMowerProperties => 'Газонокосилки';

  @override
  String get moduleDesc_LawnMowerProperties => 'Стиль газонокосилок для уровня';

  @override
  String get moduleTitle_TunnelDefendModuleProperties =>
      'Тоннели Подземного Дворца';

  @override
  String get moduleDesc_TunnelDefendModuleProperties =>
      'Размещение тоннелей Подземного Дворца';

  @override
  String get moduleTitle_SouDaCheTunnelDefendDefault =>
      'Плитки Врат Экспедиции';

  @override
  String get moduleDesc_SouDaCheTunnelDefendDefault =>
      'Настройка непосадочных зон из режима рогалика в PvZ.';

  @override
  String get moduleTitle_WitchModuleProperties => 'Тыквенная ведьма';

  @override
  String get moduleDesc_WitchModuleProperties =>
      'Анимация появления тыквенной ведьмы и интервал';

  @override
  String get moduleTitle_InitialGridItemGulliverTunnelProperties =>
      'Тоннели Гулливера';

  @override
  String get moduleDesc_InitialGridItemGulliverTunnelProperties =>
      'Предустановленные тоннели Гулливера на газоне';

  @override
  String get witchModuleTitle => 'Тыквенная ведьма';

  @override
  String get witchModuleHelpTitle => 'Модуль тыквенной ведьмы';

  @override
  String get witchModuleHelpIntro =>
      'Добавляет анимацию и субтитры появления тыквенной ведьмы. По умолчанию используется WitchModule из LevelModules.';

  @override
  String get witchModuleHelpParams => 'Параметры';

  @override
  String get witchModuleHelpParamsBody =>
      'Включите локальные параметры, чтобы изменить WitchSpawnInterval. Иначе используются значения LevelModules.';

  @override
  String get witchModuleSpawnInterval =>
      'Интервал появления ведьмы (WitchSpawnInterval, сек.)';

  @override
  String get gulliverTunnelTitle => 'Тоннели Гулливера';

  @override
  String get gulliverTunnelHelpOverview =>
      'Размещение тоннелей Гулливера на газоне до начала уровня.';

  @override
  String get gulliverTunnelHelpUsage => 'Использование';

  @override
  String get gulliverTunnelHelpUsageBody =>
      'Выберите ориентацию и нажмите на сетку для размещения. Повторное нажатие удаляет тоннель; другая ориентация заменяет существующую.';

  @override
  String get gulliverTunnelOrientationBigOnLeft => 'Большой проход слева';

  @override
  String get gulliverTunnelOrientationBigOnRight => 'Большой проход справа';

  @override
  String get gulliverTunnelPlacedCount => 'Размещено';

  @override
  String get gulliverTunnelClearAll => 'Очистить всё';

  @override
  String get gulliverTunnelClearConfirmTitle =>
      'Очистить все тоннели Гулливера?';

  @override
  String get gulliverTunnelClearConfirmMessage =>
      'Удалить все размещённые тоннели Гулливера с сетки.';

  @override
  String get gulliverTunnelSelectOrientation => 'Выберите ориентацию';

  @override
  String get gulliverTunnelOutsideLawn => 'Вне газона';

  @override
  String get gulliverTunnelDeleteOutside => 'Удалить вне газона';

  @override
  String get gulliverTunnelDeleteOutsideConfirmTitle =>
      'Удалить тоннели вне газона?';

  @override
  String get gulliverTunnelDeleteOutsideConfirmMessage =>
      'Удалить размещения тоннелей за пределами сетки 5×9.';

  @override
  String get moduleTitle_RiftThemeDemoModuleProperties => 'Модификаторы уровня';

  @override
  String get moduleDesc_RiftThemeDemoModuleProperties =>
      'Задаёт пользовательские модификаторы уровня (Погоня Пенни / Дорога Воспоминаний)';

  @override
  String get riftThemeModuleTitle => 'Модификаторы уровня';

  @override
  String get riftThemeHelpTitle => 'Модуль модификаторов уровня';

  @override
  String get riftThemeHelpOverview =>
      'Задаёт пользовательский список модификаторов для уровня — как в уровнях Погони Пенни и Дороги Воспоминаний. Нажмите и удерживайте карточку темы или щёлкните по ней правой кнопкой мыши, чтобы просмотреть краткое описание её эффекта и списки связанных растений и зомби.';

  @override
  String get riftThemeHelpUsage => 'Использование';

  @override
  String get riftThemeHelpUsageBody =>
      'Нажмите кнопку, чтобы открыть выбор модификаторов. Нажимайте на модификаторы, чтобы включить или снять выбор, затем подтвердите галочкой. Модификаторы применяются в порядке списка.';

  @override
  String get riftThemeHelpUnique => 'Уникальные модификаторы';

  @override
  String get riftThemeHelpUniqueBody =>
      'Каждый модификатор может встречаться в списке только один раз.';

  @override
  String get riftThemeEmpty =>
      'Модификаторы не выбраны. Нажмите кнопку ниже, чтобы выбрать модификаторы.';

  @override
  String get riftThemeAddTheme => 'Добавить модификаторы';

  @override
  String get riftThemeSelectThemes => 'Выбрать модификаторы';

  @override
  String get riftThemeSelectTheme => 'Модификатор';

  @override
  String get riftThemeSearchPlaceholder => 'Поиск по названию или id';

  @override
  String get riftThemeAlreadyAdded => 'Уже добавлен';

  @override
  String get riftThemeNoSearchResults => 'Модификаторы не найдены';

  @override
  String get riftThemeAllUsedTitle => 'Все модификаторы добавлены';

  @override
  String get riftThemeAllUsedMessage =>
      'Все модификаторы уже в списке. Каждый можно добавить только один раз.';

  @override
  String get moduleTitle_ZombieRushModuleProperties =>
      'Таймер (из плана уничтожения зомби / нанесения урона снеговикам за время)';

  @override
  String get moduleDesc_ZombieRushModuleProperties => 'Обратный отсчёт уровня';

  @override
  String get moduleTitle_PVZ1PassageModuleProperties => 'Порталы PvZ1';

  @override
  String get moduleDesc_PVZ1PassageModuleProperties =>
      'Порталы в стиле PvZ 1: группы, колонки появления и тайминги телепорта';

  @override
  String get moduleTitle_PVZ1CopycatsModuleProperties => 'Угадай, кто я';

  @override
  String get moduleDesc_PVZ1CopycatsModuleProperties =>
      'Мини-игра: призыв растений или зомби; шансы, уровни и белые/чёрные списки';

  @override
  String get pvz1CopycatsModuleTitle => 'Угадай, кто я';

  @override
  String get pvz1CopycatsSectionParams => 'Параметры';

  @override
  String get pvz1CopycatsFieldZombieWeightLabel =>
      'Шанс на зомби (ZombieWeight)';

  @override
  String get pvz1CopycatsHelpZombieWeight =>
      'Относительный шанс призыва зомби по сравнению с растениями.';

  @override
  String get pvz1CopycatsFieldSpawnPlantLevelLabel =>
      'Уровень растения (SpawnPlantLevel)';

  @override
  String get pvz1CopycatsHelpSpawnPlantLevel =>
      'Уровень растения при призыве того шляпой.';

  @override
  String get pvz1CopycatsSectionPlantBlackList =>
      'Чёрный список растений (PlantBlackList)';

  @override
  String get pvz1CopycatsHelpPlantBlackList =>
      'Растения, которые шляпа не может призвать.';

  @override
  String get pvz1CopycatsSectionZombieWhiteList =>
      'Белый список зомби (ZombieWhiteList)';

  @override
  String get pvz1CopycatsHelpZombieWhiteList =>
      'Допустимые типы зомби при призыве зомби.';

  @override
  String get pvz1CopycatsHelpTip =>
      'Не забудьте дать игроку шляпу в банке семян.';

  @override
  String get pvz1CopycatsHelpOverview =>
      'Угадай, кто я: шляпа случайно призывает растения (из каталога, кроме чёрного списка) или зомби (из белого списка); задаётся ZombieWeight и SpawnPlantLevel.';

  @override
  String get pvz1CopycatsHelpFieldsTitle => 'Описание полей';

  @override
  String get pvz1CopycatsPlantListEmpty => 'Список пуст';

  @override
  String get pvz1CopycatsZombieListEmpty => 'Список пуст';

  @override
  String get pvz1CopycatsAddPlant => 'Добавить растение в чёрный список';

  @override
  String get pvz1CopycatsAddZombie => 'Добавить зомби в белый список';

  @override
  String get moduleTitle_PVZ1SeeingStarsModuleProperties => 'Звёздный узор';

  @override
  String get moduleDesc_PVZ1SeeingStarsModuleProperties =>
      'Настройка целевых растений и цикла волн мини-игры «Звёздный узор»';

  @override
  String get pvz1SeeingStarsModuleTitle => 'Звёздный узор';

  @override
  String get pvz1SeeingStarsSectionParams => 'Параметры';

  @override
  String get pvz1SeeingStarsSectionMatchPlants =>
      'Целевые растения (MatchPlants)';

  @override
  String get pvz1SeeingStarsHelpMatchPlants =>
      'Выберите клетку на сетке и добавьте растение. Если в ней уже есть растение, новое заменит его. В уровне эти растения отображаются как полупрозрачные подсказки. Победа наступает, когда на всех целевых клетках посажены соответствующие растения. На целевых клетках можно сажать только соответствующее целевое растение и растения-лианы; другие растения на них посадить нельзя.';

  @override
  String get pvz1SeeingStarsFieldCycleIndexLabel => 'Волна цикла (CycleIndex)';

  @override
  String get pvz1SeeingStarsHelpCycleIndex =>
      'Индекс первой волны, с которой возобновляется призыв после последней волны; отсчёт начинается с 0. Например, если в уровне 15 волн и указано 5, после 15-й волны начинается 6-я. Волны повторяются, пока узор не будет завершён.';

  @override
  String get pvz1SeeingStarsFieldSettlementDurationLabel =>
      'Задержка засчёта (SettlementDuration)';

  @override
  String get pvz1SeeingStarsHelpSettlementDuration =>
      'После завершения узора начинается задержка на указанное число секунд. По её окончании засчитывается победа, даже если на целевых клетках уже нет соответствующих растений. Задержка действует только при отсутствии модулей «Полная зачистка» и «Разгром Бронзы».';

  @override
  String get pvz1SeeingStarsHelpOverview =>
      'Настраивает мини-игру Аллеи воспоминаний «Звёздный узор». Название происходит от уровня первой игры, где нужно было высадить карамболы в форме звезды. Следуйте подсказкам на газоне и посадите соответствующие растения в указанных клетках, чтобы победить. Тем временем заданные волны зомби повторяются и мешают расстановке растений.';

  @override
  String get pvz1SeeingStarsHelpFieldsTitle => 'Описание полей';

  @override
  String get pvz1SeeingStarsHelpWinCon =>
      'Не используйте этот модуль вместе с «Полной зачисткой» или «Разгромом Бронзы». При наличии любого из них приоритет получает его условие победы, а задержка засчёта игнорируется, что влияет на игровой процесс мини-игры.\nКроме того, «Звёздный узор» несовместим с генератором волн и приведёт к сбою уровня. Используйте с осторожностью.';

  @override
  String get pvz1SeeingStarsMatchPlantsEmpty =>
      'Узор ещё не задан. Выберите любую клетку на сетке и добавьте растение.';

  @override
  String get seeingStarsWinConWarningTitle => 'Конфликт условий победы';

  @override
  String get seeingStarsWinConWarning =>
      '«Звёздный узор» содержит собственное условие победы и завершает уровень после выполнения узора. «Полная зачистка» или «Разгром Бронзы» переопределяет это поведение. Рекомендуется удалить модуль «Полная зачистка» или «Разгром Бронзы».';

  @override
  String get seeingStarsCycleWaveLabel =>
      'Волна цикла (CycleIndex, отсчёт с 0)';

  @override
  String get seeingStarsSettlementLabel =>
      'Задержка засчёта (SettlementDuration, секунды)';

  @override
  String get pvz1SeeingStarsHelpTipsTitle => 'Дружеское напоминание';

  @override
  String get seeingStarsCompatibilityWarningTitle =>
      'Предупреждение о совместимости модулей';

  @override
  String get seeingStarsCompatibilityWarning =>
      '«Звёздный узор» несовместим с генератором волн и приведёт к сбою уровня. Используйте с осторожностью.';

  @override
  String get seeingStarsCycleWaveBadge => 'Цикл волн';

  @override
  String seeingStarsCycleWaveInfo(int wave) {
    return 'После последней волны призыв зомби возобновляется с волны $wave. Волны повторяются, пока на всех целевых клетках не будут посажены соответствующие растения.';
  }

  @override
  String get seeingStarsMatchPlants => 'Целевые растения';

  @override
  String get magicHatSpawnPreviewTitle => 'Шляпа — возможные растения';

  @override
  String get magicHatSpawnPreviewEmpty => 'Нет растений для этого списка.';

  @override
  String get pvz1PassageModuleTitle => 'Порталы PvZ1';

  @override
  String get pvz1PassageSectionParams => 'Параметры порталов';

  @override
  String get pvz1PassageHelpOverview =>
      'Настраивает порталы-проходы на газоне в стиле PvZ 1: число типов групп порталов, число порталов в каждой группе, диапазон колонок появления, минимальный интервал между телепортами одного зомби и период обновления позиций порталов.';

  @override
  String get pvz1PassageHelpFieldsTitle => 'Описание полей';

  @override
  String get pvz1PassageFieldGroupAmount =>
      'Типов групп порталов (GroupAmount)';

  @override
  String get pvz1PassageHelpGroupAmount =>
      'Число различных типов групп порталов.';

  @override
  String get pvz1PassageFieldPassageAmount =>
      'Порталов в группе (PassageAmount)';

  @override
  String get pvz1PassageHelpPassageAmount =>
      'Сколько порталов в каждой группе.';

  @override
  String get pvz1PassageFieldGridXMin =>
      'Минимальная колонка появления (GridXMin)';

  @override
  String pvz1PassageHelpGridXMin(int maxIndex) {
    return 'Самая левая колонка газона, где могут появляться порталы. На этом газоне индексы колонок от 0 до $maxIndex.';
  }

  @override
  String get pvz1PassageFieldGridXMax =>
      'Максимальная колонка появления (GridXMax)';

  @override
  String pvz1PassageHelpGridXMax(int maxIndex) {
    return 'Самая правая колонка газона, где могут появляться порталы. На этом газоне индексы колонок от 0 до $maxIndex.';
  }

  @override
  String pvz1PassageGridColumnRange(int maxIndex) {
    return '0–$maxIndex';
  }

  @override
  String get pvz1PassageFieldTransferCooldown =>
      'Перезарядка телепорта на зомби (transferCooldown; секунды)';

  @override
  String get pvz1PassageHelpTransferCooldown =>
      'Минимальное время между телепортами одного и того же зомби.';

  @override
  String get pvz1PassageFieldRefreshTime =>
      'Интервал смены позиций порталов (refreshTime; секунды)';

  @override
  String get pvz1PassageHelpRefreshTime =>
      'Как часто заново выбираются позиции порталов.';

  @override
  String get pvz1PassagePortalSpawnPreview => 'Предпросмотр колонок появления';

  @override
  String get pvz1PassageHelpPreview => 'Предпросмотр';

  @override
  String pvz1PassageHelpPreviewBody(int maxIndex) {
    return 'Оранжевым выделены колонки в диапазоне GridXMin–GridXMax включительно. На этом газоне допустимы индексы колонок 0–$maxIndex. Строки в этом модуле не ограничивают появление.';
  }

  @override
  String get moduleWaveIndexZeroBasedHint =>
      'Индекс волны: 0 = первая волна, 1 = вторая и т.д.';

  @override
  String get moduleWaveFieldZeroBased =>
      'Волна (0 = волна 1, 1 = волна 2, ...)';

  @override
  String get appearanceLabel => 'Появление';

  @override
  String get airDropShipGroupLabel => 'Группа';

  @override
  String get moduleTitle_RenaiModuleProperties => 'Ренессанс';

  @override
  String get moduleDesc_RenaiModuleProperties =>
      'Включает функционал колеса и плиток Ренессанса, позволяет настраивать статуи';

  @override
  String get renaiModuleTitle => 'Модуль Ренессанса';

  @override
  String get renaiModuleHelpTitle => 'Справка по модулю Ренессанса';

  @override
  String get renaiModuleHelpOverview => 'Обзор';

  @override
  String get renaiModuleHelpOverviewBody =>
      'Включает колёса и плитки. Волна начала ночи (0-базовый индекс) переключает на ночной режим. Дневные и ночные статуи оживают на своей волне.';

  @override
  String get renaiModuleHelpStatues => 'Статуи';

  @override
  String get renaiModuleHelpStatuesBody =>
      'Дневные статуи: днём. Ночные — после начала ночи. Волна начала ночи и волна «оживления» статуи задаются индексом с 0 (0 = первая волна).';

  @override
  String get renaiModuleEnableNight => 'Включить ночь';

  @override
  String get renaiModuleEnableNightSubtitle =>
      'Разрешить волну начала ночи и ночные статуи';

  @override
  String get renaiModuleNightStart => 'Волна начала ночи';

  @override
  String get renaiModuleDayStatues => 'Дневные статуи';

  @override
  String get renaiModuleNightStatues => 'Ночные статуи';

  @override
  String get renaiModuleNightStatuesDisabledHint =>
      'Включите ночь, чтобы добавить ночные статуи';

  @override
  String get renaiModuleAddStatue => 'Добавить статую';

  @override
  String get renaiModuleCarveWave => 'Волна оживления';

  @override
  String get renaiModuleStatuesInCell => 'Статуи в выбранной ячейке';

  @override
  String get renaiModuleExpectationLabel => 'Превью события Ренессанса';

  @override
  String get renaiModuleNightStarts => 'Начало ночи';

  @override
  String get renaiModulePreviewNightStatues => 'Ночные статуи:';

  @override
  String get renaiModulePreviewRevivingStatues => 'Воскрешаемые статуи:';

  @override
  String get renaiModuleStatueCarve => 'Оживление статуи';

  @override
  String get moduleTitle_DropShipProperties => 'Воздушный сброс';

  @override
  String get moduleDesc_DropShipProperties =>
      'Настройка волн сброса импов с воздуха';

  @override
  String get airDropShipModuleTitle => 'Воздушный сброс';

  @override
  String get airDropShipModuleHelpTitle => 'Справка по воздушному сбросу';

  @override
  String get airDropShipModuleHelpOverview => 'Обзор';

  @override
  String get airDropShipModuleHelpOverviewBody =>
      'Настройка волн, когда бесята сбрасываются с воздуха. Номер волны — индекс с 0 (0 = первая волна). Каждая запись задаёт волну, доп. количество бесов, их уровень и зону сброса.';

  @override
  String get airDropShipModuleHelpImps => 'Импы';

  @override
  String get airDropShipModuleHelpImpsBody =>
      'Индекс волны с 0. Доп. количество бесят — число дополнительных бесят поверх минимум одного.';

  @override
  String get airDropShipModuleAppearWaves => 'Волны появления';

  @override
  String get airDropShipModuleAppearances => 'Группы сброса';

  @override
  String get airDropShipModuleExtraImpCount => 'Доп. количество бесят';

  @override
  String get airDropShipModuleDropArea => 'Зона сброса';

  @override
  String get airDropShipModuleDropAreaPreview => 'Предпросмотр зоны сброса';

  @override
  String get airDropShipModuleAreaDropPreviewLabel =>
      'Предпросмотр зоны сброса:';

  @override
  String get airDropShipModuleExpectationLabel => 'Сброс бесят';

  @override
  String get airDropShipModuleImpLevel => 'Уровень бесёнка';

  @override
  String get airDropShipModuleRowMin => 'Минимальная строка';

  @override
  String get airDropShipModuleRowMax => 'Максимальная строка';

  @override
  String get airDropShipModuleColMin => 'Минимальный столбец';

  @override
  String get airDropShipModuleColMax => 'Максимальный столбец';

  @override
  String get openModuleSettings => 'Открыть настройки модуля';

  @override
  String get moduleTitle_GlacierModuleProperties => 'Ледяные Блоки Зомбосса';

  @override
  String get moduleDesc_GlacierModuleProperties =>
      'Шансы у зомби для ледяных блоков Зомбосса (6 столбцов слева)';

  @override
  String get glacierModuleTitle => 'Ледяные блоки Зомбосса';

  @override
  String get glacierModuleHelpTitle => 'Ледяные блоки Зомбосса';

  @override
  String get glacierModuleHelpOverviewBody =>
      'Задаёт, какие зомби появляются из ледяных блоков, когда вы их разрушаете. Размещайте модуль в начале списка Modules уровня. Без него блоки не призывают зомби.';

  @override
  String get glacierModuleHelpColumnsTitle => 'Столбцы и записи';

  @override
  String get glacierModuleHelpColumnsBody =>
      'Модуль содержит шесть групп содержимого — по одной для каждого столбца ледяных глыб слева направо. После выбора «Добавить содержимое» можно добавить зомби или пустой результат, при котором после разрушения глыбы зомби не появляется. У каждого элемента есть отдельный вес; только для зомби можно менять тип и задавать уровень от 0 до 4, а у пустого результата настраивается только вес.';

  @override
  String get glacierModuleHelpRequirementsTitle => 'Требования';

  @override
  String get glacierModuleHelpRequirementsBody =>
      'Работает только вместе с модулем битвы с Зомбоссом, если выбран мех Ледникового периода (zombossmech_iceage и его варианты).';

  @override
  String get glacierModuleHelpPresetsTitle => 'Предустановленные конфигурации';

  @override
  String get glacierModuleHelpPresetsBody =>
      'Редактор содержит конфигурации ледяных глыб, использованные вариантами босса Ледникового периода в оригинальной игре. Применение пресета заменяет все шесть групп и не может быть отменено; после этого записи можно изменить вручную. Варианту головоломки с растениями модуль ледяных глыб не нужен, поэтому для него нет пресета. Пользовательский вариант по умолчанию использует пустой пресет.';

  @override
  String get glacierModulePresetSectionTitle => 'Пресеты ледяных глыб';

  @override
  String get glacierModulePresetBlankCustom =>
      'Пользовательский вариант (пустой пресет)';

  @override
  String get glacierModulePresetCustomConfiguration =>
      'Пользовательская конфигурация';

  @override
  String get glacierModuleSwitchPresetTitle => 'Сменить пресет ледяных глыб';

  @override
  String glacierModuleSwitchPresetMessage(String from, String to) {
    return 'Переключиться с «$from» на «$to»? Все шесть текущих групп ледяных глыб будут заменены без возможности отмены.';
  }

  @override
  String get glacierModuleVariationPresetPromptTitle =>
      'Включить соответствующий пресет ледяных глыб';

  @override
  String get glacierModuleVariationPresetPrompt =>
      'Зомбосс призывает зомби через ледяные глыбы, содержимое которых настраивается отдельным модулем. Вы собираетесь выбрать другой вариант Зомбосса Замороженных Пещер. Включить также пресет модуля ледяных глыб, использованный этим вариантом в оригинальной игре?';

  @override
  String get glacierModuleCustomVariationPresetPrompt =>
      'Пользовательский вариант по умолчанию использует пустой пресет ледяных глыб. Переключить модуль на пустой пресет?';

  @override
  String get zombossMechSwitchVariationOnly => 'Сменить только вариант';

  @override
  String get glacierModuleEnablePreset => 'Также включить пресет';

  @override
  String get iceAgePlantPuzzleVariationWarningTitle =>
      'Головоломке с растениями не нужны ледяные глыбы';

  @override
  String get iceAgePlantPuzzleVariationWarning =>
      'Этот вариант создан специально для мини-игры с растениями в Замороженных Пещерах. Его способности не требуют модуля ледяных глыб.';

  @override
  String get glacierModuleCompatibilityWarningTitle =>
      'Требования модуля ледяных глыб';

  @override
  String get glacierModuleCompatibilityWarning =>
      'Модуль работает только с модулем битвы с боссом и мехом Замороженных пещер (zombossmech_iceage). Добавьте или исправьте эти настройки, чтобы ледяные блоки призывали зомби.';

  @override
  String get glacierModuleUnderwaterWarningTitle =>
      'Несовместимость с лужайками на основе Подводного Мира';

  @override
  String get glacierModuleUnderwaterWarning =>
      'Не рекомендуется использовать Зомбосса Замоороженных Пещер и модуль ледяных глыб на лужайке Подводного Мира/Атлантиды. Это может испортить внешний вид уровня.';

  @override
  String glacierModuleColumn(int columnIndex) {
    return 'Столбец $columnIndex (слева)';
  }

  @override
  String glacierModuleEntryCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count записей',
      many: '$count записей',
      few: '$count записи',
      one: '1 запись',
    );
    return '$_temp0';
  }

  @override
  String glacierModuleEntryLabel(int index) {
    return 'Запись $index';
  }

  @override
  String get glacierModuleNoEntries =>
      'Для этого столбца пока не настроено содержимое.';

  @override
  String get glacierModuleAddEntry => 'Добавить содержимое';

  @override
  String get glacierModuleAddContentTitle =>
      'Добавить содержимое ледяной глыбы';

  @override
  String get glacierModuleAddZombieContent => 'Добавить зомби';

  @override
  String get glacierModuleAddZombieDescription =>
      'Выберите зомби, который может появиться после разрушения ледяной глыбы.';

  @override
  String get glacierModuleAddEmptyDescription =>
      'Добавьте отдельно взвешенный результат, при котором ледяная глыба не выпускает зомби.';

  @override
  String get glacierModuleSelectZombie => 'Выбрать зомби';

  @override
  String get glacierModuleEmptyType =>
      'После разрушения глыбы зомби не появляется';

  @override
  String get glacierModuleWeight => 'Шанс';

  @override
  String get glacierModuleWeightTooltip =>
      'Относительный шанс появления этого зомби в столбце.';

  @override
  String get glacierModuleEmptyWeightTooltip =>
      'Шанс результата, при котором ледяная глыба не выпускает зомби.';

  @override
  String get glacierModuleLevel => 'Уровень зомби';

  @override
  String get glacierModuleLevelTooltip => 'Уровень зомби от 0 до 4.';

  @override
  String get moduleTitle_HeianWindModuleProperties => 'Ветер Хэйан';

  @override
  String get moduleDesc_HeianWindModuleProperties =>
      'Настройка ветров, влияющих на зомби в волнах';

  @override
  String get heianWindModuleTitle => 'Ветер Хэйан';

  @override
  String get heianWindModuleHelpTitle => 'Справка по ветру Хэйан';

  @override
  String get heianWindModuleHelpOverview => 'Обзор';

  @override
  String get heianWindModuleHelpOverviewBody =>
      'Настройка ветров на конкретных волнах. Индекс волны с 0 (0 = первая волна). Ветер толкает зомби; на отдельных рядах может вызвать торнадо, которое несёт зомби вперёд и сдувает растения.';

  @override
  String get heianWindModuleHelpDistance => 'Дистанция';

  @override
  String get heianWindModuleHelpDistanceBody =>
      'Дистанция 50 равна одной клетке сетки. Отрицательные значения двигают зомби влево; положительные — вправо.';

  @override
  String get heianWindModuleHelpRow => 'Ряд';

  @override
  String get heianWindModuleHelpRowBody =>
      'Можно указать любой ряд или все ряды сразу. Ветер на отдельных рядах также вызывает торнадо, которое несёт зомби вперёд и сдувает растение.';

  @override
  String get heianWindModuleWaves => 'Волны с ветром';

  @override
  String get heianWindModuleWavesHint => 'начинается с 0';

  @override
  String get heianWindModuleAppearances => 'Появления';

  @override
  String get heianWindModuleWindDelay => 'Задержка ветра (WindDelay; секунды)';

  @override
  String get heianWindModuleWindDelayHint => 'единица: секунды';

  @override
  String get heianWindModuleWindEntries => 'Записи ветра';

  @override
  String get heianWindModuleAddWind => 'Добавить ветер';

  @override
  String get heianWindModuleRow => 'Ряд';

  @override
  String get heianWindModuleAllRows => 'Все ряды';

  @override
  String get heianWindModuleAffectZombies => 'Затронуто зомби';

  @override
  String get heianWindModuleDistance => 'Дистанция';

  @override
  String get heianWindModuleDistanceHint => '1 клетка = 50 единиц';

  @override
  String get heianWindModuleMoveTime => 'Время движения (MoveTime; секунды)';

  @override
  String get heianWindModuleMoveTimeHint => 'единица: секунды';

  @override
  String get heianWindModuleExpectationLabel => 'Ветер Хэйан';

  @override
  String get jsonViewerModeReading => '(режим чтения)';

  @override
  String get jsonViewerModeObjectReading => '(режим чтения объектов)';

  @override
  String get jsonViewerModeEdit => '(режим редактирования)';

  @override
  String get jsonViewerFontSize => 'Размер шрифта';

  @override
  String get jsonViewerSearchHint => 'Поиск';

  @override
  String get jsonViewerReplaceHint => 'Заменить';

  @override
  String get jsonViewerSearchHistory => 'Недавние запросы';

  @override
  String get jsonViewerReplaceHistory => 'Недавние замены';

  @override
  String get jsonViewerInsertNewline => 'Вставить перевод строки';

  @override
  String get jsonViewerMatchCase => 'Учитывать регистр';

  @override
  String get jsonViewerWholeWords => 'Слова';

  @override
  String get jsonViewerRegex => 'Регулярные выражения';

  @override
  String get jsonViewerPreviousMatch => 'Предыдущее совпадение';

  @override
  String get jsonViewerNextMatch => 'Следующее совпадение';

  @override
  String get jsonViewerReplaceOne => 'Заменить';

  @override
  String get jsonViewerReplaceAll => 'Заменить все';

  @override
  String jsonViewerMatchCounter(int current, int total) {
    return '$current из $total';
  }

  @override
  String get tooltipAboutModule => 'О модуле';

  @override
  String get tooltipAboutSection => 'Об этом разделе';

  @override
  String get tooltipAboutEvent => 'О событии';

  @override
  String get tooltipSave => 'Сохранить';

  @override
  String get tooltipEdit => 'Редактировать';

  @override
  String get tooltipClose => 'Закрыть';

  @override
  String get tooltipToggleObjectView =>
      'Переключить вид объектов/сырого текста';

  @override
  String get tooltipClearUnused => 'Удалить неиспользуемые объекты';

  @override
  String get tooltipCopyJson => 'Копировать JSON уровня';

  @override
  String get tooltipCopyObject => 'Копировать JSON объекта';

  @override
  String get tooltipMore => 'Ещё';

  @override
  String get jsonViewerCopied => 'JSON скопирован в буфер обмена';

  @override
  String get tooltipJsonViewer => 'Просмотр/редактирование JSON';

  @override
  String get tooltipAdd => 'Добавить';

  @override
  String get tooltipDecrease => 'Уменьшить';

  @override
  String get tooltipIncrease => 'Увеличить';

  @override
  String get bungeeWaveEventTitle => 'Событие сброса с парашютом';

  @override
  String get bungeeWaveEventHelpTitle => 'Событие сброса с парашютом';

  @override
  String get bungeeWaveEventHelpOverview =>
      'Задайте тип зомби и клетку лужайки для одного сброса. Одно событие — один зомби.';

  @override
  String get bungeeWaveEventHelpGrid => 'Сетка';

  @override
  String get bungeeWaveEventHelpGridBody =>
      'Нажмите на клетку в сетке, чтобы задать место приземления зомби с парашютом.';

  @override
  String get bungeeWaveCurrentTarget => 'Текущая цель';

  @override
  String get bungeeWaveCol => 'Столб.';

  @override
  String get bungeeWaveRow => 'Ряд';

  @override
  String get bungeeWavePropertiesConfig => 'Свойства';

  @override
  String get bungeeWaveZombieLevel => 'Уровень зомби (Level)';

  @override
  String get bungeeWaveRoofWarning =>
      'На крыше Пальмы-зонты могут перехватить сброс и вызвать мгновенное съедание мозга. Используйте осторожно.';

  @override
  String get moduleTitle_LevelMutatorRiftTimedSunProps => 'Солнце за зомби';

  @override
  String get moduleDesc_LevelMutatorRiftTimedSunProps =>
      'Солнце за зомби по уровням (Погоня Пенни); отключает солнечную лопату';

  @override
  String get zombieSunDropTitle => 'Настройка солнца за зомби';

  @override
  String get zombieSunDropHelpTitle => 'Солнце за зомби';

  @override
  String get zombieSunDropHelpOverview =>
      'Задайте количество солнца за конкретных зомби по уровням (Погоня Пенни). Модуль также отключает солнечную лопату.';

  @override
  String get zombieSunDropHelpValues => 'Значения';

  @override
  String get zombieSunDropHelpValuesBody =>
      'Шесть целых чисел соответствуют уровням 1–6. При уровне выше 6 используется значение 1-го уровня.';

  @override
  String get zombieSunDropEmpty => 'Нет записей. Нажмите +, чтобы добавить.';

  @override
  String get zombieSunDropDefaultDrop => 'Сброс по умолчанию';

  @override
  String get zombieSunDropSun => 'солнце';

  @override
  String get zombieSunDropEditTitle => 'Редактировать значения';

  @override
  String get zombieSunDropEditHint =>
      'Настройте солнце для уровней 1–6. При уровне выше 6 используется значение 1-го уровня.';

  @override
  String get zombieSunDropTier => 'Уровень';

  @override
  String zombieSunDropTierLabel(int tier) {
    return 'Уровень $tier';
  }

  @override
  String get moduleTitle_PickupCollectableTutorialProperties =>
      'Обучение с монеткой';

  @override
  String get moduleDesc_PickupCollectableTutorialProperties =>
      'Зомби, роняющий монетку + текст диалога подбора';

  @override
  String get pickupCollectableTutorialTitle => 'Обучение с монеткой';

  @override
  String get pickupCollectableTutorialHelpTitle => 'Обучение с монеткой';

  @override
  String get pickupCollectableTutorialHelpBasic => 'Описание';

  @override
  String get pickupCollectableTutorialHelpBasicBody =>
      'Настройте зомби, роняющего монетку, и текст до/после подбора. При первом убийстве такого зомби в уровне показывается диалог.';

  @override
  String get pickupCollectableTutorialHelpDialogs => 'Диалоги';

  @override
  String get pickupCollectableTutorialHelpDialogsBody =>
      'Диалоги показываются до и после подбора предмета и могут приостанавливать уровень.';

  @override
  String get pickupCollectableTutorialCoreConfig => 'Основная настройка';

  @override
  String get pickupCollectableTutorialZombieLabel => 'Зомби с монеткой';

  @override
  String get pickupCollectableTutorialLootType => 'Тип добычи';

  @override
  String get pickupCollectableTutorialGuideText => 'Текст подсказок';

  @override
  String get pickupCollectableTutorialPickupAdvice =>
      'До подбора (PickupAdvice)';

  @override
  String get pickupCollectableTutorialPostPickupAdvice =>
      'После подбора (PostPickupAdvice)';

  @override
  String get pickupCollectableTutorialNotSet => 'Не задано';

  @override
  String get pickupCollectableLootGoldCoin => 'Золотая монета';

  @override
  String get invalidRtonMagic =>
      'Неверный файл RTON: магия должна быть «RTON».';

  @override
  String get invalidRtonVersion => 'Неверная версия RTON (ожидается 1).';

  @override
  String get invalidRtonEnd =>
      'Неверный файл RTON: должен заканчиваться на «DONE».';

  @override
  String get invalidRtonArrayEnd => 'Неверный разделитель массива RTON.';

  @override
  String get invalidRtid => 'Недопустимое значение RTID.';

  @override
  String get invalidValueType => 'Недопустимый тип значения для RTON.';

  @override
  String get musicSuffix => 'Суффикс музыки';

  @override
  String get ambientAudioSuffix => 'Суффикс фонового звука';

  @override
  String get selectMusicSuffix => 'Выбор суффикса музыки';

  @override
  String get searchMusicSuffix => 'Поиск по названию или коду';

  @override
  String get noMusicSuffixFound => 'Суффикс не найден';

  @override
  String get jsonViewerLineContinuation => '↳';

  @override
  String get zombossMechCustomVariation => 'Свой';

  @override
  String get editCustomZombossMech => 'Изменить';

  @override
  String get customZombossMechProperties => 'Свои свойства зомбот';

  @override
  String get customZombossMechScalars => 'Параметры перемещения';

  @override
  String get customZombossMechStages => 'Фазы боя';

  @override
  String get customZombossMechEditHint =>
      'Редактирование свойств memo-варианта меха в файле уровня.';

  @override
  String get zombossMechMinColumn => 'Мин. колонка';

  @override
  String get zombossMechMaxColumn => 'Макс. колонка';

  @override
  String get zombossMechSquashZombies => 'Может раздавливать зомби';

  @override
  String get zombossMechSquashGridItems => 'Может раздавливать объекты газона';

  @override
  String get zombossMultipleModuleSelectionHint =>
      'Обнаружено несколько одинаковых модулей босса. Выберите нужный экземпляр в списке модулей в настройках уровня.';

  @override
  String get zombossMechStageActions => 'Действия';

  @override
  String get zombossMechActions => 'Действия';

  @override
  String get zombossMechPropertiesLabel => 'Свойства';

  @override
  String get zombossMechAliasLabel =>
      'Псевдоним (только английские буквы; без пробелов)';

  @override
  String get zombossMechDeletePhase => 'Удалить фазу';

  @override
  String zombossMechDeletePhaseTitle(int number) {
    return 'Удалить фазу $number?';
  }

  @override
  String get zombossMechDeletePhaseMessage =>
      'Фаза и её список действий будут удалены. Это нельзя отменить.';

  @override
  String get zombossMechDeleteEightiesPhaseMessage =>
      'Фаза, её список действий, а также соответствующие ей музыка и анимация Зомбосса будут удалены. Это действие нельзя отменить.';

  @override
  String get zombossMechStageJamOrder => 'Порядок музыки (StageJamOrder)';

  @override
  String get zombossMechZombossAnimOrder =>
      'Порядок анимаций Зомбосса (ZombossAnimOrder)';

  @override
  String get zombossMechAddEightiesPhaseTitle =>
      'Выберите музыку и анимацию Зомбосса для новой фазы';

  @override
  String get zombossMechEightiesPhaseSelectionRequired =>
      'Перед созданием фазы необходимо выбрать музыку и анимацию Зомбосса.';

  @override
  String get zombossMechCreatePhase => 'Создать фазу';

  @override
  String get zombossAnimNewWave => 'Новая волна';

  @override
  String get zombossAnimHipHop => 'Хип-хоп';

  @override
  String get zombossMechOrphanActionDeleteTitle =>
      'Удалить данные пользовательского действия?';

  @override
  String zombossMechOrphanActionDeleteMessage(String alias) {
    return '«$alias» больше не используется в уровне. Удалить объект действия из файла уровня?';
  }

  @override
  String get zombossMechPhasesHelp =>
      'У каждой фазы есть очки здоровья, упорядоченный список действий (сверху вниз) и при поддержке — действие отступления.';

  @override
  String get zombossMechPhasesHelpTitle => 'Содержимое фаз';

  @override
  String get zombossMechAddAction => 'Добавить действие';

  @override
  String get zombossMechNoStageActions => 'Действий пока нет';

  @override
  String get zombossMechSelectAction => 'Выбрать действие';

  @override
  String get zombossMechSummonJump => 'Прыжок при призыве';

  @override
  String get zombossMechSelectRetreatAction => 'Выбрать отступление';

  @override
  String get zombossMechCreateCustomAction => 'Новое своё действие';

  @override
  String get zombossMechEditCustomAction => 'Редактировать своё действие';

  @override
  String get zombossMechActionCategoryAll => 'Все';

  @override
  String get zombossMechActionCategoryMovement => 'Движение';

  @override
  String get zombossMechActionCategoryAttack => 'Атака';

  @override
  String get zombossMechActionCategorySpecial => 'Особые';

  @override
  String get zombossMechActionCategorySpawn => 'Призыв';

  @override
  String get zombossMechActionCategoryCustom => 'Свои';

  @override
  String get zombossMechActionCategoryRetreat => 'Отступление';

  @override
  String get zombossMechNoActionsFound => 'Действия не найдены';

  @override
  String get zombossMechCustomActionLabel => 'Своё (CurrentLevel)';

  @override
  String zombossCustomActionBaseAction(String action) {
    return 'Базовое действие: $action';
  }

  @override
  String zombossPresetDerivedBaseAction(String action) {
    return 'На основе предустановленного пользовательского действия: $action';
  }

  @override
  String get zombossMechActionAliasHint =>
      'Имя в RTID(псевдоним@CurrentLevel). Можно изменить позже; ссылки в этом листе свойств обновятся автоматически.';

  @override
  String get zombossMechActionBaseObjclass => 'Тип действия (objclass)';

  @override
  String get zombossMechActionBaseAction => 'Базовое действие';

  @override
  String get zombossMechActionTemplateHint =>
      'Выберите встроенное действие, чтобы скопировать его тип и значения по умолчанию. После создания всё можно изменить.';

  @override
  String get zombossMechRecreateFromTemplate => 'Пересоздать из шаблона';

  @override
  String get zombossMechRecreateFromTemplateTitle => 'Заменить это действие?';

  @override
  String get zombossMechRecreateFromTemplateMessage =>
      'Тип действия (objclass) и все значения полей будут заменены выбранным шаблоном. Текущие значения будут потеряны.';

  @override
  String get zombossMechBaseActionAliasSyncTitle =>
      'Обновить кодовое имя действия?';

  @override
  String zombossMechBaseActionAliasSyncMessage(String alias) {
    return 'После смены базового действия также изменить кодовое имя действия на «$alias»?';
  }

  @override
  String get zombossMechBaseActionAliasKeep => 'Сохранить текущее имя';

  @override
  String get zombossMechBaseActionAliasUpdate => 'Обновить имя';

  @override
  String get zombossMechActionDetails => 'Сведения о действии';

  @override
  String get zombossMechActionRtid => 'RTID';

  @override
  String get zombossMechActionFields => 'Поля действия';

  @override
  String get zombossMechPropertiesViewTitle => 'Свойства зомбот';

  @override
  String get viewZombossMechProperties => 'Просмотреть свойства';

  @override
  String get zombossMechEditRetreatAction => 'Выбрать отступление';

  @override
  String get zombossMechAddZombie => 'Добавить зомби';

  @override
  String get zombossMechPickZombie => 'Выбрать зомби';

  @override
  String get zombossMechNoZombiesInList => 'Список зомби пуст';

  @override
  String get zombossMechSpawnBallSettings =>
      'Настройка выпадения (ZombieDropProps)';

  @override
  String get zombossMechAwardDropInvalidTitle =>
      'Недействительная ссылка SpawnBall';

  @override
  String zombossMechAwardDropInvalidBody(String rtid) {
    return 'AwardDrop ссылается на «$rtid», но это не является корректным объектом ZombieDropProps текущего уровня. Игра может не загрузить это действие.';
  }

  @override
  String get zombossMechAwardDropClearInvalid =>
      'Очистить неверное значение и восстановить значение по умолчанию';

  @override
  String get zombossMechCatalogActionReadOnly =>
      'Встроенные действия здесь не редактируются. Создайте своё действие, чтобы изменить списки зомби.';

  @override
  String get zombossMechRetreatDisabled => 'Отключено';

  @override
  String get zombossMechOpenGlacierModule =>
      'Перейти к настройкам модуля ледяных глыб';

  @override
  String get zombossMechConfigureInitialGridItems =>
      'Настроить начальные объекты сетки';

  @override
  String get zombossMechEightiesSpeakerPresetPromptTitle =>
      'Разместить динамики заранее?';

  @override
  String get zombossMechEightiesSpeakerPresetPrompt =>
      'На первой фазе Зомбот Неонового Микстейп Тура обычно использует специальные динамики на поле для применения своих способностей, поэтому на официальных уровнях их заранее размещают в определённых позициях.\nВы собираетесь переключиться на Зомбота Неонового Микстейп Тура. Разместить эти динамики на тех же позициях, что и на официальных уровнях?';

  @override
  String get zombossMechSwitchBaseOnly => 'Только сменить Зомбота';

  @override
  String get zombossMechPreplaceSpeakers => 'Разместить динамики';

  @override
  String get zombossMechEightiesSpeakerRemovePromptTitle => 'Удалить динамики?';

  @override
  String get zombossMechEightiesSpeakerRemovePrompt =>
      'Вы собираетесь переключиться с Зомбота Неонового Микстейп Тура на другого. Удалить специальные динамики, ранее размещённые на тех же позициях, что и на официальных уровнях?\nБудут удалены только те объекты в этих позициях, которые всё ещё являются динамиками Зомбосса; всё, чем вы заменили их позднее, останется без изменений.';

  @override
  String get zombossMechKeepSpeakers => 'Оставить динамики';

  @override
  String get zombossMechRemoveSpeakers => 'Удалить динамики';

  @override
  String get zombossMechRobotSpawnRow => 'Ряд';

  @override
  String get zombossMechRobotSpawnRowRandom => 'Случайный (-1)';

  @override
  String get zombossMechRobotSpawnLevel => 'Уровень';

  @override
  String get zombossMechRobotSpawnWeight => 'Шанс';

  @override
  String get zombossMechRobotSpawnPlantfood => 'Подкормка';

  @override
  String get zombossMechRetreatAction => 'Отступление';

  @override
  String zombossMechPhaseNumber(int number) {
    return 'Фаза $number';
  }

  @override
  String get zombossMechAddPhase => 'Добавить фазу';

  @override
  String get zombossMechRemovePhase => 'Удалить фазу';

  @override
  String get zombossMechHitPoints => 'Очки здоровья';

  @override
  String get continueAnyway => 'Всё равно продолжить';

  @override
  String get armrackModuleTitle => 'Оружейные стойки';

  @override
  String get armrackModuleHelpTitle => 'Модуль оружейных стоек';

  @override
  String get armrackModuleHelpOverview => 'Обзор';

  @override
  String get armrackModuleHelpOverviewBody =>
      'Размещает оружейные стойки на газоне. Волна 1 — начальный пресет (до старта уровня); последующие группы появляются в волнах генератора по правилу N−1.';

  @override
  String get armrackModuleHelpPlacement => 'Размещение';

  @override
  String get armrackModuleHelpPlacementBody =>
      'Выберите тип стойки и нажмите на клетку (одна на клетку). ПКМ или долгое нажатие удаляет стойку с клетки.';

  @override
  String get armrackModuleHelpWaveLimit => 'Ограничение по волнам';

  @override
  String get armrackModuleHelpWaveLimitBody =>
      'Из-за ограничения игры в игре действуют только записи волны 1. Другие группы волн можно редактировать здесь и сохранять в файл уровня, но на временной шкале отображается только волна 1.';

  @override
  String get armrackModuleTypePalette => 'Тип стойки';

  @override
  String get armrackModuleExpectationLabel => 'Оружейные стойки';

  @override
  String get armrackModuleIgnoredWaveOverridesWarning =>
      'В уровне есть переопределения оружейных стоек для волн, отличных от 1. Они сохраняются, но не отображаются на временной шкале, так как игра применяет только волну 1.';

  @override
  String armrackModuleRequiredMessage(String moduleName) {
    return 'Чтобы оружейные стойки отображались правильно и без текстур солнца, нужно добавить модуль «$moduleName».';
  }

  @override
  String renaiGridItemModuleRequiredMessage(String moduleName) {
    return 'Для корректной работы колеса Ренессанса требуется модуль «$moduleName». Добавить его?';
  }

  @override
  String get energyGridModuleTitle => 'Плитки с подкормкой';

  @override
  String get energyGridModuleHelpTitle => 'Модуль плиток с подкормкой';

  @override
  String get energyGridModuleHelpOverview => 'Обзор';

  @override
  String get energyGridModuleHelpOverviewBody =>
      'Размещает плитки с подкормкой на газоне. Волна 1 — начальный пресет (до старта уровня); последующие группы появляются в волнах генератора по правилу N−1.';

  @override
  String get energyGridModuleHelpPlacement => 'Размещение';

  @override
  String get energyGridModuleHelpPlacementBody =>
      'Нажмите пустую клетку, чтобы поставить плитку (одна на клетку). ПКМ или долгое нажатие удаляет плитку.';

  @override
  String get energyGridModuleHelpWaveLimit => 'Ограничение по волнам';

  @override
  String get energyGridModuleHelpWaveLimitBody =>
      'Из-за ограничения игры в игре действуют только записи волны 1. Другие группы волн можно редактировать здесь и сохранять в файл уровня, но на временной шкале отображается только волна 1.';

  @override
  String get energyGridModuleTapToPlace =>
      'Нажмите пустую клетку, чтобы поставить плитку с подкормкой.';

  @override
  String get energyGridModuleExpectationLabel => 'Плитки с подкормкой';

  @override
  String get energyGridModuleIgnoredWaveOverridesWarning =>
      'В уровне есть переопределения плиток с подкормкой для волн, отличных от 1. Они сохраняются, но не отображаются на временной шкале, так как игра применяет только волну 1.';

  @override
  String get energyGridModuleWarningMessage =>
      'Из-за ошибки игры сгенерированные плитки с подкормкой могут отображаться как фиолетовые маркеры X. На функциональность это не влияет.';

  @override
  String get gridOverrideModuleAppearances => 'Группы волн';

  @override
  String get gridOverrideModuleWaveFieldOneBased =>
      'Волна модуля (1 = начальный пресет, 2+ = появление в волне генератора N−1)';

  @override
  String get gridOverrideModuleTimelineNote =>
      'На временной шкале отображаются только записи волны 1.';

  @override
  String get gridOverrideModuleInitialWaveNote =>
      'Это начальный пресет: объекты появляются на газоне до старта уровня.';

  @override
  String gridOverrideModuleWaveSpawnNote(int waveGeneratorWave) {
    return 'Эта группа появляется, когда начинается волна генератора $waveGeneratorWave.';
  }

  @override
  String get gridOverrideModuleWaveSpawnTimelineNote =>
      'Эти записи не действуют во вкладке менеджера волн.';

  @override
  String get gridOverrideModuleHelpWaveNumbering => 'Нумерация волн';

  @override
  String get gridOverrideModuleHelpWaveNumberingBody =>
      'Волна 1 — начальный пресет: объекты на газоне до старта уровня. С волны 2 правило N−1: волна модуля N появляется при волне генератора N−1 (волна 2 → волна генератора 1, волна 3 → волна генератора 2 и т. д.).';

  @override
  String get gridOverridePreviewArmrackTitle => 'Размещение оружейных стоек';

  @override
  String get gridOverridePreviewEnergyGridTitle =>
      'Размещение плиток с подкормкой';

  @override
  String get waveGeneratorInitialGridOverridesTitle =>
      'Управление начальными препятствиями мира Кунг-фу';

  @override
  String get waveGeneratorPreviewInitialArmrack => 'Начальные оружейные стойки';

  @override
  String get waveGeneratorPreviewInitialEnergyGrid =>
      'Начальные плитки с подкормкой';

  @override
  String waveGeneratorGridOverrideWavePreviewTitle(int wave, String label) {
    return 'Волна $wave — $label';
  }

  @override
  String get mechanismPlankSettings => 'Настройки объединённых вагонеток';

  @override
  String get mechanismPlankStartColumn => 'Стартовая колонка (mx)';

  @override
  String get mechanismPlankTrackLength => 'Длина рельсовых дорожек (mWidth)';

  @override
  String get mechanismPlankEditNotice =>
      'Этот интерфейс поддерживает только изменение стартовой колонны и длины рельсовых дорожек. Все остальные параметры используют уже заранее заготовленные значения, так как их изменение может привести к поломке вагонеток. Для более продвинутой кастомизации воспользуйтесь функцией редактирования JSON файла.\nК тому же, не рекомендуется использовать модуль объединённых вагонеток вне лужайки Кунг-Фу мира, так как сами вагонетки могут не прогрузиться и отображаться как фиолетовые кресты. Их работоспособность не постарадает, но на визуальной составляющей уровня это может сказаться сильно.';

  @override
  String get mechanismPlankOutOfAreaWarning =>
      'Текущая доска может вылезти за пределы лужайки.';

  @override
  String get portalTypeEgypt => 'Древний Египет (1)';

  @override
  String get portalTypeEgypt2 => 'Древний Египет (2)';

  @override
  String get portalTypePirate => 'Пиратские Моря';

  @override
  String get portalTypeWest => 'Дикий Запад';

  @override
  String get portalTypeFuture => 'Далёкое Будущее (1)';

  @override
  String get portalTypeFuture2 => 'Далёкое Будущее (2)';

  @override
  String get portalTypeDark => 'Тёмные Века';

  @override
  String get portalTypeBeach => 'Пляж Большой Волны';

  @override
  String get portalTypeIceAge => 'Замоороженные Пещеры';

  @override
  String get portalTypeLostCity => 'Затерянный Город';

  @override
  String get portalTypeEighties => 'Неоновый Микстейп Тур';

  @override
  String get portalTypeDino => 'Юрское Болото';

  @override
  String get portalTypeEndlessEgypt => 'Древний Египет (Беск. зона)';

  @override
  String get portalTypeEndlessPirate => 'Пиратские Моря (Беск. зона)';

  @override
  String get portalTypeEndlessWest => 'Дикий Запад (Беск. зона)';

  @override
  String get portalTypeEndlessKongfu => 'Кунг-Фу Мир (Беск. Зона)';

  @override
  String get portalTypeEndlessFuture => 'Далёкое Будущее (Беск. зона)';

  @override
  String get portalTypeEndlessDark => 'Тёмные Века (Беск. зона)';

  @override
  String get portalTypeEndlessBeach => 'Пляж Большой Волны (Беск. зона)';

  @override
  String get portalTypeEndlessIceAge => 'Замороженные Пещеры (Беск. зона)';

  @override
  String get portalTypeEndlessSkyCity => 'Небесный Город (Беск. зона)';

  @override
  String get portalTypeEndlessLostCity => 'Затерянный Город (Беск. зона)';

  @override
  String get portalTypeEndlessEighties => 'Неоновый Микстейп Тур (Беск. зона)';

  @override
  String get portalTypeEndlessDino => 'Юрское Болото (Беск. зона)';

  @override
  String get portalTypeEndlessModern => 'Современный День (Беск. зона)';

  @override
  String get portalTypeMemoryLane1 => 'Дорога Воспоминаний (1)';

  @override
  String get portalTypeMemoryLane2 => 'Дорога Воспоминаний (2)';

  @override
  String get portalTypeMemoryLane3 => 'Дорога Воспоминаний (3)';

  @override
  String get portalTypeShieldGenerator =>
      'Генератор Щита (статичный протектор)';

  @override
  String get portalTypeGlacialNianSkill => 'Способность Ледяного Няня';

  @override
  String get portalTypeZombotany => 'Зомботания';

  @override
  String get portalTypeSlimeZombies => 'Слизневый';

  @override
  String get portalTypeUniverse42 => 'Параллельная Вселенная № 42';

  @override
  String get portalTypeUniverse41 => 'Параллельная Вселенная № 41';

  @override
  String get portalTypeEliteHealerNormal => 'Элитный Целитель (обычный)';

  @override
  String get portalTypeEliteElectricNormal =>
      'Элитный Зомби с Электропушкой (обычный)';

  @override
  String get portalTypeEliteBallistaNormal => 'Элитная Баллиста (обычная)';

  @override
  String get portalTypeEliteOnmyojiNormal =>
      'Элитный Онмидзе (зомби с веером, обычный)';

  @override
  String get portalTypeEliteHealerHard => 'Элитный Целитель (усложнённый)';

  @override
  String get portalTypeEliteElectricHard =>
      'Элитный Зомби с Электропушкой (усложнённый)';

  @override
  String get portalTypeEliteBallistaHard => 'Элитная Баллиста (усложнённая)';

  @override
  String get portalTypeEliteOnmyojiHard =>
      'Элитный Онмидзе (зомби с веером, усложнённый)';

  @override
  String get portalTypeRomeoHard => 'Ромео (1, Дорога Воспоминаний)';

  @override
  String get portalTypeRomeoHard2 => 'Ромео (2, Дорога Воспоминаний)';

  @override
  String get portalTypeJulietHard => 'Джульетта (1, Дорога Воспоминаний)';

  @override
  String get portalTypeJulietHard2 => 'Джульетта (2, Дорога Воспоминаний)';

  @override
  String get portalTypeSherlockHard => 'Шейлок (Дорога Воспоминаний)';

  @override
  String get portalTypeEliteHunter => 'Элитный Охотник';

  @override
  String get portalTypeEliteChief => 'Элитный Ветровой Шеф';

  @override
  String get portalTypeEliteWeasel => 'Элитная Ласочница';

  @override
  String get portalTypeEliteBumperCar => 'Элитная Бамперная Машина';

  @override
  String get portalTypeGlacialNian => 'Ледяной Нянь';

  @override
  String get portalTypeEliteWizard => 'Элитный Маг';

  @override
  String get portalTypeEliteKing => 'Элитный Король';

  @override
  String get portalTypeEliteMirrorQueen => 'Элитная Королева Кривых Зеркал';

  @override
  String get waveGeneratorTabLabel => 'Линия генерации волн';

  @override
  String get waveGeneratorModuleTitle => 'Генератор волн';

  @override
  String get waveGeneratorModuleHelpTitle =>
      'Справка по модулю генератора волн';

  @override
  String get waveGeneratorModuleHelpOverview => 'Краткое описание';

  @override
  String get waveGeneratorModuleHelpOverviewBody =>
      'Генератор волн — ранняя система волн, используемая в Кунг-Фу мире, испытаниях с пазлами и других старых уровнях. Данные всех волн хранятся непосредственно в модуле, без отдельных событий волн.\nГруппы в модулях оружейных стоек и плиток с подкормкой можно сопоставить с волнами генератора один к одному, чтобы получить эффект, аналогичный событиям волн. На экране «Линия генерации волн» отображаются позиции появления этих препятствий Кунг-Фу Мира.';

  @override
  String get waveGeneratorModuleHelpSpending => 'Призыв за очки';

  @override
  String get waveGeneratorModuleHelpSpendingBody =>
      'Случайный призыв расходует очки, доступные на текущей волне. Игра выбирает по шансу одного из зомби, доступных за оставшиеся очки, вычитает его стоимость и снова фильтрует кандидатов, пока подходящих зомби не останется. Неиспользованные очки не переносятся на следующую волну, а фиксированный призыв их не расходует.';

  @override
  String get waveGeneratorModuleHelpPointTrajectory => 'Параметры';

  @override
  String get waveGeneratorModuleHelpPointTrajectoryBody =>
      'Первая волна использует «Начальные очки случайного призыва (WaveSpendingPoints)». Затем количество очков по умолчанию увеличивается на «Прирост очков за волну (WaveSpendingPointIncrement)» с каждой волной; отключение случайного призыва на отдельной волне не останавливает этот рост.\n«Очки случайного призыва текущей волны (WavePointStart)» изменяют очки текущей волны, «Новый прирост очков (WavePointIncrement)» изменяет прирост для последующих волн, а «Сброс траектории очков (WavePointOverride)» определяет, вернётся ли следующая волна к значению, рассчитанному по исходному номеру волны, или продолжит расчёт от очков текущей волны как от новой начальной точки.';

  @override
  String get waveGeneratorModuleHelpPool => 'Пул зомби';

  @override
  String get waveGeneratorModuleHelpPoolBody =>
      'Пул зомби для случайного призыва постепенно расширяется по мере прохождения волн. Сначала используется начальный пул, затем зомби, добавленные на каждой волне, сохраняются для этой и всех последующих волн. Даже если случайный призыв на текущей волне отключён, добавленные на ней зомби всё равно попадут в пул.';

  @override
  String get waveGeneratorModuleHelpIncompat => 'Совместимость модулей';

  @override
  String get waveGeneratorModuleHelpIncompatBody =>
      'Генератор волн может быть несовместим с некоторыми модулями, например со «Звёздным узором», что приводит к сбою уровня. Используйте с осторожностью.\nГладиаторский ряд не работает с Генератором волн. Используйте Менеджер волн.';

  @override
  String get waveGeneratorModuleHelpRow => 'Номера рядов';

  @override
  String get waveGeneratorModuleHelpRowBody =>
      'Нумерация рядов для фиксированного призыва начинается с 1: для первого ряда укажите «1», для второго — «2». Значение «?» позволяет игре выбрать ряд случайно.';

  @override
  String get waveGeneratorModuleGlobalParams => 'Глобальные параметры';

  @override
  String get waveGeneratorGlobalParams => 'Параметры генератора волн';

  @override
  String get waveGeneratorFlagIntervalHint =>
      'Через указанное число волн создаётся флаговая волна. Это не изменяет её очки случайного призыва.';

  @override
  String get flagWaveInterval => 'Интервал флаговых волн (FlagWaveInterval)';

  @override
  String get waveGeneratorSpendingPoints =>
      'Начальные очки случайного призыва (WaveSpendingPoints)';

  @override
  String get waveGeneratorSpendingPointIncrement =>
      'Прирост очков за волну (WaveSpendingPointIncrement)';

  @override
  String get waveGeneratorSpendingCompatibilityWarning =>
      'Начальные очки случайного призыва превышают прирост очков за волну; это может привести к сбою при загрузке уровня.';

  @override
  String get waveGeneratorSpawnColumns =>
      'Диапазон колонок для зомби, появляющихся из-под земли';

  @override
  String get waveGeneratorRiseFromGround => 'Режим появления из-под земли';

  @override
  String get waveGeneratorRiseFromGroundHint =>
      'Если включено, зомби появляются из-под земли в указанных клетках вместо того, чтобы входить справа.';

  @override
  String get waveGeneratorIgnoreFlagCarriers => 'Игнорировать зомби с флагами';

  @override
  String get waveGeneratorIgnoreFlagCarriersHint =>
      'Отключить автоматических зомби с флагами при случайном призыве.';

  @override
  String get waveGeneratorWaveSpawnTime =>
      'Задержка появления волны (WaveSpawnTime)';

  @override
  String get waveGeneratorWaveSpawnTimeHint =>
      'Задержка в секундах перед началом появления этой волны после завершения предыдущей.';

  @override
  String get waveGeneratorZombieTargetValidTime =>
      'Время действия цели (TargetValidTime)';

  @override
  String get waveGeneratorZombieTargetValidTimeHint =>
      'Длительность в секундах, в течение которой этот зомби может быть поражён способностями.';

  @override
  String get waveGeneratorZombieRiseGridX => 'Колонка появления (Rise_GridX)';

  @override
  String get waveGeneratorZombieRiseGridXHint =>
      'Колонка, из которой зомби вылезает из-под земли. Используйте \'?\' для случайной.';

  @override
  String get waveGeneratorZombieRiseGridY => 'Ряд появления (Rise_GridY)';

  @override
  String get waveGeneratorZombieRiseGridYHint =>
      'Ряд, из которого зомби вылезает из-под земли. Используйте \'?\' для случайного.';

  @override
  String waveGeneratorWaveCountSummary(int count) {
    return 'Всего волн: $count';
  }

  @override
  String get waveGeneratorInitialPool =>
      'Начальный пул зомби (AddToZombiePool)';

  @override
  String get waveGeneratorEmptyPool => 'Начальный пул зомби пуст.';

  @override
  String get waveGeneratorCustomZombieBlocked =>
      'Здесь нельзя добавлять пользовательских зомби';

  @override
  String get waveGeneratorTabMissingModule =>
      'Добавьте модуль генератора волн, чтобы настроить здесь дополнительные группы.';

  @override
  String waveGeneratorTabSummary(int interval, int points, int increment) {
    return 'Флаговая волна каждые $interval волн · Начальные очки $points · Прирост $increment за волну';
  }

  @override
  String get waveGeneratorNoWaves => 'Волны ещё не настроены.';

  @override
  String waveGeneratorDeleteWaveConfirm(int count) {
    return 'Будут удалены эта волна и настроенные в ней объекты фиксированного призыва ($count).';
  }

  @override
  String get waveGeneratorEmptyWaveRow => 'Нет фиксированного призыва';

  @override
  String get waveGeneratorRandomSpawnsEnabled => 'Случайный призыв включён';

  @override
  String get waveGeneratorRandomSpawnsDisabled =>
      'Случайный призыв на этой волне отключён';

  @override
  String get waveGeneratorRandomZombiesLabel =>
      'Текущий пул случайного призыва';

  @override
  String get waveGeneratorWavePoolDisabled =>
      'На этой волне случайный призыв не выполняется, но изменения пула зомби вступают в силу с этой волны.';

  @override
  String get waveGeneratorDisableRandomSpawns =>
      'Отключить случайный призыв (DisableRandomSpawns)';

  @override
  String get waveGeneratorDisableRandomSpawnsHint =>
      'Пропускает только призыв за очки на этой волне. Количество очков продолжает расти с номером волны, а изменения пула сохраняются и влияют на последующие волны.';

  @override
  String get waveGeneratorWaitUntilAllDie =>
      'Создать эту волну после уничтожения всех зомби предыдущей волны (WaitUntilAllZombiesDie)';

  @override
  String get waveGeneratorNoScriptedZombies =>
      'На этой волне нет фиксированного призыва.';

  @override
  String get waveGeneratorSpawnPlantFood =>
      'Количество зомби с подкормкой (SpawnPlantFoodCount)';

  @override
  String get waveGeneratorWavePointStart =>
      'Очки случайного призыва текущей волны (WavePointStart)';

  @override
  String get waveGeneratorWavePointStartHint =>
      'Задаёт очки случайного призыва только для текущей волны. Оставьте поле пустым, чтобы использовать значение, рассчитанное по умолчанию.';

  @override
  String get waveGeneratorWavePointIncrement =>
      'Новый прирост очков (WavePointIncrement)';

  @override
  String get waveGeneratorWavePointIncrementHint =>
      'Изменяет прирост очков для последующих волн и действует только при заданных очках случайного призыва текущей волны (WavePointStart).';

  @override
  String get waveGeneratorWavePointIncrementInactiveHint =>
      'Без очков случайного призыва текущей волны (WavePointStart) этот параметр не действует, но сохранённое значение не удаляется.';

  @override
  String get waveGeneratorWavePointOverride =>
      'Сброс траектории очков (WavePointOverride)';

  @override
  String get waveGeneratorWavePointOverrideHint =>
      'Когда параметр отключён, очки случайного призыва текущей волны (WavePointStart) влияют только на эту волну, а следующая получает значение, рассчитанное по её исходному номеру. Когда параметр включён, очки текущей волны становятся новой начальной точкой для последующих волн. В обоих случаях используется текущий прирост очков.';

  @override
  String get waveGeneratorPointTrajectory => 'Предпросмотр траектории очков';

  @override
  String get waveGeneratorPointTrajectoryTemporary =>
      'Очки случайного призыва текущей волны влияют только на эту волну. Следующая волна получает значение, рассчитанное по её исходному номеру, и продолжает увеличиваться с действующим приростом.';

  @override
  String get waveGeneratorPointTrajectoryReset =>
      'Очки текущей волны становятся новой начальной точкой для последующих волн, которые продолжают увеличиваться с действующим приростом.';

  @override
  String waveGeneratorPointTrajectoryWaveValue(int wave, int points) {
    return 'Волна $wave · очки: $points';
  }

  @override
  String get waveGeneratorBlackHoleFieldHint =>
      'Укажите число столбцов, чтобы в конце этой волны появилась пространственно-временная чёрная дыра и сдвинула все растения вправо.\nЧёрная дыра появляется только в том случае, если эта волна не является последней и включён параметр «Создать эту волну после уничтожения всех зомби предыдущей волны (WaitUntilAllZombiesDie)».';

  @override
  String waveGeneratorBlackHoleWaveHint(int cols) {
    return 'В конце этой волны появляется пространственно-временная чёрная дыра и сдвигает растения на $cols столбцов вправо';
  }

  @override
  String get waveGeneratorCurrentPool => 'Текущий эффективный пул зомби';

  @override
  String get waveGeneratorCurrentPoolEmpty =>
      'Текущий эффективный пул зомби пуст.';

  @override
  String get waveGeneratorWavePoolAdd =>
      'Расширение пула на этой волне (AddToZombiePool)';

  @override
  String get waveGeneratorWavePoolNoChanges =>
      'На этой волне пул зомби не расширяется.';

  @override
  String get waveGeneratorWaveScreenSubtitle => 'Модуль генератора волн';

  @override
  String get waveGeneratorWaveScreenHelpTitle =>
      'Справка по модулю генератора волн';

  @override
  String get waveGeneratorWaveScreenHelpBody =>
      'Во время случайного призыва игра выбирает по весу одного из зомби, доступных за оставшиеся очки, вычитает его стоимость и снова фильтрует кандидатов, пока доступных зомби не останется. Неиспользованные очки не переносятся на следующую волну. Фиксированный спавн добавляется непосредственно в текущую волну и не расходует очки случайного спавна.';

  @override
  String get waveGeneratorRandomSpawnsSectionTitle => 'Случайный призыв';

  @override
  String get waveGeneratorZombiePoolSectionTitle => 'Пул зомби';

  @override
  String get waveGeneratorWaveSettingsTitle => 'Настройки волны';

  @override
  String get waveGeneratorFixedSpawnsHelpTitle =>
      'Раздел «Фиксированный призыв»';

  @override
  String get waveGeneratorRandomSpawnsHelpTitle => 'Раздел «Случайный призыв»';

  @override
  String get waveGeneratorZombiePoolHelpTitle => 'Раздел «Пул зомби»';

  @override
  String get waveGeneratorWaveSettingsHelpTitle => 'Раздел «Настройки волны»';

  @override
  String get waveGeneratorFixedSpawnsHelpBody =>
      'Фиксированный призыв добавляется непосредственно в текущую волну, не расходует очки случайного призыва и может использоваться одновременно с ним.';

  @override
  String get waveGeneratorPointTrajectoryHelpBody =>
      'Предпросмотр траектории показывает эффективные очки случайного призыва, рассчитанные редактором для каждой волны. Он не отражает количество объектов фиксированного призыва.';

  @override
  String get waveGeneratorWavePoolAddHelpBody =>
      'Зомби, добавленные на этой волне, сразу входят в эффективный пул и продолжают влиять на последующие волны. Добавление действует, даже если случайный призыв на этой волне отключён.';

  @override
  String get waveGeneratorPoolCompatibilityTitle => 'Ограничения типов';

  @override
  String get waveGeneratorPoolCompatibilityHelpBody =>
      'Пул генератора волн поддерживает только стандартные игровые типы зомби, но не пользовательских зомби, определённых в уровне.';

  @override
  String get waveGeneratorWaitUntilAllDieHelpBody =>
      'Определяет, должна ли эта волна дождаться уничтожения всех зомби предыдущей волны перед началом следующей.';

  @override
  String get waveGeneratorSpawnPlantFoodHelpBody =>
      'Задаёт количество зомби на этой волне, которые несут и оставляют подкормку.';

  @override
  String waveGeneratorFixedSummary(int count) {
    return 'Гарантированное появление зомби: $count';
  }

  @override
  String get waveGeneratorFixedSummaryEmpty => 'Нет фиксированного призыва';

  @override
  String waveGeneratorRandomSummary(int points) {
    return 'Включён · $points очков';
  }

  @override
  String waveGeneratorRandomLocalSummary(int points) {
    return 'Включён · $points очков · Очки текущей волны';
  }

  @override
  String get waveGeneratorRandomSummaryDisabled =>
      'На этой волне нет случайного призыва';

  @override
  String waveGeneratorPoolSummary(int current, int added) {
    return 'Текущих типов: $current · Добавлено: $added';
  }

  @override
  String waveGeneratorPoolSummaryNoAdditions(int current) {
    return 'Текущих типов: $current · Без расширения на этой волне';
  }

  @override
  String get waveGeneratorWaveSettingsDefaultSummary =>
      'Настройки по умолчанию';

  @override
  String waveGeneratorWaveSettingsPlantFoodSummary(int count) {
    return 'Подкормка ×$count';
  }

  @override
  String waveGeneratorWaveSettingsBlackHoleSummary(int cols) {
    return 'Пространственно-временная дыра · $cols столбцов';
  }

  @override
  String get waveGeneratorExpectationTapHint =>
      'Открыть статистический предпросмотр случайного спавна';

  @override
  String get waveGeneratorStatisticalPreview => 'Статистический предпросмотр';

  @override
  String get waveGeneratorExpectationEmpty =>
      'В пуле этой волны нет зомби, доступных для случайного призыва.';

  @override
  String get waveGeneratorExpectationPoolNote =>
      'Предпросмотр оценивает количество зомби с помощью повторных симуляций взвешенного выбора. Даже при одинаковом числе очков результат может меняться из-за порядка выбора, поэтому точно предсказать фактический призыв в игре невозможно.';

  @override
  String waveGeneratorExpectationTitle(int wave) {
    return 'Предпросмотр случайного призыва: волна $wave';
  }

  @override
  String waveGeneratorEffectiveRandomPoints(int points) {
    return 'Очки случайного призыва: $points';
  }

  @override
  String waveGeneratorFixedSpawnCount(int count) {
    return 'Фиксированный призыв: $count';
  }

  @override
  String get waveGeneratorFixedSpawns => 'Фиксированный призыв';

  @override
  String waveGeneratorPoolAddedCount(int count) {
    return 'Добавлено в пул на этой волне: $count';
  }

  @override
  String get waveGeneratorWaitStatus => 'Ожидание завершения предыдущей волны';

  @override
  String get waveGeneratorExpectationDisabled =>
      'Случайный призыв на этой волне отключён.';

  @override
  String waveGeneratorExpectationMissingData(String types) {
    return 'Невозможно рассчитать предпросмотр случайного призыва: у следующих зомби отсутствуют надёжные данные WavePointCost или Weight: $types';
  }

  @override
  String waveGeneratorExpectationEstimatedTotal(String count) {
    return 'Среднее количество зомби при случайном призыве: около $count';
  }

  @override
  String waveGeneratorExpectationCommonRange(int minimum, int maximum) {
    return 'Ожидаемый диапазон количества: $minimum–$maximum';
  }

  @override
  String waveGeneratorExpectationCostWeight(int cost, String weight) {
    return 'Стоимость $cost · Вес $weight';
  }

  @override
  String waveGeneratorExpectationAverageCount(String count) {
    return 'В среднем $count';
  }

  @override
  String get protectItems => 'Защита Объектов Лужайки';

  @override
  String get protectGridItemChallengeHelpTitle =>
      'Модуль на защиту определённых объектов лужайки';

  @override
  String get briefOverview => 'Обзор';

  @override
  String get automaticCount => 'Автоматическое кол-во';

  @override
  String get operationGuide => 'Подсказка по операции';

  @override
  String get protectGridItemChallengeHelpOverview =>
      'Расставьте объекты на сетку, которые надо защитить. Уровень будет считаться проигранным, если один из объектов будет уничтожен';

  @override
  String get protectGridItemChallengeHelpAutoCountBody =>
      'Редактор автоматически изменит число объектов, которые надо защитить в зависимости от ваших действий (добавления/удаления объектов)';

  @override
  String get protectGridItemChallengeHelpOperationGuide =>
      'Нажмите на клетку сетки, затем на \"Добавить объект\", чтобы выбрать защищаемый объект';

  @override
  String mustProtectCount(int count) {
    return 'Текущее количество целей для защиты: $count';
  }

  @override
  String get customStageProperties => 'Свойства пользовательской лужайки';

  @override
  String get customStageNotFound =>
      'Объект пользовательской лужайки не найден.';

  @override
  String get customStageSectionGeneral => 'Общие';

  @override
  String get customStageSectionZombies => 'Типы зомби';

  @override
  String get customStageSectionResourceGroups => 'Группы ресурсов';

  @override
  String get customStageSectionMusicAndOther => 'Вид газона, музыка и прочее';

  @override
  String get customStageSectionAdvanced => 'Дополнительно';

  @override
  String get customStageAlias =>
      'Псевдоним лужайки (только английские буквы; без пробелов)';

  @override
  String get customStageNoResourceGroups => 'В списке нет групп ресурсов';

  @override
  String get customStageMissingBackgroundWarning =>
      'Импортируйте хотя бы одну группу DelayLoad_Background из справочника локаций, иначе газон может отображаться полностью чёрным.';

  @override
  String get customStageEnableAmbient => 'Включить эмбиент';

  @override
  String get customStageDisabledCellsEmpty => 'Пусто';

  @override
  String get customStageDisabledCellsDefault => 'По умолчанию';

  @override
  String get customStageEnableSubmarine => 'Включить подлодку';

  @override
  String get customStageSubmarineHitpoints => 'Прочность подлодки';

  @override
  String get customStageBeachMinigame => 'Использовать мини-игровую версию';

  @override
  String get customStageOnePerLevelLimit =>
      'В этом уровне уже есть пользовательская лужайка. Удалите её, прежде чем добавлять другую.';

  @override
  String get selectStageBackground => 'Выберите вид лужайки';

  @override
  String get searchStageBackground => 'Поиск лужайки';

  @override
  String get noStageBackgroundFound => 'Вид лужайки не найден';

  @override
  String get stageBackgroundNeedMorePromptTitle => 'Нужен другой вид лужайки?';

  @override
  String get stageBackgroundNeedMorePromptMessage =>
      'Импортируйте группы ресурсов из другой лужайки, чтобы открыть здесь больше вариантов лужаек.';

  @override
  String get stageBackgroundAddFromStage => 'Добавить ещё вид лужайки';

  @override
  String get customStageNameSuffix => ' (Пользов.)';

  @override
  String get customStageLawnAppearance => 'Вид лужайки';

  @override
  String get customStageBaseStage => 'Базовая лужайка';

  @override
  String get selectCustomStageBase => 'Выберите базовую лужайку';

  @override
  String get noStageBaseFound => 'Лужайка не найдена';

  @override
  String get importResourceGroup => 'Импорт группы ресурсов';

  @override
  String get importResourceGroupGlobal => 'Из общего списка';

  @override
  String get importResourceGroupFromStage => 'Из лужайки';

  @override
  String get importResourceGroupSourceStage => 'Исходная лужайка';

  @override
  String get searchResourceGroup => 'Поиск группы ресурсов';

  @override
  String get noResourceGroupFound => 'Группа ресурсов не найдена';

  @override
  String get importResourceGroupsFromStageTitle =>
      'Добавить группы ресурсов из лужайки?';

  @override
  String importResourceGroupsFromStageMessage(String stageName) {
    return 'Будут добавлены следующие группы ресурсов из $stageName:';
  }

  @override
  String importResourceGroupsFromStageSkipped(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count групп ресурсов уже есть на этом уровне и будут пропущены.',
      many: '$count групп ресурсов уже есть на этом уровне и будут пропущены.',
      few: '$count группы ресурсов уже есть на этом уровне и будут пропущены.',
      one: '$count группа ресурсов уже есть на этом уровне и будет пропущена.',
    );
    return '$_temp0';
  }

  @override
  String get importResourceGroupsFromStageAllPresent =>
      'Все группы ресурсов из этой лужайки уже есть на этом уровне.';

  @override
  String get importResourceGroupsApplySourceLawnAppearance =>
      'Также использовать соответствующий вид лужайки';

  @override
  String get createCustomStage => 'Создать пользовательскую лужайку';

  @override
  String get createCustomStageHint =>
      'Выберите базовый вид лужайки и отредактируйте его локально в этом уровне.';

  @override
  String get customStageAliasPromptTitle =>
      'Псевдоним пользовательской лужайки';

  @override
  String get customStageAliasTaken =>
      'Этот псевдоним уже используется в этом уровне.';

  @override
  String get stageSelectionTabBuiltin => 'Встроенные';

  @override
  String get stageSelectionTabCustom => 'Пользовательские';

  @override
  String get customStageSelectionEmpty =>
      'В этом уровне пока нет пользовательской лужайки.';

  @override
  String get customStageSelectionInLevel => 'Пользовательские лужайки в уровне';

  @override
  String get customStageSwitchToBuiltinTitle =>
      'Переключиться на встроенную лужайку?';

  @override
  String get customStageSwitchToBuiltinMessage =>
      'Это навсегда удалит данные пользовательской лужайки из этого уровня. Отменить будет нельзя.';

  @override
  String get customStageDeleteTitle => 'Удалить пользовательскую лужайку?';

  @override
  String get customStageDeleteMessage =>
      'Это навсегда удалит данные пользовательской лужайки из этого уровня. Если она сейчас активна, уровень переключится на встроенную лужайку по умолчанию.';

  @override
  String get customStagePresetSectionTitle =>
      'Встроенные в редактор пользовательские лужайки';

  @override
  String get editCustomStage => 'Редактировать пользовательскую лужайку';

  @override
  String get startupLoadingLocalization => 'локализаций';

  @override
  String get startupLoadingStages => 'данных о лужайках';

  @override
  String get startupLoadingAudio => 'данных о музыке';

  @override
  String get startupLoadingGridItems => 'данных о препятствиях';

  @override
  String get startupLoadingZomboss => 'данных о боссах';

  @override
  String get startupLoadingReference => 'справочных данных';

  @override
  String get startupLoadingZombies => 'данных о зомби';

  @override
  String get startupLoadingPlants => 'данных о растениях';

  @override
  String get startupLoadingFish => 'данных о морских обитателях';

  @override
  String get startupLoadingImages => 'изображений';

  @override
  String get startupLoadingPlugins => 'плагинов';

  @override
  String startupLoadingCategoryProgress(String category) {
    return 'Загрузка $category...';
  }

  @override
  String get reselectFiles => 'Выбрать заново';

  @override
  String get validationReviewRequest =>
      'Пожалуйста, ознакомьтесь с результатами проверки выбранных уровней.';

  @override
  String get validationRecommendation =>
      'Рекомендуется отредактировать выбранные уровни для исправления ошибок или выбрать другие файлы.';

  @override
  String validationProgress(int current, int total) {
    return 'Проверка $current / $total';
  }

  @override
  String get invalid_rsb_version => 'Неверная версия RSB, должна быть 3 или 4';

  @override
  String get invalid_file_list_offset => 'Неверное смещение списка файлов';

  @override
  String get invalid_rsb_ver_3_resource_offset =>
      'Неверное смещение ресурса для RSB версии 3';

  @override
  String get invalid_composite_name => 'Неверное имя композита';

  @override
  String get out_of_range_1 => 'Выход за пределы диапазона poolIndex';

  @override
  String get out_of_range_2 => 'Выход за пределы диапазона индекса пакета';

  @override
  String get invalid_rsg_name => 'Неверное имя RSG';

  @override
  String get invalid_packet_width => 'Неверная ширина пакета';

  @override
  String get invalid_packet_height => 'Неверная высота пакета';

  @override
  String get invalid_item_packet => 'Неверный пакет элемента';

  @override
  String get invalid_rsg_number => 'Неверный индекс RSG';

  @override
  String get invalid_part2_offset => 'Неверное смещение Part2';

  @override
  String get invalid_head_length => 'Неверная длина заголовка';

  @override
  String get rsb_is_corrupted => 'Этот RSB поврежден';

  @override
  String get invalid_ptx_info_eachlength => 'Информация PTX неверна';

  @override
  String get invalid_end_offset => 'Неверное конечное смещение';

  @override
  String get invalid_rsb_head =>
      'Несоответствие магического числа RSB, должно начинаться с \"1BSR\"';

  @override
  String get invalid_ptx_info_each_length => 'Неверная информация PTX';

  @override
  String get category_out_of_length => 'Категория выходит за пределы длины';

  @override
  String get name_path_must_be_ascii =>
      'Путь имени должен соответствовать ASCII';

  @override
  String get invalid_rsg_magic =>
      'Неверное магическое число RSG, должно начинаться с \"PGSR\"';

  @override
  String get invalid_rsg_version => 'Неверная версия RSG, должна быть 3 или 4';

  @override
  String get invalid_rsg_compression_flag =>
      'Неверный флаг сжатия RSG, поддерживаются только от 0 до 3';

  @override
  String get mismatch_zlib_magic =>
      'Несоответствие магического числа PopCap Zlib, должно начинаться с 0xDEADFED4';

  @override
  String get customPortalAdd => 'Новый пользовательский портал';

  @override
  String get customPortalSingleName => 'Пользовательский портал';

  @override
  String customPortalName(int index) {
    return 'Пользовательский портал $index';
  }

  @override
  String get customPortalCreateTitle => 'Создать пользовательский портал';

  @override
  String get customPortalEditTitle => 'Изменить пользовательский портал';

  @override
  String get customPortalSelectBaseTitle => 'Выберите базовый портал';

  @override
  String get customPortalBlankTemplate => 'Пустой шаблон портала';

  @override
  String get customPortalBlankTemplateSubtitle =>
      'Стандартная структура портала без зомби.';

  @override
  String get customPortalBuiltInBases => 'Встроенные базовые порталы';

  @override
  String get customPortalUnusedTitle => 'Удалить неиспользуемый портал?';

  @override
  String get customPortalUnusedSingleMessage =>
      'Пользовательский портал больше не используется. Удалить связанные с ним объекты данных из уровня?';

  @override
  String customPortalUnusedMessage(int index) {
    return 'Пользовательский портал $index больше не используется. Удалить связанные с ним объекты данных из уровня?';
  }

  @override
  String get customPortalAppearanceSection => 'Внешний вид портала';

  @override
  String get customPortalSpawnSection => 'Появление зомби';

  @override
  String get customPortalWorld => 'Внешний вид мира';

  @override
  String get customPortalWorldTwister => 'Пусто';

  @override
  String get customPortalPopAnimation => 'Анимация портала';

  @override
  String get customPortalAnimationModern => 'Портал Современного Дня';

  @override
  String get customPortalAnimationMemoryLane => 'Портал Дороги Воспоминаний';

  @override
  String get customPortalAnimationHydra => 'Зеркало Зомбота Сказочного Леса';

  @override
  String get customPortalSpawnMethod => 'Способ появления зомби';

  @override
  String get customPortalSpawnMethodShuffled =>
      'Перемешанная последовательность';

  @override
  String get customPortalSpawnMethodInOrder => 'По порядку';

  @override
  String get customPortalSpawnMethodHydra =>
      'Случайный выбор Зомбота Сказочного Леса';

  @override
  String get customPortalZombieTypes => 'Доступные типы зомби';

  @override
  String get customPortalMinimumQuantity => 'Минимальное количество';

  @override
  String get customPortalMaximumQuantity => 'Максимальное количество';

  @override
  String get customPortalSpawnInterval => 'Интервал появления зомби';

  @override
  String get customPortalSpawnIntervalSubtitle =>
      'Необязательно задайте минимальное и максимальное время между появлениями зомби.';

  @override
  String get moduleTitle_MoonLifeSupportSystemProperties =>
      'Система жизнеобеспечения';

  @override
  String get moduleDesc_MoonLifeSupportSystemProperties =>
      'Настраивает запас энергии Лунной Базы и протоколы перегрузки';

  @override
  String get moduleTitle_LunarTerminalModuleProperties =>
      'Терминал добычи энергии';

  @override
  String get moduleDesc_LunarTerminalModuleProperties =>
      'Развёртывает добывающих роботов для сбора энергии кристаллов и повышения предела энергии';

  @override
  String get moduleTitle_LunarMineVeinModuleProperties => 'Кристалльные жилы';

  @override
  String get moduleDesc_LunarMineVeinModuleProperties =>
      'Размещает жилы лунных энергетических кристаллов и задаёт волны их роста';

  @override
  String get moduleTitle_RadiationMeteorModuleProperties =>
      'Исцеляющий метеорит';

  @override
  String get moduleDesc_RadiationMeteorModuleProperties =>
      'Обрушивает метеориты, уничтожающие сущностей на упавшей клетке и заражающие соседние';

  @override
  String get eventTitle_SpawnRocketLandingWaveActionProps =>
      'Приземление ракет';

  @override
  String get eventDesc_SpawnRocketLandingWaveActionProps =>
      'Создаёт в заданных позициях лунные ракеты, в которые можно посадить пакет семян или зомби';

  @override
  String get moonLifeSupportHelpTitle => 'Система жизнеобеспечения';

  @override
  String get moonLifeSupportHelpOverview =>
      'Экономическая система, часто используемая в уровнях Лунной Базы. После добавления этого модуля посадка растений не расходует солнце: вместо этого растения в реальном времени занимают часть запаса энергии системы жизнеобеспечения. Когда растение выкапывают лопатой, уничтожают зомби или оно исчезает из-за особой механики, весь занятый им запас немедленно возвращается.\nОбратите внимание, что этот модуль также не позволяет растениям 4-го уровня и выше автоматически использовать подкормку при посадке.';

  @override
  String get moonLifeSupportHelpProtocolsTitle => 'Протоколы перегрузки';

  @override
  String get moonLifeSupportHelpProtocols =>
      'Когда потребление энергии системы жизнеобеспечения превышает её начальный запас, система переходит в состояние перегрузки и включает протокол энергосбережения, снижая скорость атаки растений на поле и скорость перезарядки пакетов семян.\nКогда потребление энергии превышает (начальный запас энергии × требуемый коэффициент гибернации), после заданного отсчёта система принудительно включает протокол гибернации: все растения на поле впадают в спячку, а пакет семян и шкала космической подкормки блокируются и становятся недоступны.';

  @override
  String get moonLifeSupportHelpPlantFoodTitle => 'Независимая перезарядка';

  @override
  String get moonLifeSupportHelpPlantFood =>
      'Модуль содержит отдельный список растений с независимой перезарядкой. Время перезарядки растений из списка не зависит от протокола энергосбережения, но при протоколе гибернации их всё равно нельзя высаживать.';

  @override
  String get moonLifeSupportPowerSettings => 'Настройки энергии';

  @override
  String get moonInitialCapacity => 'Начальный запас энергии (InitialCapacity)';

  @override
  String get moonBufferOverloadRatio =>
      'Требуемый коэффициент гибернации (BufferOverloadRatio)';

  @override
  String get moonPenaltyCountdown =>
      'Отсчёт до гибернации (PenaltyCountdown, секунды)';

  @override
  String get moonPlantImmunityList =>
      'Растения с независимой перезарядкой (PlantImmunityList)';

  @override
  String get moonPlantImmunityListHint =>
      'Время перезарядки растений из списка не зависит от протокола энергосбережения, но при протоколе гибернации их всё равно нельзя высаживать.';

  @override
  String get moonSelectImmunePlants =>
      'Выбрать растения для добавления в список';

  @override
  String get lunarTerminalHelpTitle => 'Терминал добычи энергии';

  @override
  String get lunarTerminalHelpOverview =>
      'Артефакт, часто используемый в уровнях Лунной Базы. Он занимает постоянную позицию на поле, как пушка Небесного города. После нажатия на терминал сбора энергии можно выбрать одного из трёх добывающих роботов и перетащить его на поле. Роботы автоматически собирают энергию лунных энергетических кристаллов и исцеляющих метеоритов в пределах досягаемости, навсегда увеличивая доступный в этом уровне запас энергии системы жизнеобеспечения и позволяя сажать больше растений. У роботов есть здоровье; зомби, исцеляющие метеориты и другие цели могут атаковать и уничтожать их.';

  @override
  String get lunarTerminalHelpFixedTitle => 'Перезарядка развёртывания';

  @override
  String get lunarTerminalHelpFixed =>
      'После каждого развёртывания робота терминал сбора лунной энергии уходит на перезарядку. Её длительность можно настроить в уровне.';

  @override
  String get lunarTerminalCollectorCooldown =>
      'Перезарядка развёртывания робота (CollectorCooldown, секунды)';

  @override
  String get lunarMineVeinHelpTitle => 'Кристалльные жилы';

  @override
  String get lunarMineVeinHelpOverview =>
      'В начале уровня размещает на поле жилы лунных энергетических кристаллов, часто встречающиеся на Лунной Базе. Изначально жилы не дают энергии. На заданной волне на их месте вырастают кристаллы соответствующего типа, которые можно добывать с учётом их свойств. Выберите тип жилы и нажмите на клетку для размещения. Для удаления нажмите правой кнопкой мыши или используйте долгое нажатие на мобильном устройстве.';

  @override
  String get lunarMineVeinTypePalette => 'Тип кристаллической жилы';

  @override
  String get lunarMineVeinHelpHardened =>
      'Защищена прочной внешней оболочкой из камня. Прежде чем начать обычную добычу, оболочку нужно разрушить атаками растений. Такая жила всегда создаёт кристалл с прочной оболочкой, имеющий 3000 единиц здоровья.';

  @override
  String get lunarMineVeinHelpFragile =>
      'Добыча непрерывно расходует прочность кристалла, пока он не расколется. Также можно разместить особые хрупкие кристаллические жилы, содержащие космическую подкормку.';

  @override
  String get lunarMineVeinHelpRadiation =>
      'Периодически испускает радиацию во все стороны. Облучённые растения случайным образом превращаются в другие растения, а зомби получают урон или мутируют в Космического Радиационного Гаргантюа. Космические Радиационные Гаргантюа обладают огромным запасом здоровья и при гибели также облучают ближайшие растения и зомби.';

  @override
  String get lunarMineVeinHelpWaveTitle => 'Нумерация волн';

  @override
  String get lunarMineVeinHelpWave =>
      'Волна роста (EmergenceWave) нумеруется с 1: для роста на первой волне укажите 1, на второй — 2 и так далее.';

  @override
  String get lunarMineVeinPlacements => 'Размещение жил (VeinPlacements)';

  @override
  String get lunarMineVeinModuleExpectationLabel => 'Кристалльные жилы';

  @override
  String get lunarMineVeinModulePreviewEmerging =>
      'Лунные кристаллы, появляющиеся на этой волне:';

  @override
  String get lunarMineEmergenceWave =>
      'Волна роста (EmergenceWave, нумерация с 1)';

  @override
  String get moonPlacementGestureHint =>
      'Нажмите пустую клетку, чтобы добавить объект. Щёлкните правой кнопкой или удерживайте занятую клетку, чтобы удалить его.';

  @override
  String get moduleTitle_GladiatorRowModuleProperties => 'Гладиаторский ряд';

  @override
  String get moduleDesc_GladiatorRowModuleProperties =>
      'Временно изолирует пять клеток ряда; исход поединка определяет награду или наказание';

  @override
  String get gladiatorSettings =>
      'Общие настройки поединков, наград и наказаний';

  @override
  String get gladiatorArenaDuration =>
      'Длительность поединка (ArenaDuration, секунды)';

  @override
  String get gladiatorRewardCount =>
      'Награда подкормкой (PlantWinPlantfoodCount)';

  @override
  String get gladiatorPunishmentCount =>
      'Число штрафных клеток с зомби (ZombieWinPunishmentCageCount)';

  @override
  String get gladiatorPunishmentDuration =>
      'Длительность штрафного десанта (ZombieWinPunishmentDuration, секунды)';

  @override
  String get gladiatorPunishmentLevel =>
      'Уровень зомби наказания (ZombieWinPunishmentZombieLevel)';

  @override
  String get gladiatorEncounters => 'Расписание поединков (Encounters)';

  @override
  String get gladiatorAddEncounter => 'Добавить поединок';

  @override
  String get gladiatorRemoveEncounter => 'Удалить текущий поединок';

  @override
  String get gladiatorWave => 'Волна запуска (Wave, отсчёт с 0)';

  @override
  String get gladiatorRow => 'Ряд (Row, отсчёт с 0)';

  @override
  String get gladiatorWarningDuration =>
      'Предупреждение перед появлением Зомбосса (WarningDuration, секунды)';

  @override
  String get gladiatorFirstCageDelay =>
      'Задержка сброса первой клетки (FirstCageDelay, секунды)';

  @override
  String get gladiatorPreviewTitle => 'Предпросмотр области поединка';

  @override
  String get gladiatorPreviewLegend =>
      'Зелёная клетка обозначает кубок, закреплённый в столбце 5; красные — остальные клетки арены. Значки зомби показывают позиции сброса клеток, а число на клетке — количество зомби. Нажмите на сетку, чтобы выбрать ряд.';

  @override
  String get gladiatorSpawns => 'Расписание высадки из клеток (Spawns)';

  @override
  String get gladiatorAddSpawn => 'Добавить высадку';

  @override
  String get gladiatorSpawnTime =>
      'Задержка появления после начала поединка (Time, секунды)';

  @override
  String get gladiatorSpawnColumn => 'Столбец появления (GridX, отсчёт с 0)';

  @override
  String get gladiatorSpawnCount => 'Количество зомби (Count)';

  @override
  String get gladiatorSpawnInterval => 'Интервал появления (Interval, секунды)';

  @override
  String get gladiatorSpawnLevel => 'Уровень зомби (Level)';

  @override
  String get gladiatorPunishmentPool =>
      'Пул зомби за поражение (ZombieWinPunishmentZombiePool)';

  @override
  String get gladiatorPunishmentHint =>
      'После поражения штрафные клетки выбирают зомби из этого списка по весам. Чем больше вес, тем выше шанс выбора.';

  @override
  String get gladiatorAddPunishment => 'Добавить штрафного зомби';

  @override
  String get gladiatorWeight => 'Вес появления (Weight)';

  @override
  String get gladiatorCompatibilityWarningTitle =>
      'Предупреждение о совместимости модулей';

  @override
  String get gladiatorWaveGeneratorCompatibilityWarning =>
      'Гладиаторский ряд не работает с Генератором волн. Используйте Менеджер волн.';

  @override
  String get gladiatorUnderwaterMismatchWarning =>
      'Текущая лужайка использует шестирядный облик Подводного мира. Гладиаторский ряд на ней не появится. Используйте лужайку с пятью рядами.';

  @override
  String get gladiatorLegacyModeWarning =>
      'В этом модуле режим поединка с кубком (GameplayVersion: 1) не включён явно. Версия 0 — устаревший режим поединка. Предпросмотр области поддерживает только режим с кубком; включить его можно в редакторе модуля.';

  @override
  String get gladiatorUseTrophyMode => 'Использовать режим с кубком';

  @override
  String get gladiatorHelpTipsTitle => 'Полезные советы';

  @override
  String get gladiatorHelpOverview =>
      'Этот модуль настраивает механизм «Гладиаторский ряд», который запускается на заданных волнах и часто встречается в тайном мире «Римская слава». На указанной волне римский Зомбосс появляется в выбранном ряду и временно перекрывает пять соседних клеток. Растения и зомби внутри уничтожаются, а растения и зомби снаружи прекращают двигаться и действовать.\nВ центре арены поднимается кубок. Зомби прибывают в клетках, сбрасываемых справа. Защитите кубок до окончания отсчёта, чтобы победить. Победа приносит много подкормки; при поражении на лужайку сбрасываются клетки с большим количеством зомби. После поединка растения и зомби, оставшиеся внутри арены, уничтожаются.';

  @override
  String get gladiatorHelpUsage =>
      'Длительность поединка, количество подкормки за победу и параметры сброса при поражении сверху, а также список зомби наказания и их веса снизу являются общими настройками для всех поединков модуля. Нажмите «Добавить поединок», чтобы настроить отдельный поединок. Wave, Row и GridX нумеруются с 0: Wave 0 соответствует волне 1 на временной шкале, а Wave 4 — волне 5.';

  @override
  String get gladiatorHelpTips =>
      'Во время поединка посадка растений не расходует солнце, но по-прежнему требует энергии.\nМгновенно убивающие атаки Гаргантюа и подобных зомби не повреждают кубок.\nСнаряды растений, вылетающие за пределы арены, задерживаются ограждениями. Зомби, покинувшие арену, а также зомби, чьи отдельные способности нацелены за её пределы, замирают. После окончания отсчёта они освобождаются и продолжают наступление.\nГладиаторский ряд не появляется на шестирядных лужайках с обликом Подводного мира, таких как «20 000 лье под водой» или «Атлантида».\nНовые модули используют режим поединка с кубком (GameplayVersion 1). Версия 0 — устаревший режим.\nГладиаторский ряд не работает с Генератором волн. Используйте Менеджер волн.';

  @override
  String get radiationMeteorHelpTitle => 'Исцеляющий метеорит';

  @override
  String get radiationMeteorHelpOverview =>
      'На заданных волнах обрушивает особые исцеляющие метеориты, часто встречающиеся на Лунной Базе. Перед падением метеорита в уровне появляется красное предупреждение, а предполагаемая клетка падения отмечается прицелом. По окончании заданного времени предупреждения метеорит падает вертикально, мгновенно уничтожает всех в клетке приземления, а затем медленно заражает соседние клетки по часовой стрелке.\nЗомби на заражённых клетках получают прибавку к скорости передвижения и восстановлению здоровья, а космические растения непрерывно получают урон.';

  @override
  String get radiationMeteorHelpWaveTitle => 'Нумерация волн';

  @override
  String get radiationMeteorHelpWave =>
      'Волны падения исцеляющих метеоритов нумеруются с 0: для первой волны укажите 0, для второй — 1 и так далее. При добавлении групп в редакторе группа 1 по умолчанию получает значение 0, группа 2 — 1 и так далее.';

  @override
  String get radiationMeteorHelpMiningTitle => 'Уничтожение добычей';

  @override
  String get radiationMeteorHelpMining =>
      'Устройства сбора лунной энергии могут добывать исцеляющие метеориты и через некоторое время уничтожать их. После уничтожения метеорита терминал навсегда повышает доступный в этом уровне запас энергии игрока и устраняет эффект заражения.';

  @override
  String get radiationMeteorParameters => 'Параметры метеорита';

  @override
  String get radiationMeteorWarningDuration =>
      'Длительность предупреждения (WarningDuration, секунды)';

  @override
  String get radiationMeteorPollutionInterval =>
      'Интервал распространения исцеляющей жидкости (PollutionInterval, секунды)';

  @override
  String get radiationMeteorMiningDuration =>
      'Время добычи (MiningDurationRequired, секунды)';

  @override
  String get radiationMeteorPowerReward =>
      'Награда энергией (PowerRewardOnDestroy)';

  @override
  String get radiationMeteorSpawnSchedule => 'Порядок падения (SpawnSchedule)';

  @override
  String get radiationMeteorWave => 'Волна (Wave, нумерация с 0)';

  @override
  String get radiationMeteorModuleExpectationLabel => 'Исцеляющий метеорит';

  @override
  String get radiationMeteorModulePreviewLanding =>
      'Метеориты, падающие на этой волне:';

  @override
  String get eventTitle_GravityGeneratorWaveActionProps =>
      'Генератор гравитации';

  @override
  String get eventDesc_GravityGeneratorWaveActionProps =>
      'Применяет разные состояния гравитации к растениям или клеткам';

  @override
  String get gravityLevel => 'Состояние гравитации (GravityLevel)';

  @override
  String get gravityAnti => 'Антигравитация';

  @override
  String get gravityHeavy => 'Гипергравитация';

  @override
  String get gravityTargetType => 'Тип цели (TargetType)';

  @override
  String get gravityTargetPlant => 'Случайное растение';

  @override
  String get gravityTargetGrid => 'Заданная клетка';

  @override
  String get gravityRangeX => 'Смещение по горизонтали (Range.mX)';

  @override
  String get gravityRangeY => 'Смещение по вертикали (Range.mY)';

  @override
  String get gravityRangeWidth => 'Ширина области (Range.mWidth, клеток)';

  @override
  String get gravityRangeHeight => 'Высота области (Range.mHeight, клеток)';

  @override
  String get gravityTargetX => 'Столбец цели (TargetGrid.mX, с 0)';

  @override
  String get gravityTargetY => 'Строка цели (TargetGrid.mY, с 0)';

  @override
  String get gravityPreviewTitle => 'Предпросмотр области действия гравитации';

  @override
  String get gravityPlantRangeHint =>
      'Случайное растение на лужайке служит опорной точкой. Эффект действует на растения и зомби в заданной области. Крест отмечает выбранное растение. Область начинается с учётом смещения и простирается вправо и вниз, включая начальную клетку. Отрицательные смещения сдвигают начало влево или вверх.';

  @override
  String get gravityGridRangeHint =>
      'Ряды и столбцы нумеруются с 0. Нажмите на сетку, чтобы выбрать опорную клетку. Начало области определяется этой клеткой и смещениями по горизонтали и вертикали. Область простирается вправо и вниз; ширина и высота включают начальную клетку. При нулевых смещениях ширина 3 и высота 1 охватывают выбранную клетку и две клетки справа.';

  @override
  String get gravityCenterLegend => 'Крест: опорная точка';

  @override
  String get gravityRestrictions =>
      'Растения и зомби, на которых эффект не действует (TargetRestriction)';

  @override
  String get gravityRestrictionHint =>
      'Растения и зомби из этого списка не подвержены действию гравитационного поля. Пустой список не исключает дополнительные типы.';

  @override
  String get gravityAddPlantRestriction => 'Добавить невосприимчивые растения';

  @override
  String get gravityAddZombieRestriction => 'Добавить невосприимчивых зомби';

  @override
  String get gravityAdvancedSettings => 'Параметры действий и времени';

  @override
  String get gravityActivationDelay =>
      'Задержка активации (ActivationDelay, сек.)';

  @override
  String get gravityDuration =>
      'Длительность состояния гравитации (Duration, секунды)';

  @override
  String get gravityDeployDuration =>
      'Время развёртывания устройства (DeployDuration, секунды)';

  @override
  String get gravityChargeDuration =>
      'Зарядка перед применением гравитации (ChargeDuration, секунды)';

  @override
  String get gravityRetractDuration =>
      'Время возврата и перезарядки устройства (RetractDuration, секунды)';

  @override
  String get gravityPlantExitDelay =>
      'Время до исчезновения парящего растения (PlantExitDelay, секунды)';

  @override
  String get gravityZombieRiseDuration =>
      'Время подъёма зомби (ZombieRiseDuration, секунды)';

  @override
  String get gravityZombieTranslateDuration =>
      'Время перемещения зомби в воздухе (ZombieTranslateDuration, секунды)';

  @override
  String get gravityZombieFallDuration =>
      'Время приземления зомби в конечной точке (ZombieFallDuration, секунды)';

  @override
  String get gravityZombieLiftHeight =>
      'Высота подъёма зомби (ZombieLiftHeight)';

  @override
  String get gravityZombieForwardDistance =>
      'Дальность движения зомби (ZombieForwardDistance, 64 пикселя = 1 клетка)';

  @override
  String get gravityHeavyPlantSinkDuration =>
      'Время погружения растения (HeavyPlantSinkDuration, сек.)';

  @override
  String get gravityHelpParametersTitle => 'Описание параметров';

  @override
  String get gravityHelpParameters =>
      'По умолчанию событие содержит все параметры для антигравитации и гипергравитации. В настройках действий отображаются только параметры выбранного режима. При переключении значения другого режима сохраняются.';

  @override
  String get gravityHelpTipsTitle => 'Полезный совет';

  @override
  String get gravitySequentialNotice =>
      'События генератора гравитации не могут выполняться одновременно. Предыдущая последовательность антигравитации или гипергравитации должна завершиться до следующей. Разносите время запуска событий.';

  @override
  String get gravityHelpOverview =>
      'Устройство на базе зомби, которое активируется как заранее заданное событие на указанной волне. Выдвинувшись из базы, оно захватывает растения или зомби в заданной области и выпускает гравитационный луч, изменяя их состояние гравитации и нарушая ритм атак растений и передвижение зомби.';

  @override
  String get gravityHelpAnti =>
      'Выбранные растения медленно поднимаются и через некоторое время улетают с поля боя. Выбранные зомби поднимаются и перемещаются вперёд, получая в воздухе иммунитет к прямолинейным выстрелам.\nЕсли растение под действием антигравитации находится в радиусе атаки Гравидрева, Гравидрево атакует и снимает антигравитацию с растений в своём радиусе. Само Гравидрево невосприимчиво к генератору гравитации: его нельзя поднять в воздух или вдавить в землю.';

  @override
  String get gravityHelpHeavy =>
      'Выбранные растения наполовину вдавливаются в землю. В этом состоянии они не могут атаковать, но зомби по-прежнему могут их есть. Выбранные зомби уверенно движутся вперёд и становятся невосприимчивыми к отбрасыванию.\nКосмическая Тарелка снимает гипергравитацию с зомби и переводит их в состояние парения. Она также снимает гипергравитацию с растений, возвращая их в нормальное состояние.';

  @override
  String get rocketLandingHelpTitle => 'Приземление раке';

  @override
  String get rocketLandingHelpOverview =>
      'Событие, часто используемое на Лунной Базе. Оно создаёт ракеты в заданных позициях как цели, за которые борются растения и зомби.';

  @override
  String get rocketLandingHelpPlantsTitle => 'Захват растениями';

  @override
  String get rocketLandingHelpPlants =>
      'Посадите подходящее космическое растение в ракету. Через некоторое время ракета взлетит, наведётся на опасного зомби на поле и нанесёт ему огромный урон. Космический горох выпускает рикошетящие космические снаряды; Космический гриб создаёт грибные червоточины в области; Космический орех создаёт небольшую кратковременную чёрную дыру, которая притягивает ближайших зомби и непрерывно наносит им урон.';

  @override
  String get rocketLandingHelpZombiesTitle => 'Захват зомби';

  @override
  String get rocketLandingHelpZombies =>
      'Вошедший в ракету зомби после запуска переносится в клетку ближе к тылу. Некоторые зомби не могут входить в ракеты.';

  @override
  String get rocketLandingSettings => 'Настройки ракеты';

  @override
  String get rocketPoolCount => 'Количество ракет (Count)';

  @override
  String get rocketSpawnCount =>
      'Общее количество создаваемых объектов (SpawnCount)';

  @override
  String get rocketSpawnInterval =>
      'Интервал появления (SpawnInterval, секунды)';

  @override
  String get moduleTitle_LevelPowerupModuleProperties => 'Усиления';

  @override
  String get moduleDesc_LevelPowerupModuleProperties =>
      'Включает три способности: прижим, смахивание и электризацию';

  @override
  String get powerUpsHelpTitle => 'Усиления';

  @override
  String get powerUpsHelpOverview =>
      'Эта механика триумфально вернулась в Реалме 13-й годовщины и позволяет уничтожать зомби особыми способностями, пока действует усиление. После включения модуля можно задать точное число бесплатных применений каждой способности на уровне. Обратите внимание: Power Snow и Power Flame из международной версии отсутствуют в китайской версии.';

  @override
  String get powerUpsAddTitle => 'Добавить способность';

  @override
  String get powerUpsOrder => 'Порядок';

  @override
  String get powerUpsOrderInfo =>
      'Способности появляются в игре в указанном здесь порядке. Перетаскивайте маркеры ⋮⋮, чтобы изменить порядок. Удалённая из списка способность не появится в игре; при необходимости её можно снова добавить в этом модуле.';

  @override
  String get powerUpsFreeUseCount => 'Бесплатные применения (FreeUseCount)';

  @override
  String get powerZap => 'Электризация';

  @override
  String get powerZapInfo =>
      'Ведите пальцем, управляя электрическим зарядом, непрерывно наносящим урон всем задетым зомби.';

  @override
  String get powerToss => 'Смахивание';

  @override
  String get powerTossInfo =>
      'Быстро свайпайте пальцем по зомби, чтобы подбросить его в воздух. Повторный свайп полностью выбросит его с поля.';

  @override
  String get powerPinch => 'Прижим';

  @override
  String get powerPinchInfo =>
      'Сведите два пальца на зомби, словно ножницы, чтобы отрезать ему голову и быстро устранить угрозу.';

  @override
  String get moduleTitle_StatueMazeModuleProperties => 'Лабиринт статуй';

  @override
  String get moduleDesc_StatueMazeModuleProperties =>
      'Мини-игра «Лабиринт статуй» — нужно нажимать на правильные статуи в сетке, которая вращается';

  @override
  String get moduleHelpStatueMazeOverviewBody =>
      'Модуль «Лабиринт статуй» добавляет мини-игру с вращающейся сеткой. Каждый раунд представляет лужайку со статуями, которые вращаются, и игрок должен успеть нажать на правильные, пока не закончилось время.';

  @override
  String get moduleHelpStatueMazeSetsBody =>
      'Каждый набор определяет один раунд пазла. Можно добавить несколько раундов с разными размерами сетки, временными ограничениями и целевыми количествами.';

  @override
  String get moduleHelpStatueMazeTilesBody =>
      'Тип «c» — правильная клетка, на которую нужно нажать. Тип «ac» — целевая клетка. WaitDuration — пауза между вращениями, RotateTime — длительность каждого вращения.';

  @override
  String statueMazeSet(int index) {
    return 'Набор $index';
  }

  @override
  String get statueMazeMatrixSize => 'Размер сетки (MatrixSize)';

  @override
  String get statueMazeDisplayTime => 'Время показа (секунды)';

  @override
  String get statueMazeTargetNum => 'Целевое количество (TargetNum)';

  @override
  String get statueMazeBonusLife => 'Бонусная жизнь (BonusLife)';

  @override
  String get statueMazeTileType => 'Тип клетки';

  @override
  String get statueMazeTileTypeCorrect => 'Правильная (c)';

  @override
  String get statueMazeTileTypeAllCorrect => 'Все правильные (ac)';

  @override
  String get statueMazeWaitDuration => 'Время ожидания (секунды)';

  @override
  String get statueMazeRotateTime => 'Время вращения (секунды)';

  @override
  String get statueMazeAddSet => 'Добавить набор';

  @override
  String get statueMazeRemoveSet => 'Удалить набор';

  @override
  String get statueMazeAddTile => 'Добавить клетку';

  @override
  String get statueMazeRemoveTile => 'Удалить клетку';

  @override
  String get statueMazeTiles => 'Клетки';

  @override
  String get statueMazeSets => 'Наборы';

  @override
  String get statueMazeRotations => 'Вращения';

  @override
  String get statueMazeGridSize => 'Размер сетки';

  @override
  String get statueMazeNoRotations => 'Вращения не добавлены';

  @override
  String get statueMazePlay => 'Воспроизвести вращение';

  @override
  String get statueMazePlaying => 'Воспроизведение...';

  @override
  String get statueMazeStop => 'Стоп';

  @override
  String get moduleHelpStatueMazeRotationsBody =>
      'Each rotation step spins the entire grid. \"c\" is clockwise, \"ac\" is anti-clockwise. WaitDuration is the pause before the rotation starts, RotateTime is how long the spin takes.';

  @override
  String get statueMazeRotationsHint =>
      'Нажмите стрелку, чтобы сменить направление. Нажмите карточку, чтобы изменить время ожидания и вращения. Длительное нажатие — удалить.';

  @override
  String get statueMazeRemoveRotationConfirm => 'Удалить этот шаг вращения?';

  @override
  String get moduleTitle_CamelMinigameProperties =>
      'Карточная игра «Память верблюдов»';

  @override
  String get moduleDesc_CamelMinigameProperties =>
      'Мини-игра «Память верблюдов» — нужно собирать одинаковые пары верблюдов, переворачивая их';

  @override
  String get moduleHelpCamelOverviewBody =>
      'Мини-игра «Память верблюдов» размещает цепочки зомби на газоне. Зомби вылезают из-под земли, а игрок должен успеть найти пары, переворачивая верблюдов.';

  @override
  String get moduleHelpCamelTimingsBody =>
      'CardMatchTime — задержка после успешного совпадения. CardMatchingTime — длительность анимации переворота. CardNoMatchTime — время простоя после неудачного совпадения или одиночного переворота.';

  @override
  String get moduleHelpCamelSpawningBody =>
      'MinSpawnXStart / MinSpawnXEnd определяют горизонтальный диапазон появления новых цепочек карт. MaxSpawnX — крайняя правая координата (столбец 1 = 0). AdditionalXBufferBetweenChains сдвигает последующие цепочки вправо, если на месте уже есть зомби.';

  @override
  String get camelAdditionalXBuffer =>
      'Буфер X цепочки (AdditionalXBufferBetweenChains)';

  @override
  String get camelRiseStagger => 'Задержка между верблюдами (секунды)';

  @override
  String get camelCardMatchTime =>
      'Задержка после совпадения (CardMatchTime, с)';

  @override
  String get camelCardMatchingTime => 'Время переворота (CardMatchingTime, с)';

  @override
  String get camelCardNoMatchTime =>
      'Простой после неудачи (CardNoMatchTime, с)';

  @override
  String get camelCardTypesUsed => 'Типы карт (1-7)';

  @override
  String get camelTutorialRiseDelay => 'Задержка учебного зомби (с)';

  @override
  String get camelMaxSpawnX => 'Макс. X появления';

  @override
  String get camelMinSpawnXEnd => 'Мин. X конец';

  @override
  String get camelMinSpawnXStart => 'Мин. X начало';

  @override
  String get camelShowTutorial => 'Показать обучение';

  @override
  String get moduleTitle_OakTrainProperties => 'Тренирока Дубопня';

  @override
  String get moduleDesc_OakTrainProperties =>
      'Мини-игра Тренирока Дубопня — нужно отстреливаться от волн зомби, с помощью Дубопня';

  @override
  String get moduleHelpOakTrainOverviewBody =>
      'Мини-игра «Тренирока Дубопня» в ней вам выдают уже посаженного Дубопня. Волны зомби наступают и игрок должен набирать очки, уничтожая их. У Дубопня есть определенный запас HP; зелья лечения и усиленные стрелы восполняются по таймеру.';

  @override
  String get moduleHelpOakTrainScoresBody =>
      'ArrowScore — базовые очки атаки. WizardScore, ArchmageScore и BossScore — бонусные очки за уничтожение определённых типов зомби.';

  @override
  String get moduleHelpOakTrainArrowsBody =>
      'ArrowPowerNum — количество усиленных стрел за определенный период. ArrowMultipleNum — количество разделяющихся стрел за определенный период. HealNum — количество HP, восстанавливаемых зельем.';

  @override
  String get oakTrainTotalLife => 'Общее HP (TotalLife)';

  @override
  String get oakTrainArrowScore => 'Очки базовой атаки (ArrowScore)';

  @override
  String get oakTrainWizardScore => 'Очки за волшебника (WizardScore)';

  @override
  String get oakTrainArchmageScore => 'Очки за архимага (ArchmageScore)';

  @override
  String get oakTrainBossScore => 'Очки за босса (BossScore)';

  @override
  String get oakTrainHealNum => 'Восстановление HP (HealNum)';

  @override
  String get oakTrainArrowPowerNum =>
      'Усиленные стрелы за определенный период (ArrowPowerNum)';

  @override
  String get oakTrainArrowMultipleNum =>
      'Разделяющиеся стрелы за определенный период (ArrowMultipleNum)';

  @override
  String get oakTrainInitArrowsNum =>
      'Начальные стрелы (Обычные, Усиленные, Разделяющиеся)';

  @override
  String get oakTrainInitArrowNormal => 'Обычные стрелы';

  @override
  String get oakTrainInitArrowPower => 'Усиленные стрелы';

  @override
  String get oakTrainInitArrowSplit => 'Разделяющиеся стрелы';

  @override
  String get oakTrainInitArrowUnused => 'Unused';

  @override
  String get moduleTitle_OakTrainIntroProperties => 'Обучение Дубопня»';

  @override
  String get moduleDesc_OakTrainIntroProperties =>
      'Вступительная анимация мини-игры «Тренирока Дубопня»';

  @override
  String get moduleTitle_GoldRoadProperties => 'Золотая дорога';

  @override
  String get moduleDesc_GoldRoadProperties =>
      'Мини-игра из Затерянного города, где первая и последняя линии лужайки заблокированы для посадки';

  @override
  String get goldRoadNonLostCityLawnWarningTitle =>
      'Лужайка не из Затерянного города';

  @override
  String get goldRoadNonLostCityLawnWarning =>
      '«Золотая дорога» предназначена для лужайки Затерянного города. Не рекомендуется использовать этот модуль на других лужайках, так как это плохо скажется на внешнем виде уровня.';

  @override
  String get goldRoadDeepseaLawnWarningTitle => 'Несовместимая лужайка';

  @override
  String get goldRoadDeepseaLawnWarning =>
      '«Золотая дорога» работает некорректно с лужайками подводного мира. Вместо блокировки первой и последней линии лужайки блокируются первая и пятая.';

  @override
  String get goldRoadCustomLostCityLawnWarningTitle =>
      'Неродная лужайка Затерянного города';

  @override
  String get goldRoadCustomLostCityLawnWarning =>
      '«Золотая дорога» предназначена для родной лужайки Затерянного города. Ваш уровень использует пользовательскую лужайку с ресурсами Затерянного города. Это всё равно может повлиять на внешний вид уровня. Используйте этот модуль с осторожностью.';
}
