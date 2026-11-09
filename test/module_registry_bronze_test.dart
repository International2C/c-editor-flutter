import 'package:flutter_test/flutter_test.dart';
import 'package:c_editor/data/registry/module_registry.dart';

void main() {
  group('BronzeProperties module metadata', () {
    test('is registered as single-instance (allowMultiple false)', () {
      final meta = ModuleRegistry.registry['BronzeProperties'];
      expect(meta, isNotNull);
      expect(meta!.allowMultiple, isFalse);
    });

    test('is categorized under Scene (not Special Modes)', () {
      final bronze = ModuleRegistry.registry['BronzeProperties'];
      final renai = ModuleRegistry.registry['RenaiModuleProperties'];
      expect(bronze, isNotNull);
      expect(renai, isNotNull);
      expect(bronze!.category, ModuleCategory.scene);
      expect(bronze.category, renai!.category);
    });
  });

  group('SouDaCheDamageTextModule module metadata', () {
    test('is registered as a basic CurrentLevel parameter module', () {
      final meta = ModuleRegistry.getMetadata(
        'SouDaCheDamageTextModuleProperties',
      );

      expect(meta.defaultAlias, 'SouDaCheDamageTextModule');
      expect(meta.defaultSource, 'CurrentLevel');
      expect(meta.category, ModuleCategory.base);
      expect(meta.isCore, isFalse);
      expect(meta.allowMultiple, isFalse);
      expect(meta.initialData, isEmpty);
    });

    test('appears between scoring and lawn mowers in registry order', () {
      final keys = ModuleRegistry.registry.keys.toList();

      expect(
        keys.indexOf('LevelScoringModuleProperties'),
        lessThan(keys.indexOf('SouDaCheDamageTextModuleProperties')),
      );
      expect(
        keys.indexOf('SouDaCheDamageTextModuleProperties'),
        lessThan(keys.indexOf('LawnMowerProperties')),
      );
    });
  });

  test('Escalation Spawning follows Wave Generator in module list order', () {
    final keys = ModuleRegistry.registry.keys.toList();
    final waveGeneratorIndex = keys.indexOf('WaveGeneratorProperties');
    final escalationIndex = keys.indexOf('LevelEscalationModuleProperties');

    expect(waveGeneratorIndex, greaterThanOrEqualTo(0));
    expect(escalationIndex, waveGeneratorIndex + 1);
  });
}
