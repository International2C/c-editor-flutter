import 'package:c_editor/data/level_parser.dart';
import 'package:c_editor/data/pvz_models.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Map<String, dynamic> levelDefinitionJson() => <String, dynamic>{
    'Name': 'Original name',
    'LevelNumber': 7,
    'Description': 'Original description',
    'StageModule': 'RTID(EgyptStage@LevelModules)',
    'Loot': 'RTID(DefaultLoot@LevelModules)',
    'StartingSun': 100,
    'VictoryModule': 'RTID(VictoryOutro@LevelModules)',
    'MusicType': 'MainPath',
    'MusicSuffix': 'egypt',
    'DisablePeavine': true,
    'Modules': <String>['RTID(WaveManagerModule@CurrentLevel)'],
    'FirstIntroNarrative': 'RTID(MyFirstIntro@CurrentLevel)',
    'FirstOutroNarrative': 1000450,
    'LastIntroNarrative': 'RTID(MyLastIntro@CurrentLevel)',
    'ExtensionData': <String, dynamic>{
      'Enabled': true,
      'Values': <int>[1, 2, 3],
    },
  };

  test(
    'LevelDefinitionData preserves fields that the editor does not expose',
    () {
      final definition = LevelDefinitionData.fromJson(levelDefinitionJson());

      definition.name = 'Edited name';
      definition.musicSuffix = '';
      definition.disablePeavine = null;
      final encoded = definition.toJson();

      expect(encoded['Name'], 'Edited name');
      expect(encoded.containsKey('MusicSuffix'), isFalse);
      expect(encoded.containsKey('DisablePeavine'), isFalse);
      expect(encoded['FirstIntroNarrative'], 'RTID(MyFirstIntro@CurrentLevel)');
      expect(encoded['FirstOutroNarrative'], 1000450);
      expect(encoded['LastIntroNarrative'], 'RTID(MyLastIntro@CurrentLevel)');
      expect(encoded['ExtensionData'], <String, dynamic>{
        'Enabled': true,
        'Values': <int>[1, 2, 3],
      });
    },
  );

  test('basic info write-back keeps unexposed LevelDefinition fields', () {
    final levelFile = PvzLevelFile(
      objects: <PvzObject>[
        PvzObject(
          aliases: const <String>['LevelDefinition'],
          objClass: 'LevelDefinition',
          objData: levelDefinitionJson(),
        ),
      ],
    );
    final definition = LevelParser.parseLevel(levelFile).levelDef!;

    definition.description = 'Edited description';
    definition.startingSun = 250;
    LevelParser.syncAndWriteLevelDefinition(definition, levelFile);

    final written = levelFile.objects.single.objData as Map<String, dynamic>;
    expect(written['Description'], 'Edited description');
    expect(written['StartingSun'], 250);
    expect(written['FirstIntroNarrative'], 'RTID(MyFirstIntro@CurrentLevel)');
    expect(written['FirstOutroNarrative'], 1000450);
    expect(written['LastIntroNarrative'], 'RTID(MyLastIntro@CurrentLevel)');
    expect(written['ExtensionData'], <String, dynamic>{
      'Enabled': true,
      'Values': <int>[1, 2, 3],
    });
  });

  test('narrative values preserve strings and numbers and omit nulls', () {
    final definition = LevelDefinitionData.fromJson(<String, dynamic>{
      'FirstIntroNarrative': 4000,
      'FirstOutroNarrative': 'EGYPT_DAY_01_OUTRO',
    });

    expect(definition.firstIntroNarrative, 4000);
    expect(definition.firstOutroNarrative, 'EGYPT_DAY_01_OUTRO');
    expect(definition.extraFields, isNot(contains('FirstIntroNarrative')));
    expect(definition.extraFields, isNot(contains('FirstOutroNarrative')));

    var encoded = definition.toJson();
    expect(encoded['FirstIntroNarrative'], 4000);
    expect(encoded['FirstOutroNarrative'], 'EGYPT_DAY_01_OUTRO');

    definition.firstIntroNarrative = null;
    definition.firstOutroNarrative = null;
    encoded = definition.toJson();
    expect(encoded, isNot(contains('FirstIntroNarrative')));
    expect(encoded, isNot(contains('FirstOutroNarrative')));
  });

  test(
    'invalid narrative JSON values are discarded instead of written back',
    () {
      final definition = LevelDefinitionData.fromJson(<String, dynamic>{
        'FirstIntroNarrative': <String, dynamic>{'id': 'EGYPT_INTRO'},
        'FirstOutroNarrative': <dynamic>['EGYPT_OUTRO'],
      });

      expect(definition.firstIntroNarrative, isNull);
      expect(definition.firstOutroNarrative, isNull);
      expect(definition.extraFields, isNot(contains('FirstIntroNarrative')));
      expect(definition.extraFields, isNot(contains('FirstOutroNarrative')));
      expect(definition.toJson(), isNot(contains('FirstIntroNarrative')));
      expect(definition.toJson(), isNot(contains('FirstOutroNarrative')));

      definition.firstIntroNarrative = true;
      definition.firstOutroNarrative = 1.5;
      expect(definition.toJson(), isNot(contains('FirstIntroNarrative')));
      expect(definition.toJson(), isNot(contains('FirstOutroNarrative')));
    },
  );
}
