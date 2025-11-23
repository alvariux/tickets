import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter/foundation.dart';
import 'package:tickets/services/storage_service.dart';
import 'package:tickets/config/compile_time.dart';

class AppConfig {
  static const String _defaultApiUrl = 'http://127.0.0.1/api/imagen';

  /// Call once at app startup to load environment file if present.
  static Future<void> load() async {
    // dotenv.load() is called from main; keep method for compatibility
    // and to allow future initialization steps.
  }

  /// Get the effective API URL. Priority:
  /// 0. compile-time `--dart-define` (API_URL)
  /// 1. override stored in secure storage
  /// 2. value from .env (API_URL)
  /// 3. default
  static Future<String> getApiUrl() async {
    // 0. compile-time value (useful for production builds via --dart-define)
    if (kApiUrlCompileTime.isNotEmpty) {
      debugPrint('AppConfig: using API_URL from compile-time dart-define -> $kApiUrlCompileTime');
      return kApiUrlCompileTime;
    }

    // 1. secure storage override (user-provided at runtime)
    final override = await StorageService().getApiUrlOverride();
    if (override != null && override.isNotEmpty) return override;

    // 2. dotenv file (development convenience)
    String? envUrl;
    try {
      envUrl = dotenv.env['API_URL'];
    } catch (e) {
      envUrl = null;
    }
    if (envUrl != null && envUrl.isNotEmpty) {
      debugPrint('AppConfig: using API_URL from .env -> $envUrl');
      return envUrl;
    }

    // 3. default
    debugPrint('AppConfig: using default API URL -> $_defaultApiUrl');
    return _defaultApiUrl;
  }
}
