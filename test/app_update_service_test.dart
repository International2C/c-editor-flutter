import 'dart:async';
import 'dart:convert';

import 'package:c_editor/services/app_update_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  test('web checks the deployed site version instead of GitHub', () async {
    SharedPreferences.setMockInitialValues({});
    final checker = AppUpdateService(
      isWeb: true,
      webBaseUri: Uri.parse('https://example.com/c-editor-flutter/'),
      currentVersion: () async => '1.1.0',
      releasesApi: () async => throw StateError('Must not contact GitHub'),
      client: MockClient((request) async {
        expect(request.url.path, '/c-editor-flutter/version.json');
        expect(request.url.queryParameters, contains('updateCheck'));
        return http.Response('{"version":"1.2.0"}', 200);
      }),
    );
    addTearDown(checker.close);
    expect(
      (await checker.checkForUpdates()).status,
      AppUpdateCheckStatus.updateAvailable,
    );
  });

  late SharedPreferences preferences;
  late DateTime now;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    preferences = await SharedPreferences.getInstance();
    now = DateTime.utc(2026, 10, 17);
  });

  Map<String, Object> releasePayload({
    String version = 'v1.2.0',
    bool draft = false,
    bool prerelease = false,
    String? url,
  }) => {
    'tag_name': version,
    'html_url':
        url ?? 'https://github.com/example/editor/releases/tag/$version',
    'draft': draft,
    'prerelease': prerelease,
  };

  AppUpdateService service(
    Future<http.Response> Function(http.Request) handler, {
    String installed = '1.1.0',
    Duration timeout = const Duration(seconds: 15),
  }) {
    final result = AppUpdateService(
      client: MockClient(handler),
      preferences: () async => preferences,
      currentVersion: () async => installed,
      releasesApi: () async => Uri.parse('https://example.com/releases/latest'),
      now: () => now,
      timeout: timeout,
    );
    addTearDown(result.close);
    return result;
  }

  TypeMatcher<AppUpdateException> failure(AppUpdateErrorKind kind) =>
      isA<AppUpdateException>().having((error) => error.kind, 'kind', kind);

  test('compares numeric versions and ignores Flutter build numbers', () async {
    for (final entry in [
      ('1.9.0', 'v1.10.0', AppUpdateCheckStatus.updateAvailable),
      ('1.10.0+24', 'v1.10.0+25', AppUpdateCheckStatus.upToDate),
      ('1.10.0', '1.9.9', AppUpdateCheckStatus.upToDate),
      ('1.10.0-beta.1', 'v1.10.0', AppUpdateCheckStatus.updateAvailable),
      ('1.1', 'v1.2', AppUpdateCheckStatus.updateAvailable),
    ]) {
      final checker = service(
        (_) async =>
            http.Response(jsonEncode(releasePayload(version: entry.$2)), 200),
        installed: entry.$1,
      );
      final result = await checker.checkForUpdates();
      expect(result.status, entry.$3, reason: '${entry.$1} -> ${entry.$2}');
      expect(result.currentVersion, entry.$1);
      expect(result.latestRelease, isNotNull);
    }
  });

  test(
    'automatic checks cache success across service instances for 24h',
    () async {
      var requests = 0;
      Future<http.Response> handler(http.Request request) async {
        requests++;
        expect(request.url.toString(), 'https://example.com/releases/latest');
        return http.Response(jsonEncode(releasePayload()), 200);
      }

      final initial = await service(handler).checkForUpdates(automatic: true);
      expect(initial.status, AppUpdateCheckStatus.updateAvailable);
      expect(initial.fromCache, isFalse);

      now = now.add(const Duration(hours: 23, minutes: 59));
      final cached = await service(handler).checkForUpdates(automatic: true);
      expect(cached.status, AppUpdateCheckStatus.updateAvailable);
      expect(cached.latestRelease!.version, '1.2.0');
      expect(cached.fromCache, isTrue);
      expect(requests, 1);

      // A newly installed version is compared again even while using the cache.
      final upgraded = await service(
        handler,
        installed: '1.2.0',
      ).checkForUpdates(automatic: true);
      expect(upgraded.status, AppUpdateCheckStatus.upToDate);
      expect(requests, 1);

      now = now.add(const Duration(minutes: 1));
      await service(handler).checkForUpdates(automatic: true);
      expect(requests, 2);
    },
  );

  test(
    'failed automatic attempts are throttled but manual checks bypass',
    () async {
      var requests = 0;
      final checker = service((_) async {
        requests++;
        if (requests == 1) return http.Response('rate limited', 403);
        return http.Response(jsonEncode(releasePayload()), 200);
      });

      await expectLater(
        checker.checkForUpdates(automatic: true),
        throwsA(failure(AppUpdateErrorKind.rateLimited)),
      );
      final skipped = await checker.checkForUpdates(automatic: true);
      expect(skipped.status, AppUpdateCheckStatus.skipped);
      expect(skipped.latestRelease, isNull);
      expect(requests, 1);

      final manual = await checker.checkForUpdates();
      expect(manual.status, AppUpdateCheckStatus.updateAvailable);
      expect(requests, 2);
    },
  );

  test('simultaneous automatic and manual checks share one request', () async {
    final response = Completer<http.Response>();
    var requests = 0;
    final checker = service((_) {
      requests++;
      return response.future;
    });
    final automatic = checker.checkForUpdates(automatic: true);
    final manual = checker.checkForUpdates();
    response.complete(http.Response(jsonEncode(releasePayload()), 200));
    final results = await Future.wait([automatic, manual]);
    expect(results.map((result) => result.status), [
      AppUpdateCheckStatus.updateAvailable,
      AppUpdateCheckStatus.updateAvailable,
    ]);
    expect(requests, 1);
  });

  test(
    'manual check also bypasses an overlapping automatic cache lookup',
    () async {
      var requests = 0;
      final checker = service((_) async {
        requests++;
        return http.Response(jsonEncode(releasePayload()), 200);
      });
      await checker.checkForUpdates(automatic: true);
      final automatic = checker.checkForUpdates(automatic: true);
      final manual = checker.checkForUpdates();
      expect((await automatic).fromCache, isTrue);
      expect((await manual).fromCache, isFalse);
      expect(requests, 2);
    },
  );

  test('rejects draft, prerelease and malformed release responses', () async {
    for (final payload in [
      releasePayload(draft: true),
      releasePayload(prerelease: true),
      releasePayload(version: 'v1.3.0-beta.1'),
      releasePayload(version: 'not-a-version'),
      releasePayload(url: 'https://github.com.example.com/releases/tag/v1.2.0'),
      releasePayload(
        url: 'http://github.com/example/editor/releases/tag/v1.2.0',
      ),
      <String, dynamic>{'tag_name': 'v1.2.0'},
      <dynamic>[],
    ]) {
      final checker = service(
        (_) async => http.Response(jsonEncode(payload), 200),
      );
      await expectLater(
        checker.checkForUpdates(),
        throwsA(failure(AppUpdateErrorKind.invalidResponse)),
        reason: '$payload',
      );
    }
    await expectLater(
      service((_) async => http.Response('not JSON', 200)).checkForUpdates(),
      throwsA(failure(AppUpdateErrorKind.invalidResponse)),
    );
  });

  test('returns typed HTTP, connection and timeout failures', () async {
    for (final status in [403, 429, 404, 500]) {
      final checker = service((_) async => http.Response('error', status));
      await expectLater(
        checker.checkForUpdates(),
        throwsA(
          failure(
            status == 403 || status == 429
                ? AppUpdateErrorKind.rateLimited
                : AppUpdateErrorKind.unavailable,
          ).having((error) => error.statusCode, 'statusCode', status),
        ),
      );
    }
    await expectLater(
      service(
        (_) async => throw http.ClientException('unreachable'),
      ).checkForUpdates(),
      throwsA(failure(AppUpdateErrorKind.network)),
    );
    await expectLater(
      service(
        (_) => Completer<http.Response>().future,
        timeout: const Duration(milliseconds: 1),
      ).checkForUpdates(),
      throwsA(failure(AppUpdateErrorKind.timeout)),
    );
  });

  test(
    'new failed attempt does not expose an older successful cache',
    () async {
      var requests = 0;
      final checker = service((_) async {
        requests++;
        if (requests == 1) {
          return http.Response(jsonEncode(releasePayload()), 200);
        }
        return http.Response('unavailable', 500);
      });
      await checker.checkForUpdates(automatic: true);
      now = now.add(const Duration(hours: 24));
      await expectLater(
        checker.checkForUpdates(automatic: true),
        throwsA(failure(AppUpdateErrorKind.unavailable)),
      );
      expect(
        (await checker.checkForUpdates(automatic: true)).status,
        AppUpdateCheckStatus.skipped,
      );
      expect(requests, 2);
    },
  );
}
