import 'dart:convert';
import 'dart:io';

import 'package:c_editor/bundled_plugins/preview_img_cplugin/lib/src/preview/preview_module_info.dart';
import 'package:c_editor/bundled_plugins/preview_img_cplugin/lib/src/preview/preview_module_resource_names.dart';
import 'package:c_editor/data/pvz_models.dart';
import 'package:c_editor/l10n/app_localizations.dart';
import 'package:c_editor/l10n/resource_names.dart';
import 'package:c_editor/plugins/plugin_arb.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _pluginRoot = 'lib/bundled_plugins/preview_img_cplugin/assets/l10n';

PreviewModuleL10n _localizer(String locale) {
  final entries = parsePluginArbBundle(
    File('$_pluginRoot/$locale.arb').readAsStringSync(),
  );
  return (key, fallback, [args]) {
    // Do not silently pass tests through the English fallback.
    expect(entries, contains(key), reason: '$locale: $key');
    final entry = entries[key]!;
    return formatPluginArbMessage(
      entry.pattern,
      args: args ?? const {},
      locale: locale,
      placeholders: entry.placeholders,
    );
  };
}

PreviewModuleInfoPayload _build(
  String objClass,
  Map<String, dynamic> data,
  PreviewModuleL10n t, {
  BuildContext? context,
}) {
  final level = PvzLevelFile(
    objects: [
      PvzObject(aliases: ['Module'], objClass: objClass, objData: data),
    ],
  );
  final original = jsonEncode(level.toJson());
  final payload = previewModuleInfoBuild(
    levelFile: level,
    objClass: objClass,
    t: t,
    resourceName: context == null
        ? null
        : (kind, id) => previewModuleResourceName(context, level, kind, id),
  );
  expect(
    jsonEncode(level.toJson()),
    original,
    reason: 'Display translation must not change serialized identifiers',
  );
  return payload;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(() async {
    SharedPreferences.setMockInitialValues({});
    await loadPreviewModuleResourceNames();
  });

  for (final locale in ['zh', 'en', 'ru']) {
    final t = _localizer(locale);

    test('$locale seed-bank values are localized and custom modes survive', () {
      for (final entry in {
        'chooser': t('previewGenSeedBankChooser', ''),
        'preset': t('previewGenSeedBankPreset', ''),
        'my_custom_mode': 'my_custom_mode',
      }.entries) {
        final payload = _build('SeedBankProperties', {
          'SelectionMethod': entry.key,
          'OverrideSeedSlotsCount': 8,
          'GridItemMode': true,
        }, t);
        expect(
          payload.lines.first,
          t('previewGenSeedBankMethod', '', {'method': entry.value}),
        );
        expect(
          payload.textBody,
          contains(t('previewGenSeedBankGridItemMode', '')),
        );
      }
    });

    test('$locale railcart names agree in text and icon-panel notes', () {
      for (final entry in {
        'railcart_cowboy': 'previewGenRailcartCowboy',
        'railcart_future': 'previewGenRailcartFuture',
        'railcart_egypt': 'previewGenRailcartEgypt',
        'railcart_pirate': 'previewGenRailcartPirate',
        'railcart_worldcup': 'previewGenRailcartWorldcup',
        'my_custom_cart': '',
      }.entries) {
        final payload = _build(
          'RailcartProperties',
          RailcartPropertiesData(
            railcartType: entry.key,
            railcarts: [RailcartData(column: 2, row: 3)],
          ).toJson(),
          t,
        );
        final expected = t('previewGenRailcartType', '', {
          'type': entry.value.isEmpty ? entry.key : t(entry.value, ''),
        });
        expect(payload.lines.first, expected);
        expect(payload.gridNotes.single, expected);
        final item = payload.sections.single.items.single;
        expect(item.id, '${entry.key}_2_3');
        expect((item.gridX, item.gridY), (2, 3));
      }
    });

    test('$locale weight, level and time labels use translated units', () {
      final weight = t('previewGenWeight', '', {'weight': 80});
      final conveyor = _build(
        'ConveyorSeedBankProperties',
        ConveyorBeltData(
          initialPlantList: [
            InitialPlantListData(plantType: 'peashooter', weight: 80),
          ],
        ).toJson(),
        t,
      );
      expect(conveyor.sections.single.items.single.label, weight);
      final rain = _build(
        'SeedRainProperties',
        SeedRainPropertiesData(
          seedRains: [SeedRainItem(plantTypeName: 'peashooter', weight: 80)],
        ).toJson(),
        t,
      );
      expect(rain.textBody, contains(weight));
      final dropShip = _build(
        'DropShipProperties',
        DropShipPropertiesData(
          appearWaves: [DropShipAppearWaveData(wave: 0, impLv: 3, imp: 1)],
        ).toJson(),
        t,
      );
      expect(
        dropShip.sections.single.items.first.label,
        t('previewGenLevel', '', {'level': 3}),
      );
      final sun = _build('SunDropperProperties', {
        'InitialSunDropDelay': 4.5,
      }, t);
      expect(
        sun.sections.single.items.single.label,
        t('previewGenSeconds', '', {'n': '4.5'}),
      );
    });

    test(
      '$locale generic booleans are translated without replacing strings',
      () {
        final payload = _build('PreviewCustomModule', {
          'Enabled': true,
          'Disabled': false,
          'CustomLabel': 'preset',
        }, t);
        expect(
          payload.lines,
          contains('Enabled: ${t('previewGenValueYes', '')}'),
        );
        expect(
          payload.lines,
          contains('Disabled: ${t('previewGenValueNo', '')}'),
        );
        expect(payload.lines, contains('CustomLabel: preset'));
      },
    );

    testWidgets('$locale conditions resolve in text, notes and generic lists', (
      tester,
    ) async {
      late BuildContext context;
      await tester.pumpWidget(
        MaterialApp(
          locale: Locale(locale),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Builder(
            builder: (value) {
              context = value;
              return const SizedBox();
            },
          ),
        ),
      );
      await tester.pumpAndSettle();
      for (final id in ['icecubed', 'freeze', 'stun', 'custom_condition']) {
        final key = 'zombieCondition_$id';
        final value = ResourceNames.lookup(context, key);
        final expected = value == key ? id : value;
        final payload = _build(
          'InitialZombieProperties',
          {
            'InitialZombiePlacements': [
              {'TypeName': 'mummy', 'Condition': id, 'GridX': 1, 'GridY': 2},
            ],
          },
          t,
          context: context,
        );
        expect(payload.textBody, contains('($expected)'));
        expect(payload.gridNotes.single, endsWith(': $expected'));
        final item = payload.sections.single.items.single;
        expect(item.id, 'mummy');
        expect((item.gridX, item.gridY), (1, 2));
        final generic = _build(
          'ApplyZombieConditionsChallengeProps',
          {
            'Conditions': [id],
          },
          t,
          context: context,
        );
        expect(generic.lines, contains('  · $expected'));
      }
      final plant = _build(
        'CustomPlantModule',
        {
          'PlantConditions': ['icecubed'],
        },
        t,
        context: context,
      );
      expect(
        plant.textBody,
        contains(ResourceNames.lookup(context, 'plantCondition_icecubed')),
      );
    });
  }
}
