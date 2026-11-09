import 'dart:async';

import 'package:c_editor/bundled_plugins/level_test_cplugin/lib/src/dynamic_fetch_ui.dart';
import 'package:c_editor/bundled_plugins/level_test_cplugin/lib/src/releases_api.dart';
import 'package:c_editor/bundled_plugins/preview_img_cplugin/lib/src/preview/preview_document.dart';
import 'package:c_editor/bundled_plugins/preview_img_cplugin/lib/src/preview/preview_generator_pickers.dart';
import 'package:c_editor/bundled_plugins/preview_img_cplugin/lib/src/preview/preview_pickers.dart';
import 'package:c_editor/bundled_plugins/preview_img_cplugin/lib/src/preview/stage_banner_resolver.dart';
import 'package:c_editor/data/repository/custom_stage_preset_repository.dart';
import 'package:c_editor/data/repository/stage_repository.dart';
import 'package:c_editor/l10n/app_localizations.dart';
import 'package:c_editor/l10n/resource_names.dart';
import 'package:c_editor/plugin_api/c_plugin_host.dart';
import 'package:c_editor/widgets/editor_components.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

String _t(String key, [String? fallback]) => fallback ?? key;

class _Host extends Fake implements CPluginHost {
  _Host({this.failureMessage});

  final String? failureMessage;

  @override
  String localize(
    BuildContext context,
    String key, [
    String? fallback,
    Map<String, Object?>? args,
  ]) => switch (key) {
    'dynamicSelectTitle' => 'Select a dynamic resource release',
    'dynamicLatestBadge' => 'Latest',
    'dynamicFetchError' =>
      failureMessage ?? args?['error']?.toString() ?? fallback ?? key,
    _ => fallback ?? key,
  };
}

const _release = DynamicReleaseOption(
  tagName: '2026.09.13-release',
  name: 'A readable dynamic release with a long localized name',
  downloadUrl: 'https://example.invalid/dynamic.rsb.smf',
  assetName: 'dynamic.rsb.smf',
  sizeBytes: 2097152,
  publishedAt: null,
  isLatest: true,
);

