import 'package:flutter/material.dart';

class RememberMe extends StatelessWidget {
  final bool value;
  final ValueChanged<bool?> onChanged;

  const RememberMe({
    super.key,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 30,
      child: Row(
         children: [
        SizedBox(
          width: 20,
          height: 20,
          child: Checkbox(
            value: value,
            onChanged: onChanged,
            shape: const CircleBorder(),
            activeColor: const Color(0xFFA83232),
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
        ),

        const SizedBox(width: 3),

        const Text(
          'Lembrar-me',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w800,
            color: Color(0xFFA83232),
          ),
        ),
      ],
      ),
    );
  }
}