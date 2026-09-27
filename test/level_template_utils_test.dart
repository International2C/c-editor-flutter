import 'dart:io';

import 'package:c_editor/data/level_template_utils.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('template identity only depends on its numeric prefix', () {
    expect(LevelTemplateUtils.idOf('12_custom_stage_example.json'), 12);
    expect(LevelTemplateUtils.idOf('12_custom_lawn_example.json'), 12);
    expect(LevelTemplateUtils.idOf('renamed_template.json'), isNull);
  });

  test('suggested level name keeps the complete template filename', () {
    expect(
      LevelTemplateUtils.defaultLevelName('12_custom_lawn_example.json'),
      '12_custom_lawn_example',
    );
    expect(
      LevelTemplateUtils.defaultLevelName('1_blank_level.json'),
      '1_blank_level',
    );
  });

  test('normalization deduplicates renamed entries by template number', () {
    expect(
      LevelTemplateUtils.normalizeById([
        '12_custom_lawn_example.json',
        '12_custom_stage_example.json',
        '2_chooser_example.json',
      ]),
      ['12_custom_lawn_example.json', '2_chooser_example.json'],
    );
  });

  test('discovers and orders numbered templates from bundled asset paths', () {
    expect(
      LevelTemplateUtils.fromBundledAssetPaths([
        'assets/reference/template/12_any_name.json',
        'assets/reference/template/2_chooser_example.json',
        'assets/reference/template/not_numbered.json',
        'assets/reference/other/1_not_a_template.json',
      ]),
      ['2_chooser_example.json', '12_any_name.json'],
    );
  });

  test('bundled template directory contains one asset for each number', () {
    final templateDirectory = Directory('assets/reference/template');
    final assetPaths = templateDirectory.listSync().whereType<File>().map(
      (file) =>
          '${LevelTemplateUtils.templateAssetDirectory}${file.uri.pathSegments.last}',
    );
    final assetNames = LevelTemplateUtils.fromBundledAssetPaths(assetPaths);

    expect(
      assetNames.map(LevelTemplateUtils.idOf),
      orderedEquals(List.generate(12, (i) => i + 1)),
    );
    expect(assetNames.last, '12_custom_lawn_example.json');
  });
}
