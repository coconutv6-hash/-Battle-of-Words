import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../models/match_mistake.dart';
import '../models/player.dart';
import '../state/game_controller.dart';
import '../theme/bow_brand.dart';
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
    final mistakes = controller.matchMistakes;

    final byPlayer = <String, List<MatchMistake>>{};
    for (final m in mistakes) {
      byPlayer.putIfAbsent(m.playerId, () => []).add(m);
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
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Podsumowanie',
                  style: GoogleFonts.fredoka(
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    shadows: BowBrand.titleShadow(),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  winner != null
                      ? '${winner.displayName} wygrywa 🎉'
                      : 'Koniec meczu',
                  style: GoogleFonts.fredoka(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: Colors.white.withValues(alpha: 0.95),
                  ),
                ),
                const SizedBox(height: 20),
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _playerCard(host, 'Host'),
                        const SizedBox(height: 10),
                        _playerCard(guest, 'Gość'),
                        const SizedBox(height: 20),
                        Text(
                          'Błędy w meczu',
                          style: GoogleFonts.fredoka(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 10),
                        if (mistakes.isEmpty)
                          Text(
                            'Brak zapisanych błędów.',
                            style: GoogleFonts.montserrat(
                              color: Colors.white.withValues(alpha: 0.85),
                            ),
                          )
                        else ...[
                          for (final e in (byPlayer.entries.toList()
                            ..sort(
                              (a, b) => a.value.first.playerDisplayName
                                  .compareTo(b.value.first.playerDisplayName),
                            )))
                            Padding(
                              padding: const EdgeInsets.only(bottom: 14),
                              child: Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.94),
                                  borderRadius: BorderRadius.circular(18),
                                  border: Border.all(
                                    color: Colors.white.withValues(alpha: 0.4),
                                  ),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      e.value.first.playerDisplayName,
                                      style: GoogleFonts.fredoka(
                                        fontSize: 17,
                                        fontWeight: FontWeight.w800,
                                        color: const Color(0xFF1E3A8A),
                                      ),
                                    ),
                                    const SizedBox(height: 10),
                                    ...e.value.map(_mistakeLine),
                                  ],
                                ),
                              ),
                            ),
                        ],
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: FilledButton(
                        style: FilledButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: const Color(0xFF1E3A8A),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        onPressed: () {
                          controller.rematch();
                          Navigator.of(context).pushReplacement(
                            MaterialPageRoute(builder: (_) => const RoundScreen()),
                          );
                        },
                        child: Text(
                          'Rewanż',
                          style: GoogleFonts.fredoka(
                            fontWeight: FontWeight.w700,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.white,
                          side: const BorderSide(color: Colors.white, width: 2),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        onPressed: () {
                          controller.reset();
                          Navigator.of(context).pushAndRemoveUntil(
                            MaterialPageRoute(builder: (_) => const LobbyScreen()),
                            (route) => false,
                          );
                        },
                        child: Text(
                          'Nowy pokój',
                          style: GoogleFonts.fredoka(
                            fontWeight: FontWeight.w700,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _mistakeLine(MatchMistake m) {
    final detail = m.timeout
        ? '⏱ koniec czasu'
        : (m.wrongAnswer != null && m.wrongAnswer!.isNotEmpty)
            ? 'wpisano: „${m.wrongAnswer}”'
            : 'błędna odpowiedź';
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('• ', style: TextStyle(height: 1.4)),
          Expanded(
            child: Text.rich(
              TextSpan(
                style: GoogleFonts.montserrat(
                  fontSize: 14,
                  height: 1.35,
                  color: const Color(0xFF334155),
                ),
                children: [
                  TextSpan(
                    text: '${m.wordPair.pl} ',
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                  TextSpan(
                    text: '→ ${m.wordPair.en}  ',
                  ),
                  TextSpan(
                    text: '($detail)',
                    style: TextStyle(
                      color: Colors.grey.shade700,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _playerCard(PlayerState? player, String label) {
    if (player == null) return const SizedBox.shrink();
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withValues(alpha: 0.35)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$label · ${player.displayName}',
            style: GoogleFonts.fredoka(
              fontWeight: FontWeight.w800,
              fontSize: 16,
              color: const Color(0xFF1E3A8A),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Punkty: ${player.points}',
            style: GoogleFonts.montserrat(
              fontWeight: FontWeight.w600,
              color: const Color(0xFF475569),
            ),
          ),
          Text(
            'Życia: ${player.lives}',
            style: GoogleFonts.montserrat(
              color: const Color(0xFF64748B),
            ),
          ),
        ],
      ),
    );
  }
}
