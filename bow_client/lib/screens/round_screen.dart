import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../state/game_controller.dart';
import '../state/multiplayer_controller.dart';
import '../state/player_role.dart';
import '../theme/bow_brand.dart';
import '../widgets/life_hearts.dart';
import '../widgets/round_timer_bar.dart';
import 'summary_screen.dart';

class RoundScreen extends StatefulWidget {
  const RoundScreen({super.key});

  @override
  State<RoundScreen> createState() => _RoundScreenState();
}

class _RoundScreenState extends State<RoundScreen> {
  final _answerController = TextEditingController();
  String? _error;
  bool _gameOverNavScheduled = false;

  static const Color _titleNavy = Color(0xFF1E3A8A);

  @override
  void dispose() {
    _answerController.dispose();
    super.dispose();
  }

  void _scheduleGameOverNav(GameController controller) {
    if (!controller.hasWinner || _gameOverNavScheduled) return;
    _gameOverNavScheduled = true;
    final multiplayer = context.read<MultiplayerController>();
    multiplayer.markMatchFinished();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      Future.delayed(const Duration(seconds: 3), () {
        if (!mounted) return;
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (_) => const SummaryScreen(),
          ),
        );
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<GameController>(
      builder: (context, controller, _) {
        final mp = context.watch<MultiplayerController>();
        if (mp.room != null) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (!context.mounted) return;
            context.read<GameController>().syncOnlineSession(mp);
          });
        }

        if (controller.hasWinner) {
          _scheduleGameOverNav(controller);
        }

