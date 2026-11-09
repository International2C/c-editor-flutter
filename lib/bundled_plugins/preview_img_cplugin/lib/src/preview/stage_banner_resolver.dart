import 'dart:convert';

import 'package:collection/collection.dart';
import 'package:flutter/services.dart';
import 'package:c_editor/data/custom_stage_level_utils.dart';
import 'package:c_editor/data/repository/stage_repository.dart';

/// Resolves stage / custom-stage aliases to banner asset paths.
class StageBannerResolver {
  StageBannerResolver._(
    this._defaultStem,
    this._extension,
    this._directory,
    this._stages,
    this._variantBaseStems,
  );

  static const flutterAssetsRoot =
      'lib/bundled_plugins/preview_img_cplugin/assets';

  final String _defaultStem;
  final String _extension;
  final String _directory;
  final Map<String, String> _stages;
  final Map<String, String> _variantBaseStems;

  static StageBannerResolver? _instance;

  static Future<StageBannerResolver> load() async {
    if (_instance != null) return _instance!;
    final raw = await rootBundle.loadString(
      '$flutterAssetsRoot/stage_banners.json',
    );
    final json = jsonDecode(raw) as Map<String, dynamic>;
    final stagesRaw = json['stages'];
    final stages = <String, String>{};
    if (stagesRaw is Map) {
      for (final e in stagesRaw.entries) {
        stages[e.key.toString()] = e.value.toString();
      }
    }
    _instance = StageBannerResolver._(
      (json['default'] as String?) ?? 'Unknown',
      (json['extension'] as String?) ?? '.png',
      (json['directory'] as String?) ?? 'banners',
      stages,
      Map<String, String>.from(json['variants'] as Map? ?? const {}),
    );
    return _instance!;
  }

  /// For tests.
  static void resetForTest() => _instance = null;

  static StageBannerResolver forTest({
    String defaultStem = 'Unknown',
    String extension = '.png',
    String directory = 'banners',
    Map<String, String> stages = const {},
    Map<String, String> variants = const {},
  }) {
    return StageBannerResolver._(
      defaultStem,
      extension,
      directory,
      stages,
      variants,
    );
  }

  String get defaultStem => _defaultStem;

  String assetPathForStem(String stem) =>
      '$flutterAssetsRoot/$_directory/$stem$_extension';

  String resolveStem(String? stageAlias, {Map<String, dynamic>? stageObjdata}) {
    if (stageObjdata != null &&
        CustomStageLevelUtils.supportsMoonPart2Appearance(stageObjdata)) {
      return CustomStageLevelUtils.isMoonPart2AppearanceEnabled(stageObjdata)
          ? 'Moon2'
          : 'Moon';
    }
    if (stageAlias == null || stageAlias.isEmpty) return _defaultStem;
    final direct = _stages[stageAlias];
    if (direct != null && direct.isNotEmpty) return direct;
    // Alias without trailing "Stage" / custom suffix already in map.
    if (_stages.containsKey(stageAlias)) return _stages[stageAlias]!;
    return _defaultStem;
  }

  String resolveAssetPath(String? stageAlias) =>
      assetPathForStem(resolveStem(stageAlias));

  /// Stage aliases that explicitly map to [stem], in catalog order.
  ///
  /// This is intentionally different from [resolveStem]: an unknown alias
  /// resolves to the fallback banner, but must not be presented as a stage
  /// that belongs to that banner in selection UI.
  List<String> stageAliasesForStem(String stem) => [
    for (final entry in _stages.entries)
      if (entry.value == (_variantBaseStems[stem] ?? stem)) entry.key,
  ];

