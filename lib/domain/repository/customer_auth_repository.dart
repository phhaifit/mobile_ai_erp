import 'package:mobile_ai_erp/domain/entity/customer_auth/customer_auth_entities.dart';
import 'package:mobile_ai_erp/data/model/customer_auth/customer_auth_models.dart';

abstract class CustomerAuthRepository {
  Future<String> getTenantId(String subdomain);

  /// Sign in with email and password
  Future<TokenPair> signIn({
    required String email,
    required String password,
  });

  /// Get gooogle OAuth URL
  Future<Uri> getGoogleOAuthUri(String redirectUri);

  /// Sign up with email and password
  Future<MessageResponseDto> signUp({
    required String email,
    required String password,
    required String name,
  });

  /// Sign out
  Future<void> signOut();

  /// Verify email with verification token
  Future<TokenResponseDto> verifyEmail({
    required String token,
  });

  /// Request magic link for passwordless sign in
  Future<void> requestMagicLink({
    required String email,
  });

  /// Confirm magic link and get tokens
  Future<TokenResponseDto> confirmMagicLink({
    required String token,
  });

  /// Get new access token from refresh token
  Future<(String, String)> refreshToken({
    required String refreshToken,
    required String sessionId,
  });

  /// Get current customer
  Future<GetCustomerProfileDto> getCurrentCustomer();
}
