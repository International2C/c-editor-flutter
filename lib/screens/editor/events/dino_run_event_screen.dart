import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:c_editor/data/level_parser.dart';
import 'package:c_editor/data/pvz_models.dart';
import 'package:c_editor/l10n/app_localizations.dart';
import 'package:c_editor/widgets/dino_run_preview_grid.dart';
import 'package:c_editor/widgets/editor_components.dart';
import 'package:c_editor/widgets/editor_object_alias.dart';

/// Dino run event editor. Row-based dinosaur run hazard.
class DinoRunEventScreen extends StatefulWidget {
  const DinoRunEventScreen({
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
  State<DinoRunEventScreen> createState() => _DinoRunEventScreenState();
}

class _DinoRunEventScreenState extends State<DinoRunEventScreen> {
  static const _objClass = 'DinoRunActionProps';

  late PvzObject _moduleObj;
  late DinoRunActionPropsData _data;
  late TextEditingController _waveStartMessageCtrl;
  late String _alias;

  bool get _isDeepSeaLawn =>
      LevelParser.isDeepSeaLawnFromFile(widget.levelFile);
  int get _maxRowIndex => _isDeepSeaLawn ? 5 : 4;

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
      if (obj.objClass == 'DinoRunActionProps' && obj.objData is Map) {
        final msg = (obj.objData as Map)['WaveStartMessage'] as String?;
        if (msg != null && msg.isNotEmpty) return msg;
      }
    }
    return '[WARNING_DINO_RUN]';
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
        objData: DinoRunActionPropsData(waveStartMessage: defaultMsg).toJson(),
      );
      widget.levelFile.objects.add(_moduleObj);
    }
    try {
      _data = DinoRunActionPropsData.fromJson(
        Map<String, dynamic>.from(_moduleObj.objData as Map),
      );
    } catch (_) {
      _data = DinoRunActionPropsData(
        waveStartMessage: _getDefaultWaveStartMessage(),
      );
    }
    if (_data.waveStartMessage.isEmpty) {
      final defaultMsg = _getDefaultWaveStartMessage();
      _data = DinoRunActionPropsData(
        dinoRow: _data.dinoRow,
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
              title: l10n?.eventDinoRun ?? 'Dino run event',
              sections: [
                HelpSectionData(
                  title: l10n?.overview ?? 'Overview',
                  body: l10n?.eventHelpDinoRunBody ?? '',
                ),
                HelpSectionData(
                  title: l10n?.rowCol0Index ?? 'Row (0-based)',
                  body: l10n?.eventHelpDinoRunRow ?? '',
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
                              l10n?.positionAndDuration ?? 'Position & timing',
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
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              l10n?.dinoRow(_data.dinoRow + 1) ??
                                  'Row (DinoRow): ${_data.dinoRow + 1}',
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: theme.textTheme.bodyLarge,
                            ),
                          ),
                          const SizedBox(width: 8),
                          IconButton(
                            icon: const Icon(Icons.remove),
                            onPressed: _data.dinoRow > 0
                                ? () {
                                    _data = DinoRunActionPropsData(
                                      dinoRow: _data.dinoRow - 1,
                                      timeInterval: _data.timeInterval,
                                      waveStartMessage: _data.waveStartMessage,
                                    );
                                    _sync();
                                  }
                                : null,
                          ),
                          IconButton(
                            icon: const Icon(Icons.add),
                            onPressed: _data.dinoRow < _maxRowIndex
                                ? () {
                                    _data = DinoRunActionPropsData(
                                      dinoRow: _data.dinoRow + 1,
                                      timeInterval: _data.timeInterval,
                                      waveStartMessage: _data.waveStartMessage,
                                    );
                                    _sync();
                                  }
                                : null,
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Center(
                        child: Text(
                          l10n?.dinoRunPreview ?? 'Stampede preview',
                          style: theme.textTheme.titleSmall?.copyWith(
                            color: theme.colorScheme.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Center(
                        child: DinoRunPreviewGrid(
                          gridRows: gridRows,
                          gridCols: gridCols,
                          dinoRow: _data.dinoRow,
                        ),
                      ),
                      const SizedBox(height: 12),
                      EditorResponsiveInputField(
                        label: localizedSecondsPropertyLabel(
                          context,
                          l10n?.timeInterval ?? 'Time interval',
                          'TimeInterval',
                        ),
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
                              _data = DinoRunActionPropsData(
                                dinoRow: _data.dinoRow,
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
                            'Red subtitle (WaveStartMessage)',
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
                          _data = DinoRunActionPropsData(
                            dinoRow: _data.dinoRow,
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
}
