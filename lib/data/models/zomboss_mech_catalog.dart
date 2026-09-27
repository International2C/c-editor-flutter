import 'dart:convert';

/// Spawn actions must reference the built-in jump, even in level-local actions.
const zombossSpawnJumpActionRtid = 'RTID(ZombossSpawnJump@ZombieActions)';

/// Objclasses for jump actions that can be used in both phase lists and retreat.
const zombossJumpActionObjclasses = <String>{
  'ZombossJumpActionDefinition',
  'ZombossSteamJumpActionDefinition',
  'ZombossSteamRandomJumpActionDefinition',
  'ZombossQigongJumpActionDefinition',
  'ZombossRomanHotRodicusJumpActionDefinition',
};

bool isZombossJumpActionObjclass(String objclass) =>
    zombossJumpActionObjclasses.contains(objclass);

bool isRegularPhaseCatalogAction(ZombossMechCatalogAction action) =>
    action.tag != 'retreat';

bool isRetreatPhaseCatalogAction(ZombossMechCatalogAction action) =>
    action.tag == 'retreat' || isZombossJumpActionObjclass(action.objclass);

bool isRegularPhaseActionGroup(ZombossMechObjclassGroup group) =>
    group.tag != 'retreat';

bool isRetreatPhaseActionGroup(ZombossMechObjclassGroup group) =>
    group.tag == 'retreat' || isZombossJumpActionObjclass(group.objclass);

bool isZombossJumpActionField(ZombossMechFieldSpec field) =>
    field.type == 'rtid' && field.name.endsWith('JumpAction');

/// Field descriptor from [ZombossMechs.json] `fields` arrays.
class ZombossMechFieldSpec {
  const ZombossMechFieldSpec({
    required this.name,
    required this.type,
    this.defaultValue,
    this.objectFields = const [],
  });

  final String name;
  final String type;
  final dynamic defaultValue;
  final List<ZombossMechFieldSpec> objectFields;

  factory ZombossMechFieldSpec.fromJson(Map<String, dynamic> json) {
    final nested = json['fields'];
    return ZombossMechFieldSpec(
      name: json['name'] as String? ?? '',
      type: json['type'] as String? ?? 'dynamic',
      defaultValue: json['default'],
      objectFields: nested is List
          ? nested
                .whereType<Map>()
                .map(
                  (e) => ZombossMechFieldSpec.fromJson(
                    Map<String, dynamic>.from(e),
                  ),
                )
                .toList()
          : const [],
    );
  }
}

/// Catalog action entry (implementation alias + metadata).
class ZombossMechCatalogAction {
  const ZombossMechCatalogAction({
    required this.alias,
    required this.objclass,
    required this.tag,
    required this.fields,
    required this.defaultData,
  });

  final String alias;
  final String objclass;
  final String tag;
  final List<ZombossMechFieldSpec> fields;
  final Map<String, dynamic> defaultData;
}

/// Action or property group keyed by implementation alias.
class ZombossMechObjclassGroup {
  const ZombossMechObjclassGroup({
    required this.objclass,
    required this.fields,
    required this.implementations,
    this.tag = '',
  });

  final String objclass;
  final List<ZombossMechFieldSpec> fields;
  final Map<String, Map<String, dynamic>> implementations;
  final String tag;

  factory ZombossMechObjclassGroup.fromJson(Map<String, dynamic> json) {
    final implRaw = json['implementations'];
    final implementations = <String, Map<String, dynamic>>{};
    if (implRaw is Map) {
      for (final entry in implRaw.entries) {
        if (entry.value is Map) {
          implementations[entry.key] = Map<String, dynamic>.from(
            entry.value as Map,
          );
        }
      }
    }
    final fieldsRaw = json['fields'];
    return ZombossMechObjclassGroup(
      objclass: json['objclass'] as String? ?? '',
      tag: json['tag'] as String? ?? '',
      fields: fieldsRaw is List
          ? fieldsRaw
                .whereType<Map>()
                .map(
                  (e) => ZombossMechFieldSpec.fromJson(
                    Map<String, dynamic>.from(e),
                  ),
                )
                .toList()
          : const [],
      implementations: implementations,
    );
  }
}

/// Full mech group entry from [assets/resources/ZombossMechs.json].
class ZombossMechCatalogEntry {
  const ZombossMechCatalogEntry({
    required this.id,
    required this.icon,
    required this.defaultPhaseCount,
    required this.variations,
    required this.editableInstance,
    required this.editableInstancePropsName,
    required this.actions,
    required this.properties,
  });

  final String id;
  final String icon;
  final int defaultPhaseCount;
  final List<String> variations;
  final String editableInstance;
  final String editableInstancePropsName;
  final List<ZombossMechObjclassGroup> actions;
  final List<ZombossMechObjclassGroup> properties;

