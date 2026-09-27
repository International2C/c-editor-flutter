import 'package:c_editor/data/models/zomboss_mech_catalog.dart';
import 'package:c_editor/data/pvz_models.dart';
import 'package:c_editor/data/repository/zombie_properties_repository.dart';
import 'package:c_editor/data/rtid_parser.dart';

enum ZombossMechActionMainCategory { movement, summon, attack, special, other }

extension ZombossMechActionMainCategoryX on ZombossMechActionMainCategory {
  int get priority {
    return switch (this) {
      ZombossMechActionMainCategory.movement => 0,
      ZombossMechActionMainCategory.summon => 1,
      ZombossMechActionMainCategory.attack => 2,
      ZombossMechActionMainCategory.special => 3,
      ZombossMechActionMainCategory.other => 4,
    };
  }

  String get filterKey {
    return switch (this) {
      ZombossMechActionMainCategory.movement => 'movement',
      ZombossMechActionMainCategory.summon => 'spawn',
      ZombossMechActionMainCategory.attack => 'attack',
      ZombossMechActionMainCategory.special => 'special',
      ZombossMechActionMainCategory.other => 'other',
    };
  }
}

class ZombossMechActionOrdering {
  ZombossMechActionOrdering._();

  static const allFilter = 'all';
  static const customFilter = 'custom';
  static const summonFilter = 'spawn';

  static ZombossMechActionMainCategory categoryForCatalogAction(
    ZombossMechCatalogAction action,
  ) {
    return _categoryFromFields(
      tag: action.tag,
      alias: action.alias,
      objclass: action.objclass,
    );
  }

  static ZombossMechActionMainCategory categoryForGroup(
    ZombossMechObjclassGroup group, {
    String alias = '',
  }) {
    return _categoryFromFields(
      tag: group.tag,
      alias: alias,
      objclass: group.objclass,
    );
  }

  static bool matchesFilter({
    required String filter,
    required bool isCustom,
    required ZombossMechActionMainCategory category,
  }) {
    if (filter == allFilter) return true;
    if (filter == customFilter) return isCustom;
    if (category == ZombossMechActionMainCategory.other) return false;
    if (isCustom && filter != summonFilter) return false;
    return category.filterKey == filter;
  }

  static List<ZombossMechCatalogAction> sortedCatalogActions(
    ZombossMechCatalogEntry catalog,
  ) {
    final actions = <ZombossMechCatalogAction>[];
    final seen = <String>{};
    for (final action in catalog.catalogActions) {
      if (!isRegularPhaseCatalogAction(action)) continue;
      if (seen.add(action.alias)) actions.add(action);
    }

    final originalIndex = <String, int>{};
    for (var i = 0; i < actions.length; i++) {
      originalIndex.putIfAbsent(actions[i].alias, () => i);
    }

    final variationOrder = _variationActionOrder(catalog);
    actions.sort((a, b) {
      final aOrder = variationOrder[a.alias];
      final bOrder = variationOrder[b.alias];
      final aMatched = aOrder != null;
      final bMatched = bOrder != null;
      if (aMatched != bMatched) return aMatched ? -1 : 1;

      final aCategory = categoryForCatalogAction(a);
      final bCategory = categoryForCatalogAction(b);
      if (aMatched && bMatched) {
        final variationCompare = aOrder.variationIndex.compareTo(
          bOrder.variationIndex,
        );
        if (variationCompare != 0) return variationCompare;
      }

      final categoryCompare = aCategory.priority.compareTo(bCategory.priority);
      if (categoryCompare != 0) return categoryCompare;

      final aIndex = aOrder?.originalIndex ?? originalIndex[a.alias] ?? 0;
      final bIndex = bOrder?.originalIndex ?? originalIndex[b.alias] ?? 0;
      return aIndex.compareTo(bIndex);
    });
    return actions;
  }

  static ZombossMechActionMainCategory _categoryFromFields({
    required String tag,
    required String alias,
    required String objclass,
  }) {
    if (_isSummonIdentifier(alias) ||
        _isSummonIdentifier(objclass) ||
        _isSummonIdentifier(tag) ||
        _isSummonObjclass(objclass)) {
      return ZombossMechActionMainCategory.summon;
    }
    if (isZombossJumpActionObjclass(objclass)) {
      return ZombossMechActionMainCategory.movement;
    }
    return switch (tag) {
      'movement' => ZombossMechActionMainCategory.movement,
      'attack' => ZombossMechActionMainCategory.attack,
      'special' => ZombossMechActionMainCategory.special,
      _ => ZombossMechActionMainCategory.other,
    };
  }

