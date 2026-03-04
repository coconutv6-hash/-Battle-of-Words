import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import 'app.dart';
import 'state/game_controller.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => GameController()..loadWordBank(),
      child: const BowApp(),
    ),
  );
}
