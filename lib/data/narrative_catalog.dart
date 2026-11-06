import 'dart:convert';

import 'package:flutter/widgets.dart';
import 'package:c_editor/data/asset_loader.dart';
import 'package:c_editor/utils/narrative_text_format.dart';

/// The four concrete narrative categories shown by the picker. [all] is a
/// virtual aggregate and is never written to the generated catalogue.
enum NarrativeCategory {
  all,
  mainWorlds,
  memoryLane,
  otherModes,
  systemTutorials;

  static NarrativeCategory fromJson(Object? value) {
    return NarrativeCategory.values.firstWhere(
      (category) => category.name == value,
      orElse: () => NarrativeCategory.systemTutorials,
    );
  }
}

/// Stable second-level groups used by the narrative picker.
///
/// These ids are deliberately independent of localized titles so catalogue
/// entries stay grouped the same way in every language.
enum NarrativeSectionId {
  tutorialYard,
  ancientEgypt,
  pirateSeas,
  wildWest,
  kongfuWorld,
  farFuture,
  darkAges,
  bigWaveBeach,
  frostbiteCaves,
  skyCity,
  lostCity,
  neonMixtapeTour,
  jurassicMarsh,
  modernDay,
  steamAges,
  renaissanceAges,
  heianAges,
  underwaterWorld,
  moonBase,
  memoryImport,
  memorySeason27,
  memorySeason28,
  memorySeason29,
  memorySeason30,
  memorySeason31,
  memorySeason32,
  secretRealm,
  twoPlayerDuel,
  pennysPursuit,
  endlessModes,
  pvpMode,
  cardClash,
  plantEncounter,
  travelLog,
  zenGarden,
  pinataParty,
  systemTutorials,
}

class NarrativeSection {
  const NarrativeSection({
    required this.id,
    required this.category,
    required this.iconAsset,
    required this.labelKey,
  });

  final NarrativeSectionId id;
  final NarrativeCategory category;
  final String iconAsset;
  final String labelKey;
}

const _narrativeSections = <NarrativeSection>[
  NarrativeSection(
    id: NarrativeSectionId.tutorialYard,
    category: NarrativeCategory.mainWorlds,
    iconAsset: 'assets/images/round_icons/Stage_Modern.webp',
    labelKey: 'sectionTutorialYard',
  ),
  NarrativeSection(
    id: NarrativeSectionId.ancientEgypt,
    category: NarrativeCategory.mainWorlds,
    iconAsset: 'assets/images/round_icons/Stage_Egypt.webp',
    labelKey: 'sectionAncientEgypt',
  ),
  NarrativeSection(
    id: NarrativeSectionId.pirateSeas,
    category: NarrativeCategory.mainWorlds,
    iconAsset: 'assets/images/round_icons/Stage_Pirate.webp',
    labelKey: 'sectionPirateSeas',
  ),
  NarrativeSection(
    id: NarrativeSectionId.wildWest,
    category: NarrativeCategory.mainWorlds,
    iconAsset: 'assets/images/round_icons/Stage_West.webp',
    labelKey: 'sectionWildWest',
  ),
  NarrativeSection(
    id: NarrativeSectionId.kongfuWorld,
    category: NarrativeCategory.mainWorlds,
    iconAsset: 'assets/images/round_icons/Stage_Kongfu.webp',
    labelKey: 'sectionKongfuWorld',
  ),
  NarrativeSection(
    id: NarrativeSectionId.farFuture,
    category: NarrativeCategory.mainWorlds,
    iconAsset: 'assets/images/round_icons/Stage_Future.webp',
    labelKey: 'sectionFarFuture',
  ),
  NarrativeSection(
    id: NarrativeSectionId.darkAges,
    category: NarrativeCategory.mainWorlds,
    iconAsset: 'assets/images/round_icons/Stage_Dark.webp',
    labelKey: 'sectionDarkAges',
  ),
  NarrativeSection(
    id: NarrativeSectionId.bigWaveBeach,
    category: NarrativeCategory.mainWorlds,
    iconAsset: 'assets/images/round_icons/Stage_Beach.webp',
    labelKey: 'sectionBigWaveBeach',
  ),
  NarrativeSection(
    id: NarrativeSectionId.frostbiteCaves,
    category: NarrativeCategory.mainWorlds,
    iconAsset: 'assets/images/round_icons/Stage_Iceage.webp',
    labelKey: 'sectionFrostbiteCaves',
  ),
  NarrativeSection(
    id: NarrativeSectionId.skyCity,
    category: NarrativeCategory.mainWorlds,
    iconAsset: 'assets/images/round_icons/Stage_Skycity.webp',
    labelKey: 'sectionSkyCity',
  ),
  NarrativeSection(
    id: NarrativeSectionId.lostCity,
    category: NarrativeCategory.mainWorlds,
    iconAsset: 'assets/images/round_icons/Stage_LostCity.webp',
    labelKey: 'sectionLostCity',
  ),
  NarrativeSection(
    id: NarrativeSectionId.neonMixtapeTour,
    category: NarrativeCategory.mainWorlds,
    iconAsset: 'assets/images/round_icons/Stage_Eighties.webp',
    labelKey: 'sectionNeonMixtapeTour',
  ),
  NarrativeSection(
    id: NarrativeSectionId.jurassicMarsh,
    category: NarrativeCategory.mainWorlds,
    iconAsset: 'assets/images/round_icons/Stage_Dino.webp',
    labelKey: 'sectionJurassicMarsh',
  ),
  NarrativeSection(
    id: NarrativeSectionId.modernDay,
    category: NarrativeCategory.mainWorlds,
    iconAsset: 'assets/images/round_icons/Stage_Modern.webp',
    labelKey: 'sectionModernDay',
  ),
  NarrativeSection(
    id: NarrativeSectionId.steamAges,
    category: NarrativeCategory.mainWorlds,
    iconAsset: 'assets/images/round_icons/Stage_Steam.webp',
    labelKey: 'sectionSteamAges',
  ),
  NarrativeSection(
    id: NarrativeSectionId.renaissanceAges,
    category: NarrativeCategory.mainWorlds,
    iconAsset: 'assets/images/round_icons/Stage_Renai.webp',
    labelKey: 'sectionRenaissanceAges',
  ),
  NarrativeSection(
    id: NarrativeSectionId.heianAges,
    category: NarrativeCategory.mainWorlds,
    iconAsset: 'assets/images/round_icons/Stage_Heian.webp',
    labelKey: 'sectionHeianAges',
  ),
  NarrativeSection(
    id: NarrativeSectionId.underwaterWorld,
    category: NarrativeCategory.mainWorlds,
    iconAsset: 'assets/images/round_icons/Stage_Atlantis.webp',
    labelKey: 'sectionUnderwaterWorld',
  ),
  NarrativeSection(
    id: NarrativeSectionId.moonBase,
    category: NarrativeCategory.mainWorlds,
    iconAsset: 'assets/images/round_icons/Stage_Moon.webp',
    labelKey: 'sectionMoonBase',
  ),
  NarrativeSection(
    id: NarrativeSectionId.memoryImport,
    category: NarrativeCategory.memoryLane,
    iconAsset: 'assets/images/round_icons/Mode_MemoryLane.webp',
    labelKey: 'sectionMemoryImport',
  ),
  NarrativeSection(
    id: NarrativeSectionId.memorySeason27,
    category: NarrativeCategory.memoryLane,
    iconAsset: 'assets/images/round_icons/Mode_MemoryLaneS27.webp',
    labelKey: 'sectionMemorySeason27',
  ),
  NarrativeSection(
    id: NarrativeSectionId.memorySeason28,
    category: NarrativeCategory.memoryLane,
    iconAsset: 'assets/images/round_icons/Mode_MemoryLaneS28.webp',
    labelKey: 'sectionMemorySeason28',
  ),
  NarrativeSection(
    id: NarrativeSectionId.memorySeason29,
    category: NarrativeCategory.memoryLane,
    iconAsset: 'assets/images/round_icons/Mode_MemoryLaneS29.webp',
    labelKey: 'sectionMemorySeason29',
  ),
  NarrativeSection(
    id: NarrativeSectionId.memorySeason30,
    category: NarrativeCategory.memoryLane,
    iconAsset: 'assets/images/round_icons/Mode_MemoryLaneS30.webp',
    labelKey: 'sectionMemorySeason30',
  ),
  NarrativeSection(
    id: NarrativeSectionId.memorySeason31,
    category: NarrativeCategory.memoryLane,
    iconAsset: 'assets/images/round_icons/Mode_MemoryLaneS31.webp',
    labelKey: 'sectionMemorySeason31',
  ),
  NarrativeSection(
    id: NarrativeSectionId.memorySeason32,
    category: NarrativeCategory.memoryLane,
    iconAsset: 'assets/images/round_icons/Mode_MemoryLaneS32.webp',
    labelKey: 'sectionMemorySeason32',
  ),
  NarrativeSection(
    id: NarrativeSectionId.secretRealm,
    category: NarrativeCategory.otherModes,
    iconAsset: 'assets/images/round_icons/Mode_SecretRealm.webp',
    labelKey: 'sectionSecretRealm',
  ),
  NarrativeSection(
    id: NarrativeSectionId.twoPlayerDuel,
    category: NarrativeCategory.otherModes,
    iconAsset: 'assets/images/round_icons/Mode_NewPvP.webp',
    labelKey: 'sectionTwoPlayerDuel',
  ),
  NarrativeSection(
    id: NarrativeSectionId.pennysPursuit,
    category: NarrativeCategory.otherModes,
    iconAsset: 'assets/images/round_icons/Mode_PennysPursuit.webp',
    labelKey: 'sectionPennysPursuit',
  ),
  NarrativeSection(
    id: NarrativeSectionId.endlessModes,
    category: NarrativeCategory.otherModes,
    iconAsset: 'assets/images/round_icons/Mode_Endless.webp',
    labelKey: 'sectionEndlessModes',
  ),
  NarrativeSection(
    id: NarrativeSectionId.pvpMode,
    category: NarrativeCategory.otherModes,
    iconAsset: 'assets/images/round_icons/Mode_PvP.webp',
    labelKey: 'sectionPvpMode',
  ),
  NarrativeSection(
    id: NarrativeSectionId.cardClash,
    category: NarrativeCategory.otherModes,
    iconAsset: 'assets/images/round_icons/Mode_CardClash.webp',
    labelKey: 'sectionCardClash',
  ),
  NarrativeSection(
    id: NarrativeSectionId.plantEncounter,
    category: NarrativeCategory.otherModes,
    iconAsset: 'assets/images/round_icons/Mode_PlantEncounter.webp',
    labelKey: 'sectionPlantEncounter',
  ),
  NarrativeSection(
    id: NarrativeSectionId.travelLog,
    category: NarrativeCategory.otherModes,
    iconAsset: 'assets/images/round_icons/Mode_TravelLog.webp',
    labelKey: 'sectionTravelLog',
  ),
  NarrativeSection(
    id: NarrativeSectionId.zenGarden,
    category: NarrativeCategory.otherModes,
    iconAsset: 'assets/images/round_icons/Mode_ZenGarden.webp',
    labelKey: 'sectionZenGarden',
  ),
  NarrativeSection(
    id: NarrativeSectionId.pinataParty,
    category: NarrativeCategory.otherModes,
    iconAsset: 'assets/images/round_icons/Mode_PinataParty.webp',
    labelKey: 'sectionPinataParty',
  ),
  NarrativeSection(
    id: NarrativeSectionId.systemTutorials,
    category: NarrativeCategory.systemTutorials,
    iconAsset: 'assets/images/round_icons/Mode_Tutorial.webp',
    labelKey: 'sectionSystemTutorials',
  ),
];

