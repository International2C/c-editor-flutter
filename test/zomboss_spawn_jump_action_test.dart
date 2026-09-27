import 'package:c_editor/data/models/zomboss_mech_catalog.dart';
import 'package:c_editor/data/repository/zomboss_mech_repository.dart';
import 'package:c_editor/data/zomboss_mech_action_utils.dart';
import 'package:c_editor/data/zomboss_mech_l10n.dart';
import 'package:c_editor/l10n/app_localizations.dart';
import 'package:c_editor/widgets/editor_components.dart';
import 'package:c_editor/widgets/zomboss_mech_action_fields.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Widget app(Widget child, {String language = 'en'}) => MaterialApp(
  locale: Locale(language),
  localizationsDelegates: AppLocalizations.localizationsDelegates,
  supportedLocales: AppLocalizations.supportedLocales,
  home: Scaffold(body: SingleChildScrollView(child: child)),
);

Widget editor(Map<String, dynamic> data, {bool editable = true}) =>
    StatefulBuilder(
      builder: (context, setState) => ZombossMechActionFieldsEditor(
        mechId: 'ZombieZombossMech_Egypt',
        objclass: 'ZombossSpawnActionDefinition',
        fields: const [
          ZombossMechFieldSpec(
            name: 'SpawnJumpAction',
            type: 'rtid',
            defaultValue: zombossSpawnJumpActionRtid,
          ),
        ],
        data: data,
        editable: editable,
        onPickJumpAction: (_) async => throw StateError(
          'SpawnJumpAction must not open the general picker',
        ),
        onChanged: () => setState(() {}),
      ),
    );

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('all summon action templates use the built-in jump reference', () async {
    await ZombossMechRepository.init();
    var checkedDefaults = 0;
    var checkedActions = 0;
    for (final mech in ZombossMechRepository.allZombossMechs) {
      final catalog = ZombossMechRepository.getCatalog(mech.id)!;
      for (final group in catalog.actions) {
        for (final field in group.fields) {
          if (field.name != 'SpawnJumpAction') continue;
          checkedDefaults++;
          expect(field.defaultValue, zombossSpawnJumpActionRtid);
          expect(
            ZombossMechActionUtils.defaultsFromFields(
              group.fields,
            )['SpawnJumpAction'],
            zombossSpawnJumpActionRtid,
          );
        }
      }
      for (final action in catalog.catalogActions) {
        final data = ZombossMechActionUtils.dataFromCatalogAction(action);
        if (!data.containsKey('SpawnJumpAction')) continue;
        checkedActions++;
        expect(
          data['SpawnJumpAction'],
          zombossSpawnJumpActionRtid,
          reason: action.alias,
        );
      }
    }
    expect(checkedDefaults, greaterThan(0));
    expect(checkedActions, greaterThan(0));
  });

  for (final entry in {
    'zh': '召唤跳跃',
    'en': 'Summon jump',
    'ru': 'Прыжок при призыве',
  }.entries) {
    testWidgets('built-in jump is localized and has no switch (${entry.key})', (
      tester,
    ) async {
      final data = <String, dynamic>{
        'SpawnJumpAction': zombossSpawnJumpActionRtid,
      };
      await tester.pumpWidget(app(editor(data), language: entry.key));
      await tester.pumpAndSettle();
      expect(find.text(entry.value), findsOneWidget);
      expect(find.byIcon(Icons.swap_horiz), findsNothing);
      final context = tester.element(
        find.byType(ZombossMechActionFieldsEditor),
      );
      expect(
        ZombossMechL10n.implementationLabel(context, '', 'ZombossSpawnJump'),
        entry.value,
      );
    });
  }

  for (final original in [
    'RTID(ZombossSpawnJump@.)',
    'RTID(CustomJump@CurrentLevel)',
    'RTID(ZombossRetreatJump@ZombieActions)',
    '',
  ]) {
    testWidgets(
      'legacy value can only switch to built-in summon jump: $original',
      (tester) async {
        final data = <String, dynamic>{'SpawnJumpAction': original};
        await tester.pumpWidget(app(editor(data)));
        expect(data['SpawnJumpAction'], original);
        await tester.tap(find.byIcon(Icons.swap_horiz));
        await tester.pumpAndSettle();
        expect(find.byType(EditorOptionTile), findsOneWidget);
        expect(find.text(zombossSpawnJumpActionRtid), findsOneWidget);
        expect(data['SpawnJumpAction'], original);
        await tester.tap(find.text('Summon jump'));
        await tester.pumpAndSettle();
        expect(data['SpawnJumpAction'], zombossSpawnJumpActionRtid);
        expect(find.byIcon(Icons.swap_horiz), findsNothing);
        expect(find.text('Summon jump'), findsOneWidget);
      },
    );
  }

  testWidgets('cancelling preserves an existing nonstandard jump', (
    tester,
  ) async {
    final data = <String, dynamic>{
      'SpawnJumpAction': 'RTID(ZombossSpawnJump@.)',
    };
    await tester.pumpWidget(app(editor(data)));
    await tester.tap(find.byIcon(Icons.swap_horiz));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
    expect(data['SpawnJumpAction'], 'RTID(ZombossSpawnJump@.)');
    expect(find.byIcon(Icons.swap_horiz), findsOneWidget);
  });

  testWidgets('read-only legacy field has no switch', (tester) async {
    final data = <String, dynamic>{
      'SpawnJumpAction': 'RTID(ZombossSpawnJump@.)',
    };
    await tester.pumpWidget(app(editor(data, editable: false)));
    expect(find.byIcon(Icons.swap_horiz), findsNothing);
  });

  testWidgets('an omitted field can explicitly select the built-in jump', (
    tester,
  ) async {
    final data = <String, dynamic>{};
    await tester.pumpWidget(app(editor(data)));
    expect(data, isNot(contains('SpawnJumpAction')));
    await tester.tap(find.byIcon(Icons.swap_horiz));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Summon jump'));
    await tester.pumpAndSettle();
    expect(data['SpawnJumpAction'], zombossSpawnJumpActionRtid);
    expect(find.byIcon(Icons.swap_horiz), findsNothing);
  });
}
