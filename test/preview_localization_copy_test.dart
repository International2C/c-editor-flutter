import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

Map<String, String> _messages(String path) {
  final arb = jsonDecode(File(path).readAsStringSync()) as Map<String, dynamic>;
  return {
    for (final entry in arb.entries)
      if (!entry.key.startsWith('@')) entry.key: entry.value as String,
  };
}

Set<String> _placeholders(String message) => {
  for (final match in RegExp(
    r'\{([A-Za-z][A-Za-z0-9_]*)\}',
  ).allMatches(message))
    match.group(1)!,
};

String _format(String message, Map<String, Object> arguments) {
  for (final entry in arguments.entries) {
    message = message.replaceAll('{${entry.key}}', '${entry.value}');
  }
  return message;
}

void main() {
  const pluginRoot = 'lib/bundled_plugins/preview_img_cplugin/assets/l10n';
  final zh = _messages('$pluginRoot/zh.arb');
  final en = _messages('$pluginRoot/en.arb');

  test('preview locales retain matching keys and valid placeholders', () {
    expect(zh.keys, unorderedEquals(en.keys));
    for (final key in en.keys) {
      expect(zh[key], isNotEmpty, reason: '$key in zh');
      expect(en[key], isNotEmpty, reason: '$key in en');
      expect(
        _placeholders(zh[key]!),
        unorderedEquals(_placeholders(en[key]!)),
        reason: key,
      );
      for (final locale in [zh, en]) {
        final withoutPlaceholders = locale[key]!.replaceAll(
          RegExp(r'\{[A-Za-z][A-Za-z0-9_]*\}'),
          '',
        );
        expect(withoutPlaceholders, isNot(contains('{')), reason: key);
        expect(withoutPlaceholders, isNot(contains('}')), reason: key);
      }
    }
  });

  test('preview copy preserves the module argument contracts', () {
    final contracts = <String, Set<String>>{
      for (final key in const [
        'previewGenInitialWithCount',
        'previewGenLunarVeinCount',
        'previewGenMeteorCount',
        'previewGenTunnelCount',
        'previewGenBronzeCount',
        'previewGenPowerTileCount',
        'previewGenRailcartCount',
        'previewGenRailsCount',
        'previewGenSmokeManholeCount',
        'previewGenRenaiDayCount',
        'previewGenRenaiNightCount',
        'previewGenTunnelRoadCount',
        'previewGenPipelineCount',
        'previewGenMoldCount',
        'previewGenGridItemCount',
        'previewGenMustProtect',
        'previewGenProtectPlantCount',
        'previewGenInitialZombieCount',
        'previewGenVaseCount',
        'previewGenColoredPlantVases',
        'previewGenColoredZombieVases',
        'previewGenConveyorPacketCount',
        'previewGenTypeCount',
        'previewGenSeedBankSlots',
        'previewGenSeedBankPresetCount',
        'previewGenSeedBankWhitelistCount',
        'previewGenSeedBankBlacklistCount',
        'previewGenSeedRainCount',
        'previewGenDropShipWaveCount',
      ])
        key: {'count'},
      for (final key in const [
        'previewGenTimes',
        'previewGenTunnelBrickMap',
        'previewGenPipelineDamage',
        'previewGenConveyorDelay',
        'previewGenSunInitialDelay',
        'previewGenLastStandSun',
        'previewGenLastStandPlantFood',
        'previewGenSeedRainInterval',
        'previewGenTideStart',
      ])
        key: {'n'},
      'previewGenExportOk': {'path'},
      'previewSettingsCurrentFolder': {'folder'},
      'previewGenWaveLabel': {'wave'},
      'previewGenWaveWithCount': {'wave', 'count'},
      'previewGenCell': {'x', 'y'},
      'previewGenColumnRange': {'min', 'max'},
      'previewGenMeteorTiming': {'warn', 'poll'},
      'previewGenBronzeBatch': {'time', 'count'},
      'previewGenRailcartType': {'type'},
      'previewGenRailRange': {'col', 'start', 'end'},
      'previewGenRenaiNightWave': {'wave'},
      'previewGenPipelineRange': {'sx', 'sy', 'ex', 'ey'},
      'previewGenSeedBankMethod': {'method'},
      'previewGenMeteorMining': {'n', 'power'},
      'previewGenSunCountdown': {'base', 'max'},
      'previewGenDropShipWave': {
        'wave',
        'imp',
        'lv',
        'rmin',
        'rmax',
        'cmin',
        'cmax',
      },
      'previewGenDropShipWaveTitle': {
        'wave',
        'imp',
        'rmin',
        'rmax',
        'cmin',
        'cmax',
      },
      'previewGenPiratePlankRows': {'rows'},
      'previewGenListCount': {'key', 'count'},
      'previewGenLayerLabel': {'type', 'number'},
      'previewGenWeight': {'weight'},
      'previewGenLevel': {'level'},
      'previewGenSeconds': {'n'},
      'previewGenSeeingStarsCells': {'count'},
      'previewGenSeeingStarsCycle': {'wave'},
      'previewGenSeeingStarsSettlement': {'n'},
    };
    expect(
      en.entries
          .where((entry) => _placeholders(entry.value).isNotEmpty)
          .map((entry) => entry.key),
      unorderedEquals(contracts.keys),
    );
    for (final entry in contracts.entries) {
      for (final locale in [zh, en]) {
        expect(
          _placeholders(locale[entry.key]!),
          unorderedEquals(entry.value),
          reason: entry.key,
        );
      }
    }
  });

  test('preview terminology follows the main app locales', () {
    final appZh = _messages('assets/l10n/app_zh.arb');
    final appEn = _messages('assets/l10n/app_en.arb');

    expect(zh['previewGenWaves'], '随波次生成');
    expect(zh['previewGenGridItems'], '障碍物');
    expect(en['previewGenGridItems'], 'Grid Items');
    for (final entry in const {
      'previewStickerTagCreatures': ('中立生物', 'Creatures'),
      'previewStickerTagToolPackets': ('工具卡', 'Tool packets'),
      'previewStickerTagComponents': ('场地组件', 'Components'),
    }.entries) {
      expect(zh[entry.key], entry.value.$1);
      expect(en[entry.key], entry.value.$2);
    }

    expect(
      zh['previewGenBronzeCount'],
      contains(appZh['moduleTitle_BronzeProperties']!),
    );
    expect(en['previewGenBronzeCount'], contains('Bronze Matrix'));
    expect(appEn['moduleTitle_BronzeProperties'], contains('Bronze Matrix'));
    expect(zh['previewGenLastStandPlantFood'], contains(appZh['plantFood']!));
    expect(en['previewGenLastStandPlantFood'], contains('Plant Food'));
    expect(appZh['plantVaseOption'], contains('绿罐'));
    expect(appZh['zombieVaseOption'], contains('紫罐'));
    expect(zh['previewGenColoredPlantVases'], contains('绿罐'));
    expect(zh['previewGenColoredZombieVases'], contains('紫罐'));
    expect(en['previewGenColoredPlantVases'], contains('Green'));
    expect(en['previewGenColoredZombieVases'], contains('Purple'));
    expect(appEn['plantVaseOption'], contains('Green'));
    expect(appEn['zombieVaseOption'], contains('Purple'));
    expect(zh['previewGenPowerTileCount'], contains('能量瓷砖'));
    expect(zh['previewGenVaseNoPreset'], contains('砸罐子'));
    for (final text in zh.values) {
      expect(text, isNot(contains('青铜雕像')));
      expect(text, isNot(contains('彩色僵尸罐')));
      expect(text, isNot(contains('植物养分')));
      expect(text, isNot(contains('花瓶')));
    }
  });

  test('Chinese preview quantities and ranges read naturally', () {
    expect(
      _format(zh['previewGenColumnRange']!, {'min': 1, 'max': 5}),
      '第1–5列',
    );
    expect(_format(zh['previewGenMeteorCount']!, {'count': 3}), '3个辐射陨石');
    expect(
      _format(zh['previewGenBronzeBatch']!, {'time': 30, 'count': 2}),
      '复活时间：30秒 · 2个铜人像',
    );
    expect(
      _format(zh['previewGenDropShipWave']!, {
        'wave': 2,
        'imp': 3,
        'lv': 4,
        'rmin': 1,
        'rmax': 5,
        'cmin': 6,
        'cmax': 9,
      }),
      '第2波：额外投放3只飞行小鬼（4阶）· 第1–5行，第6–9列',
    );
    for (final key in const [
      'previewGenCanvasZoom',
      'previewGenFitCanvas',
      'previewGenResizeToolbar',
      'previewGenZoomIn',
      'previewGenZoomOut',
    ]) {
      expect(zh[key], isNotEmpty);
      expect(en[key], isNotEmpty);
    }
    expect(zh['previewGenScale'], isNot(zh['previewGenCanvasZoom']));
    expect(en['previewGenScale'], isNot(en['previewGenCanvasZoom']));
  });
}
