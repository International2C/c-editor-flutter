import 'dart:js_interop';

import 'package:web/web.dart' as web;

final _beforeUnload = ((web.Event event) {
  event.preventDefault();
  (event as web.BeforeUnloadEvent).returnValue = 'unsaved';
}).toJS;
bool _enabled = false;

void setBrowserLeaveWarning(bool enabled) {
  if (_enabled == enabled) return;
  _enabled = enabled;
  if (enabled) {
    web.window.addEventListener('beforeunload', _beforeUnload);
  } else {
    web.window.removeEventListener('beforeunload', _beforeUnload);
  }
}