Future<void> _open(
  WidgetTester tester,
  Future<void> Function(BuildContext context) open, {
  Size size = const Size(320, 700),
  double textScale = 1.8,
}) async {
  tester.view.devicePixelRatio = 1;
  tester.view.physicalSize = size;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
    MaterialApp(
      locale: const Locale('en'),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
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
              onPressed: () => open(context),
              child: const Text('Open'),
            ),
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

  for (final size in [const Size(320, 700), const Size(900, 300)]) {
    testWidgets('figure choices remain selectable at $size with large text', (
      tester,
    ) async {
      (PreviewShapeKind, bool)? choice;
      await _open(tester, (context) async {
        choice = await showPreviewFiguresPicker(context: context, t: _t);
      }, size: size);
      final last = find.byKey(const ValueKey('previewFigure-star-true'));
      expect(tester.widget(last), isA<EditorOptionTile>());
      final scroll = find.descendant(
        of: find.byKey(const ValueKey('previewFiguresScroll')),
        matching: find.byType(Scrollable),
      );
      await tester.scrollUntilVisible(last, 120, scrollable: scroll);
      await tester.tap(last);
      await tester.pumpAndSettle();
      expect(choice, (PreviewShapeKind.star, true));
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('module choices wrap names and codes and preserve selection', (
    tester,
  ) async {
    String? choice;
    const objectClass = 'RadioactiveMeteoriteWaveActionProps';
    const title = 'A long translated radioactive meteorite event name';
    await _open(tester, (context) async {
      choice = await showPreviewModuleInfoPicker(
        context: context,
        classes: const [objectClass],
        titleForClass: (_, _) => title,
        t: _t,
      );
    });
    final option = find.byKey(const ValueKey('previewModuleInfo-$objectClass'));
    expect(tester.widget(option), isA<EditorOptionTile>());
    final scroll = find
        .descendant(
          of: find.byKey(const ValueKey('previewModuleInfoPicker')),
          matching: find.byType(Scrollable),
        )
        .first;
    await tester.scrollUntilVisible(option, 120, scrollable: scroll);
    final label = find.descendant(of: option, matching: find.text(title));
    final code = find.descendant(of: option, matching: find.text(objectClass));
    expect(tester.widget<Text>(label).maxLines, isNull);
    expect(tester.widget<Text>(code).maxLines, isNull);
    await tester.tap(option);
    await tester.pumpAndSettle();
    expect(choice, objectClass);
    expect(tester.takeException(), isNull);
  });

  testWidgets('release picker scrolls title and options on short landscape', (
    tester,
  ) async {
    DynamicReleaseOption? choice;
    await _open(tester, (context) async {
      choice = await showDynamicReleasePicker(
        context,
        _Host(),
        loadReleases: () async => [_release],
      );
    }, size: const Size(900, 300));
    final option = find.byKey(
      const ValueKey('dynamicReleaseOption-2026.09.13-release'),
    );
    expect(tester.widget(option), isA<EditorOptionTile>());
    final scroll = find
        .descendant(
          of: find.byKey(const ValueKey('dynamicReleasePickerDialog')),
          matching: find.byType(Scrollable),
        )
        .first;
    await tester.scrollUntilVisible(option, 120, scrollable: scroll);
    await tester.tap(option);
    await tester.pumpAndSettle();
    expect(choice, same(_release));
    expect(tester.takeException(), isNull);
  });

  testWidgets('release failure actions share one footer row', (tester) async {
    var closed = false;
    await _open(
      tester,
      (context) async {
        final choice = await showDynamicReleasePicker(
          context,
          _Host(),
          loadReleases: () async => throw StateError('Network unavailable'),
        );
        expect(choice, isNull);
        closed = true;
      },
      size: const Size(800, 600),
      textScale: 1,
    );
    final cancel = find.widgetWithText(TextButton, 'Cancel');
    final retry = find.widgetWithText(FilledButton, 'Retry');
    expect(cancel.hitTestable(), findsOneWidget);
    expect(retry.hitTestable(), findsOneWidget);
    expect(tester.getCenter(cancel).dy, closeTo(tester.getCenter(retry).dy, 1));
    final gap = tester.getTopLeft(retry).dx - tester.getBottomRight(cancel).dx;
    expect(gap, inInclusiveRange(0, 16));
    await tester.tap(cancel);
    await tester.pumpAndSettle();
    expect(closed, isTrue);
    expect(tester.takeException(), isNull);
  });

  for (final size in [const Size(320, 700), const Size(900, 300)]) {
    testWidgets(
      'release error actions stay visible while content scrolls at $size',
      (tester) async {
        var closed = false;
        await _open(tester, (context) async {
          await showDynamicReleasePicker(
            context,
            _Host(
              failureMessage: List.filled(
                20,
                'A long translated network failure description.',
              ).join(' '),
            ),
            loadReleases: () async => throw StateError('Network unavailable'),
          );
          closed = true;
        }, size: size);
        final dialog = find.byKey(const ValueKey('dynamicReleasePickerDialog'));
        final cancel = find.widgetWithText(TextButton, 'Cancel');
        final retry = find.widgetWithText(FilledButton, 'Retry');
        expect(cancel.hitTestable(), findsOneWidget);
        expect(retry.hitTestable(), findsOneWidget);
        final cancelTop = tester.getTopLeft(cancel).dy;
        final retryTop = tester.getTopLeft(retry).dy;
        final scroll = find
            .descendant(of: dialog, matching: find.byType(Scrollable))
            .first;
        final position = tester.state<ScrollableState>(scroll).position;
        expect(position.maxScrollExtent, greaterThan(0));
        await tester.drag(scroll, const Offset(0, -200));
        await tester.pumpAndSettle();
        expect(position.pixels, greaterThan(0));
        expect(tester.getTopLeft(cancel).dy, closeTo(cancelTop, 0.1));
        expect(tester.getTopLeft(retry).dy, closeTo(retryTop, 0.1));
        expect(cancel.hitTestable(), findsOneWidget);
        expect(retry.hitTestable(), findsOneWidget);
        await tester.tap(cancel);
        await tester.pumpAndSettle();
        expect(closed, isTrue);
        expect(tester.takeException(), isNull);
      },
    );
  }

  testWidgets('retry clears its action while loading and returns a release', (
    tester,
  ) async {
    var attempts = 0;
    final pending = Completer<List<DynamicReleaseOption>>();
    DynamicReleaseOption? choice;
    await _open(tester, (context) async {
      choice = await showDynamicReleasePicker(
        context,
        _Host(),
        loadReleases: () {
          attempts++;
          if (attempts == 1) {
            return Future.error(StateError('Network unavailable'));
          }
          return pending.future;
        },
      );
    });
    final retry = find.widgetWithText(FilledButton, 'Retry');
    await tester.tap(retry);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    expect(attempts, 2);
    expect(find.text('Retry'), findsNothing);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(
      find.widgetWithText(TextButton, 'Cancel').hitTestable(),
      findsOneWidget,
    );
    pending.complete([_release]);
    await tester.pumpAndSettle();
    expect(find.text('Retry'), findsNothing);
    final option = find.byKey(
      const ValueKey('dynamicReleaseOption-2026.09.13-release'),
    );
    await tester.ensureVisible(option);
    await tester.tap(option);
    await tester.pumpAndSettle();
    expect(choice, same(_release));
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'narrow background choices give names full width and custom stays last',
    (tester) async {
      await tester.runAsync(() async {
        await Future.wait([
          StageRepository.init(),
          CustomStagePresetRepository.init(),
          ResourceNames.ensureLoaded(),
        ]);
      });
      String? choice;
      await _open(tester, (context) async {
        choice = await showPreviewBannerPicker(
          context: context,
          banners: StageBannerResolver.forTest(),
          currentStem: 'Unknown',
          t: _t,
        );
      });
      final unknown = find.byKey(const ValueKey('preview-banner-Unknown'));
      final custom = find.byKey(const ValueKey('preview-banner-custom'));
      final name = find.descendant(
        of: unknown,
        matching: find.text('Spacetime Main Menu'),
      );
      expect(tester.getSize(name).width, greaterThanOrEqualTo(180));
      expect(tester.widget<Text>(name).maxLines, isNull);
      final scroll = find.descendant(
        of: find.byKey(const ValueKey('previewBannerPickerScroll')),
        matching: find.byType(Scrollable),
      );
      await tester.scrollUntilVisible(custom, 120, scrollable: scroll);
      expect(
        tester.getTopLeft(unknown).dy,
        lessThan(tester.getTopLeft(custom).dy),
      );
      await tester.tap(custom);
      await tester.pumpAndSettle();
      expect(choice, '__custom__');
      expect(tester.takeException(), isNull);
    },
  );
}
