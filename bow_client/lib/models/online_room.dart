class OnlineRoom {
  OnlineRoom({
    required this.id,
    required this.roomCode,
    required this.hostName,
    required this.status,
    this.guestName,
    this.startedAtIso,
    this.gameState,
    this.answerRequest,
  });

  final String id;
  final String roomCode;
  final String hostName;
  final String? guestName;
  final String status;
  final String? startedAtIso;
  final Map<String, dynamic>? gameState;
  final Map<String, dynamic>? answerRequest;

  bool get hasGuest => (guestName ?? '').trim().isNotEmpty;
  bool get isWaiting => status == 'waiting';
  bool get isPlaying => status == 'playing';
  bool get isFinished => status == 'finished';

  factory OnlineRoom.fromMap(Map<String, dynamic> map) {
    Map<String, dynamic>? mapField(dynamic value) {
      if (value is Map) {
        return Map<String, dynamic>.from(value);
      }
      return null;
    }

    return OnlineRoom(
      id: (map['id'] ?? '').toString(),
      roomCode: (map['room_code'] ?? '').toString(),
      hostName: (map['host_name'] ?? '').toString(),
      guestName: map['guest_name']?.toString(),
      status: (map['status'] ?? 'waiting').toString(),
      startedAtIso: map['started_at']?.toString(),
      gameState: mapField(map['game_state']),
      answerRequest: mapField(map['answer_request']),
    );
  }
}
