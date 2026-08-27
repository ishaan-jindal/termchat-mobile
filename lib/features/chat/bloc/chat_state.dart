part of 'chat_bloc.dart';

class ChatState extends Equatable {
  final List<Message> messages;
  final List<BackendUserInfo> users;
  final bool isLoading;
  final bool isConnected;
  final String? error;
  final String? roomCode;
  final ConnectionStatus connectionStatus;
  final Set<String> myReactions;

  const ChatState({
    this.messages = const [],
    this.users = const [],
    this.isLoading = false,
    this.isConnected = false,
    this.error,
    this.roomCode,
    this.connectionStatus = ConnectionStatus.disconnected,
    this.myReactions = const {},
  });

  ChatState copyWith({
    List<Message>? messages,
    List<BackendUserInfo>? users,
    bool? isLoading,
    bool? isConnected,
    String? error,
    bool clearError = false,
    String? roomCode,
    ConnectionStatus? connectionStatus,
    Set<String>? myReactions,
  }) {
    return ChatState(
      messages: messages ?? this.messages,
      users: users ?? this.users,
      isLoading: isLoading ?? this.isLoading,
      isConnected: isConnected ?? this.isConnected,
      error: clearError ? null : (error ?? this.error),
      roomCode: roomCode ?? this.roomCode,
      connectionStatus: connectionStatus ?? this.connectionStatus,
      myReactions: myReactions ?? this.myReactions,
    );
  }

  @override
  List<Object?> get props => [
    messages,
    users,
    isLoading,
    isConnected,
    error,
    roomCode,
    connectionStatus,
    myReactions,
  ];
}
