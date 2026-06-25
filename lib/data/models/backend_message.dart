import 'backend_user_info.dart';

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
        'messages': messages!.map((e) => e.toJson()).toList(),
      if (users != null) 'users': users!.map((e) => e.toJson()).toList(),
    };
  }
}
