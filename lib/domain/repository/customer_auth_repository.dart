import 'package:mobile_ai_erp/domain/entity/customer_auth/customer_auth_entities.dart';
import 'package:mobile_ai_erp/data/model/customer_auth/customer_auth_models.dart';

class AuthResult {
  final Customer customer;
  final TokenPair tokenPair;

  AuthResult({
    required this.customer,
    required this.tokenPair,
  });
}

abstract class CustomerAuthRepository {
  Future<String> getTenantId(String subdomain);

  /// Sign up with email and password
  Future<MessageResponseDto> signUp({
    required String email,
    required String password,
    required String name,
  });

  /// Verify email with verification token
  Future<TokenResponseDto> verifyEmail({
    required String token,
  });
}
