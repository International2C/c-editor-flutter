import 'package:flutter/material.dart';
import 'package:c_editor/data/repository/zombie_repository.dart';
import 'package:c_editor/l10n/app_localizations.dart';
import 'package:c_editor/l10n/resource_names.dart';
import 'package:c_editor/screens/select/zombie_selection_screen.dart';
import 'package:c_editor/widgets/asset_image.dart';
import 'package:c_editor/widgets/editor_components.dart';

const _kUnknownZombieIcon = 'assets/images/others/unknown.webp';

class ZombossMechWeightedZombieListEditor extends StatelessWidget {
  const ZombossMechWeightedZombieListEditor({
    super.key,
    required this.fieldLabel,
    required this.weightLabel,
    required this.zombieIds,
    required this.weights,
    required this.editable,
    required this.onChanged,
    this.defaultWeight = 100,
    this.headingStyle,
  });

  final String fieldLabel;
  final String weightLabel;
  final List<String> zombieIds;
  final List<int> weights;
  final bool editable;
  final void Function(List<String> zombieIds, List<int> weights) onChanged;
  final int defaultWeight;
  final TextStyle? headingStyle;

  int _weightAt(int index) {
    if (index >= 0 && index < weights.length) return weights[index];
    return defaultWeight;
  }

  Future<void> _pickZombie(BuildContext context) async {
    await Navigator.push<void>(
      context,
      MaterialPageRoute(
        builder: (ctx) => ZombieSelectionScreen(
          multiSelect: true,
          onZombieSelected: (id) {
            Navigator.pop(ctx);
            onChanged([...zombieIds, id], [...weights, defaultWeight]);
          },
          onMultiZombieSelected: (ids) {
            Navigator.pop(ctx);
            if (ids.isEmpty) return;
            onChanged(
              [...zombieIds, ...ids],
              [..._normalizedWeights, for (final _ in ids) defaultWeight],
            );
          },
          onBack: () => Navigator.pop(ctx),
        ),
      ),
    );
  }

  Future<void> _replaceZombie(BuildContext context, int index) async {
    await Navigator.push<void>(
      context,
      MaterialPageRoute(
        builder: (ctx) => ZombieSelectionScreen(
          onZombieSelected: (id) {
            Navigator.pop(ctx);
            final nextIds = List<String>.from(zombieIds);
            nextIds[index] = id;
            onChanged(nextIds, _normalizedWeights);
          },
          onBack: () => Navigator.pop(ctx),
        ),
      ),
    );
  }

  List<int> get _normalizedWeights => [
    for (var i = 0; i < zombieIds.length; i++) _weightAt(i),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                fieldLabel,
                style: headingStyle ?? theme.textTheme.titleSmall,
              ),
            ),
            if (editable)
              IconButton(
                visualDensity: VisualDensity.compact,
                tooltip: l10n?.zombossMechAddZombie ?? 'Add zombie',
                onPressed: () => _pickZombie(context),
                icon: const Icon(Icons.add_circle_outline),
              ),
          ],
        ),
        const SizedBox(height: 12),
        if (zombieIds.isEmpty)
          Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Text(
              l10n?.zombossMechNoZombiesInList ?? 'No zombies in list',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          )
        else
          for (var i = 0; i < zombieIds.length; i++)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: _WeightedZombieRow(
                zombieId: zombieIds[i],
                weight: _weightAt(i),
                weightLabel: weightLabel,
                editable: editable,
                onTap: editable ? () => _replaceZombie(context, i) : null,
                onWeightChanged: editable
                    ? (weight) {
                        final nextWeights = _normalizedWeights;
                        nextWeights[i] = weight;
                        onChanged(List<String>.from(zombieIds), nextWeights);
                      }
                    : null,
                onRemove: editable
                    ? () {
                        final nextIds = List<String>.from(zombieIds)
                          ..removeAt(i);
                        final nextWeights = _normalizedWeights..removeAt(i);
                        onChanged(nextIds, nextWeights);
                      }
                    : null,
                onDuplicate: editable
                    ? () {
                        final nextIds = List<String>.from(zombieIds)
                          ..insert(i + 1, zombieIds[i]);
                        final nextWeights = _normalizedWeights
                          ..insert(i + 1, _weightAt(i));
                        onChanged(nextIds, nextWeights);
                      }
                    : null,
              ),
            ),
      ],
    );
  }
}

