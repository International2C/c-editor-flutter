import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:c_editor/data/level_parser.dart';
import 'package:c_editor/data/pvz_models.dart';
import 'package:c_editor/l10n/app_localizations.dart';
import 'package:c_editor/widgets/editor_components.dart';
import 'package:c_editor/widgets/editor_object_alias.dart';

/// Fairy tale fog event editor. Ported from Z-Editor-master FairyTaleFogWaveActionPropsEP.kt
class FairyTaleFogEventScreen extends StatefulWidget {
  const FairyTaleFogEventScreen({
    super.key,
    required this.rtid,
    required this.levelFile,
    required this.onChanged,
    required this.onBack,
  });

  final String rtid;
  final PvzLevelFile levelFile;
  final VoidCallback onChanged;
  final VoidCallback onBack;

  @override
  State<FairyTaleFogEventScreen> createState() =>
      _FairyTaleFogEventScreenState();
}

class _FairyTaleFogEventScreenState extends State<FairyTaleFogEventScreen> {
  static const _objClass = 'FairyTaleFogWaveActionProps';

  late PvzObject _moduleObj;
  late FairyTaleFogWaveActionData _data;
  late String _alias;

  bool get _isDeepSeaLawn {
    final parsed = LevelParser.parseLevel(widget.levelFile);
    return LevelParser.isDeepSeaLawn(parsed.levelDef, widget.levelFile);
  }

  int get _gridCols => _isDeepSeaLawn ? 10 : 9;
  int get _gridRows => _isDeepSeaLawn ? 6 : 5;

  static const _fogOptions = [
    ('fairy_tale_fog_lvl1', 1),
    ('fairy_tale_fog_lvl2', 2),
    ('fairy_tale_fog_lvl3', 3),
  ];

  @override
  void initState() {
    super.initState();
    _alias = aliasFromRtid(widget.rtid);
    _loadData();
  }

  void _loadData() {
    final alias = _alias;
    final existing = widget.levelFile.objects.firstWhereOrNull(
      (o) => o.aliases?.contains(alias) == true,
    );
    if (existing != null) {
      _moduleObj = existing;
    } else {
      _moduleObj = PvzObject(
        aliases: [alias],
        objClass: _objClass,
        objData: FairyTaleFogWaveActionData().toJson(),
      );
      widget.levelFile.objects.add(_moduleObj);
    }
    try {
      _data = FairyTaleFogWaveActionData.fromJson(
        Map<String, dynamic>.from(_moduleObj.objData as Map),
      );
    } catch (_) {
      _data = FairyTaleFogWaveActionData();
    }
  }

  void _sync() {
    _moduleObj.objData = _data.toJson();
    widget.onChanged();
    setState(() {});
  }

  bool _isCellInFog(int col, int row) {
    final r = _data.range;
    return col >= r.mX &&
        col < r.mX + r.mWidth &&
        row >= r.mY &&
        row < r.mY + r.mHeight;
  }

