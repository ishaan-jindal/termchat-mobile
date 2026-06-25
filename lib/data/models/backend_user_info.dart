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
