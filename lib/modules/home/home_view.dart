// lib/modules/home/home_view.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import '../auth/auth_controller.dart';
import '../lobby/lobby_controller.dart';
import '../../core/theme/app_theme.dart';
import '../../core/constants/app_constants.dart';
import '../../app/routes/app_routes.dart';
import '../../app/widgets/gradient_background.dart';
import '../../app/widgets/custom_button.dart';

class HomeView extends StatelessWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    final authCtrl = Get.find<AuthController>();
    final codeCtrl = TextEditingController();

    return Scaffold(
      body: GradientBackground(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              children: [
                const SizedBox(height: 20),

                // Header
                _buildHeader(authCtrl)
                    .animate()
                    .fadeIn()
                    .slideY(begin: -0.2),

                const SizedBox(height: 40),

                // Game banner / illustration
                _buildGameBanner()
                    .animate()
                    .fadeIn(delay: 150.ms)
                    .scale(begin: const Offset(0.9, 0.9)),

                const SizedBox(height: 40),

                // Create Room
                GradientButton(
                  label: '🎮  Create Room',
                  onPressed: () =>
                      _createRoom(authCtrl),
                ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.3),

                const SizedBox(height: 16),

                // Join Room
                _buildJoinSection(codeCtrl, authCtrl)
                    .animate()
                    .fadeIn(delay: 400.ms)
                    .slideY(begin: 0.3),

                const Spacer(),

                // Stats row
                Obx(() {
                  final user = authCtrl.userModel.value;
                  if (user == null) return const SizedBox();
                  return _buildStatsRow(user.totalGames, user.totalWins)
                      .animate()
                      .fadeIn(delay: 500.ms);
                }),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(AuthController authCtrl) => Row(
        children: [
          Obx(() {
            final user = authCtrl.userModel.value;
            final avatar = user != null
                ? AppConstants.playerAvatars[user.avatarIndex]
                : '🦊';
            return Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.2),
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.primary, width: 2),
              ),
              child: Center(child: Text(avatar, style: const TextStyle(fontSize: 24))),
            );
          }),
          const SizedBox(width: 12),
          Expanded(
            child: Obx(() => Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Hey, ${authCtrl.userModel.value?.name ?? 'Player'}!',
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const Text(
                      'Ready to catch some friends? 😈',
                      style: TextStyle(
                          color: AppColors.textSecondary, fontSize: 13),
                    ),
                  ],
                )),
          ),
          IconButton(
            onPressed: () => _showSignOutDialog(authCtrl),
            icon: const Icon(Icons.logout_rounded,
                color: AppColors.textSecondary),
          ),
        ],
      );

  Widget _buildGameBanner() => Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF1A1A35), Color(0xFF0D0D2B)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: AppColors.primary.withOpacity(0.3)),
        ),
        child: Column(
          children: [
            // Animated chain players preview
            SizedBox(
              height: 80,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Chain line
                  Positioned(
                    left: 60,
                    right: 60,
                    child: Container(
                      height: 3,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [AppColors.dennerColor, AppColors.chainColor],
                        ),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  // Players in chain
                  ...List.generate(4, (i) {
                    final emojis = ['😈', '🦊', '🐼', '🐸'];
                    final colors = [
                      AppColors.dennerColor,
                      AppColors.chainColor,
                      AppColors.chainColor,
                      AppColors.success,
                    ];
                    return Positioned(
                      left: 20.0 + i * 70,
                      child: Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: colors[i].withOpacity(0.2),
                          shape: BoxShape.circle,
                          border:
                              Border.all(color: colors[i], width: 2),
                        ),
                        child: Center(
                          child: Text(emojis[i],
                              style: const TextStyle(fontSize: 22)),
                        ),
                      ),
                    );
                  }),
                ],
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'The Chain Game',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 22,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              '2-8 players • Real-time • Catch & chain your friends!',
              style: TextStyle(
                  color: AppColors.textSecondary, fontSize: 12),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );

  Widget _buildJoinSection(
      TextEditingController codeCtrl, AuthController authCtrl) =>
      Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.bgCard,
          borderRadius: BorderRadius.circular(20),
          border:
              Border.all(color: const Color(0xFF2D2D50)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Join a Room',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: codeCtrl,
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 4,
                    ),
                    textCapitalization: TextCapitalization.characters,
                    decoration: InputDecoration(
                      hintText: 'ROOM CODE',
                      hintStyle: TextStyle(
                        color: AppColors.textHint,
                        fontSize: 16,
                        letterSpacing: 2,
                        fontWeight: FontWeight.w500,
                      ),
                      filled: true,
                      fillColor: AppColors.bgCardLight,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 14),
                    ),
                    inputFormatters: [
                      LengthLimitingTextInputFormatter(6),
                      FilteringTextInputFormatter.allow(RegExp(r'[A-Za-z0-9]')),
                    ],
                    onChanged: (v) => codeCtrl.text = v.toUpperCase(),
                  ),
                ),
                const SizedBox(width: 12),
                ElevatedButton(
                  onPressed: () => _joinRoom(codeCtrl.text, authCtrl),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.accent,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 16),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                  ),
                  child: const Icon(Icons.arrow_forward_rounded,
                      color: Colors.white),
                ),
              ],
            ),
          ],
        ),
      );

  Widget _buildStatsRow(int games, int wins) => Row(
        children: [
          _statCard('🎮', '$games', 'Games Played'),
          const SizedBox(width: 12),
          _statCard('🏆', '$wins', 'Times Won'),
          const SizedBox(width: 12),
          _statCard(
            '📊',
            games > 0 ? '${((wins / games) * 100).toStringAsFixed(0)}%' : '-',
            'Win Rate',
          ),
        ],
      );

  Widget _statCard(String icon, String value, String label) => Expanded(
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
          decoration: BoxDecoration(
            color: AppColors.bgCard,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFF2D2D50)),
          ),
          child: Column(
            children: [
              Text(icon, style: const TextStyle(fontSize: 20)),
              const SizedBox(height: 6),
              Text(
                value,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                ),
              ),
              Text(
                label,
                style: const TextStyle(
                    color: AppColors.textHint, fontSize: 10),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );

  void _createRoom(AuthController authCtrl) async {
    final user = authCtrl.userModel.value;
    if (user == null) return;

    Get.dialog(
      const Center(child: CircularProgressIndicator()),
      barrierDismissible: false,
    );

    try {
      final ctrl = Get.find<LobbyController>();
      await ctrl.createRoom(user);
      Get.back(); // close dialog
      Get.toNamed(AppRoutes.lobby);
    } catch (e) {
      Get.back();
      Get.snackbar('Error', 'Could not create room. Try again.',
          backgroundColor: AppColors.error,
          colorText: Colors.white);
    }
  }

  void _joinRoom(String code, AuthController authCtrl) async {
    if (code.length < 6) {
      Get.snackbar('Invalid Code', 'Enter a 6-character room code',
          backgroundColor: AppColors.bgCard, colorText: AppColors.textPrimary);
      return;
    }
    final user = authCtrl.userModel.value;
    if (user == null) return;

    Get.dialog(
      const Center(child: CircularProgressIndicator()),
      barrierDismissible: false,
    );

    try {
      final ctrl = Get.find<LobbyController>();
      await ctrl.joinRoom(code, user);
      Get.back();
      Get.toNamed(AppRoutes.lobby);
    } catch (e) {
      Get.back();
      String msg = 'Could not join room.';
      if (e.toString().contains('game_already_started')) {
        msg = 'Game already started!';
      } else if (e.toString().contains('room_full')) {
        msg = 'Room is full!';
      } else if (e.toString().contains('not found') ||
          e.toString().contains('null')) {
        msg = 'Room not found. Check the code.';
      }
      Get.snackbar('Error', msg,
          backgroundColor: AppColors.error, colorText: Colors.white);
    }
  }

  void _showSignOutDialog(AuthController authCtrl) {
    Get.dialog(
      AlertDialog(
        backgroundColor: AppColors.bgCard,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Sign Out',
            style: TextStyle(color: AppColors.textPrimary)),
        content: const Text('Are you sure you want to sign out?',
            style: TextStyle(color: AppColors.textSecondary)),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel',
                style: TextStyle(color: AppColors.textSecondary)),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();
              authCtrl.signOut();
            },
            style:
                ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('Sign Out'),
          ),
        ],
      ),
    );
  }
}
