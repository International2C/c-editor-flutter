import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:c_editor/data/pvz_models.dart';
import 'package:c_editor/data/rtid_parser.dart';
import 'package:c_editor/l10n/app_localizations.dart';
import 'package:c_editor/theme/app_theme.dart';
import 'package:c_editor/widgets/editor_components.dart';

/// Custom fish properties screen. Similar to CustomZombiePropertiesScreen.
/// Loads CreatureType and linked PropertySheet from level (Properties -> CurrentLevel).
class CustomFishPropertiesScreen extends StatefulWidget {
  const CustomFishPropertiesScreen({
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
  State<CustomFishPropertiesScreen> createState() =>
      _CustomFishPropertiesScreenState();
}

class _CustomFishPropertiesScreenState
    extends State<CustomFishPropertiesScreen> {
  PvzObject? _typeObj;
  PvzObject? _propsObj;
  String _typeName = '';
  String _propsRtid = '';

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    final info = RtidParser.parse(widget.rtid);
    final alias = info?.alias ?? '';
    _typeObj = widget.levelFile.objects.firstWhereOrNull(
      (o) => o.aliases?.contains(alias) == true,
    );
    if (_typeObj == null) {
      setState(() {});
      return;
    }
    final objdata = _typeObj!.objData as Map<String, dynamic>?;
    _typeName = objdata?['TypeName'] as String? ?? '';
    _propsRtid = objdata?['Properties'] as String? ?? '';
    final propsInfo = RtidParser.parse(_propsRtid);
    final propsAlias = propsInfo?.alias ?? '';
    if (propsInfo?.source == 'CurrentLevel' && propsAlias.isNotEmpty) {
      _propsObj = widget.levelFile.objects.firstWhereOrNull(
        (o) => o.aliases?.contains(propsAlias) == true,
      );
    }
    setState(() {});
  }

  void _sync() {
    widget.onChanged();
    setState(() {});
  }

  Map<String, dynamic> get _propsData {
    final d = _propsObj?.objData;
    if (d is! Map<String, dynamic>) return {};
    return d;
  }

  double _toDoubleSafe(dynamic v) {
    if (v is num) return v.toDouble();
    return 0.0;
  }

  void _updateProps(String key, dynamic value) {
    final d = _propsObj?.objData;
    if (d is! Map<String, dynamic>) return;
    d[key] = value;
    _sync();
  }

  String _formatRect(dynamic v) {
    if (v is! Map) {
      return AppLocalizations.of(context)?.defaultPropertiesLabel ?? 'Default';
    }
    final m = v as Map<String, dynamic>;
    final x = m['mX'] as num? ?? 0;
    final y = m['mY'] as num? ?? 0;
    final w = m['mWidth'] as num? ?? 0;
    final h = m['mHeight'] as num? ?? 0;
    return 'X:$x, Y:$y, W:$w, H:$h';
  }

  String _formatPoint(dynamic v) {
    if (v is! Map) {
      return AppLocalizations.of(context)?.defaultPropertiesLabel ?? 'Default';
    }
    final m = v as Map<String, dynamic>;
    final x = m['x'] as num? ?? 0;
    final y = m['y'] as num? ?? 0;
    return 'X:$x, Y:$y';
  }

  RectData _parseRect(dynamic v) {
    if (v is Map<String, dynamic>) {
      return RectData(
        mX: (v['mX'] as num?)?.toInt() ?? 0,
        mY: (v['mY'] as num?)?.toInt() ?? 0,
        mWidth: (v['mWidth'] as num?)?.toInt() ?? 0,
        mHeight: (v['mHeight'] as num?)?.toInt() ?? 0,
      );
    }
    return RectData(mX: 0, mY: 0, mWidth: 32, mHeight: 32);
  }

  Point2D _parsePoint(dynamic v) {
    if (v is Map<String, dynamic>) {
      return Point2D(
        x: (v['x'] as num?)?.toInt() ?? 0,
        y: (v['y'] as num?)?.toInt() ?? 0,
      );
    }
    return Point2D(x: 0, y: 0);
  }

  Future<void> _showRectDialog({
    required String title,
    required String key,
    required RectData initial,
  }) async {
    final l10n = AppLocalizations.of(context);
    final xController = TextEditingController(text: '${initial.mX}');
    final yController = TextEditingController(text: '${initial.mY}');
    final wController = TextEditingController(text: '${initial.mWidth}');
    final hController = TextEditingController(text: '${initial.mHeight}');
    await showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Expanded(child: _numberField(xController, label: 'X')),
                const SizedBox(width: 8),
                Expanded(child: _numberField(yController, label: 'Y')),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: _numberField(
                    wController,
                    label: l10n?.width ?? 'Width',
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _numberField(
                    hController,
                    label: l10n?.height ?? 'Height',
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(l10n?.cancel ?? 'Cancel'),
          ),
          FilledButton(
            onPressed: () {
              _updateProps(key, {
                'mX': int.tryParse(xController.text) ?? initial.mX,
                'mY': int.tryParse(yController.text) ?? initial.mY,
                'mWidth': int.tryParse(wController.text) ?? initial.mWidth,
                'mHeight': int.tryParse(hController.text) ?? initial.mHeight,
              });
              Navigator.pop(ctx);
            },
            child: Text(l10n?.ok ?? 'OK'),
          ),
        ],
      ),
    );
  }

  Future<void> _showPointDialog({
    required String title,
    required String key,
    required Point2D initial,
  }) async {
    final l10n = AppLocalizations.of(context);
    final xController = TextEditingController(text: '${initial.x}');
    final yController = TextEditingController(text: '${initial.y}');
    await showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title),
        content: Row(
          children: [
            Expanded(child: _numberField(xController, label: 'X')),
            const SizedBox(width: 8),
            Expanded(child: _numberField(yController, label: 'Y')),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(l10n?.cancel ?? 'Cancel'),
          ),
          FilledButton(
            onPressed: () {
              _updateProps(key, {
                'x': int.tryParse(xController.text) ?? initial.x,
                'y': int.tryParse(yController.text) ?? initial.y,
              });
              Navigator.pop(ctx);
            },
            child: Text(l10n?.ok ?? 'OK'),
          ),
        ],
      ),
    );
  }

  Widget _numberField(
    TextEditingController controller, {
    required String label,
  }) {
    return EditorResponsiveInputField(
      label: label,
      builder: (context, decoration) => TextField(
        controller: controller,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        decoration: decoration,
      ),
    );
  }

  String _fishPropLabel(AppLocalizations? l10n, String key) {
    if (l10n == null) return key;
    switch (key) {
      case 'Speed':
        return l10n.fishPropSpeed;
      case 'ScareSpeed':
        return l10n.fishPropScareSpeed;
      case 'Damage':
        return l10n.fishPropDamage;
      case 'Hitpoints':
        return l10n.fishPropHitpoints;
      case 'HitPoints':
        return l10n.fishPropHitPoints;
      case 'HitRect':
        return l10n.fishPropHitRect;
      case 'AttackRect':
        return l10n.fishPropAttackRect;
      case 'ScareRect':
        return l10n.fishPropScareRect;
      case 'Scarerect':
        return l10n.fishPropScarerect;
      case 'ArtCenter':
        return l10n.fishPropArtCenter;
      default:
        return key;
    }
  }

  Color get _themeColor => Theme.of(context).brightness == Brightness.dark
      ? pvzFishDark
      : pvzFishLight;

  Widget _editRow({
    required String title,
    required String subtitle,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Icon(icon, color: _themeColor),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.edit, size: 18),
          ],
        ),
      ),
    );
  }

  Widget _doubleInput({
    required String label,
    required String key,
    required double value,
  }) {
    return _DoubleInputField(
      key: ValueKey(key),
      label: label,
      value: value,
      onChanged: (v) => _updateProps(key, v),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    if (_typeObj == null) {
      return Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: widget.onBack,
          ),
          title: Text(l10n?.customFish ?? 'Custom fish'),
        ),
        body: Center(
          child: Text(
            l10n?.fishTypeNotFound ?? 'Fish type object not found.',
            style: theme.textTheme.titleMedium,
          ),
        ),
      );
    }
    if (_propsObj == null) {
      final propsAlias = RtidParser.parse(_propsRtid)?.alias ?? '';
      return Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: widget.onBack,
          ),
          title: Text(l10n?.customFishProperties ?? 'Custom fish properties'),
          backgroundColor: _themeColor,
          foregroundColor: theme.colorScheme.onPrimary,
        ),
        body: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(editorWarningIcon, size: 80, color: _themeColor),
              const SizedBox(height: 16),
              Text(
                l10n?.propertyObjectNotFound ?? 'Property object not found',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                l10n?.propertyObjectNotFoundHint(propsAlias) ??
                    'The custom fish property object ($propsAlias) was not found in the level.',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      );
    }

    final propsData = _propsData;
    final rectKeys = ['HitRect', 'AttackRect', 'ScareRect', 'Scarerect'];
    final pointKeys = ['ArtCenter'];
    final numberKeys = [
      'Speed',
      'ScareSpeed',
      'Damage',
      'Hitpoints',
      'HitPoints',
    ];

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: widget.onBack,
        ),
        title: Text(l10n?.customFishProperties ?? 'Custom fish properties'),
        backgroundColor: _themeColor,
        foregroundColor: theme.colorScheme.onPrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.help_outline),
            onPressed: () => showEditorHelpDialog(
              context,
              title: l10n?.customFish ?? 'Custom fish',
              themeColor: _themeColor,
              sections: [
                HelpSectionData(
                  title: l10n?.customFishHelpIntro ?? 'Brief introduction',
                  body:
                      l10n?.customFishHelpIntroBody ??
                      'This screen edits custom fish parameters. Only common properties are supported; animation and special attributes require manual JSON editing.',
                ),
                HelpSectionData(
                  title: l10n?.customFishHelpProps ?? 'Properties',
                  body:
                      l10n?.customFishHelpPropsBody ??
                      'HitRect, AttackRect, ScareRect define collision areas. Speed and ScareSpeed control movement. ArtCenter is the drawing anchor.',
                ),
              ],
            ),
          ),
        ],
      ),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        behavior: HitTestBehavior.deferToChild,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n?.aliasLabel ?? 'Alias',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: _themeColor,
                ),
              ),
              const SizedBox(height: 8),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: TextFormField(
                    initialValue: _typeObj!.aliases?.isNotEmpty == true
                        ? _typeObj!.aliases!.first
                        : '',
                    decoration: InputDecoration(
                      border: const OutlineInputBorder(),
                      isDense: true,
                      hintText: l10n?.aliasLabel ?? 'Alias',
                    ),
                    onChanged: (v) {
                      final trimmed = v.trim();
                      if (trimmed.isNotEmpty && _typeObj != null) {
                        _typeObj!.aliases = [trimmed];
                        _sync();
                      }
                    },
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                l10n?.baseStats ?? 'Base stats',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: _themeColor,
                ),
              ),
              const SizedBox(height: 8),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      for (final k in numberKeys)
                        if (propsData.containsKey(k)) ...[
                          _doubleInput(
                            label: _fishPropLabel(l10n, k),
                            key: k,
                            value: _toDoubleSafe(propsData[k]),
                          ),
                          const SizedBox(height: 12),
                        ],
                      if (propsData.keys
                          .where(
                            (x) =>
                                numberKeys.contains(x) ||
                                rectKeys.contains(x) ||
                                pointKeys.contains(x),
                          )
                          .isEmpty)
                        Text(
                          l10n?.noEditableFishProps ??
                              'No editable properties found.',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                l10n?.hitPosition ?? 'Hit / position',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: _themeColor,
                ),
              ),
              const SizedBox(height: 8),
              Card(
                child: Column(
                  children: [
                    for (final k in rectKeys)
                      if (propsData.containsKey(k))
                        Column(
                          children: [
                            _editRow(
                              title: _fishPropLabel(l10n, k),
                              subtitle: _formatRect(propsData[k]),
                              icon: Icons.aspect_ratio,
                              onTap: () => _showRectDialog(
                                title:
                                    '${l10n?.edit ?? 'Edit'} ${_fishPropLabel(l10n, k)}',
                                key: k,
                                initial: _parseRect(propsData[k]),
                              ),
                            ),
                            const Divider(height: 1),
                          ],
                        ),
                    for (final k in pointKeys)
                      if (propsData.containsKey(k))
                        _editRow(
                          title: _fishPropLabel(l10n, k),
                          subtitle: _formatPoint(propsData[k]),
                          icon: Icons.center_focus_strong,
                          onTap: () => _showPointDialog(
                            title:
                                '${l10n?.edit ?? 'Edit'} ${_fishPropLabel(l10n, k)}',
                            key: k,
                            initial: _parsePoint(propsData[k]),
                          ),
                        ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Text(
                l10n?.fishTypeLabel(_typeName) ?? 'Fish type: $_typeName',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              Text(
                l10n?.propertyAliasLabel(
                      RtidParser.parse(_propsRtid)?.alias ?? '',
                    ) ??
                    'Property alias: ${RtidParser.parse(_propsRtid)?.alias ?? ''}',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

class _DoubleInputField extends StatefulWidget {
  const _DoubleInputField({
    super.key,
    required this.label,
    required this.value,
    required this.onChanged,
  });
  final String label;
  final double value;
  final ValueChanged<double> onChanged;

  @override
  State<_DoubleInputField> createState() => _DoubleInputFieldState();
}

class _DoubleInputFieldState extends State<_DoubleInputField> {
  late TextEditingController _controller;
  late FocusNode _focusNode;
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.value.toString());
    _focusNode = FocusNode();
    _focusNode.addListener(() {
      final f = _focusNode.hasFocus;
      if (_isFocused != f) setState(() => _isFocused = f);
    });
  }

  @override
  void didUpdateWidget(covariant _DoubleInputField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!_isFocused && oldWidget.value != widget.value) {
      _controller.text = widget.value.toString();
    }
  }

  @override
  void dispose() {
    _focusNode.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return EditorResponsiveInputField(
      label: widget.label,
      builder: (context, decoration) => TextField(
        controller: _controller,
        focusNode: _focusNode,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        decoration: decoration,
        onChanged: (v) {
          final n = double.tryParse(v);
          if (n != null) widget.onChanged(n);
        },
      ),
    );
  }
}
