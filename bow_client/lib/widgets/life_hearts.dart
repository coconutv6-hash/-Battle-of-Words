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
          color: filled ? Colors.redAccent : Colors.grey,
        );
      }),
    );
  }
}
