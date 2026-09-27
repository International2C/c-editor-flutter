import 'package:flutter/material.dart';
import 'package:c_editor/widgets/asset_image.dart'
    show AssetImageWidget, imageAltCandidates;
import 'package:c_editor/widgets/editor_components.dart' show isDesktopPlatform;

String waveGeneratorRowDisplay(String? row) {
  if (row == null || row.isEmpty || row == '?') return '?';
  return row;
}

/// Layout variant for [WaveGeneratorZombieTile].
enum WaveGeneratorZombieTileStyle {
  /// Horizontal card with optional row badge (default).
  horizontal,

  /// Smaller icon, no row badge — for AddToZombiePool lists.
  poolCompact,

  /// Icon on top, centered names, optional row badge — waves tab fixed list.
  centered,

  /// Compact card with G/W pool source badge — waves tab random pool.
  poolSourceBadge,
}

double waveGeneratorZombieIconSize(
  BuildContext context, {
  WaveGeneratorZombieTileStyle style = WaveGeneratorZombieTileStyle.horizontal,
}) {
  final width = MediaQuery.sizeOf(context).width;
  switch (style) {
    case WaveGeneratorZombieTileStyle.poolCompact:
    case WaveGeneratorZombieTileStyle.poolSourceBadge:
      return isDesktopPlatform(context) ? 40 : 36;
    case WaveGeneratorZombieTileStyle.centered:
      if (isDesktopPlatform(context)) {
        return width >= 900 ? 56 : 50;
      }
      return width >= 400 ? 50 : 44;
    case WaveGeneratorZombieTileStyle.horizontal:
      if (isDesktopPlatform(context)) {
        return width >= 900 ? 64 : 56;
      }
      return width >= 400 ? 56 : 50;
  }
}

double? waveGeneratorZombieCardWidth(
  BuildContext context, {
  WaveGeneratorZombieTileStyle style = WaveGeneratorZombieTileStyle.horizontal,
}) {
  final width = MediaQuery.sizeOf(context).width;
  switch (style) {
    case WaveGeneratorZombieTileStyle.poolCompact:
    case WaveGeneratorZombieTileStyle.poolSourceBadge:
      return null;
    case WaveGeneratorZombieTileStyle.centered:
      return isDesktopPlatform(context) ? 120 : 108;
    case WaveGeneratorZombieTileStyle.horizontal:
      if (isDesktopPlatform(context)) {
        return width >= 1200 ? 300 : 280;
      }
      return width >= 400 ? 260 : 240;
  }
}

Color waveGeneratorGlobalPoolBadgeColor(ThemeData theme) =>
    const Color(0xFF4FC3F7);

Color waveGeneratorWavePoolBadgeColor(ThemeData theme) =>
    const Color(0xFF43A047);

Color waveGeneratorGlobalPoolBadgeForeground(ThemeData theme) => Colors.white;

Color waveGeneratorWavePoolBadgeForeground(ThemeData theme) => Colors.white;

/// Zombie card for wave generator lists: icon, localized name, codename, badges.
class WaveGeneratorZombieTile extends StatelessWidget {
  const WaveGeneratorZombieTile({
    super.key,
    required this.localizedName,
    required this.codename,
    required this.iconPath,
    this.rowLabel,
    this.sourceBadge,
    this.style = WaveGeneratorZombieTileStyle.horizontal,
    this.onTap,
    this.onDelete,
    this.selected = false,
    this.fitContent = false,
  });

  final String localizedName;
  final String codename;
  final String? iconPath;
  final String? rowLabel;
  final String? sourceBadge;
  final WaveGeneratorZombieTileStyle style;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;
  final bool selected;
  final bool fitContent;

  @override
  Widget build(BuildContext context) {
    switch (style) {
      case WaveGeneratorZombieTileStyle.centered:
        return _buildCentered(context);
      case WaveGeneratorZombieTileStyle.poolCompact:
      case WaveGeneratorZombieTileStyle.poolSourceBadge:
        return _buildCompact(context);
      case WaveGeneratorZombieTileStyle.horizontal:
        return _buildHorizontal(context);
    }
  }

  Widget _buildIcon(
    BuildContext context, {
    required double iconSize,
    String? badge,
    Color? badgeColor,
    Color? badgeForeground,
  }) {
    final theme = Theme.of(context);
    return Stack(
      clipBehavior: Clip.none,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: iconPath != null && iconPath!.isNotEmpty
              ? AssetImageWidget(
                  assetPath: iconPath!,
                  altCandidates: imageAltCandidates(iconPath!),
                  width: iconSize,
                  height: iconSize,
                  fit: BoxFit.cover,
                )
              : Container(
                  width: iconSize,
                  height: iconSize,
                  color: theme.colorScheme.surface,
                  child: Icon(
                    Icons.person_outline,
                    size: iconSize * 0.5,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
        ),
        if (badge != null && badge.isNotEmpty)
          Positioned(
            top: -6,
            right: -6,
            child: _BadgeLabel(
              label: badge,
              background: badgeColor ?? theme.colorScheme.primary,
              foreground: badgeForeground ?? theme.colorScheme.onPrimary,
            ),
          ),
      ],
    );
  }

