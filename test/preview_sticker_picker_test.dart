import 'dart:convert';
import 'dart:io';

import 'package:c_editor/bundled_plugins/preview_img_cplugin/lib/src/preview/preview_pickers.dart';
import 'package:c_editor/bundled_plugins/preview_img_cplugin/lib/src/preview/preview_sticker_catalog.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import 'helpers/preview_scrollbar_gesture.dart';

const _labels = <String, String>{
  'previewGenStickersTitle': '添加贴纸',
  'previewGenImageSearch': '搜索贴纸',
  'previewGenImageAll': '全部',
  'previewGenCancel': '取消',
  'previewGenCustomImage': '从文件添加',
  'previewStickerTagPlants': '植物',
  'previewStickerTagZombies': '僵尸',
  'previewStickerTagGridItems': '障碍物',
  'previewStickerTagCreatures': '中立生物',
  'previewStickerTagToolPackets': '工具卡',
  'previewStickerTagComponents': '场地组件',
  'previewStickerTagNPC': '剧情角色',
  'previewStickerTagMapAndMusic': '模式与音乐',
  'previewStickerTagUI': '标记与主题',
  'previewStickerTagWorlds': '世界',
  'previewStickerTagOthers': '其他',
  'fixtureSunflower': '向日葵',
  'fixtureZombie': '普通僵尸',
};

String _t(String key, [String? fallback]) => _labels[key] ?? fallback ?? key;

List<PreviewSticker> _stickers(int count) => [
  for (var i = 0; i < count; i++)
    PreviewSticker(
      assetPath: 'assets/images/plants/fixture_$i.webp',
      tag: 'plants',
      labelKey: i == 0 ? 'fixtureSunflower' : 'fixtureZombie',
      searchTerms: ['fixture_$i'],
    ),
];

Future<void> _open(
  WidgetTester tester, {
  required Size size,
  required List<PreviewSticker> stickers,
  double textScale = 1,
  double keyboardHeight = 0,
  ValueChanged<PreviewAssetImageChoice?>? onSelected,
  PreviewStickerPickerSession? session,
  Iterable<String> priorityAssetPaths = const [],
  TargetPlatform platform = TargetPlatform.android,
}) async {
  tester.view.devicePixelRatio = 1;
  tester.view.physicalSize = size;
  tester.view.viewInsets = FakeViewPadding(bottom: keyboardHeight);
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
    MaterialApp(
      theme: ThemeData(platform: platform),
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(
          context,
        ).copyWith(textScaler: TextScaler.linear(textScale)),
        child: child!,
      ),
      home: Builder(
        builder: (context) => Scaffold(
          body: TextButton(
            onPressed: () async {
              final selected = await showDialog<PreviewAssetImageChoice>(
                context: context,
                builder: (_) => PreviewStickerPickerDialog(
                  stickers: stickers,
                  t: _t,
                  session: session,
                  priorityAssetPaths: priorityAssetPaths,
                ),
              );
              onSelected?.call(selected);
            },
            child: const Text('Open'),
          ),
        ),
      ),
    ),
  );
  await tester.tap(find.text('Open'));
  await tester.pumpAndSettle();
}