  static bool _isSummonIdentifier(String value) {
    final normalized = value.toLowerCase();
    return normalized.contains('spawn') || normalized.contains('portalsevent');
  }

  static bool _isSummonObjclass(String value) {
    return value == 'ZombieDropZombiesOnBoardActionDefinition' ||
        value == 'ZombieDropActionDefinition';
  }

  static Map<String, _VariationActionOrder> _variationActionOrder(
    ZombossMechCatalogEntry catalog,
  ) {
    final order = <String, _VariationActionOrder>{};
    for (
      var variationIndex = 0;
      variationIndex < catalog.variations.length;
      variationIndex++
    ) {
      final propsData = _propsDataForVariation(catalog, variationIndex);
      if (propsData == null) continue;
      var originalIndex = 0;
      for (final alias in _actionAliasesInProps(propsData)) {
        order.putIfAbsent(
          alias,
          () => _VariationActionOrder(variationIndex, originalIndex),
        );
        originalIndex++;
      }
    }
    return order;
  }

  static Map<String, dynamic>? _propsDataForVariation(
    ZombossMechCatalogEntry catalog,
    int variationIndex,
  ) {
    final variation = catalog.variations[variationIndex];
    final aliases = <String>[
      ..._propertyAliasesFromZombieVariation(variation),
      ..._fallbackPropertyAliases(catalog, variation, variationIndex),
    ];
    final seen = <String>{};
    for (final alias in aliases) {
      if (!seen.add(alias)) continue;
      for (final group in catalog.properties) {
        final data = group.implementations[alias];
        if (data != null) return data;
      }
    }
    return null;
  }

  static Iterable<String> _propertyAliasesFromZombieVariation(
    String variation,
  ) sync* {
    if (!ZombiePropertiesRepository.isInitialized) return;
    final typeName = ZombiePropertiesRepository.getTypeNameByAlias(variation);
    final template = ZombiePropertiesRepository.getTemplateJson(typeName);
    final typeObj = template?['type'];
    if (typeObj is! PvzObject || typeObj.objData is! Map) return;
    final typeData = ZombieTypeData.fromJson(
      Map<String, dynamic>.from(typeObj.objData as Map),
    );
    final propsAlias = RtidParser.parse(typeData.properties)?.alias;
    if (propsAlias != null && propsAlias.isNotEmpty) yield propsAlias;
  }

  static Iterable<String> _fallbackPropertyAliases(
    ZombossMechCatalogEntry catalog,
    String variation,
    int variationIndex,
  ) sync* {
    if (variation == catalog.editableInstance &&
        catalog.editableInstancePropsName.isNotEmpty) {
      yield catalog.editableInstancePropsName;
    }
    final normalizedVariation = _normalizeIdentifier(variation);
    for (final group in catalog.properties) {
      var index = 0;
      for (final alias in group.implementations.keys) {
        if (_normalizeIdentifier(alias).contains(normalizedVariation)) {
          yield alias;
        }
        if (index == variationIndex) yield alias;
        index++;
      }
    }
  }

  static Iterable<String> _actionAliasesInProps(
    Map<String, dynamic> props,
  ) sync* {
    final seen = <String>{};
    final stages = props['Stages'];
    if (stages is List) {
      for (final stage in stages) {
        if (stage is! Map) continue;
        final actions = stage['Actions'];
        if (actions is! List) continue;
        for (final action in actions) {
          final alias = RtidParser.parse(action.toString())?.alias;
          if (alias != null && alias.isNotEmpty && seen.add(alias)) {
            yield alias;
          }
        }
      }
    }
  }

  static String _normalizeIdentifier(String value) {
    return value.replaceAll(RegExp(r'[^A-Za-z0-9]'), '').toLowerCase();
  }
}

class _VariationActionOrder {
  const _VariationActionOrder(this.variationIndex, this.originalIndex);

  final int variationIndex;
  final int originalIndex;
}
