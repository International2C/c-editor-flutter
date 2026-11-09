import 'package:c_editor/data/pvz_models/PvzModel.dart';

class LevelDefinitionData extends PvzModel {
  LevelDefinitionData({
    this.name = '',
    this.levelNumber = 1,
    this.description = '',
    this.stageModule = '',
    this.loot = 'RTID(DefaultLoot@LevelModules)',
    this.startingSun = 200,
    this.victoryModule = 'RTID(VictoryOutro@LevelModules)',
    this.musicType = 'MainPath',
    this.musicSuffix = '',
    this.ambientAudioSuffix = '',
    this.firstIntroNarrative,
    this.firstOutroNarrative,
    this.disablePeavine,
    this.isArtifactDisabled,
    this.boardType,
    this.modules = const [],
    Map<String, dynamic>? extraFields,
  }) : extraFields = Map<String, dynamic>.from(extraFields ?? const {});

  String name;
  int? levelNumber;
  String description;
  String stageModule;
  String loot;
  int? startingSun;
  String victoryModule;
  String musicType;
  String musicSuffix;
  String ambientAudioSuffix;

  /// Dialogue identifiers are strings in current levels, while some legacy
  /// levels use numeric identifiers. Keep the JSON value unchanged.
  Object? firstIntroNarrative;
  Object? firstOutroNarrative;
  bool? disablePeavine;
  bool? isArtifactDisabled;

  /// Deep-sea lawns require `"submarine"` so row 6 stays plantable.
  String? boardType;
  List<String> modules;

  /// Fields that this editor version does not expose must survive edits.
  final Map<String, dynamic> extraFields;

  static Object? _parseNarrativeValue(dynamic value) =>
      value is String || value is int ? value : null;

  static bool _isValidNarrativeValue(Object? value) =>
      value is String || value is int;

  factory LevelDefinitionData.fromJson(Map<String, dynamic> json) {
    final mods = json['Modules'] as List<dynamic>? ?? [];
    final rawMusicType = json['MusicType'] as String?;
    final rawBoardType = json['BoardType'] as String?;
    final extras = Map<String, dynamic>.from(json)
      ..remove('Name')
      ..remove('LevelNumber')
      ..remove('Description')
      ..remove('StageModule')
      ..remove('Loot')
      ..remove('StartingSun')
      ..remove('VictoryModule')
      ..remove('MusicType')
      ..remove('MusicSuffix')
      ..remove('AmbientAudioSuffix')
      ..remove('FirstIntroNarrative')
      ..remove('FirstOutroNarrative')
      ..remove('DisablePeavine')
      ..remove('IsArtifactDisabled')
      ..remove('BoardType')
      ..remove('Modules');
    return LevelDefinitionData(
      name: json['Name'] as String? ?? '',
      levelNumber: json['LevelNumber'] as int?,
      description: json['Description'] as String? ?? '',
      stageModule: json['StageModule'] as String? ?? '',
      loot: json['Loot'] as String? ?? 'RTID(DefaultLoot@LevelModules)',
      startingSun: json['StartingSun'] as int?,
      victoryModule:
          json['VictoryModule'] as String? ?? 'RTID(VictoryOutro@LevelModules)',
      musicType: (rawMusicType == null || rawMusicType.isEmpty)
          ? 'MainPath'
          : rawMusicType,
      musicSuffix: json['MusicSuffix'] as String? ?? '',
      ambientAudioSuffix: json['AmbientAudioSuffix'] as String? ?? '',
      firstIntroNarrative: _parseNarrativeValue(json['FirstIntroNarrative']),
      firstOutroNarrative: _parseNarrativeValue(json['FirstOutroNarrative']),
      disablePeavine: json['DisablePeavine'] as bool?,
      isArtifactDisabled: json['IsArtifactDisabled'] as bool?,
      boardType: (rawBoardType == null || rawBoardType.isEmpty)
          ? null
          : rawBoardType,
      modules: mods.cast<String>(),
      extraFields: extras,
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    ...extraFields,
    'Name': name,
    'LevelNumber': levelNumber,
    'Description': description,
    'StageModule': stageModule,
    'Loot': loot,
    'StartingSun': startingSun,
    'VictoryModule': victoryModule,
    'MusicType': musicType,
    if (musicSuffix.isNotEmpty) 'MusicSuffix': musicSuffix,
    if (ambientAudioSuffix.isNotEmpty) 'AmbientAudioSuffix': ambientAudioSuffix,
    if (_isValidNarrativeValue(firstIntroNarrative))
      'FirstIntroNarrative': firstIntroNarrative,
    if (_isValidNarrativeValue(firstOutroNarrative))
      'FirstOutroNarrative': firstOutroNarrative,
    if (disablePeavine != null) 'DisablePeavine': disablePeavine,
    if (isArtifactDisabled != null) 'IsArtifactDisabled': isArtifactDisabled,
    if (boardType != null && boardType!.isNotEmpty) 'BoardType': boardType,
    'Modules': modules,
  };
}
