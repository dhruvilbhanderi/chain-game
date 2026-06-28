// lib/data/models/room_model.dart

enum RoomStatus { waiting, countdown, playing, finished }
enum PlayerStatus { alive, inChain, winner }

class PlayerInRoom {
  final String uid;
  final String name;
  final String avatar;
  final int colorIndex;
  final bool isDenner;       // First catcher
  final bool isInChain;      // Caught and part of chain
  final int chainPosition;   // Position in the chain (0 = denner)
  final double posX;
  final double posY;
  final double velocityX;
  final double velocityY;
  final bool isAlive;        // Still free (not caught)
  final bool isHost;
  final bool isReady;

  PlayerInRoom({
    required this.uid,
    required this.name,
    required this.avatar,
    required this.colorIndex,
    this.isDenner = false,
    this.isInChain = false,
    this.chainPosition = -1,
    this.posX = 200,
    this.posY = 200,
    this.velocityX = 0,
    this.velocityY = 0,
    this.isAlive = true,
    this.isHost = false,
    this.isReady = false,
  });

  factory PlayerInRoom.fromMap(Map<dynamic, dynamic> map, String uid) {
    return PlayerInRoom(
      uid: uid,
      name: map['name'] ?? 'Player',
      avatar: map['avatar'] ?? '🦊',
      colorIndex: map['colorIndex'] ?? 0,
      isDenner: map['isDenner'] ?? false,
      isInChain: map['isInChain'] ?? false,
      chainPosition: map['chainPosition'] ?? -1,
      posX: (map['posX'] ?? 200.0).toDouble(),
      posY: (map['posY'] ?? 200.0).toDouble(),
      velocityX: (map['velocityX'] ?? 0.0).toDouble(),
      velocityY: (map['velocityY'] ?? 0.0).toDouble(),
      isAlive: map['isAlive'] ?? true,
      isHost: map['isHost'] ?? false,
      isReady: map['isReady'] ?? false,
    );
  }

  Map<String, dynamic> toMap() => {
        'uid': uid,
        'name': name,
        'avatar': avatar,
        'colorIndex': colorIndex,
        'isDenner': isDenner,
        'isInChain': isInChain,
        'chainPosition': chainPosition,
        'posX': posX,
        'posY': posY,
        'velocityX': velocityX,
        'velocityY': velocityY,
        'isAlive': isAlive,
        'isHost': isHost,
        'isReady': isReady,
      };

  PlayerInRoom copyWith({
    bool? isDenner,
    bool? isInChain,
    int? chainPosition,
    double? posX,
    double? posY,
    double? velocityX,
    double? velocityY,
    bool? isAlive,
    bool? isReady,
  }) =>
      PlayerInRoom(
        uid: uid,
        name: name,
        avatar: avatar,
        colorIndex: colorIndex,
        isDenner: isDenner ?? this.isDenner,
        isInChain: isInChain ?? this.isInChain,
        chainPosition: chainPosition ?? this.chainPosition,
        posX: posX ?? this.posX,
        posY: posY ?? this.posY,
        velocityX: velocityX ?? this.velocityX,
        velocityY: velocityY ?? this.velocityY,
        isAlive: isAlive ?? this.isAlive,
        isHost: isHost,
        isReady: isReady ?? this.isReady,
      );
}

class RoomModel {
  final String roomId;
  final String roomCode;
  final String hostUid;
  final RoomStatus status;
  final Map<String, PlayerInRoom> players;
  final int countdown;
  final String? winnerUid;
  final DateTime createdAt;

  RoomModel({
    required this.roomId,
    required this.roomCode,
    required this.hostUid,
    this.status = RoomStatus.waiting,
    this.players = const {},
    this.countdown = 0,
    this.winnerUid,
    required this.createdAt,
  });

  int get playerCount => players.length;
  bool get canStart => playerCount >= 2 && status == RoomStatus.waiting;

  List<PlayerInRoom> get chainPlayers =>
      players.values.where((p) => p.isInChain || p.isDenner).toList()
        ..sort((a, b) => a.chainPosition.compareTo(b.chainPosition));

  List<PlayerInRoom> get alivePlayers =>
      players.values.where((p) => p.isAlive && !p.isInChain && !p.isDenner).toList();

  factory RoomModel.fromMap(Map<dynamic, dynamic> map, String roomId) {
    final playersMap = <String, PlayerInRoom>{};
    if (map['players'] != null) {
      (map['players'] as Map<dynamic, dynamic>).forEach((k, v) {
        playersMap[k.toString()] = PlayerInRoom.fromMap(v, k.toString());
      });
    }

    return RoomModel(
      roomId: roomId,
      roomCode: map['roomCode'] ?? '',
      hostUid: map['hostUid'] ?? '',
      status: RoomStatus.values.firstWhere(
        (e) => e.name == (map['status'] ?? 'waiting'),
        orElse: () => RoomStatus.waiting,
      ),
      players: playersMap,
      countdown: map['countdown'] ?? 0,
      winnerUid: map['winnerUid'],
      createdAt: map['createdAt'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['createdAt'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() => {
        'roomId': roomId,
        'roomCode': roomCode,
        'hostUid': hostUid,
        'status': status.name,
        'players': players.map((k, v) => MapEntry(k, v.toMap())),
        'countdown': countdown,
        'winnerUid': winnerUid,
        'createdAt': createdAt.millisecondsSinceEpoch,
      };
}
