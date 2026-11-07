import 'package:c_editor/widgets/editor_preview_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('preview body gives wrapped actions their full height', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(320, 330);
    addTearDown(tester.view.reset);

    const footerSettings = 'Open module settings';
    const footerClose = 'Close preview window';
    await tester.pumpWidget(
      MaterialApp(
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(
            context,
          ).copyWith(textScaler: const TextScaler.linear(1.5)),
          child: child!,
        ),
        home: Scaffold(
          body: Builder(
            builder: (context) => TextButton(
              onPressed: () => showEditorPreviewDialog<void>(
                context: context,
                title: const Text('Module preview'),
                content: Column(
                  children: List.generate(30, (i) => Text('Preview row $i')),
                ),
                actions: [
                  FilledButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text(footerSettings),
                  ),
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text(footerClose),
                  ),
                ],
              ),
              child: const Text('Preview'),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('Preview'));
    await tester.pumpAndSettle();

    final body = find.byType(SingleChildScrollView);
    final settings = find.widgetWithText(FilledButton, footerSettings);
    final close = find.widgetWithText(TextButton, footerClose);
    expect(tester.takeException(), isNull);
    final bodyBounds = tester.getRect(body);
    final settingsBounds = tester.getRect(settings);
    final closeBounds = tester.getRect(close);
    expect(settingsBounds.bottom, lessThanOrEqualTo(closeBounds.top));
    expect(bodyBounds.bottom, lessThan(settingsBounds.top));
    expect(closeBounds.bottom, lessThan(330));

    final lastRow = find.text('Preview row 29');
    await tester.ensureVisible(lastRow);
    await tester.pumpAndSettle();
    expect(bodyBounds.contains(tester.getCenter(lastRow)), isTrue);
    expect(tester.getRect(settings), settingsBounds);
    expect(tester.getRect(close), closeBounds);
    await tester.tap(close);
    await tester.pumpAndSettle();
    expect(find.byType(Dialog), findsNothing);
    expect(tester.takeException(), isNull);
  });
}
