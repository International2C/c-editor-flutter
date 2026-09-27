// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Chinese (`zh`).
class AppLocalizationsZh extends AppLocalizations {
  AppLocalizationsZh([String locale = 'zh']) : super(locale);

  @override
  String get error => '错误';

  @override
  String get warning => '警告';

  @override
  String get info => '信息';

  @override
  String get success => '成功';

  @override
  String get previewTabPlants => '植物';

  @override
  String get previewTabZombies => '僵尸';

  @override
  String get previewTabGridItems => '物品';

  @override
  String get overviewPresetPlants => '预选植物';

  @override
  String get overviewPresetZombies => '预选僵尸';

  @override
  String get overviewConveyorPlants => '传送带植物';

  @override
  String get overviewLawn => '草坪';

  @override
  String get overviewWhitelist => '白名单';

  @override
  String get overviewBlacklist => '黑名单';

  @override
  String get overviewPlantBlacklist => '植物黑名单';

  @override
  String get overviewZombieWhitelist => '僵尸白名单';

  @override
  String get overviewSeedChooser => '自选种子';

  @override
  String get overviewReservedColumns => '预留列数';

  @override
  String get sunBombFalling => '阳光炸弹';

  @override
  String get sunDroppingActive => '天降阳光：有';

  @override
  String get sunDroppingInactive => '天降阳光：无';

  @override
  String get conveyorChanges => '传送带变动';

  @override
  String get willBeAdded => '将添加';

  @override
  String get willBeRemoved => '将移除';

  @override
  String get waveNumberLegend => '数字表示波次编号';

  @override
  String get expand => '展开';

  @override
  String get allZombiesInLevel => '本关所有僵尸';

  @override
  String get allObjectsInLevel => '本关所有物品';

  @override
  String get allEventsInLevel => '本关所有事件';

  @override
  String get overwhelmLabel => '排山倒海';

  @override
  String get fastEntryLabel => '快速入场';

  @override
  String get zombieRushLabel => '关卡倒计时';

  @override
  String get spermWhaleLabel => '蓝鲸出没';

  @override
  String get witchLabel => '女巫登场';

  @override
  String get lawnMowerTypeLabel => '小推车类型';

  @override
  String get renaissanceStatues => '复兴雕像和原石像';

  @override
  String get zomboss => '机甲僵王';

  @override
  String get boss => '非机甲僵王';

  @override
  String get zombossData => '僵王数据';

  @override
  String get contentsLabel => '内容：';

  @override
  String get vaseSpawnArea => '罐子生成区域';

  @override
  String get guessWhoIAm => '猜猜我是谁';

  @override
  String get plantBlackList => '植物黑名单';

  @override
  String get zombieWhiteList => '僵尸白名单';

  @override
  String get zombieWeight => '僵尸权重';

  @override
  String get rainContent => '种子雨内容';

  @override
  String get heianWind => '平安神风';

  @override
  String get all => '全部';

  @override
  String get impLv => '小鬼阶级';

  @override
  String get sortByLabel => '排序';

  @override
  String get sortByName => '排序：按名称';

  @override
  String get sortByCreationDate => '排序：按创建日期';

  @override
  String get sortByModificationDate => '排序：按修改日期';

  @override
  String get sortBySize => '排序：按文件大小';

  @override
  String get sortByFileType => '排序：按文件类型';

