import 'package:equatable/equatable.dart';

class User extends Equatable {
  final String id;
  final String nickname;
  final String colorHex;

  const User({
    required this.id,
    required this.nickname,
    required this.colorHex,
  });

  @override
  List<Object?> get props => [id, nickname, colorHex];
}
