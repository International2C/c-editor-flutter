import 'dart:math' as math;

import 'package:c_editor/data/level_parser.dart';
import 'package:c_editor/data/pvz_models.dart';
import 'package:c_editor/data/repository/grid_item_repository.dart';
import 'package:c_editor/data/repository/plant_repository.dart';
import 'package:c_editor/data/repository/reference_repository.dart';
import 'package:c_editor/data/repository/stage_repository.dart';
import 'package:c_editor/data/repository/zomboss_battle_repository.dart';
import 'package:c_editor/data/repository/zomboss_mech_repository.dart';
import 'package:c_editor/data/repository/zombie_repository.dart';
import 'package:c_editor/l10n/app_localizations.dart';
import 'package:c_editor/plugins/plugin_host_hooks.dart';
import 'package:c_editor/screens/level_overview/level_overview_dialog.dart';
import 'package:c_editor/widgets/app_ui_scaler.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _fileName = 'Preview layout mobile level overview.json';
const _name =
    'A complete level name with several words that must stay readable';
const _description =
    'This complete level description includes the final sentence, which must '
    'remain available by scrolling instead of being cut off after two lines.';

PvzLevelFile _level() => PvzLevelFile(
  objects: [
    PvzObject(
      aliases: const ['LevelDefinition'],
      objClass: 'LevelDefinition',
      objData: LevelDefinitionData(
        name: _name,
        description: _description,
        stageModule: 'RTID(MyLawn@CurrentLevel)',
      ).toJson(),
    ),
  ],
);

/// Matches the app's root scaling ([AppUiScaler]): smaller logical allocation,
/// scaled system insets, then Transform.scale (never FittedBox).
Widget _app({
  required Size physicalSize,
  required double uiScale,
  required TargetPlatform platform,
  double textScale = 1,
  double? localWidth,
}) {
  final level = _level();
  return MediaQuery(
    data: MediaQueryData(
      size: physicalSize,
      textScaler: TextScaler.linear(textScale),
    ),
    child: MaterialApp(
      locale: const Locale('en'),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      theme: ThemeData(platform: platform),
      builder: (context, child) {
        final scale = uiScale * (physicalSize.shortestSide < 600 ? 0.85 : 1);
        return AppUiScaler(scale: scale, wrapMessenger: false, child: child!);
      },
      home: Scaffold(
        body: Builder(
          builder: (context) => TextButton(
            onPressed: () => showDialog<void>(
              context: context,
              builder: (dialogContext) {
                final dialog = LevelOverviewDialog(
                  levelFile: level,
                  parsed: LevelParser.parseLevel(level),
                  fileName: _fileName,
                  onClose: () => Navigator.of(dialogContext).pop(),
                );
                return localWidth == null
                    ? dialog
                    : Align(
                        child: SizedBox(width: localWidth, child: dialog),
                      );
              },
            ),
            child: const Text('Open overview'),
          ),
        ),
      ),
    ),
  );
}

RenderParagraph _paragraph(WidgetTester tester, Finder text) =>
    tester.renderObject<RenderParagraph>(
      find.descendant(of: text, matching: find.byType(RichText)).first,
    );

