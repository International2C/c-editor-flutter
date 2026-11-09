import 'package:c_editor/l10n/app_localizations.dart';
import 'package:c_editor/widgets/asset_image.dart';
import 'package:c_editor/widgets/editor_components.dart';
import 'package:flutter/material.dart';

enum LevelJamLabel { none, punk, pop, rap, eightBit, metal }

class LevelJamOption {
  const LevelJamOption({
    required this.value,
    required this.label,
    required this.iconAssets,
  });

  final String? value;
  final LevelJamLabel label;
  final List<String> iconAssets;

  String localizedLabel(AppLocalizations l10n) => switch (label) {
    LevelJamLabel.none => l10n.jamNone,
    LevelJamLabel.pop => l10n.jamPop,
    LevelJamLabel.rap => l10n.jamRap,
    LevelJamLabel.metal => l10n.jamMetal,
    LevelJamLabel.punk => l10n.jamPunk,
    LevelJamLabel.eightBit => l10n.jam8Bit,
  };
}

const levelJamOptions = <LevelJamOption>[
  LevelJamOption(
    value: null,
    label: LevelJamLabel.none,
    iconAssets: ['assets/images/others/jamNone.webp'],
  ),
  LevelJamOption(
    value: 'jam_punk',
    label: LevelJamLabel.punk,
    iconAssets: ['assets/images/zombies/zombie_eighties_punk.webp'],
  ),
  LevelJamOption(
    value: 'jam_pop',
    label: LevelJamLabel.pop,
    iconAssets: ['assets/images/zombies/zombie_eighties_glitter.webp'],
  ),
  LevelJamOption(
    value: 'jam_rap',
    label: LevelJamLabel.rap,
    iconAssets: [
      'assets/images/zombies/zombie_eighties_mc.webp',
      'assets/images/zombies/zombie_eighties_breakdancer.webp',
    ],
  ),
  LevelJamOption(
    value: 'jam_8bit',
    label: LevelJamLabel.eightBit,
    iconAssets: ['assets/images/zombies/zombie_eighties_arcade.webp'],
  ),
  LevelJamOption(
    value: 'jam_metal',
    label: LevelJamLabel.metal,
    iconAssets: ['assets/images/zombies/zombie_eighties_gargantuar.webp'],
  ),
];

LevelJamOption? levelJamOptionFor(String? value) {
  for (final option in levelJamOptions) {
    if (option.value == value) return option;
  }
  return null;
}

class LevelJamPickerField extends StatelessWidget {
  const LevelJamPickerField({
    super.key,
    required this.labelText,
    required this.value,
    required this.onChanged,
    this.enabled = true,
    this.decoration,
  });

  final String labelText;
  final String? value;
  final ValueChanged<String?> onChanged;
  final bool enabled;
  final InputDecoration? decoration;

  Future<void> _showOptions(BuildContext context) async {
    if (!enabled) return;
    final l10n = AppLocalizations.of(context)!;
    final picked = await showDialog<_LevelJamSelection>(
      context: context,
      builder: (dialogContext) {
        final theme = Theme.of(dialogContext);
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: LayoutBuilder(
              builder: (context, constraints) => Center(
                child: Material(
                  key: const ValueKey('levelJamDialog'),
                  color:
                      theme.dialogTheme.backgroundColor ??
                      theme.colorScheme.surface,
                  elevation: theme.dialogTheme.elevation ?? 6,
                  shape:
                      theme.dialogTheme.shape ??
                      RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                  clipBehavior: Clip.antiAlias,
                  child: SizedBox(
                    width: constraints.maxWidth.clamp(0.0, 560.0),
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        maxHeight: (constraints.maxHeight * 0.85).clamp(
                          0.0,
                          620.0,
                        ),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Padding(
                            padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
                            child: Text(
                              l10n.selectLevelJamTitle,
                              style: theme.textTheme.headlineSmall,
                            ),
                          ),
                          Flexible(
                            child: ListView.separated(
                              shrinkWrap: true,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                              ),
                              itemCount: levelJamOptions.length,
                              separatorBuilder: (_, _) =>
                                  const Divider(height: 1),
                              itemBuilder: (context, index) {
                                final option = levelJamOptions[index];
                                final selected = option.value == value;
                                return EditorOptionTile(
                                  key: ValueKey(
                                    'levelJamOption_${option.value ?? 'none'}',
                                  ),
                                  selected: selected,
                                  contentPadding: const EdgeInsets.symmetric(
                                    vertical: 10,
                                  ),
                                  leading: _LevelJamAvatars(
                                    option: option,
                                    size: 42,
                                  ),
                                  title: Text(option.localizedLabel(l10n)),
                                  trailing: selected
                                      ? Icon(
                                          Icons.check_circle,
                                          color: theme.colorScheme.primary,
                                          size: 22,
                                        )
                                      : null,
                                  onTap: () => Navigator.pop(
                                    dialogContext,
                                    _LevelJamSelection(option.value),
                                  ),
                                );
                              },
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.fromLTRB(8, 4, 8, 8),
                            child: Align(
                              alignment: AlignmentDirectional.centerEnd,
                              child: TextButton(
                                onPressed: () => Navigator.pop(dialogContext),
                                child: Text(l10n.cancel),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
    if (picked != null && picked.value != value) onChanged(picked.value);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final selected = levelJamOptionFor(value);
    final displayLabel =
        selected?.localizedLabel(l10n) ?? value ?? l10n.jamNone;

    Widget buildPicker(InputDecoration effectiveDecoration) => Semantics(
      button: enabled,
      child: InkWell(
        key: const ValueKey('levelJamPickerField'),
        borderRadius: BorderRadius.circular(8),
        onTap: enabled ? () => _showOptions(context) : null,
        child: InputDecorator(
          isEmpty: false,
          decoration: effectiveDecoration.copyWith(enabled: enabled),
          child: Row(
            children: [
              if (selected != null) ...[
                _LevelJamAvatars(option: selected, size: 30),
                const SizedBox(width: 10),
              ],
              Expanded(
                child: Text(
                  displayLabel,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              const Icon(Icons.arrow_drop_down),
            ],
          ),
        ),
      ),
    );

    if (decoration != null) return buildPicker(decoration!);
    return EditorResponsiveInputField(
      label: labelText,
      decoration: editorInputDecoration(context),
      builder: (context, effectiveDecoration) =>
          buildPicker(effectiveDecoration),
    );
  }
}

class _LevelJamSelection {
  const _LevelJamSelection(this.value);

  final String? value;
}

class _LevelJamAvatars extends StatelessWidget {
  const _LevelJamAvatars({required this.option, required this.size});

  final LevelJamOption option;
  final double size;

  @override
  Widget build(BuildContext context) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      for (var index = 0; index < option.iconAssets.length; index++) ...[
        if (index > 0) const SizedBox(width: 4),
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            border: Border.all(
              color: Theme.of(
                context,
              ).colorScheme.outlineVariant.withValues(alpha: 0.7),
            ),
          ),
          padding: const EdgeInsets.all(1),
          child: ClipOval(
            key: ValueKey('levelJamAvatar_${option.value ?? 'none'}_$index'),
            child: AssetImageWidget(
              assetPath: option.iconAssets[index],
              width: size - 2,
              height: size - 2,
              fit: BoxFit.cover,
            ),
          ),
        ),
      ],
    ],
  );
}
