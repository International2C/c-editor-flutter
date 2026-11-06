import 'package:c_editor/data/pvz_models.dart';
import 'package:c_editor/l10n/app_localizations.dart';
import 'package:c_editor/screens/editor/json_viewer_screen.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

PvzLevelFile _longLevel() {
  return PvzLevelFile(
    objects: List.generate(
      120,
      (index) => PvzObject(
        aliases: ['TestObject$index'],
        objClass: 'TestClass',
        objData: {
          'Index': index,
          'Value': 'A sufficiently long JSON value for scrolling $index',
        },
      ),
    ),
  );
}

Widget _jsonViewer(PvzLevelFile level) {
  return MaterialApp(
    theme: ThemeData(platform: TargetPlatform.windows),
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    home: JsonViewerScreen(
      fileName: 'test.json',
      filePath: 'test.json',
      levelFile: level,
      onBack: () {},
      saveLevel: (_, _) async {},
    ),
  );
}

void main() {
  testWidgets('edit-mode search paints a visible match highlight', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    final level = PvzLevelFile(
      objects: [
        PvzObject(
          aliases: ['TestObject'],
          objClass: 'TestClass',
          objData: {'Value': 'before'},
        ),
      ],
    );
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: JsonViewerScreen(
          fileName: 'test.json',
          filePath: 'test.json',
          levelFile: level,
          onBack: () {},
          saveLevel: (_, _) async {},
        ),
      ),
    );
    await tester.pump();

    await tester.tap(find.byIcon(Icons.more_vert));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Edit'));
    await tester.pumpAndSettle();

    final searchField = find.byWidgetPredicate(
      (widget) =>
          widget is TextField && widget.decoration?.hintText == 'Search',
    );
    await tester.enterText(searchField, 'before');
    await tester.pump();

    final editorFinder = find.byWidgetPredicate(
      (widget) =>
          widget is TextField &&
          widget.controller?.text.contains('"before"') == true,
    );
    final editor = tester.widget<TextField>(editorFinder);
    final span = editor.controller!.buildTextSpan(
      context: tester.element(editorFinder),
      style: editor.style,
      withComposing: true,
    );
    final highlightedMatch = span.children!.whereType<TextSpan>().firstWhere(
      (child) => child.text == 'before',
    );

    expect(highlightedMatch.style?.backgroundColor, isNotNull);
    expect(tester.takeException(), isNull);
  });

  testWidgets('JSON search follows text edits without moving the selection', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    final level = PvzLevelFile(
      objects: [
        PvzObject(
          aliases: ['TestObject'],
          objClass: 'TestClass',
          objData: {'Padding': 'frost', 'First': 'chill', 'Second': 'chill'},
        ),
      ],
    );
    await tester.pumpWidget(_jsonViewer(level));
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(Icons.more_vert));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Edit'));
    await tester.pumpAndSettle();

    final searchField = find.byWidgetPredicate(
      (widget) =>
          widget is TextField && widget.decoration?.hintText == 'Search',
    );
    final replaceField = find.byWidgetPredicate(
      (widget) =>
          widget is TextField && widget.decoration?.hintText == 'Replace',
    );
    final editorFinder = find.byWidgetPredicate(
      (widget) =>
          widget is TextField &&
          widget.controller?.text.contains('"Padding"') == true,
    );
    final controller = tester.widget<TextField>(editorFinder).controller!;

    void expectSearchHighlights(int activeIndex) {
      final editor = tester.widget<TextField>(editorFinder);
      final editorContext = tester.element(editorFinder);
      final span = controller.buildTextSpan(
        context: editorContext,
        style: editor.style,
        withComposing: true,
      );
      final highlights = span.children!
          .whereType<TextSpan>()
          .where((child) => child.style?.backgroundColor != null)
          .toList();
      expect(highlights.map((child) => child.text), ['chill', 'chill']);
      final primary = Theme.of(editorContext).colorScheme.primary;
      expect(highlights[activeIndex].style?.backgroundColor, primary);
      expect(
        highlights[1 - activeIndex].style?.backgroundColor,
        isNot(primary),
      );
      for (final highlight in highlights) {
        expect(highlight.style?.fontWeight, editor.style?.fontWeight);
      }
    }

    await tester.enterText(searchField, 'chill');
    await tester.pumpAndSettle();
    expectSearchHighlights(0);

    // Shift both offsets to the right, then shift them back part of the way.
    final inserted = controller.text.replaceFirst('frost', 'prefix frost');
    await tester.enterText(editorFinder, inserted);
    await tester.pumpAndSettle();
    expectSearchHighlights(0);
    final edited = inserted.replaceFirst('prefix frost', 'p frost');
    await tester.enterText(editorFinder, edited);
    await tester.pumpAndSettle();
    expectSearchHighlights(0);

    final frostStart = edited.indexOf('frost');
    final selection = TextSelection(
      baseOffset: frostStart,
      extentOffset: frostStart + 'frost'.length,
    );
    controller.selection = selection;
    await tester.pump();
    await tester.tap(find.byTooltip('Next match'));
    await tester.pumpAndSettle();
    expect(controller.selection, selection);
    expectSearchHighlights(1);

    await tester.enterText(replaceField, 'warm');
    await tester.tap(find.byIcon(Icons.find_replace));
    await tester.pumpAndSettle();
    expect(
      controller.text,
      edited.replaceFirst('"Second": "chill"', '"Second": "warm"'),
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('edit-mode search scrolls to matches in wrapped JSON', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    tester.view.physicalSize = const Size(480, 640);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    const query = 'wrapped-target';
    final filler = List.filled(80, 'padding').join(' ');
    final level = PvzLevelFile(
      objects: [
        PvzObject(
          aliases: ['TestObject'],
          objClass: 'TestClass',
          objData: {
            for (var i = 0; i < 12; i++) 'Before$i': filler,
            'First': query,
            for (var i = 0; i < 12; i++) 'Between$i': filler,
            'Second': query,
          },
        ),
      ],
    );
    await tester.pumpWidget(_jsonViewer(level));
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(Icons.more_vert));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Edit'));
    await tester.pumpAndSettle();

    final editorFinder = find.byWidgetPredicate(
      (widget) => widget is TextField && widget.maxLines == null,
    );
    final editableFinder = find.descendant(
      of: editorFinder,
      matching: find.byType(EditableText),
    );
    final viewportFinder = find.ancestor(
      of: editorFinder,
      matching: find.byType(SingleChildScrollView),
    );
    final controller = tester.widget<TextField>(editorFinder).controller!;
    final first = controller.text.indexOf(query);
    final second = controller.text.lastIndexOf(query);
    const selection = TextSelection(baseOffset: 0, extentOffset: 1);
    controller.selection = selection;
    await tester.pump();

    Offset matchCenter(int offset) {
      final render = tester
          .state<EditableTextState>(editableFinder)
          .renderEditable;
      final boxes = render.getBoxesForSelection(
        TextSelection(baseOffset: offset, extentOffset: offset + query.length),
      );
      return render.localToGlobal(boxes.first.toRect().center);
    }

    expect(
      matchCenter(first).dy,
      greaterThan(tester.getRect(viewportFinder).bottom),
    );
    final searchField = find.byWidgetPredicate(
      (widget) =>
          widget is TextField && widget.decoration?.hintText == 'Search',
    );
    await tester.enterText(searchField, query);
    await tester.pumpAndSettle();

    expect(tester.getRect(viewportFinder).contains(matchCenter(first)), isTrue);
    expect(
      matchCenter(second).dy,
      greaterThan(tester.getRect(viewportFinder).bottom),
    );
    expect(controller.selection, selection);

    final next = find.byTooltip('Next match');
    await tester.ensureVisible(next);
    await tester.tap(next);
    await tester.pumpAndSettle();

    expect(
      tester.getRect(viewportFinder).contains(matchCenter(second)),
      isTrue,
    );
    expect(controller.selection, selection);
    expect(tester.takeException(), isNull);
  });

  testWidgets('replacing a match does not append a trailing newline', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    final level = PvzLevelFile(
      objects: [
        PvzObject(
          aliases: ['TestObject'],
          objClass: 'TestClass',
          objData: {'Value': 'before'},
        ),
      ],
    );
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: JsonViewerScreen(
          fileName: 'test.json',
          filePath: 'test.json',
          levelFile: level,
          onBack: () {},
          saveLevel: (_, _) async {},
        ),
      ),
    );
    await tester.pump();

    await tester.tap(find.byIcon(Icons.more_vert));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Edit'));
    await tester.pumpAndSettle();

    final searchField = find.byWidgetPredicate(
      (widget) =>
          widget is TextField && widget.decoration?.hintText == 'Search',
    );
    final replaceField = find.byWidgetPredicate(
      (widget) =>
          widget is TextField && widget.decoration?.hintText == 'Replace',
    );
    final originalEditor = tester.widget<TextField>(
      find.byWidgetPredicate(
        (widget) =>
            widget is TextField &&
            widget.controller?.text.contains('"before"') == true,
      ),
    );
    final originalNewlineCount = '\n'
        .allMatches(originalEditor.controller!.text)
        .length;

    await tester.enterText(searchField, 'before');
    await tester.enterText(replaceField, 'after');
    await tester.tap(find.byIcon(Icons.find_replace));
    await tester.pump();

    final updatedEditor = tester.widget<TextField>(
      find.byWidgetPredicate(
        (widget) =>
            widget is TextField &&
            widget.controller?.text.contains('"after"') == true,
      ),
    );
    final updatedText = updatedEditor.controller!.text;
    expect(updatedText.endsWith('\n'), isFalse);
    expect('\n'.allMatches(updatedText).length, originalNewlineCount);
    expect(tester.takeException(), isNull);
  });

  testWidgets('mouse clicks keep JSON scroll position with full Select all', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    await tester.pumpWidget(_jsonViewer(_longLevel()));
    await tester.pump();

    final scrollbar = tester.widget<Scrollbar>(find.byType(Scrollbar).last);
    final scrollController = scrollbar.controller!;
    scrollController.jumpTo(900);
    await tester.pump();
    final beforePrimaryClick = scrollController.offset;
    final selectionArea = find.byType(SelectionArea).first;
    final selectionRect = tester.getRect(selectionArea);
    final viewportRect = tester.getRect(
      find.byType(SingleChildScrollView).last,
    );
    final visibleSelectionRect = selectionRect.intersect(viewportRect);
    final visiblePoint = visibleSelectionRect.topLeft + const Offset(80, 18);

    await tester.tapAt(visiblePoint);
    await tester.pumpAndSettle();

    expect(scrollController.offset, closeTo(beforePrimaryClick, 0.5));

    scrollController.jumpTo(1100);
    await tester.pump();
    final beforeSecondaryClick = scrollController.offset;
    await tester.tapAt(
      visiblePoint,
      kind: PointerDeviceKind.mouse,
      buttons: kSecondaryButton,
    );
    await tester.pumpAndSettle();

    expect(scrollController.offset, closeTo(beforeSecondaryClick, 0.5));
    expect(selectionArea, findsOneWidget);
    final selectAll = find.textContaining(
      RegExp('select all', caseSensitive: false),
    );
    expect(selectAll, findsOneWidget);

    await tester.tap(selectAll);
    await tester.pumpAndSettle();

    expect(scrollController.offset, closeTo(beforeSecondaryClick, 0.5));
    expect(tester.takeException(), isNull);
  });

  testWidgets('entering JSON edit mode keeps the reading scroll position', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    await tester.pumpWidget(_jsonViewer(_longLevel()));
    await tester.pump();

    final scrollbar = tester.widget<Scrollbar>(find.byType(Scrollbar).last);
    final scrollController = scrollbar.controller!;
    scrollController.jumpTo(900);
    await tester.pump();
    final before = scrollController.offset;

    await tester.tap(find.byIcon(Icons.more_vert));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Edit'));
    await tester.pumpAndSettle();

    expect(scrollController.offset, closeTo(before, 0.5));
    expect(tester.takeException(), isNull);
  });

  testWidgets('read-mode gutter height matches wrapped JSON height', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    final level = PvzLevelFile(
      objects: List.generate(
        30,
        (index) => PvzObject(
          aliases: ['Wave$index'],
          objClass: 'SpawnZombiesJitteredWaveActionProps',
          objData: {
            'Zombies': List.generate(
              8,
              (z) => {'Type': 'RTID(moon_armor${z % 3}@ZombieTypes)'},
            ),
          },
        ),
      ),
    );
    await tester.pumpWidget(_jsonViewer(level));
    await tester.pumpAndSettle();

    final rowFinder = find.descendant(
      of: find.byType(Scrollbar).last,
      matching: find.byType(Row),
    );
    final gutterHeight = tester
        .getSize(
          find.descendant(
            of: rowFinder,
            matching: find.byWidgetPredicate(
              (widget) => widget is SizedBox && widget.child is Column,
            ),
          ),
        )
        .height;
    final contentHeight = tester
        .getSize(
          find.descendant(
            of: rowFinder,
            matching: find.byWidgetPredicate(
              (widget) =>
                  widget is SizedBox &&
                  (widget.child is Listener || widget.child is SelectionArea),
            ),
          ),
        )
        .height;
    expect(gutterHeight, closeTo(contentHeight, 1.5));
    expect(tester.takeException(), isNull);
  });
}
