import 'package:flutter_test/flutter_test.dart';
import 'package:termchat_app/data/api_exceptions.dart';

void main() {
  group('ApiException toString', () {
    test('network error keeps its message and cause', () {
      const error = ApiNetworkException('Timed out', 'cause');

      expect(error.toString(), 'Timed out');
      expect(error.cause, 'cause');
    });

    test('server error without body shows only the code', () {
      expect(const ApiServerException(500).toString(), 'Server error (500)');
    });

    test('server error with body appends the snippet', () {
      expect(
        const ApiServerException(503, 'oops').toString(),
        'Server error (503): oops',
      );
    });

    test('parse error keeps its message', () {
      expect(const ApiParseException('Malformed').toString(), 'Malformed');
    });
  });
}