final _narrativeSectionById = {
  for (final section in _narrativeSections) section.id: section,
};

enum NarrativeLineKind {
  speech,
  stage,
  system;

  static NarrativeLineKind fromJson(Object? value) {
    return NarrativeLineKind.values.firstWhere(
      (kind) => kind.name == value,
      orElse: () => NarrativeLineKind.system,
    );
  }
}

class NarrativeLine {
  const NarrativeLine({
    required this.key,
    required this.kind,
    required this.text,
    this.speaker,
    this.emotion,
    this.npc,
  });

  factory NarrativeLine.fromJson(Map<String, dynamic> json) {
    return NarrativeLine(
      key: json['key']?.toString() ?? '',
      kind: NarrativeLineKind.fromJson(json['kind']),
      text: json['text']?.toString() ?? '',
      speaker: _nonEmptyString(json['speaker']),
      emotion: _nonEmptyString(json['emotion']),
      npc: _nonEmptyString(json['npc']),
    );
  }

  final String key;
  final NarrativeLineKind kind;
  final String text;
  final String? speaker;
  final String? emotion;
  final String? npc;

  String get speakerWithEmotion {
    final name = speaker ?? '';
    final mood = emotion;
    return mood == null || mood.isEmpty ? name : '$name（$mood）';
  }
}

class NarrativeEntry {
  const NarrativeEntry({
    required this.value,
    required this.id,
    required this.groupId,
    required this.number,
    required this.category,
    required this.iconAsset,
    required this.title,
    required this.characters,
    required this.lines,
    required this.selectable,
  });

  factory NarrativeEntry.fromJson(Map<String, dynamic> json) {
    final rawValue = json['value'];
    if (rawValue is! String && rawValue is! int) {
      throw const FormatException(
        'Narrative invocation values must be strings or integers.',
      );
    }
    return NarrativeEntry(
      value: rawValue,
      id: json['id']?.toString() ?? rawValue.toString(),
      groupId: json['groupId']?.toString() ?? '',
      number: json['number']?.toString() ?? '',
      category: NarrativeCategory.fromJson(json['tag']),
      iconAsset: json['icon']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      characters: (json['characters'] as List<dynamic>? ?? const [])
          .map((value) => value.toString())
          .where((value) => value.isNotEmpty)
          .toList(growable: false),
      lines: (json['lines'] as List<dynamic>? ?? const [])
          .whereType<Map>()
          .map(
            (value) => NarrativeLine.fromJson(Map<String, dynamic>.from(value)),
          )
          .toList(growable: false),
      selectable: json['selectable'] as bool? ?? true,
    );
  }

  /// The value written verbatim to FirstIntroNarrative/FirstOutroNarrative.
  /// Its String/int type is intentionally preserved.
  final Object value;
  final String id;
  final String groupId;
  final String number;
  final NarrativeCategory category;
  final String iconAsset;
  final String title;
  final List<String> characters;
  final List<NarrativeLine> lines;
  final bool selectable;

  String get valueKey => value.toString();

  Iterable<String> get dialogueText =>
      lines.map((line) => narrativePlainText(line.text));

  Iterable<String> get speakerNames => lines
      .map((line) => line.speaker)
      .whereType<String>()
      .where((name) => name.isNotEmpty);
}