void main() {
  setUp(rootBundle.clear);

  testWidgets(
    'new tags retain the viewport and visited tags retain their own position',
    (tester) async {
      await _open(
        tester,
        size: const Size(900, 600),
        stickers: [
          ..._stickers(80),
          for (var i = 0; i < 80; i++)
            PreviewSticker(
              assetPath: 'assets/images/zombies/fixture_$i.webp',
              tag: 'zombies',
              labelKey: 'fixtureZombie',
            ),
          const PreviewSticker(
            assetPath: 'assets/images/others/fixture.webp',
            tag: 'others',
            labelKey: 'fixtureSunflower',
          ),
        ],
      );
      final controller = tester
          .widget<CustomScrollView>(
            find.byKey(const ValueKey('preview-sticker-scroll')),
          )
          .controller!;
      controller.jumpTo(90);
      await tester.pumpAndSettle();
      await tester.tap(
        find.byKey(const ValueKey('preview-sticker-tag-plants')),
      );
      await tester.pumpAndSettle();
      expect(controller.offset, closeTo(90, 1));

      controller.jumpTo(110);
      await tester.pumpAndSettle();
      await tester.tap(
        find.byKey(const ValueKey('preview-sticker-tag-zombies')),
      );
      await tester.pumpAndSettle();
      expect(controller.offset, closeTo(110, 1));

      controller.jumpTo(80);
      await tester.pumpAndSettle();
      await tester.tap(
        find.byKey(const ValueKey('preview-sticker-tag-plants')),
      );
      await tester.pumpAndSettle();
      expect(controller.offset, closeTo(110, 1));

      await tester.tap(
        find.byKey(const ValueKey('preview-sticker-tag-others')),
      );
      await tester.pumpAndSettle();
      expect(controller.offset, controller.position.maxScrollExtent);
      expect(controller.offset, 0);
      await tester.tap(
        find.byKey(const ValueKey('preview-sticker-tag-zombies')),
      );
      await tester.pumpAndSettle();
      expect(controller.offset, closeTo(80, 1));
      expect(tester.takeException(), isNull);
    },
  );

  for (final platform in [TargetPlatform.android, TargetPlatform.iOS]) {
    testWidgets(
      'vertical sticker thumb drags on ${platform.name} without choosing a sticker',
      (tester) async {
        var selected = false;
        await _open(
          tester,
          size: const Size(390, 700),
          stickers: [
            for (final tag in kPreviewImageFolders)
              for (var i = 0; i < 20; i++)
                PreviewSticker(
                  assetPath: 'assets/images/$tag/fixture_$i.webp',
                  tag: tag,
                  labelKey: 'fixtureSunflower',
                ),
          ],
          platform: platform,
          onSelected: (_) => selected = true,
        );
        final controller = tester
            .widget<CustomScrollView>(
              find.byKey(const ValueKey('preview-sticker-scroll')),
            )
            .controller!;
        expect(controller.offset, 0);
        await tester.drag(
          find.byKey(const ValueKey('preview-sticker-tags-scroll')),
          const Offset(-120, 0),
        );
        await tester.pumpAndSettle();
        expect(controller.offset, 0);
        await dragPreviewVerticalScrollbar(
          tester,
          const ValueKey('preview-sticker-scrollbar'),
        );
        expect(controller.offset, greaterThan(200));
        expect(selected, isFalse);
        expect(find.byType(PreviewStickerPickerDialog), findsOneWidget);
        expect(tester.takeException(), isNull);
      },
    );
  }

  test('toolbar and tag names use matching, capitalized locale keys', () {
    const path = 'lib/bundled_plugins/preview_img_cplugin/assets/l10n';
    final en = jsonDecode(File('$path/en.arb').readAsStringSync()) as Map;
    final zh = jsonDecode(File('$path/zh.arb').readAsStringSync()) as Map;
    expect(en['previewGenAddText'], 'Text');
    expect(en['previewGenAddImage'], 'Stickers');
    expect(zh['previewGenAddText'], '文本');
    expect(zh['previewGenAddImage'], '贴纸');
    for (final key in _labels.keys.where(
      (key) => key.startsWith('previewStickerTag'),
    )) {
      expect(zh[key], isNotEmpty);
      expect(en[key], matches(RegExp(r'^[A-Z]')));
    }
    expect(kPreviewImageFolders.last, 'others');
  });

  testWidgets('new localized tags filter their stickers independently', (
    tester,
  ) async {
    final stickers = [
      for (final tag in [
        'griditems',
        'creatures',
        'tool_packets',
        'components',
        'npcs',
      ])
        PreviewSticker(
          assetPath: 'assets/images/others/fixture_$tag.webp',
          tag: tag,
          labelKey: 'fixtureSunflower',
        ),
    ];
    await _open(tester, size: const Size(1100, 700), stickers: stickers);
    for (final (tag, label) in [
      ('creatures', '中立生物'),
      ('tool_packets', '工具卡'),
      ('components', '场地组件'),
      ('npcs', '剧情角色'),
      ('griditems', '障碍物'),
    ]) {
      await tester.ensureVisible(find.text(label));
      await tester.tap(find.text(label));
      await tester.pumpAndSettle();
      for (final sticker in stickers) {
        expect(
          find.byKey(ValueKey('preview-sticker-${sticker.assetPath}')),
          sticker.tag == tag ? findsOneWidget : findsNothing,
        );
      }
      expect(tester.takeException(), isNull);
    }
  });

  for (final keyboardHeight in [0.0, 120.0]) {
    testWidgets(
      'landscape touch scroll reaches stickers with keyboard $keyboardHeight',
      (tester) async {
        final stickers = _stickers(80);
        PreviewAssetImageChoice? selected;
        await _open(
          tester,
          size: const Size(900, 380),
          stickers: stickers,
          textScale: 1.35,
          keyboardHeight: keyboardHeight,
          onSelected: (choice) => selected = choice,
        );
        final scroll = find.byKey(const ValueKey('preview-sticker-scroll'));
        expect(tester.getSize(scroll).height, greaterThan(40));
        final target = find.byKey(
          ValueKey('preview-sticker-${stickers.last.assetPath}'),
        );
        await tester.scrollUntilVisible(
          target,
          160,
          scrollable: find
              .descendant(of: scroll, matching: find.byType(Scrollable))
              .first,
          maxScrolls: 30,
        );
        await tester.pumpAndSettle();
        expect(target.hitTestable(), findsOneWidget);
        expect(find.text('从文件添加').hitTestable(), findsOneWidget);
        await tester.tap(target);
        await tester.pumpAndSettle();
        expect(selected?.assetPath, stickers.last.assetPath);
        expect(tester.takeException(), isNull);
      },
    );
  }

  testWidgets('localized names are searchable and used instead of filenames', (
    tester,
  ) async {
    final stickers = _stickers(2);
    await _open(tester, size: const Size(900, 600), stickers: stickers);
    await tester.enterText(
      find.byKey(const ValueKey('preview-sticker-search')),
      '向日葵',
    );
    await tester.pumpAndSettle();
    expect(find.byTooltip('向日葵'), findsOneWidget);
    expect(find.byTooltip('普通僵尸'), findsNothing);
    expect(find.byTooltip('fixture_0.webp'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('search hint and prefix icon share a vertical center', (
    tester,
  ) async {
    await _open(
      tester,
      size: const Size(900, 600),
      stickers: _stickers(2),
      textScale: 1.5,
    );
    final field = find.byKey(const ValueKey('preview-sticker-search'));
    final icon = find.descendant(
      of: field,
      matching: find.byIcon(Icons.search),
    );
    final hint = find.descendant(of: field, matching: find.text('搜索贴纸'));
    expect(
      (tester.getCenter(icon).dy - tester.getCenter(hint).dy).abs(),
      lessThanOrEqualTo(2),
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('current-level stickers stay first in All, tags and search', (
    tester,
  ) async {
    final stickers = [
      ..._stickers(3),
      for (var i = 0; i < 3; i++)
        PreviewSticker(
          assetPath: 'assets/images/zombies/fixture_$i.webp',
          tag: 'zombies',
          labelKey: 'fixtureZombie',
          searchTerms: ['fixture_$i'],
        ),
    ];
    await _open(
      tester,
      size: const Size(900, 700),
      stickers: stickers,
      priorityAssetPaths: [stickers[1].assetPath, stickers[5].assetPath],
    );
    List<Key?> displayedKeys() => tester
        .widgetList<InkWell>(
          find.byWidgetPredicate(
            (widget) =>
                widget is InkWell &&
                widget.key is ValueKey<String> &&
                (widget.key! as ValueKey<String>).value.startsWith(
                  'preview-sticker-assets/',
                ),
          ),
        )
        .map((widget) => widget.key)
        .toList();
    Key stickerKey(PreviewSticker sticker) =>
        ValueKey('preview-sticker-${sticker.assetPath}');
    expect(displayedKeys(), [
      for (final index in [1, 5, 0, 2, 3, 4]) stickerKey(stickers[index]),
    ]);
    await tester.tap(find.byKey(const ValueKey('preview-sticker-tag-zombies')));
    await tester.pumpAndSettle();
    expect(displayedKeys(), [
      for (final index in [5, 3, 4]) stickerKey(stickers[index]),
    ]);
    await tester.enterText(
      find.byKey(const ValueKey('preview-sticker-search')),
      'fixture',
    );
    await tester.pumpAndSettle();
    expect(displayedKeys(), [
      for (final index in [5, 3, 4]) stickerKey(stickers[index]),
    ]);
    await tester.enterText(
      find.byKey(const ValueKey('preview-sticker-search')),
      'fixture_0',
    );
    await tester.pumpAndSettle();
    expect(displayedKeys(), [stickerKey(stickers[3])]);
    expect(tester.takeException(), isNull);
  });

  testWidgets('category chips follow catalog tag order with Others last', (
    tester,
  ) async {
    await _open(
      tester,
      size: const Size(900, 600),
      stickers: [
        for (final tag in kPreviewImageFolders.reversed)
          PreviewSticker(
            assetPath: 'assets/images/$tag/fixture.webp',
            tag: tag,
            labelKey: 'fixtureSunflower',
          ),
      ],
    );
    final chips = tester
        .widgetList<ChoiceChip>(find.byType(ChoiceChip))
        .toList();
    expect((chips.first.label as Text).data, '全部');
    expect(chips.skip(1).map((chip) => chip.key), [
      for (final tag in kPreviewImageFolders)
        ValueKey('preview-sticker-tag-$tag'),
    ]);
    expect((chips.last.label as Text).data, '其他');
    expect(tester.takeException(), isNull);
  });

  testWidgets('category scrollbar is hidden when every tag fits', (
    tester,
  ) async {
    await _open(tester, size: const Size(900, 600), stickers: _stickers(2));
    final tags = find.byKey(const ValueKey('preview-sticker-tags-scroll'));
    expect(
      tester
          .widget<Scrollbar>(
            find.descendant(of: tags, matching: find.byType(Scrollbar)),
          )
          .thumbVisibility,
      isFalse,
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'cancel and sticker selection preserve the editing-session tag and offset',
    (tester) async {
      final session = PreviewStickerPickerSession();
      final stickers = [
        ..._stickers(80),
        for (var i = 0; i < 80; i++)
          PreviewSticker(
            assetPath: 'assets/images/zombies/fixture_$i.webp',
            tag: 'zombies',
            labelKey: 'fixtureZombie',
          ),
      ];
      await _open(
        tester,
        size: const Size(900, 600),
        stickers: stickers,
        session: session,
        priorityAssetPaths: [stickers[79].assetPath, stickers.last.assetPath],
      );
      await tester.tap(
        find.byKey(const ValueKey('preview-sticker-tag-zombies')),
      );
      await tester.pumpAndSettle();
      final scroll = find.byKey(const ValueKey('preview-sticker-scroll'));
      await tester.drag(scroll, const Offset(0, -380));
      await tester.pumpAndSettle();
      final offset = tester.widget<CustomScrollView>(scroll).controller!.offset;
      expect(offset, greaterThan(200));
      await tester.tap(find.text('取消'));
      await tester.pumpAndSettle();
      expect(session.selectedTag, 'zombies');
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();
      expect(
        tester.widget<CustomScrollView>(scroll).controller!.offset,
        closeTo(offset, 1),
      );
      expect(session.selectedTag, 'zombies');
      final sticker = find
          .byWidgetPredicate((widget) {
            final key = widget.key;
            return widget is InkWell &&
                key is ValueKey<String> &&
                key.value.startsWith('preview-sticker-assets/');
          })
          .hitTestable()
          .first;
      await tester.tap(sticker);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();
      expect(session.selectedTag, 'zombies');
      expect(
        tester.widget<CustomScrollView>(scroll).controller!.offset,
        closeTo(offset, 1),
      );
      tester.widget<CustomScrollView>(scroll).controller!.jumpTo(0);
      await tester.pumpAndSettle();
      expect(
        tester
            .widget<ChoiceChip>(
              find.byKey(const ValueKey('preview-sticker-tag-zombies')),
            )
            .selected,
        isTrue,
      );
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'reopening preserves horizontal categories and search but a new edit is fresh',
    (tester) async {
      final session = PreviewStickerPickerSession();
      final stickers = [
        for (final tag in kPreviewImageFolders)
          for (var i = 0; i < 20; i++)
            PreviewSticker(
              assetPath: 'assets/images/$tag/fixture_$i.webp',
              tag: tag,
              labelKey: 'fixtureSunflower',
            ),
      ];
      await _open(
        tester,
        size: const Size(520, 480),
        textScale: 1.5,
        stickers: stickers,
        session: session,
      );
      final search = find.byKey(const ValueKey('preview-sticker-search'));
      await tester.enterText(search, '向日葵');
      await tester.pumpAndSettle();
      final tags = find.byKey(const ValueKey('preview-sticker-tags-scroll'));
      await tester.drag(tags, const Offset(-600, 0));
      await tester.pumpAndSettle();
      final othersTag = find.byKey(
        const ValueKey('preview-sticker-tag-others'),
      );
      await tester.ensureVisible(othersTag);
      await tester.pumpAndSettle();
      final tagScrollView = find.descendant(
        of: tags,
        matching: find.byKey(const ValueKey('horizontalTagScrollerScrollView')),
      );
      final tagOffset = tester
          .widget<SingleChildScrollView>(tagScrollView)
          .controller!
          .offset;
      expect(tagOffset, greaterThan(0));
      expect(
        tester
            .widget<Scrollbar>(
              find.descendant(of: tags, matching: find.byType(Scrollbar)),
            )
            .thumbVisibility,
        isTrue,
      );
      await tester.tap(othersTag);
      await tester.pumpAndSettle();
      await tester.tap(find.text('取消'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();
      expect(tester.widget<TextField>(search).controller!.text, '向日葵');
      expect(
        tester
            .widget<ChoiceChip>(
              find.byKey(const ValueKey('preview-sticker-tag-others')),
            )
            .selected,
        isTrue,
      );
      expect(
        tester.widget<SingleChildScrollView>(tagScrollView).controller!.offset,
        closeTo(tagOffset, 1),
      );
      await tester.tap(find.text('取消'));
      await tester.pumpAndSettle();
      await _open(
        tester,
        size: const Size(900, 600),
        stickers: stickers,
        session: PreviewStickerPickerSession(),
      );
      expect(tester.widget<TextField>(search).controller!.text, isEmpty);
      expect(
        tester
            .widget<ChoiceChip>(
              find.byKey(const ValueKey('preview-sticker-tag-all')),
            )
            .selected,
        isTrue,
      );
      expect(
        tester
            .widget<CustomScrollView>(
              find.byKey(const ValueKey('preview-sticker-scroll')),
            )
            .controller!
            .offset,
        0,
      );
      expect(tester.takeException(), isNull);
    },
  );
}
