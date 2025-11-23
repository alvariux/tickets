import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class StorageService {
  static final StorageService _instance = StorageService._internal();
  factory StorageService() => _instance;
  StorageService._internal();

  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  static const String _keyApiKey = 'api_key';
  static const String _keyApiUrlOverride = 'api_url_override';

  Future<void> setApiKey(String value) async {
    await _secureStorage.write(key: _keyApiKey, value: value);
  }

  Future<String?> getApiKey() async {
    return await _secureStorage.read(key: _keyApiKey);
  }

  Future<void> deleteApiKey() async {
    await _secureStorage.delete(key: _keyApiKey);
  }

  Future<void> setApiUrlOverride(String value) async {
    await _secureStorage.write(key: _keyApiUrlOverride, value: value);
  }

  Future<String?> getApiUrlOverride() async {
    return await _secureStorage.read(key: _keyApiUrlOverride);
  }

  Future<void> deleteApiUrlOverride() async {
    await _secureStorage.delete(key: _keyApiUrlOverride);
  }
}