class NarrativeStrings {
  NarrativeStrings(Map<String, dynamic> values)
    : _values = Map.unmodifiable(
        values.map((key, value) => MapEntry(key, value.toString())),
      );

  final Map<String, String> _values;

  Set<String> get keys => Set.unmodifiable(_values.keys);

  String get sectionTitle => this['sectionTitle'];
  String get helpBody => this['helpBody'];
  String get firstIntro => this['firstIntro'];
  String get firstOutro => this['firstOutro'];
  String get noDialogue => this['noDialogue'];
  String get selectTitle => this['selectTitle'];
  String get searchHint => this['searchHint'];
  String get noResults => this['noResults'];
  String get detailsTitle => this['detailsTitle'];
  String get rawId => this['rawId'];
  String get selectDialogue => this['selectDialogue'];
  String get clearDialogue => this['clearDialogue'];
  String get unavailableDialogue => this['unavailableDialogue'];
  String get loadError => this['loadError'];

  String operator [](String key) => _values[key] ?? key;

  String categoryLabel(NarrativeCategory category) => switch (category) {
    NarrativeCategory.all => this['tagAll'],
    NarrativeCategory.mainWorlds => this['tagMainWorlds'],
    NarrativeCategory.memoryLane => this['tagMemoryLane'],
    NarrativeCategory.otherModes => this['tagOtherModes'],
    NarrativeCategory.systemTutorials => this['tagSystemTutorials'],
  };

  String sectionLabel(NarrativeSection section) => this[section.labelKey];

  String dialogueCount(int count) {
    return this['dialogueCount'].replaceAll('{count}', '$count');
  }

  String searchGroupLabel(String key, int count) {
    return this[key].replaceAll('{count}', '$count');
  }
}

class NarrativeCatalog {
  NarrativeCatalog._({
    required this.localeCode,
    required this.strings,
    required this.dialogues,
  }) : _byValue = {
         for (final dialogue in dialogues) dialogue.valueKey: dialogue,
       } {
    final sourceIndexes = <String, int>{};
    final naturalGroupIndexes = <String, int>{};
    final sectionIds = <String, NarrativeSectionId>{};
    final entriesBySection = <NarrativeSectionId, List<NarrativeEntry>>{
      for (final section in _narrativeSections) section.id: [],
    };
    for (var index = 0; index < dialogues.length; index++) {
      final dialogue = dialogues[index];
      final sectionId = _resolveNarrativeSectionId(dialogue);
      sourceIndexes[dialogue.groupId] = index;
      naturalGroupIndexes.putIfAbsent(
        _naturalShape(dialogue.groupId),
        () => index,
      );
      sectionIds[dialogue.groupId] = sectionId;
      entriesBySection[sectionId]!.add(dialogue);
    }
    for (final entry in entriesBySection.entries) {
      entry.value.sort(
        (a, b) => _compareSectionEntries(
          entry.key,
          a,
          b,
          sourceIndexes,
          naturalGroupIndexes,
        ),
      );
    }
    _sectionIdByGroupId = Map.unmodifiable(sectionIds);
    _entriesBySection =
        Map<NarrativeSectionId, List<NarrativeEntry>>.unmodifiable({
          for (final entry in entriesBySection.entries)
            entry.key: List<NarrativeEntry>.unmodifiable(entry.value),
        });
    _allDisplayEntries = List<NarrativeEntry>.unmodifiable([
      for (final section in _narrativeSections)
        ..._entriesBySection[section.id]!,
    ]);
  }

  factory NarrativeCatalog.fromJson(Map<String, dynamic> json) {
    final dialogues = (json['dialogues'] as List<dynamic>? ?? const [])
        .whereType<Map>()
        .map(
          (value) => NarrativeEntry.fromJson(Map<String, dynamic>.from(value)),
        )
        .toList(growable: false);
    return NarrativeCatalog._(
      localeCode: json['locale']?.toString() ?? 'en',
      strings: NarrativeStrings(
        Map<String, dynamic>.from(json['strings'] as Map? ?? const {}),
      ),
      dialogues: List.unmodifiable(dialogues),
    );
  }

  static const String assetDirectory = 'assets/l10n';
  static final Map<String, NarrativeCatalog> _cache = {};
  static final Map<String, Future<NarrativeCatalog>> _pendingLoads = {};

  final String localeCode;
  final NarrativeStrings strings;
  final List<NarrativeEntry> dialogues;
  final Map<String, NarrativeEntry> _byValue;
  late final Map<String, NarrativeSectionId> _sectionIdByGroupId;
  late final Map<NarrativeSectionId, List<NarrativeEntry>> _entriesBySection;
  late final List<NarrativeEntry> _allDisplayEntries;

  static String localeCodeFor(Locale locale) => switch (locale.languageCode) {
    'zh' => 'zh',
    'ru' => 'ru',
    _ => 'en',
  };

  static Future<NarrativeCatalog> load(Locale locale) {
    final code = localeCodeFor(locale);
    final cached = _cache[code];
    if (cached != null) return Future.value(cached);
    return _pendingLoads.putIfAbsent(code, () => _load(code));
  }

  static Future<NarrativeCatalog> _load(String code) async {
    try {
      final source = await loadJsonString(
        '$assetDirectory/narrative_$code.json',
      );
      final catalog = NarrativeCatalog.fromJson(
        Map<String, dynamic>.from(jsonDecode(source) as Map),
      );
      _cache[code] = catalog;
      return catalog;
    } finally {
      _pendingLoads.remove(code);
    }
  }

  static void clearCacheForTesting() {
    _cache.clear();
    _pendingLoads.clear();
  }

  NarrativeEntry? findByValue(Object? value) {
    if (value == null) return null;
    return _byValue[value.toString()];
  }

  List<NarrativeEntry> forCategory(NarrativeCategory category) {
    if (category == NarrativeCategory.all) return _allDisplayEntries;
    return _allDisplayEntries
        .where((dialogue) => sectionForEntry(dialogue).category == category)
        .toList(growable: false);
  }

  List<NarrativeSection> sectionsForCategory(NarrativeCategory category) {
    if (category == NarrativeCategory.all) return _narrativeSections;
    return _narrativeSections
        .where((section) => section.category == category)
        .toList(growable: false);
  }

  NarrativeSection sectionForEntry(NarrativeEntry entry) {
    final id =
        _sectionIdByGroupId[entry.groupId] ??
        NarrativeSectionId.systemTutorials;
    return _narrativeSectionById[id]!;
  }

  List<NarrativeEntry> entriesForSection(NarrativeSectionId id) {
    return _entriesBySection[id] ?? const [];
  }

  NarrativeCategory displayCategory(NarrativeEntry entry) {
    return sectionForEntry(entry).category;
  }

  String displayIcon(NarrativeEntry entry) {
    return sectionForEntry(entry).iconAsset;
  }
}

