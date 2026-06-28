// lib/modules/auth/auth_controller.dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import '../../data/models/user_model.dart';
import '../../data/services/auth_service.dart';
import '../../app/routes/app_routes.dart';

class AuthController extends GetxController {
  final AuthService _authService = Get.find();

  final Rx<UserModel?> userModel = Rx<UserModel?>(null);
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;

  @override
  void onInit() {
    super.onInit();
    // Listen to auth state changes
    ever(isLoading, (_) {});
    _authService.authStateChanges.listen(_onAuthChanged);
  }

  Future<void> _onAuthChanged(User? user) async {
    if (user == null) {
      userModel.value = null;
      Get.offAllNamed(AppRoutes.login);
    } else {
      final profile = await _authService.getUserProfile(user.uid);
      userModel.value = profile;
      Get.offAllNamed(AppRoutes.home);
    }
  }

  // ─── Register ─────────────────────────────────────────────────────
  Future<void> register({
    required String name,
    required String email,
    required String password,
    required int avatarIndex,
    required int colorIndex,
  }) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';
      await _authService.registerWithEmail(
        name: name,
        email: email,
        password: password,
        avatarIndex: avatarIndex,
        colorIndex: colorIndex,
      );
    } on FirebaseAuthException catch (e) {
      errorMessage.value = _getAuthError(e.code);
    } catch (e) {
      errorMessage.value = 'something_went_wrong'.tr;
    } finally {
      isLoading.value = false;
    }
  }

  // ─── Login ────────────────────────────────────────────────────────
  Future<void> login({
    required String email,
    required String password,
  }) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';
      await _authService.signInWithEmail(email: email, password: password);
    } on FirebaseAuthException catch (e) {
      errorMessage.value = _getAuthError(e.code);
    } catch (e) {
      errorMessage.value = 'something_went_wrong'.tr;
    } finally {
      isLoading.value = false;
    }
  }

  // ─── Google Sign In ───────────────────────────────────────────────
  Future<void> signInWithGoogle() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';
      final cred = await _authService.signInWithGoogle();
      if (cred == null) errorMessage.value = 'google_sign_in_cancelled'.tr;
    } catch (e) {
      errorMessage.value = 'google_sign_in_failed'.tr;
    } finally {
      isLoading.value = false;
    }
  }

  // ─── Forgot Password ──────────────────────────────────────────────
  Future<bool> sendPasswordReset(String email) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';
      await _authService.sendPasswordResetEmail(email);
      return true;
    } on FirebaseAuthException catch (e) {
      errorMessage.value = _getAuthError(e.code);
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  // ─── Sign Out ─────────────────────────────────────────────────────
  Future<void> signOut() async {
    await _authService.signOut();
  }

  // ─── Error messages ───────────────────────────────────────────────
  String _getAuthError(String code) {
    switch (code) {
      case 'email-already-in-use':
        return 'email_already_in_use'.tr;
      case 'invalid-email':
        return 'invalid_email'.tr;
      case 'weak-password':
        return 'weak_password'.tr;
      case 'user-not-found':
        return 'user_not_found'.tr;
      case 'wrong-password':
        return 'wrong_password'.tr;
      case 'too-many-requests':
        return 'too_many_requests'.tr;
      default:
        return 'something_went_wrong'.tr;
    }
  }
}
