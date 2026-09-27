import 'package:c_editor/data/oak_archery_preview.dart'
    show waveGeneratorPositionLabel;
import 'package:flutter/material.dart';
import 'package:c_editor/l10n/app_localizations.dart';
import 'package:c_editor/widgets/editor_components.dart';

class WaveGeneratorPositionFields extends StatelessWidget {
  const WaveGeneratorPositionFields({
    super.key,
    required this.rows,
    required this.columns,
    required this.x,
    required this.y,
    required this.onChanged,
  });
  final int rows, columns;
  final String? x, y;
  final void Function(String? x, String? y) onChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    Widget field(bool column) {
      final raw = column ? x : y;
      final value = raw ?? '';
      final values = <String>{
        '',
        '?',
        for (var i = 0; i < (column ? columns : rows); i++) '$i',
        value,
      };
      return EditorResponsiveInputField(
        label: column
            ? l10n.waveGeneratorZombieRiseGridX
            : l10n.waveGeneratorZombieRiseGridY,
        builder: (context, decoration) => DropdownButtonFormField<String>(
          key: ValueKey(column ? 'waveRiseX' : 'waveRiseY'),
          initialValue: value,
          isExpanded: true,
          itemHeight: null,
          decoration: decoration.copyWith(
            helperText: column
                ? l10n.waveGeneratorZombieRiseGridXHint
                : l10n.waveGeneratorZombieRiseGridYHint,
            helperMaxLines: 10,
          ),
          items: [
            for (final option in values)
              DropdownMenuItem(
                value: option,
                child: Text(
                  waveGeneratorPositionLabel(l10n, option, column: column),
                ),
              ),
          ],
          onChanged: (next) {
            if (next != null) {
              final selected = next.isEmpty ? null : next;
              onChanged(column ? selected : x, column ? y : selected);
            }
          },
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [field(true), const SizedBox(height: 12), field(false)],
    );
  }
}
