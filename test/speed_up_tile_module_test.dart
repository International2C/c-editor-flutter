import 'package:c_editor/data/pvz_models.dart';
import 'package:c_editor/data/speed_up_tile_catalog.dart';
import 'package:c_editor/l10n/app_localizations.dart';
import 'package:c_editor/screens/editor/modules/speed_up_tile_module_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

const _alias = 'SpeedUpTile';

Map<String, dynamic> _road(int x, int y, String direction) => {
  'GridX': x,
  'GridY': y,
  'Img': direction,
};

// Roads from UNCHARTED_NEEDFORSPEED_202406_H_3.JSON, in original order.
List<Map<String, dynamic>> _officialRoads() => [
  _road(7, 1, SpeedUpTileCatalog.left),
  _road(6, 1, SpeedUpTileCatalog.left),
  _road(5, 1, SpeedUpTileCatalog.down),
  _road(5, 2, SpeedUpTileCatalog.left),
  _road(4, 2, SpeedUpTileCatalog.left),
  _road(3, 2, SpeedUpTileCatalog.up),
  _road(3, 1, SpeedUpTileCatalog.up),
  _road(3, 0, SpeedUpTileCatalog.left),
  _road(7, 3, SpeedUpTileCatalog.left),
  _road(6, 3, SpeedUpTileCatalog.left),
  _road(5, 3, SpeedUpTileCatalog.up),
];

PvzObject _module(Map<String, dynamic> data) => PvzObject(
  aliases: [_alias],
  objClass: 'SpeedUpTileModuleProperties',
  objData: data,
);

Widget _screen(
  PvzLevelFile level, {
  String locale = 'en',
  double textScale = 1,
  VoidCallback? onChanged,
}) => MaterialApp(
  locale: Locale(locale),
  localizationsDelegates: AppLocalizations.localizationsDelegates,
  supportedLocales: AppLocalizations.supportedLocales,
  builder: (context, child) => MediaQuery(
    data: MediaQuery.of(
      context,
    ).copyWith(textScaler: TextScaler.linear(textScale)),
    child: child!,
  ),
  home: SpeedUpTileModuleScreen(
    rtid: 'RTID($_alias@CurrentLevel)',
    levelFile: level,
    onChanged: onChanged ?? () {},
    onBack: () {},
  ),
);

Future<void> _chooseDirection(WidgetTester tester, String direction) async {
  final choice = find.byKey(ValueKey('speedUpTileDirection_$direction'));
  await tester.ensureVisible(choice);
  await tester.tap(choice);
  await tester.pumpAndSettle();
}

Future<void> _tapCell(WidgetTester tester, int x, int y) async {
  final cell = find.byKey(ValueKey('speedUpTileCell_${x}_$y'));
  await tester.ensureVisible(cell);
  await tester.tap(cell);
  await tester.pumpAndSettle();
}

