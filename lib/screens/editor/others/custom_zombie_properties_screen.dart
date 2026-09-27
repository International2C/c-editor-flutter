import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:c_editor/data/custom_zombie_property_sync.dart';
import 'package:c_editor/data/tag_assets.dart';
import 'package:c_editor/data/pvz_models.dart';
import 'package:c_editor/data/resilience_shield_utils.dart';
import 'package:c_editor/data/repository/resilience_config_repository.dart';
import 'package:c_editor/data/repository/zombie_properties_repository.dart';
import 'package:c_editor/data/rtid_parser.dart';
import 'package:c_editor/l10n/app_localizations.dart';
import 'package:c_editor/theme/app_theme.dart';
import 'package:c_editor/widgets/asset_image.dart';
import 'package:c_editor/screens/editor/others/resilience_shield_selection_screen.dart';
import 'package:c_editor/widgets/editor_components.dart';
import 'package:c_editor/widgets/resilience_shield_widgets.dart';

/// Custom zombie properties. Ported from CustomZombiePropertiesEP.kt
class CustomZombiePropertiesScreen extends StatefulWidget {
  const CustomZombiePropertiesScreen({
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
  State<CustomZombiePropertiesScreen> createState() =>
      _CustomZombiePropertiesScreenState();
}

class _CustomZombiePropertiesScreenState
    extends State<CustomZombiePropertiesScreen> {
  PvzObject? _typeObj;
  PvzObject? _propsObj;
  PvzObject? _customResilienceObj;
  late ZombieTypeData _typeData;
  late ZombiePropertySheetData _propsData;
  final List<double> _resistances = List<double>.filled(7, 0.0);
  ZombieResilienceData _customResilienceData = ZombieResilienceData();
  String? _selectedResilienceRtid;
  String _customResilienceCodename = '';

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
    _typeData = ZombieTypeData.fromJson(
      Map<String, dynamic>.from(_typeObj!.objData as Map),
    );
    final propsAlias = RtidParser.parse(_typeData.properties)?.alias ?? '';
    _propsObj = widget.levelFile.objects.firstWhereOrNull(
      (o) => o.aliases?.contains(propsAlias) == true,
    );
    if (_propsObj != null) {
      _propsData = ZombiePropertySheetData.fromJson(
        Map<String, dynamic>.from(_propsObj!.objData as Map),
      );
    }
    final list = _typeData.resistences ?? const [];
    for (var i = 0; i < 7; i++) {
      _resistances[i] = i < list.length ? list[i] : 0.0;
    }
    if (!_supportsResilienceShield) {
      if (_propsData.resilience != null) {
        _stripUnsupportedResilience();
        WidgetsBinding.instance.addPostFrameCallback((_) => widget.onChanged());
      }
      return;
    }
    _loadResilienceState();
  }

  ZombieResilienceData _resilienceDataFromEntry(ResilienceConfigEntry entry) {
    final d = entry.data;
    return ZombieResilienceData(
      amount: d.amount,
      weakType: d.weakType,
      recoverSpeed: d.recoverSpeed,
      damageThresholdPerSecond: d.damageThresholdPerSecond,
      resilienceBaseDamageThreshold: d.resilienceBaseDamageThreshold,
      resilienceExtraDamageThreshold: d.resilienceExtraDamageThreshold,
      animLabels: List<String>.from(d.animLabels),
    );
  }

  List<_ResilienceShieldOption> _resilienceShieldOptions() {
    final options = <_ResilienceShieldOption>[];
    for (final entry in ResilienceConfigRepository.getAll()) {
      options.add(
        _ResilienceShieldOption(
          rtid: entry.rtid,
          alias: entry.alias,
          source: 'ResilienceConfig',
          weakType: entry.data.weakType,
        ),
      );
    }
    for (final obj in widget.levelFile.objects) {
      if (obj.objClass != 'ZombieResilience') continue;
      final alias = obj.aliases?.firstOrNull;
      if (alias == null || obj.objData is! Map) continue;
      final data = ZombieResilienceData.fromJson(
        Map<String, dynamic>.from(obj.objData as Map),
      );
      options.add(
        _ResilienceShieldOption(
          rtid: RtidParser.build(alias, 'CurrentLevel'),
          alias: alias,
          source: 'CurrentLevel',
          weakType: data.weakType,
        ),
      );
    }
    return options;
  }

  void _applySelectedResilienceRtid(String rtid) {
    _selectedResilienceRtid = rtid;
    _propsData.resilience = rtid;
    final info = RtidParser.parse(rtid);
    if (info == null) return;
    if (info.source == 'ResilienceConfig') {
      _customResilienceObj = null;
      _customResilienceCodename = '';
      final entry = ResilienceConfigRepository.getByAlias(info.alias);
      if (entry != null) {
        _customResilienceData = _resilienceDataFromEntry(entry);
      }
    } else if (info.source == 'CurrentLevel') {
      _customResilienceCodename = info.alias;
      _customResilienceObj = widget.levelFile.objects.firstWhereOrNull(
        (o) => o.aliases?.contains(info.alias) == true,
      );
      if (_customResilienceObj?.objData is Map) {
        _customResilienceData = ZombieResilienceData.fromJson(
          Map<String, dynamic>.from(_customResilienceObj!.objData as Map),
        );
      }
    }
  }

  void _loadResilienceState() {
    final r = _propsData.resilience;
    if (r == null) {
      _selectedResilienceRtid = null;
      _customResilienceObj = null;
      _customResilienceData = ZombieResilienceData();
      _customResilienceCodename = '';
      return;
    }
    if (r is ZombieResilienceData) {
      _customResilienceData = ZombieResilienceData(
        amount: r.amount,
        weakType: r.weakType,
        recoverSpeed: r.recoverSpeed,
        damageThresholdPerSecond: r.damageThresholdPerSecond,
        resilienceBaseDamageThreshold: r.resilienceBaseDamageThreshold,
        resilienceExtraDamageThreshold: r.resilienceExtraDamageThreshold,
        animLabels: List<String>.from(r.animLabels),
      );
      _customResilienceCodename = _nextCustomResilienceCodename();
      final rtid = _ensureCustomResilienceInLevel();
      _propsData.resilience = rtid;
      _customResilienceObj = widget.levelFile.objects.firstWhereOrNull(
        (o) => o.aliases?.contains(RtidParser.parse(rtid)?.alias ?? '') == true,
      );
      _selectedResilienceRtid = rtid;
      _writeObjectsWithoutNotifying();
      WidgetsBinding.instance.addPostFrameCallback((_) => widget.onChanged());
      return;
    }
    if (r is! String || r.isEmpty) return;
    final info = RtidParser.parse(r);
    if (info == null) return;
    if (info.source == 'ResilienceConfig' || info.source == 'CurrentLevel') {
      _selectedResilienceRtid = r;
      _applySelectedResilienceRtid(r);
    }
  }

  String _nextCustomResilienceCodename() {
    var i = 0;
    while (true) {
      final codename = 'CustomResilience$i';
      final exists = widget.levelFile.objects.any(
        (o) => o.aliases?.contains(codename) == true,
      );
      if (!exists) return codename;
      i++;
    }
  }

  /// Ensures custom resilience object exists in level. Creates or updates it.
  /// Returns RTID(alias@CurrentLevel).
  String _ensureCustomResilienceInLevel() {
    var codename = _customResilienceCodename.trim();
    if (codename.isEmpty) {
      codename = _nextCustomResilienceCodename();
      _customResilienceCodename = codename;
    }

    if (_customResilienceObj != null) {
      _customResilienceObj!.aliases = [codename];
      _customResilienceObj!.objData = _customResilienceData.toLevelJson();
      final rtid = RtidParser.build(codename, 'CurrentLevel');
      _selectedResilienceRtid = rtid;
      return rtid;
    }
    final existing = widget.levelFile.objects.firstWhereOrNull(
      (o) => o.aliases?.contains(codename) == true,
    );
    if (existing != null && existing.objClass == 'ZombieResilience') {
      _customResilienceObj = existing;
      _customResilienceObj!.objData = _customResilienceData.toLevelJson();
      final rtid = RtidParser.build(codename, 'CurrentLevel');
      _selectedResilienceRtid = rtid;
      return rtid;
    }
    var finalCodename = codename;
    if (existing != null) {
      finalCodename = _nextCustomResilienceCodename();
      _customResilienceCodename = finalCodename;
    }
    final obj = PvzObject(
      aliases: [finalCodename],
      objClass: 'ZombieResilience',
      objData: _customResilienceData.toLevelJson(),
    );
    widget.levelFile.objects.add(obj);
    _customResilienceObj = obj;
    final rtid = RtidParser.build(finalCodename, 'CurrentLevel');
    _selectedResilienceRtid = rtid;
    return rtid;
  }

  bool get _isResilienceEnabled => _propsData.resilience != null;

  bool get _supportsResilienceShield =>
      ZombiePropertiesRepository.supportsResilienceShield(_typeData.typeName);

  String? get _currentResilienceRtid =>
      _selectedResilienceRtid ??
      (_propsData.resilience is String
          ? _propsData.resilience as String
          : null);

  void _stripUnsupportedResilience() {
    final r = _propsData.resilience;
    if (r == null) return;
    final oldRtid = r is String ? r : _selectedResilienceRtid;
    _propsData.resilience = null;
    _selectedResilienceRtid = null;
    _customResilienceObj = null;
    _customResilienceData = ZombieResilienceData();
    _customResilienceCodename = '';
    _writeObjectsWithoutNotifying();
    _deleteUnusedCustomResilience(oldRtid);
  }

  void _deleteUnusedCustomResilience(String? rtid) {
    if (!ResilienceShieldUtils.isCustomRtid(rtid)) return;
    if (rtid == _currentResilienceRtid) return;
    if (ResilienceShieldUtils.countReferences(widget.levelFile, rtid!) == 0) {
      ResilienceShieldUtils.deleteCustomShield(widget.levelFile, rtid);
    }
  }

  ResilienceConfigEntry? _currentResilienceEntry() {
    final rtid =
        _selectedResilienceRtid ??
        (_propsData.resilience is String
            ? _propsData.resilience as String
            : null);
    return ResilienceShieldUtils.resolveEntry(rtid, widget.levelFile);
  }

  Future<void> _pickResilienceShield() async {
    final oldRtid = _currentResilienceRtid;
    final rtid = await Navigator.push<String>(
      context,
      MaterialPageRoute(
        builder: (context) => ResilienceShieldSelectionScreen(
          levelFile: widget.levelFile,
          currentRtid:
              _selectedResilienceRtid ??
              (_propsData.resilience is String
                  ? _propsData.resilience as String
                  : null),
          onChanged: widget.onChanged,
        ),
      ),
    );
    if (!mounted || rtid == null) return;
    setState(() => _applySelectedResilienceRtid(rtid));
    _sync();
    _deleteUnusedCustomResilience(oldRtid);
  }

  Widget _buildResilienceShieldCard(AppLocalizations? l10n) {
    final entry = _currentResilienceEntry();
    final alias =
        entry?.alias ??
        RtidParser.parse(_selectedResilienceRtid ?? '')?.alias ??
        '';
    final source =
        RtidParser.parse(_selectedResilienceRtid ?? '')?.source ?? '';

    return ResilienceShieldSelectionCard(
      label:
          l10n?.resilienceSelectedShieldLabel ?? 'Selected Resilience Shield:',
      value: alias.isNotEmpty && source.isNotEmpty
          ? '$alias@$source'
          : (l10n?.resiliencePresetSelect ?? 'Selected resilience shield'),
      isCustom: source == ResilienceShieldUtils.customSource,
      onTap: _pickResilienceShield,
    );
  }

  Widget _buildResilienceParametersSummary(AppLocalizations? l10n) {
    final entry = _currentResilienceEntry();
    final data = entry?.data ?? _customResilienceData;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ResilienceShieldParameterRow(
          label: l10n?.resilienceAmount ?? 'Resilience value (Amount)',
          value: '${data.amount}',
        ),
        ResilienceShieldParameterRow(
          label: l10n?.resilienceWeakType ?? 'Resilience type (WeakType)',
          value: resilienceWeakTypeLabel(l10n, data.weakType),
          weakType: data.weakType,
        ),
        ResilienceShieldParameterRow(
          label:
              l10n?.resilienceRecoverSpeed ??
              'Resilience bar recovery speed (RecoverSpeed)',
          value: '${data.recoverSpeed}',
        ),
        ResilienceShieldParameterRow(
          label:
              l10n?.resilienceDamageThresholdPerSecond ??
              'Zombie damage threshold per second (DamageThresholdPerSecond)',
          value: '${data.damageThresholdPerSecond}',
        ),
        ResilienceShieldParameterRow(
          label:
              l10n?.resilienceBaseDamageThreshold ??
              'Resilience base damage threshold (ResilienceBaseDamageThreshold)',
          value: '${data.resilienceBaseDamageThreshold}',
        ),
        ResilienceShieldParameterRow(
          label:
              l10n?.resilienceExtraDamageThreshold ??
              'Resilience extra damage threshold (ResilienceExtraDamageThreshold)',
          value: '${data.resilienceExtraDamageThreshold}',
        ),
      ],
    );
  }

  void _sync({bool patchResistances = false}) {
    _writeObjectsWithoutNotifying(patchResistances: patchResistances);
    widget.onChanged();
    setState(() {});
  }

  void _writeObjectsWithoutNotifying({bool patchResistances = false}) {
    final typeObj = _typeObj;
    final propsObj = _propsObj;
    if (typeObj == null || propsObj == null) return;
    CustomZombiePropertySync.sync(
      typeObj: typeObj,
      propsObj: propsObj,
      typeData: _typeData,
      propsData: _propsData,
      resistances: _resistances,
      patchResistances: patchResistances,
    );
  }

  String _formatRect(RectData? rect) {
    if (rect == null) {
      return AppLocalizations.of(context)?.defaultPropertiesLabel ?? 'Default';
    }
    return 'X:${rect.mX}, Y:${rect.mY}, W:${rect.mWidth}, H:${rect.mHeight}';
  }

  String _formatPoint(Point2D? pt) {
    if (pt == null) {
      return AppLocalizations.of(context)?.defaultPropertiesLabel ?? 'Default';
    }
    return 'X:${pt.x}, Y:${pt.y}';
  }

  String _formatPoint3D(Point3DDouble? pt) {
    if (pt == null) {
      return AppLocalizations.of(context)?.defaultPropertiesLabel ?? 'Default';
    }
    return 'X:${pt.x}, Y:${pt.y}, Z:${pt.z}';
  }

  Future<void> _showRectDialog({
    required String title,
    required RectData initial,
    required ValueChanged<RectData> onConfirm,
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
              onConfirm(
                RectData(
                  mX: int.tryParse(xController.text) ?? initial.mX,
                  mY: int.tryParse(yController.text) ?? initial.mY,
                  mWidth: int.tryParse(wController.text) ?? initial.mWidth,
                  mHeight: int.tryParse(hController.text) ?? initial.mHeight,
                ),
              );
              Navigator.pop(ctx);
            },
            child: Text(l10n?.ok ?? 'OK'),
          ),
        ],
      ),
    );
  }

  Future<void> _showPoint2Dialog({
    required String title,
    required Point2D initial,
    required ValueChanged<Point2D> onConfirm,
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
              onConfirm(
                Point2D(
                  x: int.tryParse(xController.text) ?? initial.x,
                  y: int.tryParse(yController.text) ?? initial.y,
                ),
              );
              Navigator.pop(ctx);
            },
            child: Text(l10n?.ok ?? 'OK'),
          ),
        ],
      ),
    );
  }

  Future<void> _showPoint3Dialog({
    required String title,
    required Point3DDouble initial,
    required ValueChanged<Point3DDouble> onConfirm,
  }) async {
    final l10n = AppLocalizations.of(context);
    final xController = TextEditingController(text: '${initial.x}');
    final yController = TextEditingController(text: '${initial.y}');
    final zController = TextEditingController(text: '${initial.z}');
    await showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _numberField(xController, label: 'X', isDouble: true),
            const SizedBox(height: 8),
            _numberField(yController, label: 'Y', isDouble: true),
            const SizedBox(height: 8),
            _numberField(zController, label: 'Z', isDouble: true),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(l10n?.cancel ?? 'Cancel'),
          ),
          FilledButton(
            onPressed: () {
              onConfirm(
                Point3DDouble(
                  x: double.tryParse(xController.text) ?? initial.x,
                  y: double.tryParse(yController.text) ?? initial.y,
                  z: double.tryParse(zController.text) ?? initial.z,
                ),
              );
              Navigator.pop(ctx);
            },
            child: Text(l10n?.ok ?? 'OK'),
          ),
        ],
      ),
    );
  }

  Future<void> _showSizeTypeDialog() async {
    final l10n = AppLocalizations.of(context);
    final options = <String?>[null, 'small', 'mid', 'large'];
    var selected = _propsData.sizeType;
    await showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        scrollable: true,
        insetPadding: EdgeInsets.symmetric(
          horizontal: MediaQuery.sizeOf(ctx).width < 400 ? 16 : 40,
          vertical: 24,
        ),
        contentPadding: EdgeInsets.symmetric(
          horizontal: MediaQuery.sizeOf(ctx).width < 400 ? 12 : 24,
        ),
        title: Text(l10n?.selectSize ?? 'Select size'),
        content: StatefulBuilder(
          builder: (context, setState) {
            return RadioGroup<String?>(
              groupValue: selected,
              onChanged: (val) {
                setState(() {
                  selected = val;
                });
              },
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: options.map((opt) {
                  return RadioListTile<String?>(
                    value: opt,
                    title: Text(opt ?? 'null'),
                  );
                }).toList(),
              ),
            );
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(l10n?.cancel ?? 'Cancel'),
          ),
          FilledButton(
            onPressed: () {
              _propsData.sizeType = selected;
              _sync();
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
    bool isDouble = false,
  }) {
    return EditorResponsiveInputField(
      label: label,
      builder: (context, decoration) => TextField(
        controller: controller,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        decoration: decoration,
        onChanged: (_) {},
      ),
    );
  }

  Color get _themeColor => Theme.of(context).brightness == Brightness.dark
      ? pvzOrangeDark
      : pvzOrangeLight;

  ThemeData _inputTheme(ThemeData theme) {
    final accent = _themeColor;
    return theme.copyWith(
      colorScheme: theme.colorScheme.copyWith(primary: accent),
      inputDecorationTheme: theme.inputDecorationTheme.copyWith(
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: accent, width: 2),
        ),
        floatingLabelStyle: WidgetStateTextStyle.resolveWith((states) {
          if (states.contains(WidgetState.focused)) {
            return TextStyle(color: accent);
          }
          return TextStyle(color: theme.colorScheme.onSurface);
        }),
        focusColor: accent,
      ),
      textSelectionTheme: theme.textSelectionTheme.copyWith(
        cursorColor: accent,
        selectionHandleColor: accent,
      ),
    );
  }

  Widget _cardSectionTitle(String title) {
    final theme = Theme.of(context);
    return Text(
      title,
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
      style: theme.textTheme.titleMedium?.copyWith(
        fontWeight: FontWeight.bold,
        color: _themeColor,
      ),
    );
  }

  Widget _sectionCard({required Widget child}) {
    return SizedBox(
      width: double.infinity,
      child: Card(margin: EdgeInsets.zero, child: child),
    );
  }

  Widget _responsiveFieldPair({required Widget first, required Widget second}) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 600) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [first, const SizedBox(height: 12), second],
          );
        }
        return Row(
          children: [
            Expanded(child: first),
            const SizedBox(width: 12),
            Expanded(child: second),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final themeColor = _themeColor;
    final l10n = AppLocalizations.of(context);
    if (_typeObj == null) {
      return Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: widget.onBack,
          ),
          title: Text(
            l10n?.customZombie ?? 'Custom zombie',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        body: Center(
          child: Text(
            l10n?.zombieTypeNotFound ?? 'Zombie type object not found.',
            style: theme.textTheme.titleMedium,
          ),
        ),
      );
    }
    if (_propsObj == null) {
      final propsAlias = RtidParser.parse(_typeData.properties)?.alias ?? '';
      return Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: widget.onBack,
          ),
          title: Text(
            l10n?.customZombieProperties ?? 'Custom zombie properties',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          backgroundColor: themeColor,
          foregroundColor: theme.colorScheme.onPrimary,
        ),
        body: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(editorWarningIcon, size: 80, color: themeColor),
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
                    'The custom zombie\'s property object ($propsAlias) was not found in the level. The property definition does not point to level internals, so it cannot be edited here.',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: widget.onBack,
        ),
        title: Text(
          l10n?.customZombieProperties ?? 'Custom zombie properties',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        backgroundColor: themeColor,
        foregroundColor: theme.colorScheme.onPrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.help_outline),
            onPressed: () => showEditorHelpDialog(
              context,
              title: l10n?.customZombie ?? 'Custom zombie',
              themeColor: themeColor,
              sections: [
                HelpSectionData(
                  title: l10n?.customZombieHelpIntro ?? 'Brief introduction',
                  body:
                      l10n?.customZombieHelpIntroBody ??
                      'This screen edits custom zombie parameters injected into the level. Only common properties are supported; many special attributes require manual JSON editing.',
                ),
                HelpSectionData(
                  title: l10n?.customZombieHelpBase ?? 'Base properties',
                  body:
                      l10n?.customZombieHelpBaseBody ??
                      'Custom zombies can modify base stats (HP, speed, eat damage). Custom zombies do not appear in the level preview pool.',
                ),
                HelpSectionData(
                  title: l10n?.customZombieHelpHit ?? 'Hit/position',
                  body:
                      l10n?.customZombieHelpHitBody ??
                      'X and Y are offsets; W and H are width and height. Offsetting ArtCenter can hide the zombie sprite. Leaving ground track empty lets the zombie walk in place.',
                ),
                HelpSectionData(
                  title: l10n?.customZombieHelpManual ?? 'Manual editing',
                  body:
                      l10n?.customZombieHelpManualBody ??
                      'Custom injection auto-fills all properties from game files. You can further edit the JSON file manually if needed.',
                ),
              ],
            ),
          ),
        ],
      ),
      body: Theme(
        data: _inputTheme(theme),
        child: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          behavior: HitTestBehavior.deferToChild,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _sectionCard(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _cardSectionTitle(l10n?.baseStats ?? 'Base stats'),
                        const SizedBox(height: 12),
                        EditorResponsiveInputField(
                          label: l10n?.aliasLabel ?? 'Alias',
                          decoration: InputDecoration(
                            border: const OutlineInputBorder(),
                          ),
                          builder: (context, decoration) => TextFormField(
                            initialValue: _typeObj!.aliases?.isNotEmpty == true
                                ? _typeObj!.aliases!.first
                                : '',
                            decoration: decoration,
                            onChanged: (v) {
                              final trimmed = v.trim();
                              if (trimmed.isNotEmpty && _typeObj != null) {
                                _typeObj!.aliases = [trimmed];
                                widget.onChanged();
                                setState(() {});
                              }
                            },
                          ),
                        ),
                        const SizedBox(height: 12),
                        _doubleInput(
                          label: l10n?.hitpoints ?? 'Hitpoints',
                          value: _propsData.hitpoints,
                          onChanged: (v) {
                            _propsData.hitpoints = v;
                            _sync();
                          },
                        ),
                        const SizedBox(height: 12),
                        _responsiveFieldPair(
                          first: _doubleInput(
                            label: l10n?.speed ?? 'Speed',
                            value: _propsData.speed,
                            onChanged: (v) {
                              _propsData.speed = v;
                              _sync();
                            },
                          ),
                          second: _doubleInput(
                            label: l10n?.speedVariance ?? 'Speed variance',
                            value: _propsData.speedVariance ?? 0.1,
                            onChanged: (v) {
                              _propsData.speedVariance = v;
                              _sync();
                            },
                          ),
                        ),
                        const SizedBox(height: 12),
                        _doubleInput(
                          label: l10n?.eatDPS ?? 'EatDPS',
                          value: _propsData.eatDPS,
                          onChanged: (v) {
                            _propsData.eatDPS = v;
                            _sync();
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                _sectionCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                        child: _cardSectionTitle(
                          l10n?.hitPosition ?? 'Hit / position',
                        ),
                      ),
                      _editRow(
                        title: l10n?.hitRect ?? 'HitRect',
                        subtitle: _formatRect(_propsData.hitRect),
                        icon: Icons.aspect_ratio,
                        onTap: () => _showRectDialog(
                          title: l10n?.editHitRect ?? 'Edit HitRect',
                          initial:
                              _propsData.hitRect ??
                              RectData(mX: 10, mY: 10, mWidth: 32, mHeight: 95),
                          onConfirm: (r) {
                            _propsData.hitRect = r;
                            _sync();
                          },
                        ),
                      ),
                      const Divider(height: 1),
                      _editRow(
                        title: l10n?.attackRect ?? 'AttackRect',
                        subtitle: _formatRect(_propsData.attackRect),
                        icon: Icons.aspect_ratio,
                        onTap: () => _showRectDialog(
                          title: l10n?.editAttackRect ?? 'Edit AttackRect',
                          initial:
                              _propsData.attackRect ??
                              RectData(mX: 15, mY: 0, mWidth: 20, mHeight: 95),
                          onConfirm: (r) {
                            _propsData.attackRect = r;
                            _sync();
                          },
                        ),
                      ),
                      const Divider(height: 1),
                      _editRow(
                        title: l10n?.artCenter ?? 'ArtCenter',
                        subtitle: _formatPoint(_propsData.artCenter),
                        icon: Icons.center_focus_strong,
                        onTap: () => _showPoint2Dialog(
                          title: l10n?.editArtCenter ?? 'Edit ArtCenter',
                          initial:
                              _propsData.artCenter ?? Point2D(x: 90, y: 125),
                          onConfirm: (p) {
                            _propsData.artCenter = p;
                            _sync();
                          },
                        ),
                      ),
                      const Divider(height: 1),
                      _editRow(
                        title: l10n?.shadowOffset ?? 'ShadowOffset',
                        subtitle: _formatPoint3D(_propsData.shadowOffset),
                        icon: Icons.layers,
                        onTap: () => _showPoint3Dialog(
                          title: l10n?.editShadowOffset ?? 'Edit ShadowOffset',
                          initial:
                              _propsData.shadowOffset ??
                              Point3DDouble(x: 5.0, y: 0.0, z: 1.2),
                          onConfirm: (p) {
                            _propsData.shadowOffset = p;
                            _sync();
                          },
                        ),
                      ),
                      const Divider(height: 1),
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: EditorResponsiveInputField(
                          label:
                              l10n?.groundTrackName ?? 'GroundTrackName (行进轨迹)',
                          decoration: InputDecoration(
                            border: const OutlineInputBorder(),
                          ),
                          builder: (context, decoration) =>
                              DropdownButtonFormField<String>(
                                isExpanded: true,
                                initialValue:
                                    _propsData.groundTrackName ==
                                        'ground_swatch'
                                    ? 'ground_swatch'
                                    : '',
                                decoration: decoration,
                                items: [
                                  DropdownMenuItem(
                                    value: 'ground_swatch',
                                    child: Text(
                                      l10n?.groundTrackNormal ??
                                          'Normal ground (ground_swatch)',
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  DropdownMenuItem(
                                    value: '',
                                    child: Text(
                                      l10n?.groundTrackNone ?? 'None (null)',
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                                onChanged: (val) {
                                  if (val == null) return;
                                  _propsData.groundTrackName = val;
                                  _sync();
                                },
                              ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                _sectionCard(
                  child: Theme(
                    data: theme.copyWith(
                      switchTheme: SwitchThemeData(
                        trackColor: WidgetStateProperty.resolveWith((states) {
                          if (states.contains(WidgetState.selected)) {
                            return themeColor; // Amber when on
                          }
                          return null;
                        }),
                        thumbColor: WidgetStateProperty.resolveWith((states) {
                          if (states.contains(WidgetState.selected)) {
                            return theme.colorScheme.onPrimary;
                          }
                          return null;
                        }),
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _cardSectionTitle(
                            l10n?.appearanceBehavior ?? 'Appearance & behavior',
                          ),
                          const SizedBox(height: 12),
                          InkWell(
                            onTap: _showSizeTypeDialog,
                            child: Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        l10n?.sizeType ?? 'SizeType',
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      Text(
                                        _propsData.sizeType ?? 'null',
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: theme.textTheme.bodySmall
                                            ?.copyWith(
                                              color: theme
                                                  .colorScheme
                                                  .onSurfaceVariant,
                                            ),
                                      ),
                                    ],
                                  ),
                                ),
                                const Icon(Icons.edit, size: 18),
                              ],
                            ),
                          ),
                          const Divider(height: 24),
                          _switchRow(
                            title:
                                l10n?.disableDropFractions ??
                                'Disable drop fractions',
                            checked:
                                _propsData.armDropFraction != null ||
                                _propsData.headDropFraction != null,
                            onChanged: (checked) {
                              if (checked) {
                                _propsData.armDropFraction = -1;
                                _propsData.headDropFraction = 0;
                              } else {
                                _propsData.armDropFraction = null;
                                _propsData.headDropFraction = null;
                              }
                              _sync();
                            },
                          ),
                          _switchRow(
                            title:
                                l10n?.immuneToKnockback ??
                                'Immune to knockback',
                            checked:
                                _propsData.canBeLaunchedByPlants != null ||
                                _propsData.canBePlantTossedStrong != null ||
                                _propsData.canBePlantTossedweak != null,
                            onChanged: (checked) {
                              if (checked) {
                                _propsData.canBeLaunchedByPlants = false;
                                _propsData.canBePlantTossedweak = false;
                                _propsData.canBePlantTossedStrong = false;
                              } else {
                                _propsData.canBeLaunchedByPlants = null;
                                _propsData.canBePlantTossedweak = null;
                                _propsData.canBePlantTossedStrong = null;
                              }
                              _sync();
                            },
                          ),
                          _switchRow(
                            title:
                                l10n?.showHealthBarOnDamage ??
                                'Show health bar on damage',
                            checked:
                                _propsData.enableShowHealthBarByDamage == true,
                            onChanged: (checked) {
                              _propsData.enableShowHealthBarByDamage = checked
                                  ? true
                                  : null;
                              _propsData.drawHealthBarTime = checked
                                  ? (_propsData.drawHealthBarTime ?? 4.0)
                                  : null;
                              _sync();
                            },
                          ),
                          if (_propsData.enableShowHealthBarByDamage == true)
                            _doubleInput(
                              label:
                                  l10n?.drawHealthBarTime ??
                                  'DrawHealthBarTime',
                              value: _propsData.drawHealthBarTime ?? 4.0,
                              onChanged: (v) {
                                _propsData.drawHealthBarTime = v;
                                _sync();
                              },
                            ),
                          _switchRow(
                            title:
                                l10n?.enableEliteScale ?? 'Enable elite scale',
                            checked: _propsData.enableEliteScale == true,
                            onChanged: (checked) {
                              _propsData.enableEliteScale = checked
                                  ? true
                                  : null;
                              _propsData.eliteScale = checked
                                  ? (_propsData.eliteScale ?? 1.2)
                                  : null;
                              _sync();
                            },
                          ),
                          if (_propsData.enableEliteScale == true)
                            _doubleInput(
                              label: l10n?.eliteScale ?? 'EliteScale',
                              value: _propsData.eliteScale ?? 1.2,
                              onChanged: (v) {
                                _propsData.eliteScale = v;
                                _sync();
                              },
                            ),
                          _switchRow(
                            title:
                                l10n?.enableEliteImmunities ??
                                'Enable elite immunities',
                            checked: _propsData.enableEliteImmunities == true,
                            onChanged: (checked) {
                              _propsData.enableEliteImmunities = checked
                                  ? true
                                  : null;
                              _sync();
                            },
                          ),
                          _switchRow(
                            title:
                                l10n?.canSpawnPlantFood ??
                                'Can spawn plant food',
                            checked: _propsData.canSpawnPlantFood,
                            onChanged: (checked) {
                              _propsData.canSpawnPlantFood = checked;
                              _sync();
                            },
                          ),
                          _switchRow(
                            title: l10n?.canSurrender ?? 'Can surrender',
                            checked: _propsData.canSurrender == true,
                            onChanged: (checked) {
                              _propsData.canSurrender = checked ? true : null;
                              _sync();
                            },
                          ),
                          _switchRow(
                            title:
                                l10n?.canTriggerZombieWin ??
                                'Can trigger zombie win',
                            checked: _propsData.canTriggerZombieWin != false,
                            onChanged: (checked) {
                              _propsData.canTriggerZombieWin = checked
                                  ? null
                                  : false;
                              _sync();
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                if (_supportsResilienceShield) ...[
                  const SizedBox(height: 16),
                  _sectionCard(
                    child: Theme(
                      data: theme.copyWith(
                        switchTheme: SwitchThemeData(
                          trackColor: WidgetStateProperty.resolveWith((states) {
                            if (states.contains(WidgetState.selected)) {
                              return themeColor;
                            }
                            return null;
                          }),
                          thumbColor: WidgetStateProperty.resolveWith((states) {
                            if (states.contains(WidgetState.selected)) {
                              return theme.colorScheme.onPrimary;
                            }
                            return null;
                          }),
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            _cardSectionTitle(
                              l10n?.resilienceArmor ?? 'Resilience (armor)',
                            ),
                            const SizedBox(height: 12),
                            _switchRow(
                              title:
                                  l10n?.enableResilience ?? 'Enable resilience',
                              checked: _isResilienceEnabled,
                              onChanged: (checked) async {
                                if (checked) {
                                  final options = _resilienceShieldOptions();
                                  if (options.isNotEmpty) {
                                    final oldRtid = _currentResilienceRtid;
                                    _applySelectedResilienceRtid(
                                      options.first.rtid,
                                    );
                                    _sync();
                                    _deleteUnusedCustomResilience(oldRtid);
                                  } else {
                                    await _pickResilienceShield();
                                  }
                                } else {
                                  final oldRtid = _currentResilienceRtid;
                                  _propsData.resilience = null;
                                  _selectedResilienceRtid = null;
                                  _customResilienceObj = null;
                                  _customResilienceCodename = '';
                                  _sync();
                                  _deleteUnusedCustomResilience(oldRtid);
                                }
                                setState(() {});
                              },
                            ),
                            if (_isResilienceEnabled) ...[
                              const Divider(height: 24),
                              _buildResilienceShieldCard(l10n),
                              const SizedBox(height: 16),
                              _buildResilienceParametersSummary(l10n),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
                const SizedBox(height: 16),
                _sectionCard(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _cardSectionTitle(l10n?.resilience ?? 'Resilience'),
                        const SizedBox(height: 12),
                        _resistanceInput(
                          context: context,
                          index: 0,
                          label:
                              l10n?.instantKillResistance ??
                              'Instant kill resistance',
                          iconPath: null,
                        ),
                        const SizedBox(height: 12),
                        for (var i = 0; i < 3; i++)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: _responsiveFieldPair(
                              first: _resistanceInput(
                                context: context,
                                index: 1 + i * 2,
                                label: _resLabel(context, 1 + i * 2),
                                iconPath: _resIcons[1 + i * 2],
                              ),
                              second: _resistanceInput(
                                context: context,
                                index: 2 + i * 2,
                                label: _resLabel(context, 2 + i * 2),
                                iconPath: _resIcons[2 + i * 2],
                              ),
                            ),
                          ),
                        Text(
                          l10n?.resilienceHint ??
                              '0.0 = none, 1.0 = full immunity',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  l10n?.zombieTypeLabel(_typeData.typeName) ??
                      'Zombie type: ${_typeData.typeName}',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                Text(
                  l10n?.propertyAliasLabel(
                        RtidParser.parse(_typeData.properties)?.alias ?? '',
                      ) ??
                      'Property alias: ${RtidParser.parse(_typeData.properties)?.alias ?? ''}',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _resLabel(BuildContext context, int index) {
    final l10n = AppLocalizations.of(context);
    switch (index) {
      case 1:
        return l10n?.resiliencePhysics ?? 'Physics';
      case 2:
        return l10n?.resiliencePoison ?? 'Poison';
      case 3:
        return l10n?.resilienceElectric ?? 'Electric';
      case 4:
        return l10n?.resilienceMagic ?? 'Magic';
      case 5:
        return l10n?.resilienceIce ?? 'Ice';
      case 6:
        return l10n?.resilienceFire ?? 'Fire';
      default:
        return '';
    }
  }

  static const _resIcons = TagAssets.attributeIcons;

  Widget _resistanceInput({
    required BuildContext context,
    required int index,
    required String label,
    required String? iconPath,
  }) {
    return _ResilienceInputField(
      key: ValueKey('resistance_$index'),
      label: label,
      value: _resistances[index],
      iconPath: iconPath,
      onChanged: (v) {
        _resistances[index] = v.clamp(0.0, 1.0);
        _sync(patchResistances: true);
      },
    );
  }

  Widget _editRow({
    required String title,
    required String subtitle,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    final themeColor = _themeColor;
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Icon(icon, color: themeColor),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
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

  Widget _switchRow({
    required String title,
    required bool checked,
    required ValueChanged<bool> onChanged,
  }) {
    return EditorResponsiveSwitchRow(
      label: title,
      value: checked,
      onChanged: onChanged,
    );
  }

  Widget _doubleInput({
    required String label,
    required double value,
    required ValueChanged<double> onChanged,
  }) {
    return _DoubleInputField(
      key: ValueKey(label),
      label: label,
      value: value,
      onChanged: onChanged,
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
    _focusNode.addListener(_onFocusChange);
  }

  void _onFocusChange() {
    final focused = _focusNode.hasFocus;
    if (_isFocused != focused) {
      setState(() => _isFocused = focused);
    }
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
    _focusNode.removeListener(_onFocusChange);
    _focusNode.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _ResponsiveNumberTextField(
      label: widget.label,
      controller: _controller,
      focusNode: _focusNode,
      onChanged: (v) {
        final n = double.tryParse(v);
        if (n != null) widget.onChanged(n);
      },
    );
  }
}

/// Resilience input field with same styling as base stats (_DoubleInputField).
class _ResilienceInputField extends StatefulWidget {
  const _ResilienceInputField({
    super.key,
    required this.label,
    required this.value,
    required this.onChanged,
    this.iconPath,
  });

  final String label;
  final double value;
  final ValueChanged<double> onChanged;
  final String? iconPath;

  @override
  State<_ResilienceInputField> createState() => _ResilienceInputFieldState();
}

class _ResilienceInputFieldState extends State<_ResilienceInputField> {
  late TextEditingController _controller;
  late FocusNode _focusNode;
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.value.toStringAsFixed(2));
    _focusNode = FocusNode();
    _focusNode.addListener(_onFocusChange);
  }

  void _onFocusChange() {
    final focused = _focusNode.hasFocus;
    if (_isFocused != focused) {
      setState(() => _isFocused = focused);
    }
  }

  @override
  void didUpdateWidget(covariant _ResilienceInputField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!_isFocused && oldWidget.value != widget.value) {
      _controller.text = widget.value.toStringAsFixed(2);
    }
  }

  @override
  void dispose() {
    _focusNode.removeListener(_onFocusChange);
    _focusNode.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _ResponsiveNumberTextField(
      label: widget.label,
      controller: _controller,
      focusNode: _focusNode,
      prefixIcon: widget.iconPath != null
          ? Padding(
              padding: const EdgeInsets.all(8),
              child: AssetImageWidget(
                assetPath: widget.iconPath!,
                width: 20,
                height: 20,
                fit: BoxFit.contain,
                altCandidates: imageAltCandidates(widget.iconPath!),
              ),
            )
          : null,
      onChanged: (v) {
        final val = double.tryParse(v);
        if (val != null) {
          widget.onChanged(val.clamp(0.0, 1.0));
        }
      },
    );
  }
}

class _ResponsiveNumberTextField extends StatelessWidget {
  const _ResponsiveNumberTextField({
    required this.label,
    required this.controller,
    required this.focusNode,
    required this.onChanged,
    this.prefixIcon,
  });

  final String label;
  final TextEditingController controller;
  final FocusNode focusNode;
  final ValueChanged<String> onChanged;
  final Widget? prefixIcon;

  @override
  Widget build(BuildContext context) {
    return EditorResponsiveInputField(
      label: label,
      decoration: InputDecoration(
        border: const OutlineInputBorder(),
        prefixIcon: prefixIcon,
      ),
      builder: (context, decoration) => TextField(
        controller: controller,
        focusNode: focusNode,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        decoration: decoration,
        onChanged: onChanged,
      ),
    );
  }
}

class _ResilienceShieldOption {
  const _ResilienceShieldOption({
    required this.rtid,
    required this.alias,
    required this.source,
    required this.weakType,
  });

  final String rtid;
  final String alias;
  final String source;
  final int weakType;
}
