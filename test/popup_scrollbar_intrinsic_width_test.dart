import 'dart:math' as math;

import 'package:c_editor/l10n/app_localizations.dart';
import 'package:c_editor/widgets/app_ui_scaler.dart';
import 'package:c_editor/widgets/editor_components.dart';
import 'package:c_editor/widgets/persistent_scrollbar_scroll_behavior.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Future<void> _openMenu(
  WidgetTester tester, {
  required double width,
  required double uiScale,
  double textScale = 1,
  required List<String> labels,
  required ValueChanged<String> onSelected,
}) async {
  tester.view.devicePixelRatio = 1;
  tester.view.physicalSize = Size(width, 1000);
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
    MaterialApp(
      theme: ThemeData(platform: TargetPlatform.android),
      locale: const Locale('zh'),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      scrollBehavior: const PersistentScrollbarScrollBehavior(),
      builder: (context, child) => AppUiScaler(
        scale: uiScale,
        wrapMessenger: false,
        child: Builder(
          builder: (context) => MediaQuery(
            data: MediaQuery.of(
              context,
            ).copyWith(textScaler: TextScaler.linear(textScale)),
            child: child!,
          ),
        ),
      ),
      home: Scaffold(
        appBar: AppBar(
          actions: [
            PopupMenuButton<String>(
              key: const ValueKey('overflowMenu'),
              onSelected: onSelected,
              itemBuilder: (_) => [
                for (var i = 0; i < labels.length; i++)
                  PopupMenuItem<String>(
                    value: labels[i],
                    child: EditorPopupMenuTile(
                      leading: Icon(Icons.sort, key: ValueKey('menuIcon$i')),
                      title: Text(labels[i], key: ValueKey('menuTitle$i')),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    ),
  );
  await tester.tap(find.byKey(const ValueKey('overflowMenu')));
  await tester.pumpAndSettle();
}

Finder get _menuSurface => find
    .ancestor(
      of: find.byType(EditorPopupMenuTile).first,
      matching: find.byWidgetPredicate(
        (widget) => widget is Material && widget.type == MaterialType.card,
      ),
    )
    .first;

void main() {
  const labels = ['排序', '刷新', '语言', '释放缓存', '界面设置', '插件', '关于软件', '关卡测试包'];
  for (final width in [320.0, 390.0, 1000.0]) {
    for (final uiScale in [.85, 1.0, 1.8]) {
      testWidgets(
        'app scrollbar preserves popup width at viewport $width and UI scale $uiScale',
        (tester) async {
          String? selected;
          await _openMenu(
            tester,
            width: width,
            uiScale: uiScale,
            labels: labels,
            onSelected: (value) => selected = value,
          );
          expect(tester.takeException(), isNull);
          final menu = tester.getRect(_menuSurface);
          // Flutter caps ordinary popup menus at 280 logical pixels and
          // leaves 8 on either edge. The intrinsic width must reach that cap
          // when the tiles request it, rather than collapsing to 112.
          final expectedWidth = math.min(280.0, width / uiScale - 16);
          expect(menu.width / uiScale, closeTo(expectedWidth, .1));
          expect(menu.left, greaterThanOrEqualTo(0));
          expect(menu.right, lessThanOrEqualTo(width + .1));

          final tile = tester.getRect(find.byType(EditorPopupMenuTile).first);
          if (tile.width / uiScale >= 180) {
            final icon = tester.getRect(
              find.byKey(const ValueKey('menuIcon0')),
            );
            final title = tester.getRect(
              find.byKey(const ValueKey('menuTitle0')),
            );
            expect(title.left, greaterThan(icon.right));
            expect(title.center.dy, closeTo(icon.center.dy, .1));
          }
          final last = find.text(labels.last);
          await tester.ensureVisible(last);
          await tester.pumpAndSettle();
          await tester.tap(last);
          await tester.pumpAndSettle();
          expect(selected, labels.last);
          expect(tester.takeException(), isNull);
        },
      );
    }
  }

  for (final label in [
    '这是用于验证窄屏换行后仍可点击的较长中文菜单操作',
    'Настройки интерфейса и управление дополнительными действиями',
  ]) {
    testWidgets('long popup label remains readable and clickable: $label', (
      tester,
    ) async {
      String? selected;
      await _openMenu(
        tester,
        width: 320,
        uiScale: .85,
        textScale: 1.8,
        labels: [label],
        onSelected: (value) => selected = value,
      );
      expect(tester.takeException(), isNull);
      final text = find.text(label);
      final textWidget = tester.widget<Text>(text);
      expect(textWidget.maxLines, isNull);
      expect(textWidget.overflow, isNot(TextOverflow.ellipsis));
      expect(tester.getSize(text).width / .85, greaterThanOrEqualTo(200));
      final menu = tester.getRect(_menuSurface);
      final rect = tester.getRect(text);
      expect(rect.left, greaterThanOrEqualTo(menu.left));
      expect(rect.right, lessThanOrEqualTo(menu.right));
      await tester.tap(text);
      await tester.pumpAndSettle();
      expect(selected, label);
      expect(tester.takeException(), isNull);
    });
  }
}