NarrativeSectionId _resolveNarrativeSectionId(NarrativeEntry entry) {
  final id = entry.groupId;
  final number = entry.number;

  if (entry.category == NarrativeCategory.mainWorlds) {
    if (id == 'TUTORIAL_EGYPT6_INTRO' || id == 'TUTORIAL_EGYPT8_INTRO') {
      return NarrativeSectionId.ancientEgypt;
    }
    if (number.startsWith('1.1.')) return NarrativeSectionId.tutorialYard;
    if (number.startsWith('1.3.')) return NarrativeSectionId.ancientEgypt;
    if (number.startsWith('1.4.')) return NarrativeSectionId.pirateSeas;
    if (number.startsWith('1.5.')) {
      return id == 'COWBOY_OUTRO_ZOMBOSS_INTRO'
          ? NarrativeSectionId.farFuture
          : NarrativeSectionId.wildWest;
    }
    if (number.startsWith('2.1.')) return NarrativeSectionId.kongfuWorld;
    if (number.startsWith('1.6.')) return NarrativeSectionId.farFuture;
    if (number.startsWith('1.7.')) return NarrativeSectionId.darkAges;
    if (number.startsWith('1.8.')) return NarrativeSectionId.bigWaveBeach;
    if (number.startsWith('1.9.')) return NarrativeSectionId.frostbiteCaves;
    if (number.startsWith('2.2.')) return NarrativeSectionId.skyCity;
    if (number.startsWith('1.10.')) return NarrativeSectionId.lostCity;
    if (number.startsWith('1.11.')) {
      return NarrativeSectionId.neonMixtapeTour;
    }
    if (number.startsWith('1.12.')) return NarrativeSectionId.jurassicMarsh;
    if (number.startsWith('1.13.')) return NarrativeSectionId.modernDay;
    if (number.startsWith('2.3.')) return NarrativeSectionId.steamAges;
    if (number.startsWith('2.4.')) return NarrativeSectionId.renaissanceAges;
    if (number.startsWith('2.5.')) return NarrativeSectionId.heianAges;
    if (number.startsWith('2.6.')) return NarrativeSectionId.underwaterWorld;
    if (number.startsWith('2.7.')) return NarrativeSectionId.moonBase;
    return NarrativeSectionId.systemTutorials;
  }

  if (entry.category == NarrativeCategory.memoryLane) {
    if (id == 'TUTORIAL_PVZ1_INTRO' || number.startsWith('3.7.')) {
      return NarrativeSectionId.memoryImport;
    }
    if (number.startsWith('3.1.')) return NarrativeSectionId.memorySeason27;
    if (number.startsWith('3.2.')) return NarrativeSectionId.memorySeason28;
    if (number.startsWith('3.3.')) return NarrativeSectionId.memorySeason29;
    if (number.startsWith('3.4.')) return NarrativeSectionId.memorySeason30;
    if (number.startsWith('3.5.')) return NarrativeSectionId.memorySeason31;
    if (number.startsWith('3.6.')) return NarrativeSectionId.memorySeason32;
    return NarrativeSectionId.systemTutorials;
  }

  if (id == 'TUTORIAL_TRAVELLOG_INTRO' ||
      id == 'QUEST_INTRO' ||
      id.startsWith('EPIC_QUEST_')) {
    return NarrativeSectionId.travelLog;
  }

  if (entry.category == NarrativeCategory.otherModes) {
    if (id == 'TUTORIAL_PVZ2_UNCHARTED_MODE_INTRO' ||
        entry.iconAsset.endsWith('/Mode_SecretRealm.webp') ||
        id.startsWith('HALLOWEEN_')) {
      return NarrativeSectionId.secretRealm;
    }
    if (id == 'TUTORIAL_NEW_PVP_INTRO' || id.startsWith('NEW_PVP_')) {
      return NarrativeSectionId.twoPlayerDuel;
    }
    if (id == 'TUTORIAL_PVP_INTRO' ||
        id.startsWith('PVP_') ||
        id.startsWith('MAP_PVP')) {
      return NarrativeSectionId.pvpMode;
    }
    if (id == 'TUTORIAL_RIFT_INTRO' || id.startsWith('RIFT_WORLD_')) {
      return NarrativeSectionId.pennysPursuit;
    }
    if (id == 'TUTORIAL_CARD_GAME_INTRO' || id.startsWith('CARD_GAME_')) {
      return NarrativeSectionId.cardClash;
    }
    if (id.startsWith('PLANTTRIAL_')) {
      return NarrativeSectionId.plantEncounter;
    }
    if (id == 'NEW_DANGER_ROOM_INTRO' ||
        id.startsWith('DANGER_ROOM_') ||
        id.startsWith('DANGERROOM_')) {
      return NarrativeSectionId.endlessModes;
    }
    if (id.startsWith('ZEN_GARDEN_')) return NarrativeSectionId.zenGarden;
    if (entry.iconAsset.endsWith('/Mode_PinataParty.webp')) {
      return NarrativeSectionId.pinataParty;
    }
  }

  return NarrativeSectionId.systemTutorials;
}

int _compareSectionEntries(
  NarrativeSectionId sectionId,
  NarrativeEntry a,
  NarrativeEntry b,
  Map<String, int> sourceIndexes,
  Map<String, int> naturalGroupIndexes,
) {
  if (sectionId == NarrativeSectionId.ancientEgypt) {
    final egyptOrder = _ancientEgyptOrder(a).compareTo(_ancientEgyptOrder(b));
    if (egyptOrder != 0) return egyptOrder;
  }
  final mainWorldOrder = _mainWorldTimelineOrders[sectionId];
  if (mainWorldOrder != null) {
    final aIndex = mainWorldOrder.indexOf(a.groupId);
    final bIndex = mainWorldOrder.indexOf(b.groupId);
    final timelineOrder = (aIndex < 0 ? 1000 : aIndex).compareTo(
      bIndex < 0 ? 1000 : bIndex,
    );
    if (timelineOrder != 0) return timelineOrder;
  }
  if (sectionId == NarrativeSectionId.zenGarden) {
    final zenOrder = _zenGardenOrder(a).compareTo(_zenGardenOrder(b));
    if (zenOrder != 0) return zenOrder;
  }
  if (sectionId != NarrativeSectionId.systemTutorials) {
    final tutorialOrder = _modeTutorialPriority(
      a,
    ).compareTo(_modeTutorialPriority(b));
    if (tutorialOrder != 0) return tutorialOrder;
  }
  if (sectionId == NarrativeSectionId.secretRealm) {
    final releaseOrder = _secretRealmReleaseOrder(
      a,
    ).compareTo(_secretRealmReleaseOrder(b));
    if (releaseOrder != 0) return releaseOrder;
  }
  if (sectionId == NarrativeSectionId.endlessModes) {
    final endlessOrder = _endlessModeOrder(a).compareTo(_endlessModeOrder(b));
    if (endlessOrder != 0) return endlessOrder;
  }
  if (sectionId == NarrativeSectionId.pvpMode) {
    final pvpOrder = _pvpModeOrder(a).compareTo(_pvpModeOrder(b));
    if (pvpOrder != 0) return pvpOrder;
  }
  if (sectionId == NarrativeSectionId.travelLog) {
    final epicQuestOrder = _epicQuestSeriesOrder(
      a,
    ).compareTo(_epicQuestSeriesOrder(b));
    if (epicQuestOrder != 0) return epicQuestOrder;
  }
  if (sectionId == NarrativeSectionId.systemTutorials) {
    final systemAnchorOrder = _systemTutorialAnchor(
      a,
      sourceIndexes,
      naturalGroupIndexes,
    ).compareTo(_systemTutorialAnchor(b, sourceIndexes, naturalGroupIndexes));
    if (systemAnchorOrder != 0) return systemAnchorOrder;

    final systemClusterOrder = _systemTutorialClusterOrder(
      a,
    ).compareTo(_systemTutorialClusterOrder(b));
    if (systemClusterOrder != 0) return systemClusterOrder;
  }
  final naturalGroupOrder = (naturalGroupIndexes[_naturalShape(a.groupId)] ?? 0)
      .compareTo(naturalGroupIndexes[_naturalShape(b.groupId)] ?? 0);
  if (naturalGroupOrder != 0) return naturalGroupOrder;
  final naturalOrder = _compareNaturalSiblings(a.groupId, b.groupId);
  if (naturalOrder != 0) return naturalOrder;
  return (sourceIndexes[a.groupId] ?? 0).compareTo(
    sourceIndexes[b.groupId] ?? 0,
  );
}

