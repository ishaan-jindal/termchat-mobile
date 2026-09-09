import 'package:flutter_test/flutter_test.dart';
import 'package:termchat_app/features/chat/widgets/room_users_drawer.dart';

void main() {
  group('formatJoinTime', () {
    final now = DateTime(2026, 9, 9, 12, 0, 0);

    int secsAgo(Duration d) => now.subtract(d).millisecondsSinceEpoch ~/ 1000;

    test('zero means recently', () {
      expect(formatJoinTime(0, now), 'recently');
    });

    test('under a minute is just now', () {
      expect(
        formatJoinTime(secsAgo(const Duration(seconds: 30)), now),
        'just now',
      );
    });

    test('minutes and hours', () {
      expect(
        formatJoinTime(secsAgo(const Duration(minutes: 5)), now),
        '5m ago',
      );
      expect(formatJoinTime(secsAgo(const Duration(hours: 3)), now), '3h ago');
    });

    test('days', () {
      expect(formatJoinTime(secsAgo(const Duration(days: 2)), now), '2d ago');
    });
  });
}
