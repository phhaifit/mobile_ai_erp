import 'package:mobile_ai_erp/data/network/apis/customer/customer_auth_api.dart';
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
}