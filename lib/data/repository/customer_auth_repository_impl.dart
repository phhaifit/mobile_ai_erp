import 'package:mobile_ai_erp/data/network/apis/customer/customer_auth_api.dart';
import 'package:mobile_ai_erp/data/model/customer_auth/customer_auth_models.dart';
import 'package:mobile_ai_erp/domain/entity/customer_auth/customer_auth_entities.dart';
import 'package:mobile_ai_erp/domain/repository/customer_auth_repository.dart';

class CustomerAuthRepositoryImpl implements CustomerAuthRepository {
  final CustomerAuthApi _api;
  CustomerAuthRepositoryImpl({required CustomerAuthApi api}) : _api = api;
  
  @override
  Future<String> getTenantId(String subdomain) async {
    try {
      final result = await _api.getTenant(subdomain: subdomain);
      return result.id;
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<TokenPair> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final result = await _api.signIn(email: email, password: password);
      // Create a default customer object with basic info
      return result.toTokenPair();
    } catch (e) {
      rethrow;
    }
  }

  Future<Uri> getGoogleOAuthUri(String redirectUri) async {
    try {
      final url = await _api.getGoogleOAuthUrl(redirectUri);
      final result = Uri.tryParse(url);
      if (result == null) {
        throw Exception("Invalid data response from Backend: $url");
      }
      return result;
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<MessageResponseDto> signUp({
    required String email,
    required String password,
    required String name,
  }) async {
    try {
      final result = await _api.signUp(email: email, password: password, name: name);
      return result;
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<TokenResponseDto> verifyEmail({
    required String token,
  }) async {
    try {
      final result = await _api.verifyEmail(token: token);
      return result;
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> signOut() async {
    try {
      await _api.signOut();
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> requestMagicLink({
    required String email,
  }) async {
    try {
      await _api.requestMagicLink(email: email);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<TokenResponseDto> confirmMagicLink({
    required String token,
  }) async {
    try {
      final result = await _api.confirmMagicLink(token: token);
      return result;
    } catch (e) {
      rethrow;
    }
  }
}