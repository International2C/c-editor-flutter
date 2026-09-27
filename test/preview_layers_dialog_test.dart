import 'package:c_editor/bundled_plugins/preview_img_cplugin/lib/src/preview/preview_document.dart';
import 'package:c_editor/bundled_plugins/preview_img_cplugin/lib/src/preview/preview_layers_dialog.dart';
import 'package:c_editor/bundled_plugins/preview_img_cplugin/lib/src/preview/preview_picker_session.dart';
import 'package:c_editor/widgets/editor_components.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'helpers/preview_scrollbar_gesture.dart';

String _t(String key, [String? fallback]) => switch (key) {
  'previewGenLayers' => 'Layers',
  'previewGenLayersHint' =>
    'Drag a layer handle to change the front-to-back order.',
  'previewGenClose' => 'Close',
  'previewGenLayerType_background' => 'Background',
  'previewGenLayerType_text' => 'Text',
  'previewGenLayerType_image' => 'Sticker',
  'previewGenLayerType_iconGrid' => 'Icon grid',
  'previewGenLayerType_shape' => 'Shape',
  'previewGenLayerType_stroke' => 'Drawing',
  _ => fallback ?? key,
};

PreviewLayer _layer(
  String id,
  int zIndex, [
  PreviewLayerKind kind = PreviewLayerKind.text,
]) => PreviewLayer(
  id: id,
  kind: kind,
  zIndex: zIndex,
  bounds: const Rect.fromLTWH(0.1, 0.1, 0.2, 0.2),
  text: id,
);

PreviewDocument _document(List<PreviewLayer> layers) => PreviewDocument(
  banner: PreviewBannerRef(
    kind: PreviewBannerSourceKind.assetStem,
    stem: 'Modern',
  ),
  layers: layers,
);

Finder _option(String id) => find.byKey(ValueKey('previewLayerOption-$id'));
Finder _handle(String id) => find.byKey(ValueKey('previewLayerDragHandle-$id'));

EditorOptionTile _tile(WidgetTester tester, String id) =>
    tester.widget<EditorOptionTile>(
      find.descendant(of: _option(id), matching: find.byType(EditorOptionTile)),
    );

Future<void> _open(
  WidgetTester tester,
  PreviewDocument doc, {
  String? selectedLayerId,
  PreviewPickerSession? session,
  ValueChanged<String>? onSelected,
  ValueChanged<List<String>>? onReorder,
  String Function(PreviewLayerOrderEntry)? title,
  Size size = const Size(600, 900),
  double textScale = 1,
  TargetPlatform platform = TargetPlatform.android,
}) async {
  tester.view.devicePixelRatio = 1;
  tester.view.physicalSize = size;
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
          body: Center(
            child: TextButton(
              onPressed: () => showPreviewLayersDialog(
                context: context,
                session: session,
                doc: doc,
                selectedLayerId: selectedLayerId,
                t: _t,
                entryTitle:
                    title ??
                    (entry) => entry.isBackground
                        ? 'Stage background'
                        : 'Layer ${entry.id}',
                onSelected: onSelected ?? (_) {},
                onReorder: onReorder ?? (ids) => doc.reorderLayers(ids),
              ),
              child: const Text('Open layers'),
            ),
          ),
        ),
      ),
    ),
  );
  await tester.tap(find.text('Open layers'));
  await tester.pumpAndSettle();
}

