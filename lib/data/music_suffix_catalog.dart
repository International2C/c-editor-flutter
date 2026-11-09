import 'dart:convert';

import 'package:flutter/widgets.dart';
import 'package:c_editor/data/asset_loader.dart';

/// PVZ2 `MusicSuffix` codenames and icons for picker UI (`assets/resources/MusicSuffixes.json`).
class MusicSuffixCatalog {
  MusicSuffixCatalog._();

  static const String unknownIconAsset = 'assets/images/others/unknown.webp';
  static const String _resourcePath = 'assets/resources/MusicSuffixes.json';

  static final List<String> _orderedCodenames = [];
  static final Map<String, String> _iconFilenameByCodename = {};
  static String _iconFolder = 'assets/images/round_icons/';
  static bool _isLoaded = false;

  /// Display order. Empty/default suffix is deliberately not selectable.
  static List<String> get orderedCodes => List.unmodifiable(_orderedCodenames);

  static Future<void> init() async {
    if (_isLoaded) return;
    try {
      final raw =
          json.decode(await loadJsonString(_resourcePath))
              as Map<String, dynamic>;
      final folder = raw['iconFolder'] as String?;
      if (folder != null && folder.isNotEmpty) {
        final f = folder.endsWith('/') ? folder : '$folder/';
        _iconFolder = f;
      }
      final order = raw['orderedCodenames'] as List<dynamic>? ?? [];
      final icons = raw['iconFiles'] as Map<String, dynamic>? ?? {};
      _orderedCodenames
        ..clear()
        ..addAll(order.map((e) => '$e'));
      _iconFilenameByCodename.clear();
      icons.forEach((k, v) {
        _iconFilenameByCodename[k] = '$v';
      });
      _isLoaded = true;
    } catch (e) {
      debugPrint('MusicSuffixCatalog: failed to load $e — using empty catalog');
      _orderedCodenames.clear();
      _iconFilenameByCodename.clear();
      _isLoaded = true;
    }
  }

  /// Returns the guide-canonical casing for a known suffix while continuing to
  /// recognize levels saved with older casing.
  static String canonicalCode(String code) {
    final trimmed = code.trim();
    if (trimmed.isEmpty) return '';
    final normalized = trimmed.toLowerCase();
    for (final candidate in _orderedCodenames) {
      if (candidate.toLowerCase() == normalized) return candidate;
    }
    return trimmed;
  }

  static String resourceKey(String code) {
    final canonical = canonicalCode(code);
    return canonical.isEmpty ? '' : 'musicSuffix_$canonical';
  }

  /// Full asset path for tile icon (`unknown` uses [unknownIconAsset]).
  static String iconAsset(String codename) {
    final canonical = canonicalCode(codename);
    if (canonical.isEmpty) return unknownIconAsset;
    final file = _iconFilenameByCodename[canonical];
    if (file == null || file.isEmpty) return unknownIconAsset;
    return '$_iconFolder$file';
  }
}
