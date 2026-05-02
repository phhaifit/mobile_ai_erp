import 'package:shared_preferences/shared_preferences.dart';

class AuthPreferences {
  static const String _keyAccessToken = 'access_token';
  static const String _keyRefreshToken = 'refresh_token';
  static const String _keyExpiresAt = 'token_expires_at';
  static const String _keyCustomerId = 'customer_id';
  static const String _keyRememberMe = 'remember_me';
  static const String _keyCustomerEmail = 'customer_email';
  static const String _keyLastSignInEmail = 'last_sign_in_email';

  final SharedPreferences _sharedPreferences;

  AuthPreferences({required SharedPreferences sharedPreferences})
      : _sharedPreferences = sharedPreferences;

  /// Save tokens and expiration time
  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
    required DateTime expiresAt,
    String? customerId,
  }) async {
    await _sharedPreferences.setString(_keyAccessToken, accessToken);
    await _sharedPreferences.setString(_keyRefreshToken, refreshToken);
    await _sharedPreferences.setString(_keyExpiresAt, expiresAt.toIso8601String());
    if (customerId != null) {
      await _sharedPreferences.setString(_keyCustomerId, customerId);
    }
  }

  /// Get stored access token
  String? getAccessToken() {
    return _sharedPreferences.getString(_keyAccessToken);
  }

  /// Get stored refresh token
  String? getRefreshToken() {
    return _sharedPreferences.getString(_keyRefreshToken);
  }

  /// Get token expiration time
  DateTime? getTokenExpiresAt() {
    final expiresAtStr = _sharedPreferences.getString(_keyExpiresAt);
    if (expiresAtStr != null) {
      return DateTime.tryParse(expiresAtStr);
    }
    return null;
  }

  /// Get stored customer ID
  String? getCustomerId() {
    return _sharedPreferences.getString(_keyCustomerId);
  }

  /// Set remember me preference
  Future<void> setRememberMe(bool value) async {
    await _sharedPreferences.setBool(_keyRememberMe, value);
  }

  /// Get remember me preference
  bool getRememberMe() {
    return _sharedPreferences.getBool(_keyRememberMe) ?? false;
  }

  /// Store last used email for convenience
  Future<void> setLastSignInEmail(String email) async {
    await _sharedPreferences.setString(_keyLastSignInEmail, email);
  }

  /// Get last used email
  String? getLastSignInEmail() {
    return _sharedPreferences.getString(_keyLastSignInEmail);
  }

  /// Store customer email
  Future<void> setCustomerEmail(String email) async {
    await _sharedPreferences.setString(_keyCustomerEmail, email);
  }

  /// Get stored customer email
  String? getCustomerEmail() {
    return _sharedPreferences.getString(_keyCustomerEmail);
  }

  /// Clear all authentication data
  Future<void> clearTokens() async {
    await _sharedPreferences.remove(_keyAccessToken);
    await _sharedPreferences.remove(_keyRefreshToken);
    await _sharedPreferences.remove(_keyExpiresAt);
    await _sharedPreferences.remove(_keyCustomerId);
    await _sharedPreferences.remove(_keyCustomerEmail);
  }

  /// Clear all auth data including remember me settings
  Future<void> clearAllAuthData() async {
    await clearTokens();
    await _sharedPreferences.remove(_keyRememberMe);
  }

  /// Check if token is still valid
  bool hasValidToken() {
    final expiresAtStr = _sharedPreferences.getString(_keyExpiresAt);
    if (expiresAtStr == null) return false;

    final expiresAt = DateTime.tryParse(expiresAtStr);
    if (expiresAt == null) return false;

    return expiresAt.isAfter(DateTime.now());
  }

  /// Check if token is expiring soon (within 2 minutes)
  bool isTokenExpiringSoon() {
    final expiresAtStr = _sharedPreferences.getString(_keyExpiresAt);
    if (expiresAtStr == null) return false;

    final expiresAt = DateTime.tryParse(expiresAtStr);
    if (expiresAt == null) return false;

    final now = DateTime.now();
    final soonThreshold = now.add(const Duration(minutes: 2));
    return expiresAt.isBefore(soonThreshold) && expiresAt.isAfter(now);
  }

  /// Check if user is logged in
  bool isLoggedIn() {
    return getAccessToken() != null && getRefreshToken() != null;
  }

  /// Get remaining token duration in seconds
  int? getTokenRemainingSeconds() {
    final expiresAt = getTokenExpiresAt();
    if (expiresAt == null) return null;

    final remaining = expiresAt.difference(DateTime.now()).inSeconds;
    return remaining > 0 ? remaining : 0;
  }
}
