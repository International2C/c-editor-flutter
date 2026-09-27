import 'dart:io';

import 'package:c_editor/data/repository/web/web_import_filter.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('webPickExtensionFilter', () {
    test('normalises case, surrounding dots and whitespace', () {
      expect(
        webPickExtensionFilter(['.JSON', ' hujson ', 'Rton', '..bmp']),
        {'json', 'hujson', 'rton', 'bmp'},
      );
    });

    test('returns null (accept everything) for an empty list', () {
      expect(webPickExtensionFilter(const []), isNull);
      expect(webPickExtensionFilter(const ['', '  ', '.']), isNull);
    });
  });

  group('webPickExtensionOf', () {
    test('reads the extension of a plain file name', () {
      expect(webPickExtensionOf('level.json'), 'json');
      expect(webPickExtensionOf('level.JSON'), 'json');
    });

    test('ignores directories when looking for the extension', () {
      expect(webPickExtensionOf('some.dir/level.rton'), 'rton');
    });

    test('returns empty for names with no usable extension', () {
      expect(webPickExtensionOf('README'), '');
      expect(webPickExtensionOf('.gitignore'), '');
      expect(webPickExtensionOf('trailing.'), '');
      expect(webPickExtensionOf(''), '');
    });
  });

  group('webPickMatchesFilter', () {
    final filter = webPickExtensionFilter(['json', 'hujson', 'rton', 'smf']);

    test('accepts a listed level file', () {
      expect(webPickMatchesFilter('level.hujson', filter), isTrue);
    });

    test('rejects a file the accept hint should have hidden', () {
      // Android's chooser ignores `accept` often enough that a rejected pick
      // must be a *reported* miss, never a silent import of nothing.
      expect(webPickMatchesFilter('notes.docx', filter), isFalse);
      expect(webPickMatchesFilter('archive.zip', filter), isFalse);
    });

    test('a null filter accepts everything', () {
      expect(webPickMatchesFilter('anything.at.all', null), isTrue);
    });
  });

  group('web file picker', () {
    // The Android failure that motivated the hand-rolled picker: the chooser
    // runs as a separate activity, so an input detached in the same task as
    // click() loses the selection, and a window-focus cancel heuristic races
    // the change event. Guard both in source.
    final source = File(
      'lib/data/repository/web/web_file_picker.dart',
    ).readAsStringSync();

    test('does not detach the input before the selection settles', () {
      // The only removal must be inside settle(), which runs from the change /
      // cancel handlers - never on the click() code path.
      expect('input.remove()'.allMatches(source), hasLength(1));
      expect(
        RegExp(r'input\.click\(\);\s*input\.remove\(\)').hasMatch(source),
        isFalse,
      );
    });

    test('does not infer cancellation from window focus', () {
      expect(source, isNot(contains('window.addEventListener')));
      expect(source, isNot(contains('cancelledEventListener')));
    });

    test('cancels on the input cancel event and filters the accept hint', () {
      expect(source, contains("addEventListener('cancel'"));
      expect(source, contains("addEventListener('change'"));
      expect(source, contains('webPickMatchesFilter'));
      expect(source, contains('input.accept ='));
    });
  });
}