void main() {
  for (final platform in [TargetPlatform.android, TargetPlatform.iOS]) {
    testWidgets('layer thumb drags without reordering on ${platform.name}', (
      tester,
    ) async {
      final doc = _document(
        List.generate(30, (index) => _layer('layer$index', index)),
      );
      final originalOrder = doc.orderedLayerEntries
          .map((entry) => entry.id)
          .toList();
      var selected = false;
      var reordered = false;
      final session = PreviewPickerSession();
      await _open(
        tester,
        doc,
        session: session,
        size: const Size(390, 700),
        platform: platform,
        onSelected: (_) => selected = true,
        onReorder: (_) => reordered = true,
      );
      final scroll = tester
          .widget<ReorderableListView>(
            find.byKey(const ValueKey('previewLayersList')),
          )
          .scrollController!;
      await dragPreviewVerticalScrollbar(
        tester,
        const ValueKey('previewLayersScrollbar'),
      );
      expect(scroll.offset, greaterThan(200));
      final savedOffset = scroll.offset;
      expect(selected, isFalse);
      expect(reordered, isFalse);
      expect(doc.orderedLayerEntries.map((entry) => entry.id), originalOrder);
      expect(
        find.byKey(const ValueKey('previewLayersClose')).hitTestable(),
        findsOneWidget,
      );
      await tester.tap(find.byKey(const ValueKey('previewLayersClose')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Open layers'));
      await tester.pumpAndSettle();
      expect(
        tester
            .widget<ReorderableListView>(
              find.byKey(const ValueKey('previewLayersList')),
            )
            .scrollController!
            .offset,
        closeTo(savedOffset, 1),
      );
      expect(tester.takeException(), isNull);
    });
  }
  testWidgets(
    'layers are front-to-back and selection includes the background',
    (tester) async {
      final doc = _document([_layer('bottom', 0), _layer('top', 10)]);
      String? selected;
      await _open(
        tester,
        doc,
        selectedLayerId: 'top',
        onSelected: (id) => selected = id,
      );
      expect(
        tester.getTopLeft(_option('top')).dy,
        lessThan(tester.getTopLeft(_option('bottom')).dy),
      );
      expect(
        tester.getTopLeft(_option('bottom')).dy,
        lessThan(tester.getTopLeft(_option(kPreviewBackgroundLayerId)).dy),
      );
      expect(_tile(tester, 'top').selected, isTrue);
      for (final id in ['top', 'bottom', kPreviewBackgroundLayerId]) {
        final row = _tile(tester, id);
        final handle = tester.getRect(_handle(id));
        final typeIcon = find.descendant(
          of: _option(id),
          matching: find.byWidget(row.leading!),
        );
        expect(handle.right, lessThanOrEqualTo(tester.getRect(typeIcon).left));
        expect(
          handle.right,
          lessThan(tester.getRect(find.byWidget(row.title)).left),
        );
        expect(row.trailing, isNull);
      }
      await tester.tap(find.text('Stage background'));
      await tester.pumpAndSettle();
      expect(selected, kPreviewBackgroundLayerId);
      expect(_tile(tester, kPreviewBackgroundLayerId).selected, isTrue);
      expect(_tile(tester, 'top').selected, isFalse);
      expect(find.byIcon(Icons.delete), findsNothing);
      expect(find.byIcon(Icons.wallpaper), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('only handles reorder and the background can move to the front', (
    tester,
  ) async {
    final doc = _document([_layer('bottom', 0), _layer('top', 10)]);
    final orders = <List<String>>[];
    await _open(
      tester,
      doc,
      onReorder: (ids) {
        orders.add(List.of(ids));
        doc.reorderLayers(ids);
      },
    );
    expect(
      tester
          .widget<ReorderableListView>(find.byType(ReorderableListView))
          .buildDefaultDragHandles,
      isFalse,
    );
    await tester.drag(find.text('Layer top'), const Offset(0, 100));
    await tester.pumpAndSettle();
    expect(orders, isEmpty);

    final start = tester.getCenter(_handle(kPreviewBackgroundLayerId));
    final middleY = tester.getCenter(_option('bottom')).dy;
    final firstRect = tester.getRect(_option('top'));
    final dragOffsetY =
        start.dy - tester.getTopLeft(_option(kPreviewBackgroundLayerId)).dy;
    // Flutter compares the proxy card's leading edge, not the handle pointer.
    // Put that edge in the first row's leading half to select insertion index 0.
    final targetY = firstRect.top + firstRect.height * 0.25 + dragOffsetY;
    final drag = await tester.startGesture(start);
    await tester.pump();
    await drag.moveBy(const Offset(0, -24));
    await tester.pump(const Duration(milliseconds: 100));
    await drag.moveTo(Offset(start.dx, middleY));
    await tester.pump(const Duration(milliseconds: 300));
    await drag.moveTo(Offset(start.dx, targetY));
    await tester.pump(const Duration(milliseconds: 300));
    await drag.up();
    await tester.pumpAndSettle();
    expect(orders, [
      ['bottom', 'top', kPreviewBackgroundLayerId],
    ]);
    expect(doc.orderedLayerEntries.last.isBackground, isTrue);
    expect(
      tester.getTopLeft(_option(kPreviewBackgroundLayerId)).dy,
      lessThan(tester.getTopLeft(_option('top')).dy),
    );
    expect(find.byIcon(Icons.delete), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'short landscape scrolls its title and all layer types together',
    (tester) async {
      final doc = _document([
        for (var index = 0; index < PreviewLayerKind.values.length; index++)
          _layer('kind_$index', index, PreviewLayerKind.values[index]),
      ]);
      String? selected;
      await _open(
        tester,
        doc,
        size: const Size(900, 300),
        textScale: 1.8,
        onSelected: (id) => selected = id,
      );
      final list = find.byKey(const ValueKey('previewLayersList'));
      expect(
        find.descendant(
          of: list,
          matching: find.byKey(const ValueKey('previewLayersTitle')),
        ),
        findsOneWidget,
      );
      expect(
        tester
            .getSize(find.byKey(const ValueKey('previewLayersContent')))
            .height,
        lessThanOrEqualTo(270),
      );
      final scrollable = find
          .descendant(of: list, matching: find.byType(Scrollable))
          .first;
      for (final kind in PreviewLayerKind.values.reversed) {
        final index = PreviewLayerKind.values.indexOf(kind);
        await tester.scrollUntilVisible(
          _option('kind_$index'),
          120,
          scrollable: scrollable,
        );
        final subtitle = find.descendant(
          of: _option('kind_$index'),
          matching: find.text(_t('previewGenLayerType_${kind.name}')),
        );
        expect(subtitle, findsOneWidget);
        expect(tester.widget<Text>(subtitle).maxLines, isNull);
      }
      await tester.scrollUntilVisible(
        _option(kPreviewBackgroundLayerId),
        120,
        scrollable: scrollable,
      );
      expect(_option(kPreviewBackgroundLayerId).hitTestable(), findsOneWidget);
      expect(
        find.byKey(const ValueKey('previewLayersTitle')).hitTestable(),
        findsNothing,
      );
      await tester.tap(find.text('Stage background'));
      await tester.pumpAndSettle();
      expect(selected, kPreviewBackgroundLayerId);
      await tester.tap(find.byKey(const ValueKey('previewLayersClose')));
      await tester.pumpAndSettle();
      expect(find.byKey(const ValueKey('previewLayersDialog')), findsNothing);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('narrow large-text layer names keep their own readable width', (
    tester,
  ) async {
    final doc = _document([_layer('top', 10)]);
    const longTitle =
        'A long localized layer title that must not be squeezed by its icons';
    await _open(
      tester,
      doc,
      size: const Size(320, 700),
      textScale: 1.8,
      title: (entry) => entry.isBackground ? 'Stage background' : longTitle,
    );
    final title = find.text(longTitle);
    expect(tester.widget<Text>(title).maxLines, 2);
    expect(tester.widget<Text>(title).overflow, TextOverflow.ellipsis);
    expect(tester.getSize(title).width, greaterThanOrEqualTo(200));
    expect(_handle('top'), findsOneWidget);
    expect(
      tester.getRect(_handle('top')).right,
      lessThanOrEqualTo(tester.getRect(title).left),
    );
    expect(tester.takeException(), isNull);
  });
}
