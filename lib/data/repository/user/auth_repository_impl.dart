import 'dart:async';
import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:mobile_ai_erp/constants/env.dart';
import 'package:mobile_ai_erp/core/data/network/dio/dio_client.dart';
import 'package:mobile_ai_erp/data/network/constants/endpoints.dart';
import 'package:mobile_ai_erp/domain/repository/user/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  final DioClient dioClient;
  final Dio _refreshDio;

  AuthRepositoryImpl(this.dioClient, this._refreshDio);

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
  Future<(String?, String?, String?)> refreshToken(String refreshToken, {String? sessionId}) async {
    try {
      // Use the injected Dio instance (configured without auth interceptors to avoid infinite loop)
      if (sessionId != null && sessionId.isNotEmpty) {
        // Customer auth flow: POST /customer/auth/refresh
        final response = await _refreshDio.post(
          Endpoints.customerAuthRefresh,
          data: {
            'refreshToken': refreshToken,
            'sessionId': sessionId,
          },
          options: Options(
            headers: {
              'X-Tenant-Id': Endpoints.tenantId,
            },
          ),
        );

        if (response.statusCode == 200 && response.data != null) {
          final accessToken = response.data['accessToken'] as String?;
          final newRefreshToken = response.data['refreshToken'] as String?;
          final newSessionId = response.data['sessionId'] as String?;
          return (accessToken, newRefreshToken, newSessionId);
        }
      } else {
        // ERP/admin auth flow: GET /auth/refresh
        final response = await _refreshDio.get(
          Endpoints.authRefresh,
          options: Options(
            headers: {
              'Authorization': 'Bearer $refreshToken',
            },
          ),
        );

        if (response.statusCode == 200 && response.data != null) {
          return (
            response.data['token']?['accessToken'] as String?,
            response.data['token']?['refreshToken'] as String?,
            null,
          );
        }
      }
    } catch (e) {
      throw Exception('Refresh token request failed: $e');
    }

    return (null, null, null);
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
      log('Sign out request failed: $e');
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
          'client_id': Env.stackAuthClientId,
          'client_secret': Env.stackAuthClientSecret,
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