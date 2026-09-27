import 'package:c_editor/data/repository/grid_item_repository.dart';
import 'package:c_editor/l10n/app_localizations.dart';
import 'package:c_editor/l10n/resource_names.dart';
import 'package:c_editor/screens/select/grid_item_selection_screen.dart';
import 'package:c_editor/utils/selection_view_memory.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(() async {
    await GridItemRepository.init();
    await ResourceNames.ensureLoaded();
  });
  setUp(SelectionViewMemoryStore.clear);

  for (final mouse in [false, true]) {
    testWidgets('grid item full name and code are available (mouse: $mouse)', (
      tester,
    ) async {
      const id = 'lunar_mine_ore_hardened_shell_moon13_start';
      const name = 'Hard-Shell Crystal (2,000 HP)';
      String? selected;
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = const Size(360, 800);
      addTearDown(tester.view.resetDevicePixelRatio);
      addTearDown(tester.view.resetPhysicalSize);
      await tester.pumpWidget(
        MaterialApp(
          locale: const Locale('en'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          builder: (context, child) => MediaQuery(
            data: MediaQuery.of(
              context,
            ).copyWith(textScaler: TextScaler.linear(1.8)),
            child: child!,
          ),
          home: GridItemSelectionScreen(
            onGridItemSelected: (value) => selected = value,
            onBack: () {},
            filterMode: GridItemFilterMode.all,
          ),
        ),
      );
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField).first, id);
      await tester.pumpAndSettle();
      expect(find.byTooltip(name), findsOneWidget);
      expect(find.byTooltip(id), findsOneWidget);
      for (final label in [name, id]) {
        if (mouse) {
          final pointer = await tester.createGesture(
            kind: PointerDeviceKind.mouse,
          );
          await pointer.addPointer(location: Offset.zero);
          await pointer.moveTo(tester.getCenter(find.byTooltip(label)));
          await tester.pump(const Duration(seconds: 1));
          await pointer.removePointer();
        } else {
          await tester.longPress(find.byTooltip(label));
          await tester.pump();
        }
        expect(
          find.byWidgetPredicate(
            (widget) =>
                widget is RichText && widget.text.toPlainText() == label,
          ),
          findsNWidgets(2),
        );
        expect(selected, isNull);
        Tooltip.dismissAllToolTips();
        await tester.pumpAndSettle();
      }
      await tester.tap(find.text(name));
      expect(selected, id);
      expect(tester.takeException(), isNull);
    });
  }
}
