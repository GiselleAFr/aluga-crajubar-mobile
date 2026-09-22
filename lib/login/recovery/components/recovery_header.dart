import 'package:flutter/material.dart';

class RecoveryHeader extends StatelessWidget {
  final VoidCallback onBack;

  const RecoveryHeader({
    super.key,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 45,
      child: Row(
        children: [
          IconButton(
            onPressed: onBack,
            icon: const Icon(
              Icons.arrow_back_ios_new,
              size: 14,
            ),
          ),

          Expanded(
            child: Center(
              child: Transform.translate(
                offset: const Offset(-20, 0),
                child: const Text(
                  'Segurança e Login',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}