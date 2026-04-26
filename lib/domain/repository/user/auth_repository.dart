import 'dart:async';

import '../../entity/user/user.dart';

// =============================
// AUTH REPOSITORY (ASYNC)
// =============================

class AuthToken
{
  final String accessToken;
  final String refreshToken;
  AuthToken(this.accessToken, this.refreshToken);
}
abstract class AuthRepository {
  /// Get authentication status and user profile
  Future<User> getAuthStatus(String accessToken);

  /// Refresh access token using refresh token
  Future<Map<String, String>> refreshToken(String refreshToken);

  /// Sign out the user
  Future<void> signOut(String accessToken, String tenantId);

  /// Create a new tenant for first-time users
  Future<Map<String, dynamic>> createTenant(String name, String subdomain);

  /// Exchange authorization code for access token
  Future<AuthToken> getAccessToken(String authorizationCode, String codeVerifier);
}