  void _handleAliasChanged(String newAlias) {
    renameLevelObjectAlias(
      levelFile: widget.levelFile,
      oldAlias: _alias,
      newAlias: newAlias,
      onChanged: widget.onChanged,
    );
    setState(() => _alias = newAlias);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    final eventTitle = resolveEventTitleByObjClass(context, _objClass, l10n);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: widget.onBack,
        ),
        title: buildEditorObjectAppBarTitle(
          context: context,
          localizedName: eventTitle,
          isEvent: true,
          objClass: _objClass,
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.help_outline),
            onPressed: () => showEditorHelpDialog(
              context,
              isEvent: true,
              title: l10n?.eventFairyFog ?? 'Fairy fog event',
              sections: [
                HelpSectionData(
                  title: l10n?.overview ?? 'Overview',
                  body: l10n?.eventHelpFairyFogBody ?? '',
                ),
                HelpSectionData(
                  title: l10n?.range ?? 'Range',
                  body: l10n?.eventHelpFairyFogRange ?? '',
                ),
              ],
            ),
          ),
        ],
      ),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              EditorAliasInputField(
                alias: _alias,
                levelFile: widget.levelFile,
                onAliasChanged: _handleAliasChanged,
                onChanged: widget.onChanged,
              ),
              const SizedBox(height: 16),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n?.mistParameters ?? 'Fog parameters',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      EditorResponsiveInputField(
                        label: l10n?.fairyFogType ?? 'Fog type (FogType)',
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                        ),
                        builder: (context, decoration) =>
                            DropdownButtonFormField<String>(
                              isExpanded: true,
                              initialValue:
                                  _fogOptions.any((e) => e.$1 == _data.fogType)
                                  ? _data.fogType
                                  : null,
                              decoration: decoration,
                              items: _fogOptions
                                  .map(
                                    (e) => DropdownMenuItem(
                                      value: e.$1,
                                      child: Text(
                                        l10n?.fairyFogLevel(e.$2) ??
                                            'Level ${e.$2}',
                                      ),
                                    ),
                                  )
                                  .toList(),
                              onChanged: (v) {
                                if (v != null) {
                                  _data = FairyTaleFogWaveActionData(
                                    movingTime: _data.movingTime,
                                    fogType: v,
                                    range: _data.range,
                                  );
                                  _sync();
                                }
                              },
                            ),
                      ),
                      const SizedBox(height: 12),
                      EditorResponsiveInputField(
                        label:
                            l10n?.fairyFogMovingTime ??
                            'Moving time (MovingTime; seconds)',
                        builder: (context, decoration) => TextFormField(
                          initialValue: _data.movingTime.toString(),
                          decoration: decoration,
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          onChanged: (v) {
                            final n = double.tryParse(v);
                            if (n != null) {
                              _data = FairyTaleFogWaveActionData(
                                movingTime: n,
                                fogType: _data.fogType,
                                range: _data.range,
                              );
                              _sync();
                            }
                          },
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        l10n?.range ?? 'Range',
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      EditorResponsiveFieldRow(
                        children: [
                          Expanded(
                            child: EditorResponsiveInputField(
                              label:
                                  l10n?.fairyFogRangeX ??
                                  'Starting column (mX; 0-based)',
                              decoration: const InputDecoration(
                                border: OutlineInputBorder(),
                              ),
                              builder: (context, decoration) => TextFormField(
                                initialValue: _data.range.mX.toString(),
                                decoration: decoration,
                                keyboardType: TextInputType.number,
                                onChanged: (v) {
                                  final n = int.tryParse(v);
                                  if (n != null) {
                                    _data = FairyTaleFogWaveActionData(
                                      movingTime: _data.movingTime,
                                      fogType: _data.fogType,
                                      range: FogRangeData(
                                        mX: n,
                                        mY: _data.range.mY,
                                        mWidth: _data.range.mWidth,
                                        mHeight: _data.range.mHeight,
                                      ),
                                    );
                                    _sync();
                                  }
                                },
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: EditorResponsiveInputField(
                              label:
                                  l10n?.fairyFogRangeY ??
                                  'Starting row (mY; 0-based)',
                              decoration: const InputDecoration(
                                border: OutlineInputBorder(),
                              ),
                              builder: (context, decoration) => TextFormField(
                                initialValue: _data.range.mY.toString(),
                                decoration: decoration,
                                keyboardType: TextInputType.number,
                                onChanged: (v) {
                                  final n = int.tryParse(v);
                                  if (n != null) {
                                    _data = FairyTaleFogWaveActionData(
                                      movingTime: _data.movingTime,
                                      fogType: _data.fogType,
                                      range: FogRangeData(
                                        mX: _data.range.mX,
                                        mY: n,
                                        mWidth: _data.range.mWidth,
                                        mHeight: _data.range.mHeight,
                                      ),
                                    );
                                    _sync();
                                  }
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      EditorResponsiveFieldRow(
                        children: [
                          Expanded(
                            child: EditorResponsiveInputField(
                              label:
                                  l10n?.fairyFogRangeWidth ??
                                  'Width (mWidth; tiles)',
                              decoration: const InputDecoration(
                                border: OutlineInputBorder(),
                              ),
                              builder: (context, decoration) => TextFormField(
                                initialValue: _data.range.mWidth.toString(),
                                decoration: decoration,
                                keyboardType: TextInputType.number,
                                onChanged: (v) {
                                  final n = int.tryParse(v);
                                  if (n != null) {
                                    _data = FairyTaleFogWaveActionData(
                                      movingTime: _data.movingTime,
                                      fogType: _data.fogType,
                                      range: FogRangeData(
                                        mX: _data.range.mX,
                                        mY: _data.range.mY,
                                        mWidth: n,
                                        mHeight: _data.range.mHeight,
                                      ),
                                    );
                                    _sync();
                                  }
                                },
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: EditorResponsiveInputField(
                              label:
                                  l10n?.fairyFogRangeHeight ??
                                  'Height (mHeight; tiles)',
                              decoration: const InputDecoration(
                                border: OutlineInputBorder(),
                              ),
                              builder: (context, decoration) => TextFormField(
                                initialValue: _data.range.mHeight.toString(),
                                decoration: decoration,
                                keyboardType: TextInputType.number,
                                onChanged: (v) {
                                  final n = int.tryParse(v);
                                  if (n != null) {
                                    _data = FairyTaleFogWaveActionData(
                                      movingTime: _data.movingTime,
                                      fogType: _data.fogType,
                                      range: FogRangeData(
                                        mX: _data.range.mX,
                                        mY: _data.range.mY,
                                        mWidth: _data.range.mWidth,
                                        mHeight: n,
                                      ),
                                    );
                                    _sync();
                                  }
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n?.fogPreview ?? 'Fog preview',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      scaleTableForDesktop(
                        context: context,
                        child: Container(
                          constraints: const BoxConstraints(maxWidth: 480),
                          child: AspectRatio(
                            aspectRatio: _gridCols / _gridRows,
                            child: GridView.builder(
                              physics: const NeverScrollableScrollPhysics(),
                              gridDelegate:
                                  SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: _gridCols,
                                    childAspectRatio: 1,
                                  ),
                              itemCount: _gridCols * _gridRows,
                              itemBuilder: (context, i) {
                                final col = i % _gridCols;
                                final row = i ~/ _gridCols;
                                final inFog = _isCellInFog(col, row);
                                return Container(
                                  decoration: BoxDecoration(
                                    color: inFog
                                        ? Colors.purple.withValues(alpha: 0.5)
                                        : theme
                                              .colorScheme
                                              .surfaceContainerHighest,
                                    border: Border.all(
                                      color: theme.colorScheme.outlineVariant,
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}
