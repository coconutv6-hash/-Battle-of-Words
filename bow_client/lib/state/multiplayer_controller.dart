import 'dart:async';
import 'dart:math';

import 'package:flutter/foundation.dart';

import '../models/online_room.dart';
import '../services/online_room_service.dart';

class MultiplayerController extends ChangeNotifier {
  MultiplayerController({required OnlineRoomService? roomService}) : _roomService = roomService;

  final OnlineRoomService? _roomService;

  bool get isAvailable => _roomService != null;

  OnlineRoom? room;
  bool isHost = false;
  bool isBusy = false;
  String? localPlayerName;
  String? error;

  StreamSubscription<OnlineRoom?>? _roomSub;

  String? get roomCode => room?.roomCode;
  bool get hasGuest => room?.hasGuest ?? false;
  bool get canStartMatch => isHost && hasGuest && (room?.isWaiting ?? false);
  String get localPlayerId => isHost ? 'host' : 'guest';
  Map<String, dynamic>? get gameState => room?.gameState;
  Map<String, dynamic>? get answerRequest => room?.answerRequest;

  Future<bool> createRoom({required String hostName}) async {
    if (_roomService == null) {
      error = 'Online mode is not configured.';
      notifyListeners();
      return false;
    }

    isBusy = true;
    error = null;
    notifyListeners();
    try {
      final created = await _roomService.createRoom(hostName: hostName);
      room = created;
      isHost = true;
      localPlayerName = hostName.trim();
      _watchRoom(created.roomCode);
      return true;
    } catch (_) {
      error = 'Failed to create room.';
      return false;
    } finally {
      isBusy = false;
      notifyListeners();
    }
  }

  Future<bool> joinRoom({
    required String roomCode,
    required String guestName,
  }) async {
    if (_roomService == null) {
      error = 'Online mode is not configured.';
      notifyListeners();
      return false;
    }

    isBusy = true;
    error = null;
    notifyListeners();
    try {
      final joined = await _roomService.joinRoom(
        roomCode: roomCode,
        guestName: guestName,
      );
      room = joined;
      isHost = false;
      localPlayerName = guestName.trim();
      _watchRoom(joined.roomCode);
      return true;
    } on StateError catch (e) {
      if (e.message == 'Room not found') {
        error = 'Room not found.';
      } else if (e.message == 'Room is full') {
        error = 'Room is already full.';
      } else {
        error = 'Cannot join room.';
      }
      return false;
    } catch (_) {
      error = 'Cannot join room.';
      return false;
    } finally {
      isBusy = false;
      notifyListeners();
    }
  }

  Future<void> startMatch() async {
    final activeRoom = room;
    final roomService = _roomService;
    if (activeRoom == null || roomService == null || !canStartMatch) return;
    isBusy = true;
    error = null;
    notifyListeners();
    try {
      await roomService.updateRoomFields(activeRoom.id, {
        'status': 'playing',
        'started_at': DateTime.now().toUtc().toIso8601String(),
        'game_state': null,
        'answer_request': null,
      });
    } catch (_) {
      error = 'Failed to start match.';
    } finally {
      isBusy = false;
      notifyListeners();
    }
  }

  Future<void> markMatchFinished() async {
    final activeRoom = room;
    final roomService = _roomService;
    if (activeRoom == null || roomService == null) return;
    try {
      await roomService.finishMatch(activeRoom.id);
    } catch (_) {
      // Ignore best-effort finish update.
    }
  }

  Future<void> publishGameState(Map<String, dynamic> state) async {
    final activeRoom = room;
    final roomService = _roomService;
    if (activeRoom == null || roomService == null) return;
    await roomService.updateRoomFields(activeRoom.id, {'game_state': state});
  }

  Future<void> submitAnswerRequest({
    required String playerId,
    required String answer,
  }) async {
    final activeRoom = room;
    final roomService = _roomService;
    if (activeRoom == null || roomService == null) return;

    final req = {
      'id': _requestId(),
      'player_id': playerId,
      'answer': answer,
      'submitted_at': DateTime.now().toUtc().toIso8601String(),
    };
    await roomService.updateRoomFields(activeRoom.id, {'answer_request': req});
  }

  Future<void> clearAnswerRequest() async {
    final activeRoom = room;
    final roomService = _roomService;
    if (activeRoom == null || roomService == null) return;
    await roomService.updateRoomFields(activeRoom.id, {'answer_request': null});
  }

  void leaveRoom() {
    _roomSub?.cancel();
    _roomSub = null;
    room = null;
    isHost = false;
    isBusy = false;
    localPlayerName = null;
    error = null;
    notifyListeners();
  }

  void _watchRoom(String roomCode) {
    final roomService = _roomService;
    if (roomService == null) return;
    _roomSub?.cancel();
    _roomSub = roomService.watchRoomByCode(roomCode).listen((nextRoom) {
      room = nextRoom;
      notifyListeners();
    });
  }

  String _requestId() {
    final ts = DateTime.now().microsecondsSinceEpoch;
    final rand = Random().nextInt(1 << 20);
    return '$ts-$rand';
  }

  @override
  void dispose() {
    _roomSub?.cancel();
    super.dispose();
  }
}
