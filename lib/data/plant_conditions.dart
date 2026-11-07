/// Plant special-state ids (e.g. frozen preset plants).
abstract class PlantConditions {
  PlantConditions._();

  /// Preset states offered in the initial plant editor.
  static const ids = [
    'froststage1',
    'froststage2',
    'icecubed',
    'shadowboosted',
  ];

  static String resourceKey(String id) => 'plantCondition_$id';
}
