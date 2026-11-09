import 'package:c_editor/data/music_suffix_catalog.dart';

/// A named `MusicType` choice for one PVZ2 music module (`MusicSuffix`).
class MusicTypeChoice {
  const MusicTypeChoice({required this.value, required this.labelKey});

  final String value;
  final String labelKey;
}

/// Music choices and optional guide note for a `MusicSuffix` module.
class MusicTypeModule {
  const MusicTypeModule({
    required this.suffix,
    required this.choices,
    this.noteKeys = const [],
  });

  /// Canonical suffix written by the game data.
  final String suffix;

  final List<MusicTypeChoice> choices;
  final List<String> noteKeys;

  String get suffixNameKey => 'musicSuffix_$suffix';
}

/// Named `MusicType` tracks from 创辅图鉴 1.0.9's 《音乐模块》 section and
/// user-supplied supplemental modules.
///
/// The guide writes the main path as an empty string. C-Editor normalizes that
/// legacy representation to `MainPath`, so the catalog does the same. Matching
/// is case-insensitive so levels saved with older casing still resolve to the
/// guide's canonical suffix (`modern`, `Mausoleum`, or `Ghostdom`).
abstract final class MusicTypeCatalog {
  static const String mainPath = 'MainPath';
  static const String miniGameA = 'MiniGame_A';
  static const String miniGameB = 'MiniGame_B';
  static const String miniGameC = 'MiniGame_C';
  static const String miniGameD = 'MiniGame_D';
  static const String miniGameE = 'MiniGame_E';

  static const List<MusicTypeChoice> fallbackChoices = [
    MusicTypeChoice(value: mainPath, labelKey: mainPath),
    MusicTypeChoice(value: miniGameA, labelKey: miniGameA),
    MusicTypeChoice(value: miniGameB, labelKey: miniGameB),
  ];

  /// Unconfigured modules offer the three common tracks, named after their
  /// module until individual track labels are available. Empty suffixes keep
  /// the raw track labels rather than exposing an empty localization key.
  static List<MusicTypeChoice> fallbackChoicesForSuffix(String suffix) {
    final labelKey = MusicSuffixCatalog.resourceKey(suffix);
    if (labelKey.isEmpty) return fallbackChoices;
    return [
      for (final choice in fallbackChoices)
        MusicTypeChoice(value: choice.value, labelKey: labelKey),
    ];
  }

  static const _main = MusicTypeChoice(
    value: mainPath,
    labelKey: 'musicTypeLabel_main',
  );

