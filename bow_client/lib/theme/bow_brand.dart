import 'package:flutter/material.dart';

/// Visual tokens aligned with the BOW app icon: teal → blue → deep purple-blue.
abstract final class BowBrand {
  static const Color teal = Color(0xFF2EC4B6);
  static const Color skyBlue = Color(0xFF4C8CFF);
  static const Color deepBlue = Color(0xFF1E3FA8);
  static const Color nightPurple = Color(0xFF2A1F6B);

  /// Bottom (cyan/teal) → top (deep blue / purple).
  static const LinearGradient backgroundGradient = LinearGradient(
    begin: Alignment.bottomCenter,
    end: Alignment.topCenter,
    colors: [
      Color(0xFF3DD5C8),
      Color(0xFF3B82F6),
      Color(0xFF283593),
      Color(0xFF1A237E),
    ],
    stops: [0.0, 0.35, 0.72, 1.0],
  );

  /// Softer variant for round screen role tint.
  static LinearGradient roundGradient({required bool responderPhase}) {
    if (responderPhase) {
      return const LinearGradient(
        begin: Alignment.bottomLeft,
        end: Alignment.topRight,
        colors: [
          Color(0xFF5EEAD4),
          Color(0xFF2563EB),
          Color(0xFF312E81),
        ],
        stops: [0.0, 0.5, 1.0],
      );
    }
    return const LinearGradient(
      begin: Alignment.bottomLeft,
      end: Alignment.topRight,
      colors: [
        Color(0xFF67E8F9),
        Color(0xFF3B82F6),
        Color(0xFF1E3A8A),
      ],
      stops: [0.0, 0.55, 1.0],
    );
  }

  static List<BoxShadow> titleShadow({Color color = const Color(0xFF0D1B4A)}) => [
        BoxShadow(
          color: color.withOpacity(0.85),
          offset: const Offset(0, 3),
          blurRadius: 0,
        ),
        BoxShadow(
          color: color.withOpacity(0.35),
          offset: const Offset(0, 6),
          blurRadius: 12,
        ),
      ];
}
