import 'package:http/http.dart' as http;
import 'package:injectable/injectable.dart';

/// Shared HTTP client (override with MockClient in tests).
@module
abstract class NetworkModule {
  @lazySingleton
  http.Client get httpClient => http.Client();
}
