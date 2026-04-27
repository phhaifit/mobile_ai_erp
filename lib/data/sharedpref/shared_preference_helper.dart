import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'constants/preferences.dart';

class SharedPreferenceHelper {
  // shared pref instance
  final SharedPreferences _sharedPreference;

  // constructor
  SharedPreferenceHelper(this._sharedPreference);

  // General Methods: ----------------------------------------------------------
  Future<String?> get accessToken async {
    return _sharedPreference.getStringList(Preferences.auth_token)?.first;
  }

  Future<bool> saveAuthToken({required String accessToken, required String refreshToken}) async {
    return _sharedPreference.setStringList(Preferences.auth_token, [accessToken, refreshToken]);
  }

  Future<bool> removeAuthToken() async {
    return _sharedPreference.remove(Preferences.auth_token);
  }

  Future<String?> get refreshToken async {
    return _sharedPreference.getStringList(Preferences.auth_token)?.last;
  }

  Future<String?> get tenantId async {
    return _sharedPreference.getString(Preferences.tenant_id);
  }

  Future<bool> saveTenantId(String tenantId) {
    return _sharedPreference.setString(Preferences.tenant_id, tenantId);
  }

  Future<bool> removeTenantId() async {
    return _sharedPreference.remove(Preferences.tenant_id);
  }

  // Login:---------------------------------------------------------------------
  bool get isLoggedIn {
    return _sharedPreference.containsKey(Preferences.auth_token);
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