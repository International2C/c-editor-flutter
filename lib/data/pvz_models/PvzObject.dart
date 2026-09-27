import 'package:c_editor/data/pvz_models/BungeeWaveActionData.dart';

/// One row in `PvzLevelFile.objects` (`aliases`, `objclass`, `objdata`).
class PvzObject {
  PvzObject({this.aliases, required this.objClass, required this.objData});

  List<String>? aliases;
  String objClass;
  dynamic objData;

  factory PvzObject.fromJson(Map<String, dynamic> json) {
    final aliases = json['aliases'] as List<dynamic>?;
    return PvzObject(
      aliases: aliases
          ?.map((alias) => alias.toString())
          .where((alias) => !isEditorMetadataAlias(alias))
          .toList(),
      objClass: json['objclass'] as String? ?? '',
      objData: json['objdata'],
    );
  }

  Map<String, dynamic> toJson() => {
    if (aliases != null)
      'aliases': aliases!
          .where((alias) => !isEditorMetadataAlias(alias))
          .toList(),
    'objclass': objClass,
    // Also migrate unedited imported events in every level export format.
    'objdata': objClass == 'BungeeWaveActionProps' && objData is Map
        ? BungeeWaveActionData.normalizeJson(
            Map<String, dynamic>.from(objData as Map),
          )
        : objData,
  };

  /// Legacy editor-only aliases must never enter a playable level JSON.
  static bool isEditorMetadataAlias(String alias) =>
      alias.startsWith('__c_editor_');
}
