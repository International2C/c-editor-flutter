import 'package:c_editor/data/repository/plant_repository.dart';
import 'package:c_editor/data/repository/zombie_repository.dart';
import 'package:c_editor/l10n/app_localizations.dart';
import 'package:c_editor/l10n/resource_names.dart';
import 'package:c_editor/screens/select/plant_selection_screen.dart';
import 'package:c_editor/screens/select/zombie_selection_screen.dart';
import 'package:c_editor/widgets/selection_grid_confirmation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _confirmationRow = ValueKey('selectionConfirmationRow');

String _id(bool isPlant, int index) =>
    'confirmation_${isPlant ? 'plant' : 'zombie'}_$index';

String _name(int index) => 'Item $index';

void _temporaryResources(bool isPlant, int count) {
  if (isPlant) {
    final entries = PlantRepository().allPlants;
    final favorites = PlantRepository().favoriteIds;
    final savedEntries = List<PlantInfo>.of(entries);
    final savedFavorites = List<String>.of(favorites);
    entries
      ..clear()
      ..addAll([
        for (var i = 0; i < count; i++)
          PlantInfo(id: _id(true, i), name: _name(i), tags: [PlantTag.all]),
      ]);
    favorites.clear();
    addTearDown(() {
      entries
        ..clear()
        ..addAll(savedEntries);
      favorites
        ..clear()
        ..addAll(savedFavorites);
    });
  } else {
    final entries = ZombieRepository().allZombies;
    final favorites = ZombieRepository().favoriteIds;
    final savedEntries = List<ZombieInfo>.of(entries);
    final savedFavorites = List<String>.of(favorites);
    entries
      ..clear()
      ..addAll([
        for (var i = 0; i < count; i++)
          ZombieInfo(id: _id(false, i), name: _name(i), tags: [ZombieTag.all]),
      ]);
    favorites.clear();
    addTearDown(() {
      entries
        ..clear()
        ..addAll(savedEntries);
      favorites
        ..clear()
        ..addAll(savedFavorites);
    });
  }
}

Future<void> _open(
  WidgetTester tester, {
  required bool isPlant,
  required int count,
  required String bucket,
  Size size = const Size(360, 760),
  EdgeInsets padding = EdgeInsets.zero,
  bool rtl = false,
  bool multiSelect = true,
  ValueChanged<List<String>>? onMultiSelected,
  ValueChanged<String>? onSelected,
}) async {
  _temporaryResources(isPlant, count);
  tester.view.devicePixelRatio = 1;
  tester.view.physicalSize = size;
  final safePadding = FakeViewPadding(
    left: padding.left,
    top: padding.top,
    right: padding.right,
    bottom: padding.bottom,
  );
  tester.view.padding = safePadding;
  tester.view.viewPadding = safePadding;
  addTearDown(tester.view.reset);
  final screen = isPlant
      ? PlantSelectionScreen(
          stateBucketId: bucket,
          isMultiSelect: multiSelect,
          onPlantSelected: onSelected ?? (_) {},
          onMultiPlantSelected: onMultiSelected,
          onBack: () {},
        )
      : ZombieSelectionScreen(
          stateBucketId: bucket,
          multiSelect: multiSelect,
          onZombieSelected: onSelected ?? (_) {},
          onMultiZombieSelected: onMultiSelected,
          onBack: () {},
        );
  await tester.pumpWidget(
    MaterialApp(
      locale: const Locale('en'),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      builder: (context, child) => Directionality(
        textDirection: rtl ? TextDirection.rtl : TextDirection.ltr,
        child: child!,
      ),
      home: screen,
    ),
  );
  await tester.pumpAndSettle();
  expect(find.byType(GridView), findsOneWidget);
  _expectFullViewport(tester);
  expect(tester.takeException(), isNull);
}

ScrollController _gridController(WidgetTester tester) =>
    tester.widget<GridView>(find.byType(GridView)).controller!;

Future<void> _scrollToEnd(WidgetTester tester) async {
  final controller = _gridController(tester);
  controller.jumpTo(controller.position.maxScrollExtent);
  await tester.pumpAndSettle();
  expect(controller.offset, closeTo(controller.position.maxScrollExtent, .01));
}

Finder _gridScrollable() => find.descendant(
  of: find.byType(GridView),
  matching: find.byType(Scrollable),
);

