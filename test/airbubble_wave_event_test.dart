import 'dart:convert';

import 'package:c_editor/data/pvz_models.dart';
import 'package:c_editor/data/registry/event_registry.dart';
import 'package:c_editor/data/registry/object_order_registry.dart';
import 'package:c_editor/l10n/app_localizations.dart';
import 'package:c_editor/l10n/app_localizations_en.dart';
import 'package:c_editor/l10n/app_localizations_ru.dart';
import 'package:c_editor/l10n/app_localizations_zh.dart';
import 'package:c_editor/screens/editor/events/airbubble_wave_event_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

const _objClass = 'ZombieAirbubbleActionProps';
const _officialData = {
  'BubbleNumber': 10,
  'BubbleHealth': 2000,
  'SpeedRangeMin': 0.5,
  'SpeedRangeMax': 2.5,
};

void main() {
  test(
    'registry entry sits between Eagle Flags and Barrel Crisis',
    () {
      final events = EventRegistry.getAll();
      const eagleFlags = 'SpawnEagleFlagsWaveActionProps';
      const barrelCrisis = 'BarrelWaveActionProps';
      final bubbleRain = events.indexWhere(
        (m) => m.defaultObjClass == _objClass,
      );
      expect(events[bubbleRain - 1].defaultObjClass, eagleFlags);
      expect(events[bubbleRain + 1].defaultObjClass, barrelCrisis);

      final meta = EventRegistry.getByObjClass(_objClass)!;
      expect(meta.defaultAlias, 'AirbubbleEvent');
      expect(meta.category, EventCategory.zombieSpawn);
      expect(meta.initialDataFactory(), isA<ZombieAirbubbleActionPropsData>());
      expect(
        ObjectOrderRegistry.getPriority(_objClass),
        ObjectOrderRegistry.getPriority(eagleFlags) + 1,
      );
      expect(
        ObjectOrderRegistry.getPriority(_objClass),
        lessThan(ObjectOrderRegistry.getPriority(barrelCrisis)),
      );
    },
  );

  test('model round-trips the official payload', () {
    final data = ZombieAirbubbleActionPropsData.fromJson(_officialData);
    expect(data.bubbleNumber, 10);
    expect(data.bubbleHealth, 2000);
    expect(data.speedRangeMin, 0.5);
    expect(data.speedRangeMax, 2.5);
    expect(data.toJson(), _officialData);

    final meta = EventRegistry.getByObjClass(_objClass)!;
    final event = PvzObject(
      aliases: const ['AirbubbleEvent'],
      objClass: meta.defaultObjClass,
      objData: data.toJson(),
    );
    expect(jsonDecode(jsonEncode(event.toJson())), {
      'aliases': ['AirbubbleEvent'],
      'objclass': _objClass,
      'objdata': _officialData,
    });
    expect(meta.summaryProvider!(event), '10');
  });

  test('defaults and partial payloads fall back to the reference values', () {
    final defaults = ZombieAirbubbleActionPropsData();
    expect(defaults.toJson(), _officialData);

    final partial = ZombieAirbubbleActionPropsData.fromJson(const {
      'BubbleNumber': 7,
    });
    expect(partial.bubbleNumber, 7);
    expect(partial.bubbleHealth, 2000);
    expect(partial.speedRangeMin, 0.5);
    expect(partial.speedRangeMax, 2.5);
  });

  test('localized titles exist in every locale', () {
    expect(
      AppLocalizationsEn().eventTitle_ZombieAirbubbleActionProps,
      'Bubble Rain',
    );
    expect(
      AppLocalizationsRu().eventTitle_ZombieAirbubbleActionProps,
      'Дождь из пузырей',
    );
    expect(AppLocalizationsZh().eventTitle_ZombieAirbubbleActionProps, '泡泡雨');
    expect(
      AppLocalizationsEn().eventDesc_ZombieAirbubbleActionProps,
      isNotEmpty,
    );
    expect(AppLocalizationsRu().eventHelpAirbubbleWaveBody, isNotEmpty);
    expect(AppLocalizationsZh().airbubbleParameters, isNotEmpty);
  });

  testWidgets('screen edits bubble count and explains the event parameters', (
    tester,
  ) async {
    final level = PvzLevelFile(
      objects: [
        PvzObject(
          aliases: const ['AirbubbleEvent'],
          objClass: _objClass,
          objData: Map<String, dynamic>.from(_officialData),
        ),
      ],
    );
    var changed = 0;
    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('en'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: AirbubbleWaveEventScreen(
          rtid: 'RTID(AirbubbleEvent@CurrentLevel)',
          levelFile: level,
          onChanged: () => changed++,
          onBack: () {},
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.textContaining('Bubble Rain'), findsOneWidget);

    await tester.enterText(find.widgetWithText(TextFormField, '10'), '25');
    await tester.pumpAndSettle();

    final objData = level.objects.single.objData as Map<String, dynamic>;
    expect(objData['BubbleNumber'], 25);
    expect(objData['BubbleHealth'], 2000);
    expect(objData['SpeedRangeMin'], 0.5);
    expect(objData['SpeedRangeMax'], 2.5);
    expect(changed, greaterThan(0));

    await tester.tap(find.byIcon(Icons.help_outline));
    await tester.pumpAndSettle();
    final dialog = find.byType(AlertDialog);
    final l10n = AppLocalizationsEn();
    for (final text in [
      '• ${l10n.overview}',
      '• ${l10n.eventHelpAirbubbleWaveFieldsTitle}',
      l10n.eventHelpAirbubbleWaveFields,
    ]) {
      expect(
        find.descendant(of: dialog, matching: find.text(text)),
        findsOneWidget,
      );
    }
    expect(tester.takeException(), isNull);
  });
}
