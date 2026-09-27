import 'dart:ui' show PointerDeviceKind;

import 'package:c_editor/data/pvz_models.dart';
import 'package:c_editor/l10n/app_localizations.dart';
import 'package:c_editor/l10n/app_localizations_en.dart';
import 'package:c_editor/screens/editor/modules/moon_expert_module_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Future<PvzObject> _pumpMoonEditor(
  WidgetTester tester, {
  VoidCallback? onChanged,
}) async {
  final module = PvzObject(
    aliases: const ['MoonExpertProps'],
    objClass: 'MoonExpertProperties',
    objData: MoonExpertPropertiesData(zombieLevel: 2).toJson(),
  );
  await tester.pumpWidget(
    MaterialApp(
      locale: const Locale('en'),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: MoonExpertModuleScreen(
        rtid: 'RTID(MoonExpertProps@CurrentLevel)',
        levelFile: PvzLevelFile(objects: [module]),
        onChanged: onChanged ?? () {},
        onBack: () {},
      ),
    ),
  );
  await tester.pumpAndSettle();
  return module;
}

void main() {
  testWidgets('zombie level keeps long-press help without a duplicate icon', (
    tester,
  ) async {
    var changes = 0;
    final module = await _pumpMoonEditor(tester, onChanged: () => changes++);
    final l10n = AppLocalizationsEn();
    final fieldLabel = find.text(l10n.moonExpertZombieLevel);
    final fieldTooltip = find.byWidgetPredicate(
      (widget) =>
          widget is Tooltip &&
          widget.message == l10n.moonExpertZombieLevelTooltip,
    );

    expect(fieldLabel, findsOneWidget);
    expect(fieldTooltip, findsOneWidget);
    expect(
      find.descendant(
        of: fieldTooltip,
        matching: find.byIcon(Icons.help_outline),
      ),
      findsNothing,
    );
    // The module-level help entry is still the only question-mark icon.
    expect(find.byIcon(Icons.help_outline), findsOneWidget);

    await tester.longPress(fieldLabel);
    await tester.pumpAndSettle();
    expect(find.text(l10n.moonExpertZombieLevelTooltip), findsOneWidget);

    final field = find.byKey(const ValueKey('moonExpertZombieLevel'));
    final dropdown = find.descendant(
      of: field,
      matching: find.byType(DropdownButton<int>),
    );
    expect(
      tester.widget<DropdownButton<int>>(dropdown).items!.map((e) => e.value),
      List.generate(11, (i) => i),
    );
    await tester.tap(field);
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('7').last);
    await tester.pumpAndSettle();
    await tester.tap(find.text('7').last);
    await tester.pumpAndSettle();
    expect(module.objData['ZombieLevel'], 7);
    expect(changes, 1);
    expect(tester.takeException(), isNull);
  });

  testWidgets('zombie level keeps hover help and the full help page', (
    tester,
  ) async {
    await _pumpMoonEditor(tester);
    final l10n = AppLocalizationsEn();
    final mouse = await tester.createGesture(kind: PointerDeviceKind.mouse);
    await mouse.addPointer(location: Offset.zero);
    addTearDown(mouse.removePointer);
    await mouse.moveTo(tester.getCenter(find.text(l10n.moonExpertZombieLevel)));
    await tester.pump(const Duration(seconds: 1));
    await tester.pumpAndSettle();
    expect(find.text(l10n.moonExpertZombieLevelTooltip), findsOneWidget);

    await mouse.moveTo(Offset.zero);
    await tester.pump(const Duration(seconds: 2));
    await tester.tap(
      find.descendant(
        of: find.byType(AppBar),
        matching: find.byIcon(Icons.help_outline),
      ),
    );
    await tester.pumpAndSettle();

    final dialog = find.byType(AlertDialog);
    expect(dialog, findsOneWidget);
    expect(
      find.descendant(
        of: dialog,
        matching: find.text(l10n.moonExpertHelpOverview),
      ),
      findsOneWidget,
    );
    expect(
      find.descendant(
        of: dialog,
        matching: find.textContaining(l10n.moonExpertHelpTitle),
      ),
      findsOneWidget,
    );
    expect(tester.takeException(), isNull);
  });
}
