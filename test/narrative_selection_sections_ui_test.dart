import 'package:c_editor/data/narrative_catalog.dart';
import 'package:c_editor/l10n/app_localizations.dart';
import 'package:c_editor/screens/select/narrative_selection_screen.dart';
import 'package:c_editor/utils/selection_view_memory.dart';
import 'package:c_editor/widgets/asset_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    NarrativeCatalog.clearCacheForTesting();
    SelectionViewMemoryStore.clear();
  });

  testWidgets('All lists dialogues while concrete tags open section cards', (
    tester,
  ) async {
    final catalog = await NarrativeCatalog.load(const Locale('zh'));
    await tester.pumpWidget(_pickerApp(catalog, bucket: 'section-navigation'));
    await tester.pumpAndSettle();

    expect(
      find.byKey(const ValueKey('narrative-all-dialogue-list')),
      findsOneWidget,
    );
    expect(find.text('铲子引导'), findsOneWidget);
    expect(find.text('教程庭院'), findsNothing);

    await tester.tap(find.text('主线世界'));
    await tester.pumpAndSettle();
    expect(
      find.byKey(const ValueKey('narrative-section-grid')),
      findsOneWidget,
    );
    await tester.tap(find.text('教程庭院'));
    await tester.pumpAndSettle();
    final sectionList = find.byKey(
      const ValueKey('narrative-section-list-tutorialYard'),
    );
    expect(sectionList, findsOneWidget);
    expect(find.text('铲子引导'), findsOneWidget);
    final sectionImages = tester.widgetList<AssetImageWidget>(
      find.descendant(of: sectionList, matching: find.byType(AssetImageWidget)),
    );
    expect(sectionImages, isNotEmpty);
    expect(
      sectionImages.every(
        (image) =>
            image.assetPath == 'assets/images/round_icons/Stage_Modern.webp',
      ),
      isTrue,
    );

    await tester.tap(find.byType(BackButton));
    await tester.pumpAndSettle();
    expect(
      find.byKey(const ValueKey('narrative-section-grid')),
      findsOneWidget,
    );

    await tester.tap(find.text('系统教学'));
    await tester.pumpAndSettle();
    expect(
      find.byKey(const ValueKey('narrative-system-tutorial-list')),
      findsOneWidget,
    );
    expect(find.text('无对话'), findsOneWidget);
    expect(find.byKey(const ValueKey('narrative-section-grid')), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'Memory Lane import and mode tutorials are first in their lists',
    (tester) async {
      final catalog = await NarrativeCatalog.load(const Locale('zh'));
      await tester.pumpWidget(_pickerApp(catalog, bucket: 'tutorial-order'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('回忆之旅'));
      await tester.pumpAndSettle();
      final memoryImportCard = find.byKey(
        const ValueKey('narrative-section-memoryImport'),
      );
      final memoryImportImage = tester.widget<AssetImageWidget>(
        find.descendant(
          of: memoryImportCard,
          matching: find.byType(AssetImageWidget),
        ),
      );
      expect(memoryImportImage.fit, BoxFit.contain);
      expect(
        find.descendant(of: memoryImportCard, matching: find.byType(ClipOval)),
        findsNothing,
      );

      for (final season in [27, 28, 29, 30, 31, 32]) {
        final seasonCard = find.byKey(
          ValueKey('narrative-section-memorySeason$season'),
        );
        final seasonImage = tester.widget<AssetImageWidget>(
          find.descendant(
            of: seasonCard,
            matching: find.byType(AssetImageWidget),
          ),
        );
        expect(seasonImage.fit, BoxFit.contain);
        expect(
          find.descendant(of: seasonCard, matching: find.byType(ClipOval)),
          findsNothing,
        );
      }

      await tester.tap(find.text('第27赛季'));
      await tester.pumpAndSettle();
      final seasonList = find.byKey(
        const ValueKey('narrative-section-list-memorySeason27'),
      );
      final seasonEntryImages = tester.widgetList<AssetImageWidget>(
        find.descendant(
          of: seasonList,
          matching: find.byType(AssetImageWidget),
        ),
      );
      expect(seasonEntryImages, isNotEmpty);
      expect(
        seasonEntryImages.every((image) => image.fit == BoxFit.contain),
        isTrue,
      );
      expect(
        find.descendant(of: seasonList, matching: find.byType(ClipRRect)),
        findsNothing,
      );

      await tester.tap(find.byType(BackButton));
      await tester.pumpAndSettle();
      await tester.tap(find.text('引入剧情'));
      await tester.pumpAndSettle();
      expect(find.text('系统教程 - 回忆之旅'), findsOneWidget);
      expect(find.text('回忆之旅 - 引入剧情1'), findsOneWidget);
      expect(
        tester.getTopLeft(find.text('系统教程 - 回忆之旅')).dy,
        lessThan(tester.getTopLeft(find.text('回忆之旅 - 引入剧情1')).dy),
      );

      await tester.tap(find.byType(BackButton));
      await tester.pumpAndSettle();
      await tester.tap(find.text('其他模式'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('时空秘境'));
      await tester.pumpAndSettle();
      expect(find.text('系统教程 - 时空秘境'), findsOneWidget);
      expect(find.text('惊魂万圣夜 - 秘境引导'), findsOneWidget);
      expect(
        tester.getTopLeft(find.text('系统教程 - 时空秘境')).dy,
        lessThan(tester.getTopLeft(find.text('惊魂万圣夜 - 秘境引导')).dy),
      );

      await tester.tap(find.byType(BackButton));
      await tester.pumpAndSettle();
      await tester.scrollUntilVisible(
        find.text('牌面纷争'),
        300,
        scrollable: find.descendant(
          of: find.byKey(const ValueKey('narrative-section-grid')),
          matching: find.byType(Scrollable),
        ),
      );
      await tester.tap(find.text('牌面纷争'));
      await tester.pumpAndSettle();
      expect(find.text('系统教程 - 牌面纷争'), findsOneWidget);
      expect(find.text('牌面纷争 - 入门'), findsOneWidget);
      expect(
        tester.getTopLeft(find.text('系统教程 - 牌面纷争')).dy,
        lessThan(tester.getTopLeft(find.text('牌面纷争 - 入门')).dy),
      );
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('picker restores section-grid scroll only for the same level', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(480, 420);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final catalog = await NarrativeCatalog.load(const Locale('zh'));
    Finder gridScrollable() => find.descendant(
      of: find.byKey(const ValueKey('narrative-section-grid')),
      matching: find.byType(Scrollable),
    );

    await tester.pumpWidget(_pickerApp(catalog, bucket: 'level-a'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('主线世界'));
    await tester.pumpAndSettle();
    await tester.drag(
      find.byKey(const ValueKey('narrative-section-grid')),
      const Offset(0, -700),
    );
    await tester.pumpAndSettle();
    final savedOffset = tester
        .state<ScrollableState>(gridScrollable())
        .position
        .pixels;
    expect(savedOffset, greaterThan(100));

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pumpAndSettle();
    await tester.pumpWidget(_pickerApp(catalog, bucket: 'level-a'));
    await tester.pumpAndSettle();
    expect(
      tester.state<ScrollableState>(gridScrollable()).position.pixels,
      closeTo(savedOffset, 1),
    );

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pumpAndSettle();
    await tester.pumpWidget(_pickerApp(catalog, bucket: 'level-b'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('主线世界'));
    await tester.pumpAndSettle();
    expect(tester.state<ScrollableState>(gridScrollable()).position.pixels, 0);
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'large search groups collapse without eagerly building all rows',
    (tester) async {
      tester.view.physicalSize = const Size(800, 600);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final catalog = await NarrativeCatalog.load(const Locale('zh'));
      final results = searchNarratives(catalog, NarrativeCategory.all, '疯狂戴夫');
      expect(
        results.byContent.length + results.bySpeaker.length,
        greaterThan(50),
      );

      await tester.pumpWidget(_pickerApp(catalog, bucket: 'search-collapse'));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField), '疯狂戴夫');
      await tester.pump();

      expect(
        tester
            .widgetList<AssetImageWidget>(find.byType(AssetImageWidget))
            .length,
        lessThan(results.byContent.length + results.bySpeaker.length),
      );
      final contentHeader = find.byKey(
        const ValueKey('narrative-search-header-content'),
      );
      expect(contentHeader, findsOneWidget);
      await tester.tap(contentHeader);
      await tester.pump();
      expect(
        find.descendant(
          of: contentHeader,
          matching: find.byIcon(Icons.chevron_right),
        ),
        findsOneWidget,
      );
      expect(tester.takeException(), isNull);
    },
  );
}

Widget _pickerApp(NarrativeCatalog catalog, {required String bucket}) {
  return MaterialApp(
    locale: const Locale('zh'),
    supportedLocales: AppLocalizations.supportedLocales,
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    home: NarrativeSelectionScreen(
      catalog: catalog,
      currentValue: null,
      stateBucketId: bucket,
      onSelected: (_) {},
    ),
  );
}
