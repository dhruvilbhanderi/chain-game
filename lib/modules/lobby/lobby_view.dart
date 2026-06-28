// lib/modules/lobby/lobby_view.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import '../auth/auth_controller.dart';
import 'lobby_controller.dart';
import '../../core/theme/app_theme.dart';
import '../../core/constants/app_constants.dart';
import '../../app/widgets/gradient_background.dart';
import '../../data/models/room_model.dart';

class LobbyView extends StatelessWidget {
  const LobbyView({super.key});

  @override
  Widget build(BuildContext context) {
    final lobbyCtrl = Get.find<LobbyController>();
    final authCtrl = Get.find<AuthController>();
    final myUid = authCtrl.userModel.value?.uid ?? '';

    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) async {
        if (!didPop) {
          final confirm = await Get.dialog<bool>(
            AlertDialog(
              backgroundColor: AppColors.bgCard,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20)),
              title: const Text('Leave Room?',
                  style: TextStyle(color: AppColors.textPrimary)),
              content: const Text(
                  'Are you sure you want to leave this room?',
                  style: TextStyle(color: AppColors.textSecondary)),
              actions: [
                TextButton(
                    onPressed: () => Get.back(result: false),
                    child: const Text('Stay')),
                ElevatedButton(
                  onPressed: () => Get.back(result: true),
                  style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.error),
                  child: const Text('Leave'),
                ),
              ],
            ),
          );
          if (confirm == true) {
            await lobbyCtrl.leaveRoom(myUid);
            Get.back();
          }
        }
      },
      child: Scaffold(
        body: GradientBackground(
          child: SafeArea(
            child: Obx(() {
              final room = lobbyCtrl.currentRoom.value;
              if (room == null) {
                return const Center(child: CircularProgressIndicator());
              }
              final isHost = room.hostUid == myUid;

              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 20),

                    // Header
                    _buildHeader(lobbyCtrl, myUid)
                        .animate()
                        .fadeIn()
                        .slideY(begin: -0.2),

                    const SizedBox(height: 24),

                    // Room Code Card
                    _buildRoomCodeCard(room.roomCode)
                        .animate()
                        .fadeIn(delay: 100.ms)
                        .scale(begin: const Offset(0.9, 0.9)),

                    const SizedBox(height: 24),

                    // Players title
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Players (${room.playerCount}/${AppConstants.maxPlayers})',
                          style: const TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 1,
                          ),
                        ),
                        if (room.playerCount >= AppConstants.minPlayers)
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppColors.success.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Text(
                              '✓ Ready to Start',
                              style: TextStyle(
                                  color: AppColors.success, fontSize: 11),
                            ),
                          ),
                      ],
                    ).animate().fadeIn(delay: 200.ms),

                    const SizedBox(height: 12),

                    // Players list
                    Expanded(
                      child: ListView.builder(
                        itemCount: room.players.length,
                        itemBuilder: (context, i) {
                          final player =
                              room.players.values.toList()[i];
                          return _PlayerCard(
                            player: player,
                            isMe: player.uid == myUid,
                          )
                              .animate()
                              .fadeIn(delay: Duration(milliseconds: 250 + i * 80))
                              .slideX(begin: 0.3);
                        },
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Start button (host only)
                    if (isHost)
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        child: ElevatedButton(
                          onPressed: room.canStart
                              ? lobbyCtrl.startGame
                              : null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: room.canStart
                                ? AppColors.success
                                : AppColors.bgCardLight,
                            disabledBackgroundColor:
                                AppColors.bgCardLight,
                            padding: const EdgeInsets.symmetric(vertical: 18),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(18)),
                          ),
                          child: Text(
                            room.canStart
                                ? '🚀  Start Game  (${room.playerCount} players)'
                                : 'Waiting for more players...',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.3)
                    else
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.bgCard,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                              color: const Color(0xFF2D2D50)),
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: AppColors.primaryLight,
                              ),
                            ),
                            SizedBox(width: 10),
                            Text(
                              'Waiting for host to start...',
                              style: TextStyle(
                                  color: AppColors.textSecondary),
                            ),
                          ],
                        ),
                      ).animate().fadeIn(delay: 400.ms),

                    const SizedBox(height: 20),
                  ],
                ),
              );
            }),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(LobbyController ctrl, String myUid) => Row(
        children: [
          IconButton(
            onPressed: () async {
              await ctrl.leaveRoom(myUid);
              Get.back();
            },
            icon: const Icon(Icons.arrow_back_ios,
                color: AppColors.textPrimary),
          ),
          const Expanded(
            child: Text(
              'Lobby',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 22,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      );

  Widget _buildRoomCodeCard(String code) => Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [AppColors.primary, Color(0xFF8E44AD)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withOpacity(0.4),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          children: [
            const Text(
              'ROOM CODE',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 12,
                fontWeight: FontWeight.w600,
                letterSpacing: 2,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              code,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 38,
                fontWeight: FontWeight.w900,
                letterSpacing: 8,
              ),
            ),
            const SizedBox(height: 12),
            GestureDetector(
              onTap: () {
                Clipboard.setData(ClipboardData(text: code));
                Get.snackbar(
                  '✓ Copied!',
                  'Room code copied to clipboard',
                  snackPosition: SnackPosition.BOTTOM,
                  backgroundColor: Colors.white24,
                  colorText: Colors.white,
                  duration: const Duration(seconds: 2),
                );
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.copy_rounded,
                        color: Colors.white, size: 16),
                    SizedBox(width: 6),
                    Text('Share Code',
                        style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600)),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
}

class _PlayerCard extends StatelessWidget {
  final dynamic player;
  final bool isMe;

  const _PlayerCard({required this.player, required this.isMe});

  @override
  Widget build(BuildContext context) {
    final color =
        Color(AppConstants.playerColors[player.colorIndex % AppConstants.playerColors.length]);

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: isMe
            ? AppColors.primary.withOpacity(0.15)
            : AppColors.bgCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isMe ? AppColors.primary : const Color(0xFF2D2D50),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              shape: BoxShape.circle,
              border: Border.all(color: color, width: 2),
            ),
            child: Center(
              child: Text(player.avatar,
                  style: const TextStyle(fontSize: 22)),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              player.name + (isMe ? ' (You)' : ''),
              style: TextStyle(
                color: isMe
                    ? AppColors.primaryLight
                    : AppColors.textPrimary,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          if (player.isHost)
            Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.gold.withOpacity(0.15),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Text(
                '👑 Host',
                style: TextStyle(
                    color: AppColors.gold,
                    fontSize: 12,
                    fontWeight: FontWeight.w600),
              ),
            ),
        ],
      ),
    );
  }
}
