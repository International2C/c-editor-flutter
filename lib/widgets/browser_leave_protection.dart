import 'package:flutter/material.dart';

import '../utils/browser_leave_guard_stub.dart'
    if (dart.library.js_interop) '../utils/browser_leave_guard_web.dart'
    as platform;

/// Keep independent editors/routes from disabling one another's warning.
class BrowserLeaveProtection {
  BrowserLeaveProtection({void Function(bool)? onChanged})
    : _onChanged = onChanged ?? platform.setBrowserLeaveWarning;

  static final instance = BrowserLeaveProtection();
  final void Function(bool) _onChanged;
  final Set<Object> _owners = {};

  void setActive(Object owner, bool active) {
    final wasActive = _owners.isNotEmpty;
    if (active) {
      _owners.add(owner);
    } else {
      _owners.remove(owner);
    }
    if (wasActive != _owners.isNotEmpty) _onChanged(_owners.isNotEmpty);
  }
}

/// Also covers plugin editors and transfers launched above the home route.
/// Conservatively warns for open dialogs, whose unsaved state is not exposed.
class BrowserLeaveProtectionObserver extends NavigatorObserver {
  BrowserLeaveProtectionObserver({BrowserLeaveProtection? protection})
    : _protection = protection ?? BrowserLeaveProtection.instance;

  final BrowserLeaveProtection _protection;
  final Set<Route<dynamic>> _routes = {};

  void _sync() => _protection.setActive(this, _routes.length > 1);

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    _routes.add(route);
    _sync();
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    _routes.remove(route);
    _sync();
  }

  @override
  void didRemove(Route<dynamic> route, Route<dynamic>? previousRoute) {
    _routes.remove(route);
    _sync();
  }

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    _routes.remove(oldRoute);
    if (newRoute != null) _routes.add(newRoute);
    _sync();
  }

  void dispose() {
    _routes.clear();
    _protection.setActive(this, false);
  }
}
