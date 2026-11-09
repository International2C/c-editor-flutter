import 'package:flutter/material.dart';
import 'package:c_editor/data/narrative_catalog.dart';
import 'package:c_editor/l10n/app_localizations.dart';
import 'package:c_editor/utils/narrative_text_format.dart';
import 'package:c_editor/widgets/asset_image.dart'
    show AssetImageWidget, imageAltCandidates;

class NarrativePreviewScreen extends StatelessWidget {
  const NarrativePreviewScreen({
    super.key,
    required this.catalog,
    required this.dialogue,
    this.onSelect,
  });

  final NarrativeCatalog catalog;
  final NarrativeEntry dialogue;
  final VoidCallback? onSelect;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final strings = catalog.strings;
    final theme = Theme.of(context);
    final visibleLines = dialogue.lines
        .where((line) => !NarrativeLineView.isOperationHint(line))
        .toList(growable: false);
    final displayIcon = catalog.displayIcon(dialogue);
    final preserveIconBounds = displayIcon.contains('/Mode_MemoryLane');

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          tooltip: l10n?.back ?? 'Back',
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(strings.detailsTitle),
      ),
      floatingActionButton: onSelect == null || !dialogue.selectable
          ? null
          : FloatingActionButton.extended(
              onPressed: onSelect,
              icon: const Icon(Icons.check),
              label: Text(strings.selectDialogue),
            ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
        children: [
          Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 920),
              child: Card(
                margin: EdgeInsets.zero,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      if (preserveIconBounds)
                        Padding(
                          padding: const EdgeInsets.all(3),
                          child: AssetImageWidget(
                            assetPath: displayIcon,
                            altCandidates: imageAltCandidates(displayIcon),
                            width: 66,
                            height: 66,
                            fit: BoxFit.contain,
                          ),
                        )
                      else
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: AssetImageWidget(
                            assetPath: displayIcon,
                            altCandidates: imageAltCandidates(displayIcon),
                            width: 72,
                            height: 72,
                            fit: BoxFit.cover,
                          ),
                        ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              NarrativeLineView.normalizeDisplayText(
                                dialogue.title,
                              ),
                              style: theme.textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${strings.rawId}: ${dialogue.id}',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 920),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  for (var index = 0; index < visibleLines.length; index++)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 14),
                      child: NarrativeLineView(
                        key: ValueKey('narrative-line-$index'),
                        line: visibleLines[index],
                        localeCode: catalog.localeCode,
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class NarrativeLineView extends StatelessWidget {
  const NarrativeLineView({
    super.key,
    required this.line,
    required this.localeCode,
  });

  final NarrativeLine line;
  final String localeCode;

  static bool isRightAlignedNpc(String? npc) =>
      npc == 'winnie' ||
      npc == 'winnieicon' ||
      npc == 'specialwinnie' ||
      npc == 'zbcommander';

  static String normalizeDisplayText(String text) {
    return text.replaceAll(r'\n', '\n');
  }

  static Color _readableColor(int rgb, Color background) {
    final color = HSLColor.fromColor(Color(0xFF000000 | rgb));
    final muted = color.saturation > 0.75 ? color.withSaturation(0.75) : color;
    final backgroundLuminance = background.computeLuminance();
    double contrast(Color foreground) {
      final foregroundLuminance = foreground.computeLuminance();
      return foregroundLuminance >= backgroundLuminance
          ? (foregroundLuminance + 0.05) / (backgroundLuminance + 0.05)
          : (backgroundLuminance + 0.05) / (foregroundLuminance + 0.05);
    }

    // Preserve the hue and move only as far toward light or dark as needed.
    final lighten = contrast(Colors.white) > contrast(Colors.black);
    final target = lighten ? 1.0 : 0.0;
    for (var step = 0; step < 20; step++) {
      final lightness =
          muted.lightness + (target - muted.lightness) * step / 20;
      final candidate = muted.withLightness(lightness).toColor();
      if (contrast(candidate) >= 4.5) return candidate;
    }
    return lighten ? Colors.white : Colors.black;
  }

  static Text _displayText(
    String text, {
    required TextAlign textAlign,
    required Color background,
    TextStyle? style,
  }) {
    final normalized = normalizeDisplayText(text);
    final runs = narrativeTextRuns(normalized).toList();
    if (runs.length == 1 && runs.single.text == normalized) {
      return Text(normalized, textAlign: textAlign, style: style);
    }
    return Text.rich(
      TextSpan(
        children: [
          for (final run in runs)
            TextSpan(
              text: run.text,
              style: TextStyle(
                color: run.rgb == null
                    ? null
                    : _readableColor(run.rgb!, background),
                decoration: run.strikethrough
                    ? TextDecoration.lineThrough
                    : null,
              ),
            ),
        ],
      ),
      textAlign: textAlign,
      style: style,
    );
  }

  static bool isOperationHint(NarrativeLine line) {
    final text = narrativePlainText(line.text).trimLeft().toLowerCase();
    return text.startsWith('【操作提示】') ||
        text.startsWith('[操作提示]') ||
        text.startsWith('[tutorial prompt]') ||
        text.startsWith('[обучение]');
  }

  @override
  Widget build(BuildContext context) {
    if (line.kind != NarrativeLineKind.speech) {
      return _NarrativeStageDirection(line: line);
    }

    final theme = Theme.of(context);
    final background = theme.colorScheme.surfaceContainerLow;
    final rightAligned = isRightAlignedNpc(line.npc);
    final avatar = _NarrativeNpcAvatar(npc: line.npc);
    final bubble = Expanded(
      child: Column(
        crossAxisAlignment: rightAligned
            ? CrossAxisAlignment.end
            : CrossAxisAlignment.start,
        children: [
          Text(
            _speakerWithEmotion(),
            textAlign: rightAligned ? TextAlign.right : TextAlign.left,
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 5),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: background,
              border: Border.all(
                color: theme.colorScheme.outlineVariant.withValues(alpha: 0.9),
              ),
              borderRadius: BorderRadius.circular(4),
            ),
            child: _displayText(
              line.text,
              textAlign: rightAligned ? TextAlign.right : TextAlign.left,
              background: background,
              style: theme.textTheme.bodyLarge,
            ),
          ),
        ],
      ),
    );

    return Row(
      key: ValueKey(rightAligned ? 'npc-right' : 'npc-left'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: rightAligned
          ? [bubble, const SizedBox(width: 12), avatar]
          : [avatar, const SizedBox(width: 12), bubble],
    );
  }

  String _speakerWithEmotion() {
    final speaker = line.speaker ?? '';
    final emotion = line.emotion;
    if (emotion == null || emotion.isEmpty) return speaker;
    return localeCode == 'zh' ? '$speaker（$emotion）' : '$speaker ($emotion)';
  }
}

class _NarrativeStageDirection extends StatelessWidget {
  const _NarrativeStageDirection({required this.line});

  final NarrativeLine line;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final background = theme.colorScheme.surfaceContainerHighest.withValues(
      alpha: 0.45,
    );
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(10),
      ),
      child: NarrativeLineView._displayText(
        line.text,
        textAlign: TextAlign.center,
        background: Color.alphaBlend(background, theme.scaffoldBackgroundColor),
        style: theme.textTheme.bodyMedium?.copyWith(
          color: theme.colorScheme.onSurfaceVariant,
          fontStyle: line.kind == NarrativeLineKind.stage
              ? FontStyle.italic
              : null,
        ),
      ),
    );
  }
}

class _NarrativeNpcAvatar extends StatelessWidget {
  const _NarrativeNpcAvatar({required this.npc});

  final String? npc;

  @override
  Widget build(BuildContext context) {
    final id = npc;
    final asset = id == null || id.isEmpty
        ? 'assets/images/others/unknown.webp'
        : 'assets/images/npcs/npc_$id.webp';
    return AssetImageWidget(
      key: ValueKey('npc-avatar-${id ?? 'unknown'}'),
      assetPath: asset,
      altCandidates: imageAltCandidates(asset),
      width: 72,
      height: 72,
      fit: BoxFit.contain,
    );
  }
}
