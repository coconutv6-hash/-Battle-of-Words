import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../state/game_controller.dart';
import '../state/player_role.dart';
import '../widgets/life_hearts.dart';
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
        final gradient = isResponderTurn
            ? const LinearGradient(colors: [Color(0xFFFFD26F), Color(0xFFFFAF7B)])
            : const LinearGradient(colors: [Color(0xFF4AC29A), Color(0xFFBDFFF3)]);

        return Scaffold(
          appBar: AppBar(
            title: const Text('Runda'),
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
                LinearProgressIndicator(
                  minHeight: 8,
                  value: controller.timeProgress,
                  backgroundColor: Colors.black12,
                  color: Colors.white,
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Speaker: ${speaker?.displayName ?? '—'}'),
                        Text('Responder: ${responder?.displayName ?? '—'}'),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Lives'),
                                LifeHearts(lives: speaker?.lives ?? 0),
                              ],
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                const Text('Lives'),
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
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const Text('Powiedz głośno:'),
            const SizedBox(height: 12),
            Text(
              word,
              style: const TextStyle(fontSize: 48, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text('Przekaż telefon przeciwnikowi po wypowiedzeniu słowa.'),
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
            const Text('Tłumaczenie po polsku:'),
            const SizedBox(height: 12),
            Text(
              translation,
              style: theme.textTheme.headlineMedium,
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
                        style: theme.textTheme.titleMedium?.copyWith(color: theme.colorScheme.error),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        correction,
                        style: theme.textTheme.displaySmall?.copyWith(fontWeight: FontWeight.bold),
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
                child: const Text('Wyślij'),
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