  @override
  String impsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count个小鬼',
      one: '1个小鬼',
    );
    return '$_temp0';
  }

  @override
  String get dropShip => '空投模块';

  @override
  String get totalLabel => '总计';

  @override
  String get totalPlantFoodTooltip => '本关掉落物总数（包括能量豆、植物卡片等）';

  @override
  String get appTitle => '我的工作区';

  @override
  String get about => '关于';

  @override
  String get refresh => '刷新';

  @override
  String get toggleTheme => '切换主题';

  @override
  String get switchFolder => '切换文件夹';

  @override
  String get clearCache => '释放缓存';

  @override
  String get autosave => '自动保存';

  @override
  String get autosaveOn => '自动保存：开';

  @override
  String get autosaveOff => '自动保存：关';

  @override
  String get autosaveSubtitle => '离开关卡后自动保存更改';

  @override
  String get ultra => '超大';

  @override
  String get uiSize => '界面大小';

  @override
  String get aboutSoftware => '关于软件';

  @override
  String get pluginsTitle => '插件';

  @override
  String get pluginInstallNew => '安装新插件';

  @override
  String get pluginInstallFromDevice => '从本地安装';

  @override
  String get pluginInstallFromUrl => '从链接安装';

  @override
  String get pluginInstallFromFolder => '编译插件文件夹（测试专用）';

  @override
  String get pluginUrlHint => 'https://example.com/my_plugin.cplugin';

  @override
  String get pluginDownload => '下载';

  @override
  String get pluginInstalling => '正在安装插件……';

  @override
  String pluginDownloadProgress(String received, String total) {
    return '正在下载 $received / $total';
  }

  @override
  String pluginDownloadProgressUnknown(String received) {
    return '正在下载 $received';
  }

  @override
  String pluginInstallSuccess(String name) {
    return '已安装 $name';
  }

  @override
  String pluginInstallFailed(String error) {
    return '安装失败：$error';
  }

  @override
  String pluginInvalidFile(String reason) {
    return '不是有效的插件：$reason';
  }

  @override
  String get pluginInvalidUrl => '请输入有效的 http(s) 链接';

  @override
  String get pluginReadFailed => '无法读取所选文件';

  @override
  String get pluginTrustWarningTitle => '安全提示';

  @override
  String get pluginTrustWarningBody =>
      '插件可以通过在C-Editor中运行代码，为编辑器带来更多有趣实用的功能。默认情况下，插件对文件和网络的访问会受到沙箱限制，但恶意插件仍可能造成不良影响，请仅安装可信渠道提供的插件。';

  @override
  String get pluginEmpty => '尚未安装插件。可从本地或下载链接安装 .cplugin 文件。';

  @override
  String get pluginNoScreens => '此插件没有可直接跳转的功能或界面。';

  @override
  String get pluginUninstall => '卸载';

  @override
  String get pluginUninstallTitle => '卸载插件';

  @override
  String pluginUninstallConfirm(String name) {
    return '要从编辑器中移除 $name 吗？';
  }

  @override
  String get pluginLoadError => '加载失败';

  @override
  String get pluginBundledBadge => '内置';

  @override
  String get pluginImportedBadge => '已导入';

  @override
  String get pluginsFolderReserved =>
      '“.plugins” 和 “.plugin_config” 文件夹名已保留给编辑器插件使用，请换一个名称。';

  @override
  String get pluginNoLibraryForInstall => '请先选择工作区文件夹，再安装插件。';

  @override
  String pluginShowingCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '已安装$count个插件',
      one: '已安装1个插件',
    );
    return '$_temp0';
  }

  @override
  String get pluginSearchHint => '搜索插件';

  @override
  String get pluginSelectHint => '选择一个插件以查看详情、调整设置并使用相关功能。';

  @override
  String get pluginEnabled => '已启用';

  @override
  String get pluginDisabled => '已禁用';

  @override
  String get pluginAuthors => '作者';

  @override
  String get pluginContributors => '贡献者';

  @override
  String pluginByAuthors(String authors) {
    return '作者：$authors';
  }

  @override
  String get pluginLicense => '许可证';

  @override
  String pluginVersionLabel(String version) {
    return 'v$version';
  }

  @override
  String get pluginIdLabel => 'ID';

  @override
  String get pluginLinkWebsite => '网站';

  @override
  String get pluginLinkIssues => '问题反馈';

  @override
  String get pluginLinkSource => '源码';

  @override
  String get pluginLinkDiscord => 'Discord';

  @override
  String get pluginIncompatibleWith => '不兼容';

  @override
  String get pluginOpenScreen => '打开';

  @override
  String get pluginOpenSettings => '设置';

  @override
  String get pluginInstallAction => '安装';

  @override
  String get pluginConfigurable => '可配置';

  @override
  String get pluginFeaturesSection => '功能与界面';

  @override
  String get pluginNoDescription => '暂无描述。';

  @override
  String get pluginSettingsUnavailable => '此插件没有设置界面。';

  @override
  String get share => '分享';

  @override
  String shareLevelFileText(String name) {
    return '关卡文件: $name';
  }

  @override
  String get shareLevelFailed => '无法分享关卡文件';

  @override
  String get storagePermissionDialogTitle => '需要存储权限';

  @override
  String get storagePermissionDialogMessage =>
      '本应用需要访问外部存储以打开和保存关卡文件。请在设置中授予「允许访问以管理所有文件」权限。';

  @override
  String get storagePermissionGoToSettings => '前往设置';

  @override
  String get storagePermissionDeny => '拒绝';

  @override
  String get initSetup => '初始化设置';

  @override
  String get selectFolderPrompt => '请选择一个文件夹作为关卡存储目录。';

  @override
  String get selectFolderButton => '选择文件夹';

  @override
  String get importFiles => '导入文件';

  @override
  String get importFolder => '导入文件夹';

  @override
  String get importFolderEmpty => '所选文件夹中没有关卡文件';

  @override
  String importFolderSuccess(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '已导入 $count 个文件',
      one: '已导入 1 个文件',
    );
    return '$_temp0';
  }

  @override
  String get importFilesUnreadable => '无法读取所选文件。请尝试较小的文件或其他浏览器。';

  @override
  String get importFolderUnsupported => '此浏览器不支持导入文件夹。';

  @override
  String get smartUploadTitle => '重复文件';

  @override
  String smartUploadFileMessage(String fileName) {
    return '此文件已存在于工作区中：\n\n$fileName\n\n如何处理？';
  }

  @override
  String get smartUploadSkip => '不上传';

  @override
  String get smartUploadOverwrite => '覆盖';

  @override
  String get smartUploadAsCopy => '作为副本上传';

  @override
  String get smartUploadSkipAll => '全部跳过';

  @override
  String get smartUploadOverwriteAll => '全部覆盖';

  @override
  String get smartUploadCopyAll => '全部作为副本上传';

  @override
  String get openFolder => '打开文件夹';

  @override
  String get useDefaultLibraryFolder => '使用默认文件夹';

  @override
  String get emptyFolder => '文件夹为空';

  @override
  String get newFolder => '新建文件夹';

  @override
  String get newLevel => '新建关卡';

  @override
  String get rename => '重命名';

  @override
  String get delete => '删除';

  @override
  String get copy => '复制';

  @override
  String get download => '下载';

  @override
  String get downloadAllLevels => '导出所有关卡';

  @override
  String get downloadFolder => '下载此文件夹';

  @override
  String get exportLevels => '关卡测试包';

  @override
  String get exportSelectLevels => '选择要测试的关卡';

  @override
  String get exportSelectFile => '选择用于生成测试包的游戏数据包 (.rsb.smf)';

  @override
  String get backupRecommendationTitle => '建议备份';

  @override
  String get backupRecommendationBody => '强烈建议您在测试前备份游戏数据包，以免因操作中断等意外情况造成数据丢失。';

  @override
  String get backupAndProceed => '备份并继续';

  @override
  String get proceedWithoutBackup => '不备份直接继续';

  @override
  String get backupSuffix => '_副本';

  @override
  String get exportNoFilesFound => '未找到游戏数据包 (.rsb.smf)。';

  @override
  String get exportDownloadExternalDynamic => '下载数据包';

  @override
  String get cancelExportTitle => '取消生成';

  @override
  String get cancelExportMessage => '确定要取消生成关卡测试包吗？';

  @override
  String get exportDisclaimerTitle => '风险提示与免责声明';

  @override
  String get exportDisclaimerBody =>
      '本功能通过向游戏数据包 (SMF/RSB 容器文件) 中注入关卡文件来生成关卡测试包，该过程会直接修改《植物大战僵尸2》的游戏数据。\n\n• 使用本功能修改游戏数据可能违反游戏服务条款\n• 可能导致游戏账号被临时或永久封禁\n• 可能导致游戏存档损坏或数据丢失\n• 所有操作均为用户自行选择，风险自负\n\n开发者在此明确声明：\n\n1. 本功能仅供学习研究使用，不鼓励任何形式的游戏作弊行为。\n2. 用户使用本功能所产生的一切后果，包括但不限于账号封禁、数据丢失、游戏体验受损等，均由用户自行承担，开发者不承担任何直接或间接责任。\n3. 用户在使用本功能前应充分了解相关风险，并自行决定是否承担这些风险。\n4. 继续使用即表示您已阅读、理解并同意本免责声明的全部条款。';

  @override
  String get exportDisclaimerDoNotShowAgain => '不再默认显示';

  @override
  String get importProgressTitle => '正在导入文件…';

  @override
  String get exportProgressTitle => '正在导出关卡…';

  @override
  String get exportPackageProgressTitle => '正在导出数据包…';

  @override
  String get backupProgressTitle => '正在创建备份…';

  @override
  String get favorite => '收藏';

  @override
  String get move => '移动';

  @override
  String get cancel => '取消';

  @override
  String get confirm => '确定';

  @override
  String get convert => '格式转换';

  @override
  String get convertHelpTooltip => '格式转换';

  @override
  String get create => '创建';

  @override
  String get newName => '新名称';

  @override
  String get folderName => '文件夹名称';

  @override
  String get confirmDelete => '确认删除';

  @override
  String confirmDeleteMessage(String name, String detail) {
    return '确定要删除 \"$name\" 吗？$detail';
  }

  @override
  String get folderDeleteDetail => '如果是文件夹，其内容也将被删除。';

  @override
  String get levelDeleteDetail => '此操作不可恢复。';

  @override
  String get confirmDeleteCheckbox => '我确定要永久删除';

  @override
  String get renameSuccess => '重命名成功';

  @override
  String get renameFail => '重命名失败，已有同名文件';

  @override
  String get uploadLevel => '上传至创意庭院';

  @override
  String get uploadLevelConfirm =>
      '即将离开编辑器并打开官方的高级创作庭院作者中心网站。使用邮箱登录后，您可以将工作区文件夹中的JSON关卡文件上传至游戏内的创意庭院供玩家游玩。是否继续？';

  @override
  String get back => '返回';

  @override
  String get noLevelsFound => '未找到关卡';

  @override
  String get searchLevel => '搜索关卡...';

  @override
  String get proceed => '继续';

  @override
  String get exportProceed => '继续';

  @override
  String get exportBegin => '开始';

  @override
  String get exportStatusCreatingRton => '正在创建 RTON 关卡...';

  @override
  String get exportStatusUnpackingRsb => '正在解包 RSB...';

  @override
  String get exportStatusUnpackingRsg => '正在解包 Packages.rsg...';

  @override
  String get exportStatusInjecting => '正在注入关卡...';

  @override
  String get exportStatusRepackingRsg => '正在打包 RSG...';

  @override
  String get exportStatusRepackingRsb => '正在打包 RSB...';

  @override
  String get exportStatusFinalizing => '正在收尾...';

  @override
  String get exportAssignmentProposalTitle => '关卡分配';

  @override
  String get exportDifficultyReplacementNotice =>
      '如果目标关卡槽位中的普通模式与困难/专家模式实际为两个不同的关卡，编辑器只会替换其中的普通模式关卡。';

  @override
  String get exportWorld => '世界';

  @override
  String get exportLevelNumber => '关卡编号';

  @override
  String exportLevelShort(int level) {
    return '第 $level 关';
  }

  @override
  String get exportFinish => '完成';

  @override
  String get exportSuccessTitle => '生成成功';

  @override
  String exportSuccessMessage(String file) {
    return '关卡测试包已成功生成至 $file。\n用生成的游戏数据包替换游戏的对应文件后，即可从被替换的原关卡入口进入并测试自己的关卡。\n注意：1. 替换前，请彻底关闭游戏进程。\n2. 替换完成后、进入游戏前，请彻底关闭编辑器以及正在占用目标目录的文件管理器。';
  }

  @override
  String get exportCancelled => '已取消生成关卡测试包。';

  @override
  String exportDuplicateAssignment(String world, int level) {
    return '重复分配：$world 第$level关';
  }

  @override
  String get exportAssignmentIncomplete => '部分关卡未分配';

  @override
  String get exportConfirmationTitle => '确认分配';

  @override
  String get exportConfirmationBody => '请在继续之前核实您的分配。';

  @override
  String get exportFinalCheckTitle => '最终检查';

  @override
  String get exportFinalCheckBody => '以下关卡将以新名称写入数据包：';

  @override
  String exportTargetArchive(String file) {
    return '所选关卡将写入 $file';
  }

  @override
  String get exportStart => '生成测试包';

  @override
  String get exportAssignmentProposalBody =>
      '所选关卡已通过验证。接下来，请为每个关卡选择其在主线世界中占用的关卡槽位。';

  @override
  String get copyReferenceOrDeep => '复制事件引用，还是创建独立副本？';

  @override
  String get copyReference => '复制事件引用';

  @override
  String get deepCopy => '创建独立副本';

  @override
  String get comingSoon => '敬请期待';

  @override
  String get allLevelsCategory => '全部';

  @override
  String get favoritesCategory => '收藏';

  @override
  String get newFolderNameHint => '留空以使用默认名称';

  @override
  String get emptyFavorites => '您还没有收藏的关卡';

  @override
  String get copyEventTarget => '选择目标波次';

  @override
  String get targetWaveAlreadyContainsEvent => '已包含该事件';

  @override
  String get targetWaveIndexHelper => '复制引用时，已包含该事件的波次会自动跳过。';

  @override
  String get moveToWaveIndex => '移动至波次序号';

  @override
  String get invalidWaveIndex => '无效波次序号';

  @override
  String get renamingFailed => '重命名失败';

  @override
  String get deleted => '已删除';

  @override
  String get copyLevel => '复制关卡';

  @override
  String get newFileName => '新文件名';

  @override
  String get copySuccess => '复制成功';

  @override
  String get copyFail => '复制失败';

  @override
  String moving(String name) {
    return '正在移动: $name';
  }

  @override
  String get movePrompt => '请导航至目标文件夹，然后点击粘贴';

  @override
  String get paste => '粘贴';

  @override
  String get movingSuccess => '移动成功';

  @override
  String get movingFail => '移动失败';

  @override
  String get moveSameFolder => '源目录和目标目录相同';

  @override
  String get moveFileExistsTitle => '文件已存在';

  @override
  String get moveFileExistsMessage => '目标文件夹中已存在同名文件。';

  @override
  String get moveOverwrite => '覆盖';

  @override
  String fileOverwritten(String name) {
    return '文件已覆盖: $name';
  }

  @override
  String get moveSaveAsCopy => '另存为副本';

  @override
  String get moveCancelled => '操作已取消';

  @override
  String movedAs(String name) {
    return '已移动并另存为 $name';
  }

  @override
  String get folderCreated => '文件夹创建成功';

  @override
  String get createFail => '创建失败';

  @override
  String get noTemplates => '未找到模板';

  @override
  String get newLevelTemplate => '新建关卡 - 选择模板';

  @override
  String get nameLevel => '命名关卡';

  @override
  String get levelCreated => '创建成功';

  @override
  String get levelCreateFail => '创建失败，已有同名文件';

  @override
  String get templateLoadFail => '无法加载所选关卡模板';

  @override
  String get adjustUiSize => '调整界面大小';

  @override
  String currentScale(String percent) {
    return '当前缩放: $percent%';
  }

  @override
  String get small => '小';

  @override
  String get standard => '标准';

  @override
  String get large => '大';

  @override
  String get done => '完成';

  @override
  String get reset => '重置';

  @override
  String cacheCleared(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '已清理$count个缓存文件',
      one: '已清理1个缓存文件',
    );
    return '$_temp0';
  }

  @override
  String get returnUp => '返回上一级';

  @override
  String get convertToJson => '转换为JSON';

  @override
  String get convertToHotUpdateJson => '转换为热更新JSON (HUJSON)';

  @override
  String get convertToEncryptedRton => '转换为加密RTON';

  @override
  String get hujsonFormatDescription =>
      '热更新可读格式，导入游戏前需手动将扩展名从 .hujson 改回 .json';

  @override
  String get rtonFormatDescription => '用于替换游戏数据包 (dynamic.rsb.smf) 中的关卡数据';

  @override
  String get conversionRequiredTitle => '需要转换';

  @override
  String get conversionRequiredMessage => '该文件需要先转换为JSON才能在编辑器中打开。';

  @override
  String get convertAction => '格式转换';

  @override
  String get conversionFailed => '转换失败';

  @override
  String convertedMessage(String name) {
    return '已转换：$name';
  }

  @override
  String get softwareIntro => '软件介绍';

  @override
  String get cEditor => 'C-Editor';

  @override
  String get pvzEditorSubtitle => 'PvZ2C 关卡可视化编辑器';

  @override
  String get introSection => '简介';

  @override
  String get introText =>
      'C-Editor 是一款专为《植物大战僵尸2》中文版设计的可视化关卡编辑工具。它旨在解决直接修改 JSON 文件繁琐、易错的问题，提供直观的图形界面来管理关卡配置。';

  @override
  String get featuresSection => '核心功能';

  @override
  String get feature1 => '模块化编辑：对关卡模块和事件进行模块化管理，实现快速配置。';

  @override
  String get feature2 => '多模式支持：支持编辑我是僵尸、砸罐子、坚不可摧、僵王战等多种模式。';

  @override
  String get feature3 => '自定义注入：实现在关卡内注入并管理自定义僵尸、自定义地图和自定义僵王机甲，并编辑其基础属性。';

  @override
  String get feature4 => '智能校验：自动检测模块依赖缺失、引用失效等问题，有效预防关卡闪退。';

  @override
  String get feature5 => '资源预览：内置植物、僵尸和障碍物图标，优化编辑体验，所见即所得。';

  @override
  String get usageSection => '使用说明';

  @override
  String get usageTextDesktop =>
      '1. 目录设置：首次进入请点击右上角文件夹图标，选择存放 JSON 关卡文件的目录。\n2. 导入/新建：可以直接点击列表项编辑现有关卡，或使用下方按钮基于模板新建。\n3. 模块管理：在编辑器中，可以通过“添加新模块”扩展关卡功能。\n4. 保存关卡：编辑完成后点击右上角保存按钮，文件将自动回写到原 JSON 文件。\n5. 转换关卡文件：可将 JSON 转换为热更新可读的 HUJSON (导入前需手动将扩展名从 .hujson 改回 .json) 或加密后的 RTON (用于替换 dynamic.rsb.smf 中的关卡数据)。\n6. 插件：插件可以通过运行额外代码提供新的功能与界面，丰富编辑器的使用体验。除内置插件外，还可以通过安装本地 .cplugin 文件或输入 URL 链接获取新的插件。插件内的功能可以自主选择开启或禁用。\n7. 位于关卡列表顶部时，可点击右下角的“上传至创意庭院”按钮，前往官方的植物大战僵尸2高级创作庭院作者中心。\n8. 可以在「创意庭院·推荐关卡展示」网页中查看往期官方推荐的关卡ID及推荐理由。游玩这些关卡不仅能够支持优秀的关卡创作者，也有助于提升自己的关卡设计水平。';

  @override
  String get usageTextMobile =>
      '1. 目录设置：首次进入请点击右上角文件夹图标，选择存放 JSON 关卡文件的目录。\n2. 导入/新建：可以直接点击列表项编辑现有关卡，或使用下方按钮基于模板新建。\n3. 模块管理：在编辑器中，可以通过“添加新模块”扩展关卡功能。\n4. 保存关卡：编辑完成后点击右上角保存按钮，文件将自动回写到原 JSON 文件。\n5. 转换关卡文件：可将 JSON 转换为热更新可读的 HUJSON (导入前需手动将扩展名从 .hujson 改回 .json) 或加密后的 RTON (用于替换 dynamic.rsb.smf 中的关卡数据)。\n6. 插件：插件可以通过运行额外代码提供新的功能与界面，丰富编辑器的使用体验。除内置插件外，还可以通过安装本地 .cplugin 文件或输入 URL 链接获取新的插件。插件内的功能可以自主选择开启或禁用。\n7. 位于关卡列表顶部时，可点击右下角的“上传至创意庭院”按钮，前往官方的植物大战僵尸2高级创作庭院作者中心。\n8. 可以在「创意庭院·推荐关卡展示」网页中查看往期官方推荐的关卡ID及推荐理由。游玩这些关卡不仅能够支持优秀的关卡创作者，也有助于提升自己的关卡设计水平。';

  @override
  String get usageRecommendedLevelsLabel => '创意庭院·推荐关卡展示：';

  @override
  String get discordInviteLabel => '';

  @override
  String get cEditorInviteLabel => 'C-Editor Discord服务器邀请链接：';

  @override
  String get creditsSection => '致谢名单';

  @override
  String get authorLabel => '作者：';

  @override
  String get authorName => 'CyberSteve777、Devourdoom、Chara';

  @override
  String get thanksLabel => '特别鸣谢：';

  @override
  String get thanksNames =>
      'Evilhack28、Rebus、KL12、vi_i_guess、Haruma、nineteendo';

  @override
  String get sourceLabel => '代码仓库：';

  @override
  String get issuesLabel => '问题反馈：';

  @override
  String get zEditorAcknowledgment =>
      '在此，我们还要向 Z-Editor 的创作者们致以诚挚的感谢。本工具的诞生离不开他们所奠定的基础。';

  @override
  String get zEditorCreditsSubsection => 'Z-Editor 致谢名单';

  @override
  String get zEditorAuthorLabel => '作者：';

  @override
  String get zEditorAuthorName => '降维打击';

  @override
  String get zEditorThanksLabel => '特别鸣谢：';

  @override
  String get zEditorThanksNames =>
      '星寻、metal海枣、超越自我3333、桃酱、凉沈、小小师、顾小言、PhiLia093、咖啡、不留名';

  @override
  String get zEditorQqGroupLabel => 'Z-Editor QQ群：';

  @override
  String get tagline => '穿越时空 创造无穷可能';

  @override
  String editorVersion(String version) {
    return '编辑器版本：$version';
  }

  @override
  String supportedGameVersion(String version) {
    return '支持的游戏版本：$version';
  }

  @override
  String get language => '语言';

  @override
  String get languageEnglish => 'English';

  @override
  String get languageChinese => '中文';

  @override
  String get languageRussian => 'Русский';

  @override
  String get templateBlankLevel => '空白关卡';

  @override
  String get templateCardPickExample => '自选卡示例';

  @override
  String get templateConveyorExample => '传送带示例';

  @override
  String get templateLastStandExample => '坚不可摧示例';

  @override
  String get templateIZombieExample => '我是僵尸示例';

  @override
  String get templateVaseBreakerExample => '砸罐子示例';

  @override
  String get templateZombossMechExample => '机甲僵王战示例';

  @override
  String get templateZombossBattleExample => '非机甲僵王战示例';

  @override
  String get templateCustomZombieExample => '自定义僵尸示例';

  @override
  String get templateIPlantExample => '我是植物示例';

  @override
  String get templateOldStyleExample => '波次生成器示例';

  @override
  String get templateCustomLawnExample => '自定义地图示例';

  @override
  String get unsavedChanges => '有未保存的更改';

  @override
  String get saveBeforeLeaving => '离开前是否保存更改？';

  @override
  String get discard => '放弃';

  @override
  String get stayInEditor => '取消';

  @override
  String get saved => '已保存';

  @override
  String get failedToLoadLevel => '关卡加载失败。\n建议检查关卡文件是否为加密格式 (如热更新使用的JSON文件)。';

  @override
  String get noLevelDefinition => '未找到关卡定义';

  @override
  String get noLevelDefinitionHint =>
      '当前关卡内未找到关卡定义模块 (LevelDefinition)，这是关卡文件的基础节点。请尝试手动添加。';

  @override
  String get levelBasicInfo => '关卡基本信息';

  @override
  String get levelBasicInfoSubtitle => '名称、序号、描述、地图背景';

  @override
  String get removeModule => '移除模块';

  @override
  String get zombieCategoryMain => '按世界';

  @override
  String get zombieCategorySize => '按体型';

  @override
  String get zombieCategoryOther => '其他';

  @override
  String get zombieCategoryCollection => '我的收藏';

  @override
  String get zombieTagAll => '全部僵尸';

  @override
  String get zombieTagEgyptPirate => '埃及/海盗';

  @override
  String get zombieTagWestFuture => '西部/未来';

  @override
  String get zombieTagDarkBeach => '黑暗/沙滩';

  @override
  String get zombieTagIceageLostcity => '冰河/失落';

  @override
  String get zombieTagKongfuSkycity => '功夫/天空';

  @override
  String get zombieTagEightiesDino => '摇滚/恐龙';

  @override
  String get zombieTagModernPvz1 => '现代/一代';

  @override
  String get zombieTagSteamRenai => '蒸汽/复兴';

  @override
  String get zombieTagHeianAtlantis => '平安/海底';

  @override
  String get zombieTagMoon => '月球基地';

  @override
  String get zombieTagTaleZCorp => '童话/Z公司';

  @override
  String get zombieTagParkourSpeed => '跑酷/飞车';

  @override
  String get zombieTagTothewest => '西游/地宫';

  @override
  String get zombieTagMemory => '回忆之旅';

  @override
  String get zombieTagUniverse => '平行宇宙';

  @override
  String get zombieTagFestival1 => '节日串烧1';

  @override
  String get zombieTagFestival2 => '节日串烧2';

  @override
  String get zombieTagRoman => '罗马帝国';

  @override
  String get zombieTagCustom => '回忆变体';

  @override
  String get zombieTagExpedition => '远征变体';

  @override
  String get zombieTagPvp => '双人变体';

  @override
  String get zombieTagPet => '宠物';

  @override
  String get zombieTagImp => '小鬼';

  @override
  String get zombieTagBasic => '常规';

  @override
  String get zombieTagFat => '胖子';

  @override
  String get zombieTagStrong => '壮汉';

  @override
  String get zombieTagGargantuar => '巨人';

  @override
  String get zombieTagElite => '精英';

  @override
  String get zombieTagEvildave => '适配IZ';

  @override
  String get plantCategoryQuality => '按品质';

  @override
  String get plantCategoryRole => '按作用';

  @override
  String get plantCategoryAttribute => '按属性';

  @override
  String get plantCategoryWorld => '按世界';

  @override
  String get plantCategoryOther => '其他分类';

  @override
  String get plantCategoryCollection => '我的收藏';

  @override
  String get plantTagAll => '全部植物';

  @override
  String get plantTagWhite => '白色品质';

  @override
  String get plantTagGreen => '绿色品质';

  @override
  String get plantTagBlue => '蓝色品质';

  @override
  String get plantTagPurple => '紫色品质';

  @override
  String get plantTagOrange => '橙色品质';

  @override
  String get plantTagRed => '红色品质';

  @override
  String get plantTagSupport => '辅助植物';

  @override
  String get plantTagRanger => '远程植物';

  @override
  String get plantTagSunProducer => '生产植物';

  @override
  String get plantTagDefence => '坚韧植物';

  @override
  String get plantTagVanguard => '先锋植物';

  @override
  String get plantTagTrapper => '奇兵植物';

  @override
  String get plantTagFire => '火焰属性';

  @override
  String get plantTagIce => '冰冻属性';

  @override
  String get plantTagMagic => '魔法属性';

  @override
  String get plantTagPoison => '毒液属性';

  @override
  String get plantTagElectric => '雷电属性';

  @override
  String get plantTagPhysical => '物理属性';

  @override
  String get plantTagWorldTutorial => '教程庭院';

  @override
  String get plantTagWorldEgypt => '神秘埃及';

  @override
  String get plantTagWorldPirate => '海盗港湾';

  @override
  String get plantTagWorldWildWest => '狂野西部';

  @override
  String get plantTagWorldKongfu => '功夫世界';

  @override
  String get plantTagWorldFuture => '遥远未来';

  @override
  String get plantTagWorldDarkAges => '黑暗时代';

  @override
  String get plantTagWorldBeach => '巨浪沙滩';

  @override
  String get plantTagWorldIceage => '冰河世界';

  @override
  String get plantTagWorldSkycity => '天空之城';

  @override
  String get plantTagWorldLostCity => '失落之城';

  @override
  String get plantTagWorldEighties => '摇滚年代';

  @override
  String get plantTagWorldDino => '恐龙危机';

  @override
  String get plantTagWorldModern => '摩登世界';

  @override
  String get plantTagWorldSteam => '蒸汽时代';

  @override
  String get plantTagWorldRenai => '复兴时代';

  @override
  String get plantTagWorldHeian => '平安时代';

  @override
  String get plantTagWorldAtlantis => '海底世界';

  @override
  String get plantTagWorldMoon => '月球基地';

  @override
  String get plantTagWorldFairytale => '童话森林';

  @override
  String get plantTagWorldZcorp => 'Z公司';

  @override
  String get plantTagWorldMausoleum => '地宫遗迹';

  @override
  String get plantTagOriginal => '一代植物';

  @override
  String get plantTagParallel => '平行世界';

  @override
  String get plantTagSpecial => '魔术帽';

  @override
  String get plantTagHidden => '隐藏植物';

  @override
  String get plantTagTier4 => '四阶村';

  @override
  String get plantTagInternational => '国际版移植';

  @override
  String get plantTagChinese => '中文版独有';

  @override
  String get removeModuleConfirm =>
      '确定要移除该模块吗？本地自定义模块(@CurrentLevel)及其关联数据将一并删除，不可恢复。';

  @override
  String get confirmRemove => '确认移除';

  @override
  String get settings => '设置';

  @override
  String get timeline => '波次时间线';

  @override
  String get iZombie => '我是僵尸';

  @override
  String get vaseBreaker => '砸罐子';

  @override
  String get zombossMech => '机甲僵王战';

  @override
  String get zombossBattle => '非机甲僵王战';

  @override
  String get rootFolder => '根目录';

  @override
  String get createEmptyWaveContainer => '创建空波次容器';

  @override
  String get deleteEmptyContainer => '删除空容器';

  @override
  String get deleteWaveContainerTitle => '删除波次容器';

  @override
  String get deleteWaveContainerConfirm => '确定要删除空的波次容器吗？删除后您可以重新创建一个新的容器。';

  @override
  String get noWaveManager => '未找到波次容器';

  @override
  String get noWaveManagerHint =>
      '当前关卡启用了波次管理模块，但缺少存储波次数据的实体对象 (WaveManagerProperties)。请创建一个空波次容器。';

  @override
  String get waveTimelineGuideTitle => '操作指引';

  @override
  String get waveTimelineGuideBodyDesktop =>
      '左键点击波次：管理事件\n长按事件：拖动排序或移到其他波次\n点击点数：查看点数出怪期望';

  @override
  String get waveTimelineGuideBodyMobile =>
      '点击波次：管理事件\n长按事件：拖动排序或移到其他波次\n点击点数：查看点数出怪期望';

  @override
  String get waveDeadLinksTitle => '引用失效报警';

  @override
  String get waveDeadLinksClear => '一键清理失效事件';

  @override
  String get customZombieManagerTitle => '自定义僵尸管理';

  @override
  String get customZombieEmpty => '暂无自定义僵尸数据';

  @override
  String get switchCustomZombie => '切换自定义僵尸';

  @override
  String get switchProperties => '切换属性';

  @override
  String get defaultPropertiesLabel => '默认';

  @override
  String get addNewVariation => '+ 添加新变体';

  @override
  String editCustomZombieAlias(String alias) {
    return '编辑 $alias';
  }

  @override
  String get switchZombie => '切换僵尸';

  @override
  String get customZombieAppearanceLocation => '出现位置：';

  @override
  String get customZombieNotUsed => '此自定义僵尸当前未被任何波次或模块使用。';

  @override
  String customZombieWaveItem(int n) {
    return '第$n波';
  }

  @override
  String get customZombieDeleteConfirm => '将移除僵尸实体及其属性数据。';

  @override
  String get customZombieOrphanDeleteTitle => '从关卡中清除自定义属性？';

  @override
  String customZombieOrphanDeleteMessage(String alias) {
    return '“$alias”在本关卡中将不再被使用。是否从关卡文件中移除其僵尸类型与属性对象？此操作无法撤销。';
  }

  @override
  String get customZombieOrphanDeleteKeep => '保留在关卡中';

  @override
  String get customZombieOrphanDeleteErase => '从关卡中清除';

  @override
  String get customLabel => '自定义';

  @override
  String get moduleTitle_WaveManagerProperties => '关联波次参数 (WaveManagerProps)';

  @override
  String waveManagerPropsCurrent(String value) {
    return '当前值：$value';
  }

  @override
  String get waveManagerGlobalParams => '波次管理器全局参数';

  @override
  String get waveContainerAliasSection => '波次容器代号';

  @override
  String get waveContainerAliasHint =>
      '存储波次数据的 WaveManagerProperties 对象在关卡文件中使用的别名，一般不需要手动修改。';

  @override
  String waveManagerGlobalSummary(
    int interval,
    int minPercent,
    int maxPercent,
  ) {
    return '旗帜间隔: $interval, 刷新血线: $minPercent% - $maxPercent%';
  }

  @override
  String get waveEmptyTitle => '当前波次列表为空';

  @override
  String get waveEmptySubtitle => '您可以添加第一个波次，或者删除这个空的容器。';

  @override
  String get waveHeaderPreview => '内容及点数预览';

  @override
  String waveTotalLabel(int total) {
    return '总计: $total';
  }

  @override
  String get waveEmptyRowHintDesktop => '空波次 (点击管理，可拖入事件)';

  @override
  String get waveEmptyRowHintMobile => '空波次 (点击管理，可拖入事件)';

  @override
  String get removeFromWave => '从波次移除';

  @override
  String waveEventsTitle(int wave) {
    return '第 $wave 波事件';
  }

  @override
  String get waveManagerSettings => '波次事件参数配置';

  @override
  String get flagInterval => '旗帜间隔 (FlagWaveInterval)';

  @override
  String get waveManagerHelpTitle => '波次事件容器说明';

  @override
  String get waveManagerHelpOverviewTitle => '简要介绍';

  @override
  String get waveManagerHelpOverviewBody =>
      '波次事件容器用于按波次顺序存放关卡的众多事件，大部分关卡都是通过波次事件进行出怪安排的。这个页面用于调控波次事件容器的全局参数。';

  @override
  String get waveManagerHelpFlagTitle => '旗帜间隔';

  @override
  String get waveManagerHelpFlagBody =>
      '旗帜间隔指每隔多少波会出现一个旗帜波，除此之外每关的最后一波也会是旗帜波。旗帜波享有额外的点数加成和刷新间隔。';

  @override
  String get waveManagerHelpTimeTitle => '时间控制';

  @override
  String get waveManagerHelpTimeBody =>
      '第一波僵尸到来前的时间间隔会随关卡是否有传送带而变化，若有传送带，则从自选卡的12秒变为5秒。旗帜波延迟指的是红字提示到僵尸刷新的间隔。';

  @override
  String get waveManagerFirstWaveDelayConveyorOnlyHint =>
      '当前首波延迟的编辑仅对传送带关卡生效，常规关卡会采用默认值';

  @override
  String get waveManagerFirstWaveDelayConveyorOnlyHelp =>
      '当前首波延迟的编辑仅对传送带关卡生效，常规关卡会采用默认值。';

  @override
  String get waveManagerHelpMusicTitle => '音乐类型';

  @override
  String get waveManagerHelpMusicBody =>
      '本设置项只适用于摩登世界地图，用于设定一类不可更改的全局背景音乐为摇滚年代的特殊僵尸提供技能。';

  @override
  String get waveManagerBasicParams => '基础参数';

  @override
  String get waveManagerMaxHealthThreshold => '最大刷新血线';

  @override
  String get waveManagerMinHealthThreshold => '最小刷新血线';

  @override
  String get waveManagerThresholdHint =>
      '刷新血线的值必须为 0 到 1 之间的数，一波内自然出现的僵尸总血量低于血线值就会自动刷新下一波';

  @override
  String get waveManagerTimeControl => '时间控制';

  @override
  String get waveManagerFirstWaveDelayConveyor => '首波延迟（传送带，单位：秒）';

  @override
  String get waveManagerFirstWaveDelayNormal => '首波延迟（常规，单位：秒）';

  @override
  String get waveManagerFlagWaveDelay => '旗帜波延迟（单位：秒）';

  @override
  String get waveManagerConveyorDetected => '检测到传送带模块，已自动使用传送带延迟';

  @override
  String get waveManagerConveyorNotDetected => '未检测到传送带模块，使用常规延迟';

  @override
  String get waveManagerSpecial => '特殊设置';

  @override
  String get waveManagerSuppressFlagZombieTitle => '屏蔽旗帜僵尸';

  @override
  String get waveManagerSuppressFlagZombieField => 'SuppressFlagZombie';

  @override
  String get waveManagerSuppressFlagZombieHint => '开启后，大波次来袭时不会生成带旗帜的领头僵尸';

  @override
  String get waveManagerLevelJam => '背景音乐类型 (LevelJam)';

  @override
  String get waveManagerLevelJamHint => '该设置仅在摩登世界有效，用于为关卡加入不可更改的全局音乐';

  @override
  String get jamNone => '默认/无 (None)';

  @override
  String get jamPop => '流行 (Pop)';

  @override
  String get jamRap => '说唱 (Rap)';

  @override
  String get jamMetal => '重金属 (Metal)';

  @override
  String get jamPunk => '朋克 (Punk)';

  @override
  String get jam8Bit => '8位 (8-bit)';

  @override
  String get deleteWave => '删除波次';

  @override
  String deleteWaveConfirm(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '将移除此波次及其 $count 个事件。',
      one: '将移除此波次及其 1 个事件。',
    );
    return '$_temp0';
  }

  @override
  String get deleteWaveConfirmCheckbox => '我确认永久删除此波次';

  @override
  String get addEvent => '添加事件';

  @override
  String get reuseExistingEvent => '复用事件';

  @override
  String reuseExistingEventForWave(int wave) {
    return '为第 $wave 波复用事件';
  }

  @override
  String get reuseExistingEventEmpty => '关卡中还没有事件';

  @override
  String get reuseExistingEventUnused => '未加入任何波次';

  @override
  String reuseExistingEventUsedInWaves(String waves) {
    return '波次：$waves';
  }

  @override
  String get emptyWave => '空波次';

  @override
  String get addWave => '添加波次';

  @override
  String get expectation => '点数出怪期望';

  @override
  String get close => '关闭';

  @override
  String get levelOverview => '关卡总览';

  @override
  String get levelOverviewOpenLevel => '打开关卡';

  @override
  String get previewStartingPlantFood => '初始能量豆';

  @override
  String get previewPrePlaced => '预置布局';

  @override
  String get previewRegularPlants => '常规植物';

  @override
  String get previewFrozenPlants => '冰冻植物';

  @override
  String get previewLevelContent => '关卡内容';

  @override
  String get previewSeedBank => '卡槽植物';

  @override
  String get previewIZombieSeedBank => '卡槽僵尸';

  @override
  String get previewFeatures => '关卡特性';

  @override
  String get previewActiveModules => '启用模块';

  @override
  String get previewInitial => '初始障碍物';

  @override
  String get previewGenerateImagePreview => '生成预览图';

  @override
  String get editProperties => '编辑属性';

  @override
  String get deleteEntity => '删除实体';

  @override
  String get deleteObjectTitle => '删除对象？';

  @override
  String get deleteObjectConfirmMessage => '从关卡文件中移除此对象？此操作不可撤销。';

  @override
  String get objectDeleted => '对象已删除';

  @override
  String get moduleEditorInProgress => '模块编辑器开发中';

  @override
  String get saveFail => '保存失败';

  @override
  String get confirmRemoveRef => '移除引用';

  @override
  String get confirmRemoveRefMessage =>
      '确定要移除此引用吗？只有当这是该事件的最后一个引用时，才会删除事件实体数据。';

  @override
  String get code => '代码';

  @override
  String get name => '名称';

  @override
  String get levelNumber => '关卡序号';

  @override
  String get startingSun => '初始阳光';

  @override
  String get startingPlantfood => '初始能量豆';

  @override
  String get stageModule => '关卡地图';

  @override
  String get musicType => '音乐类型';

  @override
  String get loot => '关卡默认掉落';

  @override
  String get victoryModule => '胜利结算方式';

  @override
  String get basicInfoSection => '基础信息';

  @override
  String get sceneSettingsSection => '场景设置';

  @override
  String get restrictionsSection => '限制选项';

  @override
  String get victoryModuleWarning => '使用默认结算方式以外的结算方式可能会因为模块冲突导致关卡闪退，请谨慎使用。';

  @override
  String get beatTheLevelDialogHint =>
      '支持显示中文，多行文字需直接输入回车，无需使用转义序列，注意iOS端庭院内无法查看提示内容。';

  @override
  String get missingModules => '缺失模块';

  @override
  String get conflictTitle_ModuleLogic => '模块逻辑冲突';

  @override
  String conflictDefaultDescription(String module1, String module2) {
    return '「$module1」与「$module2」逻辑冲突，建议只保留其中一个。';
  }

  @override
  String get conflictDesc_SeedBankConveyor =>
      '种子库与传送带模块界面冲突，可能导致崩溃。请确保种子库为预选模式。';

  @override
  String get conflictDesc_VaseBreakerIntro => '砸罐子模式不需要开场动画。';

  @override
  String get conflictDesc_LastStandIntro => '坚不可摧模式不需要开场动画。';

  @override
  String get conflictDesc_CowboyIntro =>
      '围栏之战与转场模块存在冲突，同时使用会导致开局时的僵尸预览和转场效果异常。';

  @override
  String get conflictDesc_SingleHandedIntro =>
      '单枪匹马与转场模块存在冲突，同时使用会导致开局时的转场效果异常。';

  @override
  String get conflictDesc_SingleHandedTutorialIntro =>
      '单枪匹马教程与转场模块存在冲突，同时使用会导致开局时的转场效果异常。';

  @override
  String get conflictDesc_EvilDaveZombieDrop => '我是僵尸模式不能使用僵尸掉落模块。';

  @override
  String get conflictDesc_EvilDaveVictory => '我是僵尸模式不能使用僵尸胜利条件。';

  @override
  String get conflictDesc_ZombossDeathDrop => '机甲僵王战中死亡结算会阻止关卡正常完成。';

  @override
  String get conflictDesc_WinConditionExclusive =>
      '「死亡结算」与「铜人阵死亡结算」不需要同时添加，建议移除其中一个。';

  @override
  String get conflictDesc_ZombossTwoIntros => '两个开场动画不能共存，否则僵王的血条会显示异常。';

  @override
  String get conflictDesc_InitialPlantEntryRoof => '在屋顶上预置植物会导致关卡闪退。';

  @override
  String get conflictDesc_InitialPlantRoof => '在屋顶上预设植物会导致关卡闪退。';

  @override
  String get conflictDesc_ProtectPlantRoof => '在屋顶上设置保护植物会导致关卡闪退。';

  @override
  String get conflictDesc_LawnMowerYard => '庭院模块中添加小推车无效。';

  @override
  String get conflictDesc_MoonExpertYard => '「月球专家」模块在庭院模块下无效。';

  @override
  String get conflictDesc_WaveGeneratorWaveManagerModule =>
      '波次生成器与波次管理器模块不能共存——它们是两套不同的波次系统。';

  @override
  String get conflictDesc_WaveGeneratorWaveManager =>
      '波次生成器内嵌波次数据，不能与独立的波次管理器容器同时使用。';

  @override
  String conflictDesc_CamelMinigameNonTouchZombies(String zombies) {
    return '记忆骆驼牌仅支持特殊「记忆骆驼牌僵尸」。$zombies等其他僵尸在关卡中出现会导致游戏闪退。请替换或移除这些僵尸。';
  }

  @override
  String get targetZombieRequiresOakTrain =>
      '百步穿僵小游戏的专属僵尸在专属模块下能够更好地发挥作用，请在关卡中添加「百步穿僵」模块。';

  @override
  String get conflictDesc_CamelMinigameIntro =>
      '记忆骆驼牌与转场模块存在冲突，同时使用会导致开局时的转场效果异常。';

  @override
  String get targetZombieInWaveManagerWarningTitle => '僵尸兼容性提示';

  @override
  String get targetZombieInWaveManagerWarning =>
      '百步穿僵小游戏的专属僵尸无法在波次管理器的普通出怪、海底出怪等常规出怪事件中使用技能，建议使用地底出怪事件或自定义僵尸实现类似效果。';

  @override
  String get oakTrainUnderwaterWarningTitle => '地图兼容性提示';

  @override
  String get oakTrainUnderwaterWarning =>
      '当前基础地图为海底世界或月球基地，百步穿僵小游戏自带的橡木弓手可能无法在地图中生存，请注意预置氧气藻或苔藓地块。';

  @override
  String get waveGeneratorRiseFromGroundWarningTitle => '出怪情况提示';

  @override
  String get waveGeneratorRiseFromGroundWarning =>
      '开启「从地底出怪 (IsRiseFromGroundMode)」后，大多数生成的僵尸将无法移动或使用技能。若仅指定出怪行而未设置具体生成位置，指定的行将不会生效，僵尸会固定在第一行第一格生成。建议为僵尸随机分配出怪行，或设置好具体的生成位置。';

  @override
  String get missingPlantModuleWarningTitle => '缺少平行宇宙植物所需模块';

  @override
  String get editableModules => '可用编辑模块';

  @override
  String get parameterModules => '默认参数模块';

  @override
  String get addNewModule => '添加新模块';

  @override
  String get selectStage => '选择地图';

  @override
  String get searchStage => '搜索地图名称或代号';

  @override
  String get noStageFound => '未找到相关地图';

  @override
  String get stageTypeAll => '全部';

  @override
  String get stageTypeMain => '主线世界';

  @override
  String get stageTypeExtra => '秘境/活动';

  @override
  String get stageTypeSeasons => '一代/季节';

  @override
  String get stageTypeSpecial => '特殊';

  @override
  String get stageTypeCustomPresets => '自定义预设';

  @override
  String get search => '搜索';

  @override
  String get disablePeavine => '禁用豆藤共生';

  @override
  String get disableArtifact => '禁用神器（庭院模式下自动生效）';

  @override
  String get selectPlant => '选择植物';

  @override
  String get selectAll => '全选';

  @override
  String get searchPlant => '搜索植物';

  @override
  String get noPlantFound => '未找到植物';

  @override
  String noResultsFor(String query) {
    return '没有关于“$query”的结果';
  }

  @override
  String get noModulesInCategory => '该分类下没有模块';

  @override
  String get noEventsInCategory => '该分类下没有事件';

  @override
  String get eventCategoryZombieSpawn => '生成僵尸';

  @override
  String get eventCategoryGridItemSpawn => '生成物品';

  @override
  String get eventCategoryEnvironmental => '环境效果';

  @override
  String get eventCategoryOther => '其他';

  @override
  String addEventForWave(int wave) {
    return '为第 $wave 波添加事件';
  }

  @override
  String get waveLabel => '波次';

  @override
  String get pointsLabel => '点数';

  @override
  String wavePointsShort(int points) {
    return '$points 点';
  }

  @override
  String get noDynamicZombies => '没有动态僵尸';

  @override
  String get moduleTitle_WaveManagerModuleProperties => '波次管理器';

  @override
  String get moduleDesc_WaveManagerModuleProperties => '管理关卡的波次事件总配置';

  @override
  String get moduleTitle_WaveGeneratorProperties => '波次生成器';

  @override
  String get moduleDesc_WaveGeneratorProperties => '功夫世界等早期关卡使用的旧版波次写法';

  @override
  String get moduleTitle_CustomLevelModuleProperties => '庭院模块';

  @override
  String get moduleDesc_CustomLevelModuleProperties => '开启后关卡适配庭院框架，并屏蔽装扮功能';

  @override
  String get powerTileModuleRequiredTitle => '需要能量瓷砖模块';

  @override
  String get powerTileModuleRequiredBody =>
      '添加能量瓷砖工具卡需要关卡中包含能量瓷砖模块。是否添加该模块并继续？';

  @override
  String get conveyorPlantWearCostume => '显示装扮 (iAvatar，已失效)';

  @override
  String get conveyorPlantWearCostumeTooltip =>
      '启用后该植物在传送带上的卡牌将显示其装扮，该功能在当前版本不生效。';

  @override
  String get modifyConveyorAddPoolTitle => '加入传送带池 (Add List)';

  @override
  String get modifyConveyorAddPoolEmpty => '列表为空，请添加植物或工具卡';

  @override
  String get modifyConveyorRemovePoolTitle => '移出传送带池 (Remove List，在庭院模块下不生效)';

  @override
  String get modifyConveyorEntryEditTitle => '编辑具体参数';

  @override
  String plantModuleRequiredMessage(String moduleName) {
    return '要选择此植物，需要添加「$moduleName」模块。';
  }

  @override
  String zombieModuleRequiredMessage(String moduleName) {
    return '要选择此僵尸，需要添加「$moduleName」模块。';
  }

  @override
  String get realmExclusivePlantChooserBlockedTitle => '无法选择该植物';

  @override
  String get realmExclusivePlantChooserBlockedMessage =>
      '秘境专属植物无法在自选模式下选择。请通过预选模式、传送带、卡片掉落等其他方式使用。';

  @override
  String get hiddenPlantChooserBlockedTitle => '无法选择该植物';

  @override
  String get hiddenPlantChooserBlockedMessage =>
      '隐藏植物无法在自选模式下选择。请通过预选模式、传送带、卡片掉落等其他方式使用。\n除祭司小喷菇、植甲拼装者-炎星等特定植物外，其余隐藏植物在游戏卡槽中的图标均会显示为向日葵；小仙人球、魔法豆藤等植物还存在一些异常交互表现，可能影响关卡的整体观感，请谨慎选用。';

  @override
  String get comingSoonPlantBlockedLabel => '未完待续';

  @override
  String get comingSoonPlantBlockedTitle => '未完待续';

  @override
  String get comingSoonPlantBlockedMessage => '植物们仍在茁壮成长。敬请期待后续更新！';

  @override
  String get stayTunedMoonZombieBlockedTitle => '来自宇宙的预告';

  @override
  String get stayTunedMoonZombieBlockedMessage => '月球基地第二章节即将推出，敬请关注！';

  @override
  String get stayTunedTaleZCorpZombieBlockedTitle => '还有高手？';

  @override
  String get stayTunedTaleZCorpZombieBlockedMessage => 'Z公司的第二章节即将推出，敬请期待！';

  @override
  String get stayTunedZombieBlockedTitle => '未完待续';

  @override
  String get stayTunedZombieBlockedMessage => '更多的僵尸要来了。敬请关注后续更新！';

  @override
  String missingModuleForPlantsWarning(String moduleName, String plantList) {
    return '缺少模块「$moduleName」，涉及植物：$plantList';
  }

  @override
  String get moduleTitle_StandardLevelIntroProperties => '转场动画';

  @override
  String get moduleDesc_StandardLevelIntroProperties => '关卡开始时的镜头平移';

  @override
  String get moduleTitle_ZombiesAteYourBrainsProperties => '失败判定';

  @override
  String get moduleDesc_ZombiesAteYourBrainsProperties => '僵尸进屋判负的位置';

  @override
  String get moduleTitle_ZombiesDeadWinConProperties => '死亡结算';

  @override
  String get moduleDesc_ZombiesDeadWinConProperties => '在僵尸死亡后进行结算';

  @override
  String get moduleTitle_BronzeDeadWinConProperties => '铜人阵死亡结算';

  @override
  String get moduleDesc_BronzeDeadWinConProperties =>
      '当所有铜人像和铜人僵尸被消灭后，立即消灭场上的其他僵尸';

  @override
  String get moduleTitle_SpermWhaleModuleProperties => '蓝鲸出没';

  @override
  String get moduleDesc_SpermWhaleModuleProperties =>
      '配置海底世界鲸鱼相关参数，需要场上有磷虾才有效果';

  @override
  String get spermWhaleModuleTitle => '蓝鲸出没设置';

  @override
  String get spermWhaleModuleHelpTitle => '蓝鲸出没模块说明';

  @override
  String get spermWhaleModuleParameters => '参数';

  @override
  String get spermWhaleModuleHelpOverview => '概述';

  @override
  String get spermWhaleModuleHelpOverviewBody =>
      '本模块用于配置特殊海洋生物“鲸鱼”的相关参数，通常用于海底世界关卡。随着磷虾出现，鲸鱼会在场地上方盘旋，并触发对应的红色字幕提示。当场上至少存在三只磷虾时，鲸鱼将正式出现在场地左上角。鲸鱼会优先吞食当前场上的磷虾，随后持续吸取并吞噬植物。噗噗鱼藤释放的鱼藤酮可被鲸鱼吸入，首次吸入后会降低其吞噬速度；当吸入次数达到设定的中毒触发次数后，鲸鱼将强制退场。注意鲸鱼在一关中只会登场一次。';

  @override
  String get spermWhaleModuleHelpFieldsTitle => '参数介绍';

  @override
  String get spermWhaleModuleHelpFieldsBody =>
      '吞噬间隔 (SwallowInterval) 指鲸鱼在正常状态下吞噬植物的间隔。\n中毒时吞噬间隔 (PoisonSwallowInterval) 指鲸鱼在吸入一次鱼藤酮后吞噬植物的间隔。\n吞噬持续时间 (SwallowDuration) 指鲸鱼在场上驻留并吸取植物的总时长。\n中毒触发次数 (PoisonTriggerCount) 指迫使鲸鱼退场所需的鱼藤酮吸入次数。';

  @override
  String get spermWhaleModuleSwallowInterval => '吞噬间隔 (SwallowInterval，单位：秒)';

  @override
  String get spermWhaleModuleHelpSwallowInterval => '正常状态下，两次吞噬之间间隔的时间。';

  @override
  String get spermWhaleModulePoisonSwallowInterval =>
      '中毒时吞噬间隔 (PoisonSwallowInterval，单位：秒)';

  @override
  String get spermWhaleModuleHelpPoisonSwallowInterval => '中毒状态下，两次吞噬之间间隔的时间。';

  @override
  String get spermWhaleModuleSwallowDuration => '吞噬持续时间 (SwallowDuration，单位：秒)';

  @override
  String get spermWhaleModuleHelpSwallowDuration => '鲸鱼在场上驻留并吸取植物的总时长。';

  @override
  String get spermWhaleModulePoisonTriggerCount =>
      '中毒触发次数 (PoisonTriggerCount)';

  @override
  String get spermWhaleModuleHelpPoisonTriggerCount =>
      '噗噗鱼藤的鱼藤酮使鲸鱼强制退场所需的累计吸入次数。';

  @override
  String get spermWhaleModuleNotDeepSeaWarning =>
      '推荐在海底世界地图中使用该模块；在非海底两万里/亚特兰蒂斯地图中使用时，可能会出现不兼容的情况。';

  @override
  String get moduleTitle_PennyClassroomModuleProperties => '阶级定义';

  @override
  String get moduleDesc_PennyClassroomModuleProperties => '全局定义植物阶级，能覆盖其他模块';

  @override
  String get moduleTitle_SeedBankProperties => '种子库';

  @override
  String get moduleDesc_SeedBankProperties => '预设卡槽植物与选卡方式';

  @override
  String get moduleTitle_ConveyorSeedBankProperties => '传送带';

  @override
  String get moduleDesc_ConveyorSeedBankProperties => '预设传送带植物种类与权重';

  @override
  String get moduleTitle_SunDropperProperties => '阳光掉落';

  @override
  String get moduleDesc_SunDropperProperties => '控制天上掉落阳光的频率';

  @override
  String get moduleTitle_LevelMutatorMaxSunProps => '阳光上限';

  @override
  String get moduleDesc_LevelMutatorMaxSunProps => '覆盖关卡最大阳光存储值';

  @override
  String get moduleTitle_MoonExpertProperties => '月球专家';

  @override
  String get moduleDesc_MoonExpertProperties => '固定植物和僵尸阶级，注意在庭院中不生效';

  @override
  String get moduleTitle_LevelMutatorStartingPlantfoodProps => '初始能量豆';

  @override
  String get moduleDesc_LevelMutatorStartingPlantfoodProps => '覆盖关卡开始时的能量豆数量';

  @override
  String get moduleTitle_StarChallengeModuleProperties => '挑战模块';

  @override
  String get moduleDesc_StarChallengeModuleProperties => '设置关卡的限制条件与挑战目标';

  @override
  String get starChallengeNoConfigTitle => '挑战';

  @override
  String get starChallengeNoConfigMessage => '该挑战没有可配置的参数。';

  @override
  String get starChallengeSaveMowersTitle => '不丢车挑战';

  @override
  String get starChallengeSaveMowersNoConfigMessage =>
      '该挑战没有可配置的参数。\n\n通关时所有小推车必须完好无损，注意庭院模块下默认没有小推车。';

  @override
  String get starChallengePlantFoodNonuseTitle => '禁用能量豆挑战';

  @override
  String get starChallengePlantFoodNonuseNoConfigMessage =>
      '该挑战没有可配置的参数。\n\n禁止玩家使用能量豆。';

  @override
  String get moduleTitle_LevelScoringModuleProperties => '积分模块';

  @override
  String get moduleDesc_LevelScoringModuleProperties => '启用积分模块，杀死僵尸获得分数';

  @override
  String get moduleTitle_SouDaCheDamageTextModuleProperties => '伤害数字显示';

  @override
  String get moduleDesc_SouDaCheDamageTextModuleProperties =>
      '在关卡中显示植物每次攻击造成的伤害数值';

  @override
  String get moduleTitle_BowlingMinigameProperties => '沙滩保龄球';

  @override
  String get moduleDesc_BowlingMinigameProperties => '设置禁种线以及禁用铲子';

  @override
  String get moduleTitle_NewBowlingMinigameProperties => '坚果保龄球';

  @override
  String get moduleDesc_NewBowlingMinigameProperties => '在固定位置绘制保龄球警戒线';

  @override
  String get moduleTitle_VaseBreakerPresetProperties => '罐子布局';

  @override
  String get moduleDesc_VaseBreakerPresetProperties => '配置罐子的内容，需要另外两个模块支持';

  @override
  String get moduleTitle_VaseBreakerArcadeModuleProperties => '砸罐子模式';

  @override
  String get moduleDesc_VaseBreakerArcadeModuleProperties =>
      '开启砸罐子模式的基础环境与UI支持';

  @override
  String get moduleTitle_VaseBreakerFlowModuleProperties => '砸罐子动画';

  @override
  String get moduleDesc_VaseBreakerFlowModuleProperties => '控制砸罐子关卡开始前罐子掉下来的动画';

  @override
  String get moduleTitle_EvilDaveProperties => '我是僵尸模式';

  @override
  String get moduleDesc_EvilDaveProperties => '启用我是僵尸模式，需配置僵尸卡槽和预置植物';

  @override
  String get moduleTitle_ZombossBattleModuleProperties => '机甲僵王战';

  @override
  String get moduleDesc_ZombossBattleModuleProperties => '配置机甲僵王战模式参数以及机甲种类';

  @override
  String get moduleTitle_ZombossBattleIntroProperties => '机甲僵王战转场';

  @override
  String get moduleDesc_ZombossBattleIntroProperties => '控制机甲僵王战前的过场动画与血条显示';

  @override
  String get moduleTitle_ZombossLastStandMinigameProperties => '非机甲僵王战';

  @override
  String get moduleDesc_ZombossLastStandMinigameProperties =>
      '配置气功教主、地宫之主等非机甲僵王战';

  @override
  String get moduleTitle_SeedRainProperties => '种子雨';

  @override
  String get moduleDesc_SeedRainProperties => '控制植物、僵尸或能量豆从天而降';

  @override
  String get moduleTitle_LastStandMinigameProperties => '坚不可摧';

  @override
  String get moduleDesc_LastStandMinigameProperties => '设置初始资源，开启布阵阶段';

  @override
  String get moduleTitle_CowboyMinigameProperties => '围栏之战';

  @override
  String get moduleDesc_CowboyMinigameProperties => '每种植一个传送带植物，才开始一波僵尸进攻';

  @override
  String get moduleTitle_SingleHandedProperties => '单枪匹马';

  @override
  String get moduleDesc_SingleHandedProperties => '配置单枪匹马小游戏基础属性';

  @override
  String get moduleTitle_IntroSingleHandedProperties => '单枪匹马教程';

  @override
  String get moduleDesc_IntroSingleHandedProperties => '配置单枪匹马小游戏的教程提示';

  @override
  String get moduleTitle_PVZ1OverwhelmModuleProperties => '排山倒海';

  @override
  String get moduleDesc_PVZ1OverwhelmModuleProperties => '植物一种种一列，建议配合传送带使用';

  @override
  String get moduleTitle_SunBombChallengeProperties => '阳光炸弹';

  @override
  String get moduleDesc_SunBombChallengeProperties => '配置阳光炸弹掉落的爆炸范围和伤害';

  @override
  String get moduleTitle_IncreasedCostModuleProperties => '通货膨胀';

  @override
  String get moduleDesc_IncreasedCostModuleProperties => '植物阳光价格随种植次数递增';

  @override
  String get moduleTitle_DeathHoleModuleProperties => '死亡坑洞';

  @override
  String get moduleDesc_DeathHoleModuleProperties => '植物消失后留下不可种植的坑洞';

  @override
  String get moduleTitle_ZombieMoveFastModuleProperties => '加速进场';

  @override
  String get moduleDesc_ZombieMoveFastModuleProperties => '僵尸入场时快速移动一段距离';

  @override
  String get moduleTitle_InitialPlantProperties => '旧版预置植物';

  @override
  String get moduleDesc_InitialPlantProperties => '预置植物传统写法，可放置冰封植物';

  @override
  String get moduleTitle_InitialPlantEntryProperties => '预置植物';

  @override
  String get moduleDesc_InitialPlantEntryProperties => '放置关卡开始时场上已存在的植物';

  @override
  String get frozenPlantPlacementLastStand => '复活之战模式';

  @override
  String get frozenPlantPlacementSelectedPosition => '选中位置';

  @override
  String get frozenPlantPlacementPlantList => '当前格子中的植物';

  @override
  String frozenPlantPlacementEditPlant(String name) {
    return '编辑 $name';
  }

  @override
  String get frozenPlantPlacementLevel => '阶级';

  @override
  String get frozenPlantPlacementCondition => '初始状态 (Condition)';

  @override
  String get frozenPlantPlacementConditionNull => '无状态 (null)';

  @override
  String get noConditions => '无条件';

  @override
  String get frozenPlantPlacementHelpTitle => '初始植物配置模块说明';

  @override
  String get frozenPlantPlacementHelpOverviewTitle => '简要介绍';

  @override
  String get frozenPlantPlacementHelpOverviewBody =>
      '此模块用于在关卡开始前配置植物布局，与预置植物布局类似，但结构不同且支持特殊状态。';

  @override
  String get frozenPlantPlacementHelpConditionTitle => '特殊状态';

  @override
  String get frozenPlantPlacementHelpConditionBody =>
      '可以为植物设置冰封状态 (icecubed)，常见于冰河世界关卡。';

  @override
  String get frozenPlantPlacementHelpLastStandTitle => '复活之战模式';

  @override
  String get frozenPlantPlacementHelpLastStandBody =>
      '开启复活之战模式后，初始植物将于开始游戏后被销毁。注意中文版没有销毁植物的火焰效果。';

  @override
  String get save => '保存';

  @override
  String get moduleTitle_InitialZombieProperties => '预置僵尸';

  @override
  String get moduleDesc_InitialZombieProperties => '放置关卡开始时场上已存在的僵尸';

  @override
  String get moduleTitle_InitialGridItemProperties => '预置障碍物';

  @override
  String get moduleDesc_InitialGridItemProperties => '放置关卡开始时场上已存在的障碍物';

  @override
  String get moduleTitle_ProtectThePlantChallengeProperties => '保护植物挑战';

  @override
  String get moduleDesc_ProtectThePlantChallengeProperties => '设置关卡中必须保护的植物';

  @override
  String get moduleTitle_ProtectTheGridItemChallengeProperties => '保护物品挑战';

  @override
  String get moduleDesc_ProtectTheGridItemChallengeProperties =>
      '设置关卡中必须保护且不能被破坏的物品';

  @override
  String get moduleTitle_MoldColonyChallengeProps => '霉菌区域';

  @override
  String get moduleDesc_MoldColonyChallengeProps => '设置关卡中禁止种植的霉菌覆盖区域';

  @override
  String get moldColonyLocationsTitle => '关联霉菌布局 (Locations)';

  @override
  String moldColonyLocationsValue(String value) {
    return '当前值：$value';
  }

  @override
  String get moldColonyLevelModulesError => '错误：引用源为 LevelModules，需切换为关卡自定义对象。';

  @override
  String get moldColonyInvalidLinkError =>
      '错误：Locations 必须关联关卡内的 BoardGridMapProps 布局对象。';

  @override
  String moldColonyRepairLink(String alias) {
    return '一键修复关联至：$alias';
  }

  @override
  String get moldColonies => '霉菌';

  @override
  String get moldColonyEmpty => '空地';

  @override
  String get moldColonyHelpOverview => '设置关卡中的霉菌覆盖区域。霉菌会阻止玩家在对应格子上种植植物。';

  @override
  String get moldColonyHelpGridTitle => '网格操作';

  @override
  String get moldColonyHelpGridBody =>
      '点击格子可在空地（可种植）与霉菌（不可种植）之间切换。网格上方会显示当前选中的行列位置。';

  @override
  String get moduleTitle_ZombiePotionModuleProperties => '僵尸药水';

  @override
  String get moduleDesc_ZombiePotionModuleProperties => '配置黑暗时代药水自动生成机制';

  @override
  String get moduleTitle_PiratePlankProperties => '海盗甲板';

  @override
  String get moduleDesc_PiratePlankProperties => '配置海盗港湾地图的甲板行数';

  @override
  String get moduleTitle_RailcartProperties => '矿车轨道';

  @override
  String get moduleDesc_RailcartProperties => '配置矿车与轨道的初始布局';

  @override
  String get moduleTitle_MechanismPlankProperties => '连体矿车';

  @override
  String get moduleDesc_MechanismPlankProperties => '配置功夫世界连体矿车与轨道的初始布局';

  @override
  String get moduleTitle_PowerTileProperties => '能量瓷砖';

  @override
  String get moduleDesc_PowerTileProperties => '配置能量豆联动效果与瓷砖布局';

  @override
  String get moduleTitle_ManholePipelineModuleProperties => '地下管道';

  @override
  String get moduleDesc_ManholePipelineModuleProperties => '配置蒸汽时代的地下传输管道';

  @override
  String get moduleTitle_SmokePollutionModuleProperties => '蒸汽井洞';

  @override
  String get moduleDesc_SmokePollutionModuleProperties => '配置蒸汽时代的毒雾下水道';

  @override
  String get moduleTitle_RoofProperties => '屋顶花盆';

  @override
  String get moduleDesc_RoofProperties => '配置屋顶关卡的预置花盆列数';

  @override
  String get moduleTitle_TideProperties => '潮水系统';

  @override
  String get moduleDesc_TideProperties => '开启关卡中的潮水系统，需最后添加';

  @override
  String get moduleTitle_BombProperties => '炸药桶';

  @override
  String get moduleDesc_BombProperties => '配置功夫世界炸药桶引线的长度与燃烧速度';

  @override
  String get moduleTitle_BronzeProperties => '铜人像';

  @override
  String get moduleDesc_BronzeProperties => '配置功夫世界的铜人像';

  @override
  String get moduleTitle_ArmrackProperties => '兵器架';

  @override
  String get moduleDesc_ArmrackProperties => '配置功夫世界兵器架的生成情况';

  @override
  String get moduleTitle_EnergyGridProperties => '太极地砖';

  @override
  String get moduleDesc_EnergyGridProperties => '配置功夫世界太极地砖的生成情况';

  @override
  String get bronzeModuleHelpTitle => '铜人像模块说明';

  @override
  String get bronzeModuleHelpOverview => '简要介绍';

  @override
  String get bronzeModuleHelpOverviewBody =>
      '该模块用于在草坪上放置关卡开始时已存在的铜人像障碍物，常用于功夫世界小游戏“铜人阵”关卡。铜人像会随时间逐渐褪去铜皮，并在设定的倒计时结束后复活为铜人。铜人像的生命值与其对应的一阶铜人相同。\n抖动距离 (shakeOffset) 指复活动画中抖动中心的偏移量，调整该数值无实际意义。\n注意：此模块本身不包含在场上全部铜人像和铜人僵尸被消灭后立即消灭其余僵尸的效果。若需实现该效果，需要添加「铜人阵死亡结算」模块。';

  @override
  String get bronzeModuleHelpBatches => '复活逻辑';

  @override
  String get bronzeModuleHelpBatchesBody =>
      '每添加一个铜人像，关卡文件中就会对应生成一组条目。复活使用条目中填写的复活时间 (spawnTime)，以秒为单位，与关卡波次无关。复活时间相同的铜人会同时复活。后续批次铜人的复活倒计时承接第一批铜人（例如：第一批为30秒，第二批为45秒，第三批为50秒，则第二批会在第一批复活后的15秒复活，第三批会在第二批复活后的5秒复活）。';

  @override
  String get bronzeModuleShakeOffset => '动画效果';

  @override
  String get bronzeModuleShakeOffsetLabel => '抖动距离';

  @override
  String get bronzeModuleInCell => '当前格子中的铜人像';

  @override
  String get bronzeModuleAddTitle => '添加铜人像';

  @override
  String get bronzeModuleSpawnTimeLabel => '复活时间（单位：秒）';

  @override
  String get moduleTitle_WarMistProperties => '迷雾系统';

  @override
  String get moduleDesc_WarMistProperties => '设置战场迷雾覆盖范围与交互';

  @override
  String get moduleTitle_RainDarkProperties => '环境天气';

  @override
  String get moduleDesc_RainDarkProperties => '设置关卡的雨雪、雷电等环境特效';

  @override
  String get eventTitle_SpawnZombiesFromGroundSpawnerProps => '地底出怪';

  @override
  String get eventDesc_SpawnZombiesFromGroundSpawnerProps => '从地下生成僵尸的出怪事件';

  @override
  String get eventTitle_SpawnZombiesJitteredWaveActionProps => '普通出怪';

  @override
  String get eventDesc_SpawnZombiesJitteredWaveActionProps => '最基础的自然出怪事件';

  @override
  String get eventTitle_FrostWindWaveActionProps => '寒风侵袭';

  @override
  String get eventDesc_FrostWindWaveActionProps => '在指定行吹起寒风冻结植物';

  @override
  String get eventTitle_BeachStageEventZombieSpawnerProps => '退潮';

  @override
  String get eventDesc_BeachStageEventZombieSpawnerProps => '僵尸在退潮时浮现突袭';

  @override
  String get eventTitle_TidalChangeWaveActionProps => '潮水变更';

  @override
  String get eventDesc_TidalChangeWaveActionProps => '改变潮水位置';

  @override
  String get eventTitle_TideWaveWaveActionProps => '召唤洋流';

  @override
  String get eventDesc_TideWaveWaveActionProps => '改变潜艇位置并影响僵尸移速';

  @override
  String get eventTitle_SpawnZombiesFishWaveActionProps => '海底出怪';

  @override
  String get eventDesc_SpawnZombiesFishWaveActionProps =>
      '在场地左侧或右侧生成僵尸或海洋生物，只能在海底世界使用';

  @override
  String get eventTitle_ModifyConveyorWaveActionProps => '传送带修改';

  @override
  String get eventDesc_ModifyConveyorWaveActionProps => '动态添加或移除传送带上的卡片';

  @override
  String get eventTitle_DinoWaveActionProps => '恐龙召唤';

  @override
  String get eventDesc_DinoWaveActionProps => '在指定行召唤一只恐龙协助僵尸';

  @override
  String get eventTitle_DinoTreadActionProps => '恐龙践踏';

  @override
  String get eventDesc_DinoTreadActionProps => '雷龙在一定区域践踏造成伤害';

  @override
  String get eventTitle_DinoRunActionProps => '龙潮突袭';

  @override
  String get eventDesc_DinoRunActionProps => '恐龙沿行冲锋，踩死沿途的植物或僵尸';

  @override
  String get eventTitle_SpawnModernPortalsWaveActionProps => '时空裂缝';

  @override
  String get eventDesc_SpawnModernPortalsWaveActionProps => '在指定位置召唤时空裂缝';

  @override
  String get eventTitle_StormZombieSpawnerProps => '风暴突袭';

  @override
  String get eventDesc_StormZombieSpawnerProps => '沙尘暴或暴风雪运送僵尸';

  @override
  String get eventTitle_RaidingPartyZombieSpawnerProps => '海盗登船';

  @override
  String get eventDesc_RaidingPartyZombieSpawnerProps => '生成若干个飞索僵尸的事件';

  @override
  String get eventTitle_ZombiePotionActionProps => '投放药水';

  @override
  String get eventDesc_ZombiePotionActionProps => '在场地固定位置强行生成障碍物';

  @override
  String get eventTitle_ZombieAtlantisShellActionProps => '贝壳生成';

  @override
  String get eventDesc_ZombieAtlantisShellActionProps => '在指定位置生成海底贝壳';

  @override
  String get eventTitle_SpawnEagleFlagsWaveActionProps => '鹰旗生成';

  @override
  String get eventDesc_SpawnEagleFlagsWaveActionProps => '在指定位置生成罗马鹰旗';

  @override
  String get eventHelpEagleStandardBody =>
      '此事件可在指定位置生成罗马鹰旗。僵尸经过可以拾起鹰旗，阵亡时会掉落，后续僵尸可以反复重新拾起。携带鹰旗的僵尸会为 3×3 范围内的僵尸提供减伤与免控效果。\n普通植物无法攻击鹰旗。鹰旗落地后，磁力菇与吸金磁可以将其摧毁。';

  @override
  String get eventHelpEagleStandardEligibleZombiesTitle => '适用僵尸';

  @override
  String get eventHelpEagleStandardEligibleZombiesBody =>
      '当前版本中，只有罗马僵尸、路障罗马僵尸、铁桶罗马僵尸、百夫长罗马僵尸、罗马石像僵尸、罗马旗帜僵尸和罗马小鬼僵尸可以拾取鹰旗。其他僵尸会无视鹰旗直接经过，但仍能受到鹰旗携带者赋予的加成效果。';

  @override
  String get eventHelpEagleStandardUsage =>
      '选中网格中的格子，点击“+”添加鹰旗。可在同一格放置多面鹰旗，并通过下方卡片删除。网格会根据当前草坪调整大小，草坪外的鹰旗会单独列出。';

  @override
  String get eventTitle_PumpkinHouseActionProps => '南瓜屋生成';

  @override
  String get eventDesc_PumpkinHouseActionProps => '在指定位置生成南瓜屋';

  @override
  String get eventTitle_WaveActionZombieTentProps => '帐篷生成';

  @override
  String get eventDesc_WaveActionZombieTentProps => '在指定位置生成僵尸帐篷，并配置帐篷内僵尸';

  @override
  String get eventTitle_SpawnGravestonesWaveActionProps => '障碍物生成';

  @override
  String get eventDesc_SpawnGravestonesWaveActionProps => '在场地的空位处生成障碍物';

  @override
  String get eventTitle_SpawnZombiesFromGridItemSpawnerProps => '障碍物出怪';

  @override
  String get eventDesc_SpawnZombiesFromGridItemSpawnerProps => '从指定的障碍物种类生成僵尸';

  @override
  String get eventTitle_FairyTaleFogWaveActionProps => '魔力迷雾';

  @override
  String get eventDesc_FairyTaleFogWaveActionProps => '生成覆盖场地、给僵尸提供护盾的迷雾';

  @override
  String get eventTitle_FairyTaleWindWaveActionProps => '童话微风';

  @override
  String get eventDesc_FairyTaleWindWaveActionProps => '把场上所有魔力迷雾吹走的风';

  @override
  String get eventTitle_SpiderRainZombieSpawnerProps => '小鬼空降';

  @override
  String get eventDesc_SpiderRainZombieSpawnerProps => '小鬼僵尸从天而降';

  @override
  String get eventTitle_ParachuteRainZombieSpawnerProps => '降落伞空降';

  @override
  String get eventDesc_ParachuteRainZombieSpawnerProps => '僵尸依靠降落伞从天而降';

  @override
  String get eventTitle_BassRainZombieSpawnerProps => '贝斯手/喷射器空降';

  @override
  String get eventDesc_BassRainZombieSpawnerProps => '贝斯手或喷射器僵尸从天而降';

  @override
  String get eventTitle_BlackHoleWaveActionProps => '黑洞吸引';

  @override
  String get eventDesc_BlackHoleWaveActionProps => '生成黑洞吸引所有植物';

  @override
  String get eventTitle_BarrelWaveActionProps => '滚桶危机';

  @override
  String get eventDesc_BarrelWaveActionProps => '在指定行生成具有不同能力的滚桶';

  @override
  String get eventTitle_SchoolBusWaveActionProps => '冰淇淋车生成';

  @override
  String get eventDesc_SchoolBusWaveActionProps => '在指定行生成冰淇淋车，并配置车内僵尸';

  @override
  String get eventTitle_HamsterZombieSpawnerProps => '僵尸仓鼠球';

  @override
  String get eventDesc_HamsterZombieSpawnerProps => '滚动仓鼠球将僵尸带入场地';

  @override
  String get eventTitle_BungeeWaveActionProps => '蹦极投放';

  @override
  String get eventDesc_BungeeWaveActionProps => '由蹦极僵尸投放一只僵尸到场内';

  @override
  String get eventTitle_ThunderWaveActionProps => '雷云风暴';

  @override
  String get eventDesc_ThunderWaveActionProps => '天降闪电，为植物施加正负电荷状态';

  @override
  String get eventTitle_MagicMirrorWaveActionProps => '魔镜传送';

  @override
  String get eventDesc_MagicMirrorWaveActionProps => '在指定位置生成成对的传送门';

  @override
  String get weatherOption_DefaultSnow_label => '冰河飞雪 (DefaultSnow)';

  @override
  String get weatherOption_DefaultSnow_desc => '冰河再临秘境的下雪效果';

  @override
  String get weatherOption_LightningRain_label => '雷雨天气 (LightningRain)';

  @override
  String get weatherOption_LightningRain_desc => '带闪电的下雨效果';

  @override
  String get weatherOption_DefaultRainDark_label => '阴雨天气 (DefaultRainDark)';

  @override
  String get weatherOption_DefaultRainDark_desc => '场上会进入持续较长时间的黑暗状态';

  @override
  String get iZombiePlantReserveLabel => '植物预留列 (PlantDistance)';

  @override
  String get column => '列';

  @override
  String get iZombieInfoText => '我是僵尸模式下的预置植物和僵尸选择分别要在关卡模块里的预置植物和种子库里设置。';

  @override
  String get vaseRangeTitle => '罐子生成范围与禁用格点';

  @override
  String get startColumnLabel => '起始列 (Min)';

  @override
  String get endColumnLabel => '结束列 (Max)';

  @override
  String get toggleBlacklistHint => '点击格子可切换禁用状态（禁用点将不生成罐子）';

  @override
  String get vaseCapacityTitle => '罐子容量';

  @override
  String vaseCapacitySummary(String current, String total) {
    return '已配置：$current / 有效容量：$total';
  }

  @override
  String get vaseListTitle => '罐子列表';

  @override
  String get addVaseTitle => '添加罐子';

  @override
  String get plantVaseOption => '植物罐子 (绿罐)';

  @override
  String get zombieVaseOption => '僵尸罐子 (紫罐)';

  @override
  String get searchZombie => '搜索僵尸';

  @override
  String get noZombieFound => '未找到僵尸';

  @override
  String get unknownVaseLabel => '未知罐子';

  @override
  String get plantLabel => '植物 (Plant)';

  @override
  String get zombieLabel => '僵尸 (Zombie)';

  @override
  String get itemLabel => '物品 (Collectable)';

  @override
  String get railcartType => '矿车类型 (RailcartType)';

  @override
  String get layRails => '铺设轨道';

  @override
  String get placeCarts => '放置矿车';

  @override
  String get railSegments => '轨道段数';

  @override
  String get railcartCount => '矿车数量';

  @override
  String get clearAll => '清空所有配置';

  @override
  String get moduleCategoryBase => '基础功能';

  @override
  String get moduleCategoryMode => '特殊模式';

  @override
  String get moduleCategoryScene => '场地配置';

  @override
  String get moduleCategoryGimmick => '特殊机制';

  @override
  String get moduleTitle_RocketZombieFlickModuleProperties => '划走火箭筒';

  @override
  String get moduleDesc_RocketZombieFlickModuleProperties =>
      '允许在关卡内使用手指划过火箭筒，将火箭筒小鬼僵尸的火箭筒划飞';

  @override
  String get kongfuRocketFlickDialogTitle => '发现可添加模块';

  @override
  String get kongfuRocketFlickDialogMessage =>
      '添加「划走火箭筒」模块后，可划动屏幕，将小鬼僵尸从火箭筒上拨落。是否添加？';

  @override
  String get customZombie => '自定义僵尸';

  @override
  String get customZombieProperties => '自定义僵尸通用属性';

  @override
  String get zombieTypeNotFound => '未找到僵尸类型对象';

  @override
  String get propertyObjectNotFound => '未找到属性对象';

  @override
  String propertyObjectNotFoundHint(String alias) {
    return '自定义僵尸的属性对象 ($alias)在关卡中未找到。属性定义未指向关卡内部，因此无法在此编辑。';
  }

  @override
  String get baseStats => '基础数值';

  @override
  String get hitpoints => '生命值 (Hitpoints)';

  @override
  String get speed => '移动速度 (Speed)';

  @override
  String get speedVariance => '移速方差 (Variance)';

  @override
  String get eatDPS => '啃食伤害 (EatDPS)';

  @override
  String get hitPosition => '判定与位置参数';

  @override
  String get hitRect => '受击判定 (HitRect)';

  @override
  String get editHitRect => '编辑受击判定 (HitRect)';

  @override
  String get attackRect => '攻击判定 (AttackRect)';

  @override
  String get editAttackRect => '编辑攻击判定 (AttackRect)';

  @override
  String get artCenter => '贴图中心 (ArtCenter)';

  @override
  String get editArtCenter => '编辑贴图中心 (ArtCenter)';

  @override
  String get shadowOffset => '阴影偏移 (ShadowOffSet)';

  @override
  String get editShadowOffset => '编辑阴影偏移 (ShadowOffSet)';

  @override
  String get groundTrackName => '行进轨迹 (GroundTrackName)';

  @override
  String get groundTrackNormal => '普通地面 (ground_swatch)';

  @override
  String get groundTrackNone => '无 (null)';

  @override
  String get appearanceBehavior => '外观与行为设置';

  @override
  String get sizeType => '体型大小 (SizeType)';

  @override
  String get selectSize => '选择体型';

  @override
  String get disableDropFractions => '关闭临界值 (headDropFraction)';

  @override
  String get immuneToKnockback => '免疫植物击退 (CanBeLaunchedByPlants)';

  @override
  String get showHealthBarOnDamage => '受伤显示血条 (EnableShowHealthBar)';

  @override
  String get drawHealthBarTime => '血条显示时长 (DrawHealthBarTime，单位：秒)';

  @override
  String get enableEliteScale => '启用精英缩放 (EnableEliteScale)';

  @override
  String get eliteScale => '缩放比例 (EliteScale)';

  @override
  String get enableEliteImmunities => '启用精英免疫 (EnableEliteImmunities)';

  @override
  String get canSpawnPlantFood => '能否携带能量豆 (CanSpawnPlantFood)';

  @override
  String get canSurrender => '可在游戏结束时投降 (CanSurrender)';

  @override
  String get canTriggerZombieWin => '可食脑判负 (CanTriggerZombieWin)';

  @override
  String get resilience => '僵尸抗性设置 (Resistences)';

  @override
  String get resilienceArmor => '韧性条 (Resilience)';

  @override
  String get enableResilience => '启用韧性';

  @override
  String get resiliencePresetSelect => '选择韧性条配置';

  @override
  String get resilienceAmount => '韧性条数值 (Amount)';

  @override
  String get resilienceWeakType => '韧性条类型 (WeakType)';

  @override
  String get resilienceRecoverSpeed => '韧性条恢复速度 (RecoverSpeed)';

  @override
  String get resilienceDamageThresholdPerSecond =>
      '僵尸每秒承伤上限 (DamageThresholdPerSecond)';

  @override
  String get resilienceBaseDamageThreshold =>
      '韧性条基础伤害上限 (ResilienceBaseDamageThreshold)';

  @override
  String get resilienceExtraDamageThreshold =>
      '韧性条额外伤害上限 (ResilienceExtraDamageThreshold)';

  @override
  String get resilienceCodename => '韧性条代码名 (aliases，仅支持英文字母；不支持空格)';

  @override
  String get resilienceCodenameHint => '例如： CustomResilience0';

  @override
  String get instantKillResistance => '即死抗性（受到秒杀攻击的免疫概率）';

  @override
  String get resiliencePhysics => '物理';

  @override
  String get resiliencePoison => '毒液';

  @override
  String get resilienceElectric => '电能';

  @override
  String get resilienceMagic => '魔法';

  @override
  String get resilienceIce => '寒冰';

  @override
  String get resilienceFire => '火焰';

  @override
  String get resilienceHint => '数值范围0.0-1.0，0.0表示无影响，1.0表示完全免疫';

  @override
  String get resilienceSelectedShieldLabel => '已选韧性条：';

  @override
  String get selectionFilterBySource => '按来源';

  @override
  String get selectionFilterByType => '按类型';

  @override
  String get selectionPreMade => '预设';

  @override
  String get selectionDefinedByUser => '自定义';

  @override
  String get aliasAlreadyTakenTitle => '代号已被占用';

  @override
  String get aliasRenameConfirmTitle => '重命名代号？';

  @override
  String aliasRenameConfirmMessage(String oldAlias, String newAlias) {
    return '将「$oldAlias」重命名为「$newAlias」？本关卡中的所有引用都将更新。';
  }

  @override
  String get resilienceSelectShield => '选择韧性条';

  @override
  String get resilienceCreateCustom => '新建自定义韧性条';

  @override
  String get resilienceEditCustom => '编辑自定义韧性条';

  @override
  String get resilienceTypeAll => '全部类型';

  @override
  String get resilienceNoShieldsFound => '未找到韧性条';

  @override
  String get resilienceShieldInUseCannotDelete => '本关卡中有僵尸正在使用此韧性条，故无法删除。';

  @override
  String get resilienceShieldDeleteTitle => '删除自定义韧性条？';

  @override
  String resilienceShieldDeleteMessage(String alias) {
    return '从本关卡中删除「$alias」？';
  }

  @override
  String get aliasAlreadyExists => '本关卡中已存在该代号。';

  @override
  String zombieTypeLabel(String type) {
    return '僵尸所属种类：$type';
  }

  @override
  String propertyAliasLabel(String alias) {
    return '属性链接代号：$alias';
  }

  @override
  String get ok => '确定';

  @override
  String get helpDialogGotIt => '我明白了';

  @override
  String get width => '宽度';

  @override
  String get height => '高度';

  @override
  String get customZombieHelpIntro => '简要介绍';

  @override
  String get customZombieHelpIntroBody =>
      '这里通过关卡内注入自定义的方式，修改僵尸数据的主要参数。不同种僵尸所含有的特殊属性非常多，软件只对一些通用的属性提供修改。';

  @override
  String get customZombieHelpBase => '基础属性';

  @override
  String get customZombieHelpBaseBody =>
      '自定义僵尸可以自由修改其基础属性，包括血量、移动速度和啃食伤害等。自定义的僵尸不会出现在关卡预览池中。';

  @override
  String get customZombieHelpHit => '部分功能介绍';

  @override
  String get customZombieHelpHitBody =>
      '判定部分中X和Y表示偏移量；W和H分别表示宽度和高度。通过偏移僵尸的贴图中心可以实现隐藏僵尸。在行进轨迹部分选择留空可以让僵尸原地行走。';

  @override
  String get customZombieHelpManual => '手动修改';

  @override
  String get customZombieHelpManualBody =>
      '软件实现自定义注入时会从对应的游戏文件中自动填入原僵尸的相关属性，可以在此基础上手动修改JSON文件。';

  @override
  String editAlias(String alias) {
    return '编辑 $alias';
  }

  @override
  String editNamedEvent(String name) {
    return '编辑$name事件';
  }

  @override
  String editNamedModule(String name) {
    return '编辑$name模块';
  }

  @override
  String get addEventAliasTitle => '添加事件';

  @override
  String get addModuleAliasTitle => '添加模块';

  @override
  String get aliasLabel => '代号 (仅支持英文字母；不支持空格)';

  @override
  String get add => '添加';

  @override
  String get overview => '简要介绍';

  @override
  String get left => '左';

  @override
  String get right => '右';

  @override
  String get weight => '权重';

  @override
  String get maxCount => '最大数量';

  @override
  String get startColumn => '起始列 (Start)';

  @override
  String get endColumn => '结束列 (End)';

  @override
  String get removeItem => '移除物品';

  @override
  String removeItemConfirm(String name) {
    return '确定要移除$name吗？';
  }

  @override
  String groupN(int n) {
    return '第$n组';
  }

  @override
  String rowN(int n) {
    return '第$n行';
  }

  @override
  String get addWind => '添加寒风';

  @override
  String get addDropItem => '添加掉落物品';

  @override
  String get addMirrorGroup => '在上方添加一组魔镜';

  @override
  String pipeN(int n) {
    return '管道$n';
  }

  @override
  String get setStart => '放置起点（入口）';

  @override
  String get setEnd => '放置终点（出口）';

  @override
  String get collectable => '道具（能量豆）';

  @override
  String get plantFood => '能量豆';

  @override
  String get initialPlantLayout => '初始植物布局';

  @override
  String get gridItemLayout => '场地物品布局';

  @override
  String get zombieCount => '总数量 (Total)';

  @override
  String get timeBeforeSpawn => '完全生成前摇时间（单位：秒）';

  @override
  String get waterBoundaryColumn => '变更位置 (ChangeAmount)';

  @override
  String get columnsDragged => '拖拽列数 (ColNumPlantIsDragged)';

  @override
  String get typeIndex => '镜子外观 (TypeIndex)';

  @override
  String get noStyle => '无样式';

  @override
  String styleN(int n) {
    return '样式$n';
  }

  @override
  String get existDurationSec => '存在持续时间（单位：秒）';

  @override
  String get mirror1 => '放置镜子 1';

  @override
  String get mirror2 => '放置镜子 2';

  @override
  String get ignoreGravestone => '无视墓碑 (IgnoreGraveStone)';

  @override
  String zombiePreview(String name) {
    return '$name - 僵尸预览';
  }

  @override
  String get zombiePreviewTooltip => '僵尸预览';

  @override
  String get weatherSettings => '环境天气设置';

  @override
  String get holeLifetimeSeconds => '坑洞存在时间（单位：秒）';

  @override
  String get startingWaveLocation => '初始潮水位置 (StartingWaveLocation)';

  @override
  String get rainIntervalSeconds => '掉落间隔（单位：秒）';

  @override
  String get bowlingFoulLine => '禁种线 (BowlingFoulLine)';

  @override
  String get bowlingFoulLinePreview => '禁种线预览';

  @override
  String get bowlingMinigameParams => '参数';

  @override
  String get bowlingMinigameHelpOverview =>
      '旧版沙滩保龄球的设置模块，作用仅为设置禁种线和禁用铲子，可用于常规关卡。';

  @override
  String get bowlingMinigameHelpFoulLine =>
      '设置禁止种植植物的列数边界，其值从场地最左侧起按0开始计数。例如，从左往右第一格的左侧边界线为0，右侧边界线为1。边界值越小，左侧可操作区域越小。\n在海底世界地图中，游戏会将禁种线数值自动加1。例如填写0时，第1列仍可种植，从第2列起不可种植；此时编辑器允许填写的最小值为-1。';

  @override
  String get stopColumn => '停止列';

  @override
  String get speedUp => '加速倍率';

  @override
  String get baseCostIncreased => '每次增加阳光消耗 (BaseCostIncreased)';

  @override
  String get maxIncreasedCount => '最大增长次数 (MaxIncreasedCount)';

  @override
  String get initialMistPositionX => '迷雾起始列';

  @override
  String get normalValueX => '往右延伸距离（1格为64单位）';

  @override
  String get bloverEffectInterval => '三叶草吹散后恢复秒数';

  @override
  String get dinoType => '恐龙种类';

  @override
  String get dinoRowTitle => '所在行';

  @override
  String dinoRow(int n) {
    return '所在行：$n';
  }

  @override
  String get dinoWaveDuration => '停留波次';

  @override
  String get eventHelpDinoRow => '恐龙出现的行，从0开始计数。海底世界地图可设置为5，即第六行。';

  @override
  String get eventHelpDinoWaveDuration =>
      '恐龙在场上停留的波次数。停留达到设定波数，或与一定数量的僵尸互动后，恐龙会离开场地。该值设为0时，则不限制停留波次，默认在完成互动后离场。';

  @override
  String get unknownModuleTitle => '模块编辑器开发中';

  @override
  String get unknownModuleHelpTitle => '未解析模块说明';

  @override
  String get noEditorForModule => '该模块暂无可用编辑器';

  @override
  String get noEditorForModuleBody =>
      '该模块未注册到关卡解释器，暂无可用编辑器。也有可能是手动修改了模块的objclass导致无法正常读取。';

  @override
  String get invalidEventTitle => '无效事件';

  @override
  String get invalidReference => '引用失效提示';

  @override
  String aliasNotFound(String alias) {
    return '代号\"$alias\"找不到实体';
  }

  @override
  String invalidRefBody(int wave) {
    return '在第$wave波中引用了此事件，但在关卡中未找到对应的实体定义，这通常是因为对象被误删或手动改名导致的。将其存留在关卡中会导致游戏闪退。';
  }

  @override
  String get removeInvalidRef => '从波次容器中移除此无效引用';

  @override
  String get spawnCount => '生成数量控制';

  @override
  String get columnRangeTiming => '位置与时间参数';

  @override
  String get waveStartMessage => '红色字幕警告信息';

  @override
  String get optional => '事件开始时在屏幕中央显示，不支持输入中文';

  @override
  String get eventHelpBeachStageBody =>
      '僵尸会从水下浮现。通常用于巨浪沙滩的潜水僵尸，或者需要在低潮期出现的僵尸。\n与空降事件类似，僵尸会分批次出现。可以指定总数量和出现范围。\n在单个事件中只能出现一种僵尸，若想实现多种僵尸出现需要额外添加若干次事件。';

  @override
  String get eventHelpTidalChangeBody => '本事件用于在波次中改变潮水位置。潮水的更改范围不能超出场地。';

  @override
  String get eventTideWave => '事件类型：召唤洋流';

  @override
  String get eventHelpTideWaveBody => '生成推动潜艇、为僵尸提供移速加成的洋流，常用于海底世界第一章-海底两万里关卡。';

  @override
  String get tideWaveHelpType => '类型说明';

  @override
  String get eventHelpTideWaveType =>
      '左方：洋流从潜艇左侧袭来，向右推动潜艇，并增加左侧僵尸的移动速度.\n右方：洋流从潜艇右侧袭来，向左推动潜艇，并增加右侧僵尸的移动速度。';

  @override
  String get tideWaveHelpParams => '注意事项';

  @override
  String get eventHelpTideWaveParams =>
      '除特殊情况外，持续时间结束后，潜艇会自动回到原位。在潜艇移动时，不能在潜艇上种植植物。';

  @override
  String get tideWaveType => '类型 (Type)';

  @override
  String get tideWaveTypeLeft => '左方 (left)';

  @override
  String get tideWaveTypeRight => '右方 (right)';

  @override
  String get tideWaveDuration => '洋流持续时间 (Duration，单位：秒)';

  @override
  String get tideWaveSubmarineMovingDistance =>
      '潜艇被推动列数 (SubmarineMovingDistance)';

  @override
  String get tideWaveSpeedUpDuration => '僵尸加速持续时间 (单位：秒)';

  @override
  String get tideWaveSpeedUpIncreased => '僵尸移动速度加成 (SpeedUpIncreased)';

  @override
  String get tideWaveSubmarineMovingTime => '潜艇被推动时间 (单位：秒)';

  @override
  String get tideWaveZombieMovingSpeed =>
      '僵尸洋流中移动速度 (ZombieMovingSpeed，1格为64单位)';

  @override
  String get eventZombieFishWave => '事件类型：海底出怪';

  @override
  String get eventHelpZombieFishWaveBody =>
      '本事件用于配置双面夹击的僵尸与海洋生物，只能用于海底世界关卡。坐标中的行、列均从 0 开始计数，因此第 1 行对应 0，第 10 列对应 9。';

  @override
  String get eventHelpZombieFishWaveFish =>
      '使用“添加海洋生物属性”按钮在场地上放置深海鱼群。场地大小因关卡而异，海底世界关卡为 6×10，其他关卡为 5×9。坐标中行对应 Y，列对应 X。';

  @override
  String get eventHelpBatchLevel => '将本波次所有僵尸设为指定阶级（精英僵尸不受影响，保持默认阶级）。';

  @override
  String get eventHelpDropConfig => '当掉落植物列表的植物数等于能量豆数量时会变为掉落植物卡片。';

  @override
  String get fishPropertiesEntryHelp =>
      '点击选中网格后可以添加海洋生物。点击“+”可添加默认海洋生物。点击海洋生物图标可进行复制、删除、自定义等更多操作，自定义的海洋生物会显示蓝色的“C”角标。海洋生物放置在场地外会显示警告。';

  @override
  String get makeFishAsCustom => '设为自定义';

  @override
  String get switchCustomFish => '切换自定义海洋生物';

  @override
  String get selectCustomFish => '选择自定义海洋生物';

  @override
  String get editCustomFishProperties => '编辑自定义海洋生物属性';

  @override
  String get fishPropertiesButton => '海洋生物属性';

  @override
  String get addFishProperties => '添加海洋生物属性';

  @override
  String get editFishProperties => '编辑海洋生物属性';

  @override
  String get fishPropertiesGrid => '海洋生物放置';

  @override
  String get fishSelectedPosition => '已选：';

  @override
  String get fishRow => '行';

  @override
  String get fishColumn => '列';

  @override
  String get fishAtPosition => '当前格子中的海洋生物';

  @override
  String get searchFish => '搜索海洋生物';

  @override
  String get noFishFound => '未找到海洋生物';

  @override
  String get customFishManagerTitle => '自定义海洋生物管理';

  @override
  String get customFishAppearanceLocation => '出现位置：';

  @override
  String get customFishNotUsed => '此自定义海洋生物未被任何波次使用。';

  @override
  String customFishWaveItem(int n) {
    return '第$n波';
  }

  @override
  String get customFishDeleteConfirm => '确定要移除此自定义海洋生物及其属性数据？';

  @override
  String get customFish => '自定义海洋生物说明';

  @override
  String get customFishProperties => '自定义海洋生物属性';

  @override
  String get fishTypeNotFound => '未找到海洋生物对象。';

  @override
  String fishTypeLabel(String type) {
    return '海洋生物：$type';
  }

  @override
  String get customFishHelpIntro => '简要介绍';

  @override
  String get customFishHelpIntroBody =>
      '本界面用于修改自定义海洋生物的参数。软件仅支持对常用属性进行修改，修改动画和特殊属性需手动编辑JSON文件。';

  @override
  String get customFishHelpProps => '属性介绍';

  @override
  String get customFishHelpPropsBody =>
      'HitRect、AttackRect、ScareRect定义海洋生物的碰撞区域。Speed和ScareSpeed控制海洋生物的移动速度。ArtCenter为海洋生物的贴图中心。';

  @override
  String get noEditableFishProps => '未找到可编辑属性。';

  @override
  String get fishPropSpeed => '速度 (Speed)';

  @override
  String get fishPropScareSpeed => '受惊后速度 (ScareSpeed)';

  @override
  String get fishPropDamage => '伤害 (Damage)';

  @override
  String get fishPropHitpoints => '生命值 (Hitpoints)';

  @override
  String get fishPropHitPoints => '生命值 (HitPoints)';

  @override
  String get fishPropHitRect => '受击判定 (HitRect)';

  @override
  String get fishPropAttackRect => '攻击判定 (AttackRect)';

  @override
  String get fishPropScareRect => '受惊判定 (ScareRect)';

  @override
  String get fishPropScarerect => '受惊区域 (Scarerect)';

  @override
  String get fishPropArtCenter => '贴图中心 (ArtCenter)';

  @override
  String get edit => '编辑';

  @override
  String get eventHelpTidalChangePosition =>
      '可以指定潮水变更后的位置。场地最右边为0，最左边为9。允许输入负数在内的整数。';

  @override
  String get eventHelpBlackHoleBody => '常见于功夫世界的事件，时空黑洞会随事件生成，将所有植物向右吸动。';

  @override
  String get eventHelpBlackHoleColumns => '可以输入植物被吸引拖拽的列数，表示植物会受黑洞影响向右移多少格。';

  @override
  String get eventHelpMagicMirrorBody =>
      '魔镜事件会在场地上生成成对的传送门。每对传送门包含入口和出口，二者外观相同。';

  @override
  String get eventHelpMagicMirrorType => '可以更改镜子的外观样式用于区分，该事件中共有3种不同形态的魔镜。';

  @override
  String get eventHelpParachuteRainBody =>
      '僵尸会从屏幕上方空降突袭，通常用于未来世界的机器虫小鬼僵尸、失落之城的飞行员僵尸、摇滚年代的贝斯手僵尸、Z公司的技术支持僵尸等。僵尸的阶级随地图阶级序列。';

  @override
  String get eventHelpParachuteRainLogic =>
      '事件触发后，僵尸会分批次从天而降。可以控制总数量和每批次之间的时间间隔。僵尸会随机降落在选择的列数。若到达了下落总前摇时间，剩下的僵尸会立即出现。\n事件出现前会出现红色字幕显示，在字幕中输入中文会显示乱码。可以不设置僵尸让这个事件变为纯粹的字幕显示。';

  @override
  String get eventHelpModernPortalsBody =>
      '在场地上刷新出固定种类的时空裂缝，常见于摩登世界和回忆之旅。\n一个事件只能配置一个裂缝，若需要在同一波次中添加多个裂缝，请在该波次内添加多个时空裂缝事件。';

  @override
  String get eventHelpModernPortalsType => '游戏内有非常多种裂缝类型，可以在此选择具体的裂缝种类，预览出怪。';

  @override
  String get eventHelpModernPortalsIgnore => '开启此开关后，裂缝不会因为被墓碑冲浪板等障碍物挡住而不生成。';

  @override
  String get eventHelpFrostWindBody =>
      '常见于冰河世界的事件，在指定行生成寒风，寒风会携带冰冻效果，将植物冻结成冰块。';

  @override
  String get eventHelpFrostWindDirection =>
      '可以设置寒风来袭的方向（从左或从右）。注意每一次寒风之间会有一定间隔，若想要实现寒风同时出现，可以尝试添加多个寒风事件。';

  @override
  String get eventHelpModifyConveyorBody =>
      '这个事件可以在游戏运行过程中更改传送带的配置情况，具体参数和传送带模块基本一致，请确保关卡中已经加入了传送带模块。';

  @override
  String get eventHelpModifyConveyorAdd =>
      '可以把新植物或工具卡加入传送带。如果传送带上已经有该植物或工具卡，会把之前的数据覆盖掉。';

  @override
  String get eventHelpModifyConveyorRemove =>
      '移除功能在庭院模板下不生效，需要通过将植物权重强行设置为0来替代此效果。';

  @override
  String get eventHelpDinoBody =>
      '常见于恐龙危机的事件，在指定行召唤一只指定的恐龙进入场地，恐龙会协助僵尸进攻。\n一个事件只能配置一只恐龙，若需要同时出现多只恐龙需要在波次内添加多个恐龙召唤事件。';

  @override
  String get eventHelpDinoDuration =>
      '恐龙在场上停留的时间，单位为波次。时间结束或与足够量的僵尸互动后恐龙会离开场地。';

  @override
  String get eventDinoTread => '事件类型：恐龙践踏';

  @override
  String get eventDinoRun => '事件类型：龙潮突袭';

  @override
  String get eventHelpDinoTreadBody =>
      '雷龙的脚移动到指定区域内，并在数秒后落下，对范围内所有植物和僵尸造成伤害，留下一个持续约 7 秒的脚印，期间无法在该区域种植。';

  @override
  String get eventHelpDinoTreadRowCol =>
      'GridY表示践踏中心的行；GridXMin/GridXMax表示可能的中心列范围（均从 0 开始）。每次践踏覆盖中心周围 3×3 的区域。预览中高亮显示这些中心位置可能波及的所有格子。海底世界地图：行 0–5，列 0–9。';

  @override
  String get dinoTreadPreview => '可能践踏区域预览';

  @override
  String get dinoTreadRowLabel => '行 (GridY)';

  @override
  String get dinoTreadColMinLabel => '最左列 (GridXMin)';

  @override
  String get dinoTreadColMaxLabel => '最右列 (GridXMax)';

  @override
  String get dinoTreadTimeIntervalLabel => '登场间隔 (TimeInterval，单位：秒)';

  @override
  String get columnStartLabel => '起始列 (ColumnStart)';

  @override
  String get columnEndLabel => '结束列 (ColumnEnd)';

  @override
  String get eventHelpDinoRunBody =>
      '触发该事件时，会在2－3行的范围内聚集起恐龙。这些恐龙不会发动能力，而是直接向场内发起冲锋，踩死植物或僵尸。不同的恐龙可以踩死的植物或僵尸数目不同。';

  @override
  String get eventHelpDinoRunRow =>
      'DinoRow表示龙潮中心的行数（预览中为红色）。相邻行（预览中为黄色）也可能聚集恐龙。从0开始计数。海底世界地图可设置为5。';

  @override
  String get dinoRunPreview => '龙潮预览';

  @override
  String get positionAndArea => '位置与区域';

  @override
  String get positionAndDuration => '位置与持续时间';

  @override
  String get rowCol0Index => '行/列（从0开始计数）';

  @override
  String get timeInterval => '时间间隔';

  @override
  String get eventHelpZombiePotionBody =>
      '此事件可以在场地上强行生成药水，能无视植物，可以作为障碍物生成事件的替代。';

  @override
  String get eventHelpZombiePotionUsage =>
      '与障碍物生成的预选池不同，这个事件能精准地在固定格点强行生成障碍物并挤走植物。\n注意在部分缺少墓碑出土特效的地图可能会出现阳光贴图的情况，请谨慎使用此事件。';

  @override
  String get eventHelpShellBody =>
      '此事件可以在指定位置生成海底贝壳。贝壳初始为闭合状态，有僵尸踩中贝壳时，贝壳会张开，将僵尸向前弹射，并在10秒后重新闭合。张开状态下的贝壳可被植物攻击，阻挡平射子弹。每次张开，生成一个随机物品，包括能量豆、鱿鱼、植物卡片或遗迹小鬼僵尸。若3次被僵尸触发，贝壳会游向植物卡槽处，将随机一个卡槽替换为贝壳卡槽。将贝壳种植到场上3次后，卡槽会恢复原植物。';

  @override
  String get eventHelpShellUsage =>
      '选中格子后，点击“+”放置贝壳。场地大小因关卡地图而异，共有5×9和6×10两种规格。';

  @override
  String get eventHelpPumpkinHouseBody =>
      '此事件可在指定位置生成南瓜屋。经过南瓜屋的僵尸将会变为南瓜屋幽灵僵尸。南瓜屋幽灵僵尸有独立的血量，只能被抛投类植物攻击，血量归零时恢复原僵尸。南瓜屋本身也有一定血量，可以被集火打爆。';

  @override
  String get eventHelpPumpkinHouseUsage =>
      '选中格子后，点击“+”放置南瓜屋。场地大小因关卡地图而异，共有5×9和6×10两种规格。';

  @override
  String get eventHelpZombieTentBody =>
      '此事件可以在场地上强行生成回忆之旅中的僵尸帐篷，与小鬼搬运工僵尸背上的帐篷不同的是，这些帐篷不需要黄金地砖，会直接在指定位置生成，并源源不断地召唤僵尸，直至被摧毁。只有场上的所有僵尸帐篷都被摧毁，关卡才会胜利结算。';

  @override
  String get eventHelpZombieTentUsage =>
      '选中格子后，点击“+”放置帐篷，随后可以单独配置每顶帐篷的类型、生命值、召唤僵尸的权重及间隔。';

  @override
  String get eventHelpZombieTentFieldsTitle => '参数说明';

  @override
  String get eventHelpZombieTentFields =>
      '僵尸帐篷有常规帐篷和新年帐篷两种，二者除外观上的区别外无任何区别。\n权重数值越大，僵尸出现的概率越高。如果两种僵尸的权重分别为10和30，那么两者被选中的概率比例约为1:3。\n 僵尸阶级中的0阶表示随地图阶级，庭院模式下即为1阶。\n手动编辑时，注意JSON文件中帐篷所在的列 (Column) 和行 (Row) 都从1开始计数，如\"Column\": 7代表第7列。';

  @override
  String get eventZombieTentSpawn => '事件：帐篷生成';

  @override
  String get zombieTentSectionTitle => '当前格子的帐篷';

  @override
  String get zombieTentTypeLabel => '帐篷类型 (TentType)';

  @override
  String get zombieTentTypeNormal => '常规帐篷';

  @override
  String get zombieTentTypeFestival => '新年帐篷';

  @override
  String get zombieTentHitpoints => '帐篷生命值 (Hitpoints)';

  @override
  String get zombieTentProductionInterval => '生产间隔 (ProductionInterval, 单位：秒)';

  @override
  String get zombieTentZombiesSection => '可能召唤的僵尸 (ZombieTypesToSpawn)';

  @override
  String get zombieTentWeight => '出现权重 (Weight)';

  @override
  String get zombieTentAddZombie => '添加僵尸';

  @override
  String get zombieTentAddTent => '添加帐篷';

  @override
  String get zombieTentDeleteTitle => '删除帐篷';

  @override
  String get zombieTentDeleteConfirm => '确定要删除这顶帐篷吗？';

  @override
  String get eventHelpFairyFogBody =>
      '本事件用于生成覆盖场地、给僵尸提供护盾的魔力迷雾，常用于童话森林关卡，只有微风事件才能吹散。\n迷雾阶级越高，僵尸获得的护盾及免控效果越强。阶级从低到高依次为白色、蓝色、紫色。';

  @override
  String get eventHelpFairyFogRange =>
      'mX和mY为计算中心点，mWidth和mHeight分别表示含中心点向右和向下延伸的距离。';

  @override
  String get eventHelpFairyWindBody => '本事件会产生一股持续的微风，用于将魔力迷雾吹散，常见于童话森林。';

  @override
  String get eventHelpFairyWindVelocity =>
      '该事件作用时可以改变抛射物的速度。1.0表示原速，数值越大子弹运动越快。';

  @override
  String get eventHelpRaidingPartyBody =>
      '常见于海盗港湾的事件，能分批依次生成若干只飞索僵尸进攻。组间间隔 (TimeBetweenGroups) 指两批突袭之间的时间间隔。';

  @override
  String get eventHelpRaidingPartyGroup => '每一组所包含的僵尸数量。';

  @override
  String get eventHelpRaidingPartyCount => '该事件总共生成的僵尸数量。';

  @override
  String get eventHelpGravestoneBody => '此事件用于在波次进行中随机生成障碍物，例如黑暗时代的生成墓碑事件。';

  @override
  String get eventHelpGravestoneLogic =>
      '该事件从上面的格子中随机选取可使用的格子生成目标障碍物。障碍物数量总和不能超过上方位置池的坐标总数，否则多余的物品将无法生成。';

  @override
  String get eventHelpGravestoneMissingAssets =>
      '在部分缺少墓碑出土特效的地图可能会出现阳光贴图的情况，请谨慎使用此事件。';

  @override
  String get eventHelpBarrelWaveBody =>
      '本事件用于生成回忆之旅机制“滚桶危机”中的三种滚桶。滚桶会从场地右侧滚入，碾压沿途的所有植物。';

  @override
  String get barrelWaveHelpTypes => '滚桶类型';

  @override
  String get eventHelpBarrelWaveTypes =>
      '空桶：击破后无事发生。\n小鬼桶：击破后会从中钻出僵尸。僵尸种类可以自行选择，通常为小鬼。\n炸药桶：接触到植物或被击破时会爆炸，对周围 3×3 范围内的植物和僵尸造成伤害。';

  @override
  String get barrelWaveHelpRows => '行数说明';

  @override
  String get eventHelpBarrelWaveRows =>
      '行数从1开始计，地图最上面一行为1，最下面一行为5（或6）。标准地图共有5行，海底世界地图共有6行。';

  @override
  String get eventHelpSchoolBusBody =>
      '此事件用于在指定行生成冰淇淋车。冰淇淋车载着僵尸从右侧缓慢驶入，占据两行。前进路径上被车体碾压到的植物会被直接摧毁。\n若冰淇淋车贴图显示搭乘的是泡泡枪小鬼僵尸和棒棒糖僵尸 (即类型为 schoolbus_special)，且场上存在植物，则会在前进过程中持续释放对应僵尸的技能。\n地刺、钢地刺等植物可以扎破冰淇淋车的轮胎。轮胎破裂后，冰淇淋车会逐渐减速并进入滑行状态，一段时间后停止移动并损毁。';

  @override
  String get schoolBusHelpRows => '行数说明';

  @override
  String get eventHelpSchoolBusRows =>
      '行数从1开始计，地图最上面一行为1，最下面一行为5（或6）。标准地图共有5行，海底世界地图共有6行。';

  @override
  String get eventHelpSchoolBusType =>
      '类型决定生成的冰淇淋车变体。普通 (schoolbus_normal) 为标准冰淇淋车。特殊 (schoolbus_special) 贴图显示泡泡枪小鬼和棒棒糖僵尸，场上存在植物时，车辆会在前进过程中持续释放对应技能。';

  @override
  String get schoolBusHelpZombies => '乘客说明';

  @override
  String get eventHelpSchoolBusZombies =>
      '冰淇淋车具有一定血量，车体被击毁后，车上的僵尸会下车继续前进。可以单独设置每个僵尸的阶数（0阶表示随地图阶级，庭院模式下即为1阶）。';

  @override
  String get schoolBusRow => '冰激凌车所在行 (Row)';

  @override
  String get schoolBusType => '车辆类型 (Type)';

  @override
  String get schoolBusTypeNormal => '普通';

  @override
  String get schoolBusTypeSpecial => '特殊';

  @override
  String get schoolBusHitPoints => '车辆血量 (SchoolBusHitPoints)';

  @override
  String get schoolBusSpeed => '车辆速度 (SchoolBusSpeed)';

  @override
  String get schoolBusZombies => '车内僵尸 (Zombies)';

  @override
  String get schoolBusZombieLevel => '僵尸阶级 (Level)';

  @override
  String get schoolBusAddZombie => '添加僵尸';

  @override
  String get eventHelpThunderWaveBody =>
      '本事件会在波次持续时间内落下闪电，劈中与其他植物相邻的植物，常见于天空之城地图。每道闪电可为植物施加正电荷或负电荷状态。';

  @override
  String get thunderWaveHelpTypes => '电荷效果';

  @override
  String get eventHelpThunderWaveTypes =>
      '2枚正电荷会使植物持续受到上方电球的百分比伤害；2枚负电荷会使植物在一段时间内陷入麻痹状态，无法行动；1正1负两枚电荷会使植物永久减速。植物在已处于上述状态时仍可接收电荷，但不会受到新的电荷效果影响。';

  @override
  String get thunderWaveHelpKillRate => '击杀率';

  @override
  String get eventHelpThunderWaveKillRate =>
      '闪电劈中植物时直接将其杀死的概率（0.0–1.0），电离红掌不受影响。无论是携带正电荷还是负电荷的闪电，均能触发该效果。';

  @override
  String get thunderWaveTypePositive => '劈正电 (positive)';

  @override
  String get thunderWaveTypeNegative => '劈负电 (negative)';

  @override
  String get thunderWaveKillRate => '击杀率 (KillRate)';

  @override
  String get thunderWaveKillRateHint => '闪电劈中植物时直接将其杀死的概率（0.0–1.0），电离红掌不受影响';

  @override
  String get thunderWaveThunders => '雷云风暴';

  @override
  String get thunderWaveAddThunder => '添加闪电';

  @override
  String get thunderWaveThunder => '闪电';

  @override
  String get barrelWaveTypeEmpty => '空桶 (barrelempty)';

  @override
  String get barrelWaveTypeZombie => '小鬼桶 (barrelmoster)';

  @override
  String get barrelWaveTypeExplosive => '炸药桶 (barrelpowder)';

  @override
  String get barrelWaveRowsHint => '行数从1开始计，地图最上面一行为1，最下面一行为5（或6）。';

  @override
  String get barrelWaveAddBarrel => '添加滚桶';

  @override
  String get barrelWaveBarrel => '滚桶';

  @override
  String get barrelWaveRow => '滚桶所在行 (Row)';

  @override
  String get barrelWaveType => '滚桶类型 (Type)';

  @override
  String get barrelWaveHitPoints => '滚桶生命值 (BarrelHitPoints)';

  @override
  String get barrelWaveSpeed => '滚桶移动速度 (BarrelSpeed)';

  @override
  String get barrelWaveZombies => '桶内僵尸 (Zombies)';

  @override
  String get barrelWaveZombieLevel => '僵尸阶级 (Level)';

  @override
  String get barrelWaveAddZombie => '添加僵尸';

  @override
  String get barrelWaveExplosionDamage => '滚桶爆炸伤害 (BarrelBlowDamageAmount)';

  @override
  String get barrelWaveDeleteTitle => '删除滚桶';

  @override
  String get barrelWaveDeleteConfirm => '确认要删除这个滚桶吗？';

  @override
  String get barrelWaveDeleteLastHint => '这是最后一个滚桶。删除后该事件中将不再有滚桶，确定要继续吗？';

  @override
  String get moduleHelpDeathHoleBody => '植物被铲除或被啃食消失后，会在原位置留下一个不可种植的坑洞，持续一段时间。';

  @override
  String get moduleHelpZombieMoveFastBody =>
      '使僵尸在进入场地时快速移动，直到到达指定列数后恢复正常速度。该模块出现于「僵尸清除计划」中。';

  @override
  String get moduleHelpSeedRainBody => '种子雨模块会让物品卡片按照一定时间间隔从天空中掉落。';

  @override
  String get moduleHelpSeedRainParameters => '参数设置';

  @override
  String get moduleHelpSeedRainParametersBody =>
      '权重决定掉落概率，最大数量决定场上最多同时存在的数量。注意大部分僵尸没有适配的僵尸卡片图标。';

  @override
  String get moduleHelpSeedRainPlantLevels => '植物阶级';

  @override
  String get seedRainAddContentTitle => '添加种子雨内容';

  @override
  String get moduleHelpRailcartBody =>
      '在此可以放置矿车与轨道的位置，并设定矿车的款式。点击一次格点进行放置，再次点击进行删除。';

  @override
  String get moduleHelpRailcartRailsBody =>
      '在轨道铺设模式下点击网格铺设轨道。编辑器会自动将同一列连续的格子合并为一段轨道数据。';

  @override
  String get moduleHelpRailcartCartsBody => '点击网格放置或移除矿车。注意在同一段轨道上的矿车容易被堆叠起来。';

  @override
  String get moduleHelpTideBody =>
      '本模块用于开启关卡中的潮水系统，以便后续使用潮水更改事件。注意该模块需要最后添加，否则可能导致闪退。';

  @override
  String get moduleHelpTidePosition =>
      '可以指定潮水的初始位置，即关卡中海岸线所在的位置。场地最右边为0，最左边为9。允许输入负数在内的整数。';

  @override
  String get initialTidePosition => '海岸线配置';

  @override
  String get moduleHelpWeatherBody => '本模块用于控制关卡中的全局环境特效，如雨雪天气。';

  @override
  String get moduleHelpWeatherRef => '这些模块通常直接引用自LevelModules，无需在关卡内自定义参数。';

  @override
  String get moduleHelpZombiePotionBody => '此模块会按一定的时间间隔从右往左在随机行生成指定类型的障碍物。';

  @override
  String get moduleHelpZombiePotionMechanism => '生成机制';

  @override
  String get moduleHelpZombiePotionMechanismBody =>
      '障碍物会在指定的时间间隔区间内随机生成。如果场上指定障碍物数量达到上限，则不会继续生成。';

  @override
  String get moduleHelpZombiePotionPotionTypes => '药水类型';

  @override
  String get moduleHelpZombiePotionTypes =>
      '会在指定的种类中随机选取。如果想间隔固定时间同时生成多个，可以尝试在关卡里添加多次此模块。';

  @override
  String get moduleHelpUnknownBody =>
      '关卡文件是由根节点和多个模块构成的，这些可用模块称为PVZ2Object。每一个Object都有代号(Aliases)，类型(objclass)和数据(objdata)。根节点没有代号。';

  @override
  String get moduleHelpUnknownEvents =>
      '本软件通过读取objclass解析模块类型。当前模块的objclass尚未注册到软件的模块列表中，所以没有匹配的模块编辑器，需要等开发者后续完善。';

  @override
  String get eventHelpInvalidBody =>
      '该事件在波次容器中被引用过，但是解析器在关卡里找不到这个事件的实体定义，Rtid语句块落空。';

  @override
  String get eventHelpInvalidImpact =>
      '若将该失效语句保留在关卡中，会导致关卡无法正常读取导致闪退。需要将该语句手动移除。';

  @override
  String get position => '选中的位置';

  @override
  String get editing => '编辑';

  @override
  String get logic => '逻辑';

  @override
  String get impact => '影响';

  @override
  String get events => '事件';

  @override
  String get referenceModules => '参考模块';

  @override
  String get portalType => '裂缝类型 (PortalType)';

  @override
  String get selectPortalType => '选择裂缝类型';

  @override
  String get noPortalTypesFound => '未找到裂缝类型。';

  @override
  String get noPortalTypeSelected => '未选择裂缝类型。';

  @override
  String get direction => '风向 (Direction)';

  @override
  String get windDirectionLabel => '风向';

  @override
  String get velocityScale => '速度倍率 (VelocityScale)';

  @override
  String get range => '范围参数 (Range)';

  @override
  String get columnRange => '出怪范围（列数）';

  @override
  String get eventColumnRangeBoundaryHint => '场地左边界为0列，右边界为9列，起始列需小于结束列';

  @override
  String get eventColumnRangeExampleHint => '若需要在第 n 到 m 列刷新，起始列填 n-1 终止列填 m';

  @override
  String get zombieLevels => '僵尸阶级';

  @override
  String get missingAssets => '缺少资源';

  @override
  String get usage => '使用说明';

  @override
  String get types => '类型';

  @override
  String get eventBlackHole => '事件类型：黑洞吸引';

  @override
  String get attractionConfig => '吸引配置';

  @override
  String get plantList => '当前格子中的植物';

  @override
  String get firstCostume => '佩戴第一装扮 (Avatar)';

  @override
  String get costumeOn => '启用装扮';

  @override
  String get costumeOff => '禁用装扮';

  @override
  String get outsideLawnItems => '场外物品';

  @override
  String get zombieFromLeft => '从场地左侧出现';

  @override
  String get eventMagicMirror => '事件类型：魔镜传送';

  @override
  String get eventParachuteRain => '事件类型：空降突袭';

  @override
  String get selectZombie => '选择僵尸';

  @override
  String get manholePipeline => '地下管道模块';

  @override
  String get manholePipelineHelpTitle => '地下管道';

  @override
  String get manholePipelineHelpOverview =>
      '定义场景中的地下管道系统，常用于蒸汽时代地图。管道连接两点，僵尸可以通过管道进行移动。';

  @override
  String get manholePipelineHelpEditing =>
      '在上方列表选择管道组，下方网格显示管道布局。点击“放置起点”或“放置终点”切换模式，然后点击网格设定位置。';

  @override
  String get smokePollutionModuleHelpTitle => '蒸汽井洞模块说明';

  @override
  String get smokePollutionModuleHelpOverview => '简要介绍';

  @override
  String get smokePollutionModuleHelpOverviewBody =>
      '在场地上预先放置盖有井盖的下水道，常用于蒸汽时代地图。经过设定时间后，有毒的蒸汽会将井盖喷飞，并向以井口为中心的3×3范围扩散。处于蒸汽中的植物每秒会受到30点伤害。';

  @override
  String get smokePollutionModuleHelpManholes => '使用说明';

  @override
  String get smokePollutionModuleHelpManholesBody =>
      '选中格子后，点击“+”放置下水道。每个下水道均可单独设置喷发时间 (StartTime)，即从关卡开始到井盖被喷飞并释放有毒蒸汽所经过的时间。';

  @override
  String get smokePollutionModuleStartTimeLabel => '喷发时间（单位：秒）';

  @override
  String manholePipelineStartEndFormat(int sx, int sy, int ex, int ey) {
    return '起点: ($sx, $sy)  终点: ($ex, $ey)';
  }

  @override
  String get piratePlank => '海盗甲板模块';

  @override
  String get weatherModule => '环境天气模块说明';

  @override
  String get zombiePotion => '僵尸药水模块';

  @override
  String get zombiePotionHelpTitle => '僵尸药水模块说明';

  @override
  String get eventTimeRift => '事件类型：时空裂缝';

  @override
  String get seedRain => '种子雨模块';

  @override
  String get eventFrostWind => '事件类型：寒风侵袭';

  @override
  String get lastStandInitialResourceSettings => '初始资源设置';

  @override
  String get lastStandManualStartupHint =>
      '添加坚不可摧模块后，会自动在波次管理器模块中启用“手动开始游戏”开关。';

  @override
  String get lastStandHelpTitle => '坚不可摧模块说明';

  @override
  String get lastStandHelpOverviewBody =>
      '启用此模块后，关卡开始时会进入布阵阶段，不会立即出怪，允许玩家消耗初始阳光摆放植物。点击“开始战斗”后才会开始刷新波次。';

  @override
  String get lastStandHelpNotes => '注意事项';

  @override
  String get lastStandHelpNotesBody =>
      '启用坚不可摧后，需要在波次管理器中启用“手动开始游戏”开关，否则僵尸会自动出现。添加或移除坚不可摧模块时，软件会自动管理此开关。';

  @override
  String moduleDependencyRequiredMessage(String moduleName) {
    return '要选择此模块，需要先添加「$moduleName」模块。';
  }

  @override
  String get cowboyMinigameSettings => '围栏之战设置';

  @override
  String get cowboyMinigameBeginString => '提示文本';

  @override
  String get cowboyMinigameBeginStringDefault => '默认文本';

  @override
  String get cowboyMinigameBeginStringCustom => '自由编辑（支持输入中文）';

  @override
  String get cowboyMinigameCustomTextInput => '自定义提示文本';

  @override
  String get cowboyMinigameShowTutorial => '显示教程对话';

  @override
  String get cowboyMinigameBeginStringHint =>
      '添加围栏之战模块后，会自动在传送带模块中启用“手动生成卡片”开关。';

  @override
  String get cowboyMinigameHelpTitle => '围栏之战模块说明';

  @override
  String get cowboyMinigameHelpOverviewBody =>
      '狂野西部的专属小游戏。玩家会在每波开始前随机获得一张植物卡片，每种植一个植物就会出现一波僵尸，消灭所有僵尸即可完成关卡。\n每次种植植物之前，游戏会预览每一行即将出现的僵尸数量、种类及位置，便于玩家斟酌植物的种植选择。';

  @override
  String get cowboyMinigameHelpBeginStringBody =>
      '提示文本会在每次种植植物前与僵尸预览一同显示。选择“默认文本”时，关卡内对话框会显示“种植传送带上的植物以开始关卡！”。也可以自由输入自定义内容。';

  @override
  String get cowboyMinigameHelpTutorialBody =>
      '开启“显示教程对话”后，戴夫和潘妮会在关卡开始前出现，以对话形式交代小游戏的背景。对话内容固定为首次游玩狂野西部-第4天时的剧情。';

  @override
  String get singleHandedTabLabel => '单枪匹马';

  @override
  String get singleHandedBasicParameters => '基础参数';

  @override
  String get singleHandedOverviewBasicConfiguration => '基础配置';

  @override
  String get singleHandedMissileCount => '单次导弹数量';

  @override
  String get singleHandedMissileInterval => '导弹发射间隔';

  @override
  String get singleHandedWarningTime => '预警时间';

  @override
  String get singleHandedRocketSpeed => '导弹速度';

  @override
  String get singleHandedZombieSpeedMultiplier => '僵尸速度倍率';

  @override
  String get singleHandedZombieHealthMultiplier => '僵尸血量倍率';

  @override
  String get singleHandedSpecialMultiplierHint => '特殊波次中的速度/血量会在该值基础上再乘系数';

  @override
  String get singleHandedPlantConfiguration => '植物配置';

  @override
  String get singleHandedPlantConfigurationInfo =>
      '初始植物为开局武器，达到击杀数后自动升级植物。\n初始植物会出现在场地左上角第一格，需要把矿车放置于此处，否则会直接判定游戏失败。';

  @override
  String singleHandedInitialPlantSubtitle(String interval) {
    return '初始植物 · 攻击间隔：$interval';
  }

  @override
  String get singleHandedAttackInterval => '攻击间隔';

  @override
  String get singleHandedAttackIntervalHint => '攻击间隔越小，攻速越快';

  @override
  String get singleHandedAddUpgradePlant => '添加升级植物';

  @override
  String get singleHandedNoUpgradePlants => '暂无升级植物，请添加';

  @override
  String get singleHandedRequiredKills => '所需击杀数';

  @override
  String singleHandedEditUpgradePlant(String plantName) {
    return '编辑：$plantName';
  }

  @override
  String singleHandedUpgradePlantSubtitle(int kills, String interval) {
    return '击杀：$kills · 攻击间隔：$interval';
  }

  @override
  String get singleHandedSpecialWaves => '特殊波次';

  @override
  String get singleHandedSpecialWavesInfo => '用于放置 Boss 波次，速度/血量系数在此前基础值上再相乘。';

  @override
  String get singleHandedAddSpecialWave => '添加特殊波次';

  @override
  String get singleHandedNoSpecialWaves => '暂无特殊波次，请添加';

  @override
  String get singleHandedSpecialWave => '特殊波次';

  @override
  String get singleHandedWave => '波次';

  @override
  String get singleHandedSpeedMultiplier => '速度系数';

  @override
  String get singleHandedHealthMultiplier => '血量系数';

  @override
  String get singleHandedShowHealthBar => '显示血条';

  @override
  String singleHandedWaveNumber(int wave) {
    return '波次 $wave';
  }

  @override
  String get singleHandedHealthBarEnabled => '血条开启';

  @override
  String get singleHandedHealthBarDisabled => '血条关闭';

  @override
  String singleHandedSpecialWaveSubtitle(String speed, String health) {
    return '速度 x$speed · 血量 x$health';
  }

  @override
  String get singleHandedAddTutorial => '添加单枪匹马教程';

  @override
  String get singleHandedConfigureTutorial => '配置单枪匹马教程';

  @override
  String get singleHandedTutorialWaveForStartRocket => '导弹出现波次';

  @override
  String get singleHandedTutorialHelpTitle => '单枪匹马教程说明';

  @override
  String get singleHandedTutorialHelpPromptsTitle => '教程提示';

  @override
  String get singleHandedTutorialHelpPromptsBody =>
      '添加该模块后，关卡开始时、植物首次升级时、首次导弹预警时都会出现相应的教程提示。';

  @override
  String get singleHandedTutorialHelpWaveTitle => '导弹出现波次';

  @override
  String get singleHandedTutorialHelpWaveBody =>
      '该模块还可设置导弹从第几波开始出现，并从该波开始计算发射间隔。例如，若导弹发射间隔为 30 秒、出现波次为第 7 波，则第一批导弹会在第 7 波开始 30 秒后发射。\n注意单独添加此模块并不会使关卡在设定波次天降导弹，对导弹出现波次的配置必须要搭配「单枪匹马」模块才会生效。';

  @override
  String get hamsterballGeneration => '生成逻辑';

  @override
  String get hamsterballTimeBeforeFullSpawn =>
      '全部生成所需时间 (TimeBeforeFullSpawn，单位：秒)';

  @override
  String get hamsterballZombies => '仓鼠球内僵尸 (Zombies)';

  @override
  String get hamsterballAddZombie => '添加僵尸';

  @override
  String get hamsterballEmptyZombies => '列表中没有僵尸';

  @override
  String get hamsterballZombieLevel => '僵尸阶级';

  @override
  String get hamsterballInitialSpeed => '初始速度';

  @override
  String get hamsterballBehavior => '行为';

  @override
  String get hamsterballBehaviorUniform => '匀速运动';

  @override
  String get hamsterballBehaviorSlowdown => '先快后慢';

  @override
  String get hamsterballBehaviorChangeLane => '碰撞换行';

  @override
  String get hamsterballBehaviorDetailUniform => '保持匀速运动';

  @override
  String get hamsterballBehaviorDetailSlowdown => '初始快，碰到植物后变慢';

  @override
  String get hamsterballBehaviorDetailChangeLane => '碰到植物会换行';

  @override
  String hamsterballBehaviorSummary(String value) {
    return '行为 (Behavior)：$value';
  }

  @override
  String get hamsterballHasPlantfood => '携带能量豆 (HasPlantfood)';

  @override
  String get hamsterballHelpTitle => '仓鼠球事件说明';

  @override
  String get hamsterballHelpOverviewTitle => '简要介绍';

  @override
  String get hamsterballHelpOverviewBody =>
      '在十二周年秘境中引入中文版的突袭事件，会召唤滚动的仓鼠球将僵尸带入场地。仓鼠球有三种不同的行为模式，滚动途中碾到的植物会被直接摧毁。\n仓鼠球拥有一定生命值，被击破后会释放球中的僵尸，使其继续前进。地刺、钢地刺等植物可以将仓鼠球扎破并释放其中的僵尸。';

  @override
  String get hamsterballHelpRangeTitle => '滚动范围';

  @override
  String get hamsterballHelpRangeBody => '仓鼠球滚动范围固定为从0列到8列，该字段不影响内容，由编辑器静默写入。';

  @override
  String get hamsterballHelpGenerationTitle => '生成逻辑';

  @override
  String get hamsterballHelpGenerationBody =>
      '每组数量描述一组里出现几个仓鼠球，组间间隔为相邻组的间隔时间，达到全部生成所需时间后不会进行额外分组，剩余仓鼠球将直接全部生成。';

  @override
  String get cowboyMinigameDependencyWarningTitle => '缺少必需模块';

  @override
  String get cowboyMinigameConveyorWarning =>
      '「围栏之战」模块必须与「传送带」模块搭配使用，否则会造成关卡闪退。';

  @override
  String customGravestoneReplacePrompt(String gridItemName) {
    return '一关中只能添加一种自定义墓碑。是否将关卡中原本的自定义墓碑替换为「$gridItemName」？';
  }

  @override
  String get customGravestoneResourceGroupPrompt =>
      '为使庭院墓碑正常显示且不出现阳光贴图，需要在地图中添加\"Modern_Gravestone\"资源组。是否前往自定义地图界面进行添加？可直接以预设自定义地图「现代墓园」为基础进行配置。';

  @override
  String get openCustomStageSelection => '前往自定义地图';

  @override
  String get customGridItemReplaceAction => '替换';

  @override
  String get roofFlowerPotColumns => '花盆范围设置';

  @override
  String get roofFlowerPotStartColumn => '起始列 (StartColumn)';

  @override
  String get roofFlowerPotEndColumn => '终止列 (EndColumn)';

  @override
  String get roofFlowerPotPreview => '花盆预览';

  @override
  String get roofFlowerPotLawnMismatchWarning =>
      '当前地图类型并非屋顶地图，此模块在游戏中可能无法生效，甚至导致闪退。';

  @override
  String get eventConveyorModify => '事件类型：传送带更改';

  @override
  String get bowlingMinigame => '沙滩保龄球模块说明';

  @override
  String get eventPotionDrop => '事件类型：药水投放';

  @override
  String get eventShellSpawn => '事件类型：贝壳生成';

  @override
  String get eventPumpkinHouseSpawn => '事件类型：南瓜屋生成';

  @override
  String get duration => '持续时间';

  @override
  String get eventFairyWind => '事件类型：童话微风';

  @override
  String get eventFairyFog => '事件类型：魔力迷雾';

  @override
  String get eventRaidingParty => '事件类型：海盗登船';

  @override
  String get swashbucklerCount => '总僵尸数 (SwashbucklerCount)';

  @override
  String get sunBomb => '阳光炸弹模块';

  @override
  String get eventSpawnGravestones => '事件类型：障碍物生成';

  @override
  String get eventBarrelWave => '事件类型：滚桶危机';

  @override
  String get eventThunderWave => '事件类型：雷云风暴';

  @override
  String get eventGraveSpawn => '障碍物出怪事件';

  @override
  String get zombieSpawnWait => '僵尸生成延迟';

  @override
  String get change => '更换';

  @override
  String get autoLevel => '自动设置阶级';

  @override
  String get apply => '一键应用';

  @override
  String get applyBatchLevel => '确认批量应用';

  @override
  String get starChallenges => '挑战模块';

  @override
  String get addChallenge => '添加新挑战';

  @override
  String get unknownChallengeType => '未知挑战类型';

  @override
  String get protectedPlants => '保护植物挑战';

  @override
  String get addPlant => '添加植物';

  @override
  String get protectedGridItems => '保护物品挑战';

  @override
  String get addGridItem => '添加目标';

  @override
  String get scope => '范围';

  @override
  String get applyBatch => '批量应用';

  @override
  String get addPlants => '添加植物';

  @override
  String get noPlantsConfigured => '暂无配置，请添加植物';

  @override
  String batchLevelFormat(int level) {
    return '批量设置：$level';
  }

  @override
  String get protectPlants => '保护植物挑战';

  @override
  String get autoCount => '自动计数';

  @override
  String get startingPlantfoodOverride => '初始能量豆数量 (StartingPlantfoodOverride)';

  @override
  String get iconText => '图标文字';

  @override
  String get iconImage => '图标图片';

  @override
  String get maxSunOverride => '最大阳光数值 (MaxSunOverride)';

  @override
  String get maxSunHelpTitle => '阳光上限模块说明';

  @override
  String get maxSunHelpOverview => '该模块原本用于控制潘追关卡不同难度级别，可以用此模块覆盖关卡内能够储存的阳光最大值。';

  @override
  String get moonExpertZombieLevel => '僵尸阶级 (ZombieLevel)';

  @override
  String get moonExpertZombieLevelTooltip =>
      '启用该模块后，关卡中已定义的所有僵尸阶级都会被此处设置的阶级覆盖。';

  @override
  String get moonExpertHelpTitle => '月球专家';

  @override
  String get moonExpertHelpOverview =>
      '该模块常见于月球基地专家模式。启用后，关卡中的所有僵尸都会统一使用指定阶级，所有植物都会被强制设为1阶。\n上述设置会覆盖包括「阶级定义」模块在内的其他植物与僵尸阶级设置。注意在庭院环境下该模块不生效。';

  @override
  String get startingPlantfoodHelpTitle => '初始能量豆模块说明';

  @override
  String get startingPlantfoodHelpOverview =>
      '该模块原本用于控制潘追关卡不同难度级别，可以用此模块覆盖关卡内携带的初始能量豆数量。';

  @override
  String get starChallengeHelpTitle => '挑战模块说明';

  @override
  String get starChallengeHelpOverview =>
      '这里可用选择关卡使用的各项挑战模块。可以同时设置多项挑战目标以及使用多次同种挑战。';

  @override
  String get starChallengeHelpSuggestionTitle => '优化建议';

  @override
  String get starChallengeHelpSuggestion =>
      '部分挑战在游戏内有统计框记录进度，当挑战模块过多时统计数据框可能会被遮挡。';

  @override
  String get remove => '移除';

  @override
  String get plant => '植物';

  @override
  String get zombie => '僵尸';

  @override
  String get initialZombieLayout => '初始僵尸布局';

  @override
  String get manualInput => '手动输入';

  @override
  String get waveManagerModule => '波次管理器模块说明';

  @override
  String get points => '积分';

  @override
  String get row => '行';

  @override
  String get addType => '添加';

  @override
  String get availableZombies => '可用僵尸列表';

  @override
  String get presetPlants => '预选植物 (PresetPlantList)';

  @override
  String get whiteList => '白名单 (WhiteList)';

  @override
  String get blackList => '黑名单 (BlackList)';

  @override
  String get chooser => '自选 (Chooser)';

  @override
  String get preset => '预设 (Preset)';

  @override
  String get seedBankHelp => '种子库模块说明';

  @override
  String get conveyorBeltHelp => '传送带模块说明';

  @override
  String get dropDelayConditions => '刷新延迟 (DropDelayConditions)';

  @override
  String get unitSeconds => '单位：秒';

  @override
  String propertyLabelSeconds(String name, String code) {
    return '$name ($code，单位：秒)';
  }

  @override
  String get speedConditions => '传输速度 (SpeedConditions)';

  @override
  String get speedConditionsSubtitle => '标准值为100，值越大越快';

  @override
  String get addPlantConveyor => '添加植物';

  @override
  String get addTool => '添加工具卡';

  @override
  String get powerTile => '能量瓷砖模块';

  @override
  String get powerTileGridSection => '当前场地';

  @override
  String get powerTileGridHelpPrimary =>
      '点击格子放置瓷砖，再次点击进行删除，若该格已有其他瓷砖将直接替换。场地中非当前选中组的瓷砖会以半透明效果显示。';

  @override
  String get powerTileGridHelpSecondaryMobile => '长按瓷砖可快速更改其所在组，或单独修改其传导延迟。';

  @override
  String get powerTileGridHelpSecondaryDesktop => '右键点击瓷砖可快速更改其所在组，或单独修改其传导延迟。';

  @override
  String get powerTileLinkedTilesSection => '瓷砖列表';

  @override
  String get powerTilePropagationDelayLabel => '传导延迟 (PropagationDelay，单位：秒)';

  @override
  String get powerTilePropagationDelayTooltip =>
      '能量开始传导至其他瓷砖之前的前摇时间（0–5秒），注意该时间不包含传输本身的时间。延迟默认为1.5秒。';

  @override
  String get powerTileDialogEditCell => '编辑瓷砖';

  @override
  String get powerTileDialogTileGroup => '瓷砖所在组';

  @override
  String get powerTileDialogNone => '无';

  @override
  String get powerTileDialogPropagationDelay => '传导延迟 (PropagationDelay，单位：秒)';

  @override
  String get powerTileHelpOverview =>
      '瓷砖分为五组。种植在瓷砖上的植物在触发能量豆大招时，会传导能量，使其他同组瓷砖上的植物也释放一次大招。可以设置能量开始传导的前摇时间。';

  @override
  String get powerTileHelpGridSize => '场地大小因关卡而异，海底世界关卡为6行10列，其他关卡为5行9列。';

  @override
  String powerTileHelpQuickEdit(String interaction) {
    return '快捷编辑：$interaction';
  }

  @override
  String get eventEditorInDevelopment => '事件编辑器开发中';

  @override
  String get level => '阶级';

  @override
  String get missingTideModule => '模块缺失警告';

  @override
  String get levelHasNoTideProperties =>
      '关卡未检测到潮水模块 (TideProperties)，此事件在游戏中可能无法生效，甚至导致闪退。';

  @override
  String get changePositionChangeAmount => '潮水变更配置';

  @override
  String get preview => '潮水位置预览';

  @override
  String get fogPreview => '迷雾预览';

  @override
  String get water => '有潮水';

  @override
  String get land => '无潮水';

  @override
  String get tidePositionOrderHint =>
      '场地最右边坐标为0，最左边为9。注意潮水系统模块需要最后添加，否则可能导致闪退。';

  @override
  String groupConfigN(int n) {
    return '第$n组配置';
  }

  @override
  String get globalParameters => '全局参数';

  @override
  String get timePerGrid => '传输耗时（秒/格）';

  @override
  String get damagePerSecond => '每秒伤害';

  @override
  String get stageMismatch => '地图类型不匹配';

  @override
  String get currentStageNotPirate => '当前地图类型并非海盗港湾，此模块可能在游戏中可能无法生效，甚至导致闪退';

  @override
  String get plankPreview => '甲板预览';

  @override
  String get plankRows => '甲板行数配置';

  @override
  String get plankRowsDeepSea => '海底世界甲板行数配置';

  @override
  String get selectWeatherType => '选择天气类型';

  @override
  String get counts => '数量控制';

  @override
  String get initialCount => '初始数量';

  @override
  String get maximumCount => '最大数量';

  @override
  String get spawnInterval => '生成时间间隔';

  @override
  String get minimumIntervalSeconds => '最小间隔（单位：秒）';

  @override
  String get maximumIntervalSeconds => '最大间隔（单位：秒）';

  @override
  String get potionTypeList => '药水种类列表';

  @override
  String get max => '最大数量 (MaxPotionCount)';

  @override
  String get ignoreGravestoneSubtitle => '开启后裂缝可无视障碍物生成';

  @override
  String get thisPortalSpawns => '该裂缝可能生成以下僵尸：';

  @override
  String get noItemsAddHint => '暂无物品。可添加植物、僵尸或道具。';

  @override
  String get zombieTypeSpiderZombieName => '僵尸代号 (SpiderZombieName)';

  @override
  String get noneSelected => '未选择';

  @override
  String get totalSpiderCount => '总数量 (SpiderCount)';

  @override
  String get perBatchGroupSize => '每批数量 (GroupSize)';

  @override
  String get fallTime => '降落耗时（单位：秒）';

  @override
  String get waveStartMessageLabel => '红色字幕警告信息 (WaveStartMessage)';

  @override
  String get optionalWarningText => '空降开始时在屏幕中央显示的红字警告，不支持输入中文';

  @override
  String rowNShort(int n) {
    return '第$n行';
  }

  @override
  String weightMaxFormat(int weight, int max) {
    return '权重：$weight，最大：$max';
  }

  @override
  String seedRainTypeLabel(String type) {
    return '类型：$type';
  }

  @override
  String seedRainWeightLabel(int weight) {
    return '权重：$weight';
  }

  @override
  String seedRainMaxLabel(int max) {
    return '最大：$max';
  }

  @override
  String get random => '随机';

  @override
  String get noChallengesConfigured => '暂未配置挑战';

  @override
  String get whiteListBlackListHint =>
      '白名单为空时不作限制。未添加平行宇宙模块时，平行宇宙植物加入白名单无效。黑名单为额外禁用植物，优先级高于白名单。';

  @override
  String get conveyorBeltHelpIntro => '传送带模式会按照设定的权重随机生成卡牌。需要配置植物池以及刷新延迟数据。';

  @override
  String get conveyorBeltHelpPool =>
      '某种植物出现的概率为这种植物的权重占所有植物权重的比例。可以通过设置两个阈值动态调整植物的权重。';

  @override
  String get conveyorBeltHelpDropDelay =>
      '控制卡片生成的间隔时间。可以根据挤压的植物数量调整传送间隔。通常植物积压越多，生成越慢。';

  @override
  String get conveyorBeltHelpSpeed =>
      '控制卡片在传送带上移动的物理速度，标准速度为100。可以根据积压数量进行分段变速。';

  @override
  String get cannotAddEliteZombies => '无法添加精英僵尸';

  @override
  String get eliteZombiesNotAllowed => '此处不允许添加精英僵尸';

  @override
  String get yetiZombiesNotAllowed => '此处不允许添加雪人僵尸';

  @override
  String fixToAlias(String alias) {
    return '修复至 $alias';
  }

  @override
  String editPresetZombie(String name) {
    return '编辑预设僵尸：$name';
  }

  @override
  String get missingZombossMechModule => '缺少 ZombossBattleModuleProperties';

  @override
  String get missingZombossBattleModule =>
      '缺少 ZombossLastStandMinigameProperties';

  @override
  String get challengeNoConfig => '此挑战不支持配置。';

  @override
  String get maxPotionCount => '最大药水数量';

  @override
  String potionTypesConfigured(int count) {
    return '药水种类：已配置 $count 个';
  }

  @override
  String pipelinesCount(int count) {
    return '管道：$count';
  }

  @override
  String windN(int n) {
    return '寒风 #$n';
  }

  @override
  String get zombieList => '僵尸列表';

  @override
  String get positionPoolSpawnPositions => '候选位置池 (SpawnPositionsPool)';

  @override
  String get tapCellsSelectDeselect => '点击格子以选中/取消选中，选中的格子即为可能的生成点';

  @override
  String get gravestonePool => '物品池 (GravestonePool)';

  @override
  String get current => '当前';

  @override
  String get eliteZombiesUseDefaultLevel => '精英僵尸使用默认阶级。';

  @override
  String get basicParameters => '基本参数';

  @override
  String get zombieSpawnWaitSec => '僵尸生成延迟（单位：秒）';

  @override
  String get gridTypes => '障碍物类型';

  @override
  String zombiesCount(int count) {
    return '僵尸（$count）';
  }

  @override
  String stormCarriedZombiesCount(int count) {
    return '携带的僵尸（共$count个）';
  }

  @override
  String get eventHelpGraveSpawnBody => '此事件可以在特定障碍物类型上出怪，常用于黑暗时代的亡灵返乡。';

  @override
  String get eventHelpGraveSpawnZombieWait =>
      '从波次开始到僵尸生成的时间间隔，如果计时尚未结束就已经进入下一波，则不会出怪。';

  @override
  String get eventHelpStormOverview =>
      '生成沙尘暴或暴风雪将僵尸快速传送到前线，可以分组出现。极寒风暴出现于回忆之旅，可以冻结经过的植物。';

  @override
  String get eventHelpStormColumnRange =>
      '场地左边界为0列，右边界为9列（海底世界地图为10列）。起始列数要小于结束列数，否则风暴不会生成。';

  @override
  String get spawnParameters => '生成参数';

  @override
  String get sandstorm => '沙尘暴';

  @override
  String get snowstorm => '暴风雪';

  @override
  String get excoldStorm => '极寒风暴';

  @override
  String get columnStart => '起始列 (ColumnStart)';

  @override
  String get columnEnd => '结束列 (ColumnEnd)';

  @override
  String get groupSize => '每批数量 (GroupSize)';

  @override
  String get timeBetweenGroups => '批次间隔 (TimeBetweenGroups，单位：秒)';

  @override
  String applyBatchLevelContent(int level) {
    return '将本波次所有僵尸设为$level阶（精英僵尸不受影响）。';
  }

  @override
  String get randomRow => '随机行';

  @override
  String levelFormat(int level) {
    return '阶级：$level';
  }

  @override
  String get levelAccount => '阶级：随账户';

  @override
  String levelDisplay(String value) {
    return '阶级：$value';
  }

  @override
  String get eventStandardSpawnTitle => '普通出怪事件说明';

  @override
  String get eventGroundSpawnTitle => '地下突袭事件说明';

  @override
  String get eventHelpStandardOverview =>
      '最基础的生成僵尸事件。可以配置每一只僵尸的阶数和行号，0阶表示随地图阶级，庭院模式下即为1阶。\n掉落物默认情况下配置的是携带能量豆的僵尸个数，启用掉落植物功能后会随机从配置的植物库里掉落植物卡片。';

  @override
  String get eventHelpStandardRow => '僵尸可出现在第1–5行中的任意一行，或随机选择一行出现。';

  @override
  String get eventHelpStandardRowDeepSea => '僵尸可出现在第1–6行中的任意一行，或随机选择一行出现。';

  @override
  String get ztPerksSectionTitle => '僵局逃脱词条';

  @override
  String get ztPerksSectionHint => '一只僵尸不能同时拥有多个同类型的词条。';

  @override
  String get ztPerksNone => '尚未添加任何词条。';

  @override
  String get ztPerksAdd => '添加';

  @override
  String get ztPerksAddTitle => '为僵尸添加词条';

  @override
  String get eventHelpJitteredZtPerks =>
      '为单个僵尸选择僵局逃脱词条，带词条的僵尸会额外受到增益效果。所选词条将保存在该僵尸的Titles数组中。每类词条中仅能选择一个，例如“结晶I”和“结晶II”不能同时选择。';

  @override
  String get ztPerkCategoryCrystal => '结晶';

  @override
  String get ztPerkCategoryAttack => '强力';

  @override
  String get ztPerkCategorySpeed => '高速';

  @override
  String get ztPerkCategoryShield => '能量盾';

  @override
  String get ztPerkCategoryGravity => '超重力';

  @override
  String get ztPerkCategoryImmuneControl => '不屈';

  @override
  String get ztPerkCategoryAntiControl => '定力';

  @override
  String get ztPerksViewStats => '查看数值';

  @override
  String get ztPerkPropDamageTakenInterval => '受伤间隔（单位：秒）';

  @override
  String get ztPerkPropDamageTotalTaken => '累计承受伤害次数';

  @override
  String get ztPerkPropDamageTakenPerTime => '单次伤害';

  @override
  String get ztPerkPropHpReduced => '生命值削减';

  @override
  String get ztPerkPropShieldNum => '护盾次数';

  @override
  String get ztPerkPropReducedControlPercent => '控制效果减免';

  @override
  String get ztPerkPropReducedDamagePercent => '伤害减免';

  @override
  String get ztPerkPropImprovedDamagePercent => '攻击力提升';

  @override
  String get ztPerkPropImprovedSpeedPercent => '移动速度提升';

  @override
  String ztPerkDescCrystal(
    String interval,
    String damageCount,
    String damagePerHit,
    String hpReduced,
  ) {
    return '免疫秒杀效果，在$interval秒内只会受到$damageCount次伤害，每次受到的伤害降至$damagePerHit点，生命值降低$hpReduced。';
  }

  @override
  String get ztPerkDescGravity => '不会受到击退和击飞效果影响。';

  @override
  String ztPerkDescShield(String shieldNum) {
    return '前$shieldNum次伤害无效，持续期间免疫秒杀效果。';
  }

  @override
  String ztPerkDescImmuneControl(String percent) {
    return '受到的控制效果降低$percent。';
  }

  @override
  String ztPerkDescAntiControl(String percent) {
    return '处于控制效果影响时，受到的伤害降低$percent。';
  }

  @override
  String ztPerkDescAttack(String percent) {
    return '攻击力增加$percent。';
  }

  @override
  String ztPerkDescSpeed(String percent) {
    return '移动速度增加$percent。';
  }

  @override
  String get ztPerksCategoryInfoTitle => '增益说明';

  @override
  String get ztPerkCategoryDescNumericHint => 'A、B、X、N、P 代表随增益等级变化的数值。';

  @override
  String get ztPerkCategoryDescCrystal =>
      '免疫秒杀效果，在A秒内只会受到N次伤害，每次受到的伤害降至B点，生命值降低X。';

  @override
  String get ztPerkCategoryDescGravity => '免疫击退和击飞效果。';

  @override
  String get ztPerkCategoryDescShield => '前N次伤害无效，持续期间免疫秒杀效果。';

  @override
  String get ztPerkCategoryDescImmuneControl => '受到的控制效果降低P%。';

  @override
  String get ztPerkCategoryDescAntiControl => '处于控制效果影响时，受到的伤害降低P%。';

  @override
  String get ztPerkCategoryDescAttack => '攻击力增加P%。';

  @override
  String get ztPerkCategoryDescSpeed => '移动速度增加P%。';

  @override
  String get warningStageSwitchedTo5Rows =>
      '当前关卡的地图只有5行，但部分数据引用了第6行。这些对象在关卡中可能无法正确显示。';

  @override
  String warningObjectsOutsideArea(int rows, int cols) {
    return '部分对象在场外（场地范围为$rows×$cols）。';
  }

  @override
  String get izombieModeTitle => '我是僵尸模式';

  @override
  String get izombieModeSubtitle => '启用后将转变为放置僵尸的玩法，选卡方式将被锁定';

  @override
  String get reverseZombieFactionTitle => '反转僵尸阵营';

  @override
  String get reverseZombieFactionSubtitle =>
      '启用后放置的僵尸属于植物阵营，可用于“僵尸大战僵尸”(ZvZ)玩法';

  @override
  String get initialWeight => '初始权重';

  @override
  String get plantLevelLabel => '植物阶级';

  @override
  String get missingIntroModule => '模块缺失警告';

  @override
  String get missingIntroModuleHint =>
      '关卡未检测到机甲僵王战转场模块 (ZombossBattleIntro)，可能无法正常运行，请添加转场模块后重新选择机甲。';

  @override
  String get zombossMechType => '僵王机甲类型';

  @override
  String get zombossMechSelection => '僵王机甲选择';

  @override
  String get zombossMechBaseHint =>
      '由僵尸博士亲手打造并驾驶的僵尸机甲，常见于各个世界或模式的终极挑战。更改基础机甲后，下方的可选变体也会随之变化。';

  @override
  String get zombossMechSelectBaseTitle => '选择基础机甲';

  @override
  String get zombossMechUsedProperties => '使用的属性';

  @override
  String get zombossMechVariationLabel => '变体';

  @override
  String get zombossMechVariationHint =>
      '关卡中使用的具体机甲类型 (ZombossMechType)，可选项取决于上方选择的基础机甲。更改类型时，机甲的阶段数和出现位置也会相应变化。';

  @override
  String get zombossBattleSelection => '非机甲僵王选择';

  @override
  String get zombossBattleSelectBaseTitle => '选择基础僵王';

  @override
  String get zombossBattleLeaveUndergroundTitle => '切换基础僵王';

  @override
  String zombossBattleLeaveUndergroundBody(String zombossName) {
    return '您即将从$zombossName切换至其他基础僵王，将会为您自动清除关卡中的「终结技计时」模块。是否同时清除「地宫坑道」模块？';
  }

  @override
  String get zombossBattleKeepTunnelDefend => '保留地宫坑道';

  @override
  String get zombossBattleRemoveTunnelDefend => '同时清除';

  @override
  String get zombossBattleBaseHint =>
      '在僵尸博士没有穿越到的世界或秘境里统率一方的僵尸王者，有着与僵王机甲相似的阶段与出场设定。更改基础僵王后，僵王对应的资源组也会随之变化。';

  @override
  String get zombossBattleVariationLabel => '变体';

  @override
  String get zombossBattleVariationHint =>
      '关卡中使用的具体僵王类型 (ZombossTypeName)，可选项取决于上方选择的基础僵王。';

  @override
  String get zombossBattleStartingSunLabel => '初始阳光 (StartingSun)';

  @override
  String get zombossBattleStartingSunHint => '进入关卡时拥有的阳光数量。';

  @override
  String get zombossBattleStartingPlantfoodLabel => '初始能量豆 (StartingPlantfood)';

  @override
  String get zombossBattleStartingPlantfoodHint => '进入关卡时拥有的能量豆数量。';

  @override
  String get zombossBattleInitialGridColLabel => '初始列数 (ZombossInitialGridCol)';

  @override
  String get zombossBattleInitialGridColHint => '设置僵王初始出现在场地的第几列。';

  @override
  String get zombossBattleInitialGridRowLabel => '初始行数 (ZombossInitialGridRow)';

  @override
  String get zombossBattleInitialGridRowHint => '设置僵王初始出现在场地的第几行。';

  @override
  String get zombossBattleSkipPlantingLabel => '跳过布阵阶段 (SkipPlanting)';

  @override
  String get zombossBattleSkipPlantingHint => '启用后，僵王战前将不会出现坚不可摧同款的准备环节。';

  @override
  String get parameters => '关卡参数';

  @override
  String get reservedColumnCount => '预留列 (ReservedColumnCount)';

  @override
  String get reservedColumnCountHint => '表示右边预留不能种植植物的列数，通常预留两列以上。';

  @override
  String get reservedColumnPreview => '预留列位置预览';

  @override
  String get protectedList => '保护目标列表';

  @override
  String get plantLevelsFollowGlobal => '此模块中的植物随玩家账号阶级，可以使用全局阶级定义模块统一阶级。';

  @override
  String get protectPlantsOverview => '定义关卡中必须保护的植物。如果这些植物被僵尸吃掉或摧毁，关卡失败。';

  @override
  String get protectPlantsAutoCount => '编辑器会自动跟随您添加的植物数量更新需要保护的植物数量。';

  @override
  String positionsCount(int count) {
    return '候选位置数：$count';
  }

  @override
  String totalItemsCount(int count) {
    return '待生成物品总数：$count';
  }

  @override
  String get itemCountExceedsPositionsWarning => '警告：物品总数超过了候选位置数，部分物品将无法生成！';

  @override
  String get gravestoneBlockedInfo =>
      '此事件中墓碑这类和植物冲突的障碍物会因为植物阻挡而无法生成，强制生成需要采用投放药水事件等其它方法。';

  @override
  String get enterConditionValue => '输入条件值';

  @override
  String get customInputHint => '自定义输入需准确无误';

  @override
  String get presetConditions => '预设条件';

  @override
  String get selectFromPresetHint => '从预设条件列表中选择';

  @override
  String get potionTypes => '药水种类列表 (PotionTypes)';

  @override
  String get noPotionTypes => '暂无配置，请添加药水类型';

  @override
  String get conveyorCardPool => '传送带卡片池';

  @override
  String get maxLimits => '上限控制 (Max Limits)';

  @override
  String get maxCountThreshold => '最大数量阈值';

  @override
  String get weightFactor => '达标后权重倍率';

  @override
  String get minLimits => '下限控制 (Min Limits)';

  @override
  String get minCountThreshold => '最小数量阈值';

  @override
  String get followAccountLevel => '0阶植物将使用玩家账号中的对应阶级';

  @override
  String get enablePointSpawning => '启用点数出怪';

  @override
  String get pointSpawningEnabledDesc => '已启用 (使用额外点数出怪)';

  @override
  String get pointSpawningDisabledDesc => '未启用 (仅使用波次事件)';

  @override
  String get pointSettings => '点数分配设置';

  @override
  String get startingWave => '起始波次 (StartingWave)';

  @override
  String get startingPoints => '起始点数 (StartingPoints)';

  @override
  String get pointIncrement => '每波点数增量 (PointIncrementPerWave)';

  @override
  String get zombiePool => '僵尸池 (ZombiePool)';

  @override
  String get protectGridItems => '保护物品挑战';

  @override
  String get waveManagerHelpOverview =>
      '波次管理器是波次事件容器的前置定义。只有添加了波次管理器模块，软件才会开放波次事件编辑入口。';

  @override
  String get waveManagerHelpPoints =>
      '点数出怪会根据僵尸消耗的点数在有效波次中额外刷新僵尸。常规波次点数上限为60000，旗帜波点数会变为2.5倍。点数为正数时，出怪使用的僵尸从僵尸池中选取。在波次容器编辑页面内可查看每种僵尸的出现期望。点数为负数时，会从自然出怪事件中扣除相应点数的僵尸。注意点数出怪池不应该写精英僵尸、雪人僵尸以及自定义僵尸。';

  @override
  String get pointsSection => '点数出怪';

  @override
  String get globalPlantLevels => '阶级定义模块说明';

  @override
  String get globalPlantLevelsOverview =>
      '此模块用于定义植物的全局阶级。它通常优于种子库中的阶级设置，且可以针对特定植物单独设置阶级。';

  @override
  String get globalPlantLevelsScope => '设置的阶级将应用于关卡内玩家使用的该种植物，包括保护植物、卡片掉落等。';

  @override
  String get noWaveManagerPropsFound => '未找到波次管理器 (WaveManagerProperties) 模块。';

  @override
  String get itemsSortedByRow => '当前格子中的物品';

  @override
  String get stormEvent => '风暴突袭事件说明';

  @override
  String get zombieLevelsBody =>
      '风暴内僵尸的阶级和所在行不能独立设置。因此对僵尸阶级进行手动编辑是无效的，阶级默认随地图阶级序列。';

  @override
  String get batchLevel => '批量设置阶级';

  @override
  String get start => '起始';

  @override
  String get end => '结束';

  @override
  String get backgroundMusicLevelJam => '魔音音乐切换 (LevelJam)';

  @override
  String get onlyAppliesRockEra => '此事件触发时切换背景音乐，仅对摇滚年代地图有效。';

  @override
  String get appliesToAllNonElite => '将本波次所有僵尸设为指定阶级（精英僵尸不受影响，保持默认阶级）。';

  @override
  String get dropConfigPlants => '掉落物（植物卡片）配置';

  @override
  String get dropConfigPlantFood => '掉落物（能量豆）配置';

  @override
  String get waveDropConfigTitle => '掉落物配置';

  @override
  String get waveDropPlantSelectionLabel => '指定掉落植物 (SpawnPlantName)';

  @override
  String get waveDropTotalLabel => '携带掉落物的僵尸总数 (AdditionalPlantfood)';

  @override
  String get waveDropAddZombiesFirst => '请先为本波次添加僵尸，再配置掉落物。';

  @override
  String get waveDropIncreaseTotalBeforePlants => '请先增加携带掉落物的僵尸总数，再添加植物卡片。';

  @override
  String waveDropPlantFoodOnlyCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count 个能量豆',
      one: '1 个能量豆',
    );
    return '$_temp0';
  }

  @override
  String waveDropPlantsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count 张植物卡片',
      one: '1 张植物卡片',
    );
    return '$_temp0';
  }

  @override
  String get description => '描述';

  @override
  String get descriptiveName => '提示名称 (DescriptiveName)';

  @override
  String get count => '数量 (Count)';

  @override
  String get targetDistance => '花坛距离 (TargetDistance)';

  @override
  String get starChallengeTargetDistanceHint => '数值表示从左边线起的列数，数值越大离房屋越远，可输入小数。';

  @override
  String get targetSun => '目标阳光 (TargetSun)';

  @override
  String get maximumSun => '阳光限额 (MaximumSun)';

  @override
  String get holdoutSeconds => '保持时间 (HoldoutSeconds)';

  @override
  String get zombiesToKill => '击杀个数 (ZombiesToKill)';

  @override
  String get timeSeconds => '时间限制（单位：秒）';

  @override
  String get speedModifier => '增幅倍率 (SpeedModifier)';

  @override
  String get starChallengeSpeedModifierHint => '填入 0.5 表示僵尸移动速度提升 50%。';

  @override
  String get sunModifier => '降低倍率 (SunModifier)';

  @override
  String get starChallengeSunModifierHint => '填入 0.2 表示阳光获取量降低 20%。';

  @override
  String get starChallengeChineseUnsupportedHint => '不支持显示中文。';

  @override
  String get maximumPlantsLost => '植物损失上限 (MaximumPlantsLost)';

  @override
  String get maximumPlants => '植物数量上限 (Maximum Plants)';

  @override
  String get targetScore => '目标分数 (targetScore)';

  @override
  String get plantBombRadius => '植物爆炸半径';

  @override
  String get plantType => '植物类型';

  @override
  String get gridX => '列数';

  @override
  String get gridY => '行数';

  @override
  String get noCardsYetAddPlants => '暂无卡片，请添加植物或工具卡';

  @override
  String get mustProtectCountAll => '必须保护的数量（0表示全部保护）：';

  @override
  String get gridItemType => '物品类型';

  @override
  String get zombieBombRadius => '僵尸爆炸半径';

  @override
  String get plantDamage => '对植物伤害';

  @override
  String get zombieDamage => '对僵尸伤害';

  @override
  String get initialPotionCount => '初始药水数量 (InitialPotionCount)';

  @override
  String get operationTimePerGrid => '传输耗时（秒/格）';

  @override
  String get levelLabel => '阶级：';

  @override
  String get fairyFogType => '迷雾阶级 (FogType)';

  @override
  String fairyFogLevel(int level) {
    return '$level阶';
  }

  @override
  String get fairyFogMovingTime => '移动时间 (MovingTime，单位：秒)';

  @override
  String get fairyFogRangeX => '起始列 (mX，从0开始计数)';

  @override
  String get fairyFogRangeY => '起始行 (mY，从0开始计数)';

  @override
  String get fairyFogRangeWidth => '范围宽度 (mWidth，单位：格)';

  @override
  String get fairyFogRangeHeight => '范围高度 (mHeight，单位：格)';

  @override
  String get fairyWindParameters => '微风参数';

  @override
  String get fairyWindDuration => '持续时间 (Duration，单位：秒)';

  @override
  String get modifyConveyorMissingModule => '关卡中未检测到「传送带」模块，此事件可能不会生效。';

  @override
  String get renaiWavePreviewEmpty => '模块中未配置任何雕像或原石像的数据';

  @override
  String get decompressZlib => '解压ZLib';

  @override
  String get compressWithZlib => '压缩为ZLib';

  @override
  String get seedRainUnknownItem => '未知物品';

  @override
  String get mistParameters => '迷雾参数';

  @override
  String get increasePerSun => '单次增加间隔 (SunCountdownIncreasePurSun)';

  @override
  String get inflationParams => '膨胀参数';

  @override
  String get baseCostIncreaseLabel => '每次增加消耗 (BaseCostIncreased)';

  @override
  String get maxIncreaseCountLabel => '最大增长次数 (MaxIncreasedCount)';

  @override
  String get inflationMaxIncreaseCountWarning =>
      '由于模块本身的问题，目前更改最大增长次数设置暂时无效，游戏只能读取默认值10次。';

  @override
  String get inflationHelpTitle => '通货膨胀模块说明';

  @override
  String get inflationHelpOverview => '每次种植植物后，该植物的阳光消耗会增加。类似于一代无尽模式紫卡的机制。';

  @override
  String get inflationHelpParametersTitle => '参数说明';

  @override
  String get inflationHelpParametersBody => '可以调节每次种植增加的阳光数值以及价格最多增加的次数。';

  @override
  String get selectGroup => '选择组';

  @override
  String get sunBombHelpOverview => '简要介绍';

  @override
  String get sunBombHelpBody =>
      '本模块是未来世界小游戏太阳风暴的必要模块，使用后天降阳光会变为紫色可引爆的阳光炸弹。阳光炸弹对不同阵营的杀伤可以区别填写。';

  @override
  String get bombProperties => '炸药桶模块';

  @override
  String get bombPropertiesHelpBody =>
      '本模块是配置功夫世界炸药桶小游戏的必要模块，使用后炸药桶会出现在小推车的位置，并引出一条可点燃的引线。若有火星沿着引线到达炸药桶处，炸药桶会爆炸，摧毁以自身为中心3×3范围内的植物。';

  @override
  String get bombPropertiesHelpFuse => '引线长度';

  @override
  String get bombPropertiesHelpFuseBody =>
      '引线长度按行设置，从第1行开始，自上而下，每行代表数组中的一个值，数值表示引线向右延伸的格数。标准地图共有5行，海底世界地图共有6行，打开本界面时，数组长度会自动适配当前地图。';

  @override
  String get bombPropertiesFlameSpeed => '引线燃烧速度 (FlameSpeed)';

  @override
  String get bombPropertiesFuseLengths => '引线长度 (FuseLengths)';

  @override
  String get bombPropertiesFuseLengthsHint => '按行设置引线向右延伸的格数，每行一个值';

  @override
  String get damage => '爆炸伤害 (Damage)';

  @override
  String get explosionRadius => '爆炸半径 (ExplosionRadius)';

  @override
  String get plantRadius => '植物爆炸半径';

  @override
  String get zombieRadius => '僵尸爆炸半径';

  @override
  String get radiusPixelsHint => '爆炸半径单位为像素，1格约60像素';

  @override
  String get enterMaxSunHint => '输入关卡阳光上限（如 9900）';

  @override
  String get enterStartingPlantfoodHint => '输入初始能量豆数量（0个及以上）';

  @override
  String get threshold => '阈值';

  @override
  String get delay => '延迟';

  @override
  String get seedBankLetsPlayersChoose =>
      '种子库可以允许玩家选择已有的植物，在庭院模式下可以定义全局阶级且实现全植物可用。';

  @override
  String get iZombieModePresetHint =>
      '启用我是僵尸模式后，需要预设关卡的可用僵尸。此时选卡模式强制为预选。如果关卡中同时存在植物卡槽模式和僵尸卡槽模式，需将卡槽锁定至相同阶级。';

  @override
  String get invalidIdsHint =>
      '非法的代号在卡槽中会空缺。在植物模式下僵尸代号非法，反之亦然。可以用此特点在关卡里创建两个种子库，拼接两种模式的卡槽。注意要将僵尸卡槽置于前面。';

  @override
  String get seedBankWhiteAndBlacklistTitle => '黑白名单';

  @override
  String get seedBankIZombieHelpTitle => '我是僵尸模式';

  @override
  String get seedBankSlotOccupancyTitle => '卡槽占位';

  @override
  String get seedBankAdvancedGameplayTitle => '进阶玩法';

  @override
  String get seedBankAdvancedGameplayBody =>
      '当选择模式是预选时，将选卡模块放在传送带模块前面可以让传送带中的植物消耗阳光种植，放在后面可以让预选卡中的植物不消耗阳光。';

  @override
  String get basicRules => '基础规则';

  @override
  String get selectionMethod => '选卡模式';

  @override
  String get emptyList => '列表为空';

  @override
  String get plantsAvailableAtStart => '开局自带的植物';

  @override
  String get presetPlantListReorderHint => '可以长按并拖动 ⋮⋮ 来调整顺序';

  @override
  String get presetPlantListReorderHintDesktop => '可以拖动 ⋮⋮ 来调整顺序';

  @override
  String get whiteListDescription => '仅允许选择这些植物（空则不限制）';

  @override
  String get blackListDescription => '禁止选择这些植物';

  @override
  String get availableZombiesDescription => '我是僵尸模式下供玩家使用的僵尸';

  @override
  String get izombieCardSlotsHint =>
      '只有部分僵尸在我是僵尸模式 (IZ) 中有对应的卡槽和阳光消耗，这些僵尸可以在僵尸选择界面的「其他分类」中找到。';

  @override
  String get seedBankPresetModeHint => '选择模式为预选时，无论预选卡片数量多少都会立刻进入游戏。';

  @override
  String get seedBankPlantLevelLabel => '植物阶级 (0-5)';

  @override
  String get seedBankSlotCountLabel => '卡槽数量 (0-9)';

  @override
  String get seedBankCourtyardSlotsHint => '庭院模式下，对卡槽数量的更改无效，自选模式会锁定8槽。';

  @override
  String get seedBankAddGridItemsTitle => '添加障碍物';

  @override
  String get seedBankAddGridItemsSubtitle => '将可种植的障碍物加入预选植物列表，可重复添加';

  @override
  String seedBankGridItemCount(int count) {
    return '预选列表中已有$count个';
  }

  @override
  String get seedBankGridItemsPresetOnlySwitchWarning =>
      '「添加障碍物」功能仅在预选模式下生效，切换至自选模式后，该功能将被关闭。是否继续切换？';

  @override
  String get starChallengeSelectConditions => '选择状态';

  @override
  String get starChallengeEditConditions => '编辑状态';

  @override
  String get selectToolCard => '选择工具卡';

  @override
  String get searchGridItems => '搜索障碍物';

  @override
  String get searchStatues => '搜索复兴雕像或原石像';

  @override
  String get noItems => '无物品';

  @override
  String get addedToFavorites => '已添加至收藏';

  @override
  String get removedFromFavorites => '已从收藏移除';

  @override
  String selectedCountTapToSearch(int count) {
    return '已选 $count，点击搜索';
  }

  @override
  String get noFavoritesLongPress => '暂无收藏，长按图标即可收藏';

  @override
  String get gridItemCategoryAll => '全部物品';

  @override
  String get gridItemCategoryScene => '场景布置';

  @override
  String get gridItemCategoryTrap => '互动陷阱';

  @override
  String get gridItemCategorySpawnableObjects => '生成物品';

  @override
  String get customLocalParams => '自定义本地参数';

  @override
  String get currentModeLocal => '当前: 本地编辑 (@CurrentLevel)';

  @override
  String get currentModeSystem => '当前: 系统默认 (@LevelModules)';

  @override
  String get paramAdjust => '参数调节';

  @override
  String get firstDropDelay => '首次掉落延迟 (InitialSunDropDelay，单位：秒)';

  @override
  String get initialDropInterval => '初始掉落间隔 (SunCountdownBase，单位：秒)';

  @override
  String get maxDropInterval => '最大掉落间隔 (SunCountdownMax，单位：秒)';

  @override
  String get intervalFloatRange => '间隔浮动范围 (SunCountdownRange，单位：秒)';

  @override
  String get sunDropperHelpTitle => '阳光掉落模块说明';

  @override
  String get sunDropperHelpIntro => '本模块用于配置关卡中的天降阳光参数，若是黑夜地图可考虑不添加此模块。';

  @override
  String get sunDropperHelpParams => '参数配置';

  @override
  String get sunDropperHelpParamsBody =>
      '常规情况下，本模块使用在游戏文件里的定义，也可以选择打开自定义开关对详细参数进行编辑。';

  @override
  String get noZombossMechFound => '未找到僵王机甲';

  @override
  String get noZombossBattleFound => '未找到僵王数据';

  @override
  String get searchChallengeNameOrCode => '搜索挑战名称或代码';

  @override
  String get deleteChallengeTitle => '删除挑战？';

  @override
  String deleteChallengeConfirmLocal(String name) {
    return '确定要移除「$name」吗？本地挑战数据将永久删除。';
  }

  @override
  String deleteChallengeConfirmRef(String name) {
    return '确定要移除对「$name」的引用吗？挑战仍将保留在关卡模块 (LevelModules) 中。';
  }

  @override
  String get missingModulesRecommended => '关卡可能无法正常运行。建议添加以下模块：';

  @override
  String get recommendedTunnelDefendTitle => '强烈建议添加「地宫坑道」模块';

  @override
  String get recommendedTunnelDefendBody =>
      '地宫秘境场地中的地砖需通过「地宫坑道」模块铺设。若未添加该模块，场地可能会显得较为空旷。';

  @override
  String get recommendedExpeditionTilesTitle => '可以搭配「远征地砖」模块使用';

  @override
  String get recommendedExpeditionTilesBody =>
      '添加「远征地砖」模块，可以规避地图本体缺少瓷砖贴图的问题，并获得更加还原远征之门模式的关卡体验。';

  @override
  String get selectedPosition => '选中位置';

  @override
  String get addItem => '添加物品';

  @override
  String get itemListRowFirst => '当前格子中的物品';

  @override
  String get railcartCowboy => '西部矿车';

  @override
  String get railcartFuture => '未来矿车';

  @override
  String get railcartEgypt => '埃及矿车';

  @override
  String get railcartPirate => '海盗矿车';

  @override
  String get railcartWorldcup => '世界杯矿车';

  @override
  String get clearUnusedTitle => '清除未使用对象？';

  @override
  String get clearUnusedMessage =>
      '将永久删除关卡文件中所有未使用的对象，包括自定义僵尸、其属性及任何其他未被引用的数据。此操作不可撤销。确定继续？';

  @override
  String get clearUnusedNone => '未找到未使用的对象。';

  @override
  String clearUnusedDone(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '已移除$count个未使用对象。',
      one: '已移除1个未使用对象。',
    );
    return '$_temp0';
  }

  @override
  String get lawnMowerTitle => '小推车样式设置';

  @override
  String get lawnMowerNotes => '注意事项';

  @override
  String get lawnMowerHelpOverview => '本模块用于控制关卡中小推车的样式外观，注意在庭院框架下小推车模块无效。';

  @override
  String get lawnMowerHelpNotes => '小推车模块通常直接引用自LevelModules，无需在关卡内自定义参数。';

  @override
  String get lawnMowerSelectType => '选择小推车类型';

  @override
  String get zombieRushTitle => '关卡计时模块';

  @override
  String get zombieRushHelpOverview => '僵尸清除计划里的倒计时模块，在倒计时结束后关卡会结束进行结算。';

  @override
  String get zombieRushHelpNotes => '注意事项';

  @override
  String get zombieRushHelpIncompat =>
      '潘追的计时器模块和庭院不兼容会闪退，所以软件推荐使用僵尸清除计划里的计时模块。';

  @override
  String get zombieRushTimeSettings => '时间设置';

  @override
  String get levelCountdown => '关卡倒计时（单位：秒）';

  @override
  String get tunnelDefendTitle => '地宫坑道设置';

  @override
  String get tunnelDefendHelpOverview => '使用本模块在关卡里添加地宫秘境的坑道，部分僵尸与植物的交互会被坑道影响。';

  @override
  String get tunnelDefendHelpUsage => '使用说明';

  @override
  String get tunnelDefendHelpUsageBody =>
      '先在下方列表中选择一个坑道组件，在上方网格中点击即可放置。点击已有的相同组件可将其移除，点击不同的组件可直接替换。';

  @override
  String get tunnelDefendSelectComponent => '选择组件';

  @override
  String get tunnelDefendPlacedCount => '已放置组件';

  @override
  String get tunnelDefendClearAll => '清空全部';

  @override
  String get tunnelDefendClearConfirmTitle => '确定要清空全部坑道组件吗？';

  @override
  String get tunnelDefendClearConfirmMessage => '将移除场上所有已放置的坑道组件，此操作不可撤销。';

  @override
  String get tunnelDefendPathOutsideLawn => '场地外的路径组件：';

  @override
  String get tunnelDefendDeleteOutside => '删除场地外的路径组件';

  @override
  String get tunnelDefendDeleteOutsideConfirmTitle => '确定要删除场地外的坑道组件吗？';

  @override
  String get tunnelDefendDeleteOutsideConfirmMessage =>
      '将移除 5×9 场地之外的坑道组件，此操作不可撤销。';

  @override
  String get tunnelDefendTileStylePreset => '地砖样式预设';

  @override
  String get tunnelDefendTileStylePart1 => '地宫遗迹（第一章）';

  @override
  String get tunnelDefendTileStylePart2 => '地宫镇魂（第二章）';

  @override
  String get tunnelDefendSequenceInterval =>
      '坑道生成间隔 (TunnelSequenceInterval，单位：秒)';

  @override
  String get tunnelDefendHelpSequenceInterval => '坑道生成间隔';

  @override
  String get tunnelDefendHelpSequenceIntervalBody =>
      '地宫之主生成一条坑道时，相邻坑道组件之间的出现间隔。数值越小，坑道组件生成得越快。';

  @override
  String get tunnelDefendHelpSodPromptBody =>
      '“种植草垛提示”用于控制在受限制地块种植时是否显示“请先放置草垛”的提示。地宫坑道模块默认开启该提示。';

  @override
  String get sodPlantingPromptTitle => '种植草垛提示';

  @override
  String get expeditionTilesSodPromptBody => '种植植物时是否提示需要草垛，默认关闭';

  @override
  String get tunnelDefendSodPromptBody => '种植植物时是否提示需要草垛，默认开启';

  @override
  String get expeditionTilesPresetLayout => '布局预设';

  @override
  String get expeditionTilesPresetFloor1 => '远征之门第一层';

  @override
  String get expeditionTilesPresetFloor2 => '远征之门第二层';

  @override
  String get expeditionTilesPresetFloor3 => '远征之门第三层';

  @override
  String get customLayout => '自定义布局';

  @override
  String get switchAction => '切换';

  @override
  String get expeditionTilesSwitchPresetTitle => '切换预设布局';

  @override
  String get expeditionTilesSwitchPresetMessage =>
      '是否切换至预设布局？这将移除场上所有已放置的禁种地块，此操作不可撤销。';

  @override
  String expeditionTilesSwitchPresetBetweenMessage(String from, String to) {
    return '是否从“$from”切换至“$to”？';
  }

  @override
  String get expeditionTilesUnderwaterMismatchWarning =>
      '当前地图为海底世界外观，与「远征地砖」模块不适配，会导致关卡闪退。';

  @override
  String get expeditionTilesBlockedCount => '禁种地块';

  @override
  String get expeditionTilesClearConfirmTitle => '确定要清空全部禁种地块吗？';

  @override
  String get expeditionTilesClearConfirmMessage => '将移除场上所有已放置的禁种地块，此操作不可撤销。';

  @override
  String get expeditionTilesHelpTitle => '远征地砖模块说明';

  @override
  String get expeditionTilesHelpOverview =>
      '远征地砖模块用于配置远征之门地图中的不可种植区域。该模块沿用地宫坑道的地块数据结构，并通过远征模式专用的地砖图案显示禁种区域。可以在禁种地块上种植草垛来恢复其种植职能。';

  @override
  String get expeditionTilesHelpEditing => '地块编辑';

  @override
  String get expeditionTilesHelpEditingBody =>
      '点击草坪上的任意地块，可以添加或取消禁种地块。禁种地块会覆盖原有地砖，关卡中无法在这些位置种植植物。漩涡地砖和空白地砖都是允许种植的区域，漩涡地砖在此的作用仅为还原在该模组下的初始地图布局。';

  @override
  String get expeditionTilesHelpPresets => '预设布局';

  @override
  String get expeditionTilesHelpPresetsBody =>
      '编辑器提供远征之门第一层、第二层和第三层三种官方布局。切换预设会替换当前已放置的所有禁种地块，且无法撤销；应用预设后仍可继续手动调整。';

  @override
  String get expeditionTilesHelpSodPrompt => '种植提示';

  @override
  String get expeditionTilesHelpSodPromptBody =>
      '“种植草垛提示”用于控制在受限制地块种植时是否显示“请先放置草垛”的提示。远征地砖模块默认关闭该提示。';

  @override
  String get expeditionTilesHelpNotesBody =>
      '远征地砖适用于远征之门等五行地图。请勿与“海底世界-海底两万里”或“海底世界-亚特兰蒂斯”等海底世界外观的六行地图搭配使用，否则会导致关卡闪退。';

  @override
  String get tunnelExpeditionCompatibilityWarningTitle => '模块兼容性提示';

  @override
  String get tunnelExpeditionCompatibilityWarningBody =>
      '同时使用「地宫坑道」模块与「远征地砖」模块时，可能会出现地砖贴图互相覆盖的现象，影响关卡整体观感。如一定要同时使用，请万分注意。';

  @override
  String get moduleTitle_ZombossFinalStageTimeLimitedChallengeProperties =>
      '终结技计时';

  @override
  String get moduleDesc_ZombossFinalStageTimeLimitedChallengeProperties =>
      '地宫之主僵王战必需模块';

  @override
  String get finalStageTimeLimitedChallengeHelpTitle => '终结技计时模块说明';

  @override
  String get finalStageTimeLimitedChallengeHelpIntro =>
      '为地宫之主僵王战的最终阶段添加限时击杀挑战。若未在规定时间内清空其剩余血量，地宫之主将会挥剑。';

  @override
  String get finalStageTimeLimitedChallengeHelpParams => '参数配置';

  @override
  String get finalStageTimeLimitedChallengeHelpParamsBody =>
      '当前使用该模块时，直接从LevelModules引用即可。实际倒计时时长由僵王属性表中的ZombossFinalStageTimeLimited决定，而非本模块的ZombossTimeLimit字段，因此对该模块自定义没有任何意义。';

  @override
  String get finalStageTimeLimitedChallengeTimeLimit =>
      '挥剑倒计时 (ZombossTimeLimit，单位：秒)';

  @override
  String get moduleTitle_LawnMowerProperties => '小推车';

  @override
  String get moduleDesc_LawnMowerProperties => '设置小推车样式，注意在庭院中不生效';

  @override
  String get moduleTitle_TunnelDefendModuleProperties => '地宫坑道';

  @override
  String get moduleDesc_TunnelDefendModuleProperties => '设置地宫秘境的坑道及地砖样式';

  @override
  String get moduleTitle_SouDaCheTunnelDefendDefault => '远征地砖';

  @override
  String get moduleDesc_SouDaCheTunnelDefendDefault => '设置远征之门地图的不可种植区域';

  @override
  String get moduleTitle_WitchModuleProperties => '女巫登场';

  @override
  String get moduleDesc_WitchModuleProperties => '惊吓巫婆周期性掠过场地，泼洒魔法药剂';

  @override
  String get moduleTitle_InitialGridItemGulliverTunnelProperties => '格列佛隧道';

  @override
  String get moduleDesc_InitialGridItemGulliverTunnelProperties =>
      '在场地上预置可以使进入单位变大变小的隧道';

  @override
  String get witchModuleHelpTitle => '女巫登场模块说明';

  @override
  String get witchModuleHelpIntro =>
      '使用本模块会为关卡添加2名惊吓巫婆。关卡开始后，惊吓巫婆会从场地左侧或右侧随机选择一行突入，骑着魔法扫帚快速掠过场地，并在沿途随机洒下魔法药剂，随后每隔一段时间返回场地，重复上述操作。\n不同药剂拥有不同效果：橙色爆炸药剂会对落点周围3×3范围造成百分比伤害；绿色变形药剂会将单格植物变为羊、青蛙或鸡中的一种，也有概率将其变为高坚果卡片；蓝色亡灵药剂会在持续时间内不断复活落点周围3×3范围内死亡的僵尸；红色狂化药剂会为僵尸提供生命值和移动速度加成。\n惊吓巫婆无法被植物攻击。使用高坚果可以将其撞离场地；若高坚果释放过能量豆大招，则会直接将巫婆撞碎，使其不再出现。';

  @override
  String get witchModuleHelpParams => '参数配置';

  @override
  String get witchModuleHelpParamsBody =>
      '常规情况下，本模块使用在游戏文件里的定义，也可以选择打开自定义开关，对巫婆出现的间隔进行编辑。';

  @override
  String get witchModuleSpawnInterval => '女巫出现间隔 (WitchSpawnInterval，单位：秒)';

  @override
  String get gulliverTunnelTitle => '格列佛隧道';

  @override
  String get gulliverTunnelHelpOverview =>
      '本模块用于放置关卡开始前场地上的格列佛隧道。根据朝向不同，格列佛隧道分为两种：小口朝右、大口朝左，以及小口朝左、大口朝右。\n从小口进入的小鬼僵尸会变为巨型小鬼僵尸，拥有更高血量；从大口进入的常规僵尸会变为小小僵尸，移速更快，且可以躲避部分较高的平射子弹。\n植物的平射子弹也可进入大口，在被缩小后从小口射出，伤害降低；抛投子弹可越过隧道直接攻击僵尸。';

  @override
  String get gulliverTunnelHelpUsage => '使用说明';

  @override
  String get gulliverTunnelHelpUsageBody =>
      '先在下方选择隧道的朝向，然后点击网格放置。再次点击已有隧道的格可将其移除；选择不同朝向后点击已有隧道的格可以替换其朝向。';

  @override
  String get gulliverTunnelOrientationBigOnLeft => '小口朝右，大口朝左';

  @override
  String get gulliverTunnelOrientationBigOnRight => '小口朝左，大口朝右';

  @override
  String get gulliverTunnelPlacedCount => '已放置';

  @override
  String get gulliverTunnelClearAll => '清空全部';

  @override
  String get gulliverTunnelClearConfirmTitle => '确定要清空全部格列佛隧道吗？';

  @override
  String get gulliverTunnelClearConfirmMessage => '将移除场上所有已放置的格列佛隧道，此操作不可撤销。';

  @override
  String get gulliverTunnelSelectOrientation => '选择隧道朝向';

  @override
  String get gulliverTunnelOutsideLawn => '场地外的隧道：';

  @override
  String get gulliverTunnelDeleteOutside => '删除场地外的隧道';

  @override
  String get gulliverTunnelDeleteOutsideConfirmTitle => '确定要删除场地外的隧道吗？';

  @override
  String get gulliverTunnelDeleteOutsideConfirmMessage =>
      '将移除 5×9 场地之外的格列佛隧道，此操作不可撤销。';

  @override
  String get moduleTitle_RiftThemeDemoModuleProperties => '主题配置';

  @override
  String get moduleDesc_RiftThemeDemoModuleProperties =>
      '为关卡配置来自潘妮的追击、回忆之旅等模式的主题效果';

  @override
  String get riftThemeHelpTitle => '主题配置模块说明';

  @override
  String get riftThemeHelpOverview =>
      '本模块用于为关卡添加主题列表。主题是在潘妮的追击、回忆之旅、时空秘境等模式中出现的全局机制，不同的主题有着不同的效果。长按或右键点击主题卡片，可查看该主题效果的简要说明，以及相关植物和僵尸名单。';

  @override
  String get riftThemeHelpUsage => '使用说明';

  @override
  String get riftThemeHelpUsageBody =>
      '点击右下角按钮打开主题选择界面。点击主题可将其加入或移出主题列表。全部设置完成后，再次点击右下角按钮确认，即可完成添加。主题将在关卡中按照列表顺序依次生效。';

  @override
  String get riftThemeHelpUnique => '添加规范';

  @override
  String get riftThemeHelpUniqueBody => '每个主题最多在列表中添加一次。添加过多主题可能造成关卡闪退。';

  @override
  String get riftThemeEmpty => '尚未选择主题。点击右下角按钮选择主题。';

  @override
  String get riftThemeSelectThemes => '选择主题';

  @override
  String get riftThemeNoSearchResults => '没有匹配的主题';

  @override
  String get moduleTitle_ZombieRushModuleProperties => '关卡倒计时';

  @override
  String get moduleDesc_ZombieRushModuleProperties => '倒计时结束后关卡直接结算';

  @override
  String get moduleTitle_PVZ1PassageModuleProperties => '斗转星移';

  @override
  String get moduleDesc_PVZ1PassageModuleProperties => '配置一代传送门的生成情况';

  @override
  String get moduleTitle_PVZ1CopycatsModuleProperties => '猜猜我是谁';

  @override
  String get moduleDesc_PVZ1CopycatsModuleProperties => '配置魔术帽的召唤情况，开启后可选择魔术帽';

  @override
  String get pvz1CopycatsModuleTitle => '猜猜我是谁';

  @override
  String get pvz1CopycatsSectionParams => '参数配置';

  @override
  String get pvz1CopycatsFieldZombieWeightLabel => '召唤僵尸权重 (ZombieWeight)';

  @override
  String get pvz1CopycatsHelpZombieWeight =>
      '单次召唤时出现僵尸的概率（范围为0-1），用1减去该值即可得到植物出现的概率。';

  @override
  String get pvz1CopycatsFieldSpawnPlantLevelLabel =>
      '召唤植物阶级 (SpawnPlantLevel)';

  @override
  String get pvz1CopycatsHelpSpawnPlantLevel => '魔术帽召唤出的植物的阶级。';

  @override
  String get pvz1CopycatsSectionPlantBlackList => '植物黑名单 (PlantBlackList)';

  @override
  String get pvz1CopycatsHelpPlantBlackList =>
      '每种魔术帽都有独立的可召唤植物列表，列表不受黑名单影响，因此修改黑名单没有意义。';

  @override
  String get pvz1CopycatsSectionZombieWhiteList => '僵尸白名单 (ZombieWhiteList)';

  @override
  String get pvz1CopycatsHelpZombieWhiteList => '魔术帽仅会召唤白名单中的僵尸。';

  @override
  String get pvz1CopycatsHelpTip =>
      '添加此模块后，不要忘记在种子库或传送带模块中预选魔术帽。长按或右键点击选择植物界面的魔术帽，可以预览该魔术帽可能召唤的植物。';

  @override
  String get pvz1CopycatsHelpOverview =>
      '本模块用于配置卡槽中可种植的魔术帽的召唤情况，常用于回忆之旅小游戏“猜猜我是谁”关卡。缺少该模块时，魔术帽将无法正常召唤。不同种类的魔法帽有着不同的阳光消耗和冷却时间。魔术帽种下后会在片刻内变为随机的植物或僵尸。\n植物从魔术帽自身的植物列表中选择，僵尸仅会从白名单中选择。植物或僵尸列表中各项的出现权重无法单独设置。';

  @override
  String get pvz1CopycatsHelpFieldsTitle => '参数介绍';

  @override
  String get pvz1CopycatsPlantListEmpty => '黑名单为空';

  @override
  String get pvz1CopycatsZombieListEmpty => '白名单为空';

  @override
  String get pvz1CopycatsAddPlant => '向黑名单添加植物';

  @override
  String get pvz1CopycatsAddZombie => '向白名单添加僵尸';

  @override
  String get moduleTitle_PVZ1SeeingStarsModuleProperties => '看星星';

  @override
  String get moduleDesc_PVZ1SeeingStarsModuleProperties => '配置观星小游戏的目标植物与循环波数';

  @override
  String get pvz1SeeingStarsModuleTitle => '看星星';

  @override
  String get pvz1SeeingStarsSectionParams => '参数';

  @override
  String get pvz1SeeingStarsSectionMatchPlants => '目标植物 (MatchPlants)';

  @override
  String get pvz1SeeingStarsHelpMatchPlants =>
      '点击格子后可添加植物；若所选格子已有植物，添加后会替换掉原植物。添加的植物会在关卡中显示为透明提示，当所有目标格均种有对应植物时，关卡胜利。目标格内只能种植目标植物和藤蔓类植物，无法种植其他植物。';

  @override
  String get pvz1SeeingStarsFieldCycleIndexLabel => '循环波数 (CycleIndex)';

  @override
  String get pvz1SeeingStarsHelpCycleIndex =>
      '最后一波结束后继续出怪使用的初始波次数目，从0开始计数。例如关卡共15波且循环波数为5时，第15波结束后会从第6波开始继续出怪，循环往复直至图案完成。';

  @override
  String get pvz1SeeingStarsFieldSettlementDurationLabel =>
      '结算延迟 (SettlementDuration)';

  @override
  String get pvz1SeeingStarsHelpSettlementDuration =>
      '图案完成后会进入指定秒数的延迟，延迟结束后，无论目标格是否还种有对应植物，关卡都会胜利结算。延迟仅会在关卡中没有「死亡结算」或「铜人阵死亡结算」模块时生效。';

  @override
  String get pvz1SeeingStarsHelpOverview =>
      '本模块用于在关卡中配置回忆之旅小游戏“看星星”关卡所需的各类参数。该小游戏因其一代原关卡是使用星星果在草坪上种满星星图案而得名。根据草坪上的提示，在对应位置种上相同植物，完成图案，即可过关。在此过程中，波次中配置的僵尸会循环往复地出现，干扰布阵。';

  @override
  String get pvz1SeeingStarsHelpFieldsTitle => '参数说明';

  @override
  String get pvz1SeeingStarsHelpWinCon =>
      '请勿将该模块与「死亡结算」、「铜人阵死亡结算」、「关卡倒计时」、「僵尸迷阵」等带有其他结算方式的模块同时使用，否则可能覆盖或干扰「看星星」的结算条件，影响该小游戏的游玩体验。\n此外，「看星星」模块与波次生成器模块不兼容，会导致关卡闪退，请谨慎使用。';

  @override
  String get pvz1SeeingStarsMatchPlantsEmpty => '尚未配置图案。请选中网格中的任意格子并添加植物。';

  @override
  String get seeingStarsWinConWarningTitle => '结算条件冲突';

  @override
  String get seeingStarsWinConWarning =>
      '「看星星」模块自带结算条件，会在场上的图案完成后自动结算。请勿与「死亡结算」、「铜人阵死亡结算」、「关卡倒计时」、「僵尸迷阵」等带有其他结算方式的模块同时使用，以免覆盖或干扰其结算条件。';

  @override
  String get seeingStarsCycleWaveLabel => '循环波数 (CycleIndex，从0开始计数)';

  @override
  String get seeingStarsSettlementLabel => '结算延迟 (SettlementDuration，单位：秒)';

  @override
  String get pvz1SeeingStarsHelpTipsTitle => '温馨提示';

  @override
  String get seeingStarsCompatibilityWarningTitle => '模块兼容性提示';

  @override
  String get seeingStarsCompatibilityWarning =>
      '「看星星」模块与波次生成器模块不兼容，会导致关卡闪退，请谨慎使用。';

  @override
  String get seeingStarsCycleWaveBadge => '波次循环';

  @override
  String seeingStarsCycleWaveInfo(int wave) {
    return '最后一波结束后，将从第$wave波重新出怪，循环直至所有目标格均种有对应植物。';
  }

  @override
  String get seeingStarsMatchPlants => '目标植物';

  @override
  String get magicHatSpawnPreviewTitle => '魔术帽可能召唤的植物';

  @override
  String get magicHatSpawnPreviewEmpty => '没有符合黑名单条件的植物。';

  @override
  String get pvz1PassageModuleTitle => '斗转星移';

  @override
  String get pvz1PassageSectionParams => '传送门参数';

  @override
  String get pvz1PassageHelpOverview =>
      '本模块用于配置一代风格的传送门，常见于回忆之旅小游戏“斗转星移”关卡。传送门成对出现，影响植物子弹和僵尸的运动轨迹，每隔一段时间会改变位置。注意传送门不会影响植物的索敌范围，即植物不会主动攻击前方传送门另一端的僵尸，只会在本行有僵尸时发动攻击。';

  @override
  String get pvz1PassageHelpFieldsTitle => '参数介绍';

  @override
  String get pvz1PassageFieldGroupAmount => '传送门种类 (GroupAmount)';

  @override
  String get pvz1PassageHelpGroupAmount =>
      '关卡中出现的传送门种类数。一代风格的传送门共有两种：方形和圆形。若设为1，则只会出现方形传送门；设为2时，方形传送门和圆形传送门会同时出现；设为3及以上时，多余的传送门种类会显示为阳光贴图，这些传送门不会刷新位置，但仍然可以传送僵尸。';

  @override
  String get pvz1PassageFieldPassageAmount => '每组传送门数量 (PassageAmount)';

  @override
  String get pvz1PassageHelpPassageAmount =>
      '每一组内传送门的数量。例如，设为2时，每种类型各有2个传送门。传送门的总数不能超过生成区域内的格子数。如果同一类型中存在多个可传送的传送门，僵尸会始终传送到指定的那个传送门。';

  @override
  String get pvz1PassageFieldGridXMin => '最小生成列数 (GridXMin)';

  @override
  String pvz1PassageHelpGridXMin(int maxIndex) {
    return '传送门可出现的最左列。场地左边界为0列，右边界为$maxIndex列。最小生成列数必须小于最大生成列数。';
  }

  @override
  String get pvz1PassageFieldGridXMax => '最大生成列数 (GridXMax)';

  @override
  String pvz1PassageHelpGridXMax(int maxIndex) {
    return '传送门可出现的最右列。场地左边界为0列，右边界为$maxIndex列。最大生成列数必须大于最小生成列数。';
  }

  @override
  String pvz1PassageGridColumnRange(int maxIndex) {
    return '0–$maxIndex';
  }

  @override
  String get pvz1PassageFieldTransferCooldown =>
      '同僵尸传送最短间隔 (transferCooldown，单位：秒)';

  @override
  String get pvz1PassageHelpTransferCooldown =>
      '同一只僵尸两次传送之间的最短时间。如果时间设置过短，僵尸在传送后未能在间隔内离开传送门所在格，则会在间隔结束后再次被传送回原传送门。';

  @override
  String get pvz1PassageFieldRefreshTime => '传送门位置刷新间隔 (refreshTime，单位：秒)';

  @override
  String get pvz1PassageHelpRefreshTime =>
      '传送门重新生成位置的间隔。位置生成是逐个进行的，即每次刷新只会改变同一类型中的一个传送门的位置。';

  @override
  String get pvz1PassagePortalSpawnPreview => '传送门生成列预览';

  @override
  String get pvz1PassageHelpPreview => '生成范围预览';

  @override
  String pvz1PassageHelpPreviewBody(int maxIndex) {
    return '橙色高亮区域表示传送门可能出现在哪些列。当前场地的列范围为 0–$maxIndex（包含场地两侧的边界）。本模块无法限制传送门生成行的范围。';
  }

  @override
  String get moduleWaveIndexZeroBasedHint => '这里0是第1波，以此类推';

  @override
  String get moduleWaveFieldZeroBased => '波次 (从0开始计数)';

  @override
  String get moduleTitle_RenaiModuleProperties => '复兴时代模块';

  @override
  String get moduleDesc_RenaiModuleProperties => '启用复兴圆环和昼夜更替功能，配置复兴雕像和原石像';

  @override
  String get renaiModuleHelpTitle => '复兴时代模块说明';

  @override
  String get renaiModuleHelpOverview => '简要介绍';

  @override
  String get renaiModuleHelpOverviewBody =>
      '此模块用于使复兴圆环响应启动按钮，设置昼夜更替的波次，并在夜幕降临时按配置复活雕像、原石像及生成障碍物，通常在复兴时代地图使用。';

  @override
  String get renaiModuleHelpStatues => '部分功能介绍';

  @override
  String get renaiModuleHelpStatuesBody =>
      '初始障碍物指关卡开始时场上已存在的雕像和原石像，会在指定波次复活成为僵尸。夜间障碍物指黑夜开始后生成的障碍物，生成时若目标格上已有植物，则不会生成。黑夜开始的波次在代码中从0开始计数（如第1波入夜为0，第2波入夜为1）。';

  @override
  String get renaiModuleEnableNight => '启用昼夜更替功能';

  @override
  String get renaiModuleEnableNightSubtitle => '允许设置夜幕降临的波次和夜间障碍物';

  @override
  String get renaiModuleNightStart => '黑夜开始波次';

  @override
  String get renaiModuleDayStatues => '初始障碍物';

  @override
  String get renaiModuleNightStatues => '夜间障碍物';

  @override
  String get renaiModuleNightStatuesDisabledHint => '请先启用昼夜更替功能';

  @override
  String get renaiModuleCarveWave => '雕像复活波次';

  @override
  String get renaiModuleStatuesInCell => '当前格子中的物品';

  @override
  String get renaiModuleExpectationLabel => '夜幕降临事件';

  @override
  String get renaiModuleNightStarts => '黑夜开始';

  @override
  String get renaiModulePreviewNightStatues => '本波生成的夜间障碍物：';

  @override
  String get renaiModulePreviewRevivingStatues => '本波复活的障碍物：';

  @override
  String get moduleTitle_DropShipProperties => '运兵艇突袭';

  @override
  String get moduleDesc_DropShipProperties => '将飞行小鬼僵尸空投至场地';

  @override
  String get airDropShipModuleHelpTitle => '运兵艇突袭模块说明';

  @override
  String get airDropShipModuleHelpOverview => '简要介绍';

  @override
  String get airDropShipModuleHelpOverviewBody =>
      '此模块用于配置关卡中随波次出现的运兵艇，常见于天空之城关卡。运兵艇不会受到攻击，指定数量的飞行小鬼僵尸会从中依次降落到指定投放区域内的位置。';

  @override
  String get airDropShipModuleHelpImps => '参数介绍';

  @override
  String get airDropShipModuleHelpImpsBody =>
      '运兵艇的出现波次从0开始计数，如第1波登场填0，第2波登场填1。运兵艇至少会投放1只飞行小鬼僵尸，因此额外小鬼数量填写的是在这1只的基础上，该波次额外投放的小鬼数量。';

  @override
  String get airDropShipModuleAppearances => '投放组';

  @override
  String get airDropShipModuleExtraImpCount => '额外小鬼数量 (Imp)';

  @override
  String get airDropShipModuleDropArea => '投放区域';

  @override
  String get airDropShipModuleDropAreaPreview => '投放区域预览';

  @override
  String get airDropShipModuleAreaDropPreviewLabel => '投放区域预览：';

  @override
  String get airDropShipModuleExpectationLabel => '空投小鬼';

  @override
  String get airDropShipModuleImpLevel => '小鬼阶级 (ImpLv)';

  @override
  String get airDropShipModuleRowMin => '起始行';

  @override
  String get airDropShipModuleRowMax => '结束行';

  @override
  String get airDropShipModuleColMin => '起始列';

  @override
  String get airDropShipModuleColMax => '结束列';

  @override
  String get openModuleSettings => '打开模块设置';

  @override
  String get moduleTitle_GlacierModuleProperties => '冰堆模块';

  @override
  String get moduleDesc_GlacierModuleProperties => '配置冰河世界僵王生成的冰堆中隐藏的僵尸';

  @override
  String get glacierModuleTitle => '冰堆模块';

  @override
  String get glacierModuleHelpTitle => '冰堆模块说明';

  @override
  String get glacierModuleHelpOverviewBody =>
      '冰河世界僵王召唤僵尸的方式与其他僵王机甲不同：它会自下而上喷吐寒冰并生成冰堆，冰堆破碎后会释放藏在其中的僵尸。本模块便用于配置冰堆中可能出现的僵尸。';

  @override
  String get glacierModuleHelpColumnsTitle => '参数介绍';

  @override
  String get glacierModuleHelpColumnsBody =>
      '本模块由6组内容数据构成，每组数据分别对应一列冰堆，并从离僵王最远的一列开始计数，也就是常规地图最左侧的第1列。点击“添加内容”后，可以选择添加僵尸，或添加“冰堆破碎后不出现僵尸”的空结果。每项内容均可配置出现权重，但只有僵尸内容可以切换僵尸并单独配置阶级（最高为4阶），空结果仅配置权重。';

  @override
  String get glacierModuleHelpRequirementsTitle => '温馨提示';

  @override
  String get glacierModuleHelpRequirementsBody =>
      '本模块必须与机甲僵王战模块同时使用，且所选基础僵王机甲必须为“冰河世界僵王 (獠牙征服者)”，否则不会生效。\n此外，不建议在海底世界外观的地图中使用冰河世界僵王与冰堆模块，否则会影响关卡的整体观感。';

  @override
  String get glacierModuleHelpPresetsTitle => '预设配置';

  @override
  String get glacierModuleHelpPresetsBody =>
      '编辑器内置了冰河世界僵王各变体在游戏原有关卡中使用的冰堆配置。应用预设会替换当前6组冰堆数据，且无法撤销；应用后仍可继续手动调整。植物迷阵变体的技能不需要冰堆模块，因此没有对应预设；自定义变体默认使用空白预设。';

  @override
  String get glacierModulePresetSectionTitle => '冰堆预设配置';

  @override
  String get glacierModulePresetBlankCustom => '自定义变体 (空白预设)';

  @override
  String get glacierModulePresetCustomConfiguration => '自定义配置';

  @override
  String get glacierModuleSwitchPresetTitle => '切换冰堆预设';

  @override
  String glacierModuleSwitchPresetMessage(String from, String to) {
    return '是否从“$from”切换至“$to”？当前6组冰堆配置将被替换，且无法撤销。';
  }

  @override
  String get glacierModuleVariationPresetPromptTitle => '启用对应的冰堆预设';

  @override
  String get glacierModuleVariationPresetPrompt =>
      '冰河世界僵王通过灌注冰堆召唤僵尸，冰堆中出现的僵尸由专门的「冰堆模块」进行配置。您即将切换至冰河世界僵王的另一变体，是否要同时启用该变体在游戏原有关卡中使用的「冰堆模块」预设配置？';

  @override
  String get glacierModuleCustomVariationPresetPrompt =>
      '自定义变体默认采用空白冰堆预设。是否同时将「冰堆模块」切换为空白预设？';

  @override
  String get zombossMechSwitchVariationOnly => '仅切换变体';

  @override
  String get glacierModuleEnablePreset => '同时启用预设';

  @override
  String get iceAgePlantPuzzleVariationWarningTitle => '植物迷阵变体无需冰堆模块';

  @override
  String get iceAgePlantPuzzleVariationWarning =>
      '獠牙征服者的植物迷阵变体是为冰河世界迷你游戏「植物迷阵」量身打造的，其技能不需要「冰堆模块」。';

  @override
  String get glacierModuleCompatibilityWarningTitle => '模块使用条件提示';

  @override
  String get glacierModuleCompatibilityWarning =>
      '「冰堆模块」必须与机甲僵王战模块同时使用，且所选基础僵王机甲必须为“冰河世界僵王 (獠牙征服者)”，否则不会生效。如没有在关卡中使用冰河世界僵王的打算，建议删除该模块。';

  @override
  String get glacierModuleUnderwaterWarningTitle => '海底世界外观不兼容';

  @override
  String get glacierModuleUnderwaterWarning =>
      '不建议在海底世界外观的地图中使用冰河世界僵王与「冰堆模块」，否则会影响关卡整体观感。';

  @override
  String glacierModuleColumn(int columnIndex) {
    return '左起第$columnIndex列';
  }

  @override
  String glacierModuleEntryCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '已配置$count项内容',
      one: '已配置1项内容',
    );
    return '$_temp0';
  }

  @override
  String get glacierModuleNoEntries => '本组数据中暂未配置内容。';

  @override
  String get glacierModuleAddEntry => '添加内容';

  @override
  String get glacierModuleAddContentTitle => '添加冰堆内容';

  @override
  String get glacierModuleAddZombieContent => '添加僵尸';

  @override
  String get glacierModuleEmptyType => '冰堆破碎后不出现僵尸';

  @override
  String get glacierModuleWeight => '权重';

  @override
  String get glacierModuleWeightTooltip => '设置该僵尸在本列冰堆中出现的权重。';

  @override
  String get glacierModuleEmptyWeightTooltip => '设置“冰堆破碎后不出现僵尸”这一结果的权重。';

  @override
  String get glacierModuleLevel => '僵尸阶级';

  @override
  String get glacierModuleLevelTooltip =>
      '设置该僵尸的阶级，范围为0-4。0阶表示随地图阶级，庭院模式下即为1阶。';

  @override
  String get moduleTitle_HeianWindModuleProperties => '平安神风';

  @override
  String get moduleDesc_HeianWindModuleProperties => '推动僵尸平移并击飞植物的风';

  @override
  String get heianWindModuleHelpTitle => '平安神风模块说明';

  @override
  String get heianWindModuleHelpOverview => '简要介绍';

  @override
  String get heianWindModuleHelpOverviewBody =>
      '此模块用于在指定波次召唤神风，常见于平安时代关卡。神风会推动覆盖范围内指定数量的中小体型僵尸平移一段距离。一个波次内所有神风结束后，该波次中被单行神风作用过的行会生成旋风，一行最多只会生成一道旋风。旋风会裹挟遇到的僵尸前进，并在接触植物时将其击飞，随后消失。';

  @override
  String get heianWindModuleHelpDistance => '平移距离';

  @override
  String get heianWindModuleHelpDistanceBody =>
      '1格等于50距离。距离为负值时，神风推动僵尸向左平移；距离为正值时，神风推动僵尸向右平移。';

  @override
  String get heianWindModuleHelpRow => '覆盖范围';

  @override
  String get heianWindModuleHelpRowBody =>
      '神风的出现波次从0开始计数，如第1波降临填0，第2波降临填1。神风的作用行也从0开始计数，除了可以指定作用在单独一行外，也可以设为-1，使神风作用于全屏；此时不会生成旋风。';

  @override
  String get heianWindModuleWaves => '神风的出现波次 (WaveNumber)';

  @override
  String get heianWindModuleWavesHint => '从0开始计数';

  @override
  String get heianWindModuleAppearances => '召唤组';

  @override
  String get heianWindModuleWindDelay => '神风生成间隔 (WindDelay，单位：秒)';

  @override
  String get heianWindModuleWindDelayHint => '单位：秒';

  @override
  String get heianWindModuleWindEntries => '神风具体配置';

  @override
  String get heianWindModuleAddWind => '添加神风';

  @override
  String get heianWindModuleRow => '神风作用行 (Row)';

  @override
  String get heianWindModuleAllRows => '全屏大风 (-1)';

  @override
  String get heianWindModuleAffectZombies => '影响僵尸数量 (AffectZombies)';

  @override
  String get heianWindModuleDistance => '僵尸平移距离 (Distance)';

  @override
  String get heianWindModuleDistanceHint => '1格=50距离';

  @override
  String get heianWindModuleMoveTime => '僵尸平移时间 (MoveTime，单位：秒)';

  @override
  String get heianWindModuleMoveTimeHint => '单位：秒';

  @override
  String get heianWindModuleExpectationLabel => '神风配置';

  @override
  String get jsonViewerModeReading => '（纯文本视图）';

  @override
  String get jsonViewerModeObjectReading => '（结构化视图）';

  @override
  String get jsonViewerModeEdit => '（编辑模式）';

  @override
  String get jsonViewerFontSize => '字体大小';

  @override
  String get jsonViewerSearchHint => '搜索';

  @override
  String get jsonViewerReplaceHint => '替换';

  @override
  String get jsonViewerSearchHistory => '最近搜索';

  @override
  String get jsonViewerReplaceHistory => '最近替换';

  @override
  String get jsonViewerInsertNewline => '插入换行';

  @override
  String get jsonViewerMatchCase => '区分大小写';

  @override
  String get jsonViewerWholeWords => '全词匹配';

  @override
  String get jsonViewerRegex => '正则表达式';

  @override
  String get jsonViewerPreviousMatch => '上一个匹配';

  @override
  String get jsonViewerNextMatch => '下一个匹配';

  @override
  String get jsonViewerReplaceOne => '替换';

  @override
  String get jsonViewerReplaceAll => '全部替换';

  @override
  String jsonViewerMatchCounter(int current, int total) {
    return '$current / $total';
  }

  @override
  String get tooltipAboutModule => '关于此模块';

  @override
  String get tooltipAboutSection => '关于此分区';

  @override
  String get tooltipAboutEvent => '关于此事件';

  @override
  String get tooltipSave => '保存';

  @override
  String get tooltipEdit => '编辑';

  @override
  String get tooltipClose => '关闭';

  @override
  String get tooltipToggleObjectView => '切换纯文本/结构化视图';

  @override
  String get tooltipClearUnused => '清除未使用对象';

  @override
  String get tooltipCopyJson => '复制关卡JSON';

  @override
  String get tooltipCopyObject => '复制对象JSON';

  @override
  String get tooltipMore => '更多';

  @override
  String get jsonViewerCopied => 'JSON已复制到剪贴板';

  @override
  String get tooltipJsonViewer => '查看/编辑JSON文件';

  @override
  String get bungeeWaveEventHelpTitle => '蹦极投放事件说明';

  @override
  String get bungeeWaveEventHelpOverview =>
      '在关卡中设置蹦极僵尸投放僵尸的种类与位置，单个事件只能投放一只僵尸。';

  @override
  String get bungeeWaveEventHelpGrid => '坐标说明';

  @override
  String get bungeeWaveEventHelpGridBody => '在下方网格中点击，即可设置蹦极僵尸的落点位置。';

  @override
  String get bungeeWaveCurrentTarget => '当前目标';

  @override
  String get bungeeWaveCol => '行';

  @override
  String get bungeeWaveRow => '列';

  @override
  String get bungeeWavePropertiesConfig => '属性配置';

  @override
  String get bungeeWaveZombieLevel => '僵尸阶级 (Level)';

  @override
  String get bungeeWaveRoofWarning => '注意在屋顶地图中蹦极投放事件被叶子保护伞拦截后有可能直接触发食脑，请谨慎使用。';

  @override
  String get moduleTitle_LevelMutatorRiftTimedSunProps => '追击阳光掉落';

  @override
  String get moduleDesc_LevelMutatorRiftTimedSunProps => '击败僵尸掉落阳光';

  @override
  String get zombieSunDropHelpTitle => '僵尸掉落阳光模块说明';

  @override
  String get zombieSunDropHelpOverview =>
      '此模块用于设置特定僵尸在关卡中掉落的阳光数值，用于追击第五关。该模块的副作用是让阳光铲失效。';

  @override
  String get zombieSunDropHelpValues => '数值设置';

  @override
  String get zombieSunDropHelpValuesBody =>
      '6个整数分别对应僵尸在1阶至6阶时掉落的阳光，若阶级超过6则使用1阶的数据。';

  @override
  String get zombieSunDropEmpty => '暂无配置，点击右下角添加';

  @override
  String get zombieSunDropDefaultDrop => '默认掉落';

  @override
  String get zombieSunDropSun => '阳光';

  @override
  String get zombieSunDropEditTitle => '编辑具体数值';

  @override
  String get zombieSunDropEditHint => '配置该僵尸在1阶至6阶时的阳光掉落量，若超过6阶则使用1阶数值';

  @override
  String zombieSunDropTierLabel(int tier) {
    return '$tier阶';
  }

  @override
  String get moduleTitle_PickupCollectableTutorialProperties => '捡取教程';

  @override
  String get moduleDesc_PickupCollectableTutorialProperties => '击败特定僵尸弹出对话教程';

  @override
  String get pickupCollectableTutorialHelpTitle => '捡取教程模块说明';

  @override
  String get pickupCollectableTutorialHelpBasic => '基本描述';

  @override
  String get pickupCollectableTutorialHelpBasicBody =>
      '用于配置掉落特定物品的僵尸，以及捡取前后的文字提示引导。在关卡中首次击杀该种类的僵尸（含自定义僵尸）会弹出对话框。';

  @override
  String get pickupCollectableTutorialHelpDialogs => '对话提示';

  @override
  String get pickupCollectableTutorialHelpDialogsBody =>
      '在捡起掉落物前后都会弹出对话框提示，对话会延缓关卡的进程，阻碍下一波刷新。';

  @override
  String get pickupCollectableTutorialCoreConfig => '核心配置';

  @override
  String get pickupCollectableTutorialZombieLabel => '携带物品的僵尸';

  @override
  String get pickupCollectableTutorialLootType => '掉落物品类型';

  @override
  String get pickupCollectableTutorialGuideText => '引导文本';

  @override
  String get pickupCollectableTutorialPickupAdvice => '捡取前提示 (PickupAdvice)';

  @override
  String get pickupCollectableTutorialPostPickupAdvice =>
      '捡取后提示 (PostPickupAdvice)';

  @override
  String get pickupCollectableTutorialNotSet => '未设置';

  @override
  String get pickupCollectableLootGoldCoin => '金币';

  @override
  String get invalidRtonMagic => 'RTON 文件无效，文件开头应为「RTON」。';

  @override
  String get invalidRtonVersion => 'RTON 版本无效（应为1）。';

  @override
  String get invalidRtonEnd => 'RTON 文件无效，应以「DONE」结尾。';

  @override
  String get invalidRtonArrayEnd => '无效的RTON 数组分隔符。';

  @override
  String get invalidRtid => '无效的 RTID 值。';

  @override
  String get invalidValueType => 'RTON 不支持该值类型。';

  @override
  String get musicSuffix => '音乐模块';

  @override
  String get ambientAudioSuffix => '背景环境白噪音';

  @override
  String get selectMusicSuffix => '选择音乐模块';

  @override
  String get searchMusicSuffix => '搜索名称或代码名';

  @override
  String get noMusicSuffixFound => '未找到音乐模块';

  @override
  String get jsonViewerLineContinuation => '↳';

  @override
  String get zombossMechCustomVariation => '自定义';

  @override
  String get editCustomZombossMech => '编辑';

  @override
  String get customZombossMechProperties => '自定义僵王机甲属性';

  @override
  String get customZombossMechScalars => '活动参数';

  @override
  String get customZombossMechStages => '机甲阶段';

  @override
  String get customZombossMechEditHint =>
      '编辑关卡内使用的自定义机甲变体 (memo) 的属性。此类自定义僵王机甲常见于回忆之旅关卡。';

  @override
  String get zombossMechMinColumn => '最小列';

  @override
  String get zombossMechMaxColumn => '最大列';

  @override
  String get zombossMechSquashZombies => '可碾压僵尸';

  @override
  String get zombossMechSquashGridItems => '可碾压障碍物';

  @override
  String get zombossMultipleModuleSelectionHint =>
      '检测到多个同类僵王战模块，请在关卡设置的模块列表中选择要编辑的具体实例。';

  @override
  String get zombossMechActions => '动作';

  @override
  String get zombossMechPropertiesLabel => '属性';

  @override
  String get zombossMechAliasLabel => '代号 (仅支持英文字母；不支持空格)';

  @override
  String get zombossMechDeletePhase => '删除阶段';

  @override
  String zombossMechDeletePhaseTitle(int number) {
    return '确定要删除第$number阶段吗？';
  }

  @override
  String get zombossMechDeletePhaseMessage => '将移除此阶段及其动作列表，且无法撤销。';

  @override
  String get zombossMechDeleteEightiesPhaseMessage =>
      '将移除此阶段、动作列表，以及同一阶段对应的音乐和僵王动画，且无法撤销。';

  @override
  String get zombossMechStageJamOrder => '音乐播放顺序 (StageJamOrder)';

  @override
  String get zombossMechZombossAnimOrder => '僵王动画顺序 (ZombossAnimOrder)';

  @override
  String get zombossMechAddEightiesPhaseTitle => '选择新阶段的音乐与僵王动画';

  @override
  String get zombossMechEightiesPhaseSelectionRequired =>
      '必须同时选择该阶段播放的音乐和调用的僵王动画，才能新建阶段。';

  @override
  String get zombossMechCreatePhase => '新建阶段';

  @override
  String get zombossAnimNewWave => '新浪潮 (New Wave)';

  @override
  String get zombossAnimHipHop => '嘻哈 (Hip-Hop)';

  @override
  String get zombossMechOrphanActionDeleteTitle => '移除自定义动作数据？';

  @override
  String zombossMechOrphanActionDeleteMessage(String alias) {
    return '“$alias”已不在本关卡中使用。是否从关卡文件中移除其动作对象？';
  }

  @override
  String get zombossMechPhasesHelp =>
      '每个阶段可单独配置机甲的生命值、可使用的动作，以及阶段切换时执行的撤退动作等参数。动作列表中的技能会根据各自动作属性中的权重和重复次数执行，而非按列表顺序依次执行。';

  @override
  String get zombossMechPhasesHelpTitle => '阶段内容';

  @override
  String get zombossMechAddAction => '添加动作';

  @override
  String get zombossMechNoStageActions => '暂无动作';

  @override
  String get zombossMechSelectAction => '选择动作';

  @override
  String get zombossMechSummonJump => '召唤跳跃';

  @override
  String get zombossMechSelectRetreatAction => '选择撤退动作';

  @override
  String get zombossMechCreateCustomAction => '新建自定义动作';

  @override
  String get zombossMechEditCustomAction => '编辑自定义动作';

  @override
  String get zombossMechActionCategoryAll => '全部';

  @override
  String get zombossMechActionCategoryMovement => '移动';

  @override
  String get zombossMechActionCategoryAttack => '攻击';

  @override
  String get zombossMechActionCategorySpecial => '特殊';

  @override
  String get zombossMechActionCategorySpawn => '召唤';

  @override
  String get zombossMechActionCategoryCustom => '自定义';

  @override
  String get zombossMechActionCategoryRetreat => '撤退';

  @override
  String get zombossMechNoActionsFound => '未找到动作';

  @override
  String zombossCustomActionBaseAction(String action) {
    return '基础动作：$action';
  }

  @override
  String zombossPresetDerivedBaseAction(String action) {
    return '基础预设自定义动作：$action';
  }

  @override
  String get zombossMechActionAliasHint =>
      '自定义动作在关卡内的引用名称，用于组成 RTID(名称@CurrentLevel) 并供机甲属性表中的相关内容引用。该名称可以随时修改，修改后属性表中已有的相关 RTID 引用也会自动更新。';

  @override
  String get zombossMechActionBaseObjclass => '动作类型 (objclass)';

  @override
  String get zombossMechActionBaseAction => '基础动作';

  @override
  String get zombossMechActionTemplateHint => '选择一个内置动作以复制其类型与默认参数。创建后仍可自由修改。';

  @override
  String get zombossMechRecreateFromTemplate => '从模板重建';

  @override
  String get zombossMechRecreateFromTemplateTitle => '替换此动作？';

  @override
  String get zombossMechRecreateFromTemplateMessage =>
      '将用所选模板替换动作类型（objclass）及全部字段值，当前数值会丢失。';

  @override
  String get zombossMechBaseActionAliasSyncTitle => '同步动作代号？';

  @override
  String zombossMechBaseActionAliasSyncMessage(String alias) {
    return '切换基础动作后，是否同时将动作代号更新为“$alias”？';
  }

  @override
  String get zombossMechBaseActionAliasKeep => '保留当前代号';

  @override
  String get zombossMechBaseActionAliasUpdate => '同步更换代号';

  @override
  String get zombossMechActionDetails => '动作详情';

  @override
  String get zombossMechActionRtid => 'RTID';

  @override
  String get zombossMechActionFields => '动作字段';

  @override
  String get zombossMechPropertiesViewTitle => '僵王机甲属性';

  @override
  String get viewZombossMechProperties => '查看属性';

  @override
  String get zombossMechEditRetreatAction => '选择撤退动作';

  @override
  String get zombossMechAddZombie => '添加僵尸';

  @override
  String get zombossMechPickZombie => '选择僵尸';

  @override
  String get zombossMechNoZombiesInList => '列表中暂无僵尸';

  @override
  String get zombossMechSpawnBallSettings => '掉落物配置 (ZombieDropProps)';

  @override
  String get zombossMechAwardDropInvalidTitle => 'SpawnBall引用失效';

  @override
  String zombossMechAwardDropInvalidBody(String rtid) {
    return 'AwardDrop当前指向“$rtid”，但该引用不是关卡内结构有效的 ZombieDropProps 对象，游戏可能无法正常读取此动作。';
  }

  @override
  String get zombossMechAwardDropClearInvalid => '清除无效值并恢复默认';

  @override
  String get zombossMechOpenGlacierModule => '配置冰堆模块';

  @override
  String get zombossMechConfigureInitialGridItems => '配置初始障碍物';

  @override
  String get zombossMechEightiesSpeakerPresetPromptTitle => '需要预置音响吗？';

  @override
  String get zombossMechEightiesSpeakerPresetPrompt =>
      '摇滚年代僵王的第一阶段通常需要场上的专属音响配合其技能，因此官方关卡会在地图指定位置预置音响。\n您即将切换至摇滚年代僵王，是否要按照官方关卡的位置一并预置这些音响？';

  @override
  String get zombossMechSwitchBaseOnly => '仅切换机甲';

  @override
  String get zombossMechPreplaceSpeakers => '预置音响';

  @override
  String get zombossMechEightiesSpeakerRemovePromptTitle => '需要删除音响吗？';

  @override
  String get zombossMechEightiesSpeakerRemovePrompt =>
      '您即将从摇滚年代僵王切换至其他基础机甲，是否删除此前按官方位置预置的专属音响？\n仅会删除这些位置上仍为僵王音响的对象，不会影响后来替换成的其他内容。';

  @override
  String get zombossMechKeepSpeakers => '保留音响';

  @override
  String get zombossMechRemoveSpeakers => '删除音响';

  @override
  String get zombossMechRobotSpawnRow => '行';

  @override
  String get zombossMechRobotSpawnRowRandom => '随机 (-1)';

  @override
  String get zombossMechRobotSpawnLevel => '阶级';

  @override
  String get zombossMechRobotSpawnWeight => '权重';

  @override
  String get zombossMechRobotSpawnPlantfood => '携带能量豆';

  @override
  String get zombossMechRetreatAction => '撤退动作';

  @override
  String zombossMechPhaseNumber(int number) {
    return '第 $number 阶段';
  }

  @override
  String get zombossMechAddPhase => '添加阶段';

  @override
  String get zombossMechHitPoints => '生命值';

  @override
  String get continueAnyway => '仍然继续';

  @override
  String get armrackModuleHelpTitle => '兵器架模块说明';

  @override
  String get armrackModuleHelpOverview => '简要介绍';

  @override
  String get armrackModuleHelpOverviewBody =>
      '在场上指定位置放置功夫世界的兵器架。经过兵器架的功夫僵尸和武僧僵尸会拾取架上的兵器，变为对应的特殊僵尸并恢复全部生命值。兵器架自身生命值耗尽，或架上的兵器被拾取后，都会破碎并消失。\n此模块还可以确保兵器架在编辑器和游戏中正常显示，避免被错误显示为阳光贴图。';

  @override
  String get armrackModuleHelpPlacement => '放置方式';

  @override
  String get armrackModuleHelpPlacementBody =>
      '选择兵器架类型后，点击空白格子即可放置选中的兵器架，每格最多放置一个。桌面端右键或移动端长按可删除该格的兵器架。';

  @override
  String get armrackModuleTypePalette => '兵器架类型';

  @override
  String get armrackModuleExpectationLabel => '兵器架';

  @override
  String armrackModuleRequiredMessage(String moduleName) {
    return '为使兵器架正常显示且不出现阳光贴图，需要添加「$moduleName」模块。';
  }

  @override
  String renaiGridItemModuleRequiredMessage(String moduleName) {
    return '复兴圆环需要搭配「$moduleName」才能正常生效。是否添加？';
  }

  @override
  String get energyGridModuleHelpTitle => '太极地砖模块说明';

  @override
  String get energyGridModuleHelpOverview => '简要介绍';

  @override
  String get energyGridModuleHelpOverviewBody =>
      '在场上指定位置生成太极地砖，常见于功夫世界。植物种在太极地砖上后，太极图腾会开始闪烁，并在经过「1000 ÷ 该植物阳光消耗」秒后生成一颗能量豆，随后消失。若该植物的阳光消耗为0，则不会生成能量豆。';

  @override
  String get energyGridModuleHelpPlacement => '放置方式';

  @override
  String get energyGridModuleHelpPlacementBody =>
      '点击空白格子即可放置太极地砖，每格最多放置一个。桌面端右键或移动端长按可删除该格的太极地砖。';

  @override
  String get energyGridModuleTapToPlace => '点击空格放置太极地砖。';

  @override
  String get energyGridModuleExpectationLabel => '太极地砖';

  @override
  String get energyGridModuleWarningMessage =>
      '由于游戏本身的问题，生成的太极地砖可能显示为紫色叉号，但不会影响实际功能。';

  @override
  String get gridOverrideModuleAppearances => '生成组';

  @override
  String get gridOverrideModuleWaveFieldOneBased => '波次编号';

  @override
  String get gridOverrideModuleInitialWaveNote =>
      '本波次用于预置障碍物，添加的障碍物会在关卡开始前出现在场地上。';

  @override
  String gridOverrideModuleWaveSpawnNote(int waveGeneratorWave) {
    return '本波次的障碍物会在波次生成器的第$waveGeneratorWave波开始时生成。';
  }

  @override
  String get gridOverrideModuleWaveSpawnTimelineNote =>
      '由于新旧写法不兼容，波次管理器中无法通过此模块随波次生成障碍物，请使用障碍物生成等事件进行生成。';

  @override
  String get gridOverrideModuleHelpWaveNumbering => '波次编号';

  @override
  String get gridOverrideModuleHelpWaveNumberingBody =>
      '波次编号1用于预置障碍物，添加的障碍物会在关卡开始前出现在场地上。从波次编号2开始，编号与波次生成器中的波次一一对应，如波次编号2对应生成器第1波，波次编号3对应生成器第2波。';

  @override
  String get gridOverridePreviewArmrackTitle => '兵器架布局预览';

  @override
  String get gridOverridePreviewEnergyGridTitle => '太极地砖布局预览';

  @override
  String get waveGeneratorInitialGridOverridesTitle => '初始功夫障碍物管理';

  @override
  String get waveGeneratorPreviewInitialArmrack => '初始兵器架';

  @override
  String get waveGeneratorPreviewInitialEnergyGrid => '初始太极地砖';

  @override
  String waveGeneratorGridOverrideWavePreviewTitle(int wave, String label) {
    return '第$wave波 - $label';
  }

  @override
  String get mechanismPlankStartColumn => '起始列 (mX)';

  @override
  String get mechanismPlankTrackLength => '轨道宽度 (mWidth)';

  @override
  String get mechanismPlankEditNotice =>
      '该界面仅支持编辑轨道宽度和起始列。其他参数采用预设值，因为修改它们可能会导致连体矿车无法正常使用。如需进一步自定义，请手动编辑JSON文件。\n此外，不建议在功夫世界以外的地图中使用连体矿车。连体矿车在其他地图中更容易显示为紫色叉号，虽然不影响实际功能，但可能会影响关卡的整体观感。';

  @override
  String get mechanismPlankOutOfAreaWarning => '当前轨道范围可能超出场地。';

  @override
  String get portalTypeEgypt => '主线埃及';

  @override
  String get portalTypeEgypt2 => '埃及2号';

  @override
  String get portalTypePirate => '主线海盗';

  @override
  String get portalTypeWest => '主线西部';

  @override
  String get portalTypeFuture => '主线未来';

  @override
  String get portalTypeFuture2 => '未来2号';

  @override
  String get portalTypeDark => '主线黑暗';

  @override
  String get portalTypeBeach => '主线沙滩';

  @override
  String get portalTypeIceAge => '主线冰河';

  @override
  String get portalTypeLostCity => '主线失落';

  @override
  String get portalTypeEighties => '主线摇滚';

  @override
  String get portalTypeDino => '主线恐龙';

  @override
  String get portalTypeEndlessEgypt => '无尽埃及';

  @override
  String get portalTypeEndlessPirate => '无尽海盗';

  @override
  String get portalTypeEndlessWest => '无尽西部';

  @override
  String get portalTypeEndlessKongfu => '无尽功夫';

  @override
  String get portalTypeEndlessFuture => '无尽未来';

  @override
  String get portalTypeEndlessDark => '无尽黑暗';

  @override
  String get portalTypeEndlessBeach => '无尽沙滩';

  @override
  String get portalTypeEndlessIceAge => '无尽冰河';

  @override
  String get portalTypeEndlessSkyCity => '无尽天空';

  @override
  String get portalTypeEndlessLostCity => '无尽失落';

  @override
  String get portalTypeEndlessEighties => '无尽摇滚';

  @override
  String get portalTypeEndlessDino => '无尽恐龙';

  @override
  String get portalTypeEndlessModern => '无尽摩登';

  @override
  String get portalTypeMemoryLane1 => '时空能量1';

  @override
  String get portalTypeMemoryLane2 => '时空能量2';

  @override
  String get portalTypeMemoryLane3 => '时空能量3';

  @override
  String get portalTypeShieldGenerator => '电磁盾发生器';

  @override
  String get portalTypeGlacialNianSkill => '寒冰年兽技能';

  @override
  String get portalTypeZombotany => '植物僵尸';

  @override
  String get portalTypeSlimeZombies => '史莱姆僵尸';

  @override
  String get portalTypeUniverse42 => '42号宇宙';

  @override
  String get portalTypeUniverse41 => '41号宇宙';

  @override
  String get portalTypeEliteHealerNormal => '普通治愈';

  @override
  String get portalTypeEliteElectricNormal => '普通闪电';

  @override
  String get portalTypeEliteBallistaNormal => '普通投罐';

  @override
  String get portalTypeEliteOnmyojiNormal => '普通阴阳';

  @override
  String get portalTypeEliteHealerHard => '困难治愈';

  @override
  String get portalTypeEliteElectricHard => '困难闪电';

  @override
  String get portalTypeEliteBallistaHard => '困难投罐';

  @override
  String get portalTypeEliteOnmyojiHard => '困难阴阳';

  @override
  String get portalTypeRomeoHard => '回忆罗密欧';

  @override
  String get portalTypeRomeoHard2 => '回忆罗密欧2';

  @override
  String get portalTypeJulietHard => '回忆朱丽叶';

  @override
  String get portalTypeJulietHard2 => '回忆朱丽叶2';

  @override
  String get portalTypeSherlockHard => '回忆夏洛克';

  @override
  String get portalTypeEliteHunter => '精英猎人';

  @override
  String get portalTypeEliteChief => '精英酋长';

  @override
  String get portalTypeEliteWeasel => '精英冰鼬';

  @override
  String get portalTypeEliteBumperCar => '精英碰碰';

  @override
  String get portalTypeGlacialNian => '寒冰年兽';

  @override
  String get portalTypeEliteWizard => '精英巫师';

  @override
  String get portalTypeEliteKing => '精英国王';

  @override
  String get portalTypeEliteMirrorQueen => '精英魔镜';

  @override
  String get waveGeneratorTabLabel => '波次生成线';

  @override
  String get waveGeneratorModuleHelpTitle => '波次生成器模块说明';

  @override
  String get waveGeneratorModuleHelpOverview => '简要介绍';

  @override
  String get waveGeneratorModuleHelpOverviewBody =>
      '波次生成器是功夫世界、碎片挑战等早期关卡使用的波次系统，各波数据直接存放在模块内，不使用独立的波次事件。\n兵器架和太极地砖模块中的各组数据可与波次生成器的波次一一对应，从而实现类似波次事件的效果。「波次生成线」界面中会标明这些功夫世界障碍物的出现位置。';

  @override
  String get waveGeneratorModuleHelpSpending => '点数出怪';

  @override
  String get waveGeneratorModuleHelpSpendingBody =>
      '随机出怪会消耗当前波的可用点数。游戏会从剩余点数足以生成的僵尸中按权重选择一种，生成后扣除对应的点数并重新筛选，直到没有符合条件的僵尸为止。未使用的点数不会保留到下一波，固定出怪也不会消耗这些点数。';

  @override
  String get waveGeneratorModuleHelpPointTrajectory => '参数介绍';

  @override
  String get waveGeneratorModuleHelpPointTrajectoryBody =>
      '第1波使用「初始随机出怪点数 (WaveSpendingPoints)」，之后点数默认按「每波点数增量 (WaveSpendingPointIncrement)」持续增加，即使某一波禁用了随机出怪也不会暂停。\n「当前波次随机出怪点数 (WavePointStart)」可单独更改当前波的点数，「新点数增量 (WavePointIncrement)」可更改后续波次使用的增量，「重置点数轨迹 (WavePointOverride)」则决定下一波是恢复原本应有的点数，还是以当前波次点数为新起点继续计算。';

  @override
  String get waveGeneratorModuleHelpPool => '僵尸池';

  @override
  String get waveGeneratorModuleHelpPoolBody =>
      '随机出怪使用的僵尸池会随着波次逐步扩充：关卡开始时先使用初始僵尸池，之后每一波加入的僵尸都会保留下来，供本波及后续波次使用。即使本波禁用了随机出怪，本波加入的僵尸也仍会进入僵尸池。';

  @override
  String get waveGeneratorModuleHelpIncompat => '模块兼容性提示';

  @override
  String get waveGeneratorModuleHelpIncompatBody =>
      '波次生成器可能与「看星星」等部分模块不兼容，造成关卡闪退，请谨慎使用。\n「罗马角斗行」模块在波次生成器下不会生效，请改用波次管理器。';

  @override
  String get waveGeneratorModuleHelpRow => '行号';

  @override
  String get waveGeneratorModuleHelpRowBody =>
      '固定出怪的行号从1开始计数，例如第1行填写“1”、第2行填写“2”；填写“?”时，则由游戏随机选择出现行。';

  @override
  String get waveGeneratorModuleGlobalParams => '全局参数';

  @override
  String get waveGeneratorGlobalParams => '波次生成器参数';

  @override
  String get waveGeneratorFlagIntervalHint => '每隔指定波数设置一个旗帜波，不会改变该波的随机出怪点数。';

  @override
  String get flagWaveInterval => '旗帜波间隔 (FlagWaveInterval)';

  @override
  String get waveGeneratorSpendingPoints => '初始随机出怪点数 (WaveSpendingPoints)';

  @override
  String get waveGeneratorSpendingPointIncrement =>
      '每波点数增量 (WaveSpendingPointIncrement)';

  @override
  String get waveGeneratorSpendingCompatibilityWarning =>
      '当前初始随机出怪点数高于每波点数增量，可能导致关卡加载时闪退。';

  @override
  String get waveGeneratorRiseFromGround => '从地底出怪 (IsRiseFromGroundMode)';

  @override
  String get waveGeneratorRiseFromGroundHint => '启用后，僵尸会默认从地底钻出，而非从右侧走入';

  @override
  String get waveGeneratorWaveSpawnTime => '波次出怪延迟 (WaveSpawnTime，单位：秒)';

  @override
  String get waveGeneratorWaveSpawnTimeHint =>
      '从上一波出怪到本波出怪的最短等待时间，只有在「从地底出怪 (IsRiseFromGroundMode)」开启时才会生效。在上一波的出怪行为完成后，游戏会读取本波的出怪延迟时间，开始倒计时。计时结束后，本波僵尸将会出现。\n注意如果本波还设置了「等待上一波僵尸全部死亡后再生成本波 (WaitUntilAllZombiesDie)」，那么这两项条件需要同时满足才会开始本波出怪。上一波结尾若出现了时空黑洞，则出怪延迟时间失效，会在触发黑洞约8秒后进入本波的后续出怪流程。';

  @override
  String get waveGeneratorZombieTargetValidTime =>
      '在场时间 (TargetValidTime，单位：秒)';

  @override
  String get waveGeneratorZombieTargetValidTimeHint =>
      '靶子出现后在场上停留的时间，若留空则默认在1.5秒后消失。';

  @override
  String get waveGeneratorZombieRiseGridX => '出现列 (Rise_GridX)';

  @override
  String get waveGeneratorZombieRiseGridXHint => '该僵尸从地底钻出时位于第几列。';

  @override
  String get waveGeneratorZombieRiseGridY => '出现行 (Rise_GridY)';

  @override
  String get waveGeneratorZombieRiseGridYHint =>
      '该僵尸从地底钻出时位于第几行，优先级高于波次生成器自带的行数。';

  @override
  String waveGeneratorWaveCountSummary(int count) {
    return '共$count波';
  }

  @override
  String get waveGeneratorInitialPool => '初始僵尸池 (AddToZombiePool)';

  @override
  String get waveGeneratorEmptyPool => '初始僵尸池为空。';

  @override
  String get waveGeneratorCustomZombieBlocked => '此处不允许添加自定义僵尸';

  @override
  String get waveGeneratorTabMissingModule => '添加波次生成器模块后，即可在此配置更多组数据。';

  @override
  String waveGeneratorTabSummary(int interval, int points, int increment) {
    return '每$interval波为旗帜波 · 初始点数$points · 每波增加$increment';
  }

  @override
  String get waveGeneratorNoWaves => '尚未配置波次。';

  @override
  String waveGeneratorDeleteWaveConfirm(int count) {
    return '将删除该波及其中的$count只固定出怪。';
  }

  @override
  String get waveGeneratorEmptyWaveRow => '无固定出怪';

  @override
  String get waveGeneratorRandomZombiesLabel => '当前随机出怪池';

  @override
  String get waveGeneratorDisableRandomSpawns => '禁用随机出怪 (DisableRandomSpawns)';

  @override
  String get waveGeneratorDisableRandomSpawnsHint =>
      '启用后仅跳过本波的点数随机出怪；点数仍会按波次继续增加，对僵尸池的修改也会保留并影响后续波次。';

  @override
  String get waveGeneratorWaitUntilAllDie =>
      '等待上一波僵尸全部死亡后再生成本波僵尸 (WaitUntilAllZombiesDie)';

  @override
  String get waveGeneratorSpawnPlantFood => '携带能量豆的僵尸数量 (SpawnPlantFoodCount)';

  @override
  String get waveGeneratorWavePointStart => '当前波次随机出怪点数 (WavePointStart)';

  @override
  String get waveGeneratorWavePointStartHint =>
      '单独设置当前波使用的随机出怪点数；留空则继续使用默认计算出的点数。';

  @override
  String get waveGeneratorWavePointIncrement => '新点数增量 (WavePointIncrement)';

  @override
  String get waveGeneratorWavePointIncrementHint =>
      '更改后续波次使用的点数增量，仅在已设置「当前波次随机出怪点数 (WavePointStart)」时生效。';

  @override
  String get waveGeneratorWavePointOverride => '重置点数轨迹 (WavePointOverride)';

  @override
  String get waveGeneratorWavePointOverrideHint =>
      '关闭时，「当前波次随机出怪点数 (WavePointStart)」只影响当前波，下一波会恢复为按原有波次进度计算出的点数；开启时，则以当前波次点数为新起点，重新计算后续波次的点数。两种情况下，后续波次都会按当前生效的点数增量继续增加。';

  @override
  String get waveGeneratorPointTrajectory => '点数轨迹预览';

  @override
  String get waveGeneratorPointTrajectoryTemporary =>
      '当前波次随机出怪点数只影响本波，下一波会恢复为按原有波次进度计算出的点数，并按当前生效的增量继续增加。';

  @override
  String get waveGeneratorPointTrajectoryReset =>
      '以当前波次随机出怪点数为新起点，重新计算后续波次的点数，并按当前生效的增量继续增加。';

  @override
  String waveGeneratorPointTrajectoryWaveValue(int wave, int points) {
    return '第$wave波 · $points点';
  }

  @override
  String get waveGeneratorBlackHoleFieldHint =>
      '填写列数后，可在本波结束时召唤时空黑洞，将所有植物向右吸动。\n注意：只有本波不是关卡的最后一波，且启用了「等待上一波僵尸全部死亡后再生成本波 (WaitUntilAllZombiesDie)」时，时空黑洞才能正常出现。';

  @override
  String waveGeneratorBlackHoleWaveHint(int cols) {
    return '本波结束时出现时空黑洞，将植物向右吸动$cols列';
  }

  @override
  String get waveGeneratorCurrentPool => '当前有效僵尸池';

  @override
  String get waveGeneratorCurrentPoolEmpty => '当前有效僵尸池为空。';

  @override
  String get waveGeneratorWavePoolAdd => '本波扩展僵尸池 (AddToZombiePool)';

  @override
  String get waveGeneratorWavePoolNoChanges => '本波没有扩展僵尸池。';

  @override
  String get waveGeneratorWaveScreenSubtitle => '波次生成器模块';

  @override
  String get waveGeneratorRandomSpawnsSectionTitle => '随机出怪';

  @override
  String get waveGeneratorZombiePoolSectionTitle => '僵尸池';

  @override
  String get waveGeneratorWaveSettingsTitle => '波次设置';

  @override
  String get waveGeneratorFixedSpawnsHelpTitle => '固定出怪分区说明';

  @override
  String get waveGeneratorRandomSpawnsHelpTitle => '随机出怪分区说明';

  @override
  String get waveGeneratorZombiePoolHelpTitle => '僵尸池分区说明';

  @override
  String get waveGeneratorWaveSettingsHelpTitle => '波次设置分区说明';

  @override
  String get waveGeneratorFixedSpawnsHelpBody =>
      '固定出怪会直接加入当前波，不消耗随机出怪点数，也可以与随机出怪同时使用。';

  @override
  String get waveGeneratorPointTrajectoryHelpBody =>
      '点数轨迹预览展示编辑器根据当前配置计算出的各波有效随机出怪点数，不代表固定出怪的数量。';

  @override
  String get waveGeneratorWavePoolAddHelpBody =>
      '本波扩展的僵尸从当前波起进入有效僵尸池，并继续影响后续波次；即使本波禁用了随机出怪，扩展内容仍会生效。';

  @override
  String get waveGeneratorPoolCompatibilityTitle => '类型限制';

  @override
  String get waveGeneratorPoolCompatibilityHelpBody =>
      '波次生成器的僵尸池仅支持游戏内的默认僵尸类型，不支持关卡中定义的自定义僵尸。';

  @override
  String get waveGeneratorWaitUntilAllDieHelpBody =>
      '决定本波是否等待上一波的僵尸全部死亡后再开始生成。';

  @override
  String get waveGeneratorSpawnPlantFoodHelpBody => '固定设置本波中携带并掉落能量豆的僵尸数量。';

  @override
  String waveGeneratorFixedSummary(int count) {
    return '必定出现$count只僵尸';
  }

  @override
  String get waveGeneratorFixedSummaryEmpty => '无固定出怪';

  @override
  String waveGeneratorRandomSummary(int points) {
    return '已启用 · $points点';
  }

  @override
  String waveGeneratorRandomLocalSummary(int points) {
    return '已启用 · $points点 · 使用当前波次点数';
  }

  @override
  String get waveGeneratorRandomSummaryDisabled => '本波不随机出怪';

  @override
  String waveGeneratorPoolSummary(int current, int added) {
    return '当前$current种 · 本波新增$added种';
  }

  @override
  String waveGeneratorPoolSummaryNoAdditions(int current) {
    return '当前$current种 · 本波无扩展';
  }

  @override
  String get waveGeneratorWaveSettingsDefaultSummary => '默认设置';

  @override
  String waveGeneratorWaveSettingsPlantFoodSummary(int count) {
    return '能量豆 ×$count';
  }

  @override
  String waveGeneratorWaveSettingsBlackHoleSummary(int cols) {
    return '时空黑洞 · 吸动$cols列';
  }

  @override
  String get waveGeneratorExpectationTapHint => '查看本波随机出怪预估结果';

  @override
  String get waveGeneratorStatisticalPreview => '出怪预览';

  @override
  String get waveGeneratorExpectationEmpty => '本波的僵尸池中没有可用于随机出怪的僵尸。';

  @override
  String get waveGeneratorExpectationPoolNote =>
      '预览会通过重复模拟加权选取来估算出怪数量。即使点数相同，结果也可能因选取顺序不同而变化，因此无法准确预测游戏中的实际出怪。';

  @override
  String waveGeneratorExpectationTitle(int wave) {
    return '第$wave波随机出怪预览';
  }

  @override
  String waveGeneratorEffectiveRandomPoints(int points) {
    return '随机出怪点数：$points';
  }

  @override
  String waveGeneratorFixedSpawnCount(int count) {
    return '固定出怪：$count只';
  }

  @override
  String get waveGeneratorFixedSpawns => '固定出怪';

  @override
  String waveGeneratorPoolAddedCount(int count) {
    return '本波扩展僵尸池：$count项';
  }

  @override
  String get waveGeneratorWaitStatus => '等待上一波结束';

  @override
  String get waveGeneratorExpectationDisabled => '本波已禁用随机出怪。';

  @override
  String waveGeneratorExpectationMissingData(String types) {
    return '以下僵尸缺少可靠的 WavePointCost 或 Weight 数据，无法计算随机出怪预览：$types';
  }

  @override
  String waveGeneratorExpectationEstimatedTotal(String count) {
    return '平均随机出怪：约$count只';
  }

  @override
  String waveGeneratorExpectationCommonRange(int minimum, int maximum) {
    return '预计数量范围：$minimum–$maximum只';
  }

  @override
  String waveGeneratorExpectationCostWeight(int cost, String weight) {
    return '消耗$cost · 权重$weight';
  }

  @override
  String waveGeneratorExpectationAverageCount(String count) {
    return '平均$count只';
  }

  @override
  String get protectItems => '保护物品挑战';

  @override
  String get protectGridItemChallengeHelpTitle => '保护物品挑战说明';

  @override
  String get briefOverview => '简要介绍';

  @override
  String get automaticCount => '自动计数';

  @override
  String get operationGuide => '操作指引';

  @override
  String get protectGridItemChallengeHelpOverview =>
      '定义关卡中必须保护的障碍物。如果这些物品被破坏，关卡将立即失败。';

  @override
  String get protectGridItemChallengeHelpAutoCountBody =>
      '软件会自动跟随您添加的物品数量更新需要保护的障碍物数量。';

  @override
  String get protectGridItemChallengeHelpOperationGuide =>
      '在上方网格中点击选择坐标，然后点击“添加目标”按钮选择要保护的物品类型。';

  @override
  String mustProtectCount(int count) {
    return '当前保护目标数量：$count';
  }

  @override
  String get customStageProperties => '自定义地图属性';

  @override
  String get customStageNotFound => '未找到自定义地图对象。';

  @override
  String get customStageSectionGeneral => '常规';

  @override
  String get customStageSectionZombies => '僵尸类型';

  @override
  String get customStageSectionResourceGroups => '资源组';

  @override
  String get customStageSectionMusicAndOther => '基本元素';

  @override
  String get customStageSectionAdvanced => '高级设置';

  @override
  String get customStageAlias => '地图代号 (仅支持英文字母；不支持空格)';

  @override
  String get customStageNoResourceGroups => '列表中没有资源组';

  @override
  String get customStageMissingBackgroundWarning =>
      '请至少导入一个该地图拥有的 DelayLoad_Background 资源组，否则地图无法正常显示。';

  @override
  String get customStageEnableAmbient => '启用环境音';

  @override
  String get customStageDisabledCellsEmpty => '留空';

  @override
  String get customStageDisabledCellsDefault => '默认';

  @override
  String get customStageEnableSubmarine => '启用潜艇';

  @override
  String get customStageSubmarineHitpoints => '潜艇生命值';

  @override
  String get customStageBeachMinigame => '使用小游戏版本';

  @override
  String get customStageOnePerLevelLimit => '此关卡已有自定义地图，请先删除后再添加。';

  @override
  String get selectStageBackground => '选择地图外观';

  @override
  String get searchStageBackground => '搜索地图';

  @override
  String get noStageBackgroundFound => '未找到地图外观';

  @override
  String get stageBackgroundNeedMorePromptTitle => '需要更多地图外观？';

  @override
  String get stageBackgroundNeedMorePromptMessage =>
      '从其他地图导入资源组，以在此解锁更多地图外观选项。';

  @override
  String get stageBackgroundAddFromStage => '添加地图外观';

  @override
  String get customStageNameSuffix => '（自定义）';

  @override
  String get customStageLawnAppearance => '地图外观';

  @override
  String get customStageBaseStage => '基础地图';

  @override
  String get selectCustomStageBase => '选择基础地图';

  @override
  String get noStageBaseFound => '未找到地图';

  @override
  String get importResourceGroup => '导入资源组';

  @override
  String get importResourceGroupGlobal => '单独导入';

  @override
  String get importResourceGroupFromStage => '从地图导入';

  @override
  String get searchResourceGroup => '搜索资源组';

  @override
  String get noResourceGroupFound => '未找到资源组';

  @override
  String get importResourceGroupsFromStageTitle => '从地图添加资源组？';

  @override
  String importResourceGroupsFromStageMessage(String stageName) {
    return '将添加以下来自$stageName的资源组：';
  }

  @override
  String importResourceGroupsFromStageSkipped(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '自定义地图已包含该地图的$count个资源组，这些资源组将不再重复添加。',
      one: '自定义地图已包含该地图的1个资源组，该资源组将不再重复添加。',
    );
    return '$_temp0';
  }

  @override
  String get importResourceGroupsFromStageAllPresent =>
      '该地图的所有资源组已在自定义地图中，无需再次添加。';

  @override
  String get importResourceGroupsApplySourceLawnAppearance => '同时改用该地图的外观';

  @override
  String get createCustomStage => '创建自定义地图';

  @override
  String get createCustomStageHint => '选择基础地图外观并编辑地图属性';

  @override
  String get customStageAliasPromptTitle => '自定义地图代号';

  @override
  String get customStageAliasTaken => '该代号在关卡中已被占用，请另想一个代号。';

  @override
  String get stageSelectionTabBuiltin => '默认';

  @override
  String get stageSelectionTabCustom => '自定义';

  @override
  String get customStageSelectionEmpty => '此关卡中尚无自定义地图';

  @override
  String get customStageSelectionInLevel => '关卡使用的自定义地图';

  @override
  String get customStageSwitchToBuiltinTitle => '确定要切换为默认地图吗？';

  @override
  String get customStageSwitchToBuiltinMessage => '将永久删除原本使用的自定义地图数据，此操作不可撤销。';

  @override
  String get customStageDeleteTitle => '确定要删除自定义地图吗？';

  @override
  String get customStageDeleteMessage =>
      '将在关卡中永久删除该自定义地图的相关数据，并将当前地图切换为默认的教程庭院地图。';

  @override
  String get customStagePresetSectionTitle => '预设自定义地图';

  @override
  String get startupLoadingLocalization => '本地化文本';

  @override
  String get startupLoadingStages => '地图';

  @override
  String get startupLoadingAudio => '音频';

  @override
  String get startupLoadingGridItems => '障碍物';

  @override
  String get startupLoadingZomboss => '僵王';

  @override
  String get startupLoadingReference => '参考数据';

  @override
  String get startupLoadingZombies => '僵尸';

  @override
  String get startupLoadingPlants => '植物';

  @override
  String get startupLoadingFish => '海洋生物';

  @override
  String get startupLoadingImages => '图片';

  @override
  String get startupLoadingPlugins => '插件';

  @override
  String startupLoadingCategoryProgress(String category) {
    return '正在加载$category...';
  }

  @override
  String get reselectFiles => '重新选择文件';

  @override
  String get validationReviewRequest => '请查看所选关卡的校验结果。';

  @override
  String get validationRecommendation => '建议在导出前修改这些关卡以修复问题，或者选择其他文件。';

  @override
  String get customPortalAdd => '新建自定义裂缝';

  @override
  String get customPortalSingleName => '自定义裂缝';

  @override
  String get customPortalCreateTitle => '创建自定义裂缝';

  @override
  String get customPortalEditTitle => '编辑自定义裂缝';

  @override
  String get customPortalSelectBaseTitle => '选择基础裂缝';

  @override
  String get customPortalBlankTemplate => '空白裂缝模板';

  @override
  String get customPortalBlankTemplateSubtitle => '使用标准裂缝结构创建，不预先添加僵尸';

  @override
  String get customPortalBuiltInBases => '默认裂缝';

  @override
  String get customPortalUnusedTitle => '清除未使用的自定义裂缝？';

  @override
  String get customPortalUnusedSingleMessage => '自定义裂缝已不再被使用，是否从关卡中清除其关联数据对象？';

  @override
  String get customPortalAppearanceSection => '裂缝外观';

  @override
  String get customPortalSpawnSection => '僵尸生成';

  @override
  String get customPortalWorld => '世界外观';

  @override
  String get customPortalWorldTwister => '空白';

  @override
  String get customPortalPopAnimation => '裂缝动画';

  @override
  String get customPortalAnimationModern => '摩登世界裂缝动画';

  @override
  String get customPortalAnimationMemoryLane => '回忆之旅裂缝动画';

  @override
  String get customPortalAnimationHydra => '魔咒吟唱者魔镜动画';

  @override
  String get customPortalSpawnMethod => '僵尸生成方式';

  @override
  String get customPortalSpawnMethodShuffled => '乱序依次生成';

  @override
  String get customPortalSpawnMethodInOrder => '按顺序生成';

  @override
  String get customPortalSpawnMethodHydra => '魔咒吟唱者随机生成';

  @override
  String get customPortalZombieTypes => '可生成的僵尸';

  @override
  String get customPortalSpawnInterval => '僵尸生成间隔';

  @override
  String get customPortalSpawnIntervalSubtitle => '设置僵尸从裂缝出现所需的最短与最长时间。';

  @override
  String get moduleTitle_MoonLifeSupportSystemProperties => '维生系统';

  @override
  String get moduleDesc_MoonLifeSupportSystemProperties => '配置月球基地的电力容量与过载协议';

  @override
  String get moduleTitle_LunarTerminalModuleProperties => '月能采集终端';

  @override
  String get moduleDesc_LunarTerminalModuleProperties => '部署采矿机器人采集水晶能量，提高电力上限';

  @override
  String get moduleTitle_LunarMineVeinModuleProperties => '月球晶矿';

  @override
  String get moduleDesc_LunarMineVeinModuleProperties => '放置月能水晶矿脉并设置其成长波次';

  @override
  String get moduleTitle_RadiationMeteorModuleProperties => '辐射陨石';

  @override
  String get moduleDesc_RadiationMeteorModuleProperties => '天降陨石，摧毁单位并侵蚀周围地块';

  @override
  String get eventTitle_SpawnRocketLandingWaveActionProps => '火箭降落';

  @override
  String get eventDesc_SpawnRocketLandingWaveActionProps => '在指定位置生成可被占领的月球火箭';

  @override
  String get moonLifeSupportHelpTitle => '维生系统';

  @override
  String get moonLifeSupportHelpOverview =>
      '常见于月球基地关卡的经济系统。添加该模块后，植物种植不消耗阳光，而是实时占用维生系统的一定电力容量。植物被铲除、被僵尸摧毁或因特殊机制消失时，其占用的容量会立即全额返还。\n注意，该模块还会屏蔽四阶及以上植物的落地开大效果。';

  @override
  String get moonLifeSupportHelpProtocolsTitle => '过载协议';

  @override
  String get moonLifeSupportHelpProtocols =>
      '当维生系统的电力超过初始电力容量时，系统会进入过载状态并启动节能协议，降低场上植物的攻击速度和卡槽的冷却恢复速度。\n当电力值超过（初始电力容量×休眠所需倍率）时，系统会在设定倒计时结束后强制进入休眠协议，使场上所有植物进入休眠状态，卡槽和宇宙能量豆槽也会被锁定，无法继续使用。';

  @override
  String get moonLifeSupportHelpPlantFoodTitle => '独立冷却';

  @override
  String get moonLifeSupportHelpPlantFood =>
      '模块为拥有独立冷却的植物定义了专属列表，列表中植物的冷却时间不会受到节能协议的影响，但在休眠协议下仍会强制无法种植。';

  @override
  String get moonLifeSupportPowerSettings => '电力设置';

  @override
  String get moonInitialCapacity => '初始电力容量 (InitialCapacity)';

  @override
  String get moonBufferOverloadRatio => '休眠所需倍率 (BufferOverloadRatio)';

  @override
  String get moonPenaltyCountdown => '休眠倒计时 (PenaltyCountdown，单位：秒)';

  @override
  String get moonPlantImmunityList => '拥有独立冷却的植物 (PlantImmunityList)';

  @override
  String get moonPlantImmunityListHint =>
      '列表中植物的冷却时间不会受到节能协议的影响，但在休眠协议下仍会强制无法种植。';

  @override
  String get moonSelectImmunePlants => '选择植物加入列表';

  @override
  String get lunarTerminalHelpTitle => '月能采集终端';

  @override
  String get lunarTerminalHelpOverview =>
      '常见于月球基地关卡的神器道具，在场地中的位置固定，类似天空之城的火炮。点击采集终端后，可从三种采矿机器人中选择一种并拖动至场上。机器人会自动采集范围内月能水晶和辐射陨石的能量，从而为基地维生系统永久提升本局可用的电力容量，支持布置更强大的阵容。机器人拥有一定生命值，会被僵尸、辐射陨石等目标攻击并摧毁。';

  @override
  String get lunarTerminalHelpFixedTitle => '部署冷却';

  @override
  String get lunarTerminalHelpFixed =>
      '月能采集终端每次部署机器人后都会进入一段冷却时间，具体冷却时长可在关卡中自定义。';

  @override
  String get lunarTerminalCollectorCooldown =>
      '机器人部署冷却 (CollectorCooldown，单位：秒)';

  @override
  String get lunarMineVeinHelpTitle => '月球晶矿';

  @override
  String get lunarMineVeinHelpOverview =>
      '在关卡开始时于场上放置月能水晶矿脉，常见于月球基地。晶矿初始无法提供能量，进入设定波次后，会在原位置生长出对应类型的水晶，此后可按其特性进行开采。选择晶矿类型后，点击网格放置；桌面端右键或移动端长按可删除。';

  @override
  String get lunarMineVeinTypePalette => '晶矿类型';

  @override
  String get lunarMineVeinHelpHardened =>
      '外层有坚固岩石保护，需要使用植物的攻击摧毁外壳后才可以正常开采。坚壳晶矿生长出的坚壳水晶固定为3000生命值的版本。';

  @override
  String get lunarMineVeinHelpFragile =>
      '采集过程会持续消耗耐久，直至晶体碎裂。可以添加蕴含宇宙能量豆的特殊易碎晶矿。';

  @override
  String get lunarMineVeinHelpRadiation =>
      '每隔一段时间持续向四周发散辐射，将受到辐射的植物随机变为其他植物，对僵尸造成伤害或使其变异为宇宙辐射巨人僵尸。宇宙辐射巨人僵尸具备超高血量，击败时还将辐射附近的植物和僵尸。';

  @override
  String get lunarMineVeinHelpWaveTitle => '波次编号';

  @override
  String get lunarMineVeinHelpWave =>
      '成长波次 (EmergenceWave) 从1开始计数：第1波成长填1，第2波成长填2，以此类推。';

  @override
  String get lunarMineVeinPlacements => '晶矿放置 (VeinPlacements)';

  @override
  String get lunarMineVeinModuleExpectationLabel => '月球晶矿';

  @override
  String get lunarMineVeinModulePreviewEmerging => '本波生长的月能水晶：';

  @override
  String get lunarMineEmergenceWave => '成长波次 (EmergenceWave，从1开始计数)';

  @override
  String get moonPlacementGestureHint => '点击空地块添加项目；右键单击或长按已有项目的地块可将其移除。';

  @override
  String get moduleTitle_GladiatorRowModuleProperties => '罗马角斗行';

  @override
  String get moduleDesc_GladiatorRowModuleProperties =>
      '临时封锁横向五格，根据角斗胜负获得奖励或惩罚';

  @override
  String get gladiatorSettings => '全局角斗与奖惩设置';

  @override
  String get gladiatorArenaDuration => '角斗时长 (ArenaDuration，单位：秒)';

  @override
  String get gladiatorRewardCount => '胜利能量豆奖励 (PlantWinPlantfoodCount)';

  @override
  String get gladiatorPunishmentCount =>
      '失败铁笼数量 (ZombieWinPunishmentCageCount)';

  @override
  String get gladiatorPunishmentDuration =>
      '失败空投持续时间 (ZombieWinPunishmentDuration，单位：秒)';

  @override
  String get gladiatorPunishmentLevel =>
      '降落的僵尸阶级 (ZombieWinPunishmentZombieLevel)';

  @override
  String get gladiatorEncounters => '角斗安排 (Encounters)';

  @override
  String get gladiatorWave => '触发波次 (Wave，从0开始计数)';

  @override
  String get gladiatorRow => '所在行 (Row，从0开始计数)';

  @override
  String get gladiatorWarningDuration => '僵王登场预警时长 (WarningDuration，单位：秒)';

  @override
  String get gladiatorFirstCageDelay => '首个铁笼降落延迟 (FirstCageDelay，单位：秒)';

  @override
  String get gladiatorPreviewTitle => '角斗行范围预览';

  @override
  String get gladiatorPreviewLegend =>
      '绿色方格代表固定位于第5列的奖杯，红色方格代表其余角斗格。僵尸图标表示铁笼出怪位置，同格数字表示僵尸的数量。点击网格可选择所在行。';

  @override
  String get gladiatorSpawns => '铁笼出怪安排 (Spawns)';

  @override
  String get gladiatorAddSpawn => '添加铁笼出怪';

  @override
  String get gladiatorSpawnTime => '角斗开始后的出怪延迟 (Time，单位：秒)';

  @override
  String get gladiatorSpawnColumn => '出怪列 (GridX，从0开始计数)';

  @override
  String get gladiatorSpawnCount => '出怪数量 (Count)';

  @override
  String get gladiatorSpawnInterval => '出怪间隔 (Interval，单位：秒)';

  @override
  String get gladiatorSpawnLevel => '僵尸阶级 (Level)';

  @override
  String get gladiatorPunishmentPool =>
      '失败惩罚僵尸池 (ZombieWinPunishmentZombiePool)';

  @override
  String get gladiatorPunishmentHint => '角斗失败后，空投铁笼从此列表按权重选择僵尸。权重越大，出现概率越高。';

  @override
  String get gladiatorAddPunishment => '添加惩罚僵尸';

  @override
  String get gladiatorWeight => '出现权重 (Weight)';

  @override
  String get gladiatorCompatibilityWarningTitle => '模块兼容性提示';

  @override
  String get gladiatorWaveGeneratorCompatibilityWarning =>
      '「罗马角斗行」模块在波次生成器下不会生效，请改用波次管理器。';

  @override
  String get gladiatorUnderwaterMismatchWarning =>
      '当前地图为海底世界外观的六行地图，「罗马角斗行」不会生成。请改用五行地图。';

  @override
  String get gladiatorLegacyModeWarning =>
      '检测到当前模块的对决模式 (GameplayVersion) 不为1，可能使用的是废弃的旧版对决模式而非奖杯对决模式，无法预览角斗行范围。';

  @override
  String get gladiatorUseTrophyMode => '切换至奖杯对决模式';

  @override
  String get gladiatorHelpTipsTitle => '温馨提示';

  @override
  String get gladiatorHelpOverview =>
      '此模块用于配置关卡中随波次出现的“角斗行”机制，常见于罗马荣光秘境。到达指定波次时，罗马僵王会出现在指定行，临时封锁该行的横向五格，消灭五格内原有的植物和僵尸，并停止五格外植物和僵尸的行动，形成“角斗行”。\n角斗行中心会升起一座奖杯。僵尸会通过右侧空投的铁笼进入角斗行，植物方需要竭尽全力保护奖杯，坚守到计时结束即可获胜。角斗胜利，玩家将获得大量能量豆奖励；角斗失败，场上会空投铁笼，释放大量僵尸。角斗结束后，角斗行内已有的植物和僵尸会被摧毁。';

  @override
  String get gladiatorHelpUsage =>
      '上方的角斗时长、胜利能量豆数量及失败空投参数，以及下方的惩罚僵尸池和权重，均为全局参数，会对模块中的所有角斗生效。点击“添加角斗”，可设置每组角斗的具体参数。加入僵尸时，会自动在模块中添加对应僵尸的资源组。角斗的波次 (Wave)、所在行 (Row)、出怪列 (GridX) 均从0开始计数，如波次填0对应波次时间线的第1波，填4对应第5波。本模块的对决模式 (GameplayVersion) 在编辑器中默认为1，填0会使用另一种废弃的对决模式，可通过手动编辑模式自行探索。';

  @override
  String get gladiatorHelpTips =>
      '角斗期间，种植植物不再消耗阳光，但仍然会占用维生系统的电力容量。\n巨人僵尸等僵尸的秒杀攻击无法对奖杯造成伤害。\n植物射出角斗行范围的子弹会被围栏阻挡，而离开角斗行范围的僵尸或部分技能瞄准角斗行范围外的僵尸则会静止不动，在角斗计时结束后被释放，继续进攻。\n注意角斗行不会在“海底世界-海底两万里”或“海底世界-亚特兰蒂斯”等海底世界外观的六行地图中生成，「罗马角斗行」模块在波次生成器下也不会生效。';

  @override
  String get radiationMeteorHelpTitle => '辐射陨石';

  @override
  String get radiationMeteorHelpOverview =>
      '在指定波次降下特殊的辐射陨石，常见于月球基地。陨石落下前，关卡中会显示红字警告，预计落点也会出现准星标记。预警持续指定时间后，陨石会垂直落下，直接消灭落点格上的单位，随后以顺时针方向缓慢侵蚀周围地块。\n污染地块上的僵尸会获得移速加成和生命值恢复效果，宇宙植物则会持续受到伤害。';

  @override
  String get radiationMeteorHelpWaveTitle => '波次计数';

  @override
  String get radiationMeteorHelpWave =>
      '辐射陨石的降落波次从0开始计数，如第1波降落填0，第2波降落填1。编辑器新增降落安排时，第1组默认为0，第2组默认为1，以此类推。';

  @override
  String get radiationMeteorHelpMiningTitle => '挖矿销毁';

  @override
  String get radiationMeteorHelpMining =>
      '月能采集单元可以挖掘辐射陨石，经过一段时间后摧毁陨石。摧毁陨石后，终端将为玩家提供本局永久生效的电力容量，并消除污染效果。';

  @override
  String get radiationMeteorParameters => '陨石参数';

  @override
  String get radiationMeteorWarningDuration => '预警时长 (WarningDuration，单位：秒)';

  @override
  String get radiationMeteorPollutionInterval =>
      '污染间隔 (PollutionInterval，单位：秒)';

  @override
  String get radiationMeteorMiningDuration =>
      '所需开采时长 (MiningDurationRequired，单位：秒)';

  @override
  String get radiationMeteorPowerReward => '摧毁后电力奖励 (PowerRewardOnDestroy)';

  @override
  String get radiationMeteorSpawnSchedule => '降落安排 (SpawnSchedule)';

  @override
  String get radiationMeteorWave => '波次 (Wave，从0开始计数)';

  @override
  String get radiationMeteorModuleExpectationLabel => '辐射陨石';

  @override
  String get radiationMeteorModulePreviewLanding => '本波降落的陨石：';

  @override
  String get eventTitle_GravityGeneratorWaveActionProps => '重力发生器';

  @override
  String get eventDesc_GravityGeneratorWaveActionProps => '为植物或格子施加不同等级引力状态';

  @override
  String get gravityLevel => '引力状态 (GravityLevel)';

  @override
  String get gravityAnti => '反重力 (anti)';

  @override
  String get gravityHeavy => '超重力 (heavy)';

  @override
  String get gravityTargetType => '目标类型 (TargetType)';

  @override
  String get gravityTargetPlant => '随机植物 (plant)';

  @override
  String get gravityTargetGrid => '固定格子 (grid)';

  @override
  String get gravityRangeX => '横向偏移 (Range.mX)';

  @override
  String get gravityRangeY => '纵向偏移 (Range.mY)';

  @override
  String get gravityRangeWidth => '范围宽度 (Range.mWidth，单位：格)';

  @override
  String get gravityRangeHeight => '范围高度 (Range.mHeight，单位：格)';

  @override
  String get gravityTargetX => '目标列 (TargetGrid.mX，从0开始计数)';

  @override
  String get gravityTargetY => '目标行 (TargetGrid.mY，从0开始计数)';

  @override
  String get gravityPreviewTitle => '引力场生效范围预览';

  @override
  String get gravityPlantRangeHint =>
      '随机选择场上一株植物作为定位基准，影响范围内的植物和僵尸。十字标记为目标植物；范围从偏移后的位置起，向右、向下延伸，并包含起始格。负偏移表示向左或向上移动范围起点。';

  @override
  String get gravityGridRangeHint =>
      '行列均从0开始计数，点击网格可选择定位基准格。范围起点为目标格加上横向、纵向偏移，再向右、向下延伸，宽度和高度均包含起始格。例如偏移为0、宽3高1时，覆盖目标格及其右侧两格。';

  @override
  String get gravityCenterLegend => '十字：定位基准点';

  @override
  String get gravityRestrictions => '不受影响的植物和僵尸 (TargetRestriction)';

  @override
  String get gravityRestrictionHint => '此列表中的植物和僵尸不会受到引力场的影响。留空表示不额外排除任何类型。';

  @override
  String get gravityAddPlantRestriction => '添加不受影响的植物';

  @override
  String get gravityAddZombieRestriction => '添加不受影响的僵尸';

  @override
  String get gravityAdvancedSettings => '动作与时序参数';

  @override
  String get gravityActivationDelay => '触发延迟 (ActivationDelay，单位：秒)';

  @override
  String get gravityDuration => '引力状态持续时间 (Duration，单位：秒)';

  @override
  String get gravityDeployDuration => '装置展开时间 (DeployDuration，单位：秒)';

  @override
  String get gravityChargeDuration => '施加引力前的蓄力时间 (ChargeDuration，单位：秒)';

  @override
  String get gravityRetractDuration => '装置回收冷却时间 (RetractDuration，单位：秒)';

  @override
  String get gravityPlantExitDelay => '植物浮空后消失时间 (PlantExitDelay，单位：秒)';

  @override
  String get gravityZombieRiseDuration => '僵尸浮空上升时间 (ZombieRiseDuration，单位：秒)';

  @override
  String get gravityZombieTranslateDuration =>
      '僵尸浮空前移时间 (ZombieTranslateDuration，单位：秒)';

  @override
  String get gravityZombieFallDuration =>
      '僵尸到达目的地后的降落时间 (ZombieFallDuration，单位：秒)';

  @override
  String get gravityZombieLiftHeight => '僵尸浮空高度 (ZombieLiftHeight)';

  @override
  String get gravityZombieForwardDistance =>
      '僵尸前移距离 (ZombieForwardDistance，64像素=1格)';

  @override
  String get gravityHeavyPlantSinkDuration =>
      '超重力植物下沉时间 (HeavyPlantSinkDuration，单位：秒)';

  @override
  String get gravityHelpParametersTitle => '参数说明';

  @override
  String get gravityHelpParameters =>
      '本事件默认包含反重力和超重力两种状态使用的所有参数。动作参数区会随引力状态切换，仅显示当前模式使用的参数；另一模式已填写的数值会保留。';

  @override
  String get gravityHelpTipsTitle => '温馨提示';

  @override
  String get gravitySequentialNotice =>
      '多个重力发生器事件不能同时进行。前一次反重力或超重力流程结束后才能进行下一次，请错开事件触发时间。';

  @override
  String get gravityHelpOverview =>
      '僵尸方基地上的装置，作为预设战场事件在指定波次触发。装置从基地探出后锁定场上固定范围内的植物或僵尸，发射引力光束为其施加不同等级引力状态，干扰植物攻击节奏与僵尸移动方式。';

  @override
  String get gravityHelpAnti =>
      '被锁定的植物缓慢上浮，一段时间后飘离战场消失；被锁定的僵尸上升并向前移动，空中免疫平射攻击。\n当重力树攻击范围内有处于反重力状态的植物时，重力树会攻击并清除攻击范围内植物的反重力状态。重力树自身免疫引力发生器效果，不被浮空，也不被压入土中。';

  @override
  String get gravityHelpHeavy =>
      '被锁定的植物将其一半压入土中，期间无法攻击，可被僵尸啃食；被锁定的僵尸稳固行进，免疫击退效果。\n宇宙飞碟瓜可以解除僵尸的超重力状态，并使其进入悬浮态；同时还可以解除植物的超重力状态，使其恢复正常。';

  @override
  String get rocketLandingHelpTitle => '火箭降落';

  @override
  String get rocketLandingHelpOverview =>
      '常见于月球基地的事件，在指定位置生成火箭，作为植物和僵尸双方争夺的目标。';

  @override
  String get rocketLandingHelpPlantsTitle => '植物占领';

  @override
  String get rocketLandingHelpPlants =>
      '将指定宇宙植物种在火箭内，一段时间后火箭会发射升空，锁定场上的高威胁僵尸轰炸并造成高额伤害。宇宙豌豆会爆发可在场上反弹的宇宙子弹；宇宙蘑菇会在范围内召唤蘑菇虫洞；宇宙坚果会产生短暂存在的小型黑洞，拖拽并持续伤害附近僵尸。';

  @override
  String get rocketLandingHelpZombiesTitle => '僵尸占领';

  @override
  String get rocketLandingHelpZombies =>
      '僵尸进入火箭后，火箭会在片刻后发射并向场地后方某格降落，将僵尸传送到该格。部分僵尸无法进入火箭。';

  @override
  String get rocketLandingSettings => '火箭设置';

  @override
  String get rocketSpawnInterval => '生成间隔 (SpawnInterval，单位：秒)';

  @override
  String get moduleTitle_LevelPowerupModuleProperties => '金手指';

  @override
  String get moduleDesc_LevelPowerupModuleProperties => '使用妙趣横生的手势系统';

  @override
  String get powerUpsHelpTitle => '金手指';

  @override
  String get powerUpsHelpOverview =>
      '于十三周年秘境重磅回归的“六脉神剑”，允许玩家在道具持续时间内使用特定手势操作击杀僵尸。开启本模块后可设置各个金手指在关卡中免费使用的具体次数。注意国际版中的冰雹指和火焰指在中文版并不存在，砸罐子和宝石迷阵模式下的强化道具也不能通过此模块添加。';

  @override
  String get powerUpsAddTitle => '添加金手指';

  @override
  String get powerUpsOrder => '排列顺序';

  @override
  String get powerUpsOrderInfo =>
      '游戏中的金手指会按照此处的顺序排列。拖动 ⋮⋮ 可调整顺序。将金手指从列表中移除后，该金手指将不会在游戏中出现；需要时可在本模块中重新添加。';

  @override
  String get powerUpsFreeUseCount => '免费使用次数 (FreeUseCount)';

  @override
  String get powerZap => '闪电指';

  @override
  String get powerZapInfo => '点击或拖动对僵尸释放强力电击，对触碰到的僵尸持续造成伤害。';

  @override
  String get powerToss => '浮空指';

  @override
  String get powerTossInfo => '在僵尸身上快速划动，将其弹向空中；再次划动，还能把僵尸直接甩出战场。';

  @override
  String get powerPinch => '剪刀指';

  @override
  String get powerPinchInfo => '用双指对准僵尸做捏合手势，像使用剪刀一样剪掉僵尸的脑袋，快速解除威胁。';

  @override
  String get moduleTitle_StatueMazeModuleProperties => '僵尸迷阵';

  @override
  String get moduleDesc_StatueMazeModuleProperties => '在旋转过后的雕像阵列中找出所有隐藏的僵尸';

  @override
  String get moduleHelpStatueMazeOverviewBody =>
      '复兴时代的专属小游戏。小游戏分为多个轮次，每轮都会在场上生成一组雕像阵列，其中部分雕像内藏有贵族僵尸。每轮开始时，会先向玩家展示藏有僵尸的雕像位置，随后整个雕像阵列会旋转若干次，干扰玩家的记忆。旋转结束后，玩家需要消耗手中的工具，砸碎所有藏有僵尸的雕像。若可用次数耗尽时仍未找出所有僵尸，则关卡失败。注意玩家也可以在次数耗尽时花费钻石购买额外次数。';

  @override
  String get moduleHelpStatueMazeTimingTitle => '时间参数';

  @override
  String get moduleHelpStatueMazeTimingBody =>
      '初始展示时间（DisplayTime）：从显示藏有僵尸的雕像开始，到第一次旋转开始前的等待时间。\n步骤总时长（WaitDuration）：从本次旋转开始，到下一次旋转开始之间的总时间。每轮的最后一个旋转步骤同样会完整经过该时长，随后才进入玩家操作阶段。\n旋转所需时间（RotateTime）：本次 90° 旋转动画的播放时长。\n因此，两次旋转之间的实际等待时间为「步骤总时长 − 旋转所需时间」。若旋转所需时间大于步骤总时长，下一次旋转会在上一次旋转尚未结束时启动，并重置雕像的移动参数，可能导致旋转轨迹或动画表现异常。\n注意两个轮次之间的黑屏过渡时间为固定值，无法在关卡中自定义。';

  @override
  String get statueMazeDisplayTime => '初始展示时间（DisplayTime，单位：秒）';

  @override
  String get statueMazeTargetNum => '僵尸数量 (TargetNum)';

  @override
  String get statueMazeBonusLife => '额外尝试次数 (BonusLife)';

  @override
  String get statueMazeWaitDuration => '步骤总时长（WaitDuration, 单位：秒）';

  @override
  String get statueMazeRotateTime => '旋转所需时间（RotateTime，单位：秒）';

  @override
  String get statueMazeAddSet => '添加轮次';

  @override
  String get statueMazeSets => '旋转轮次';

  @override
  String get statueMazeRotations => '旋转步骤';

  @override
  String get statueMazeGridSize => '阵列大小';

  @override
  String get statueMazeNoRotations => '暂无旋转步骤';

  @override
  String get moduleHelpStatueMazeRotationsBody =>
      '每轮可以添加多个旋转步骤，每个步骤都会使整个阵列旋转90°。“C”代表顺时针旋转，“AC”代表逆时针旋转。点击网格下方的播放键，可以一次性预览本轮所有旋转步骤的模拟效果。';

  @override
  String get statueMazeRotationsHint => '点击箭头切换旋转方向，点击卡片编辑此次旋转的参数，长按卡片删除此次旋转。';

  @override
  String get statueMazeRemoveRotationConfirm => '确定要移除此旋转步骤吗？';

  @override
  String get camelGenerationParameters => '生成参数';

  @override
  String get camelSpawnDistance => '召唤距离';

  @override
  String get camelSpawnPreview => '召唤距离预览';

  @override
  String get camelSpawnCoordinatesHint =>
      '横向坐标以第1列左边界为0，每格间隔为64。彩线标出各召唤距离参数的位置；额外后移距离仅在生成位置已有僵尸时生效。';

  @override
  String get camelCompatibilityWarning =>
      '本模块仅适用于使用特殊「记忆骆驼牌僵尸」且种子库为预选模式的关卡。若关卡中出现其他僵尸，或种子库使用自选模式，游戏会闪退。';

  @override
  String get camelHelpSpawningTitle => '出怪逻辑';

  @override
  String get camelHelpTutorialTitle => '显示教程对话';

  @override
  String get camelHelpTipsTitle => '温馨提示';

  @override
  String get moduleHelpCamelTutorialBody =>
      '开启“显示教程对话”后，戴夫和潘妮会在关卡开始前出现，指引玩家如何通过配对赢得比赛。对话内容固定为首次游玩神秘埃及-第7天时的剧情。';

  @override
  String get moduleHelpCamelTipsBody =>
      '本模块仅适用于使用特殊「记忆骆驼牌僵尸」且种子库为预选模式的关卡。若关卡中出现其他僵尸，或种子库使用自选模式，游戏会闪退。\n植物可以与记忆骆驼牌僵尸正常交互，但记忆骆驼牌僵尸在被魅惑、被击杀等情况下可能出现动画异常，使用时请注意。';

  @override
  String get conflictDesc_CamelMinigameChooser =>
      '记忆骆驼牌与种子库的自选模式存在冲突，会导致关卡闪退。请将种子库切换为预选模式。';

  @override
  String get moduleTitle_CamelMinigameProperties => '记忆骆驼牌';

  @override
  String get moduleDesc_CamelMinigameProperties => '配置木乃伊记忆小游戏中骆驼牌的生成范围与参数';

  @override
  String get moduleHelpCamelOverviewBody =>
      '神秘埃及的专属小游戏。关卡会从地底召唤特殊的骆驼牌僵尸，玩家点击骆驼牌僵尸后可以查看其骆驼牌对应的图案进行消除。如果玩家翻出了两个一样的图案，则僵尸会立即死亡；如果翻出的两个图案不一样，则骆驼牌将翻转回去，僵尸继续行进。如果最后场上只剩下一个骆驼牌僵尸，或是剩下两个图案不同的骆驼牌僵尸时，僵尸会在翻转其骆驼牌后直接死亡。';

  @override
  String get moduleHelpCamelSpawningBody =>
      '在本模块下，普通出怪、海底出怪等常规出怪事件中的僵尸均会直接从地底出现，出现的具体范围可以通过调整参数进行配置，横向坐标以第1列左边界为0，每格间隔为64。通过沙尘暴、运兵艇突袭、障碍物生成等事件和模块生成的僵尸不受影响。';

  @override
  String get camelAdditionalXBuffer =>
      '生成位置被占用时的额外后移距离 (AdditionalXBufferBetweenChains)';

  @override
  String get camelRiseStagger => '同组相邻骆驼牌钻出间隔 (CamelSegmentRiseStagger，单位：秒)';

  @override
  String get camelCardMatchTime => '卡片匹配成功反应时间 (CardMatchTime，单位：秒)';

  @override
  String get camelCardMatchingTime => '翻牌时间 (CardMatchingTime，单位：秒)';

  @override
  String get camelCardNoMatchTime => '匹配失败或单张翻牌闲置时间 (CardNoMatchTime，单位：秒)';

  @override
  String get camelCardTypesUsed => '骆驼牌种类 (CardTypesUsed)';

  @override
  String get camelTutorialRiseDelay =>
      '从地底钻出所需时间 (InitialTutorialZombieRiseDelay，单位：秒)';

  @override
  String get camelMaxSpawnX => '最大召唤距离 (MaxSpawnX)';

  @override
  String get camelMinSpawnXEnd => '最大召唤距离末端位置 (MinSpawnXEnd)';

  @override
  String get camelMinSpawnXStart => '最小召唤距离起始位置 (MinSpawnXStart)';

  @override
  String get camelShowTutorial => '显示教程对话 (ShowTutorial)';

  @override
  String get moduleTitle_OakTrainProperties => '百步穿僵';

  @override
  String get moduleDesc_OakTrainProperties => '操控橡木弓手，消耗箭矢“爆头”敌人并获得分数';

  @override
  String get moduleHelpOakTrainOverviewBody =>
      '黑暗时代的专属小游戏。场地第一列第三行会预置一株橡木弓手，玩家需要操控这株橡木弓手，使用三种不同箭矢“爆头”目标，获得胜利。若橡木弓手生命值耗尽或僵尸进家，则游戏失败。';

  @override
  String get moduleHelpOakTrainScoresBody =>
      '击败不同种类的僵尸可以获得不同的分数，分数会在过关时折算为硬币，在庭院模块下捡拾这些硬币不会生效。注意这里的分数跟积分模块下杀死僵尸获得的分数不是一种，是分开计算的，不会计入获取积分挑战。';

  @override
  String get moduleHelpOakTrainArrowsBody =>
      '橡木弓手可以发射三种箭矢，普通箭矢为普通单体攻击，强攻箭矢为双倍伤害的小范围群体攻击、散射箭矢为七连散射的单体攻击。普通箭矢会在用完后10秒钟自动装填12支，其他的箭矢都需要攻击场上不同颜色的靶子获取。注意散射箭矢还可以在关卡中花费钻石购买。';

  @override
  String get oakTrainTotalLife => '总生命值 (TotalLife)';

  @override
  String get oakTrainArrowScore => '基础攻击得分 (ArrowScore)';

  @override
  String get oakTrainWizardScore => '击杀巫师得分 (WizardScore)';

  @override
  String get oakTrainArchmageScore => '击杀大法师得分 (ArchmageScore)';

  @override
  String get oakTrainBossScore => '击杀巨人Boss得分 (BossScore)';

  @override
  String get oakTrainHealNum => '生命药水恢复量 (HealNum)';

  @override
  String get oakTrainArrowPowerNum => '蓝色靶子补充强攻箭矢的数量 (ArrowPowerNum)';

  @override
  String get oakTrainArrowMultipleNum => '黄色靶子补充散射箭矢的数量 (ArrowMultipleNum)';

  @override
  String get oakTrainInitArrowsNum => '初始箭矢数量';

  @override
  String get oakTrainInitArrowNormal => '普通箭矢';

  @override
  String get oakTrainInitArrowPower => '强攻箭矢';

  @override
  String get oakTrainInitArrowSplit => '散射箭矢';

  @override
  String get moduleTitle_OakTrainIntroProperties => '百步穿僵教程';

  @override
  String get moduleDesc_OakTrainIntroProperties => '在关卡开始前展示百步穿僵小游戏的基础玩法';

  @override
  String get moduleTitle_GoldRoadProperties => '黄金之路';

  @override
  String get moduleDesc_GoldRoadProperties => '将第一行和第五行变为无草皮之地';

  @override
  String get goldRoadNonLostCityLawnWarningTitle => '地图外观提示';

  @override
  String get goldRoadNonLostCityLawnWarning =>
      '「黄金之路」是失落之城的小游戏模块，因此其无草皮之地上带有失落之城地图专属的太阳图案，在其他外观的地图中使用可能会影响关卡的整体观感。';

  @override
  String get goldRoadDeepseaLawnWarningTitle => '地图兼容性提示';

  @override
  String get goldRoadDeepseaLawnWarning =>
      '「黄金之路」仅会将第一行和第五行变为无草皮之地，在海底世界外观的六行地图也是如此，使用时需要注意。';

  @override
  String get moduleHelpOakTrainZombiesBody =>
      '适配此模块的僵尸均为独立的专属僵尸变体，有着与常规塔防模式不同的技能表现，并在波次生成器下通过「从地底出怪」的方式出现。这些僵尸无法在波次管理器的普通出怪、海底出怪等常规出怪事件中使用技能，建议使用地底出怪事件或自定义僵尸实现类似效果。\n同时，获取箭矢的靶子在代码层面也是僵尸，其技能与小游戏模块、「从地底出怪」相绑定，若脱离这些条件单独生成，可能会丢失贴图和效果。';

  @override
  String get oakTrainHealthTitle => '橡木弓手生命值';

  @override
  String get oakTrainScoresTitle => '分数判定';

  @override
  String get oakTrainArrowsTitle => '箭矢获取';

  @override
  String get oakTrainHelpArrowsTitle => '箭矢介绍';

  @override
  String get oakTrainHelpScoresTitle => '计分逻辑';

  @override
  String get oakTrainHelpZombiesTitle => '特殊僵尸';

  @override
  String waveGeneratorColumnOption(int number, String index) {
    return '第$number列 ($index)';
  }

  @override
  String waveGeneratorRowOption(int number, String index) {
    return '第$number行 ($index)';
  }

  @override
  String waveGeneratorDelaySummary(String seconds) {
    return '本波延迟$seconds秒出怪';
  }

  @override
  String waveGeneratorDelayInactiveSummary(String seconds) {
    return '出怪延迟$seconds秒（未启用从地底出怪，不生效）';
  }

  @override
  String waveGeneratorPositionSummary(String column, String row) {
    return '出现位置：$column，$row';
  }

  @override
  String get waveGeneratorPositionUnset => '未设置';

  @override
  String get oakTrainTutorialIntroWarningTitle => '模块兼容性提示';

  @override
  String get oakTrainTutorialIntroWarning =>
      '「百步穿僵教程」与转场模块存在冲突，同时使用会导致关卡在教程结束前出怪。';

  @override
  String statueMazeMissingRotationsWarning(String rounds) {
    return '「僵尸迷阵」第 $rounds 轮未添加旋转步骤，会导致关卡闪退。请为每轮至少添加一个旋转步骤。';
  }

  @override
  String get moduleHelpStatueMazeCompatibilityTitle => '兼容性提示';

  @override
  String get moduleHelpStatueMazeCompatibilityBody =>
      '僵尸迷阵可以与很多模块共存，通常情况下，关卡需要等僵尸迷阵的胜利条件也满足后才会结算；但「关卡倒计时」等特定模块可能会优先触发结算，使关卡提前结束，搭配使用时请注意。';

  @override
  String get autosaveZombossAction => '离开僵王机甲自定义动作时自动保存更改';

  @override
  String get autosavePortal => '离开自定义裂缝时自动保存更改';

  @override
  String get autosaveResilienceShield => '离开自定义韧性条时自动保存更改';

  @override
  String get autosavePreviewImage => '离开预览图生成器时自动保存图片';

  @override
  String get autosaveExit => '退出';

  @override
  String get automaticallySaved => '已自动保存';

  @override
  String automaticallySavedTo(String path) {
    return '已自动保存到：$path';
  }
}
