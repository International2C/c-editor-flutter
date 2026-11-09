import 'package:c_editor/data/registry/module_registry.dart';
import 'package:c_editor/data/repository/grid_item_repository.dart';
import 'package:c_editor/data/repository/rift_theme_repository.dart';
import 'package:c_editor/l10n/app_localizations.dart';
import 'package:c_editor/l10n/resource_names.dart';
import 'package:c_editor/screens/select/grid_item_selection_screen.dart';
import 'package:c_editor/screens/select/rift_theme_selection_screen.dart';
import 'package:c_editor/widgets/rift_theme_widgets.dart';
import 'package:c_editor/widgets/selection_list_confirmation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _app(Widget home, {double textScale = 1}) => MaterialApp(
  locale: const Locale('en'),
  localizationsDelegates: AppLocalizations.localizationsDelegates,
  supportedLocales: AppLocalizations.supportedLocales,
  builder: (context, child) => MediaQuery(
    data: MediaQuery.of(context).copyWith(
      textScaler: TextScaler.linear(textScale),
      padding: const EdgeInsets.only(bottom: 28),
    ),
    child: child!,
  ),
  home: home,
);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(ResourceNames.ensureLoaded);

  test('pathways and expedition tiles use the same module icon', () {
    expect(
      ModuleRegistry.getMetadata('TunnelDefendModuleProperties').icon,
      ModuleRegistry.getMetadata('SouDaCheTunnelDefendDefault').icon,
    );
  });

  for (final textScale in [1.0, 2.0]) {
    testWidgets('theme confirmation clears the last card at scale $textScale', (
      tester,
    ) async {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = const Size(360, 760);
      addTearDown(tester.view.reset);
      List<String>? confirmed;
      await tester.pumpWidget(
        _app(
          RiftThemeSelectionScreen(
            stateBucketId: 'theme-clearance-$textScale',
            initialSelectedIds: const [],
            accentColor: Colors.purple,
            onThemesConfirmed: (ids) => confirmed = ids,
            onBack: () {},
          ),
          textScale: textScale,
        ),
      );
      await tester.pumpAndSettle();
      final list = find.byType(ListView);
      final controller = tester.widget<ListView>(list).controller!;
      controller.jumpTo(controller.position.maxScrollExtent);
      await tester.pumpAndSettle();

      final lastId = RiftThemeRepository.themeIds.last;
      final lastIcon = find.byWidgetPredicate(
        (widget) => widget is RiftThemeIcon && widget.themeId == lastId,
      );
      final lastCard = find.ancestor(of: lastIcon, matching: find.byType(Card));
      final button = find.byType(FloatingActionButton);
      expect(lastCard, findsOneWidget);
      expect(
        tester.getRect(lastCard).overlaps(tester.getRect(button)),
        isFalse,
      );
      expect(
        tester.getRect(list),
        tester.getRect(find.byType(SelectionListConfirmation)),
        reason: 'Clearance must not shrink the scrollable viewport',
      );
      expect(controller.position.extentAfter, closeTo(0, .1));
      await tester.tap(lastCard);
      await tester.pumpAndSettle();
      await tester.tap(button);
      expect(confirmed, [lastId]);

      await tester.enterText(find.byType(TextField).first, lastId);
      await tester.pumpAndSettle();
      expect(tester.widget<ListView>(list).padding, const EdgeInsets.all(16));
      expect(tester.takeException(), isNull);
    });
  }

  for (final mode in [GridItemFilterMode.all, GridItemFilterMode.restricted]) {
    testWidgets('general grid item picker excludes cauldrons in $mode', (
      tester,
    ) async {
      final saved = List<GridItemInfo>.from(GridItemRepository.staticItems);
      GridItemRepository.staticItems
        ..clear()
        ..addAll(const [
          GridItemInfo(
            typeName: 'wizard_crucible',
            category: GridItemCategory.scene,
            icon: 'wizard_crucible.webp',
          ),
          GridItemInfo(
            typeName: 'custom_cauldron',
            gameTypeName: 'wizard_crucible',
            category: GridItemCategory.scene,
          ),
          GridItemInfo(
            typeName: 'gravestone_egypt',
            category: GridItemCategory.scene,
          ),
        ]);
      addTearDown(() {
        GridItemRepository.staticItems
          ..clear()
          ..addAll(saved);
      });
      await tester.pumpWidget(
        _app(
          GridItemSelectionScreen(
            filterMode: mode,
            onGridItemSelected: (_) {},
            onBack: () {},
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('wizard_crucible'), findsNothing);
      expect(find.text('custom_cauldron'), findsNothing);
      expect(find.text('gravestone_egypt'), findsOneWidget);
      expect(
        GridItemRepository.getIconPath('wizard_crucible'),
        'assets/images/griditems/wizard_crucible.webp',
      );
      expect(tester.takeException(), isNull);
    });
  }
}
