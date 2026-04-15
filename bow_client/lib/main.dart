import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'app.dart';
import 'services/online_room_service.dart';
import 'state/game_controller.dart';
import 'state/multiplayer_controller.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final roomService = await _tryInitOnlineRoomService();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => GameController()..loadWordBank(),
        ),
        ChangeNotifierProvider(
          create: (_) => MultiplayerController(roomService: roomService),
        ),
      ],
      child: const BowApp(),
    ),
  );
}

Future<OnlineRoomService?> _tryInitOnlineRoomService() async {
  const url = String.fromEnvironment('SUPABASE_URL');
  const anonKey = String.fromEnvironment('SUPABASE_ANON_KEY');
  if (url.isEmpty || anonKey.isEmpty) {
    return null;
  }

  try {
    await Supabase.initialize(
      url: url,
      anonKey: anonKey,
    );
    return OnlineRoomService();
  } catch (_) {
    return null;
  }
}
