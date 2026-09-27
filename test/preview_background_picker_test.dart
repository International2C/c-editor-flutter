import 'dart:convert';
import 'dart:io';

import 'package:c_editor/bundled_plugins/preview_img_cplugin/lib/src/preview/preview_pickers.dart';
import 'package:c_editor/bundled_plugins/preview_img_cplugin/lib/src/preview/preview_picker_session.dart';
import 'package:c_editor/bundled_plugins/preview_img_cplugin/lib/src/preview/stage_banner_resolver.dart';
import 'package:c_editor/data/repository/custom_stage_preset_repository.dart';
import 'package:c_editor/data/repository/stage_repository.dart';
import 'package:c_editor/l10n/resource_names.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'helpers/preview_scrollbar_gesture.dart';

Map<String, dynamic> _pluginLocale(String locale) =>
    jsonDecode(
          File(
            '${StageBannerResolver.flutterAssetsRoot}/l10n/$locale.arb',
          ).readAsStringSync(),
        )
        as Map<String, dynamic>;

void main() {
  test('keeps map order, then main menu immediately above custom images', () {
    final banners = StageBannerResolver.forTest(
      stages: const {
        'EgyptStage': 'Egypt',
        'RiftStage': 'Rift',
        'CardGameStage': 'CardGame',
        'DaveCupStage': 'DaveCup',
        'ModernStage': 'Modern',
        'TutorialStage': 'Modern',
        'LostVolcanoCustom': 'VolcanoLostCity',
        'FallbackStage': 'Unknown',
      },
    );
    final entries = previewBannerPickerEntries(
      banners: banners,
      stageAliases: const [
        'ModernStage',
        'TutorialStage',
        'EgyptStage',
        'RiftStage',
        'CardGameStage',
        'DaveCupStage',
        'FallbackStage',
      ],
    );

    expect(entries, [
      'Modern',
      'Egypt',
      'Rift',
      'CardGame',
      'DaveCup',
      'VolcanoLostCity',
      'Unknown',
      '__custom__',
    ]);
    expect(entries.where((stem) => stem == 'Unknown'), hasLength(1));
  });

  test('empty catalog still offers main menu before custom images', () {
    expect(
      previewBannerPickerEntries(
        banners: StageBannerResolver.forTest(),
        stageAliases: const [],
      ),
      ['Unknown', '__custom__'],
    );
  });

  test('localizes the menu name without changing the Unknown asset stem', () {
    const names = {
      'zh': '时空主界面',
      'en': 'Spacetime Main Menu',
      'ru': 'Главное меню пространства-времени',
    };
    for (final entry in names.entries) {
      expect(_pluginLocale(entry.key)['previewGenUnknownBanner'], entry.value);
    }

    final manifest =
        jsonDecode(
              File(
                '${StageBannerResolver.flutterAssetsRoot}/stage_banners.json',
              ).readAsStringSync(),
            )
            as Map<String, dynamic>;
    expect(manifest['default'], 'Unknown');
    final banners = StageBannerResolver.forTest();
    expect(banners.resolveStem('MissingStage'), 'Unknown');
    expect(
      banners.assetPathForStem('Unknown'),
      '${StageBannerResolver.flutterAssetsRoot}/banners/Unknown.png',
    );
    expect(File(banners.assetPathForStem('Unknown')).existsSync(), isTrue);
  });

  testWidgets('picker displays localized name, Unknown code, and custom last', (
    tester,
  ) async {
    await tester.runAsync(() async {
      await Future.wait([
        StageRepository.init(),
        CustomStagePresetRepository.init(),
        ResourceNames.ensureLoaded(),
      ]);
    });
    final en = _pluginLocale('en');
    String? selected;
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => Scaffold(
            body: TextButton(
              key: const ValueKey('open-background-picker'),
              onPressed: () async {
                selected = await showPreviewBannerPicker(
                  context: context,
                  banners: StageBannerResolver.forTest(),
                  currentStem: 'Unknown',
                  t: (key, [fallback]) => en[key] as String? ?? fallback ?? key,
                );
              },
              child: const Text('Open'),
            ),
          ),
        ),
      ),
    );

    final opener = find.byKey(const ValueKey('open-background-picker'));
    await tester.tap(opener);
    await tester.pumpAndSettle();
    final menu = find.byKey(const ValueKey('preview-banner-Unknown'));
    final custom = find.byKey(const ValueKey('preview-banner-custom'));
    expect(find.text('Spacetime Main Menu'), findsOneWidget);
    expect(find.text('Unknown'), findsOneWidget);
    expect(find.text('Custom background image'), findsOneWidget);
    expect(tester.getTopLeft(menu).dy, lessThan(tester.getTopLeft(custom).dy));

    await tester.tap(menu);
    await tester.pumpAndSettle();
    expect(selected, 'Unknown');
    await tester.tap(opener);
    await tester.pumpAndSettle();
    await tester.tap(custom);
    await tester.pumpAndSettle();
    expect(selected, '__custom__');
  });

  testWidgets(
    'landscape background picker remembers its position after selection',
    (tester) async {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = const Size(900, 300);
      addTearDown(tester.view.reset);
      await tester.runAsync(() async {
        await Future.wait([
          StageRepository.init(),
          CustomStagePresetRepository.init(),
          ResourceNames.ensureLoaded(),
        ]);
      });
      String? selected;
      final session = PreviewPickerSession();
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(platform: TargetPlatform.android),
          builder: (context, child) => MediaQuery(
            data: MediaQuery.of(
              context,
            ).copyWith(textScaler: TextScaler.linear(1.5)),
            child: child!,
          ),
          home: Builder(
            builder: (context) => Scaffold(
              body: TextButton(
                onPressed: () async {
                  selected = await showPreviewBannerPicker(
                    context: context,
                    session: session,
                    banners: StageBannerResolver.forTest(
                      stages: {
                        for (var i = 0; i < 20; i++)
                          'TestStage$i': 'TestBackground$i',
                      },
                    ),
                    t: (key, [fallback]) => fallback ?? key,
                  );
                },
                child: const Text('Open'),
              ),
            ),
          ),
        ),
      );
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();
      final custom = find.byKey(const ValueKey('preview-banner-custom'));
      final controller = tester
          .widget<ListView>(
            find.byKey(const ValueKey('previewBannerPickerScroll')),
          )
          .controller!;
      await dragPreviewVerticalScrollbar(
        tester,
        const ValueKey('previewBannerPickerScrollbar'),
        distance: 80,
      );
      expect(controller.offset, greaterThan(100));
      expect(selected, isNull);
      final scrollable = find
          .descendant(
            of: find.byType(AlertDialog),
            matching: find.byType(Scrollable),
          )
          .first;
      await tester.scrollUntilVisible(custom, 140, scrollable: scrollable);
      await tester.pumpAndSettle();
      expect(custom.hitTestable(), findsOneWidget);
      final savedOffset = controller.offset;
      await tester.tap(custom);
      await tester.pumpAndSettle();
      expect(selected, '__custom__');
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();
      final restoredController = tester
          .widget<ListView>(
            find.byKey(const ValueKey('previewBannerPickerScroll')),
          )
          .controller!;
      expect(restoredController.offset, closeTo(savedOffset, 1));
      expect(custom.hitTestable(), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );
}
