import 'package:c_editor/data/gladiator_row_utils.dart';
import 'dart:convert';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:c_editor/data/module_open_hint.dart';
import 'package:c_editor/data/moon_wave_preview_utils.dart';
import 'package:c_editor/data/pvz_alias_utils.dart';
import 'package:c_editor/data/renai_wave_preview_utils.dart';
import 'package:c_editor/data/registry/event_registry.dart';
import 'package:c_editor/data/level_parser.dart';
import 'package:c_editor/data/pvz_models.dart';
import 'package:c_editor/data/rtid_parser.dart';
import 'package:c_editor/data/wave_point_analysis.dart';
import 'package:c_editor/l10n/app_localizations.dart';
import 'package:c_editor/l10n/resource_names.dart';
import 'package:c_editor/escape_override.dart';
import 'package:c_editor/data/repository/zombie_repository.dart';
import 'package:c_editor/data/repository/fish_type_repository.dart';
import 'package:c_editor/theme/app_theme.dart';
import 'package:c_editor/screens/select/event_selection_screen.dart';
import 'package:c_editor/screens/select/existing_wave_event_selection_screen.dart';
import 'package:c_editor/widgets/asset_image.dart'
    show AssetImageWidget, imageAltCandidates;
import 'package:c_editor/widgets/editor_components.dart'
    show
        EditorResponsiveInputField,
        EditorFilledButton,
        EventChipWidget,
        isDesktopPlatform,
        EditorOptionTile,
        EditorChoiceDialogOption,
        showEditorChoiceDialog;
import 'package:c_editor/widgets/editor_object_alias.dart';
import 'package:c_editor/widgets/initial_kongfu_grid_items_card.dart';
import 'package:c_editor/screens/common/level_preview_grid_helpers.dart'
    show readSeeingStarsModuleData;
import 'package:c_editor/widgets/wave_module_preview_dialogs.dart';
import 'package:c_editor/widgets/wave_number_label.dart';
import 'package:c_editor/widgets/zombie_lane_drag_widgets.dart'
    show zombieDragLongPressDelay, zombieDropSlotWidth;

String _waveGuideBodyForPlatform(BuildContext context, AppLocalizations? l10n) {
  final desktop = isDesktopPlatform(context);
  if (l10n == null) {
    return desktop
        ? 'Left-click a wave: Manage wave events\nLong-press an event: Drag to reorder or move waves\nClick points: View spawn expectations'
        : 'Tap a wave: Manage events\nLong-press an event: Drag to reorder or move waves\nTap points: View spawn expectations';
  }
  return desktop
      ? l10n.waveTimelineGuideBodyDesktop
      : l10n.waveTimelineGuideBodyMobile;
}

String _waveEmptyRowHintForPlatform(
  BuildContext context,
  AppLocalizations? l10n,
) {
  final desktop = isDesktopPlatform(context);
  if (l10n == null) {
    return desktop
        ? 'Empty wave (click to manage, drop events here)'
        : 'Empty wave (tap to manage, drop events here)';
  }
  return desktop ? l10n.waveEmptyRowHintDesktop : l10n.waveEmptyRowHintMobile;
}

class _WaveEventDragData {
  const _WaveEventDragData({
    required this.rtid,
    required this.sourceWaveIndex,
    required this.sourceIndex,
  });

  final String rtid;
  final int sourceWaveIndex;
  final int sourceIndex;
}

const _kUnknownIconPath = 'assets/images/others/unknown.webp';

double _expectationDialogIconSize(BuildContext context) {
  final isDesktop = isDesktopPlatform(context);
  final compact = MediaQuery.sizeOf(context).width < 400;
  if (isDesktop) return compact ? 44 : 48;
  return compact ? 36 : 40;
}

Size _expectationDialogListSize(BuildContext context) {
  final isDesktop = isDesktopPlatform(context);
  final screenWidth = MediaQuery.sizeOf(context).width;
  if (isDesktop) {
    return Size(420, compactWidth(screenWidth) ? 300 : 360);
  }
  return Size((screenWidth - 96).clamp(280, 360), 280);
}

bool compactWidth(double screenWidth) => screenWidth < 500;

double _requiredIconButtonWidth(BuildContext context, String label) {
  final theme = Theme.of(context);
  final textStyle = theme.textTheme.labelLarge ?? const TextStyle(fontSize: 14);
  final painter = TextPainter(
    text: TextSpan(text: label, style: textStyle),
    textDirection: Directionality.of(context),
    textScaler: MediaQuery.textScalerOf(context),
    maxLines: 1,
  )..layout();
  // Includes the icon, icon/label gap, and horizontal button padding.
  return painter.width + 72;
}

Size _waveManageButtonSize(
  BuildContext context,
  ButtonStyle style,
  String label,
  double availableWidth,
) {
  const states = <WidgetState>{};
  final textStyle =
      style.textStyle?.resolve(states) ??
      Theme.of(context).textTheme.labelLarge;
  final padding =
      style.padding?.resolve(states)?.resolve(Directionality.of(context)) ??
      EdgeInsets.zero;
  final iconSize = style.iconSize?.resolve(states) ?? 24.0;
  final minimumSize = style.minimumSize?.resolve(states) ?? Size.zero;
  final painter = TextPainter(
    text: TextSpan(text: label, style: textStyle),
    textDirection: Directionality.of(context),
    textScaler: MediaQuery.textScalerOf(context),
  )..layout();
  final width = painter.width + padding.horizontal + iconSize + 8;
  painter.layout(
    maxWidth: (availableWidth - padding.horizontal - iconSize - 8).clamp(
      1,
      double.infinity,
    ),
  );
  // Reserve the padded Material tap target as well as the visible button.
  final height = (painter.height + padding.vertical)
      .clamp(minimumSize.height.clamp(48, double.infinity), double.infinity)
      .toDouble();
  return Size(width.clamp(minimumSize.width, double.infinity), height);
}

/// Wave timeline tab with events. Ported from Z-Editor-master WaveTimelineTab.kt
class WaveTimelineTab extends StatefulWidget {
  const WaveTimelineTab({
    super.key,
    required this.levelFile,
    required this.parsed,
    required this.onChanged,
    required this.onEditEvent,
    required this.onAddEvent,
    required this.onEditWaveManagerSettings,
    this.onEditCustomZombie,
    this.onEditCustomFish,
    this.onOpenModule,
    this.openWaveSheetNotifier,
    this.onCreateContainer,
    this.onDeleteContainer,
  });

  final PvzLevelFile levelFile;
  final ParsedLevelData parsed;
  final VoidCallback onChanged;
  final Future<void> Function(String rtid, int waveIndex) onEditEvent;
  final void Function(int waveIndex) onAddEvent;
  final VoidCallback onEditWaveManagerSettings;
  final void Function(String rtid)? onEditCustomZombie;
  final void Function(String rtid)? onEditCustomFish;
  final OpenModuleCallback? onOpenModule;
  final ValueNotifier<({int waveIndex, String? rtid})?>? openWaveSheetNotifier;
  final VoidCallback? onCreateContainer;
  final VoidCallback? onDeleteContainer;

  @override
  State<WaveTimelineTab> createState() => _WaveTimelineTabState();
}

class _WaveTimelineTabState extends State<WaveTimelineTab> {
  VoidCallback? _notifierListener;
  _WaveEventDragData? _draggingEvent;
  int? _dragHoverWaveIndex;

  @override
  void initState() {
    super.initState();
    _notifierListener = () {
      final payload = widget.openWaveSheetNotifier?.value;
      if (payload != null && mounted) {
        widget.openWaveSheetNotifier!.value = null;
        _showWaveManageSheet(context, payload.waveIndex);
      }
    };
    widget.openWaveSheetNotifier?.addListener(_notifierListener!);
  }

