import '../json_coerce.dart';

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
      userCount: asInt(json['user_count']) ?? 0,
      hasPassword: asBool(json['has_password']) ?? false,
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
