import 'dart:convert';
import 'dart:io';

import 'package:c_editor/bloc/settings/settings_cubit.dart';
import 'package:c_editor/data/pvz_models.dart';
import 'package:c_editor/data/rtid_parser.dart';
import 'package:c_editor/l10n/app_localizations.dart';
import 'package:c_editor/screens/editor/tabs/wave_timeline_tab.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _alias = 'SharedEvent';

class _Fixture {
  _Fixture(List<List<String>> waves) {
    waveManager = WaveManagerData(waveCount: waves.length, waves: waves);
    event = PvzObject(
      aliases: const [_alias],
      objClass: 'SpawnZombiesJitteredWaveActionProps',
      objData: <String, dynamic>{
        'Zombies': <dynamic>[],
        'Nested': <dynamic>[1],
      },
    );
    level = PvzLevelFile(
      objects: [
        event,
        PvzObject(
          aliases: const ['WaveManager'],
          objClass: 'WaveManagerProperties',
          objData: waveManager.toJson(),
        ),
      ],
    );
  }

  late final WaveManagerData waveManager;
  late final PvzObject event;
  late final PvzLevelFile level;
  final rtid = RtidParser.build(_alias, 'CurrentLevel');

  Widget build({
    Locale locale = const Locale('en'),
    double textScale = 1,
    bool scaleTimeline = true,
    SettingsCubit? settings,
  }) {
    final app = MaterialApp(
      locale: locale,
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      theme: ThemeData(platform: TargetPlatform.android),
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(
          context,
        ).copyWith(textScaler: TextScaler.linear(textScale)),
        child: child!,
      ),
      home: Scaffold(
        body: Builder(
          builder: (context) => MediaQuery(
            data: MediaQuery.of(context).copyWith(
              textScaler: TextScaler.linear(scaleTimeline ? textScale : 1),
            ),
            child: WaveTimelineTab(
              levelFile: level,
              parsed: ParsedLevelData(
                waveManager: waveManager,
                objectMap: {_alias: event},
              ),
              onChanged: () {},
              onEditEvent: (_, _) async {},
              onAddEvent: (_) {},
              onEditWaveManagerSettings: () {},
            ),
          ),
        ),
      ),
    );
    return settings == null
        ? app
        : BlocProvider<SettingsCubit>.value(value: settings, child: app);
  }
}

void _setSize(WidgetTester tester, Size size) {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
}

Future<void> _openCopy(WidgetTester tester) async {
  await tester.tap(find.byKey(const ValueKey('waveTimelineWaveNumberTap-1')));
  await tester.pumpAndSettle();
  await tester.tap(find.text(_alias).last);
  await tester.pumpAndSettle();
  await tester.tap(find.byKey(const ValueKey('waveEventCopyButton')));
  await tester.pumpAndSettle();
}

Finder _target(int wave) => find.byKey(ValueKey('waveCopyTarget-$wave'));
Finder get _confirm => find.byKey(const ValueKey('waveCopyTargetConfirm'));
Finder get _targetDialog => find.byKey(const ValueKey('waveCopyTargetDialog'));

Offset _checkboxCenter(WidgetTester tester, int wave) => tester.getCenter(
  find.descendant(of: _target(wave), matching: find.byType(Checkbox)),
);

