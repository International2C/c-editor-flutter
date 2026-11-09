import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:c_editor/data/bootstrap_loading_category.dart';
import 'package:c_editor/l10n/app_localizations.dart';
import 'package:c_editor/theme/app_theme.dart';

class StartupLoadingScreen extends StatelessWidget {
  const StartupLoadingScreen({
    super.key,
    required this.progress,
    required this.locale,
    required this.themeMode,
    this.loadingCategory,
    this.pluginResourcesCompleted,
    this.pluginResourcesTotal,
  });

  final double progress;
  final Locale locale;
  final ThemeMode themeMode;
  final BootstrapLoadingCategory? loadingCategory;

  final int? pluginResourcesCompleted;
  final int? pluginResourcesTotal;

  static const _barHeight = 6.0;
  static const _labelGap = 8.0;
  /// Widest percent strings we expect with [toStringAsFixed(2)]; used so the
  /// bar width stays fixed while the live label text changes during load.
  static const _percentWidthSamples = ['100.00%', '88.88%', '00.00%'];

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: lightTheme,
      darkTheme: darkTheme,
      themeMode: themeMode,
      locale: locale,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Builder(
        builder: (context) {
          final theme = Theme.of(context);
          final l10n = AppLocalizations.of(context)!;
          final isDark = theme.brightness == Brightness.dark;
          final accent = isDark ? pvzGreenDark : pvzGreenLight;
          final clamped = progress.clamp(0.0, 1.0);
          final percentLabel = '${(clamped * 100).toStringAsFixed(2)}%';
          final labelStyle = TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 13,
            color: accent,
          );
          final rowHeight = math.max(20.0, labelStyle.fontSize! + 8);
          final categoryLabel =
              loadingCategory == BootstrapLoadingCategory.plugins &&
                  pluginResourcesCompleted != null &&
                  pluginResourcesTotal != null
              ? l10n.startupPluginResources(
                  pluginResourcesCompleted!,
                  pluginResourcesTotal!,
                )
              : loadingCategory?.loadingLabel(l10n);

          return Scaffold(
            body: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 320),
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: Image.asset(
                          'assets/meta/icon.png',
                          width: 96,
                          height: 96,
                          fit: BoxFit.cover,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        'C-Editor',
                        textAlign: TextAlign.center,
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: accent,
                        ),
                      ),
                      const SizedBox(height: 24),
                      LayoutBuilder(
                        builder: (context, constraints) {
                          final textDirection = Directionality.of(context);
                          final textScaler = MediaQuery.textScalerOf(context);
                          var labelWidth = 0.0;
                          for (final sample in _percentWidthSamples) {
                            final painter = TextPainter(
                              text: TextSpan(text: sample, style: labelStyle),
                              textDirection: textDirection,
                              textScaler: textScaler,
                            )..layout();
                            labelWidth = math.max(labelWidth, painter.width);
                          }
                          // Balance the trailing percent with an equal leading
                          // gap so the bar stays centered under the logo.
                          // Clamp when large text scale would otherwise crush
                          // the bar to zero width.
                          const minBarWidth = 32.0;
                          final maxSide =
                              ((constraints.maxWidth -
                                          (2 * _labelGap) -
                                          minBarWidth) /
                                      2)
                                  .clamp(0.0, double.infinity);
                          final side = math.min(labelWidth, maxSide);

                          return ConstrainedBox(
                            constraints: BoxConstraints(minHeight: rowHeight),
                            child: Row(
                              children: [
                                SizedBox(width: side),
                                const SizedBox(width: _labelGap),
                                Expanded(
                                  child: LinearProgressIndicator(
                                    value: progress > 0 ? clamped : null,
                                    minHeight: _barHeight,
                                    borderRadius: BorderRadius.circular(999),
                                    color: accent,
                                    backgroundColor: accent.withValues(
                                      alpha: 0.18,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: _labelGap),
                                SizedBox(
                                  width: side,
                                  child: FittedBox(
                                    fit: BoxFit.scaleDown,
                                    alignment: Alignment.centerRight,
                                    child: Text(
                                      percentLabel,
                                      style: labelStyle,
                                      maxLines: 1,
                                      softWrap: false,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                      if (categoryLabel != null) ...[
                        const SizedBox(height: 12),
                        Text(
                          categoryLabel,
                          textAlign: TextAlign.center,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
