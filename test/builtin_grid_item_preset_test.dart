import 'dart:convert';

import 'package:c_editor/data/grid_item_discovery.dart';
import 'package:c_editor/data/pvz_models.dart';
import 'package:c_editor/data/repository/grid_item_repository.dart';
import 'package:c_editor/data/repository/reference_repository.dart';
import 'package:c_editor/l10n/app_localizations.dart';
import 'package:c_editor/l10n/resource_names.dart';
import 'package:c_editor/screens/editor/modules/initial_grid_item_entry_screen.dart';
import 'package:c_editor/screens/level_overview/level_overview_widgets.dart'
    as overview;
import 'package:c_editor/widgets/asset_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

const _icon = 'assets/images/griditems/ArmrackRandom.webp';

PvzLevelFile _level() => PvzLevelFile(
  objects: [
    PvzObject(
      aliases: ['InitialItems'],
      objClass: 'InitialGridItemProperties',
      objData: {
        'InitialGridItemPlacements': [
          {'GridX': 0, 'GridY': 0, 'TypeName': 'armrack'},
        ],
      },
    ),
  ],
);

Widget _app(Widget home) => MaterialApp(
  locale: const Locale('zh'),
  localizationsDelegates: AppLocalizations.localizationsDelegates,
  supportedLocales: AppLocalizations.supportedLocales,
  home: home,
);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(() async {
    await GridItemRepository.init();
    await ResourceNames.ensureLoaded();
  });

  test(
    'built-in armrack without a local definition is recognized without changing the level',
    () {
      final reference = ReferenceRepository.instance.gridItemTypeForName(
        'armrack',
      );
      expect(reference, isNotNull);
      expect(reference!.aliases ?? [], isEmpty);
      final level = _level();
      final original = jsonEncode(level.toJson());
      expect(
        GridItemRepository.displayTypeNameForLevel('armrack', level),
        'armrack',
      );
      expect(
        GridItemRepository.isRecognizedCustomGridItem('armrack', level),
        isTrue,
      );
      expect(GridItemDiscovery.discoverGridItems(level), {'armrack'});
      expect(GridItemRepository.getIconPath('armrack'), _icon);
      expect(jsonEncode(level.toJson()), original);
    },
  );

  test(
    'built-in lookup does not accept conflicting local definitions or a different preset',
    () {
      final level = _level();
      expect(
        GridItemRepository.displayTypeNameForLevel(
          'gravestone_egypt_memo',
          level,
        ),
        isNull,
      );
      final template = GridItemRepository.getByTypeName(
        'armrack',
      )!.gridItemType!;
      final local = PvzObject.fromJson(
        jsonDecode(jsonEncode(template.toJson())) as Map<String, dynamic>,
      );
      level.objects.add(local);
      expect(GridItemRepository.isValidForLevel('armrack', level), isTrue);
      local.objData['GridItemClass'] = 'OtherGridItemClass';
      expect(
        GridItemRepository.displayTypeNameForLevel('armrack', level),
        isNull,
      );
      local.aliases = ['RenamedArmrack'];
      expect(
        GridItemRepository.displayTypeNameForLevel('armrack', level),
        isNull,
      );
      level.objects.remove(local);
      expect(GridItemRepository.isValidForLevel('armrack', level), isTrue);
      // RTID-based spawners still get a local alias, since the built-in type lacks one.
      expect(
        GridItemRepository.buildGridItemTypeRtid('armrack', level),
        'RTID(armrack@CurrentLevel)',
      );
      expect(
        level.objects.where((o) => o.objClass == 'GridItemType'),
        hasLength(1),
      );
    },
  );

  testWidgets(
    'initial placement grid and item card show random weapon stand art and name',
    (tester) async {
      final level = _level();
      final original = jsonEncode(level.toJson());
      await tester.pumpWidget(
        _app(
          InitialGridItemEntryScreen(
            rtid: 'RTID(InitialItems@CurrentLevel)',
            levelFile: level,
            onChanged: () {},
            onBack: () {},
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('随机兵器架'), findsOneWidget);
      expect(
        find.byWidgetPredicate(
          (w) => w is AssetImageWidget && w.assetPath == _icon,
        ),
        findsNWidgets(2),
      );
      expect(
        find.byWidgetPredicate(
          (w) =>
              w is AssetImageWidget &&
              w.assetPath == 'assets/images/others/unknown.webp',
        ),
        findsNothing,
      );
      expect(jsonEncode(level.toJson()), original);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('overview also recognizes the built-in preset icon', (
    tester,
  ) async {
    await tester.pumpWidget(
      _app(
        Scaffold(
          body: overview.GridItemIcon(id: 'armrack', levelFile: _level()),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(
      find.byWidgetPredicate(
        (w) => w is AssetImageWidget && w.assetPath == _icon,
      ),
      findsOneWidget,
    );
    expect(find.byTooltip('随机兵器架'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
