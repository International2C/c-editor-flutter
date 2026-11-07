import 'package:flutter/material.dart';

const _desktopInsetPadding = EdgeInsets.symmetric(horizontal: 40, vertical: 24);
const _dialogPadding = EdgeInsets.fromLTRB(24, 20, 24, 12);
const _actionsGap = 12.0;

/// Modal dialog for editor previews. Unlike [AlertDialog], does not use
/// [IntrinsicWidth], so flex-based lawn grids lay out correctly.
Future<T?> showEditorPreviewDialog<T>({
  required BuildContext context,
  Widget? title,
  required Widget content,
  List<Widget>? actions,
}) {
  return showDialog<T>(
    context: context,
    builder: (dialogContext) {
      final size = MediaQuery.sizeOf(dialogContext);
      final isCompact = size.width < 600;
      final insetPadding = isCompact
          ? const EdgeInsets.symmetric(horizontal: 16, vertical: 16)
          : _desktopInsetPadding;
      final dialogWidth = (size.width - insetPadding.horizontal).clamp(
        280.0,
        720.0,
      );
      final hasActions = actions != null && actions.isNotEmpty;

      return Dialog(
        insetPadding: insetPadding,
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: dialogWidth),
          child: Padding(
            padding: _dialogPadding,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Flexible(
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        if (title != null) ...[
                          DefaultTextStyle(
                            style: Theme.of(
                              dialogContext,
                            ).textTheme.titleLarge!,
                            child: title,
                          ),
                          const SizedBox(height: 16),
                        ],
                        content,
                      ],
                    ),
                  ),
                ),
                if (hasActions) ...[
                  const SizedBox(height: _actionsGap),
                  OverflowBar(
                    spacing: 8,
                    alignment: MainAxisAlignment.end,
                    children: actions,
                  ),
                ],
              ],
            ),
          ),
        ),
      );
    },
  );
}
