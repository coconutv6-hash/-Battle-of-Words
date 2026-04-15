import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart' show rootBundle;

import '../models/match_mistake.dart';
import '../models/player.dart';
import '../models/round_state.dart';
import '../models/word_pair.dart';
import 'multiplayer_controller.dart';
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

  /// All mistakes in the current match (cleared on [startMatch] / [reset]).
  final List<MatchMistake> matchMistakes = [];

  Timer? _ticker;
  Timer? _nextRoundDelay;
  Timer? _botMoveTimer;
  MultiplayerController? _multiplayer;
  bool _isOnlineMatch = false;
  bool _soloVsBot = false;
  String? _humanPlayerId;
  String? _botPlayerId;
  int _onlineVersion = 0;
  int _lastAppliedVersion = -1;
  String? _lastProcessedAnswerRequestId;

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
    _botMoveTimer?.cancel();
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
    matchMistakes.clear();
    _soloVsBot = false;
    _humanPlayerId = null;
    _botPlayerId = null;
    notifyListeners();
  }

  void setupSoloVsBot({required String playerName, String botName = 'BOW Bot'}) {
    _botMoveTimer?.cancel();
    host = PlayerState(
      id: 'host',
      displayName: playerName,
      role: PlayerRole.speaker,
    );
    guest = PlayerState(
      id: 'guest',
      displayName: botName,
      role: PlayerRole.responder,
    );
    winner = null;
    currentRound = null;
    matchMistakes.clear();
    _soloVsBot = true;
    _humanPlayerId = 'host';
    _botPlayerId = 'guest';
    notifyListeners();
  }

  void syncOnlineSession(MultiplayerController multiplayer) {
    final room = multiplayer.room;
    if (room == null) {
      return;
    }

    _multiplayer = multiplayer;
    _isOnlineMatch = true;
    _soloVsBot = false;
    _humanPlayerId = null;
    _botPlayerId = null;

    final guestName = (room.guestName ?? '').trim().isEmpty ? 'Guest' : room.guestName!.trim();
    if (!ready) {
      setupPlayers(hostName: room.hostName, guestName: guestName);
    }

    final snapshot = room.gameState;
    if (snapshot != null) {
      _applyOnlineSnapshot(snapshot);
    } else if (multiplayer.isHost && room.isPlaying && currentRound == null && !hasWinner) {
      startMatch();
    }

    if (multiplayer.isHost && room.isPlaying) {
      _tryProcessIncomingAnswerRequest();
      _ensureOnlineTimeoutTicker();
    }
  }

  bool get ready => host != null && guest != null;
  bool get isSoloVsBot => _soloVsBot;
  bool get isHumanResponderTurn => !_soloVsBot || responder?.id == _humanPlayerId;
  bool get isBotResponderTurn => _soloVsBot && responder?.id == _botPlayerId;
  String get botDisplayName {
    if (_botPlayerId == null) return 'BOW Bot';
    final p = host?.id == _botPlayerId ? host : guest;
    return p?.displayName ?? 'BOW Bot';
  }

  void startMatch() {
    if (!ready || _wordBank.isEmpty) return;
    _botMoveTimer?.cancel();
    host!..lives = 2..points = 0..role = PlayerRole.speaker;
    guest!..lives = 2..points = 0..role = PlayerRole.responder;
    winner = null;
    matchMistakes.clear();
    _startRound();
    _publishOnlineStateIfNeeded();
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
      if (_isOnlineMatch && !(_multiplayer?.isHost ?? false)) {
        return;
      }
      final remaining = currentRound?.remaining.inMilliseconds ?? 0;
      if (remaining <= 0) {
        timer.cancel();
        _handleMiss(isTimeout: true);
      } else {
        notifyListeners();
      }
    });
    notifyListeners();
    _scheduleBotMoveIfNeeded();
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
    if (_soloVsBot && responder?.id == _botPlayerId) {
      return;
    }
    final multiplayer = _multiplayer;
    if (_isOnlineMatch && multiplayer != null && !multiplayer.isHost) {
      final responderNow = responder;
      if (responderNow == null || responderNow.id != multiplayer.localPlayerId) {
        return;
      }
      unawaited(
        multiplayer.submitAnswerRequest(
          playerId: multiplayer.localPlayerId,
          answer: answer.trim(),
        ),
      );
      return;
    }
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
    _botMoveTimer?.cancel();
    final activeResponder = responder;
    if (activeResponder == null) return;
    activeResponder.points += 1;
    currentRound!..wasCorrect = true..correctSpelling = null;
    notifyListeners();
    _startRound(swapRoles: true);
    _publishOnlineStateIfNeeded();
  }

  void _handleMiss({bool isTimeout = false}) {
    _ticker?.cancel();
    _botMoveTimer?.cancel();
    final activeResponder = responder;
    final round = currentRound;
    if (activeResponder == null || round == null) return;
    matchMistakes.add(
      MatchMistake(
        playerId: activeResponder.id,
        playerDisplayName: activeResponder.displayName,
        wordPair: round.wordPair,
        timeout: isTimeout,
        wrongAnswer: isTimeout ? null : round.responderInput.trim(),
      ),
    );
    activeResponder.lives -= 1;
    round
      ..wasCorrect = false
      ..correctSpelling = round.wordPair.en;
    notifyListeners();
    if (!activeResponder.isAlive) {
      winner = speaker;
      _publishOnlineStateIfNeeded();
      notifyListeners();
      return;
    }
    _nextRoundDelay?.cancel();
    _nextRoundDelay = Timer(const Duration(seconds: 2), () {
      if (currentRound == round && winner == null) {
        _startRound();
        _publishOnlineStateIfNeeded();
      }
    });
    _publishOnlineStateIfNeeded();
  }

  void rematch() {
    startMatch();
  }

  void reset() {
    _ticker?.cancel();
    _nextRoundDelay?.cancel();
    _botMoveTimer?.cancel();
    host = null;
    guest = null;
    currentRound = null;
    winner = null;
    matchMistakes.clear();
    _onlineVersion = 0;
    _lastAppliedVersion = -1;
    _lastProcessedAnswerRequestId = null;
    _isOnlineMatch = false;
    _soloVsBot = false;
    _humanPlayerId = null;
    _botPlayerId = null;
    _multiplayer = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _ticker?.cancel();
    _nextRoundDelay?.cancel();
    _botMoveTimer?.cancel();
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

  void _scheduleBotMoveIfNeeded() {
    if (!_soloVsBot || _isOnlineMatch || hasWinner) return;
    final botId = _botPlayerId;
    final activeResponder = responder;
    final round = currentRound;
    if (botId == null || activeResponder == null || round == null) return;
    if (activeResponder.id != botId) return;

    _botMoveTimer?.cancel();
    final remaining = round.remaining.inMilliseconds;
    if (remaining <= 450) return;

    final planned = 900 + _random.nextInt(1400);
    final upperBound = max(450, remaining - 250);
    var delayMs = planned;
    if (delayMs < 400) {
      delayMs = 400;
    }
    if (delayMs > upperBound) {
      delayMs = upperBound;
    }
    _botMoveTimer = Timer(Duration(milliseconds: delayMs), () {
      if (currentRound != round || winner != null) return;
      final expected = round.wordPair.en;
      final correct = _random.nextDouble() < 0.72;
      if (correct) {
        round.responderInput = expected;
        _handleCorrect();
      } else {
        round.responderInput = _botMistypedAnswer(expected);
        _handleMiss();
      }
    });
  }

  String _botMistypedAnswer(String expected) {
    if (expected.isEmpty) return '...';
    if (expected.length == 1) return '${expected}x';
    final cut = max(1, expected.length - 1);
    return expected.substring(0, cut);
  }

  void _ensureOnlineTimeoutTicker() {
    if (!(_isOnlineMatch && (_multiplayer?.isHost ?? false))) {
      return;
    }
    if (_ticker != null) {
      return;
    }
    _ticker = Timer.periodic(const Duration(milliseconds: 200), (timer) {
      final remaining = currentRound?.remaining.inMilliseconds ?? 0;
      if (remaining <= 0 && currentRound != null && winner == null) {
        timer.cancel();
        _ticker = null;
        _handleMiss(isTimeout: true);
      } else {
        notifyListeners();
      }
    });
  }

  void _ensurePassiveCountdownTicker() {
    if (!(_isOnlineMatch && !(_multiplayer?.isHost ?? false))) {
      return;
    }
    if (_ticker != null) {
      return;
    }
    _ticker = Timer.periodic(const Duration(milliseconds: 200), (timer) {
      if (currentRound == null || winner != null) {
        timer.cancel();
        _ticker = null;
        return;
      }
      notifyListeners();
    });
  }

  void _tryProcessIncomingAnswerRequest() {
    final multiplayer = _multiplayer;
    if (multiplayer == null || !multiplayer.isHost) return;
    final req = multiplayer.answerRequest;
    if (req == null || currentRound == null || hasWinner) return;
    final reqId = (req['id'] ?? '').toString();
    if (reqId.isEmpty || reqId == _lastProcessedAnswerRequestId) return;
    final playerId = (req['player_id'] ?? '').toString();
    final answer = (req['answer'] ?? '').toString();
    final currentResponder = responder;
    if (currentResponder == null || currentResponder.id != playerId) {
      _lastProcessedAnswerRequestId = reqId;
      unawaited(multiplayer.clearAnswerRequest());
      return;
    }
    _lastProcessedAnswerRequestId = reqId;
    unawaited(multiplayer.clearAnswerRequest());
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

  void _publishOnlineStateIfNeeded() {
    final multiplayer = _multiplayer;
    if (!_isOnlineMatch || multiplayer == null || !multiplayer.isHost) return;
    _onlineVersion += 1;
    unawaited(multiplayer.publishGameState(_serializeOnlineGameState()));
  }

  Map<String, dynamic> _serializeOnlineGameState() {
    final round = currentRound;
    final hostState = host;
    final guestState = guest;
    return {
      'version': _onlineVersion,
      'host': _playerToMap(hostState),
      'guest': _playerToMap(guestState),
      'winner_id': winner?.id,
      'current_round': round == null
          ? null
          : {
              'en': round.wordPair.en,
              'pl': round.wordPair.pl,
              'deadline': round.deadline.toUtc().toIso8601String(),
              'responder_input': round.responderInput,
              'was_correct': round.wasCorrect,
              'correct_spelling': round.correctSpelling,
            },
      'mistakes': matchMistakes
          .map(
            (m) => {
              'player_id': m.playerId,
              'player_display_name': m.playerDisplayName,
              'en': m.wordPair.en,
              'pl': m.wordPair.pl,
              'timeout': m.timeout,
              'wrong_answer': m.wrongAnswer,
            },
          )
          .toList(),
    };
  }

  Map<String, dynamic>? _playerToMap(PlayerState? p) {
    if (p == null) return null;
    return {
      'id': p.id,
      'display_name': p.displayName,
      'lives': p.lives,
      'points': p.points,
      'role': p.role.name,
    };
  }

  void _applyOnlineSnapshot(Map<String, dynamic> snap) {
    final ver = (snap['version'] is num) ? (snap['version'] as num).toInt() : 0;
    if (ver <= _lastAppliedVersion) {
      return;
    }
    _lastAppliedVersion = ver;
    _onlineVersion = ver;

    final hostMap = snap['host'];
    final guestMap = snap['guest'];
    if (hostMap is Map && guestMap is Map) {
      host = _mapToPlayer(Map<String, dynamic>.from(hostMap));
      guest = _mapToPlayer(Map<String, dynamic>.from(guestMap));
    }

    final winnerId = snap['winner_id']?.toString();
    if (winnerId == 'host') {
      winner = host;
    } else if (winnerId == 'guest') {
      winner = guest;
    } else {
      winner = null;
    }

    final roundMap = snap['current_round'];
    if (roundMap is Map) {
      final r = Map<String, dynamic>.from(roundMap);
      final wp = WordPair(
        en: (r['en'] ?? '').toString(),
        pl: (r['pl'] ?? '').toString(),
      );
      DateTime deadline;
      try {
        deadline = DateTime.parse((r['deadline'] ?? '').toString()).toLocal();
      } catch (_) {
        deadline = DateTime.now();
      }
      final reconstructed = RoundState(wordPair: wp, deadline: deadline)
        ..responderInput = (r['responder_input'] ?? '').toString()
        ..wasCorrect = r['was_correct'] as bool?
        ..correctSpelling = r['correct_spelling']?.toString();
      currentRound = reconstructed;
      _ensurePassiveCountdownTicker();
    } else {
      currentRound = null;
      if (_isOnlineMatch && !(_multiplayer?.isHost ?? false)) {
        _ticker?.cancel();
        _ticker = null;
      }
    }

    final mistakesRaw = snap['mistakes'];
    matchMistakes.clear();
    if (mistakesRaw is List) {
      for (final item in mistakesRaw) {
        if (item is! Map) continue;
        final m = Map<String, dynamic>.from(item);
        matchMistakes.add(
          MatchMistake(
            playerId: (m['player_id'] ?? '').toString(),
            playerDisplayName: (m['player_display_name'] ?? '').toString(),
            wordPair: WordPair(
              en: (m['en'] ?? '').toString(),
              pl: (m['pl'] ?? '').toString(),
            ),
            timeout: m['timeout'] == true,
            wrongAnswer: m['wrong_answer']?.toString(),
          ),
        );
      }
    }

    notifyListeners();
  }

  PlayerState _mapToPlayer(Map<String, dynamic> map) {
    final roleName = (map['role'] ?? 'speaker').toString();
    final role = roleName == PlayerRole.responder.name ? PlayerRole.responder : PlayerRole.speaker;
    return PlayerState(
      id: (map['id'] ?? '').toString(),
      displayName: (map['display_name'] ?? '').toString(),
      lives: ((map['lives'] as num?) ?? 2).toInt(),
      points: ((map['points'] as num?) ?? 0).toInt(),
      role: role,
    );
  }
}
