import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../state/game_controller.dart';
import 'round_screen.dart';

class WaitingRoomScreen extends StatelessWidget {
  const WaitingRoomScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<GameController>();
    final host = controller.host;
    final guest = controller.guest;

    return Scaffold(
      appBar: AppBar(title: const Text('Pokój oczekujący')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Udostępnij kod pokoju (lokalnie symboliczny) i upewnij się, że obie osoby są gotowe.'),
            const SizedBox(height: 24),
            Card(
              child: ListTile(
                title: Text(host?.displayName ?? '—'),
                subtitle: const Text('Host · zaczyna jako speaker'),
              ),
            ),
            const SizedBox(height: 12),
            Card(
              child: ListTile(
                title: Text(guest?.displayName ?? '—'),
                subtitle: const Text('Gość · zaczyna jako responder'),
              ),
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: controller.ready
                    ? () {
                        controller.startMatch();
                        Navigator.of(context).pushReplacement(
                          MaterialPageRoute(
                            builder: (_) => const RoundScreen(),
                          ),
                        );
                      }
                    : null,
                icon: const Icon(Icons.play_arrow),
                label: const Text('Start rundy'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
