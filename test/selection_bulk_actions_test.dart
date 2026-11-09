import 'package:c_editor/data/pvz_models.dart';
import 'package:c_editor/data/repository/plant_repository.dart';
import 'package:c_editor/data/repository/zombie_repository.dart';
import 'package:c_editor/l10n/app_localizations.dart';
import 'package:c_editor/l10n/resource_names.dart';
import 'package:c_editor/screens/select/plant_selection_screen.dart';
import 'package:c_editor/screens/select/zombie_selection_screen.dart';
import 'package:c_editor/widgets/selection_grid_confirmation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void _useFixtureResources(bool isPlant) {
  if (isPlant) {
    final entries = PlantRepository().allPlants;
    final original = List<PlantInfo>.of(entries);
    entries
      ..clear()
      ..addAll([
        for (final (id, name) in [
          ('alpha_one', 'Alpha one'),
          ('alpha_two', 'Alpha two'),
          ('beta', 'Beta'),
          ('excluded', 'Alpha excluded'),
          ('coming_soon', 'Alpha unavailable'),
        ])
          PlantInfo(id: id, name: name, tags: [PlantTag.all]),
        PlantInfo(
          id: 'module_required',
          name: 'Alpha module required',
          tags: [PlantTag.all],
          internalTags: ['_internal_copycats'],
        ),
        PlantInfo(id: 'hidden', name: 'Alpha hidden', tags: [PlantTag.hidden]),
      ]);
    addTearDown(
      () => entries
        ..clear()
        ..addAll(original),
    );
  } else {
    final entries = ZombieRepository().allZombies;
    final original = List<ZombieInfo>.of(entries);
    entries
      ..clear()
      ..addAll([
        for (final (id, name) in [
          ('alpha_one', 'Alpha one'),
          ('alpha_two', 'Alpha two'),
          ('beta', 'Beta'),
          ('excluded', 'Alpha excluded'),
          ('stay_tuned', 'Alpha unavailable'),
          ('zombie_target_arrow_fixture', 'Alpha module required'),
        ])
          ZombieInfo(id: id, name: name, tags: [ZombieTag.all]),
      ]);
    addTearDown(
      () => entries
        ..clear()
        ..addAll(original),
    );
  }
}

Future<void> _open(
  WidgetTester tester, {
  required bool isPlant,
  required String bucket,
  required ValueChanged<List<String>> onConfirmed,
  List<String> initialIds = const [],
  bool allowDuplicates = false,
  String locale = 'en',
  double textScale = 1,
  VoidCallback? onBack,
}) async {
  tester.view.physicalSize = const Size(320, 760);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  _useFixtureResources(isPlant);
  final level = PvzLevelFile(objects: []);
  final screen = isPlant
      ? PlantSelectionScreen(
          stateBucketId: bucket,
          isMultiSelect: true,
          allowDuplicateSelection: allowDuplicates,
          levelFile: level,
          blockHiddenPlantsInChooser: true,
          excludeIds: const ['excluded'],
          initialSelectedIds: initialIds,
          onPlantSelected: (_) =>
              fail('Multi-select must wait for confirmation'),
          onMultiPlantSelected: onConfirmed,
          onBack: onBack ?? () {},
        )
      : ZombieSelectionScreen(
          stateBucketId: bucket,
          multiSelect: true,
          allowDuplicateSelection: allowDuplicates,
          levelFile: level,
          excludeIds: const ['excluded'],
          initialSelectedIds: initialIds,
          onZombieSelected: (_) =>
              fail('Multi-select must wait for confirmation'),
          onMultiZombieSelected: onConfirmed,
          onBack: onBack ?? () {},
        );
  await tester.pumpWidget(
    MaterialApp(
      locale: Locale(locale),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(
          context,
        ).copyWith(textScaler: TextScaler.linear(textScale)),
        child: child!,
      ),
      home: screen,
    ),
  );
  await tester.pumpAndSettle();
}

Future<void> _search(WidgetTester tester, String query) async {
  await tester.enterText(find.byType(TextField).first, query);
  await tester.pumpAndSettle();
}

Future<void> _toggleAll(WidgetTester tester) async {
  await tester.tap(find.byType(SelectionGridSelectAllButton));
  await tester.pumpAndSettle();
}

Future<void> _confirm(WidgetTester tester) async {
  await tester.tap(find.byType(FloatingActionButton));
  await tester.pumpAndSettle();
}