  @override
  void didUpdateWidget(covariant WaveTimelineTab oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.openWaveSheetNotifier != widget.openWaveSheetNotifier) {
      oldWidget.openWaveSheetNotifier?.removeListener(_notifierListener!);
      _notifierListener = () {
        final payload = widget.openWaveSheetNotifier?.value;
        if (payload != null && mounted) {
          widget.openWaveSheetNotifier!.value = null;
          _showWaveManageSheet(context, payload.waveIndex);
        }
      };
      widget.openWaveSheetNotifier?.addListener(_notifierListener!);
    }
  }

  @override
  void dispose() {
    widget.openWaveSheetNotifier?.removeListener(_notifierListener!);
    super.dispose();
  }

  int _pointsAtWave(WaveManagerModuleData module, int waveIndex, bool isFlag) {
    if (module.dynamicZombies.isEmpty) return 0;
    final g = module.dynamicZombies.first;
    final startEffectWave = g.startingWave + 1;
    if (waveIndex < startEffectWave) return 0;
    var basePoints =
        g.startingPoints + (waveIndex - startEffectWave) * g.pointIncrement;
    if (basePoints > 60000) basePoints = 60000;
    return isFlag ? (basePoints * 2.5).toInt() : basePoints;
  }

  Widget _buildHintCard(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? usageGuideDarkBg : usageGuideLightBg;
    final onBg = isDark ? Colors.white : usageGuideLightOnBg;
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: bgColor,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Icon(Icons.lightbulb, color: onBg),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n?.waveTimelineGuideTitle ?? 'Usage guide',
                    style: TextStyle(fontWeight: FontWeight.bold, color: onBg),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _waveGuideBodyForPlatform(context, l10n),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: onBg.withValues(alpha: 0.9),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDeadLinksCard(BuildContext context, List<String> deadLinks) {
    final l10n = AppLocalizations.of(context);
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: Theme.of(context).colorScheme.error,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.gpp_bad,
                  color: Theme.of(context).colorScheme.onError,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    l10n?.waveDeadLinksTitle ?? 'Broken references',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.onError,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            ...deadLinks.map(
              (rtid) => Text(
                rtid,
                style: TextStyle(color: Theme.of(context).colorScheme.onError),
              ),
            ),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerRight,
              child: FilledButton(
                style: FilledButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.onError,
                  foregroundColor: Theme.of(context).colorScheme.error,
                ),
                onPressed: () {
                  final wm = widget.parsed.waveManager;
                  if (wm is! WaveManagerData) return;
                  for (final wave in wm.waves) {
                    wave.removeWhere((r) => deadLinks.contains(r));
                  }
                  _syncWaves();
                  setState(() {});
                },
                child: Text(l10n?.waveDeadLinksClear ?? 'Clear dead links'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCustomFishCard(
    BuildContext context,
    List<_CustomFishUsage> customFishes,
  ) {
    if (customFishes.isEmpty) return const SizedBox.shrink();
    final l10n = AppLocalizations.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? pvzFishDark : pvzFishLight;
    final itemBg = isDark ? const Color(0xFFB3E5FC) : const Color(0xFFE1F5FE);
    final onCard = isDark ? Colors.white : Colors.black87;
    final onItem = Colors.black87;
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: cardBg,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.pets, color: onCard),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    l10n?.customFishManagerTitle ?? 'Custom fish',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: onCard,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: customFishes.map((info) {
                final icon = info.isUnused
                    ? editorWarningIcon
                    : Icons.check_circle;
                final iconColor = info.isUnused
                    ? editorWarningBannerForeground(
                        Theme.of(context).brightness,
                      )
                    : const Color(0xFF2E7D32);
                return Material(
                  color: itemBg,
                  borderRadius: BorderRadius.circular(20),
                  child: InkWell(
                    onTap: () => _showCustomFishSheet(context, info),
                    borderRadius: BorderRadius.circular(20),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(icon, size: 18, color: iconColor),
                          const SizedBox(width: 8),
                          Flexible(
                            child: Text(
                              info.alias,
                              style: TextStyle(
                                color: onItem,
                                fontWeight: FontWeight.w500,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCustomZombieCard(
    BuildContext context,
    List<_CustomZombieUsage> customZombies,
  ) {
    final l10n = AppLocalizations.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? pvzOrangeDark : pvzOrangeLight;
    // Distinct item backgrounds: light cream/beige so pills don't blend with card
    final itemBg = isDark
        ? const Color(
            0xFFE8D4C4,
          ) // Light beige-orange (matches reference photos)
        : const Color(0xFFFFF5D6); // Warm cream (matches reference photos)
    final onCard = isDark ? Colors.white : Colors.black87;
    final onItem = Colors.black87; // Dark text for readability on light item bg
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: cardBg,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.science, color: onCard),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    l10n?.customZombieManagerTitle ??
                        'Custom zombie management',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: onCard,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (customZombies.isEmpty)
              Text(
                l10n?.customZombieEmpty ?? 'No custom zombie data',
                style: TextStyle(color: onCard.withValues(alpha: 0.9)),
              )
            else
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: customZombies.map((info) {
                  final icon = info.isUnused
                      ? editorWarningIcon
                      : Icons.check_circle;
                  final iconColor = info.isUnused
                      ? editorWarningBannerForeground(
                          Theme.of(context).brightness,
                        )
                      : const Color(0xFF2E7D32); // Dark green for ok
                  return Material(
                    color: itemBg,
                    borderRadius: BorderRadius.circular(20),
                    child: InkWell(
                      onTap: () => _showCustomZombieSheet(context, info),
                      borderRadius: BorderRadius.circular(20),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(icon, size: 18, color: iconColor),
                            const SizedBox(width: 8),
                            Flexible(
                              child: Text(
                                info.alias,
                                style: TextStyle(
                                  color: onItem,
                                  fontWeight: FontWeight.w500,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
          ],
        ),
      ),
    );
  }

  void _showRenaiInfoDialog(BuildContext context, int waveIndex) {
    final renai = _getRenaiModuleData();
    if (renai == null) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!context.mounted) return;
      showRenaiWavePreviewDialog(
        context,
        levelFile: widget.levelFile,
        waveIndex: waveIndex,
        renai: renai,
        onOpenModuleSettings: widget.onOpenModule == null
            ? null
            : () => openModuleWithHint(
                widget.onOpenModule,
                widget.levelFile,
                'RenaiModuleProperties',
              ),
      );
    });
  }

  Widget _buildWaveContainerAliasCard(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final propsObj = widget.levelFile.objects.firstWhereOrNull(
      (o) => o.objClass == 'WaveManagerProperties',
    );
    final alias = propsObj?.aliases?.firstOrNull;
    if (alias == null) return const SizedBox.shrink();

    return Card(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n?.waveContainerAliasSection ?? 'Wave container alias',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.primary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              l10n?.waveContainerAliasHint ??
                  'Alias for the WaveManagerProperties object that stores wave data.',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 12),
            EditorAliasInputField(
              key: ValueKey(alias),
              alias: alias,
              levelFile: widget.levelFile,
              wrapInCard: false,
              onAliasChanged: (newAlias) {
                renameLevelObjectAlias(
                  levelFile: widget.levelFile,
                  oldAlias: alias,
                  newAlias: newAlias,
                  onChanged: widget.onChanged,
                );
              },
              onChanged: widget.onChanged,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWaveManagerSettingsCard(
    BuildContext context,
    int interval,
    double minPercent,
    double maxPercent,
  ) {
    final l10n = AppLocalizations.of(context);
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        leading: const Icon(Icons.tune),
        title: Text(l10n?.waveManagerGlobalParams ?? 'Wave manager parameters'),
        subtitle: Text(
          l10n?.waveManagerGlobalSummary(
                interval,
                (minPercent * 100).toInt(),
                (maxPercent * 100).toInt(),
              ) ??
              'Flag interval: $interval, health: ${(minPercent * 100).toInt()}% - ${(maxPercent * 100).toInt()}%',
        ),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: widget.onEditWaveManagerSettings,
      ),
    );
  }

  Widget _buildEmptyWaveCard(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Text(
              l10n?.waveEmptyTitle ?? 'No waves yet',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              l10n?.waveEmptySubtitle ??
                  'Add the first wave, or remove this empty container.',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            if (widget.onDeleteContainer != null) ...[
              const SizedBox(height: 16),
              FilledButton.icon(
                style: FilledButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.error,
                ),
                onPressed: widget.onDeleteContainer,
                icon: const Icon(Icons.delete_forever),
                label: Text(
                  l10n?.deleteEmptyContainer ?? 'Delete empty container',
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildWaveHeaderRow(BuildContext context, int total) {
    final l10n = AppLocalizations.of(context);
    final color = Theme.of(context).colorScheme.onSurfaceVariant;
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      child: Row(
        children: [
          SizedBox(
            width: 36,
            child: Text(
              '#',
              style: TextStyle(fontWeight: FontWeight.bold, color: color),
            ),
          ),
          Expanded(
            child: Text(
              l10n?.waveHeaderPreview ?? 'Content & points preview',
              style: TextStyle(fontWeight: FontWeight.bold, color: color),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Flexible(
            child: Text(
              l10n?.waveTotalLabel(total) ?? 'Total: $total',
              style: TextStyle(fontWeight: FontWeight.bold, color: color),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWaveRowItem(
    BuildContext context, {
    required int waveIndex,
    required bool isFlagWave,
    required List<String> rtidList,
    required Map<String, PvzObject> objectMap,
    required List<({String label, VoidCallback onTap})> actionButtons,
    required VoidCallback? onRowTap,
    bool includeDivider = true,
  }) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final color = theme.colorScheme.onSurfaceVariant;
    final isDropTarget =
        _draggingEvent != null &&
        _draggingEvent!.sourceWaveIndex != waveIndex &&
        _dragHoverWaveIndex == waveIndex;
    final waveNumber = WaveNumberLabel(
      waveNumber: waveIndex,
      isFlagWave: isFlagWave,
    );
    final numberSize = waveNumber.minimumSize(context, minWidth: 52);
    final dragging = _draggingEvent != null;
    final eventsColumn = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (rtidList.isEmpty)
          dragging && _dragHoverWaveIndex == waveIndex && _draggingEvent != null
              ? Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: _buildWaveEventPreviewChip(
                    rtid: _draggingEvent!.rtid,
                    objectMap: objectMap,
                  ),
                )
              : Text(
                  _waveEmptyRowHintForPlatform(context, l10n),
                  key: ValueKey('waveTimelineEmptyHint-$waveIndex'),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                )
        else ...[
          // Insert slots use zero layout height (overflow hit targets) so
          // dragging does not inflate spacing between chips.
          if (dragging)
            _buildWaveEventInsertSlot(
              waveIndex: waveIndex,
              insertBeforeIndex: 0,
              objectMap: objectMap,
            ),
          for (var i = 0; i < rtidList.length; i++) ...[
            Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: _buildDraggableEventChip(
                context: context,
                waveIndex: waveIndex,
                sourceIndex: i,
                rtid: rtidList[i],
                objectMap: objectMap,
              ),
            ),
            if (dragging)
              _buildWaveEventInsertSlot(
                waveIndex: waveIndex,
                insertBeforeIndex: i + 1 < rtidList.length ? i + 1 : null,
                objectMap: objectMap,
              ),
          ],
        ],
      ],
    );
    final eventDropTarget = DragTarget<_WaveEventDragData>(
      key: ValueKey('waveTimelineDropTarget-$waveIndex'),
      onWillAcceptWithDetails: (details) {
        return details.data.sourceWaveIndex != waveIndex;
      },
      onMove: (_) {
        if (_dragHoverWaveIndex != waveIndex) {
          setState(() => _dragHoverWaveIndex = waveIndex);
        }
      },
      onLeave: (_) {
        if (_dragHoverWaveIndex == waveIndex) {
          setState(() => _dragHoverWaveIndex = null);
        }
      },
      onAcceptWithDetails: (details) {
        setState(() {
          _dragHoverWaveIndex = null;
          _draggingEvent = null;
        });
        _placeWaveEvent(
          sourceWaveIndex: details.data.sourceWaveIndex,
          sourceIndex: details.data.sourceIndex,
          targetWaveIndex: waveIndex,
          insertBeforeIndex: null,
        );
      },
      builder: (context, candidateData, rejectedData) {
        final highlighted = isDropTarget || candidateData.isNotEmpty;
        return Material(
          color: highlighted
              ? theme.colorScheme.primary.withValues(alpha: 0.12)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          child: InkWell(
            onTap: _draggingEvent == null ? onRowTap : null,
            borderRadius: BorderRadius.circular(8),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 120),
              curve: Curves.easeOut,
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                border: highlighted
                    ? Border.all(color: theme.colorScheme.primary, width: 1.5)
                    : null,
              ),
              child: eventsColumn,
            ),
          ),
        );
      },
    );

    Widget moduleActions(double maxWidth, WrapAlignment alignment) {
      return Wrap(
        key: ValueKey('waveTimelineModuleActions-$waveIndex'),
        alignment: alignment,
        spacing: 6,
        runSpacing: 6,
        children: [
          for (var i = 0; i < actionButtons.length; i++)
            ConstrainedBox(
              constraints: BoxConstraints(maxWidth: maxWidth),
              child: InkWell(
                key: ValueKey('waveTimelineExpectation-$waveIndex-$i'),
                onTap: actionButtons[i].onTap,
                borderRadius: BorderRadius.circular(6),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 10,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Flexible(
                        child: Text(
                          actionButtons[i].label,
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: color,
                          ),
                          softWrap: true,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Icon(Icons.info_outline, size: 18, color: color),
                    ],
                  ),
                ),
              ),
            ),
        ],
      );
    }

    final rowStack = LayoutBuilder(
      builder: (context, constraints) {
        final numberWidth = numberSize.width;
        const maxActionWidth = 260.0;
        const gap = 8.0;
        final contentWidth = (constraints.maxWidth - numberWidth).clamp(
          0.0,
          double.infinity,
        );
        final actionWidth = contentWidth.clamp(0.0, maxActionWidth);
        final textScale = MediaQuery.textScalerOf(context).scale(14) / 14;
        // Badges must not take their unconstrained intrinsic width before the
        // event area is laid out. Stack them below when doing so would leave
        // less than a readable text area, including accessibility text scaling.
        final actionsBesideEvents =
            actionButtons.isNotEmpty &&
            contentWidth >= 240 * textScale + maxActionWidth + gap;
        final content = actionsBesideEvents
            ? Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: eventDropTarget),
                  const SizedBox(width: gap),
                  SizedBox(
                    width: actionWidth,
                    child: moduleActions(actionWidth, WrapAlignment.end),
                  ),
                ],
              )
            : Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  eventDropTarget,
                  if (actionButtons.isNotEmpty) ...[
                    const SizedBox(height: gap),
                    moduleActions(actionWidth, WrapAlignment.start),
                    const SizedBox(height: 8),
                  ],
                ],
              );
        return Stack(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(width: numberWidth),
                Expanded(child: content),
              ],
            ),
            Positioned(
              left: 0,
              top: 0,
              bottom: 0,
              width: numberWidth,
              child: Semantics(
                button: onRowTap != null,
                label:
                    l10n?.waveEventsTitle(waveIndex) ??
                    'Wave $waveIndex events',
                child: Material(
                  type: MaterialType.transparency,
                  child: InkWell(
                    key: ValueKey('waveTimelineWaveNumberTap-$waveIndex'),
                    onTap: _draggingEvent == null ? onRowTap : null,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      child: waveNumber,
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
    final rowContent = ConstrainedBox(
      // Empty waves have less intrinsic content than event waves. Keep enough
      // height for the overlaid number strip (and its full tap target) so the
      // number is never compressed out of view.
      constraints: BoxConstraints(
        minHeight: (numberSize.height + 28).clamp(48, double.infinity),
      ),
      child: rowStack,
    );
    if (!includeDivider) {
      return rowContent;
    }
    return Column(
      children: [
        rowContent,
        Divider(
          height: 1,
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
        ),
      ],
    );
  }

  Widget _buildWaveEventPreviewChip({
    required String rtid,
    required Map<String, PvzObject> objectMap,
  }) {
    final theme = Theme.of(context);
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: theme.colorScheme.primary, width: 2),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(6),
        child: Opacity(
          opacity: 0.55,
          child: EventChipWidget(
            rtid: rtid,
            objectMap: objectMap,
            onTap: () {},
          ),
        ),
      ),
    );
  }

  Widget _buildWaveEventInsertSlot({
    required int waveIndex,
    required int? insertBeforeIndex,
    required Map<String, PvzObject> objectMap,
  }) {
    final slotKey = insertBeforeIndex == null
        ? 'waveTimelineInsertSlot-$waveIndex-end'
        : 'waveTimelineInsertSlot-$waveIndex-$insertBeforeIndex';
    return DragTarget<_WaveEventDragData>(
      key: ValueKey(slotKey),
      onWillAcceptWithDetails: (details) {
        if (details.data.sourceWaveIndex != waveIndex) return true;
        final from = details.data.sourceIndex;
        // Mirror jittered: reject only the slot immediately before the dragged item.
        if (insertBeforeIndex == null) return true;
        return from != insertBeforeIndex;
      },
      onMove: (_) {
        if (_dragHoverWaveIndex != waveIndex) {
          setState(() => _dragHoverWaveIndex = waveIndex);
        }
      },
      onLeave: (_) {
        if (_dragHoverWaveIndex == waveIndex) {
          setState(() => _dragHoverWaveIndex = null);
        }
      },
      onAcceptWithDetails: (details) {
        setState(() {
          _dragHoverWaveIndex = null;
          _draggingEvent = null;
        });
        _placeWaveEvent(
          sourceWaveIndex: details.data.sourceWaveIndex,
          sourceIndex: details.data.sourceIndex,
          targetWaveIndex: waveIndex,
          insertBeforeIndex: insertBeforeIndex,
        );
      },
      builder: (context, candidateData, rejectedData) {
        final showPreview = candidateData.isNotEmpty && _draggingEvent != null;
        if (showPreview) {
          // Jittered-style ghost at the hovered insert position.
          return Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: _buildWaveEventPreviewChip(
              rtid: _draggingEvent!.rtid,
              objectMap: objectMap,
            ),
          );
        }
        // Zero layout height keeps chip spacing unchanged while dragging;
        // overflow preserves a usable drop hit target between chips.
        return SizedBox(
          width: double.infinity,
          height: 0,
          child: OverflowBox(
            minHeight: zombieDropSlotWidth,
            maxHeight: zombieDropSlotWidth,
            alignment: Alignment.center,
            child: const SizedBox(
              width: double.infinity,
              height: zombieDropSlotWidth,
            ),
          ),
        );
      },
    );
  }

  Widget _buildDraggableEventChip({
    required BuildContext context,
    required int waveIndex,
    required int sourceIndex,
    required String rtid,
    required Map<String, PvzObject> objectMap,
  }) {
    final data = _WaveEventDragData(
      rtid: rtid,
      sourceWaveIndex: waveIndex,
      sourceIndex: sourceIndex,
    );
    final chip = EventChipWidget(
      rtid: rtid,
      objectMap: objectMap,
      onTap: () => _showEventActionSheet(
        context: context,
        waveIndex: waveIndex,
        rtid: rtid,
      ),
    );

    return LongPressDraggable<_WaveEventDragData>(
      data: data,
      delay: zombieDragLongPressDelay,
      maxSimultaneousDrags: 1,
      rootOverlay: true,
      hapticFeedbackOnStart: true,
      onDragStarted: () {
        setState(() {
          _draggingEvent = data;
          _dragHoverWaveIndex = null;
        });
      },
      onDragEnd: (_) {
        if (!mounted) return;
        setState(() {
          _draggingEvent = null;
          _dragHoverWaveIndex = null;
        });
      },
      onDraggableCanceled: (_, _) {
        if (!mounted) return;
        setState(() {
          _draggingEvent = null;
          _dragHoverWaveIndex = null;
        });
      },
      feedback: Material(
        color: Colors.transparent,
        elevation: 6,
        borderRadius: BorderRadius.circular(6),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 240),
          child: EventChipWidget(
            rtid: rtid,
            objectMap: objectMap,
            onTap: () {},
          ),
        ),
      ),
      childWhenDragging: Opacity(opacity: 0.45, child: chip),
      child: chip,
    );
  }

  void _openReuseExistingEvent(int waveIndex) {
    final wm = widget.parsed.waveManager;
    if (wm is! WaveManagerData) return;
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (ctx) => ExistingWaveEventSelectionScreen(
          waveIndex: waveIndex,
          levelFile: widget.levelFile,
          waveManager: wm,
          onEventSelected: (rtid) {
            Navigator.pop(ctx);
            _performCopyReference(rtid, [waveIndex]);
          },
          onBack: () => Navigator.pop(ctx),
        ),
      ),
    );
  }

  Map<String, List<int>> _collectCustomZombieWaveUsage() {
    final result = <String, Set<int>>{};
    final wm = widget.parsed.waveManager;
    if (wm is! WaveManagerData) return {};
    final aliasToObj = <String, PvzObject>{};
    for (final obj in widget.levelFile.objects) {
      if (obj.aliases?.isNotEmpty == true) {
        for (final a in obj.aliases!) {
          aliasToObj[a] = obj;
        }
      }
    }
    for (var i = 0; i < wm.waves.length; i++) {
      final waveIndex = i + 1;
      for (final eventRtid in wm.waves[i]) {
        final alias = LevelParser.extractAlias(eventRtid);
        final obj = aliasToObj[alias];
        if (obj == null) continue;
        final usedAliases = <String>{};
        if (obj.objClass == 'SpawnZombiesJitteredWaveActionProps') {
          try {
            final data = WaveActionData.fromJson(
              Map<String, dynamic>.from(obj.objData as Map),
            );
            for (final z in data.zombies) {
              final info = RtidParser.parse(z.type);
              if (info?.source == 'CurrentLevel') {
                usedAliases.add(info!.alias);
              }
            }
          } catch (_) {}
        } else if (obj.objClass == 'SpawnZombiesFromGroundSpawnerProps') {
          try {
            final data = SpawnZombiesFromGroundData.fromJson(
              Map<String, dynamic>.from(obj.objData as Map),
            );
            for (final z in data.zombies) {
              final info = RtidParser.parse(z.type);
              if (info?.source == 'CurrentLevel') {
                usedAliases.add(info!.alias);
              }
            }
          } catch (_) {}
        } else if (obj.objClass == 'SpawnZombiesFishWaveActionProps') {
          try {
            final data = SpawnZombiesFishWaveActionPropsData.fromJson(
              Map<String, dynamic>.from(obj.objData as Map),
            );
            for (final z in data.zombies) {
              final info = RtidParser.parse(z.type);
              if (info?.source == 'CurrentLevel') {
                usedAliases.add(info!.alias);
              }
            }
          } catch (_) {}
        }
        for (final a in usedAliases) {
          final set = result.putIfAbsent(a, () => <int>{});
          set.add(waveIndex);
        }
      }
    }
    return result.map((k, v) => MapEntry(k, (v.toList()..sort())));
  }

  /// Returns the base zombie type (e.g. future_gargantuar) for a custom zombie alias.
  String? _getCustomZombieBaseType(String alias) {
    final typeObj = widget.levelFile.objects.firstWhereOrNull(
      (o) => o.objClass == 'ZombieType' && o.aliases?.contains(alias) == true,
    );
    if (typeObj?.objData is Map<String, dynamic>) {
      final typeName =
          (typeObj!.objData as Map<String, dynamic>)['TypeName'] as String?;
      if (typeName != null && typeName.isNotEmpty) return typeName;
    }
    return null;
  }

  String? _getCustomFishBaseType(String alias) {
    final typeObj = widget.levelFile.objects.firstWhereOrNull(
      (o) => o.objClass == 'CreatureType' && o.aliases?.contains(alias) == true,
    );
    if (typeObj?.objData is Map<String, dynamic>) {
      final typeName =
          (typeObj!.objData as Map<String, dynamic>)['TypeName'] as String?;
      if (typeName != null && typeName.isNotEmpty) return typeName;
    }
    return null;
  }

  Map<String, List<int>> _collectCustomFishWaveUsage() {
    final result = <String, Set<int>>{};
    final wm = widget.parsed.waveManager;
    if (wm is! WaveManagerData) return {};
    final aliasToObj = <String, PvzObject>{};
    for (final obj in widget.levelFile.objects) {
      if (obj.aliases?.isNotEmpty == true) {
        for (final a in obj.aliases!) {
          aliasToObj[a] = obj;
        }
      }
    }
    for (var i = 0; i < wm.waves.length; i++) {
      final waveIndex = i + 1;
      for (final eventRtid in wm.waves[i]) {
        final alias = LevelParser.extractAlias(eventRtid);
        final obj = aliasToObj[alias];
        if (obj == null || obj.objClass != 'SpawnZombiesFishWaveActionProps') {
          continue;
        }
        try {
          final data = SpawnZombiesFishWaveActionPropsData.fromJson(
            Map<String, dynamic>.from(obj.objData as Map),
          );
          for (final f in data.fishes) {
            final info = RtidParser.parse(f.type);
            if (info?.source == 'CurrentLevel') {
              result.putIfAbsent(info!.alias, () => <int>{}).add(waveIndex);
            }
          }
        } catch (_) {}
      }
    }
    return result.map((k, v) => MapEntry(k, (v.toList()..sort())));
  }

  List<_CustomFishUsage> _collectCustomFishes() {
    final waveUsage = _collectCustomFishWaveUsage();
    final customFish = widget.levelFile.objects
        .where((o) => o.objClass == 'CreatureType')
        .where((o) => o.aliases?.isNotEmpty == true)
        .where((o) {
          if (o.objData is! Map<String, dynamic>) return false;
          final cc =
              (o.objData as Map<String, dynamic>)['CreatureClass'] as String? ??
              '';
          return cc.contains('Fish');
        })
        .toList();
    return customFish.map((o) {
      final alias = o.aliases!.first;
      final rtid = RtidParser.build(alias, 'CurrentLevel');
      final waveIndices = waveUsage[alias] ?? [];
      return _CustomFishUsage(
        alias: alias,
        rtid: rtid,
        isUnused: waveIndices.isEmpty,
        waveIndices: waveIndices,
      );
    }).toList();
  }

  List<_CustomZombieUsage> _collectCustomZombies() {
    final waveUsage = _collectCustomZombieWaveUsage();
    final customObjects = widget.levelFile.objects
        .where((o) => o.objClass == 'ZombieType')
        .where((o) => o.aliases?.isNotEmpty == true)
        .toList();
    return customObjects.map((o) {
      final alias = o.aliases!.first;
      final rtid = RtidParser.build(alias, 'CurrentLevel');
      final waveIndices = waveUsage[alias] ?? [];
      return _CustomZombieUsage(
        alias: alias,
        rtid: rtid,
        isUnused: waveIndices.isEmpty,
        waveIndices: waveIndices,
      );
    }).toList();
  }

  void _showCustomZombieSheet(BuildContext context, _CustomZombieUsage info) {
    final l10n = AppLocalizations.of(context);
    final canDelete = info.isUnused;
    final baseType = _getCustomZombieBaseType(info.alias);
    final zombieInfo = baseType != null
        ? ZombieRepository().getZombieById(baseType)
        : null;
    final iconPath = zombieInfo?.iconAssetPath;
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (ctx) => EscapeClosesModal(
        child: SafeArea(
          top: false,
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.sizeOf(ctx).height * 0.9,
            ),
            child: SingleChildScrollView(
              key: const ValueKey('waveCustomZombieSheetScroll'),
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  EditorOptionTile(
                    contentPadding: EdgeInsets.zero,
                    leading: iconPath != null
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: AssetImageWidget(
                              assetPath: iconPath,
                              altCandidates: imageAltCandidates(iconPath),
                              width: 36,
                              height: 36,
                              fit: BoxFit.cover,
                            ),
                          )
                        : null,
                    title: Text(
                      info.alias,
                      style: Theme.of(ctx).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    l10n?.customZombieAppearanceLocation ??
                        'Appearance location:',
                    style: Theme.of(ctx).textTheme.titleSmall?.copyWith(
                      color: Theme.of(ctx).colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    info.waveIndices.isEmpty
                        ? (l10n?.customZombieNotUsed ??
                              'This custom zombie is not used by any wave or module.')
                        : info.waveIndices
                              .map(
                                (n) =>
                                    l10n?.customZombieWaveItem(n) ?? 'Wave $n',
                              )
                              .join(', '),
                    style: Theme.of(ctx).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 12),
                  if (widget.onEditCustomZombie != null)
                    FilledButton.icon(
                      onPressed: () {
                        Navigator.pop(ctx);
                        widget.onEditCustomZombie!(info.rtid);
                      },
                      style: FilledButton.styleFrom(
                        backgroundColor:
                            Theme.of(ctx).brightness == Brightness.dark
                            ? pvzYellowDark
                            : pvzYellowLight,
                        foregroundColor: Colors.black87,
                      ),
                      icon: const Icon(Icons.edit),
                      label: Text(l10n?.editProperties ?? 'Edit properties'),
                    ),
                  if (widget.onEditCustomZombie != null)
                    const SizedBox(height: 8),
                  FilledButton.icon(
                    style: FilledButton.styleFrom(
                      backgroundColor: Theme.of(ctx).colorScheme.error,
                    ),
                    onPressed: canDelete
                        ? () async {
                            Navigator.pop(ctx);
                            final ok = await showDialog<bool>(
                              context: context,
                              builder: (dctx) => AlertDialog(
                                title: Text(
                                  l10n?.deleteEntity ?? 'Delete entity',
                                ),
                                content: Text(
                                  l10n?.customZombieDeleteConfirm ??
                                      'Remove this custom zombie entity and its property data.',
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(dctx, false),
                                    child: Text(l10n?.cancel ?? 'Cancel'),
                                  ),
                                  FilledButton(
                                    onPressed: () => Navigator.pop(dctx, true),
                                    child: Text(l10n?.confirm ?? 'Confirm'),
                                  ),
                                ],
                              ),
                            );
                            if (ok == true) {
                              _deleteCustomZombie(info);
                            }
                          }
                        : null,
                    icon: const Icon(Icons.delete),
                    label: Text(l10n?.deleteEntity ?? 'Delete entity'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showCustomFishSheet(BuildContext context, _CustomFishUsage info) {
    final l10n = AppLocalizations.of(context);
    final canDelete = info.isUnused;
    final baseType = _getCustomFishBaseType(info.alias);
    final fishInfo = baseType != null
        ? (FishTypeRepository().getFishByAlias(baseType) ??
              FishTypeRepository().getFishByTypeName(baseType))
        : null;
    final iconPath = fishInfo?.iconAssetPath;
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (ctx) => EscapeClosesModal(
        child: SafeArea(
          top: false,
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.sizeOf(ctx).height * 0.9,
            ),
            child: SingleChildScrollView(
              key: const ValueKey('waveCustomFishSheetScroll'),
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  EditorOptionTile(
                    contentPadding: EdgeInsets.zero,
                    leading: iconPath != null
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: AssetImageWidget(
                              assetPath: iconPath,
                              altCandidates: imageAltCandidates(iconPath),
                              width: 36,
                              height: 36,
                              fit: BoxFit.cover,
                            ),
                          )
                        : null,
                    title: Text(
                      info.alias,
                      style: Theme.of(ctx).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    l10n?.customFishAppearanceLocation ??
                        'Appearance location:',
                    style: Theme.of(ctx).textTheme.titleSmall?.copyWith(
                      color: Theme.of(ctx).colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    info.waveIndices.isEmpty
                        ? (l10n?.customFishNotUsed ??
                              'This custom fish is not used by any wave.')
                        : info.waveIndices
                              .map(
                                (n) => l10n?.customFishWaveItem(n) ?? 'Wave $n',
                              )
                              .join(', '),
                    style: Theme.of(ctx).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 12),
                  if (widget.onEditCustomFish != null)
                    FilledButton.icon(
                      onPressed: () {
                        Navigator.pop(ctx);
                        widget.onEditCustomFish!(info.rtid);
                      },
                      style: FilledButton.styleFrom(
                        backgroundColor:
                            Theme.of(ctx).brightness == Brightness.dark
                            ? pvzFishDark
                            : pvzFishLight,
                        foregroundColor:
                            Theme.of(ctx).brightness == Brightness.dark
                            ? Colors.white
                            : Colors.black87,
                      ),
                      icon: const Icon(Icons.edit),
                      label: Text(
                        l10n?.editCustomFishProperties ?? 'Edit properties',
                      ),
                    ),
                  if (widget.onEditCustomFish != null)
                    const SizedBox(height: 8),
                  FilledButton.icon(
                    style: FilledButton.styleFrom(
                      backgroundColor: Theme.of(ctx).colorScheme.error,
                    ),
                    onPressed: canDelete
                        ? () async {
                            Navigator.pop(ctx);
                            final ok = await showDialog<bool>(
                              context: context,
                              builder: (dctx) => AlertDialog(
                                title: Text(
                                  l10n?.deleteEntity ?? 'Delete entity',
                                ),
                                content: Text(
                                  l10n?.customFishDeleteConfirm ??
                                      'Remove this custom fish and its property data.',
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(dctx, false),
                                    child: Text(l10n?.cancel ?? 'Cancel'),
                                  ),
                                  FilledButton(
                                    onPressed: () => Navigator.pop(dctx, true),
                                    child: Text(l10n?.confirm ?? 'Confirm'),
                                  ),
                                ],
                              ),
                            );
                            if (ok == true) {
                              _deleteCustomFish(info);
                            }
                          }
                        : null,
                    icon: const Icon(Icons.delete),
                    label: Text(l10n?.deleteEntity ?? 'Delete entity'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _deleteCustomFish(_CustomFishUsage custom) {
    final typeObj = widget.levelFile.objects.firstWhereOrNull(
      (o) => o.aliases?.contains(custom.alias) == true,
    );
    if (typeObj != null) {
      final data = typeObj.objData;
      if (data is Map<String, dynamic>) {
        final propsRtid = data['Properties'] as String?;
        final propsInfo = propsRtid != null
            ? RtidParser.parse(propsRtid)
            : null;
        if (propsInfo?.source == 'CurrentLevel') {
          widget.levelFile.objects.removeWhere(
            (o) => o.aliases?.contains(propsInfo!.alias) == true,
          );
        }
      }
      widget.levelFile.objects.remove(typeObj);
      widget.onChanged();
      setState(() {});
    }
  }

  void _deleteCustomZombie(_CustomZombieUsage custom) {
    final typeObj = widget.levelFile.objects.firstWhereOrNull(
      (o) => o.aliases?.contains(custom.alias) == true,
    );
    if (typeObj != null) {
      final data = typeObj.objData;
      if (data is Map<String, dynamic>) {
        final propsRtid = data['Properties'] as String?;
        final propsInfo = propsRtid != null
            ? RtidParser.parse(propsRtid)
            : null;
        if (propsInfo?.source == 'CurrentLevel') {
          widget.levelFile.objects.removeWhere(
            (o) => o.aliases?.contains(propsInfo!.alias) == true,
          );
        }
      }
      widget.levelFile.objects.remove(typeObj);
    }

    for (final obj in widget.levelFile.objects) {
      if (obj.objClass == 'SpawnZombiesJitteredWaveActionProps') {
        try {
          final data = WaveActionData.fromJson(
            Map<String, dynamic>.from(obj.objData as Map),
          );
          final filtered = data.zombies.where((z) {
            final info = RtidParser.parse(z.type);
            return !(info?.source == 'CurrentLevel' &&
                info?.alias == custom.alias);
          }).toList();
          final updated = WaveActionData(
            notificationEvents: data.notificationEvents,
            additionalPlantFood: data.additionalPlantFood,
            spawnPlantName: data.spawnPlantName,
            zombies: filtered,
          );
          obj.objData = updated.toJson();
        } catch (_) {}
      }
      if (obj.objClass == 'SpawnZombiesFromGroundSpawnerProps') {
        try {
          final data = SpawnZombiesFromGroundData.fromJson(
            Map<String, dynamic>.from(obj.objData as Map),
          );
          final filtered = data.zombies.where((z) {
            final info = RtidParser.parse(z.type);
            return !(info?.source == 'CurrentLevel' &&
                info?.alias == custom.alias);
          }).toList();
          final updated = SpawnZombiesFromGroundData(
            columnStart: data.columnStart,
            columnEnd: data.columnEnd,
            additionalPlantFood: data.additionalPlantFood,
            spawnPlantName: data.spawnPlantName,
            zombies: filtered,
          );
          obj.objData = updated.toJson();
        } catch (_) {}
      }
    }
    widget.onChanged();
    setState(() {});
  }

  void _syncWaves() {
    final wm = widget.parsed.waveManager;
    if (wm is! WaveManagerData) return;
    final wmObj = widget.levelFile.objects.firstWhereOrNull(
      (o) => o.objClass == 'WaveManagerProperties',
    );
    if (wmObj != null) {
      wmObj.objData = wm.toJson();
      widget.onChanged();
    }
  }

  void _addWave() {
    final wm = widget.parsed.waveManager;
    if (wm is! WaveManagerData) return;
    wm.waves.add(<String>[]);
    wm.waveCount = wm.waves.length;
    _syncWaves();
    setState(() {});
  }

  void _removeEventFromWave(int waveIndex, String rtid) {
    final wm = widget.parsed.waveManager;
    if (wm is! WaveManagerData) return;
    if (waveIndex <= 0 || waveIndex > wm.waves.length) return;
    wm.waves[waveIndex - 1].remove(rtid);
    _syncWaves();
    setState(() {});
  }

  void _performGlobalRename(String oldRtid, String newAlias) {
    final wm = widget.parsed.waveManager;
    if (wm is! WaveManagerData) return;
    final oldAlias = LevelParser.extractAlias(oldRtid);
    if (oldAlias == newAlias) return;
    if (widget.levelFile.objects.any(
      (o) => o.aliases?.contains(newAlias) == true,
    )) {
      return;
    }
    final newRtid = RtidParser.build(newAlias, 'CurrentLevel');
    final objIdx = widget.levelFile.objects.indexWhere(
      (o) => o.aliases?.contains(oldAlias) == true,
    );
    if (objIdx >= 0) {
      widget.levelFile.objects[objIdx] = PvzObject(
        aliases: [newAlias],
        objClass: widget.levelFile.objects[objIdx].objClass,
        objData: widget.levelFile.objects[objIdx].objData,
      );
    }
    for (final wave in wm.waves) {
      for (var i = 0; i < wave.length; i++) {
        if (wave[i] == oldRtid) wave[i] = newRtid;
      }
    }
    _syncWaves();
    widget.onChanged();
    setState(() {});
  }

  void _performCopyReference(String rtid, Iterable<int> targetWaveIndexes) {
    final wm = widget.parsed.waveManager;
    if (wm is! WaveManagerData) return;
    var changed = false;
    for (final targetWaveIndex in targetWaveIndexes) {
      if (targetWaveIndex < 1 || targetWaveIndex > wm.waves.length) continue;
      final targetIdx = targetWaveIndex - 1;
      // Skip waves that already reference this event.
      if (wm.waves[targetIdx].contains(rtid)) continue;
      wm.waves[targetIdx] = [...wm.waves[targetIdx], rtid];
      changed = true;
    }
    if (!changed) return;
    _syncWaves();
    setState(() {});
  }

  void _performDeepCopy(
    String rtid,
    String newAlias,
    Iterable<int> targetWaveIndexes,
  ) {
    final wm = widget.parsed.waveManager;
    if (wm is! WaveManagerData) return;
    final targets = targetWaveIndexes
        .where((w) => w >= 1 && w <= wm.waves.length)
        .toList(growable: false);
    if (targets.isEmpty) return;

    final oldAlias = LevelParser.extractAlias(rtid);
    final obj = widget.levelFile.objects.firstWhereOrNull(
      (o) => o.aliases?.contains(oldAlias) == true,
    );
    if (obj == null) return;

    var changed = false;
    for (final targetWaveIndex in targets) {
      final targetIdx = targetWaveIndex - 1;
      // One independent deep copy per wave; aliases stay unique.
      final alias = PvzAliasUtils.uniqueAlias(widget.levelFile, newAlias);
      final newRtid = RtidParser.build(alias, 'CurrentLevel');
      // Skip if this wave somehow already references the new RTID.
      if (wm.waves[targetIdx].contains(newRtid)) continue;
      final dataCopy = obj.objData is Map
          ? jsonDecode(jsonEncode(obj.objData)) as Map<String, dynamic>
          : obj.objData;
      widget.levelFile.objects.add(
        PvzObject(aliases: [alias], objClass: obj.objClass, objData: dataCopy),
      );
      wm.waves[targetIdx] = [...wm.waves[targetIdx], newRtid];
      changed = true;
    }
    if (!changed) return;
    _syncWaves();
    widget.onChanged();
    setState(() {});
  }

  void _placeWaveEvent({
    required int sourceWaveIndex,
    required int sourceIndex,
    required int targetWaveIndex,
    int? insertBeforeIndex,
  }) {
    final wm = widget.parsed.waveManager;
    if (wm is! WaveManagerData) return;
    final srcIdx = sourceWaveIndex - 1;
    final tgtIdx = targetWaveIndex - 1;
    if (srcIdx < 0 ||
        srcIdx >= wm.waves.length ||
        tgtIdx < 0 ||
        tgtIdx >= wm.waves.length) {
      return;
    }
    final sourceWave = List<String>.from(wm.waves[srcIdx]);
    if (sourceIndex < 0 || sourceIndex >= sourceWave.length) return;
    final rtid = sourceWave.removeAt(sourceIndex);

    if (sourceWaveIndex == targetWaveIndex) {
      var insertAt = insertBeforeIndex ?? sourceWave.length;
      if (insertBeforeIndex != null && insertBeforeIndex > sourceIndex) {
        insertAt = insertBeforeIndex - 1;
      }
      insertAt = insertAt.clamp(0, sourceWave.length);
      sourceWave.insert(insertAt, rtid);
      wm.waves[srcIdx] = sourceWave;
    } else {
      final targetWave = List<String>.from(wm.waves[tgtIdx]);
      final insertAt = (insertBeforeIndex ?? targetWave.length).clamp(
        0,
        targetWave.length,
      );
      targetWave.insert(insertAt, rtid);
      wm.waves[srcIdx] = sourceWave;
      wm.waves[tgtIdx] = targetWave;
    }
    _syncWaves();
    setState(() {});
  }

  void _performMove(String rtid, int sourceWaveIndex, int targetWaveIndex) {
    final wm = widget.parsed.waveManager;
    if (wm is! WaveManagerData) return;
    if (sourceWaveIndex == targetWaveIndex) return;
    final srcIdx = sourceWaveIndex - 1;
    final tgtIdx = targetWaveIndex - 1;
    if (srcIdx < 0 ||
        srcIdx >= wm.waves.length ||
        tgtIdx < 0 ||
        tgtIdx >= wm.waves.length) {
      return;
    }
    final sourceIndex = wm.waves[srcIdx].indexOf(rtid);
    if (sourceIndex < 0) return;
    _placeWaveEvent(
      sourceWaveIndex: sourceWaveIndex,
      sourceIndex: sourceIndex,
      targetWaveIndex: targetWaveIndex,
      insertBeforeIndex: null,
    );
  }

  void _smartDeleteEvent(int waveIndex, String rtid) {
    final wm = widget.parsed.waveManager;
    if (wm is! WaveManagerData) return;
    final alias = LevelParser.extractAlias(rtid);
    final allRefs = wm.waves.expand((w) => w).toList();
    final refCount = allRefs.where((r) => r == rtid).length;
    if (refCount > 1) {
      _removeEventFromWave(waveIndex, rtid);
      return;
    }
    for (final wave in wm.waves) {
      wave.removeWhere((r) => r == rtid);
    }
    widget.levelFile.objects.removeWhere(
      (o) => o.aliases?.contains(alias) == true,
    );
    _syncWaves();
    setState(() {});
  }

  void _showRenameDialog(
    BuildContext context,
    String rtid,
    String alias,
    VoidCallback? onEditFinished,
  ) {
    final l10n = AppLocalizations.of(context);
    final wm = widget.parsed.waveManager;
    if (wm is! WaveManagerData) return;
    final ctrl = TextEditingController(text: alias);
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        scrollable: true,
        constraints: const BoxConstraints.tightFor(width: 560),
        title: Text(l10n?.rename ?? 'Rename'),
        content: SizedBox(
          width: double.maxFinite,
          child: EditorResponsiveInputField(
            label: l10n?.newName ?? 'New name',
            decoration: InputDecoration(),
            builder: (context, decoration) => TextField(
              controller: ctrl,
              decoration: decoration,
              onChanged: (_) {},
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(ctx).colorScheme.error,
            ),
            child: Text(l10n?.cancel ?? 'Cancel'),
          ),
          FilledButton(
            onPressed: () {
              final newAlias = ctrl.text.trim();
              Navigator.pop(ctx);
              if (newAlias.isEmpty) return;
              if (widget.levelFile.objects.any(
                (o) => o.aliases?.contains(newAlias) == true,
              )) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      l10n?.renameFail ?? 'Rename failed, alias already exists',
                    ),
                  ),
                );
                return;
              }
              _performGlobalRename(rtid, newAlias);
              onEditFinished?.call();
            },
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(ctx).colorScheme.primary,
              foregroundColor: Colors.white,
            ),
            child: Text(l10n?.confirm ?? 'Confirm'),
          ),
        ],
      ),
    );
  }

  Future<void> _showCopyChoiceDialog(
    BuildContext context,
    String rtid,
    String alias,
    int waveIndex,
    VoidCallback? onEditFinished,
  ) async {
    final l10n = AppLocalizations.of(context);
    final choice = await showEditorChoiceDialog<String>(
      context,
      title: l10n?.copy ?? 'Copy',
      message:
          l10n?.copyReferenceOrDeep ?? 'Copy reference or make a deep copy?',
      options: [
        EditorChoiceDialogOption(
          value: 'reference',
          icon: Icons.link,
          title: l10n?.copyReference ?? 'Copy reference',
        ),
        EditorChoiceDialogOption(
          value: 'independent',
          icon: Icons.copy,
          title: l10n?.deepCopy ?? 'Deep copy',
        ),
      ],
    );
    if (!mounted || !context.mounted || choice == null) return;
    if (choice == 'reference') {
      _showCopyTargetWaveDialog(context, rtid, null, waveIndex, onEditFinished);
    } else {
      _showDeepCopyNameDialog(context, rtid, alias, waveIndex, onEditFinished);
    }
  }

  void _showDeepCopyNameDialog(
    BuildContext context,
    String rtid,
    String alias,
    int waveIndex,
    VoidCallback? onEditFinished,
  ) {
    final l10n = AppLocalizations.of(context);
    final defaultName = '${alias}_copy';
    final ctrl = TextEditingController(text: defaultName);
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        scrollable: true,
        constraints: const BoxConstraints.tightFor(width: 560),
        title: Text(l10n?.deepCopy ?? 'Deep copy'),
        content: SizedBox(
          width: double.maxFinite,
          child: EditorResponsiveInputField(
            label: l10n?.newName ?? 'New name',
            decoration: InputDecoration(),
            builder: (context, decoration) =>
                TextField(controller: ctrl, decoration: decoration),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(ctx).colorScheme.error,
            ),
            child: Text(l10n?.cancel ?? 'Cancel'),
          ),
          FilledButton(
            onPressed: () {
              final newAlias = ctrl.text.trim();
              Navigator.pop(ctx);
              if (newAlias.isEmpty) return;
              if (widget.levelFile.objects.any(
                (o) => o.aliases?.contains(newAlias) == true,
              )) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      l10n?.renameFail ?? 'Rename failed, alias already exists',
                    ),
                  ),
                );
                return;
              }
              _showCopyTargetWaveDialog(
                context,
                rtid,
                newAlias,
                waveIndex,
                onEditFinished,
              );
            },
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(ctx).colorScheme.primary,
              foregroundColor: Colors.white,
            ),
            child: Text(l10n?.confirm ?? 'Confirm'),
          ),
        ],
      ),
    );
  }

  void _showCopyTargetWaveDialog(
    BuildContext context,
    String rtid,
    String? newAlias,
    int sourceWaveIndex,
    VoidCallback? onEditFinished,
  ) {
    final l10n = AppLocalizations.of(context);
    final wm = widget.parsed.waveManager;
    if (wm is! WaveManagerData) return;
    final selectedWaves = <int>{};
    final helperText =
        l10n?.targetWaveIndexHelper ??
        'When copying references, waves that already contain this event are automatically skipped.';
    showDialog<void>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) {
          final theme = Theme.of(ctx);
          return AlertDialog(
            key: const ValueKey('waveCopyTargetDialog'),
            scrollable: true,
            title: Text(l10n?.copyEventTarget ?? 'Select target waves'),
            content: SizedBox(
              width: 420,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    helperText,
                    softWrap: true,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 8),
                  for (var index = 0; index < wm.waves.length; index++)
                    CheckboxListTile(
                      key: ValueKey('waveCopyTarget-${index + 1}'),
                      contentPadding: EdgeInsets.zero,
                      controlAffinity: ListTileControlAffinity.leading,
                      value: selectedWaves.contains(index + 1),
                      onChanged: (selected) => setDialogState(() {
                        if (selected == true) {
                          selectedWaves.add(index + 1);
                        } else {
                          selectedWaves.remove(index + 1);
                        }
                      }),
                      title: Wrap(
                        spacing: 12,
                        runSpacing: 4,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          Text('${index + 1}'),
                          if (wm.waves[index].contains(rtid))
                            Text(
                              l10n?.targetWaveAlreadyContainsEvent ??
                                  'Already contains this event',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                style: TextButton.styleFrom(
                  foregroundColor: theme.colorScheme.error,
                ),
                child: Text(l10n?.cancel ?? 'Cancel'),
              ),
              FilledButton(
                key: const ValueKey('waveCopyTargetConfirm'),
                onPressed: selectedWaves.isEmpty
                    ? null
                    : () {
                        final targets = selectedWaves.toList()..sort();
                        Navigator.pop(ctx);
                        if (newAlias != null) {
                          _performDeepCopy(rtid, newAlias, targets);
                        } else {
                          _performCopyReference(rtid, targets);
                        }
                        onEditFinished?.call();
                      },
                style: FilledButton.styleFrom(
                  backgroundColor: theme.colorScheme.primary,
                  foregroundColor: Colors.white,
                ),
                child: Text(l10n?.copy ?? 'Copy'),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showMoveDialog(
    BuildContext context,
    String rtid,
    int waveIndex,
    VoidCallback? onEditFinished,
  ) {
    final l10n = AppLocalizations.of(context);
    final wm = widget.parsed.waveManager;
    if (wm is! WaveManagerData) return;
    final ctrl = TextEditingController(text: waveIndex.toString());
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        scrollable: true,
        constraints: const BoxConstraints.tightFor(width: 560),
        title: Text(l10n?.move ?? 'Move'),
        content: SizedBox(
          width: double.maxFinite,
          child: EditorResponsiveInputField(
            label: l10n?.moveToWaveIndex ?? 'Move to wave index',
            decoration: InputDecoration(),
            builder: (context, decoration) => TextField(
              controller: ctrl,
              decoration: decoration,
              keyboardType: TextInputType.number,
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(ctx).colorScheme.error,
            ),
            child: Text(l10n?.cancel ?? 'Cancel'),
          ),
          FilledButton(
            onPressed: () {
              final target = int.tryParse(ctrl.text.trim());
              Navigator.pop(ctx);
              if (target == null || target < 1 || target > wm.waves.length) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      l10n?.invalidWaveIndex ?? 'Invalid wave index',
                    ),
                  ),
                );
                return;
              }
              _performMove(rtid, waveIndex, target);
              onEditFinished?.call();
            },
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(ctx).colorScheme.primary,
              foregroundColor: Colors.white,
            ),
            child: Text(l10n?.move ?? 'Move'),
          ),
        ],
      ),
    );
  }

  void _showEventActionSheet({
    required BuildContext context,
    required int waveIndex,
    required String rtid,
    VoidCallback? onEditFinished,
  }) {
    final l10n = AppLocalizations.of(context);
    final alias = LevelParser.extractAlias(rtid);
    final obj = widget.parsed.objectMap[alias];
    final meta = EventRegistry.getByObjClass(obj?.objClass);
    final localizedTitle = meta != null
        ? EventSelectionScreen.resolveEventTitle(context, meta, l10n)
        : alias;
    final sheetTitle = meta != null && localizedTitle != alias
        ? '$alias ($localizedTitle)'
        : alias;
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (ctx) => EscapeClosesModal(
        child: SafeArea(
          top: false,
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.sizeOf(ctx).height * 0.9,
            ),
            child: SingleChildScrollView(
              key: const ValueKey('waveEventActionSheetScroll'),
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      if (meta != null) ...[
                        Icon(meta.icon, color: meta.color),
                        const SizedBox(width: 8),
                      ],
                      Expanded(
                        child: Text(
                          sheetTitle,
                          style: Theme.of(ctx).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (obj?.objClass != null)
                    Text(
                      obj!.objClass,
                      style: Theme.of(ctx).textTheme.bodySmall,
                    ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: FilledButton.icon(
                          onPressed: () async {
                            Navigator.pop(ctx);
                            await widget.onEditEvent(rtid, waveIndex);
                            // Do not re-open wave sheet when exiting event editor
                          },
                          icon: const Icon(Icons.edit),
                          label: Text(
                            l10n?.editProperties ?? 'Edit properties',
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final theme = Theme.of(ctx);
                      final scheme = theme.colorScheme;
                      final actionLabels = <String>[
                        l10n?.rename ?? 'Rename',
                        l10n?.copy ?? 'Copy',
                        l10n?.move ?? 'Move',
                      ];
                      final requiredRowWidth =
                          actionLabels
                              .map(
                                (label) => _requiredIconButtonWidth(ctx, label),
                              )
                              .fold<double>(0, (sum, width) => sum + width) +
                          16;
                      final compact = constraints.maxWidth < requiredRowWidth;

                      Widget actionButton({
                        required Key key,
                        required IconData icon,
                        required String label,
                        required VoidCallback onPressed,
                      }) {
                        return TextButton.icon(
                          key: key,
                          onPressed: onPressed,
                          style: TextButton.styleFrom(
                            minimumSize: const Size(0, 48),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 10,
                            ),
                            backgroundColor: scheme.primaryContainer,
                            foregroundColor: scheme.onPrimaryContainer,
                          ),
                          icon: Icon(icon),
                          label: Text(
                            label,
                            maxLines: 2,
                            softWrap: true,
                            textAlign: TextAlign.center,
                          ),
                        );
                      }

                      final buttons = <Widget>[
                        actionButton(
                          key: const ValueKey('waveEventRenameButton'),
                          icon: Icons.drive_file_rename_outline,
                          label: actionLabels[0],
                          onPressed: () => _showRenameDialog(
                            context,
                            rtid,
                            alias,
                            onEditFinished,
                          ),
                        ),
                        actionButton(
                          key: const ValueKey('waveEventCopyButton'),
                          icon: Icons.copy,
                          label: actionLabels[1],
                          onPressed: () => _showCopyChoiceDialog(
                            context,
                            rtid,
                            alias,
                            waveIndex,
                            onEditFinished,
                          ),
                        ),
                        actionButton(
                          key: const ValueKey('waveEventMoveButton'),
                          icon: Icons.drive_file_move,
                          label: actionLabels[2],
                          onPressed: () => _showMoveDialog(
                            context,
                            rtid,
                            waveIndex,
                            onEditFinished,
                          ),
                        ),
                      ];

                      if (compact) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            for (
                              var index = 0;
                              index < buttons.length;
                              index++
                            ) ...[
                              SizedBox(
                                width: double.infinity,
                                child: buttons[index],
                              ),
                              if (index != buttons.length - 1)
                                const SizedBox(height: 8),
                            ],
                          ],
                        );
                      }
                      return Row(
                        children: [
                          for (
                            var index = 0;
                            index < buttons.length;
                            index++
                          ) ...[
                            Expanded(child: buttons[index]),
                            if (index != buttons.length - 1)
                              const SizedBox(width: 8),
                          ],
                        ],
                      );
                    },
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: FilledButton.icon(
                          key: const ValueKey('waveEventRemoveButton'),
                          style: FilledButton.styleFrom(
                            backgroundColor: Theme.of(ctx).colorScheme.error,
                          ),
                          onPressed: () async {
                            Navigator.pop(ctx);
                            final ok = await showDialog<bool>(
                              context: context,
                              builder: (dctx) {
                                return AlertDialog(
                                  title: Text(
                                    l10n?.confirmRemoveRef ??
                                        'Remove reference',
                                  ),
                                  content: Text(
                                    l10n?.confirmRemoveRefMessage ??
                                        'Remove this reference? The entity data will remain until all references are removed.',
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () =>
                                          Navigator.pop(dctx, false),
                                      style: TextButton.styleFrom(
                                        foregroundColor: Theme.of(
                                          dctx,
                                        ).colorScheme.primary,
                                      ),
                                      child: Text(l10n?.cancel ?? 'Cancel'),
                                    ),
                                    FilledButton(
                                      onPressed: () =>
                                          Navigator.pop(dctx, true),
                                      style: FilledButton.styleFrom(
                                        backgroundColor: Theme.of(
                                          dctx,
                                        ).colorScheme.error,
                                        foregroundColor: Colors.white,
                                      ),
                                      child: Text(
                                        l10n?.confirmRemoveRef ??
                                            'Remove reference',
                                      ),
                                    ),
                                  ],
                                );
                              },
                            );
                            if (ok == true) {
                              _smartDeleteEvent(waveIndex, rtid);
                            }
                          },
                          icon: const Icon(Icons.remove_circle_outline),
                          label: Text(
                            l10n?.removeFromWave ?? 'Remove from wave',
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<bool> _showDeleteWaveConfirmDialog(
    BuildContext context,
    int waveIndex,
    int eventCount,
  ) async {
    final l10n = AppLocalizations.of(context);
    var confirm = false;
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: Text(
            (l10n?.deleteWave != null && l10n?.waveLabel != null)
                ? '${l10n?.deleteWave} ${l10n?.waveLabel} $waveIndex?'
                : 'Delete Wave $waveIndex?',
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n?.deleteWaveConfirm(eventCount) ??
                    'This will remove this wave and its $eventCount events.',
              ),
              const SizedBox(height: 16),
              CheckboxListTile(
                value: confirm,
                onChanged: (v) => setDialogState(() => confirm = v ?? false),
                title: Text(
                  l10n?.deleteWaveConfirmCheckbox ??
                      'I confirm permanent deletion of this wave',
                ),
                controlAffinity: ListTileControlAffinity.leading,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              style: TextButton.styleFrom(
                foregroundColor: Theme.of(ctx).colorScheme.error,
              ),
              child: Text(l10n?.cancel ?? 'Cancel'),
            ),
            FilledButton(
              onPressed: confirm ? () => Navigator.pop(ctx, true) : null,
              style: FilledButton.styleFrom(
                backgroundColor: Theme.of(ctx).colorScheme.error,
              ),
              child: Text(l10n?.delete ?? 'Delete'),
            ),
          ],
        ),
      ),
    );
    return result ?? false;
  }

  void _showWaveManageSheet(BuildContext context, int waveIndex) {
    final l10n = AppLocalizations.of(context);
    final wm = widget.parsed.waveManager;
    if (wm is! WaveManagerData) return;
    if (waveIndex <= 0 || waveIndex > wm.waves.length) return;
    final rtidList = wm.waves[waveIndex - 1];
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (ctx) => EscapeClosesModal(
        child: LayoutBuilder(
          builder: (ctx, viewport) {
            final theme = Theme.of(ctx);
            final title =
                l10n?.waveEventsTitle(waveIndex) ?? 'Wave $waveIndex events';
            final titleStyle = theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            );
            final contentWidth = (viewport.maxWidth - 32)
                .clamp(1, double.infinity)
                .toDouble();

            double textHeight(String text, TextStyle? style, double width) {
              final painter = TextPainter(
                text: TextSpan(text: text, style: style),
                textDirection: Directionality.of(ctx),
                textScaler: MediaQuery.textScalerOf(ctx),
              )..layout(maxWidth: width.clamp(1, double.infinity));
              return painter.height;
            }

            Widget eventCard(int i) {
              final rtid = rtidList[i];
              final alias = LevelParser.extractAlias(rtid);
              final obj = widget.parsed.objectMap[alias];
              final meta = EventRegistry.getByObjClass(obj?.objClass);
              final color = meta?.color ?? Theme.of(ctx).colorScheme.primary;
              final displayTitle = EventSelectionScreen.resolveEventTitle(
                ctx,
                meta,
                l10n,
              );
              return Card(
                key: ValueKey('waveManageEvent-$i'),
                margin: const EdgeInsets.only(bottom: 8),
                child: EditorOptionTile(
                  leading: Icon(meta?.icon ?? Icons.event, color: color),
                  title: Text(alias),
                  subtitle: Text(
                    displayTitle.isNotEmpty
                        ? displayTitle
                        : (meta?.titleKey ?? 'Unknown event'),
                  ),
                  onTap: () {
                    Navigator.pop(ctx);
                    _showEventActionSheet(
                      context: context,
                      waveIndex: waveIndex,
                      rtid: rtid,
                      onEditFinished: () =>
                          _showWaveManageSheet(context, waveIndex),
                    );
                  },
                  trailing: IconButton(
                    icon: const Icon(Icons.delete_outline),
                    onPressed: () async {
                      Navigator.pop(ctx);
                      final ok = await showDialog<bool>(
                        context: context,
                        builder: (dctx) => AlertDialog(
                          title: Text(
                            l10n?.confirmRemoveRef ?? 'Remove reference',
                          ),
                          content: Text(
                            l10n?.confirmRemoveRefMessage ??
                                'Remove this reference? The entity data will remain until all references are removed.',
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(dctx, false),
                              style: TextButton.styleFrom(
                                foregroundColor: Theme.of(
                                  dctx,
                                ).colorScheme.primary,
                              ),
                              child: Text(l10n?.cancel ?? 'Cancel'),
                            ),
                            FilledButton(
                              onPressed: () => Navigator.pop(dctx, true),
                              style: FilledButton.styleFrom(
                                backgroundColor: Theme.of(
                                  dctx,
                                ).colorScheme.error,
                                foregroundColor: Colors.white,
                              ),
                              child: Text(
                                l10n?.confirmRemoveRef ?? 'Remove reference',
                              ),
                            ),
                          ],
                        ),
                      );
                      if (ok == true) {
                        _smartDeleteEvent(waveIndex, rtid);
                        setState(() {});
                      }
                    },
                  ),
                ),
              );
            }

            final addLabel = l10n?.addEvent ?? 'Add event';
            final reuseLabel = l10n?.reuseExistingEvent ?? 'Reuse event';
            final addButton = OutlinedButton.icon(
              key: const ValueKey('waveManageAddEventButton'),
              onPressed: () {
                Navigator.pop(ctx);
                widget.onAddEvent(waveIndex);
              },
              icon: const Icon(Icons.add),
              label: Text(addLabel, textAlign: TextAlign.center),
            );
            final reuseButton = OutlinedButton.icon(
              key: const ValueKey('waveManageReuseEventButton'),
              onPressed: () {
                Navigator.pop(ctx);
                _openReuseExistingEvent(waveIndex);
              },
              icon: const Icon(Icons.link),
              label: Text(reuseLabel, textAlign: TextAlign.center),
            );
            final outlinedStyle =
                (OutlinedButtonTheme.of(ctx).style ?? const ButtonStyle())
                    .merge(addButton.defaultStyleOf(ctx));
            final addSize = _waveManageButtonSize(
              ctx,
              outlinedStyle,
              addLabel,
              contentWidth,
            );
            final reuseSize = _waveManageButtonSize(
              ctx,
              outlinedStyle,
              reuseLabel,
              contentWidth,
            );
            // The row uses equal-width buttons, so both halves must fit the
            // longer label, including the active theme and system text scale.
            final requiredButtonWidth = addSize.width > reuseSize.width
                ? addSize.width
                : reuseSize.width;
            final stackedActions = contentWidth < requiredButtonWidth * 2 + 8;
            final actionWidth = stackedActions
                ? contentWidth
                : (contentWidth - 8) / 2;
            final addHeight = _waveManageButtonSize(
              ctx,
              outlinedStyle,
              addLabel,
              actionWidth,
            ).height;
            final reuseHeight = _waveManageButtonSize(
              ctx,
              outlinedStyle,
              reuseLabel,
              actionWidth,
            ).height;
            final actionHeight = stackedActions
                ? addHeight + reuseHeight + 8
                : (addHeight > reuseHeight ? addHeight : reuseHeight);

            final deleteLabel = l10n?.deleteWave ?? 'Delete wave';
            final deleteButton = FilledButton.icon(
              key: const ValueKey('waveManageDeleteWaveButton'),
              style: FilledButton.styleFrom(
                backgroundColor: theme.colorScheme.error,
                foregroundColor: theme.colorScheme.onError,
              ),
              onPressed: () async {
                Navigator.pop(ctx);
                final ok = await _showDeleteWaveConfirmDialog(
                  context,
                  waveIndex,
                  rtidList.length,
                );
                if (ok == true && mounted) {
                  final wm = widget.parsed.waveManager;
                  if (wm is WaveManagerData &&
                      waveIndex >= 1 &&
                      waveIndex <= wm.waves.length) {
                    wm.waves.removeAt(waveIndex - 1);
                    wm.waveCount = wm.waves.length;
                    _syncWaves();
                    setState(() {});
                  }
                }
              },
              icon: const Icon(Icons.delete),
              label: Text(deleteLabel, textAlign: TextAlign.center),
            );
            final filledStyle = (deleteButton.style ?? const ButtonStyle())
                .merge(FilledButtonTheme.of(ctx).style)
                .merge(deleteButton.defaultStyleOf(ctx));
            final deleteHeight = _waveManageButtonSize(
              ctx,
              filledStyle,
              deleteLabel,
              contentWidth,
            ).height;
            final actions = Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (stackedActions) ...[
                  addButton,
                  const SizedBox(height: 8),
                  reuseButton,
                ] else
                  Row(
                    children: [
                      Expanded(child: addButton),
                      const SizedBox(width: 8),
                      Expanded(child: reuseButton),
                    ],
                  ),
                const SizedBox(height: 12),
                deleteButton,
              ],
            );

            final titleHeight = textHeight(title, titleStyle, contentWidth);
            final tileTheme = ListTileTheme.of(ctx);
            final tilePadding =
                (tileTheme.contentPadding ??
                        const EdgeInsetsDirectional.fromSTEB(16, 0, 24, 0))
                    .resolve(Directionality.of(ctx));
            final tileTextWidth =
                contentWidth -
                tilePadding.horizontal -
                (tileTheme.minLeadingWidth ?? 40) -
                (tileTheme.horizontalTitleGap ?? 16) * 2 -
                48;
            final visibleEventHeights = <double>[];
            for (final rtid in rtidList.take(3)) {
              final alias = LevelParser.extractAlias(rtid);
              final meta = EventRegistry.getByObjClass(
                widget.parsed.objectMap[alias]?.objClass,
              );
              final localizedTitle = EventSelectionScreen.resolveEventTitle(
                ctx,
                meta,
                l10n,
              );
              final subtitle = localizedTitle.isNotEmpty
                  ? localizedTitle
                  : (meta?.titleKey ?? 'Unknown event');
              final textExtent =
                  textHeight(
                    alias,
                    tileTheme.titleTextStyle ?? theme.textTheme.bodyLarge,
                    tileTextWidth,
                  ) +
                  textHeight(
                    subtitle,
                    tileTheme.subtitleTextStyle ?? theme.textTheme.bodyMedium,
                    tileTextWidth,
                  ) +
                  24;
              visibleEventHeights.add(
                textExtent.clamp(72, double.infinity) + 8,
              );
            }
            final firstEventHeight = visibleEventHeights.isEmpty
                ? 96.0
                : visibleEventHeights.first;
            final desiredEventHeight = visibleEventHeights.isEmpty
                ? 96.0
                : visibleEventHeights.fold<double>(
                    0,
                    (sum, height) => sum + height,
                  );
            final fixedInnerContentHeight =
                titleHeight + 12 + 8 + actionHeight + 12 + deleteHeight;
            final fixedContentHeight =
                fixedInnerContentHeight + 24 + MediaQuery.paddingOf(ctx).bottom;
            final availableHeight = viewport.maxHeight;
            final desiredHeight = fixedContentHeight + desiredEventHeight;
            final initialSize = (desiredHeight / availableHeight).clamp(
              rtidList.isEmpty ? 0.5 : 0.7,
              0.9,
            );

            return DraggableScrollableSheet(
              key: const ValueKey('waveManageSheet'),
              initialChildSize: initialSize,
              minChildSize: 0.25,
              maxChildSize: 0.9,
              expand: false,
              builder: (ctx2, scrollController) => SafeArea(
                top: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                  child: LayoutBuilder(
                    builder: (ctx2, contentConstraints) {
                      final heading = Text(title, style: titleStyle);
                      final empty = Center(
                        child: Text(
                          l10n?.emptyWave ?? 'Empty wave',
                          style: theme.textTheme.bodySmall,
                        ),
                      );
                      // On a short landscape window, keeping the action area
                      // fixed would leave no usable event list. Let all content
                      // scroll together while retaining the sheet's controller.
                      // The inner constraints already exclude bottom padding
                      // and SafeArea, so only compare against inner content.
                      if (contentConstraints.maxHeight <
                          fixedInnerContentHeight + firstEventHeight) {
                        return CustomScrollView(
                          key: const ValueKey('waveManageSheetScroll'),
                          controller: scrollController,
                          slivers: [
                            SliverToBoxAdapter(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [heading, const SizedBox(height: 12)],
                              ),
                            ),
                            if (rtidList.isEmpty)
                              SliverToBoxAdapter(
                                child: SizedBox(height: 96, child: empty),
                              )
                            else
                              SliverList.builder(
                                itemCount: rtidList.length,
                                itemBuilder: (_, i) => eventCard(i),
                              ),
                            SliverFillRemaining(
                              hasScrollBody: false,
                              child: Align(
                                alignment: Alignment.bottomCenter,
                                child: Padding(
                                  padding: const EdgeInsets.only(top: 8),
                                  child: actions,
                                ),
                              ),
                            ),
                          ],
                        );
                      }
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          heading,
                          const SizedBox(height: 12),
                          Expanded(
                            child: ListView.builder(
                              key: const ValueKey('waveManageEventList'),
                              controller: scrollController,
                              itemCount: rtidList.isEmpty ? 1 : rtidList.length,
                              itemBuilder: (_, i) => rtidList.isEmpty
                                  ? SizedBox(height: 96, child: empty)
                                  : eventCard(i),
                            ),
                          ),
                          const SizedBox(height: 8),
                          actions,
                        ],
                      );
                    },
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final wm = widget.parsed.waveManager is WaveManagerData
        ? widget.parsed.waveManager as WaveManagerData
        : null;
    final module = widget.parsed.waveModule is WaveManagerModuleData
        ? widget.parsed.waveModule as WaveManagerModuleData
        : null;
    final objectMap = widget.parsed.objectMap;

    if (wm == null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.inbox,
                size: 64,
                color: Theme.of(context).colorScheme.outline,
              ),
              const SizedBox(height: 16),
              Text(
                l10n?.noWaveManager ?? 'No wave manager found',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.outline,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                l10n?.noWaveManagerHint ??
                    'This level has wave management but no WaveManagerProperties object.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.outline,
                ),
                textAlign: TextAlign.center,
              ),
              if (widget.onCreateContainer != null) ...[
                const SizedBox(height: 24),
                EditorFilledButton(
                  onPressed: widget.onCreateContainer,
                  icon: const Icon(Icons.add),
                  label: Text(
                    l10n?.createEmptyWaveContainer ??
                        'Create empty wave container',
                  ),
                ),
              ],
            ],
          ),
        ),
      );
    }

    final waves = wm.waves;
    final seeingStars = readSeeingStarsModuleData(widget.levelFile);
    final interval = wm.flagWaveInterval <= 0 ? 10 : wm.flagWaveInterval;

    final deadLinks = wm.waves
        .expand((w) => w)
        .toSet()
        .where((rtid) => !objectMap.containsKey(LevelParser.extractAlias(rtid)))
        .toList();
    final customZombies = _collectCustomZombies();
    final customFishes = _collectCustomFishes();
    final isDeepSeaLawn = LevelParser.isDeepSeaLawnFromFile(widget.levelFile);

    return ListView(
      padding: const EdgeInsets.only(bottom: 16),
      children: [
        _buildHintCard(context),
        if (deadLinks.isNotEmpty) _buildDeadLinksCard(context, deadLinks),
        _buildCustomZombieCard(context, customZombies),
        if (isDeepSeaLawn) _buildCustomFishCard(context, customFishes),
        _buildWaveContainerAliasCard(context),
        _buildWaveManagerSettingsCard(
          context,
          interval,
          wm.minNextWaveHealthPercentage,
          wm.maxNextWaveHealthPercentage,
        ),
        InitialKongfuGridItemsCard(
          levelFile: widget.levelFile,
          onOpenModule: widget.onOpenModule,
        ),
        const SizedBox(height: 16),
        if (waves.isEmpty)
          _buildEmptyWaveCard(context)
        else ...[
          _buildWaveHeaderRow(context, waves.length),
          ...List.generate(waves.length, (index) {
            final waveIndex = index + 1;
            final waveEvents = waves[index];
            final isFlagWave =
                waveIndex % interval == 0 || waveIndex == waves.length;
            final points = module != null
                ? _pointsAtWave(module, waveIndex, isFlagWave)
                : 0;
            final l10n = AppLocalizations.of(context);
            final actionButtons = <({String label, VoidCallback onTap})>[];
            if (points != 0) {
              actionButtons.add((
                label: l10n?.wavePointsShort(points) ?? '$points pts.',
                onTap: () => _showExpectationDialog(context, waveIndex, points),
              ));
            }
            if (_waveHasRenaiActivity(waveIndex)) {
              actionButtons.add((
                label: l10n?.renaiModuleExpectationLabel ?? 'Renai',
                onTap: () => _showRenaiInfoDialog(context, waveIndex),
              ));
            }
            if (_waveHasLunarMineVeinActivity(waveIndex)) {
              actionButtons.add((
                label:
                    l10n?.lunarMineVeinModuleExpectationLabel ?? 'Lunar Veins',
                onTap: () => _showLunarMineVeinInfoDialog(context, waveIndex),
              ));
            }
            final gladiator = readGladiatorRowModuleData(widget.levelFile);
            if (gladiator != null &&
                gladiatorEncountersForWave(gladiator, waveIndex).isNotEmpty) {
              actionButtons.add((
                label:
                    l10n?.moduleTitle_GladiatorRowModuleProperties ??
                    'Gladiatorial Row',
                onTap: () => showGladiatorRowWavePreviewDialog(
                  context,
                  levelFile: widget.levelFile,
                  waveIndex: waveIndex,
                  data: gladiator,
                  onOpenModuleSettings: widget.onOpenModule == null
                      ? null
                      : () => openModuleWithHint(
                          widget.onOpenModule,
                          widget.levelFile,
                          'GladiatorRowModuleProperties',
                          hint: ModuleOpenHint(gladiatorWave: waveIndex - 1),
                        ),
                ),
              ));
            }
            if (_waveHasRadiationMeteorActivity(waveIndex)) {
              actionButtons.add((
                label:
                    l10n?.radiationMeteorModuleExpectationLabel ??
                    'Radioactive Meteorite',
                onTap: () => _showRadiationMeteorInfoDialog(context, waveIndex),
              ));
            }
            if (seeingStars != null && seeingStars.cycleIndex == index) {
              actionButtons.add((
                label: l10n?.seeingStarsCycleWaveBadge ?? 'Wave loop',
                onTap: () => showSeeingStarsWavePreviewDialog(
                  context,
                  waveIndex: waveIndex,
                  onOpenModuleSettings: widget.onOpenModule == null
                      ? null
                      : () => openModuleWithHint(
                          widget.onOpenModule,
                          widget.levelFile,
                          'PVZ1SeeingStarsModuleProperties',
                        ),
                ),
              ));
            }
            if (_waveHasDropShipActivity(waveIndex)) {
              actionButtons.add((
                label: l10n?.airDropShipModuleExpectationLabel ?? 'Imp drops',
                onTap: () => _showDropShipInfoDialog(context, waveIndex),
              ));
            }
            if (_waveHasHeianWindActivity(waveIndex)) {
              actionButtons.add((
                label: l10n?.heianWindModuleExpectationLabel ?? 'Heian wind',
                onTap: () => _showHeianWindInfoDialog(context, waveIndex),
              ));
            }
            final rowWidget = _buildWaveRowItem(
              context,
              waveIndex: waveIndex,
              isFlagWave: isFlagWave,
              rtidList: waveEvents,
              objectMap: objectMap,
              actionButtons: actionButtons,
              onRowTap: () => _showWaveManageSheet(context, waveIndex),
            );
            return rowWidget;
          }),
        ],
        Padding(
          padding: const EdgeInsets.fromLTRB(32, 32, 32, 16),
          child: Center(
            child: EditorFilledButton(
              onPressed: _addWave,
              icon: const Icon(Icons.add),
              label: Text(l10n?.addWave ?? 'Add wave'),
            ),
          ),
        ),
      ],
    );
  }

  bool _waveHasRenaiActivity(int waveIndex) {
    final renai = _getRenaiModuleData();
    if (renai == null) return false;
    return renaiWaveHasPreviewActivity(renai, waveIndex);
  }

  bool _waveHasLunarMineVeinActivity(int waveIndex) {
    final data = _getLunarMineVeinModuleData();
    if (data == null) return false;
    return lunarMineVeinWaveHasPreviewActivity(data, waveIndex);
  }

  bool _waveHasRadiationMeteorActivity(int waveIndex) {
    final data = _getRadiationMeteorModuleData();
    if (data == null) return false;
    return radiationMeteorWaveHasPreviewActivity(data, waveIndex);
  }

  LunarMineVeinModulePropertiesData? _getLunarMineVeinModuleData() {
    final obj = widget.levelFile.objects.firstWhereOrNull(
      (o) => o.objClass == 'LunarMineVeinModuleProperties',
    );
    if (obj?.objData is Map<String, dynamic>) {
      try {
        return LunarMineVeinModulePropertiesData.fromJson(
          obj!.objData as Map<String, dynamic>,
        );
      } catch (_) {}
    }
    return null;
  }

  RadiationMeteorModulePropertiesData? _getRadiationMeteorModuleData() {
    final obj = widget.levelFile.objects.firstWhereOrNull(
      (o) => o.objClass == 'RadiationMeteorModuleProperties',
    );
    if (obj?.objData is Map<String, dynamic>) {
      try {
        return RadiationMeteorModulePropertiesData.fromJson(
          obj!.objData as Map<String, dynamic>,
        );
      } catch (_) {}
    }
    return null;
  }

  void _showLunarMineVeinInfoDialog(BuildContext context, int waveIndex) {
    final data = _getLunarMineVeinModuleData();
    if (data == null) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!context.mounted) return;
      showLunarMineVeinWavePreviewDialog(
        context,
        levelFile: widget.levelFile,
        waveIndex: waveIndex,
        data: data,
        onOpenModuleSettings: widget.onOpenModule == null
            ? null
            : () => openModuleWithHint(
                widget.onOpenModule,
                widget.levelFile,
                'LunarMineVeinModuleProperties',
              ),
      );
    });
  }

  void _showRadiationMeteorInfoDialog(BuildContext context, int waveIndex) {
    final data = _getRadiationMeteorModuleData();
    if (data == null) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!context.mounted) return;
      showRadiationMeteorWavePreviewDialog(
        context,
        levelFile: widget.levelFile,
        waveIndex: waveIndex,
        data: data,
        onOpenModuleSettings: widget.onOpenModule == null
            ? null
            : () => openModuleWithHint(
                widget.onOpenModule,
                widget.levelFile,
                'RadiationMeteorModuleProperties',
              ),
      );
    });
  }

  String? _getModuleRtid(String objClass) {
    final obj = widget.levelFile.objects.firstWhereOrNull(
      (o) => o.objClass == objClass,
    );
    final alias = obj?.aliases?.firstOrNull;
    if (alias == null) return null;
    return RtidParser.build(alias, 'CurrentLevel');
  }

  RenaiModulePropertiesData? _getRenaiModuleData() {
    final obj = widget.levelFile.objects.firstWhereOrNull(
      (o) => o.objClass == 'RenaiModuleProperties',
    );
    if (obj?.objData is Map<String, dynamic>) {
      try {
        return RenaiModulePropertiesData.fromJson(
          obj!.objData as Map<String, dynamic>,
        );
      } catch (_) {}
    }
    return null;
  }

  DropShipPropertiesData? _getDropShipModuleData() {
    final obj = widget.levelFile.objects.firstWhereOrNull(
      (o) => o.objClass == 'DropShipProperties',
    );
    if (obj?.objData is Map<String, dynamic>) {
      try {
        return DropShipPropertiesData.fromJson(
          obj!.objData as Map<String, dynamic>,
        );
      } catch (_) {}
    }
    return null;
  }

  bool _waveHasDropShipActivity(int waveIndex) {
    final dropShip = _getDropShipModuleData();
    if (dropShip == null) return false;
    return dropShip.appearWaves.any((w) => w.wave + 1 == waveIndex);
  }

  HeianWindModulePropertiesData? _getHeianWindModuleData() {
    final obj = widget.levelFile.objects.firstWhereOrNull(
      (o) => o.objClass == 'HeianWindModuleProperties',
    );
    if (obj?.objData is Map<String, dynamic>) {
      try {
        return HeianWindModulePropertiesData.fromJson(
          obj!.objData as Map<String, dynamic>,
        );
      } catch (_) {}
    }
    return null;
  }

  bool _waveHasHeianWindActivity(int waveIndex) {
    final heianWind = _getHeianWindModuleData();
    if (heianWind == null) return false;
    return heianWind.waveWindInfos.any((w) => w.waveNumber + 1 == waveIndex);
  }

  void _showHeianWindInfoDialog(BuildContext context, int waveIndex) {
    final heianWind = _getHeianWindModuleData();
    if (heianWind == null) return;
    final waves = heianWind.waveWindInfos
        .where((w) => w.waveNumber + 1 == waveIndex)
        .toList();
    if (waves.isEmpty) return;
    showHeianWindWavePreviewDialog(
      context,
      waveIndex: waveIndex,
      waves: waves,
      onOpenModuleSettings: widget.onOpenModule == null
          ? null
          : () => openModuleWithHint(
              widget.onOpenModule,
              widget.levelFile,
              'HeianWindModuleProperties',
              hint: ModuleOpenHint(heianWindWaveNumber: waveIndex - 1),
            ),
    );
  }

  void _showDropShipInfoDialog(BuildContext context, int waveIndex) {
    final dropShip = _getDropShipModuleData();
    if (dropShip == null) return;
    final waves = dropShip.appearWaves
        .where((w) => w.wave + 1 == waveIndex)
        .toList();
    if (waves.isEmpty) return;
    showDropShipWavePreviewDialog(
      context,
      levelFile: widget.levelFile,
      waveIndex: waveIndex,
      waves: waves,
      onOpenModuleSettings: widget.onOpenModule == null
          ? null
          : () => openModuleWithHint(
              widget.onOpenModule,
              widget.levelFile,
              'DropShipProperties',
              hint: ModuleOpenHint(dropShipWave: waves.first.wave),
            ),
    );
  }

  void _showExpectationDialog(BuildContext context, int waveIndex, int points) {
    final l10n = AppLocalizations.of(context);
    final expectation = WavePointAnalysis.calculateExpectation(
      points,
      widget.parsed,
    );
    final sorted = expectation.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final items = sorted.where((e) => e.value > 0).toList();
    showDialog<void>(
      context: context,
      builder: (ctx) {
        final scrollController = ScrollController();
        final iconSize = _expectationDialogIconSize(ctx);
        final listSize = _expectationDialogListSize(ctx);
        return AlertDialog(
          title: Text(
            '${l10n?.waveLabel ?? "Wave"} $waveIndex ${l10n?.expectation ?? "Expectation"}',
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('${l10n?.pointsLabel ?? "Points"}: $points'),
              const SizedBox(height: 16),
              if (items.isEmpty)
                Text(
                  l10n?.noDynamicZombies ?? 'No dynamic zombies',
                  style: Theme.of(ctx).textTheme.bodySmall,
                )
              else
                SizedBox(
                  width: listSize.width,
                  height: listSize.height,
                  child: Scrollbar(
                    controller: scrollController,
                    thumbVisibility: true,
                    child: ListView.builder(
                      controller: scrollController,
                      padding: const EdgeInsets.only(right: 14),
                      itemCount: items.length,
                      itemBuilder: (_, i) {
                        final e = items[i];
                        final typeName = e.key;
                        final info = ZombieRepository().getZombieById(typeName);
                        final nameKey =
                            info?.name ?? ZombieRepository().getName(typeName);
                        final displayName = ResourceNames.lookup(ctx, nameKey);
                        final iconPath =
                            info?.iconAssetPath ?? _kUnknownIconPath;
                        return Padding(
                          padding: EdgeInsets.symmetric(
                            vertical: isDesktopPlatform(ctx) ? 5 : 4,
                          ),
                          child: Row(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: ColoredBox(
                                  color: Theme.of(
                                    ctx,
                                  ).colorScheme.surfaceContainerHighest,
                                  child: SizedBox(
                                    width: iconSize,
                                    height: iconSize,
                                    child: AssetImageWidget(
                                      assetPath: iconPath,
                                      altCandidates: imageAltCandidates(
                                        iconPath,
                                      ),
                                      width: iconSize,
                                      height: iconSize,
                                      fit: BoxFit.contain,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      displayName.isNotEmpty
                                          ? displayName
                                          : typeName,
                                      overflow: TextOverflow.ellipsis,
                                      style: Theme.of(ctx).textTheme.bodyMedium
                                          ?.copyWith(
                                            fontWeight: FontWeight.w500,
                                          ),
                                    ),
                                    Text(
                                      typeName,
                                      overflow: TextOverflow.ellipsis,
                                      style: Theme.of(ctx).textTheme.bodySmall
                                          ?.copyWith(
                                            color: Theme.of(
                                              ctx,
                                            ).colorScheme.onSurfaceVariant,
                                          ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                e.value.toStringAsFixed(2),
                                style: Theme.of(ctx).textTheme.bodyMedium,
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ),
            ],
          ),
          actions: [
            if (widget.onOpenModule != null)
              FilledButton(
                style: FilledButton.styleFrom(backgroundColor: Colors.green),
                onPressed: () {
                  final rtid = _getModuleRtid('WaveManagerModuleProperties');
                  if (rtid != null) {
                    Navigator.pop(ctx);
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      widget.onOpenModule!(rtid);
                    });
                  }
                },
                child: Text(l10n?.openModuleSettings ?? 'Open module settings'),
              ),
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(l10n?.close ?? 'Close'),
            ),
          ],
        );
      },
    );
  }
}

class _CustomZombieUsage {
  const _CustomZombieUsage({
    required this.alias,
    required this.rtid,
    required this.isUnused,
    required this.waveIndices,
  });

  final String alias;
  final String rtid;
  final bool isUnused;
  final List<int> waveIndices;
}

class _CustomFishUsage {
  const _CustomFishUsage({
    required this.alias,
    required this.rtid,
    required this.isUnused,
    required this.waveIndices,
  });

  final String alias;
  final String rtid;
  final bool isUnused;
  final List<int> waveIndices;
}
