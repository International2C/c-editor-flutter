import 'dart:convert';
import 'dart:typed_data';

import 'package:c_editor/data/pvz_models.dart';
import 'package:c_editor/data/registry/event_registry.dart';
import 'package:c_editor/data/repository/level_repository_native.dart';
import 'package:c_editor/plugins/plugin_level_io.dart';
import 'package:c_editor/utils/3rdParty/pyvz2/pyvz2_rton_codec.dart';
import 'package:c_editor/utils/pvz2c_crypto.dart';
import 'package:flutter_test/flutter_test.dart';

const _objClass = 'BungeeWaveActionProps';
const _officialData = {
  'target': {'mX': 6, 'mY': 2},
  'zombieName': 'tutorial',
  'Level': 4,
};
const _legacyData = {
  'Target': {'mX': 6, 'mY': 2},
  'ZombieName': 'tutorial',
  'Level': 4,
};

Map<String, dynamic> _eventJson(Map<String, dynamic> data) => {
  'aliases': ['Wave1BungeeDropEvent0'],
  'objclass': _objClass,
  'objdata': data,
};

PvzLevelFile _importLevel(Map<String, dynamic> data) => PvzLevelFile.fromJson({
  'version': 1,
  'objects': [_eventJson(data)],
});

void main() {
  test('new registry event exports only the official keys and objclass', () {
    final metadata = EventRegistry.getByObjClass(_objClass)!;
    final data = metadata.initialDataFactory() as BungeeWaveActionData;
    final event = PvzObject(
      aliases: ['Wave1${metadata.defaultAlias}0'],
      objClass: metadata.defaultObjClass,
      objData: data.toJson(),
    );

    expect(
      jsonDecode(jsonEncode(event.toJson())),
      _eventJson({
        'target': {'mX': 0, 'mY': 0},
        'zombieName': 'tutorial',
        'Level': 1,
      }),
    );
  });

  for (final fixture in {
    'official': _officialData,
    'legacy': _legacyData,
  }.entries) {
    test(
      '${fixture.key} model imports all fields and exports official keys',
      () {
        final data = BungeeWaveActionData.fromJson(fixture.value);
        expect(data.target.mX, 6);
        expect(data.target.mY, 2);
        expect(data.zombieName, 'tutorial');
        expect(data.level, 4);
        expect(data.toJson(), _officialData);
        expect(
          EventRegistry.getByObjClass(_objClass)!.summaryProvider!(
            PvzObject.fromJson(_eventJson(fixture.value)),
          ),
          'C7R3',
        );
      },
    );

    test('${fixture.key} unedited level exports official JSON', () {
      final repository = LevelRepositoryNativeImpl();
      final level = _importLevel(fixture.value);
      final bytes = repository.encodeLevelBytes('bungee.json', level);
      final json = jsonDecode(utf8.decode(bytes)) as Map;
      expect(json['objects'], [_eventJson(_officialData)]);
      expect(level.objects.single.objData, fixture.value);
    });

    test('${fixture.key} plugin JSON round trip uses official keys', () {
      final json = jsonEncode({
        'version': 1,
        'objects': [_eventJson(fixture.value)],
      });
      final exported =
          jsonDecode(encodeLevelJson(decodeLevelJson(json))) as Map;
      expect(exported['objects'], [_eventJson(_officialData)]);
    });

    for (final encrypted in [false, true]) {
      test(
        '${fixture.key} RTON export (encrypted: $encrypted) uses official keys',
        () {
          const codec = Pyvz2RtonCodec();
          // A test-only key keeps this regression test independent of build secrets.
          final cipher = RijndaelC(
            Uint8List(32),
            Uint8List(PvZ2Crypto.blockSize),
          );
          final bytes = codec.encode(
            _importLevel(fixture.value),
            encrypt: encrypted,
            rijndael: cipher,
          );
          final decoded = codec.decode(
            bytes,
            decrypt: encrypted,
            rijndael: cipher,
          );
          // Inspect raw decoded data: calling toJson here would hide export regressions.
          expect(decoded.objects.single.objData, _officialData);
          expect(decoded.objects.single.objClass, _objClass);
          expect(decoded.objects.single.aliases, ['Wave1BungeeDropEvent0']);
        },
      );
    }
  }

  test('official keys win when both spellings are present', () {
    final mixed = <String, dynamic>{
      ..._officialData,
      'Target': {'mX': 1, 'mY': 0},
      'ZombieName': 'mummy',
    };
    expect(BungeeWaveActionData.fromJson(mixed).toJson(), _officialData);
    expect(
      PvzObject.fromJson(_eventJson(mixed)).toJson(),
      _eventJson(_officialData),
    );
    expect(mixed['ZombieName'], 'mummy');
  });

  test(
    'export migration preserves unknown data without changing the input',
    () {
      final source = <String, dynamic>{
        ..._legacyData,
        'Target': {'mX': 6, 'mY': 2, 'ExtraCoordinate': 9},
        'ExtraOption': {'enabled': true},
      };
      final original = jsonEncode(source);
      final object = PvzObject.fromJson(_eventJson(source));
      expect(object.toJson()['objdata'], {
        ..._officialData,
        'target': {'mX': 6, 'mY': 2, 'ExtraCoordinate': 9},
        'ExtraOption': {'enabled': true},
      });
      expect(jsonEncode(source), original);
    },
  );

  test('migration only changes Bungee fields that are present', () {
    final unrelated = PvzObject(
      objClass: 'OtherWaveActionProps',
      objData: _legacyData,
    );
    expect(unrelated.toJson()['objdata'], _legacyData);
    expect(PvzObject.fromJson(_eventJson({'Level': 3})).toJson()['objdata'], {
      'Level': 3,
    });
  });
}