  Widget _buildHorizontal(BuildContext context) {
    final theme = Theme.of(context);
    final iconSize = waveGeneratorZombieIconSize(context);
    final isDesktop = isDesktopPlatform(context);
    final cardWidth = fitContent
        ? null
        : waveGeneratorZombieCardWidth(context)!;
    final showRowBadge = rowLabel != null;

    return Material(
      color: selected
          ? theme.colorScheme.primaryContainer
          : theme.colorScheme.surfaceContainerHighest,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          width: cardWidth,
          constraints: fitContent ? const BoxConstraints(maxWidth: 420) : null,
          padding: EdgeInsets.all(isDesktop ? 12 : 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: selected
                  ? theme.colorScheme.primary
                  : theme.colorScheme.outline.withValues(alpha: 0.45),
              width: selected ? 2 : 1,
            ),
          ),
          child: Row(
            mainAxisSize: fitContent ? MainAxisSize.min : MainAxisSize.max,
            crossAxisAlignment: fitContent
                ? CrossAxisAlignment.center
                : CrossAxisAlignment.start,
            children: [
              _buildIcon(
                context,
                iconSize: iconSize,
                badge: showRowBadge ? rowLabel : null,
                badgeColor: rowLabel == '?'
                    ? theme.colorScheme.secondaryContainer
                    : theme.colorScheme.primary,
                badgeForeground: rowLabel == '?'
                    ? theme.colorScheme.onSecondaryContainer
                    : theme.colorScheme.onPrimary,
              ),
              const SizedBox(width: 10),
              if (fitContent)
                _NameColumn(
                  localizedName: localizedName,
                  codename: codename,
                  align: CrossAxisAlignment.start,
                  fitContent: true,
                  nameStyle: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    height: 1.2,
                    fontSize: isDesktop ? 14 : 13,
                  ),
                  codenameStyle: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                    fontSize: 11,
                  ),
                )
              else
                Expanded(
                  child: _NameColumn(
                    localizedName: localizedName,
                    codename: codename,
                    align: CrossAxisAlignment.start,
                    nameStyle: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      height: 1.2,
                      fontSize: isDesktop ? 14 : 13,
                    ),
                    codenameStyle: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                      fontSize: 11,
                    ),
                  ),
                ),
              if (onDelete != null) _DeleteButton(onDelete: onDelete!),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCentered(BuildContext context) {
    final theme = Theme.of(context);
    final iconSize = waveGeneratorZombieIconSize(context, style: style);
    final isDesktop = isDesktopPlatform(context);
    final cardWidth = waveGeneratorZombieCardWidth(context, style: style)!;
    final showRowBadge = rowLabel != null;

    return Material(
      color: theme.colorScheme.surfaceContainerHighest,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          width: cardWidth,
          padding: EdgeInsets.all(isDesktop ? 10 : 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: theme.colorScheme.outline.withValues(alpha: 0.45),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildIcon(
                context,
                iconSize: iconSize,
                badge: showRowBadge ? rowLabel : null,
                badgeColor: rowLabel == '?'
                    ? theme.colorScheme.secondaryContainer
                    : theme.colorScheme.primary,
                badgeForeground: rowLabel == '?'
                    ? theme.colorScheme.onSecondaryContainer
                    : theme.colorScheme.onPrimary,
              ),
              const SizedBox(height: 8),
              _NameColumn(
                localizedName: localizedName,
                codename: codename,
                align: CrossAxisAlignment.center,
                textAlign: TextAlign.center,
                nameStyle: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  height: 1.2,
                  fontSize: isDesktop ? 15 : 14,
                ),
                codenameStyle: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                  fontSize: isDesktop ? 12 : 11,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCompact(BuildContext context) {
    final theme = Theme.of(context);
    final iconSize = waveGeneratorZombieIconSize(context, style: style);
    final isDesktop = isDesktopPlatform(context);
    final showSourceBadge =
        style == WaveGeneratorZombieTileStyle.poolSourceBadge &&
        sourceBadge != null;

    Color? badgeColor;
    Color? badgeForeground;
    if (showSourceBadge) {
      if (sourceBadge == 'G') {
        badgeColor = waveGeneratorGlobalPoolBadgeColor(theme);
        badgeForeground = waveGeneratorGlobalPoolBadgeForeground(theme);
      } else {
        badgeColor = waveGeneratorWavePoolBadgeColor(theme);
        badgeForeground = waveGeneratorWavePoolBadgeForeground(theme);
      }
    }

    final preferredWidth = isDesktop ? 260.0 : 220.0;
    return LayoutBuilder(
      builder: (context, constraints) {
        final tileWidth = constraints.hasBoundedWidth
            ? constraints.maxWidth.clamp(0.0, preferredWidth).toDouble()
            : preferredWidth;
        return Material(
          color: theme.colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(10),
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(10),
            child: Container(
              width: tileWidth,
              padding: EdgeInsets.all(isDesktop ? 8 : 6),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: theme.colorScheme.outline.withValues(alpha: 0.4),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.max,
                children: [
                  _buildIcon(
                    context,
                    iconSize: iconSize,
                    badge: showSourceBadge ? sourceBadge : null,
                    badgeColor: badgeColor,
                    badgeForeground: badgeForeground,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _NameColumn(
                      localizedName: localizedName,
                      codename: codename,
                      align: CrossAxisAlignment.start,
                      nameStyle: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        height: 1.2,
                        fontSize: isDesktop ? 13 : 12,
                      ),
                      codenameStyle: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                        fontSize: 10,
                      ),
                    ),
                  ),
                  if (onDelete != null) _DeleteButton(onDelete: onDelete!),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _BadgeLabel extends StatelessWidget {
  const _BadgeLabel({
    required this.label,
    required this.background,
    required this.foreground,
  });

  final String label;
  final Color background;
  final Color foreground;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: Theme.of(context).colorScheme.surface,
          width: 1.5,
        ),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.bold,
          color: foreground,
        ),
      ),
    );
  }
}

class _NameColumn extends StatelessWidget {
  const _NameColumn({
    required this.localizedName,
    required this.codename,
    required this.align,
    required this.nameStyle,
    required this.codenameStyle,
    this.textAlign,
    this.fitContent = false,
  });

  final String localizedName;
  final String codename;
  final CrossAxisAlignment align;
  final TextStyle? nameStyle;
  final TextStyle? codenameStyle;
  final TextAlign? textAlign;
  final bool fitContent;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: align,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          localizedName,
          maxLines: fitContent ? null : 2,
          overflow: fitContent ? null : TextOverflow.ellipsis,
          textAlign: textAlign,
          style: nameStyle,
        ),
        const SizedBox(height: 2),
        Text(
          codename,
          maxLines: fitContent ? null : 1,
          overflow: fitContent ? null : TextOverflow.ellipsis,
          textAlign: textAlign,
          style: codenameStyle,
        ),
      ],
    );
  }
}

