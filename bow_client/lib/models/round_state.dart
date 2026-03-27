import 'word_pair.dart';

class RoundState {
  RoundState({required this.wordPair, required this.deadline});

  final WordPair wordPair;
  final DateTime deadline;
  String responderInput = '';
  bool? wasCorrect;
  String? correctSpelling;

  Duration get remaining => deadline.difference(DateTime.now());
}
