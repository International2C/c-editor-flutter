import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Clears the focus restored to a dropdown after a pointer-opened menu closes.
/// Keyboard activation keeps its focus so traversal and the focus cue survive.
class DropdownPointerFocus extends StatefulWidget {
  const DropdownPointerFocus({super.key, required this.builder});

  final Widget Function(BuildContext context, FocusNode focusNode) builder;

  @override
  State<DropdownPointerFocus> createState() => _DropdownPointerFocusState();
}

class _DropdownPointerFocusState extends State<DropdownPointerFocus> {
  final _focusNode = FocusNode(debugLabel: 'dropdownPointerFocus');
  bool _pointerActivated = false;
  bool _clearScheduled = false;

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(_schedulePointerFocusClear);
    HardwareKeyboard.instance.addHandler(_handleKeyEvent);
  }

  @override
  void dispose() {
    _focusNode.removeListener(_schedulePointerFocusClear);
    HardwareKeyboard.instance.removeHandler(_handleKeyEvent);
    _focusNode.dispose();
    super.dispose();
  }

  bool _handleKeyEvent(KeyEvent event) {
    // Menus live in another route, and Tab may originate in another control.
    // Observe the input mode without consuming keyboard navigation anywhere.
    if (event is KeyDownEvent || event is KeyRepeatEvent) {
      _pointerActivated = false;
    }
    return false;
  }

  void _schedulePointerFocusClear() {
    if (!_pointerActivated || !_focusNode.hasPrimaryFocus || _clearScheduled) {
      return;
    }
    _clearScheduled = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _clearScheduled = false;
      if (!mounted ||
          !_pointerActivated ||
          !_focusNode.hasPrimaryFocus ||
          ModalRoute.of(context)?.isCurrent == false) {
        return;
      }
      _pointerActivated = false;
      _focusNode.unfocus(
        disposition: UnfocusDisposition.previouslyFocusedChild,
      );
    });
  }

  @override
  Widget build(BuildContext context) => Listener(
    onPointerDown: (_) {
      _pointerActivated = true;
      _schedulePointerFocusClear();
    },
    child: widget.builder(context, _focusNode),
  );
}
