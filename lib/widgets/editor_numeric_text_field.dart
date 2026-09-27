import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Keeps the editing session alive while the parent saves each valid number.
/// In-progress text (for example `1.` or an empty field) is retained; changes
/// from another entry or a preset still refresh the displayed value.
class EditorNumericTextField extends StatefulWidget {
  const EditorNumericTextField({
    super.key,
    required this.value,
    required this.onChanged,
    required this.decoration,
    this.keyboardType = TextInputType.number,
    this.inputFormatters,
    this.style,
  });

  final num value;
  final ValueChanged<String> onChanged;
  final InputDecoration decoration;
  final TextInputType keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final TextStyle? style;

  @override
  State<EditorNumericTextField> createState() => _EditorNumericTextFieldState();
}

class _EditorNumericTextFieldState extends State<EditorNumericTextField> {
  late final TextEditingController _controller;

  String get _formattedValue =>
      widget.value.isFinite && widget.value == widget.value.roundToDouble()
      ? widget.value.toInt().toString()
      : widget.value.toString();

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: _formattedValue);
  }

  @override
  void didUpdateWidget(covariant EditorNumericTextField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.value != oldWidget.value &&
        num.tryParse(_controller.text) != widget.value) {
      final text = _formattedValue;
      _controller.value = TextEditingValue(
        text: text,
        selection: TextSelection.collapsed(offset: text.length),
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => TextFormField(
    controller: _controller,
    decoration: widget.decoration,
    keyboardType: widget.keyboardType,
    inputFormatters: widget.inputFormatters,
    style: widget.style,
    onChanged: widget.onChanged,
  );
}
