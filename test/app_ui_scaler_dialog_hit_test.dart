import 'package:c_editor/theme/app_theme.dart';
import 'package:c_editor/widgets/app_ui_scaler.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Regression: UI scale must not leave dialog ConstrainedBoxes with
/// `size: MISSING` (the old FittedBox scaler caused that on pointer moves).
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  for (final scale in [0.85, 1.0, 1.5, 2.0]) {
    testWidgets('AlertDialog hit-tests under AppUiScaler scale=$scale', (
      tester,
    ) async {
      await tester.binding.setSurfaceSize(const Size(1280, 720));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(
        MaterialApp(
          theme: lightTheme,
          builder: (context, child) =>
              AppUiScaler(scale: scale, wrapMessenger: false, child: child!),
          home: Scaffold(
            body: Builder(
              builder: (context) => TextButton(
                onPressed: () {
                  showDialog<void>(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      title: const Text('Scaled dialog'),
                      content: const Text('Body'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.of(ctx).pop(),
                          child: const Text('OK'),
                        ),
                      ],
                    ),
                  );
                },
                child: const Text('Open'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();
      expect(find.text('Scaled dialog'), findsOneWidget);

      // Pointer moves across the overlay used to flood:
      // "Cannot hit test a render box with no size" via RenderFittedBox.
      final gesture = await tester.createGesture(kind: PointerDeviceKind.mouse);
      await gesture.addPointer(location: const Offset(10, 10));
      addTearDown(gesture.removePointer);
      await tester.pump();

      for (final offset in [
        const Offset(100, 80),
        const Offset(640, 360),
        const Offset(900, 500),
        const Offset(200, 200),
      ]) {
        await gesture.moveTo(offset);
        await tester.pump();
        expect(
          tester.takeException(),
          isNull,
          reason: 'pointer move to $offset at scale $scale',
        );
      }

      // No FittedBox may wrap the navigator/overlays.
      expect(find.byType(FittedBox), findsNothing);

      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();
    });
  }

  testWidgets('compact phone taps reach bottom-right and top-right controls', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(360, 780);
    addTearDown(tester.view.reset);
    var topRight = 0;
    var bottomRight = 0;

    await tester.pumpWidget(
      MaterialApp(
        builder: (context, child) => AppUiScaler(
          scale: 1,
          applyCompactViewportScale: true,
          wrapMessenger: false,
          child: child!,
        ),
        home: Scaffold(
          appBar: AppBar(
            actions: [
              IconButton(
                key: const ValueKey('phone-top-right'),
                onPressed: () => topRight++,
                icon: const Icon(Icons.settings),
              ),
            ],
          ),
          body: const SizedBox.expand(),
          floatingActionButton: FloatingActionButton(
            key: const ValueKey('phone-bottom-right'),
            onPressed: () => bottomRight++,
            child: const Icon(Icons.add),
          ),
        ),
      ),
    );

    final top = tester.getRect(find.byKey(const ValueKey('phone-top-right')));
    final bottom = tester.getRect(
      find.byKey(const ValueKey('phone-bottom-right')),
    );
    expect(top.right, greaterThan(300));
    expect(top.top, lessThan(80));
    expect(bottom.right, greaterThan(300));
    expect(bottom.bottom, greaterThan(700));

    await tester.tapAt(top.center);
    await tester.tapAt(bottom.center);
    await tester.tapAt(Offset(top.right - 4, top.top + 4));
    await tester.tapAt(Offset(bottom.right - 4, bottom.bottom - 4));
    expect(topRight, 2);
    expect(bottomRight, 2);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Dialog with TextField lays out, hit-tests, and closes cleanly', (
    tester,
  ) async {
    // AlertDialog + LayoutBuilder fails intrinsics; disposing a controller
    // owned outside the dialog races route teardown.
    await tester.binding.setSurfaceSize(const Size(1280, 720));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      MaterialApp(
        theme: lightTheme,
        builder: (context, child) =>
            AppUiScaler(scale: 1.2, wrapMessenger: false, child: child!),
        home: Scaffold(
          body: Builder(
            builder: (context) => TextButton(
              onPressed: () {
                showDialog<String>(
                  context: context,
                  builder: (ctx) => const _OwnedAliasDialog(),
                );
              },
              child: const Text('Open'),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    expect(find.text('Custom stage alias'), findsOneWidget);

    final gesture = await tester.createGesture(kind: PointerDeviceKind.mouse);
    await gesture.addPointer(location: const Offset(10, 10));
    addTearDown(gesture.removePointer);
    await tester.pump();
    await gesture.moveTo(const Offset(640, 360));
    await tester.pump();
    expect(tester.takeException(), isNull);

    await tester.tap(find.text('OK'));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });
}

class _OwnedAliasDialog extends StatefulWidget {
  const _OwnedAliasDialog();

  @override
  State<_OwnedAliasDialog> createState() => _OwnedAliasDialogState();
}

class _OwnedAliasDialogState extends State<_OwnedAliasDialog> {
  late final TextEditingController _controller = TextEditingController(
    text: 'CustomStage',
  );

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: SizedBox(
        width: 420,
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text('Custom stage alias'),
              const SizedBox(height: 16),
              TextField(
                controller: _controller,
                decoration: const InputDecoration(
                  labelText: 'Stage alias',
                  border: OutlineInputBorder(),
                ),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(_controller.text),
                child: const Text('OK'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
