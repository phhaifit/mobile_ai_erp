import 'package:mobile_ai_erp/domain/entity/customer_auth/customer_auth_entities.dart';

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
}