void _expectFullViewport(WidgetTester tester) {
  final grid = tester.getRect(find.byType(GridView));
  final available = tester.getRect(find.byType(SelectionGridConfirmation));
  expect(grid, available, reason: 'Confirmation must not reserve a fixed row');
  expect(
    _gridController(tester).position.viewportDimension,
    closeTo(grid.height, .01),
  );
  expect(find.byKey(_confirmationRow), findsNothing);
  final button = find.byType(FloatingActionButton);
  if (button.evaluate().isNotEmpty) {
    expect(button.hitTestable(), findsOneWidget);
    expect(grid.contains(tester.getRect(button).center), isTrue);
  }
  expect(tester.takeException(), isNull);
}

Future<void> _exerciseScrollingViewport(WidgetTester tester) async {
  final controller = _gridController(tester);
  controller.jumpTo(0);
  await tester.pumpAndSettle();
  final viewport = tester.getRect(find.byType(GridView));
  final scrollState = tester.state<ScrollableState>(_gridScrollable());
  final button = find.byType(FloatingActionButton);
  final buttonRect = button.evaluate().isEmpty ? null : tester.getRect(button);
  _expectFullViewport(tester);
  // Reach the middle and end, scroll back up, then finish at the end again.
  // None of these movements may consume viewport height or move the button.
  for (final fraction in [.5, 1.0, .5, 1.0]) {
    if (fraction == 1) {
      await _scrollToEnd(tester);
    } else {
      controller.jumpTo(controller.position.maxScrollExtent * fraction);
      await tester.pumpAndSettle();
    }
    _expectFullViewport(tester);
    expect(tester.getRect(find.byType(GridView)), viewport);
    expect(tester.state<ScrollableState>(_gridScrollable()), same(scrollState));
    if (buttonRect != null) expect(tester.getRect(button), buttonRect);
  }
}

void _expectTailBelowButton(WidgetTester tester, int count) {
  expect(
    tester.getRect(_lastCard(count)).bottom,
    lessThanOrEqualTo(
      tester.getRect(find.byType(FloatingActionButton)).top - 16 + .01,
    ),
    reason: 'The final content must finish above the floating confirmation',
  );
}

Finder _lastCard(int count) => find
    .ancestor(of: find.text(_name(count - 1)), matching: find.byType(InkWell))
    .first;

Finder _lastIcon(bool isPlant, int count) => isPlant
    ? find.byKey(ValueKey('plantSelectionIcon-${_id(true, count - 1)}'))
    : find.descendant(of: _lastCard(count), matching: find.byType(ClipOval));

void _expectLastItemClear(
  WidgetTester tester, {
  required bool isPlant,
  required int count,
}) {
  final icon = _lastIcon(isPlant, count);
  final card = _lastCard(count);
  final confirmation = find.byType(FloatingActionButton);
  expect(icon, findsOneWidget);
  expect(icon.hitTestable(), findsOneWidget);
  expect(confirmation.hitTestable(), findsOneWidget);
  final buttonRect = tester.getRect(confirmation);
  expect(tester.getRect(card).overlaps(buttonRect), isFalse);
  expect(tester.getRect(icon).overlaps(buttonRect), isFalse);
  final bulk = find.byType(SelectionGridSelectAllButton);
  if (bulk.evaluate().isNotEmpty) {
    final bulkRect = tester.getRect(bulk);
    expect(tester.getRect(card).overlaps(bulkRect), isFalse);
    expect(tester.getRect(icon).overlaps(bulkRect), isFalse);
  }
  expect(tester.takeException(), isNull);
}

