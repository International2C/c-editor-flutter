import 'package:c_editor/widgets/persistent_scrollbar_scroll_behavior.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _app({
  required TargetPlatform platform,
  required Widget child,
  ScrollBehavior scrollBehavior = const PersistentScrollbarScrollBehavior(),
  double width = 320,
}) => MaterialApp(
  theme: ThemeData(platform: platform),
  scrollBehavior: scrollBehavior,
  home: Scaffold(
    body: SizedBox(width: width, height: 240, child: child),
  ),
);

ListView _longVerticalList({ScrollController? controller}) => ListView.builder(
  controller: controller,
  itemCount: 30,
  itemBuilder: (_, index) => SizedBox(height: 48, child: Text('Item $index')),
);

Finder get _persistentBar => find.byWidgetPredicate(
  (widget) =>
      widget is Scrollbar &&
      widget.thumbVisibility == true &&
      widget.scrollbarOrientation == ScrollbarOrientation.right,
);

void main() {
  for (final platform in <TargetPlatform>[
    TargetPlatform.android,
    TargetPlatform.iOS,
    TargetPlatform.macOS,
    TargetPlatform.windows,
  ]) {
    testWidgets('vertical pages keep one right scrollbar on ${platform.name}', (
      tester,
    ) async {
      await tester.pumpWidget(
        _app(platform: platform, child: _longVerticalList()),
      );
      await tester.pumpAndSettle();

      expect(_persistentBar, findsOneWidget);
      final scrollbar = tester.widget<Scrollbar>(_persistentBar);
      expect(scrollbar.controller, isNotNull);
      expect(scrollbar.trackVisibility, isTrue);
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('help text leaves a separate gutter on every platform', (
    tester,
  ) async {
    for (final platform in TargetPlatform.values) {
      await tester.pumpWidget(
        _app(
          platform: platform,
          child: SingleChildScrollView(
            child: Container(
              key: const ValueKey('helpBody'),
              height: 900,
              width: double.infinity,
              child: const Text('A long help page'),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final content = tester.getRect(find.byKey(const ValueKey('helpBody')));
      final bar = tester.getRect(_persistentBar);
      expect(content.right, lessThanOrEqualTo(bar.right - 20));
      expect(content.left, closeTo(bar.left, 0.01));
      expect(tester.takeException(), isNull);
    }
  });

  testWidgets('the gutter also covers a wider hovered thumb', (tester) async {
    await tester.pumpWidget(
      _app(
        platform: TargetPlatform.windows,
        child: ScrollbarTheme(
          data: ScrollbarThemeData(
            thickness: WidgetStateProperty.resolveWith(
              (states) => states.contains(WidgetState.hovered) ? 32 : 8,
            ),
            crossAxisMargin: 3,
          ),
          child: SingleChildScrollView(
            child: Container(
              key: const ValueKey('helpBody'),
              height: 900,
              width: double.infinity,
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    final content = tester.getRect(find.byKey(const ValueKey('helpBody')));
    final bar = tester.getRect(_persistentBar);
    final mouse = await tester.createGesture(kind: PointerDeviceKind.mouse);
    addTearDown(mouse.removePointer);
    await mouse.addPointer(location: Offset(bar.right - 5, bar.top + 30));
    await tester.pumpAndSettle();

    expect(content.right, lessThanOrEqualTo(bar.right - 42));
    expect(content.left, closeTo(bar.left, 0.01));
    expect(tester.getRect(find.byKey(const ValueKey('helpBody'))), content);
    expect(tester.takeException(), isNull);
  });

  testWidgets('compact padded pages balance the existing page margins', (
    tester,
  ) async {
    for (final platform in [
      TargetPlatform.android,
      TargetPlatform.iOS,
      TargetPlatform.windows,
    ]) {
      for (final padding in [12.0, 16.0, 24.0]) {
        await tester.pumpWidget(
          _app(
            platform: platform,
            child: SingleChildScrollView(
              padding: EdgeInsets.all(padding),
              child: const SizedBox(
                key: ValueKey('centeredPage'),
                width: double.infinity,
                height: 900,
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        final content = tester.getRect(
          find.byKey(const ValueKey('centeredPage')),
        );
        final bar = tester.getRect(_persistentBar);
        final expectedMargin = padding < 20 ? 20.0 : padding;
        expect(content.center.dx, closeTo(bar.center.dx, .01));
        expect(content.left - bar.left, closeTo(expectedMargin, .01));
        expect(bar.right - content.right, closeTo(expectedMargin, .01));
        expect(tester.takeException(), isNull);
      }
    }
  });

  testWidgets('compact list keeps its edge channel draggable by touch', (
    tester,
  ) async {
    final controller = ScrollController();
    addTearDown(controller.dispose);
    await tester.pumpWidget(
      _app(
        platform: TargetPlatform.android,
        child: ListView.builder(
          controller: controller,
          padding: const EdgeInsets.all(16),
          itemCount: 30,
          itemBuilder: (_, index) => SizedBox(
            key: ValueKey('paddedRow_$index'),
            width: double.infinity,
            height: 48,
            child: Text('Item $index'),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    final bar = tester.getRect(_persistentBar);
    final first = tester.getRect(find.byKey(const ValueKey('paddedRow_0')));
    expect(first.center.dx, closeTo(bar.center.dx, .01));
    expect(first.width, closeTo(bar.width - 40, .01));
    final gesture = await tester.startGesture(
      Offset(bar.right - 6, bar.top + 20),
    );
    await tester.pump();
    await gesture.moveBy(const Offset(0, 40));
    await tester.pump(const Duration(milliseconds: 16));
    await gesture.moveBy(const Offset(0, 60));
    await tester.pump(const Duration(milliseconds: 16));
    await gesture.up();
    await tester.pumpAndSettle();
    expect(controller.offset, greaterThan(200));

    controller.jumpTo(0);
    await tester.pumpAndSettle();
    await tester.dragFrom(
      Offset(bar.center.dx, bar.top + 180),
      const Offset(0, -100),
    );
    await tester.pumpAndSettle();
    expect(controller.offset, greaterThan(0));
    expect(tester.takeException(), isNull);
  });

  testWidgets('compact explicit left scrollbar respects safe insets and RTL', (
    tester,
  ) async {
    final controller = ScrollController();
    addTearDown(controller.dispose);
    await tester.pumpWidget(
      _app(
        platform: TargetPlatform.iOS,
        child: MediaQuery(
          data: const MediaQueryData(
            size: Size(320, 240),
            padding: EdgeInsets.only(left: 12, right: 4),
          ),
          child: Directionality(
            textDirection: TextDirection.rtl,
            child: Scrollbar(
              key: const ValueKey('safeLeftBar'),
              controller: controller,
              thumbVisibility: true,
              scrollbarOrientation: ScrollbarOrientation.left,
              child: ListView(
                controller: controller,
                padding: const EdgeInsetsDirectional.symmetric(horizontal: 16),
                children: const [
                  SizedBox(
                    key: ValueKey('safePaddedRow'),
                    width: double.infinity,
                    height: 900,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    final content = tester.getRect(find.byKey(const ValueKey('safePaddedRow')));
    final bar = tester.getRect(find.byKey(const ValueKey('safeLeftBar')));
    expect(content.left - bar.left, closeTo(32, .01));
    expect(bar.right - content.right, closeTo(24, .01));
    expect(find.byType(Scrollbar), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('padded pages stay centered at and beyond the old breakpoint', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    for (final width in [600.0, 800.0, 1200.0]) {
      tester.view.physicalSize = Size(width, 600);
      await tester.pumpWidget(
        _app(
          width: width,
          platform: TargetPlatform.windows,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: const SizedBox(
              key: ValueKey('widePage'),
              width: double.infinity,
              height: 900,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      final content = tester.getRect(find.byKey(const ValueKey('widePage')));
      final bar = tester.getRect(_persistentBar);
      expect(content.center.dx, closeTo(bar.center.dx, .01));
      expect(content.left - bar.left, closeTo(20, .01));
      expect(bar.right - content.right, closeTo(20, .01));
      expect(tester.takeException(), isNull);
    }
  });

  testWidgets('horizontal controls keep their component-specific behavior', (
    tester,
  ) async {
    await tester.pumpWidget(
      _app(
        platform: TargetPlatform.android,
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: const SizedBox(width: 1200, height: 80),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(Scrollbar), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('an explicit scrollbar is not duplicated by app behavior', (
    tester,
  ) async {
    final controller = ScrollController();
    addTearDown(controller.dispose);

    await tester.pumpWidget(
      _app(
        platform: TargetPlatform.android,
        child: Scrollbar(
          key: const ValueKey('explicitScrollbar'),
          controller: controller,
          thumbVisibility: true,
          child: _longVerticalList(controller: controller),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(Scrollbar), findsOneWidget);
    expect(find.byKey(const ValueKey('explicitScrollbar')), findsOneWidget);
    final viewport = tester.getRect(find.byType(Viewport));
    final bar = tester.getRect(find.byKey(const ValueKey('explicitScrollbar')));
    expect(viewport.right, lessThanOrEqualTo(bar.right - 20));
    expect(viewport.left, closeTo(bar.left, 0.01));
    expect(tester.takeException(), isNull);
  });

  testWidgets('an explicit left scrollbar reserves space on the left', (
    tester,
  ) async {
    final controller = ScrollController();
    addTearDown(controller.dispose);

    await tester.pumpWidget(
      _app(
        platform: TargetPlatform.iOS,
        child: Scrollbar(
          key: const ValueKey('leftScrollbar'),
          controller: controller,
          thumbVisibility: true,
          scrollbarOrientation: ScrollbarOrientation.left,
          child: _longVerticalList(controller: controller),
        ),
      ),
    );
    await tester.pumpAndSettle();

    final viewport = tester.getRect(find.byType(Viewport));
    final bar = tester.getRect(find.byKey(const ValueKey('leftScrollbar')));
    expect(find.byType(Scrollbar), findsOneWidget);
    expect(viewport.left, greaterThanOrEqualTo(bar.left + 20));
    expect(viewport.right, closeTo(bar.right, 0.01));
    expect(tester.takeException(), isNull);
  });

  testWidgets('nested independent vertical regions each keep one scrollbar', (
    tester,
  ) async {
    final outerController = ScrollController();
    final innerController = ScrollController();
    addTearDown(outerController.dispose);
    addTearDown(innerController.dispose);

    await tester.pumpWidget(
      _app(
        platform: TargetPlatform.android,
        child: Scrollbar(
          key: const ValueKey('outerExplicitScrollbar'),
          controller: outerController,
          thumbVisibility: true,
          child: ListView(
            controller: outerController,
            children: [
              SizedBox(
                height: 120,
                child: ListView.builder(
                  key: const ValueKey('innerVerticalList'),
                  controller: innerController,
                  itemCount: 20,
                  itemBuilder: (_, index) =>
                      SizedBox(height: 36, child: Text('Nested item $index')),
                ),
              ),
              const SizedBox(height: 500),
            ],
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(Scrollbar), findsNWidgets(2));
    expect(
      tester
          .widgetList<Scrollbar>(find.byType(Scrollbar))
          .where((bar) => bar.controller == innerController),
      hasLength(1),
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('non-scrolling module lists add no nested scrollbar or indent', (
    tester,
  ) async {
    await tester.pumpWidget(
      _app(
        platform: TargetPlatform.windows,
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const SizedBox(
              key: ValueKey('moduleHeading'),
              width: double.infinity,
              height: 40,
              child: Text('Editable modules'),
            ),
            ReorderableListView.builder(
              padding: EdgeInsets.zero,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              buildDefaultDragHandles: false,
              itemCount: 3,
              onReorderItem: (_, _) {},
              itemBuilder: (_, index) => SizedBox(
                key: ValueKey('moduleRow_$index'),
                width: double.infinity,
                height: 48,
                child: Text('Module $index'),
              ),
            ),
            const SizedBox(height: 500),
          ],
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(Scrollbar), findsOneWidget);
    final heading = tester.getRect(find.byKey(const ValueKey('moduleHeading')));
    final row = tester.getRect(find.byKey(const ValueKey('moduleRow_0')));
    expect(row.left, closeTo(heading.left, 0.01));
    expect(row.right, closeTo(heading.right, 0.01));
    expect(tester.takeException(), isNull);
  });

  testWidgets('multiline fields keep their original left text padding', (
    tester,
  ) async {
    double? originalInset;
    for (final behavior in const [
      MaterialScrollBehavior(),
      PersistentScrollbarScrollBehavior(),
    ]) {
      await tester.pumpWidget(
        _app(
          platform: TargetPlatform.windows,
          scrollBehavior: behavior,
          child: TextFormField(
            key: const ValueKey('descriptionField'),
            initialValue:
                'Conveyor belt example\nSecond line\nThird line\nFourth line',
            minLines: 3,
            maxLines: 3,
            decoration: const InputDecoration(
              labelText: 'Level description',
              border: OutlineInputBorder(),
              contentPadding: EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 16,
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final field = tester.getRect(
        find.byKey(const ValueKey('descriptionField')),
      );
      final editable = tester.state<EditableTextState>(
        find.byType(EditableText),
      );
      final textLeft = editable.renderEditable.localToGlobal(Offset.zero).dx;
      originalInset ??= textLeft - field.left;
      expect(textLeft - field.left, closeTo(originalInset, 0.01));
      expect(tester.takeException(), isNull);
    }
  });

  testWidgets('scrollable dialogs keep their original title and body padding', (
    tester,
  ) async {
    double? originalTitleInset;
    double? originalBodyInset;
    for (final behavior in const [
      MaterialScrollBehavior(),
      PersistentScrollbarScrollBehavior(),
    ]) {
      await tester.pumpWidget(
        _app(
          platform: TargetPlatform.windows,
          scrollBehavior: behavior,
          child: Builder(
            builder: (context) => TextButton(
              onPressed: () => showDialog<void>(
                context: context,
                builder: (_) => const AlertDialog(
                  scrollable: true,
                  title: Text('No update needed', key: ValueKey('updateTitle')),
                  content: Text(
                    'You are using the latest stable version.',
                    key: ValueKey('updateBody'),
                  ),
                ),
              ),
              child: const Text('Open dialog'),
            ),
          ),
        ),
      );
      await tester.tap(find.text('Open dialog'));
      await tester.pumpAndSettle();

      final surface = tester.getRect(
        find.descendant(
          of: find.byType(Dialog),
          matching: find.byWidgetPredicate(
            (widget) => widget is Material && widget.type == MaterialType.card,
          ),
        ),
      );
      final title = tester.getRect(find.byKey(const ValueKey('updateTitle')));
      final body = tester.getRect(find.byKey(const ValueKey('updateBody')));
      originalTitleInset ??= title.left - surface.left;
      originalBodyInset ??= body.left - surface.left;
      expect(title.left - surface.left, closeTo(originalTitleInset, 0.01));
      expect(body.left - surface.left, closeTo(originalBodyInset, 0.01));
      expect(tester.takeException(), isNull);
      Navigator.of(tester.element(find.byType(AlertDialog))).pop();
      await tester.pumpAndSettle();
    }
  });
}
