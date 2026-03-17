import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AppCartInputField extends StatefulWidget {
  const AppCartInputField({
    super.key,
    required this.controller,
    required this.onChanged,
    this.style,
    this.enabled = true,
  });

  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final TextStyle? style;
  final bool enabled;

  @override
  State<AppCartInputField> createState() => _AppCartInputFieldState();
}

class _AppCartInputFieldState extends State<AppCartInputField> {
  late FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  void _onTap() {
    // Select all text when tapped
    widget.controller.selection = TextSelection(
      baseOffset: 0,
      extentOffset: widget.controller.text.length,
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _onTap,
      child: TextField(
        controller: widget.controller,
        focusNode: _focusNode,
        keyboardType: TextInputType.number,
        textAlign: TextAlign.center,
        style: widget.style,
        enabled: widget.enabled,
        decoration: const InputDecoration(
          border: InputBorder.none,
          contentPadding: EdgeInsets.only(bottom: 16),
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          errorBorder: InputBorder.none,
          disabledBorder: InputBorder.none,
        ),
        onTapOutside: (_) => FocusScope.of(context).unfocus(),
        onTap: () {
          widget.controller.selection = TextSelection(
            baseOffset: 0,
            extentOffset: widget.controller.value.text.length,
          );
        },
        onChanged: widget.onChanged,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      ),
    );
  }
}
