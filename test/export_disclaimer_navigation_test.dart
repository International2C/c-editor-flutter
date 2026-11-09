import 'dart:typed_data';

import 'package:c_editor/data/repository/world_repository.dart';
import 'package:c_editor/l10n/app_localizations.dart';
import 'package:c_editor/screens/export/export_screen.dart';
import 'package:c_editor/screens/export/export_engine.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _FakeExportEngine implements ExportEngine {
  @override
  Future<bool> hasEligibleArchive(String rootPath) async => true;

  @override
  Future<List<ExportEntry>> listDirectory(
    String path, {
    required bool archiveStep,
  }) async => archiveStep
      ? [
          const ExportEntry(
            name: 'dynamic.rsb.smf',
            path: 'library/dynamic.rsb.smf',
            isDirectory: false,
          ),
        ]
      : [
          const ExportEntry(
            name: 'example.txt',
            path: 'library/example.txt',
            isDirectory: false,
          ),
        ];

  @override
  String parentDirectory(String path) => 'library';

  @override
  Future<void> performExport({
    required String archivePath,
    required Map<String, Uint8List> rtonLevels,
    required void Function(double progress, ExportPhase phase) onProgress,
  }) => throw UnimplementedError();

  @override
  void cancelExport() {}

  @override
  void resetExportState() {}

  @override
  bool get isCancelledByUser => false;
}

