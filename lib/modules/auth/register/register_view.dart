// lib/modules/auth/register/register_view.dart
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import '../auth_controller.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/constants/app_constants.dart';
import '../../../app/widgets/custom_button.dart';
import '../../../app/widgets/custom_text_field.dart';
import '../../../app/widgets/gradient_background.dart';

class RegisterView extends GetView<AuthController> {
  const RegisterView({super.key});

  @override
  Widget build(BuildContext context) {
    final nameCtrl = TextEditingController();
    final emailCtrl = TextEditingController();
    final passCtrl = TextEditingController();
    final confirmPassCtrl = TextEditingController();
    final formKey = GlobalKey<FormState>();
    final selectedAvatar = 0.obs;
    final selectedColor = 0.obs;

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
                  // Back button + title
                  Row(
                    children: [
                      IconButton(
                        onPressed: () => Get.back(),
                        icon: const Icon(Icons.arrow_back_ios,
                            color: AppColors.textPrimary),
                      ),
                      const Text(
                        'Create Account',
                        style: TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 24,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ).animate().fadeIn(),

                  const SizedBox(height: 24),

                  // Avatar picker
                  _AvatarPicker(
                    selectedIndex: selectedAvatar,
                    selectedColor: selectedColor,
                  ).animate().fadeIn(delay: 100.ms),

                  const SizedBox(height: 24),

                  CustomTextField(
                    controller: nameCtrl,
                    label: 'Display Name',
                    hint: 'Your cool name',
                    icon: Icons.person_outline,
                    validator: (v) =>
                        v!.isEmpty ? 'Enter your name' : null,
                  ).animate().fadeIn(delay: 150.ms),

                  const SizedBox(height: 14),

                  CustomTextField(
                    controller: emailCtrl,
                    label: 'Email',
                    hint: 'your@email.com',
                    icon: Icons.email_outlined,
                    keyboardType: TextInputType.emailAddress,
                    validator: (v) =>
                        !GetUtils.isEmail(v!) ? 'Enter valid email' : null,
                  ).animate().fadeIn(delay: 200.ms),

                  const SizedBox(height: 14),

                  CustomTextField(
                    controller: passCtrl,
                    label: 'Password',
                    hint: '••••••••',
                    icon: Icons.lock_outline,
                    isPassword: true,
                    validator: (v) =>
                        v!.length < 6 ? 'Min 6 characters' : null,
                  ).animate().fadeIn(delay: 250.ms),

                  const SizedBox(height: 14),

                  CustomTextField(
                    controller: confirmPassCtrl,
                    label: 'Confirm Password',
                    hint: '••••••••',
                    icon: Icons.lock_outline,
                    isPassword: true,
                    validator: (v) =>
                        v != passCtrl.text ? 'Passwords don\'t match' : null,
                  ).animate().fadeIn(delay: 300.ms),

                  const SizedBox(height: 12),

                  Obx(() => controller.errorMessage.value.isNotEmpty
                      ? Container(
                          padding: const EdgeInsets.all(12),
                          margin: const EdgeInsets.only(bottom: 8),
                          decoration: BoxDecoration(
                            color: AppColors.error.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            controller.errorMessage.value,
                            style:
                                const TextStyle(color: AppColors.error),
                          ),
                        )
                      : const SizedBox()),

                  const SizedBox(height: 8),

                  Obx(() => GradientButton(
                        label: 'Create Account',
                        isLoading: controller.isLoading.value,
                        onPressed: controller.isLoading.value
                            ? null
                            : () {
                                if (formKey.currentState!.validate()) {
                                  controller.register(
                                    name: nameCtrl.text.trim(),
                                    email: emailCtrl.text.trim(),
                                    password: passCtrl.text,
                                    avatarIndex: selectedAvatar.value,
                                    colorIndex: selectedColor.value,
                                  );
                                }
                              },
                      )).animate().fadeIn(delay: 400.ms),

                  const SizedBox(height: 20),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('Already have an account? ',
                          style:
                              TextStyle(color: AppColors.textSecondary)),
                      GestureDetector(
                        onTap: () => Get.back(),
                        child: const Text('Login',
                            style: TextStyle(
                                color: AppColors.primary,
                                fontWeight: FontWeight.w700)),
                      ),
                    ],
                  ).animate().fadeIn(delay: 450.ms),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _AvatarPicker extends StatelessWidget {
  final RxInt selectedIndex;
  final RxInt selectedColor;

  const _AvatarPicker({
    required this.selectedIndex,
    required this.selectedColor,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Choose Your Avatar',
          style: TextStyle(
            color: AppColors.textSecondary,
            fontSize: 13,
            fontWeight: FontWeight.w600,
            letterSpacing: 1,
          ),
        ),
        const SizedBox(height: 12),
        Obx(() => Wrap(
              spacing: 12,
              runSpacing: 12,
              children: List.generate(
                AppConstants.playerAvatars.length,
                (i) {
                  final isSelected = selectedIndex.value == i;
                  final color = Color(AppConstants.playerColors[
                      selectedColor.value % AppConstants.playerColors.length]);
                  return GestureDetector(
                    onTap: () {
                      selectedIndex.value = i;
                      selectedColor.value = i;
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: isSelected
                            ? color.withOpacity(0.3)
                            : AppColors.bgCardLight,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isSelected ? color : Colors.transparent,
                          width: 2.5,
                        ),
                        boxShadow: isSelected
                            ? [
                                BoxShadow(
                                  color: color.withOpacity(0.4),
                                  blurRadius: 12,
                                )
                              ]
                            : [],
                      ),
                      child: Center(
                        child: Text(
                          AppConstants.playerAvatars[i],
                          style: const TextStyle(fontSize: 28),
                        ),
                      ),
                    ),
                  );
                },
              ),
            )),
      ],
    );
  }
}
