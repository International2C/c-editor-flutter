import 'dart:convert';

import 'package:c_editor/data/asset_loader.dart';

/// External URLs loaded from [assetPath] (editable without recompiling).
class AppLinks {
  AppLinks({
    required this.source,
    required this.issues,
    required this.pvzDiscordInviteLink,
    required this.cEditorInviteLink,
    required this.recommendedLevels,
    required this.levelUpload,
    this.releasesApi = '',
    this.releases = '',
    this.baiduDownload = '',
    this.updateBilibili = '',
  });

  static const assetPath = 'assets/meta/links.json';

  final String source;
  final String issues;
  final String pvzDiscordInviteLink;
  final String cEditorInviteLink;
  final String recommendedLevels;
  final String levelUpload;
  final String releasesApi;
  final String releases;
  final String baiduDownload;
  final String updateBilibili;

  static AppLinks? _cached;

  static Future<AppLinks> load() async {
    if (_cached != null) return _cached!;
    final raw =
        json.decode(await loadJsonString(assetPath)) as Map<String, dynamic>;
    _cached = AppLinks(
      source: raw['source'] as String,
      issues: raw['issues'] as String,
      pvzDiscordInviteLink: raw['PvZDiscordInviteLink'] as String,
      cEditorInviteLink: raw['CEditorInviteLink'] as String,
      recommendedLevels:
          (raw['recommendedLevels'] ?? raw['levelPlaza']) as String,
      levelUpload: raw['levelUpload'] as String,
      releasesApi: raw['releasesApi'] as String? ?? '',
      releases: raw['releases'] as String? ?? '',
      baiduDownload: raw['baiduDownload'] as String? ?? '',
      updateBilibili: raw['updateBilibili'] as String? ?? '',
    );
    return _cached!;
  }
}
