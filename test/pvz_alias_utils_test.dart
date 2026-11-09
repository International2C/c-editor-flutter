import 'package:c_editor/data/pvz_alias_utils.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('PvzAliasUtils.unsupportedCharacterIssue', () {
    test('allows existing non-whitespace alias characters', () {
      for (final alias in const ['Alias', 'Alias123', 'Alias_2', 'alias-copy']) {
        expect(
          PvzAliasUtils.unsupportedCharacterIssue(alias),
          isNull,
          reason: alias,
        );
      }
    });

    test('rejects whitespace before any trimming occurs', () {
      for (final alias in const [
        'Alias 2',
        ' Alias',
        'Alias ',
        'Alias\t2',
        'Alias\n2',
        'Alias\u30002',
        'Alias\u00852',
      ]) {
        expect(
          PvzAliasUtils.unsupportedCharacterIssue(alias),
          PvzAliasCharacterIssue.whitespace,
          reason: alias,
        );
      }
    });

    test('rejects common and supplementary Han characters', () {
      for (final alias in [
        'Alias中文',
        'Alias${String.fromCharCode(0x3400)}',
        'Alias${String.fromCharCode(0x20000)}',
        'Alias${String.fromCharCode(0x30000)}',
      ]) {
        expect(
          PvzAliasUtils.unsupportedCharacterIssue(alias),
          PvzAliasCharacterIssue.chineseCharacters,
          reason: alias,
        );
      }
    });
  });
}
