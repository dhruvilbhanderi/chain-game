// lib/modules/auth/login/login_view.dart
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import '../auth_controller.dart';
import '../../../core/theme/app_theme.dart';
import '../../../app/routes/app_routes.dart';
import '../../../app/widgets/custom_button.dart';
import '../../../app/widgets/custom_text_field.dart';
import '../../../app/widgets/gradient_background.dart';

class LoginView extends GetView<AuthController> {
  const LoginView({super.key});

  @override
  Widget build(BuildContext context) {
    final emailCtrl = TextEditingController();
    final passCtrl = TextEditingController();
    final formKey = GlobalKey<FormState>();

    return Scaffold(
      body: GradientBackground(
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            child: Form(
              key: formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 40),

                  // Logo / Title
                  _buildLogo()
                      .animate()
                      .fadeIn(duration: 600.ms)
                      .slideY(begin: -0.3),

                  const SizedBox(height: 48),

                  // Email field
                  CustomTextField(
                    controller: emailCtrl,
                    label: 'Email',
                    hint: 'your@email.com',
                    icon: Icons.email_outlined,
                    keyboardType: TextInputType.emailAddress,
                    validator: (v) =>
                        v!.isEmpty ? 'Enter email' : null,
                  ).animate().fadeIn(delay: 200.ms).slideX(begin: -0.2),

                  const SizedBox(height: 16),

                  // Password field
                  CustomTextField(
                    controller: passCtrl,
                    label: 'Password',
                    hint: '••••••••',
                    icon: Icons.lock_outline,
                    isPassword: true,
                    validator: (v) =>
                        v!.length < 6 ? 'Min 6 characters' : null,
                  ).animate().fadeIn(delay: 300.ms).slideX(begin: -0.2),

                  // Forgot Password
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () =>
                          Get.toNamed(AppRoutes.forgotPassword),
                      child: const Text(
                        'Forgot Password?',
                        style: TextStyle(color: AppColors.primaryLight),
                      ),
                    ),
                  ).animate().fadeIn(delay: 350.ms),

                  const SizedBox(height: 8),

                  // Error message
                  Obx(() => controller.errorMessage.value.isNotEmpty
                      ? _buildError(controller.errorMessage.value)
                      : const SizedBox()),

                  const SizedBox(height: 8),

                  // Login Button
                  Obx(() => GradientButton(
                        onPressed: controller.isLoading.value
                            ? null
                            : () {
                                if (formKey.currentState!.validate()) {
                                  controller.login(
                                    email: emailCtrl.text.trim(),
                                    password: passCtrl.text,
                                  );
                                }
                              },
                        isLoading: controller.isLoading.value,
                        label: 'Login',
                      )).animate().fadeIn(delay: 400.ms).slideY(begin: 0.2),

                  const SizedBox(height: 20),

                  // Divider
                  _buildDivider()
                      .animate()
                      .fadeIn(delay: 450.ms),

                  const SizedBox(height: 20),

                  // Google Sign In
                  GoogleSignInButton(
                    onPressed: controller.signInWithGoogle,
                  ).animate().fadeIn(delay: 500.ms),

                  const SizedBox(height: 32),

                  // Register link
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        "Don't have an account? ",
                        style: TextStyle(color: AppColors.textSecondary),
                      ),
                      GestureDetector(
                        onTap: () => Get.toNamed(AppRoutes.register),
                        child: const Text(
                          'Register',
                          style: TextStyle(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ).animate().fadeIn(delay: 550.ms),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLogo() => Column(
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              gradient: AppColors.primaryGradient,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withOpacity(0.4),
                  blurRadius: 30,
                  spreadRadius: 5,
                ),
              ],
            ),
            child: const Center(
              child: Text('⛓️', style: TextStyle(fontSize: 48)),
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'The Chain Game',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 32,
              fontWeight: FontWeight.w900,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Catch • Chain • Win',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 16,
              letterSpacing: 2,
            ),
          ),
        ],
      );

  Widget _buildError(String msg) => Container(
        padding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        margin: const EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(
          color: AppColors.error.withOpacity(0.15),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.error.withOpacity(0.3)),
        ),
        child: Row(
          children: [
            const Icon(Icons.error_outline, color: AppColors.error, size: 18),
            const SizedBox(width: 8),
            Expanded(
              child: Text(msg,
                  style: const TextStyle(
                      color: AppColors.error, fontSize: 13)),
            ),
          ],
        ),
      );

  Widget _buildDivider() => Row(
        children: const [
          Expanded(child: Divider(color: Color(0xFF2D2D50))),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Text('OR',
                style: TextStyle(
                    color: AppColors.textHint, fontSize: 12)),
          ),
          Expanded(child: Divider(color: Color(0xFF2D2D50))),
        ],
      );
}
