import 'package:c_editor/data/level_parser.dart';
import 'package:c_editor/data/pvz_models.dart';
import 'package:c_editor/l10n/app_localizations.dart';
import 'package:c_editor/screens/editor/tabs/wave_generator_tab.dart';
import 'package:c_editor/screens/editor/tabs/wave_timeline_tab.dart';
import 'package:c_editor/widgets/wave_number_label.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

PvzLevelFile _level({required bool generator, required int waveCount}) {
  final interval = waveCount ~/ 2;
  return PvzLevelFile(
    objects: [
      PvzObject(
        aliases: const ['Waves'],
        objClass: generator
            ? 'WaveGeneratorProperties'
            : 'WaveManagerProperties',
        objData: generator
            ? WaveGeneratorPropertiesData(
                flagWaveInterval: interval,
                waves: List.generate(
                  waveCount,
                  (_) => WaveGeneratorWaveData(disableRandomSpawns: true),
                ),
              ).toJson()
            : WaveManagerData(
                flagWaveInterval: interval,
                waveCount: waveCount,
                waves: List.generate(waveCount, (_) => <String>[]),
              ).toJson(),
      ),
    ],
  );
}

Widget _app({
  required PvzLevelFile level,
  required bool generator,
  required double scale,
  required TargetPlatform platform,
  required void Function(int) onEditWave,
}) => MaterialApp(
  locale: const Locale('en'),
  supportedLocales: AppLocalizations.supportedLocales,
  localizationsDelegates: AppLocalizations.localizationsDelegates,
  theme: ThemeData(platform: platform),
  builder: (context, child) => MediaQuery(
    data: MediaQuery.of(context).copyWith(textScaler: TextScaler.linear(scale)),
    child: child!,
  ),
  home: Scaffold(
    body: generator
        ? WaveGeneratorTab(
            levelFile: level,
            parsed: LevelParser.parseLevel(level),
            onChanged: () {},
            onEditWave: onEditWave,
          )
        : WaveTimelineTab(
            levelFile: level,
            parsed: LevelParser.parseLevel(level),
            onChanged: () {},
            onEditEvent: (_, _) async {},
            onAddEvent: (_) {},
            onEditWaveManagerSettings: () {},
          ),
  ),
);

Finder _number(int wave) => find.byWidgetPredicate(
  (widget) => widget is WaveNumberLabel && widget.waveNumber == wave,
);

Future<void> _expectFlagVisible(
  WidgetTester tester,
  int wave, {
  required bool generator,
}) async {
  final number = _number(wave);
  await tester.scrollUntilVisible(
    number,
    400,
    maxScrolls: 200,
    scrollable: find.byType(Scrollable).first,
  );
  await tester.pumpAndSettle();
  expect(tester.takeException(), isNull);

  final flag = find.descendant(of: number, matching: find.byIcon(Icons.flag));
  final text = find.descendant(of: number, matching: find.text('$wave'));
  expect(flag, findsOneWidget);
  final numberRect = tester.getRect(number).inflate(0.01);
  final flagRect = tester.getRect(flag);
  final textRect = tester.getRect(text);
  for (final rect in [flagRect, textRect]) {
    expect(numberRect.contains(rect.topLeft), isTrue);
    expect(numberRect.contains(rect.bottomRight), isTrue);
  }
  expect(flagRect.width, greaterThanOrEqualTo(12));
  expect(flagRect.height, greaterThanOrEqualTo(12));
  expect(textRect.right, lessThanOrEqualTo(flagRect.left));
  expect(tester.widget<Text>(text).softWrap, isFalse);

  if (generator) {
    final card = find.ancestor(of: number, matching: find.byType(Card)).first;
    final content = find.descendant(
      of: card,
      matching: find.text(
        lookupAppLocalizations(const Locale('en')).waveGeneratorEmptyWaveRow,
      ),
    );
    expect(flagRect.right, lessThan(tester.getRect(content).left));
  } else {
    final content = find.byKey(ValueKey('waveTimelineDropTarget-$wave'));
    expect(flagRect.right, lessThanOrEqualTo(tester.getRect(content).left));
    final tapTarget = tester.getRect(
      find.byKey(ValueKey('waveTimelineWaveNumberTap-$wave')),
    );
    expect(tapTarget.contains(textRect.topLeft), isTrue);
    expect(tapTarget.contains(textRect.bottomRight), isTrue);
  }
}

void main() {
  for (final generator in [false, true]) {
    for (final platform in [TargetPlatform.android, TargetPlatform.windows]) {
      for (final scale in [1.0, 2.5]) {
        testWidgets(
          'both flags fit while resizing: generator=$generator, $platform, scale=$scale',
          (tester) async {
            tester.view.devicePixelRatio = 1;
            tester.view.physicalSize = const Size(1200, 1000);
            addTearDown(tester.view.reset);
            int? editedWave;
            await tester.pumpWidget(
              _app(
                level: _level(generator: generator, waveCount: 20),
                generator: generator,
                scale: scale,
                platform: platform,
                onEditWave: (wave) => editedWave = wave,
              ),
            );
            await tester.pumpAndSettle();

            for (final width in [1200.0, 320.0, 480.0]) {
              tester.view.physicalSize = Size(width, 1000);
              await tester.pumpAndSettle();
              tester
                  .state<ScrollableState>(find.byType(Scrollable).first)
                  .position
                  .jumpTo(0);
              await tester.pumpAndSettle();
              await _expectFlagVisible(tester, 10, generator: generator);
              await _expectFlagVisible(tester, 20, generator: generator);
            }

            await tester.tap(_number(20));
            await tester.pumpAndSettle();
            if (generator) {
              expect(editedWave, 20);
            } else {
              expect(find.text('Wave 20 events'), findsOneWidget);
            }
            expect(tester.takeException(), isNull);
          },
        );
      }
    }

    testWidgets(
      'three-digit flag wave fits on narrow screens with large text: generator=$generator',
      (tester) async {
        tester.view.devicePixelRatio = 1;
        tester.view.physicalSize = const Size(320, 1000);
        addTearDown(tester.view.reset);
        await tester.pumpWidget(
          _app(
            level: _level(generator: generator, waveCount: 100),
            generator: generator,
            scale: 2.5,
            platform: TargetPlatform.android,
            onEditWave: (_) {},
          ),
        );
        await tester.pumpAndSettle();
        await _expectFlagVisible(tester, 100, generator: generator);
        expect(tester.takeException(), isNull);
      },
    );
  }
}
