import '../../entity/storefront_customer/storefront_customer.dart';

abstract class AccountCustomerRepository {
  Future<Map<String, dynamic>> login(String email, String password);
  Future<Map<String, dynamic>> register(String name, String email, String password);
  Future<void> forgotPassword(String email);
  Future<StorefrontCustomer> getProfile();
  Future<StorefrontCustomer> updateProfile(Map<String, dynamic> data);
}