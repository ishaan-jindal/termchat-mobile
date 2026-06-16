import 'package:equatable/equatable.dart';

class User extends Equatable {
  final String id;
  final String nickname;
  final String colorHex;
  final bool isHost;

  const User({
    required this.id,
    required this.nickname,
    required this.colorHex,
    this.isHost = false,
  });

  @override
  List<Object?> get props => [id, nickname, colorHex, isHost];
}
