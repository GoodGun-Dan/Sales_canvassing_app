import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;

/// Konfigurasi API terpusat
class ApiConfig {
  // true = Railway (Production)
  // false = Localhost (Development)
  static const bool useProduction = bool.fromEnvironment(
    'USE_PRODUCTION_API',
    defaultValue: true,
  );

  // URL Railway
  static const String productionUrl =
      'https://salescanvassingbackend-production.up.railway.app/api';

  static const String _envHost = String.fromEnvironment('API_HOST');
  static const String _envBaseUrl = String.fromEnvironment('API_BASE_URL');

  static const int port = int.fromEnvironment(
    'API_PORT',
    defaultValue: 3000,
  );

  static String get host {
    if (_envHost.isNotEmpty) return _envHost;

    if (kIsWeb) return 'localhost';

    try {
      if (Platform.isAndroid) {
        return '10.0.2.2';
      }
    } catch (_) {}

    return 'localhost';
  }

  static String get localUrl => 'http://$host:$port/api';

  /// API_BASE_URL memiliki prioritas tertinggi supaya build staging dan lokal
  /// tidak perlu mengubah kode sumber. Nilainya harus sudah berakhiran `/api`.
  static String get baseUrl {
    if (_envBaseUrl.isNotEmpty) {
      return _envBaseUrl.replaceFirst(RegExp(r'/+$'), '');
    }
    return useProduction ? productionUrl : localUrl;
  }
}
