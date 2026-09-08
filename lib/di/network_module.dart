import 'package:http/http.dart' as http;
import 'package:injectable/injectable.dart';

/// Shared HTTP client so repositories reuse connections instead of opening a
/// new socket per request. Swap in a `MockClient` in tests by overriding the
/// registration.
@module
abstract class NetworkModule {
  @lazySingleton
  http.Client get httpClient => http.Client();
}
