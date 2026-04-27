import 'dart:async';

import 'package:dio/dio.dart';
import 'package:mobile_ai_erp/core/data/network/constants/network_constants.dart';
import 'package:mobile_ai_erp/core/data/network/dio/dio_client.dart';
import 'package:mobile_ai_erp/data/network/constants/endpoints.dart';
import 'package:mobile_ai_erp/domain/repository/user/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  final DioClient dioClient;

  AuthRepositoryImpl(this.dioClient);

  @override
  Future<AuthStatusResponse> getAuthStatus(String accessToken) async {
    try {
      final response = await dioClient.dio.get(
        Endpoints.authStatus,
        options: Options(
          headers: {
            'Authorization': 'Bearer $accessToken',
          },
        ),
      );

      if (response.statusCode == 200 && response.data != null) {
        return AuthStatusResponse.fromJson(response.data!);
      } else {
        throw Exception('Failed to get auth status');
      }
    } catch (e) {
      throw Exception('Auth status request failed: $e');
    }
  }

  @override
  Future<(String?, String?)> refreshToken(String refreshToken) async {
    try {
      final response = await dioClient.dio.get(
        Endpoints.authRefresh,
        options: Options(
          headers: {
            'Authorization': 'Bearer $refreshToken',
          },
        ),
      );

      if (response.statusCode == 200 && response.data != null) {
        return (response.data['token']?['accessToken'] as String?, response.data['token']?['refreshToken'] as String?);
      }
    } catch (e) {
      throw Exception('Refresh token request failed: $e');
    }

    return (null, null);
  }

  @override
  Future<void> signOut(String accessToken, String tenantId) async {
    try {
      await dioClient.dio.get(
        Endpoints.authSignOut,
        options: Options(
          headers: {
            'Authorization': 'Bearer $accessToken',
            'X-Tenant-Id': tenantId,
          },
        ),
      );
    } catch (e) {
      // Sign out should not fail the operation, just log
      print('Sign out request failed: $e');
    }
  }

  @override
  Future<Map<String, dynamic>> createTenant(String name, String subdomain) async {
    try {
      final response = await dioClient.dio.post(
        Endpoints.tenantsCreate,
        data: {
          'name': name,
          'subdomain': subdomain,
        },
      );

      if (response.statusCode == 201 && response.data != null) {
        return response.data;
      } else {
        throw Exception('Failed to create tenant');
      }
    } catch (e) {
      throw Exception('Create tenant request failed: $e');
    }
  }

  @override
  Future<AuthToken> getAccessToken(String authorizationCode, String codeVerifier, String redirectUri) async {
    try {
      final response = await dioClient.dio.post(
        Endpoints.stackAuthToken,
        data: {
          'grant_type': 'authorization_code',
          'client_id': NetworkConstants.stackAuthClientId,
          'client_secret': NetworkConstants.stackAuthClientSecret,
          'code': authorizationCode,
          'code_verifier': codeVerifier,
          'redirect_uri': redirectUri,
        },
      );

      if (response.statusCode == 200 && response.data != null) {
        final data = response.data;
        final accessToken = data['access_token'] ?? '';
        final refreshToken = data['refresh_token'] ?? '';
        return AuthToken(accessToken, refreshToken);
      } else {
        throw Exception('Failed to get access token');
      }
    } catch (e) {
      throw Exception('Create access token retrieval request failed: $e');
    }
  }
}