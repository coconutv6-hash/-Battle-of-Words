import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'screens/lobby_screen.dart';

class BowApp extends StatelessWidget {
  const BowApp({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = ThemeData(
      colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF4C6FFF)),
      textTheme: GoogleFonts.fredokaTextTheme().apply(
            displayColor: const Color(0xFF1F1F1F),
            bodyColor: const Color(0xFF1F1F1F),
          ),
      useMaterial3: true,
    );

    return MaterialApp(
      title: 'Bow',
      debugShowCheckedModeBanner: false,
      theme: theme,
      home: const LobbyScreen(),
    );
  }
}
