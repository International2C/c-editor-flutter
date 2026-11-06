class ZombieStats {
  ZombieStats({
    this.id = '',
    this.hp = 0.0,
    this.cost = 0,
    this.weight = 0,
    this.speed = 0.0,
    this.eatDPS = 0.0,
    this.sizeType = '',
  });

  /// Read only statistics, independently of optional geometry or behavior data.
  factory ZombieStats.fromPropertySheet(String id, Map<String, dynamic> json) {
    num number(String key, {num defaultWhenAbsent = 0}) {
      if (!json.containsKey(key)) return defaultWhenAbsent;
      final value = json[key];
      return value is num && value.isFinite ? value : 0;
    }

    return ZombieStats(
      id: id,
      hp: number('Hitpoints').toDouble(),
      cost: number('WavePointCost', defaultWhenAbsent: 100).toInt(),
      weight: number('Weight', defaultWhenAbsent: 4000).toInt(),
      speed: number('Speed').toDouble(),
      eatDPS: number('EatDPS').toDouble(),
      sizeType: json['SizeType'] is String
          ? json['SizeType'] as String
          : 'unknown',
    );
  }

  String id;
  double hp;
  int cost;
  int weight;
  double speed;
  double eatDPS;
  String sizeType;
}
