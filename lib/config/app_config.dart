import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter/foundation.dart';
import 'package:tickets/services/storage_service.dart';

class AppConfig {
  static const String _defaultApiUrl = 'http://127.0.0.1/api/imagen';

  /// Call once at app startup to load environment file if present.
  static Future<void> load() async {
    // dotenv.load() is called from main; keep method for compatibility
    // and to allow future initialization steps.
  }

  /// Get the effective API URL. Priority:
  /// 1. override stored in secure storage
  /// 2. value from .env (API_URL)
  /// 3. default
  static Future<String> getApiUrl() async {
    final override = await StorageService().getApiUrlOverride();
    if (override != null && override.isNotEmpty) return override;

    String? envUrl;
    try {
      envUrl = dotenv.env['API_URL'];
    } catch (e) {
      // dotenv wasn't initialized; log and continue to default
      // avoid throwing NotInitializedError to callers
      // (some code may call AppConfig before dotenv.load completes)
      // We use the default below.
      // Note: use debugPrint to avoid depending on Flutter bindings here.
      // Importing foundation is unnecessary in this file; callers will log.
      envUrl = null;
    }
    if (envUrl != null && envUrl.isNotEmpty) {
      debugPrint('AppConfig: using API_URL from .env -> $envUrl');
      return envUrl;
    }

    debugPrint('AppConfig: using default API URL -> $_defaultApiUrl');
    return _defaultApiUrl;
  }
}
