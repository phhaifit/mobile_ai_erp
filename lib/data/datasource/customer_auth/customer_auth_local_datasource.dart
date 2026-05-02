import 'package:mobile_ai_erp/data/model/customer_auth/customer_auth_models.dart';
import 'package:mobile_ai_erp/data/local/preferences/customer_auth/auth_preferences.dart';

abstract class CustomerAuthLocalDatasource {
  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
    required DateTime expiresAt,
    String? customerId,
  });

  Future<void> saveSessions(List<SessionModel> sessions);

  String? getAccessToken();

  String? getRefreshToken();

  DateTime? getTokenExpiresAt();

  String? getCustomerId();

  bool hasValidToken();

  bool isTokenExpiringSoon();

  Future<void> clearTokens();

  bool isLoggedIn();

  Future<void> setRememberMe(bool value);

  bool getRememberMe();

  Future<void> setLastSignInEmail(String email);

  String? getLastSignInEmail();

  Future<void> setCustomerEmail(String email);

  String? getCustomerEmail();

  int? getTokenRemainingSeconds();
}

class CustomerAuthLocalDatasourceImpl implements CustomerAuthLocalDatasource {
  final AuthPreferences _authPreferences;

  CustomerAuthLocalDatasourceImpl({
    required AuthPreferences authPreferences,
  }) : _authPreferences = authPreferences;

  @override
  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
    required DateTime expiresAt,
    String? customerId,
  }) {
    return _authPreferences.saveTokens(
      accessToken: accessToken,
      refreshToken: refreshToken,
      expiresAt: expiresAt,
      customerId: customerId,
    );
  }

  @override
  Future<void> saveSessions(List<SessionModel> sessions) async {
    // Future implementation for local session storage with Sembast
  }

  @override
  String? getAccessToken() {
    return _authPreferences.getAccessToken();
  }

  @override
  String? getRefreshToken() {
    return _authPreferences.getRefreshToken();
  }

  @override
  DateTime? getTokenExpiresAt() {
    return _authPreferences.getTokenExpiresAt();
  }

  @override
  String? getCustomerId() {
    return _authPreferences.getCustomerId();
  }

  @override
  bool hasValidToken() {
    return _authPreferences.hasValidToken();
  }

  @override
  bool isTokenExpiringSoon() {
    return _authPreferences.isTokenExpiringSoon();
  }

  @override
  Future<void> clearTokens() {
    return _authPreferences.clearTokens();
  }

  @override
  bool isLoggedIn() {
    return _authPreferences.isLoggedIn();
  }

  @override
  Future<void> setRememberMe(bool value) {
    return _authPreferences.setRememberMe(value);
  }

  @override
  bool getRememberMe() {
    return _authPreferences.getRememberMe();
  }

  @override
  Future<void> setLastSignInEmail(String email) {
    return _authPreferences.setLastSignInEmail(email);
  }

  @override
  String? getLastSignInEmail() {
    return _authPreferences.getLastSignInEmail();
  }

  @override
  Future<void> setCustomerEmail(String email) {
    return _authPreferences.setCustomerEmail(email);
  }

  @override
  String? getCustomerEmail() {
    return _authPreferences.getCustomerEmail();
  }

  @override
  int? getTokenRemainingSeconds() {
    return _authPreferences.getTokenRemainingSeconds();
  }
}
