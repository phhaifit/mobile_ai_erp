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
  Future<MessageResponseDto> signUp({
    required String email,
    required String password,
    required String name,
  }) async {
    try {
      final response = await _dio.post(
        Endpoints.customerSignUp,
        data: {
          'email': email,
          'password': password,
          'name': name,
          'useCode': true,
        },
      );
      final result = MessageResponseDto.fromJson(response.data);
      if (response.statusCode == 201) {
        return result;
      } else {
        throw result;
      }
    } catch (e) {
      rethrow;
    }
  }

  /// Verify email with verification token
  Future<TokenResponseDto> verifyEmail({
    required String token,
  }) async {
    try {
      final response = await _dio.post(
        Endpoints.customerVerifyEmail,
        data: {
          'token': token
        },
      );
      if (response.statusCode == 200) {
        return TokenResponseDto.fromJson(response.data);
      } else {
        final result = MessageResponseDto.fromJson(response.data);
        throw result;
      }
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
        Endpoints.customerSignIn,
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

  /// Initiate Google OAuth flow
  Future<String> getGoogleOAuthUrl(String redirectUri) async {
    try {
      final response = await _dio.get(Endpoints.customerGetGoogleOAuthUrl, queryParameters: {"redirectUri": redirectUri});
      final location = response.headers['location'];
      return location?.firstOrNull ?? '';
    } catch (e) {
      rethrow;
    }
  }

  /// Request a magic link for passwordless authentication
  Future<void> requestMagicLink({
    required String email,
  }) async {
    try {
      final response = await _dio.post(
        Endpoints.customerSendMagicLink,
        data: {
          'email': email,
          'useCode': true,
        },
      );
      if (response.statusCode != 200) {
        throw MessageResponseDto.fromJson(response.data).message;
      }
    } catch (e) {
      rethrow;
    }
  }

  /// Confirm magic link and get tokens
  Future<TokenResponseDto> confirmMagicLink({
    required String token,
  }) async {
    try {
      final response = await _dio.post(
        Endpoints.customerConfirmMagicLink,
        data: {'token': token},
      );
      if (response.statusCode == 200) {
        return TokenResponseDto.fromJson(response.data);
      }
      throw MessageResponseDto.fromJson(response.data).message;
    } catch (e) {
      rethrow;
    }
  }

  /// Refresh access token using refresh token
  Future<TokenResponseDto> refreshToken({
    required String refreshToken,
    required String sessionId,
  }) async {
    try {
      final response = await _dio.post(
        Endpoints.customerRefreshToken,
        data: {
          refreshToken: refreshToken,
          sessionId: sessionId,
        }
      );
      if (response.statusCode == 200) {
        return TokenResponseDto.fromJson(response.data);
      }
      throw MessageResponseDto.fromJson(response.data).message;
    } catch (e) {
      rethrow;
    }
  }

  /// Sign out current session
  Future<void> signOut() async {
    try {
      await _dio.post(Endpoints.customerSignOut);
    } catch (e) {
      rethrow;
    }
  }

  /// Sign out current session
  Future<List<SessionResponseDto>> listSessions() async {
    try {
      final response = await _dio.get(Endpoints.customerAuthGetSessions);
      if (response.statusCode == 200) {
        if (response.data == null || response.data['sessions'] == null) {
          return [];
        }
        return List<SessionResponseDto>.from((response.data['sessions'] as Iterable).map((item) => SessionResponseDto.fromJson(item)));
      }
      throw MessageResponseDto.fromJson(response.data).message;
    } catch (e) {
      rethrow;
    }
  }
}
