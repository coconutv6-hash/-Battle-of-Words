import 'package:flutter/material.dart';

class LifeHearts extends StatelessWidget {
  const LifeHearts({super.key, required this.lives});

  final int lives;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(2, (index) {
        final filled = index < lives;
        return Icon(
          filled ? Icons.favorite : Icons.favorite_border,
          size: 28,
          shadows: filled
              ? const [
                  Shadow(
                    color: Color(0x66000000),
                    offset: Offset(0, 1),
                    blurRadius: 3,
                  ),
                ]
              : null,
          color: filled ? Colors.redAccent : Colors.white.withOpacity(0.4),
        );
      }),
    );
  }
}
