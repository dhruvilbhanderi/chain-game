// lib/modules/game/game_view.dart
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_joystick/flutter_joystick.dart';
import 'package:get/get.dart';
import 'game_controller.dart';
import '../../core/theme/app_theme.dart';
import '../../core/constants/app_constants.dart';
import '../../data/models/room_model.dart';
import '../../app/routes/app_routes.dart';

class GameView extends GetView<GameController> {
  const GameView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A1A),
      body: Obx(() {
        final room = controller.room.value;
        if (room == null) {
          return const Center(child: CircularProgressIndicator());
        }

        // Countdown overlay
        if (room.status == RoomStatus.countdown) {
          return _CountdownOverlay(countdown: controller.countdown.value);
        }

        // Game over overlay
        if (controller.gameOver.value) {
          return _GameOverScreen(
            winnerName: controller.winnerName.value,
            isWinner: controller.isWinner.value,
          );
        }

        return SafeArea(
          child: Stack(
            children: [
              // Game canvas
              _GameCanvas(room: room, ctrl: controller),

              // HUD - top bar
              _HUD(room: room, ctrl: controller),

              // Role indicator
              _RoleIndicator(ctrl: controller),

              // Joystick (bottom right) - only for alive/denner/chain players
              if (controller.isAlive ||
                  controller.isDenner ||
                  controller.isInChain)
                Positioned(
                  bottom: 30,
                  right: 30,
                  child: Joystick(
                    mode: JoystickMode.all,
                    listener: (details) {
                      controller.onJoystickMove(details.x, details.y);
                    },
                  ),
                ),
            ],
          ),
        );
      }),
    );
  }
}

// ─── Game Canvas ─────────────────────────────────────────────────────
class _GameCanvas extends StatelessWidget {
  final RoomModel room;
  final GameController ctrl;

  const _GameCanvas({required this.room, required this.ctrl});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        ctrl.mapWidth = constraints.maxWidth;
        ctrl.mapHeight = constraints.maxHeight;

        return GestureDetector(
          onTapDown: (d) => ctrl.onTapMove(d.localPosition),
          child: AnimatedBuilder(
            animation: ctrl,
            builder: (context, _) => CustomPaint(
              size: Size(constraints.maxWidth, constraints.maxHeight),
              painter: _GamePainter(room: room, myUid: ctrl.myUid),
            ),
          ),
        );
      },
    );
  }
}

class _GamePainter extends CustomPainter {
  final RoomModel room;
  final String myUid;

  _GamePainter({required this.room, required this.myUid});

  @override
  void paint(Canvas canvas, Size size) {
    // Background grid
    _drawGrid(canvas, size);

    // Draw chains between chained players
    _drawChains(canvas);

    // Draw players
    for (final player in room.players.values) {
      _drawPlayer(canvas, player, player.uid == myUid);
    }
  }

  void _drawGrid(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF1A1A35)
      ..strokeWidth = 1;

    for (double x = 0; x < size.width; x += 60) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y < size.height; y += 60) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  void _drawChains(Canvas canvas) {
    final chainPlayers = room.chainPlayers;
    if (chainPlayers.length < 2) return;

    for (int i = 0; i < chainPlayers.length - 1; i++) {
      final a = chainPlayers[i];
      final b = chainPlayers[i + 1];

      // Draw glowing chain line
      final paint = Paint()
        ..shader = LinearGradient(
          colors: [
            const Color(0xFFFF6B6B).withOpacity(0.8),
            const Color(0xFF6C5CE7).withOpacity(0.8),
          ],
        ).createShader(Rect.fromPoints(
          Offset(a.posX, a.posY),
          Offset(b.posX, b.posY),
        ))
        ..strokeWidth = 4
        ..strokeCap = StrokeCap.round;

      canvas.drawLine(Offset(a.posX, a.posY), Offset(b.posX, b.posY), paint);

      // Glow effect
      final glowPaint = Paint()
        ..color = AppColors.chainColor.withOpacity(0.2)
        ..strokeWidth = 12
        ..strokeCap = StrokeCap.round;
      canvas.drawLine(
          Offset(a.posX, a.posY), Offset(b.posX, b.posY), glowPaint);
    }
  }

  void _drawPlayer(Canvas canvas, PlayerInRoom player, bool isMe) {
    final color = Color(
        AppConstants.playerColors[player.colorIndex % AppConstants.playerColors.length]);
    final pos = Offset(player.posX, player.posY);
    const radius = 24.0;

    // Glow for denner
    if (player.isDenner) {
      canvas.drawCircle(
        pos,
        radius + 12,
        Paint()..color = AppColors.dennerColor.withOpacity(0.3),
      );
    }

    // Glow for "me"
    if (isMe) {
      canvas.drawCircle(
        pos,
        radius + 8,
        Paint()..color = Colors.white.withOpacity(0.15),
      );
    }

    // Player circle background
    canvas.drawCircle(
      pos,
      radius,
      Paint()..color = color.withOpacity(0.25),
    );

    // Border
    canvas.drawCircle(
      pos,
      radius,
      Paint()
        ..color = player.isDenner ? AppColors.dennerColor : color
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3,
    );

    // Emoji avatar (using TextPainter)
    final tp = TextPainter(
      text: TextSpan(
        text: player.avatar,
        style: const TextStyle(fontSize: 20),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas,
        Offset(pos.dx - tp.width / 2, pos.dy - tp.height / 2));

    // Name tag
    final namePainter = TextPainter(
      text: TextSpan(
        text: isMe ? '${player.name} ★' : player.name,
        style: TextStyle(
          color: isMe ? Colors.white : Colors.white70,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    namePainter.paint(
      canvas,
      Offset(
          pos.dx - namePainter.width / 2, pos.dy + radius + 4),
    );

    // Denner / Chain badge
    if (player.isDenner) {
      _drawBadge(canvas, pos, radius, '😈');
    } else if (player.isInChain) {
      _drawBadge(canvas, pos, radius, '⛓️');
    }
  }

  void _drawBadge(Canvas canvas, Offset center, double radius, String emoji) {
    const badgeRadius = 12.0;
    final badgePos = Offset(center.dx + radius * 0.7, center.dy - radius * 0.7);

    canvas.drawCircle(badgePos, badgeRadius,
        Paint()..color = AppColors.bgDark);

    final tp = TextPainter(
      text: TextSpan(text: emoji, style: const TextStyle(fontSize: 14)),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas,
        Offset(badgePos.dx - tp.width / 2, badgePos.dy - tp.height / 2));
  }

  @override
  bool shouldRepaint(_GamePainter old) => true;
}

// ─── HUD ─────────────────────────────────────────────────────────────
class _HUD extends StatelessWidget {
  final RoomModel room;
  final GameController ctrl;

  const _HUD({required this.room, required this.ctrl});

  @override
  Widget build(BuildContext context) {
    final free = room.alivePlayers.length;
    final chained = room.chainPlayers.length;

    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.black87,
              Colors.transparent,
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Row(
          children: [
            _hudChip('⛓️ Chain', '$chained', AppColors.chainColor),
            const SizedBox(width: 12),
            _hudChip('🏃 Free', '$free', AppColors.success),
            const Spacer(),
            _hudChip('👥', '${room.playerCount}', AppColors.textSecondary),
          ],
        ),
      ),
    );
  }

  Widget _hudChip(String label, String value, Color color) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: color.withOpacity(0.15),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withOpacity(0.4)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(label,
                style: TextStyle(color: color, fontSize: 12)),
            const SizedBox(width: 4),
            Text(value,
                style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.w800,
                    fontSize: 14)),
          ],
        ),
      );
}

