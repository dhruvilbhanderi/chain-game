// lib/data/services/room_service.dart
import 'dart:math';
import 'package:firebase_database/firebase_database.dart';
import 'package:get/get.dart';
import '../models/room_model.dart';
import '../models/user_model.dart';
import '../../core/constants/app_constants.dart';

class RoomService extends GetxService {
  final FirebaseDatabase _db = FirebaseDatabase.instance;

  DatabaseReference get _roomsRef => _db.ref(AppConstants.roomsPath);

  // ─── Generate unique room code ────────────────────────────────────
  String _generateRoomCode() {
    const chars = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';
    final rand = Random();
    return List.generate(AppConstants.roomCodeLength,
        (_) => chars[rand.nextInt(chars.length)]).join();
  }

  // ─── Create Room ──────────────────────────────────────────────────
  Future<RoomModel> createRoom(UserModel host) async {
    final roomRef = _roomsRef.push();
    final roomId = roomRef.key!;
    String code;

    // Ensure code uniqueness
    do {
      code = _generateRoomCode();
    } while (await _codeExists(code));

    final hostPlayer = PlayerInRoom(
      uid: host.uid,
      name: host.name,
      avatar: AppConstants.playerAvatars[host.avatarIndex],
      colorIndex: host.colorIndex,
      isHost: true,
      posX: 200,
      posY: 200,
    );

    final room = RoomModel(
      roomId: roomId,
      roomCode: code,
      hostUid: host.uid,
      players: {host.uid: hostPlayer},
      createdAt: DateTime.now(),
    );

    await roomRef.set(room.toMap());

    // Also write reverse-lookup: code -> roomId
    await _db.ref('roomCodes/$code').set(roomId);

    return room;
  }

  // ─── Join Room by Code ────────────────────────────────────────────
  Future<RoomModel?> joinRoom(String code, UserModel user) async {
    final codeSnap = await _db.ref('roomCodes/${code.toUpperCase()}').get();
    if (!codeSnap.exists) return null;

    final roomId = codeSnap.value as String;
    final roomSnap = await _roomsRef.child(roomId).get();
    if (!roomSnap.exists) return null;

    final room = RoomModel.fromMap(
        roomSnap.value as Map<dynamic, dynamic>, roomId);

    if (room.status != RoomStatus.waiting) {
      throw Exception('game_already_started');
    }
    if (room.playerCount >= AppConstants.maxPlayers) {
      throw Exception('room_full');
    }
    if (room.players.containsKey(user.uid)) {
      return room; // Already in
    }

    final playerData = PlayerInRoom(
      uid: user.uid,
      name: user.name,
      avatar: AppConstants.playerAvatars[user.avatarIndex],
      colorIndex: user.colorIndex,
      posX: 100 + Random().nextDouble() * 400,
      posY: 100 + Random().nextDouble() * 400,
    );

    await _roomsRef
        .child('$roomId/players/${user.uid}')
        .set(playerData.toMap());

    final updatedSnap = await _roomsRef.child(roomId).get();
    return RoomModel.fromMap(
        updatedSnap.value as Map<dynamic, dynamic>, roomId);
  }

  // ─── Stream Room Changes ──────────────────────────────────────────
  Stream<RoomModel?> streamRoom(String roomId) {
    return _roomsRef.child(roomId).onValue.map((event) {
      if (!event.snapshot.exists) return null;
      return RoomModel.fromMap(
          event.snapshot.value as Map<dynamic, dynamic>, roomId);
    });
  }

  // ─── Start Game (host only) ───────────────────────────────────────
  Future<void> startGame(String roomId, List<String> playerUids) async {
    // Pick random denner
    final dennerUid = playerUids[Random().nextInt(playerUids.length)];

    // Set all players' chain positions; denner gets 0
    final updates = <String, dynamic>{};
    updates['status'] = RoomStatus.countdown.name;
    updates['countdown'] = AppConstants.countdownSeconds;

    int chainPos = 0;
    for (final uid in playerUids) {
      final isDenner = uid == dennerUid;
      updates['players/$uid/isDenner'] = isDenner;
      updates['players/$uid/isInChain'] = isDenner;
      updates['players/$uid/chainPosition'] = isDenner ? chainPos++ : -1;
      updates['players/$uid/isAlive'] = !isDenner;
    }

    await _roomsRef.child(roomId).update(updates);

    // Countdown then set to playing
    await Future.delayed(const Duration(seconds: AppConstants.countdownSeconds));
    await _roomsRef.child(roomId).update({'status': RoomStatus.playing.name});
  }

  // ─── Update My Position (called each frame) ───────────────────────
  Future<void> updatePosition(
    String roomId,
    String uid, {
    required double posX,
    required double posY,
    required double velocityX,
    required double velocityY,
  }) async {
    await _roomsRef.child('$roomId/players/$uid').update({
      'posX': posX,
      'posY': posY,
      'velocityX': velocityX,
      'velocityY': velocityY,
    });
  }

  // ─── Catch a player (add to chain) ───────────────────────────────
  Future<void> catchPlayer(
      String roomId, String caughtUid, int newChainPosition) async {
    await _roomsRef.child('$roomId/players/$caughtUid').update({
      'isInChain': true,
      'isAlive': false,
      'chainPosition': newChainPosition,
    });
  }

  // ─── Set Winner & End Game ────────────────────────────────────────
  Future<void> endGame(String roomId, String winnerUid) async {
    await _roomsRef.child(roomId).update({
      'status': RoomStatus.finished.name,
      'winnerUid': winnerUid,
    });

    // Auto-delete room after 10 seconds to free DB
    await Future.delayed(const Duration(seconds: 10));
    await deleteRoom(roomId);
  }

  // ─── Delete Room (cleanup) ────────────────────────────────────────
  Future<void> deleteRoom(String roomId) async {
    final roomSnap = await _roomsRef.child(roomId).get();
    if (roomSnap.exists) {
      final room = RoomModel.fromMap(
          roomSnap.value as Map<dynamic, dynamic>, roomId);
      await _db.ref('roomCodes/${room.roomCode}').remove();
    }
    await _roomsRef.child(roomId).remove();
  }

  // ─── Leave Room ───────────────────────────────────────────────────
  Future<void> leaveRoom(String roomId, String uid, bool isHost) async {
    if (isHost) {
      await deleteRoom(roomId);
    } else {
      await _roomsRef.child('$roomId/players/$uid').remove();
    }
  }

  // ─── Helpers ─────────────────────────────────────────────────────
  Future<bool> _codeExists(String code) async {
    final snap = await _db.ref('roomCodes/$code').get();
    return snap.exists;
  }
}
