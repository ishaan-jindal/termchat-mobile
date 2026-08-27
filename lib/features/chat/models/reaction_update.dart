import 'package:equatable/equatable.dart';

import '../../../core/models/reaction.dart';

class ReactionUpdate extends Equatable {
  final String messageId;
  final List<Reaction> reactions;

  const ReactionUpdate({required this.messageId, required this.reactions});

  @override
  List<Object?> get props => [messageId, reactions];
}