int _modeTutorialPriority(NarrativeEntry entry) {
  if (entry.groupId.startsWith('TUTORIAL_')) return 0;
  if (entry.groupId == 'QUEST_INTRO') return 1;
  return 2;
}

/// Follows the in-game order of the Epic Quest series that are present in the
/// current dialogue catalogue instead of the unrelated source-file order.
int _epicQuestSeriesOrder(NarrativeEntry entry) {
  final id = entry.groupId;
  if (id.startsWith('EPIC_QUEST_GOLDBLOOM_')) return 0;
  if (id.startsWith('EPIC_QUEST_BEGHOULED_BLITZ_')) return 1;
  if (id.startsWith('EPIC_QUEST_ELECTRICCURRANT_')) return 2;
  if (id.startsWith('EPIC_QUEST_GEMJAM_')) return 3;
  return 4;
}

/// Keeps the current Chinese campaign first, then the international campaign,
/// followed by legacy and unused dialogue. Each block follows day order and
/// keeps multi-part or intro/outro pairs adjacent.
int _ancientEgyptOrder(NarrativeEntry entry) {
  const order = <String, int>{
    // Current Chinese campaign: Days 1-15.
    'FRESHINTRO_EGYPT_DAY1': 0,
    'FRESHINTRO_ZOMBIE_INTRO': 1,
    'FRESHINTRO_PLANTFOOD_INTRO': 2,
    'FRESHINTRO_END_INTRO': 3,
    'EAT_PLANTFOOD_INTRO': 4,
    'USE_PLANTFOOD_INTRO': 5,
    'EGYPT_ICE_INTRO': 6,
    'EGYPT_STANDSTORM_INTRO': 7,
    'EGYPT_CAMEL_INTRO': 8,
    'TUTORIAL_EGYPT6_INTRO': 9,
    'EAT_PLANTFOOD1_INTRO': 10,
    'USE_PLANTFOOD1_INTRO': 11,
    'LEGACY_NUMBERED_SEQUENCE_EGYPT_DAY7': 12,
    'TUTORIAL_EGYPT8_INTRO': 13,
    'EGYPT_TOMB_INTRO': 14,
    'EGYPT_ZOMBIENOTE': 15,
    'EGYPT_INTRO_ZOMBOSS': 16,
    'EGYPT_OUTRO_ZOMBOSS': 17,

    // International campaign: Days 1, 6, and 12.
    'EGYPT_INTRO_FIRSTLEVEL': 18,
    'LEGACY_NUMBERED_SEQUENCE_EGYPT_DAY1_PLANTFOOD_TUTORIAL': 19,
    'LEGACY_NUMBERED_SEQUENCE_EGYPT_DAY1_PLANTFOOD_FOLLOWUP': 20,
    'LEGACY_NUMBERED_SEQUENCE_EGYPT_DAY1_PLANT_EATEN_PROMPT': 21,
    'EGYPT_WORLDMAP_INTRO': 22,
    'EGYPT_INTRO_GARGANTUAR': 23,
    'EGYPT_OUTRO_GARGANTUAR': 24,
    'EGYPT_OUTRO_DANGER_ROOM_KEY': 25,

    // Legacy campaign: day-specific dialogue first.
    'BUY_POWERUPS': 26,
    'EGYPT_CHALLENGE_MINIGAME_B': 27,
    'WORLDMAP_PLANTGJ_INTRO': 28,
    'EGYPT_CHALLENGE_LASTSTAND_A': 29,
    'EGYPT_CHALLENGE_CONVEYOR_INTRO': 30,
    'EGYPT_CHALLENGE_CONVEYOR_OUTRO': 31,
    'EGYPT_INTRO_LASTLEVEL': 32,
    'EGYPT_OUTRO_LASTTLEVEL': 33,
    'EGYPT_CHALLENGE_MINIGAME_C': 34,

    // Legacy challenges without a confirmed day.
    'EGYPT_CHALLENGE_PRESET_A': 35,
    'EGYPT_CHALLENGE_PRESET_B': 36,
    'EGYPT_CHALLENGE_PRESET_C': 37,
    'EGYPT_CHALLENGE_PROTECTPLANTS_A': 38,
    'EGYPT_CHALLENGE_PROTECTPLANTS_B': 39,
    'EGYPT_CHALLENGE_PROTECTPLANTS_C': 40,
    'EGYPT_CHALLENGE_LASTSTAND_B': 41,
    'EGYPT_CHALLENGE_LASTSTAND_C': 42,
    'EGYPT_CHALLENGE_MINIGAME_A': 43,

    // Unused Zomboss dialogue.
    'EYGPT_INTRO_ZOMBOSS': 44,
    'EYGPT_OUTRO_ZOMBOSS': 45,
  };
  return order[entry.groupId] ?? 1000;
}

