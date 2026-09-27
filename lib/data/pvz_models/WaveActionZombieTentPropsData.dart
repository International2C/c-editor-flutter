import 'package:c_editor/data/pvz_models/PvzModel.dart';
import 'package:c_editor/data/pvz_models/ZombieTentData.dart';

/// Wave action that places zombie tents and configures their spawn pools.
class WaveActionZombieTentPropsData extends PvzModel {
  WaveActionZombieTentPropsData({this.zombieTents = const []});

  List<ZombieTentData> zombieTents;

  factory WaveActionZombieTentPropsData.fromJson(Map<String, dynamic> json) {
    final raw = json['ZombieTents'] as List<dynamic>? ?? const [];
    return WaveActionZombieTentPropsData(
      zombieTents: raw
          .whereType<Map>()
          .map(
            (e) => ZombieTentData.fromJson(Map<String, dynamic>.from(e)),
          )
          .toList(),
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'ZombieTents': zombieTents.map((e) => e.toJson()).toList(),
  };
}
