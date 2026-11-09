import 'dart:async';
import 'dart:convert';

import 'package:c_editor/data/app_links.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:pub_semver/pub_semver.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum AppUpdateErrorKind {
  network,
  timeout,
  rateLimited,
  unavailable,
  invalidResponse,
  unknown,
}

/// A machine-readable failure. The UI supplies localized explanations/advice.
class AppUpdateException implements Exception {
  const AppUpdateException(this.kind, {this.statusCode});

  final AppUpdateErrorKind kind;
  final int? statusCode;

  @override
  String toString() => 'AppUpdateException($kind, statusCode: $statusCode)';
}

class AppUpdateRelease {
  const AppUpdateRelease({required this.version, required this.releaseUrl});

  final String version;
  final Uri releaseUrl;
}

enum AppUpdateCheckStatus { updateAvailable, upToDate, skipped }

class AppUpdateCheckResult {
  const AppUpdateCheckResult({
    required this.status,
    required this.currentVersion,
    this.latestRelease,
    this.fromCache = false,
  });

  final AppUpdateCheckStatus status;
  final String currentVersion;
  final AppUpdateRelease? latestRelease;
  final bool fromCache;
}

/// Checks only the latest stable GitHub release without platform-specific I/O.
///
/// Automatic attempts are persisted before contacting the server, including
/// failed attempts. A successful result remains available during the cooldown
/// so leaving a screen while a check runs does not lose an update notification.
class AppUpdateService {
  AppUpdateService({
    http.Client? client,
    Future<String> Function()? currentVersion,
    Future<SharedPreferences> Function()? preferences,
    Future<Uri> Function()? releasesApi,
    DateTime Function()? now,
    this.timeout = const Duration(seconds: 15),
    this.isWeb = kIsWeb,
    Uri? webBaseUri,
  }) : _client = client ?? http.Client(),
       _currentVersion = currentVersion ?? _loadCurrentVersion,
       _preferences = preferences ?? SharedPreferences.getInstance,
       _releasesApi = releasesApi ?? _loadReleasesApi,
       _now = now ?? DateTime.now,
       _webBaseUri = webBaseUri ?? Uri.base;

  static final instance = AppUpdateService();
  static const automaticCheckInterval = Duration(hours: 24);

  final http.Client _client;
  final Future<String> Function() _currentVersion;
  final Future<SharedPreferences> Function() _preferences;
  final Future<Uri> Function() _releasesApi;
  final DateTime Function() _now;
  final Duration timeout;
  final bool isWeb;
  final Uri _webBaseUri;

  static const _attemptKey = 'app_update_last_attempt_ms';
  static const _releaseKey = 'app_update_last_release';
  Future<AppUpdateCheckResult>? _inFlight;

  /// Manual checks bypass the cooldown; overlapping checks share one request.
  /// Automatic callers should silently ignore [AppUpdateException].
  Future<AppUpdateCheckResult> checkForUpdates({bool automatic = false}) {
    final pending = _inFlight;
    if (pending != null) {
      if (automatic) return pending;
      // A manual click during an automatic cooldown lookup still requests
      // fresh information, while a running HTTP request remains shared.
      return pending.then(
        (result) => result.fromCache ? checkForUpdates() : result,
      );
    }

    late final Future<AppUpdateCheckResult> request;
    request = _check(automatic: automatic).whenComplete(() {
      if (identical(_inFlight, request)) _inFlight = null;
    });
    _inFlight = request;
    return request;
  }

