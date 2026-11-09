import 'package:c_editor/data/pvz_models.dart';
import 'package:c_editor/l10n/app_localizations.dart';
import 'package:c_editor/widgets/jitter_offsets_binding_card.dart';
import 'package:c_editor/widgets/persistent_scrollbar_scroll_behavior.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets(
    'offset controls start collapsed and the dialog can cancel or open management',
    (tester) async {
      var changes = 0;
      var managementOpened = false;
      await tester.pumpWidget(
        MaterialApp(
          locale: const Locale('zh'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(
            body: SingleChildScrollView(
              child: JitterOffsetsBindingCard(
                levelFile: PvzLevelFile(objects: []),
                currentValue: null,
                fixedOffset: 0,
                onFixedOffsetChanged: (_) {},
                onChanged: (_) => changes++,
                onManage: () => managementOpened = true,
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(
        find.byKey(const ValueKey('jitterOffsetsPresetPicker')),
        findsNothing,
      );
      expect(find.byKey(const ValueKey('fixedOffsetField')), findsNothing);
      await tester.tap(
        find.byKey(const ValueKey('spawnPositionOffsetSettings')),
      );
      await tester.pumpAndSettle();
      expect(find.byKey(const ValueKey('fixedOffsetField')), findsOneWidget);
      final l10n = AppLocalizations.of(
        tester.element(find.byType(JitterOffsetsBindingCard)),
      )!;
      expect(find.text(l10n.jitterOffsetsFixedOffsetDescription), findsNothing);
      await tester.tap(find.byKey(const ValueKey('jitterOffsetsPresetPicker')));
      await tester.pumpAndSettle();
      expect(find.text(l10n.jitterOffsetsSelectTitle), findsOneWidget);
      expect(find.byType(BottomSheet), findsNothing);
      await tester.tap(find.text(l10n.cancel));
      await tester.pumpAndSettle();
      expect(changes, 0);
      await tester.tap(find.byKey(const ValueKey('jitterOffsetsPresetPicker')));
      await tester.pumpAndSettle();
      await tester.tap(
        find.byKey(const ValueKey('jitterOffsetsAddFromPicker')),
      );
      await tester.pumpAndSettle();
      expect(managementOpened, isTrue);
      expect(changes, 0);
      expect(
        find.byKey(const ValueKey('jitterOffsetsPresetDialog')),
        findsNothing,
      );
    },
  );

  for (final brightness in Brightness.values) {
    for (final size in const [Size(320, 640), Size(900, 300)]) {
      testWidgets('offset dialog fits $brightness $size with large text', (
        tester,
      ) async {
        tester.view.physicalSize = size;
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        for (final locale in ['zh', 'en', 'ru']) {
          await tester.pumpWidget(const SizedBox.shrink());
          await tester.pumpWidget(
            MaterialApp(
              locale: Locale(locale),
              localizationsDelegates: AppLocalizations.localizationsDelegates,
              supportedLocales: AppLocalizations.supportedLocales,
              theme: ThemeData(brightness: brightness),
              scrollBehavior: const PersistentScrollbarScrollBehavior(),
              builder: (_, child) => MediaQuery(
                data: MediaQueryData(
                  size: size,
                  textScaler: TextScaler.linear(1.4),
                ),
                child: child!,
              ),
              home: Scaffold(
                body: SingleChildScrollView(
                  child: JitterOffsetsBindingCard(
                    levelFile: PvzLevelFile(
                      objects: [
                        for (var i = 0; i < 12; i++)
                          PvzObject(
                            aliases: ['OffsetsLongAlias$i'],
                            objClass: 'ZombieJitterOffsets',
                            objData: {
                              'ZombieSpawningOffsetIncrement': 80,
                              'ZombieSpawningRandomJitter': 30,
                            },
                          ),
                      ],
                    ),
                    currentValue: null,
                    fixedOffset: 0,
                    onFixedOffsetChanged: (_) {},
                    onChanged: (_) {},
                    onManage: () {},
                  ),
                ),
              ),
            ),
          );
          await tester.pumpAndSettle();
          await tester.tap(
            find.byKey(const ValueKey('spawnPositionOffsetSettings')),
          );
          await tester.pumpAndSettle();
          final picker = find.byKey(
            const ValueKey('jitterOffsetsPresetPicker'),
          );
          await tester.ensureVisible(picker);
          await tester.tap(picker);
          await tester.pumpAndSettle();
          expect(
            find.byKey(const ValueKey('jitterOffsetsPresetDialog')),
            findsOneWidget,
          );
          expect(
            find
                .byKey(const ValueKey('jitterOffsetsAddFromPicker'))
                .hitTestable(),
            findsOneWidget,
          );
          expect(tester.takeException(), isNull, reason: locale);
        }
      });
    }
  }
}
