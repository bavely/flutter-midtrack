import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorage {
  static final _storage = FlutterSecureStorage(
    aOptions: const AndroidOptions(
      encryptedSharedPreferences: true,
    ),
    iOptions: IOSOptions(
        // accessibility: IOSAccessibilityType.first_unlock_this_device_only,
        ),
  );

  // Token management
  Future<void> saveToken(String token) async {
    await _storage.write(key: 'auth_token', value: token);
  }

  Future<String?> readToken() async {
    return await _storage.read(key: 'auth_token');
  }

  Future<void> deleteToken() async {
    await _storage.delete(key: 'auth_token');
  }

  // Refresh token
  Future<void> saveRefreshToken(String refreshToken) async {
    await _storage.write(key: 'refresh_token', value: refreshToken);
  }

  Future<String?> readRefreshToken() async {
    return await _storage.read(key: 'refresh_token');
  }

  Future<void> deleteRefreshToken() async {
    await _storage.delete(key: 'refresh_token');
  }

  // User preferences
  Future<void> saveUserPreferences(Map<String, String> preferences) async {
    for (final entry in preferences.entries) {
      await _storage.write(key: 'pref_${entry.key}', value: entry.value);
    }
  }

  Future<Map<String, String>> readUserPreferences(List<String> keys) async {
    final preferences = <String, String>{};
    for (final key in keys) {
      final value = await _storage.read(key: 'pref_$key');
      if (value != null) {
        preferences[key] = value;
      }
    }
    return preferences;
  }

  // Clear all data
  Future<void> clearAll() async {
    await _storage.deleteAll();
  }

  // Check if storage contains key
  Future<bool> containsKey(String key) async {
    return await _storage.containsKey(key: key);
  }
}
