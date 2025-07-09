// ignore_for_file: json_serializable
import 'dart:convert';

class SecureStorageService {
  // In-memory storage as fallback for Linux
  static final Map<String, String> _memoryStorage = {};

  static Future<void> saveAuthToken(String token) async {
    _memoryStorage['auth_token'] = token;
  }

  static Future<String?> getAuthToken() async {
    return _memoryStorage['auth_token'];
  }

  static Future<void> deleteAuthToken() async {
    _memoryStorage.remove('auth_token');
  }

  static Future<void> saveUserCredentials(String username, String password) async {
    _memoryStorage['username'] = username;
    _memoryStorage['password'] = password;
  }

  static Future<Map<String, String?>> getUserCredentials() async {
    return {
      'username': _memoryStorage['username'],
      'password': _memoryStorage['password'],
    };
  }

  static Future<void> deleteUserCredentials() async {
    _memoryStorage.remove('username');
    _memoryStorage.remove('password');
  }

  static Future<void> saveBiometricEnabled(bool enabled) async {
    _memoryStorage['biometric_enabled'] = enabled.toString();
  }

  static Future<bool> isBiometricEnabled() async {
    final value = _memoryStorage['biometric_enabled'];
    if (value == null) return false;
    return value.toLowerCase() == 'true';
  }

  static Future<void> saveSecureData(String key, String value) async {
    _memoryStorage[key] = value;
  }

  static Future<String?> getSecureData(String key) async {
    return _memoryStorage[key];
  }

  static Future<void> deleteSecureData(String key) async {
    _memoryStorage.remove(key);
  }

  static Future<void> saveObject(String key, Map<String, dynamic> object) async {
    final jsonString = jsonEncode(object);
    _memoryStorage[key] = jsonString;
  }

  static Future<Map<String, dynamic>?> getObject(String key) async {
    final jsonString = _memoryStorage[key];
    if (jsonString == null) return null;
    try {
      final decoded = jsonDecode(jsonString);
      if (decoded is Map<String, dynamic>) {
        return decoded;
      } else {
        throw Exception('Stored value is not a Map<String, dynamic>');
      }
    } catch (e) {
      throw Exception('Failed to decode JSON for key "$key": $e');
    }
  }

  static Future<bool> containsKey(String key) async {
    return _memoryStorage.containsKey(key);
  }

  static Future<List<String>> getAllKeys() async {
    return _memoryStorage.keys.toList();
  }

  static Future<void> clearAll() async {
    _memoryStorage.clear();
  }

  static Future<Map<String, String>> exportData() async {
    return Map.from(_memoryStorage);
  }
}
