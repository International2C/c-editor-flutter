import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Supported image extensions: png, jpg, gif (gif files play animation).
const List<String> kImageExtensions = [
  '.gif',
  '.png',
  '.jpg',
  '.jpeg',
  '.webp',
  '.bmp',
];

String canonicalImageAssetPath(String assetPath) =>
    assetPath == 'assets/images/round_icons/Stage_Autumn.webp'
    ? 'assets/images/round_icons/Stage_AutumnLate.webp'
    : assetPath;

/// Display-only trims for the original 390×390 armor sprites. Keep all
/// nontransparent pixels (including the sword, feet, and faint shadow).
Rect? livingArmorDisplayCrop(String assetPath) {
  if (assetPath == 'assets/images/griditems/living_armor_left.webp') {
    return const Rect.fromLTWH(114, 40, 172, 346);
  }
  if (assetPath == 'assets/images/griditems/living_armor_right.webp') {
    return const Rect.fromLTWH(104, 40, 172, 342);
  }
  return null;
}

/// Returns alternate asset paths for fallback when primary path fails.
/// Prefers .gif first so animated icons display correctly.
List<String> imageAltCandidates(String assetPath) {
  assetPath = canonicalImageAssetPath(assetPath);
  final idx = assetPath.lastIndexOf('.');
  final base = idx == -1 ? assetPath : assetPath.substring(0, idx);
  final currentExt = idx == -1 ? '' : assetPath.substring(idx).toLowerCase();
  return kImageExtensions
      .where((e) => e != currentExt)
      .map((e) => '$base$e')
      .toList();
}

/// Loads and displays images from assets. Ported from Z-Editor-master AssetImage.kt
/// GIF files play animation automatically via Flutter's Image.asset.
class AssetImageWidget extends StatefulWidget {
  const AssetImageWidget({
    super.key,
    required this.assetPath,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.errorWidget,
    this.altCandidates,
    this.cacheWidth,
    this.cacheHeight,
  });

  /// Path relative to assets folder, e.g. 'images/round_icons/Stage_Modern.png'
  final String assetPath;
  final double? width;
  final double? height;
  final BoxFit fit;
  final Widget? errorWidget;

  /// Alternative asset paths to try if [assetPath] is not found.
  /// Useful for multi-extension fallback (e.g., .gif, .png, .jpg).
  final List<String>? altCandidates;

  final int? cacheWidth;
  final int? cacheHeight;

  static bool _preloadComplete = false;
  static final Set<String> _manifestPaths = {};
  static final Map<String, String?> _pathCache = {};

  static bool get isPreloadComplete => _preloadComplete;

  static void registerManifestPath(String path) {
    _manifestPaths.add(path);
  }

  static void markPreloadComplete() {
    _preloadComplete = true;
  }

  static String? resolvePath(String assetPath, [List<String>? altCandidates]) {
    final cacheKey = '$assetPath|${altCandidates?.join(",") ?? ""}';
    if (_pathCache.containsKey(cacheKey)) {
      return _pathCache[cacheKey];
    }

    final candidates = <String>[
      assetPath,
      ...?altCandidates,
    ].map(canonicalImageAssetPath);
    if (_preloadComplete) {
      for (final path in candidates) {
        if (_manifestPaths.contains(path)) {
          _pathCache[cacheKey] = path;
          return path;
        }
      }
      _pathCache[cacheKey] = null;
      return null;
    }

    return null;
  }

  @override
  State<AssetImageWidget> createState() => _AssetImageWidgetState();
}

class _AssetImageWidgetState extends State<AssetImageWidget> {
  String? _resolvedPath;
  bool _resolving = false;
  int _requestId = 0;

  @override
  void initState() {
    super.initState();
    _resolveAsset();
  }

  @override
  void didUpdateWidget(covariant AssetImageWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.assetPath != widget.assetPath ||
        oldWidget.altCandidates != widget.altCandidates) {
      _resolveAsset();
    }
  }

  Future<void> _resolveAsset() async {
    final cacheKey = '${widget.assetPath}|${widget.altCandidates?.join(",")}';
    final cached = AssetImageWidget.resolvePath(
      widget.assetPath,
      widget.altCandidates,
    );
    if (cached != null || AssetImageWidget._pathCache.containsKey(cacheKey)) {
      if (mounted) {
        setState(() {
          _resolvedPath = cached;
          _resolving = false;
        });
      }
      return;
    }

    if (AssetImageWidget.isPreloadComplete) {
      if (mounted) {
        setState(() {
          _resolvedPath = null;
          _resolving = false;
        });
      }
      return;
    }

    final currentId = ++_requestId;
    if (mounted) {
      setState(() {
        _resolving = true;
        _resolvedPath = null;
      });
    }
    final candidates = <String>[
      widget.assetPath,
      ...?widget.altCandidates,
    ].map(canonicalImageAssetPath);
    for (final path in candidates) {
      try {
        await rootBundle.load(path);
        if (!mounted || currentId != _requestId) return;

        AssetImageWidget._pathCache[cacheKey] = path;
        setState(() {
          _resolvedPath = path;
          _resolving = false;
        });
        return;
      } catch (_) {
        // try next
      }
    }

    if (!mounted || currentId != _requestId) return;

    AssetImageWidget._pathCache[cacheKey] = null;
    setState(() {
      _resolving = false;
      _resolvedPath = null;
    });
  }

  static const String _unknownIconPath = 'assets/images/others/unknown.webp';

  @override
  Widget build(BuildContext context) {
    final placeholder =
        widget.errorWidget ??
        Image.asset(
          _unknownIconPath,
          width: widget.width,
          height: widget.height,
          fit: widget.fit,
          errorBuilder: (_, _, _) => Icon(
            Icons.image_not_supported,
            size: widget.width ?? widget.height ?? 48,
            color: Theme.of(context).colorScheme.outline,
          ),
        );
    if (_resolving) {
      return SizedBox(
        width: widget.width,
        height: widget.height,
        child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
      );
    }
    if (_resolvedPath == null) {
      return placeholder;
    }
    final crop = livingArmorDisplayCrop(_resolvedPath!);
    if (crop != null) {
      return SizedBox(
        width: widget.width,
        height: widget.height,
        child: FittedBox(
          fit: BoxFit.contain,
          child: SizedBox(
            width: crop.width,
            height: crop.height,
            child: ClipRect(
              child: Stack(
                children: [
                  Positioned(
                    left: -crop.left,
                    top: -crop.top,
                    width: 390,
                    height: 390,
                    child: Image.asset(_resolvedPath!, fit: BoxFit.fill),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }
    return Image.asset(
      _resolvedPath!,
      width: widget.width,
      height: widget.height,
      fit: widget.fit,
      cacheWidth: widget.cacheWidth,
      cacheHeight: widget.cacheHeight,
    );
  }
}
