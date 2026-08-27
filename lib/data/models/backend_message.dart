import 'backend_reaction.dart';
import 'backend_user_info.dart';

class BackendMessage {
  final String type;
  final int? id;
  final String? nick;
  final String? room;
  final String? text;
  final String? newNick;
  final String? color;
  final String? password;
  final String? token;
  final int? timestamp;
  final int? serverTime;
  final int? replyToId;
  final String? replyToNick;
  final String? replyToText;
  final List<BackendReaction>? reactions;
  final List<BackendMessage>? messages;
  final List<BackendUserInfo>? users;

  BackendMessage({
    required this.type,
    this.id,
    this.nick,
    this.room,
    this.text,
    this.newNick,
    this.color,
    this.password,
    this.token,
    this.timestamp,
    this.serverTime,
    this.replyToId,
    this.replyToNick,
    this.replyToText,
    this.reactions,
    this.messages,
    this.users,
  });

  factory BackendMessage.fromJson(Map<String, dynamic> json) {
    return BackendMessage(
      type: json['type'] as String,
      id: json['id'] as int?,
      nick: json['nick'] as String?,
      room: json['room'] as String?,
      text: json['text'] as String?,
      newNick: json['new_nick'] as String?,
      color: json['color'] as String?,
      password: json['password'] as String?,
      token: json['token'] as String?,
      timestamp: json['timestamp'] as int?,
      serverTime: json['server_time'] as int?,
      replyToId: json['reply_to_id'] as int?,
      replyToNick: json['reply_to_nick'] as String?,
      replyToText: json['reply_to_text'] as String?,
      reactions: (json['reactions'] as List<dynamic>?)
          ?.map((e) => BackendReaction.fromJson(e as Map<String, dynamic>))
          .toList(),
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
      if (id != null) 'id': id,
      if (nick != null) 'nick': nick,
      if (room != null) 'room': room,
      if (text != null) 'text': text,
      if (newNick != null) 'new_nick': newNick,
      if (color != null) 'color': color,
      if (password != null) 'password': password,
      if (token != null) 'token': token,
      if (timestamp != null) 'timestamp': timestamp,
      if (serverTime != null) 'server_time': serverTime,
      if (replyToId != null) 'reply_to_id': replyToId,
      if (replyToNick != null) 'reply_to_nick': replyToNick,
      if (replyToText != null) 'reply_to_text': replyToText,
      if (reactions != null)
        'reactions': reactions!.map((e) => e.toJson()).toList(),
      if (messages != null)
        'messages': messages!.map((e) => e.toJson()).toList(),
      if (users != null) 'users': users!.map((e) => e.toJson()).toList(),
    };
  }
}
