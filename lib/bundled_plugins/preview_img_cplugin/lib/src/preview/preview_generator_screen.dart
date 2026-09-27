import 'package:c_editor/widgets/autosave.dart';
import 'package:c_editor/l10n/app_localizations.dart';
import 'package:flutter/foundation.dart'
    show kIsWeb, listEquals, visibleForTesting;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:c_editor/bundled_plugins/preview_img_cplugin/lib/src/preview/gif_first_frame.dart';
import 'package:c_editor/bundled_plugins/preview_img_cplugin/lib/src/preview/preview_auto_composer.dart';
import 'package:c_editor/bundled_plugins/preview_img_cplugin/lib/src/preview/preview_canvas.dart';
import 'package:c_editor/bundled_plugins/preview_img_cplugin/lib/src/preview/preview_document.dart';
import 'package:c_editor/bundled_plugins/preview_img_cplugin/lib/src/preview/preview_document_snapshot.dart';
import 'package:c_editor/bundled_plugins/preview_img_cplugin/lib/src/preview/preview_editor_workspace.dart';
import 'package:c_editor/bundled_plugins/preview_img_cplugin/lib/src/preview/preview_feature_groups.dart';
import 'package:c_editor/bundled_plugins/preview_img_cplugin/lib/src/preview/preview_fonts.dart';
import 'package:c_editor/bundled_plugins/preview_img_cplugin/lib/src/preview/preview_module_info.dart';
import 'package:c_editor/bundled_plugins/preview_img_cplugin/lib/src/preview/preview_module_resource_names.dart';
import 'package:c_editor/bundled_plugins/preview_img_cplugin/lib/src/preview/preview_pickers.dart';
import 'package:c_editor/bundled_plugins/preview_img_cplugin/lib/src/preview/preview_png_exporter.dart';
import 'package:c_editor/bundled_plugins/preview_img_cplugin/lib/src/preview/preview_rich_text_controller.dart';
import 'preview_toolbar_prefs.dart';
import 'preview_toolbar_action.dart';
import 'preview_generator_pickers.dart';
import 'preview_layers_dialog.dart';
import 'preview_picker_session.dart';
import 'preview_sticker_catalog.dart';
import 'preview_user_image.dart';
import 'preview_gif_first_frames.dart';
import 'preview_gif_png_notice_dialog.dart';
import 'package:c_editor/bundled_plugins/preview_img_cplugin/lib/src/preview/stage_banner_resolver.dart';
import 'package:c_editor/data/pvz_models.dart';
import 'package:c_editor/data/registry/module_registry.dart';
import 'package:c_editor/l10n/resource_names.dart';
import 'package:c_editor/widgets/editor_components.dart';
import 'package:c_editor/widgets/app_ui_scale.dart';
import 'package:c_editor/plugin_api/c_plugin_host.dart';
import 'dart:ui' as ui;

/// Desktop windows keep the full-width budget. Mobile screens can use the
/// scrollable toolbar and view-only canvas zoom at a smaller allocation.
const double kPreviewGeneratorMinimumWidth = 600;
const double kPreviewGeneratorMinimumMobileWidth = 360;

@visibleForTesting
bool isPreviewGeneratorWidthAvailable(double availableWidth) =>
    availableWidth >= kPreviewGeneratorMinimumWidth;

@visibleForTesting
bool isPreviewGeneratorDisplayAreaAvailable({
  required Size availableSize,
  required TargetPlatform platform,
  double uiScale = 1,
  bool isWeb = kIsWeb,
}) {
  // Even the responsive controls need a usable touch/keyboard editing area.
  if (!availableSize.width.isFinite ||
      !availableSize.height.isFinite ||
      availableSize.width < 320 ||
      availableSize.height < 160 ||
      !uiScale.isFinite ||
      uiScale <= 0) {
    return false;
  }
  final windowAllocation = availableSize * uiScale;
  final nativeMobile = useMobilePreviewGeneratorNarrowPrompt(
    platform: platform,
    isWeb: isWeb,
  );
  if (!nativeMobile) {
    return isPreviewGeneratorWidthAvailable(windowAllocation.width);
  }
  // Phones can edit in either orientation with the scrollable toolbar and
  // canvas zoom. Keep a minimum window width for narrow split-screen regions;
  // zooming the UI out must not bypass this allocation budget.
  return windowAllocation.width >= kPreviewGeneratorMinimumMobileWidth;
}

@visibleForTesting
bool useMobilePreviewGeneratorNarrowPrompt({
  required TargetPlatform platform,
  bool isWeb = kIsWeb,
}) {
  if (isWeb) return false;
  return platform == TargetPlatform.android || platform == TargetPlatform.iOS;
}

/// Asks for Normal / Simple starting layout. Cancel returns null.
/// [Simple] is the recommended (primary) action.
Future<PreviewAutoStyle?> showPreviewLayoutStyleDialog({
  required BuildContext context,
  required String Function(String key, [String? fallback]) t,
  bool recreate = false,
  bool barrierDismissible = false,
}) {
  return showDialog<PreviewAutoStyle>(
    context: context,
    barrierDismissible: barrierDismissible,
    builder: (ctx) {
      final theme = Theme.of(ctx);
      return AlertDialog(
        scrollable: true,
        title: Text(
          t(
            recreate ? 'previewGenRecreate' : 'previewGenStartTitle',
            recreate ? 'Recreate again' : 'Choose starting layout',
          ),
        ),
        content: Text(
          t(
            recreate ? 'previewGenRecreateHint' : 'previewGenStartHint',
            recreate
                ? 'Replace the current preview with a fresh layout? You can undo afterwards.'
                : 'Simple is recommended for most levels. You can edit freely after generating.',
          ),
        ),
        actions: [
          TextButton(
            style: TextButton.styleFrom(
              foregroundColor: theme.colorScheme.error,
            ),
            onPressed: () => Navigator.pop(ctx),
            child: Text(t('previewGenCancel', 'Cancel')),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, PreviewAutoStyle.normal),
            child: Text(
              t(
                recreate ? 'previewGenRecreateFromNormal' : 'previewGenNormal',
                recreate ? 'From normal' : 'Normal',
              ),
            ),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, PreviewAutoStyle.simple),
            child: Text(
              t(
                recreate ? 'previewGenRecreateFromSimple' : 'previewGenSimple',
                recreate ? 'From simple' : 'Simple',
              ),
            ),
          ),
        ],
      );
    },
  );
}

class PreviewGeneratorScreen extends StatefulWidget {
  const PreviewGeneratorScreen({
    super.key,
    required this.host,
    required this.levelFile,
    required this.parsed,
    required this.fileName,
    this.initialStyle = PreviewAutoStyle.simple,
    @visibleForTesting this.imageExporter,
  });

  final CPluginHost host;
  final PvzLevelFile levelFile;
  final ParsedLevelData parsed;
  final String fileName;
  final PreviewAutoStyle initialStyle;

  /// Overrides file output in tests; normal use writes to the export folder.
  @visibleForTesting
  final Future<PreviewExportResult> Function(ui.Image image, String fileName)?
  imageExporter;

  @override
  State<PreviewGeneratorScreen> createState() => _PreviewGeneratorScreenState();
}

class _PreviewGeneratorScreenState extends State<PreviewGeneratorScreen> {
  final _boundaryKey = GlobalKey();
  final _stickerPickerSession = PreviewStickerPickerSession();
  final _bannerPickerSession = PreviewPickerSession();
  final _moduleInfoPickerSession = PreviewPickerSession();
  final _figuresPickerSession = PreviewPickerSession();
  final _layersPickerSession = PreviewPickerSession();
  final _textController = PreviewRichTextController();
  // Content fields use UI text; preview styling belongs only on the canvas.
  final _textContentController = TextEditingController();
  final _textContentKey = GlobalKey();
  final _textContentFocusNode = FocusNode();
  bool _syncingTextContent = false;
  bool _editingTextInToolbar = false;
  final _focusNode = FocusNode();
  final _textFocusNode = FocusNode();
  String _lastControllerText = '';

  /// Snapshot taken on toolbar pointer-down so range styles survive focus theft.
  TextSelection? _toolbarSelectionSnapshot;
  final List<_TextEditCheckpoint> _textUndoStack = [];
  final List<_TextEditCheckpoint> _textRedoStack = [];

  PreviewDocument? _document;
  StageBannerResolver? _banners;
  late PreviewAutoStyle _autoStyle = widget.initialStyle;
  PreviewEditTool _tool = PreviewEditTool.select;
  PreviewToolbarStyle _toolbarStyle = PreviewToolbarStyle.full;
  PreviewShapeKind _figureKind = PreviewShapeKind.rect;
  bool _figureFilled = false;
  String? _selectedLayerId;
  String? _editingTextLayerId;
  PreviewTextPartSelection? _selectedTextPart;
  int? _selectedIconSectionIndex;
  int? _selectedIconRowIndex;
  final _iconRowControlKey = GlobalKey();
  String? _activeStrokeId;
  String? _draftShapeId;
  Color _drawColor = Colors.white;
  final double _drawStrokeWidth = 4;
  int _idSeq = 0;
  bool _loading = true;
  bool _exporting = false;
  bool _confirmingGifExport = false;
  Map<String, ui.Image> _exportImageFrames = const {};
  bool _widthAvailable = false;
  bool _confirmingExit = false;
  bool _allowExit = false;
  String? _error;
  Future<List<PreviewSticker>>? _layerStickerCatalog;

  PreviewDocument? _undoSnapshot;
  PreviewDocument? _redoSnapshot;
  PreviewDocumentSnapshot? _savedDocumentSnapshot;

  bool get _hasUnsavedChanges {
    final document = _document;
    return document != null &&
        (_savedDocumentSnapshot == null ||
            !_savedDocumentSnapshot!.matches(document));
  }

  static const _palette = <Color>[
    Colors.white,
    Colors.black,
    Color(0xFFFFE082),
    Colors.red,
    Colors.blue,
    Colors.green,
    Colors.purple,
    Colors.orange,
  ];

  String _t(String key, [String? fallback, Map<String, Object?>? args]) =>
      widget.host.localize(context, key, fallback ?? key, args);

  @override
  void initState() {
    super.initState();
    _textController.addListener(_onTextControllerTick);
    _textContentController.addListener(_onTextContentControllerTick);
    _textFocusNode.addListener(_onTextFocusChanged);
    _textContentFocusNode.addListener(_onTextContentFocusChanged);
    HardwareKeyboard.instance.addHandler(_onHardwareKey);
    _loadToolbarStyle();
    _compose();
  }

  Future<void> _loadToolbarStyle() async {
    final style = await PreviewToolbarPrefs.getStyle();
    if (mounted) setState(() => _toolbarStyle = style);
  }

  void _onTextControllerTick() {
    if (!mounted) return;
    _syncPlainTextContent();
    if (_textController.isApplyingProgrammaticValue) {
      _lastControllerText = _textController.text;
      return;
    }
    final textChanged = _textController.text != _lastControllerText;
    _lastControllerText = _textController.text;
    // Caret moves clear typingStyle inside the controller; rebuild toolbar.
    if (!textChanged) {
      setState(() {});
      return;
    }
    final layer = _selectedTextLayer();
    if (layer != null && _editingTextLayerId == layer.id) {
      // Checkpoint the pre-edit layer before applying the controller's new runs.
      _pushTextCheckpoint(layer);
      if (_undoSnapshot == null) _pushHistory(force: true);
      _textController.applyToLayer(layer);
    }
    setState(() {});
    _ensureTextFocus();
  }

