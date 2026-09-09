import '../json_coerce.dart';
import 'backend_reaction.dart';
import 'backend_user_info.dart';

class BackendMessage {
  static const int maxBatchItems = 1000;
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
      type: json['type'] as String? ?? 'unknown',
      id: asInt(json['id']),
      nick: json['nick'] as String?,
      room: json['room'] as String?,
      text: json['text'] as String?,
      newNick: json['new_nick'] as String?,
      color: json['color'] as String?,
      password: json['password'] as String?,
      token: json['token'] as String?,
      timestamp: asInt(json['timestamp']),
      serverTime: asInt(json['server_time']),
      replyToId: asInt(json['reply_to_id']),
      replyToNick: json['reply_to_nick'] as String?,
      replyToText: json['reply_to_text'] as String?,
      reactions: _parseList(json['reactions'], BackendReaction.fromJson),
      messages: _parseList(json['messages'], BackendMessage.fromJson),
      users: _parseList(json['users'], BackendUserInfo.fromJson),
    );
  }

  /// Parses a JSON list element-by-element, skipping malformed entries
  /// instead of aborting the whole batch. Capped so a pathological
  /// history payload can't OOM the isolate.
  static List<T>? _parseList<T>(
    Object? raw,
    T Function(Map<String, dynamic>) fromJson,
  ) {
    if (raw == null) return null;
    if (raw is! List) return null;
    final out = <T>[];
    for (final e in raw) {
      if (out.length >= maxBatchItems) break;
      if (e is! Map<String, dynamic>) continue;
      try {
        out.add(fromJson(e));
      } catch (_) {
        continue;
      }
    }
    return out;
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
