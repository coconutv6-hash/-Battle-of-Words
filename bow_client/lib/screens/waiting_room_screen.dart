import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../state/game_controller.dart';
import '../theme/bow_brand.dart';
import 'round_screen.dart';

class WaitingRoomScreen extends StatelessWidget {
  const WaitingRoomScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<GameController>();
    final host = controller.host;
    final guest = controller.guest;

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
                  'Obie osoby są gotowe? Startujecie rundę.',
                  style: GoogleFonts.montserrat(
                    fontSize: 14,
                    color: Colors.white.withOpacity(0.88),
                  ),
                ),
                const SizedBox(height: 28),
                _playerCard(
                  name: host?.displayName ?? '—',
                  subtitle: 'Host · zaczyna jako speaker',
                ),
                const SizedBox(height: 14),
                _playerCard(
                  name: guest?.displayName ?? '—',
                  subtitle: 'Gość · zaczyna jako responder',
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
                    icon: const Icon(Icons.play_arrow_rounded, size: 28),
                    label: Text(
                      'Start rundy',
                      style: GoogleFonts.fredoka(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
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
