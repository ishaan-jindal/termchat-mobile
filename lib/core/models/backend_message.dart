class BackendMessage {
  final String type;
  final String? nick;
  final String? room;
  final String? text;
  final String? newNick;
  final String? color;
  final String? password;
  final List<BackendMessage>? messages;
  final List<BackendUserInfo>? users;

  BackendMessage({
    required this.type,
    this.nick,
    this.room,
    this.text,
    this.newNick,
    this.color,
    this.password,
    this.messages,
    this.users,
  });

  factory BackendMessage.fromJson(Map<String, dynamic> json) {
    return BackendMessage(
      type: json['type'] as String,
      nick: json['nick'] as String?,
      room: json['room'] as String?,
      text: json['text'] as String?,
      newNick: json['new_nick'] as String?,
      color: json['color'] as String?,
      password: json['password'] as String?,
      messages: (json['messages'] as List<dynamic>?)
          ?.map((e) => BackendMessage.fromJson(e as Map<String, dynamic>))
          .toList(),
      users: (json['users'] as List<dynamic>?)
          ?.map((e) => BackendUserInfo.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type,
      if (nick != null) 'nick': nick,
      if (room != null) 'room': room,
      if (text != null) 'text': text,
      if (newNick != null) 'new_nick': newNick,
      if (color != null) 'color': color,
      if (password != null) 'password': password,
      if (messages != null)
        'messages': messages?.map((e) => e.toJson()).toList(),
      if (users != null) 'users': users?.map((e) => e.toJson()).toList(),
    };
  }
}

class BackendUserInfo {
  final String nick;
  final String color;
  final int joinedAt;
  final bool typing;
  final bool isHost;

  BackendUserInfo({
    required this.nick,
    required this.color,
    required this.joinedAt,
    required this.typing,
    required this.isHost,
  });

  factory BackendUserInfo.fromJson(Map<String, dynamic> json) {
    return BackendUserInfo(
      nick: json['nick'] as String,
      color: json['color'] as String,
      joinedAt: json['joined_at'] as int? ?? 0,
      typing: json['typing'] as bool? ?? false,
      isHost: json['is_host'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'nick': nick,
      'color': color,
      'joined_at': joinedAt,
      'typing': typing,
      'is_host': isHost,
    };
  }
}

class BackendRoomInfo {
  final String id;
  final int userCount;
  final bool hasPassword;
  final String hostNick;

  BackendRoomInfo({
    required this.id,
    required this.userCount,
    required this.hasPassword,
    required this.hostNick,
  });

  factory BackendRoomInfo.fromJson(Map<String, dynamic> json) {
    return BackendRoomInfo(
      id: json['id'] as String,
      userCount: json['user_count'] as int? ?? 0,
      hasPassword: json['has_password'] as bool? ?? false,
      hostNick: json['host_nick'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_count': userCount,
      'has_password': hasPassword,
      'host_nick': hostNick,
    };
  }
}
