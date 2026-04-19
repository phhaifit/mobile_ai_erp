import '../../entity/customer/customer.dart';

abstract class AccountCustomerRepository {
  Future<Map<String, dynamic>> login(String email, String password);
  Future<Map<String, dynamic>> register(String name, String email, String password);
  Future<void> forgotPassword(String email);
  Future<Customer> getProfile();
  Future<Customer> updateProfile(Map<String, dynamic> data);
  Future<Map<String, dynamic>> getLoyaltyPoints();
}