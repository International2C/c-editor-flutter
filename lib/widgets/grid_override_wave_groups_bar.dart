import 'package:flutter/material.dart';

/// Inner padding for module editor section cards (no extra horizontal inset).
const EdgeInsets kGridOverrideModuleSectionPadding = EdgeInsets.symmetric(
  vertical: 16,
);

/// Minimum chip height, also used by the add (+) control.
const double kGridOverrideGroupChipHeight = 44;

/// Wave-group selector row used by Armrack / EnergyGrid module editors.
class GridOverrideWaveGroupsBar extends StatelessWidget {
  const GridOverrideWaveGroupsBar({
    super.key,
    required this.itemCount,
    required this.selectedIndex,
    required this.onSelected,
    required this.onDeleteAt,
    required this.onAdd,
    required this.groupLabel,
  });

  final int itemCount;
  final int selectedIndex;
  final ValueChanged<int> onSelected;
  final ValueChanged<int> onDeleteAt;
  final VoidCallback onAdd;
  final String Function(int index) groupLabel;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        for (var idx = 0; idx < itemCount; idx++)
          _GroupChip(
            label: groupLabel(idx),
            isSelected: selectedIndex == idx,
            onTap: () => onSelected(idx),
            onDelete: () => onDeleteAt(idx),
            theme: theme,
          ),
        _AddGroupChip(onTap: onAdd, theme: theme),
      ],
    );
  }
}

class _GroupChip extends StatelessWidget {
  const _GroupChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
    required this.onDelete,
    required this.theme,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final VoidCallback onDelete;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(
        minHeight: kGridOverrideGroupChipHeight,
      ),
      child: Material(
        color: isSelected
            ? theme.colorScheme.primaryContainer
            : theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(8),
          child: Container(
            constraints: const BoxConstraints(
              minHeight: kGridOverrideGroupChipHeight,
            ),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: isSelected
                    ? theme.colorScheme.primary
                    : Colors.transparent,
                width: 2,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Flexible(
                  child: Text(
                    label,
                    style: theme.textTheme.labelLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline, size: 18),
                  onPressed: onDelete,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(
                    minWidth: 28,
                    minHeight: 28,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _AddGroupChip extends StatelessWidget {
  const _AddGroupChip({required this.onTap, required this.theme});

  final VoidCallback onTap;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      key: const ValueKey('addGridOverrideWaveGroup'),
      height: kGridOverrideGroupChipHeight,
      width: kGridOverrideGroupChipHeight,
      child: Material(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(8),
          child: const Center(child: Icon(Icons.add, size: 24)),
        ),
      ),
    );
  }
}
