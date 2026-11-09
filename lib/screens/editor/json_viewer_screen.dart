import 'dart:convert';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:c_editor/data/repository/level_repository.dart';
import 'package:c_editor/data/interface_menu_config.dart';
import 'package:c_editor/data/pvz_models.dart';
import 'package:c_editor/data/unused_level_object_utils.dart';
import 'package:c_editor/l10n/app_localizations.dart';
import 'package:c_editor/escape_override.dart';
import 'package:c_editor/utils/json_viewer_search.dart';
import 'package:c_editor/widgets/app_message.dart';
import 'package:c_editor/widgets/autosave.dart';
import 'package:c_editor/widgets/editor_components.dart'
    show EditorPopupMenuTile;
import 'package:c_editor/widgets/json_viewer_search_bar.dart';

const _fontSizeKey = 'json_viewer_font_size';
const _searchHistoryKey = 'json_viewer_search_history';
const _replaceHistoryKey = 'json_viewer_replace_history';
const _maxSearchHistory = 10;

/// Indent for on-screen JSON (view, edit, copy). Files still save with `\t`.
const _jsonIndent = '    ';
final _jsonEncoder = const JsonEncoder.withIndent(_jsonIndent);

class _EscapeIntent extends Intent {
  const _EscapeIntent();
}

/// Cached font size for immediate apply on screen enter (before async load).
double? _cachedFontSize;

enum _JsonViewMode { rawText, structured }

TextStyle _matchStyle(
  TextStyle base,
  ColorScheme colors, {
  bool active = false,
}) => base.copyWith(
  backgroundColor: active ? colors.primary : colors.primaryContainer,
  color: active ? colors.onPrimary : colors.onPrimaryContainer,
);

class _JsonEditController extends TextEditingController {
  List<JsonViewerTextMatch> _searchMatches = const [];
  int _activeMatchIndex = 0;
  String? _matchedText;

  void showSearchMatches(
    List<JsonViewerTextMatch> matches,
    int activeMatchIndex,
  ) {
    _searchMatches = List.unmodifiable(matches);
    _activeMatchIndex = activeMatchIndex;
    _matchedText = text;
    notifyListeners();
  }

  void clearSearchMatches() {
    if (_searchMatches.isEmpty) return;
    _searchMatches = const [];
    _activeMatchIndex = 0;
    _matchedText = null;
    notifyListeners();
  }

  @override
  TextSpan buildTextSpan({
    required BuildContext context,
    TextStyle? style,
    required bool withComposing,
  }) {
    if (_searchMatches.isEmpty ||
        _matchedText != text ||
        (withComposing &&
            value.composing.isValid &&
            !value.composing.isCollapsed)) {
      return super.buildTextSpan(
        context: context,
        style: style,
        withComposing: withComposing,
      );
    }

    final baseStyle = style ?? const TextStyle();
    final colors = Theme.of(context).colorScheme;
    final activeMatch =
        _activeMatchIndex >= 0 && _activeMatchIndex < _searchMatches.length
        ? _searchMatches[_activeMatchIndex]
        : null;
    return TextSpan(
      style: baseStyle,
      children: buildHighlightedTextSpans(
        text: text,
        segmentStartInLine: 0,
        segmentEndInLine: text.length,
        baseStyle: baseStyle,
        highlightStyle: _matchStyle(baseStyle, colors),
        activeHighlightStyle: _matchStyle(baseStyle, colors, active: true),
        lineMatches: _searchMatches,
        activeMatch: activeMatch,
        lineStartOffset: 0,
      ),
    );
  }
}

/// JSON code viewer. Ported from Z-Editor-master JsonCodeViewerScreen.kt
/// Includes font size slider, edit/save, and scrollbar.
class JsonViewerScreen extends StatefulWidget {
  const JsonViewerScreen({
    super.key,
    required this.fileName,
    required this.filePath,
    required this.levelFile,
    required this.onBack,
    this.onSaved,
    this.saveLevel,
    this.menuActions,
  });

  final String fileName;
  final String filePath;
  final PvzLevelFile levelFile;
  final VoidCallback onBack;
  final VoidCallback? onSaved;
  final Future<void> Function(String filePath, PvzLevelFile levelFile)?
  saveLevel;
  final List<InterfaceMenuActionPreference>? menuActions;

  @override
  State<JsonViewerScreen> createState() => _JsonViewerScreenState();
}

class _JsonViewerScreenState extends State<JsonViewerScreen> {
  double _fontSize = _cachedFontSize ?? 12;
  final _verticalController = ScrollController();
  bool _isEditing = false;
  String _editInitialText = '';
  bool _confirmingCancelEdit = false;
  bool _savingEdit = false;
  final _editController = _JsonEditController();
  final _searchController = TextEditingController();
  final _replaceController = TextEditingController();
  String? _syntaxError;
  _JsonViewMode _viewMode = _JsonViewMode.rawText;
  final Map<int, bool> _expandedStates = {};
  bool Function()? _escapeHandler;

  bool _matchCase = false;
  bool _wholeWords = false;
  bool _useRegex = false;
  bool _regexError = false;
  List<String> _searchHistory = [];
  List<String> _replaceHistory = [];
  List<JsonViewerTextMatch> _matches = const [];
  int _currentMatchIndex = 0;
  final List<int?> _matchObjectIndices = [];
  final Map<int, List<JsonViewerTextMatch>> _objectMatches = {};
  double? _pinchBaseFontSize;

  // Cache for gutter rows derived from the rendered document layout.
  double _lastWidth = 0;
  double _lastFontSize = 0;
  int? _lastContentSignature;
  _GutterLayout? _cachedGutterLayout;
  int? _selectionPointer;
  double? _selectionPointerScrollOffset;

  @override
  void initState() {
    super.initState();
    _loadFontSize();
    _loadSearchHistories();
    _pushEscapeHandler();
  }

  JsonViewerSearchOptions get _searchOptions => JsonViewerSearchOptions(
    caseSensitive: _matchCase,
    wholeWords: _wholeWords,
    regex: _useRegex,
  );

