part of 'identity_bloc.dart';

abstract class IdentityState extends Equatable {
  const IdentityState();

  @override
  List<Object?> get props => [];
}

class IdentityInitial extends IdentityState {}

class IdentityLoading extends IdentityState {}

class IdentityLoaded extends IdentityState {
  final User user;

  const IdentityLoaded(this.user);

  @override
  List<Object?> get props => [user];
}

class IdentityError extends IdentityState {
  final String message;

  const IdentityError(this.message);

  @override
  List<Object?> get props => [message];
}
