import 'package:flutter_test/flutter_test.dart';
import 'package:termchat_app/core/models/reaction.dart';
import 'package:termchat_app/features/chat/models/reaction_update.dart';

void main() {
  group('ReactionUpdate', () {
    test('value equality compares message id and reactions', () {
      expect(
        const ReactionUpdate(
          messageId: 'm1',
          reactions: [Reaction(name: '+1', count: 2)],
        ),
        const ReactionUpdate(
          messageId: 'm1',
          reactions: [Reaction(name: '+1', count: 2)],
        ),
      );
    });

    test('differs on message id or reactions', () {
      const base = ReactionUpdate(
        messageId: 'm1',
        reactions: [Reaction(name: '+1', count: 2)],
      );

      expect(
        base,
        isNot(
          const ReactionUpdate(
            messageId: 'm2',
            reactions: [Reaction(name: '+1', count: 2)],
          ),
        ),
      );
      expect(
        base,
        isNot(
          const ReactionUpdate(
            messageId: 'm1',
            reactions: [Reaction(name: '+1', count: 3)],
          ),
        ),
      );
    });
  });
}