  Future<void> _loadSearchHistories() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() {
      _searchHistory = prefs.getStringList(_searchHistoryKey) ?? [];
      _replaceHistory = prefs.getStringList(_replaceHistoryKey) ?? [];
    });
  }

  Future<void> _pushHistory(
    String key,
    String value,
    List<String> current,
  ) async {
    if (value.isEmpty) return;
    final next = [
      value,
      ...current.where((e) => e != value),
    ].take(_maxSearchHistory).toList();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(key, next);
    if (!mounted) return;
    setState(() {
      if (key == _searchHistoryKey) {
        _searchHistory = next;
      } else {
        _replaceHistory = next;
      }
    });
  }

  List<int> _fontSizeOptions(bool isDesktop) => isDesktop
      ? const [12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24]
      : const [6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18];

  void _setFontSize(double value) {
    _cachedFontSize = value;
    setState(() => _fontSize = value);
    _saveFontSize(value);
  }

  double _fontSizeMin(bool isDesktop) => isDesktop ? 12.0 : 6.0;

  double _fontSizeMax(bool isDesktop) => isDesktop ? 24.0 : 18.0;

  void _adjustFontSizeByStep(double step, bool isDesktop) {
    final next = (_fontSize + step).clamp(
      _fontSizeMin(isDesktop),
      _fontSizeMax(isDesktop),
    );
    if (next != _fontSize) {
      _setFontSize(next.roundToDouble());
    }
  }

  Widget _wrapWithFontSizeGestures({
    required Widget child,
    required bool isDesktop,
  }) {
    return Listener(
      onPointerSignal: (event) {
        if (event is! PointerScrollEvent) return;
        final keyboard = HardwareKeyboard.instance;
        if (!keyboard.isControlPressed && !keyboard.isMetaPressed) return;
        final step = event.scrollDelta.dy > 0 ? -1.0 : 1.0;
        _adjustFontSizeByStep(step, isDesktop);
      },
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onScaleStart: (_) => _pinchBaseFontSize = _fontSize,
        onScaleUpdate: (details) {
          final base = _pinchBaseFontSize;
          if (base == null) return;
          final next = (base * details.scale).clamp(
            _fontSizeMin(isDesktop),
            _fontSizeMax(isDesktop),
          );
          if (next.roundToDouble() != _fontSize.roundToDouble()) {
            _setFontSize(next.roundToDouble());
          }
        },
        onScaleEnd: (_) => _pinchBaseFontSize = null,
        child: child,
      ),
    );
  }

  String _rawPrettyText() => _jsonEncoder.convert(widget.levelFile.toJson());

  void _invalidateRenderedJson() {
    _cachedGutterLayout = null;
    _lastWidth = 0;
    _lastFontSize = 0;
    _lastContentSignature = null;
    _jsonStringCache.clear();
  }

  double _jsonContentWidth({
    required double rowWidth,
    required double gutterW,
    required double gutterTextGap,
  }) {
    return (rowWidth - gutterW - gutterTextGap).clamp(32.0, double.maxFinite);
  }

  Future<void> _copyTextToClipboard(
    String text, {
    required String successMessage,
  }) async {
    await Clipboard.setData(ClipboardData(text: text));
    if (!mounted) return;
    AppMessage.show(context, successMessage, icon: Icons.check_circle);
  }

  Future<void> _copyLevelJson() async {
    final l10n = AppLocalizations.of(context);
    await _copyTextToClipboard(
      _rawPrettyText(),
      successMessage: l10n?.jsonViewerCopied ?? 'JSON copied to clipboard',
    );
  }

  Future<void> _copyObjectJson(PvzObject obj) async {
    final l10n = AppLocalizations.of(context);
    await _copyTextToClipboard(
      _jsonEncoder.convert(obj.toJson()),
      successMessage: l10n?.jsonViewerCopied ?? 'JSON copied to clipboard',
    );
  }

  void _runSearch({bool reveal = true, int matchIndex = 0}) {
    final query = _searchController.text;
    if (query.isEmpty) {
      setState(() {
        _matches = const [];
        _matchObjectIndices.clear();
        _objectMatches.clear();
        _currentMatchIndex = 0;
        _regexError = false;
      });
      _editController.clearSearchMatches();
      return;
    }

    final opts = _searchOptions;
    if (_useRegex && buildJsonViewerSearchPattern(query, opts) == null) {
      setState(() {
        _matches = const [];
        _matchObjectIndices.clear();
        _objectMatches.clear();
        _currentMatchIndex = 0;
        _regexError = true;
      });
      _editController.clearSearchMatches();
      return;
    }

    final matches = <JsonViewerTextMatch>[];
    final objectIndices = <int?>[];
    _objectMatches.clear();
    if (_isEditing) {
      matches.addAll(findJsonViewerMatches(_editController.text, query, opts));
      objectIndices.addAll(List.filled(matches.length, null));
    } else if (_viewMode == _JsonViewMode.structured) {
      final objects = widget.levelFile.objects;
      for (var i = 0; i < objects.length; i++) {
        final json = _jsonEncoder.convert(objects[i].objData);
        final objectMatches = findJsonViewerMatches(json, query, opts);
        if (objectMatches.isNotEmpty) {
          _objectMatches[i] = objectMatches;
          matches.addAll(objectMatches);
          objectIndices.addAll(List.filled(objectMatches.length, i));
        }
      }
    } else {
      matches.addAll(findJsonViewerMatches(_rawPrettyText(), query, opts));
      objectIndices.addAll(List.filled(matches.length, null));
    }

    final activeIndex = matches.isEmpty
        ? 0
        : matchIndex.clamp(0, matches.length - 1);
    setState(() {
      _matches = matches;
      _matchObjectIndices
        ..clear()
        ..addAll(objectIndices);
      _currentMatchIndex = activeIndex;
      _regexError = false;
    });
    if (!_isEditing || matches.isEmpty) {
      _editController.clearSearchMatches();
    }
    if (matches.isEmpty) return;
    if (reveal) {
      _goToMatch(activeIndex);
    } else if (_isEditing) {
      _editController.showSearchMatches(matches, activeIndex);
    }
  }

  void _goToMatch(int index) {
    if (_matches.isEmpty) return;
    final safeIndex = index.clamp(0, _matches.length - 1);
    setState(() => _currentMatchIndex = safeIndex);
    final match = _matches[safeIndex];

    if (_isEditing) {
      _editController.showSearchMatches(_matches, safeIndex);
      _revealTextMatch(match, editing: true);
      return;
    }

    if (_viewMode == _JsonViewMode.structured) {
      final objectIndex = _matchObjectIndices[safeIndex];
      if (objectIndex != null) {
        setState(() => _expandedStates[objectIndex] = true);
        _scrollToLine(objectIndex);
      }
      return;
    }

    _revealTextMatch(match, editing: false);
  }

  final _readTextKey = GlobalKey();
  final _editTextKey = GlobalKey();

  T? _findRenderDescendant<T extends RenderObject>(RenderObject? object) {
    if (object is T) return object;
    T? result;
    object?.visitChildren((child) {
      result ??= _findRenderDescendant<T>(child);
    });
    return result;
  }

  void _revealTextMatch(JsonViewerTextMatch match, {required bool editing}) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted ||
          !_verticalController.hasClients ||
          _isEditing != editing ||
          _matches.isEmpty ||
          !identical(_matches[_currentMatchIndex], match)) {
        return;
      }
      final selection = TextSelection(
        baseOffset: match.start,
        extentOffset: match.end,
      );
      final RenderObject renderText;
      final Rect matchRect;
      if (editing) {
        final editable = _findRenderDescendant<RenderEditable>(
          _editTextKey.currentContext?.findRenderObject(),
        );
        if (editable == null) return;
        renderText = editable;
        final boxes = editable.getBoxesForSelection(selection);
        matchRect = boxes.isEmpty
            ? editable.getLocalRectForCaret(selection.base)
            : boxes.first.toRect();
      } else {
        final paragraph = _findRenderDescendant<RenderParagraph>(
          _readTextKey.currentContext?.findRenderObject(),
        );
        if (paragraph == null) return;
        final boxes = paragraph.getBoxesForSelection(selection);
        if (boxes.isEmpty) return;
        renderText = paragraph;
        matchRect = boxes.first.toRect();
      }
      final position = _verticalController.position;
      final viewport = RenderAbstractViewport.of(renderText);
      double offsetAt(double alignment) => viewport
          .getOffsetToReveal(renderText, alignment, rect: matchRect)
          .offset;
      if (editing &&
          position.pixels >= offsetAt(1) &&
          position.pixels <= offsetAt(0)) {
        return;
      }
      final target = offsetAt(
        0.5,
      ).clamp(position.minScrollExtent, position.maxScrollExtent);
      _verticalController.animateTo(
        target.toDouble(),
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
      );
    });
  }

  void _scrollToLine(int lineIndex) {
    if (!_verticalController.hasClients) return;
    final lineHeight = _fontSize * 1.3;
    final target = (lineIndex * lineHeight).clamp(
      0.0,
      _verticalController.position.maxScrollExtent,
    );
    _verticalController.animateTo(
      target,
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOut,
    );
  }

  double? _currentScrollOffset() {
    if (!_verticalController.hasClients) return null;
    return _verticalController.offset;
  }

  void _restoreScrollOffsetAfterFrame(
    double offset, {
    bool repeatNextFrame = false,
  }) {
    void restore() {
      if (!mounted || !_verticalController.hasClients) return;
      final position = _verticalController.position;
      final target = offset
          .clamp(position.minScrollExtent, position.maxScrollExtent)
          .toDouble();
      if ((position.pixels - target).abs() > 0.5) {
        position.jumpTo(target);
      }
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      restore();
      if (repeatNextFrame) {
        WidgetsBinding.instance.addPostFrameCallback((_) => restore());
      }
    });
  }

  void _handleReadViewPointerDown(PointerDownEvent event) {
    if ((event.buttons & (kPrimaryButton | kSecondaryButton)) == 0) return;
    final offset = _currentScrollOffset();
    if (offset == null) return;
    _selectionPointer = event.pointer;
    _selectionPointerScrollOffset = offset;
  }

  void _finishReadViewSelectionPointer(PointerEvent event) {
    if (_selectionPointer != event.pointer) return;
    final offset = _selectionPointerScrollOffset;
    _selectionPointer = null;
    _selectionPointerScrollOffset = null;
    if (offset != null) {
      _restoreScrollOffsetAfterFrame(offset, repeatNextFrame: true);
    }
  }

  Widget _buildReadSelectionContextMenu(
    BuildContext context,
    SelectableRegionState regionState,
  ) {
    final items = regionState.contextMenuButtonItems
        .map((item) {
          if (item.type != ContextMenuButtonType.selectAll ||
              item.onPressed == null) {
            return item;
          }
          return item.copyWith(
            onPressed: () {
              final offset = _currentScrollOffset();
              item.onPressed!();
              if (offset != null) {
                _restoreScrollOffsetAfterFrame(offset, repeatNextFrame: true);
              }
            },
          );
        })
        .toList(growable: false);
    if (items.isEmpty) return const SizedBox.shrink();
    return AdaptiveTextSelectionToolbar.buttonItems(
      anchors: regionState.contextMenuAnchors,
      buttonItems: items,
    );
  }

  void _onPreviousMatch() {
    if (_matches.isEmpty) return;
    final next = (_currentMatchIndex - 1 + _matches.length) % _matches.length;
    _goToMatch(next);
  }

  void _onNextMatch() {
    if (_matches.isEmpty) return;
    final next = (_currentMatchIndex + 1) % _matches.length;
    _goToMatch(next);
  }

  void _replaceCurrentMatch() {
    if (_savingEdit || !_isEditing || _matches.isEmpty) return;
    final match = _matches[_currentMatchIndex];
    final replacement = _replaceController.text;
    final next = replaceJsonViewerMatch(
      _editController.text,
      match,
      replacement,
    );
    _applyReplacementText(
      next,
      preferredCaretOffset: match.start + replacement.length,
    );
    _pushHistory(_replaceHistoryKey, replacement, _replaceHistory);
    _runSearch(matchIndex: _currentMatchIndex);
  }

  void _replaceAllMatches() {
    if (_savingEdit || !_isEditing || _searchController.text.isEmpty) return;
    final replacement = _replaceController.text;
    final next = replaceAllJsonViewerMatches(
      _editController.text,
      _searchController.text,
      replacement,
      _searchOptions,
    );
    final previousSelection = _editController.selection;
    _applyReplacementText(
      next,
      preferredCaretOffset: previousSelection.isValid
          ? previousSelection.extentOffset
          : 0,
    );
    _pushHistory(_replaceHistoryKey, replacement, _replaceHistory);
    _runSearch(reveal: false, matchIndex: _currentMatchIndex);
  }

  void _applyReplacementText(String text, {required int preferredCaretOffset}) {
    final caretOffset = preferredCaretOffset.clamp(0, text.length);
    _editController.value = TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: caretOffset),
    );
  }

  void _onSearchChanged(String value) {
    _runSearch();
  }

  void _commitSearchHistory() {
    _pushHistory(_searchHistoryKey, _searchController.text, _searchHistory);
  }

  Future<void> _loadFontSize() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getDouble(_fontSizeKey);
    if (saved != null && mounted) {
      final isDesktop =
          Theme.of(context).platform == TargetPlatform.windows ||
          Theme.of(context).platform == TargetPlatform.macOS ||
          Theme.of(context).platform == TargetPlatform.linux;
      final min = isDesktop ? 12.0 : 6.0;
      final max = isDesktop ? 24.0 : 18.0;
      final value = saved.clamp(min, max);
      _cachedFontSize = value;
      setState(() => _fontSize = value);
    }
  }

  Future<void> _saveFontSize(double value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_fontSizeKey, value);
  }

  void _pushEscapeHandler() {
    if (_escapeHandler != null) return;
    _escapeHandler = () {
      if (_isEditing) {
        _cancelEdit();
        return true;
      }
      widget.onBack();
      return true;
    };
    EscapeOverride.push(_escapeHandler!);
  }

  void _popEscapeHandler() {
    if (_escapeHandler == null) return;
    EscapeOverride.pop(_escapeHandler!);
    _escapeHandler = null;
  }

  @override
  void dispose() {
    _popEscapeHandler();
    _verticalController.dispose();
    _editController.dispose();
    _searchController.dispose();
    _replaceController.dispose();
    super.dispose();
  }

  void _startEdit() {
    final previousScrollOffset = _currentScrollOffset();
    _editController.text = _rawPrettyText();
    _editInitialText = _editController.text;
    setState(() {
      _isEditing = true;
      _syntaxError = null;
    });
    _runSearch(reveal: false, matchIndex: _currentMatchIndex);
    if (previousScrollOffset != null) {
      _restoreScrollOffsetAfterFrame(previousScrollOffset);
    }
    _pushEscapeHandler();
  }

  Future<void> _cancelEdit() async {
    if (_confirmingCancelEdit || _savingEdit) return;
    if (_editController.text != _editInitialText) {
      if (autosaveEnabled(context, AutosaveTarget.level)) {
        await _saveEdit();
        // Invalid JSON or a failed write leaves edit mode and its text intact.
        return;
      }
      _confirmingCancelEdit = true;
      bool? discard;
      try {
        final l10n = AppLocalizations.of(context)!;
        discard = await showDialog<bool>(
          context: context,
          builder: (dialogContext) => EscapeClosesModal(
            child: AlertDialog(
              key: const ValueKey('jsonDiscardEditsDialog'),
              title: Text(l10n.unsavedChanges),
              content: Text(l10n.jsonDiscardEditsBody),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext, false),
                  child: Text(l10n.stayInEditor),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext, true),
                  child: Text(l10n.discard),
                ),
              ],
            ),
          ),
        );
      } finally {
        _confirmingCancelEdit = false;
      }
      if (!mounted || discard != true) return;
    }
    if (!mounted) return;
    _popEscapeHandler();
    setState(() {
      _isEditing = false;
      _syntaxError = null;
    });
    _runSearch(reveal: false, matchIndex: _currentMatchIndex);
  }

  Future<void> _saveEdit() async {
    if (_savingEdit || !_isEditing) return;
    setState(() => _savingEdit = true);
    try {
      await _saveEditImpl();
    } finally {
      if (mounted) setState(() => _savingEdit = false);
    }
  }

  Future<void> _saveEditImpl() async {
    final l10n = AppLocalizations.of(context);
    dynamic json;
    try {
      json = jsonDecode(_editController.text);
    } on FormatException catch (error) {
      final offset = error.offset;
      if (offset != null) {
        final preceding = _editController.text.substring(
          0,
          offset.clamp(0, _editController.text.length),
        );
        final line = 1 + '\n'.allMatches(preceding).length;
        final column = preceding.length - preceding.lastIndexOf('\n');
        _showEditError(
          l10n?.jsonEditSyntaxErrorAt('$line', '$column') ??
              'Invalid JSON syntax near line $line, column $column. Check commas, brackets, and double quotes, then save again.',
        );
      } else {
        _showEditError(
          l10n?.jsonEditSyntaxError ??
              'Invalid JSON syntax. Check commas, brackets, and double quotes, then save again.',
        );
      }
      return;
    }

    late final PvzLevelFile newLevel;
    try {
      // A missing objects list must not silently replace the level with an
      // empty file. Leave object-specific compatibility to the existing parser.
      if (json is! Map<String, dynamic> || json['objects'] is! List) {
        throw const FormatException('Expected a level objects list');
      }
      newLevel = PvzLevelFile.fromJson(json);
    } catch (_) {
      _showEditError(
        l10n?.jsonEditStructureError ??
            "This JSON does not match the level structure. Keep the objects list and each object's objclass and objdata fields; the version must be an integer.",
      );
      return;
    }

    try {
      await (widget.saveLevel ?? LevelRepository.saveAndExport)(
        widget.filePath,
        newLevel,
      );
      // Commit only after the file is saved, so a failed write does not change
      // the level behind the editor or discard the user's pending JSON edits.
      widget.levelFile.objects.clear();
      widget.levelFile.objects.addAll(newLevel.objects);
      widget.levelFile.version = newLevel.version;
      if (mounted) {
        _popEscapeHandler();
        setState(() {
          _isEditing = false;
          _syntaxError = null;
          _invalidateRenderedJson();
        });
        _runSearch(reveal: false, matchIndex: _currentMatchIndex);
        widget.onSaved?.call();
        final l10n = AppLocalizations.of(context);
        AppMessage.show(
          context,
          l10n?.saved ?? 'Saved',
          icon: Icons.check_circle,
        );
      }
    } catch (_) {
      _showEditError(
        l10n?.jsonEditSaveError ??
            'Could not save the file. Check workspace write permissions and free space, then try again. On the web, make sure the browser allows local storage. Your edits have been kept.',
      );
    }
  }

  void _showEditError(String message) {
    if (!mounted) return;
    setState(() => _syntaxError = message);
    AppMessage.show(
      context,
      AppLocalizations.of(context)?.saveFail ?? 'Save failed',
      icon: Icons.warning_amber_rounded,
    );
  }

  void _toggleJsonView() {
    setState(() {
      _viewMode = _viewMode == _JsonViewMode.rawText
          ? _JsonViewMode.structured
          : _JsonViewMode.rawText;
    });
    _runSearch();
  }

  String _jsonActionLabel(AppLocalizations? l10n, String id) {
    return switch (id) {
      InterfaceMenuActionIds.toggleJsonView =>
        l10n?.tooltipToggleObjectView ?? 'Toggle object/raw view',
      InterfaceMenuActionIds.copyJson =>
        l10n?.tooltipCopyJson ?? 'Copy level JSON',
      InterfaceMenuActionIds.clearUnused =>
        l10n?.tooltipClearUnused ?? 'Clear unused objects',
      InterfaceMenuActionIds.editJson => l10n?.tooltipEdit ?? 'Edit',
      _ => id,
    };
  }

  IconData _jsonActionIcon(String id) {
    return switch (id) {
      InterfaceMenuActionIds.toggleJsonView =>
        _viewMode == _JsonViewMode.structured ? Icons.list : Icons.data_object,
      InterfaceMenuActionIds.copyJson => Icons.copy,
      InterfaceMenuActionIds.clearUnused => Icons.cleaning_services,
      InterfaceMenuActionIds.editJson => Icons.edit,
      _ => Icons.more_horiz,
    };
  }

  Future<void> _handleJsonAction(String id) async {
    switch (id) {
      case InterfaceMenuActionIds.toggleJsonView:
        _toggleJsonView();
      case InterfaceMenuActionIds.copyJson:
        await _copyLevelJson();
      case InterfaceMenuActionIds.clearUnused:
        _showClearUnusedDialog();
      case InterfaceMenuActionIds.editJson:
        _startEdit();
    }
  }

  Widget _jsonToolbarAction(AppLocalizations? l10n, String id) {
    return IconButton(
      key: ValueKey('jsonToolbarAction_$id'),
      icon: Icon(_jsonActionIcon(id)),
      tooltip: _jsonActionLabel(l10n, id),
      onPressed: () => _handleJsonAction(id),
    );
  }

  PopupMenuEntry<String> _jsonOverflowAction(
    AppLocalizations? l10n,
    String id,
  ) {
    return PopupMenuItem<String>(
      key: ValueKey('jsonOverflowAction_$id'),
      value: id,
      child: EditorPopupMenuTile(
        contentPadding: EdgeInsets.zero,
        leading: Icon(_jsonActionIcon(id)),
        title: Text(_jsonActionLabel(l10n, id)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final isDesktop =
        theme.platform == TargetPlatform.windows ||
        theme.platform == TargetPlatform.macOS ||
        theme.platform == TargetPlatform.linux;

    return LayoutBuilder(
      builder: (context, constraints) {
        final isNarrow = constraints.maxWidth < 600;
        final pretty = _isEditing ? '' : _rawPrettyText();
        final configuredActions =
            widget.menuActions ??
            defaultInterfaceMenuActions(InterfaceMenuSurface.jsonViewer);
        final toolbarActionIds = {
          if (!isNarrow)
            for (final action in configuredActions)
              if (action.placement == InterfaceMenuPlacement.toolbar) action.id,
        };
        final overflowActions = configuredActions
            .where(
              (action) =>
                  action.placement == InterfaceMenuPlacement.overflow ||
                  (action.placement == InterfaceMenuPlacement.toolbar &&
                      !toolbarActionIds.contains(action.id)),
            )
            .toList(growable: false);

        Widget child = PopScope(
          canPop: !_isEditing,
          onPopInvokedWithResult: (didPop, result) {
            if (didPop) return;
            if (_isEditing) {
              _cancelEdit();
            } else {
              widget.onBack();
            }
          },
          child: Scaffold(
            appBar: AppBar(
              automaticallyImplyLeading: false,
              leading: IconButton(
                icon: Icon(_isEditing ? Icons.close : Icons.arrow_back),
                tooltip: _isEditing
                    ? (l10n?.tooltipClose ?? 'Close')
                    : (l10n?.back ?? 'Back'),
                onPressed: () {
                  if (_isEditing) {
                    _cancelEdit();
                  } else {
                    widget.onBack();
                  }
                },
              ),
              title: Text(
                _isEditing
                    ? '${widget.fileName} ${l10n?.jsonViewerModeEdit ?? '(edit mode)'}'
                    : _viewMode == _JsonViewMode.structured
                    ? '${widget.fileName} ${l10n?.jsonViewerModeObjectReading ?? '(object reading mode)'}'
                    : '${widget.fileName} ${l10n?.jsonViewerModeReading ?? '(reading mode)'}',
                overflow: TextOverflow.ellipsis,
              ),
              actions: [
                JsonViewerFontSizeButton(
                  currentSize: _fontSize,
                  sizes: _fontSizeOptions(isDesktop),
                  tooltip: l10n?.jsonViewerFontSize ?? 'Font size',
                  onSelected: _setFontSize,
                ),
                if (_isEditing)
                  IconButton(
                    icon: const Icon(Icons.save),
                    tooltip: l10n?.tooltipSave ?? 'Save',
                    onPressed: _savingEdit ? null : _saveEdit,
                  )
                else ...[
                  for (final action in configuredActions)
                    if (toolbarActionIds.contains(action.id))
                      _jsonToolbarAction(l10n, action.id),
                  if (overflowActions.isNotEmpty)
                    PopupMenuButton<String>(
                      key: const ValueKey('jsonOverflowMenu'),
                      tooltip: l10n?.tooltipMore ?? 'More',
                      icon: const Icon(Icons.more_vert),
                      onSelected: _handleJsonAction,
                      itemBuilder: (context) => [
                        for (final action in overflowActions)
                          _jsonOverflowAction(l10n, action.id),
                      ],
                    ),
                ],
              ],
            ),
            body: LayoutBuilder(
              builder: (context, constraints) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    JsonViewerSearchBar(
                      searchController: _searchController,
                      replaceController: _replaceController,
                      showReplace: _isEditing,
                      matchCase: _matchCase,
                      wholeWords: _wholeWords,
                      useRegex: _useRegex,
                      searchHistory: _searchHistory,
                      replaceHistory: _replaceHistory,
                      matchCount: _matches.length,
                      currentMatchIndex: _currentMatchIndex,
                      regexError: _regexError,
                      onSearchChanged: _onSearchChanged,
                      onReplaceChanged: (_) => setState(() {}),
                      onMatchCaseChanged: (v) {
                        setState(() => _matchCase = v);
                        _runSearch();
                      },
                      onWholeWordsChanged: (v) {
                        setState(() => _wholeWords = v);
                        _runSearch();
                      },
                      onRegexChanged: (v) {
                        setState(() => _useRegex = v);
                        _runSearch();
                      },
                      onPreviousMatch: _onPreviousMatch,
                      onNextMatch: _onNextMatch,
                      onReplaceOne: _replaceCurrentMatch,
                      onReplaceAll: _replaceAllMatches,
                      onHistorySelected: (v) =>
                          _pushHistory(_searchHistoryKey, v, _searchHistory),
                      onReplaceHistorySelected: (v) =>
                          _pushHistory(_replaceHistoryKey, v, _replaceHistory),
                      onSearchSubmitted: _commitSearchHistory,
                    ),
                    if (_syntaxError != null)
                      Container(
                        width: double.infinity,
                        color: theme.colorScheme.error,
                        padding: const EdgeInsets.all(8),
                        child: Text(
                          _syntaxError!,
                          style: TextStyle(
                            color: theme.colorScheme.onError,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    Expanded(
                      child: _wrapWithFontSizeGestures(
                        isDesktop: isDesktop,
                        child: _isEditing
                            ? _buildEditView()
                            : _viewMode == _JsonViewMode.structured
                            ? _buildObjectMode(isDesktop, l10n)
                            : _buildViewMode(pretty, isDesktop, l10n),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        );

        if (isDesktop) {
          child = Shortcuts(
            shortcuts: const {
              SingleActivator(LogicalKeyboardKey.escape): _EscapeIntent(),
            },
            child: Actions(
              actions: {
                _EscapeIntent: CallbackAction<_EscapeIntent>(
                  onInvoke: (_) {
                    if (_isEditing) {
                      _cancelEdit();
                      return null;
                    }
                    widget.onBack();
                    return null;
                  },
                ),
              },
              child: child,
            ),
          );
        }
        return child;
      },
    );
  }

  static const _codeFontFamily = 'monospace';

  Widget _buildEditView() {
    final colorScheme = Theme.of(context).colorScheme;
    final baseStyle = TextStyle(
      fontFamily: _codeFontFamily,
      fontSize: _fontSize,
      height: 1.3,
    );
    final editor = Scrollbar(
      controller: _verticalController,
      thumbVisibility: true,
      trackVisibility: true,
      child: SingleChildScrollView(
        controller: _verticalController,
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildLineNumbersColumn(_editController.text, baseStyle),
            const SizedBox(width: 16),
            Expanded(
              child: TextField(
                key: _editTextKey,
                readOnly: _savingEdit,
                controller: _editController,
                keyboardType: TextInputType.multiline,
                textInputAction: TextInputAction.newline,
                maxLines: null,
                // Avoid browser scroll-into-view padding that can leave a
                // blank strip under the caret after large pastes on web.
                scrollPadding: kIsWeb
                    ? EdgeInsets.zero
                    : const EdgeInsets.all(20),
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontFamily: _codeFontFamily,
                  fontSize: _fontSize,
                  height: 1.3,
                ),
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  isDense: true,
                  contentPadding: EdgeInsets.zero,
                ),
                onChanged: (_) =>
                    _runSearch(reveal: false, matchIndex: _currentMatchIndex),
              ),
            ),
          ],
        ),
      ),
    );
    // Paint the editor surface under the scroll view so any web text-editing
    // overlay / layout gap cannot show through as a white band.
    if (!kIsWeb) return editor;
    return ColoredBox(color: colorScheme.surface, child: editor);
  }

  Widget _buildLineNumbersColumn(String text, TextStyle baseStyle) {
    final lines = text.split('\n');
    final lineCount = lines.isEmpty ? 1 : lines.length;
    final digitCount = '$lineCount'.length;
    final width = _fontSize * (digitCount * 0.6 + 1.5);
    return SizedBox(
      width: width,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisSize: MainAxisSize.min,
        children: List.generate(
          lineCount,
          (i) => Text(
            '${i + 1}',
            style: baseStyle.copyWith(
              fontFamily: _codeFontFamily,
              color: Theme.of(
                context,
              ).colorScheme.onSurface.withValues(alpha: 0.5),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildViewMode(String pretty, bool isDesktop, AppLocalizations? l10n) {
    return _buildScrollLayout(pretty, isDesktop, l10n);
  }

  final Map<int, String> _jsonStringCache = {};

  Widget _buildObjectMode(bool isDesktop, AppLocalizations? l10n) {
    final objects = widget.levelFile.objects;
    return Scrollbar(
      controller: _verticalController,
      thumbVisibility: true,
      trackVisibility: isDesktop,
      child: ListView.builder(
        controller: _verticalController,
        padding: const EdgeInsets.all(16),
        itemCount: objects.length,
        itemBuilder: (context, index) {
          final obj = objects[index];
          // Cache JSON string for performance during scroll
          final jsonContent = _jsonStringCache.putIfAbsent(
            index,
            () => _jsonEncoder.convert(obj.objData),
          );

          return _ObjectCodeCard(
            index: index,
            obj: obj,
            jsonContent: jsonContent,
            fontSize: _fontSize,
            expanded: _expandedStates[index] ?? true,
            onToggle: () {
              setState(() {
                _expandedStates[index] = !(_expandedStates[index] ?? false);
              });
            },
            onCopy: () => _copyObjectJson(obj),
            onDelete: () => _deleteObjectAtIndex(index),
            copyTooltip: l10n?.tooltipCopyObject ?? 'Copy object JSON',
            deleteTooltip: l10n?.delete ?? 'Delete',
            objectMatches: _objectMatches[index] ?? const [],
            activeMatchIndex: _activeMatchIndexForObject(index),
          );
        },
      ),
    );
  }

  void _showClearUnusedDialog() async {
    final toRemove = await UnusedLevelObjectUtils.findUnusedObjects(
      widget.levelFile,
    );
    if (!mounted) return;
    if (toRemove.isEmpty) {
      if (mounted) {
        final l10n = AppLocalizations.of(context);
        AppMessage.show(
          context,
          l10n?.clearUnusedNone ?? 'No unused objects found.',
          icon: Icons.check_circle,
        );
      }
      return;
    }
    final l10n = AppLocalizations.of(context);
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n?.clearUnusedTitle ?? 'Clear unused objects?'),
        content: Text(
          l10n?.clearUnusedMessage ??
              'This will permanently delete all unused objects from the level file, including custom zombies, their properties, and any other unreferenced data. This action cannot be undone. Continue?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(l10n?.cancel ?? 'Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(ctx).colorScheme.error,
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(l10n?.delete ?? 'Delete'),
          ),
        ],
      ),
    );
    if (ok == true && mounted) {
      for (final obj in toRemove) {
        widget.levelFile.objects.remove(obj);
      }
      await LevelRepository.saveAndExport(widget.filePath, widget.levelFile);
      widget.onSaved?.call();
      if (mounted) {
        _invalidateRenderedJson();
        _runSearch(reveal: false, matchIndex: _currentMatchIndex);
        final msg =
            l10n?.clearUnusedDone(toRemove.length) ??
            'Removed ${toRemove.length} unused object(s).';
        AppMessage.show(context, msg, icon: Icons.check_circle);
      }
    }
  }

  void _deleteObjectAtIndex(int index) async {
    final l10n = AppLocalizations.of(context);
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n?.deleteObjectTitle ?? 'Delete object?'),
        content: Text(
          l10n?.deleteObjectConfirmMessage ??
              'Remove this object from the level file? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(l10n?.cancel ?? 'Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(l10n?.delete ?? 'Delete'),
          ),
        ],
      ),
    );
    if (ok == true && mounted) {
      widget.levelFile.objects.removeAt(index);
      await LevelRepository.saveAndExport(widget.filePath, widget.levelFile);
      widget.onSaved?.call();
      if (mounted) {
        _invalidateRenderedJson();
        _runSearch(reveal: false, matchIndex: _currentMatchIndex);
        AppMessage.show(
          context,
          l10n?.objectDeleted ?? 'Object deleted',
          icon: Icons.check_circle,
        );
      }
    }
  }

  int? _activeMatchIndexForObject(int objectIndex) {
    if (_matches.isEmpty || _currentMatchIndex >= _matchObjectIndices.length) {
      return null;
    }
    if (_matchObjectIndices[_currentMatchIndex] != objectIndex) return null;
    final objectMatches = _objectMatches[objectIndex];
    if (objectMatches == null) return null;
    return objectMatches.indexOf(_matches[_currentMatchIndex]);
  }

  Widget _buildScrollLayout(
    String pretty,
    bool isDesktop,
    AppLocalizations? l10n,
  ) {
    final theme = Theme.of(context);
    final baseStyle = TextStyle(
      fontFamily: _codeFontFamily,
      fontSize: _fontSize,
      height: 1.5, // Predictable height for stability
      color: theme.colorScheme.onSurface,
    );
    final muted = theme.colorScheme.onSurface.withValues(alpha: 0.5);
    final logicalLines = pretty.split('\n');
    final logicalLineCount = logicalLines.isEmpty ? 1 : logicalLines.length;
    final digitCount = '$logicalLineCount'.length;
    final gutterW = _fontSize * (digitCount * 0.65 + 0.8).clamp(2.5, 8.0);
    final contSymbol = l10n?.jsonViewerLineContinuation ?? '↳';
    final highlightStyle = _matchStyle(baseStyle, theme.colorScheme);
    final activeHighlightStyle = _matchStyle(
      baseStyle,
      theme.colorScheme,
      active: true,
    );
    final lineStarts = <int>[];
    var runningOffset = 0;
    for (final line in logicalLines) {
      lineStarts.add(runningOffset);
      runningOffset += line.length + 1;
    }
    final activeMatch = _matches.isEmpty
        ? null
        : _matches[_currentMatchIndex.clamp(0, _matches.length - 1)];
    const textHeightBehavior = TextHeightBehavior(
      applyHeightToFirstAscent: false,
      applyHeightToLastDescent: false,
    );

    return Scrollbar(
      controller: _verticalController,
      thumbVisibility: true,
      trackVisibility: isDesktop,
      interactive: isDesktop,
      child: SingleChildScrollView(
        controller: _verticalController,
        padding: const EdgeInsets.all(16),
        child: LayoutBuilder(
          builder: (context, constraints) {
            const gutterTextGap = 12.0;
            final rowWidth = constraints.maxWidth;
            final contentWidth = _jsonContentWidth(
              rowWidth: rowWidth,
              gutterW: gutterW,
              gutterTextGap: gutterTextGap,
            );
            final strutStyle = StrutStyle(
              fontFamily: _codeFontFamily,
              fontSize: _fontSize,
              height: 1.5,
              forceStrutHeight: true,
            );

            // Keep the JSON as one selectable paragraph. The paragraph performs
            // visual wrapping while its underlying text retains only the original
            // logical newlines. Gutter rows are derived from the same layout pass
            // so line numbers stay aligned with the rendered source.
            final documentSpans = <InlineSpan>[];
            for (var i = 0; i < logicalLines.length; i++) {
              final line = logicalLines[i];
              if (_matches.isEmpty) {
                documentSpans.add(TextSpan(text: line));
              } else {
                documentSpans.addAll(
                  buildHighlightedTextSpans(
                    text: line,
                    segmentStartInLine: 0,
                    segmentEndInLine: line.length,
                    baseStyle: baseStyle,
                    highlightStyle: highlightStyle,
                    activeHighlightStyle: activeHighlightStyle,
                    lineMatches: _matches
                        .where((match) => match.lineIndex == i)
                        .toList(),
                    activeMatch: activeMatch,
                    lineStartOffset: lineStarts[i],
                  ),
                );
              }
              if (i != logicalLines.length - 1) {
                documentSpans.add(const TextSpan(text: '\n'));
              }
            }

            final contentSignature = Object.hash(
              pretty.hashCode,
              _matches.length,
              _currentMatchIndex,
            );
            final sizeDelta = (_fontSize - _lastFontSize).abs();
            final widthDelta = (contentWidth - _lastWidth).abs();

            if (_cachedGutterLayout == null ||
                widthDelta > 1.0 ||
                sizeDelta > 0.1 ||
                _lastContentSignature != contentSignature) {
              _cachedGutterLayout = _layoutGutter(
                documentSpans: documentSpans,
                baseStyle: baseStyle,
                strutStyle: strutStyle,
                maxWidth: contentWidth,
                lineStarts: lineStarts,
                textScaler: MediaQuery.textScalerOf(context),
                textHeightBehavior: textHeightBehavior,
              );
              _lastWidth = contentWidth;
              _lastFontSize = _fontSize;
              _lastContentSignature = contentSignature;
            }

            final visualRows = _cachedGutterLayout!.rows;
            final lineHeights = _cachedGutterLayout!.lineHeights;

            final selectableJson = SelectionArea(
              contextMenuBuilder: _buildReadSelectionContextMenu,
              child: Text.rich(
                TextSpan(children: documentSpans),
                key: _readTextKey,
                style: baseStyle,
                strutStyle: strutStyle,
                textHeightBehavior: textHeightBehavior,
                softWrap: true,
              ),
            );

            final jsonContent = isDesktop
                ? Listener(
                    behavior: HitTestBehavior.translucent,
                    onPointerDown: _handleReadViewPointerDown,
                    onPointerUp: _finishReadViewSelectionPointer,
                    onPointerCancel: _finishReadViewSelectionPointer,
                    child: selectableJson,
                  )
                : selectableJson;

            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: gutterW,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      for (var i = 0; i < visualRows.length; i++)
                        SizedBox(
                          height: lineHeights[i],
                          child: Align(
                            alignment: Alignment.centerRight,
                            child: Text(
                              visualRows[i].isContinuation
                                  ? contSymbol
                                  : '${visualRows[i].logicalLineOneBased}',
                              style: baseStyle.copyWith(
                                fontFamily: _codeFontFamily,
                                color: muted,
                                fontSize: visualRows[i].isContinuation
                                    ? _fontSize * 0.92
                                    : _fontSize,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(width: gutterTextGap),
                SizedBox(width: contentWidth, child: jsonContent),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _GutterLayout {
  const _GutterLayout({required this.rows, required this.lineHeights});

  final List<_WrappedJsonRow> rows;
  final List<double> lineHeights;
}

class _WrappedJsonRow {
  const _WrappedJsonRow({
    required this.logicalLineOneBased,
    required this.isContinuation,
    required this.text,
    required this.segmentStartInLine,
  });

  final int logicalLineOneBased;
  final bool isContinuation;
  final String text;
  final int segmentStartInLine;
}

_GutterLayout _layoutGutter({
  required List<InlineSpan> documentSpans,
  required TextStyle baseStyle,
  required StrutStyle strutStyle,
  required double maxWidth,
  required List<int> lineStarts,
  required TextScaler textScaler,
  required TextHeightBehavior textHeightBehavior,
}) {
  final width = maxWidth <= 8 ? 8.0 : maxWidth;
  final painter = TextPainter(
    text: TextSpan(style: baseStyle, children: documentSpans),
    textDirection: TextDirection.ltr,
    strutStyle: strutStyle,
    textScaler: textScaler,
    textHeightBehavior: textHeightBehavior,
  )..layout(maxWidth: width);

  final metrics = painter.computeLineMetrics();
  if (metrics.isEmpty) {
    return const _GutterLayout(
      rows: [
        _WrappedJsonRow(
          logicalLineOneBased: 1,
          isContinuation: false,
          text: '',
          segmentStartInLine: 0,
        ),
      ],
      lineHeights: [18],
    );
  }

  final plainTextLength = painter.text?.toPlainText().length ?? 0;
  final rows = <_WrappedJsonRow>[];
  final lineHeights = <double>[];
  var previousLogicalLine = -1;
  for (final metric in metrics) {
    final yMid = metric.baseline - metric.ascent + metric.height / 2;
    final offset = painter
        .getPositionForOffset(Offset(0, yMid))
        .offset
        .clamp(0, plainTextLength);
    final logicalIndex = _logicalLineIndexForOffset(offset, lineStarts);
    final logicalLineOneBased = logicalIndex + 1;
    rows.add(
      _WrappedJsonRow(
        logicalLineOneBased: logicalLineOneBased,
        isContinuation: logicalLineOneBased == previousLogicalLine,
        text: '',
        segmentStartInLine: 0,
      ),
    );
    lineHeights.add(metric.height);
    previousLogicalLine = logicalLineOneBased;
  }
  return _GutterLayout(rows: rows, lineHeights: lineHeights);
}

int _logicalLineIndexForOffset(int offset, List<int> lineStarts) {
  if (lineStarts.isEmpty) return 0;
  var low = 0;
  var high = lineStarts.length - 1;
  while (low < high) {
    final mid = (low + high + 1) >> 1;
    if (lineStarts[mid] <= offset) {
      low = mid;
    } else {
      high = mid - 1;
    }
  }
  return low;
}

class _ObjectCodeCard extends StatelessWidget {
  static const codeFontFamily = 'monospace';

  const _ObjectCodeCard({
    required this.index,
    required this.obj,
    required this.jsonContent,
    required this.fontSize,
    required this.expanded,
    required this.onToggle,
    required this.onCopy,
    required this.onDelete,
    required this.copyTooltip,
    required this.deleteTooltip,
    required this.objectMatches,
    required this.activeMatchIndex,
  });

  final int index;
  final PvzObject obj;
  final String jsonContent;
  final double fontSize;
  final bool expanded;
  final VoidCallback onToggle;
  final VoidCallback onCopy;
  final VoidCallback onDelete;
  final String copyTooltip;
  final String deleteTooltip;
  final List<JsonViewerTextMatch> objectMatches;
  final int? activeMatchIndex;

  Widget _headerActionButton({
    required Color backgroundColor,
    required Color foregroundColor,
    required IconData icon,
    required String tooltip,
    required VoidCallback onPressed,
  }) {
    return Material(
      color: backgroundColor,
      borderRadius: BorderRadius.circular(6),
      child: IconButton(
        icon: Icon(icon),
        tooltip: tooltip,
        onPressed: onPressed,
        color: foregroundColor,
        iconSize: 20,
        padding: const EdgeInsets.all(6),
        constraints: const BoxConstraints(),
        style: IconButton.styleFrom(
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final isLevelDef = obj.objClass == 'LevelDefinition';
    // String processing moved out of build for performance.
    final headerBg = isDark ? const Color(0xFF2E7D32) : const Color(0xFF4CAF50);
    final deleteBtnBg = theme.colorScheme.error;
    // Light blue, tuned per theme so it stays readable on the green header.
    final copyBtnBg = isDark
        ? const Color(0xFF4FC3F7)
        : const Color(0xFF81D4FA);
    final copyBtnFg = isDark
        ? const Color(0xFF01579B)
        : const Color(0xFF0277BD);

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          InkWell(
            onTap: onToggle,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(color: headerBg),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 12,
                    backgroundColor: Colors.white.withValues(alpha: 0.3),
                    child: Text(
                      '${index + 1}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (!isLevelDef &&
                            obj.aliases != null &&
                            obj.aliases!.isNotEmpty)
                          Text(
                            'Aliases: ${obj.aliases!.join(', ')}',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: Colors.white,
                            ),
                          ),
                        Text(
                          'ObjClass: ${obj.objClass}',
                          style: theme.textTheme.bodySmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                  _headerActionButton(
                    backgroundColor: copyBtnBg,
                    foregroundColor: copyBtnFg,
                    icon: Icons.copy,
                    tooltip: copyTooltip,
                    onPressed: onCopy,
                  ),
                  const SizedBox(width: 6),
                  _headerActionButton(
                    backgroundColor: deleteBtnBg,
                    foregroundColor: theme.colorScheme.onError,
                    icon: Icons.delete_outline,
                    tooltip: deleteTooltip,
                    onPressed: onDelete,
                  ),
                  const SizedBox(width: 4),
                  Icon(
                    expanded ? Icons.expand_less : Icons.expand_more,
                    color: Colors.white,
                  ),
                ],
              ),
            ),
          ),
          if (expanded)
            Padding(
              padding: const EdgeInsets.all(12),
              child: _HighlightedJsonText(
                jsonContent: jsonContent,
                fontSize: fontSize,
                objectMatches: objectMatches,
                activeMatch:
                    activeMatchIndex != null &&
                        activeMatchIndex! >= 0 &&
                        activeMatchIndex! < objectMatches.length
                    ? objectMatches[activeMatchIndex!]
                    : null,
              ),
            ),
        ],
      ),
    );
  }
}

class _HighlightedJsonText extends StatelessWidget {
  const _HighlightedJsonText({
    required this.jsonContent,
    required this.fontSize,
    required this.objectMatches,
    required this.activeMatch,
  });

  final String jsonContent;
  final double fontSize;
  final List<JsonViewerTextMatch> objectMatches;
  final JsonViewerTextMatch? activeMatch;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final baseStyle =
        theme.textTheme.bodyMedium?.copyWith(
          fontFamily: _ObjectCodeCard.codeFontFamily,
          fontSize: fontSize,
          height: 1.3,
          color: theme.colorScheme.onSurface,
        ) ??
        TextStyle(
          fontFamily: _ObjectCodeCard.codeFontFamily,
          fontSize: fontSize,
          height: 1.3,
          color: theme.colorScheme.onSurface,
        );
    if (objectMatches.isEmpty) {
      return Text(jsonContent, style: baseStyle);
    }

    final highlightStyle = _matchStyle(baseStyle, theme.colorScheme);
    final activeHighlightStyle = _matchStyle(
      baseStyle,
      theme.colorScheme,
      active: true,
    );
    final lines = jsonContent.split('\n');
    final lineStarts = <int>[];
    var offset = 0;
    for (final line in lines) {
      lineStarts.add(offset);
      offset += line.length + 1;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (var i = 0; i < lines.length; i++)
          RichText(
            text: TextSpan(
              style: baseStyle,
              children: [
                ...buildHighlightedTextSpans(
                  text: lines[i],
                  segmentStartInLine: 0,
                  segmentEndInLine: lines[i].length,
                  baseStyle: baseStyle,
                  highlightStyle: highlightStyle,
                  activeHighlightStyle: activeHighlightStyle,
                  lineMatches: objectMatches
                      .where((m) => m.lineIndex == i)
                      .toList(),
                  activeMatch: activeMatch,
                  lineStartOffset: lineStarts[i],
                ),
                if (i < lines.length - 1) const TextSpan(text: '\n'),
              ],
            ),
          ),
      ],
    );
  }
}