  static const List<MusicTypeModule> modules = [
    MusicTypeModule(
      suffix: 'Tutorial',
      choices: [
        _main,
        MusicTypeChoice(value: miniGameA, labelKey: 'musicTypeLabel_main'),
        MusicTypeChoice(value: miniGameB, labelKey: 'musicTypeLabel_main'),
      ],
    ),
    MusicTypeModule(
      suffix: 'Egypt',
      choices: [
        _main,
        MusicTypeChoice(value: miniGameA, labelKey: 'musicTypeLabel_egyptUb'),
        MusicTypeChoice(value: miniGameB, labelKey: 'musicTypeLabel_egyptMg'),
      ],
    ),
    MusicTypeModule(
      suffix: 'Pirate',
      choices: [
        _main,
        MusicTypeChoice(value: miniGameA, labelKey: 'musicTypeLabel_pirateUb'),
        MusicTypeChoice(value: miniGameB, labelKey: 'musicTypeLabel_pirateMg'),
      ],
    ),
    MusicTypeModule(
      suffix: 'WildWest',
      choices: [
        _main,
        MusicTypeChoice(
          value: miniGameA,
          labelKey: 'musicTypeLabel_wildWestUb',
        ),
        MusicTypeChoice(
          value: miniGameB,
          labelKey: 'musicTypeLabel_wildWestMg',
        ),
      ],
    ),
    MusicTypeModule(
      suffix: 'Kongfu',
      choices: [
        _main,
        MusicTypeChoice(value: miniGameA, labelKey: 'musicTypeLabel_main'),
        MusicTypeChoice(value: miniGameB, labelKey: 'musicTypeLabel_main'),
      ],
    ),
    MusicTypeModule(
      suffix: 'Future',
      choices: [
        _main,
        MusicTypeChoice(value: miniGameA, labelKey: 'musicTypeLabel_futureUb'),
        MusicTypeChoice(value: miniGameB, labelKey: 'musicTypeLabel_futureMg'),
      ],
    ),
    MusicTypeModule(
      suffix: 'DarkAges',
      choices: [
        _main,
        MusicTypeChoice(
          value: miniGameA,
          labelKey: 'musicTypeLabel_darkAgesUb',
        ),
        MusicTypeChoice(
          value: miniGameB,
          labelKey: 'musicTypeLabel_darkAgesMg',
        ),
      ],
    ),
    MusicTypeModule(
      suffix: 'Beach',
      choices: [
        _main,
        MusicTypeChoice(value: miniGameA, labelKey: 'musicTypeLabel_beachUb'),
        MusicTypeChoice(value: miniGameB, labelKey: 'musicTypeLabel_beachMg'),
      ],
    ),
    MusicTypeModule(
      suffix: 'IceAge',
      choices: [
        _main,
        MusicTypeChoice(value: miniGameA, labelKey: 'musicTypeLabel_iceAgeUb'),
        MusicTypeChoice(value: miniGameB, labelKey: 'musicTypeLabel_iceAgeMg'),
      ],
    ),
    MusicTypeModule(
      suffix: 'SkyCity',
      choices: [
        _main,
        MusicTypeChoice(value: miniGameA, labelKey: 'musicTypeLabel_main'),
        MusicTypeChoice(value: miniGameB, labelKey: 'musicTypeLabel_main'),
      ],
    ),
    MusicTypeModule(
      suffix: 'LostCity',
      choices: [
        _main,
        MusicTypeChoice(
          value: miniGameA,
          labelKey: 'musicTypeLabel_lostCityUb',
        ),
        MusicTypeChoice(
          value: miniGameB,
          labelKey: 'musicTypeLabel_lostCityMg',
        ),
      ],
    ),
    MusicTypeModule(
      suffix: 'Eighties',
      // The guide's jam_* entries belong to wave NotificationEvents, not
      // MusicType. Use the module name until individual tracks are documented.
      choices: [
        MusicTypeChoice(value: mainPath, labelKey: 'musicSuffix_Eighties'),
        MusicTypeChoice(value: miniGameA, labelKey: 'musicSuffix_Eighties'),
        MusicTypeChoice(value: miniGameB, labelKey: 'musicSuffix_Eighties'),
      ],
      noteKeys: ['musicTypeNote_eighties'],
    ),
    MusicTypeModule(
      suffix: 'Dino',
      choices: [
        _main,
        MusicTypeChoice(value: miniGameA, labelKey: 'musicTypeLabel_dinoUb'),
        MusicTypeChoice(value: miniGameB, labelKey: 'musicTypeLabel_dinoMg'),
      ],
    ),
    MusicTypeModule(
      suffix: 'modern',
      choices: [
        _main,
        MusicTypeChoice(value: miniGameA, labelKey: 'musicTypeLabel_modernUb'),
        MusicTypeChoice(value: miniGameB, labelKey: 'musicTypeLabel_modernMg'),
      ],
    ),
    MusicTypeModule(
      suffix: 'Steam',
      choices: [
        _main,
        MusicTypeChoice(value: miniGameA, labelKey: 'musicTypeLabel_main'),
        MusicTypeChoice(value: miniGameB, labelKey: 'musicTypeLabel_main'),
      ],
    ),
    MusicTypeModule(
      suffix: 'Renai',
      choices: [
        _main,
        MusicTypeChoice(value: miniGameA, labelKey: 'musicTypeLabel_main'),
        MusicTypeChoice(value: miniGameB, labelKey: 'musicTypeLabel_main'),
      ],
    ),
    MusicTypeModule(
      suffix: 'Heian',
      choices: [
        _main,
        MusicTypeChoice(value: miniGameA, labelKey: 'musicTypeLabel_main'),
        MusicTypeChoice(value: miniGameB, labelKey: 'musicTypeLabel_main'),
      ],
    ),
    MusicTypeModule(
      suffix: 'Atlantis',
      choices: [
        _main,
        MusicTypeChoice(
          value: miniGameA,
          labelKey: 'musicTypeLabel_atlantisUb',
        ),
        MusicTypeChoice(
          value: miniGameB,
          labelKey: 'musicTypeLabel_atlantisMg',
        ),
      ],
    ),
    MusicTypeModule(
      suffix: 'Moon',
      choices: [
        _main,
        MusicTypeChoice(value: miniGameA, labelKey: 'musicTypeLabel_moonUb'),
        MusicTypeChoice(value: miniGameB, labelKey: 'musicTypeLabel_moonMg'),
        MusicTypeChoice(
          value: miniGameC,
          labelKey: 'musicTypeLabel_moonDay24FinalWave',
        ),
      ],
    ),
    MusicTypeModule(
      suffix: 'ZCorp',
      choices: [
        MusicTypeChoice(
          value: mainPath,
          labelKey: 'musicTypeLabel_zCorpChinese',
        ),
        MusicTypeChoice(
          value: miniGameA,
          labelKey: 'musicTypeLabel_zCorpChinese',
        ),
        MusicTypeChoice(
          value: miniGameB,
          labelKey: 'musicTypeLabel_zCorpChinese',
        ),
      ],
      noteKeys: ['musicTypeNote_regularBossNoIntro'],
    ),
    MusicTypeModule(
      suffix: 'Twister',
      choices: [
        MusicTypeChoice(value: mainPath, labelKey: 'musicTypeLabel_grasswalk'),
        MusicTypeChoice(
          value: miniGameA,
          labelKey: 'musicTypeLabel_moongrains',
        ),
        MusicTypeChoice(
          value: miniGameB,
          labelKey: 'musicTypeLabel_grazeTheRoof',
        ),
      ],
    ),
    MusicTypeModule(
      suffix: 'Uncharted',
      choices: [
        MusicTypeChoice(
          value: mainPath,
          labelKey: 'musicTypeLabel_fairyForest',
        ),
        MusicTypeChoice(
          value: miniGameA,
          labelKey: 'musicTypeLabel_undergroundPalaceRuins',
        ),
        MusicTypeChoice(
          value: miniGameB,
          labelKey: 'musicTypeLabel_universe41',
        ),
        MusicTypeChoice(
          value: miniGameC,
          labelKey: 'musicTypeLabel_needForSun',
        ),
      ],
      noteKeys: ['musicTypeNote_uncharted'],
    ),
    MusicTypeModule(
      suffix: 'BGMa',
      choices: [
        MusicTypeChoice(
          value: mainPath,
          labelKey: 'musicTypeLabel_brainiacManiac',
        ),
        MusicTypeChoice(
          value: miniGameA,
          labelKey: 'musicTypeLabel_auspiciousSnowWelcomesSpring',
        ),
        MusicTypeChoice(
          value: miniGameB,
          labelKey: 'musicTypeLabel_frostbiteCavesResurgence',
        ),
      ],
      noteKeys: ['musicTypeNote_regularBossNoIntro'],
    ),
    MusicTypeModule(
      suffix: 'BGMb',
      choices: [
        MusicTypeChoice(
          value: mainPath,
          labelKey: 'musicTypeLabel_zombwaySurfers',
        ),
        MusicTypeChoice(
          value: miniGameA,
          labelKey: 'musicTypeLabel_universe42',
        ),
        MusicTypeChoice(
          value: miniGameB,
          labelKey: 'musicTypeLabel_zCorpChinese',
        ),
      ],
      noteKeys: ['musicTypeNote_regularBossNoIntro'],
    ),
    MusicTypeModule(
      suffix: 'BGMc',
      choices: [
        MusicTypeChoice(value: mainPath, labelKey: 'musicTypeLabel_loonboon'),
        MusicTypeChoice(
          value: miniGameA,
          labelKey: 'musicTypeLabel_zombwaySurfers',
        ),
        MusicTypeChoice(
          value: miniGameB,
          labelKey: 'musicTypeLabel_needForSun',
        ),
      ],
      noteKeys: ['musicTypeNote_regularBossNoIntro'],
    ),
    MusicTypeModule(
      suffix: 'BGMd',
      choices: [
        MusicTypeChoice(
          value: mainPath,
          labelKey: 'musicTypeLabel_columnLikeYouSeeEm',
        ),
        MusicTypeChoice(
          value: miniGameA,
          labelKey: 'musicTypeLabel_stalemateZombossLab',
        ),
        MusicTypeChoice(
          value: miniGameB,
          labelKey: 'musicTypeLabel_stalemateJourneyWest',
        ),
      ],
      noteKeys: ['musicTypeNote_regularBossNoIntro'],
    ),
    MusicTypeModule(
      suffix: 'TeamBoss',
      choices: [
        MusicTypeChoice(
          value: mainPath,
          labelKey: 'musicTypeLabel_pharaohKunquCurse',
        ),
        MusicTypeChoice(
          value: miniGameA,
          labelKey: 'musicTypeLabel_pharaohPirateUbCurse',
        ),
        MusicTypeChoice(
          value: miniGameB,
          labelKey: 'musicTypeLabel_pharaohPirateUbCurse',
        ),
      ],
      noteKeys: ['musicTypeNote_briefPlayback', 'musicTypeNote_teamBoss'],
    ),
    MusicTypeModule(
      suffix: 'TeamBossRoman',
      choices: [
        MusicTypeChoice(
          value: mainPath,
          labelKey: 'musicTypeLabel_pharaohKunquCurse',
        ),
        MusicTypeChoice(
          value: miniGameA,
          labelKey: 'musicTypeLabel_pharaohPirateUbCurse',
        ),
        MusicTypeChoice(
          value: miniGameB,
          labelKey: 'musicTypeLabel_pharaohPirateUbCurse',
        ),
      ],
      noteKeys: ['musicTypeNote_briefPlayback', 'musicTypeNote_teamBossRoman'],
    ),
    MusicTypeModule(
      suffix: 'Mausoleum',
      choices: [
        MusicTypeChoice(
          value: mainPath,
          labelKey: 'musicTypeLabel_undergroundPalaceRuins',
        ),
        MusicTypeChoice(
          value: miniGameA,
          labelKey: 'musicTypeLabel_undergroundPalaceRuins',
        ),
        MusicTypeChoice(
          value: miniGameB,
          labelKey: 'musicTypeLabel_undergroundPalaceRuins',
        ),
      ],
      noteKeys: ['musicTypeNote_undergroundRuler'],
    ),
    MusicTypeModule(
      suffix: 'Ghostdom',
      choices: [
        MusicTypeChoice(
          value: mainPath,
          labelKey: 'musicTypeLabel_undergroundPalaceSpiritSuppression',
        ),
        MusicTypeChoice(
          value: miniGameA,
          labelKey: 'musicTypeLabel_undergroundPalaceSpiritSuppression',
        ),
        MusicTypeChoice(
          value: miniGameB,
          labelKey: 'musicTypeLabel_undergroundPalaceSpiritSuppression',
        ),
      ],
      noteKeys: ['musicTypeNote_undergroundRuler'],
    ),
    MusicTypeModule(
      suffix: 'Sportz',
      choices: [
        MusicTypeChoice(value: mainPath, labelKey: 'musicTypeLabel_daveCup'),
        MusicTypeChoice(value: miniGameA, labelKey: 'musicTypeLabel_blank'),
        MusicTypeChoice(value: miniGameB, labelKey: 'musicTypeLabel_blank'),
      ],
      noteKeys: ['musicTypeNote_regularBossNoIntro'],
    ),
    MusicTypeModule(
      suffix: 'Roman',
      choices: [
        MusicTypeChoice(value: mainPath, labelKey: 'musicTypeLabel_romanGlory'),
        MusicTypeChoice(
          value: miniGameA,
          labelKey: 'musicTypeLabel_romanGlory',
        ),
        MusicTypeChoice(
          value: miniGameB,
          labelKey: 'musicTypeLabel_romanGlory',
        ),
      ],
      noteKeys: ['musicTypeNote_romanBossWithIntro'],
    ),
    MusicTypeModule(
      suffix: 'Halloween',
      choices: [
        MusicTypeChoice(value: mainPath, labelKey: 'musicSuffix_Halloween'),
        MusicTypeChoice(value: miniGameA, labelKey: 'musicSuffix_Halloween'),
        MusicTypeChoice(value: miniGameB, labelKey: 'musicSuffix_Halloween'),
      ],
      noteKeys: ['musicTypeNote_regularBossNoIntro'],
    ),
    MusicTypeModule(
      suffix: 'Gnomiverse',
      choices: [
        MusicTypeChoice(
          value: mainPath,
          labelKey: 'musicTypeLabel_expeditionGate',
        ),
        MusicTypeChoice(
          value: miniGameA,
          labelKey: 'musicTypeLabel_expeditionGate',
        ),
        MusicTypeChoice(
          value: miniGameB,
          labelKey: 'musicTypeLabel_expeditionGate',
        ),
      ],
      noteKeys: ['musicTypeNote_regularBossNoIntro'],
    ),
    MusicTypeModule(
      suffix: 'SilkRoad',
      choices: [
        MusicTypeChoice(value: mainPath, labelKey: 'musicTypeLabel_dunhuang'),
        MusicTypeChoice(value: miniGameA, labelKey: 'musicTypeLabel_dunhuang'),
        MusicTypeChoice(value: miniGameB, labelKey: 'musicTypeLabel_dunhuang'),
      ],
      noteKeys: ['musicTypeNote_regularBossNoIntro'],
    ),
    MusicTypeModule(
      suffix: 'rift',
      choices: [
        MusicTypeChoice(
          value: mainPath,
          labelKey: 'musicTypeLabel_zCorpInternational',
        ),
        MusicTypeChoice(
          value: miniGameA,
          labelKey: 'musicTypeLabel_zCorpInternational',
        ),
        MusicTypeChoice(
          value: miniGameB,
          labelKey: 'musicTypeLabel_zCorpInternational',
        ),
      ],
      noteKeys: ['musicTypeNote_regularBossNoIntro'],
    ),
  ];

  static final Map<String, MusicTypeModule> _byNormalizedSuffix = {
    for (final module in modules) module.suffix.toLowerCase(): module,
  };

  static MusicTypeModule? forSuffix(String suffix) =>
      _byNormalizedSuffix[suffix.trim().toLowerCase()];
}
