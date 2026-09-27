import 'package:flutter/material.dart';

import 'package:c_editor/widgets/editor_components.dart';
import 'package:c_editor/widgets/zombie_lane_drag_widgets.dart';

const double zombieLaneCardSize = 56;

Widget buildZombieLaneCard({
  required ZombieLaneIconData item,
  required VoidCallback onTap,
}) {
  return ZombieIconCard(
    iconPath: item.iconPath,
    levelDisplay: item.levelDisplay,
    isElite: item.isElite,
    isCustom: item.isCustom,
    isMissingCustomZombie: item.isMissingCustomZombie,
    size: zombieLaneCardSize,
    onTap: onTap,
  );
}

Widget buildZombieLaneDragFeedback(ZombieLaneIconData item) {
  return Material(
    color: Colors.transparent,
    elevation: 8,
    shadowColor: Colors.black45,
    borderRadius: BorderRadius.circular(8),
    child: Transform.scale(
      scale: 1.05,
      child: buildZombieLaneCard(
        item: item,
        onTap: () {},
      ),
    ),
  );
}
