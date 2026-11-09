import 'dart:convert';
import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:c_editor/l10n/app_localizations.dart';
import 'package:c_editor/widgets/app_message.dart';
import 'package:c_editor/widgets/labeled_progress_bar.dart';
import 'package:c_editor/widgets/editor_components.dart';
import 'package:c_editor/data/level_validator.dart';
import 'package:c_editor/data/repository/level_repository.dart';
import 'package:c_editor/data/repository/world_repository.dart';
import 'package:c_editor/widgets/asset_image.dart';
import 'package:c_editor/screens/export/export_engine.dart';
import 'package:c_editor/screens/export/export_rsb_isolate.dart';
import 'package:c_editor/plugins/plugin_host_hooks.dart';
import 'package:c_editor/theme/app_theme.dart';

enum ExportStep {
  disclaimer,
  selectingArchive,
  selectingLevels,
  reviewSelection,
  proposingAssignments,
  finalCheck,
  success,
}

const _exportDisclaimerSkipKey = 'export_disclaimer_skip';

/// Leaf file name for display, stripping the web `web://` scheme prefix (which
/// `p.basename` leaves intact) and any directory segments.
String _exportLeafName(String path) {
  var s = path;
  const webPrefix = 'web://';
  if (s.startsWith(webPrefix)) {
    s = s.substring(webPrefix.length);
  }
  final fwd = s.lastIndexOf('/');
  if (fwd >= 0) s = s.substring(fwd + 1);
  final back = s.lastIndexOf('\\');
  if (back >= 0) s = s.substring(back + 1);
  return s;
}

class ExportScreen extends StatefulWidget {
  const ExportScreen({super.key, this.engine});

  @visibleForTesting
  final ExportEngine? engine;

  @override
  State<ExportScreen> createState() => _ExportScreenState();
}

class _ExportScreenState extends State<ExportScreen> {
  String? _selectedArchivePath;
  final Set<String> _selectedLevelPaths = {};
  final Map<String, ({String world, int level})> _levelAssignments = {};
  bool _noFilesFound = false;
  ExportStep _currentStep = ExportStep.disclaimer;
  bool _doNotShowDisclaimerAgain = false;

  /// When true, the disclaimer step is bypassed entirely (the user ticked "Do
  /// not show again"), so backing out of archive selection must exit the export
  /// screen rather than returning to a disclaimer that should never show.
  bool _skipDisclaimer = false;

  /// True until SharedPreferences are read — avoids a one-frame disclaimer flash
  /// when "Do not show again" is already saved.
  bool _initializing = true;

  // State for custom file picker
  String? _rootPath;
  final List<({String name, String path})> _pathStack = [];
  List<ExportEntry> _currentPathItems = [];
  bool _isScanning = false;

  late final ExportEngine _engine;

  double _exportProgress = 0;
  String _exportStatus = '';
  bool _isExporting = false;

  @override
  void initState() {
    super.initState();
    _engine = widget.engine ?? createExportEngine();
    _initRootPath();
  }

  Future<void> _initRootPath() async {
    // Safety net if export is opened before AppBootstrap finished (or in tests).
    await WorldRepository.init();
    final prefs = await SharedPreferences.getInstance();
    final skipDisclaimer = prefs.getBool(_exportDisclaimerSkipKey) ?? false;
    if (!mounted) return;
    setState(() {
      _rootPath = kIsWeb ? 'web://' : prefs.getString('folder_path');
      _doNotShowDisclaimerAgain = skipDisclaimer;
      _skipDisclaimer = skipDisclaimer;
      if (skipDisclaimer) {
        // Skip the disclaimer entirely — never paint it.
        _currentStep = ExportStep.selectingArchive;
        _isScanning = true;
      }
      _initializing = false;
    });
    if (skipDisclaimer) {
      await _performGlobalScan();
    }
  }

