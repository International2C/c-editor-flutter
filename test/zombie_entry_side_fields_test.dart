import 'package:c_editor/l10n/app_localizations.dart';
import 'package:c_editor/widgets/zombie_entry_side_fields.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  for (final locale in ['zh', 'en', 'ru']) {
    testWidgets(
      'entry-side switches fit narrow scaled $locale and restore fixed side',
      (tester) async {
        tester.view.physicalSize = const Size(280, 900);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.reset);
        String? direction;
        await tester.pumpWidget(
          MaterialApp(
            locale: Locale(locale),
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            builder: (context, child) => MediaQuery(
              data: MediaQuery.of(
                context,
              ).copyWith(textScaler: TextScaler.linear(1.5)),
              child: child!,
            ),
            home: Scaffold(
              body: StatefulBuilder(
                builder: (context, setState) => SingleChildScrollView(
                  child: ZombieEntrySideFields(
                    direction: direction,
                    onChanged: (value) => setState(() => direction = value),
                  ),
                ),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();
        final l10n = lookupAppLocalizations(Locale(locale));
        expect(find.text(l10n.zombieEntrySideLabel), findsOneWidget);
        expect(find.text(l10n.zombieFromRight), findsOneWidget);
        final left = find.byKey(const ValueKey('zombieLeftEntrySide'));
        final random = find.byKey(const ValueKey('zombieRandomEntrySide'));
        await tester.ensureVisible(left);
        await tester.tap(left);
        await tester.pumpAndSettle();
        expect(direction, 'left');
        await tester.ensureVisible(random);
        await tester.tap(random);
        await tester.pumpAndSettle();
        expect(direction, 'random');
        expect(tester.widget<SwitchListTile>(left).onChanged, isNull);
        await tester.tap(random);
        await tester.pumpAndSettle();
        expect(direction, 'left');
        expect(tester.widget<SwitchListTile>(left).value, isTrue);
        expect(tester.takeException(), isNull);
      },
    );
  }
}
