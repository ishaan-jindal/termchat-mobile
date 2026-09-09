import 'package:flutter_test/flutter_test.dart';
import 'package:termchat_app/data/models/backend_reaction.dart';

void main() {
  group('BackendReaction.fromJson', () {
    test('parses name and count', () {
      final reaction = BackendReaction.fromJson({'name': '+1', 'count': 3});

      expect(reaction.name, '+1');
      expect(reaction.count, 3);
    });

    test('defaults missing count to zero', () {
      final reaction = BackendReaction.fromJson({'name': 'fire'});

      expect(reaction.count, 0);
    });

    test('coerces string counts', () {
      final reaction = BackendReaction.fromJson({'name': '+1', 'count': '4'});

      expect(reaction.count, 4);
    });

    test('throws on missing name', () {
      expect(
        () => BackendReaction.fromJson({'count': 1}),
        throwsFormatException,
      );
      expect(() => BackendReaction.fromJson({}), throwsFormatException);
    });

    test('round-trips through toJson', () {
      final reaction = BackendReaction(name: 'eyes', count: 2);
      final clone = BackendReaction.fromJson(reaction.toJson());

      expect(clone.name, 'eyes');
      expect(clone.count, 2);
    });
  });
}
