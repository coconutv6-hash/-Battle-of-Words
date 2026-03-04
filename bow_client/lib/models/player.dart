import '../state/player_role.dart';

class PlayerState {
  PlayerState({
    required this.id,
    required this.displayName,
    this.lives = 2,
    this.points = 0,
    this.role = PlayerRole.speaker,
  });

  final String id;
  final String displayName;
  int lives;
  int points;
  PlayerRole role;

  bool get isAlive => lives > 0;
}
