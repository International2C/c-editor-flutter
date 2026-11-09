import 'dart:convert';

import 'package:c_editor/bloc/settings/settings_cubit.dart';
import 'package:c_editor/data/app_links.dart';
import 'package:c_editor/l10n/app_localizations.dart';
import 'package:c_editor/services/app_update_service.dart';
import 'package:c_editor/widgets/app_update_prompt.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:shared_preferences/shared_preferences.dart';

final _links = AppLinks(
  source: '',
  issues: '',
  pvzDiscordInviteLink: '',
  cEditorInviteLink: 'https://discord.gg/test',
  recommendedLevels: '',
  levelUpload: '',
  releases: 'https://github.com/International2C/c-editor-flutter/releases',
  baiduDownload: 'https://pan.baidu.com/s/test',
  updateBilibili: 'https://www.bilibili.com/opus/test',
);

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  test('web update copy identifies the editor and retains save guidance', () {
    const messages = {
      'zh': '检测到编辑器有新版本。请先保存正在编辑的内容，再刷新页面加载新版。',
      'en':
          'A new version of the editor is available. Save your work, then refresh this page to load it.',
      'ru':
          'Обнаружена новая версия редактора. Сохраните изменения, затем обновите страницу.',
    };
    for (final entry in messages.entries) {
      final l10n = lookupAppLocalizations(Locale(entry.key));
      expect(l10n.webUpdateSaveAndRefresh, entry.value);
    }
  });

  Future<void> pumpApp(
    WidgetTester tester,
    Widget child, {
    String locale = 'en',
  }) async {
    await tester.pumpWidget(
      MaterialApp(
        locale: Locale(locale),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(body: child),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets(
    'update dialog displays version and Chinese-only mirror without overflow',
    (tester) async {
      tester.view.physicalSize = const Size(320, 700);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      for (final locale in ['zh', 'en', 'ru']) {
        final l10n = lookupAppLocalizations(Locale(locale));
        await pumpApp(
          tester,
          AppUpdateDialog(links: _links, version: '2.3.4'),
          locale: locale,
        );
        expect(find.textContaining('2.3.4'), findsOneWidget);
        expect(
          find.byKey(const ValueKey('appUpdateDownloadGithub')),
          findsOneWidget,
        );
        expect(find.text(l10n.updateGithubDownload), findsOneWidget);
        expect(
          find.byKey(const ValueKey('appUpdateDownloadBaidu')),
          locale == 'zh' ? findsOneWidget : findsNothing,
        );
        expect(tester.takeException(), isNull);
        expect(find.byKey(const ValueKey('appUpdateBilibili')), findsNothing);
        expect(find.byKey(const ValueKey('appUpdateDiscord')), findsNothing);
      }
    },
  );

  testWidgets(
    'manual check reports localized rate limit and offers download links',
    (tester) async {
      final prefs = await SharedPreferences.getInstance();
      final service = AppUpdateService(
        client: MockClient(
          (_) async => http.Response('private raw server body', 403),
        ),
        preferences: () async => prefs,
        currentVersion: () async => '1.0.0',
        releasesApi: () async =>
            Uri.parse('https://api.github.com/releases/latest'),
      );
      addTearDown(service.close);
      await pumpApp(
        tester,
        Builder(
          builder: (context) => TextButton(
            onPressed: () => checkForAppUpdates(context, service: service),
            child: const Text('Check'),
          ),
        ),
        locale: 'zh',
      );
      await tester.tap(find.text('Check'));
      await tester.pumpAndSettle();
      expect(find.text('更新检测失败'), findsOneWidget);
      expect(find.textContaining('请求次数已达上限'), findsOneWidget);
      expect(find.textContaining('private raw'), findsNothing);
      expect(
        find.byKey(const ValueKey('appUpdateDownloadBaidu')),
        findsOneWidget,
      );
    },
  );

  testWidgets(
    'failure only shows localized fallback links without update guidance',
    (tester) async {
      tester.view.physicalSize = const Size(320, 900);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      for (final locale in ['zh', 'en', 'ru']) {
        final l10n = lookupAppLocalizations(Locale(locale));
        await pumpApp(
          tester,
          AppUpdateDialog(
            links: _links,
            errorMessage: l10n.networkConnectionAdvice,
          ),
          locale: locale,
        );
        expect(find.text(l10n.updateCheckFailedLinks), findsOneWidget);
        expect(find.text(l10n.updateSaveWorkGuidance), findsNothing);
        expect(find.text(l10n.updateDownload), findsNothing);
        expect(find.text(l10n.updateDownloadDescription), findsNothing);
        expect(
          find.byKey(const ValueKey('appUpdateBilibili')),
          locale == 'zh' ? findsOneWidget : findsNothing,
        );
        expect(
          find.byKey(const ValueKey('appUpdateDiscord')),
          locale == 'zh' ? findsNothing : findsOneWidget,
        );
        expect(tester.takeException(), isNull);
      }
    },
  );

  testWidgets('manual up-to-date result has its own title', (tester) async {
    final prefs = await SharedPreferences.getInstance();
    final service = AppUpdateService(
      client: MockClient(
        (_) async => http.Response(
          jsonEncode({
            'tag_name': '1.0.0',
            'html_url': 'https://github.com/releases/1.0.0',
            'draft': false,
            'prerelease': false,
          }),
          200,
        ),
      ),
      preferences: () async => prefs,
      currentVersion: () async => '1.0.0',
      releasesApi: () async =>
          Uri.parse('https://api.github.com/releases/latest'),
    );
    addTearDown(service.close);
    await pumpApp(
      tester,
      Builder(
        builder: (context) => TextButton(
          onPressed: () => checkForAppUpdates(context, service: service),
          child: const Text('Check'),
        ),
      ),
      locale: 'zh',
    );
    await tester.tap(find.text('Check'));
    await tester.pumpAndSettle();
    expect(find.text('无需更新'), findsOneWidget);
    expect(find.text('当前已是最新正式版。'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'automatic failures stay silent and disabled setting makes no request',
    (tester) async {
      final prefs = await SharedPreferences.getInstance();
      final settings = SettingsCubit(prefs);
      addTearDown(settings.close);
      var requests = 0;
      final service = AppUpdateService(
        client: MockClient((_) async {
          requests++;
          throw http.ClientException('offline');
        }),
        preferences: () async => prefs,
        currentVersion: () async => '1.0.0',
        releasesApi: () async =>
            Uri.parse('https://api.github.com/releases/latest'),
      );
      addTearDown(service.close);
      settings.setCheckForUpdates(false);
      await pumpApp(
        tester,
        BlocProvider.value(
          value: settings,
          child: AutomaticAppUpdateCheck(
            service: service,
            child: const Text('Workspace'),
          ),
        ),
      );
      expect(requests, 0);
      settings.setCheckForUpdates(true);
      await tester.pumpAndSettle();
      expect(requests, 1);
      expect(find.byType(AlertDialog), findsNothing);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'later reminder suppresses cached automatic prompts but not manual check',
    (tester) async {
      final prefs = await SharedPreferences.getInstance();
      final settings = SettingsCubit(prefs);
      addTearDown(settings.close);
      var requests = 0;
      final service = AppUpdateService(
        client: MockClient((_) async {
          requests++;
          return http.Response(
            jsonEncode({
              'draft': false,
              'prerelease': false,
              'tag_name': 'v2.0.0',
              'html_url':
                  'https://github.com/International2C/c-editor-flutter/releases/tag/v2.0.0',
            }),
            200,
          );
        }),
        preferences: () async => prefs,
        currentVersion: () async => '1.0.0',
        releasesApi: () async =>
            Uri.parse('https://api.github.com/releases/latest'),
      );
      addTearDown(service.close);
      await pumpApp(
        tester,
        BlocProvider.value(
          value: settings,
          child: Builder(
            builder: (context) => Column(
              children: [
                TextButton(
                  onPressed: () => checkForAppUpdates(
                    context,
                    service: service,
                    automatic: true,
                  ),
                  child: const Text('Auto'),
                ),
                TextButton(
                  onPressed: () =>
                      checkForAppUpdates(context, service: service),
                  child: const Text('Manual'),
                ),
              ],
            ),
          ),
        ),
      );
      await tester.tap(find.text('Auto'));
      await tester.pumpAndSettle();
      expect(find.textContaining('2.0.0'), findsOneWidget);
      await tester.tap(find.text('Remind me later'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Auto'));
      await tester.pumpAndSettle();
      expect(requests, 1);
      expect(find.byType(AlertDialog), findsNothing);
      await tester.tap(find.text('Manual'));
      await tester.pumpAndSettle();
      expect(requests, 2);
      expect(find.textContaining('2.0.0'), findsOneWidget);
    },
  );
}
