import 'package:c_editor/bundled_plugins/preview_img_cplugin/lib/src/preview/preview_document.dart';
import 'package:c_editor/bundled_plugins/preview_img_cplugin/lib/src/preview/preview_generator_pickers.dart';
import 'package:c_editor/bundled_plugins/preview_img_cplugin/lib/src/preview/preview_generator_screen.dart';
import 'package:c_editor/bundled_plugins/preview_img_cplugin/lib/src/preview/preview_picker_session.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'helpers/preview_scrollbar_gesture.dart';

String _t(String key, [String? fallback]) => fallback ?? key;

Future<void> _pumpLandscape(
  WidgetTester tester,
  void Function(BuildContext context) open, {
  double height = 300,
  double scale = 1.6,
  TargetPlatform platform = TargetPlatform.android,
}) async {
  tester.view.physicalSize = Size(900, height);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  await tester.pumpWidget(
    MaterialApp(
      theme: ThemeData(platform: platform),
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(
          context,
        ).copyWith(textScaler: TextScaler.linear(scale)),
        child: child!,
      ),
      home: Builder(
        builder: (context) => Scaffold(
          body: Center(
            child: TextButton(
              onPressed: () => open(context),
              child: const Text('Open'),
            ),
          ),
        ),
      ),
    ),
  );
  await tester.tap(find.text('Open'));
  await tester.pumpAndSettle();
}

