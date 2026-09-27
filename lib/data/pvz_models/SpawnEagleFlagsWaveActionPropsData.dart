import 'package:c_editor/data/pvz_models/LocationData.dart';
import 'package:c_editor/data/pvz_models/PvzModel.dart';

class SpawnEagleFlagsWaveActionPropsData extends PvzModel {
  SpawnEagleFlagsWaveActionPropsData({List<EagleFlagData>? flags})
    : flags = flags ?? [];

  List<EagleFlagData> flags;
  final Map<String, dynamic> _extraData = {};

  factory SpawnEagleFlagsWaveActionPropsData.fromJson(
    Map<String, dynamic> json,
  ) {
    return SpawnEagleFlagsWaveActionPropsData(
      flags: (json['Flags'] as List? ?? [])
          .map(
            (entry) =>
                EagleFlagData.fromJson(Map<String, dynamic>.from(entry as Map)),
          )
          .toList(),
    ).._extraData.addAll(Map<String, dynamic>.from(json)..remove('Flags'));
  }

  @override
  Map<String, dynamic> toJson() => {
    ..._extraData,
    'Flags': flags.map((flag) => flag.toJson()).toList(),
  };
}

class EagleFlagData extends PvzModel {
  EagleFlagData({LocationData? location, this.type = 'roman_eagle_flag'})
    : location = location ?? LocationData();

  LocationData location;
  String type;
  final Map<String, dynamic> _extraData = {};

  factory EagleFlagData.fromJson(Map<String, dynamic> json) {
    return EagleFlagData(
        location: LocationData.fromJson(
          Map<String, dynamic>.from(json['Location'] as Map? ?? {}),
        ),
        type: json['Type'] as String? ?? 'roman_eagle_flag',
      )
      .._extraData.addAll(
        Map<String, dynamic>.from(json)
          ..remove('Location')
          ..remove('Type'),
      );
  }

  @override
  Map<String, dynamic> toJson() => {
    ..._extraData,
    'Location': location.toJson(),
    'Type': type,
  };
}
