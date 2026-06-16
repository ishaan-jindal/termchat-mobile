part of 'identity_bloc.dart';

abstract class IdentityEvent extends Equatable {
  const IdentityEvent();

  @override
  List<Object?> get props => [];
}

class LoadIdentity extends IdentityEvent {}

class UpdateNickname extends IdentityEvent {
  final String nickname;

  const UpdateNickname(this.nickname);

  @override
  List<Object?> get props => [nickname];
}

class UpdateColor extends IdentityEvent {
  final String colorHex;

  const UpdateColor(this.colorHex);

  @override
  List<Object?> get props => [colorHex];
}