/// Sections whose source order does not match the displayed day or gameplay
/// progression. Worlds omitted here already follow their audited timeline.
const _mainWorldTimelineOrders = <NarrativeSectionId, List<String>>{
  NarrativeSectionId.tutorialYard: [
    'LEGACY_NUMBERED_SEQUENCE_SHOVEL',
    'PLAYER_HOUSE_DAY5',
  ],
  NarrativeSectionId.pirateSeas: [
    'PIRATE_INTRO_FIRSTLEVEL',
    'PIRATE_WORLDMAP_INTRO',
    'PIRATE_CHALLENGE_PRESET_A',
    'LEGACY_NUMBERED_SEQUENCE_PIRATE_DAY3',
    'PIRATE_OUTRO_DANGER_ROOM_KEY',
    'PIRATE_ZOMBIENOTE',
    'PIRATE_INTRO_GARGANTUAR',
    'PIRATE_OUTRO_GARGANTUAR',
    'PIRATE_CHALLENGE_MINIGAME_A',
    'PIRATE_CHALLENGE_PROTECTPLANTS_A',
    'PIRATE_CHALLENGE_LASTSTAND_A',
    'PIRATE_INTRO_ZOMBOSS',
    'PIRATE_OUTRO_ZOMBOSS',
    'PIRATE_OUTRO_LASTTLEVEL',
    'PIRATE_CHALLENGE_LASTSTAND_B',
    'PIRATE_CHALLENGE_LASTSTAND_C',
    'PIRATE_CHALLENGE_MINIGAME_B',
    'PIRATE_CHALLENGE_MINIGAME_C',
    'PIRATE_CHALLENGE_PRESET_B',
    'PIRATE_CHALLENGE_PRESET_C',
    'PIRATE_CHALLENGE_PROTECTPLANTS_B',
    'PIRATE_CHALLENGE_PROTECTPLANTS_C',
  ],
  NarrativeSectionId.wildWest: [
    'COWBOY_INTRO_FIRSTLEVEL',
    'COWBOY_WORLDMAP_INTRO',
    'COWBOY_OUTRO_DANGER_ROOM_KEY',
    'LEGACY_NUMBERED_SEQUENCE_COWBOY_DAY4',
    'COWBOY_CHALLENGE_LASTSTAND_A',
    'COWBOY_INTRO_LEVEL7',
    'COWBOY_ZOMBIENOTE',
    'COWBOY_INTRO_GARGANTUAR',
    'COWBOY_OUTRO_GARGANTUAR',
    'COWBOY_CHALLENGE_PRESET_A',
    'COWBOY_CHALLENGE_PROTECTPLANTS_A',
    'COWBOY_INTRO_ZOMBOSS',
    'COWBOY_OUTRO_ZOMBOSS',
    'COWBOY_OUTRO_LASTTLEVEL',
    'COWBOY_NEW_OUTRO_LASTTLEVEL',
    'COWBOY_CHALLENGE_LASTSTAND_B',
    'COWBOY_CHALLENGE_LASTSTAND_C',
    'COWBOY_CHALLENGE_MINIGAME_A',
    'COWBOY_CHALLENGE_MINIGAME_B',
    'COWBOY_CHALLENGE_MINIGAME_C',
    'COWBOY_CHALLENGE_PRESET_B',
    'COWBOY_CHALLENGE_PRESET_C',
    'COWBOY_CHALLENGE_PROTECTPLANTS_B',
    'COWBOY_CHALLENGE_PROTECTPLANTS_C',
  ],
  NarrativeSectionId.farFuture: [
    'COWBOY_OUTRO_ZOMBOSS_INTRO',
    'FUTURE_INTRO_FIRSTLEVEL',
    'FUTURE_INTRO_FIRSTLEVEL_FAILURE',
    'FUTURE_CHALLENGE_SUNBOMBS_A',
    'FUTURE_OUTRO_DANGER_ROOM_KEY',
    'FUTURE_CHALLENGE_PRESET_A',
    'FUTURE_ZOMBIENOTE',
    'FUTURE_INTRO_GARGANTUAR',
    'FUTURE_CHALLENGE_LASTSTAND_A',
    'FUTURE_CHALLENGE_PROTECTPLANTS_A',
    'FUTURE_MAGNIFYING_GRASS_FAILURE',
    'FUTURE_CHALLENGE_PRESET_B',
    'FUTURE_MANUAL_MOWERS',
    'FUTURE_INTRO_ZOMBOSS',
    'FUTURE_OUTRO_ZOMBOSS',
    'FUTURE_INTRO_ZOMBOSS_BASIC',
    'FUTURE_INTRO_ZOMBOSS_TOUCH',
  ],
  NarrativeSectionId.darkAges: [
    'DARK_INTRO_FIRSTLEVEL',
    'DARK_INTRO_HYPNOSHROOM',
    'DARK_INTRO_FUMESHROOM',
    'DARK_INTRO_EVILPOTIONS',
    'DARK_ZOMBIENOTE',
    'DARK_INTRO_GARGANTUAR',
    'DARK_OUTRO_DANGER_ROOM_KEY',
    'DARK_INTRO_PEANUT',
    'DARK_INTRO_MAGNETSHROOM',
    'DARK_INTRO_ZOMBOSS',
    'DARK_OUTRO_ZOMBOSS',
    'DARK_HYPNOSHROOM_INTRO',
    'DARK_INTRO_SUNSHROOM_CHAT',
  ],
  NarrativeSectionId.bigWaveBeach: [
    'BEACH_INTRO_FIRSTLEVEL',
    'BEACH_INTRO_TIDES',
    'BEACH_INTRO_CHOMPER',
    'BEACH_INTRO_GUACODILE',
    'BEACH_INTRO_BOWLING',
    'BEACH_ZOMBIENOTE',
    'BEACH_INTRO_GARGANTUAR_ALT',
    'BEACH_OUTRO_DANGER_ROOM_KEY',
    'BEACH_INTRO_HOMINGTHISTLE',
    'BEACH_INTRO_BANANA',
    'BEACH_INTRO_ZOMBOSS',
    'BEACH_OUTRO_ZOMBOSS',
    'BEACH_INTRO_GARGANTUAR',
  ],
  NarrativeSectionId.frostbiteCaves: [
    'ICEAGE_INTRO_FIRSTLEVEL',
    'ICEAGE_INTRO_ICEBLOCKS',
    'ICEAGE_INTRO_HURRIKALE',
    'ICEAGE_INTRO_FIREPEASHOOTER',
    'ICEAGE_INTRO_FLAMETHROWER',
    'ICEAGE_INTRO_CHARDGUARD',
    'ICEAGE_INTRO_GARGANTUAR',
    'ICEAGE_ZOMBIENOTE',
    'ICEAGE_INTRO_STUNION',
    'ICEAGE_INTRO_PEPPERPULT',
    'ICEAGE_OUTRO_DANGER_ROOM_KEY',
    'ICEAGE_INTRO_ZOMBOSS',
    'ICEAGE_OUTRO_ZOMBOSS',
    'ICEAGE_INTRO_XSHOT',
    'ICEAGE_INTRO_MINIGAME',
  ],
  NarrativeSectionId.kongfuWorld: [
    'KONGFU_INTRO_FIRSTLEVEL',
    'KONGFU_INTRO_KONGFU_LEVEL6',
    'KONGFU_INTRO_KONGFU_LEVEL9',
    'KONGFU_CHALLENGE_LASTSTAND_A',
    'KONGFU_INTRO_KONGFU_LEVEL32',
    'KONGFU_INTRO_KONGFU_LEVEL31',
    'KONGFU_INTRO_KONGFU_LEVEL33',
    'KONGFU_INTRO_KONGFU_LEVEL34',
    'KONGFU_INTRO_KONGFU_LEVEL35',
    'KONGFU_INTRO_KONGFU_LEVEL36',
    'KONGFU_INTRO_KONGFU_LEVEL14',
    'KONGFU_INTRO_KONGFU_LEVEL15',
    'KONGFU_OUTRO_KONGFU_LEVEL15',
  ],
  NarrativeSectionId.skyCity: [
    'SKYCITY_FIRSTLEVEL_INTRO',
    'CANNON_USE_INTRO',
    'CANNON_USE_END_INTRO',
    'POOYAN_CHOOSING',
    'POOYAN_CHOOSED',
    'POOYAN_ZOMBIE_GARGANTUAR',
    'BESIEGE_INTRO',
    'BOX_INTRO',
    'BOX_PLANTED_INTRO',
    'BOX_SHOVELED_INTRO',
    'SHOWREGINSKY_INTRO',
    'SHOWSHIPHEALTH_INTRO',
    'SHOWTHUNDER_INTRO',
    'PLANTTHUNDER_INTRO',
  ],
  NarrativeSectionId.lostCity: [
    'LOSTCITY_1_INTRO',
    'LOSTCITY_2_INTRO',
    'LOSTCITY_3_INTRO',
    'LOSTCITY_4_INTRO',
    'LOSTCITY_ZOMBIENOTE',
    'LOSTCITY_16_INTRO',
    'LOSTCITY_17_INTRO',
    'LOSTCITY_22_INTRO',
    'LOSTCITY_OUTRO_DANGER_ROOM_KEY',
    'LOSTCITY_INTRO_ZOMBOSS',
    'LOSTCITY_OUTRO_ZOMBOSS',
  ],
  NarrativeSectionId.neonMixtapeTour: [
    'EIGHTIES_1_INTRO',
    'EIGHTIES_2_INTRO',
    'EIGHTIES_3_INTRO',
    'EIGHTIES_15_OUTRO',
    'EIGHTIES_16_INTRO',
    'EIGHTIES_17_INTRO',
    'EIGHTIES_OUTRO_DANGER_ROOM_KEY',
    'EIGHTIES_22_INTRO',
    'EIGHTIES_32_INTRO',
    'EIGHTIES_32_OUTRO',
    'EIGHTIES_26_INTRO',
  ],
  NarrativeSectionId.jurassicMarsh: [
    'DINO_1_INTRO',
    'DINO_2_INTRO',
    'DINO_6_INTRO',
    'DINO_9_INTRO',
    'DINO_8_INTRO',
    'DINO_21_INTRO',
    'DINO_16_INTRO',
    'DINO_15_OUTRO',
    'DINO_17_INTRO',
    'DINO_OUTRO_DANGER_ROOM_KEY',
    'DINO_23_INTRO',
    'DINO_INTRO_ZOMBOSS',
    'DINO_OUTRO_ZOMBOSS',
  ],
  NarrativeSectionId.modernDay: [
    'MODERN_1_INTRO',
    'MODERN_2_INTRO',
    'MODERN_3_INTRO',
    'MODERN_5_INTRO',
    'MODERN_8_INTRO',
    'MODERN_9_INTRO',
    'MODERN_11_INTRO',
    'MODERN_15_OUTRO',
    'MODERN_16_INTRO',
    'MODERN_17_INTRO',
    'MODERN_19_INTRO',
    'MODERN_OUTRO_DANGER_ROOM_KEY',
    'MODERN_21_INTRO',
    'MODERN_22_INTRO',
    'MODERN_23_INTRO',
    'MODERN_24_INTRO',
    'MODERN_25_INTRO',
    'MODERN_25_OUTRO',
    'MODERN_26_INTRO',
    'MODERN_26_OUTRO',
    'MODERN_27_INTRO',
    'MODERN_27_OUTRO',
  ],
  NarrativeSectionId.steamAges: [
    'STEAM_1_INTRO',
    'STEAM_3_INTRO',
    'STEAM_6_INTRO',
    'STEAM_13_INTRO',
    'STEAM_16_INTRO',
    'STEAM_21_INTRO',
    'STEAM_INTRO_ZOMBOSS',
    'STEAM_OUTRO_ZOMBOSS',
  ],
  NarrativeSectionId.renaissanceAges: [
    'RENAI_1_INTRO',
    'RENAI_3_INTRO',
    'RENAI_5_INTRO',
    'RENAI_7_INTRO',
    'RENAI_14_INTRO',
    'RENAI_16_INTRO',
    'RENAI_INTRO_ZOMBOSS',
    'RENAI_OUTRO_ZOMBOSS',
  ],
  NarrativeSectionId.heianAges: [
    'HEIAN_1_INTRO',
    'HEIAN_2_INTRO',
    'HEIAN_3_INTRO',
    'HEIAN_4_INTRO',
    'HEIAN_5_INTRO',
    'HEIAN_6_INTRO',
    'HEIAN_7_INTRO',
    'HEIAN_11_INTRO',
    'HEIAN_13_INTRO',
    'HEIAN_17_INTRO',
  ],
  NarrativeSectionId.underwaterWorld: [
    'ATLANTIS_1_INTRO',
    'ATLANTIS_2_INTRO',
    'ATLANTIS_3_INTRO',
    'ATLANTIS_4_INTRO',
    'ATLANTIS_5_INTRO',
    'ATLANTIS_6_INTRO',
    'ATLANTIS_7_INTRO',
    'ATLANTIS_8_INTRO',
    'ATLANTIS_9_INTRO',
    'ATLANTIS_10_INTRO',
    'ATLANTIS_11_INTRO',
    'ATLANTIS_12_INTRO',
    'ATLANTIS_13_INTRO',
    'ATLANTIS_14_INTRO',
    'ATLANTIS_15_INTRO',
    'ATLANTIS_16_INTRO',
    'ATLANTIS_17_INTRO',
    'ATLANTIS_18_INTRO',
    'ATLANTIS_21_INTRO',
    'ATLANTIS_24_INTRO',
  ],
  NarrativeSectionId.moonBase: [
    'MOON1_TUTORIAL_1',
    'MOON1_TUTORIAL_2',
    'MOON1_TUTORIAL_3',
    'MOON1_TUTORIAL_4',
    'MOON1_TUTORIAL_5',
    'MOON1_TUTORIAL_6',
    'MOON1_TUTORIAL_7',
    'MOON_2_INTRO',
    'ROCKET_TUTORIAL_1',
    'ROCKET_TUTORIAL_2',
    'MOON_4_INTRO',
    'METEOR_TUTORIAL_1',
    'METEOR_TUTORIAL_2',
    'METEOR_TUTORIAL_3',
    'MOON_13_INTRO',
    'MOON_14_INTRO',
    'GRAVITY_TUTORIAL_1',
    'GRAVITY_TUTORIAL_2',
    'GRAVITY_TUTORIAL_3',
    'MOON_20_INTRO',
  ],
};

