// lib/core/constants/app_constants.dart

class AppConstants {
  // App Info
  static const String appName = 'The Chain Game';
  static const String appVersion = '1.0.0';

  // Firebase Realtime DB paths
  static const String roomsPath = 'rooms';
  static const String playersPath = 'players';
  static const String gameStatePath = 'gameState';

  // Game Settings
  static const int minPlayers = 2;
  static const int maxPlayers = 8;
  static const double playerSpeed = 200.0;
  static const double chainBreakDistance = 180.0; // max pixels before chain "pulls"
  static const double catchRadius = 40.0;          // collision detection radius
  static const int countdownSeconds = 3;
  static const int roomCodeLength = 6;

  // Player Colors (hex)
  static const List<int> playerColors = [
    0xFFFF6B6B, // Red
    0xFF4ECDC4, // Teal
    0xFFFFE66D, // Yellow
    0xFF95E1D3, // Mint
    0xFFF38181, // Salmon
    0xFF6C5CE7, // Purple
    0xFF00B894, // Green
    0xFFE17055, // Orange
  ];

  // Avatar emojis
  static const List<String> playerAvatars = [
    '🦊', '🐼', '🐸', '🦄', '🐯', '🐙', '🦋', '🐉',
  ];
}
