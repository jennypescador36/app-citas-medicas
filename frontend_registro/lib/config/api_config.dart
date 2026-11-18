import 'package:flutter/foundation.dart';

/// URL base del backend.
///
/// Al compilar para la nube se pasa con:
///   flutter build apk --release --dart-define=API_URL=https://app-citas-backend.onrender.com
/// Sin ese valor se usa el backend local (10.0.2.2 en el emulador Android).
class ApiConfig {
  static const String _apiUrl = String.fromEnvironment('API_URL');

  static String get baseUrl {
    if (_apiUrl.isNotEmpty) {
      return _apiUrl.endsWith('/')
          ? _apiUrl.substring(0, _apiUrl.length - 1)
          : _apiUrl;
    }
    if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
      return 'http://10.0.2.2:8080';
    }
    return 'http://localhost:8080';
  }
}