void main() {
  setUpAll(() async {
    SharedPreferences.setMockInitialValues({});
    await Future.wait([
      PlantRepository().init(),
      ZombieRepository().init(),
      ResourceNames.ensureLoaded(),
    ]);
  });

  testWidgets('bulk confirmation controls fit double text with safe areas', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    var toggles = 0;
    var confirmations = 0;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: MediaQuery(
            data: const MediaQueryData(
              size: Size(320, 400),
              padding: EdgeInsets.symmetric(horizontal: 44),
              textScaler: TextScaler.linear(2),
            ),
            child: SelectionGridConfirmation(
              itemCount: 0,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
              ),
              confirmation: FloatingActionButton(
                onPressed: () => confirmations++,
                child: const Icon(Icons.check),
              ),
              selectAll: SelectionGridSelectAllButton(
                label: lookupAppLocalizations(const Locale('ru')).deselectAll,
                onPressed: () => toggles++,
              ),
              builder: (_, _) => const SizedBox.expand(),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    final bulk = find.byType(SelectionGridSelectAllButton);
    final confirm = find.byType(FloatingActionButton);
    expect(tester.getRect(bulk).left, greaterThanOrEqualTo(60));
    expect(tester.getRect(confirm).right, lessThanOrEqualTo(260));
    expect(
      tester.getRect(bulk).right,
      lessThanOrEqualTo(tester.getRect(confirm).left - 12),
    );
    await tester.tap(bulk);
    await tester.tap(confirm);
    expect(toggles, 1);
    expect(confirmations, 1);
    expect(tester.takeException(), isNull);
  });

  for (final isPlant in [true, false]) {
    final kind = isPlant ? 'plant' : 'zombie';
    testWidgets('$kind bulk actions respect filters and blocked selections', (
      tester,
    ) async {
      List<String>? submitted;
      await _open(
        tester,
        isPlant: isPlant,
        bucket: '$kind-bulk-filters',
        initialIds: [
          'beta',
          'excluded',
          isPlant ? 'coming_soon' : 'stay_tuned',
          isPlant ? 'module_required' : 'zombie_target_arrow_fixture',
          if (isPlant) 'hidden',
        ],
        onConfirmed: (ids) => submitted = ids,
      );
      await _confirm(tester);
      expect(submitted, ['beta']);
      await _search(tester, 'Alpha');
      await _toggleAll(tester);
      expect(find.text('Deselect ALL'), findsOneWidget);
      expect(find.byType(AlertDialog), findsNothing);
      await _confirm(tester);
      expect(submitted, ['beta', 'alpha_one', 'alpha_two']);

      await _search(tester, 'Beta');
      expect(find.text('Deselect ALL'), findsOneWidget);
      await _toggleAll(tester);
      await _confirm(tester);
      expect(submitted, ['alpha_one', 'alpha_two']);

      await _search(tester, 'Alpha');
      await _toggleAll(tester);
      expect(find.text('Select ALL'), findsOneWidget);
      await _confirm(tester);
      expect(submitted, isEmpty);

      await _search(tester, 'no matching resource');
      expect(
        tester
            .widget<SelectionGridSelectAllButton>(
              find.byType(SelectionGridSelectAllButton),
            )
            .onPressed,
        isNull,
      );
      expect(tester.takeException(), isNull);
    });

    testWidgets('$kind duplicate batch toggle clears visible duplicates only', (
      tester,
    ) async {
      List<String>? submitted;
      var callbacks = 0;
      var backedOut = false;
      await _open(
        tester,
        isPlant: isPlant,
        bucket: '$kind-bulk-duplicates',
        allowDuplicates: true,
        onConfirmed: (ids) {
          submitted = ids;
          callbacks++;
        },
        onBack: () => backedOut = true,
      );
      await _search(tester, 'Alpha');
      for (var i = 0; i < 2; i++) {
        await tester.tap(find.text('Alpha one'));
        await tester.pumpAndSettle();
      }
      expect(callbacks, 0);
      await _toggleAll(tester);
      await _confirm(tester);
      expect(submitted, ['alpha_one', 'alpha_one', 'alpha_two']);
      await _search(tester, 'Beta');
      await tester.tap(
        find.descendant(of: find.byType(GridView), matching: find.text('Beta')),
      );
      await tester.pumpAndSettle();
      await _search(tester, 'Alpha');
      await _toggleAll(tester);
      await _confirm(tester);
      expect(submitted, ['beta']);
      final beforeBack = callbacks;
      await tester.tap(find.byIcon(Icons.arrow_back));
      await tester.pumpAndSettle();
      expect(backedOut, isTrue);
      expect(callbacks, beforeBack);
      expect(tester.takeException(), isNull);
    });

    testWidgets('$kind Russian bulk controls fit narrow enlarged text', (
      tester,
    ) async {
      await _open(
        tester,
        isPlant: isPlant,
        bucket: '$kind-bulk-russian',
        locale: 'ru',
        textScale: 1.5,
        onConfirmed: (_) {},
      );
      await _search(tester, 'Alpha');
      await _toggleAll(tester);
      final strings = lookupAppLocalizations(const Locale('ru'));
      expect(find.text(strings.deselectAll), findsOneWidget);
      final bulk = tester.getRect(find.byType(SelectionGridSelectAllButton));
      final confirm = tester.getRect(find.byType(FloatingActionButton));
      expect(bulk.left, greaterThanOrEqualTo(16));
      expect(confirm.right, lessThanOrEqualTo(304));
      expect(bulk.right, lessThanOrEqualTo(confirm.left - 12));
      expect(tester.takeException(), isNull);
    });
  }
}
