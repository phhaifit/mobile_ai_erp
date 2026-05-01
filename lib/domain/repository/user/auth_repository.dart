import 'dart:async';
import 'package:json_annotation/json_annotation.dart';

import '../../entity/user/user.dart';

part 'auth_repository.g.dart';

// =============================
// AUTH REPOSITORY (ASYNC)
// =============================

class AuthToken
{
  final String accessToken;
  final String refreshToken;
  AuthToken(this.accessToken, this.refreshToken);
}

@JsonSerializable()
class SsoProfile
{
  final String email;
  final String name;
  SsoProfile({required this.email, required this.name});

  factory SsoProfile.fromJson(Map<String, dynamic> json) => _$SsoProfileFromJson(json);
  Map<String, dynamic> toJson() => _$SsoProfileToJson(this);
}

@JsonSerializable()
class TenantSummary {
   final String id;
   final String name;
   final String subdomain;
   final String role;
   final String userId;
   final bool isActive;
   final String? helpdeskTenantId;

  factory TenantSummary.fromJson(Map<String, dynamic> json) => _$TenantSummaryFromJson(json);
  Map<String, dynamic> toJson() => _$TenantSummaryToJson(this);

  TenantSummary({required this.id, required this.name, required this.subdomain, required this.role, required this.userId, required this.isActive, required this.helpdeskTenantId});
}

@JsonSerializable()
class AuthResponseUser
{
  final String id;
  final String? email;
  final String? name;
  final String? role;
  final String tenantId;
  final String? profileImageUrl;

  AuthResponseUser({
    required this.id,
    required this.email,
    required this.name,
    required this.role,
    required this.tenantId,
    this.profileImageUrl,
  });

  factory AuthResponseUser.fromJson(Map<String, dynamic> json) => _$AuthResponseUserFromJson(json);
  Map<String, dynamic> toJson() => _$AuthResponseUserToJson(this);
}

@JsonSerializable()
class AuthStatusResponse
{
  final bool hasTenant;

  final SsoProfile? ssoProfile;

  final String? subdomain;
  final AuthResponseUser? user;
  final List<TenantSummary>? tenants;

  factory AuthStatusResponse.fromJson(Map<String, dynamic> json) => _$AuthStatusResponseFromJson(json);
  Map<String, dynamic> toJson() => _$AuthStatusResponseToJson(this);

  AuthStatusResponse({required this.hasTenant, required this.ssoProfile, required this.subdomain, required this.user, required this.tenants});
}

abstract class AuthRepository {
  /// Get authentication status and user profile
  Future<AuthStatusResponse> getAuthStatus(String accessToken);

  /// Refresh access token using refresh token
  Future<(String?, String?)> refreshToken(String refreshToken);

  /// Sign out the user
  Future<void> signOut(String accessToken, String tenantId);

  /// Create a new tenant for first-time users
  Future<Map<String, dynamic>> createTenant(String name, String subdomain);

  /// Exchange authorization code for access token
  Future<AuthToken> getAccessToken(String authorizationCode, String codeVerifier, String redirectUri);
}