import 'package:equatable/equatable.dart';

class Message extends Equatable {
  final String id;
  final String roomId;
  final String senderId;
  final String senderNickname;
  final String senderColorHex;
  final String content;
  final DateTime timestamp;
  final bool isSystemMessage;

  const Message({
    required this.id,
    required this.roomId,
    required this.senderId,
    required this.senderNickname,
    required this.senderColorHex,
    required this.content,
    required this.timestamp,
    this.isSystemMessage = false,
  });

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
  ];
}
