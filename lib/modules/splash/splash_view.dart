import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';

import '../../app/routes/app_routes.dart';
import '../../app/widgets/gradient_background.dart';
import '../../core/theme/app_theme.dart';
import '../../data/services/auth_service.dart';

class SplashView extends StatefulWidget {
  const SplashView({super.key});

  @override
  State<SplashView> createState() => _SplashViewState();
}

class _SplashViewState extends State<SplashView>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulseController;
  Timer? _navigationTimer;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _navigationTimer = Timer(const Duration(seconds: 3), _goNext);
  }

  void _goNext() {
    if (!mounted) return;

    final authService = Get.find<AuthService>();
    final nextRoute =
        authService.currentUser != null ? AppRoutes.home : AppRoutes.login;
    Get.offAllNamed(nextRoute);
  }

  @override
  void dispose() {
    _navigationTimer?.cancel();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GradientBackground(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ScaleTransition(
                scale: Tween<double>(begin: 0.92, end: 1.08).animate(
                  CurvedAnimation(
                    parent: _pulseController,
                    curve: Curves.easeInOut,
                  ),
                ),
                child: Container(
                  width: 132,
                  height: 132,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: AppColors.primaryGradient,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.45),
                        blurRadius: 30,
                        spreadRadius: 6,
                      ),
                    ],
                  ),
                  child: const Center(
                    child: Text(
                      '⛓️',
                      style: TextStyle(fontSize: 58),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 28),
              const Text(
                'The Chain Game',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 30,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.6,
                ),
              ).animate().fadeIn(duration: 500.ms).slideY(begin: 0.2),
              const SizedBox(height: 8),
              const Text(
                'Catch • Chain • Win',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 14,
                  letterSpacing: 2.2,
                ),
              ).animate().fadeIn(delay: 150.ms, duration: 500.ms),
              const SizedBox(height: 40),
              const SizedBox(
                width: 28,
                height: 28,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                ),
              ).animate().fadeIn(delay: 250.ms, duration: 400.ms),
              const SizedBox(height: 16),
              const Text(
                'Loading your game...',
                style: TextStyle(
                  color: AppColors.textHint,
                  fontSize: 13,
                ),
              ).animate().fadeIn(delay: 300.ms, duration: 400.ms),
            ],
          ),
        ),
      ),
    );
  }
}
