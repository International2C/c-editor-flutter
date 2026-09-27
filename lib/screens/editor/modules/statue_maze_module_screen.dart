import 'package:c_editor/data/statue_maze_validation.dart';
import 'dart:async';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:c_editor/data/pvz_models.dart';
import 'package:c_editor/data/level_parser.dart';
import 'package:c_editor/l10n/app_localizations.dart';
import 'package:c_editor/widgets/editor_components.dart'
    show
        EditorWarningBanner,
        EditorResponsiveInputField,
        HelpSectionData,
        showEditorHelpDialog;
import 'package:c_editor/widgets/editor_object_alias.dart';

class StatueMazeModuleScreen extends StatefulWidget {
  const StatueMazeModuleScreen({
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
  State<StatueMazeModuleScreen> createState() => _StatueMazeModuleScreenState();
}

class _StatueMazeModuleScreenState extends State<StatueMazeModuleScreen>
    with TickerProviderStateMixin {
  static const _objClass = 'StatueMazeModuleProperties';

  late PvzObject _moduleObj;
  late StatueMazeModulePropertiesData _data;
  late String _alias;
  int _selectedSetIndex = 0;
  bool _isAnimating = false;
  bool _isPaused = false;
  int _animatingRotationIndex = -1;
  int _longPressedRotationIndex = -1;
  AnimationController? _animController;
  double _visualRotationAngle = 0;
  List<Offset> _currentPositions = [];

  @override
  void initState() {
    super.initState();
    _alias = aliasFromRtid(widget.rtid);
    _loadData();
    _resetPositions();
  }

  @override
  void dispose() {
    _isAnimating = false;
    _animController?.dispose();
    _animController = null;
    super.dispose();
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
        objData: StatueMazeModulePropertiesData.createDefault().toJson(),
      );
      widget.levelFile.objects.add(_moduleObj);
    }
    try {
      _data = StatueMazeModulePropertiesData.fromJson(
        Map<String, dynamic>.from(_moduleObj.objData as Map),
      );
    } catch (_) {
      _data = StatueMazeModulePropertiesData.createDefault();
    }
  }

