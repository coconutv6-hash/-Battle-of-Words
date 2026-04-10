import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../state/game_controller.dart';
import '../theme/bow_brand.dart';
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

  InputDecoration _fieldDecoration(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: GoogleFonts.montserrat(color: const Color(0xFF1E3A5F)),
      floatingLabelStyle: GoogleFonts.montserrat(
        fontWeight: FontWeight.w600,
        color: const Color(0xFF1E3A5F),
      ),
      filled: true,
      fillColor: Colors.white.withOpacity(0.94),
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(20),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(20),
        borderSide: BorderSide(color: Colors.white.withOpacity(0.35)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(20),
        borderSide: const BorderSide(color: Color(0xFF3B82F6), width: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<GameController>();

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: BowBrand.backgroundGradient,
        ),
        child: Stack(
          children: [
            Positioned(
              right: -40,
              top: 80,
              child: IgnorePointer(
                child: Container(
                  width: 220,
                  height: 220,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withOpacity(0.06),
                  ),
                ),
              ),
            ),
            Positioned(
              left: -30,
              bottom: 120,
              child: IgnorePointer(
                child: Container(
                  width: 180,
                  height: 180,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: BowBrand.teal.withOpacity(0.12),
                  ),
                ),
              ),
            ),
            SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(height: 12),
                      Text(
                        'BOW',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.fredoka(
                          fontSize: 52,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 2,
                          color: Colors.white,
                          height: 1,
                          shadows: BowBrand.titleShadow(),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Battle of Words',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.fredoka(
                          fontSize: 22,
                          fontWeight: FontWeight.w600,
                          color: Colors.white.withOpacity(0.92),
                          shadows: [
                            Shadow(
                              color: const Color(0xFF0D1B4A).withOpacity(0.65),
                              offset: const Offset(0, 2),
                              blurRadius: 6,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 28),
                      Text(
                        'Ustaw pseudonimy i zagraj lokalnie na jednym urządzeniu.\n'
                        'Wkrótce: pokoje online.',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.montserrat(
                          fontSize: 14,
                          height: 1.45,
                          color: Colors.white.withOpacity(0.88),
                        ),
                      ),
                      const SizedBox(height: 32),
                      TextFormField(
                        controller: _hostController,
                        style: GoogleFonts.montserrat(
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF1F2937),
                        ),
                        decoration: _fieldDecoration('Host / Gracz A'),
                        validator: _required,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _guestController,
                        style: GoogleFonts.montserrat(
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF1F2937),
                        ),
                        decoration: _fieldDecoration('Gość / Gracz B'),
                        validator: _required,
                      ),
                      const SizedBox(height: 36),
                      SizedBox(
                        height: 56,
                        child: FilledButton(
                          style: FilledButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: const Color(0xFF1E3A8A),
                            elevation: 6,
                            shadowColor: Colors.black26,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(18),
                            ),
                          ),
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
                          child: Text(
                            'Stwórz lokalny pojedynek',
                            style: GoogleFonts.fredoka(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
            ),
          ],
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