Future<void> _selectAndConfirm(
  WidgetTester tester, {
  required bool isPlant,
  required int count,
}) async {
  await tester.tap(_lastIcon(isPlant, count));
  await tester.pumpAndSettle();
  await tester.tap(find.byType(FloatingActionButton));
  await tester.pumpAndSettle();
  expect(tester.takeException(), isNull);
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(() async {
    SharedPreferences.setMockInitialValues({});
    await Future.wait([
      PlantRepository().init(),
      ZombieRepository().init(),
      ResourceNames.ensureLoaded(),
    ]);
  });
  setUp(() {
    SharedPreferences.setMockInitialValues({});
    rootBundle.clear();
  });

  for (final isPlant in [true, false]) {
    final kind = isPlant ? 'plant' : 'zombie';
    testWidgets(
      '$kind complete final row clears confirmation at the end without shrinking the viewport',
      (tester) async {
        List<String>? submitted;
        await _open(
          tester,
          isPlant: isPlant,
          count: 50,
          bucket: 'confirmation-$kind-full-row',
          onMultiSelected: (ids) => submitted = ids,
        );
        // At 360 dp this grid has five columns, so 50 ends at the right edge.
        expect(
          _gridController(tester).position.maxScrollExtent,
          greaterThan(0),
        );
        await _exerciseScrollingViewport(tester);
        _expectLastItemClear(tester, isPlant: isPlant, count: 50);
        _expectTailBelowButton(tester, 50);
        await _selectAndConfirm(tester, isPlant: isPlant, count: 50);
        expect(submitted, [_id(isPlant, 49)]);
      },
    );

    for (final count in [1, 49]) {
      testWidgets(
        '$kind ${count == 1 ? 'short list' : 'final row with a right-side gap'} keeps floating confirmation usable',
        (tester) async {
          List<String>? submitted;
          await _open(
            tester,
            isPlant: isPlant,
            count: count,
            bucket: 'confirmation-$kind-gap-$count',
            onMultiSelected: (ids) => submitted = ids,
          );
          expect(find.byKey(_confirmationRow), findsNothing);
          final padding = tester
              .widget<GridView>(find.byType(GridView))
              .padding!;
          expect(
            padding.resolve(TextDirection.ltr).bottom,
            count == 1 ? equals(12) : greaterThan(12),
            reason:
                'The bulk control covers the last row despite the gap beside the FAB',
          );
          expect(
            _gridController(tester).position.maxScrollExtent,
            count == 1 ? equals(0) : greaterThan(0),
          );
          await _exerciseScrollingViewport(tester);
          _expectLastItemClear(tester, isPlant: isPlant, count: count);
          final gridRect = tester.getRect(find.byType(GridView));
          final confirmationRect = tester.getRect(
            find.byType(FloatingActionButton),
          );
          expect(gridRect.contains(confirmationRect.center), isTrue);
          await _selectAndConfirm(tester, isPlant: isPlant, count: count);
          expect(submitted, [_id(isPlant, count - 1)]);
        },
      );
    }

    for (final rtl in [false, true]) {
      final direction = rtl ? 'RTL' : 'LTR';
      testWidgets(
        '$kind $direction floating confirmation respects both horizontal safe areas',
        (tester) async {
          List<String>? submitted;
          await _open(
            tester,
            isPlant: isPlant,
            count: 41,
            bucket: 'confirmation-$kind-safe-floating-$direction',
            padding: const EdgeInsets.symmetric(horizontal: 44),
            rtl: rtl,
            onMultiSelected: (ids) => submitted = ids,
          );
          expect(find.byKey(_confirmationRow), findsNothing);
          expect(
            tester
                .widget<GridView>(find.byType(GridView))
                .padding!
                .resolve(TextDirection.ltr)
                .bottom,
            greaterThan(12),
            reason: 'Safe-area insets put the bulk control above the final row',
          );
          await _exerciseScrollingViewport(tester);
          _expectLastItemClear(tester, isPlant: isPlant, count: 41);
          final button = tester.getRect(find.byType(FloatingActionButton));
          expect(button.left, greaterThanOrEqualTo(44));
          expect(button.right, lessThanOrEqualTo(360 - 44));
          expect(
            rtl ? button.left : 360 - button.right,
            closeTo(44 + 16, .01),
            reason: 'The floating margin must start inside the safe area',
          );
          await _selectAndConfirm(tester, isPlant: isPlant, count: 41);
          expect(submitted, [_id(isPlant, 40)]);
        },
      );

      testWidgets(
        '$kind $direction safe-area offset clears the occupied final row without a fixed row',
        (tester) async {
          List<String>? submitted;
          await _open(
            tester,
            isPlant: isPlant,
            count: 49,
            bucket: 'confirmation-$kind-safe-collision-$direction',
            padding: rtl
                ? const EdgeInsets.only(left: 44)
                : const EdgeInsets.only(right: 44),
            rtl: rtl,
            onMultiSelected: (ids) => submitted = ids,
          );
          // The final row leaves the outermost cell empty. A 44 dp safe area
          // shifts the would-be floating button into the adjacent occupied cell.
          await _exerciseScrollingViewport(tester);
          _expectLastItemClear(tester, isPlant: isPlant, count: 49);
          _expectTailBelowButton(tester, 49);
          final button = tester.getRect(find.byType(FloatingActionButton));
          expect(
            rtl ? button.left : 360 - button.right,
            greaterThanOrEqualTo(44),
          );
          await _selectAndConfirm(tester, isPlant: isPlant, count: 49);
          expect(submitted, [_id(isPlant, 48)]);
        },
      );
    }

    testWidgets(
      '$kind bottom safe area avoids the occupied row above a sparse final row',
      (tester) async {
        List<String>? submitted;
        await _open(
          tester,
          isPlant: isPlant,
          count: 41,
          bucket: 'confirmation-$kind-safe-previous-row',
          padding: const EdgeInsets.only(bottom: 68),
          onMultiSelected: (ids) => submitted = ids,
        );
        // Only the leftmost final-row cell is occupied. The bottom safe area
        // raises the floating button far enough to cover the preceding full row.
        await _exerciseScrollingViewport(tester);
        _expectLastItemClear(tester, isPlant: isPlant, count: 41);
        _expectLastItemClear(tester, isPlant: isPlant, count: 40);
        _expectTailBelowButton(tester, 41);
        _expectTailBelowButton(tester, 40);
        final button = tester.getRect(find.byType(FloatingActionButton));
        expect(button.bottom, lessThanOrEqualTo(760 - 68));
        await _selectAndConfirm(tester, isPlant: isPlant, count: 40);
        expect(submitted, [_id(isPlant, 39)]);
      },
    );

    testWidgets(
      '$kind recalculates confirmation on portrait and landscape resize without replacing the grid',
      (tester) async {
        List<String>? submitted;
        await _open(
          tester,
          isPlant: isPlant,
          count: 50,
          bucket: 'confirmation-$kind-resize',
          onMultiSelected: (ids) => submitted = ids,
        );
        final originalController = _gridController(tester);
        final gridScrollable = find.descendant(
          of: find.byType(GridView),
          matching: find.byType(Scrollable),
        );
        final originalScrollState = tester.state<ScrollableState>(
          gridScrollable,
        );
        await _exerciseScrollingViewport(tester);
        for (final scenario in [
          (size: const Size(720, 420), needsClearance: false),
          (size: const Size(430, 760), needsClearance: false),
          (size: const Size(360, 760), needsClearance: true),
        ]) {
          tester.view.physicalSize = scenario.size;
          await tester.pumpAndSettle();
          expect(_gridController(tester), same(originalController));
          expect(
            tester.state<ScrollableState>(gridScrollable),
            same(originalScrollState),
          );
          final padding = tester
              .widget<GridView>(find.byType(GridView))
              .padding!;
          expect(
            padding
                .resolve(
                  Directionality.of(tester.element(find.byType(GridView))),
                )
                .bottom,
            scenario.needsClearance ? greaterThan(12) : equals(12),
          );
          await _exerciseScrollingViewport(tester);
          _expectLastItemClear(tester, isPlant: isPlant, count: 50);
          if (scenario.needsClearance) _expectTailBelowButton(tester, 50);
        }
        await _selectAndConfirm(tester, isPlant: isPlant, count: 50);
        expect(submitted, [_id(isPlant, 49)]);
      },
    );

    testWidgets('$kind single selection has no confirmation button or row', (
      tester,
    ) async {
      String? submitted;
      await _open(
        tester,
        isPlant: isPlant,
        count: 50,
        bucket: 'confirmation-$kind-single',
        multiSelect: false,
        onSelected: (id) => submitted = id,
      );
      expect(find.byKey(_confirmationRow), findsNothing);
      expect(find.byType(FloatingActionButton), findsNothing);
      expect(
        tester.widget<GridView>(find.byType(GridView)).padding,
        const EdgeInsets.all(12),
      );
      await _exerciseScrollingViewport(tester);
      final lastIcon = _lastIcon(isPlant, 50);
      expect(lastIcon.hitTestable(), findsOneWidget);
      await tester.tap(lastIcon);
      await tester.pumpAndSettle();
      expect(submitted, _id(isPlant, 49));
      expect(tester.takeException(), isNull);
    });
  }
}
