import 'dart:convert';
import 'dart:io';

import 'package:c_editor/bundled_plugins/preview_img_cplugin/lib/src/preview/preview_canvas.dart';
import 'package:c_editor/bundled_plugins/preview_img_cplugin/lib/src/preview/preview_document.dart';
import 'package:c_editor/bundled_plugins/preview_img_cplugin/lib/src/preview/preview_export_folder_picker.dart';
import 'package:c_editor/bundled_plugins/preview_img_cplugin/lib/src/preview/preview_export_prefs.dart';
import 'package:c_editor/bundled_plugins/preview_img_cplugin/lib/src/preview/preview_generator_screen.dart';
import 'package:c_editor/bundled_plugins/preview_img_cplugin/lib/src/preview/preview_settings_screen.dart';
import 'package:c_editor/bundled_plugins/preview_img_cplugin/lib/src/preview/preview_toolbar_action.dart';
import 'package:c_editor/bundled_plugins/preview_img_cplugin/lib/src/preview/preview_toolbar_prefs.dart';
import 'package:c_editor/bloc/settings/settings_cubit.dart';
import 'package:c_editor/data/pvz_models.dart';
import 'package:c_editor/data/repository/level_repository.dart';
import 'package:c_editor/plugin_api/c_plugin_host.dart';
import 'package:c_editor/widgets/editor_components.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path/path.dart' as p;

late Map<String, dynamic> _copy;
String _t(String key, [String? fallback]) =>
    _copy[key] as String? ?? fallback ?? key;

class _Host extends Fake implements CPluginHost {
  @override
  String localize(
    BuildContext context,
    String key, [
    String? fallback,
    Map<String, Object?>? args,
  ]) => _t(key, fallback);
}

