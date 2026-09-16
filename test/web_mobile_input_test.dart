import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('web index opts into a cover viewport without locking scale', () {
    final html = File('web/index.html').readAsStringSync();
    expect(html, contains('viewport-fit=cover'));
    expect(html, contains('mobile_web_input.js'));
    expect(html, isNot(contains('maximum-scale')));
    expect(html, isNot(contains('user-scalable=no')));
    expect(html, isNot(contains('touch-action: none')));
    expect(html, isNot(contains('100dvh')));
    expect(html, contains('position: fixed'));
  });

  test('mobile web input script pins the document to visualViewport', () {
    final js = File('web/mobile_web_input.js').readAsStringSync();
    expect(js, contains('visualViewport'));
    expect(js, contains('fitToVisualViewport'));
    expect(js, contains('flt-semantics-placeholder'));
    expect(js, contains('viewport-fit=cover'));
    expect(js, contains('flutter-first-frame'));
    expect(js, isNot(contains('maximum-scale')));
    expect(js, isNot(contains('user-scalable=no')));
  });
}
