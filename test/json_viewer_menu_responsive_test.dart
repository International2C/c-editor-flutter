import 'package:c_editor/data/interface_menu_config.dart';
import 'package:c_editor/data/pvz_models.dart';
import 'package:c_editor/l10n/app_localizations.dart';
import 'package:c_editor/screens/editor/json_viewer_screen.dart';
import 'package:c_editor/widgets/editor_components.dart';
import 'package:c_editor/widgets/persistent_scrollbar_scroll_behavior.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('JSON viewer menu preserves readable choices and their actions', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(320, 900);
    addTearDown(tester.view.reset);
    final level = PvzLevelFile(
      objects: [
        PvzObject(
          aliases: ['ResponsiveTestObject'],
          objClass: 'TestClass',
          objData: {'Value': 'menu edit fixture'},
        ),
      ],
    );
    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('en'),
        theme: ThemeData(platform: TargetPlatform.windows),
        scrollBehavior: const PersistentScrollbarScrollBehavior(),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(
            context,
          ).copyWith(textScaler: const TextScaler.linear(1.8)),
          child: child!,
        ),
        home: JsonViewerScreen(
          fileName: 'test.json',
          filePath: 'test.json',
          levelFile: level,
          onBack: () {},
          saveLevel: (_, _) async {},
        ),
      ),
    );
    await tester.pumpAndSettle();
    final l10n = AppLocalizations.of(
      tester.element(find.byType(JsonViewerScreen)),
    )!;

    Future<void> openMenu() async {
      await tester.tap(find.byIcon(Icons.more_vert));
      await tester.pumpAndSettle();
      expect(find.byType(EditorPopupMenuTile), findsNWidgets(4));
      expect(
        tester
            .widgetList<PopupMenuItem<String>>(
              find.byType(PopupMenuItem<String>),
            )
            .map((item) => item.value),
        ['toggle_view', 'copy', 'clear_unused', 'edit'],
      );
      for (final label in [
        l10n.tooltipToggleObjectView,
        l10n.tooltipCopyJson,
        l10n.tooltipClearUnused,
        l10n.tooltipEdit,
      ]) {
        final textFinder = find.descendant(
          of: find.byType(EditorPopupMenuTile),
          matching: find.text(label),
        );
        expect(textFinder, findsOneWidget);
        final text = tester.widget<Text>(textFinder);
        expect(text.maxLines, isNull);
        expect(text.overflow, isNot(TextOverflow.ellipsis));
        expect(tester.getSize(textFinder).width, greaterThanOrEqualTo(200));
      }
      expect(tester.takeException(), isNull);
    }

    await openMenu();
    await tester.tap(find.text(l10n.tooltipToggleObjectView));
    await tester.pumpAndSettle();
    expect(
      find.text('test.json ${l10n.jsonViewerModeObjectReading}'),
      findsOneWidget,
    );
    expect(tester.takeException(), isNull);

    await openMenu();
    await tester.tap(find.text(l10n.tooltipEdit));
    await tester.pumpAndSettle();
    expect(find.text('test.json ${l10n.jsonViewerModeEdit}'), findsOneWidget);
    expect(find.byIcon(Icons.save), findsOneWidget);
    expect(find.byType(EditorPopupMenuTile), findsNothing);
    expect(
      find.byWidgetPredicate(
        (widget) =>
            widget is TextField &&
            widget.controller?.text.contains('menu edit fixture') == true,
      ),
      findsOneWidget,
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('JSON viewer hides an empty overflow menu on wide screens', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(1000, 900);
    addTearDown(tester.view.reset);
    final menuActions =
        defaultInterfaceMenuActions(InterfaceMenuSurface.jsonViewer)
            .map(
              (action) =>
                  action.copyWith(placement: InterfaceMenuPlacement.toolbar),
            )
            .toList(growable: false);

    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('en'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: JsonViewerScreen(
          fileName: 'test.json',
          filePath: 'test.json',
          levelFile: PvzLevelFile(objects: const []),
          onBack: () {},
          saveLevel: (_, _) async {},
          menuActions: menuActions,
        ),
      ),
    );
    await tester.pumpAndSettle();

    final actionIds = [
      InterfaceMenuActionIds.toggleJsonView,
      InterfaceMenuActionIds.copyJson,
      InterfaceMenuActionIds.clearUnused,
      InterfaceMenuActionIds.editJson,
    ];
    final centers = <double>[];
    for (final id in actionIds) {
      final action = find.byKey(ValueKey('jsonToolbarAction_$id'));
      expect(action, findsOneWidget);
      centers.add(tester.getCenter(action).dx);
    }
    expect(centers, orderedEquals([...centers]..sort()));
    expect(find.byKey(const ValueKey('jsonOverflowMenu')), findsNothing);
    expect(tester.takeException(), isNull);
  });
}