void main() {
  testWidgets(
    'narrow direction selector fits two choices per row without an unrelated warning',
    (tester) async {
      tester.view.physicalSize = const Size(320, 1200);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final level = PvzLevelFile(
        objects: [
          _module({'Roads': []}),
        ],
      );
      await tester.pumpWidget(_screen(level, locale: 'zh', textScale: 1.5));
      await tester.pumpAndSettle();
      final left = find.byKey(
        ValueKey('speedUpTileDirection_${SpeedUpTileCatalog.left}'),
      );
      final right = find.byKey(
        ValueKey('speedUpTileDirection_${SpeedUpTileCatalog.right}'),
      );
      final up = find.byKey(
        ValueKey('speedUpTileDirection_${SpeedUpTileCatalog.up}'),
      );
      await tester.ensureVisible(left);
      await tester.pumpAndSettle();
      expect(
        tester.getTopLeft(left).dy,
        closeTo(tester.getTopLeft(right).dy, .1),
      );
      expect(tester.getTopLeft(up).dy, greaterThan(tester.getTopLeft(left).dy));
      expect(
        find.text('加速带会被「地宫坑道」或「远征地砖」模块添加的地块覆盖，从而无法生效，请勿同时使用。'),
        findsNothing,
      );
      expect(tester.takeException(), isNull);
    },
  );
  testWidgets('compatibility warning follows active tile modules', (
    tester,
  ) async {
    for (final brickMapIndex in [0, 3]) {
      final definition = PvzObject(
        aliases: ['LevelDefinition'],
        objClass: 'LevelDefinition',
        objData: LevelDefinitionData(
          modules: const [
            'RTID(SpeedUpTile@CurrentLevel)',
            'RTID(Tunnel@CurrentLevel)',
          ],
        ).toJson(),
      );
      final level = PvzLevelFile(
        objects: [
          definition,
          _module({'Roads': []}),
          PvzObject(
            aliases: ['Tunnel'],
            objClass: 'TunnelDefendModuleProperties',
            objData: {'BrickMapIndex': brickMapIndex},
          ),
        ],
      );
      final banner = find.byKey(
        const ValueKey('speedUpTileCompatibilityWarning'),
      );
      await tester.pumpWidget(_screen(level));
      await tester.pumpAndSettle();
      expect(banner, findsOneWidget);
      // Keep the object in the file: unlinking it must still clear the warning.
      definition.objData['Modules'] = ['RTID(SpeedUpTile@CurrentLevel)'];
      await tester.pumpWidget(_screen(level));
      await tester.pumpAndSettle();
      expect(banner, findsNothing);
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox.shrink());
    }
  });
  test('official roads retain zero-based coordinates and list order', () {
    final original = <String, dynamic>{'Roads': _officialRoads()};
    final data = SpeedUpTileModulePropertiesData.fromJson(original);

    expect(data.roads, hasLength(11));
    expect(data.roads[7].gridX, 3);
    expect(data.roads[7].gridY, 0);
    expect(data.roads[2].img, SpeedUpTileCatalog.down);
    expect(data.toJson(), original);
  });

  test('unknown module and road fields, images and outside cells survive', () {
    final original = <String, dynamic>{
      'FutureModuleSetting': {'enabled': true},
      'Roads': [
        {..._road(0, 0, 'IMAGE_FUTURE_SPEED_TILE'), 'FutureRoadSetting': 4},
        _road(-1, 7, SpeedUpTileCatalog.up),
      ],
    };
    final data = SpeedUpTileModulePropertiesData.fromJson(original);

    expect(data.toJson(), original);
    data.roads.first.img = SpeedUpTileCatalog.right;
    final serialized = data.toJson();
    expect(serialized['FutureModuleSetting'], {'enabled': true});
    expect((serialized['Roads'] as List).first['FutureRoadSetting'], 4);
    expect((serialized['Roads'] as List).last, original['Roads'][1]);
  });

  test('all four game image identifiers map to provided assets', () {
    for (final direction in SpeedUpTileCatalog.directions) {
      final name = direction.split('_').last.toLowerCase();
      expect(
        SpeedUpTileCatalog.assetForImage(direction),
        'assets/images/tunnels/speed_up_tile_$name.webp',
      );
    }
    expect(SpeedUpTileCatalog.assetForImage('FUTURE_TILE'), isNull);
    expect(SpeedUpTileModulePropertiesData().toJson(), {'Roads': []});
  });

  testWidgets('grid places all directions at zero-based cells and toggles', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(900, 1400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final module = _module({'Roads': <dynamic>[]});
    final level = PvzLevelFile(objects: [module]);
    var changes = 0;
    await tester.pumpWidget(_screen(level, onChanged: () => changes++));
    await tester.pumpAndSettle();

    for (var index = 0; index < SpeedUpTileCatalog.directions.length; index++) {
      await _chooseDirection(tester, SpeedUpTileCatalog.directions[index]);
      await _tapCell(tester, index, 0);
    }
    expect((module.objData as Map)['Roads'], [
      for (var index = 0; index < SpeedUpTileCatalog.directions.length; index++)
        _road(index, 0, SpeedUpTileCatalog.directions[index]),
    ]);
    expect(changes, 4);
    expect(find.byKey(const ValueKey('speedUpTileCell_8_4')), findsOneWidget);
    expect(find.byKey(const ValueKey('speedUpTileCell_9_5')), findsNothing);

    await _tapCell(tester, 3, 0);
    expect((module.objData as Map)['Roads'], hasLength(3));
    expect(tester.takeException(), isNull);
  });

  testWidgets('editing another cell preserves imported roads and their order', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(900, 1400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final roads = <Map<String, dynamic>>[
      {..._road(7, 1, SpeedUpTileCatalog.left), 'Custom': 42},
      _road(2, 3, 'IMAGE_FUTURE_SPEED_TILE'),
      _road(12, -1, SpeedUpTileCatalog.down),
    ];
    final module = _module({'Roads': roads, 'Imported': 'keep'});
    await tester.pumpWidget(_screen(PvzLevelFile(objects: [module])));
    await tester.pumpAndSettle();

    await _tapCell(tester, 0, 0);
    expect((module.objData as Map)['Imported'], 'keep');
    expect((module.objData as Map)['Roads'], [
      ...roads,
      _road(0, 0, SpeedUpTileCatalog.left),
    ]);

    await _chooseDirection(tester, SpeedUpTileCatalog.right);
    await _tapCell(tester, 7, 1);
    expect((module.objData as Map)['Roads'], [
      {..._road(7, 1, SpeedUpTileCatalog.right), 'Custom': 42},
      ...roads.skip(1),
      _road(0, 0, SpeedUpTileCatalog.left),
    ]);
    expect(tester.takeException(), isNull);
  });

  testWidgets('deep-sea lawn exposes the tenth column and sixth row', (
    tester,
  ) async {
    final module = _module({'Roads': <dynamic>[]});
    final level = PvzLevelFile(
      objects: [
        PvzObject(
          aliases: ['LevelDefinition'],
          objClass: 'LevelDefinition',
          objData: LevelDefinitionData(
            stageModule: 'RTID(CustomDeepsea@CurrentLevel)',
          ).toJson(),
        ),
        PvzObject(
          aliases: ['CustomDeepsea'],
          objClass: 'DeepseaStageProperties',
          objData: <String, dynamic>{},
        ),
        module,
      ],
    );
    await tester.pumpWidget(_screen(level));
    await tester.pumpAndSettle();
    await _tapCell(tester, 9, 5);

    expect((module.objData as Map)['Roads'], [
      _road(9, 5, SpeedUpTileCatalog.left),
    ]);
    expect(tester.takeException(), isNull);
  });

  testWidgets('clear all asks for confirmation and removes outside roads too', (
    tester,
  ) async {
    final module = _module({
      'Roads': [
        _road(0, 0, SpeedUpTileCatalog.left),
        _road(20, 2, SpeedUpTileCatalog.right),
      ],
      'KeepSetting': 17,
    });
    await tester.pumpWidget(_screen(PvzLevelFile(objects: [module])));
    await tester.pumpAndSettle();
    final clear = find.byKey(const ValueKey('speedUpTileClearAll'));
    await tester.ensureVisible(clear);
    await tester.tap(clear);
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(TextButton, 'Cancel'));
    await tester.pumpAndSettle();
    expect((module.objData as Map)['Roads'], hasLength(2));

    await tester.tap(clear);
    await tester.pumpAndSettle();
    await tester.tap(
      find.descendant(
        of: find.byType(AlertDialog),
        matching: find.byType(FilledButton),
      ),
    );
    await tester.pumpAndSettle();
    expect(module.objData, {'Roads': [], 'KeepSetting': 17});
    expect(tester.takeException(), isNull);
  });

  testWidgets('outside removal leaves the visible road untouched', (
    tester,
  ) async {
    final inside = _road(0, 0, SpeedUpTileCatalog.left);
    final module = _module({
      'Roads': [inside, _road(9, 0, SpeedUpTileCatalog.right)],
    });
    await tester.pumpWidget(_screen(PvzLevelFile(objects: [module])));
    await tester.pumpAndSettle();
    final remove = find.byKey(const ValueKey('speedUpTileDeleteOutside'));
    await tester.ensureVisible(remove);
    await tester.tap(remove);
    await tester.pumpAndSettle();
    await tester.tap(
      find.descendant(
        of: find.byType(AlertDialog),
        matching: find.byType(FilledButton),
      ),
    );
    await tester.pumpAndSettle();

    expect((module.objData as Map)['Roads'], [inside]);
    expect(
      find.byKey(const ValueKey('speedUpTileDeleteOutside')),
      findsNothing,
    );
    expect(tester.takeException(), isNull);
  });

  for (final locale in ['zh', 'en', 'ru']) {
    testWidgets('narrow $locale layout and help fit at 150% text size', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(285, 1200);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final module = _module({
        'Roads': [_road(20, 2, SpeedUpTileCatalog.right)],
      });
      await tester.pumpWidget(
        _screen(
          PvzLevelFile(objects: [module]),
          locale: locale,
          textScale: 1.5,
        ),
      );
      await tester.pumpAndSettle();
      await _chooseDirection(tester, SpeedUpTileCatalog.down);
      expect(tester.takeException(), isNull);

      await tester.tap(find.byIcon(Icons.help_outline).first);
      await tester.pumpAndSettle();
      final context = tester.element(find.byType(SpeedUpTileModuleScreen));
      final l10n = AppLocalizations.of(context)!;
      final topologyTitle = find.text('• ${l10n.speedUpTileTopologyTitle}');
      expect(topologyTitle, findsOneWidget);
      await tester.ensureVisible(topologyTitle);
      await tester.pumpAndSettle();
      final topologyBody = find.text(l10n.speedUpTileTopologyBody);
      await tester.ensureVisible(topologyBody);
      await tester.pumpAndSettle();
      expect(topologyBody, findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }
}