FileItem _folder(String name) => FileItem(
  name: name,
  path: 'unused/$name',
  isDirectory: true,
  lastModified: 0,
  size: 0,
);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(() {
    _copy =
        jsonDecode(
              File(
                'lib/bundled_plugins/preview_img_cplugin/assets/l10n/en.arb',
              ).readAsStringSync(),
            )
            as Map<String, dynamic>;
  });
  setUp(() {
    SharedPreferences.setMockInitialValues({});
    // Asset futures created by another test's FakeAsync zone cannot be reused.
    rootBundle.clear();
  });

  test(
    'export folder preserves nested localized names and rejects escapes',
    () async {
      expect(await PreviewExportPrefs.getFolderName(), 'previews');
      await PreviewExportPrefs.setFolderPath('截图/关卡预览');
      expect(await PreviewExportPrefs.getFolderName(), '截图/关卡预览');
      expect(
        previewExportDirectoryPath('web://', 'previews'),
        'web://previews',
      );
      expect(previewExportDirectoryPath('web://', '截图/关卡预览'), 'web://截图/关卡预览');
      expect(previewExportFilePath('web://', 'a.png'), 'web://a.png');
      expect(previewExportFileName('web://a.png'), 'a.png');
      expect(previewExportParentDirectory('web://a.png'), 'web://');
      expect(
        previewExportLibraryRelativePath('web://截图/关卡预览/a.png', 'web://'),
        '截图/关卡预览/a.png',
      );
      final nativeWorkspace = Directory.systemTemp.path;
      expect(
        previewExportDirectoryPath(nativeWorkspace, '截图/关卡预览'),
        p.join(nativeWorkspace, '截图', '关卡预览'),
      );
      expect(
        previewExportDirectoryPath('web://levels', '截图/关卡预览'),
        'web://levels/截图/关卡预览',
      );
      expect(
        previewExportLibraryRelativePath(
          'web://levels/截图/关卡预览/a.png',
          'web://levels',
        ),
        '截图/关卡预览/a.png',
      );
      for (final unsafe in [
        '../outside',
        'a/../../outside',
        '/absolute',
        r'C:\outside',
        r'\\server\outside',
      ]) {
        expect(
          PreviewExportPrefs.normalizeRelativeFolderPath(unsafe),
          'previews',
        );
      }
      expect(
        () => previewExportLibraryRelativePath(
          'web://elsewhere/a.png',
          'web://levels',
        ),
        throwsArgumentError,
      );
      await PreviewExportPrefs.setFolderPath('.');
      expect(await PreviewExportPrefs.getFolderName(), '.');
      expect(previewExportDirectoryPath('web://levels', '.'), 'web://levels');
    },
  );

  test('toolbar style defaults to full and persists compact choice', () async {
    expect(await PreviewToolbarPrefs.getStyle(), PreviewToolbarStyle.full);
    await PreviewToolbarPrefs.setStyle(PreviewToolbarStyle.compact);
    expect(await PreviewToolbarPrefs.getStyle(), PreviewToolbarStyle.compact);
    await PreviewToolbarPrefs.setStyle(PreviewToolbarStyle.full);
    expect(await PreviewToolbarPrefs.getStyle(), PreviewToolbarStyle.full);
  });

  test('new folder names reject Windows device aliases and trailing dots', () {
    for (final invalid in [
      'CON',
      'nul.png',
      'Com1',
      'LPT9',
      '截图.',
      '.',
      '..',
      'a/b',
    ]) {
      expect(isValidPreviewExportFolderName(invalid), isFalse);
    }
    for (final valid in ['关卡预览', '截图 2026', 'COM10', 'Content']) {
      expect(isValidPreviewExportFolderName(valid), isTrue);
    }
  });

  testWidgets(
    'folder-only picker navigates, creates and selects nested folder',
    (tester) async {
      final folders = <String, List<FileItem>>{
        'web://': [_folder('previews'), _folder('截图')],
        'web://previews': [],
        'web://截图': [],
      };
      String? result;
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) => Scaffold(
              body: TextButton(
                onPressed: () async {
                  result = await Navigator.push<String>(
                    context,
                    MaterialPageRoute(
                      builder: (_) => PreviewExportFolderPicker(
                        workspacePath: 'web://',
                        initialFolder: 'previews',
                        t: _t,
                        listFolders: (path) async => folders[path]!,
                        createFolder: (path, name) async {
                          folders[path]!.add(_folder(name));
                          folders['$path/$name'] = [];
                          return true;
                        },
                      ),
                    ),
                  );
                },
                child: const Text('Open picker'),
              ),
            ),
          ),
        ),
      );
      await tester.tap(find.text('Open picker'));
      await tester.pumpAndSettle();
      expect(find.text('Currently in: previews'), findsOneWidget);
      await tester.tap(find.text(_t('previewSettingsParentFolder')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('previewExportFolder-截图')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('previewExportCreateFolder')));
      await tester.pumpAndSettle();
      await tester.enterText(
        find.byKey(const ValueKey('previewExportNewFolderName')),
        '关卡预览',
      );
      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();
      expect(find.text('Currently in: 截图/关卡预览'), findsOneWidget);
      await tester.tap(find.byKey(const ValueKey('previewExportSelectFolder')));
      await tester.pumpAndSettle();
      expect(result, '截图/关卡预览');
      expect(folders['web://截图']!.single.name, '关卡预览');
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('folder picker rejects traversal names and keeps failures open', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: PreviewExportFolderPicker(
          workspacePath: 'web://levels',
          initialFolder: 'previews',
          t: _t,
          listFolders: (_) async => [],
          createFolder: (_, _) async => false,
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('previewExportCreateFolder')));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byKey(const ValueKey('previewExportNewFolderName')),
      '../bad',
    );
    await tester.tap(find.text('OK'));
    await tester.pumpAndSettle();
    expect(find.text(_t('previewSettingsFolderNameInvalid')), findsOneWidget);
    await tester.enterText(
      find.byKey(const ValueKey('previewExportNewFolderName')),
      'existing',
    );
    await tester.tap(find.text('OK'));
    await tester.pumpAndSettle();
    expect(find.byType(PreviewExportFolderPicker), findsOneWidget);
    expect(find.text(_t('previewSettingsFolderCreateFailed')), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('settings uses folder button with hint below and saves toolbar', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(600, 900));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(
      MaterialApp(home: PreviewSettingsScreen(host: _Host())),
    );
    await tester.pumpAndSettle();
    expect(find.byType(TextField), findsNothing);
    final button = find.byKey(
      const ValueKey('previewSettingsChooseExportFolder'),
    );
    final hint = find.byKey(const ValueKey('previewSettingsFolderHint'));
    expect(
      tester.getRect(hint).top,
      greaterThanOrEqualTo(tester.getRect(button).bottom),
    );
    expect(
      find.descendant(of: button, matching: find.textContaining('previews')),
      findsOneWidget,
    );
    await tester.tap(find.byKey(const ValueKey('previewToolbarStyleCompact')));
    await tester.pumpAndSettle();
    await tester.tap(find.text(_t('previewSettingsSave')));
    await tester.pumpAndSettle();
    expect(await PreviewToolbarPrefs.getStyle(), PreviewToolbarStyle.compact);
    expect(await PreviewExportPrefs.getFolderName(), 'previews');
    expect(tester.takeException(), isNull);
  });

  testWidgets('settings stages and saves the shared preview autosave option', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final cubit = SettingsCubit(prefs);
    addTearDown(cubit.close);
    await tester.binding.setSurfaceSize(const Size(600, 900));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      BlocProvider.value(
        value: cubit,
        child: MaterialApp(home: PreviewSettingsScreen(host: _Host())),
      ),
    );
    await tester.pumpAndSettle();

    final autosave = find.byKey(
      const ValueKey('previewSettingsAutosaveOnExit'),
    );
    expect(tester.widget<CheckboxListTile>(autosave).value, isFalse);
    await tester.tap(autosave);
    await tester.pump();
    expect(
      cubit.state.autosaveTargets.contains(AutosaveTarget.previewImage),
      isFalse,
    );

    await tester.tap(find.text(_t('previewSettingsSave')));
    await tester.pumpAndSettle();
    expect(
      cubit.state.autosaveTargets.contains(AutosaveTarget.previewImage),
      isTrue,
    );
    expect(
      prefs.getBool(AutosaveTarget.previewImage.preferenceKey),
      isTrue,
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'narrow settings wraps long folder names without squeezing labels',
    (tester) async {
      SharedPreferences.setMockInitialValues({
        kPreviewExportFolderPrefsKey: '截图/很长的关卡预览文件夹名称/另一个很长的文件夹',
      });
      await tester.binding.setSurfaceSize(const Size(320, 850));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      await tester.pumpWidget(
        MaterialApp(
          builder: (context, child) => MediaQuery(
            data: MediaQuery.of(
              context,
            ).copyWith(textScaler: const TextScaler.linear(1.8)),
            child: child!,
          ),
          home: PreviewSettingsScreen(host: _Host()),
        ),
      );
      await tester.pumpAndSettle();
      expect(
        find.byKey(const ValueKey('previewSettingsChooseExportFolder')),
        findsOneWidget,
      );
      expect(tester.takeException(), isNull);
    },
  );

  for (final style in PreviewToolbarStyle.values) {
    testWidgets('generator applies $style original labels and primary row', (
      tester,
    ) async {
      SharedPreferences.setMockInitialValues({
        kPreviewToolbarStylePrefsKey: style.name,
      });
      await tester.binding.setSurfaceSize(const Size(1200, 900));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      await tester.pumpWidget(
        MaterialApp(
          home: PreviewGeneratorScreen(
            host: _Host(),
            levelFile: PvzLevelFile(objects: []),
            parsed: ParsedLevelData(objectMap: {}),
            fileName: 'toolbar.json',
          ),
        ),
      );
      for (
        var attempt = 0;
        attempt < 200 && find.byType(PreviewCanvas).evaluate().isEmpty;
        attempt++
      ) {
        await tester.runAsync(
          () => Future<void>.delayed(const Duration(milliseconds: 25)),
        );
        await tester.pump(const Duration(milliseconds: 25));
      }
      await tester.pumpAndSettle();
      final select = find.byKey(const ValueKey('previewToolbarTool-select'));
      final addText = find.byKey(
        const ValueKey('previewToolbarAction-previewGenAddText'),
      );
      expect(select, findsOneWidget);
      expect(addText, findsOneWidget);
      expect(
        tester.widget<PreviewToolbarAction>(select).compact,
        style == PreviewToolbarStyle.compact,
      );
      if (style == PreviewToolbarStyle.compact) {
        expect(find.text(_t('previewGenAddText')), findsNothing);
        final primary = find.byKey(
          const ValueKey('previewToolbarCompactPrimaryRow'),
        );
        expect(find.descendant(of: primary, matching: select), findsOneWidget);
        expect(find.descendant(of: primary, matching: addText), findsOneWidget);
        expect(tester.widget(primary), isA<HorizontalTagScroller>());
        expect(
          (tester.getRect(select).center.dy - tester.getRect(addText).center.dy)
              .abs(),
          lessThan(10),
        );
        await tester.longPress(addText);
        await tester.pumpAndSettle();
        expect(find.text(_t('previewGenAddText')), findsOneWidget);
      } else {
        expect(find.text(_t('previewGenAddText')), findsOneWidget);
        expect(
          tester.widget(
            find.byKey(const ValueKey('previewToolbarFullToolRow')),
          ),
          isA<Wrap>(),
        );
        expect(
          find.descendant(of: addText, matching: find.byType(Column)),
          findsNothing,
        );
        expect(
          tester.getRect(addText).top,
          greaterThan(tester.getRect(select).top),
        );
      }
      final tooltip = tester.widget<Tooltip>(
        find.descendant(of: select, matching: find.byType(Tooltip)).first,
      );
      expect(tooltip.message, _t('previewTool_select'));
      expect(_copy.containsKey('previewTool_selectHint'), isFalse);
      expect(_copy.containsKey('previewGenAddTextHint'), isFalse);
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets(
    'full toolbar naturally wraps instead of locking horizontal rows',
    (tester) async {
      SharedPreferences.setMockInitialValues({
        kPreviewToolbarStylePrefsKey: PreviewToolbarStyle.full.name,
      });
      await tester.binding.setSurfaceSize(const Size(600, 900));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      await tester.pumpWidget(
        MaterialApp(
          builder: (context, child) => MediaQuery(
            data: MediaQuery.of(
              context,
            ).copyWith(textScaler: const TextScaler.linear(1.5)),
            child: child!,
          ),
          home: PreviewGeneratorScreen(
            host: _Host(),
            levelFile: PvzLevelFile(objects: []),
            parsed: ParsedLevelData(objectMap: {}),
            fileName: 'toolbar-scroll.json',
          ),
        ),
      );
      for (
        var attempt = 0;
        attempt < 200 && find.byType(PreviewCanvas).evaluate().isEmpty;
        attempt++
      ) {
        await tester.runAsync(
          () => Future<void>.delayed(const Duration(milliseconds: 25)),
        );
        await tester.pump(const Duration(milliseconds: 25));
      }
      await tester.pumpAndSettle();
      final row = find.byKey(const ValueKey('previewToolbarElementOptionsRow'));
      expect(tester.widget(row), isA<Wrap>());
      expect(
        find.descendant(of: row, matching: find.byType(HorizontalTagScroller)),
        findsNothing,
      );
      final narrowHeight = tester.getSize(row).height;
      expect(narrowHeight, greaterThan(100));
      final narrowRowRect = tester.getRect(row);
      final actions = find.descendant(
        of: row,
        matching: find.byType(PreviewToolbarAction),
      );
      expect(actions, findsNWidgets(7));
      for (final element in actions.evaluate()) {
        final rect = tester.getRect(find.byWidget(element.widget));
        expect(rect.left, greaterThanOrEqualTo(narrowRowRect.left));
        expect(rect.right, lessThanOrEqualTo(narrowRowRect.right));
      }
      // Adding rows must remain inside the independently scrollable toolbar,
      // rather than causing that toolbar to take more of the fitted canvas.
      final canvasSize = tester.getSize(find.byType(PreviewCanvas));
      await tester.ensureVisible(
        find.byKey(const ValueKey('previewToolbarAction-previewGenRecreate')),
      );
      await tester.pumpAndSettle();
      expect(tester.getSize(find.byType(PreviewCanvas)), canvasSize);
      expect(
        find
            .byKey(const ValueKey('previewToolbarAction-previewGenRecreate'))
            .hitTestable(),
        findsOneWidget,
      );
      await tester.binding.setSurfaceSize(const Size(1200, 900));
      await tester.pumpAndSettle();
      expect(tester.getSize(row).height, lessThan(narrowHeight));
      expect(tester.takeException(), isNull);
    },
  );

  for (final style in PreviewToolbarStyle.values) {
    testWidgets(
      'selected rectangle keeps $style sliders usable with large text',
      (tester) async {
        SharedPreferences.setMockInitialValues({
          kPreviewToolbarStylePrefsKey: style.name,
        });
        await tester.binding.setSurfaceSize(const Size(600, 900));
        addTearDown(() => tester.binding.setSurfaceSize(null));
        await tester.pumpWidget(
          MaterialApp(
            builder: (context, child) => MediaQuery(
              data: MediaQuery.of(
                context,
              ).copyWith(textScaler: const TextScaler.linear(1.5)),
              child: child!,
            ),
            home: PreviewGeneratorScreen(
              host: _Host(),
              levelFile: PvzLevelFile(objects: []),
              parsed: ParsedLevelData(objectMap: {}),
              fileName: 'rectangle-toolbar.json',
            ),
          ),
        );
        for (
          var attempt = 0;
          attempt < 200 && find.byType(PreviewCanvas).evaluate().isEmpty;
          attempt++
        ) {
          await tester.runAsync(
            () => Future<void>.delayed(const Duration(milliseconds: 25)),
          );
          await tester.pump(const Duration(milliseconds: 25));
        }
        await tester.pumpAndSettle();
        final figures = find.byKey(
          const ValueKey('previewToolbarAction-previewTool_figures'),
        );
        await tester.ensureVisible(figures);
        await tester.pumpAndSettle();
        await tester.tap(figures);
        await tester.pumpAndSettle();
        await tester.tap(
          find.byKey(const ValueKey('previewFigure-rect-false')),
        );
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);

        final canvasFinder = find.byType(PreviewCanvas);
        final drawingCanvas = tester.widget<PreviewCanvas>(canvasFinder);
        expect(drawingCanvas.tool, PreviewEditTool.figures);
        // PreviewCanvas fills the viewport, but its fitted image can have
        // letterboxing. Draw in the actual export boundary, not that padding.
        final boundary = tester.renderObject<RenderBox>(
          find.byKey(drawingCanvas.boundaryKey!),
        );
        final start = boundary.localToGlobal(
          Offset(boundary.size.width * 0.2, boundary.size.height * 0.2),
        );
        final end = boundary.localToGlobal(
          Offset(boundary.size.width * 0.5, boundary.size.height * 0.5),
        );
        final gesture = await tester.startGesture(start);
        await tester.pump();
        await gesture.moveTo(Offset.lerp(start, end, 0.5)!);
        await tester.pump();
        await gesture.moveTo(end);
        await tester.pump();
        await gesture.up();
        await tester.pumpAndSettle();
        final canvas = tester.widget<PreviewCanvas>(canvasFinder);
        final rectangle = canvas.document.layers.singleWhere(
          (layer) => layer.kind == PreviewLayerKind.shape,
        );
        expect(rectangle.shapeKind, PreviewShapeKind.rect);
        expect(canvas.selectedLayerId, rectangle.id);

        final options = find.byKey(
          const ValueKey('previewToolbarElementOptionsRow'),
        );
        if (style == PreviewToolbarStyle.compact) {
          expect(tester.widget(options), isA<HorizontalTagScroller>());
          expect(
            tester
                .widget<Scrollbar>(
                  find.descendant(
                    of: options,
                    matching: find.byType(Scrollbar),
                  ),
                )
                .thumbVisibility,
            isTrue,
          );
        } else {
          expect(tester.widget(options), isA<Wrap>());
          expect(
            find.descendant(of: options, matching: find.byType(Scrollbar)),
            findsNothing,
          );
        }
        final controlCenters = <double>[];
        for (final key in ['previewGenScale', 'previewGenCornerRadius']) {
          final label = _t(key);
          final tooltip = find.descendant(
            of: options,
            matching: find.byTooltip(label),
          );
          expect(tooltip, findsOneWidget);
          final controlRow = find
              .ancestor(of: tooltip, matching: find.byType(Row))
              .first;
          final slider = find.descendant(
            of: controlRow,
            matching: find.byType(Slider),
          );
          expect(slider, findsOneWidget);
          expect(tester.getSize(controlRow).width, 260);
          expect(tester.getSize(slider).width, greaterThanOrEqualTo(130));
          expect(
            (tester.getCenter(tooltip).dy - tester.getCenter(slider).dy).abs(),
            lessThanOrEqualTo(2),
          );
          controlCenters.add(tester.getCenter(controlRow).dy);
          final visibleLabel = find.descendant(
            of: controlRow,
            matching: find.text(label),
          );
          if (style == PreviewToolbarStyle.compact) {
            expect(visibleLabel, findsNothing);
            expect(
              find.descendant(
                of: controlRow,
                matching: find.byIcon(Icons.tune),
              ),
              findsOneWidget,
            );
          } else {
            expect(visibleLabel, findsOneWidget);
            expect(tester.getSize(visibleLabel).width, lessThanOrEqualTo(120));
            expect(
              tester.getRect(visibleLabel).right,
              lessThanOrEqualTo(tester.getRect(slider).left),
            );
          }
        }
        if (style == PreviewToolbarStyle.compact) {
          expect(
            (controlCenters[0] - controlCenters[1]).abs(),
            lessThanOrEqualTo(2),
          );
        }
        expect(tester.takeException(), isNull);
      },
    );
  }
}
