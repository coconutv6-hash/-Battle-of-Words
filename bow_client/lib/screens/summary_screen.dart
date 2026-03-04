import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../state/game_controller.dart';
import 'lobby_screen.dart';
import 'round_screen.dart';

class SummaryScreen extends StatelessWidget {
  const SummaryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<GameController>();
    final winner = controller.winner;
    final host = controller.host;
    final guest = controller.guest;

    return Scaffold(
      appBar: AppBar(title: const Text('Podsumowanie')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 32),
            Text(
              winner != null
                  ? '${winner.displayName} wygrywa 🎉'
                  : 'Koniec meczu',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 24),
            _playerCard(host, 'Host'),
            const SizedBox(height: 12),
            _playerCard(guest, 'Gość'),
            const Spacer(),
            Row(
              children: [
                Expanded(
                  child: FilledButton(
                    onPressed: () {
                      controller.rematch();
                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute(builder: (_) => const RoundScreen()),
                      );
                    },
                    child: const Text('Rewanż'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      controller.reset();
                      Navigator.of(context).pushAndRemoveUntil(
                        MaterialPageRoute(builder: (_) => const LobbyScreen()),
                        (route) => false,
                      );
                    },
                    child: const Text('Nowy pokój'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _playerCard(player, String label) {
    if (player == null) return const SizedBox.shrink();
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('$label · ${player.displayName}', style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text('Punkty: ${player.points}'),
            Text('Życia: ${player.lives}'),
          ],
        ),
      ),
    );
  }
}
