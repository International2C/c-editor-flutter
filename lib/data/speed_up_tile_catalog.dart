/// Image identifiers used by the game's pre-placed speed-up roads.
abstract final class SpeedUpTileCatalog {
  static const left = 'IMAGE_UI_SPEEDUPTILE_SPEED_UP_TILE_LEFT';
  static const right = 'IMAGE_UI_SPEEDUPTILE_SPEED_UP_TILE_RIGHT';
  static const up = 'IMAGE_UI_SPEEDUPTILE_SPEED_UP_TILE_UP';
  static const down = 'IMAGE_UI_SPEEDUPTILE_SPEED_UP_TILE_DOWN';

  static const directions = <String>[left, right, up, down];

  /// Unknown imported identifiers are retained without substituting a direction.
  static String? assetForImage(String image) => switch (image) {
    left => 'assets/images/tunnels/speed_up_tile_left.webp',
    right => 'assets/images/tunnels/speed_up_tile_right.webp',
    up => 'assets/images/tunnels/speed_up_tile_up.webp',
    down => 'assets/images/tunnels/speed_up_tile_down.webp',
    _ => null,
  };
}