  bool get hasCustomInstance =>
      editableInstance.isNotEmpty &&
      editableInstance != 'none' &&
      editableInstancePropsName.isNotEmpty;

  String get propsObjclass =>
      properties.isNotEmpty ? properties.first.objclass : '';

  /// All action aliases available for this mech (for stage action pickers).
  List<String> get actionAliases {
    return catalogActions.map((a) => a.alias).toList()..sort();
  }

  /// Flattened catalog actions for this mech.
  List<ZombossMechCatalogAction> get catalogActions {
    final result = <ZombossMechCatalogAction>[];
    for (final group in actions) {
      for (final entry in group.implementations.entries) {
        result.add(
          ZombossMechCatalogAction(
            alias: entry.key,
            objclass: group.objclass,
            tag: group.tag,
            fields: group.fields,
            defaultData: _cloneMap(entry.value),
          ),
        );
      }
    }
    return result;
  }

  /// Whether battle phases in the template support [RetreatAction].
  bool get supportsRetreatInStages {
    final stages = templatePropsData()['Stages'];
    if (stages is! List) return false;
    for (final stage in stages) {
      if (stage is Map && stage.containsKey('RetreatAction')) return true;
    }
    return false;
  }

  List<ZombossMechCatalogAction> actionsByTag(String? tagFilter) {
    final all = catalogActions.where(isRegularPhaseCatalogAction);
    if (tagFilter == null || tagFilter.isEmpty) return all.toList();
    return all.where((a) => a.tag == tagFilter).toList();
  }

  List<ZombossMechCatalogAction> get retreatCatalogActions =>
      catalogActions.where(isRetreatPhaseCatalogAction).toList();

  List<ZombossMechCatalogAction> get jumpCatalogActions => catalogActions
      .where((a) => isZombossJumpActionObjclass(a.objclass))
      .toList();

  ZombossMechObjclassGroup? groupForAlias(String alias) {
    for (final group in actions) {
      if (group.implementations.containsKey(alias)) return group;
    }
    return null;
  }

  ZombossMechCatalogAction? catalogActionForAlias(String alias) {
    for (final action in catalogActions) {
      if (action.alias == alias) return action;
    }
    return null;
  }

  /// Unique objclasses used by this mech's actions (for custom action editor).
  List<ZombossMechObjclassGroup> get uniqueActionGroups {
    final seen = <String>{};
    final groups = <ZombossMechObjclassGroup>[];
    for (final group in actions) {
      if (seen.add(group.objclass)) groups.add(group);
    }
    return groups;
  }

  /// Default property-sheet objdata used when creating a level-local custom instance.
  Map<String, dynamic> templatePropsData() {
    if (properties.isEmpty) return {};
    final impls = properties.first.implementations;
    final memo = editableInstancePropsName;
    if (memo.isNotEmpty && impls.containsKey(memo)) {
      return _cloneMap(impls[memo]!);
    }
    if (impls.isNotEmpty) {
      final preferred = impls.keys.firstWhere(
        (k) =>
            !k.contains('12TH') &&
            !k.contains('Rift') &&
            !k.contains('TimeTravel') &&
            !k.contains('Vacation') &&
            !k.contains('Modern'),
        orElse: () => impls.keys.first,
      );
      return _cloneMap(impls[preferred]!);
    }
    final data = <String, dynamic>{};
    for (final field in properties.first.fields) {
      if (field.name.isEmpty || field.name.startsWith('#')) continue;
      if (field.defaultValue != null) {
        data[field.name] = _cloneValue(field.defaultValue);
      }
    }
    return data;
  }

  factory ZombossMechCatalogEntry.fromJson(Map<String, dynamic> json) {
    List<ZombossMechObjclassGroup> parseGroups(String key) {
      final raw = json[key];
      if (raw is! List) return const [];
      return raw
          .whereType<Map>()
          .map(
            (e) =>
                ZombossMechObjclassGroup.fromJson(Map<String, dynamic>.from(e)),
          )
          .toList();
    }

    final variations = json['variations'];
    return ZombossMechCatalogEntry(
      id: json['id'] as String? ?? '',
      icon: json['icon'] as String? ?? 'unknown.webp',
      defaultPhaseCount: json['defaultPhaseCount'] as int? ?? 3,
      variations: variations is List
          ? variations.map((e) => e.toString()).toList()
          : const [],
      editableInstance: json['editableInstance'] as String? ?? 'none',
      editableInstancePropsName:
          json['editableInstancePropsName'] as String? ?? '',
      actions: parseGroups('actions'),
      properties: parseGroups('Properties'),
    );
  }

  static Map<String, dynamic> _cloneMap(Map<String, dynamic> source) {
    return Map<String, dynamic>.from(jsonDecode(jsonEncode(source)) as Map);
  }

  static dynamic _cloneValue(dynamic value) {
    return jsonDecode(jsonEncode(value));
  }
}
