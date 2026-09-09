import 'package:flutter_test/flutter_test.dart';
import 'package:termchat_app/core/models/reaction.dart';

void main() {
  group('Reaction', () {
    test('copyWith replaces only given fields', () {
      const reaction = Reaction(name: '+1', count: 2);

      final byCount = reaction.copyWith(count: 5);
      expect(byCount.name, '+1');
      expect(byCount.count, 5);

      final byName = reaction.copyWith(name: 'fire');
      expect(byName.name, 'fire');
      expect(byName.count, 2);
    });

    test('value equality compares name and count', () {
      expect(
        const Reaction(name: '+1', count: 2),
        const Reaction(name: '+1', count: 2),
      );
      expect(
        const Reaction(name: '+1', count: 2),
        isNot(const Reaction(name: '+1', count: 3)),
      );
    });
  });

  group('reactionGlyph', () {
    test('maps known names to emoji', () {
      expect(reactionGlyph('+1'), '👍');
      expect(reactionGlyph('fire'), '🔥');
    });

    test('falls back to the raw name for unknown reactions', () {
      expect(reactionGlyph('custom-thing'), 'custom-thing');
    });
  });
}
