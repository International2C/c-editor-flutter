import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:c_editor/data/bootstrap_loading_category.dart';
import 'package:c_editor/widgets/asset_image.dart';

typedef AssetPreloadProgressCallback =
    void Function(double progress, BootstrapLoadingCategory? category);

/// Preloads image assets listed in the Flutter asset manifest.
abstract final class AssetImagePreloader {
  static bool _complete = false;

  static int get _parallelism => kIsWeb ? 8 : 12;

  static bool get isComplete => _complete;

  static Future<void> preloadAll({
    AssetPreloadProgressCallback? onProgress,
  }) async {
    if (_complete) return;

    final manifest = await AssetManifest.loadFromAssetBundle(rootBundle);
    final assets =
        manifest.listAssets().where(_isImageAsset).toList(growable: false)
          ..sort();

    if (assets.isEmpty) {
      _complete = true;
      AssetImageWidget.markPreloadComplete();
      onProgress?.call(1, null);
      return;
    }

    onProgress?.call(0, BootstrapLoadingCategory.images);

    await _preloadInParallel(assets, onProgress);

    _complete = true;
    AssetImageWidget.markPreloadComplete();
    onProgress?.call(1, null);
  }

  static Future<void> _preloadInParallel(
    List<String> assets,
    AssetPreloadProgressCallback? onProgress,
  ) async {
    final total = assets.length;
    var nextIndex = 0;
    var completed = 0;

    Future<void> worker() async {
      while (true) {
        final index = nextIndex++;
        if (index >= total) return;

        final path = assets[index];
        // Manifest membership must not depend on a successful preload request.
        AssetImageWidget.registerManifestPath(path);
        try {
          await rootBundle.load(path).timeout(const Duration(seconds: 20));
        } catch (error) {
          // Preloading is optional; Image.asset can retry when displayed.
          debugPrint('Image preload skipped: $path ($error)');
        }
        completed++;
        onProgress?.call(completed / total, BootstrapLoadingCategory.images);
      }
    }

    final workerCount = math.min(_parallelism, total);
    await Future.wait(List.generate(workerCount, (_) => worker()));
  }

  static bool _isImageAsset(String path) {
    if (!path.startsWith('assets/')) return false;
    final lower = path.toLowerCase();
    return lower.endsWith('.png') ||
        lower.endsWith('.jpg') ||
        lower.endsWith('.jpeg') ||
        lower.endsWith('.webp') ||
        lower.endsWith('.gif');
  }
}
