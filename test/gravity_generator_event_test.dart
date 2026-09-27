import 'dart:convert';
import 'dart:io';

import 'package:c_editor/data/level_parser.dart';
import 'package:c_editor/data/pvz_models.dart';
import 'package:c_editor/data/registry/event_registry.dart';
import 'package:c_editor/data/registry/object_order_registry.dart';
import 'package:c_editor/data/repository/plant_repository.dart';
import 'package:c_editor/data/repository/zombie_repository.dart';
import 'package:c_editor/data/zombie_discovery.dart';
import 'package:c_editor/l10n/app_localizations.dart';
import 'package:c_editor/l10n/resource_names.dart';
import 'package:c_editor/screens/editor/events/gravity_generator_event_screen.dart';
import 'package:c_editor/screens/select/event_selection_screen.dart';
import 'package:c_editor/screens/select/plant_selection_screen.dart';
import 'package:c_editor/screens/select/zombie_selection_screen.dart';
import 'package:c_editor/widgets/gravity_range_preview.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _class = 'GravityGeneratorWaveActionProps';
List<Map<String, dynamic>> _fixtures() =>
    (jsonDecode(
              File(
                'test/fixtures/gravity_generator_events.json',
              ).readAsStringSync(),
            )
            as List)
        .cast<Map<String, dynamic>>();

PvzObject _event([int fixture = 0]) =>
    PvzObject.fromJson(_fixtures()[fixture]['event'] as Map<String, dynamic>);

Widget _app(
  PvzLevelFile level, {
  String locale = 'en',
  double scale = 1,
  VoidCallback? onChanged,
}) => MaterialApp(
  locale: Locale(locale),
  localizationsDelegates: AppLocalizations.localizationsDelegates,
  supportedLocales: AppLocalizations.supportedLocales,
  builder: (context, child) => MediaQuery(
    data: MediaQuery.of(context).copyWith(textScaler: TextScaler.linear(scale)),
    child: child!,
  ),
  home: GravityGeneratorEventScreen(
    rtid:
        'RTID(${level.objects.firstOrNull?.aliases?.first ?? 'Gravity'}@CurrentLevel)',
    levelFile: level,
    onChanged: onChanged ?? () {},
    onBack: () {},
  ),
);

GravityRangePainter _painter(WidgetTester tester) =>
    tester
            .widget<CustomPaint>(
              find.byKey(const ValueKey('gravityRangeCanvas')),
            )
            .painter!
        as GravityRangePainter;

Future<void> _tap(WidgetTester tester, String key) async {
  final finder = find.byKey(ValueKey(key));
  await tester.ensureVisible(finder);
  await tester.pumpAndSettle();
  await tester.tap(finder);
  await tester.pumpAndSettle();
}

