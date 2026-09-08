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
    final id = json['id'] as String?;
    if (id == null || id.isEmpty) {
      throw const FormatException('missing room id');
    }
    return BackendRoomInfo(
      id: id,
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
