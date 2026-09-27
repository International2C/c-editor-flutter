import 'dart:convert';
import 'dart:io';

import 'package:c_editor/data/grid_item_discovery.dart';
import 'package:c_editor/data/level_parser.dart';
import 'package:c_editor/data/pvz_models.dart';
import 'package:c_editor/data/registry/event_registry.dart';
import 'package:c_editor/data/registry/object_order_registry.dart';
import 'package:c_editor/data/repository/grid_item_repository.dart';
import 'package:c_editor/data/zombie_discovery.dart';
import 'package:c_editor/l10n/app_localizations.dart';
import 'package:c_editor/l10n/resource_names.dart';
import 'package:c_editor/screens/editor/events/eagle_standard_event_screen.dart';
import 'package:c_editor/screens/select/event_selection_screen.dart';
import 'package:c_editor/widgets/asset_image.dart';
import 'package:c_editor/widgets/editor_components.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

const _class = 'SpawnEagleFlagsWaveActionProps';
const _type = 'roman_eagle_flag';

Map<String, dynamic> _fixture() =>
    jsonDecode(
          File('test/fixtures/eagle_standard_event.json').readAsStringSync(),
        )
        as Map<String, dynamic>;

Widget _app(
  PvzLevelFile level, {
  String locale = 'en',
  double scale = 1,
  VoidCallback? onChanged,
}) => MaterialApp(
  locale: Locale(locale),
  supportedLocales: AppLocalizations.supportedLocales,
  localizationsDelegates: AppLocalizations.localizationsDelegates,
  builder: (context, child) => MediaQuery(
    data: MediaQuery.of(context).copyWith(textScaler: TextScaler.linear(scale)),
    child: child!,
  ),
  home: EagleStandardEventScreen(
    rtid: 'RTID(EagleFlagWave10@CurrentLevel)',
    levelFile: level,
    onChanged: onChanged ?? () {},
    onBack: () {},
  ),
);

