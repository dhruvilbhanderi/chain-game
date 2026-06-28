// lib/modules/lobby/lobby_controller.dart
import 'dart:async';
import 'package:get/get.dart';
import '../../data/models/room_model.dart';
import '../../data/models/user_model.dart';
import '../../data/services/room_service.dart';
import '../../app/routes/app_routes.dart';

class LobbyController extends GetxController {
  final RoomService _roomService = Get.find();

  final Rx<RoomModel?> currentRoom = Rx<RoomModel?>(null);
  final RxBool isLoading = false.obs;
  StreamSubscription? _roomSub;

  String? get roomId => currentRoom.value?.roomId;

  // ─── Create Room ──────────────────────────────────────────────────
  Future<void> createRoom(UserModel user) async {
    isLoading.value = true;
    try {
      final room = await _roomService.createRoom(user);
      currentRoom.value = room;
      _listenToRoom(room.roomId);
    } finally {
      isLoading.value = false;
    }
  }

  // ─── Join Room ────────────────────────────────────────────────────
  Future<void> joinRoom(String code, UserModel user) async {
    isLoading.value = true;
    try {
      final room = await _roomService.joinRoom(code, user);
      if (room == null) throw Exception('room_not_found');
      currentRoom.value = room;
      _listenToRoom(room.roomId);
    } finally {
      isLoading.value = false;
    }
  }

  // ─── Listen for room changes (start game, player joins, etc.) ─────
  void _listenToRoom(String roomId) {
    _roomSub?.cancel();
    _roomSub = _roomService.streamRoom(roomId).listen((room) {
      if (room == null) {
        // Room deleted — go home
        currentRoom.value = null;
        Get.offAllNamed(AppRoutes.home);
        Get.snackbar('Room Closed', 'The host closed the room.');
        return;
      }
      currentRoom.value = room;

      // Navigate to game when status changes
      if (room.status == RoomStatus.countdown ||
          room.status == RoomStatus.playing) {
        if (Get.currentRoute != AppRoutes.game) {
          Get.offNamed(AppRoutes.game);
        }
      }
    });
  }

  // ─── Start Game (host only) ───────────────────────────────────────
  Future<void> startGame() async {
    final room = currentRoom.value;
    if (room == null) return;
    final playerUids = room.players.keys.toList();
    await _roomService.startGame(room.roomId, playerUids);
  }

  // ─── Leave Room ───────────────────────────────────────────────────
  Future<void> leaveRoom(String myUid) async {
    final room = currentRoom.value;
    if (room == null) return;
    final isHost = room.hostUid == myUid;
    await _roomService.leaveRoom(room.roomId, myUid, isHost);
    _roomSub?.cancel();
    currentRoom.value = null;
  }

  @override
  void onClose() {
    _roomSub?.cancel();
    super.onClose();
  }
}