Future<void> _enter(WidgetTester tester, String key, String value) async {
  final finder = find.byKey(ValueKey('gravity-$key'));
  await tester.ensureVisible(finder);
  await tester.enterText(finder, value);
  tester.testTextInput.hide();
  await tester.pumpAndSettle();
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(() async {
    SharedPreferences.setMockInitialValues({});
    await Future.wait([
      ResourceNames.ensureLoaded(),
      PlantRepository().init(),
      ZombieRepository().init(),
    ]);
  });

  for (final fixture in _fixtures()) {
    final json = fixture['event'] as Map<String, dynamic>;
    test(
      '${fixture['level']} ${(json['aliases'] as List).single} imports and exports unchanged',
      () {
        final event = PvzObject.fromJson(json);
        final data = GravityGeneratorWaveActionPropsData.fromJson(
          event.objData as Map<String, dynamic>,
        );
        expect(data.toJson(), json['objdata']);
        event.objData = data.toJson();
        expect(event.toJson(), json);
      },
    );
  }

  test('registry puts gravity after rockets in environmental effects', () {
    final events = EventRegistry.getAll();
    final rocket = events.indexWhere(
      (m) => m.defaultObjClass == 'SpawnRocketLandingWaveActionProps',
    );
    final meta = events[rocket + 1];
    expect(meta.defaultObjClass, _class);
    expect(meta.category, EventCategory.environmental);
    expect(
      ObjectOrderRegistry.getPriority(_class),
      ObjectOrderRegistry.getPriority('SpawnRocketLandingWaveActionProps') + 1,
    );
    final data =
        meta.initialDataFactory() as GravityGeneratorWaveActionPropsData;
    expect(data.toJson()['WarningMessage'], '');
    expect(data.targetRestriction, isEmpty);
    expect(data.gravityLevel, 'anti');
  });

  test(
    'range offsets are relative to zero-based targets, not one-based columns',
    () {
      final plant = GravityGeneratorWaveActionPropsData.fromJson(
        _event().objData,
      );
      expect(plant.affectsCell(-1, 0), isTrue);
      expect(plant.affectsCell(0, 0), isTrue);
      expect(plant.affectsCell(1, 0), isTrue);
      expect(plant.affectsCell(2, 0), isFalse);
      final grid = GravityGeneratorWaveActionPropsData.fromJson(
        _event(1).objData,
      );
      expect(grid.affectsCell(6, 2), isTrue);
      expect(grid.affectsCell(8, 2), isTrue);
      expect(grid.affectsCell(5, 2), isFalse);
      expect(grid.affectsCell(6, 3), isFalse);
      grid.range.mX = -1;
      expect(grid.affectsCell(5, 2), isTrue);
      expect(grid.affectsCell(8, 2), isFalse);
    },
  );

  test('excluded targets do not become zombies in the level overview', () {
    final object = _event(5);
    final level = PvzLevelFile(
      objects: [
        PvzObject(
          objClass: 'LevelDefinition',
          objData: LevelDefinitionData().toJson(),
        ),
        PvzObject(
          aliases: ['WaveManager'],
          objClass: 'WaveManagerProperties',
          objData: {
            'Waves': [
              ['RTID(${object.aliases!.first}@CurrentLevel)'],
            ],
          },
        ),
        object,
      ],
    );
    final parsed = LevelParser.parseLevel(level);
    expect(ZombieDiscovery.discoverEvents(parsed), contains(_class));
    expect(ZombieDiscovery.discoverZombies(level, parsed), isEmpty);
  });

  test('unrecognized event fields and imported warning text are retained', () {
    final json = Map<String, dynamic>.from(_event().objData as Map)
      ..['WarningMessage'] = 'existing message'
      ..['FutureParameter'] = 7;
    final data = GravityGeneratorWaveActionPropsData.fromJson(json);
    data.parameters['Duration'] = 10;
    expect(data.toJson(), {...json, 'Duration': 10});
  });

  test(
    'guide-style full-lawn range includes the starting tile and respects pixel distances',
    () {
      final data = GravityGeneratorWaveActionPropsData.fromJson({
        'GravityLevel': 'anti',
        'TargetType': 'grid',
        'Range': {'mX': 0, 'mY': 0, 'mWidth': 9, 'mHeight': 5},
        'TargetGrid': {'mX': 0, 'mY': 0},
        'ZombieForwardDistance': 64,
        'Duration': 12,
        'TargetRestriction': ['tristerixaphyllus', 'moon_walker'],
      });
      expect(data.affectsCell(0, 0), isTrue);
      expect(data.affectsCell(8, 4), isTrue);
      expect(data.affectsCell(9, 4), isFalse);
      expect(data.affectsCell(8, 5), isFalse);
      expect(data.toJson()['ZombieForwardDistance'], 64);
      expect(data.parameter('HeavyPlantSinkDuration'), 0.5);
      expect(data.toJson().containsKey('HeavyPlantSinkDuration'), isFalse);
      data.gravityLevel = 'heavy';
      expect(data.toJson().containsKey('HeavyPlantSinkDuration'), isFalse);
      data.parameters['HeavyPlantSinkDuration'] = 1.2;
      expect(data.toJson()['HeavyPlantSinkDuration'], 1.2);
      expect(data.toJson()['TargetRestriction'], [
        'tristerixaphyllus',
        'moon_walker',
      ]);
    },
  );

  testWidgets(
    'mode-specific action fields preserve hidden values while switching',
    (tester) async {
      final object = _event();
      (object.objData as Map).remove('HeavyPlantSinkDuration');
      await tester.pumpWidget(_app(PvzLevelFile(objects: [object])));
      await tester.pumpAndSettle();
      await _tap(tester, 'gravity-advanced-settings');
      expect(
        find.byKey(const ValueKey('gravity-HeavyPlantSinkDuration')),
        findsNothing,
      );
      await _enter(tester, 'ZombieForwardDistance', '128');
      await _enter(tester, 'PlantExitDelay', '7.5');
      await _tap(tester, 'gravity-level-heavy');
      expect(
        find.byKey(const ValueKey('gravity-PlantExitDelay')),
        findsNothing,
      );
      expect(
        find.byKey(const ValueKey('gravity-ZombieForwardDistance')),
        findsNothing,
      );
      expect(
        find.byKey(const ValueKey('gravity-HeavyPlantSinkDuration')),
        findsOneWidget,
      );
      expect(
        find.byKey(const ValueKey('gravity-DeployDuration')),
        findsOneWidget,
      );
      expect(object.objData.containsKey('HeavyPlantSinkDuration'), isFalse);
      expect(object.objData['ZombieForwardDistance'], 128);
      await _enter(tester, 'HeavyPlantSinkDuration', '1.2');
      await _tap(tester, 'gravity-level-anti');
      expect(
        find.byKey(const ValueKey('gravity-HeavyPlantSinkDuration')),
        findsNothing,
      );
      expect(
        tester
            .widget<TextField>(
              find.byKey(const ValueKey('gravity-ZombieForwardDistance')),
            )
            .controller!
            .text,
        '128',
      );
      expect(
        tester
            .widget<TextField>(
              find.byKey(const ValueKey('gravity-PlantExitDelay')),
            )
            .controller!
            .text,
        '7.5',
      );
      expect(object.objData['HeavyPlantSinkDuration'], 1.2);
      expect(object.objData['ZombieForwardDistance'], 128);
      expect(object.objData['WarningMessage'], '');
      final l10n = lookupAppLocalizations(const Locale('en'));
      expect(
        tester
            .widget<Text>(find.text(l10n.gravityAdvancedSettings))
            .style
            ?.fontWeight,
        FontWeight.bold,
      );
      expect(find.text(l10n.gravitySequentialNotice), findsNothing);
      await tester.tap(find.byIcon(Icons.help_outline));
      await tester.pumpAndSettle();
      expect(find.text(l10n.gravityHelpParameters), findsOneWidget);
      expect(find.text(l10n.gravitySequentialNotice), findsOneWidget);
      final help = find.byType(AlertDialog);
      for (final text in [
        l10n.gravityTargetType,
        l10n.gravityRestrictions,
        l10n.gravityPlantRangeHint,
        l10n.gravityGridRangeHint,
        l10n.gravityRestrictionHint,
      ]) {
        expect(
          find.descendant(of: help, matching: find.textContaining(text)),
          findsNothing,
        );
      }
      expect(l10n.gravityHelpAnti, isNot(contains('ZombieForwardDistance')));
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('new events have a compact plant range and no warning editor', (
    tester,
  ) async {
    final level = PvzLevelFile(objects: []);
    await tester.pumpWidget(_app(level));
    await tester.pumpAndSettle();
    expect(level.objects.single.objClass, _class);
    expect(level.objects.single.objData['WarningMessage'], '');
    expect(find.textContaining('WarningMessage'), findsNothing);
    expect(_painter(tester).bounds, const Rect.fromLTWH(-1, 0, 3, 1));
    expect(_painter(tester).target, Offset.zero);
    expect(_painter(tester).fieldColor, Colors.red);
    expect(tester.takeException(), isNull);
  });

  testWidgets('mode, coordinates, range, timings and color can be edited', (
    tester,
  ) async {
    final object = _event();
    var changes = 0;
    await tester.pumpWidget(
      _app(PvzLevelFile(objects: [object]), onChanged: () => changes++),
    );
    await tester.pumpAndSettle();
    expect(changes, 0);
    await _tap(tester, 'gravity-level-heavy');
    expect(object.objData['GravityLevel'], 'heavy');
    expect(_painter(tester).fieldColor, Colors.green);
    await _tap(tester, 'gravity-target-grid');
    expect(_painter(tester).bounds, const Rect.fromLTWH(0, 0, 9, 5));
    await _enter(tester, 'RangeX', '0');
    await _enter(tester, 'RangeWidth', '3');
    await _enter(tester, 'RangeHeight', '2');
    final canvas = find.byKey(const ValueKey('gravityRangeCanvas'));
    await tester.ensureVisible(canvas);
    await tester.pumpAndSettle();
    final rect = tester.getRect(canvas);
    await tester.tapAt(
      rect.topLeft + Offset(rect.width * 6.5 / 9, rect.height * 2.5 / 5),
    );
    await tester.pumpAndSettle();
    expect(object.objData['TargetGrid'], {'mX': 6, 'mY': 2});
    expect(_painter(tester).range, const Rect.fromLTWH(6, 2, 3, 2));
    expect(
      tester
          .widget<TextField>(find.byKey(const ValueKey('gravity-TargetX')))
          .controller!
          .text,
      '6',
    );
    await _enter(tester, 'TargetX', '7');
    await _enter(tester, 'RangeX', '-1');
    await _enter(tester, 'Duration', '12');
    await _enter(tester, 'ActivationDelay', '2.5');
    expect(object.objData['ActivationDelay'], 2.5);
    expect(object.objData['Duration'], 12);
    expect(object.objData['DeployDuration'], 1);
    expect(_painter(tester).range, const Rect.fromLTWH(6, 2, 3, 2));
    await _enter(tester, 'Duration', 'NaN');
    expect(object.objData['Duration'], 12);
    await _tap(tester, 'gravity-target-plant');
    expect(_painter(tester).bounds, const Rect.fromLTWH(-1, 0, 3, 2));
    expect(_painter(tester).target, Offset.zero);
    expect(find.byKey(const ValueKey('gravity-TargetX')), findsNothing);
    expect(object.objData['WarningMessage'], '');
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'mixed exclusion lists can add plants and zombies and remove one type',
    (tester) async {
      final object = _event();
      object.objData['TargetRestriction'] = ['unknown_custom_type'];
      await tester.pumpWidget(_app(PvzLevelFile(objects: [object])));
      await tester.pumpAndSettle();
      await _tap(tester, 'gravity-add-plants');
      tester
          .widget<PlantSelectionScreen>(find.byType(PlantSelectionScreen))
          .onMultiPlantSelected!(['peashooter']);
      await tester.pumpAndSettle();
      await _tap(tester, 'gravity-add-zombies');
      tester
          .widget<ZombieSelectionScreen>(find.byType(ZombieSelectionScreen))
          .onMultiZombieSelected!(['moon']);
      await tester.pumpAndSettle();
      expect(object.objData['TargetRestriction'], [
        'unknown_custom_type',
        'peashooter',
        'moon',
      ]);
      await _tap(tester, 'gravity-remove-peashooter');
      expect(object.objData['TargetRestriction'], [
        'unknown_custom_type',
        'moon',
      ]);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'wide controls share rows and keep active edits when resized to a phone',
    (tester) async {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = const Size(1400, 1000);
      addTearDown(tester.view.reset);
      final object = _event(1);
      await tester.pumpWidget(
        _app(PvzLevelFile(objects: [object]), locale: 'ru', scale: 1.3),
      );
      await tester.pumpAndSettle();
      await _tap(tester, 'gravity-advanced-settings');

      const pairs = [
        ('level-anti', 'level-heavy'),
        ('target-plant', 'target-grid'),
        ('ActivationDelay', 'Duration'),
        ('TargetX', 'TargetY'),
        ('RangeX', 'RangeY'),
        ('RangeWidth', 'RangeHeight'),
        ('DeployDuration', 'ChargeDuration'),
        ('PlantExitDelay', 'ZombieRiseDuration'),
        ('ZombieTranslateDuration', 'ZombieFallDuration'),
        ('ZombieLiftHeight', 'ZombieForwardDistance'),
      ];
      for (final (first, second) in pairs) {
        final firstRect = tester.getRect(
          find.byKey(ValueKey('gravity-$first')),
        );
        final secondRect = tester.getRect(
          find.byKey(ValueKey('gravity-$second')),
        );
        expect(firstRect.top, closeTo(secondRect.top, 0.1), reason: first);
        expect(
          firstRect.right,
          lessThanOrEqualTo(secondRect.left),
          reason: first,
        );
      }

      final field = find.byKey(const ValueKey('gravity-ActivationDelay'));
      await tester.ensureVisible(field);
      await tester.showKeyboard(field);
      final editable = find.descendant(
        of: field,
        matching: find.byType(EditableText),
      );
      final focus = tester.widget<EditableText>(editable).focusNode;
      tester.testTextInput.updateEditingValue(
        const TextEditingValue(
          text: '1.',
          selection: TextSelection.collapsed(offset: 2),
        ),
      );
      await tester.pumpAndSettle();
      tester.view.physicalSize = const Size(380, 850);
      await tester.pumpAndSettle();
      expect(tester.widget<EditableText>(editable).focusNode, same(focus));
      expect(focus.hasFocus, isTrue);
      expect(tester.widget<TextField>(field).controller!.text, '1.');
      for (final (first, second) in pairs) {
        final firstRect = tester.getRect(
          find.byKey(ValueKey('gravity-$first')),
        );
        final secondRect = tester.getRect(
          find.byKey(ValueKey('gravity-$second')),
        );
        expect(
          firstRect.bottom,
          lessThanOrEqualTo(secondRect.top),
          reason: first,
        );
      }
      tester.testTextInput.updateEditingValue(
        const TextEditingValue(
          text: '1.25',
          selection: TextSelection.collapsed(offset: 4),
        ),
      );
      await tester.pumpAndSettle();
      expect(object.objData['ActivationDelay'], 1.25);
      expect(tester.takeException(), isNull);
    },
  );

  for (final locale in ['zh', 'en', 'ru']) {
    testWidgets(
      '$locale labels and help fit large text and changing window sizes',
      (tester) async {
        tester.view.devicePixelRatio = 1;
        tester.view.physicalSize = const Size(380, 850);
        addTearDown(tester.view.resetDevicePixelRatio);
        addTearDown(tester.view.resetPhysicalSize);
        final level = PvzLevelFile(objects: [_event(5)]);
        await tester.pumpWidget(_app(level, locale: locale, scale: 2));
        await tester.pumpAndSettle();
        final context = tester.element(
          find.byType(GravityGeneratorEventScreen),
        );
        final l10n = AppLocalizations.of(context)!;
        expect(
          EventSelectionScreen.resolveEventTitleByObjClass(
            context,
            _class,
            l10n,
          ),
          l10n.eventTitle_GravityGeneratorWaveActionProps,
        );
        expect(
          EventSelectionScreen.resolveEventDescription(
            context,
            EventRegistry.getByObjClass(_class)!,
            l10n,
          ),
          l10n.eventDesc_GravityGeneratorWaveActionProps,
        );
        await tester.ensureVisible(
          find.byKey(const ValueKey('gravity-add-zombies')),
        );
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
        tester.view.physicalSize = const Size(800, 380);
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
        await tester.tap(find.byIcon(Icons.help_outline));
        await tester.pumpAndSettle();
        await tester.ensureVisible(find.text(l10n.gravityHelpHeavy));
        await tester.pumpAndSettle();
        expect(find.text(l10n.gravityHelpAnti), findsOneWidget);
        expect(find.text(l10n.gravityHelpHeavy), findsOneWidget);
        expect(tester.takeException(), isNull);
      },
    );
  }
}
