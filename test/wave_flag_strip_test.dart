import 'package:c_editor/l10n/app_localizations.dart';
import 'package:c_editor/widgets/wave_flag_strip.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

const _sectionColor = Color(0xFF1565C0);

Widget _app({
  required int waveCount,
  required int interval,
  TargetPlatform platform = TargetPlatform.windows,
  double textScale = 1,
}) => MaterialApp(
  locale: const Locale('zh'),
  localizationsDelegates: AppLocalizations.localizationsDelegates,
  supportedLocales: AppLocalizations.supportedLocales,
  theme: ThemeData(platform: platform),
  builder: (context, child) => MediaQuery(
    data: MediaQuery.of(
      context,
    ).copyWith(textScaler: TextScaler.linear(textScale)),
    child: child!,
  ),
  home: Scaffold(
    body: Center(
      child: WaveFlagStrip(
        waveCount: waveCount,
        isFlagWave: (wave) => wave % interval == 0 || wave == waveCount,
        color: _sectionColor,
      ),
    ),
  ),
);

Finder _segment(int endWave) =>
    find.byKey(ValueKey('waveFlagStripSegment-$endWave'));

Finder _flag(int wave) => find.byKey(ValueKey('waveFlagStripFlag-$wave'));

Finder _label(int wave) => find.byKey(ValueKey('waveFlagStripLabel-$wave'));

void main() {
  testWidgets('hovering the wave ruler reveals intervals and flag details', (
    tester,
  ) async {
    await tester.pumpWidget(_app(waveCount: 12, interval: 5));
    await tester.pumpAndSettle();

    final track = find.byKey(const ValueKey('waveFlagStripTrack'));
    final decoration = tester.widget<DecoratedBox>(track).decoration;
    expect((decoration as BoxDecoration).color, _sectionColor);
    expect(
      find.byKey(const ValueKey('waveFlagStripTicks')),
      paints..line(color: _sectionColor),
    );
    expect(tester.getSize(track).width, greaterThan(240));
    expect(
      tester.getCenter(track).dx,
      closeTo(tester.getCenter(find.byType(Scaffold)).dx, 0.5),
    );

    final mouse = await tester.createGesture(kind: PointerDeviceKind.mouse);
    await mouse.addPointer(location: Offset.zero);

    Future<void> expectHover(Finder target, String message) async {
      expect(find.text(message), findsNothing);
      await mouse.moveTo(tester.getCenter(target));
      await tester.pump(const Duration(milliseconds: 500));
      await tester.pumpAndSettle();
      expect(find.text(message), findsOneWidget);
    }

    await expectHover(_segment(10), '第6波 – 第10波\n共5波');
    await expectHover(_segment(12), '第11波 – 第12波\n共2波');
    await expectHover(_flag(10), '旗帜波 · 第10波\n共12波');

    await mouse.removePointer();
    await tester.pumpAndSettle();
  });

  testWidgets('long-pressing an interval or flag reveals its tooltip', (
    tester,
  ) async {
    await tester.pumpWidget(
      _app(waveCount: 12, interval: 5, platform: TargetPlatform.android),
    );
    await tester.pumpAndSettle();

    await tester.longPress(_segment(5));
    await tester.pumpAndSettle();
    expect(find.text('第1波 – 第5波\n共5波'), findsOneWidget);

    final flagTarget = tester.getRect(_flag(12));
    expect(flagTarget.width, greaterThanOrEqualTo(44));
    expect(flagTarget.height, greaterThanOrEqualTo(44));
    await tester.longPressAt(flagTarget.topLeft + const Offset(4, 4));
    await tester.pumpAndSettle();
    expect(find.text('旗帜波 · 第12波\n共12波'), findsOneWidget);
    await tester.pump(const Duration(seconds: 3));
    await tester.pumpAndSettle();
  });

  testWidgets('dense labels stay on one line and can be scrolled', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(320, 640);
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      _app(
        waveCount: 120,
        interval: 5,
        platform: TargetPlatform.android,
        textScale: 2.5,
      ),
    );
    await tester.pumpAndSettle();

    final labels = [
      tester.getRect(_label(1)),
      for (var wave = 5; wave <= 120; wave += 5) tester.getRect(_label(wave)),
    ];
    for (var i = 0; i < labels.length; i++) {
      expect(labels[i].top, closeTo(labels.first.top, 0.5));
      for (var j = i + 1; j < labels.length; j++) {
        expect(labels[i].overlaps(labels[j]), isFalse);
      }
    }
    expect(
      find.byKey(const ValueKey('waveFlagStripTicks')),
      paintsExactlyCountTimes(#drawLine, 120),
    );
    expect(_label(1).hitTestable(), findsOneWidget);
    expect(_label(120).hitTestable(), findsNothing);

    await tester.dragUntilVisible(
      _label(120).hitTestable(),
      find.byType(SingleChildScrollView),
      const Offset(220, 0),
      maxIteration: 40,
    );
    await tester.pumpAndSettle();

    expect(_label(120).hitTestable(), findsOneWidget);
    expect(_flag(120).hitTestable(), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('one wave has one centered label and flag', (tester) async {
    await tester.pumpWidget(_app(waveCount: 1, interval: 5));
    await tester.pumpAndSettle();

    expect(find.text('第1波'), findsOneWidget);
    expect(find.byIcon(Icons.flag), findsOneWidget);
    expect(
      tester.getCenter(_label(1)).dx,
      closeTo(tester.getCenter(_flag(1)).dx, 0.5),
    );
    expect(tester.takeException(), isNull);
  });
}