  Future<AppUpdateCheckResult> _check({required bool automatic}) async {
    try {
      final preferences = await _preferences();
      final currentVersion = await _currentVersion();
      final installed = _parseVersion(currentVersion);
      final now = _now().millisecondsSinceEpoch;
      final attemptKey = isWeb ? 'web_$_attemptKey' : _attemptKey;
      final lastAttempt = preferences.getInt(attemptKey);

      if (automatic &&
          lastAttempt != null &&
          now - lastAttempt < automaticCheckInterval.inMilliseconds) {
        final cached = isWeb ? null : _readCachedRelease(preferences);
        return cached == null
            ? AppUpdateCheckResult(
                status: AppUpdateCheckStatus.skipped,
                currentVersion: currentVersion,
                fromCache: true,
              )
            : _compare(cached, installed, currentVersion, fromCache: true);
      }

      // Recording an attempt before networking also throttles timeouts/errors.
      await preferences.setInt(attemptKey, now);
      if (!isWeb) await preferences.remove(_releaseKey);
      final uri = isWeb
          ? _webBaseUri
                .resolve('version.json')
                .replace(queryParameters: {'updateCheck': '$now'})
          : await _releasesApi();
      final response = await _client
          .get(uri, headers: {'Accept': 'application/vnd.github+json'})
          .timeout(timeout);
      if (response.statusCode == 403 || response.statusCode == 429) {
        throw AppUpdateException(
          AppUpdateErrorKind.rateLimited,
          statusCode: response.statusCode,
        );
      }
      if (response.statusCode != 200) {
        throw AppUpdateException(
          AppUpdateErrorKind.unavailable,
          statusCode: response.statusCode,
        );
      }

      final payload = jsonDecode(response.body);
      if (isWeb) {
        if (payload is! Map<String, dynamic> || payload['version'] is! String) {
          throw const FormatException('Expected a web build version');
        }
        return _compare(
          AppUpdateRelease(
            version: payload['version'] as String,
            releaseUrl: _webBaseUri,
          ),
          installed,
          currentVersion,
        );
      }
      final release = _parseRelease(payload);
      await preferences.setString(
        _releaseKey,
        jsonEncode({
          'version': release.version,
          'url': release.releaseUrl.toString(),
        }),
      );
      return _compare(release, installed, currentVersion);
    } on AppUpdateException {
      rethrow;
    } on TimeoutException {
      throw const AppUpdateException(AppUpdateErrorKind.timeout);
    } on http.ClientException {
      throw const AppUpdateException(AppUpdateErrorKind.network);
    } on FormatException {
      throw const AppUpdateException(AppUpdateErrorKind.invalidResponse);
    } catch (_) {
      throw const AppUpdateException(AppUpdateErrorKind.unknown);
    }
  }

  AppUpdateCheckResult _compare(
    AppUpdateRelease release,
    Version installed,
    String currentVersion, {
    bool fromCache = false,
  }) {
    return AppUpdateCheckResult(
      status: _parseVersion(release.version) > installed
          ? AppUpdateCheckStatus.updateAvailable
          : AppUpdateCheckStatus.upToDate,
      currentVersion: currentVersion,
      latestRelease: release,
      fromCache: fromCache,
    );
  }

  AppUpdateRelease _parseRelease(dynamic raw) {
    if (raw is! Map<String, dynamic> ||
        raw['draft'] != false ||
        raw['prerelease'] != false ||
        raw['tag_name'] is! String ||
        raw['html_url'] is! String) {
      throw const FormatException('Expected a stable release');
    }
    return _validatedRelease(
      raw['tag_name'] as String,
      raw['html_url'] as String,
    );
  }

  AppUpdateRelease _validatedRelease(String version, String url) {
    final parsed = _parseVersion(version);
    final releaseUrl = Uri.tryParse(url);
    if (parsed.isPreRelease ||
        releaseUrl == null ||
        releaseUrl.scheme != 'https' ||
        releaseUrl.host != 'github.com' ||
        releaseUrl.userInfo.isNotEmpty ||
        !releaseUrl.path.contains('/releases/')) {
      throw const FormatException('Invalid stable release');
    }
    return AppUpdateRelease(version: parsed.toString(), releaseUrl: releaseUrl);
  }

  AppUpdateRelease? _readCachedRelease(SharedPreferences preferences) {
    try {
      final encoded = preferences.getString(_releaseKey);
      if (encoded == null) return null;
      final raw = jsonDecode(encoded);
      if (raw is! Map<String, dynamic> ||
          raw['version'] is! String ||
          raw['url'] is! String) {
        return null;
      }
      return _validatedRelease(raw['version'] as String, raw['url'] as String);
    } catch (_) {
      return null;
    }
  }

  static Version _parseVersion(String raw) {
    // Flutter build numbers do not identify newer user-facing releases.
    var normalized = raw
        .trim()
        .replaceFirst(RegExp(r'^[vV]'), '')
        .split('+')[0];
    final match = RegExp(
      r'^(\d+)(?:\.(\d+))?(?:\.(\d+))?(-.+)?$',
    ).firstMatch(normalized);
    if (match == null) throw const FormatException('Invalid version');
    normalized =
        '${match[1]}.${match[2] ?? '0'}.${match[3] ?? '0'}${match[4] ?? ''}';
    return Version.parse(normalized);
  }

  static Future<String> _loadCurrentVersion() async =>
      (await PackageInfo.fromPlatform()).version;

  static Future<Uri> _loadReleasesApi() async =>
      Uri.parse((await AppLinks.load()).releasesApi);

  void close() => _client.close();
}