  Future<void> _onDisclaimerProceed() async {
    final skipDisclaimer = _doNotShowDisclaimerAgain;
    setState(() {
      _skipDisclaimer = skipDisclaimer;
      _isScanning = true;
    });
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_exportDisclaimerSkipKey, skipDisclaimer);
    if (!mounted) return;
    await _performGlobalScan();
  }

  Future<void> _performGlobalScan() async {
    if (_rootPath == null || _rootPath!.isEmpty) {
      setState(() {
        _noFilesFound = true;
        _isScanning = false;
      });
      return;
    }

    setState(() => _isScanning = true);

    try {
      final hasEligibleFile = await _engine.hasEligibleArchive(_rootPath!);

      if (mounted) {
        if (hasEligibleFile) {
          setState(() {
            _currentStep = ExportStep.selectingArchive;
            _noFilesFound = false;
          });
          await _loadDirectory(_rootPath!);
        } else {
          setState(() => _noFilesFound = true);
        }
      }
    } catch (e) {
      debugPrint("Scan failed: $e");
      if (mounted) {
        setState(() => _noFilesFound = true);
      }
    } finally {
      if (mounted) {
        setState(() => _isScanning = false);
      }
    }

    if (mounted && _noFilesFound) {
      await _offerExternalDynamicIfAvailable();
    }
  }

  /// When no `.rsb.smf` files exist, let an enabled plugin offer a download.
  Future<void> _offerExternalDynamicIfAvailable() async {
    await _runExternalDynamicDownload();
  }

  bool get _externalDynamicDownloadAvailable =>
      PluginHostHooks.offerExternalDynamic != null &&
      _rootPath != null &&
      _rootPath!.isNotEmpty;

  /// Directory the user is currently browsing (or the library root).
  String? get _currentLibraryPath {
    if (_pathStack.isNotEmpty) return _pathStack.last.path;
    return _rootPath;
  }

  Future<void> _runExternalDynamicDownload({
    bool skipInitialPrompt = false,
  }) async {
    final hook = PluginHostHooks.offerExternalDynamic;
    // Import into the folder currently being browsed, matching native behavior.
    final libraryPath = _currentLibraryPath;
    if (hook == null || libraryPath == null || libraryPath.isEmpty) return;
    if (!mounted) return;

    final obtained = await hook(
      context,
      libraryPath: libraryPath,
      skipInitialPrompt: skipInitialPrompt,
    );
    if (!obtained || !mounted) return;

    await _refreshAfterExternalDynamicDownload();
  }

  Future<void> _refreshAfterExternalDynamicDownload() async {
    final rootPath = _rootPath;
    if (rootPath == null || rootPath.isEmpty) return;
    final currentPath = _currentLibraryPath ?? rootPath;

    setState(() => _isScanning = true);
    try {
      // Eligibility is library-wide; refresh the folder the user is viewing.
      final hasEligibleFile = await _engine.hasEligibleArchive(rootPath);
      if (!mounted) return;
      if (!hasEligibleFile) return;

      if (_currentStep == ExportStep.disclaimer) {
        setState(() {
          _currentStep = ExportStep.selectingArchive;
          _noFilesFound = false;
          _pathStack.clear();
        });
        await _loadDirectory(rootPath);
      } else if (_currentStep == ExportStep.selectingArchive) {
        setState(() => _noFilesFound = false);
        await _loadDirectory(currentPath);
      }
    } finally {
      if (mounted) setState(() => _isScanning = false);
    }
  }

  Future<void> _loadDirectory(String path) async {
    try {
      final filtered = await _engine.listDirectory(
        path,
        archiveStep: _currentStep == ExportStep.selectingArchive,
      );

      if (mounted) {
        final l10n = AppLocalizations.of(context)!;
        setState(() {
          _currentPathItems = filtered;
          if (_pathStack.isEmpty || _pathStack.last.path != path) {
            _pathStack.add((name: _dirDisplayName(path, l10n), path: path));
          }
        });
      }
    } catch (e) {
      debugPrint("Load directory failed: $e");
    }
  }

  /// Breadcrumb label for a directory. The web library root is the virtual
  /// `web://` path, which is meaningless to users — show a localized "Root"
  /// label instead of the raw scheme.
  String _dirDisplayName(String path, AppLocalizations l10n) {
    if (path == _rootPath && path.startsWith('web://')) {
      return l10n.rootFolder;
    }
    final base = _exportLeafName(path);
    return base.isEmpty ? l10n.rootFolder : base;
  }

  void _navigateBack() {
    if (_pathStack.length > 1) {
      setState(() {
        _pathStack.removeLast();
        _loadDirectory(_pathStack.last.path);
      });
    } else if (_skipDisclaimer) {
      // Disclaimer is bypassed — leave the export screen instead of exposing it.
      Navigator.of(context).pop();
    } else {
      setState(() {
        _pathStack.clear();
        _currentStep = ExportStep.disclaimer;
      });
    }
  }

  void _breadcrumbTap(int index) {
    if (index < _pathStack.length - 1) {
      final target = _pathStack[index];
      setState(() {
        _pathStack.removeRange(index + 1, _pathStack.length);
        _loadDirectory(target.path);
      });
    }
  }

  Future<void> _showBackupRecommendation() async {
    final l10n = AppLocalizations.of(context)!;

    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(l10n.backupRecommendationTitle),
          content: Text(l10n.backupRecommendationBody),
          actions: <Widget>[
            TextButton(
              child: Text(l10n.proceedWithoutBackup),
              onPressed: () {
                Navigator.of(context).pop();
                _switchToLevelSelection();
              },
            ),
            FilledButton(
              child: Text(l10n.backupAndProceed),
              onPressed: () async {
                final nav = Navigator.of(context);
                await _createBackup();
                nav.pop();
                _switchToLevelSelection();
              },
            ),
          ],
        );
      },
    );
  }

  void _switchToLevelSelection() {
    setState(() {
      _currentStep = ExportStep.selectingLevels;
      _pathStack.clear();
    });
    _loadDirectory(_rootPath!);
  }

  Future<void> _createBackup() async {
    if (_selectedArchivePath == null) return;

    final l10n = AppLocalizations.of(context)!;
    final directory = _engine.parentDirectory(_selectedArchivePath!);
    // Never use p.basename on web:// paths — on Flutter web (url path style)
    // it returns the whole "web://…" string, which then creates a "web:" folder.
    final fileName = _exportLeafName(_selectedArchivePath!);

    String baseName;
    String extension;
    const rsbExt = '.rsb.smf';
    if (fileName.toLowerCase().endsWith(rsbExt)) {
      baseName = fileName.substring(0, fileName.length - rsbExt.length);
      extension = rsbExt;
    } else {
      final dot = fileName.lastIndexOf('.');
      if (dot > 0) {
        baseName = fileName.substring(0, dot);
        extension = fileName.substring(dot);
      } else {
        baseName = fileName;
        extension = '';
      }
    }

    final suggestedBase = "$baseName${l10n.backupSuffix}";
    final backupName = await LevelRepository.getFirstAvailableIndexedName(
      directory,
      suggestedBase,
      extension,
    );

    // Show progress dialog
    if (!mounted) return;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text(l10n.backupProgressTitle),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [LabeledProgressBar(value: null), SizedBox(height: 16)],
        ),
      ),
    );

    try {
      final ok = await LevelRepository.copyLevelToTarget(
        _selectedArchivePath!,
        directory,
        backupName,
      );
      if (!ok) {
        throw Exception('Backup copy failed');
      }
      if (mounted) {
        Navigator.of(context).pop(); // Close progress dialog

        // Auto-refresh the list so the new backup file appears immediately
        await _loadDirectory(_pathStack.last.path);

        if (mounted) {
          AppMessage.show(context, l10n.success, icon: Icons.check_circle);
        }
      }
    } catch (e) {
      debugPrint("Backup failed: $e");
      if (mounted) {
        Navigator.of(context).pop(); // Close progress dialog
        AppMessage.show(
          context,
          "${l10n.error}: $e",
          icon: Icons.error_outline,
        );
      }
    }
  }

  Future<void> _validateAndFinishExport() async {
    final l10n = AppLocalizations.of(context)!;
    final total = _selectedLevelPaths.length;
    int current = 0;

    // Use a ValueNotifier to update the progress dialog
    final progressNotifier = ValueNotifier<double>(0);

    // Show progress dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text(l10n.exportPackageProgressTitle),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ValueListenableBuilder<double>(
              valueListenable: progressNotifier,
              builder: (context, value, child) =>
                  LabeledProgressBar(value: value),
            ),
          ],
        ),
      ),
    );

    final allIssues = <String, List<ValidationIssue>>{};

    try {
      for (final path in _selectedLevelPaths) {
        current++;
        progressNotifier.value = current / total;

        final lowerPath = path.toLowerCase();
        final isJson = lowerPath.endsWith('.json');
        final isRton = lowerPath.endsWith('.rton');

        if (!isJson && !isRton) continue;

        try {
          final levelFile = await LevelRepository.loadLevelFromPath(path);

          if (levelFile != null && mounted) {
            final issues = LevelValidator.validate(context, levelFile);
            if (issues.isNotEmpty) {
              allIssues[_exportLeafName(path)] = issues;
            }
          }
        } catch (e) {
          debugPrint("Validation failed for $path: $e");
        }
      }
    } catch (e) {
      debugPrint("Global validation process failed: $e");
    } finally {
      if (mounted) {
        Navigator.of(context).pop(); // Close progress dialog
      }
    }

    if (allIssues.isNotEmpty) {
      final action = await _showValidationIssuesDialog(allIssues);
      if (action == 'proceed' || action == 'close') {
        setState(() {
          _currentStep = ExportStep.reviewSelection;
        });
      }
      return;
    }

    setState(() {
      _currentStep = ExportStep.reviewSelection;
    });
  }

  void _initializeAssignments() {
    _levelAssignments.clear();
    final worlds = WorldRepository.allWorlds;
    int worldIdx = 0;
    int levelIdx = 1;

    for (final path in _selectedLevelPaths) {
      if (worldIdx >= worlds.length) {
        // Fallback or stop if too many levels selected?
        // Just repeat last world if necessary, user will have to fix duplicates anyway
        final world = worlds.last;
        _levelAssignments[path] = (world: world.codename, level: 1);
        continue;
      }

      final world = worlds[worldIdx];
      _levelAssignments[path] = (world: world.codename, level: levelIdx);

      levelIdx++;
      if (levelIdx > world.levelCount) {
        levelIdx = 1;
        worldIdx++;
      }
    }
  }

  Future<String?> _showValidationIssuesDialog(
    Map<String, List<ValidationIssue>> allIssues,
  ) async {
    final l10n = AppLocalizations.of(context)!;

    return showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.conflictTitle_ModuleLogic),
        content: SizedBox(
          width: 600,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: Text(
                    l10n.validationReviewRequest,
                    style: const TextStyle(fontStyle: FontStyle.italic),
                  ),
                ),
                ...allIssues.entries.map((entry) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: Text(
                          entry.key,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Colors.blueGrey,
                          ),
                        ),
                      ),
                      ...entry.value.map((issue) {
                        if (issue.isError) {
                          return Card(
                            color: Theme.of(context).colorScheme.errorContainer,
                            margin: const EdgeInsets.only(bottom: 8),
                            child: Padding(
                              padding: const EdgeInsets.all(12),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.error,
                                        color: Theme.of(
                                          context,
                                        ).colorScheme.onErrorContainer,
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          issue.title,
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Theme.of(
                                              context,
                                            ).colorScheme.onErrorContainer,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    issue.message,
                                    style: TextStyle(
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.onErrorContainer,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        } else {
                          return EditorWarningBanner(
                            title: issue.title,
                            message: issue.message,
                            margin: const EdgeInsets.only(bottom: 8),
                            children: issue.bulletPoints
                                .map(
                                  (bp) => Text(
                                    '• $bp',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: editorWarningBannerForeground(
                                        Theme.of(context).brightness,
                                      ),
                                    ),
                                  ),
                                )
                                .toList(),
                          );
                        }
                      }),
                      const Divider(),
                    ],
                  );
                }),
                Padding(
                  padding: const EdgeInsets.only(top: 16.0, bottom: 8.0),
                  child: Text(
                    l10n.validationRecommendation,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                      fontSize: 13,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop('reselect'),
            child: Text(l10n.reselectFiles),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop('close'),
            child: Text(l10n.close),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop('proceed'),
            child: Text(
              l10n.proceed,
              style: const TextStyle(
                color: Colors.orange,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<bool> _onWillPop() async {
    if (_isExporting) return false;
    if (_currentStep == ExportStep.disclaimer) {
      return true;
    }

    if (_currentStep == ExportStep.selectingArchive &&
        _selectedArchivePath != null) {
      setState(() => _selectedArchivePath = null);
      return false;
    }

    if (_currentStep == ExportStep.selectingLevels &&
        _selectedLevelPaths.isNotEmpty) {
      setState(() => _selectedLevelPaths.clear());
      return false;
    }

    if (_currentStep == ExportStep.reviewSelection) {
      setState(() {
        _currentStep = ExportStep.selectingLevels;
      });
      return false;
    }

    if (_currentStep == ExportStep.proposingAssignments) {
      setState(() {
        _currentStep = ExportStep.reviewSelection;
        _levelAssignments.clear();
      });
      return false;
    }

    if (_currentStep == ExportStep.finalCheck) {
      setState(() {
        _currentStep = ExportStep.proposingAssignments;
      });
      return false;
    }

    // If we are in selecting step, back button should navigate folders
    if (_currentStep == ExportStep.selectingArchive ||
        _currentStep == ExportStep.selectingLevels) {
      if (_pathStack.length > 1) {
        _navigateBack();
        return false;
      } else if (_currentStep == ExportStep.selectingLevels) {
        // From root of level selection, go back to archive selection
        setState(() {
          _currentStep = ExportStep.selectingArchive;
          _selectedArchivePath = null;
          _pathStack.clear();
        });
        _loadDirectory(_rootPath!);
        return false;
      } else if (_skipDisclaimer) {
        // Disclaimer is bypassed — allow the export screen to close.
        return true;
      } else {
        // From root of archive selection, go back to disclaimer
        _navigateBack();
        return false;
      }
    }

    return true;
  }

  Future<void> _handleClose() async {
    if (_isExporting) return;
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.cancelExportTitle),
        content: Text(l10n.cancelExportMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(
              l10n.confirm,
              style: const TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      Navigator.of(context).pop();
    }
  }

  Future<void> _showDisclaimerDialog() {
    final l10n = AppLocalizations.of(context)!;
    return showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        key: const ValueKey('exportDisclaimerDialog'),
        title: Row(
          children: [
            Icon(
              Icons.info_outline,
              color: Theme.of(dialogContext).colorScheme.primary,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                l10n.exportDisclaimerTitle,
                key: const ValueKey('exportDisclaimerDialogTitle'),
                style: Theme.of(
                  dialogContext,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        content: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 720),
          child: SingleChildScrollView(
            child: Text(
              l10n.exportDisclaimerBody,
              style: Theme.of(
                dialogContext,
              ).textTheme.bodyMedium?.copyWith(height: 1.6),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(MaterialLocalizations.of(dialogContext).okButtonLabel),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        final nav = Navigator.of(context);
        final shouldPop = await _onWillPop();
        if (shouldPop && mounted) {
          nav.pop();
        }
      },
      child: Scaffold(
        appBar: _currentStep == ExportStep.success
            ? null
            : AppBar(
                title: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Flexible(
                      child: Text(
                        l10n.exportLevels,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    if (_currentStep != ExportStep.disclaimer) ...[
                      const SizedBox(width: 4),
                      IconButton(
                        key: const ValueKey('exportDisclaimerInfoButton'),
                        visualDensity: VisualDensity.compact,
                        tooltip: l10n.exportDisclaimerTitle,
                        onPressed: _showDisclaimerDialog,
                        icon: const Icon(Icons.info_outline),
                      ),
                    ],
                  ],
                ),
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () async {
                    if (_isExporting) return;
                    if (_currentStep == ExportStep.disclaimer) {
                      Navigator.of(context).pop();
                    } else {
                      final nav = Navigator.of(context);
                      final shouldPop = await _onWillPop();
                      if (shouldPop && mounted) {
                        nav.pop();
                      }
                    }
                  },
                ),
                actions: (_currentStep == ExportStep.disclaimer || _isExporting)
                    ? null
                    : [
                        IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: _handleClose,
                          tooltip: l10n.cancel,
                        ),
                      ],
              ),
        body: _initializing
            ? const Center(child: CircularProgressIndicator())
            : _buildStepContent(l10n, theme),
      ),
    );
  }

  Widget _buildStepContent(AppLocalizations l10n, ThemeData theme) {
    if (_isExporting) {
      return _buildExportProgress(l10n, theme);
    }
    if (_currentStep == ExportStep.disclaimer) {
      return _buildDisclaimer(l10n, theme);
    }

    if (_currentStep == ExportStep.reviewSelection) {
      return _buildReviewSelection(l10n, theme);
    }

    if (_currentStep == ExportStep.proposingAssignments) {
      return _buildAssignmentProposal(l10n, theme);
    }

    if (_currentStep == ExportStep.finalCheck) {
      return _buildFinalCheck(l10n, theme);
    }

    if (_currentStep == ExportStep.success) {
      return _buildSuccessStep(l10n, theme);
    }

    final String stepTitle = _currentStep == ExportStep.selectingArchive
        ? l10n.exportSelectFile
        : l10n.exportSelectLevels;

    return Column(
      children: [
        const SizedBox(height: 16),
        Text(
          stepTitle,
          textAlign: TextAlign.center,
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        _ExportBreadcrumbBar(
          pathStack: _pathStack,
          onBreadcrumbClick: _breadcrumbTap,
        ),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              if (_pathStack.length > 1)
                _ExportFileItemRow(
                  name: l10n.returnUp,
                  isDir: true,
                  isBack: true,
                  onTap: _navigateBack,
                ),
              ..._currentPathItems.map((item) {
                final isDir = item.isDirectory;
                final fullPath = item.path;
                final fileName = item.name;

                String displayName = fileName;
                String? extension;

                if (!isDir) {
                  if (fileName.toLowerCase().endsWith('.rsb.smf')) {
                    displayName = fileName.substring(
                      0,
                      fileName.length - '.rsb.smf'.length,
                    );
                    extension = '.rsb.smf';
                  } else if (fileName.toLowerCase().endsWith('.json')) {
                    displayName = fileName.substring(
                      0,
                      fileName.length - '.json'.length,
                    );
                    extension = '.json';
                  } else if (fileName.toLowerCase().endsWith('.rton')) {
                    displayName = fileName.substring(
                      0,
                      fileName.length - '.rton'.length,
                    );
                    extension = '.rton';
                  } else if (fileName.toLowerCase().endsWith('.smf')) {
                    displayName = fileName.substring(
                      0,
                      fileName.length - '.smf'.length,
                    );
                    extension = '.smf';
                  }
                }

                final bool isSelected =
                    _currentStep == ExportStep.selectingArchive
                    ? _selectedArchivePath == fullPath
                    : _selectedLevelPaths.contains(fullPath);

                return _ExportFileItemRow(
                  name: displayName,
                  isDir: isDir,
                  isSelected: isSelected,
                  extension: extension,
                  onTap: () {
                    if (isDir) {
                      _loadDirectory(fullPath);
                    } else {
                      setState(() {
                        if (_currentStep == ExportStep.selectingArchive) {
                          if (isSelected) {
                            _selectedArchivePath = null;
                          } else {
                            _selectedArchivePath = fullPath;
                          }
                        } else {
                          if (isSelected) {
                            _selectedLevelPaths.remove(fullPath);
                          } else {
                            _selectedLevelPaths.add(fullPath);
                          }
                        }
                      });
                    }
                  },
                );
              }),
            ],
          ),
        ),
        if (_noFilesFound) ...[
          const SizedBox(height: 16),
          Text(
            l10n.exportNoFilesFound,
            style: const TextStyle(color: Colors.red),
            textAlign: TextAlign.center,
          ),
        ],
        if (_isScanning) ...[
          const SizedBox(height: 16),
          const Center(child: CircularProgressIndicator()),
        ],
        SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            child: SizedBox(
              width: double.infinity,
              child: Wrap(
                alignment: WrapAlignment.end,
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: 8,
                runSpacing: 4,
                children: [
                  if (_currentStep == ExportStep.selectingArchive &&
                      _externalDynamicDownloadAvailable)
                    TextButton.icon(
                      key: const ValueKey('exportDownloadPackageButton'),
                      onPressed: _isScanning
                          ? null
                          : () => _runExternalDynamicDownload(
                              skipInitialPrompt: true,
                            ),
                      icon: const Icon(Icons.cloud_download_outlined),
                      label: Text(l10n.exportDownloadExternalDynamic),
                    ),
                  TextButton(
                    key: const ValueKey('exportProceedButton'),
                    onPressed: _isScanning
                        ? null
                        : () {
                            if (_noFilesFound) {
                              Navigator.of(context).pop();
                            } else {
                              if (_currentStep == ExportStep.selectingArchive &&
                                  _selectedArchivePath != null) {
                                _showBackupRecommendation();
                              } else if (_currentStep ==
                                      ExportStep.selectingLevels &&
                                  _selectedLevelPaths.isNotEmpty) {
                                _validateAndFinishExport();
                              }
                            }
                          },
                    child: Text(
                      _noFilesFound ? l10n.close : l10n.proceed,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: _isScanning
                            ? null
                            : ((_currentStep == ExportStep.selectingArchive &&
                                          _selectedArchivePath != null) ||
                                      (_currentStep ==
                                              ExportStep.selectingLevels &&
                                          _selectedLevelPaths.isNotEmpty)
                                  ? Colors.green
                                  : theme.colorScheme.onSurfaceVariant),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildExportProgress(AppLocalizations l10n, ThemeData theme) {
    final green = theme.brightness == Brightness.dark
        ? pvzGreenLight
        : pvzGreenDark;
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              l10n.exportPackageProgressTitle,
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 32),
            LabeledProgressBar(value: _exportProgress),
            const SizedBox(height: 16),
            Text(_exportStatus),
            const SizedBox(height: 32),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: green,
                foregroundColor: Colors.white,
              ),
              onPressed: _handleExportCancel,
              child: Text(l10n.cancel),
            ),
          ],
        ),
      ),
    );
  }

  /// Cancels an in-flight export after confirmation. Works even while the pack
  /// is running because the heavy pipeline runs off the UI thread (a Web Worker
  /// on web, `compute` isolates on native).
  Future<void> _handleExportCancel() async {
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.cancelExportTitle),
        content: Text(l10n.cancelExportMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(l10n.back),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(
              l10n.confirm,
              style: const TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      _engine.cancelExport();
    }
  }

  Widget _buildReviewSelection(AppLocalizations l10n, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 48, 24, 24),
      child: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 800),
                  child: Column(
                    children: [
                      Text(
                        l10n.exportAssignmentProposalTitle,
                        textAlign: TextAlign.center,
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 32),
                      Text(
                        l10n.exportAssignmentProposalBody,
                        textAlign: TextAlign.left,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          height: 1.6,
                          color: theme.colorScheme.onSurface.withValues(
                            alpha: 0.8,
                          ),
                        ),
                      ),
                      const SizedBox(height: 32),
                      ..._selectedLevelPaths.map(
                        (path) => Card(
                          margin: const EdgeInsets.only(bottom: 8),
                          child: ListTile(
                            leading: const Icon(
                              Icons.description,
                              color: Colors.blue,
                            ),
                            title: Text(_exportLeafName(path)),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),
          Align(
            alignment: Alignment.bottomRight,
            child: Padding(
              padding: const EdgeInsets.only(right: 16, bottom: 16),
              child: TextButton(
                onPressed: () {
                  _initializeAssignments();
                  setState(() {
                    _currentStep = ExportStep.proposingAssignments;
                  });
                },
                child: Text(
                  l10n.exportBegin,
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: Colors.green,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAssignmentProposal(AppLocalizations l10n, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
      child: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 900),
                  child: Column(
                    children: [
                      Text(
                        l10n.exportAssignmentProposalTitle,
                        textAlign: TextAlign.center,
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 720),
                        child: Text(
                          l10n.exportDifficultyReplacementNotice,
                          textAlign: TextAlign.center,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                            height: 1.4,
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      ..._selectedLevelPaths.map((path) {
                        final assignment = _levelAssignments[path];
                        return _WorldDistributionRow(
                          fileName: _exportLeafName(path),
                          assignment: assignment,
                          onCheckDuplicate: (newAssignment) {
                            return _levelAssignments.values.any(
                              (a) =>
                                  a.world == newAssignment.world &&
                                  a.level == newAssignment.level,
                            );
                          },
                          onChanged: (newAssignment) {
                            setState(() {
                              if (newAssignment == null) {
                                _levelAssignments.remove(path);
                              } else {
                                _levelAssignments[path] = newAssignment;
                              }
                            });
                          },
                        );
                      }),
                    ],
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),
          Align(
            alignment: Alignment.bottomRight,
            child: Padding(
              padding: const EdgeInsets.only(right: 16, bottom: 16),
              child: FilledButton(
                onPressed: _finishAssignments,
                child: Text(
                  l10n.exportFinish,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _finishAssignments() async {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    // 1. Check if all levels have assignments
    if (_levelAssignments.length < _selectedLevelPaths.length) {
      AppMessage.show(context, l10n.exportAssignmentIncomplete);
      return;
    }

    // 3. Confirmation dialog
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.exportConfirmationTitle),
        content: SizedBox(
          width: 500,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(l10n.exportConfirmationBody),
              const SizedBox(height: 16),
              Flexible(
                child: SingleChildScrollView(
                  child: Column(
                    children: _selectedLevelPaths.map((path) {
                      final assignment = _levelAssignments[path]!;
                      final worldInfo = WorldRepository.findByCodename(
                        assignment.world,
                      );
                      final destination =
                          '→ ${worldInfo?.nameGetter(l10n) ?? assignment.world} ${l10n.exportLevelShort(assignment.level)}';
                      Widget buildWorldIcon() => ClipOval(
                        child: AssetImageWidget(
                          assetPath: worldInfo!.getIconPath(),
                          width: 24,
                          height: 24,
                        ),
                      );

                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: LayoutBuilder(
                          builder: (context, constraints) {
                            if (constraints.maxWidth < 420) {
                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      if (worldInfo != null) ...[
                                        buildWorldIcon(),
                                        const SizedBox(width: 8),
                                      ],
                                      Expanded(
                                        child: Text(
                                          _exportLeafName(path),
                                          style: const TextStyle(fontSize: 13),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Padding(
                                    padding: EdgeInsets.only(
                                      left: worldInfo == null ? 0 : 32,
                                    ),
                                    child: Text(
                                      destination,
                                      style: theme.textTheme.bodySmall
                                          ?.copyWith(
                                            fontWeight: FontWeight.bold,
                                          ),
                                    ),
                                  ),
                                ],
                              );
                            }

                            return Row(
                              children: [
                                if (worldInfo != null) ...[
                                  buildWorldIcon(),
                                  const SizedBox(width: 8),
                                ],
                                Expanded(
                                  child: Text(
                                    _exportLeafName(path),
                                    style: const TextStyle(fontSize: 13),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Flexible(
                                  child: Text(
                                    destination,
                                    textAlign: TextAlign.end,
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(l10n.back),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(l10n.exportProceed),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      setState(() {
        _currentStep = ExportStep.finalCheck;
      });
    }
  }

  /// The archive path shown to the user: relative to the library root and with
  /// the web `web://` scheme stripped. Falls back to the leaf file name.
  String _relativeArchiveDisplayPath() {
    final full = _selectedArchivePath;
    if (full == null || full.isEmpty) return '';
    var rel = full;
    final root = _rootPath;
    if (root != null && root.isNotEmpty && rel.startsWith(root)) {
      rel = rel.substring(root.length);
    }
    const webPrefix = 'web://';
    if (rel.startsWith(webPrefix)) rel = rel.substring(webPrefix.length);
    while (rel.startsWith('/') || rel.startsWith('\\')) {
      rel = rel.substring(1);
    }
    return rel.isEmpty ? _exportLeafName(full) : rel;
  }

  Widget _buildFinalCheck(AppLocalizations l10n, ThemeData theme) {
    final String archiveName = _selectedArchivePath != null
        ? _exportLeafName(_selectedArchivePath!)
        : '';
    final String relativeArchivePath = _relativeArchiveDisplayPath();

    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxWidth < 600;
        return Padding(
          padding: EdgeInsets.all(compact ? 16 : 24),
          child: Column(
            children: [
              Text(
                l10n.exportFinalCheckTitle,
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                l10n.exportFinalCheckBody,
                style: theme.textTheme.bodyMedium,
              ),
              const SizedBox(height: 16),
              if (_selectedArchivePath != null)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withValues(alpha: 0.9),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.inventory_2_outlined, color: Colors.white),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              l10n.exportTargetArchive(archiveName),
                              style: theme.textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            Text(
                              relativeArchivePath,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: Colors.white.withValues(alpha: 0.7),
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              const SizedBox(height: 24),
              Expanded(
                child: ListView.builder(
                  itemCount: _selectedLevelPaths.length,
                  itemBuilder: (context, index) {
                    final path = _selectedLevelPaths.elementAt(index);
                    final assignment = _levelAssignments[path]!;
                    final worldInfo = WorldRepository.findByCodename(
                      assignment.world,
                    );
                    final exportedName =
                        '${assignment.world}${assignment.level}.json';

                    final worldIcon = worldInfo != null
                        ? ClipOval(
                            child: AssetImageWidget(
                              assetPath: worldInfo.getIconPath(),
                              width: 40,
                              height: 40,
                            ),
                          )
                        : const Icon(Icons.help_outline);
                    final sourceAndTarget = Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _exportLeafName(path),
                          maxLines: compact ? 2 : 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '→ $exportedName',
                          maxLines: compact ? 2 : 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    );
                    final assignmentLabel = Text(
                      '${worldInfo?.nameGetter(l10n) ?? assignment.world} ${l10n.exportLevelShort(assignment.level)}',
                      style: theme.textTheme.bodySmall,
                      softWrap: true,
                    );

                    return Card(
                      key: ValueKey('exportFinalCheckLevelCard-$index'),
                      margin: const EdgeInsets.only(bottom: 8),
                      child: compact
                          ? Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      worldIcon,
                                      const SizedBox(width: 12),
                                      Expanded(child: sourceAndTarget),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  Padding(
                                    padding: const EdgeInsets.only(left: 52),
                                    child: assignmentLabel,
                                  ),
                                ],
                              ),
                            )
                          : ListTile(
                              leading: worldIcon,
                              title: sourceAndTarget,
                              trailing: assignmentLabel,
                            ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 24),
              Align(
                alignment: Alignment.bottomRight,
                child: SizedBox(
                  width: compact ? double.infinity : null,
                  child: FilledButton.icon(
                    onPressed: _isExporting ? null : _performExport,
                    icon: _isExporting
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Icon(Icons.file_upload),
                    label: Text(l10n.exportStart),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSuccessStep(AppLocalizations l10n, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.check_circle_outline,
              color: Colors.green,
              size: 80,
            ),
            const SizedBox(height: 24),
            Text(
              l10n.exportSuccessTitle,
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              l10n.exportSuccessMessage(_relativeArchiveDisplayPath()),
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: 48),
            SizedBox(
              width: 200,
              child: FilledButton(
                onPressed: () {
                  if (mounted) {
                    Navigator.of(context).pop();
                  }
                },
                child: Text(l10n.close),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _phaseStatus(AppLocalizations l10n, ExportPhase phase) {
    switch (phase) {
      case ExportPhase.creatingRton:
        return l10n.exportStatusCreatingRton;
      case ExportPhase.unpackingRsb:
        return l10n.exportStatusUnpackingRsb;
      case ExportPhase.unpackingRsg:
        return l10n.exportStatusUnpackingRsg;
      case ExportPhase.injecting:
        return l10n.exportStatusInjecting;
      case ExportPhase.repackingRsg:
        return l10n.exportStatusRepackingRsg;
      case ExportPhase.repackingRsb:
        return l10n.exportStatusRepackingRsb;
      case ExportPhase.finalizing:
        return l10n.exportStatusFinalizing;
    }
  }

  Future<void> _performExport() async {
    if (_selectedArchivePath == null) return;
    final l10n = AppLocalizations.of(context)!;

    // Clear stale cancellation state before anything starts: a Cancel tap
    // during the encoding stage below must not be lost (or, worse, dropped
    // by the engine when the pipeline itself begins).
    _engine.resetExportState();

    setState(() {
      _isExporting = true;
      _exportProgress = 0;
      _exportStatus = l10n.exportPackageProgressTitle;
    });

    final String archivePath = _selectedArchivePath!;

    try {
      // 1. Encode the selected levels as encrypted RTON. The heavy Rijndael
      // pass runs in a background isolate per level, so the editor stays
      // responsive and the Cancel button keeps working.
      setState(() {
        _exportProgress = 0.02;
        _exportStatus = l10n.exportStatusCreatingRton;
      });

      final Map<String, Uint8List> rtonLevels = {};
      final assignmentCount = _levelAssignments.length;
      var encodedCount = 0;

      for (final entry in _levelAssignments.entries) {
        if (_engine.isCancelledByUser) {
          throw const ExportCancelledException();
        }
        final srcPath = entry.key;
        final assignment = entry.value;
        final exportedName = '${assignment.world}${assignment.level}.rton';

        final levelFile = await LevelRepository.loadLevelFromPath(srcPath);
        if (levelFile == null) {
          throw Exception("Failed to load level: $srcPath");
        }

        final levelJson = jsonEncode(levelFile.toJson());
        final rtonBytes = await compute(exportIsolateEncodeRton, levelJson);
        rtonLevels[exportedName] = rtonBytes;

        encodedCount++;
        if (mounted) {
          setState(() {
            _exportProgress =
                0.02 + 0.13 * encodedCount / math.max(1, assignmentCount);
            _exportStatus = l10n.exportStatusCreatingRton;
          });
        }
      }

      // 2. Run the platform-specific unpack -> inject -> repack pipeline.
      await _engine.performExport(
        archivePath: archivePath,
        rtonLevels: rtonLevels,
        onProgress: (progress, phase) {
          if (!mounted) return;
          setState(() {
            _exportProgress = progress;
            _exportStatus = _phaseStatus(l10n, phase);
          });
        },
      );

      if (mounted) {
        setState(() {
          _exportProgress = 1.0;
          _isExporting = false;
          _currentStep = ExportStep.success;
        });
      }
    } on ExportCancelledException {
      if (mounted) {
        setState(() {
          _isExporting = false;
          _currentStep = ExportStep.finalCheck;
        });
        AppMessage.show(
          context,
          l10n.exportCancelled,
          icon: Icons.info_outline,
        );
      }
    } catch (e) {
      debugPrint("Export failed: $e");
      if (mounted) {
        setState(() {
          _isExporting = false;
        });
        AppMessage.show(
          context,
          "${l10n.error}: $e",
          icon: Icons.error_outline,
        );
      }
    }
  }

  Widget _buildDisclaimer(AppLocalizations l10n, ThemeData theme) {
    final content = Column(
      children: [
        Text(
          l10n.exportDisclaimerTitle,
          textAlign: TextAlign.center,
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 32),
        Text(
          l10n.exportDisclaimerBody,
          textAlign: TextAlign.left,
          style: theme.textTheme.bodyMedium?.copyWith(
            height: 1.6,
            color: theme.colorScheme.onSurface.withValues(alpha: 0.8),
          ),
        ),
        if (_noFilesFound) ...[
          const SizedBox(height: 32),
          Text(
            l10n.exportNoFilesFound,
            style: const TextStyle(
              color: Colors.red,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
        ],
        const SizedBox(height: 24),
        Align(
          alignment: Alignment.centerLeft,
          child: CheckboxListTile(
            contentPadding: EdgeInsets.zero,
            controlAffinity: ListTileControlAffinity.leading,
            value: _doNotShowDisclaimerAgain,
            onChanged: _isScanning
                ? null
                : (value) {
                    setState(() => _doNotShowDisclaimerAgain = value ?? false);
                  },
            title: Text(l10n.exportDisclaimerDoNotShowAgain),
          ),
        ),
      ],
    );

    final proceedButton = _noFilesFound && _externalDynamicDownloadAvailable
        ? Wrap(
            alignment: WrapAlignment.end,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 8,
            runSpacing: 4,
            children: [
              TextButton.icon(
                onPressed: _isScanning
                    ? null
                    : () =>
                          _runExternalDynamicDownload(skipInitialPrompt: true),
                icon: const Icon(Icons.cloud_download_outlined),
                label: Text(l10n.exportDownloadExternalDynamic),
              ),
              TextButton(
                onPressed: _isScanning
                    ? null
                    : () => Navigator.of(context).pop(),
                child: Text(
                  l10n.close,
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          )
        : TextButton(
            onPressed: _isScanning
                ? null
                : (_noFilesFound
                      ? () => Navigator.of(context).pop()
                      : _onDisclaimerProceed),
            child: _isScanning
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Text(
                    _noFilesFound ? l10n.close : l10n.proceed,
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: _noFilesFound
                          ? theme.colorScheme.onSurfaceVariant
                          : Colors.green,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
          );

    return LayoutBuilder(
      builder: (context, constraints) {
        final tight = constraints.maxHeight < 220;
        if (tight) {
          return SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1000),
                child: Column(
                  children: [
                    content,
                    const SizedBox(height: 16),
                    Align(
                      alignment: Alignment.centerRight,
                      child: proceedButton,
                    ),
                  ],
                ),
              ),
            ),
          );
        }

        return Padding(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 8),
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 1000),
                      child: content,
                    ),
                  ),
                ),
              ),
              Align(alignment: Alignment.centerRight, child: proceedButton),
            ],
          ),
        );
      },
    );
  }
}

class _WorldDistributionRow extends StatefulWidget {
  const _WorldDistributionRow({
    required this.fileName,
    required this.assignment,
    required this.onChanged,
    required this.onCheckDuplicate,
  });

  final String fileName;
  final ({String world, int level})? assignment;
  final ValueChanged<({String world, int level})?> onChanged;
  final bool Function(({String world, int level}) assignment) onCheckDuplicate;

  @override
  State<_WorldDistributionRow> createState() => _WorldDistributionRowState();
}

class _WorldDistributionRowState extends State<_WorldDistributionRow> {
  late TextEditingController _levelController;

  @override
  void initState() {
    super.initState();
    _levelController = TextEditingController(
      text: widget.assignment?.level.toString() ?? '1',
    );
  }

  @override
  void didUpdateWidget(_WorldDistributionRow oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.assignment?.level != oldWidget.assignment?.level) {
      final newText = widget.assignment?.level.toString() ?? '1';
      if (_levelController.text != newText) {
        _levelController.text = newText;
      }
    }
  }

  @override
  void dispose() {
    _levelController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final worlds = WorldRepository.allWorlds;
    final currentWorld = worlds
        .where((w) => w.codename == widget.assignment?.world)
        .firstOrNull;

    final worldIcon = KeyedSubtree(
      key: const ValueKey('exportWorldIcon'),
      child: ClipOval(
        child: Container(
          width: 48,
          height: 48,
          color: theme.colorScheme.surfaceContainerHighest,
          child: currentWorld != null
              ? AssetImageWidget(
                  assetPath: currentWorld.getIconPath(),
                  width: 48,
                  height: 48,
                )
              : const Icon(Icons.help_outline),
        ),
      ),
    );
    Widget buildWorldField(InputDecoration decoration) =>
        DropdownButtonFormField<String>(
          isExpanded: true,
          decoration: decoration,
          initialValue: widget.assignment?.world,
          items: worlds.map((w) {
            return DropdownMenuItem(
              value: w.codename,
              child: Text(w.nameGetter(l10n), overflow: TextOverflow.ellipsis),
            );
          }).toList(),
          onChanged: (val) {
            if (val != null) {
              final newAssignment = (
                world: val,
                level: widget.assignment?.level ?? 1,
              );
              if (widget.onCheckDuplicate(newAssignment)) {
                AppMessage.show(
                  context,
                  l10n.exportDuplicateAssignment(
                    WorldRepository.findByCodename(val)?.nameGetter(l10n) ??
                        val,
                    newAssignment.level,
                  ),
                );
              } else {
                widget.onChanged(newAssignment);
              }
            }
          },
        );
    final worldDecoration = editorInputDecoration(context).copyWith(
      labelText: l10n.exportWorld,
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
    );
    final narrowWorldDecoration = editorInputDecoration(context).copyWith(
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
    );
    void handleLevelChanged(String val) {
      final num = int.tryParse(val) ?? 1;
      if (currentWorld == null) return;

      final clamped = num.clamp(1, currentWorld.levelCount);
      final newAssignment = (
        world: widget.assignment?.world ?? worlds.first.codename,
        level: clamped,
      );

      if (widget.onCheckDuplicate(newAssignment)) {
        AppMessage.show(
          context,
          l10n.exportDuplicateAssignment(
            currentWorld.nameGetter(l10n),
            clamped,
          ),
        );
        _levelController.text = widget.assignment?.level.toString() ?? '1';
      } else {
        widget.onChanged(newAssignment);
      }
    }

    Widget buildLevelTextField(InputDecoration decoration) => TextFormField(
      controller: _levelController,
      decoration: decoration,
      keyboardType: TextInputType.number,
      onChanged: handleLevelChanged,
    );

    final levelDecoration = editorInputDecoration(context).copyWith(
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
    );
    final levelField = EditorResponsiveInputField(
      label: l10n.exportLevelNumber,
      decoration: levelDecoration,
      builder: (context, decoration) => buildLevelTextField(decoration),
    );
    final levelStepper = Theme(
      data: theme.copyWith(
        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_drop_up),
            padding: EdgeInsets.zero,
            visualDensity: VisualDensity.compact,
            constraints: const BoxConstraints(minWidth: 32, minHeight: 24),
            onPressed: () {
              if (currentWorld != null) {
                final currentLevel = widget.assignment?.level ?? 1;
                if (currentLevel < currentWorld.levelCount) {
                  final newAssignment = (
                    world: widget.assignment!.world,
                    level: currentLevel + 1,
                  );
                  if (widget.onCheckDuplicate(newAssignment)) {
                    AppMessage.show(
                      context,
                      l10n.exportDuplicateAssignment(
                        currentWorld.nameGetter(l10n),
                        newAssignment.level,
                      ),
                    );
                  } else {
                    widget.onChanged(newAssignment);
                  }
                }
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.arrow_drop_down),
            padding: EdgeInsets.zero,
            visualDensity: VisualDensity.compact,
            constraints: const BoxConstraints(minWidth: 32, minHeight: 24),
            onPressed: () {
              if (currentWorld != null) {
                final currentLevel = widget.assignment?.level ?? 1;
                if (currentLevel > 1) {
                  final newAssignment = (
                    world: widget.assignment!.world,
                    level: currentLevel - 1,
                  );
                  if (widget.onCheckDuplicate(newAssignment)) {
                    AppMessage.show(
                      context,
                      l10n.exportDuplicateAssignment(
                        currentWorld.nameGetter(l10n),
                        newAssignment.level,
                      ),
                    );
                  } else {
                    widget.onChanged(newAssignment);
                  }
                }
              }
            },
          ),
        ],
      ),
    );

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.fileName,
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 16),
            LayoutBuilder(
              builder: (context, constraints) {
                if (constraints.maxWidth < 520) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Center(child: worldIcon),
                      const SizedBox(height: 12),
                      Text(
                        l10n.exportWorld,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 8),
                      KeyedSubtree(
                        key: const ValueKey('exportWorldField'),
                        child: buildWorldField(narrowWorldDecoration),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        l10n.exportLevelNumber,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Expanded(
                            child: SizedBox(
                              key: const ValueKey('exportLevelNumberField'),
                              height: 56,
                              child: buildLevelTextField(levelDecoration),
                            ),
                          ),
                          const SizedBox(width: 4),
                          SizedBox(
                            key: const ValueKey('exportLevelStepper'),
                            height: 56,
                            child: levelStepper,
                          ),
                        ],
                      ),
                    ],
                  );
                }

                return Row(
                  children: [
                    worldIcon,
                    const SizedBox(width: 12),
                    Expanded(
                      child: KeyedSubtree(
                        key: const ValueKey('exportWorldField'),
                        child: buildWorldField(worldDecoration),
                      ),
                    ),
                    const SizedBox(width: 8),
                    SizedBox(
                      key: const ValueKey('exportLevelNumberField'),
                      width: 160,
                      child: levelField,
                    ),
                    const SizedBox(width: 4),
                    levelStepper,
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _ExportBreadcrumbBar extends StatelessWidget {
  const _ExportBreadcrumbBar({
    required this.pathStack,
    required this.onBreadcrumbClick,
  });

  final List<({String name, String path})> pathStack;
  final void Function(int index) onBreadcrumbClick;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 6),
      child: Row(
        children: [
          for (int i = 0; i < pathStack.length; i++) ...[
            InkWell(
              onTap: i < pathStack.length - 1
                  ? () => onBreadcrumbClick(i)
                  : null,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                decoration: BoxDecoration(
                  color: i == pathStack.length - 1
                      ? theme.colorScheme.primaryContainer
                      : theme.colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (i == 0) ...[
                      Icon(
                        Icons.folder_open,
                        size: 16,
                        color: theme.colorScheme.onPrimaryContainer,
                      ),
                      const SizedBox(width: 4),
                    ],
                    Text(
                      pathStack[i].name,
                      style: TextStyle(
                        fontWeight: i == pathStack.length - 1
                            ? FontWeight.bold
                            : FontWeight.w500,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if (i < pathStack.length - 1) ...[
              const SizedBox(width: 4),
              Icon(
                Icons.arrow_forward_ios,
                size: 12,
                color: theme.colorScheme.onSurfaceVariant,
              ),
              const SizedBox(width: 4),
            ],
          ],
        ],
      ),
    );
  }
}

class _ExportFileItemRow extends StatelessWidget {
  const _ExportFileItemRow({
    required this.name,
    required this.isDir,
    required this.onTap,
    this.isBack = false,
    this.isSelected = false,
    this.extension,
  });

  final String name;
  final bool isDir;
  final VoidCallback onTap;
  final bool isBack;
  final bool isSelected;
  final String? extension;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isResourceFile =
        !isDir &&
        (name.toLowerCase().endsWith('.smf') ||
            (extension?.toLowerCase().endsWith('.smf') ?? false));

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: isSelected ? 4 : 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: isSelected
            ? BorderSide(color: theme.colorScheme.primary, width: 2)
            : BorderSide.none,
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              SizedBox(
                width: 48,
                height: 48,
                child: Icon(
                  isBack
                      ? Icons.arrow_back
                      : (isDir
                            ? Icons.folder
                            : (isResourceFile
                                  ? Icons.inventory_2_outlined
                                  : Icons.description)),
                  size: isBack ? 30 : 36,
                  color: isBack
                      ? const Color(0xFFFFC107)
                      : (isDir
                            ? const Color(0xFFFFC107)
                            : (isResourceFile
                                  ? Colors.blueGrey
                                  : theme.colorScheme.primary)),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      name,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (extension != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        extension!,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              if (isSelected)
                Icon(Icons.check_circle, color: theme.colorScheme.primary)
              else if (isDir && !isBack)
                Icon(
                  Icons.chevron_right,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
