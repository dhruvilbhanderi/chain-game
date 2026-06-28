// lib/modules/auth/forgot_password/forgot_password_view.dart
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import '../auth_controller.dart';
import '../../../core/theme/app_theme.dart';
import '../../../app/widgets/custom_button.dart';
import '../../../app/widgets/custom_text_field.dart';
import '../../../app/widgets/gradient_background.dart';

class ForgotPasswordView extends GetView<AuthController> {
  const ForgotPasswordView({super.key});

  @override
  Widget build(BuildContext context) {
    final emailCtrl = TextEditingController();
    final formKey = GlobalKey<FormState>();
    final sent = false.obs;

    return Scaffold(
      body: GradientBackground(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            child: Form(
              key: formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      IconButton(
                        onPressed: () => Get.back(),
                        icon: const Icon(Icons.arrow_back_ios,
                            color: AppColors.textPrimary),
                      ),
                    ],
                  ),

                  const SizedBox(height: 32),

                  // Icon
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.15),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.lock_reset_rounded,
                      color: AppColors.primary,
                      size: 40,
                    ),
                  ).animate().scale(duration: 500.ms, curve: Curves.elasticOut),

                  const SizedBox(height: 24),

                  const Text(
                    'Forgot Password?',
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                    ),
                    textAlign: TextAlign.center,
                  ).animate().fadeIn(delay: 100.ms),

                  const SizedBox(height: 8),

                  const Text(
                    'Enter your email and we\'ll send you a reset link.',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 15,
                    ),
                    textAlign: TextAlign.center,
                  ).animate().fadeIn(delay: 150.ms),

                  const SizedBox(height: 40),

                  Obx(() => sent.value
                      ? _buildSuccessCard()
                      : Column(
                          children: [
                            CustomTextField(
                              controller: emailCtrl,
                              label: 'Email',
                              hint: 'your@email.com',
                              icon: Icons.email_outlined,
                              keyboardType: TextInputType.emailAddress,
                              validator: (v) => !GetUtils.isEmail(v!)
                                  ? 'Enter valid email'
                                  : null,
                            ).animate().fadeIn(delay: 200.ms),

                            const SizedBox(height: 16),

                            Obx(() =>
                                controller.errorMessage.value.isNotEmpty
                                    ? Text(
                                        controller.errorMessage.value,
                                        style: const TextStyle(
                                            color: AppColors.error),
                                        textAlign: TextAlign.center,
                                      )
                                    : const SizedBox()),

                            const SizedBox(height: 16),

                            Obx(() => GradientButton(
                                  label: 'Send Reset Link',
                                  isLoading: controller.isLoading.value,
                                  onPressed: controller.isLoading.value
                                      ? null
                                      : () async {
                                          if (formKey.currentState!
                                              .validate()) {
                                            final ok = await controller
                                                .sendPasswordReset(
                                                    emailCtrl.text.trim());
                                            if (ok) sent.value = true;
                                          }
                                        },
                                )).animate().fadeIn(delay: 300.ms),
                          ],
                        )),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSuccessCard() => Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: AppColors.success.withOpacity(0.15),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.success.withOpacity(0.3)),
        ),
        child: Column(
          children: [
            const Icon(Icons.mark_email_read_rounded,
                color: AppColors.success, size: 48),
            const SizedBox(height: 16),
            const Text(
              'Reset link sent!',
              style: TextStyle(
                color: AppColors.success,
                fontSize: 20,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Check your email inbox and follow the instructions to reset your password.',
              style: TextStyle(color: AppColors.textSecondary),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            OutlinedButton(
              onPressed: () => Get.back(),
              style: OutlinedButton.styleFrom(
                side:
                    const BorderSide(color: AppColors.success),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('Back to Login',
                  style: TextStyle(color: AppColors.success)),
            ),
          ],
        ),
      ).animate().scale(duration: 400.ms, curve: Curves.elasticOut);
}