  void _save() {
    _moduleObj.objData = _data.toJson();
    widget.onChanged();
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

  StatueSetInfo get _currentSet => _data.setInfos[_selectedSetIndex];

  static List<int> _ringOrder(int size) {
    if (size <= 1) return List.generate(size * size, (i) => i);
    final ring = <int>[];
    var r0 = 0, c0 = 0, r1 = size - 1, c1 = size - 1;
    while (r0 <= r1 && c0 <= c1) {
      if (r0 == r1 && c0 == c1) break;
      for (var c = c0; c <= c1; c++) ring.add(r0 * size + c);
      for (var r = r0 + 1; r <= r1; r++) ring.add(r * size + c1);
      if (r0 < r1) {
        for (var c = c1 - 1; c >= c0; c--) ring.add(r1 * size + c);
      }
      if (c0 < c1) {
        for (var r = r1 - 1; r > r0; r--) ring.add(r * size + c0);
      }
      r0++;
      c0++;
      r1--;
      c1--;
    }
    return ring;
  }

  void _resetPositions() {
    final size = _currentSet.matrixSize;
    _currentPositions = List.generate(
      size * size,
      (i) => Offset((i % size).toDouble(), (i ~/ size).toDouble()),
    );
  }

  List<Offset> _computeRotatedPositions(bool clockwise) {
    final size = _currentSet.matrixSize;
    final ring = _ringOrder(size);
    final newPositions = List<Offset>.from(_currentPositions);
    if (ring.length <= 1) return newPositions;
    if (clockwise) {
      final first = newPositions[ring.first];
      for (var i = 0; i < ring.length - 1; i++) {
        newPositions[ring[i]] = newPositions[ring[i + 1]];
      }
      newPositions[ring.last] = first;
    } else {
      final last = newPositions[ring.last];
      for (var i = ring.length - 1; i > 0; i--) {
        newPositions[ring[i]] = newPositions[ring[i - 1]];
      }
      newPositions[ring.first] = last;
    }
    return newPositions;
  }

  void _addSet() {
    _data.setInfos.add(StatueSetInfo());
    setState(() => _selectedSetIndex = _data.setInfos.length - 1);
    _resetPositions();
    _save();
  }

  void _removeSet(int index) {
    if (_data.setInfos.length <= 1) return;
    _data.setInfos.removeAt(index);
    if (_selectedSetIndex >= _data.setInfos.length) {
      _selectedSetIndex = _data.setInfos.length - 1;
    }
    _resetPositions();
    setState(() {});
    _save();
  }

  void _addRotation() {
    _currentSet.matrixInfos.add(StatueMatrixInfo());
    setState(() {});
    _save();
  }

  void _removeRotation(int index) {
    final l10n = AppLocalizations.of(context);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n?.confirmDelete ?? 'Delete?'),
        content: Text(
          l10n?.statueMazeRemoveRotationConfirm ?? 'Remove this rotation step?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(l10n?.cancel ?? 'Cancel'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(ctx);
              _currentSet.matrixInfos.removeAt(index);
              setState(() {});
              _save();
            },
            child: Text(l10n?.confirm ?? 'OK'),
          ),
        ],
      ),
    );
  }

  void _toggleRotationType(int index) {
    final tile = _currentSet.matrixInfos[index];
    tile.type = tile.type == 'c' ? 'ac' : 'c';
    setState(() {});
    _save();
  }

  void _editRotationParams(int index) {
    final info = _currentSet.matrixInfos[index];
    final waitCtrl = TextEditingController(text: info.waitDuration.toString());
    final rotateCtrl = TextEditingController(text: info.rotateTime.toString());
    final l10n = AppLocalizations.of(context);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('${l10n?.statueMazeRotations ?? 'Rotation'} #${index + 1}'),
        scrollable: true,
        content: SizedBox(
          width: 360,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              EditorResponsiveInputField(
                label:
                    l10n?.statueMazeWaitDuration ??
                    'Total step duration (WaitDuration, seconds)',
                builder: (context, decoration) => TextField(
                  controller: waitCtrl,
                  keyboardType: TextInputType.number,
                  decoration: decoration,
                ),
              ),
              const SizedBox(height: 12),
              EditorResponsiveInputField(
                label:
                    l10n?.statueMazeRotateTime ??
                    'Rotation duration (RotateTime, seconds)',
                builder: (context, decoration) => TextField(
                  controller: rotateCtrl,
                  keyboardType: TextInputType.number,
                  decoration: decoration,
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(l10n?.cancel ?? 'Cancel'),
          ),
          FilledButton(
            onPressed: () {
              final wait = double.tryParse(waitCtrl.text);
              final rotate = double.tryParse(rotateCtrl.text);
              if (wait != null && wait >= 0) info.waitDuration = wait;
              if (rotate != null && rotate > 0) info.rotateTime = rotate;
              Navigator.pop(ctx);
              setState(() {});
              _save();
            },
            child: Text(l10n?.confirm ?? 'OK'),
          ),
        ],
      ),
    );
  }

  Future<void> _playAnimation() async {
    if (_isAnimating || _currentSet.matrixInfos.isEmpty) return;
    _resetPositions();
    setState(() {
      _isAnimating = true;
      _animatingRotationIndex = 0;
      _visualRotationAngle = 0;
    });
    for (var i = 0; i < _currentSet.matrixInfos.length; i++) {
      if (!_isAnimating) break;
      final info = _currentSet.matrixInfos[i];
      setState(() => _animatingRotationIndex = i);
      await Future.delayed(
        Duration(milliseconds: (info.waitDuration * 1000).round()),
      );
      if (!_isAnimating) break;
      final clockwise = info.type == 'c';
      final targetAngle = clockwise ? 1.5708 : -1.5708;
      _animController?.dispose();
      _animController = AnimationController(
        vsync: this,
        duration: Duration(milliseconds: (info.rotateTime * 1000).round()),
      );
      _animController!.addListener(() {
        final t = Curves.easeInOut.transform(_animController!.value);
        setState(() => _visualRotationAngle = targetAngle * t);
      });
      await _animController!.forward();
      _currentPositions = _computeRotatedPositions(clockwise);
      setState(() => _visualRotationAngle = 0);
    }
    _animController?.dispose();
    _animController = null;
    setState(() {
      _isAnimating = false;
      _animatingRotationIndex = -1;
    });
    _resetPositions();
    setState(() {});
  }

  void _togglePause() {
    if (!_isAnimating) return;
    if (_isPaused) {
      _animController?.forward();
      setState(() => _isPaused = false);
    } else {
      _animController?.stop();
      setState(() => _isPaused = true);
    }
  }

  void _stopAnimation() {
    _isAnimating = false;
    _isPaused = false;
    _visualRotationAngle = 0;
    if (_animController != null) {
      if (_animController!.isAnimating) {
        _animController!.stop();
      }
      _animController!.dispose();
      _animController = null;
    }
    _resetPositions();
    setState(() {
      _animatingRotationIndex = -1;
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final emptyRounds = statueMazeRoundsWithoutRotations(_data.toJson());
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: widget.onBack,
        ),
        title: buildEditorObjectAppBarTitle(
          context: context,
          localizedName: resolveModuleTitleByObjClass(context, _objClass),
          isEvent: false,
          objClass: _objClass,
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.help_outline),
            onPressed: () => showEditorHelpDialog(
              context,
              isEvent: false,
              title: l10n.moduleTitle_StatueMazeModuleProperties,
              sections: [
                HelpSectionData(
                  title: l10n.overview,
                  body: l10n.moduleHelpStatueMazeOverviewBody,
                ),
                HelpSectionData(
                  title: l10n.statueMazeRotations,
                  body: l10n.moduleHelpStatueMazeRotationsBody,
                ),
                HelpSectionData(
                  title: l10n.moduleHelpStatueMazeTimingTitle,
                  body: l10n.moduleHelpStatueMazeTimingBody,
                ),
                HelpSectionData(
                  title: l10n.moduleHelpStatueMazeCompatibilityTitle,
                  body: l10n.moduleHelpStatueMazeCompatibilityBody,
                ),
              ],
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ModuleAliasInputField(
              rtid: widget.rtid,
              alias: _alias,
              levelFile: widget.levelFile,
              onAliasChanged: _handleAliasChanged,
              onChanged: widget.onChanged,
            ),
            const SizedBox(height: 16),
            if (emptyRounds.isNotEmpty) ...[
              EditorWarningBanner(
                key: const ValueKey('statueMazeMissingRotations'),
                message: l10n.statueMazeMissingRotationsWarning(
                  emptyRounds.join(', '),
                ),
              ),
              const SizedBox(height: 16),
            ],
            _buildSetSelector(l10n),
            const SizedBox(height: 16),
            _buildGridSizeSelector(l10n),
            const SizedBox(height: 12),
            _buildParameterBoxes(l10n),
            const SizedBox(height: 16),
            _buildRotationSection(l10n),
            _buildRotationHint(l10n),
            const SizedBox(height: 16),
            _buildGridPreview(),
            const SizedBox(height: 16),
            _buildAnimationControls(l10n),
          ],
        ),
      ),
    );
  }

  Widget _buildSetSelector(AppLocalizations? l10n) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n?.statueMazeSets ?? 'Sets',
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 44,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: _data.setInfos.length + 1,
            separatorBuilder: (_, __) => const SizedBox(width: 8),
            itemBuilder: (context, index) {
              if (index == _data.setInfos.length) {
                return SizedBox(
                  height: 44,
                  child: OutlinedButton.icon(
                    onPressed: _addSet,
                    icon: const Icon(Icons.add, size: 18),
                    label: Text(l10n?.statueMazeAddSet ?? 'Add'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                    ),
                  ),
                );
              }
              final sel = index == _selectedSetIndex;
              return GestureDetector(
                onTap: () {
                  setState(() => _selectedSetIndex = index);
                  _resetPositions();
                },
                onLongPress: _data.setInfos.length > 1
                    ? () => _removeSet(index)
                    : null,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: sel
                        ? theme.colorScheme.primary
                        : theme.colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: sel
                          ? theme.colorScheme.primary
                          : theme.colorScheme.outline.withValues(alpha: 0.3),
                      width: 2,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      '${index + 1}',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: sel
                            ? theme.colorScheme.onPrimary
                            : theme.colorScheme.onSurface,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildGridSizeSelector(AppLocalizations? l10n) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n?.statueMazeGridSize ?? 'Grid size',
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [2, 3, 4, 5].map((size) {
            final sel = _currentSet.matrixSize == size;
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: GestureDetector(
                onTap: () {
                  _currentSet.matrixSize = size;
                  _resetPositions();
                  setState(() {});
                  _save();
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 56,
                  height: 44,
                  decoration: BoxDecoration(
                    color: sel
                        ? theme.colorScheme.primary
                        : theme.colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: sel
                          ? theme.colorScheme.primary
                          : theme.colorScheme.outline.withValues(alpha: 0.3),
                      width: 2,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      '${size}x$size',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                        color: sel
                            ? theme.colorScheme.onPrimary
                            : theme.colorScheme.onSurface,
                      ),
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildParameterBoxes(AppLocalizations? l10n) {
    return Row(
      children: [
        Expanded(
          child: _buildParamBox(
            l10n?.statueMazeDisplayTime ?? 'Display time (s)',
            _currentSet.displayTime.toString(),
            (v) {
              final n = double.tryParse(v);
              if (n != null && n > 0) {
                _currentSet.displayTime = n;
                _save();
              }
            },
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _buildParamBox(
            l10n?.statueMazeTargetNum ?? 'Target count',
            _currentSet.targetNum.toString(),
            (v) {
              final n = int.tryParse(v);
              if (n != null && n >= 0) {
                _currentSet.targetNum = n;
                _save();
              }
            },
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _buildParamBox(
            l10n?.statueMazeBonusLife ?? 'Bonus life',
            _currentSet.bonusLife.toString(),
            (v) {
              final n = int.tryParse(v);
              if (n != null && n >= 0) {
                _currentSet.bonusLife = n;
                _save();
              }
            },
          ),
        ),
      ],
    );
  }

  Widget _buildParamBox(
    String label,
    String value,
    ValueChanged<String> onChanged,
  ) {
    return EditorResponsiveInputField(
      label: label,
      labelSpacing: 4,
      builder: (context, decoration) => TextField(
        controller: TextEditingController(text: value),
        keyboardType: TextInputType.number,
        decoration: decoration.copyWith(
          isDense: true,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 8,
            vertical: 8,
          ),
        ),
        onChanged: onChanged,
      ),
    );
  }

  Widget _buildGridPreview() {
    final (rows, cols) = LevelParser.getGridDimensionsFromFile(
      widget.levelFile,
    );
    final size = _currentSet.matrixSize;
    final theme = Theme.of(context);
    const refCols = 9;
    const refRows = 5;
    final offsetCol = (refCols - size) ~/ 2;
    final offsetRow = (refRows - size) ~/ 2;

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 500),
        child: AspectRatio(
          aspectRatio: cols / rows,
          child: LayoutBuilder(
            builder: (context, constraints) {
              final w = constraints.maxWidth;
              final h = constraints.maxHeight;
              final cellW = w / cols;
              final cellH = h / rows;
              return Container(
                decoration: BoxDecoration(
                  color: theme.brightness == Brightness.dark
                      ? const Color(0xFF31383B)
                      : const Color(0xFFD7ECF1),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: const Color(0xFF6B899A)),
                ),
                clipBehavior: Clip.antiAlias,
                child: Stack(
                  children: [
                    Column(
                      children: List.generate(
                        rows,
                        (row) => Expanded(
                          child: Row(
                            children: List.generate(
                              cols,
                              (col) => Expanded(
                                child: Container(
                                  margin: const EdgeInsets.all(0.5),
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                      color: const Color(0xFF6B899A),
                                      width: 0.5,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      left: 0,
                      top: 0,
                      width: w,
                      height: h,
                      child: Transform.rotate(
                        angle: _visualRotationAngle,
                        alignment: Alignment(
                          ((offsetCol + size / 2) * cellW / w) * 2 - 1,
                          ((offsetRow + size / 2) * cellH / h) * 2 - 1,
                        ),
                        child: Stack(
                          children: [
                            for (var i = 0; i < size * size; i++)
                              Positioned(
                                left:
                                    (offsetCol + _currentPositions[i].dx) *
                                    cellW,
                                top:
                                    (offsetRow + _currentPositions[i].dy) *
                                    cellH,
                                width: cellW,
                                height: cellH,
                                child: Padding(
                                  padding: const EdgeInsets.all(2),
                                  child: Transform.rotate(
                                    angle: -_visualRotationAngle,
                                    child: Image.asset(
                                      'assets/images/griditems/renai_statue_zombie1.webp',
                                      fit: BoxFit.contain,
                                      errorBuilder: (_, __, ___) => Icon(
                                        Icons.account_balance,
                                        size: 16,
                                        color: theme.colorScheme.primary
                                            .withValues(alpha: 0.6),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildRotationSection(AppLocalizations? l10n) {
    final theme = Theme.of(context);
    final textScaler = MediaQuery.textScalerOf(context);
    final cardWidth = textScaler.scale(72).clamp(72.0, double.infinity);
    final cardHeight = textScaler.scale(80).clamp(80.0, double.infinity);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              l10n?.statueMazeRotations ?? 'Rotations',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const Spacer(),
            Text(
              '${_currentSet.matrixInfos.length}',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        if (_currentSet.matrixInfos.isEmpty)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text(
              l10n?.statueMazeNoRotations ?? 'No rotations added',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        SizedBox(
          height: cardHeight,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: _currentSet.matrixInfos.length + 1,
            separatorBuilder: (_, __) => const SizedBox(width: 8),
            itemBuilder: (context, index) {
              if (index == _currentSet.matrixInfos.length) {
                return GestureDetector(
                  onTap: _addRotation,
                  child: Container(
                    width: cardWidth,
                    height: cardHeight,
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: theme.colorScheme.outline.withValues(alpha: 0.5),
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.add,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                );
              }
              final info = _currentSet.matrixInfos[index];
              final cw = info.type == 'c';
              final active = _animatingRotationIndex == index;
              return GestureDetector(
                onTap: () => _editRotationParams(index),
                onLongPressStart: (_) =>
                    setState(() => _longPressedRotationIndex = index),
                onLongPressEnd: (_) {
                  setState(() => _longPressedRotationIndex = -1);
                  _removeRotation(index);
                },
                onLongPressCancel: () =>
                    setState(() => _longPressedRotationIndex = -1),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: cardWidth,
                  height: cardHeight,
                  decoration: BoxDecoration(
                    color: _longPressedRotationIndex == index
                        ? theme.colorScheme.errorContainer
                        : active
                        ? theme.colorScheme.primary.withValues(alpha: 0.2)
                        : theme.colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: _longPressedRotationIndex == index
                          ? theme.colorScheme.error
                          : active
                          ? theme.colorScheme.primary
                          : theme.colorScheme.outline.withValues(alpha: 0.3),
                      width: _longPressedRotationIndex == index || active
                          ? 2
                          : 1,
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      GestureDetector(
                        onTap: () => _toggleRotationType(index),
                        child: Icon(
                          cw ? Icons.rotate_right : Icons.rotate_left,
                          size: 22,
                          color: cw
                              ? theme.colorScheme.primary
                              : theme.colorScheme.tertiary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        cw ? 'C' : 'AC',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: cw
                              ? theme.colorScheme.primary
                              : theme.colorScheme.tertiary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${info.waitDuration}s / ${info.rotateTime}s',
                        style: theme.textTheme.bodySmall?.copyWith(
                          fontSize: 8,
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildRotationHint(AppLocalizations? l10n) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(top: 6),
      child: Text(
        l10n?.statueMazeRotationsHint ??
            'Tap the arrow to switch rotation direction. Tap a card to edit that step’s parameters. Long-press a card to delete the step.',
        style: theme.textTheme.bodySmall?.copyWith(
          color: theme.colorScheme.onSurfaceVariant,
          fontSize: 11,
        ),
      ),
    );
  }

  Widget _buildAnimationControls(AppLocalizations? l10n) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(
          width: 36,
          height: 36,
          child: IconButton.filled(
            onPressed: _isAnimating ? _togglePause : _playAnimation,
            iconSize: 18,
            padding: EdgeInsets.zero,
            icon: Icon(
              _isAnimating
                  ? (_isPaused ? Icons.play_arrow : Icons.pause)
                  : Icons.play_arrow,
            ),
          ),
        ),
        if (_isAnimating) ...[
          const SizedBox(width: 8),
          SizedBox(
            width: 36,
            height: 36,
            child: IconButton.outlined(
              onPressed: _stopAnimation,
              iconSize: 18,
              padding: EdgeInsets.zero,
              icon: const Icon(Icons.stop),
            ),
          ),
        ],
      ],
    );
  }
}
