import 'package:flutter_test/flutter_test.dart';
import 'package:termchat_app/data/json_coerce.dart';

void main() {
  group('asInt', () {
    test('passes ints through', () {
      expect(asInt(3), 3);
    });

    test('coerces doubles, bools and numeric strings', () {
      expect(asInt(3.9), 3);
      expect(asInt(true), 1);
      expect(asInt(false), 0);
      expect(asInt('42'), 42);
    });

    test('returns null for null and garbage', () {
      expect(asInt(null), isNull);
      expect(asInt('nope'), isNull);
      expect(asInt([1]), isNull);
    });
  });

  group('asString', () {
    test('passes strings through', () {
      expect(asString('hi'), 'hi');
    });

    test('stringifies numbers and bools', () {
      expect(asString(7), '7');
      expect(asString(1.5), '1.5');
      expect(asString(true), 'true');
    });

    test('returns null for null and structured values', () {
      expect(asString(null), isNull);
      expect(asString([1]), isNull);
      expect(asString({'a': 1}), isNull);
    });
  });

  group('asBool', () {
    test('passes bools through', () {
      expect(asBool(true), isTrue);
      expect(asBool(false), isFalse);
    });

    test('coerces numbers and strings', () {
      expect(asBool(1), isTrue);
      expect(asBool(0), isFalse);
      expect(asBool('true'), isTrue);
      expect(asBool('0'), isFalse);
    });

    test('returns null for null and garbage', () {
      expect(asBool(null), isNull);
      expect(asBool('maybe'), isNull);
    });
  });
}
