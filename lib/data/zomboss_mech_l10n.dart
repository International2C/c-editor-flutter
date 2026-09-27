import 'package:flutter/widgets.dart';
import 'package:c_editor/data/models/zomboss_mech_catalog.dart';
import 'package:c_editor/data/pvz_models/PvzLevelFile.dart';
import 'package:c_editor/data/rtid_parser.dart';
import 'package:c_editor/data/zomboss_mech_action_utils.dart';
import 'package:c_editor/l10n/app_localizations.dart';
import 'package:c_editor/l10n/resource_names.dart';

/// Localization keys for [assets/l10n/resource_*.json] zomboss mech editor strings.
abstract class ZombossMechL10n {
  ZombossMechL10n._();

  static String variationKey(String mechId, String variation) =>
      '${mechId}_variation_$variation';

  static String actionKey(String mechId, String objclass) =>
      '${mechId}_action_$objclass';

  static String genericActionKey(String objclass) =>
      'zombossMech_action_$objclass';

  static String actionImplementationKey(String mechId, String alias) =>
      '${mechId}_action_impl_$alias';

  static String fieldKey(String mechId, String objclass, String fieldName) =>
      '${mechId}_action_${objclass}_field_$fieldName';

  static String genericFieldKey(String objclass, String fieldName) =>
      'zombossMech_action_${objclass}_field_$fieldName';

  static String? _lookup(BuildContext context, String key, String fallback) {
    final localized = ResourceNames.lookup(context, key);
    return localized != key ? localized : fallback;
  }

  static String variationLabel(
    BuildContext context,
    String mechId,
    String variation, {
    String? fallback,
  }) {
    final fb = fallback ?? variation;
    return _lookup(context, variationKey(mechId, variation), fb) ?? fb;
  }

  static String actionLabel(
    BuildContext context,
    String mechId,
    String objclass, {
    String? fallback,
  }) {
    final fb = fallback ?? objclass;
    final localized = _lookup(context, actionKey(mechId, objclass), fb);
    if (localized != null && localized != fb) return localized;
    return _lookup(context, genericActionKey(objclass), fb) ?? fb;
  }

  /// Display label for objclass fields: localized class name plus raw objclass.
  static String objclassLabel(BuildContext context, String objclass) {
    final key = genericActionKey(objclass);
    final localized = ResourceNames.lookup(context, key);
    if (localized == key || localized.isEmpty || localized == objclass) {
      return objclass;
    }
    return '$localized ($objclass)';
  }

  /// Per-implementation alias label (picker rows). Falls back to [alias].
  static String implementationLabel(
    BuildContext context,
    String mechId,
    String alias, {
    String? fallback,
  }) {
    if (alias == 'ZombossSpawnJump') {
      return AppLocalizations.of(context)?.zombossMechSummonJump ??
          'Summon jump';
    }
    final fb = fallback ?? alias;
    final implKey = actionImplementationKey(mechId, alias);
    final localized = ResourceNames.lookup(context, implKey);
    if (localized != implKey) return localized;
    return fb;
  }

  /// Per-implementation picker label with the raw action alias kept visible.
  static String implementationDisplayLabel(
    BuildContext context,
    String mechId,
    String alias, {
    String? fallback,
  }) {
    final localized = implementationLabel(
      context,
      mechId,
      alias,
      fallback: fallback,
    );
    if (localized.isEmpty || localized == alias) return alias;
    return '$localized ($alias)';
  }

  static String fieldLabel(
    BuildContext context,
    String mechId,
    String objclass,
    String fieldName, {
    String? fallback,
  }) {
    final fb = fallback ?? fieldName;
    final localized = _lookup(
      context,
      fieldKey(mechId, objclass, fieldName),
      fb,
    );
    if (localized != null && localized != fb) return localized;
    return _lookup(context, genericFieldKey(objclass, fieldName), fb) ?? fb;
  }

  /// Category chip / tag label from ARB (movement, attack, spawn, …).
  static String tagLabel(BuildContext context, String tag) {
    final l10n = AppLocalizations.of(context);
    return switch (tag) {
      'movement' => l10n?.zombossMechActionCategoryMovement ?? 'Movement',
      'attack' => l10n?.zombossMechActionCategoryAttack ?? 'Attack',
      'spawn' => l10n?.zombossMechActionCategorySpawn ?? 'Summon',
      'special' => l10n?.zombossMechActionCategorySpecial ?? 'Special',
      'retreat' => l10n?.zombossMechActionCategoryRetreat ?? 'Retreat',
      _ => tag,
    };
  }

  /// RTID label for phase lists and action picker.
  /// [CurrentLevel] actions stay ``alias@CurrentLevel``; catalog uses resource JSON.
  static String actionRtidLabel(
    BuildContext context,
    String mechId,
    String rtid, {
    String? objclass,
    String? implementationAlias,
  }) {
    final info = RtidParser.parse(rtid);
    if (info == null) return rtid;
    if (info.source == 'CurrentLevel') {
      return '${info.alias}@${info.source}';
    }
    if (implementationAlias != null && implementationAlias.isNotEmpty) {
      return implementationLabel(
        context,
        mechId,
        implementationAlias,
        fallback: info.alias,
      );
    }
    if (objclass != null && objclass.isNotEmpty) {
      return actionLabel(
        context,
        mechId,
        objclass,
        fallback: implementationAlias ?? info.alias,
      );
    }
    return '${info.alias}@${info.source}';
  }

  /// Phase / retreat list label: always ``alias@source`` (catalog and custom).
  static String labelForStageRtid({
    required BuildContext context,
    required String mechId,
    required ZombossMechCatalogEntry catalog,
    required PvzLevelFile levelFile,
    required String rtid,
  }) {
    return ZombossMechActionUtils.displayLabel(rtid);
  }
}
