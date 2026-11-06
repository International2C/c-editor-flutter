import 'package:c_editor/data/pvz_models/PvzModel.dart';

/// Entry in global or per-wave [AddToZombiePool].
class WaveGeneratorPoolEntryData extends PvzModel {
  WaveGeneratorPoolEntryData({
    this.type = '',
    this.cost = -1,
    this.weight = -1,
    this.overridden,
  });

  String type;
  int cost;
  int weight;
  bool? overridden;

  factory WaveGeneratorPoolEntryData.fromJson(Map<String, dynamic> json) {
    return WaveGeneratorPoolEntryData(
      type: json['Type'] as String? ?? '',
      cost: (json['Cost'] as num?)?.toInt() ?? -1,
      weight: (json['Weight'] as num?)?.toInt() ?? -1,
      overridden: json['Overridden'] as bool?,
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'Type': type,
    if (cost != -1) 'Cost': cost,
    if (weight != -1) 'Weight': weight,
    if (overridden != null) 'Overridden': overridden,
  };
}
