import 'package:flutter_dotenv/flutter_dotenv.dart';
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

    final envUrl = dotenv.env['API_URL'];
    if (envUrl != null && envUrl.isNotEmpty) return envUrl;

    return _defaultApiUrl;
  }
}