int _zenGardenOrder(NarrativeEntry entry) {
  const order = <String, int>{
    'ZEN_GARDEN_MARIGOLD_TUTORIAL_WELCOME': 0,
    'ZEN_GARDEN_MARIGOLD_TUTORIAL_SPEED_UP': 1,
    'ZEN_GARDEN_INTRO_TUTORIAL_SPEED_UP': 2,
    'ZEN_GARDEN_INTRO_TUTORIAL_WELCOME': 3,
  };
  return order[entry.groupId] ?? 1000;
}

int _endlessModeOrder(NarrativeEntry entry) {
  const order = <String, int>{
    'DANGER_ROOM_TUTORIAL': 0,
    'DANGER_ROOM_INTROWRAPUP': 1,
    'DANGER_ROOM_POWER': 2,
    'DANGER_ROOM_SUCCESS': 3,
    'DANGER_ROOM_FAILURE': 4,
    'DANGER_ROOM_LAWNMOWER_SUCCESS': 5,
    'DANGER_ROOM_INTRO_EGYPT': 6,
    'DANGER_ROOM_INTRO_PIRATE': 7,
    'DANGER_ROOM_INTRO_COWBOY': 8,
    'DANGER_ROOM_INTRO_FUTURE': 9,
    'DANGER_ROOM_INTRO_DARK': 10,
    'DANGER_ROOM_INTRO_BEACH': 11,
    'DANGER_ROOM_INTRO_ICEAGE': 12,
    'DANGER_ROOM_INTRO_LOSTCITY': 13,
    'DANGER_ROOM_INTRO_EIGHTIES': 14,
    'DANGER_ROOM_INTRO_DINO': 15,
    'DANGER_ROOM_INTRO_MODERN': 16,
    'DANGER_ROOM_INTRO_FESTIVAL': 17,
    'DANGER_ROOM_INTRO_FESTIVAL_LEVEL_ONE': 18,
    'DANGER_ROOM_INTRO_FESTIVAL_LEVEL_TWO': 19,
    'DANGER_ROOM_INTRO_FESTIVAL_LEVEL_THREE': 20,
    'DANGER_ROOM_INTRO_FESTIVAL_LEVEL_FOUR': 21,
    'NEW_DANGER_ROOM_INTRO': 22,
    'DANGERROOM_SELECT_TUTORIAL': 23,
  };
  return order[entry.groupId] ?? 1000;
}

