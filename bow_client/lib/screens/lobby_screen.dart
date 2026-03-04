import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../state/game_controller.dart';
import 'waiting_room_screen.dart';

class LobbyScreen extends StatefulWidget {
  const LobbyScreen({super.key});

  @override
  State<LobbyScreen> createState() => _LobbyScreenState();
}

class _LobbyScreenState extends State<LobbyScreen> {
  final _hostController = TextEditingController(text: 'Gracz A');
  final _guestController = TextEditingController(text: 'Gracz B');
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _hostController.dispose();
    _guestController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<GameController>();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bow Lobby'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Ustaw pseudonimy i rozpocznij lokalny pojedynek.\nDocelowo w tym miejscu pojawi się tworzenie/dołączanie do pokoju online.',
              ),
              const SizedBox(height: 24),
              TextFormField(
                controller: _hostController,
                decoration: const InputDecoration(labelText: 'Host / Gracz A'),
                validator: _required,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _guestController,
                decoration: const InputDecoration(labelText: 'Gość / Gracz B'),
                validator: _required,
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: controller.ready && controller.currentRound != null
                      ? null
                      : () {
                          final valid = _formKey.currentState?.validate() ?? false;
                          if (!valid) return;
                          controller.setupPlayers(
                            hostName: _hostController.text.trim(),
                            guestName: _guestController.text.trim(),
                          );
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => const WaitingRoomScreen(),
                            ),
                          );
                        },
                  child: const Text('Stwórz lokalny pojedynek'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String? _required(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Wpisz nazwę';
    }
    return null;
  }
}
