import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../state/game_controller.dart';
import '../state/multiplayer_controller.dart';
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
  final _soloController = TextEditingController(text: 'Gracz');
  final _onlineHostController = TextEditingController(text: 'Host');
  final _joinNameController = TextEditingController(text: 'Guest');
  final _joinCodeController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final _onlineFormKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _hostController.dispose();
    _guestController.dispose();
    _soloController.dispose();
    _onlineHostController.dispose();
    _joinNameController.dispose();
    _joinCodeController.dispose();
    super.dispose();
  }

  InputDecoration _fieldDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: GoogleFonts.montserrat(
        color: const Color(0xFF94A3B8),
        fontWeight: FontWeight.w500,
      ),
      filled: true,
      fillColor: Colors.white.withValues(alpha: 0.94),
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(20),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(20),
        borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.35)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(20),
        borderSide: const BorderSide(color: Color(0xFF3B82F6), width: 2),
      ),
    );
  }

  Widget _nameFieldRow({
    required String title,
    required String subtitle,
    required TextEditingController controller,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          title,
          style: GoogleFonts.fredoka(
            fontSize: 17,
            fontWeight: FontWeight.w700,
            color: Colors.white,
            shadows: const [
              Shadow(
                color: Color(0x80000000),
                offset: Offset(0, 1),
                blurRadius: 4,
              ),
            ],
          ),
        ),
        const SizedBox(height: 4),
        Text(
          subtitle,
          style: GoogleFonts.montserrat(
            fontSize: 13,
            height: 1.3,
            color: Colors.white.withValues(alpha: 0.88),
          ),
        ),
        const SizedBox(height: 10),
        TextFormField(
          controller: controller,
          style: GoogleFonts.montserrat(
            fontWeight: FontWeight.w600,
            color: const Color(0xFF1F2937),
          ),
          decoration: _fieldDecoration('Wpisz pseudonim'),
          validator: _required,
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<GameController>();
    final mp = context.watch<MultiplayerController>();

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
                        'Lub stwórz pokój online i zaproś znajomego kodem.',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.montserrat(
                          fontSize: 14,
                          height: 1.45,
                          color: Colors.white.withOpacity(0.88),
                        ),
                      ),
                      const SizedBox(height: 24),
                      _onlineRoomCard(mp),
                      const SizedBox(height: 24),
                      _soloCard(controller),
                      const SizedBox(height: 32),
                      _nameFieldRow(
                        title: 'Gracz A (host)',
                        subtitle: 'Zaczyna jako mówiący — pierwsza tura.',
                        controller: _hostController,
                      ),
                      const SizedBox(height: 22),
                      _nameFieldRow(
                        title: 'Gracz B (gość)',
                        subtitle: 'Zaczyna jako odpowiadający.',
                        controller: _guestController,
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
                                  mp.leaveRoom();
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

  Widget _soloCard(GameController controller) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.94),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.35)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Solo vs Bot',
            style: GoogleFonts.fredoka(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF1E3A8A),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Ćwiczysz sam: grasz przeciwko botowi i walczysz o przetrwanie.',
            style: GoogleFonts.montserrat(
              fontSize: 12.5,
              color: const Color(0xFF475569),
            ),
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _soloController,
            decoration: _fieldDecoration('Twój nick'),
            validator: _required,
          ),
          const SizedBox(height: 10),
          SizedBox(
            height: 48,
            child: FilledButton(
              onPressed: () {
                final nick = _soloController.text.trim();
                if (nick.isEmpty) return;
                context.read<MultiplayerController>().leaveRoom();
                controller.setupSoloVsBot(playerName: nick);
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const WaitingRoomScreen()),
                );
              },
              child: Text(
                'Zagraj solo',
                style: GoogleFonts.fredoka(fontWeight: FontWeight.w700),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _onlineRoomCard(MultiplayerController mp) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.94),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.35)),
      ),
      child: Form(
        key: _onlineFormKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Online multiplayer (MVP)',
              style: GoogleFonts.fredoka(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF1E3A8A),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              mp.isAvailable
                  ? 'Host tworzy pokój i wysyła kod. Drugi gracz dołącza po kodzie.'
                  : 'Tryb online wymaga konfiguracji SUPABASE_URL i SUPABASE_ANON_KEY.',
              style: GoogleFonts.montserrat(
                fontSize: 12.5,
                color: const Color(0xFF475569),
              ),
            ),
            if (mp.error != null) ...[
              const SizedBox(height: 10),
              Text(
                mp.error!,
                style: GoogleFonts.montserrat(
                  color: const Color(0xFFB91C1C),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
            const SizedBox(height: 14),
            TextFormField(
              controller: _onlineHostController,
              enabled: mp.isAvailable && !mp.isBusy,
              decoration: _fieldDecoration('Twoja nazwa (host)'),
              validator: _required,
            ),
            const SizedBox(height: 10),
            SizedBox(
              height: 48,
              child: FilledButton(
                onPressed: mp.isAvailable && !mp.isBusy
                    ? () => _createOnlineRoom(mp)
                    : null,
                child: Text(
                  'Stwórz pokój online',
                  style: GoogleFonts.fredoka(fontWeight: FontWeight.w700),
                ),
              ),
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _joinNameController,
                    enabled: mp.isAvailable && !mp.isBusy,
                    decoration: _fieldDecoration('Twoja nazwa (guest)'),
                    validator: _required,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextFormField(
                    controller: _joinCodeController,
                    enabled: mp.isAvailable && !mp.isBusy,
                    textCapitalization: TextCapitalization.characters,
                    decoration: _fieldDecoration('Kod pokoju'),
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) return 'Podaj kod';
                      if (v.trim().length < 6) return 'Min. 6 znaków';
                      return null;
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            SizedBox(
              height: 48,
              child: OutlinedButton(
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Color(0xFF1E3A8A), width: 1.5),
                ),
                onPressed: mp.isAvailable && !mp.isBusy
                    ? () => _joinOnlineRoom(mp)
                    : null,
                child: Text(
                  'Dołącz po kodzie',
                  style: GoogleFonts.fredoka(
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF1E3A8A),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _createOnlineRoom(MultiplayerController mp) async {
    final valid = _onlineFormKey.currentState?.validate() ?? false;
    if (!valid) return;
    final ok = await mp.createRoom(hostName: _onlineHostController.text.trim());
    if (!mounted || !ok) return;
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const WaitingRoomScreen()),
    );
  }

  Future<void> _joinOnlineRoom(MultiplayerController mp) async {
    final valid = _onlineFormKey.currentState?.validate() ?? false;
    if (!valid) return;
    final ok = await mp.joinRoom(
      roomCode: _joinCodeController.text.trim(),
      guestName: _joinNameController.text.trim(),
    );
    if (!mounted || !ok) return;
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const WaitingRoomScreen()),
    );
  }

  String? _required(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Wpisz nazwę';
    }
    return null;
  }
}