// ─── Role Indicator ───────────────────────────────────────────────────
class _RoleIndicator extends StatelessWidget {
  final GameController ctrl;

  const _RoleIndicator({required this.ctrl});

  @override
  Widget build(BuildContext context) {
    String role;
    Color color;
    String emoji;

    if (ctrl.isDenner) {
      role = 'YOU\'RE THE DENNER!';
      color = AppColors.dennerColor;
      emoji = '😈';
    } else if (ctrl.isInChain) {
      role = 'YOU\'RE CHAINED!';
      color = AppColors.chainColor;
      emoji = '⛓️';
    } else {
      role = 'STAY FREE!';
      color = AppColors.success;
      emoji = '🏃';
    }

    return Positioned(
      bottom: 110,
      left: 20,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.15),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withOpacity(0.5)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(emoji),
            const SizedBox(width: 6),
            Text(role,
                style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.w700,
                    fontSize: 12,
                    letterSpacing: 0.5)),
          ],
        ),
      ),
    );
  }
}

// ─── Countdown Overlay ────────────────────────────────────────────────
class _CountdownOverlay extends StatelessWidget {
  final String countdown;

  const _CountdownOverlay({required this.countdown});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black87,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Game starts in',
                style: TextStyle(
                    color: AppColors.textSecondary, fontSize: 18)),
            const SizedBox(height: 12),
            Text(
              countdown,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 100,
                fontWeight: FontWeight.w900,
              ),
            )
                .animate(key: ValueKey(countdown))
                .scale(
                    begin: const Offset(0.5, 0.5),
                    duration: 400.ms,
                    curve: Curves.elasticOut)
                .fadeIn(),
          ],
        ),
      ),
    );
  }
}

// ─── Game Over Screen ─────────────────────────────────────────────────
class _GameOverScreen extends StatelessWidget {
  final String winnerName;
  final bool isWinner;

  const _GameOverScreen(
      {required this.winnerName, required this.isWinner});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(gradient: AppColors.bgGradient),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              isWinner ? '🏆' : '😅',
              style: const TextStyle(fontSize: 80),
            )
                .animate()
                .scale(
                    duration: 600.ms, curve: Curves.elasticOut)
                .fadeIn(),

            const SizedBox(height: 20),

            Text(
              isWinner ? 'YOU WIN!' : 'GAME OVER',
              style: TextStyle(
                color: isWinner ? AppColors.gold : AppColors.textSecondary,
                fontSize: 40,
                fontWeight: FontWeight.w900,
              ),
            ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.3),

            const SizedBox(height: 12),

            Text(
              isWinner
                  ? 'You stayed free to the end! 🎉'
                  : '$winnerName stayed free and wins!',
              style: const TextStyle(
                  color: AppColors.textSecondary, fontSize: 16),
              textAlign: TextAlign.center,
            ).animate().fadeIn(delay: 350.ms),

            const SizedBox(height: 40),

            ElevatedButton.icon(
              onPressed: () => Get.offAllNamed(AppRoutes.home),
              icon: const Icon(Icons.home_rounded),
              label: const Text('Back to Home'),
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    isWinner ? AppColors.gold : AppColors.primary,
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(
                    horizontal: 32, vertical: 16),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
              ),
            ).animate().fadeIn(delay: 500.ms).slideY(begin: 0.3),
          ],
        ),
      ),
    );
  }
}
