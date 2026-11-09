import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:c_editor/data/narrative_catalog.dart';
import 'package:c_editor/data/pvz_models.dart';
import 'package:c_editor/l10n/app_localizations.dart';
import 'package:c_editor/screens/editor/basic_info_screen.dart';
import 'package:c_editor/screens/select/narrative_selection_screen.dart';
import 'package:c_editor/utils/selection_view_memory.dart';
import 'package:c_editor/widgets/asset_image.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    NarrativeCatalog.clearCacheForTesting();
    SelectionViewMemoryStore.clear();
  });

  testWidgets('basic info selects integer, string, and no-dialogue values', (
    tester,
  ) async {
    final levelDef = LevelDefinitionData();
    var changeCount = 0;

    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('zh'),
        supportedLocales: AppLocalizations.supportedLocales,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        home: BasicInfoScreen(
          levelFile: PvzLevelFile(objects: []),
          levelDef: levelDef,
          onBack: () {},
          onStageTap: null,
          onChanged: () => changeCount++,
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(
      find.byKey(const ValueKey('narrative-settings-section')),
      findsOneWidget,
    );
    expect(find.text('无对话'), findsNWidgets(2));

    await tester.ensureVisible(
      find.byKey(const ValueKey('narrative-setting-FirstIntroNarrative')),
    );
    await tester.tap(
      find.byKey(const ValueKey('narrative-setting-FirstIntroNarrative')),
    );
    await tester.pumpAndSettle();

    for (final tag in const ['全部', '主线世界', '回忆之旅', '其他模式', '系统教学']) {
      expect(find.text(tag), findsOneWidget);
    }
    expect(find.text('铲子引导'), findsOneWidget);

    await tester.tap(find.text('铲子引导'));
    await tester.pumpAndSettle();
    expect(levelDef.firstIntroNarrative, 1000300);
    expect(levelDef.firstIntroNarrative, isA<int>());

    await tester.ensureVisible(
      find.byKey(const ValueKey('narrative-setting-FirstOutroNarrative')),
    );
    await tester.tap(
      find.byKey(const ValueKey('narrative-setting-FirstOutroNarrative')),
    );
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField).first, '能量豆收集引导');
    await tester.pumpAndSettle();
    expect(find.textContaining('按剧情名称（1条）'), findsOneWidget);
    await tester.tap(find.text('能量豆收集引导（未使用）'));
    await tester.pumpAndSettle();
    expect(levelDef.firstOutroNarrative, 'FRESHINTRO_COLLECT_INTRO');
    expect(levelDef.firstOutroNarrative, isA<String>());

    await tester.ensureVisible(
      find.byKey(const ValueKey('narrative-setting-FirstIntroNarrative')),
    );
    await tester.tap(
      find.byKey(const ValueKey('narrative-setting-FirstIntroNarrative')),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(Icons.clear));
    await tester.pumpAndSettle();
    await tester.tap(find.text('无对话'));
    await tester.pumpAndSettle();
    expect(levelDef.firstIntroNarrative, isNull);
    expect(changeCount, 3);
    expect(tester.takeException(), isNull);
  });

  testWidgets('info button opens dialogue content without selecting it', (
    tester,
  ) async {
    final catalog = await NarrativeCatalog.load(const Locale('zh'));
    final entry = catalog.dialogues.first;

    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('zh'),
        supportedLocales: AppLocalizations.supportedLocales,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        home: Builder(
          builder: (context) => Scaffold(
            body: Center(
              child: FilledButton(
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => _PickerHost(catalog: catalog),
                  ),
                ),
                child: const Text('open'),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();

    expect(find.textContaining('${entry.number} ·'), findsNothing);
    expect(find.text(entry.id), findsOneWidget);

    await tester.tap(find.byIcon(Icons.info_outline).first);
    await tester.pumpAndSettle();
    expect(find.text('剧情内容'), findsOneWidget);
    expect(find.text(entry.title), findsOneWidget);
    expect(find.textContaining('${entry.number} ·'), findsNothing);
    expect(find.text('调用值: ${entry.id}'), findsOneWidget);
    expect(find.text('那些豌豆射手被迷惑了，会挡住道路。'), findsOneWidget);
    expect(find.byKey(const ValueKey('npc-avatar-crazydave')), findsWidgets);
    expect(tester.takeException(), isNull);
  });

  testWidgets('unknown narrative rawId uses the shared unknown image', (
    tester,
  ) async {
    final levelDef = LevelDefinitionData()
      ..firstIntroNarrative = 'UNKNOWN_NARRATIVE_RAW_ID';

    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('zh'),
        supportedLocales: AppLocalizations.supportedLocales,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        home: BasicInfoScreen(
          levelFile: PvzLevelFile(objects: []),
          levelDef: levelDef,
          onBack: () {},
          onStageTap: null,
          onChanged: () {},
        ),
      ),
    );
    await tester.pumpAndSettle();

    final settingCard = find.byKey(
      const ValueKey('narrative-setting-FirstIntroNarrative'),
    );
    await tester.ensureVisible(settingCard);
    final image = tester.widget<AssetImageWidget>(
      find.descendant(of: settingCard, matching: find.byType(AssetImageWidget)),
    );
    expect(image.assetPath, 'assets/images/others/unknown.webp');
    expect(find.text('UNKNOWN_NARRATIVE_RAW_ID'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}

class _PickerHost extends StatelessWidget {
  const _PickerHost({required this.catalog});

  final NarrativeCatalog catalog;

  @override
  Widget build(BuildContext context) {
    return NarrativeSelectionScreen(
      catalog: catalog,
      currentValue: null,
      onSelected: (_) {},
    );
  }
}
