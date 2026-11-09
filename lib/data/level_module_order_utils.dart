import 'package:collection/collection.dart';
import 'package:c_editor/data/custom_stage_level_utils.dart';
import 'package:c_editor/data/pvz_models.dart';
import 'package:c_editor/data/registry/module_registry.dart';
import 'package:c_editor/data/repository/reference_repository.dart';
import 'package:c_editor/data/rtid_parser.dart';

/// Helpers for reordering entries in [LevelDefinitionData.modules] and syncing
/// `@CurrentLevel` module objects in [PvzLevelFile.objects].
abstract final class LevelModuleOrderUtils {
  static String? resolveModuleObjClass(
    String rtid,
    Map<String, PvzObject> objectMap,
  ) {
    final info = RtidParser.parse(rtid);
    if (info == null) return null;
    if (info.source == CustomStageLevelUtils.currentLevel) {
      return objectMap[info.alias]?.objClass;
    }
    return ReferenceRepository.instance.getObjClass(info.alias);
  }

  static bool isCoreModuleRtid(
    String rtid,
    Map<String, PvzObject> objectMap,
  ) {
    final objClass = resolveModuleObjClass(rtid, objectMap);
    if (objClass == null) return false;
    return ModuleRegistry.getMetadata(objClass).isCore;
  }

  static List<int> moduleSectionIndices({
    required List<String> modules,
    required Map<String, PvzObject> objectMap,
    required bool isCoreSection,
  }) {
    final indices = <int>[];
    for (var i = 0; i < modules.length; i++) {
      if (isCoreModuleRtid(modules[i], objectMap) == isCoreSection) {
        indices.add(i);
      }
    }
    return indices;
  }

  /// [newIndex] is the final index within the section, as in onReorderItem.
  static void reorderModuleSection({
    required LevelDefinitionData levelDef,
    required PvzLevelFile levelFile,
    required Map<String, PvzObject> objectMap,
    required bool isCoreSection,
    required int oldIndex,
    required int newIndex,
  }) {
    final modules = levelDef.modules;
    final sectionIndices = moduleSectionIndices(
      modules: modules,
      objectMap: objectMap,
      isCoreSection: isCoreSection,
    );
    if (oldIndex < 0 ||
        oldIndex >= sectionIndices.length ||
        newIndex < 0 ||
        newIndex >= sectionIndices.length ||
        oldIndex == newIndex) {
      return;
    }

    final fromGlobal = sectionIndices[oldIndex];
    final rtid = modules.removeAt(fromGlobal);

    final remainingSectionIndices = moduleSectionIndices(
      modules: modules,
      objectMap: objectMap,
      isCoreSection: isCoreSection,
    );
    final insertAt = newIndex >= remainingSectionIndices.length
        ? (remainingSectionIndices.isEmpty
              ? modules.length
              : remainingSectionIndices.last + 1)
        : remainingSectionIndices[newIndex];

    modules.insert(insertAt, rtid);
    syncCurrentLevelModuleObjectsOrder(
      levelDef: levelDef,
      levelFile: levelFile,
    );
  }

  static void syncCurrentLevelModuleObjectsOrder({
    required LevelDefinitionData levelDef,
    required PvzLevelFile levelFile,
  }) {
    final objects = levelFile.objects;
    final moduleSlots = <int>[];

    for (var i = 0; i < objects.length; i++) {
      final alias = objects[i].aliases?.firstOrNull;
      if (alias == null) continue;
      for (final rtid in levelDef.modules) {
        final info = RtidParser.parse(rtid);
        if (info?.source == CustomStageLevelUtils.currentLevel &&
            info!.alias == alias) {
          moduleSlots.add(i);
          break;
        }
      }
    }

    if (moduleSlots.isEmpty) return;
    moduleSlots.sort();

    final orderedObjects = <PvzObject>[];
    for (final rtid in levelDef.modules) {
      final info = RtidParser.parse(rtid);
      if (info?.source != CustomStageLevelUtils.currentLevel) continue;
      final idx = objects.indexWhere(
        (o) => o.aliases?.contains(info!.alias) == true,
      );
      if (idx >= 0) orderedObjects.add(objects[idx]);
    }

    for (var i = 0; i < orderedObjects.length && i < moduleSlots.length; i++) {
      objects[moduleSlots[i]] = orderedObjects[i];
    }
  }
}
