import 'dart:convert';
import 'dart:io';

import 'package:c_editor/data/pvz_models.dart';
import 'package:c_editor/l10n/app_localizations.dart';
import 'package:c_editor/l10n/resource_names.dart';
import 'package:c_editor/screens/editor/events/fairy_tale_fog_event_screen.dart';
import 'package:c_editor/screens/editor/events/fairy_tale_wind_event_screen.dart';
import 'package:c_editor/screens/editor/events/raiding_party_event_screen.dart';
import 'package:c_editor/screens/editor/modules/wave_generator_module_screen.dart';
import 'package:c_editor/widgets/editor_components.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

Widget _app(Widget home, {String locale = 'zh', double scale = 1}) =>
    MaterialApp(
      locale: Locale(locale),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(
          context,
        ).copyWith(textScaler: TextScaler.linear(scale)),
        child: child!,
      ),
      home: home,
    );

Finder _field(String label) => find.descendant(
  of: find.byWidgetPredicate(
    (widget) => widget is EditorResponsiveInputField && widget.label == label,
  ),
  matching: find.byType(TextFormField),
);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    SharedPreferences.setMockInitialValues({});
    await ResourceNames.ensureLoaded();
  });

  test('app and bundled plugin locales contain every template message', () {
    final catalogs = [
      ('assets/l10n', 'app_'),
      ('lib/bundled_plugins/preview_img_cplugin/assets/l10n', ''),
      ('lib/bundled_plugins/level_test_cplugin/assets/l10n', ''),
    ];
    for (final (folder, prefix) in catalogs) {
      Set<String> keys(String locale) {
        final data =
            jsonDecode(File('$folder/$prefix$locale.arb').readAsStringSync())
                as Map<String, dynamic>;
        return data.keys.where((key) => !key.startsWith('@')).toSet();
      }

      final template = keys('en');
      for (final locale in ['zh', 'ru']) {
        expect(
          template.difference(keys(locale)),
          isEmpty,
          reason: '$folder/$locale',
        );
      }
    }
  });

  for (final locale in ['zh', 'en', 'ru']) {
    testWidgets(
      'fog editor uses $locale text and keeps serialized identifiers',
      (tester) async {
        final level = PvzLevelFile(objects: []);
        final l10n = lookupAppLocalizations(Locale(locale));
        await tester.pumpWidget(
          _app(
            FairyTaleFogEventScreen(
              rtid: 'RTID(Fog@CurrentLevel)',
              levelFile: level,
              onChanged: () {},
              onBack: () {},
            ),
            locale: locale,
          ),
        );
        await tester.pumpAndSettle();

        for (final label in [
          l10n.mistParameters,
          l10n.fairyFogType,
          l10n.fairyFogMovingTime,
          l10n.range,
          l10n.fairyFogRangeX,
          l10n.fairyFogRangeY,
          l10n.fairyFogRangeWidth,
          l10n.fairyFogRangeHeight,
          l10n.fogPreview,
        ]) {
          expect(find.text(label), findsWidgets);
        }

        final dropdown = find.byType(DropdownButtonFormField<String>);
        await tester.ensureVisible(dropdown);
        await tester.tap(dropdown);
        await tester.pumpAndSettle();
        await tester.tap(find.text(l10n.fairyFogLevel(3)).last);
        await tester.pumpAndSettle();
        final movingTime = _field(l10n.fairyFogMovingTime);
        await tester.ensureVisible(movingTime);
        await tester.enterText(movingTime, '4.5');
        await tester.pumpAndSettle();
        final startColumn = _field(l10n.fairyFogRangeX);
        await tester.ensureVisible(startColumn);
        await tester.enterText(startColumn, '2');
        await tester.pumpAndSettle();

        final json = level.objects.single.toJson();
        expect(json['objclass'], 'FairyTaleFogWaveActionProps');
        final data = json['objdata'] as Map;
        expect(data['FogType'], 'fairy_tale_fog_lvl3');
        expect(data['MovingTime'], 4.5);
        expect((data['Range'] as Map)['mX'], 2);
        expect(data.keys, unorderedEquals(['FogType', 'MovingTime', 'Range']));
        expect(tester.takeException(), isNull);
      },
    );
  }

  testWidgets('Chinese fog labels fit a narrow screen at large text scale', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(360, 800));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(
      _app(
        FairyTaleFogEventScreen(
          rtid: 'RTID(Fog@CurrentLevel)',
          levelFile: PvzLevelFile(objects: []),
          onChanged: () {},
          onBack: () {},
        ),
        scale: 1.8,
      ),
    );
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    await tester.ensureVisible(find.text('迷雾预览'));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });

  testWidgets('wind editor localizes its parameter labels in Chinese', (
    tester,
  ) async {
    final l10n = lookupAppLocalizations(const Locale('zh'));
    await tester.pumpWidget(
      _app(
        FairyTaleWindEventScreen(
          rtid: 'RTID(Wind@CurrentLevel)',
          levelFile: PvzLevelFile(objects: []),
          onChanged: () {},
          onBack: () {},
        ),
      ),
    );
    await tester.pumpAndSettle();
    for (final label in [
      l10n.fairyWindParameters,
      l10n.fairyWindDuration,
      l10n.velocityScale,
    ]) {
      expect(find.text(label), findsWidgets);
    }
    expect(tester.takeException(), isNull);
  });

  testWidgets('rise mode hides column bounds and writes fixed defaults', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(360, 800));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    final object = PvzObject(
      aliases: ['Generator'],
      objClass: 'WaveGeneratorProperties',
      objData: WaveGeneratorPropertiesData().toJson(),
    );
    final l10n = lookupAppLocalizations(const Locale('zh'));
    await tester.pumpWidget(
      _app(
        WaveGeneratorModuleScreen(
          rtid: 'RTID(Generator@CurrentLevel)',
          levelFile: PvzLevelFile(objects: [object]),
          onChanged: () {},
          onBack: () {},
          onRequestZombieSelection: (_) {},
        ),
        scale: 1.5,
      ),
    );
    await tester.pumpAndSettle();
    final toggle = find.widgetWithText(
      SwitchListTile,
      l10n.waveGeneratorRiseFromGround,
    );
    await tester.ensureVisible(toggle);
    await tester.tap(toggle);
    await tester.pumpAndSettle();
    expect(find.textContaining('SpawnColStart'), findsNothing);
    expect(find.textContaining('SpawnColEnd'), findsNothing);
    expect((object.objData as Map)['IsRiseFromGroundMode'], true);
    expect((object.objData as Map)['SpawnColStart'], 2);
    expect((object.objData as Map)['SpawnColEnd'], 2);
    expect(
      find.text(l10n.waveGeneratorRiseFromGroundWarningTitle),
      findsOneWidget,
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('raiding party localizes all spawn parameter labels in Chinese', (
    tester,
  ) async {
    final l10n = lookupAppLocalizations(const Locale('zh'));
    await tester.pumpWidget(
      _app(
        RaidingPartyEventScreen(
          rtid: 'RTID(RaidingParty@CurrentLevel)',
          levelFile: PvzLevelFile(objects: []),
          onChanged: () {},
          onBack: () {},
        ),
      ),
    );
    await tester.pumpAndSettle();
    for (final label in [
      l10n.spawnParameters,
      l10n.groupSize,
      l10n.swashbucklerCount,
      l10n.timeBetweenGroups,
    ]) {
      expect(find.text(label), findsWidgets);
    }
    expect(tester.takeException(), isNull);
  });
}