void main() {
  for (final kind in [PointerDeviceKind.touch, PointerDeviceKind.mouse]) {
    testWidgets(
      '$kind toggles individual checkboxes and rows without drag selection',
      (tester) async {
        _setSize(tester, const Size(900, 1200));
        final rtid = RtidParser.build(_alias, 'CurrentLevel');
        final fixture = _Fixture([
          [rtid],
          <String>[],
          [rtid],
          <String>[],
          <String>[],
        ]);
        await tester.pumpWidget(fixture.build());
        await tester.pumpAndSettle();
        await _openCopy(tester);
        await tester.tap(find.text('Copy reference'));
        await tester.pumpAndSettle();

        if (kind == PointerDeviceKind.mouse) {
          final hover = await tester.createGesture(kind: kind);
          await hover.addPointer(location: _checkboxCenter(tester, 1));
          await hover.moveTo(_checkboxCenter(tester, 4));
          await tester.pump();
          expect(tester.widget<FilledButton>(_confirm).onPressed, isNull);
          await hover.removePointer();
        }

        final checkboxTap = await tester.startGesture(
          _checkboxCenter(tester, 2),
          kind: kind,
        );
        await checkboxTap.up();
        await tester.pump();
        final rowTap = await tester.startGesture(
          tester.getCenter(_target(4)),
          kind: kind,
        );
        await rowTap.up();
        await tester.pump();
        expect(tester.widget<CheckboxListTile>(_target(2)).value, isTrue);
        expect(tester.widget<CheckboxListTile>(_target(4)).value, isTrue);

        // Crossing the checkbox column no longer changes any selections.
        final drag = await tester.startGesture(
          _checkboxCenter(tester, 2),
          kind: kind,
        );
        await drag.moveTo(_checkboxCenter(tester, 4));
        await tester.pump();
        await drag.moveTo(_checkboxCenter(tester, 2));
        await drag.up();
        await tester.pumpAndSettle();
        for (var wave = 1; wave <= 5; wave++) {
          expect(
            tester.widget<CheckboxListTile>(_target(wave)).value,
            [2, 4].contains(wave),
          );
        }

        final clearTap = await tester.startGesture(
          _checkboxCenter(tester, 4),
          kind: kind,
        );
        await clearTap.up();
        await tester.pump();
        expect(tester.widget<CheckboxListTile>(_target(2)).value, isTrue);
        expect(tester.widget<CheckboxListTile>(_target(4)).value, isFalse);
        await tester.tap(_confirm);
        await tester.pumpAndSettle();
        expect(fixture.waveManager.waves, [
          [rtid],
          [rtid],
          [rtid],
          <String>[],
          <String>[],
        ]);
        expect(fixture.level.objects.length, 2);
        expect(tester.takeException(), isNull);
      },
    );
  }

  testWidgets('touch dragging the checkbox column scrolls without selecting', (
    tester,
  ) async {
    _setSize(tester, const Size(900, 1200));
    final rtid = RtidParser.build(_alias, 'CurrentLevel');
    final fixture = _Fixture([
      [rtid],
      for (var index = 1; index < 40; index++) <String>[],
    ]);
    await tester.pumpWidget(fixture.build());
    await tester.pumpAndSettle();
    await _openCopy(tester);
    await tester.tap(find.text('Copy reference'));
    await tester.pumpAndSettle();
    await tester.tapAt(_checkboxCenter(tester, 2));
    await tester.pump();
    final scrollable = find.descendant(
      of: _targetDialog,
      matching: find.byType(Scrollable),
    );
    final scrollState = tester.state<ScrollableState>(scrollable);
    final start = _checkboxCenter(tester, 5);
    final gesture = await tester.startGesture(start);
    await gesture.moveTo(start - const Offset(0, 120));
    await tester.pump();
    await gesture.moveTo(start - const Offset(0, 240));
    await gesture.up();
    await tester.pumpAndSettle();
    expect(scrollState.position.pixels, greaterThan(0));
    for (var wave = 1; wave <= 40; wave++) {
      expect(tester.widget<CheckboxListTile>(_target(wave)).value, wave == 2);
    }
    expect(tester.widget<FilledButton>(_confirm).onPressed, isNotNull);
    expect(tester.takeException(), isNull);
  });

  testWidgets('trackpad scrolling over checkboxes does not select waves', (
    tester,
  ) async {
    _setSize(tester, const Size(900, 1200));
    final rtid = RtidParser.build(_alias, 'CurrentLevel');
    final fixture = _Fixture([
      [rtid],
      for (var index = 1; index < 40; index++) <String>[],
    ]);
    await tester.pumpWidget(fixture.build());
    await tester.pumpAndSettle();
    await _openCopy(tester);
    await tester.tap(find.text('Copy reference'));
    await tester.pumpAndSettle();
    final scrollable = find.descendant(
      of: _targetDialog,
      matching: find.byType(Scrollable),
    );
    final scrollState = tester.state<ScrollableState>(scrollable);
    final start = _checkboxCenter(tester, 2);
    final trackpad = await tester.createGesture(
      kind: PointerDeviceKind.trackpad,
    );
    await trackpad.panZoomStart(start);
    await trackpad.panZoomUpdate(start, pan: const Offset(0, -100));
    await tester.pump();
    await trackpad.panZoomUpdate(start, pan: const Offset(0, -200));
    await tester.pump();
    await trackpad.panZoomEnd();
    await tester.pumpAndSettle();
    expect(scrollState.position.pixels, greaterThan(0));
    for (var wave = 1; wave <= 40; wave++) {
      expect(tester.widget<CheckboxListTile>(_target(wave)).value, isFalse);
    }
    expect(tester.widget<FilledButton>(_confirm).onPressed, isNull);
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'reference selection is empty by default and skips existing references',
    (tester) async {
      _setSize(tester, const Size(900, 1200));
      final rtid = RtidParser.build(_alias, 'CurrentLevel');
      final fixture = _Fixture([
        [rtid],
        <String>[],
        [rtid],
        <String>[],
      ]);
      await tester.pumpWidget(fixture.build());
      await tester.pumpAndSettle();
      await _openCopy(tester);
      await tester.tap(find.text('Copy reference'));
      await tester.pumpAndSettle();

      expect(find.text('Select target waves'), findsOneWidget);
      expect(
        find.descendant(of: _targetDialog, matching: find.byType(TextField)),
        findsNothing,
      );
      expect(find.text('Already contains this event'), findsNWidgets(2));
      expect(tester.widget<FilledButton>(_confirm).onPressed, isNull);
      for (var wave = 1; wave <= 4; wave++) {
        expect(tester.widget<CheckboxListTile>(_target(wave)).value, isFalse);
      }
      await tester.tap(_target(2));
      await tester.pump();
      expect(tester.widget<CheckboxListTile>(_target(2)).value, isTrue);
      expect(tester.widget<FilledButton>(_confirm).onPressed, isNotNull);
      await tester.tap(_target(2));
      await tester.pump();
      expect(tester.widget<FilledButton>(_confirm).onPressed, isNull);

      for (var wave = 1; wave <= 3; wave++) {
        await tester.tap(_target(wave));
        await tester.pump();
      }
      await tester.tap(_confirm);
      await tester.pumpAndSettle();
      expect(fixture.waveManager.waves, [
        [rtid],
        [rtid],
        [rtid],
        <String>[],
      ]);
      expect(fixture.level.objects.length, 2);
    },
  );

  testWidgets(
    'independent copies preserve naming flow and include source wave',
    (tester) async {
      _setSize(tester, const Size(900, 1200));
      final rtid = RtidParser.build(_alias, 'CurrentLevel');
      final fixture = _Fixture([
        [rtid],
        <String>[],
        [rtid],
      ]);
      await tester.pumpWidget(fixture.build());
      await tester.pumpAndSettle();
      await _openCopy(tester);
      await tester.tap(find.text('Deep copy'));
      await tester.pumpAndSettle();
      final l10n = lookupAppLocalizations(const Locale('en'));
      expect(find.text(l10n.aliasLabel), findsWidgets);
      final nameDialog = find.ancestor(
        of: find.text(l10n.aliasLabel),
        matching: find.byType(AlertDialog),
      );
      await tester.enterText(
        find.descendant(of: nameDialog, matching: find.byType(TextField)),
        'Independent',
      );
      await tester.tap(
        find.descendant(of: nameDialog, matching: find.text('Confirm')),
      );
      await tester.pumpAndSettle();
      expect(find.text('Select target waves'), findsOneWidget);
      expect(find.text('Already contains this event'), findsNWidgets(2));
      for (var wave = 1; wave <= 3; wave++) {
        await tester.tap(_target(wave));
        await tester.pump();
      }
      await tester.tap(_confirm);
      await tester.pumpAndSettle();

      final copies = fixture.level.objects
          .where(
            (object) => object.aliases?.first.startsWith('Independent') == true,
          )
          .toList();
      expect(copies, hasLength(3));
      expect(
        copies.map((object) => object.aliases!.first).toSet(),
        hasLength(3),
      );
      for (var index = 0; index < 3; index++) {
        expect(
          fixture.waveManager.waves[index].last,
          RtidParser.build(copies[index].aliases!.first, 'CurrentLevel'),
        );
        expect(copies[index].objData, fixture.event.objData);
        expect(
          identical(copies[index].objData, fixture.event.objData),
          isFalse,
        );
      }
      (copies.first.objData['Nested'] as List<dynamic>).add(2);
      expect(fixture.event.objData['Nested'], [1]);
      expect(copies.last.objData['Nested'], [1]);
      expect(fixture.waveManager.waves.first.first, rtid);
      expect(fixture.waveManager.waves.last.first, rtid);
    },
  );

  testWidgets(
    'deep copy uses its generated alias when creation prompts are disabled',
    (tester) async {
      _setSize(tester, const Size(900, 1200));
      SharedPreferences.setMockInitialValues({
        'locale': 'en',
        'theme_mode': 'light',
      });
      final preferences = await SharedPreferences.getInstance();
      final settings = SettingsCubit(preferences);
      addTearDown(settings.close);
      final rtid = RtidParser.build(_alias, 'CurrentLevel');
      final fixture = _Fixture([
        [rtid],
        <String>[],
      ]);

      await tester.pumpWidget(fixture.build(settings: settings));
      await tester.pumpAndSettle();
      await _openCopy(tester);
      await tester.tap(find.text('Deep copy'));
      await tester.pumpAndSettle();

      final l10n = lookupAppLocalizations(const Locale('en'));
      expect(
        find.ancestor(
          of: find.text(l10n.aliasLabel),
          matching: find.byType(AlertDialog),
        ),
        findsNothing,
      );
      expect(find.text('Select target waves'), findsOneWidget);
      await tester.tap(_target(2));
      await tester.pump();
      await tester.tap(_confirm);
      await tester.pumpAndSettle();

      expect(
        fixture.level.objects.any(
          (object) => object.aliases?.first == '${_alias}_copy',
        ),
        isTrue,
      );
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('canceling target selection does not modify waves or objects', (
    tester,
  ) async {
    _setSize(tester, const Size(900, 1200));
    final rtid = RtidParser.build(_alias, 'CurrentLevel');
    final fixture = _Fixture([
      [rtid],
      <String>[],
    ]);
    await tester.pumpWidget(fixture.build());
    await tester.pumpAndSettle();
    await _openCopy(tester);
    await tester.tap(find.text('Copy reference'));
    await tester.pumpAndSettle();
    await tester.tap(_target(2));
    await tester.pump();
    await tester.tap(
      find.descendant(of: _targetDialog, matching: find.text('Cancel')),
    );
    await tester.pumpAndSettle();
    expect(fixture.waveManager.waves, [
      [rtid],
      <String>[],
    ]);
    expect(fixture.level.objects.length, 2);
  });

  testWidgets(
    'target waves stay scrollable in short landscape with enlarged text',
    (tester) async {
      _setSize(tester, const Size(900, 1200));
      final rtid = RtidParser.build(_alias, 'CurrentLevel');
      final fixture = _Fixture([
        [rtid],
        for (var index = 1; index < 40; index++) <String>[],
      ]);
      // Keep the unrelated fixed-width timeline number/flag cells at their
      // normal scale. Navigator dialogs retain the app's enlarged text scale.
      await tester.pumpWidget(
        fixture.build(textScale: 1.3, scaleTimeline: false),
      );
      await tester.pumpAndSettle();
      expect(
        tester.takeException(),
        isNull,
        reason: 'initial timeline fixture',
      );
      await _openCopy(tester);
      expect(
        tester.takeException(),
        isNull,
        reason: 'existing event/copy choice sheets',
      );
      await tester.tap(find.text('Copy reference'));
      await tester.pumpAndSettle();
      expect(
        tester.takeException(),
        isNull,
        reason: 'target dialog before resize',
      );
      tester.view.physicalSize = const Size(900, 320);
      await tester.pumpAndSettle();
      expect(
        tester.takeException(),
        isNull,
        reason: 'target dialog after resize',
      );

      final dialog = find.byKey(const ValueKey('waveCopyTargetDialog'));
      expect(MediaQuery.textScalerOf(tester.element(dialog)).scale(10), 13);
      final scrollable = find.descendant(
        of: dialog,
        matching: find.byType(Scrollable),
      );
      expect(scrollable, findsOneWidget);
      await tester.scrollUntilVisible(
        _target(40),
        160,
        scrollable: scrollable,
        maxScrolls: 40,
      );
      for (var wave = 1; wave <= 40; wave++) {
        expect(tester.widget<CheckboxListTile>(_target(wave)).value, isFalse);
      }
      await tester.tap(_target(40));
      await tester.pump();
      expect(tester.widget<CheckboxListTile>(_target(40)).value, isTrue);
      expect(tester.getRect(_confirm).bottom, lessThanOrEqualTo(320));
      expect(tester.takeException(), isNull);
      await tester.tap(_confirm);
      await tester.pumpAndSettle();
      expect(fixture.waveManager.waves.last, [rtid]);
      expect(fixture.waveManager.waves[1], isEmpty);
    },
  );

  test('target wave localizations only describe existing reference skips', () {
    for (final locale in ['zh', 'en', 'ru']) {
      final arb =
          jsonDecode(File('assets/l10n/app_$locale.arb').readAsStringSync())
              as Map<String, dynamic>;
      expect(arb.containsKey('targetWaveIndexHint'), isFalse);
      expect(arb['targetWaveIndexHelper'], isNot(contains('\n')));
      expect(arb['targetWaveAlreadyContainsEvent'], isA<String>());
    }
    final zh =
        jsonDecode(File('assets/l10n/app_zh.arb').readAsStringSync())
            as Map<String, dynamic>;
    expect(zh['copyEventTarget'], '选择目标波次');
    expect(zh['targetWaveAlreadyContainsEvent'], '已包含该事件');
    expect(zh['targetWaveIndexHelper'], '复制引用时，已包含该事件的波次会自动跳过。');
  });
}
