import 'package:c_editor/l10n/resource_names.dart';
import 'package:c_editor/widgets/zomboss_mech_weighted_zombie_list.dart';
import 'package:c_editor/widgets/zomboss_mech_zombie_type_list.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  setUpAll(ResourceNames.ensureLoaded);

  for (final weighted in [true, false]) {
    testWidgets('zombie-list heading leaves space before its first card '
        '(${weighted ? 'weighted' : 'simple'})', (tester) async {
      tester.view.physicalSize = const Size(320, 1000);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      const heading = 'Spawnable zombie types (ZombieTypesToSpawn)';
      final editor = weighted
          ? ZombossMechWeightedZombieListEditor(
              fieldLabel: heading,
              weightLabel: 'Zombie weight (Weight)',
              zombieIds: const ['mummy'],
              weights: const [1],
              editable: true,
              onChanged: (_, _) {},
            )
          : ZombossMechZombieTypeListEditor(
              fieldLabel: heading,
              zombieIds: const ['mummy'],
              editable: true,
              isList: true,
              onChanged: (_) {},
            );
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Padding(
              padding: const EdgeInsets.all(16),
              child: MediaQuery(
                data: const MediaQueryData(textScaler: TextScaler.linear(2)),
                child: editor,
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final headingRow = find
          .ancestor(of: find.text(heading), matching: find.byType(Row))
          .first;
      final card = find
          .byWidgetPredicate(
            (widget) =>
                widget is Material &&
                widget.borderRadius == BorderRadius.circular(8),
          )
          .first;
      expect(
        tester.getRect(card).top - tester.getRect(headingRow).bottom,
        greaterThanOrEqualTo(12),
      );
      expect(tester.takeException(), isNull);
    });
  }
}
