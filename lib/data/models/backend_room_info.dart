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
    final id = asString(json['id']);
    if (id == null || id.isEmpty) {
      throw const FormatException('missing room id');
    }
    return BackendRoomInfo(
      id: id,
      userCount: asInt(json['user_count']) ?? 0,
      hasPassword: asBool(json['has_password']) ?? false,
      hostNick: asString(json['host_nick']) ?? '',
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
