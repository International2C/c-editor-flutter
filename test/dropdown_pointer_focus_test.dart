import 'package:c_editor/widgets/dropdown_pointer_focus.dart';
import 'package:c_editor/widgets/persistent_scrollbar_scroll_behavior.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  for (final formField in [false, true]) {
    for (final kind in [PointerDeviceKind.touch, PointerDeviceKind.mouse]) {
      testWidgets(
        '$kind dropdown clears returned pointer focus after selection and dismissal (form: $formField)',
        (tester) async {
          final previousStrategy = FocusManager.instance.highlightStrategy;
          FocusManager.instance.highlightStrategy =
              FocusHighlightStrategy.alwaysTraditional;
          addTearDown(() {
            FocusManager.instance.highlightStrategy = previousStrategy;
          });
          late FocusNode focusNode;
          var value = 'One';
          await tester.pumpWidget(
            MaterialApp(
              scrollBehavior: const PersistentScrollbarScrollBehavior(),
              home: Scaffold(
                body: Center(
                  child: SizedBox(
                    width: 240,
                    child: StatefulBuilder(
                      builder: (context, setState) => DropdownPointerFocus(
                        builder: (context, node) {
                          focusNode = node;
                          final items = [
                            for (final item in ['One', 'Two'])
                              DropdownMenuItem(value: item, child: Text(item)),
                          ];
                          void onChanged(String? next) {
                            setState(() => value = next!);
                          }

                          return formField
                              ? DropdownButtonFormField<String>(
                                  focusNode: node,
                                  initialValue: value,
                                  items: items,
                                  onChanged: onChanged,
                                )
                              : DropdownButton<String>(
                                  focusNode: node,
                                  value: value,
                                  items: items,
                                  onChanged: onChanged,
                                );
                        },
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
          final dropdown = find.byWidgetPredicate(
            (widget) => widget is DropdownButton<String>,
          );
          // Repeatedly selecting the same value must also clear the focus.
          for (final next in ['Two', 'Two', 'One']) {
            await tester.tap(dropdown, kind: kind);
            await tester.pumpAndSettle();
            await tester.tap(find.text(next).last, kind: kind);
            await tester.pumpAndSettle();
            expect(value, next);
            expect(focusNode.hasPrimaryFocus, isFalse);
          }
          await tester.tap(dropdown, kind: kind);
          await tester.pumpAndSettle();
          await tester.tapAt(const Offset(20, 20), kind: kind);
          await tester.pumpAndSettle();
          expect(value, 'One');
          expect(focusNode.hasPrimaryFocus, isFalse);
          expect(tester.takeException(), isNull);
        },
      );
    }
  }

  testWidgets('keyboard selection and dismissal retain anchor focus', (
    tester,
  ) async {
    late FocusNode focusNode;
    var value = 'One';
    await tester.pumpWidget(
      MaterialApp(
        scrollBehavior: const PersistentScrollbarScrollBehavior(),
        home: Scaffold(
          body: Center(
            child: StatefulBuilder(
              builder: (context, setState) => DropdownPointerFocus(
                builder: (context, node) {
                  focusNode = node;
                  return DropdownButton<String>(
                    focusNode: node,
                    value: value,
                    items: [
                      for (final item in ['One', 'Two'])
                        DropdownMenuItem(value: item, child: Text(item)),
                    ],
                    onChanged: (next) => setState(() => value = next!),
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
    focusNode.requestFocus();
    await tester.pumpAndSettle();
    expect(focusNode.hasPrimaryFocus, isTrue);
    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    await tester.pumpAndSettle();
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    await tester.pumpAndSettle();
    expect(value, 'Two');
    expect(focusNode.hasPrimaryFocus, isTrue);
    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    await tester.pumpAndSettle();
    await tester.sendKeyEvent(LogicalKeyboardKey.escape);
    await tester.pumpAndSettle();
    expect(focusNode.hasPrimaryFocus, isTrue);
    // A pointer-opened menu can still be dismissed with the keyboard. Its
    // route is outside the wrapper, so observe Escape without consuming it.
    await tester.tap(find.byType(DropdownButton<String>));
    await tester.pumpAndSettle();
    await tester.sendKeyEvent(LogicalKeyboardKey.escape);
    await tester.pumpAndSettle();
    expect(focusNode.hasPrimaryFocus, isTrue);
    expect(tester.takeException(), isNull);
  });
}
