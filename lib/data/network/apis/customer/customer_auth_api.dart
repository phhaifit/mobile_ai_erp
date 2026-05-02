import 'package:dio/dio.dart';
import 'package:mobile_ai_erp/data/model/customer_auth/customer_auth_models.dart';
import 'package:mobile_ai_erp/data/network/constants/endpoints.dart';

class CustomerAuthApi {
  final Dio _dio;

  CustomerAuthApi({required Dio dio}) : _dio = dio;

  Future<GetTenantDto> getTenant({required String subdomain}) async {
    try {
      final response = await _dio.get(Endpoints.getTenantBySubdomain(subdomain));
      if (response.statusCode != 200) {
        throw Exception("failed to get tenant by subdomain ${response.data.toString()}");
      }
      return GetTenantDto.fromJson(response.data);
    } catch (e) {
      throw Exception("Get tenant request failed: $e");
    }
  }

  /// Sign Up with email and password
  Future<TokenResponseModel> signUp({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _dio.post(
        '/sign-up',
        data: {
          'email': email,
          'password': password,
        },
      );
      return TokenResponseModel.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  /// Verify email with verification token
  Future<CustomerModel> verifyEmail({
    required String token,
  }) async {
    try {
      final response = await _dio.post(
        '/verify-email',
        data: {'verificationToken': token},
      );
      return CustomerModel.fromJson(response.data['data']);
    } catch (e) {
      rethrow;
    }
  }

  /// Sign In with email and password
  Future<SignInResponseModel> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _dio.post(
        '/sign-in',
        data: {
          'email': email,
          'password': password,
        },
      );
      return SignInResponseModel.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  /// Request a magic link for passwordless authentication
  Future<void> requestMagicLink({
    required String email,
  }) async {
    try {
      await _dio.post(
        '/magic-link',
        data: {'email': email},
      );
    } catch (e) {
      rethrow;
    }
  }

  /// Confirm magic link and get tokens
  Future<SignInResponseModel> confirmMagicLink({
    required String token,
  }) async {
    try {
      final response = await _dio.post(
        '/magic-link/confirm',
        queryParameters: {'token': token},
      );
      return SignInResponseModel.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  /// Initiate Google OAuth flow
  Future<String> initiateGoogleOAuth({
    required String redirectUri,
  }) async {
    try {
      final response = await _dio.post(
        '/google',
        data: {'redirectUri': redirectUri},
      );
      return response.data['authorizationUrl'] as String;
    } catch (e) {
      rethrow;
    }
  }

  /// Complete Google OAuth flow with authorization code
  Future<SignInResponseModel> googleOAuthCallback({
    required String authorizationCode,
  }) async {
    try {
      final response = await _dio.post(
        '/google/callback',
        data: {'authorizationCode': authorizationCode},
      );
      return SignInResponseModel.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  /// Refresh access token using refresh token
  Future<TokenResponseModel> refreshToken({
    required String refreshToken,
  }) async {
    try {
      final response = await _dio.post(
        '/refresh',
        data: {'refreshToken': refreshToken},
        options: Options(
          headers: {'Authorization': 'Bearer $refreshToken'},
        ),
      );
      return TokenResponseModel.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  /// Sign out current session
  Future<void> signOut({
    required String accessToken,
  }) async {
    try {
      await _dio.post(
        '/sign-out',
        options: Options(
          headers: {'Authorization': 'Bearer $accessToken'},
        ),
      );
    } catch (e) {
      rethrow;
    }
  }

  /// Get list of active sessions
  Future<List<SessionModel>> listSessions({
    required String accessToken,
  }) async {
    try {
      final response = await _dio.get(
        '/sessions',
        options: Options(
          headers: {'Authorization': 'Bearer $accessToken'},
        ),
      );
      final sessions = (response.data['data'] as List)
          .map((e) => SessionModel.fromJson(e as Map<String, dynamic>))
          .toList();
      return sessions;
    } catch (e) {
      rethrow;
    }
  }

  /// Revoke a specific session
  Future<void> revokeSession({
    required String accessToken,
    required String sessionId,
  }) async {
    try {
      await _dio.delete(
        '/sessions/$sessionId',
        options: Options(
          headers: {'Authorization': 'Bearer $accessToken'},
        ),
      );
    } catch (e) {
      rethrow;
    }
  }
}
