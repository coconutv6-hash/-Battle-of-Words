import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart' show rootBundle;

import '../models/player.dart';
import '../models/round_state.dart';
import '../models/word_pair.dart';
import 'player_role.dart';

class GameController extends ChangeNotifier {
  final List<WordPair> _wordBank = [];
  final List<WordPair> _wordDeck = [];
  final _random = Random();
  final Duration roundDuration = const Duration(seconds: 8);

  PlayerState? host;
  PlayerState? guest;
  RoundState? currentRound;
  PlayerState? winner;
  bool get hasWinner => winner != null;

  Timer? _ticker;
  Timer? _nextRoundDelay;

  Future<void> loadWordBank() async {
    if (_wordBank.isNotEmpty) return;
    try {
      final byteData = await rootBundle.load('assets/words.json');
      final raw = utf8.decode(byteData.buffer.asUint8List());
      final List<dynamic> decoded = jsonDecode(raw) as List<dynamic>;
      _wordBank
        ..clear()
        ..addAll(decoded.map((e) => WordPair.fromJson(e as Map<String, dynamic>)));
      if (kDebugMode) {
        debugPrint('Loaded ${_wordBank.length} word pairs');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Failed to load words: $e');
      }
    }
  }

  void setupPlayers({required String hostName, required String guestName}) {
    host = PlayerState(
      id: 'host',
      displayName: hostName,
      role: PlayerRole.speaker,
    );
    guest = PlayerState(
      id: 'guest',
      displayName: guestName,
      role: PlayerRole.responder,
    );
    winner = null;
    currentRound = null;
    notifyListeners();
  }

  bool get ready => host != null && guest != null;

  void startMatch() {
    if (!ready || _wordBank.isEmpty) return;
    host!..lives = 2..points = 0..role = PlayerRole.speaker;
    guest!..lives = 2..points = 0..role = PlayerRole.responder;
    winner = null;
    _startRound();
  }

  void _startRound({bool swapRoles = false}) {
    _nextRoundDelay?.cancel();
    if (swapRoles) {
      _swapRoles();
    }
    currentRound = RoundState(
      wordPair: _drawWord(),
      deadline: DateTime.now().add(roundDuration),
    );
    _ticker?.cancel();
    _ticker = Timer.periodic(const Duration(milliseconds: 200), (timer) {
      final remaining = currentRound?.remaining.inMilliseconds ?? 0;
      if (remaining <= 0) {
        timer.cancel();
        _handleMiss(isTimeout: true);
      } else {
        notifyListeners();
      }
    });
    notifyListeners();
  }

  PlayerState? get speaker =>
      host?.role == PlayerRole.speaker ? host : guest;
  PlayerState? get responder =>
      host?.role == PlayerRole.responder ? host : guest;

  double get timeProgress {
    if (currentRound == null) return 1;
    final remaining = currentRound!.remaining.inMilliseconds.clamp(0, roundDuration.inMilliseconds);
    return remaining / roundDuration.inMilliseconds;
  }

  void submitAnswer(String answer) {
    if (currentRound == null || hasWinner) return;
    final normalized = answer.trim().toLowerCase();
    currentRound!.responderInput = answer;
    final expected = currentRound!.wordPair.en.toLowerCase();
    final isCorrect = normalized == expected;
    if (isCorrect) {
      _handleCorrect();
    } else {
      _handleMiss();
    }
  }

  void _handleCorrect() {
    _ticker?.cancel();
    final activeResponder = responder;
    if (activeResponder == null) return;
    activeResponder.points += 1;
    currentRound!..wasCorrect = true..correctSpelling = null;
    notifyListeners();
    _startRound(swapRoles: true);
  }

  void _handleMiss({bool isTimeout = false}) {
    _ticker?.cancel();
    final activeResponder = responder;
    final round = currentRound;
    if (activeResponder == null || round == null) return;
    activeResponder.lives -= 1;
    round
      ..wasCorrect = false
      ..correctSpelling = round.wordPair.en;
    notifyListeners();
    if (!activeResponder.isAlive) {
      winner = speaker;
      notifyListeners();
      return;
    }
    _nextRoundDelay?.cancel();
    _nextRoundDelay = Timer(const Duration(seconds: 2), () {
      if (currentRound == round && winner == null) {
        _startRound();
      }
    });
  }

  void rematch() {
    startMatch();
  }

  void reset() {
    _ticker?.cancel();
    _nextRoundDelay?.cancel();
    host = null;
    guest = null;
    currentRound = null;
    winner = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _ticker?.cancel();
    _nextRoundDelay?.cancel();
    super.dispose();
  }

  void _resetDeck() {
    _wordDeck
      ..clear()
      ..addAll(_wordBank)
      ..shuffle(_random);
  }

  WordPair _drawWord() {
    if (_wordDeck.isEmpty) {
      _resetDeck();
    }
    return _wordDeck.removeLast();
  }

  void _swapRoles() {
    if (host == null || guest == null) return;
    final hostRole = host!.role;
    host!.role = guest!.role;
    guest!.role = hostRole;
  }
}
