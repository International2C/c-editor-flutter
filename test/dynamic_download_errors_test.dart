import 'dart:async';
import 'dart:io';

import 'package:c_editor/bundled_plugins/level_test_cplugin/lib/src/download.dart';
import 'package:c_editor/bundled_plugins/level_test_cplugin/lib/src/releases_api.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

void main() {
  test('GitHub rate limits are distinct from ordinary access denial', () async {
    for (final response in [
      http.Response(
        '{"message":"API rate limit exceeded for PRIVATE_IP"}',
        403,
      ),
      http.Response('', 403, headers: {'x-ratelimit-remaining': '0'}),
      http.Response('', 429),
    ]) {
      final releases = Pvz2cDynamicReleases(
        client: MockClient((_) async => response),
      );
      addTearDown(releases.close);
      await expectLater(
        releases.list(),
        throwsA(
          isA<DynamicReleaseRequestException>()
              .having(
                (e) => classifyDownloadError(e),
                'kind',
                DownloadErrorKind.rateLimited,
              )
              .having(
                (e) => '$e',
                'safe diagnostics',
                isNot(contains('PRIVATE_IP')),
              ),
        ),
      );
    }

    final forbidden = Pvz2cDynamicReleases(
      client: MockClient((_) async => http.Response('Forbidden', 403)),
    );
    addTearDown(forbidden.close);
    await expectLater(
      forbidden.list(),
      throwsA(
        predicate<Object>(
          (error) =>
              classifyDownloadError(error) == DownloadErrorKind.accessDenied,
        ),
      ),
    );
  });

  test('invalid release payloads become readable response errors', () async {
    for (final body in ['<html>Network portal</html>', '{}']) {
      final releases = Pvz2cDynamicReleases(
        client: MockClient((_) async => http.Response(body, 200)),
      );
      addTearDown(releases.close);
      await expectLater(
        releases.list(),
        throwsA(
          predicate<Object>(
            (error) =>
                classifyDownloadError(error) ==
                DownloadErrorKind.invalidResponse,
          ),
        ),
      );
    }
  });

  test(
    'timeouts, network failures, and storage failures have distinct advice',
    () {
      expect(
        classifyDownloadError(TimeoutException('slow')),
        DownloadErrorKind.timeout,
      );
      expect(
        classifyDownloadError(http.ClientException('Failed to fetch')),
        DownloadErrorKind.noConnection,
      );
      expect(
        classifyDownloadError(const FileSystemException('Permission denied')),
        DownloadErrorKind.storage,
      );
      expect(
        classifyDownloadError(DownloadCanceledException()),
        DownloadErrorKind.canceled,
      );
    },
  );
}
