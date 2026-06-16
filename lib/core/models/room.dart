import 'package:equatable/equatable.dart';

import 'user.dart';

class Room extends Equatable {
  final String id;
  final String name;
  final int usersCount;
  final int unreadCount;
  final bool isLocked;
  final bool isViewing;
  final String? lastMessagePreview;
  final List<User> activeUsers;

  const Room({
    required this.id,
    required this.name,
    this.usersCount = 1,
    this.unreadCount = 0,
    this.isLocked = false,
    this.isViewing = false,
    this.lastMessagePreview,
    this.activeUsers = const [],
  });

  @override
  List<Object?> get props => [
    id,
    name,
    usersCount,
    unreadCount,
    isLocked,
    isViewing,
    lastMessagePreview,
    activeUsers,
  ];
}