void main() {
  for (final platform in [TargetPlatform.android, TargetPlatform.iOS]) {
    testWidgets('figure thumb reaches its last item on ${platform.name}', (
      tester,
    ) async {
      (PreviewShapeKind, bool)? selected;
      final session = PreviewPickerSession();
      await _pumpLandscape(tester, (context) async {
        selected = await showPreviewFiguresPicker(
          context: context,
          t: _t,
          session: session,
        );
      }, platform: platform);
      final scroll = tester
          .widget<SingleChildScrollView>(
            find.byKey(const ValueKey('previewFiguresScroll')),
          )
          .controller!;
      await dragPreviewVerticalScrollbar(
        tester,
        const ValueKey('previewFiguresScrollbar'),
        distance: 180,
      );
      expect(scroll.offset, greaterThan(100));
      final last = find.byKey(const ValueKey('previewFigure-star-true'));
      expect(last.hitTestable(), findsOneWidget);
      expect(selected, isNull);
      final savedOffset = scroll.offset;
      await tester.tap(last);
      await tester.pumpAndSettle();
      expect(selected, (PreviewShapeKind.star, true));
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();
      expect(
        tester
            .widget<SingleChildScrollView>(
              find.byKey(const ValueKey('previewFiguresScroll')),
            )
            .controller!
            .offset,
        closeTo(savedOffset, 1),
      );
      expect(last.hitTestable(), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets(
      'module thumb scrolls while cancel remains visible on ${platform.name}',
      (tester) async {
        final session = PreviewPickerSession();
        await _pumpLandscape(tester, (context) {
          showPreviewModuleInfoPicker(
            context: context,
            session: session,
            classes: List.generate(25, (index) => 'Module$index'),
            titleForClass: (_, objClass) => 'Long localized title $objClass',
            t: _t,
          );
        }, platform: platform);
        final scroll = tester
            .widget<SingleChildScrollView>(
              find.byKey(const ValueKey('previewModuleInfoScroll')),
            )
            .controller!;
        await dragPreviewVerticalScrollbar(
          tester,
          const ValueKey('previewModuleInfoScrollbar'),
          distance: 80,
        );
        expect(scroll.offset, greaterThan(100));
        final savedOffset = scroll.offset;
        expect(
          find.byKey(const ValueKey('previewModuleInfoCancel')).hitTestable(),
          findsOneWidget,
        );
        await tester.tap(find.byKey(const ValueKey('previewModuleInfoCancel')));
        await tester.pumpAndSettle();
        expect(
          find.byKey(const ValueKey('previewModuleInfoPicker')),
          findsNothing,
        );
        await tester.tap(find.text('Open'));
        await tester.pumpAndSettle();
        expect(
          tester
              .widget<SingleChildScrollView>(
                find.byKey(const ValueKey('previewModuleInfoScroll')),
              )
              .controller!
              .offset,
          closeTo(savedOffset, 1),
        );
        expect(tester.takeException(), isNull);
      },
    );
  }
  testWidgets('figure sheet scrolls to and selects its last landscape item', (
    tester,
  ) async {
    (PreviewShapeKind, bool)? selected;
    await _pumpLandscape(tester, (context) async {
      selected = await showPreviewFiguresPicker(context: context, t: _t);
    });
    expect(tester.takeException(), isNull);
    final lastFigure = find.byKey(const ValueKey('previewFigure-star-true'));
    expect(lastFigure.hitTestable(), findsNothing);
    final scrollable = find.descendant(
      of: find.byKey(const ValueKey('previewFiguresScroll')),
      matching: find.byType(Scrollable),
    );
    await tester.scrollUntilVisible(lastFigure, 140, scrollable: scrollable);
    expect(lastFigure.hitTestable(), findsOneWidget);
    await tester.tap(lastFigure);
    await tester.pumpAndSettle();
    expect(selected, (PreviewShapeKind.star, true));
    expect(tester.takeException(), isNull);
  });

  testWidgets('module picker scrolls through its header to the final module', (
    tester,
  ) async {
    String? selected;
    await _pumpLandscape(tester, (context) async {
      selected = await showPreviewModuleInfoPicker(
        context: context,
        classes: List.generate(14, (index) => 'Module$index'),
        titleForClass: (_, objClass) => 'A long localized title for $objClass',
        t: _t,
      );
    });
    final lastModule = find.byKey(const ValueKey('previewModuleInfo-Module13'));
    expect(lastModule.hitTestable(), findsNothing);
    expect(
      find.byKey(const ValueKey('previewModuleInfoCancel')).hitTestable(),
      findsOneWidget,
    );
    final scrollable = find
        .descendant(
          of: find.byKey(const ValueKey('previewModuleInfoPicker')),
          matching: find.byType(Scrollable),
        )
        .first;
    await tester.scrollUntilVisible(
      lastModule,
      160,
      scrollable: scrollable,
      maxScrolls: 40,
    );
    await tester.tap(lastModule);
    await tester.pumpAndSettle();
    expect(selected, 'Module13');
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'module search preserves its query when keyboard changes height',
    (tester) async {
      await _pumpLandscape(tester, (context) {
        showPreviewModuleInfoPicker(
          context: context,
          classes: const ['ModuleOne', 'ModuleTwo'],
          titleForClass: (_, objClass) => objClass,
          t: _t,
        );
      }, scale: 1);
      await tester.enterText(
        find.byKey(const ValueKey('previewModuleInfoSearch')),
        'Two',
      );
      await tester.pumpAndSettle();
      expect(
        find.byKey(const ValueKey('previewModuleInfo-ModuleOne')),
        findsNothing,
      );
      tester.view.viewInsets = const FakeViewPadding(bottom: 110);
      addTearDown(tester.view.resetViewInsets);
      await tester.pumpAndSettle();
      expect(
        find.byKey(const ValueKey('previewModuleInfo-ModuleOne')),
        findsNothing,
      );
      final matchingModule = find.byKey(
        const ValueKey('previewModuleInfo-ModuleTwo'),
      );
      final scrollable = find
          .descendant(
            of: find.byKey(const ValueKey('previewModuleInfoPicker')),
            matching: find.byType(Scrollable),
          )
          .first;
      await tester.scrollUntilVisible(
        matchingModule,
        60,
        scrollable: scrollable,
      );
      expect(matchingModule.hitTestable(), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'module picker restores the filtered list and resets for a new session',
    (tester) async {
      var session = PreviewPickerSession();
      await _pumpLandscape(
        tester,
        (context) {
          showPreviewModuleInfoPicker(
            context: context,
            session: session,
            classes: [...List.generate(30, (i) => 'Group$i'), 'Other'],
            titleForClass: (_, objClass) => objClass,
            t: _t,
          );
        },
        height: 600,
        scale: 1,
      );
      final search = find.byKey(const ValueKey('previewModuleInfoSearch'));
      final list = find.byKey(const ValueKey('previewModuleInfoScroll'));
      final cancel = find.byKey(const ValueKey('previewModuleInfoCancel'));
      await tester.enterText(search, 'Group');
      await tester.pumpAndSettle();
      tester.widget<SingleChildScrollView>(list).controller!.jumpTo(600);
      await tester.pumpAndSettle();
      final savedOffset = tester
          .widget<SingleChildScrollView>(list)
          .controller!
          .offset;
      await tester.tap(cancel);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();
      expect(tester.widget<TextField>(search).controller!.text, 'Group');
      expect(
        find.byKey(const ValueKey('previewModuleInfo-Other')),
        findsNothing,
      );
      expect(
        tester.widget<SingleChildScrollView>(list).controller!.offset,
        closeTo(savedOffset, 1),
      );

      await tester.tap(cancel);
      await tester.pumpAndSettle();
      session = PreviewPickerSession();
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();
      expect(tester.widget<TextField>(search).controller!.text, isEmpty);
      expect(tester.widget<SingleChildScrollView>(list).controller!.offset, 0);
      expect(
        find.byKey(const ValueKey('previewModuleInfo-Other')),
        findsOneWidget,
      );
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'restored offset stays in bounds after the list shrinks and viewport grows',
    (tester) async {
      final session = PreviewPickerSession();
      var classes = List.generate(30, (i) => 'Module$i');
      await _pumpLandscape(tester, (context) {
        showPreviewModuleInfoPicker(
          context: context,
          session: session,
          classes: classes,
          titleForClass: (_, objClass) => objClass,
          t: _t,
        );
      }, platform: TargetPlatform.iOS);
      final list = find.byKey(const ValueKey('previewModuleInfoScroll'));
      final scroll = tester.widget<SingleChildScrollView>(list).controller!;
      scroll.jumpTo(scroll.position.maxScrollExtent);
      await tester.pumpAndSettle();
      expect(scroll.offset, greaterThan(100));
      await tester.tap(find.byKey(const ValueKey('previewModuleInfoCancel')));
      await tester.pumpAndSettle();
      classes = ['Module0'];
      tester.view.physicalSize = const Size(900, 700);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();
      final restored = tester.widget<SingleChildScrollView>(list).controller!;
      expect(
        restored.offset,
        inInclusiveRange(0, restored.position.maxScrollExtent),
      );
      expect(
        find.byKey(const ValueKey('previewModuleInfo-Module0')).hitTestable(),
        findsOneWidget,
      );
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('starting layout text scrolls without obscuring actions', (
    tester,
  ) async {
    await _pumpLandscape(tester, (context) {
      showPreviewLayoutStyleDialog(
        context: context,
        t: (key, [fallback]) => key == 'previewGenStartHint'
            ? List.filled(12, 'A long translated layout explanation.').join(' ')
            : fallback ?? key,
      );
    });
    expect(tester.takeException(), isNull);
    expect(find.text('Simple').hitTestable(), findsOneWidget);
    expect(find.text('Normal').hitTestable(), findsOneWidget);
    expect(find.byType(SingleChildScrollView), findsOneWidget);
    await tester.tap(find.text('Simple'));
    await tester.pumpAndSettle();
    expect(find.byType(AlertDialog), findsNothing);
    expect(tester.takeException(), isNull);
  });
}
