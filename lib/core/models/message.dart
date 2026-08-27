import 'package:equatable/equatable.dart';

import 'reaction.dart';

class Message extends Equatable {
  final String id;
  final String roomId;
  final String senderId;
  final String senderNickname;
  final String senderColorHex;
  final String content;
  final DateTime timestamp;
  final bool isSystemMessage;
  final List<Reaction> reactions;
  final int? replyToId;
  final String? replyToNick;
  final String? replyToText;

  const Message({
    required this.id,
    required this.roomId,
    required this.senderId,
    required this.senderNickname,
    required this.senderColorHex,
    required this.content,
    required this.timestamp,
    this.isSystemMessage = false,
    this.reactions = const [],
    this.replyToId,
    this.replyToNick,
    this.replyToText,
  });

  Message copyWith({
    String? id,
    String? roomId,
    String? senderId,
    String? senderNickname,
    String? senderColorHex,
    String? content,
    DateTime? timestamp,
    bool? isSystemMessage,
    List<Reaction>? reactions,
    int? replyToId,
    String? replyToNick,
    String? replyToText,
  }) {
    return Message(
      id: id ?? this.id,
      roomId: roomId ?? this.roomId,
      senderId: senderId ?? this.senderId,
      senderNickname: senderNickname ?? this.senderNickname,
      senderColorHex: senderColorHex ?? this.senderColorHex,
      content: content ?? this.content,
      timestamp: timestamp ?? this.timestamp,
      isSystemMessage: isSystemMessage ?? this.isSystemMessage,
      reactions: reactions ?? this.reactions,
      replyToId: replyToId ?? this.replyToId,
      replyToNick: replyToNick ?? this.replyToNick,
      replyToText: replyToText ?? this.replyToText,
    );
  }

  @override
  List<Object?> get props => [
    id,
    roomId,
    senderId,
    senderNickname,
    senderColorHex,
    content,
    timestamp,
    isSystemMessage,
    reactions,
    replyToId,
    replyToNick,
    replyToText,
  ];
}
