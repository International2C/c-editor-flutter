import 'package:c_editor/data/pvz_models.dart';
import 'package:c_editor/data/repository/reference_repository.dart';
import 'package:c_editor/data/repository/zombie_properties_repository.dart';
import 'package:c_editor/data/repository/zombie_repository.dart';
import 'package:c_editor/l10n/app_localizations.dart';
import 'package:c_editor/screens/editor/events/bungee_wave_event_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

Widget _app(
  PvzLevelFile level, {
  required VoidCallback onChanged,
  required void Function(void Function(String)) onSelect,
}) => MaterialApp(
  locale: const Locale('en'),
  localizationsDelegates: AppLocalizations.localizationsDelegates,
  supportedLocales: AppLocalizations.supportedLocales,
  home: BungeeWaveEventScreen(
    rtid: 'RTID(Wave1BungeeDropEvent0@CurrentLevel)',
    levelFile: level,
    onChanged: onChanged,
    onBack: () {},
    onRequestZombieSelection: onSelect,
  ),
);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    SharedPreferences.setMockInitialValues({});
    await Future.wait([
      ReferenceRepository.init(),
      ZombieRepository().init(),
      ZombiePropertiesRepository.init(),
    ]);
  });

  testWidgets('creating a missing event in the editor uses official keys', (
    tester,
  ) async {
    final level = PvzLevelFile(objects: []);
    await tester.pumpWidget(_app(level, onChanged: () {}, onSelect: (_) {}));
    await tester.pumpAndSettle();
    expect(level.objects.single.objClass, 'BungeeWaveActionProps');
    expect(level.objects.single.objData, {
      'target': {'mX': 0, 'mY': 0},
      'zombieName': 'tutorial',
      'Level': 1,
    });
    expect(tester.takeException(), isNull);
  });

  for (final legacy in [false, true]) {
    testWidgets(
      'editing target, zombie and Level preserves all fields (legacy: $legacy)',
      (tester) async {
        final level = PvzLevelFile(
          objects: [
            PvzObject(
              aliases: ['Wave1BungeeDropEvent0'],
              objClass: 'BungeeWaveActionProps',
              objData: {
                legacy ? 'Target' : 'target': {'mX': 6, 'mY': 2},
                legacy ? 'ZombieName' : 'zombieName': 'mummy',
                'Level': 4,
              },
            ),
          ],
        );
        var changes = 0;
        void Function(String)? selectZombie;
        await tester.pumpWidget(
          _app(
            level,
            onChanged: () => changes++,
            onSelect: (callback) => selectZombie = callback,
          ),
        );
        await tester.pumpAndSettle();

        expect(find.text('(X: 6, Y: 2)'), findsOneWidget);
        expect(find.text('mummy'), findsOneWidget);
        final levelField = find.byKey(const ValueKey('bungeeZombieLevel'));
        final dropdown = tester.widget<DropdownButtonFormField<int>>(
          levelField,
        );
        expect(dropdown.initialValue, 4);
        expect(
          tester
              .widget<DropdownButton<int>>(
                find.descendant(
                  of: levelField,
                  matching: find.byType(DropdownButton<int>),
                ),
              )
              .items!
              .map((item) => item.value),
          List.generate(11, (i) => i),
        );
        expect(changes, 0);

        final cells = find.descendant(
          of: find.byType(AspectRatio),
          matching: find.byType(GestureDetector),
        );
        expect(cells, findsNWidgets(45));
        await tester.ensureVisible(cells.at(3 * 9 + 2));
        await tester.tap(cells.at(3 * 9 + 2));
        await tester.pumpAndSettle();
        expect(find.text('(X: 2, Y: 3)'), findsOneWidget);
        expect(level.objects.single.objData, {
          'target': {'mX': 2, 'mY': 3},
          'zombieName': 'mummy',
          'Level': 4,
        });

        for (final value in [0, 10, 7]) {
          await tester.ensureVisible(levelField);
          await tester.tap(levelField);
          await tester.pumpAndSettle();
          await tester.ensureVisible(find.text('$value').last);
          await tester.pumpAndSettle();
          await tester.tap(find.text('$value').last);
          await tester.pumpAndSettle();
          expect((level.objects.single.objData as Map)['Level'], value);
        }

        await tester.ensureVisible(find.text('mummy'));
        await tester.tap(find.text('mummy'));
        expect(selectZombie, isNotNull);
        selectZombie!('tutorial');
        await tester.pumpAndSettle();
        expect(level.objects.single.objData, {
          'target': {'mX': 2, 'mY': 3},
          'zombieName': 'tutorial',
          'Level': 7,
        });
        expect(
          level.objects.single.toJson()['objclass'],
          'BungeeWaveActionProps',
        );
        expect(changes, 5);
        expect(tester.takeException(), isNull);
      },
    );
  }
}
