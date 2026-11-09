import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:c_editor/data/level_parser.dart';
import 'package:c_editor/data/pvz_models.dart';
import 'package:c_editor/l10n/app_localizations.dart';
import 'package:c_editor/widgets/dino_tread_preview_grid.dart';
import 'package:c_editor/widgets/editor_components.dart';
import 'package:c_editor/widgets/editor_object_alias.dart';

/// Dino tread event editor. Grid-based dinosaur tread hazard.
class DinoTreadEventScreen extends StatefulWidget {
  const DinoTreadEventScreen({
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
  State<DinoTreadEventScreen> createState() => _DinoTreadEventScreenState();
}

class _DinoTreadEventScreenState extends State<DinoTreadEventScreen> {
  static const _objClass = 'DinoTreadActionProps';

  late PvzObject _moduleObj;
  late DinoTreadActionPropsData _data;
  late TextEditingController _waveStartMessageCtrl;
  late String _alias;

  bool get _isDeepSeaLawn =>
      LevelParser.isDeepSeaLawnFromFile(widget.levelFile);
  int get _maxRowIndex => _isDeepSeaLawn ? 5 : 4;
  int get _maxColIndex => _isDeepSeaLawn ? 9 : 8;

  @override
  void initState() {
    super.initState();
    _alias = aliasFromRtid(widget.rtid);
    _loadData();
  }

  @override
  void dispose() {
    _waveStartMessageCtrl.dispose();
    super.dispose();
  }

  String _getDefaultWaveStartMessage() {
    for (final obj in widget.levelFile.objects) {
      if (obj.objClass == 'DinoTreadActionProps' && obj.objData is Map) {
        final msg = (obj.objData as Map)['WaveStartMessage'] as String?;
        if (msg != null && msg.isNotEmpty) return msg;
      }
    }
    return '[WARNING_DINO_TREAD]';
  }

  void _loadData() {
    final alias = _alias;
    final existing = widget.levelFile.objects.firstWhereOrNull(
      (o) => o.aliases?.contains(alias) == true,
    );
    if (existing != null) {
      _moduleObj = existing;
    } else {
      final defaultMsg = _getDefaultWaveStartMessage();
      _moduleObj = PvzObject(
        aliases: [alias],
        objClass: _objClass,
        objData: DinoTreadActionPropsData(
          waveStartMessage: defaultMsg,
        ).toJson(),
      );
      widget.levelFile.objects.add(_moduleObj);
    }
    try {
      _data = DinoTreadActionPropsData.fromJson(
        Map<String, dynamic>.from(_moduleObj.objData as Map),
      );
    } catch (_) {
      _data = DinoTreadActionPropsData(
        waveStartMessage: _getDefaultWaveStartMessage(),
      );
    }
    if (_data.waveStartMessage.isEmpty) {
      final defaultMsg = _getDefaultWaveStartMessage();
      _data = DinoTreadActionPropsData(
        gridY: _data.gridY,
        gridXMin: _data.gridXMin,
        gridXMax: _data.gridXMax,
        timeInterval: _data.timeInterval,
        waveStartMessage: defaultMsg,
      );
      _moduleObj.objData = _data.toJson();
    }
    _waveStartMessageCtrl = TextEditingController(text: _data.waveStartMessage);
  }

  void _sync() {
    _moduleObj.objData = _data.toJson();
    widget.onChanged();
    setState(() {});
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
    final dinoColor = theme.brightness == Brightness.dark
        ? const Color(0xFFA2B659)
        : const Color(0xFF91B900);
    final (gridRows, gridCols) = LevelParser.getGridDimensionsFromFile(
      widget.levelFile,
    );

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
              title: l10n?.eventDinoTread ?? 'Dino tread event',
              sections: [
                HelpSectionData(
                  title: l10n?.overview ?? 'Overview',
                  body: l10n?.eventHelpDinoTreadBody ?? '',
                ),
                HelpSectionData(
                  title: l10n?.rowCol0Index ?? 'Row/column (0-based)',
                  body: l10n?.eventHelpDinoTreadRowCol ?? '',
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
                      Row(
                        children: [
                          Icon(Icons.pets, color: dinoColor),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              l10n?.positionAndArea ?? 'Position & area',
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      _buildIntField(
                        label: l10n?.dinoTreadRowLabel ?? 'Row [GridY]',
                        value: _data.gridY,
                        max: _maxRowIndex,
                        onChanged: (v) {
                          _data = DinoTreadActionPropsData(
                            gridY: v,
                            gridXMin: _data.gridXMin,
                            gridXMax: _data.gridXMax,
                            timeInterval: _data.timeInterval,
                            waveStartMessage: _data.waveStartMessage,
                          );
                          _sync();
                        },
                      ),
                      const SizedBox(height: 12),
                      _buildIntField(
                        label:
                            l10n?.dinoTreadColMinLabel ??
                            'Column min [GridXMin]',
                        value: _data.gridXMin,
                        max: _maxColIndex,
                        onChanged: (v) {
                          _data = DinoTreadActionPropsData(
                            gridY: _data.gridY,
                            gridXMin: v,
                            gridXMax: _data.gridXMax,
                            timeInterval: _data.timeInterval,
                            waveStartMessage: _data.waveStartMessage,
                          );
                          _sync();
                        },
                      ),
                      const SizedBox(height: 12),
                      _buildIntField(
                        label:
                            l10n?.dinoTreadColMaxLabel ??
                            'Column max [GridXMax]',
                        value: _data.gridXMax,
                        max: _maxColIndex,
                        onChanged: (v) {
                          _data = DinoTreadActionPropsData(
                            gridY: _data.gridY,
                            gridXMin: _data.gridXMin,
                            gridXMax: v,
                            timeInterval: _data.timeInterval,
                            waveStartMessage: _data.waveStartMessage,
                          );
                          _sync();
                        },
                      ),
                      const SizedBox(height: 12),
                      Center(
                        child: Text(
                          l10n?.dinoTreadPreview ?? 'Stomp area preview',
                          style: theme.textTheme.titleSmall?.copyWith(
                            color: theme.colorScheme.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Center(
                        child: DinoTreadPreviewGrid(
                          gridRows: gridRows,
                          gridCols: gridCols,
                          gridY: _data.gridY,
                          gridXMin: _data.gridXMin,
                          gridXMax: _data.gridXMax,
                        ),
                      ),
                      const SizedBox(height: 12),
                      EditorResponsiveInputField(
                        label:
                            l10n?.dinoTreadTimeIntervalLabel ??
                            'Time interval [TimeInterval]',
                        decoration: InputDecoration(
                          border: const OutlineInputBorder(),
                        ),
                        builder: (context, decoration) => TextFormField(
                          initialValue: _data.timeInterval.toString(),
                          decoration: decoration,
                          keyboardType: TextInputType.number,
                          onChanged: (v) {
                            final n = int.tryParse(v);
                            if (n != null) {
                              _data = DinoTreadActionPropsData(
                                gridY: _data.gridY,
                                gridXMin: _data.gridXMin,
                                gridXMax: _data.gridXMax,
                                timeInterval: n,
                                waveStartMessage: _data.waveStartMessage,
                              );
                              _sync();
                            }
                          },
                        ),
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
                        l10n?.waveStartMessageLabel ??
                            'Red subtitle [WaveStartMessage]',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        key: const ValueKey('waveStartMessageField'),
                        controller: _waveStartMessageCtrl,
                        decoration: InputDecoration(
                          helperText:
                              l10n?.optionalWarningText ??
                              'Optional red warning text shown at the center of the screen when the event begins; Chinese is not supported',
                          helperMaxLines: 3,
                          border: const OutlineInputBorder(),
                        ),
                        onChanged: (v) {
                          _data = DinoTreadActionPropsData(
                            gridY: _data.gridY,
                            gridXMin: _data.gridXMin,
                            gridXMax: _data.gridXMax,
                            timeInterval: _data.timeInterval,
                            waveStartMessage: v,
                          );
                          _sync();
                        },
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

  Widget _buildIntField({
    required String label,
    required int value,
    required int max,
    required ValueChanged<int> onChanged,
  }) {
    return EditorResponsiveInputField(
      label: label,
      decoration: const InputDecoration(
        border: OutlineInputBorder(),
        isDense: true,
      ),
      builder: (context, decoration) => TextFormField(
        initialValue: value.toString(),
        decoration: decoration,
        keyboardType: TextInputType.number,
        onChanged: (v) {
          final n = int.tryParse(v);
          if (n != null && n >= 0 && n <= max) onChanged(n);
        },
      ),
    );
  }
}
