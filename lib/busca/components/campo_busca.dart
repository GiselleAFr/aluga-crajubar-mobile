
import 'package:flutter/material.dart';

class CampoBusca extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  const CampoBusca({
    super.key,
    required this.controller,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 42,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFFE8D2C7)),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        children: [
          const SizedBox(width: 10),
          const Icon(
            Icons.home_outlined,
            color: Color(0xFFA83232),
            size: 17,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              controller: controller,
              onChanged: onChanged,
              style: const TextStyle(fontSize: 12),
              decoration: const InputDecoration(
                hintText: 'Casas e Apartamentos',
                hintStyle: TextStyle(fontSize: 11),
                border: InputBorder.none,
                isDense: true,
              ),
            ),
          ),
          const Icon(
            Icons.keyboard_arrow_down,
            color: Color(0xFFA83232),
            size: 19,
          ),
          const SizedBox(width: 10),
        ],
      ),
    );
  }
}
