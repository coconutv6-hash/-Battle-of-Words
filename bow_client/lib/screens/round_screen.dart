import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../state/game_controller.dart';
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

  @override
  void dispose() {
    _answerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<GameController>(
      builder: (context, controller, _) {
        if (controller.hasWinner) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(
                builder: (_) => const SummaryScreen(),
              ),
            );
          });
        }

        final speaker = controller.speaker;
        final responder = controller.responder;
        final round = controller.currentRound;
        final isResponderTurn = responder?.role == PlayerRole.responder;

        final theme = Theme.of(context);
        const onSurface = Colors.white;
        final gradient = BowBrand.roundGradient(responderPhase: isResponderTurn);

        return Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            foregroundColor: Colors.white,
            elevation: 0,
            title: Text(
              'Runda',
              style: GoogleFonts.fredoka(
                fontWeight: FontWeight.w600,
                color: Colors.white,
                shadows: BowBrand.titleShadow(),
              ),
            ),
            actions: [
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
                        Text(
                          'Mówiący: ${speaker?.displayName ?? '—'}',
                          style: GoogleFonts.montserrat(
                            fontWeight: FontWeight.w700,
                            color: onSurface,
                          ),
                        ),
                        Text(
                          'Odpowiadający: ${responder?.displayName ?? '—'}',
                          style: GoogleFonts.montserrat(
                            fontWeight: FontWeight.w700,
                            color: onSurface,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Życia',
                                  style: GoogleFonts.montserrat(
                                    fontWeight: FontWeight.w600,
                                    color: onSurface,
                                  ),
                                ),
                                LifeHearts(lives: speaker?.lives ?? 0),
                              ],
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  'Życia',
                                  style: GoogleFonts.montserrat(
                                    fontWeight: FontWeight.w600,
                                    color: onSurface,
                                  ),
                                ),
                                LifeHearts(lives: responder?.lives ?? 0),
                              ],
                            ),
                          ],
                        ),
                        const Spacer(),
                        if (!isResponderTurn)
                          _speakerCard(round)
                        else
                          _responderCard(context, round, controller, theme),
                        const Spacer(),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
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

  Widget _responderCard(BuildContext context, round, GameController controller, ThemeData theme) {
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
                onPressed: () => _submit(controller),
                child: Text(
                  'Wyślij',
                  style: GoogleFonts.montserrat(fontWeight: FontWeight.w700),
                ),
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
