import 'dart:async';

import 'package:flutter/material.dart';
import 'package:c_editor/data/custom_zombie_level_utils.dart';
import 'package:c_editor/data/pvz_models.dart';
import 'package:c_editor/l10n/app_localizations.dart';
import 'package:c_editor/theme/app_theme.dart';

/// Bottom-sheet actions for switching / editing custom zombie property variants.
class CustomZombiePropertiesSheetActions extends StatelessWidget {
  const CustomZombiePropertiesSheetActions({
    super.key,
    required this.levelFile,
    required this.baseType,
    required this.currentRtid,
    required this.onRtidSelected,
    this.onEditCustomZombie,
    this.onInjectCustomZombie,
    this.onCloseSheet,
  });

  final PvzLevelFile levelFile;
  final String baseType;
  final String currentRtid;
  final ValueChanged<String> onRtidSelected;
  final FutureOr<void> Function(String rtid)? onEditCustomZombie;
  final String? Function(String baseType)? onInjectCustomZombie;
  final VoidCallback? onCloseSheet;

  bool get _available =>
      onEditCustomZombie != null || onInjectCustomZombie != null;

  bool get _isCustom => CustomZombieLevelUtils.isCustomZombieRtid(currentRtid);

  String? get _currentAlias =>
      CustomZombieLevelUtils.aliasFromRtid(currentRtid);

  void _openSwitchDialog(BuildContext context) {
    onCloseSheet?.call();
    showCustomZombiePropertiesSwitchDialog(
      context,
      levelFile: levelFile,
      baseType: baseType,
      currentRtid: currentRtid,
      onRtidSelected: onRtidSelected,
      onEditCustomZombie: onEditCustomZombie,
      onInjectCustomZombie: onInjectCustomZombie,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!_available) return const SizedBox.shrink();

    final l10n = AppLocalizations.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryYellow = isDark ? pvzYellowDark : pvzYellowLight;
    final alias = _currentAlias;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 8),
        OutlinedButton.icon(
          onPressed: () => _openSwitchDialog(context),
          style: OutlinedButton.styleFrom(
            foregroundColor: isDark
                ? pvzYellowDarkMuted
                : const Color(0xFF9A7600),
            side: BorderSide(
              color: isDark ? Colors.white : Colors.black,
              width: 1.5,
            ),
          ),
          icon: const Icon(Icons.swap_horiz),
          label: Text(l10n?.switchProperties ?? 'Switch properties'),
        ),
        if (_isCustom && onEditCustomZombie != null && alias != null) ...[
          const SizedBox(height: 8),
          FilledButton.icon(
            onPressed: () {
              onCloseSheet?.call();
              onEditCustomZombie!(currentRtid);
            },
            style: FilledButton.styleFrom(
              backgroundColor: primaryYellow,
              foregroundColor: Colors.black87,
            ),
            icon: const Icon(Icons.build),
            label: Text(l10n?.editCustomZombieAlias(alias) ?? 'Edit $alias'),
          ),
        ],
      ],
    );
  }
}

Future<void> showCustomZombiePropertiesSwitchDialog(
  BuildContext context, {
  required PvzLevelFile levelFile,
  required String baseType,
  required String currentRtid,
  required ValueChanged<String> onRtidSelected,
  FutureOr<void> Function(String rtid)? onEditCustomZombie,
  String? Function(String baseType)? onInjectCustomZombie,
}) async {
  final l10n = AppLocalizations.of(context);
  final theme = Theme.of(context);
  final isDark = theme.brightness == Brightness.dark;
  final selectedGreen = isDark ? pvzGreenDark : pvzGreenLight;
  final defaultRtid = CustomZombieLevelUtils.defaultRtid(baseType);
  final variations = CustomZombieLevelUtils.listVariations(levelFile, baseType);
  final isDefaultSelected =
      !CustomZombieLevelUtils.isCustomZombieRtid(currentRtid) ||
      currentRtid == defaultRtid;

  await showDialog<void>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: Text(l10n?.switchProperties ?? 'Switch properties'),
      content: SizedBox(
        width: double.maxFinite,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _PropertiesVariationCard(
                label: l10n?.defaultPropertiesLabel ?? 'Default',
                selected: isDefaultSelected,
                selectedColor: selectedGreen,
                onTap: () {
                  Navigator.pop(ctx);
                  onRtidSelected(defaultRtid);
                },
              ),
              for (final variation in variations)
                _PropertiesVariationCard(
                  label: variation.alias,
                  selected: variation.rtid == currentRtid,
                  selectedColor: selectedGreen,
                  onTap: () {
                    Navigator.pop(ctx);
                    onRtidSelected(variation.rtid);
                  },
                ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx),
          style: TextButton.styleFrom(foregroundColor: theme.colorScheme.error),
          child: Text(l10n?.cancel ?? 'Cancel'),
        ),
        if (onInjectCustomZombie != null)
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: selectedGreen,
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              Navigator.pop(ctx);
              final rtid = onInjectCustomZombie(baseType);
              if (rtid != null) {
                onRtidSelected(rtid);
                onEditCustomZombie?.call(rtid);
              }
            },
            child: Text(l10n?.addNewVariation ?? '+ Add new variation'),
          ),
      ],
    ),
  );
}

class _PropertiesVariationCard extends StatelessWidget {
  const _PropertiesVariationCard({
    required this.label,
    required this.selected,
    required this.selectedColor,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final Color selectedColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            color: selected
                ? selectedColor.withValues(alpha: isDark ? 0.35 : 0.18)
                : theme.colorScheme.surfaceContainerHighest,
            border: Border.all(
              color: selected
                  ? selectedColor
                  : theme.colorScheme.outline.withValues(alpha: 0.5),
              width: selected ? 2 : 1,
            ),
          ),
          child: Text(
            label,
            style: theme.textTheme.bodyLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}