        final speaker = controller.speaker;
        final responder = controller.responder;
        final round = controller.currentRound;
        if (round == null && !controller.hasWinner) {
          return Scaffold(
            backgroundColor: Colors.transparent,
            body: Container(
              decoration: BoxDecoration(
                gradient: BowBrand.roundGradient(responderPhase: false),
              ),
              child: Center(
                child: Text(
                  'Przygotowuję rundę...',
                  style: GoogleFonts.fredoka(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          );
        }
        final isLocalResponderTurn = mp.room == null
            ? controller.isHumanResponderTurn
            : ((responder?.id ?? '') == mp.localPlayerId);

        final theme = Theme.of(context);
        final gradient = BowBrand.roundGradient(responderPhase: isLocalResponderTurn);

        return Stack(
          children: [
            Scaffold(
              backgroundColor: Colors.transparent,
              appBar: AppBar(
                backgroundColor: Colors.transparent,
                foregroundColor: Colors.white,
                elevation: 0,
                title: Text(
                  'Runda',
                  style: GoogleFonts.fredoka(
                    fontSize: 26,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.5,
                    color: _titleNavy,
                    shadows: const [
                      Shadow(
                        color: Color(0xE6FFFFFF),
                        offset: Offset(0, -1),
                        blurRadius: 0,
                      ),
                      Shadow(
                        color: Color(0xE6FFFFFF),
                        offset: Offset(0, 1),
                        blurRadius: 0,
                      ),
                      Shadow(
                        color: Color(0xB3000000),
                        offset: Offset(0, 3),
                        blurRadius: 8,
                      ),
                    ],
                  ),
                ),
                actions: [
                  if (!controller.hasWinner)
                    IconButton(
                      icon: const Icon(Icons.stop_circle_outlined),
                      onPressed: () {
                        controller.reset();
                        Navigator.of(context).popUntil((route) => route.isFirst);
                      },
                    )
                ],
              ),
              body: Container(
                decoration: BoxDecoration(gradient: gradient),
                child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
                  child: RoundTimerBar(
                    progress: controller.timeProgress,
                    height: 12,
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: _playerLivesBlock(
                                roleLabel: 'Mówiący',
                                name: speaker?.displayName ?? '—',
                                lives: speaker?.lives ?? 0,
                                alignEnd: false,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: _playerLivesBlock(
                                roleLabel: 'Odpowiadający',
                                name: responder?.displayName ?? '—',
                                lives: responder?.lives ?? 0,
                                alignEnd: true,
                              ),
                            ),
                          ],
                        ),
                        const Spacer(),
                        if (!isLocalResponderTurn)
                          (controller.isSoloVsBot && controller.isBotResponderTurn
                              ? _botTurnCard(controller, round)
                              : _speakerCard(round))
                        else
                          _responderCard(context, round, controller, theme, mp.room != null),
                        const Spacer(),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
            ),
            if (controller.hasWinner)
              Positioned.fill(
                child: ColoredBox(
                  color: Colors.black.withValues(alpha: 0.55),
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Material(
                        color: Colors.white,
                        elevation: 12,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'Koniec gry',
                                style: GoogleFonts.fredoka(
                                  fontSize: 22,
                                  fontWeight: FontWeight.w800,
                                  color: _titleNavy,
                                ),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                'Poprawna odpowiedź:',
                                style: GoogleFonts.montserrat(
                                  fontSize: 15,
                                  color: Colors.grey.shade700,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                round?.wordPair.en ?? '—',
                                textAlign: TextAlign.center,
                                style: GoogleFonts.fredoka(
                                  fontSize: 32,
                                  fontWeight: FontWeight.w800,
                                  color: _titleNavy,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                round?.wordPair.pl ?? '',
                                textAlign: TextAlign.center,
                                style: GoogleFonts.montserrat(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.grey.shade800,
                                ),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'Za chwilę podsumowanie…',
                                style: GoogleFonts.montserrat(
                                  fontSize: 13,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }

  /// Nick przy ikonach życia — biała ramka, tekst w kolorze jak obramowanie „Wyślij” (#1E3A8A).
  Widget _playerLivesBlock({
    required String roleLabel,
    required String name,
    required int lives,
    required bool alignEnd,
  }) {
    final nickStyle = GoogleFonts.montserrat(
      fontSize: 15,
      fontWeight: FontWeight.w500,
      height: 1.25,
      color: _titleNavy,
    );

    final nickBox = Container(
      constraints: const BoxConstraints(minWidth: 72, maxWidth: 200),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _titleNavy, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.12),
            offset: const Offset(0, 2),
            blurRadius: 6,
          ),
        ],
      ),
      child: Text(
        name,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        textAlign: alignEnd ? TextAlign.end : TextAlign.start,
        style: nickStyle,
      ),
    );

    final hearts = LifeHearts(lives: lives);

    final row = alignEnd
        ? Row(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Flexible(child: nickBox),
              const SizedBox(width: 10),
              hearts,
            ],
          )
        : Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              hearts,
              const SizedBox(width: 10),
              Flexible(child: nickBox),
            ],
          );

    return Column(
      crossAxisAlignment:
          alignEnd ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [
        Text(
          roleLabel,
          style: GoogleFonts.montserrat(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: Colors.white.withValues(alpha: 0.9),
            shadows: const [
              Shadow(
                color: Color(0x80000000),
                offset: Offset(0, 1),
                blurRadius: 3,
              ),
            ],
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'Życia',
          style: GoogleFonts.montserrat(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Colors.white.withValues(alpha: 0.92),
            shadows: const [
              Shadow(
                color: Color(0x80000000),
                offset: Offset(0, 1),
                blurRadius: 4,
              ),
            ],
          ),
        ),
        const SizedBox(height: 6),
        row,
      ],
    );
  }

  Widget _speakerCard(round) {
    final word = round?.wordPair.en ?? '...';
    final theme = Theme.of(context);
    final brandColor = theme.colorScheme.primary;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Text(
              'Hasło dla mówiącego',
              style: GoogleFonts.montserrat(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: theme.colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 12),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 350),
              switchInCurve: Curves.easeOutBack,
              switchOutCurve: Curves.easeInCubic,
              transitionBuilder: (Widget child, Animation<double> animation) {
                final curved = CurvedAnimation(
                  parent: animation,
                  curve: Curves.easeOutBack,
                  reverseCurve: Curves.easeInCubic,
                );
                return ScaleTransition(
                  scale: Tween<double>(begin: 0.82, end: 1.0).animate(curved),
                  child: RotationTransition(
                    turns: Tween<double>(begin: 10 / 360, end: 0).animate(curved),
                    child: child,
                  ),
                );
              },
              child: _SpeakerWordDepth(
                key: ValueKey<String>('speaker-word-$word'),
                word: word,
                brandColor: brandColor,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Przekaż telefon przeciwnikowi po wypowiedzeniu słowa.',
              textAlign: TextAlign.center,
              style: GoogleFonts.montserrat(
                fontWeight: FontWeight.w500,
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _responderCard(
    BuildContext context,
    round,
    GameController controller,
    ThemeData theme,
    bool isOnline,
  ) {
    final translation = round?.wordPair.pl ?? '—';
    final correction = round?.correctSpelling;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Tłumaczenie po polsku:',
              style: GoogleFonts.montserrat(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: theme.colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 12),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 500),
              child: Text(
                translation,
                key: ValueKey<String>(translation),
                style: GoogleFonts.montserrat(
                  fontSize: 36,
                  fontWeight: FontWeight.w700,
                  color: theme.colorScheme.primary,
                ),
              ),
            ),
            const SizedBox(height: 16),
            if (correction != null) ...[
              Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: theme.colorScheme.error),
                  ),
                  child: Column(
                    children: [
                      Text(
                        'Poprawna pisownia',
                        style: GoogleFonts.montserrat(
                          fontWeight: FontWeight.w700,
                          color: theme.colorScheme.error,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        correction,
                        style: GoogleFonts.montserrat(
                          fontSize: 34,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
            TextField(
              controller: _answerController,
              enabled: !controller.hasWinner,
              decoration: InputDecoration(
                labelText: 'Wpisz angielski odpowiednik',
                errorText: _error,
              ),
              onSubmitted: (_) => _submit(controller),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: controller.hasWinner ? null : () => _submit(controller),
                child: Text(
                  'Wyślij',
                  style: GoogleFonts.montserrat(fontWeight: FontWeight.w700),
                ),
              ),
            ),
            if (isOnline) ...[
              const SizedBox(height: 8),
              Text(
                'Twoja odpowiedź zostanie wysłana do hosta.',
                style: GoogleFonts.montserrat(
                  fontSize: 12,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _botTurnCard(GameController controller, dynamic round) {
    final translation = round?.wordPair.pl ?? '—';
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Text(
              '${controller.botDisplayName} odpowiada…',
              style: GoogleFonts.fredoka(
                fontSize: 24,
                fontWeight: FontWeight.w700,
                color: _titleNavy,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Polskie hasło:',
              style: GoogleFonts.montserrat(
                fontWeight: FontWeight.w700,
                color: Colors.grey.shade700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              translation,
              textAlign: TextAlign.center,
              style: GoogleFonts.montserrat(
                fontSize: 34,
                fontWeight: FontWeight.w700,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            const SizedBox(height: 18),
            Text(
              'Poczekaj na ruch bota.',
              style: GoogleFonts.montserrat(
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _submit(GameController controller) {
    final answer = _answerController.text.trim();
    if (answer.isEmpty) {
      setState(() => _error = 'Wpisz odpowiedź');
      return;
    }
    setState(() => _error = null);
    controller.submitAnswer(answer);
    _answerController.clear();
  }
}

class _SpeakerWordDepth extends StatelessWidget {
  const _SpeakerWordDepth({
    super.key,
    required this.word,
    required this.brandColor,
  });

  final String word;
  final Color brandColor;

  @override
  Widget build(BuildContext context) {
    final baseStyle = GoogleFonts.montserrat(
      fontSize: 48,
      fontWeight: FontWeight.bold,
      height: 1.05,
    );

    final gradient = LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        Color.lerp(brandColor, Colors.white, 0.2)!,
        brandColor,
        Color.lerp(brandColor, const Color(0xFF151A2E), 0.15)!,
      ],
      stops: const [0.0, 0.48, 1.0],
    );

    return Stack(
      clipBehavior: Clip.none,
      alignment: Alignment.center,
      children: [
        Transform.translate(
          offset: const Offset(2, 6),
          child: Text(
            word,
            textAlign: TextAlign.center,
            style: baseStyle.copyWith(
              color: Colors.black.withOpacity(0.34),
              shadows: [
                Shadow(
                  color: Colors.black.withOpacity(0.45),
                  offset: const Offset(0, 4),
                  blurRadius: 16,
                ),
              ],
            ),
          ),
        ),
        Transform.translate(
          offset: const Offset(0, 3),
          child: Text(
            word,
            textAlign: TextAlign.center,
            style: baseStyle.copyWith(
              color: brandColor.withOpacity(0.18),
            ),
          ),
        ),
        ShaderMask(
          blendMode: BlendMode.srcIn,
          shaderCallback: (Rect bounds) => gradient.createShader(bounds),
          child: Text(
            word,
            textAlign: TextAlign.center,
            style: baseStyle.copyWith(color: Colors.white),
          ),
        ),
      ],
    );
  }
}
