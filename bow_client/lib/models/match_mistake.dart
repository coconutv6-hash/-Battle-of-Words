import 'word_pair.dart';

/// One mistake in a match (responder failed on this word).
class MatchMistake {
  MatchMistake({
    required this.playerId,
    required this.playerDisplayName,
    required this.wordPair,
    required this.timeout,
    this.wrongAnswer,
  });

  final String playerId;
  final String playerDisplayName;
  final WordPair wordPair;
  final bool timeout;
  final String? wrongAnswer;
}
