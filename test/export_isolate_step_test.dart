import 'dart:io';
import 'dart:isolate';

import 'package:c_editor/screens/export/export_engine_native.dart';
import 'package:flutter_test/flutter_test.dart';

/// Regression test for the export crash "Illegal argument in isolate
/// message: object is unsendable": the pipeline step must be spawned as a
/// top-level function fed with plain sendable data, never as a closure
/// capturing engine state (Completers, isolate handles).
void main() {
  test('export isolate step accepts a sendable plain-data message', () async {
    final port = ReceivePort();
    addTearDown(port.close);
    final tmp = Directory.systemTemp.createTempSync('c_editor_step_test_');
    addTearDown(() => tmp.deleteSync(recursive: true));

    // A missing input file makes the step fail, so the entry reports the
    // error back through the reply port — which still proves that the
    // spawn itself accepted the message (spawn failures throw here).
    await Isolate.spawn(exportIsolateStepEntry, (
      port.sendPort,
      ExportIsolateStep.unpackRsb,
      '${tmp.path}${Platform.pathSeparator}missing.rsb',
      '${tmp.path}${Platform.pathSeparator}out',
    ));

    final message = await port.first;
    expect(
      message,
      isA<String>(),
      reason: 'the entry replies with the error string when the step fails',
    );
  });
}