class _DeleteButton extends StatelessWidget {
  const _DeleteButton({required this.onDelete});

  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SizedBox(
      width: 28,
      height: 28,
      child: IconButton(
        padding: EdgeInsets.zero,
        visualDensity: VisualDensity.compact,
        icon: Icon(
          Icons.close,
          size: 16,
          color: theme.colorScheme.onSurfaceVariant,
        ),
        tooltip: MaterialLocalizations.of(context).deleteButtonTooltip,
        onPressed: onDelete,
      ),
    );
  }
}

/// Compact zombie icon for wave list previews (icon + optional badges, tooltip).
class WaveGeneratorZombieIconChip extends StatelessWidget {
  const WaveGeneratorZombieIconChip({
    super.key,
    required this.localizedName,
    required this.codename,
    required this.iconPath,
    this.rowLabel,
    this.positionTooltip,
    this.sourceBadge,
  });

  final String localizedName;
  final String codename;
  final String? iconPath;
  final String? rowLabel;
  final String? positionTooltip;
  final String? sourceBadge;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDesktop = isDesktopPlatform(context);
    final iconSize = isDesktop ? 36.0 : 32.0;

    Color? badgeColor;
    Color? badgeForeground;
    if (sourceBadge == 'G') {
      badgeColor = waveGeneratorGlobalPoolBadgeColor(theme);
      badgeForeground = waveGeneratorGlobalPoolBadgeForeground(theme);
    } else if (sourceBadge == 'W') {
      badgeColor = waveGeneratorWavePoolBadgeColor(theme);
      badgeForeground = waveGeneratorWavePoolBadgeForeground(theme);
    } else if (rowLabel != null) {
      badgeColor = rowLabel == '?'
          ? theme.colorScheme.secondaryContainer
          : theme.colorScheme.primary;
      badgeForeground = rowLabel == '?'
          ? theme.colorScheme.onSecondaryContainer
          : theme.colorScheme.onPrimary;
    }

    final tooltip = positionTooltip != null
        ? '$localizedName\n$codename\n$positionTooltip'
        : rowLabel != null && rowLabel!.isNotEmpty
        ? '$localizedName\n$codename · R$rowLabel'
        : '$localizedName\n$codename';

    return Tooltip(
      message: tooltip,
      waitDuration: const Duration(milliseconds: 400),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: iconPath != null && iconPath!.isNotEmpty
                ? AssetImageWidget(
                    assetPath: iconPath!,
                    altCandidates: imageAltCandidates(iconPath!),
                    width: iconSize,
                    height: iconSize,
                    fit: BoxFit.cover,
                  )
                : Container(
                    width: iconSize,
                    height: iconSize,
                    color: theme.colorScheme.surfaceContainerHighest,
                    child: Icon(
                      Icons.person_outline,
                      size: iconSize * 0.5,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
          ),
          if ((sourceBadge != null && sourceBadge!.isNotEmpty) ||
              (rowLabel != null && rowLabel!.isNotEmpty))
            Positioned(
              top: -4,
              right: -4,
              child: _BadgeLabel(
                label: sourceBadge ?? rowLabel!,
                background: badgeColor ?? theme.colorScheme.primary,
                foreground: badgeForeground ?? theme.colorScheme.onPrimary,
              ),
            ),
        ],
      ),
    );
  }
}
