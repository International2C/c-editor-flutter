import 'package:c_editor/data/pvz_models.dart';
import 'package:c_editor/l10n/app_localizations.dart';
import 'package:c_editor/screens/editor/basic_info_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('loot and victory choices use localized labels but keep RTIDs', (
    tester,
  ) async {
    final levelDef = LevelDefinitionData();
    var changes = 0;

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
          onChanged: () => changes++,
        ),
      ),
    );
    await tester.pumpAndSettle();

    final dropdowns = tester
        .widgetList<DropdownButton<String>>(find.byType(DropdownButton<String>))
        .toList();
    expect(dropdowns, hasLength(2));

    List<String?> labels(DropdownButton<String> dropdown) =>
        dropdown.items!.map((item) => (item.child as Text).data).toList();

    expect(labels(dropdowns[0]), ['默认掉落 (DefaultLoot)', '无掉落 (NoLoot)']);
    expect(labels(dropdowns[1]), [
      '默认胜利 (VictoryOutro)',
      '僵王战胜利 (ZombossVictoryOutro)',
    ]);

    dropdowns[0].onChanged!('RTID(NoLoot@LevelModules)');
    await tester.pump();
    expect(levelDef.loot, 'RTID(NoLoot@LevelModules)');

    final updatedDropdowns = tester
        .widgetList<DropdownButton<String>>(find.byType(DropdownButton<String>))
        .toList();
    updatedDropdowns[1].onChanged!('RTID(ZombossVictoryOutro@LevelModules)');
    await tester.pump();
    expect(levelDef.victoryModule, 'RTID(ZombossVictoryOutro@LevelModules)');
    expect(changes, 2);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Chinese basic information help matches the reference copy', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('zh'),
        supportedLocales: AppLocalizations.supportedLocales,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        home: BasicInfoScreen(
          levelFile: PvzLevelFile(objects: []),
          levelDef: LevelDefinitionData(),
          onBack: () {},
          onStageTap: null,
          onChanged: () {},
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.help_outline));
    await tester.pumpAndSettle();

    final dialog = find.byType(AlertDialog);
    expect(dialog, findsOneWidget);
    expect(find.text('关卡定义基础说明'), findsOneWidget);
    expect(find.text('关卡定义基础模块说明'), findsNothing);
    final dialogTitle = tester.widget<Text>(find.text('关卡定义基础说明'));
    expect(
      dialogTitle.style?.color,
      Theme.of(tester.element(dialog)).colorScheme.primary,
    );

    for (final title in const [
      '• 简要介绍',
      '• 基础信息界面',
      '• 场景设置',
      '• 剧情设置',
      '• 限制选项',
    ]) {
      expect(find.descendant(of: dialog, matching: find.text(title)), findsOne);
    }

    for (final body in const [
      '关卡定义是PvZ2关卡的根节点，不仅存放了关卡全局属性，还通过模块列表逐级链接了关卡内所有模块。本页面可以对关卡全局属性进行修改。',
      '这里可以定义关卡名称、描述、初始阳光等基本信息。关卡描述字段是进入关卡播放转场动画时的白色字幕。初始阳光是指计算账号阳光强化前的可用阳光。',
      '这里可以从列表中选择关卡的地图、音乐类型等场景信息。海盗港湾地图默认无甲板。\n音乐类型的可选范围由地图默认的音乐模块决定，自定义地图后可更改音乐模块，在关卡中使用其他地图的音乐。\n结算方式仅适用于部分特殊关卡种类，一般不建议对其进行修改。',
      '这里可以为关卡添加开始前和结束后播放的剧情对话。对话只能选取游戏中已有的对话，不能自定义。在庭院模块下，剧情对话每次进入关卡都会播放。',
      '这里提供禁用豆藤共生和神器的开关。豆藤共生是豌豆藤蔓的五阶技能，账户中拥有五阶豌豆藤蔓的玩家在开启该技能后，种植豌豆类植物时会立即附带种植1棵豌豆藤蔓，可能影响使用豌豆类植物的关卡的游玩体验。 在庭院模块下神器自动禁用，无需手动开启禁用开关。',
    ]) {
      expect(find.descendant(of: dialog, matching: find.text(body)), findsOne);
    }

    final overviewTitle = tester.widget<Text>(find.text('• 简要介绍'));
    expect(
      overviewTitle.style?.color,
      Theme.of(tester.element(dialog)).colorScheme.primary,
    );

    await tester.tap(find.text('我明白了'));
    await tester.pumpAndSettle();
    expect(find.byType(AlertDialog), findsNothing);
    expect(tester.takeException(), isNull);
  });

  test(
    'fixed offset descriptions identify Two-Player Mode in each locale',
    () async {
      const introductions = {
        'zh': '常见于双人对决，默认值为0。',
        'en': 'Commonly used in Two-Player Mode; the default is 0.',
        'ru': 'Часто используется в режиме для двух игроков; по умолчанию — 0.',
      };

      for (final entry in introductions.entries) {
        final localizations = await AppLocalizations.delegate.load(
          Locale(entry.key),
        );
        expect(
          localizations.jitterOffsetsFixedOffsetDescription,
          startsWith(entry.value),
        );
        expect(
          localizations.levelBasicInfoHelpSceneBody.split('\n'),
          hasLength(3),
        );
      }
    },
  );
}
