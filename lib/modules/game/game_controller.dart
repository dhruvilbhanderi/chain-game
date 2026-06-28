// lib/modules/game/game_controller.dart
import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../data/models/room_model.dart';
import '../../data/services/room_service.dart';
import '../../data/services/auth_service.dart';
import '../../app/routes/app_routes.dart';
import '../../core/constants/app_constants.dart';

class GameController extends GetxController with GetTickerProviderStateMixin {
  final RoomService _roomService = Get.find();
  final AuthService _authService = Get.find();

  // Observable state
  final Rx<RoomModel?> room = Rx<RoomModel?>(null);
  final RxString countdown = ''.obs;
  final RxBool gameOver = false.obs;
  final RxString winnerName = ''.obs;
  final RxBool isWinner = false.obs;

  // My position & velocity
  double myPosX = 200;
  double myPosY = 300;
  double myVelX = 0;
  double myVelY = 0;

  // Joystick input
  double joystickX = 0;
  double joystickY = 0;

  String get myUid => _authService.currentUser?.uid ?? '';

  // Map/Canvas size
  double mapWidth = 800;
  double mapHeight = 600;

  late AnimationController _gameLoop;
  StreamSubscription? _roomSub;
  Timer? _positionThrottle;

  String? get roomId => room.value?.roomId;

  PlayerInRoom? get myPlayer =>
      room.value?.players[myUid];

  bool get isDenner =>
      myPlayer?.isDenner ?? false;

  bool get isInChain =>
      myPlayer?.isInChain ?? false;

  bool get isAlive =>
      myPlayer?.isAlive ?? false;

  @override
  void onInit() {
    super.onInit();
    _startGameLoop();

    // Listen to the current room from lobby controller
    final lobbyRoom =
        Get.find<dynamic>().currentRoom?.value as RoomModel?;
    if (lobbyRoom != null) {
      _listenToRoom(lobbyRoom.roomId);
    }
  }

  void initRoom(String roomId) {
    _listenToRoom(roomId);
  }

  void _listenToRoom(String roomId) {
    _roomSub?.cancel();
    _roomSub = _roomService.streamRoom(roomId).listen((r) {
      if (r == null) {
        _handleRoomDeleted();
        return;
      }
      room.value = r;

      // Handle countdown display
      if (r.status == RoomStatus.countdown) {
        countdown.value = '${r.countdown}';
      } else if (r.status == RoomStatus.playing) {
        countdown.value = '';
      }

      // Handle game finish
      if (r.status == RoomStatus.finished) {
        _handleGameOver(r);
      }

      // Check if only I'm left (I win!)
      if (r.status == RoomStatus.playing) {
        _checkWinCondition(r);
      }
    });
  }

  // ─── Game Loop (60fps) ────────────────────────────────────────────
  void _startGameLoop() {
    _gameLoop = AnimationController(
      vsync: this,
      duration: const Duration(hours: 1),
    );
    _gameLoop.repeat();
    _gameLoop.addListener(_onTick);
  }

  DateTime _lastTick = DateTime.now();

  void _onTick() {
    if (room.value == null) return;
    if (room.value!.status != RoomStatus.playing) return;
    if (!isAlive && !isDenner && !isInChain) return;

    final now = DateTime.now();
    final dt = now.difference(_lastTick).inMilliseconds / 1000.0;
    _lastTick = now;

    // Update my position
    _updateMyPosition(dt);

    // Check collisions (chain catching other players)
    if (isDenner || isInChain) {
      _checkCatchCollisions();
    }
  }

  void _updateMyPosition(double dt) {
    final speed = AppConstants.playerSpeed;

    // Apply joystick velocity
    myVelX = joystickX * speed;
    myVelY = joystickY * speed;

    myPosX = (myPosX + myVelX * dt).clamp(20.0, mapWidth - 20);
    myPosY = (myPosY + myVelY * dt).clamp(20.0, mapHeight - 20);

    // Throttle position updates to Firebase (max 20/s)
    _positionThrottle ??= Timer.periodic(
      const Duration(milliseconds: 50),
      (_) {
        _roomService.updatePosition(
          room.value!.roomId,
          myUid,
          posX: myPosX,
          posY: myPosY,
          velocityX: myVelX,
          velocityY: myVelY,
        );
        _positionThrottle = null;
      },
    );
  }

  // ─── Collision Detection ─────────────────────────────────────────
  void _checkCatchCollisions() {
    final r = room.value;
    if (r == null) return;

    final chainPlayers = r.chainPlayers;
    final freePlayers = r.alivePlayers;

    for (final chainPlayer in chainPlayers) {
      // Only the LAST player in chain can catch
      if (chainPlayer.uid != myUid &&
          chainPlayer.chainPosition !=
              chainPlayers.map((p) => p.chainPosition).reduce(max)) {
        continue;
      }
      if (chainPlayer.uid != myUid) continue;

      for (final freePlayer in freePlayers) {
        final dx = myPosX - freePlayer.posX;
        final dy = myPosY - freePlayer.posY;
        final dist = sqrt(dx * dx + dy * dy);

        if (dist < AppConstants.catchRadius) {
          // Caught! Add to chain
          final nextPos = chainPlayers.length;
          _roomService.catchPlayer(
              r.roomId, freePlayer.uid, nextPos);
        }
      }
    }
  }

  // ─── Win Condition ────────────────────────────────────────────────
  void _checkWinCondition(RoomModel r) {
    final aliveFree = r.alivePlayers;
    if (aliveFree.length == 1) {
      // Only 1 free player left — they win!
      final winner = aliveFree.first;
      _roomService.endGame(r.roomId, winner.uid);
    } else if (aliveFree.isEmpty && r.playerCount > 1) {
      // Everyone caught, denner wins? (edge case)
      final denner = _firstOrNull(r.players.values, (p) => p.isDenner);
      if (denner != null) {
        _roomService.endGame(r.roomId, denner.uid);
      }
    }
  }

  T? _firstOrNull<T>(Iterable<T> items, bool Function(T item) test) {
    for (final item in items) {
      if (test(item)) return item;
    }
    return null;
  }

  void _handleGameOver(RoomModel r) {
    if (gameOver.value) return;
    gameOver.value = true;
    _gameLoop.stop();

    final winner =
        r.players[r.winnerUid];
    winnerName.value = winner?.name ?? 'Unknown';
    isWinner.value = r.winnerUid == myUid;
  }

  void _handleRoomDeleted() {
    _gameLoop.stop();
    Get.offAllNamed(AppRoutes.home);
    Get.snackbar('Game Ended', 'The room was closed.');
  }

  // ─── Joystick input ───────────────────────────────────────────────
  void onJoystickMove(double x, double y) {
    joystickX = x;
    joystickY = y;
  }

  void onJoystickEnd() {
    joystickX = 0;
    joystickY = 0;
  }

  // ─── Spectator tap-to-move (for chain players) ───────────────────
  void onTapMove(Offset position) {
    if (!isAlive && !isDenner) return;
    // calculate direction toward tap
    final dx = position.dx - myPosX;
    final dy = position.dy - myPosY;
    final len = sqrt(dx * dx + dy * dy);
    if (len > 0) {
      joystickX = dx / len;
      joystickY = dy / len;
    }
  }

  @override
  void onClose() {
    _gameLoop.dispose();
    _roomSub?.cancel();
    _positionThrottle?.cancel();
    super.onClose();
  }
}
