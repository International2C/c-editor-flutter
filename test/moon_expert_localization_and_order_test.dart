import 'dart:convert';
import 'dart:io';

import 'package:c_editor/data/registry/module_registry.dart';
import 'package:c_editor/data/registry/object_order_registry.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('keeps Moon Expert immediately after Lawn Mowers', () {
    final moduleKeys = ModuleRegistry.getAllModules()
        .map((module) => module.objClass)
        .toList();
    final lawnMower = moduleKeys.indexOf('LawnMowerProperties');

    expect(lawnMower, isNonNegative);
    expect(moduleKeys[lawnMower + 1], 'MoonExpertProperties');
    expect(
      ObjectOrderRegistry.getPriority('MoonExpertProperties'),
      ObjectOrderRegistry.getPriority('LawnMowerProperties') + 1,
    );
  });

  test('keeps English Moon Expert copy aligned with the Chinese source', () {
    final arb =
        jsonDecode(File('assets/l10n/app_en.arb').readAsStringSync())
            as Map<String, dynamic>;

    expect(arb['moduleTitle_MoonExpertProperties'], 'Moon Expert');
    expect(
      arb['moduleDesc_MoonExpertProperties'],
      "Sets fixed plant and zombie levels (doesn't work in Creative Courtyard)",
    );
    expect(
      arb['conflictDesc_MoonExpertYard'],
      'The Moon Expert module has no effect when the Creative Courtyard '
      'module is enabled.',
    );
    expect(
      arb['moonExpertZombieLevelTooltip'],
      'When this module is enabled, all zombie levels defined in the level '
      'are overridden by the level set here.',
    );
    expect(arb['moonExpertHelpTitle'], 'Moon Expert');
    expect(
      arb['moonExpertHelpOverview'],
      allOf(
        contains('Moon BaseZ Expert Mode'),
        contains('all plants are forced to Level 1'),
        contains('Tier Definition module'),
        contains('has no effect in Creative Courtyard'),
      ),
    );
    expect(arb['moonExpertZombieLevel'], 'Zombie level (ZombieLevel)');
  });
}
