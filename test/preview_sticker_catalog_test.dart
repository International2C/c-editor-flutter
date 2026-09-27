import 'dart:convert';
import 'dart:io';

import 'package:c_editor/bundled_plugins/preview_img_cplugin/lib/src/preview/preview_sticker_catalog.dart';
import 'package:c_editor/data/dino_type_catalog.dart';
import 'package:c_editor/data/repository/fish_type_repository.dart';
import 'package:c_editor/data/repository/tool_repository.dart';
import 'package:c_editor/l10n/app_localizations.dart';
import 'package:c_editor/l10n/resource_names.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _localeRoot = 'lib/bundled_plugins/preview_img_cplugin/assets/l10n';

Map<String, dynamic> _messages(String locale) =>
    jsonDecode(File('$_localeRoot/$locale.arb').readAsStringSync())
        as Map<String, dynamic>;

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late List<PreviewSticker> stickers;
  late Set<String> images;
  setUpAll(() async {
    SharedPreferences.setMockInitialValues({});
    rootBundle.clear();
    stickers = await loadPreviewStickerCatalog();
    images = (await AssetManifest.loadFromAssetBundle(
      rootBundle,
    )).listAssets().where((path) => path.startsWith('assets/images/')).toSet();
  });

  test(
    'all combines tag order and preserves original per-tag catalog order',
    () {
      final actual = orderPreviewStickers(
        assetPaths: const [
          'assets/images/others/last.webp',
          'assets/images/zombies/a.webp',
          'assets/images/zombies/z.webp',
          'assets/images/plants/b.webp',
        ],
        orderedEntries: const [
          PreviewSticker(
            assetPath: 'assets/images/zombies/z.webp',
            tag: 'zombies',
          ),
          PreviewSticker(
            assetPath: 'assets/images/others/last.webp',
            tag: 'others',
          ),
          PreviewSticker(
            assetPath: 'assets/images/zombies/a.webp',
            tag: 'zombies',
          ),
          PreviewSticker(
            assetPath: 'assets/images/plants/b.webp',
            tag: 'plants',
          ),
        ],
      );
      expect(actual.map((entry) => entry.assetPath), [
        'assets/images/plants/b.webp',
        'assets/images/zombies/z.webp',
        'assets/images/zombies/a.webp',
        'assets/images/others/last.webp',
      ]);
      expect(kPreviewStickerTags.last, 'others');
      expect(kPreviewStickerTags.take(7), [
        'plants',
        'zombies',
        'griditems',
        'creatures',
        'tool_packets',
        'components',
        'round_icons',
      ]);
    },
  );

  test(
    'uses GIFs before static alternatives and deduplicates shared icons',
    () {
      final actual = orderPreviewStickers(
        assetPaths: const [
          'assets/images/zombies/Animated.png',
          'assets/images/zombies/Animated.webp',
          'assets/images/zombies/Animated.gif',
        ],
        orderedEntries: const [
          PreviewSticker(
            assetPath: 'assets/images/zombies/animated.webp',
            tag: 'zombies',
            resourceNameKey: 'first_name',
          ),
          PreviewSticker(
            assetPath: 'assets/images/zombies/Animated.png',
            tag: 'zombies',
            resourceNameKey: 'second_name',
          ),
        ],
      );
      expect(actual, hasLength(1));
      expect(actual.single.assetPath, 'assets/images/zombies/Animated.gif');
      expect(actual.single.resourceNameKey, 'first_name');
    },
  );

  test('lunar vein stickers have variant names and keep picker order', () {
    const types = [
      'lunar_mine_vein',
      'lunar_mine_vein_hardened',
      'lunar_mine_vein_fragile',
      'lunar_mine_vein_fragile_plantfood',
      'lunar_mine_vein_radiation',
    ];
    final variants = stickers
        .where(
          (entry) => types.any(
            (type) => entry.assetPath == 'assets/images/griditems/$type.webp',
          ),
        )
        .toList();
    expect(
      variants.map((entry) => entry.resourceNameKey),
      types.map((type) => 'griditem_$type'),
    );
    for (final entry in variants) {
      expect(entry.tag, 'griditems');
      for (final locale in ['zh', 'en', 'ru']) {
        expect(
          ResourceNames.lookupWithLocale(locale, entry.resourceNameKey!),
          isNot(entry.resourceNameKey),
        );
      }
    }
  });

  test('zombie stickers follow Zombies, ZombossMechs, then Zombosses JSON', () {
    final expected = <String>[];
    final seen = <String>{};
    for (final catalog in ['Zombies', 'ZombossMechs', 'Zombosses']) {
      final entries =
          jsonDecode(File('assets/resources/$catalog.json').readAsStringSync())
              as List;
      for (final entry in entries.cast<Map>()) {
        final icon = entry['icon'] as String?;
        if (icon == null) continue;
        final path = 'assets/images/zombies/$icon';
        if (images.contains(path) && seen.add(path)) expected.add(path);
      }
    }
    final actual = stickers
        .where((entry) => entry.tag == 'zombies')
        .map((entry) => entry.assetPath)
        .toList();
    expect(actual.take(expected.length), expected);
    expect(actual.toSet(), hasLength(actual.length));
  });

  test('plant and grid item stickers retain their editor JSON order', () {
    for (final catalog in {
      'Plants': 'plants',
      'GridItems': 'griditems',
    }.entries) {
      final expected = <String>[];
      final seen = <String>{};
      final entries =
          jsonDecode(
                File('assets/resources/${catalog.key}.json').readAsStringSync(),
              )
              as List;
      for (final entry in entries.cast<Map>()) {
        final icon = entry['icon'] as String?;
        if (icon == null) continue;
        final path = 'assets/images/${catalog.value}/$icon';
        if (images.contains(path) && seen.add(path)) expected.add(path);
      }
      expect(
        stickers
            .where((entry) => entry.tag == catalog.value)
            .take(expected.length)
            .map((entry) => entry.assetPath),
        expected,
      );
    }
    final tunnelPickerSource = File(
      'lib/screens/editor/modules/tunnel_defend_module_screen.dart',
    ).readAsStringSync();
    final moduleImages = RegExp(
      r"static const _availableAssets = \[([\s\S]*?)\];",
    ).firstMatch(tunnelPickerSource)!.group(1)!;
    final expectedTunnels = RegExp(r"'(IMAGE_UI_MAUSOLEUM_TUNNEL_[A-Z0-9_]+)'")
        .allMatches(moduleImages)
        .map((match) => 'assets/images/tunnels/${match.group(1)}.webp');
    expect(
      stickers
          .where(
            (sticker) =>
                sticker.assetPath.contains('/IMAGE_UI_MAUSOLEUM_TUNNEL_'),
          )
          .map((sticker) => sticker.assetPath),
      expectedTunnels,
    );
  });

  test('creatures and tool packets follow their dedicated editor catalogs', () {
    String stem(String path) => path.replaceFirst(RegExp(r'\.[^/.]+$'), '');
    final creatures = stickers.where((sticker) => sticker.tag == 'creatures');
    expect(creatures.map((sticker) => stem(sticker.assetPath)), [
      for (final id in kDinoSpawnTypeIds) stem(dinoSpawnImageAsset(id)),
      for (final fish in FishTypeRepository().allFishes)
        if (FishInfo.hasEditorIcon(fish.alias)) stem(fish.iconAssetPath),
    ]);
    expect(
      creatures.first.resourceNameKey,
      'dinoType_${kDinoSpawnTypeIds.first}',
    );
    final tools = stickers.where((sticker) => sticker.tag == 'tool_packets');
    expect(tools.map((sticker) => sticker.resourceNameKey), [
      for (final tool in ToolRepository.toolCards)
        if (tool.icon != null) tool.id,
    ]);
    expect(tools.map((sticker) => stem(sticker.assetPath)), [
      for (final tool in ToolRepository.toolCards)
        if (tool.icon != null) stem('assets/images/tools/${tool.icon}'),
    ]);
    expect(
      stickers
          .where((sticker) => sticker.tag == 'griditems')
          .any(
            (sticker) =>
                sticker.assetPath.startsWith('assets/images/tools/') ||
                sticker.assetPath.startsWith('assets/images/dinos/') ||
                sticker.assetPath.startsWith('assets/images/fishes/'),
          ),
      isFalse,
    );
  });

  test('lawn components keep their module labels and internal ordering', () {
    final components = stickers
        .where((sticker) => sticker.tag == 'components')
        .toList();
    expect(components.take(11).map((sticker) => sticker.labelKey), [
      'previewStickerNameRails',
      'previewStickerNameRailcart',
      'previewStickerNamePiratePlanks',
      'previewStickerNameKongfuTracks',
      'previewStickerNameKongfuCartLeft',
      'previewStickerNameKongfuCartMiddle',
      'previewStickerNameKongfuCartRight',
      'previewStickerNameGulliverLeft',
      'previewStickerNameGulliverRight',
      'previewStickerNameExpeditionRoad',
      'previewStickerNameExpeditionRoadBlocked',
    ]);
    expect(
      stickers
          .where(
            (sticker) => sticker.assetPath.startsWith('assets/images/tunnels/'),
          )
          .every((sticker) => sticker.tag == 'components'),
      isTrue,
    );
    expect(
      components
          .where((sticker) => sticker.assetPath.contains('MAUSOLEUM'))
          .every((sticker) => sticker.searchTerms.isNotEmpty),
      isTrue,
    );
    expect(
      stickers
          .firstWhere(
            (sticker) =>
                sticker.searchTerms.contains('cosmoss') &&
                sticker.assetPath.startsWith('assets/images/griditems/'),
          )
          .tag,
      'griditems',
    );
  });

  test(
    'the complete catalog is grouped, unique and names every packaged image',
    () {
      expect(stickers, isNotEmpty);
      final expectedImageStems = images
          .where(
            (path) => RegExp(
              r'\.(gif|webp|png|jpe?g)$',
              caseSensitive: false,
            ).hasMatch(path),
          )
          .map(
            (path) => path.replaceFirst(RegExp(r'\.[^/.]+$'), '').toLowerCase(),
          )
          .toSet();
      expect(stickers, hasLength(expectedImageStems.length));
      expect(
        stickers.map((entry) => entry.assetPath).toSet(),
        hasLength(stickers.length),
      );
      var previousRank = -1;
      for (final sticker in stickers) {
        final rank = kPreviewStickerTags.indexOf(sticker.tag);
        expect(
          rank,
          greaterThanOrEqualTo(previousRank),
          reason: sticker.assetPath,
        );
        previousRank = rank;
        final resourceIsNamed =
            sticker.resourceNameKey != null &&
            ['en', 'zh'].every(
              (locale) =>
                  ResourceNames.lookupWithLocale(
                    locale,
                    sticker.resourceNameKey!,
                  ) !=
                  sticker.resourceNameKey,
            );
        expect(
          resourceIsNamed ||
              sticker.labelKey != null ||
              sticker.nameResolver != null,
          isTrue,
          reason: 'Missing a real localized name for ${sticker.assetPath}',
        );
        if (sticker.labelKey != null) {
          for (final locale in ['en', 'zh']) {
            expect(
              _messages(locale)[sticker.labelKey],
              isNotEmpty,
              reason: sticker.assetPath,
            );
          }
        }
      }
    },
  );

  for (final locale in ['en', 'zh']) {
    testWidgets('every $locale hint is localized, never a raw filename', (
      tester,
    ) async {
      final messages = _messages(locale);
      late BuildContext appContext;
      await tester.pumpWidget(
        MaterialApp(
          locale: Locale(locale),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Builder(
            builder: (context) {
              appContext = context;
              return const SizedBox();
            },
          ),
        ),
      );
      await tester.pumpAndSettle();
      String translate(String key, [String? fallback]) =>
          messages[key] as String? ?? fallback ?? key;
      for (final sticker in stickers) {
        final name = sticker.localizedName(appContext, translate);
        expect(name, isNotEmpty, reason: sticker.assetPath);
        expect(
          name,
          isNot(messages['previewStickerUnnamed']),
          reason: sticker.assetPath,
        );
        expect(
          name,
          isNot(sticker.assetPath.split('/').last),
          reason: sticker.assetPath,
        );
        expect(name, isNot(sticker.labelKey), reason: sticker.assetPath);
        expect(name, isNot(sticker.resourceNameKey), reason: sticker.assetPath);
      }
      expect(
        stickers
            .firstWhere((entry) => entry.assetPath.endsWith('/sun_large.webp'))
            .localizedName(appContext, translate),
        locale == 'zh' ? '阳光' : 'Sun',
      );
      final unknown = stickers.firstWhere(
        (entry) => entry.assetPath == 'assets/images/others/unknown.webp',
      );
      expect(unknown.labelKey, 'previewStickerNameUnknown');
      expect(
        unknown.localizedName(appContext, translate),
        locale == 'zh' ? '未知' : 'Unknown',
      );
      expect(
        messages['previewGenUnknownBanner'],
        locale == 'zh' ? '时空主界面' : 'Spacetime Main Menu',
      );
    });
  }
}
