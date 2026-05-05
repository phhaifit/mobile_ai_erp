import '../../../domain/entity/storefront_customer/storefront_customer.dart';
import '../../../domain/repository/storefront_account/customer_repository.dart';
import '../../local/datasources/storefront_customer/customer_api_datasource.dart';

class AccountCustomerRepositoryImpl implements AccountCustomerRepository {
  final AccountCustomerApiDataSource _dataSource;

  AccountCustomerRepositoryImpl(this._dataSource);

  @override
  Future<Map<String, dynamic>> login(String email, String password) {
    return _dataSource.login(email, password);
  }

  @override
  Future<Map<String, dynamic>> register(String name, String email, String password) {
    return _dataSource.register(name, email, password);
  }

  @override
  Future<void> forgotPassword(String email) {
    return _dataSource.forgotPassword(email);
  }

  @override
  Future<StorefrontCustomer> getProfile() {
    return _dataSource.getProfile();
  }

  @override
  Future<StorefrontCustomer> updateProfile(Map<String, dynamic> data) {
    return _dataSource.updateProfile(data);
  }
}