  /// Banner stems ordered by the supplied stage catalog, followed by banners
  /// that only belong to custom stages. The fallback banner is always last.
  /// Picker actions such as adding a custom image are not part of this list.
  List<String> orderedStemsForStageAliases(Iterable<String> stageAliases) {
    final stems = <String>{};
    for (final alias in stageAliases) {
      final stem = _stages[alias];
      if (stem != null && stem.isNotEmpty && stem != _defaultStem) {
        stems.add(stem);
      }
    }
    for (final stem in _stages.values) {
      if (stem.isNotEmpty && stem != _defaultStem) stems.add(stem);
    }
    return [
      for (final stem in stems) ...[
        stem,
        for (final variant in _variantBaseStems.entries)
          if (variant.value == stem) variant.key,
      ],
      _defaultStem,
    ];
  }

  List<String> get allStems {
    final stems = <String>{
      _defaultStem,
      ..._stages.values,
      ..._variantBaseStems.keys,
    };
    return stems.toList()..sort();
  }

  /// Stage aliases that map to [stem] (e.g. EgyptStage → Egypt).
  List<String> aliasesForStem(String stem) {
    final out = stageAliasesForStem(stem);
    out.sort();
    return out;
  }

  /// Round icon under assets/images/round_icons (uses Stages_tags icon names).
  /// Unknown / default stem always uses the shared question-mark icon.
  String roundIconAssetForStem(String stem) {
    if (_isUnknownStem(stem)) {
      return 'assets/images/others/unknown.webp';
    }
    stem = _variantBaseStems[stem] ?? stem;
    final aliases = aliasesForStem(stem);
    for (final alias in aliases) {
      final icon = StageRepository.allItems
          .firstWhereOrNull((s) => s.alias == alias)
          ?.iconName;
      if (icon != null && icon.isNotEmpty) {
        if (icon == 'unknown.webp' || icon.endsWith('/unknown.webp')) {
          return 'assets/images/others/unknown.webp';
        }
        return icon.startsWith('assets/')
            ? icon
            : 'assets/images/round_icons/$icon';
      }
    }

    // Fallbacks when catalog isn't loaded or stem has no tagged alias.
    final shortAliases = [
      for (final a in aliases) a.replaceAll(RegExp(r'(Stage|Custom)$'), ''),
    ];
    final candidates = <String>[
      'assets/images/round_icons/Stage_$stem.webp',
      'assets/images/round_icons/Stage_$stem.gif',
      for (final a in shortAliases)
        if (a.isNotEmpty) 'assets/images/round_icons/Stage_$a.webp',
      if (stem.startsWith('Uncharted'))
        'assets/images/round_icons/Suffix_Uncharted.webp',
      'assets/images/others/unknown.webp',
    ];
    return candidates.first;
  }

  /// Alternate round-icon paths for [AssetImageWidget] fallbacks.
  List<String> roundIconAltCandidatesForStem(String stem) {
    if (_isUnknownStem(stem)) {
      return const [];
    }
    final primary = roundIconAssetForStem(stem);
    final aliases = aliasesForStem(stem);
    final paths = <String>{'assets/images/others/unknown.webp'};
    for (final alias in aliases) {
      final icon = StageRepository.allItems
          .firstWhereOrNull((s) => s.alias == alias)
          ?.iconName;
      if (icon != null && icon.isNotEmpty) {
        paths.add(
          icon.startsWith('assets/') ? icon : 'assets/images/round_icons/$icon',
        );
      }
      final short = alias.replaceAll(RegExp(r'(Stage|Custom)$'), '');
      if (short.isNotEmpty) {
        paths.add('assets/images/round_icons/Stage_$short.webp');
      }
    }
    paths.add('assets/images/round_icons/Stage_$stem.webp');
    paths.add('assets/images/round_icons/Stage_$stem.gif');
    if (stem.startsWith('Uncharted')) {
      paths.add('assets/images/round_icons/Suffix_Uncharted.webp');
    }
    paths.remove(primary);
    return paths.toList();
  }

  bool _isUnknownStem(String stem) =>
      stem == _defaultStem ||
      stem == 'Unknown' ||
      stem.toLowerCase() == 'unknown';
}
