import 'package:c_editor/data/bootstrap_loading_category.dart';
import 'package:c_editor/l10n/app_localizations.dart';
import 'package:c_editor/screens/startup_loading_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  for (final locale in ['zh', 'en', 'ru']) {
    for (final width in [320.0, 390.0, 1200.0]) {
      testWidgets('startup content stays centered at $width in $locale', (
        tester,
      ) async {
        tester.view.physicalSize = Size(width, 900);
        tester.view.devicePixelRatio = 1;
        tester.platformDispatcher.textScaleFactorTestValue = 1.8;
        addTearDown(tester.view.reset);
        addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);

        await tester.pumpWidget(
          StartupLoadingScreen(
            progress: 1,
            locale: Locale(locale),
            themeMode: ThemeMode.light,
            loadingCategory: BootstrapLoadingCategory.stages,
          ),
        );
        await tester.pumpAndSettle();

        final screen = tester.getRect(find.byType(Scaffold));
        final logo = tester.getRect(find.byType(Image));
        final title = tester.getRect(find.text('C-Editor'));
        final l10n = AppLocalizations.of(
          tester.element(find.byType(Scaffold)),
        )!;
        final category = tester.getRect(
          find.text(BootstrapLoadingCategory.stages.loadingLabel(l10n)),
        );
        expect(logo.center.dx, closeTo(screen.center.dx, .1));
        expect(title.center.dx, closeTo(screen.center.dx, .1));
        expect(category.center.dx, closeTo(screen.center.dx, .1));

        final bar = tester.getRect(find.byType(LinearProgressIndicator));
        final percentage = tester.getRect(find.text('100.00%'));
        expect(bar.width, greaterThan(0));
        expect(bar.right, lessThan(percentage.left));
        expect(bar.center.dy, closeTo(percentage.center.dy, .1));
        // Percent label is balanced by an equal leading gap, so the bar
        // itself should stay centered under the logo/title.
        expect(bar.center.dx, closeTo(screen.center.dx, 1));
        expect(percentage.right, lessThanOrEqualTo(screen.right - 24));
        expect(category.bottom, lessThan(screen.bottom));
        expect(tester.takeException(), isNull);
      });
    }
  }

  testWidgets('progress bar width stays fixed while percent text changes', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    Future<double> barWidthAt(double progress) async {
      await tester.pumpWidget(
        StartupLoadingScreen(
          progress: progress,
          locale: const Locale('en'),
          themeMode: ThemeMode.light,
          loadingCategory: BootstrapLoadingCategory.stages,
        ),
      );
      await tester.pump();
      return tester.getSize(find.byType(LinearProgressIndicator)).width;
    }

    final early = await barWidthAt(0.01);
    final mid = await barWidthAt(0.5);
    final done = await barWidthAt(1.0);
    expect(early, greaterThan(0));
    expect(mid, closeTo(early, 0.1));
    expect(done, closeTo(early, 0.1));
  });
}
