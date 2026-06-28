// lib/app/routes/app_pages.dart
import 'package:get/get.dart';
import '../../modules/auth/auth_controller.dart';
import '../../modules/splash/splash_view.dart';
import '../../modules/auth/login/login_view.dart';
import '../../modules/auth/register/register_view.dart';
import '../../modules/auth/forgot_password/forgot_password_view.dart';
import '../../modules/home/home_view.dart';
import '../../modules/lobby/lobby_controller.dart';
import '../../modules/lobby/lobby_view.dart';
import '../../modules/game/game_controller.dart';
import '../../modules/game/game_view.dart';
import 'app_routes.dart';

class AppPages {
  static final pages = [
    GetPage(
      name: AppRoutes.splash,
      page: () => const SplashView(),
    ),
    GetPage(
      name: AppRoutes.login,
      page: () => const LoginView(),
      binding: BindingsBuilder(() {
        Get.lazyPut<AuthController>(() => AuthController());
      }),
    ),
    GetPage(
      name: AppRoutes.register,
      page: () => const RegisterView(),
    ),
    GetPage(
      name: AppRoutes.forgotPassword,
      page: () => const ForgotPasswordView(),
    ),
    GetPage(
      name: AppRoutes.home,
      page: () => const HomeView(),
      binding: BindingsBuilder(() {
        // LobbyController stays alive across home/lobby/game
        if (!Get.isRegistered<LobbyController>()) {
          Get.put(LobbyController(), permanent: true);
        }
      }),
    ),
    GetPage(
      name: AppRoutes.lobby,
      page: () => const LobbyView(),
    ),
    GetPage(
      name: AppRoutes.game,
      page: () => const GameView(),
      binding: BindingsBuilder(() {
        Get.put(GameController());
      }),
    ),
  ];
}