void _expectFullWrapping(
  WidgetTester tester,
  Finder text,
  Rect dialogRect, {
  required int minimumLines,
}) {
  expect(text, findsOneWidget);
  final paragraph = _paragraph(tester, text);
  final value = paragraph.text.toPlainText();
  expect(paragraph.didExceedMaxLines, isFalse, reason: value);
  final boxes = paragraph.getBoxesForSelection(
    TextSelection(baseOffset: 0, extentOffset: value.length),
  );
  final lineTops = boxes.map((box) => box.top).toSet();
  expect(lineTops.length, greaterThanOrEqualTo(minimumLines), reason: value);
  // Check visible text rather than trailing spaces at a wrap boundary: a
  // clipped, single-line paragraph can otherwise have a bounded widget rect.
  for (final word in RegExp(r'\S+').allMatches(value)) {
    final wordBoxes = paragraph.getBoxesForSelection(
      TextSelection(baseOffset: word.start, extentOffset: word.end),
    );
    for (final box in wordBoxes) {
      expect(box.left, greaterThanOrEqualTo(-0.5), reason: word.group(0));
      expect(
        box.right,
        lessThanOrEqualTo(paragraph.size.width + 0.5),
        reason: word.group(0),
      );
    }
  }
  final lastCharacter = paragraph.getBoxesForSelection(
    TextSelection(baseOffset: value.length - 1, extentOffset: value.length),
  );
  expect(
    lastCharacter,
    isNotEmpty,
    reason: 'The final character must be laid out',
  );
  expect(
    lastCharacter.last.bottom,
    lessThanOrEqualTo(paragraph.size.height + 0.1),
    reason: 'The final line must fit in the paragraph',
  );
  final rect = tester.getRect(text);
  expect(rect.left, greaterThanOrEqualTo(dialogRect.left - 0.1));
  expect(rect.right, lessThanOrEqualTo(dialogRect.right + 0.1));
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(() async {
    SharedPreferences.setMockInitialValues({});
    await Future.wait([
      ReferenceRepository.init(),
      PlantRepository().init(),
      ZombieRepository().init(),
      GridItemRepository.init(),
      StageRepository.init(),
      ZombossMechRepository.ensureLoaded(),
      ZombossBattleRepository.init(),
    ]);
  });

  for (final configuration in [
    (
      size: const Size(320, 720),
      uiScale: 1.8,
      textScale: 1.0,
      localWidth: null,
    ),
    (
      size: const Size(320, 720),
      uiScale: 2.2,
      textScale: 1.0,
      localWidth: null,
    ),
    (
      size: const Size(390, 844),
      uiScale: 2.0,
      textScale: 1.0,
      localWidth: null,
    ),
    (
      size: const Size(390, 844),
      uiScale: 1.0,
      textScale: 1.8,
      localWidth: null,
    ),
    (
      size: const Size(1200, 900),
      uiScale: 1.0,
      textScale: 1.0,
      localWidth: 240.0,
    ),
  ]) {
    testWidgets(
      'overview text remains complete in narrow allocation $configuration',
      (tester) async {
        final size = configuration.size;
        tester.view.devicePixelRatio = 1;
        tester.view.physicalSize = size;
        if (size.width < 600) {
          tester.view.padding = const FakeViewPadding(top: 47, bottom: 34);
          tester.view.viewPadding = const FakeViewPadding(top: 47, bottom: 34);
        }
        addTearDown(tester.view.reset);
        final previousOpener = PluginHostHooks.openPreviewImageGenerator;
        addTearDown(
          () => PluginHostHooks.openPreviewImageGenerator = previousOpener,
        );
        var generated = false;
        PluginHostHooks.openPreviewImageGenerator =
            (
              context, {
              required levelFile,
              required parsed,
              required fileName,
            }) async {
              generated = true;
            };
        await tester.pumpWidget(
          _app(
            physicalSize: size,
            uiScale: configuration.uiScale,
            textScale: configuration.textScale,
            localWidth: configuration.localWidth,
            platform: size.width < 600
                ? TargetPlatform.iOS
                : TargetPlatform.windows,
          ),
        );
        await tester.pumpAndSettle();
        await tester.tap(find.text('Open overview'));
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
        final l10n = lookupAppLocalizations(const Locale('en'));
        final title = find.text('${l10n.levelOverview}: $_fileName');
        final generate = find.text(l10n.previewGenerateImagePreview);
        final dialogContent = find
            .byWidgetPredicate(
              (widget) =>
                  widget is Material && widget.type == MaterialType.card,
            )
            .first;
        final dialogRect = tester.getRect(dialogContent);
        expect(dialogRect.left, greaterThanOrEqualTo(0));
        expect(dialogRect.right, lessThanOrEqualTo(size.width));
        final titleRect = tester.getRect(title);
        final generateRect = tester.getRect(generate);
        expect(titleRect.left, greaterThanOrEqualTo(dialogRect.left));
        expect(titleRect.right, lessThanOrEqualTo(dialogRect.right));
        expect(generateRect.left, greaterThanOrEqualTo(dialogRect.left));
        expect(generateRect.right, lessThanOrEqualTo(dialogRect.right));
        expect(
          _paragraph(tester, generate).size.width,
          greaterThanOrEqualTo(60),
          reason:
              'The action label must have space for several letters per line',
        );
        expect(generateRect.top, greaterThanOrEqualTo(titleRect.bottom));
        _expectFullWrapping(
          tester,
          find.text('${l10n.name}: $_name'),
          dialogRect,
          minimumLines: 3,
        );
        _expectFullWrapping(
          tester,
          find.text('${l10n.description}: $_description'),
          dialogRect,
          minimumLines: 3,
        );
        final lawn = find.byWidgetPredicate(
          (widget) =>
              widget is Text &&
              (widget.data?.startsWith('${l10n.overviewLawn}: ') ?? false),
        );
        // This short label fits on one line in wider logical allocations.
        // Its glyph bounds and final character must still remain complete.
        _expectFullWrapping(tester, lawn, dialogRect, minimumLines: 1);
        final scroll = find.byKey(const ValueKey('levelOverviewScroll'));
        final scrollable = find
            .descendant(of: scroll, matching: find.byType(Scrollable))
            .first;
        final controller = tester
            .widget<Scrollbar>(
              find.byKey(const ValueKey('levelOverviewScrollbar')),
            )
            .controller!;
        expect(controller.position.maxScrollExtent, greaterThan(0));
        // A tap after revealing the action uses the actual route and scaled hit
        // geometry, so header and button layout must be usable as well as bounded.
        await tester.scrollUntilVisible(
          generate,
          math.max(30.0, size.height * 0.1),
          scrollable: scrollable,
        );
        await tester.tap(generate);
        await tester.pumpAndSettle();
        expect(generated, isTrue);
        await tester.tap(find.text(l10n.close));
        await tester.pumpAndSettle();
        expect(find.byType(LevelOverviewDialog), findsNothing);
        expect(tester.takeException(), isNull);
      },
    );
  }
}
