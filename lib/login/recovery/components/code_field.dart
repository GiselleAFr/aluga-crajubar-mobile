import 'package:flutter/material.dart';

class CodeField extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode? focusNode;
  final FocusNode? nextFocusNode;
  final FocusNode? previousFocusNode;

  const CodeField({
    super.key,
    required this.controller,
    this.focusNode,
    this.nextFocusNode,
    this.previousFocusNode,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 34,
      height: 34,
      child: TextField(
        controller: controller,
        focusNode: focusNode,

        textAlign: TextAlign.center,

        keyboardType: TextInputType.number,

        maxLength: 1,

        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),

        decoration: InputDecoration(
          counterText: '',
          contentPadding: EdgeInsets.zero,

          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
          ),

          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),

        onChanged: (value) {
          if (value.isNotEmpty && nextFocusNode != null) {
            FocusScope.of(context).requestFocus(nextFocusNode);
          }

          if (value.isEmpty && previousFocusNode != null) {
            FocusScope.of(context).requestFocus(previousFocusNode);
          }
        },
      ),
    );
  }
}