import 'package:c_editor/data/pvz_models.dart';
import 'package:c_editor/l10n/app_localizations.dart';
import 'package:c_editor/screens/editor/modules/gulliver_tunnel_module_screen.dart';
import 'package:c_editor/screens/editor/modules/speed_up_tile_module_screen.dart';
import 'package:c_editor/screens/editor/modules/tunnel_defend_module_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _app(Widget screen) => MaterialApp(
  locale: const Locale('en'),
  localizationsDelegates: AppLocalizations.localizationsDelegates,
  supportedLocales: AppLocalizations.supportedLocales,
  theme: ThemeData(platform: TargetPlatform.windows),
  home: screen,
);

void main() {
  for (final width in [800.0, 1240.0, 1600.0, 2482.0]) {
    testWidgets('tunnel picker fits its content at width $width', (
      tester,
    ) async {
      tester.view.physicalSize = Size(width, 1000);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final level = PvzLevelFile(objects: []);
      await tester.pumpWidget(
        _app(
          TunnelDefendModuleScreen(
            rtid: 'RTID(TunnelDefend@CurrentLevel)',
            levelFile: level,
            onChanged: () {},
            onBack: () {},
          ),
        ),
      );
      await tester.pump();

      final picker = find.byKey(const ValueKey('tunnelComponentGrid'));
      final lastComponent = find.byKey(const ValueKey('tunnelComponent_22'));
      // The picker ends at the last row, without reserving extra empty rows.
      expect(
        tester.getBottomRight(picker).dy,
        closeTo(tester.getBottomRight(lastComponent).dy, 0.1),
      );
      expect(
        tester.getTopLeft(find.text('Select component')).dy,
        lessThan(tester.getTopLeft(find.text('Placed components: 0')).dy),
      );

      // Every component remains selectable through the page's single scroll.
      await tester.ensureVisible(lastComponent);
      await tester.tap(lastComponent);
      await tester.pump();
      final firstCell = find
          .descendant(
            of: find.byKey(const ValueKey('tunnelLayoutPreviewCenter')),
            matching: find.byType(GestureDetector),
          )
          .first;
      await tester.ensureVisible(firstCell);
      await tester.tap(firstCell);
      await tester.pump();
      final module = level.objects.singleWhere(
        (object) => object.objClass == 'TunnelDefendModuleProperties',
      );
      final roads = TunnelDefendModuleData.fromJson(
        Map<String, dynamic>.from(module.objData as Map),
      ).roads;
      expect(roads.single.img, 'IMAGE_UI_MAUSOLEUM_TUNNEL_UP_DOWN_LEFT_2');
      expect(tester.takeException(), isNull);
    });
  }

  for (final kind in ['gulliver', 'speedUpTile']) {
    testWidgets('$kind picker precedes the placed count', (tester) async {
      tester.view.physicalSize = const Size(1240, 1000);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final level = PvzLevelFile(objects: []);
      final screen = kind == 'gulliver'
          ? GulliverTunnelModuleScreen(
              rtid: 'RTID(GulliverTunnel@CurrentLevel)',
              levelFile: level,
              onChanged: () {},
              onBack: () {},
            )
          : SpeedUpTileModuleScreen(
              rtid: 'RTID(SpeedUpTile@CurrentLevel)',
              levelFile: level,
              onChanged: () {},
              onBack: () {},
            );
      await tester.pumpWidget(_app(screen));
      await tester.pump();
      expect(
        tester
            .getTopLeft(
              find.text(
                kind == 'gulliver'
                    ? 'Select orientation'
                    : 'Select arrow direction',
              ),
            )
            .dy,
        lessThan(tester.getTopLeft(find.text('Placed: 0')).dy),
      );
      expect(tester.takeException(), isNull);
    });
  }
}
