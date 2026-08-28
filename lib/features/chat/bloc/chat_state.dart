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
  final Message? replyingTo;
  final bool isVoiceActive;
  final bool isVoiceTransmitting;
  final String? voiceError;

  const ChatState({
    this.messages = const [],
    this.users = const [],
    this.isLoading = false,
    this.isConnected = false,
    this.error,
    this.roomCode,
    this.connectionStatus = ConnectionStatus.disconnected,
    this.myReactions = const {},
    this.replyingTo,
    this.isVoiceActive = false,
    this.isVoiceTransmitting = false,
    this.voiceError,
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
    Message? replyingTo,
    bool clearReplyingTo = false,
    bool? isVoiceActive,
    bool? isVoiceTransmitting,
    String? voiceError,
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
      replyingTo: clearReplyingTo ? null : (replyingTo ?? this.replyingTo),
      isVoiceActive: isVoiceActive ?? this.isVoiceActive,
      isVoiceTransmitting: isVoiceTransmitting ?? this.isVoiceTransmitting,
      voiceError: voiceError ?? this.voiceError,
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
    replyingTo,
    isVoiceActive,
    isVoiceTransmitting,
    voiceError,
  ];
}
