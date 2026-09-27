import 'package:c_editor/data/models/zomboss_mech_catalog.dart';
import 'package:c_editor/data/zomboss_mech_action_utils.dart';
import 'package:c_editor/l10n/app_localizations.dart';
import 'package:c_editor/widgets/separated_option_picker_field.dart';
import 'package:c_editor/widgets/portal_type_selector.dart';
import 'package:c_editor/widgets/zomboss_mech_action_fields.dart';
import 'package:c_editor/widgets/zomboss_mech_editor_widgets.dart';
import 'package:c_editor/widgets/zomboss_mech_weighted_zombie_list.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _app(Widget child) {
  return MaterialApp(
    locale: const Locale('en'),
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    home: Scaffold(body: SingleChildScrollView(child: child)),
  );
}

void main() {
  test('time fields use decimal input without treating SpawnTimes as time', () {
    const duration = ZombossMechFieldSpec(name: 'TossDuration', type: 'int');
    const count = ZombossMechFieldSpec(name: 'SpawnTimes', type: 'int');

    expect(ZombossMechActionUtils.usesDecimalInput(duration), isTrue);
    expect(ZombossMechActionUtils.usesSecondsUnit(duration), isTrue);
    expect(ZombossMechActionUtils.usesDecimalInput(count), isFalse);
    expect(ZombossMechActionUtils.usesSecondsUnit(count), isFalse);
  });

  testWidgets('object list cards show stable group numbers', (tester) async {
    final data = <String, dynamic>{
      'ZombieHordes': [
        {'Name': 'first'},
        {'Name': 'second'},
      ],
    };
    await tester.pumpWidget(
      _app(
        ZombossMechActionFieldsEditor(
          mechId: '',
          objclass: '',
          fields: const [
            ZombossMechFieldSpec(
              name: 'ZombieHordes',
              type: 'List<object>',
              objectFields: [
                ZombossMechFieldSpec(name: 'Name', type: 'string'),
              ],
            ),
          ],
          data: data,
          onChanged: () {},
        ),
      ),
    );

    expect(find.text('#1'), findsOneWidget);
    expect(find.text('#2'), findsOneWidget);
  });

  testWidgets('duration fields accept decimals and show seconds', (
    tester,
  ) async {
    final data = <String, dynamic>{'TossDuration': 2};
    await tester.pumpWidget(
      _app(
        ZombossMechActionFieldsEditor(
          mechId: '',
          objclass: '',
          fields: const [
            ZombossMechFieldSpec(name: 'TossDuration', type: 'int'),
          ],
          data: data,
          onChanged: () {},
        ),
      ),
    );

    expect(find.textContaining('unit: seconds'), findsOneWidget);
    await tester.enterText(find.byType(TextFormField), '2.5');
    expect(data['TossDuration'], 2.5);
  });

  testWidgets('Zomboss portal actions use the boss-only portal catalog', (
    tester,
  ) async {
    final data = <String, dynamic>{'PortalType': 'egypt'};
    await tester.pumpWidget(
      _app(
        ZombossMechActionFieldsEditor(
          mechId: 'ZombieZombossMech_Egypt',
          objclass: 'ZombossSpawnPortalActionDefinition',
          fields: const [
            ZombossMechFieldSpec(
              name: 'PortalType',
              type: 'string',
              defaultValue: 'egypt',
            ),
          ],
          data: data,
          onChanged: () {},
        ),
      ),
    );

    final field = tester.widget<PortalTypeSingleSelectField>(
      find.byType(PortalTypeSingleSelectField),
    );
    expect(field.catalog, PortalTypeCatalog.zomboss);
  });

  testWidgets('option picker uses separated rows on narrow screens', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(360, 640);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      _app(
        SeparatedOptionPickerField<String>(
          labelText: 'Base Action',
          value: 'one',
          items: const [
            SeparatedOptionPickerItem(value: 'one', label: 'First phase'),
            SeparatedOptionPickerItem(value: 'two', label: 'Second phase'),
          ],
          onChanged: (_) {},
        ),
      ),
    );

    await tester.tap(find.text('First phase'));
    await tester.pumpAndSettle();
    expect(find.byType(Divider), findsAtLeastNWidgets(2));
    expect(find.text('Second phase'), findsOneWidget);
    final title = tester
        .widgetList<Text>(find.text('Base Action'))
        .firstWhere((text) => text.textAlign == TextAlign.center);
    expect(title.style?.fontWeight, FontWeight.bold);
  });

  testWidgets('jump action fields use action rows instead of text inputs', (
    tester,
  ) async {
    final data = <String, dynamic>{
      'FireJumpAction': 'RTID(ZombossRetreatJump@ZombieActions)',
      'BoneProjectileType': 'RTID(SomeBone@ZombieActions)',
    };
    var picked = false;
    await tester.pumpWidget(
      _app(
        ZombossMechActionFieldsEditor(
          mechId: 'ZombieZombossMech_Egypt',
          objclass: 'ZombossDropZombieActionDefinition',
          fields: const [
            ZombossMechFieldSpec(name: 'FireJumpAction', type: 'rtid'),
            ZombossMechFieldSpec(name: 'BoneProjectileType', type: 'rtid'),
          ],
          data: data,
          onPickJumpAction: (current) async {
            picked = true;
            expect(current, 'RTID(ZombossRetreatJump@ZombieActions)');
            return 'RTID(ZombossSteamJump@ZombieActions)';
          },
          onChanged: () {},
        ),
      ),
    );

    expect(find.byType(ZombossMechActionRow), findsOneWidget);
    expect(find.text('ZombossRetreatJump@ZombieActions'), findsOneWidget);
    expect(find.byType(TextFormField), findsOneWidget);
    expect(find.textContaining('BoneProjectileType'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.swap_horiz));
    await tester.pumpAndSettle();
    expect(picked, isTrue);
    expect(data['FireJumpAction'], 'RTID(ZombossSteamJump@ZombieActions)');
  });

  testWidgets('long zombie weight labels move above the input', (tester) async {
    const weightLabel =
        'Zombie weights (ZombieWeightsWithAnEspeciallyLongLocalizedName)';
    await tester.pumpWidget(
      _app(
        ZombossMechWeightedZombieListEditor(
          fieldLabel: 'Zombie types (ZombieNames)',
          weightLabel: weightLabel,
          zombieIds: const ['bobsled_punk'],
          weights: const [100],
          editable: true,
          onChanged: (_, _) {},
        ),
      ),
    );
    await tester.pump();

    final field = tester.widget<TextField>(find.byType(TextField));
    expect(field.decoration?.labelText, isNull);
    expect(find.text(weightLabel), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
