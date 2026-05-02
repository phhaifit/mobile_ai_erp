import 'dart:async';

import 'package:shared_preferences/shared_preferences.dart';

import 'constants/preferences.dart';

class SharedPreferenceHelper {
  // shared pref instance
  final SharedPreferences _sharedPreference;

  // constructor
  SharedPreferenceHelper(this._sharedPreference);

  // Protected getter for subclasses
  SharedPreferences get sharedPreference => _sharedPreference;

  // General Methods: ----------------------------------------------------------
  Future<String?> get accessToken async {
    final authTokenValue = _sharedPreference.get(Preferences.auth_token);
    if (authTokenValue is List<dynamic>) {
      return authTokenValue.isNotEmpty ? authTokenValue.first : null;
    }
    if (authTokenValue is String && authTokenValue.isNotEmpty) {
      return authTokenValue;
    }
    return null;
  }

  Future<bool> saveAuthToken({required String accessToken, required String refreshToken}) async {
    return _sharedPreference.setStringList(Preferences.auth_token, [accessToken, refreshToken]);
  }

  Future<bool> removeAuthToken() async {
    return _sharedPreference.remove(Preferences.auth_token);
  }

  Future<String?> get refreshToken async {
    final authTokenValue = _sharedPreference.get(Preferences.auth_token);
    if (authTokenValue is List<dynamic> && authTokenValue.length > 1) {
      return authTokenValue[1].isNotEmpty ? authTokenValue[1] : null;
    }
    return null;
  }

  String? get tenantId {
    return _sharedPreference.getString(Preferences.tenant_id);
  }

  Future<bool> saveTenantId(String tenantId) {
    return _sharedPreference.setString(Preferences.tenant_id, tenantId);
  }

  Future<bool> removeTenantId() async {
    return _sharedPreference.remove(Preferences.tenant_id);
  }

  /// Save subdomain to shared preferences
  Future<void> saveSubdomain(String subdomain) async {
    await sharedPreference.setString(Preferences.customer_subdomain, subdomain);
  }

  /// Get stored subdomain
  String? get subdomain => sharedPreference.getString(Preferences.customer_subdomain);

  Future<bool> removeSubdomain() async {
    return _sharedPreference.remove(Preferences.customer_subdomain);
  }

  // Login:---------------------------------------------------------------------
  bool get isLoggedIn {
    final authTokenValue = _sharedPreference.get(Preferences.auth_token);
    if (authTokenValue is List<dynamic>) {
      return authTokenValue.isNotEmpty && authTokenValue.first.isNotEmpty;
    }
    if (authTokenValue is String) {
      return authTokenValue.isNotEmpty;
    }
    return false;
  }

  // Theme:------------------------------------------------------
  bool get isDarkMode {
    return _sharedPreference.getBool(Preferences.is_dark_mode) ?? false;
  }

  Future<void> changeBrightnessToDark(bool value) {
    return _sharedPreference.setBool(Preferences.is_dark_mode, value);
  }

  // Language:---------------------------------------------------
  String? get currentLanguage {
    return _sharedPreference.getString(Preferences.current_language);
  }

  Future<void> changeLanguage(String language) {
    return _sharedPreference.setString(Preferences.current_language, language);
  }
}