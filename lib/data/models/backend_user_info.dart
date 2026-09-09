import 'package:equatable/equatable.dart';

import '../json_coerce.dart';

class BackendUserInfo extends Equatable {
  final String nick;
  final String color;
  final int joinedAt;
  final bool typing;
  final bool isHost;
  final int voiceId;

  const BackendUserInfo({
    required this.nick,
    required this.color,
    required this.joinedAt,
    required this.typing,
    required this.isHost,
    this.voiceId = 0,
  });

  factory BackendUserInfo.fromJson(Map<String, dynamic> json) {
    final nick = asString(json['nick']);
    final color = asString(json['color']);
    if (nick == null || nick.isEmpty || color == null || color.isEmpty) {
      throw const FormatException('missing user nick/color');
    }
    return BackendUserInfo(
      nick: nick,
      color: color,
      joinedAt: asInt(json['joined_at']) ?? 0,
      typing: asBool(json['typing']) ?? false,
      isHost: asBool(json['is_host']) ?? false,
      voiceId: asInt(json['voice_id']) ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'nick': nick,
      'color': color,
      'joined_at': joinedAt,
      'typing': typing,
      'is_host': isHost,
      if (voiceId != 0) 'voice_id': voiceId,
    };
  }

  @override
  List<Object?> get props => [nick, color, joinedAt, typing, isHost, voiceId];
}
