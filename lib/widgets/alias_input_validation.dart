import 'package:c_editor/data/pvz_alias_utils.dart';
import 'package:c_editor/l10n/app_localizations.dart';

/// Returns a localized error for unsupported characters in [value].
///
/// Empty and duplicate aliases are handled by the caller because those rules
/// depend on the surrounding editor and level object.
String? aliasCharacterValidationError(
  AppLocalizations? l10n,
  String value,
) {
  return switch (PvzAliasUtils.unsupportedCharacterIssue(value)) {
    PvzAliasCharacterIssue.whitespace =>
      l10n?.aliasWhitespaceUnsupported ?? 'Alias cannot contain spaces',
    PvzAliasCharacterIssue.chineseCharacters =>
      l10n?.aliasChineseUnsupported ??
          'Alias cannot contain Chinese characters',
    null => null,
  };
}
