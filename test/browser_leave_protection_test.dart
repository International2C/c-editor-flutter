import 'package:c_editor/widgets/browser_leave_protection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('overlapping editors cannot clear each other’s leave warning', () {
    final changes = <bool>[];
    final protection = BrowserLeaveProtection(onChanged: changes.add);
    final editor = Object();
    final tool = Object();
    protection.setActive(editor, true);
    protection.setActive(editor, true);
    protection.setActive(tool, true);
    protection.setActive(tool, false);
    expect(changes, [true]);
    protection.setActive(editor, false);
    protection.setActive(editor, false);
    expect(changes, [true, false]);
  });

  testWidgets('secondary routes protect work until the last route closes', (
    tester,
  ) async {
    final changes = <bool>[];
    final observer = BrowserLeaveProtectionObserver(
      protection: BrowserLeaveProtection(onChanged: changes.add),
    );
    final navigator = GlobalKey<NavigatorState>();
    await tester.pumpWidget(
      MaterialApp(
        navigatorKey: navigator,
        navigatorObservers: [observer],
        home: const Scaffold(),
      ),
    );
    expect(changes, isEmpty);
    navigator.currentState!.push(
      MaterialPageRoute<void>(builder: (_) => const Scaffold()),
    );
    await tester.pumpAndSettle();
    expect(changes, [true]);
    final context = navigator.currentState!.overlay!.context;
    showDialog<void>(context: context, builder: (_) => const AlertDialog());
    await tester.pumpAndSettle();
    navigator.currentState!.pop();
    await tester.pumpAndSettle();
    expect(changes, [true]);
    navigator.currentState!.pop();
    await tester.pumpAndSettle();
    expect(changes, [true, false]);
    observer.dispose();
  });
}
