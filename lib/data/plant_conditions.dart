/// Plant special-state ids (e.g. frozen preset plants).
abstract class PlantConditions {
  PlantConditions._();

  /// Conditions supported on legacy preset plants.
  static const ids = [
    'icecubed',
    'chill',
    'shadowboosted',
    'shroomboosted',
  ];

  static String resourceKey(String id) => 'plantCondition_$id';
}
