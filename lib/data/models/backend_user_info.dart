class BackendUserInfo {
  final String nick;
  final String color;
  final int joinedAt;
  final bool typing;
  final bool isHost;
  final int voiceId;

  BackendUserInfo({
    required this.nick,
    required this.color,
    required this.joinedAt,
    required this.typing,
    required this.isHost,
    this.voiceId = 0,
  });

  factory BackendUserInfo.fromJson(Map<String, dynamic> json) {
    final nick = json['nick'] as String?;
    final color = json['color'] as String?;
    if (nick == null || nick.isEmpty || color == null || color.isEmpty) {
      throw const FormatException('missing user nick/color');
    }
    return BackendUserInfo(
      nick: nick,
      color: color,
      joinedAt: json['joined_at'] as int? ?? 0,
      typing: json['typing'] as bool? ?? false,
      isHost: json['is_host'] as bool? ?? false,
      voiceId: json['voice_id'] as int? ?? 0,
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
}