void main() {
  test('testing package progress has a dedicated localized title', () {
    final en = lookupAppLocalizations(const Locale('en'));
    final zh = lookupAppLocalizations(const Locale('zh'));

    expect(en.exportProgressTitle, 'Exporting files…');
    expect(en.exportPackageProgressTitle, 'Exporting data package…');
    expect(zh.exportProgressTitle, '正在导出关卡…');
    expect(zh.exportPackageProgressTitle, '正在导出数据包…');
  });

  test('Moon Base is available for twelve level slots', () async {
    TestWidgetsFlutterBinding.ensureInitialized();
    await WorldRepository.init();
    final moon = WorldRepository.findByCodename('moon');
    expect(moon, isNotNull);
    expect(moon!.levelCount, 12);
    expect(moon.iconAsset, 'Stage_Moon.webp');
  });

  Future<void> pumpAsyncFrames(WidgetTester tester) async {
    for (var i = 0; i < 12; i++) {
      await tester.pump(const Duration(milliseconds: 100));
    }
  }

  testWidgets(
    'back exits export after choosing not to show the disclaimer again',
    (tester) async {
      SharedPreferences.setMockInitialValues({'folder_path': 'library'});
      await tester.binding.setSurfaceSize(const Size(1000, 1000));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(
        MaterialApp(
          locale: const Locale('en'),
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          home: Builder(
            builder: (context) => Scaffold(
              body: TextButton(
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => ExportScreen(engine: _FakeExportEngine()),
                  ),
                ),
                child: const Text('Open export'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open export'));
      await pumpAsyncFrames(tester);
      expect(find.text('Risk Warning & Disclaimer'), findsOneWidget);
      expect(
        find.byKey(const ValueKey('exportDisclaimerInfoButton')),
        findsNothing,
      );

      await tester.tap(find.text('Do not show by default'));
      await tester.pump();
      expect(tester.widget<Checkbox>(find.byType(Checkbox)).value, isTrue);
      await tester.tap(find.text('Proceed'));
      await tester.runAsync(
        () => Future<void>.delayed(const Duration(seconds: 1)),
      );
      await pumpAsyncFrames(tester);
      final prefsAfterProceed = await SharedPreferences.getInstance();
      expect(prefsAfterProceed.getBool('export_disclaimer_skip'), isTrue);
      expect(find.byType(CircularProgressIndicator), findsNothing);
      expect(find.text('Risk Warning & Disclaimer'), findsNothing);

      await tester.tap(
        find.byKey(const ValueKey('exportDisclaimerInfoButton')),
      );
      await tester.pumpAndSettle();
      expect(
        find.byKey(const ValueKey('exportDisclaimerDialog')),
        findsOneWidget,
      );
      expect(find.text('Risk Warning & Disclaimer'), findsOneWidget);
      expect(find.textContaining('at their own risk'), findsOneWidget);
      final disclaimerTitle = tester.widget<Text>(
        find.byKey(const ValueKey('exportDisclaimerDialogTitle')),
      );
      expect(disclaimerTitle.style?.fontWeight, FontWeight.bold);
      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.arrow_back));
      await pumpAsyncFrames(tester);
      expect(find.text('Open export'), findsOneWidget);

      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getBool('export_disclaimer_skip'), isTrue);
    },
  );

  testWidgets('level distribution stacks controls on narrow screens', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({
      'folder_path': 'library',
      'export_disclaimer_skip': true,
    });
    await tester.binding.setSurfaceSize(const Size(360, 900));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('en'),
        supportedLocales: AppLocalizations.supportedLocales,
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        home: ExportScreen(engine: _FakeExportEngine()),
      ),
    );
    await pumpAsyncFrames(tester);

    final initialProceedButton = find.byKey(
      const ValueKey('exportProceedButton'),
    );
    expect(initialProceedButton, findsOneWidget);
    expect(
      tester.getTopRight(initialProceedButton).dx,
      lessThanOrEqualTo(
        tester.view.physicalSize.width / tester.view.devicePixelRatio,
      ),
    );
    expect(tester.takeException(), isNull);

    await tester.tap(find.text('dynamic'));
    await tester.pump();
    await tester.tap(find.text('Proceed'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Proceed Without Backup'));
    await pumpAsyncFrames(tester);

    await tester.tap(find.text('example.txt'));
    await tester.pump();
    await tester.tap(find.text('Proceed'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Begin'));
    await tester.pumpAndSettle();

    expect(
      find.text(
        lookupAppLocalizations(
          const Locale('en'),
        ).exportDifficultyReplacementNotice,
      ),
      findsOneWidget,
    );
    final worldField = find.byKey(const ValueKey('exportWorldField'));
    final worldIcon = find.byKey(const ValueKey('exportWorldIcon'));
    final levelField = find.byKey(const ValueKey('exportLevelNumberField'));
    final levelStepper = find.byKey(const ValueKey('exportLevelStepper'));
    final worldLabel = find.text('World');
    final levelLabel = find.text('Level Number');
    final distributionFileName = find.text('example.txt');
    expect(worldField, findsOneWidget);
    expect(worldIcon, findsOneWidget);
    expect(levelField, findsOneWidget);
    expect(levelStepper, findsOneWidget);
    expect(worldLabel, findsOneWidget);
    expect(levelLabel, findsOneWidget);
    expect(tester.widget<Text>(distributionFileName).maxLines, 2);
    expect(
      tester.getCenter(worldIcon).dx,
      closeTo(tester.getCenter(worldField).dx, 1),
    );
    expect(
      tester.getBottomLeft(worldLabel).dy,
      lessThan(tester.getTopLeft(worldField).dy),
    );
    expect(
      tester.getBottomLeft(levelLabel).dy,
      lessThan(tester.getTopLeft(levelField).dy),
    );
    expect(
      tester.getBottomLeft(worldField).dy,
      lessThan(tester.getTopLeft(levelField).dy),
    );
    expect(tester.getTopRight(worldField).dx, lessThanOrEqualTo(360));
    expect(tester.getTopRight(levelField).dx, lessThanOrEqualTo(360));
    expect(
      tester.getTopLeft(levelStepper).dy,
      tester.getTopLeft(levelField).dy,
    );
    expect(
      tester.getBottomLeft(levelStepper).dy,
      tester.getBottomLeft(levelField).dy,
    );
    expect(tester.takeException(), isNull);

    await tester.tap(find.text('Finish'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Proceed').last);
    await tester.pumpAndSettle();

    final finalCheckCard = find.byKey(
      const ValueKey('exportFinalCheckLevelCard-0'),
    );
    expect(finalCheckCard, findsOneWidget);
    final sourceName = find.descendant(
      of: finalCheckCard,
      matching: find.text('example.txt'),
    );
    expect(sourceName, findsOneWidget);
    expect(tester.widget<Text>(sourceName).maxLines, 2);
    expect(tester.getSize(finalCheckCard).width, greaterThan(100));
    expect(tester.getTopRight(finalCheckCard).dx, lessThanOrEqualTo(360));
    expect(tester.takeException(), isNull);
  });
}