/// Follows the original PvP onboarding flow instead of the catalogue source
/// order, which places the map opening after several battle tutorials.
int _pvpModeOrder(NarrativeEntry entry) {
  const order = <String, int>{
    'TUTORIAL_PVP_INTRO': 0,
    'MAP_PVP_INTRO': 1,
    'MAP_PVPMAINMENU_INTRO': 2,
    'MAP_PVPGARDENWAR_INTRO': 3,
    'PVP_PLANTMODULE_INTRO': 4,
    'PVP_BATTLEMODULE1_INTRO': 5,
    'PVP_BATTLEMODULE2_INTRO': 6,
    'PVP_TRAINZB_INTRO': 7,
    'PVP_TRAINZB_MORE': 8,
    'PVP_ATTACK_INTRO': 9,
    'PVP_ATTACKBEGIN_INTRO': 10,
    'PVP_ATTACKMODULE_INTRO': 11,
    'PVP_ATTACKMODULE_BUFINTRO': 12,
    'PVP_ATTACKMODULE_END': 13,
    'PVP_OCCUPYMAP_INTRO': 14,
    'MAP_PVPEVILDAVID_START_INTRO': 15,
    'MAP_PVPEVILDAVID_FAILED_INTRO': 16,
    'MAP_PVPEVILDAVID_SUCCESS_1_INTRO': 17,
    'MAP_PVPEVILDAVID_SUCCESS_2_INTRO': 18,
    'MAP_PVPEVILDAVID_SUCCESS_3_INTRO': 19,
    'MAP_PVPEVILDAVID_SUCCESS_4_INTRO': 20,
    'MAP_PVPEVILDAVID_SUCCESS_5_INTRO': 21,
    'MAP_PVPEVILDAVID_SUCCESS_6_INTRO': 22,
  };
  return order[entry.groupId] ?? 1000;
}

const _powerGestureTutorialOrder = <String, int>{
  'PINCH': 0,
  'FLICK': 1,
  'WIZARDFINGER': 2,
};

const _seedRainTutorialOrder = <String, int>{
  'SEEDRAIN_DAVE_INTRO': 0,
  'SEEDRAIN_ACORN_INTRO': 1,
};

const _plantPuzzleTutorialOrder = <String, int>{
  'ELIMINATE_BLOCK_INTRO': 0,
  'ELIMINATE_COLOR_INTRO': 1,
  'ELIMINATE_INTRO': 2,
  'ZOMBIE_INTRO_ELIMINATE_MISSIONFINISH': 3,
  'ZOMBIE_INTRO_ELIMINATE_FREEZINGWIND': 4,
  'ZOMBIE_INTRO_ELIMINATE_SPAWNSHIELD': 5,
  'ZOMBIE_INTRO_ELIMINATE_STAGE11': 6,
  'ZOMBIE_INTRO_ELIMINATE_STAGE12': 7,
  'ZOMBIE_INTRO_ELIMINATE_STAGE21': 8,
  'ZOMBIE_INTRO_ELIMINATE_STAGE22': 9,
  'ZOMBIE_INTRO_ELIMINATE_STAGE31': 10,
  'ZOMBIE_INTRO_ELIMINATE_STAGE32': 11,
  'ZOMBIE_INTRO_ELIMINATE_STAGE41': 12,
  'ZOMBIE_INTRO_ELIMINATE_STAGE42': 13,
};

/// Keeps tutorial families together without disturbing the source order of
/// unrelated system dialogue. The family is anchored at the first member's
/// original position, while the explicit member order reflects the order in
/// which the mechanics are introduced to the player.
int _systemTutorialAnchor(
  NarrativeEntry entry,
  Map<String, int> sourceIndexes,
  Map<String, int> naturalGroupIndexes,
) {
  if (_isSystemFeatureTutorial(entry.groupId)) {
    return sourceIndexes.entries
        .firstWhere((entry) => _isSystemFeatureTutorial(entry.key))
        .value;
  }
  final family = _systemTutorialFamily(entry.groupId);
  if (family != null) {
    return family.keys
        .map((id) => sourceIndexes[id])
        .whereType<int>()
        .reduce((first, second) => first < second ? first : second);
  }
  return naturalGroupIndexes[_naturalShape(entry.groupId)] ??
      sourceIndexes[entry.groupId] ??
      0;
}

// The localized "System Tutorial" series also includes the world-unlock
// dialogue. Group it by its stable IDs, leaving the separate New Year story
// in its original position instead of treating every TUTORIAL_ ID alike.
bool _isSystemFeatureTutorial(String id) =>
    (id.startsWith('TUTORIAL_') && id != 'TUTORIAL_NEWYEARREDPACKET') ||
    id.startsWith('UNLOCK_WORLD_');

Map<String, int>? _systemTutorialFamily(String id) {
  if (_powerGestureTutorialOrder.containsKey(id)) {
    return _powerGestureTutorialOrder;
  }
  if (_seedRainTutorialOrder.containsKey(id)) {
    return _seedRainTutorialOrder;
  }
  if (_plantPuzzleTutorialOrder.containsKey(id)) {
    return _plantPuzzleTutorialOrder;
  }
  return null;
}

int _systemTutorialClusterOrder(NarrativeEntry entry) {
  return _systemTutorialFamily(entry.groupId)?[entry.groupId] ?? 0;
}

int _compareNaturalSiblings(String a, String b) {
  final numberPattern = RegExp(r'\d+');
  if (_naturalShape(a) != _naturalShape(b)) return 0;

  final aNumbers = numberPattern
      .allMatches(a)
      .map((match) => int.parse(match.group(0)!))
      .toList(growable: false);
  final bNumbers = numberPattern
      .allMatches(b)
      .map((match) => int.parse(match.group(0)!))
      .toList(growable: false);
  for (
    var index = 0;
    index < aNumbers.length && index < bNumbers.length;
    index++
  ) {
    final comparison = aNumbers[index].compareTo(bNumbers[index]);
    if (comparison != 0) return comparison;
  }
  final lengthComparison = aNumbers.length.compareTo(bNumbers.length);
  if (lengthComparison != 0) return lengthComparison;

  int phaseOrder(String value) => value.endsWith('_INTRO')
      ? 0
      : value.endsWith('_OUTRO')
      ? 1
      : 2;
  return phaseOrder(a).compareTo(phaseOrder(b));
}

String _naturalShape(String value) => value
    .replaceFirst(RegExp(r'_(INTRO|OUTRO)$'), '_PHASE')
    .replaceAll(RegExp(r'\d+'), '#');

int _secretRealmReleaseOrder(NarrativeEntry entry) {
  final id = entry.groupId;
  if (id == 'TUTORIAL_PVZ2_UNCHARTED_MODE_INTRO') return 0;
  if (id == 'ANNIVERSARY_UNCHARTED_EVENT_TUTORIAL' ||
      id.startsWith('HALLOWEEN_')) {
    return 2;
  }
  if (id.startsWith('CHILDRENSDAY_')) return 4;
  if (id.startsWith('SPECIAL_UNCHARTED_')) return 5;
  if (id.startsWith('CHRISTMAS_202512_') ||
      id.startsWith('ICEAGE_UNCHARTED_') ||
      id.startsWith('UNCHARTED_ICEAGE_')) {
    return 7;
  }
  if (id.startsWith('SPRING_FESTIVAL_2024_')) return 8;
  if (id.startsWith('ARBORDAY_')) return 9;
  if (id.startsWith('NEEDFORSPEED_')) return 10;
  if (id.startsWith('NO42_') || id.startsWith('UNCHARTED_NO42_')) return 11;
  if (id.startsWith('MAUSOLEUM_')) return 15;
  if (id.startsWith('ARENA_')) return 16;
  return 99;
}

String? _nonEmptyString(Object? value) {
  final text = value?.toString();
  return text == null || text.isEmpty ? null : text;
}
