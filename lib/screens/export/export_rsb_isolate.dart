import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:c_editor/data/pvz_models.dart';
import 'package:c_editor/utils/3rdParty/pyvz2/pyvz2_rton_codec.dart';
import 'package:c_editor/utils/3rdParty/sen/sen_rsb_pack.dart';
import 'package:c_editor/utils/3rdParty/sen/sen_rsb_unpack.dart';
import 'package:c_editor/utils/3rdParty/sen/sen_rsg_pack.dart';
import 'package:c_editor/utils/3rdParty/sen/sen_rsg_unpack.dart';

/// Encodes a level provided as a JSON string into encrypted RTON bytes.
/// Runs inside an isolate so the CPU-heavy Rijndael pass never freezes the
/// editor while a long list of levels is being exported.
Uint8List exportIsolateEncodeRton(String levelJson) {
  final data = PvzLevelFile.fromJson(
    jsonDecode(levelJson) as Map<String, dynamic>,
  );
  return const Pyvz2RtonCodec().encode(data, encrypt: true);
}

/// Input/output paths for RSB unpack (must be sendable for isolates).
typedef ExportRsbPaths = (String input, String output);

/// Top-level isolate workers — no Flutter / widget context.
void exportIsolateUnpackRsb(ExportRsbPaths paths) {
  Directory(paths.$2).createSync(recursive: true);
  RsbUnpack.process(paths.$1, paths.$2);
}

void exportIsolateUnpackRsg(ExportRsbPaths paths) {
  Directory(paths.$2).createSync(recursive: true);
  RsgUnpack.process(paths.$1, paths.$2);
}

void exportIsolatePackRsg(ExportRsbPaths paths) {
  RsgPack.process(paths.$1, paths.$2);
}

void exportIsolatePackRsb(ExportRsbPaths paths) {
  RsbPack.process(paths.$1, paths.$2);
}
