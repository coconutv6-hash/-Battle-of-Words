import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../state/game_controller.dart';
import '../state/multiplayer_controller.dart';
import '../theme/bow_brand.dart';
import 'round_screen.dart';

class WaitingRoomScreen extends StatelessWidget {
  const WaitingRoomScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<GameController>();
    final mp = context.watch<MultiplayerController>();
    final room = mp.room;
    final isOnlineRoom = room != null;
    final isSolo = !isOnlineRoom && controller.isSoloVsBot;
    final hostName = isOnlineRoom ? room.hostName : controller.host?.displayName;
    final guestName = isOnlineRoom ? room.guestName : controller.guest?.displayName;

    if (isOnlineRoom) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!context.mounted) return;
        context.read<GameController>().syncOnlineSession(mp);
      });
    }

    if (isOnlineRoom && room.isPlaying) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!context.mounted) return;
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (_) => const RoundScreen(),
          ),
        );
      });
    }

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: BowBrand.backgroundGradient,
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Pokój',
                  style: GoogleFonts.fredoka(
                    fontSize: 28,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    shadows: BowBrand.titleShadow(),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  isOnlineRoom
                      ? 'Kod pokoju: ${room.roomCode}. Host startuje mecz gdy guest dołączy.'
                      : (isSolo
                          ? 'Tryb solo: grasz przeciwko botowi. Startuj i walcz o zwycięstwo.'
                          : 'Obie osoby są gotowe? Startujecie rundę.'),
                  style: GoogleFonts.montserrat(
                    fontSize: 14,
                    color: Colors.white.withOpacity(0.88),
                  ),
                ),
                if (isOnlineRoom) ...[
                  const SizedBox(height: 10),
                  Text(
                    'Status: ${room.status}',
                    style: GoogleFonts.montserrat(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Colors.white.withOpacity(0.92),
                    ),
                  ),
                ],
                const SizedBox(height: 28),
                _playerCard(
                  name: hostName ?? '—',
                  subtitle: 'Host · zaczyna jako speaker',
                ),
                const SizedBox(height: 14),
                _playerCard(
                  name: guestName ?? 'Oczekiwanie na gracza...',
                  subtitle: isOnlineRoom
                      ? 'Gość · dołącza po kodzie pokoju'
                      : (isSolo ? 'Bot · zaczyna jako responder' : 'Gość · zaczyna jako responder'),
                ),
                const Spacer(),
                SizedBox(
                  height: 56,
                  child: FilledButton.icon(
                    style: FilledButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: const Color(0xFF1E3A8A),
                      elevation: 6,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                    ),
                    onPressed: isOnlineRoom
                        ? (mp.canStartMatch ? () => mp.startMatch() : null)
                        : (controller.ready
                            ? () {
                                controller.startMatch();
                                Navigator.of(context).pushReplacement(
                                  MaterialPageRoute(
                                    builder: (_) => const RoundScreen(),
                                  ),
                                );
                              }
                            : null),
                    icon: const Icon(Icons.play_arrow_rounded, size: 28),
                    label: Text(
                      isOnlineRoom
                          ? (mp.isHost ? 'Start meczu online' : 'Czekaj na hosta')
                          : (isSolo ? 'Start solo vs bot' : 'Start rundy'),
                      style: GoogleFonts.fredoka(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                if (isOnlineRoom)
                  SizedBox(
                    height: 46,
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.white,
                        side: const BorderSide(color: Colors.white, width: 1.8),
                      ),
                      onPressed: () {
                        mp.leaveRoom();
                        Navigator.of(context).pop();
                      },
                      child: Text(
                        'Wyjdź z pokoju',
                        style: GoogleFonts.fredoka(fontWeight: FontWeight.w700),
                      ),
                    ),
                  ),
                if (isOnlineRoom) const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _playerCard({required String name, required String subtitle}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.94),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.35)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.12),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            name,
            style: GoogleFonts.montserrat(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: const Color(0xFF1F2937),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            subtitle,
            style: GoogleFonts.montserrat(
              fontSize: 13,
              color: const Color(0xFF64748B),
            ),
          ),
        ],
      ),
    );
  }
}
