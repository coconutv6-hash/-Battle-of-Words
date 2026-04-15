import 'dart:math';

import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/online_room.dart';

class OnlineRoomService {
  OnlineRoomService({SupabaseClient? client}) : _client = client ?? Supabase.instance.client;

  final SupabaseClient _client;
  final _random = Random();

  static const _table = 'bow_rooms';

  Future<OnlineRoom> createRoom({required String hostName}) async {
    final roomCode = _generateRoomCode();
    final row = await _client
        .from(_table)
        .insert({
          'room_code': roomCode,
          'host_name': hostName.trim(),
          'guest_name': null,
          'status': 'waiting',
        })
        .select()
        .single();
    return OnlineRoom.fromMap(row);
  }

  Future<OnlineRoom?> findRoom(String roomCode) async {
    final rows = await _client
        .from(_table)
        .select()
        .eq('room_code', roomCode.toUpperCase())
        .limit(1);
    if (rows is! List || rows.isEmpty) {
      return null;
    }
    return OnlineRoom.fromMap(Map<String, dynamic>.from(rows.first as Map));
  }

  Future<OnlineRoom> joinRoom({
    required String roomCode,
    required String guestName,
  }) async {
    final code = roomCode.trim().toUpperCase();
    final room = await findRoom(code);
    if (room == null) {
      throw StateError('Room not found');
    }
    if (room.hasGuest) {
      throw StateError('Room is full');
    }
    final row = await _client
        .from(_table)
        .update({
          'guest_name': guestName.trim(),
          'status': 'waiting',
        })
        .eq('id', room.id)
        .select()
        .single();
    return OnlineRoom.fromMap(row);
  }

  Future<void> startMatch(String roomId) async {
    await _client.from(_table).update({
      'status': 'playing',
      'started_at': DateTime.now().toUtc().toIso8601String(),
    }).eq('id', roomId);
  }

  Future<void> finishMatch(String roomId) async {
    await _client.from(_table).update({'status': 'finished'}).eq('id', roomId);
  }

  Future<void> updateRoomFields(
    String roomId,
    Map<String, dynamic> fields,
  ) async {
    await _client.from(_table).update(fields).eq('id', roomId);
  }

  Stream<OnlineRoom?> watchRoomByCode(String roomCode) {
    final code = roomCode.trim().toUpperCase();
    return _client
        .from(_table)
        .stream(primaryKey: ['id'])
        .eq('room_code', code)
        .map((rows) {
          if (rows.isEmpty) return null;
          return OnlineRoom.fromMap(rows.first);
        });
  }

  String _generateRoomCode() {
    const chars = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';
    return List.generate(6, (_) => chars[_random.nextInt(chars.length)]).join();
  }
}