  void _syncPlainTextContent() {
    if (_selectedTextLayer() == null ||
        _textContentController.value == _textController.value) {
      return;
    }
    _syncingTextContent = true;
    _textContentController.value = _textController.value;
    _syncingTextContent = false;
  }

  void _onTextContentControllerTick() {
    if (!mounted || _syncingTextContent || !_editingTextInToolbar) return;
    final layer = _selectedTextLayer();
    if (layer == null || _editingTextLayerId != layer.id) return;
    // Keep rich runs, selection and composing ranges in sync without rendering
    // their font, colour, size or outline inside the toolbar input.
    _textController.value = _textContentController.value;
  }

  void _onTextContentFocusChanged() {
    if (!mounted) return;
    final layer = _selectedTextLayer();
    if (_textContentFocusNode.hasFocus && layer != null) {
      setState(() {
        if (_editingTextLayerId != layer.id) _clearTextHistory();
        _editingTextLayerId = layer.id;
        _editingTextInToolbar = true;
      });
      _textController.value = _textContentController.value;
      _ensureTextFocus();
    } else {
      _onTextFocusChanged();
    }
  }

  void _onTextFocusChanged() {
    if (!mounted) return;
    setState(() {});
    if (_textFocusNode.hasFocus ||
        _textContentFocusNode.hasFocus ||
        _editingTextLayerId == null) {
      return;
    }
    // Focus left the field while still in edit mode (e.g. parent Focus stole
    // it on rebuild). Restore unless another control intentionally took it.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || _editingTextLayerId == null) return;
      if (_textFocusNode.hasFocus || _textContentFocusNode.hasFocus) return;
      final primary = FocusManager.instance.primaryFocus;
      if (primary == null || primary == _focusNode) {
        _ensureTextFocus();
      }
    });
  }

  void _ensureTextFocus() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || _editingTextLayerId == null) return;
      final target = _editingTextInToolbar
          ? _textContentFocusNode
          : _textFocusNode;
      if (!target.hasFocus) target.requestFocus();
      if (_editingTextInToolbar) {
        final contentContext = _textContentKey.currentContext;
        if (contentContext != null) {
          Scrollable.ensureVisible(contentContext, alignment: 0);
        }
      }
    });
  }

  void _runTextToolbarAction(VoidCallback action) {
    final snap = _toolbarSelectionSnapshot;
    if (snap != null &&
        snap.isValid &&
        !snap.isCollapsed &&
        _editingTextLayerId != null) {
      // Restore range before mutating — InkWell focus clears TextField selection.
      _textController.selection = TextSelection(
        baseOffset: snap.baseOffset.clamp(0, _textController.text.length),
        extentOffset: snap.extentOffset.clamp(0, _textController.text.length),
      );
    }
    action();
    _toolbarSelectionSnapshot = null;
    _ensureTextFocus();
  }

  void _snapshotTextSelectionForToolbar() {
    if (_editingTextLayerId == null) return;
    final sel = _textController.selection;
    if (sel.isValid) {
      _toolbarSelectionSnapshot = sel;
    }
  }

  @override
  void dispose() {
    _textController.removeListener(_onTextControllerTick);
    _textContentController.removeListener(_onTextContentControllerTick);
    _textFocusNode.removeListener(_onTextFocusChanged);
    _textContentFocusNode.removeListener(_onTextContentFocusChanged);
    HardwareKeyboard.instance.removeHandler(_onHardwareKey);
    _textController.dispose();
    _textContentController.dispose();
    _textContentFocusNode.dispose();
    _textFocusNode.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  String _nextId(String prefix) => '${prefix}_${_idSeq++}';

  void _clearTextHistory() {
    _textUndoStack.clear();
    _textRedoStack.clear();
  }

  void _pushTextCheckpoint(PreviewLayer layer) {
    final sel = _textController.selection;
    final len = layer.plainText.length;
    final safeSel = sel.isValid
        ? TextSelection(
            baseOffset: sel.baseOffset.clamp(0, len),
            extentOffset: sel.extentOffset.clamp(0, len),
          )
        : TextSelection.collapsed(offset: len);
    _textUndoStack.add(_TextEditCheckpoint.capture(layer, safeSel));
    if (_textUndoStack.length > 80) {
      _textUndoStack.removeAt(0);
    }
    _textRedoStack.clear();
  }

  bool get _canUndoText =>
      _editingTextLayerId != null && _textUndoStack.isNotEmpty;

  bool get _canRedoText =>
      _editingTextLayerId != null && _textRedoStack.isNotEmpty;

  void _undoTextEdit() {
    final layer = _selectedTextLayer();
    if (layer == null || _textUndoStack.isEmpty) return;
    _textRedoStack.add(
      _TextEditCheckpoint.capture(layer, _textController.selection),
    );
    final past = _textUndoStack.removeLast();
    past.applyTo(layer);
    _textController.loadFromLayer(layer);
    final len = _textController.text.length;
    _textController.selection = TextSelection(
      baseOffset: past.selection.baseOffset.clamp(0, len),
      extentOffset: past.selection.extentOffset.clamp(0, len),
    );
    _lastControllerText = _textController.text;
    setState(() {});
    _ensureTextFocus();
  }

  void _redoTextEdit() {
    final layer = _selectedTextLayer();
    if (layer == null || _textRedoStack.isEmpty) return;
    _textUndoStack.add(
      _TextEditCheckpoint.capture(layer, _textController.selection),
    );
    final next = _textRedoStack.removeLast();
    next.applyTo(layer);
    _textController.loadFromLayer(layer);
    final len = _textController.text.length;
    _textController.selection = TextSelection(
      baseOffset: next.selection.baseOffset.clamp(0, len),
      extentOffset: next.selection.extentOffset.clamp(0, len),
    );
    _lastControllerText = _textController.text;
    setState(() {});
    _ensureTextFocus();
  }

  void _clearHistory() {
    _undoSnapshot = null;
    _redoSnapshot = null;
    _clearTextHistory();
  }

  void _pushHistory({bool force = false}) {
    // While editing text, incremental checkpoints live on _textUndoStack.
    if (!force && _editingTextLayerId != null) return;
    final doc = _document;
    if (doc == null) return;
    _undoSnapshot = doc.copy();
    _redoSnapshot = null;
  }

  void _undo() {
    if (_canUndoText) {
      _undoTextEdit();
      return;
    }
    final doc = _document;
    final past = _undoSnapshot;
    if (doc == null || past == null) return;
    setState(() {
      _redoSnapshot = doc.copy();
      _document = past;
      _undoSnapshot = null;
      _selectedLayerId = null;
      _editingTextLayerId = null;
      _selectedTextPart = null;
      _activeStrokeId = null;
      _draftShapeId = null;
      _clearTextHistory();
      _syncTextController();
    });
  }

  void _redo() {
    if (_canRedoText) {
      _redoTextEdit();
      return;
    }
    final doc = _document;
    final future = _redoSnapshot;
    if (doc == null || future == null) return;
    setState(() {
      _undoSnapshot = doc.copy();
      _document = future;
      _redoSnapshot = null;
      _selectedLayerId = null;
      _editingTextLayerId = null;
      _selectedTextPart = null;
      _activeStrokeId = null;
      _draftShapeId = null;
      _clearTextHistory();
      _syncTextController();
    });
  }

  Future<void> _compose({bool clearHistory = true}) async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final banners = await StageBannerResolver.load();
      PreviewFeatureGroups.resetForTest();
      final groups = await PreviewFeatureGroups.load();
      final doc = await PreviewAutoComposer(
        levelFile: widget.levelFile,
        parsed: widget.parsed,
        fileName: widget.fileName,
        banners: banners,
        featureGroups: groups,
        style: _autoStyle,
        localize: (key, fallback) => _t(key, fallback),
        moduleTitle: (objClass) =>
            ModuleRegistry.getMetadata(objClass).getTitle(context),
        plantsSourceLabel: _t('previewGenPlants', 'Plants'),
        zombiesSourceLabel: _t('previewGenZombies', 'Zombies'),
        gridItemsSourceLabel: _t('previewGenGridItems', 'Grid Items'),
        seedBankLabel: _t('previewSeedBank', 'Seed Bank'),
        zombieSeedBankLabel: _t(
          'previewIZombieSeedBank',
          'Seed Bank (I, Zombie)',
        ),
        vasebreakerLabel: _t('previewGenVaseContent', 'Vase content'),
        conveyorLabel: _t('previewGenConveyor', 'Conveyor'),
        prePlacedLabel: _t('previewGenPresetLayout', 'Preset layout'),
        protectLabel: _t('previewGenProtect', 'Endangered targets'),
        challengeLabel: _t('previewGenChallenge', 'Challenge'),
        wavesLabel: _t('previewGenWaves', 'Waves'),
        initialZombiesLabel: _t('previewGenInitial', 'Initial'),
        zombotPrefix: _t('previewGenZombotPrefix', 'Zombot: '),
        zombossPrefix: _t('previewGenZombossPrefix', 'Zomboss: '),
        spawnedZombiesLabel: _t(
          'previewGenSpawnedZombies',
          'Spawned zombies: ',
        ),
        resourceName: (id) => ResourceNames.lookup(context, id),
      ).compose();
      if (!mounted) return;
      setState(() {
        _banners = banners;
        _document = doc;
        _loading = false;
        _selectedLayerId = null;
        _editingTextLayerId = null;
        _selectedTextPart = null;
        _activeStrokeId = null;
        _draftShapeId = null;
        if (clearHistory) {
          _clearHistory();
        } else {
          _redoSnapshot = null;
        }
        _syncTextController();
      });
    } catch (e) {
      debugPrint('Preview composition failed: $e');
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = _t(
          'previewGenLoadFail',
          'Could not create the preview. Please try again.',
        );
      });
    }
  }

  Future<void> _recreateFromAuto() async {
    _endTextEdit();
    final choice = await showPreviewLayoutStyleDialog(
      context: context,
      t: _t,
      recreate: true,
      barrierDismissible: true,
    );
    if (choice == null || !mounted) return;
    _pushHistory();
    setState(() => _autoStyle = choice);
    await _compose(clearHistory: false);
  }

  void _syncTextController() {
    _selectedIconSectionIndex = null;
    _selectedIconRowIndex = null;
    final layer = _selectedTextLayer();
    if (layer != null) {
      _textController.loadFromLayer(layer);
    } else {
      // Use the rich controller's programmatic path for panel/shape text too,
      // so selection changes are not mistaken for edits of the previous layer.
      _textController.loadFromLayer(
        PreviewLayer(
          id: 'selected_text_part',
          kind: PreviewLayerKind.text,
          bounds: const Rect.fromLTWH(0, 0, 1, 1),
          text: _selectedTextValue() ?? '',
          textStyle: _selectedContainedText()?.style.copy(),
        ),
      );
    }
    _lastControllerText = _textController.text;
    final content = _selectedTextValue() ?? '';
    _syncingTextContent = true;
    _textContentController.value = TextEditingValue(
      text: content,
      selection: TextSelection.collapsed(offset: content.length),
    );
    _syncingTextContent = false;
  }

  static const _fontSizeChoices = <double>[
    12,
    14,
    16,
    18,
    20,
    24,
    28,
    32,
    36,
    42,
    48,
    56,
    64,
    72,
    84,
    96,
  ];

  double _snapFontSize(double size) {
    var best = _fontSizeChoices.first;
    var bestDist = (best - size).abs();
    for (final candidate in _fontSizeChoices) {
      final dist = (candidate - size).abs();
      if (dist < bestDist) {
        best = candidate;
        bestDist = dist;
      }
    }
    return best;
  }

  PreviewTextStyleData _activeTextStyle(PreviewLayer layer) {
    if (_editingTextLayerId == layer.id) {
      return _textController.styleAtCaret();
    }
    layer.ensureTextRuns();
    return (layer.textStyle ??
            (layer.textRuns.isNotEmpty
                ? layer.textRuns.first.style
                : PreviewTextStyleData()))
        .copy();
  }

  void _mutateSelectedTextStyle(
    PreviewLayer layer,
    void Function(PreviewTextStyleData style) mutate,
  ) {
    if (_editingTextLayerId == layer.id) {
      _pushTextCheckpoint(layer);
      _textController.mutateActiveStyle(mutate);
      _textController.applyToLayer(layer);
      return;
    }
    layer.ensureTextRuns();
    final sel = _textController.selection;
    if (sel.isValid && !sel.isCollapsed) {
      layer.applyStyleToRange(sel.start, sel.end, mutate);
    } else {
      layer.applyStyleToRange(0, layer.plainText.length, mutate);
    }
    _textController.loadFromLayer(layer);
  }

  Widget _toolbarToggleShell({
    required String tooltip,
    required bool selected,
    required VoidCallback onTap,
    required Widget child,
  }) {
    final theme = Theme.of(context);
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(6),
        child: Container(
          width: 34,
          height: 34,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: selected
                ? theme.colorScheme.primary.withValues(alpha: 0.18)
                : theme.colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(6),
            border: Border.all(
              color: selected
                  ? theme.colorScheme.primary
                  : theme.colorScheme.outlineVariant,
            ),
          ),
          child: child,
        ),
      ),
    );
  }

  Widget _styleToggle({
    required String label,
    required String tooltip,
    required bool selected,
    required TextStyle style,
    required VoidCallback onTap,
  }) {
    return _toolbarToggleShell(
      tooltip: tooltip,
      selected: selected,
      onTap: onTap,
      child: Text(label, style: style),
    );
  }

  Widget _alignToggle({
    required IconData icon,
    required String tooltip,
    required TextAlign align,
    PreviewLayer? layer,
    bool forIcons = false,
    TextAlign? currentAlign,
  }) {
    final selected = forIcons
        ? layer?.iconAlign == align
        : currentAlign == align;
    return _toolbarToggleShell(
      tooltip: tooltip,
      selected: forIcons ? selected : currentAlign == align,
      onTap: () {
        _runTextToolbarAction(() {
          _pushHistory();
          setState(() {
            if (forIcons) {
              layer!.iconAlign = align;
            } else {
              _setSelectedTextAlign(align);
            }
          });
        });
      },
      child: Icon(icon, size: 18),
    );
  }

  Widget _labeledSlider({
    Key? key,
    required String label,
    required double value,
    required double min,
    required double max,
    required int divisions,
    required String valueLabel,
    required ValueChanged<double> onChanged,
  }) {
    return SizedBox(
      key: key,
      width: 260,
      child: Row(
        children: [
          if (_toolbarStyle == PreviewToolbarStyle.compact)
            Tooltip(message: label, child: const Icon(Icons.tune, size: 18))
          else
            Tooltip(
              message: label,
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 120),
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
          const SizedBox(width: 6),
          Expanded(
            child: Slider(
              value: value,
              min: min,
              max: max,
              divisions: divisions,
              label: valueLabel,
              onChangeStart: (_) => _pushHistory(),
              onChanged: onChanged,
            ),
          ),
        ],
      ),
    );
  }

  PreviewLayer? _selectedLayer() {
    final id = _selectedLayerId;
    if (id == null) return null;
    return _document?.layerById(id);
  }

  PreviewLayer? _selectedTextLayer() {
    final layer = _selectedLayer();
    if (layer == null || layer.kind != PreviewLayerKind.text) return null;
    return layer;
  }

  PreviewLayer? _selectedIconGridLayer() {
    final layer = _selectedLayer();
    if (layer == null || layer.kind != PreviewLayerKind.iconGrid) return null;
    return layer;
  }

  void _beginTextEdit(String id) {
    if (_document?.layerById(id)?.kind != PreviewLayerKind.text) return;
    final platform = Theme.of(context).platform;
    setState(() {
      _selectedLayerId = id;
      _selectedTextPart = null;
      _editingTextLayerId = id;
      // A toolbar field remains readable above a phone's software keyboard.
      // Desktop users can still edit directly on the canvas.
      _editingTextInToolbar =
          platform == TargetPlatform.android || platform == TargetPlatform.iOS;
      _draftShapeId = null;
      _clearTextHistory();
      _syncTextController();
    });
    _ensureTextFocus();
  }

  void _endTextEdit() {
    if (_editingTextLayerId == null &&
        !_textFocusNode.hasFocus &&
        !_textContentFocusNode.hasFocus) {
      return;
    }
    final layer = _selectedTextLayer();
    if (layer != null) {
      _textController.applyToLayer(layer);
    }
    setState(() {
      _editingTextLayerId = null;
      _editingTextInToolbar = false;
      _textController.typingStyle = null;
      _clearTextHistory();
    });
    if (_textFocusNode.hasFocus || _textContentFocusNode.hasFocus) {
      _textFocusNode.unfocus();
      _textContentFocusNode.unfocus();
      _focusNode.requestFocus();
    }
  }

  PreviewContainedText? _selectedContainedText() {
    final selection = _selectedTextPart;
    if (selection == null || selection.kind != PreviewTextPartKind.contained) {
      return null;
    }
    final layer = _document?.layerById(selection.layerId);
    if (layer == null) return null;
    for (final text in layer.containedTexts) {
      if (text.id == selection.containedTextId) return text;
    }
    return null;
  }

  String? _selectedTextValue() {
    final textLayer = _selectedTextLayer();
    if (textLayer != null) return textLayer.plainText;

    final selection = _selectedTextPart;
    if (selection == null) return null;
    final layer = _document?.layerById(selection.layerId);
    if (layer == null) return null;
    return switch (selection.kind) {
      PreviewTextPartKind.gridTitle => layer.gridTitle,
      PreviewTextPartKind.sourceLabel => layer.sourceLabel,
      PreviewTextPartKind.sectionTitle =>
        selection.sectionIndex != null &&
                selection.sectionIndex! >= 0 &&
                selection.sectionIndex! < layer.sections.length
            ? layer.sections[selection.sectionIndex!].title
            : null,
      PreviewTextPartKind.contained => _selectedContainedText()?.text,
    };
  }

  void _setSelectedText(String value) {
    final textLayer = _selectedTextLayer();
    if (textLayer != null) {
      textLayer.setPlainText(value);
      return;
    }

    final selection = _selectedTextPart;
    if (selection == null) return;
    final layer = _document?.layerById(selection.layerId);
    if (layer == null) return;
    switch (selection.kind) {
      case PreviewTextPartKind.gridTitle:
        layer.gridTitle = value;
      case PreviewTextPartKind.sourceLabel:
        layer.sourceLabel = value;
      case PreviewTextPartKind.sectionTitle:
        final index = selection.sectionIndex;
        if (index != null && index >= 0 && index < layer.sections.length) {
          layer.sections[index].title = value;
        }
      case PreviewTextPartKind.contained:
        final contained = _selectedContainedText();
        if (contained != null) contained.text = value;
    }
    _resizeIconGridToContent(layer);
  }

  PreviewTextStyleData? _activeSelectedTextStyle() {
    final textLayer = _selectedTextLayer();
    if (textLayer != null) return _activeTextStyle(textLayer);
    final selection = _selectedTextPart;
    if (selection == null) return null;
    final layer = _document?.layerById(selection.layerId);
    if (layer == null) return null;
    return switch (selection.kind) {
      PreviewTextPartKind.gridTitle =>
        layer.gridTitleStyle ?? previewDefaultPanelTextStyle(selection.kind),
      PreviewTextPartKind.sourceLabel =>
        layer.sourceLabelStyle ?? previewDefaultPanelTextStyle(selection.kind),
      PreviewTextPartKind.sectionTitle => _selectedSectionTitleStyle(layer),
      PreviewTextPartKind.contained => _selectedContainedText()?.style,
    };
  }

  PreviewTextStyleData? _selectedSectionTitleStyle(PreviewLayer layer) {
    final index = _selectedTextPart?.sectionIndex;
    if (index == null || index < 0 || index >= layer.sections.length) {
      return null;
    }
    final section = layer.sections[index];
    return section.titleStyle ??
        previewDefaultPanelTextStyle(
          PreviewTextPartKind.sectionTitle,
          sectionIconSize: section.iconSize,
        );
  }

  void _mutateActiveTextStyle(
    void Function(PreviewTextStyleData style) mutate,
  ) {
    final textLayer = _selectedTextLayer();
    if (textLayer != null) {
      _mutateSelectedTextStyle(textLayer, mutate);
      return;
    }
    final selection = _selectedTextPart;
    final style = _activeSelectedTextStyle()?.copy();
    if (selection == null || style == null) return;
    final layer = _document?.layerById(selection.layerId);
    if (layer == null) return;
    mutate(style);
    switch (selection.kind) {
      case PreviewTextPartKind.gridTitle:
        layer.gridTitleStyle = style;
      case PreviewTextPartKind.sourceLabel:
        layer.sourceLabelStyle = style;
      case PreviewTextPartKind.sectionTitle:
        layer.sections[selection.sectionIndex!].titleStyle = style;
      case PreviewTextPartKind.contained:
        _selectedContainedText()?.style = style;
    }
    _resizeIconGridToContent(layer, preserveExistingHeight: true);
  }

  TextAlign? _selectedTextAlign() {
    final textLayer = _selectedTextLayer();
    if (textLayer != null) return textLayer.textAlign;
    return _selectedContainedText()?.textAlign;
  }

  void _setSelectedTextAlign(TextAlign align) {
    final textLayer = _selectedTextLayer();
    if (textLayer != null) {
      textLayer.textAlign = align;
      return;
    }
    final contained = _selectedContainedText();
    if (contained != null) contained.textAlign = align;
  }

  PreviewIconRow? _selectedIconRow() {
    if (_document?.autoStyle != PreviewAutoStyle.normal ||
        _selectedTextPart != null) {
      return null;
    }
    final layer = _selectedIconGridLayer();
    final sectionIndex = _selectedIconSectionIndex;
    final rowIndex = _selectedIconRowIndex;
    if (layer == null || sectionIndex == null || rowIndex == null) return null;
    final sections = previewEffectiveSections(layer);
    if (sectionIndex < 0 || sectionIndex >= sections.length) return null;
    final rows = previewIconSectionRows(
      sections[sectionIndex],
      maxWidth:
          layer.bounds.width * kPreviewCanvasSize.width -
          (layer.showChrome ? kPreviewIconGridChromeInset : 0),
      spacing: layer.iconAlign == TextAlign.justify ? 0 : 4,
    );
    if (rowIndex < 0 || rowIndex >= rows.length) return null;
    return rows[rowIndex];
  }

  void _resizeIconRow(
    String layerId,
    int sectionIndex,
    int rowIndex,
    double size,
  ) {
    if (_document?.autoStyle != PreviewAutoStyle.normal) return;
    final layer = _document?.layerById(layerId);
    if (layer == null) return;
    if (_undoSnapshot == null) _pushHistory();
    setState(() {
      resizePreviewIconRow(layer, sectionIndex, rowIndex, size);
      _resizeIconGridToContent(layer);
    });
  }

  void _resizeIconGroup(String layerId, double size) {
    final layer = _document?.layerById(layerId);
    if (layer == null) return;
    if (_undoSnapshot == null) _pushHistory();
    setState(() {
      resizePreviewIconGroup(layer, size);
      _resizeIconGridToContent(layer);
    });
  }

  void _resizeIconGridToContent(
    PreviewLayer layer, {
    bool preserveExistingHeight = false,
  }) {
    if (layer.kind != PreviewLayerKind.iconGrid) return;
    final size = previewIconGridIntrinsicSize(
      maxWidth: layer.bounds.width * kPreviewCanvasSize.width,
      sections: previewEffectiveSections(layer),
      showChrome: layer.showChrome,
      gridTitle: layer.gridTitle,
      sourceLabel: layer.sourceLabel,
      gridTitleStyle: layer.gridTitleStyle,
      sourceLabelStyle: layer.sourceLabelStyle,
      lawnRows: layer.lawnRows,
      lawnCols: layer.lawnCols,
      iconAlign: layer.iconAlign,
    );
    final maxHeight = ((1.0 - layer.bounds.top) / layer.scale.clamp(0.25, 4.0))
        .clamp(0.0, double.infinity)
        .toDouble();
    var height = (size.height / kPreviewCanvasSize.height)
        .clamp(maxHeight < 0.04 ? maxHeight : 0.04, maxHeight)
        .toDouble();
    if (preserveExistingHeight && height < layer.bounds.height) {
      height = layer.bounds.height;
    }
    layer.bounds = Rect.fromLTWH(
      layer.bounds.left,
      layer.bounds.top,
      layer.bounds.width,
      height,
    );
  }

  void _applyColor(Color c) {
    _runTextToolbarAction(() {
      _pushHistory();
      setState(() {
        _drawColor = c;
        final layer = _selectedLayer();
        if (layer == null) return;
        if (layer.kind == PreviewLayerKind.text) {
          _mutateSelectedTextStyle(layer, (s) => s.color = c);
        } else if (_activeSelectedTextStyle() != null) {
          _mutateActiveTextStyle((s) => s.color = c);
        } else if (layer.kind == PreviewLayerKind.shape ||
            layer.kind == PreviewLayerKind.stroke) {
          layer.strokeColor = c;
          if (layer.kind == PreviewLayerKind.shape && layer.shapeFilled) {
            layer.fillColor = c.withValues(alpha: 0.35);
          }
        }
      });
    });
  }

  Future<void> _openColorPicker() async {
    var pending = _drawColor;
    final chosen = await showDialog<Color>(
      context: context,
      builder: (ctx) => AlertDialog(
        scrollable: true,
        title: Text(_t('previewGenCustomColor', 'Custom color')),
        content: ColorPicker(
          pickerColor: pending,
          enableAlpha: true,
          hexInputBar: true,
          labelTypes: const [],
          onColorChanged: (c) => pending = c,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(_t('previewGenCancel', 'Cancel')),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, pending),
            child: Text(_t('previewGenApply', 'Apply')),
          ),
        ],
      ),
    );
    if (chosen == null || !mounted) return;
    _applyColor(chosen);
  }

  Future<void> _pickBannerStem() async {
    _endTextEdit();
    final banners = _banners;
    final doc = _document;
    if (banners == null || doc == null) return;
    final chosen = await showPreviewBannerPicker(
      context: context,
      banners: banners,
      t: _t,
      currentStem: doc.banner.stem,
      session: _bannerPickerSession,
    );
    if (chosen == null || !mounted) return;
    if (chosen == '__custom__') {
      await _pickCustomBanner();
      return;
    }
    _pushHistory();
    setState(() {
      doc.banner = PreviewBannerRef(
        kind: PreviewBannerSourceKind.assetStem,
        stem: chosen,
        assetPath: banners.assetPathForStem(chosen),
      );
    });
  }

  Future<void> _pickCustomBanner() async {
    final doc = _document;
    if (doc == null) return;
    final picked = await pickPreviewUserImage();
    if (picked == null) return;
    _pushHistory();
    setState(() {
      doc.banner = PreviewBannerRef(
        kind: PreviewBannerSourceKind.userFile,
        userFilePath: picked.path,
        userFileBytes: picked.bytes,
      );
    });
  }

  Future<void> _addOverlayImage() async {
    _endTextEdit();
    final doc = _document;
    if (doc == null) return;
    final choice = await showPreviewAssetImagePicker(
      context: context,
      t: _t,
      session: _stickerPickerSession,
      levelFile: widget.levelFile,
      parsed: widget.parsed,
      document: doc,
    );
    if (choice == null || !mounted) return;

    String? path;
    String? asset;
    Uint8List? bytes;
    if (choice.isCustom) {
      final picked = await pickPreviewUserImage();
      if (picked == null) return;
      path = picked.path;
      bytes = picked.bytes;
    } else {
      asset = choice.assetPath;
      if (asset == null) return;
    }

    var bounds = const Rect.fromLTWH(0.35, 0.25, 0.30, 0.40);
    try {
      ui.Image? decoded;
      if (bytes != null) {
        decoded = await decodeImageFromList(bytes);
      } else if (asset != null) {
        if (asset.toLowerCase().endsWith('.gif')) {
          decoded = await decodeFirstFrameFromAsset(asset);
        } else {
          final data = await rootBundle.load(asset);
          decoded = await decodeImageFromList(data.buffer.asUint8List());
        }
      }
      if (decoded != null) {
        final aspect = decoded.width / decoded.height.clamp(1, 100000);
        const maxW = 0.30;
        var w = maxW;
        var h = maxW / aspect;
        if (h > 0.45) {
          h = 0.45;
          w = h * aspect;
        }
        bounds = Rect.fromLTWH(0.5 - w / 2, 0.5 - h / 2, w, h);
        decoded.dispose();
      }
    } catch (_) {}

    final id = _nextId('image');
    _pushHistory();
    setState(() {
      doc.addLayer(
        PreviewLayer(
          id: id,
          kind: PreviewLayerKind.image,
          bounds: bounds,
          scale: 1,
          imagePath: path,
          imageBytes: bytes,
          imageAsset: asset,
        ),
      );
      _selectedLayerId = id;
      _tool = PreviewEditTool.select;
      _selectedTextPart = null;
    });
  }

  Future<void> _openFiguresMenu() async {
    _endTextEdit();
    final choice = await showPreviewFiguresPicker(
      context: context,
      t: _t,
      session: _figuresPickerSession,
    );
    if (choice == null || !mounted) return;
    setState(() {
      _tool = PreviewEditTool.figures;
      _figureKind = choice.$1;
      _figureFilled = choice.$2;
      _draftShapeId = null;
    });
  }

  String _layerTitle(
    PreviewDocument doc,
    PreviewLayerOrderEntry entry,
    Map<String, PreviewSticker> stickers,
  ) {
    if (entry.isBackground) return _t('previewGenLayerType_background');
    final layer = entry.layer!;
    final label = switch (layer.kind) {
      PreviewLayerKind.text => layer.plainText,
      PreviewLayerKind.iconGrid => layer.gridTitle ?? '',
      PreviewLayerKind.image =>
        stickers[layer.imageAsset]?.localizedName(context, _t) ?? '',
      PreviewLayerKind.shape => _t(
        'previewFigure_${layer.shapeKind?.name ?? 'rect'}',
      ),
      PreviewLayerKind.stroke => '',
    };
    if (label.trim().isNotEmpty) return label;
    return _t('previewGenLayerLabel', null, {
      'type': _t('previewGenLayerType_${layer.kind.name}'),
      'number': doc.layers.indexOf(layer) + 1,
    });
  }

  Future<void> _openLayers() async {
    final doc = _document;
    if (doc == null) return;
    _endTextEdit();
    var stickers = <String, PreviewSticker>{};
    if (doc.layers.any((layer) => layer.imageAsset != null)) {
      try {
        _layerStickerCatalog ??= loadPreviewStickerCatalog();
        stickers = {
          for (final sticker in await _layerStickerCatalog!)
            sticker.assetPath: sticker,
        };
      } catch (error) {
        _layerStickerCatalog = null;
        debugPrint('Preview layer sticker names: $error');
      }
    }
    if (!mounted || !identical(doc, _document)) return;
    await showPreviewLayersDialog(
      context: context,
      session: _layersPickerSession,
      doc: doc,
      selectedLayerId: _selectedLayerId,
      t: _t,
      entryTitle: (entry) => _layerTitle(doc, entry, stickers),
      onSelected: (id) {
        setState(() {
          _selectedLayerId = id;
          _selectedTextPart = null;
          _syncTextController();
        });
      },
      onReorder: (ids) {
        if (listEquals(
          ids,
          doc.orderedLayerEntries.map((entry) => entry.id).toList(),
        )) {
          return;
        }
        _pushHistory(force: true);
        setState(() => doc.reorderLayers(ids));
      },
    );
    if (mounted) _focusNode.requestFocus();
  }

  void _moveSelectedLayer(PreviewLayerOrderAction action) {
    final doc = _document;
    final id = _selectedLayerId;
    if (doc == null || id == null || !doc.canMoveLayer(id, action)) return;
    _endTextEdit();
    _pushHistory(force: true);
    setState(() => doc.moveLayer(id, action));
    _focusNode.requestFocus();
  }

  Future<void> _addModuleInfoElement() async {
    _endTextEdit();
    final doc = _document;
    if (doc == null) return;
    final classes = previewPresentModuleObjClasses(widget.levelFile);
    if (classes.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _t('previewGenModuleInfoEmpty', 'No modules found on this level'),
          ),
        ),
      );
      return;
    }

    final objClass = await showPreviewModuleInfoPicker(
      context: context,
      session: _moduleInfoPickerSession,
      classes: classes,
      titleForClass: (ctx, objClass) =>
          ModuleRegistry.getMetadata(objClass).getTitle(ctx),
      t: _t,
    );
    if (objClass == null || !mounted) return;

    await loadPreviewModuleResourceNames();
    if (!mounted) return;

    final meta = ModuleRegistry.getMetadata(objClass);
    final title = meta.getTitle(context);
    String l10n(String key, String fallback, [Map<String, Object?>? args]) =>
        _t(key, fallback, args);
    final payload = previewModuleInfoBuild(
      appL10n: AppLocalizations.of(context),
      levelFile: widget.levelFile,
      objClass: objClass,
      t: l10n,
      resourceName: (kind, id) =>
          previewModuleResourceName(context, widget.levelFile, kind, id),
    );
    final summary = payload.textBody;
    final bodyText = summary.isEmpty ? title : '$title\n$summary';
    final canGrid = payload.sections.isNotEmpty;

    String? mode;
    if (canGrid) {
      mode = await showDialog<String>(
        context: context,
        builder: (ctx) => AlertDialog(
          scrollable: true,
          title: Text(title),
          content: Text(
            _t(
              'previewGenModuleInfoKindHint',
              'Add a text label or an icon-grid summary for this module.',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(_t('previewGenCancel', 'Cancel')),
            ),
            TextButton(
              onPressed: () => Navigator.pop(ctx, 'text'),
              child: Text(_t('previewGenModuleInfoText', 'Text label')),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(ctx, 'grid'),
              child: Text(_t('previewGenModuleInfoGrid', 'Icon grid')),
            ),
          ],
        ),
      );
    } else {
      // No icons for this module — only a text summary makes sense.
      mode = 'text';
    }
    if (mode == null || !mounted) return;

    if (mode == 'text') {
      final id = _nextId('modtext');
      _pushHistory();
      setState(() {
        doc.addLayer(
          PreviewLayer(
            id: id,
            kind: PreviewLayerKind.text,
            bounds: const Rect.fromLTWH(0.12, 0.2, 0.76, 0.45),
            text: bodyText,
            textStyle: PreviewTextStyleData(
              fontFamily: PreviewFonts.familyPvZ,
              fontSize: 22,
              outline: true,
            ),
          ),
        );
        _selectedLayerId = id;
        _tool = PreviewEditTool.select;
        _selectedTextPart = null;
        _syncTextController();
      });
      return;
    }

    final sections = payload.sections;
    final chrome = payload.gridChromeBody;
    final id = _nextId('modgrid');
    _pushHistory();
    setState(() {
      doc.addLayer(
        PreviewLayer(
          id: id,
          kind: PreviewLayerKind.iconGrid,
          gridKind: PreviewIconGridKind.custom,
          gridTitle: title,
          // Only non-spatial notes on the grid chrome — cell lists stay in text mode.
          sourceLabel: chrome.isEmpty ? null : chrome,
          showChrome: true,
          lawnRows: payload.lawnRows,
          lawnCols: payload.lawnCols,
          bounds: payload.isLawnGrid
              ? const Rect.fromLTWH(0.04, 0.12, 0.42, 0.72)
              : const Rect.fromLTWH(0.05, 0.2, 0.55, 0.55),
          sections: sections,
          items: [for (final s in sections) ...s.items],
        ),
      );
      _selectedLayerId = id;
      _selectedTextPart = null;
      _tool = PreviewEditTool.select;
      _syncTextController();
    });
  }

  void _addTextLayer() {
    _endTextEdit();
    final doc = _document;
    if (doc == null) return;
    final container = _selectedLayer();
    final id = _nextId('text');
    _pushHistory();
    setState(() {
      if (container != null &&
          (container.kind == PreviewLayerKind.iconGrid ||
              container.kind == PreviewLayerKind.shape)) {
        final containedIndex = container.containedTexts.length;
        final top = (0.35 + containedIndex * 0.2).clamp(0.05, 0.77);
        container.containedTexts.add(
          PreviewContainedText(
            id: id,
            text: _t('previewGenNewText', 'New text'),
            bounds: Rect.fromLTWH(0.1, top, 0.8, 0.18),
            style: PreviewTextStyleData(
              fontFamily: PreviewFonts.familyPvZ,
              fontSize: 24,
            ),
          ),
        );
        _selectedTextPart = PreviewTextPartSelection(
          layerId: container.id,
          kind: PreviewTextPartKind.contained,
          containedTextId: id,
        );
        _tool = PreviewEditTool.select;
        _syncTextController();
        return;
      }
      doc.addLayer(
        PreviewLayer(
          id: id,
          kind: PreviewLayerKind.text,
          bounds: const Rect.fromLTWH(0.2, 0.4, 0.5, 0.15),
          text: _t('previewGenNewText', 'New text'),
          textStyle: PreviewTextStyleData(
            fontFamily: PreviewFonts.familyPvZ,
            fontSize: 36,
          ),
        ),
      );
      _selectedLayerId = id;
      _selectedTextPart = null;
      _tool = PreviewEditTool.select;
      _syncTextController();
    });
  }

  void _deleteSelected() {
    _endTextEdit();
    final doc = _document;
    final id = _selectedLayerId;
    if (doc == null || id == null) return;
    final layer = doc.layerById(id);
    if (layer == null) return;
    _pushHistory();
    setState(() {
      final textPart = _selectedTextPart;
      if (textPart != null) {
        switch (textPart.kind) {
          case PreviewTextPartKind.gridTitle:
            layer.gridTitle = null;
          case PreviewTextPartKind.sourceLabel:
            layer.sourceLabel = null;
          case PreviewTextPartKind.sectionTitle:
            final index = textPart.sectionIndex;
            if (index != null && index >= 0 && index < layer.sections.length) {
              layer.sections[index].title = null;
            }
          case PreviewTextPartKind.contained:
            layer.containedTexts.removeWhere(
              (text) => text.id == textPart.containedTextId,
            );
        }
        _selectedTextPart = null;
        _resizeIconGridToContent(layer);
        _textController.clear();
        return;
      }

      doc.layers.removeWhere((l) => l.id == id);
      _selectedLayerId = null;
      _editingTextLayerId = null;
      _selectedTextPart = null;
      _textController.clear();
    });
  }

  Future<bool> _export({bool automatic = false}) async {
    if (_exporting || _confirmingGifExport || _document == null) return false;
    _endTextEdit();
    final document = _document!;
    final hasGif = previewDocumentGifSources(document).isNotEmpty;
    if (hasGif) {
      _confirmingGifExport = true;
      bool? confirmed;
      try {
        confirmed = await showPreviewGifPngNoticeDialog(
          context: context,
          t: _t,
        );
      } finally {
        _confirmingGifExport = false;
      }
      if (confirmed != true || !mounted) return false;
    }
    final selectedTextPart = _selectedTextPart;
    setState(() {
      _exporting = true;
      _selectedTextPart = null;
    });
    PreviewGifFirstFrames? firstFrames;
    try {
      if (hasGif) {
        firstFrames = await PreviewGifFirstFrames.load(document);
        if (!mounted) return false;
        setState(() => _exportImageFrames = firstFrames!.images);
      }
      // Capture once, after first-frame overrides and the unselected canvas
      // have painted. Never capture whichever GIF frame is currently playing.
      await WidgetsBinding.instance.endOfFrame;
      if (!mounted) return false;
      final box =
          _boundaryKey.currentContext?.findRenderObject()
              as RenderRepaintBoundary?;
      if (box == null) throw StateError('Preview canvas is not ready');
      // Save the content represented by this frame, before the asynchronous
      // image write. Later edits must not become saved merely because it succeeds.
      final exportedSnapshot = PreviewDocumentSnapshot.capture(_document!);
      final image = await box.toImage(pixelRatio: 2.0);
      final PreviewExportResult result;
      try {
        result = widget.imageExporter != null
            ? await widget.imageExporter!(image, widget.fileName)
            : await PreviewPngExporter.export(
                image: image,
                levelFileName: widget.fileName,
              );
      } finally {
        image.dispose();
      }
      if (!mounted) return false;
      _savedDocumentSnapshot = exportedSnapshot;
      if (automatic) {
        showAutosavedMessage(context, path: result.path);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              _t(
                'previewGenExportOk',
                'Saved preview to {path}',
              ).replaceAll('{path}', result.path),
            ),
          ),
        );
      }
      return true;
    } catch (e) {
      if (!mounted) return false;
      debugPrint('Preview export failed: $e');
      final message = e is PreviewPngExportException
          ? switch (e.failure) {
              PreviewPngExportFailure.encoding => _t(
                'previewGenExportEncodingFail',
                'Could not encode the preview image. Please try again.',
              ),
              PreviewPngExportFailure.libraryNotConfigured => _t(
                'previewGenExportLibraryNotConfigured',
                'Please configure the level library folder before exporting a preview.',
              ),
            }
          : _t('previewGenExportFail', 'Export failed');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));
      return false;
    } finally {
      if (mounted) {
        setState(() {
          _exporting = false;
          _exportImageFrames = const {};
          _selectedTextPart = selectedTextPart;
        });
        // Replace RawImage references before releasing their decoded frames.
        if (firstFrames != null) await WidgetsBinding.instance.endOfFrame;
      }
      firstFrames?.dispose();
    }
  }

  Future<void> _requestExit() async {
    if (_confirmingExit || _exporting || _confirmingGifExport || _allowExit) {
      return;
    }
    _confirmingExit = true;
    try {
      _endTextEdit();
      final automatic = autosaveEnabled(context, AutosaveTarget.previewImage);
      final choice = !_hasUnsavedChanges
          ? _PreviewExitChoice.discard
          : automatic
          ? _PreviewExitChoice.save
          : !_widthAvailable
          ? _PreviewExitChoice.discard
          : await showDialog<_PreviewExitChoice>(
              context: context,
              builder: (dialogContext) => AlertDialog(
                key: const ValueKey('previewGeneratorExitDialog'),
                scrollable: true,
                title: Text(_t('previewGenExitTitle')),
                content: Text(_t('previewGenExitHint')),
                actions: [
                  TextButton(
                    key: const ValueKey('previewGeneratorCancelExitButton'),
                    onPressed: () => Navigator.pop(dialogContext),
                    child: Text(_t('previewGenCancel')),
                  ),
                  TextButton(
                    key: const ValueKey('previewGeneratorDiscardExitButton'),
                    onPressed: () => Navigator.pop(
                      dialogContext,
                      _PreviewExitChoice.discard,
                    ),
                    child: Text(_t('previewGenLeaveWithoutSaving')),
                  ),
                  FilledButton(
                    key: const ValueKey('previewGeneratorSaveExitButton'),
                    onPressed: () =>
                        Navigator.pop(dialogContext, _PreviewExitChoice.save),
                    child: Text(_t('previewGenSaveAndLeave')),
                  ),
                ],
              ),
            );
      if (!mounted || choice == null) return;
      if (choice == _PreviewExitChoice.save &&
          (!await _export(automatic: automatic) || _hasUnsavedChanges)) {
        return;
      }
      if (!mounted) return;
      setState(() => _allowExit = true);
      await WidgetsBinding.instance.endOfFrame;
      if (mounted) Navigator.of(context).pop();
    } finally {
      _confirmingExit = false;
      if (mounted && !_allowExit && _editingTextLayerId == null) {
        _focusNode.requestFocus();
      }
    }
  }

  void _onStrokeStarted(Offset n) {
    final doc = _document;
    if (doc == null) return;
    final id = _nextId('stroke');
    _pushHistory();
    setState(() {
      _activeStrokeId = id;
      doc.addLayer(
        PreviewLayer(
          id: id,
          kind: PreviewLayerKind.stroke,
          bounds: const Rect.fromLTWH(0, 0, 1, 1),
          strokeColor: _drawColor,
          strokeWidth: _drawStrokeWidth,
          points: [n],
        ),
      );
      _selectedLayerId = id;
      _selectedTextPart = null;
    });
  }

  void _onStrokeUpdated(Offset n) {
    final doc = _document;
    final id = _activeStrokeId;
    if (doc == null || id == null) return;
    final layer = doc.layerById(id);
    if (layer == null) return;
    setState(() => layer.points.add(n));
  }

  void _onStrokeEnded() {
    _activeStrokeId = null;
  }

  void _onEraseAt(Offset n) {
    final doc = _document;
    if (doc == null) return;
    const radius = 0.025;
    var changed = false;
    if (_undoSnapshot == null) _pushHistory();
    setState(() {
      for (final layer in doc.layers) {
        if (layer.kind != PreviewLayerKind.stroke) continue;
        final before = layer.points.length;
        layer.points.removeWhere((p) => (p - n).distance <= radius);
        if (layer.points.length != before) changed = true;
      }
      doc.layers.removeWhere(
        (l) => l.kind == PreviewLayerKind.stroke && l.points.length < 2,
      );
    });
    if (!changed && _undoSnapshot != null) {
      // no-op erase — drop empty history push
    }
  }

  void _onShapeDraft(Rect bounds) {
    final doc = _document;
    if (doc == null) return;
    final kind = _figureKind;
    final filled = _figureFilled;
    setState(() {
      if (_draftShapeId == null) {
        _pushHistory();
        _draftShapeId = _nextId('shape');
        doc.addLayer(
          PreviewLayer(
            id: _draftShapeId!,
            kind: PreviewLayerKind.shape,
            shapeKind: kind,
            shapeFilled: filled,
            bounds: bounds,
            fillColor: filled ? _drawColor.withValues(alpha: 0.35) : null,
            strokeColor: _drawColor,
            strokeWidth: kind == PreviewShapeKind.rect && filled
                ? 0
                : _drawStrokeWidth,
            cornerRadius: kind == PreviewShapeKind.rect ? 10 : 0,
          ),
        );
        _selectedLayerId = _draftShapeId;
        _selectedTextPart = null;
      } else {
        final layer = doc.layerById(_draftShapeId!);
        if (layer != null) {
          layer.bounds = bounds;
          layer.shapeKind = kind;
          layer.shapeFilled = filled;
          layer.fillColor = filled ? _drawColor.withValues(alpha: 0.35) : null;
          layer.strokeColor = _drawColor;
        }
      }
    });
  }

  bool _onHardwareKey(KeyEvent event) {
    if (!mounted ||
        !_widthAvailable ||
        _document == null ||
        _loading ||
        _exporting ||
        _confirmingExit ||
        _allowExit ||
        ModalRoute.of(context)?.isCurrent == false) {
      return false;
    }
    final primaryFocus = FocusManager.instance.primaryFocus;
    // Text edits use the focused field's shortcuts, not document commands.
    // This also protects fields in any inline or future editor controls.
    if (_editingTextLayerId != null ||
        primaryFocus == _textFocusNode ||
        primaryFocus == _textContentFocusNode ||
        primaryFocus?.context?.findAncestorWidgetOfExactType<EditableText>() !=
            null) {
      return false;
    }
    return _onKey(event) == KeyEventResult.handled;
  }

  void _restoreCanvasFocus() {
    if (_editingTextLayerId == null &&
        !_confirmingExit &&
        ModalRoute.of(context)?.isCurrent != false) {
      _focusNode.requestFocus();
    }
  }

  KeyEventResult _onKey(KeyEvent event) {
    if (event is! KeyDownEvent) return KeyEventResult.ignored;

    final key = event.logicalKey;
    if ((key == LogicalKeyboardKey.delete ||
            key == LogicalKeyboardKey.backspace) &&
        !HardwareKeyboard.instance.isControlPressed &&
        !HardwareKeyboard.instance.isMetaPressed &&
        !HardwareKeyboard.instance.isAltPressed) {
      if (_editingTextLayerId != null ||
          _textFocusNode.hasFocus ||
          _textContentFocusNode.hasFocus) {
        return KeyEventResult.ignored;
      }
      if (_selectedLayerId == null) return KeyEventResult.ignored;
      _deleteSelected();
      return KeyEventResult.handled;
    }

    final isCtrl =
        HardwareKeyboard.instance.isControlPressed ||
        HardwareKeyboard.instance.isMetaPressed;
    if (!isCtrl) return KeyEventResult.ignored;

    if (key == LogicalKeyboardKey.keyZ &&
        HardwareKeyboard.instance.isShiftPressed) {
      if (_redoSnapshot != null) {
        _redo();
        return KeyEventResult.handled;
      }
      return KeyEventResult.ignored;
    }
    if (key == LogicalKeyboardKey.keyZ) {
      if (_undoSnapshot != null) {
        _undo();
        return KeyEventResult.handled;
      }
      return KeyEventResult.ignored;
    }
    if (key == LogicalKeyboardKey.keyY) {
      if (_redoSnapshot != null) {
        _redo();
        return KeyEventResult.handled;
      }
      return KeyEventResult.ignored;
    }
    return KeyEventResult.ignored;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return LayoutBuilder(
      builder: (context, constraints) {
        final mediaSize = MediaQuery.sizeOf(context);
        final availableSize = Size(
          constraints.maxWidth.isFinite
              ? constraints.maxWidth
              : mediaSize.width,
          constraints.maxHeight.isFinite
              ? constraints.maxHeight
              : mediaSize.height,
        );
        final widthAvailable = isPreviewGeneratorDisplayAreaAvailable(
          availableSize: availableSize,
          platform: theme.platform,
          uiScale: AppUiScale.of(context),
        );
        _widthAvailable = widthAvailable;
        final useMobilePrompt = useMobilePreviewGeneratorNarrowPrompt(
          platform: theme.platform,
        );
        final showWorkspace =
            widthAvailable && !_loading && _error == null && _document != null;

        return PopScope<Object?>(
          canPop: _allowExit,
          onPopInvokedWithResult: (didPop, _) {
            if (!didPop) _requestExit();
          },
          child: CallbackShortcuts(
            // The rich-text editor has its own run/style checkpoints. Keep these
            // text-only bindings closer than Flutter's default text shortcuts.
            // Document commands are handled once by the route-scoped handler.
            bindings: widthAvailable && _editingTextLayerId != null
                ? {
                    const SingleActivator(
                      LogicalKeyboardKey.keyZ,
                      control: true,
                    ): _undoTextEdit,
                    const SingleActivator(LogicalKeyboardKey.keyZ, meta: true):
                        _undoTextEdit,
                    const SingleActivator(
                      LogicalKeyboardKey.keyZ,
                      control: true,
                      shift: true,
                    ): _redoTextEdit,
                    const SingleActivator(
                      LogicalKeyboardKey.keyZ,
                      meta: true,
                      shift: true,
                    ): _redoTextEdit,
                    const SingleActivator(
                      LogicalKeyboardKey.keyY,
                      control: true,
                    ): _redoTextEdit,
                    const SingleActivator(LogicalKeyboardKey.keyY, meta: true):
                        _redoTextEdit,
                  }
                : {},
            child: Focus(
              focusNode: _focusNode,
              autofocus: true,
              child: Scaffold(
                appBar: showWorkspace
                    ? null
                    : _buildGeneratorAppBar(showActions: widthAvailable),
                body: showWorkspace
                    ? SafeArea(bottom: false, child: _buildGeneratorBody(theme))
                    : widthAvailable
                    ? _buildGeneratorBody(theme)
                    : _buildNarrowWidthNotice(
                        theme,
                        useMobilePrompt: useMobilePrompt,
                      ),
              ),
            ),
          ),
        );
      },
    );
  }

  void _finishEditingForTransform() {
    if (_editingTextLayerId != null ||
        _textFocusNode.hasFocus ||
        _textContentFocusNode.hasFocus) {
      _endTextEdit();
    }
  }

  AppBar _buildGeneratorAppBar({bool primary = true, bool showActions = true}) {
    return AppBar(
      key: const ValueKey('previewGeneratorTitleBar'),
      primary: primary,
      leading: BackButton(
        key: const ValueKey('previewGeneratorBackButton'),
        onPressed: _requestExit,
      ),
      title: Text(_t('previewGenerator', 'Image Preview Generator')),
      actions: showActions
          ? [
              IconButton(
                tooltip: '${_t('previewGenUndo', 'Undo')} (Ctrl+Z)',
                onPressed: (_canUndoText || _undoSnapshot != null)
                    ? _undo
                    : null,
                icon: const Icon(Icons.undo),
              ),
              IconButton(
                tooltip: '${_t('previewGenRedo', 'Redo')} (Ctrl+Y)',
                onPressed: (_canRedoText || _redoSnapshot != null)
                    ? _redo
                    : null,
                icon: const Icon(Icons.redo),
              ),
              IconButton(
                key: const ValueKey('previewGeneratorExportButton'),
                tooltip: _t('previewGenExport', 'Export image'),
                onPressed: (_loading || _exporting || _document == null)
                    ? null
                    : _export,
                icon: _exporting
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.save_alt),
              ),
            ]
          : null,
    );
  }

  Widget _buildGeneratorBody(ThemeData theme) {
    if (_loading) return const Center(child: CircularProgressIndicator());
    if (_error != null) return Center(child: Text(_error!));
    if (_document == null) return const SizedBox.shrink();

    return PreviewEditorWorkspace(
      toolbarHeader: _buildGeneratorAppBar(primary: false),
      toolbar: _buildManualToolbar(theme),
      canvasZoomLabel: _t('previewGenCanvasZoom'),
      fitCanvasLabel: _t('previewGenFitCanvas'),
      resizeToolbarLabel: _t('previewGenResizeToolbar'),
      zoomInLabel: _t('previewGenZoomIn'),
      zoomOutLabel: _t('previewGenZoomOut'),
      onToolbarResizeStarted: _endTextEdit,
      // Keep the canvas subtree and viewport stable while suppressing export
      // input; toggling its editing layout can restart sticker asset loading.
      canvas: AbsorbPointer(
        key: const ValueKey('previewExportInputBarrier'),
        absorbing: _exporting,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Center(
            child: PreviewCanvas(
              document: _document!,
              imageFrameOverrides: _exportImageFrames,
              interactive: true,
              tool: _tool,
              selectedLayerId: _exporting ? null : _selectedLayerId,
              editingTextLayerId: _editingTextInToolbar
                  ? null
                  : _editingTextLayerId,
              selectedTextPart: _selectedTextPart,
              selectedIconSectionIndex: _exporting
                  ? null
                  : _selectedIconSectionIndex,
              selectedIconRowIndex: _exporting ? null : _selectedIconRowIndex,
              iconRowResizeLabel: _t('previewGenIconSize', 'Icon size'),
              onSelectIconRow: (layerId, sectionIndex, rowIndex) {
                _endTextEdit();
                setState(() {
                  _selectedLayerId = layerId;
                  _selectedTextPart = null;
                  _draftShapeId = null;
                  _syncTextController();
                  _selectedIconSectionIndex = sectionIndex;
                  _selectedIconRowIndex = rowIndex;
                });
                _restoreCanvasFocus();
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  final controlContext = _iconRowControlKey.currentContext;
                  if (!mounted || controlContext == null) return;
                  Scrollable.ensureVisible(controlContext, alignment: 0);
                });
              },
              onIconRowScaled: _resizeIconRow,
              onIconRowResizeStarted: _pushHistory,
              drawColor: _drawColor,
              drawStrokeWidth: _drawStrokeWidth,
              boundaryKey: _boundaryKey,
              textEditingController: _textController,
              textFocusNode: _textFocusNode,
              onTextEdited: (_) => _ensureTextFocus(),
              onBeginTextEdit: _beginTextEdit,
              onEndTextEdit: _endTextEdit,
              onSelectLayer: (id) {
                final previousId = _selectedLayerId;
                if (id != previousId ||
                    id == null ||
                    _selectedTextPart != null) {
                  _endTextEdit();
                }
                setState(() {
                  _selectedLayerId = id;
                  _selectedTextPart = null;
                  _draftShapeId = null;
                  _syncTextController();
                });
                _restoreCanvasFocus();
              },
              onSelectTextPart: (selection) {
                _endTextEdit();
                setState(() {
                  _selectedLayerId = selection.layerId;
                  _selectedTextPart = selection;
                  _draftShapeId = null;
                  _syncTextController();
                });
                _restoreCanvasFocus();
              },
              onLayerMoved: (id, bounds) {
                final layer = _document?.layerById(id);
                if (layer == null) return;
                _finishEditingForTransform();
                if (_undoSnapshot == null) _pushHistory();
                setState(() => layer.bounds = bounds);
              },
              onLayerScaled: (id, scale) {
                final layer = _document?.layerById(id);
                if (layer == null) return;
                _finishEditingForTransform();
                if (_undoSnapshot == null) _pushHistory();
                setState(() => layer.scale = scale);
              },
              onLayerRotated: (id, rotation) {
                final layer = _document?.layerById(id);
                if (layer == null) return;
                _finishEditingForTransform();
                if (_undoSnapshot == null) _pushHistory();
                setState(() => layer.rotation = rotation);
              },
              onStrokeStarted: _onStrokeStarted,
              onStrokeUpdated: _onStrokeUpdated,
              onStrokeEnded: () {
                setState(() {
                  _onStrokeEnded();
                  _draftShapeId = null;
                });
              },
              onEraseAt: _onEraseAt,
              onShapeDraft: _onShapeDraft,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNarrowWidthNotice(
    ThemeData theme, {
    required bool useMobilePrompt,
  }) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 520),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                useMobilePrompt ? Icons.screen_rotation : Icons.aspect_ratio,
                size: 72,
                color: theme.colorScheme.primary,
              ),
              const SizedBox(height: 24),
              Text(
                _t('previewGenDisplayTooNarrowTitle'),
                textAlign: TextAlign.center,
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                _t(
                  useMobilePrompt
                      ? 'previewGenDisplayTooNarrowMobileHint'
                      : 'previewGenDisplayTooNarrowDesktopHint',
                ),
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildManualToolbar(ThemeData theme) {
    final selected = _selectedLayer();
    final textLayer = _selectedTextLayer();
    final iconGrid = _selectedIconGridLayer();
    final selectedIconRow = _selectedIconRow();
    final iconSections = selected?.kind == PreviewLayerKind.iconGrid
        ? previewEffectiveSections(selected!)
        : const <PreviewIconSection>[];
    final selectedIconSize = iconSections.isEmpty
        ? 48.0
        : iconSections.first.iconSize;
    final selectedText = _selectedTextValue();
    final activeTextStyle = _activeSelectedTextStyle();
    final selectedTextAlign = _selectedTextAlign();
    final compact = _toolbarStyle == PreviewToolbarStyle.compact;
    final toolControls = <Widget>[
      for (final entry in [
        (PreviewEditTool.select, Icons.near_me, 'Select'),
        (PreviewEditTool.pen, Icons.edit, 'Draw'),
        (PreviewEditTool.eraser, Icons.auto_fix_off, 'Eraser'),
      ])
        PreviewToolbarAction(
          key: ValueKey('previewToolbarTool-${entry.$1.name}'),
          compact: compact,
          choice: true,
          icon: entry.$2,
          label: _t('previewTool_${entry.$1.name}', entry.$3),
          selected: _tool == entry.$1,
          onPressed: () {
            _endTextEdit();
            setState(() {
              _tool = entry.$1;
              _draftShapeId = null;
            });
            _textFocusNode.unfocus();
            _focusNode.requestFocus();
          },
        ),
    ];
    const actionLabels = {
      'previewGenAddText': 'Text',
      'previewGenAddImage': 'Stickers',
      'previewTool_figures': 'Figures',
      'previewTool_layers': 'Layers',
      'previewGenLayerToFront': 'Bring to front',
      'previewGenLayerForward': 'Bring forward',
      'previewGenLayerBackward': 'Send backward',
      'previewGenLayerToBack': 'Send to back',
      'previewGenChooseBanner': 'Choose banner',
      'previewGenModuleInfo': 'Module info',
      'previewGenRecreate': 'Recreate again',
      'previewGenDeleteElement': 'Delete element',
      'previewGenTextBgPick': 'Pick',
      'previewGenTextBgClear': 'Clear',
    };
    Widget action(
      String key,
      IconData icon,
      VoidCallback? onPressed, {
      bool selected = false,
    }) => PreviewToolbarAction(
      key: ValueKey('previewToolbarAction-$key'),
      compact: compact,
      icon: icon,
      label:
          '${_t(key, actionLabels[key])}${key == 'previewGenDeleteElement' ? ' (Del)' : ''}',
      selected: selected,
      onPressed: onPressed,
    );
    final elementControls = <Widget>[
      action('previewGenAddText', Icons.text_fields, () {
        setState(() => _tool = PreviewEditTool.select);
        _addTextLayer();
        final id = _selectedLayerId;
        if (id != null && _selectedTextLayer() != null) {
          _beginTextEdit(id);
        } else {
          _textFocusNode.requestFocus();
        }
      }),
      action(
        'previewGenAddImage',
        Icons.sticky_note_2_outlined,
        _addOverlayImage,
      ),
      action(
        'previewTool_figures',
        Icons.category,
        _openFiguresMenu,
        selected: _tool == PreviewEditTool.figures,
      ),
      action('previewTool_layers', Icons.layers_outlined, _openLayers),
      action('previewGenChooseBanner', Icons.wallpaper, _pickBannerStem),
      action('previewGenModuleInfo', Icons.extension, _addModuleInfoElement),
      action(
        'previewGenRecreate',
        Icons.restart_alt,
        _loading ? null : _recreateFromAuto,
      ),
    ];
    Widget toolbarRow({
      Key? key,
      double spacing = 8,
      required List<Widget> children,
    }) {
      // Full controls keep their original labels and wrap to as many lines as
      // the viewport needs. Only the icon-only compact layout stays in a row.
      if (!compact) {
        return Wrap(
          key: key,
          spacing: spacing,
          runSpacing: 8,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: children,
        );
      }
      return HorizontalTagScroller(
        key: key,
        padding: EdgeInsets.zero,
        children: [
          for (var i = 0; i < children.length; i++) ...[
            if (i > 0) SizedBox(width: spacing),
            children[i],
          ],
        ],
      );
    }

    return Material(
      color: Colors.transparent,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (selectedIconRow != null && selected != null) ...[
              Align(
                alignment: Alignment.centerLeft,
                child: _labeledSlider(
                  key: _iconRowControlKey,
                  label: _t('previewGenIconSize', 'Icon size'),
                  value: selectedIconRow.iconSize.clamp(
                    20,
                    previewIconRowMaximumSizeInLayer(selected, selectedIconRow),
                  ),
                  min: 20,
                  max: previewIconRowMaximumSizeInLayer(
                    selected,
                    selectedIconRow,
                  ),
                  divisions: 66,
                  valueLabel: selectedIconRow.iconSize.round().toString(),
                  onChanged: (value) => _resizeIconRow(
                    selected.id,
                    _selectedIconSectionIndex!,
                    _selectedIconRowIndex!,
                    value,
                  ),
                ),
              ),
              const SizedBox(height: 8),
            ],
            toolbarRow(
              key: ValueKey(
                compact
                    ? 'previewToolbarCompactPrimaryRow'
                    : 'previewToolbarFullToolRow',
              ),
              spacing: 6,
              children: [...toolControls, if (compact) ...elementControls],
            ),
            const SizedBox(height: 8),
            if (_selectedLayerId != null) ...[
              toolbarRow(
                key: const ValueKey('previewToolbarLayerOrderRow'),
                children: [
                  for (final entry in [
                    (
                      PreviewLayerOrderAction.toFront,
                      'previewGenLayerToFront',
                      Icons.vertical_align_top,
                    ),
                    (
                      PreviewLayerOrderAction.forward,
                      'previewGenLayerForward',
                      Icons.arrow_upward,
                    ),
                    (
                      PreviewLayerOrderAction.backward,
                      'previewGenLayerBackward',
                      Icons.arrow_downward,
                    ),
                    (
                      PreviewLayerOrderAction.toBack,
                      'previewGenLayerToBack',
                      Icons.vertical_align_bottom,
                    ),
                  ])
                    action(
                      entry.$2,
                      entry.$3,
                      _document!.canMoveLayer(_selectedLayerId!, entry.$1)
                          ? () => _moveSelectedLayer(entry.$1)
                          : null,
                    ),
                ],
              ),
              const SizedBox(height: 8),
            ],
            toolbarRow(
              key: const ValueKey('previewToolbarElementOptionsRow'),
              children: [
                if (!compact) ...elementControls,
                if (compact)
                  Tooltip(
                    message: _t('previewGenColor', 'Color'),
                    child: const Icon(Icons.palette_outlined, size: 18),
                  )
                else
                  Text('${_t('previewGenColor', 'Color')}:'),
                for (final c in _palette)
                  Listener(
                    onPointerDown: (_) => _snapshotTextSelectionForToolbar(),
                    child: GestureDetector(
                      onTap: () => _applyColor(c),
                      child: Container(
                        width: 22,
                        height: 22,
                        decoration: BoxDecoration(
                          color: c,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: _drawColor == c
                                ? theme.colorScheme.primary
                                : Colors.grey,
                            width: _drawColor == c ? 2 : 1,
                          ),
                        ),
                      ),
                    ),
                  ),
                Listener(
                  onPointerDown: (_) => _snapshotTextSelectionForToolbar(),
                  child: IconButton(
                    tooltip: _t('previewGenCustomColor', 'Custom color'),
                    onPressed: _openColorPicker,
                    icon: Icon(Icons.colorize, color: _drawColor),
                  ),
                ),
                if (selected != null) ...[
                  if (selected.kind == PreviewLayerKind.iconGrid &&
                      selectedIconRow == null &&
                      selectedText == null)
                    _labeledSlider(
                      key: const ValueKey('previewIconGroupSize'),
                      label: _t('previewGenIconSize', 'Icon size'),
                      value: selectedIconSize.clamp(20, 152),
                      min: 20,
                      max: 152,
                      divisions: 66,
                      valueLabel: selectedIconSize.round().toString(),
                      onChanged: (value) =>
                          _resizeIconGroup(selected.id, value),
                    ),
                  if (selectedIconRow == null &&
                      selectedText == null &&
                      selected.kind != PreviewLayerKind.text &&
                      selected.kind != PreviewLayerKind.image)
                    _labeledSlider(
                      label: _t('previewGenScale', 'Scale'),
                      value: selected.scale.clamp(0.25, 4.0),
                      min: 0.25,
                      max: 4.0,
                      divisions: 75,
                      valueLabel: selected.scale.toStringAsFixed(2),
                      onChanged: (value) =>
                          setState(() => selected.scale = value),
                    ),
                  if (selectedText == null &&
                      selected.kind == PreviewLayerKind.shape) ...[
                    if (selected.shapeKind == PreviewShapeKind.rect)
                      _labeledSlider(
                        label: _t('previewGenCornerRadius', 'Corner radius'),
                        value: selected.cornerRadius.clamp(0, 40),
                        min: 0,
                        max: 40,
                        divisions: 20,
                        valueLabel: selected.cornerRadius.round().toString(),
                        onChanged: (value) =>
                            setState(() => selected.cornerRadius = value),
                      ),
                    if (compact)
                      Tooltip(
                        message: _t('previewGenBorder', 'Show border'),
                        child: IconButton.outlined(
                          icon: const Icon(Icons.border_outer),
                          isSelected: selected.strokeWidth > 0,
                          onPressed: () {
                            _pushHistory();
                            setState(
                              () => selected.strokeWidth =
                                  selected.strokeWidth > 0
                                  ? 0
                                  : _drawStrokeWidth,
                            );
                          },
                        ),
                      )
                    else
                      FilterChip(
                        label: Text(_t('previewGenBorder', 'Show border')),
                        selected: selected.strokeWidth > 0,
                        onSelected: (enabled) {
                          _pushHistory();
                          setState(
                            () => selected.strokeWidth = enabled
                                ? _drawStrokeWidth
                                : 0,
                          );
                        },
                      ),
                  ],
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (compact)
                        Tooltip(
                          message: _t('previewGenOpacity', 'Opacity'),
                          child: const Icon(Icons.opacity, size: 18),
                        )
                      else
                        Text(_t('previewGenOpacity', 'Opacity')),
                      SizedBox(
                        width: 140,
                        child: Slider(
                          value: selected.opacity.clamp(0.0, 1.0),
                          min: 0,
                          max: 1,
                          divisions: 20,
                          label: selected.opacity.toStringAsFixed(2),
                          onChangeStart: (_) => _pushHistory(),
                          onChanged: (v) =>
                              setState(() => selected.opacity = v),
                        ),
                      ),
                    ],
                  ),
                  action(
                    'previewGenDeleteElement',
                    Icons.delete_outline,
                    _deleteSelected,
                  ),
                ],
              ],
            ),
            if (selectedText != null) ...[
              const SizedBox(height: 8),
              SizedBox(
                key: _textContentKey,
                child: TextField(
                  key: const ValueKey('previewTextContentField'),
                  controller: _textContentController,
                  focusNode: _textContentFocusNode,
                  style: theme.textTheme.bodyLarge,
                  minLines: 1,
                  maxLines: 3,
                  decoration: InputDecoration(
                    labelText: _t('previewGenTextContent', 'Text'),
                    isDense: true,
                  ),
                  onChanged: (value) {
                    if (textLayer != null) return;
                    if (_undoSnapshot == null) _pushHistory();
                    setState(() => _setSelectedText(value));
                  },
                ),
              ),
            ],
            if (iconGrid != null) ...[
              const SizedBox(height: 8),
              toolbarRow(
                key: const ValueKey('previewToolbarIconAlignmentRow'),
                spacing: 6,
                children: [
                  if (compact)
                    Tooltip(
                      message: _t('previewGenIconAlign', 'Icon align'),
                      child: const Icon(Icons.align_horizontal_left, size: 18),
                    )
                  else
                    Text(_t('previewGenIconAlign', 'Icon align')),
                  _alignToggle(
                    icon: Icons.format_align_left,
                    tooltip: _t('previewGenAlignLeft', 'Align left'),
                    align: TextAlign.left,
                    layer: iconGrid,
                    forIcons: true,
                  ),
                  _alignToggle(
                    icon: Icons.format_align_center,
                    tooltip: _t('previewGenAlignCenter', 'Align center'),
                    align: TextAlign.center,
                    layer: iconGrid,
                    forIcons: true,
                  ),
                  _alignToggle(
                    icon: Icons.format_align_right,
                    tooltip: _t('previewGenAlignRight', 'Align right'),
                    align: TextAlign.right,
                    layer: iconGrid,
                    forIcons: true,
                  ),
                  _alignToggle(
                    icon: Icons.format_align_justify,
                    tooltip: _t('previewGenAlignJustify', 'Justify'),
                    align: TextAlign.justify,
                    layer: iconGrid,
                    forIcons: true,
                  ),
                ],
              ),
            ],
            if (textLayer != null) ...[
              const SizedBox(height: 8),
              toolbarRow(
                key: const ValueKey('previewToolbarTextBackgroundRow'),
                children: [
                  if (compact)
                    Tooltip(
                      message: _t('previewGenTextBg', 'Text background'),
                      child: const Icon(Icons.format_color_fill, size: 18),
                    )
                  else
                    Text(_t('previewGenTextBg', 'Text background')),
                  Container(
                    width: 22,
                    height: 22,
                    decoration: BoxDecoration(
                      color:
                          textLayer.textBackgroundColor ?? Colors.transparent,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.grey),
                    ),
                  ),
                  action(
                    'previewGenTextBgPick',
                    Icons.format_color_fill,
                    () async {
                      final chosen = await showDialog<Color>(
                        context: context,
                        builder: (ctx) {
                          var pending =
                              textLayer.textBackgroundColor ?? _drawColor;
                          return AlertDialog(
                            scrollable: true,
                            title: Text(
                              _t('previewGenTextBg', 'Text background'),
                            ),
                            content: ColorPicker(
                              pickerColor: pending,
                              onColorChanged: (c) => pending = c,
                              enableAlpha: true,
                              hexInputBar: true,
                              labelTypes: const [],
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(ctx),
                                child: Text(_t('previewGenCancel', 'Cancel')),
                              ),
                              FilledButton(
                                onPressed: () => Navigator.pop(ctx, pending),
                                child: Text(_t('previewGenApply', 'Apply')),
                              ),
                            ],
                          );
                        },
                      );
                      if (chosen == null) return;
                      _pushHistory();
                      setState(() => textLayer.textBackgroundColor = chosen);
                    },
                  ),
                  action('previewGenTextBgClear', Icons.format_color_reset, () {
                    _pushHistory();
                    setState(() => textLayer.textBackgroundColor = null);
                  }),
                  if (!compact)
                    Text(
                      _t(
                        'previewGenTextStyleHint',
                        'Select text to style only that part',
                      ),
                      style: theme.textTheme.bodySmall,
                    ),
                ],
              ),
            ],
            if (activeTextStyle != null) ...[
              const SizedBox(height: 8),
              Listener(
                behavior: HitTestBehavior.translucent,
                onPointerDown: (_) => _snapshotTextSelectionForToolbar(),
                child: toolbarRow(
                  key: const ValueKey('previewToolbarTextStyleRow'),
                  spacing: 6,
                  children: [
                    DropdownButton<String>(
                      key: const ValueKey('previewTextFontPicker'),
                      value: activeTextStyle.fontFamily ?? '',
                      hint: Text(_t('previewGenFont', 'Font')),
                      items: [
                        for (final c in PreviewFonts.choices)
                          DropdownMenuItem(
                            value: c.family ?? '',
                            child: Text(
                              c.family == null
                                  ? _t('previewGenFontSystemDefault', c.label)
                                  : c.label,
                            ),
                          ),
                      ],
                      onChanged: (v) {
                        if (v == null) return;
                        _runTextToolbarAction(() {
                          _pushHistory();
                          setState(() {
                            _mutateActiveTextStyle(
                              (s) => s.fontFamily = v.isEmpty ? null : v,
                            );
                          });
                        });
                      },
                    ),
                    DropdownButton<double>(
                      value: _snapFontSize(activeTextStyle.fontSize),
                      items: [
                        for (final size in _fontSizeChoices)
                          DropdownMenuItem(
                            value: size,
                            child: Text('${size.toInt()}'),
                          ),
                      ],
                      onChanged: (v) {
                        if (v == null) return;
                        _runTextToolbarAction(() {
                          _pushHistory();
                          setState(() {
                            _mutateActiveTextStyle((s) => s.fontSize = v);
                          });
                        });
                      },
                    ),
                    _styleToggle(
                      label: 'B',
                      tooltip:
                          activeTextStyle.fontFamily == PreviewFonts.familyPvZ
                          ? _t(
                              'previewGenBoldPvZ',
                              'Bold (simulated — PvZ font has one weight)',
                            )
                          : _t('previewGenBold', 'Bold'),
                      selected: activeTextStyle.fontWeight == FontWeight.bold,
                      style: const TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 16,
                      ),
                      onTap: () {
                        _runTextToolbarAction(() {
                          _pushHistory();
                          setState(() {
                            final on =
                                activeTextStyle.fontWeight != FontWeight.bold;
                            _mutateActiveTextStyle(
                              (s) => s.fontWeight = on
                                  ? FontWeight.bold
                                  : FontWeight.w400,
                            );
                          });
                        });
                      },
                    ),
                    _styleToggle(
                      label: 'I',
                      tooltip: _t('previewGenItalic', 'Italic'),
                      selected: activeTextStyle.italic,
                      style: const TextStyle(
                        fontStyle: FontStyle.italic,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                      onTap: () {
                        _runTextToolbarAction(() {
                          _pushHistory();
                          setState(() {
                            _mutateActiveTextStyle((s) => s.italic = !s.italic);
                          });
                        });
                      },
                    ),
                    _styleToggle(
                      label: 'U',
                      tooltip: _t('previewGenUnderline', 'Underline'),
                      selected: activeTextStyle.underline,
                      style: const TextStyle(
                        decoration: TextDecoration.underline,
                        decorationThickness: 2.5,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                      onTap: () {
                        _runTextToolbarAction(() {
                          _pushHistory();
                          setState(() {
                            _mutateActiveTextStyle(
                              (s) => s.underline = !s.underline,
                            );
                          });
                        });
                      },
                    ),
                    _styleToggle(
                      label: 'O',
                      tooltip: _t('previewGenOutline', 'Outline'),
                      selected: activeTextStyle.outline,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                      ),
                      onTap: () {
                        _runTextToolbarAction(() {
                          _pushHistory();
                          setState(() {
                            _mutateActiveTextStyle(
                              (s) => s.outline = !s.outline,
                            );
                          });
                        });
                      },
                    ),
                    if (selectedTextAlign != null) ...[
                      const SizedBox(width: 4),
                      _alignToggle(
                        icon: Icons.format_align_left,
                        tooltip: _t('previewGenAlignLeft', 'Align left'),
                        align: TextAlign.left,
                        currentAlign: selectedTextAlign,
                      ),
                      _alignToggle(
                        icon: Icons.format_align_center,
                        tooltip: _t('previewGenAlignCenter', 'Align center'),
                        align: TextAlign.center,
                        currentAlign: selectedTextAlign,
                      ),
                      _alignToggle(
                        icon: Icons.format_align_right,
                        tooltip: _t('previewGenAlignRight', 'Align right'),
                        align: TextAlign.right,
                        currentAlign: selectedTextAlign,
                      ),
                      _alignToggle(
                        icon: Icons.format_align_justify,
                        tooltip: _t('previewGenAlignJustify', 'Justify'),
                        align: TextAlign.justify,
                        currentAlign: selectedTextAlign,
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

enum _PreviewExitChoice { save, discard }

/// One undo step for in-place text editing (plain + runs + caret).
class _TextEditCheckpoint {
  _TextEditCheckpoint({
    required this.plain,
    required this.runs,
    required this.textStyle,
    required this.selection,
  });

  final String plain;
  final List<PreviewTextRun> runs;
  final PreviewTextStyleData? textStyle;
  final TextSelection selection;

  factory _TextEditCheckpoint.capture(
    PreviewLayer layer,
    TextSelection selection,
  ) {
    layer.ensureTextRuns();
    return _TextEditCheckpoint(
      plain: layer.plainText,
      runs: [for (final r in layer.textRuns) r.copy()],
      textStyle: layer.textStyle?.copy(),
      selection: selection,
    );
  }

  void applyTo(PreviewLayer layer) {
    layer.textRuns = [for (final r in runs) r.copy()];
    layer.text = plain;
    layer.textStyle = textStyle?.copy();
  }
}
