import 'package:equatable/equatable.dart';

class RoomSession extends Equatable {
  final String roomId;
  final String roomName;
  final bool isLocked;
  final int unreadCount;
  final int lastAccessedAt;
  final int createdAt;

  const RoomSession({
    required this.roomId,
    required this.roomName,
    this.isLocked = false,
    this.unreadCount = 0,
    required this.lastAccessedAt,
    required this.createdAt,
  });

  RoomSession copyWith({
    String? roomId,
    String? roomName,
    bool? isLocked,
    int? unreadCount,
    int? lastAccessedAt,
    int? createdAt,
  }) {
    return RoomSession(
      roomId: roomId ?? this.roomId,
      roomName: roomName ?? this.roomName,
      isLocked: isLocked ?? this.isLocked,
      unreadCount: unreadCount ?? this.unreadCount,
      lastAccessedAt: lastAccessedAt ?? this.lastAccessedAt,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  List<Object?> get props => [
    roomId,
    roomName,
    isLocked,
    unreadCount,
    lastAccessedAt,
    createdAt,
  ];
}
