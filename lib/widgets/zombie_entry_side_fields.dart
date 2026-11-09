import 'package:c_editor/data/pvz_models/ZombieSpawnData.dart';
import 'package:c_editor/l10n/app_localizations.dart';
import 'package:flutter/material.dart';

/// Shared controls for the common spawn instruction's three entry-side values.
class ZombieEntrySideFields extends StatefulWidget {
  const ZombieEntrySideFields({
    super.key,
    required this.direction,
    required this.onChanged,
  });

  final String? direction;
  final ValueChanged<String?> onChanged;

  @override
  State<ZombieEntrySideFields> createState() => _ZombieEntrySideFieldsState();
}

class _ZombieEntrySideFieldsState extends State<ZombieEntrySideFields> {
  String? _fixedDirection;

  @override
  void initState() {
    super.initState();
    _fixedDirection = widget.direction == 'random' ? null : widget.direction;
  }

  @override
  void didUpdateWidget(covariant ZombieEntrySideFields oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.direction != 'random') _fixedDirection = widget.direction;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final random = widget.direction == 'random';
    final fromLeft = ZombieSpawnData.entersFromLeft(
      random ? _fixedDirection : widget.direction,
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.zombieEntrySideLabel,
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        SwitchListTile(
          key: const ValueKey('zombieRandomEntrySide'),
          title: Text(l10n.zombieRandomSide),
          subtitle: Text(l10n.zombieRandomSideDescription),
          value: random,
          onChanged: (enabled) {
            if (enabled) _fixedDirection = widget.direction;
            widget.onChanged(enabled ? 'random' : _fixedDirection);
          },
        ),
        SwitchListTile(
          key: const ValueKey('zombieLeftEntrySide'),
          title: Text(l10n.zombieFromLeft),
          subtitle: !random && !fromLeft ? Text(l10n.zombieFromRight) : null,
          value: fromLeft,
          onChanged: random
              ? null
              : (enabled) => widget.onChanged(
                  ZombieSpawnData.directionForEntrySide(enabled),
                ),
        ),
      ],
    );
  }
}
