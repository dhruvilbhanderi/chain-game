// lib/data/models/user_model.dart

class UserModel {
  final String uid;
  final String name;
  final String email;
  final String? photoUrl;
  final int avatarIndex;
  final int colorIndex;
  final int totalWins;
  final int totalGames;

  UserModel({
    required this.uid,
    required this.name,
    required this.email,
    this.photoUrl,
    this.avatarIndex = 0,
    this.colorIndex = 0,
    this.totalWins = 0,
    this.totalGames = 0,
  });

  factory UserModel.fromMap(Map<dynamic, dynamic> map, String uid) {
    return UserModel(
      uid: uid,
      name: map['name'] ?? 'Player',
      email: map['email'] ?? '',
      photoUrl: map['photoUrl'],
      avatarIndex: map['avatarIndex'] ?? 0,
      colorIndex: map['colorIndex'] ?? 0,
      totalWins: map['totalWins'] ?? 0,
      totalGames: map['totalGames'] ?? 0,
    );
  }

  Map<String, dynamic> toMap() => {
        'uid': uid,
        'name': name,
        'email': email,
        'photoUrl': photoUrl,
        'avatarIndex': avatarIndex,
        'colorIndex': colorIndex,
        'totalWins': totalWins,
        'totalGames': totalGames,
      };

  UserModel copyWith({
    String? name,
    String? photoUrl,
    int? avatarIndex,
    int? colorIndex,
    int? totalWins,
    int? totalGames,
  }) =>
      UserModel(
        uid: uid,
        name: name ?? this.name,
        email: email,
        photoUrl: photoUrl ?? this.photoUrl,
        avatarIndex: avatarIndex ?? this.avatarIndex,
        colorIndex: colorIndex ?? this.colorIndex,
        totalWins: totalWins ?? this.totalWins,
        totalGames: totalGames ?? this.totalGames,
      );
}
