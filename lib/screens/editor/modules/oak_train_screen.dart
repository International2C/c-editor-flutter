import 'package:c_editor/widgets/oak_train_warnings.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:c_editor/data/pvz_models.dart';
import 'package:c_editor/l10n/app_localizations.dart';
import 'package:c_editor/widgets/editor_components.dart'
    show EditorResponsiveInputField, HelpSectionData, showEditorHelpDialog;
import 'package:c_editor/widgets/editor_object_alias.dart';

class OakTrainScreen extends StatefulWidget {
  const OakTrainScreen({
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
  State<OakTrainScreen> createState() => _OakTrainScreenState();
}

class _OakTrainScreenState extends State<OakTrainScreen> {
  static const _objClass = 'OakTrainProperties';

  late PvzObject _moduleObj;
  late OakTrainPropertiesData _data;
  late String _alias;

  late TextEditingController _totalLifeCtrl;
  late TextEditingController _arrowScoreCtrl;
  late TextEditingController _wizardScoreCtrl;
  late TextEditingController _archmageScoreCtrl;
  late TextEditingController _bossScoreCtrl;
  late TextEditingController _healNumCtrl;
  late TextEditingController _arrowPowerNumCtrl;
  late TextEditingController _arrowMultipleNumCtrl;
  late TextEditingController _initNormalCtrl;
  late TextEditingController _initPowerCtrl;
  late TextEditingController _initSplitCtrl;

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
        objData: OakTrainPropertiesData().toJson(),
      );
      widget.levelFile.objects.add(_moduleObj);
    }
    try {
      _data = OakTrainPropertiesData.fromJson(
        Map<String, dynamic>.from(_moduleObj.objData as Map),
      );
    } catch (_) {
      _data = OakTrainPropertiesData();
    }
    _totalLifeCtrl = TextEditingController(text: _data.totalLife.toString());
    _arrowScoreCtrl = TextEditingController(text: _data.arrowScore.toString());
    _wizardScoreCtrl = TextEditingController(
      text: _data.wizardScore.toString(),
    );
    _archmageScoreCtrl = TextEditingController(
      text: _data.archmageScore.toString(),
    );
    _bossScoreCtrl = TextEditingController(text: _data.bossScore.toString());
    _healNumCtrl = TextEditingController(text: _data.healNum.toString());
    _arrowPowerNumCtrl = TextEditingController(
      text: _data.arrowPowerNum.toString(),
    );
    _arrowMultipleNumCtrl = TextEditingController(
      text: _data.arrowMultipleNum.toString(),
    );
    final arrows = _data.initArrowsNum;
    _initNormalCtrl = TextEditingController(
      text: arrows.isNotEmpty ? arrows[0].toString() : '0',
    );
    _initPowerCtrl = TextEditingController(
      text: arrows.length > 1 ? arrows[1].toString() : '0',
    );
    _initSplitCtrl = TextEditingController(
      text: arrows.length > 2 ? arrows[2].toString() : '0',
    );
  }

  void _sync() {
    _moduleObj.objData = {
      if (_moduleObj.objData is Map)
        ...Map<String, dynamic>.from(_moduleObj.objData as Map),
      ..._data.toJson(),
    };
    widget.onChanged();
    setState(() {});
  }

  void _syncInitArrows() {
    final n = int.tryParse(_initNormalCtrl.text) ?? 0;
    final p = int.tryParse(_initPowerCtrl.text) ?? 0;
    final s = int.tryParse(_initSplitCtrl.text) ?? 0;
    _data.initArrowsNum = [n, p, s, ..._data.initArrowsNum.skip(3)];
    _sync();
  }

  @override
  void dispose() {
    _totalLifeCtrl.dispose();
    _arrowScoreCtrl.dispose();
    _wizardScoreCtrl.dispose();
    _archmageScoreCtrl.dispose();
    _bossScoreCtrl.dispose();
    _healNumCtrl.dispose();
    _arrowPowerNumCtrl.dispose();
    _arrowMultipleNumCtrl.dispose();
    _initNormalCtrl.dispose();
    _initPowerCtrl.dispose();
    _initSplitCtrl.dispose();
    super.dispose();
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
    final l10n = AppLocalizations.of(context)!;
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
              title: l10n.moduleTitle_OakTrainProperties,
              sections: [
                HelpSectionData(
                  title: l10n.overview,
                  body: l10n.moduleHelpOakTrainOverviewBody,
                ),
                HelpSectionData(
                  title: l10n.oakTrainHelpArrowsTitle,
                  body: l10n.moduleHelpOakTrainArrowsBody,
                ),
                HelpSectionData(
                  title: l10n.oakTrainHelpScoresTitle,
                  body: l10n.moduleHelpOakTrainScoresBody,
                ),
                HelpSectionData(
                  title: l10n.oakTrainHelpZombiesTitle,
                  body: l10n.moduleHelpOakTrainZombiesBody,
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
            OakTrainWarnings(levelFile: widget.levelFile),
            _buildSection(context, l10n.oakTrainHealthTitle, [
              _buildIntFieldWithIcon(
                'assets/images/plants/icon_oakshooter.webp',
                l10n.oakTrainTotalLife,
                _totalLifeCtrl,
                (v) {
                  final n = int.tryParse(v);
                  if (n != null && n >= 0) {
                    _data.totalLife = n;
                    _sync();
                  }
                },
              ),
              _buildIntFieldWithIcon(
                'assets/images/zombies/zombie_target_bottle.webp',
                l10n.oakTrainHealNum,
                _healNumCtrl,
                (v) {
                  final n = int.tryParse(v);
                  if (n != null && n >= 0) {
                    _data.healNum = n;
                    _sync();
                  }
                },
              ),
            ]),
            const SizedBox(height: 12),
            _buildSection(context, l10n.oakTrainScoresTitle, [
              _buildIntFieldWithIcon(
                'assets/images/others/oaktrain_normal.webp',
                l10n.oakTrainArrowScore,
                _arrowScoreCtrl,
                (v) {
                  final n = int.tryParse(v);
                  if (n != null) {
                    _data.arrowScore = n;
                    _sync();
                  }
                },
              ),
              _buildIntFieldWithIcon(
                'assets/images/zombies/zombie_dark_wizard.webp',
                l10n.oakTrainWizardScore,
                _wizardScoreCtrl,
                (v) {
                  final n = int.tryParse(v);
                  if (n != null) {
                    _data.wizardScore = n;
                    _sync();
                  }
                },
              ),
              _buildIntFieldWithIcon(
                'assets/images/zombies/zombie_dark_archmage.webp',
                l10n.oakTrainArchmageScore,
                _archmageScoreCtrl,
                (v) {
                  final n = int.tryParse(v);
                  if (n != null) {
                    _data.archmageScore = n;
                    _sync();
                  }
                },
              ),
              _buildIntFieldWithIcon(
                'assets/images/zombies/zombie_dark_gargantuar.webp',
                l10n.oakTrainBossScore,
                _bossScoreCtrl,
                (v) {
                  final n = int.tryParse(v);
                  if (n != null) {
                    _data.bossScore = n;
                    _sync();
                  }
                },
              ),
            ]),
            const SizedBox(height: 12),
            _buildSection(context, l10n.oakTrainArrowsTitle, [
              _buildIntFieldWithIcon(
                'assets/images/zombies/zombie_target_arrow_blue.webp',
                l10n.oakTrainArrowPowerNum,
                _arrowPowerNumCtrl,
                (v) {
                  final n = int.tryParse(v);
                  if (n != null && n >= 0) {
                    _data.arrowPowerNum = n;
                    _sync();
                  }
                },
              ),
              _buildIntFieldWithIcon(
                'assets/images/zombies/zombie_target_arrow_yellow.webp',
                l10n.oakTrainArrowMultipleNum,
                _arrowMultipleNumCtrl,
                (v) {
                  final n = int.tryParse(v);
                  if (n != null && n >= 0) {
                    _data.arrowMultipleNum = n;
                    _sync();
                  }
                },
              ),
            ]),
            const SizedBox(height: 12),
            _buildSection(context, l10n.oakTrainInitArrowsNum, [
              _buildIntFieldWithIcon(
                'assets/images/others/oaktrain_normal.webp',
                l10n.oakTrainInitArrowNormal,
                _initNormalCtrl,
                (v) {
                  final n = int.tryParse(v);
                  if (n != null && n >= 0) {
                    _syncInitArrows();
                  }
                },
              ),
              _buildIntFieldWithIcon(
                'assets/images/others/oaktrain_power.webp',
                l10n.oakTrainInitArrowPower,
                _initPowerCtrl,
                (v) {
                  final n = int.tryParse(v);
                  if (n != null && n >= 0) {
                    _syncInitArrows();
                  }
                },
              ),
              _buildIntFieldWithIcon(
                'assets/images/others/oaktrain_triple.webp',
                l10n.oakTrainInitArrowSplit,
                _initSplitCtrl,
                (v) {
                  final n = int.tryParse(v);
                  if (n != null && n >= 0) {
                    _syncInitArrows();
                  }
                },
              ),
            ]),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(
    BuildContext context,
    String title,
    List<Widget> children,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildIntFieldWithIcon(
    String iconPath,
    String label,
    TextEditingController ctrl,
    ValueChanged<String> onChanged,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ClipOval(
              child: Image.asset(
                iconPath,
                width: 32,
                height: 32,
                fit: BoxFit.cover,
              ),
            ),
          ),
          Expanded(
            child: EditorResponsiveInputField(
              label: label,
              builder: (context, decoration) => TextField(
                controller: ctrl,
                keyboardType: TextInputType.number,
                decoration: decoration,
                onChanged: onChanged,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
