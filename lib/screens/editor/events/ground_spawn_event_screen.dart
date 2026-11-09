import 'dart:async';

import 'package:flutter/material.dart';
import 'package:c_editor/data/pvz_models.dart';
import 'package:c_editor/l10n/app_localizations.dart';
import 'package:c_editor/screens/editor/events/zombie_spawn_event_screen.dart';

/// Ground spawn event. Wraps ZombieSpawnEventScreen.
class GroundSpawnEventScreen extends StatelessWidget {
  const GroundSpawnEventScreen({
    super.key,
    required this.rtid,
    required this.levelFile,
    required this.onChanged,
    required this.onBack,
    required this.onRequestZombieSelection,
    this.onRequestPlantSelection,
    this.onEditCustomZombie,
    this.onInjectCustomZombie,
    this.onOpenReferencedEvent,
  });

  final String rtid;
  final PvzLevelFile levelFile;
  final VoidCallback onChanged;
  final VoidCallback onBack;
  final void Function(void Function(String) onSelected)
  onRequestZombieSelection;
  final void Function(void Function(String) onSelected)?
  onRequestPlantSelection;
  final FutureOr<void> Function(String rtid)? onEditCustomZombie;
  final String? Function(String alias)? onInjectCustomZombie;
  final Future<void> Function(String rtid)? onOpenReferencedEvent;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return ZombieSpawnEventScreen(
      rtid: rtid,
      levelFile: levelFile,
      onChanged: onChanged,
      onBack: onBack,
      eventSubtitle:
          l10n?.eventTitle_SpawnZombiesFromGroundSpawnerProps ??
          'GroundSpawnEvent',
      isGroundSpawner: true,
      onRequestZombieSelection: onRequestZombieSelection,
      onRequestPlantSelection: onRequestPlantSelection,
      onEditCustomZombie: onEditCustomZombie,
      onInjectCustomZombie: onInjectCustomZombie,
      onOpenReferencedEvent: onOpenReferencedEvent,
    );
  }
}