class _WeightedZombieRow extends StatefulWidget {
  const _WeightedZombieRow({
    required this.zombieId,
    required this.weight,
    required this.weightLabel,
    required this.editable,
    this.onTap,
    this.onWeightChanged,
    this.onRemove,
    this.onDuplicate,
  });

  final String zombieId;
  final int weight;
  final String weightLabel;
  final bool editable;
  final VoidCallback? onTap;
  final ValueChanged<int>? onWeightChanged;
  final VoidCallback? onRemove;
  final VoidCallback? onDuplicate;

  @override
  State<_WeightedZombieRow> createState() => _WeightedZombieRowState();
}

class _WeightedZombieRowState extends State<_WeightedZombieRow> {
  late TextEditingController _controller;
  late FocusNode _focusNode;
  bool _focused = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: '${widget.weight}');
    _focusNode = FocusNode()
      ..addListener(() {
        final focused = _focusNode.hasFocus;
        if (_focused != focused) setState(() => _focused = focused);
      });
  }

  @override
  void didUpdateWidget(covariant _WeightedZombieRow oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!_focused && oldWidget.weight != widget.weight) {
      _controller.text = '${widget.weight}';
    }
  }

  @override
  void dispose() {
    _focusNode.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final repo = ZombieRepository();
    final info = repo.getZombieById(widget.zombieId);
    final nameKey = repo.getName(widget.zombieId);
    final localized = ResourceNames.lookup(context, nameKey);
    final displayName = localized != nameKey && localized.isNotEmpty
        ? localized
        : widget.zombieId;
    final iconPath = info?.iconAssetPath ?? _kUnknownZombieIcon;

    return Material(
      color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.45),
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        onTap: widget.editable ? widget.onTap : null,
        borderRadius: BorderRadius.circular(8),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final compact = constraints.maxWidth < 480;
            final summary = _buildZombieSummary(
              context,
              displayName: displayName,
              iconPath: iconPath,
              showActions: compact,
            );
            final weightField = _buildWeightField(context);
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              child: compact
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        summary,
                        const SizedBox(height: 10),
                        weightField,
                      ],
                    )
                  : Row(
                      children: [
                        Expanded(child: summary),
                        const SizedBox(width: 10),
                        SizedBox(width: 168, child: weightField),
                        if (widget.onDuplicate != null)
                          IconButton(
                            visualDensity: VisualDensity.compact,
                            icon: const Icon(Icons.copy_outlined, size: 18),
                            tooltip:
                                AppLocalizations.of(context)?.copy ?? 'Copy',
                            onPressed: widget.onDuplicate,
                          ),
                        if (widget.onRemove != null)
                          IconButton(
                            visualDensity: VisualDensity.compact,
                            icon: const Icon(Icons.delete_outline, size: 18),
                            tooltip:
                                AppLocalizations.of(context)?.delete ??
                                'Delete',
                            onPressed: widget.onRemove,
                          ),
                      ],
                    ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildZombieSummary(
    BuildContext context, {
    required String displayName,
    required String iconPath,
    required bool showActions,
  }) {
    final theme = Theme.of(context);
    return Row(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: AssetImageWidget(
            assetPath: iconPath,
            width: 48,
            height: 48,
            fit: BoxFit.contain,
            altCandidates: imageAltCandidates(iconPath),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                displayName,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 2),
              Text(
                widget.zombieId,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                  fontSize: 11,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
        if (showActions) ...[
          if (widget.onDuplicate != null)
            IconButton(
              visualDensity: VisualDensity.compact,
              icon: const Icon(Icons.copy_outlined, size: 18),
              tooltip: AppLocalizations.of(context)?.copy ?? 'Copy',
              onPressed: widget.onDuplicate,
            ),
          if (widget.onRemove != null)
            IconButton(
              visualDensity: VisualDensity.compact,
              icon: const Icon(Icons.delete_outline, size: 18),
              tooltip: AppLocalizations.of(context)?.delete ?? 'Delete',
              onPressed: widget.onRemove,
            ),
        ],
      ],
    );
  }

  Widget _buildWeightField(BuildContext context) {
    return EditorResponsiveInputField(
      label: widget.weightLabel,
      decoration: editorInputDecoration(context),
      builder: (context, decoration) => TextFormField(
        controller: _controller,
        focusNode: _focusNode,
        readOnly: !widget.editable,
        decoration: decoration,
        keyboardType: TextInputType.number,
        onChanged: widget.editable
            ? (value) {
                final parsed = int.tryParse(value);
                if (parsed != null) {
                  widget.onWeightChanged?.call(parsed);
                }
              }
            : null,
      ),
    );
  }
}
