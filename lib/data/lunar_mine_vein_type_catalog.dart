/// Lunar vein variants and the crystals they grow, in picker order.
class LunarMineVeinTypeInfo {
  const LunarMineVeinTypeInfo({
    required this.type,
    required this.iconFile,
    required this.oreType,
  });

  final String type;
  final String iconFile;
  final String oreType;

  String get iconAsset => 'assets/images/griditems/$iconFile';
  String get oreIconAsset => 'assets/images/griditems/$oreType.webp';
}

const kLunarMineVeinTypes = [
  LunarMineVeinTypeInfo(
    type: 'lunar_mine_vein',
    iconFile: 'lunar_mine_vein.webp',
    oreType: 'lunar_mine_ore',
  ),
  LunarMineVeinTypeInfo(
    type: 'lunar_mine_vein_hardened',
    iconFile: 'lunar_mine_vein_hardened.webp',
    oreType: 'lunar_mine_ore_hardened_shell',
  ),
  LunarMineVeinTypeInfo(
    type: 'lunar_mine_vein_fragile',
    iconFile: 'lunar_mine_vein_fragile.webp',
    oreType: 'lunar_mine_ore_fragile',
  ),
  LunarMineVeinTypeInfo(
    type: 'lunar_mine_vein_fragile_plantfood',
    iconFile: 'lunar_mine_vein_fragile_plantfood.webp',
    oreType: 'lunar_mine_ore_fragile_plantfood',
  ),
  LunarMineVeinTypeInfo(
    type: 'lunar_mine_vein_radiation',
    iconFile: 'lunar_mine_vein_radiation.webp',
    oreType: 'lunar_mine_ore_radiation',
  ),
];

LunarMineVeinTypeInfo? lunarMineVeinTypeInfo(String type) {
  for (final info in kLunarMineVeinTypes) {
    if (info.type == type) return info;
  }
  return null;
}

String lunarMineVeinIconAsset(String type) =>
    lunarMineVeinTypeInfo(type)?.iconAsset ??
    'assets/images/others/unknown.webp';

String lunarMineVeinOreIconAsset(String type) =>
    lunarMineVeinTypeInfo(type)?.oreIconAsset ??
    'assets/images/others/unknown.webp';
