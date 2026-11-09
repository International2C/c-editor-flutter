import 'dart:convert';
import 'dart:io';

import 'package:c_editor/l10n/app_localizations.dart';
import 'package:c_editor/widgets/asset_image.dart';
import 'package:c_editor/widgets/editor_components.dart';
import 'package:c_editor/widgets/level_jam_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Map<String, dynamic> _messages(String locale) =>
    jsonDecode(File('assets/l10n/app_$locale.arb').readAsStringSync())
        as Map<String, dynamic>;

Widget _app({
  required String locale,
  required String? value,
  required ValueChanged<String?> onChanged,
}) => MaterialApp(
  locale: Locale(locale),
  localizationsDelegates: AppLocalizations.localizationsDelegates,
  supportedLocales: AppLocalizations.supportedLocales,
  home: Scaffold(
    body: Center(
      child: SizedBox(
        width: 420,
        child: LevelJamPickerField(
          labelText: 'LevelJam',
          value: value,
          decoration: const InputDecoration(
            labelText: 'LevelJam',
            border: OutlineInputBorder(),
          ),
          onChanged: onChanged,
        ),
      ),
    ),
  ),
);

Future<void> _openPicker(WidgetTester tester) async {
  await tester.tap(find.byKey(const ValueKey('levelJamPickerField')));
  await tester.pumpAndSettle();
  expect(find.byKey(const ValueKey('levelJamDialog')), findsOneWidget);
}

Finder _dialogDescendant(Finder matching) => find.descendant(
  of: find.byKey(const ValueKey('levelJamDialog')),
  matching: matching,
);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  for (final locale in ['en', 'zh', 'ru']) {
    testWidgets('LevelJam labels use the $locale ARB messages', (tester) async {
      final messages = _messages(locale);
      await tester.pumpWidget(
        _app(locale: locale, value: 'jam_punk', onChanged: (_) {}),
      );
      await tester.pumpAndSettle();

      expect(find.text(messages['jamPunk'] as String), findsOneWidget);
      await _openPicker(tester);
      expect(
        _dialogDescendant(find.text(messages['selectLevelJamTitle'] as String)),
        findsOneWidget,
      );

      for (final key in const [
        'jamNone',
        'jamPop',
        'jamRap',
        'jamMetal',
        'jamPunk',
        'jam8Bit',
      ]) {
        expect(
          _dialogDescendant(find.text(messages[key] as String)),
          findsOneWidget,
          reason: '$locale: $key',
        );
      }
    });
  }

  testWidgets('opens a centered dialog with six LevelJam options', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(900, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      _app(locale: 'en', value: 'unknown_jam', onChanged: (_) {}),
    );
    await tester.pumpAndSettle();
    await _openPicker(tester);

    final dialog = find.byKey(const ValueKey('levelJamDialog'));
    expect(
      find.ancestor(of: dialog, matching: find.byType(Center)),
      findsAtLeastNWidgets(1),
    );
    expect(tester.getCenter(dialog).dx, closeTo(450, 0.1));
    expect(tester.getCenter(dialog).dy, closeTo(400, 0.1));
    expect(_dialogDescendant(find.byType(EditorOptionTile)), findsNWidgets(6));
    const orderedValues = [
      'none',
      'jam_punk',
      'jam_pop',
      'jam_rap',
      'jam_8bit',
      'jam_metal',
    ];
    for (final value in orderedValues) {
      expect(find.byKey(ValueKey('levelJamOption_$value')), findsOneWidget);
    }
    final optionCenters = orderedValues
        .map(
          (value) => tester
              .getCenter(find.byKey(ValueKey('levelJamOption_$value')))
              .dy,
        )
        .toList();
    expect(optionCenters, orderedEquals([...optionCenters]..sort()));

    final cancel = _dialogDescendant(
      find.text(_messages('en')['cancel'] as String),
    );
    final lastOption = find.byKey(const ValueKey('levelJamOption_jam_metal'));
    expect(
      tester.getTopLeft(cancel).dy - tester.getBottomLeft(lastOption).dy,
      lessThan(24),
      reason:
          'the dialog should wrap its content instead of leaving a large gap',
    );
  });

  testWidgets('uses circular avatars with the expected LevelJam assets', (
    tester,
  ) async {
    await tester.pumpWidget(
      _app(locale: 'en', value: 'unknown_jam', onChanged: (_) {}),
    );
    await tester.pumpAndSettle();
    await _openPicker(tester);

    const expectedAssets = <String, List<String>>{
      'none': ['assets/images/others/jamNone.webp'],
      'jam_pop': ['assets/images/zombies/zombie_eighties_glitter.webp'],
      'jam_rap': [
        'assets/images/zombies/zombie_eighties_mc.webp',
        'assets/images/zombies/zombie_eighties_breakdancer.webp',
      ],
      'jam_metal': ['assets/images/zombies/zombie_eighties_gargantuar.webp'],
      'jam_punk': ['assets/images/zombies/zombie_eighties_punk.webp'],
      'jam_8bit': ['assets/images/zombies/zombie_eighties_arcade.webp'],
    };

    expect(_dialogDescendant(find.byType(ClipOval)), findsNWidgets(7));
    expect(_dialogDescendant(find.byType(AssetImageWidget)), findsNWidgets(7));
    for (final option in expectedAssets.entries) {
      for (var index = 0; index < option.value.length; index++) {
        final avatar = find.byKey(
          ValueKey('levelJamAvatar_${option.key}_$index'),
        );
        expect(avatar, findsOneWidget);
        expect(tester.widget(avatar), isA<ClipOval>());
        final image = find.descendant(
          of: avatar,
          matching: find.byType(AssetImageWidget),
        );
        expect(image, findsOneWidget);
        expect(
          tester.widget<AssetImageWidget>(image).assetPath,
          option.value[index],
        );
      }
    }
  });

  testWidgets('selecting None from a non-empty value reports null', (
    tester,
  ) async {
    final calls = <String?>[];
    await tester.pumpWidget(
      _app(locale: 'en', value: 'jam_pop', onChanged: calls.add),
    );
    await tester.pumpAndSettle();
    await _openPicker(tester);

    await tester.tap(find.byKey(const ValueKey('levelJamOption_none')));
    await tester.pumpAndSettle();

    expect(calls, <String?>[null]);
    expect(find.byKey(const ValueKey('levelJamDialog')), findsNothing);
  });

  testWidgets('selecting Rap reports jam_rap', (tester) async {
    final calls = <String?>[];
    await tester.pumpWidget(
      _app(locale: 'en', value: null, onChanged: calls.add),
    );
    await tester.pumpAndSettle();
    await _openPicker(tester);

    await tester.tap(find.byKey(const ValueKey('levelJamOption_jam_rap')));
    await tester.pumpAndSettle();

    expect(calls, <String?>['jam_rap']);
    expect(find.byKey(const ValueKey('levelJamDialog')), findsNothing);
  });

  testWidgets('cancelling the LevelJam dialog does not report a value', (
    tester,
  ) async {
    final calls = <String?>[];
    final messages = _messages('en');
    await tester.pumpWidget(
      _app(locale: 'en', value: 'jam_metal', onChanged: calls.add),
    );
    await tester.pumpAndSettle();
    await _openPicker(tester);

    await tester.tap(
      _dialogDescendant(find.text(messages['cancel'] as String)),
    );
    await tester.pumpAndSettle();

    expect(calls, isEmpty);
    expect(find.byKey(const ValueKey('levelJamDialog')), findsNothing);
  });
}