Future<void> _tap(WidgetTester tester, Finder finder) async {
  await tester.ensureVisible(finder);
  await tester.pumpAndSettle();
  await tester.tap(finder);
  await tester.pumpAndSettle();
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(() async {
    await GridItemRepository.init();
    await ResourceNames.ensureLoaded();
  });

  test('official UNCHARTED_ROMA_N_8 event round-trips with Flags casing', () {
    final original = _fixture();
    final event = PvzObject.fromJson(original);
    final data = SpawnEagleFlagsWaveActionPropsData.fromJson(event.objData);
    expect(data.flags.map((f) => (f.location.x, f.location.y)), [
      (7, 0),
      (7, 4),
    ]);
    expect(data.flags.map((f) => f.type), [_type, _type]);
    event.objData = data.toJson();
    final level = PvzLevelFile(objects: [event]);
    final exported = jsonDecode(jsonEncode(level.toJson())) as Map;
    expect(exported['objects'], [original]);
    expect(EventRegistry.getByObjClass(_class)!.summaryProvider!(event), '2');
  });

  test('new event follows Magic Mirror in the item spawn category', () {
    final events = EventRegistry.getAll();
    final mirror = events.indexWhere(
      (m) =>
          m.defaultObjClass == 'WaveActionMagicMirrorTeleportationArrayProps',
    );
    final metadata = events[mirror + 1];
    expect(metadata.defaultObjClass, _class);
    expect(metadata.category, EventCategory.gridItemSpawn);
    expect(
      ObjectOrderRegistry.getPriority(_class),
      ObjectOrderRegistry.getPriority(
            'WaveActionMagicMirrorTeleportationArrayProps',
          ) +
          1,
    );
    final data =
        metadata.initialDataFactory() as SpawnEagleFlagsWaveActionPropsData;
    expect(data.toJson(), {'Flags': []});
    data.flags.add(EagleFlagData(location: LocationData(x: 4, y: 2)));
    final object = PvzObject(
      objClass: metadata.defaultObjClass,
      objData: data.toJson(),
    );
    expect(object.toJson(), {
      'objclass': _class,
      'objdata': {
        'Flags': [
          {
            'Location': {'mX': 4, 'mY': 2},
            'Type': _type,
          },
        ],
      },
    });
  });

  test('unknown fields, types and off-lawn positions survive editing', () {
    final data = SpawnEagleFlagsWaveActionPropsData.fromJson({
      'FutureSetting': 12,
      'Flags': [
        {
          'Location': {'mX': -1, 'mY': 7},
          'Type': 'future_flag',
          'FutureFlagSetting': true,
        },
      ],
    });
    data.flags.add(EagleFlagData());
    final json = data.toJson();
    expect(json['FutureSetting'], 12);
    expect((json['Flags'] as List).first, {
      'Location': {'mX': -1, 'mY': 7},
      'Type': 'future_flag',
      'FutureFlagSetting': true,
    });
    expect((json['Flags'] as List).last['Type'], _type);
  });

  test(
    'overview finds flags as grid items and does not count them as zombies',
    () {
      final event = PvzObject.fromJson(_fixture());
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
                ['RTID(EagleFlagWave10@CurrentLevel)'],
              ],
            },
          ),
          event,
        ],
      );
      final parsed = LevelParser.parseLevel(level);
      expect(GridItemDiscovery.discoverGridItems(level), {_type});
      expect(ZombieDiscovery.discoverEvents(parsed), contains(_class));
      expect(ZombieDiscovery.discoverZombies(level, parsed), isEmpty);
      event.objData = {'Flags': []};
      expect(GridItemDiscovery.discoverGridItems(level), isEmpty);
    },
  );

  test('tent spawn precedes pumpkin house in both event order sources', () {
    final order = EventRegistry.getAll().map((m) => m.defaultObjClass).toList();
    expect(
      order.indexOf('WaveActionZombieTentProps') + 1,
      order.indexOf('PumpkinHouseActionProps'),
    );
    expect(
      ObjectOrderRegistry.getPriority('WaveActionZombieTentProps') + 1,
      ObjectOrderRegistry.getPriority('PumpkinHouseActionProps'),
    );
  });

  testWidgets(
    'manual item types use their actual icons in the grid and cards',
    (tester) async {
      final event = PvzObject.fromJson(_fixture());
      event.objData['Flags'] = [
        {
          'Location': {'mX': 0, 'mY': 0},
          'Type': 'rocket_landing',
        },
        {
          'Location': {'mX': 2, 'mY': 0},
          'Type': _type,
        },
      ];
      final original = jsonEncode(event.toJson());
      await tester.pumpWidget(_app(PvzLevelFile(objects: [event])));
      await tester.pumpAndSettle();
      await _tap(tester, find.byKey(const ValueKey('eagle-cell-0-0')));
      expect(
        find.byWidgetPredicate(
          (w) => w is GridItemIcon && w.typeName == 'rocket_landing',
        ),
        findsNWidgets(2),
      );
      final rocketCell = find.byKey(const ValueKey('eagle-cell-0-0'));
      expect(
        find.descendant(
          of: rocketCell,
          matching: find.byWidgetPredicate(
            (w) =>
                w is AssetImageWidget &&
                w.assetPath == GridItemRepository.getIconPath('rocket_landing'),
          ),
        ),
        findsOneWidget,
      );
      expect(
        find.descendant(
          of: rocketCell,
          matching: find.byWidgetPredicate(
            (w) =>
                w is AssetImageWidget &&
                w.assetPath == GridItemRepository.getIconPath(_type),
          ),
        ),
        findsNothing,
      );
      expect(jsonEncode(event.toJson()), original);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'new event adds duplicate flags at selected cells and removes only one',
    (tester) async {
      final level = PvzLevelFile(objects: []);
      var changes = 0;
      await tester.pumpWidget(_app(level, onChanged: () => changes++));
      await tester.pumpAndSettle();
      expect(level.objects.single.objClass, _class);
      expect(level.objects.single.objData, {'Flags': []});
      expect(changes, 0);
      await _tap(tester, find.byKey(const ValueKey('eagle-cell-7-4')));
      await _tap(tester, find.byKey(const ValueKey('eagle-add-flag')));
      await _tap(tester, find.byKey(const ValueKey('eagle-add-flag')));
      expect(level.objects.single.objData, {
        'Flags': [
          {
            'Location': {'mX': 7, 'mY': 4},
            'Type': _type,
          },
          {
            'Location': {'mX': 7, 'mY': 4},
            'Type': _type,
          },
        ],
      });
      expect(find.text(_type), findsNWidgets(2));
      expect(find.text('+1'), findsOneWidget);
      await _tap(tester, find.byTooltip('Delete').first);
      await _tap(tester, find.widgetWithText(TextButton, 'Cancel'));
      expect(level.objects.single.objData['Flags'], hasLength(2));
      await _tap(tester, find.byTooltip('Delete').first);
      await _tap(tester, find.widgetWithText(TextButton, 'Remove'));
      expect(level.objects.single.objData['Flags'], hasLength(1));
      expect(changes, 3);
      expect(tester.takeException(), isNull);
    },
  );

  for (final locale in ['zh', 'en', 'ru']) {
    testWidgets(
      '$locale imported cards and help fit narrow screens with large text',
      (tester) async {
        tester.view.physicalSize = const Size(360, 850);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        final event = PvzObject.fromJson(_fixture());
        (event.objData['Flags'] as List).add({
          'Location': {'mX': 20, 'mY': 20},
          'Type': _type,
        });
        final original = jsonEncode(event.toJson());
        await tester.pumpWidget(
          _app(PvzLevelFile(objects: [event]), locale: locale, scale: 2),
        );
        await tester.pumpAndSettle();
        expect(jsonEncode(event.toJson()), original);
        final context = tester.element(find.byType(EagleStandardEventScreen));
        final l10n = AppLocalizations.of(context)!;
        final metadata = EventRegistry.getByObjClass(_class)!;
        expect(
          EventSelectionScreen.resolveEventTitle(context, metadata, l10n),
          l10n.eventTitle_SpawnEagleFlagsWaveActionProps,
        );
        expect(
          EventSelectionScreen.resolveEventDescription(context, metadata, l10n),
          l10n.eventDesc_SpawnEagleFlagsWaveActionProps,
        );
        await _tap(tester, find.byKey(const ValueKey('eagle-cell-7-0')));
        expect(find.text(_type), findsNWidgets(2));
        expect(find.byTooltip(_type), findsNWidgets(2));
        for (final code in [find.text(_type).first, find.text(_type).last]) {
          await tester.ensureVisible(code);
          await tester.pumpAndSettle();
          final card = find
              .ancestor(of: code, matching: find.byType(Card))
              .first;
          expect(tester.getRect(card).contains(tester.getCenter(code)), isTrue);
        }
        expect(find.text('R21:C21'), findsOneWidget);
        expect(tester.takeException(), isNull);
        await _tap(tester, find.byTooltip(l10n.tooltipAboutEvent));
        expect(find.text(l10n.eventHelpEagleStandardBody), findsOneWidget);
        final helpScroll = find.descendant(
          of: find.byType(AlertDialog),
          matching: find.byType(Scrollable),
        );
        await tester.drag(helpScroll, const Offset(0, -10000));
        await tester.pumpAndSettle();
        final position = tester.state<ScrollableState>(helpScroll).position;
        expect(position.pixels, closeTo(position.maxScrollExtent, 1));
        expect(
          find
              .text(l10n.eventHelpEagleStandardUsage)
              .hitTestable(at: const Alignment(0, 0.99)),
          findsOneWidget,
        );
        expect(tester.takeException(), isNull);
        tester.view.physicalSize = const Size(850, 360);
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
      },
    );
  }
}
