import 'dart:async';

import 'package:mobile_ai_erp/data/network/apis/customer/customer_api.dart';
import 'package:mobile_ai_erp/data/sharedpref/shared_preference_helper.dart';
import 'package:mobile_ai_erp/domain/entity/customer/customer.dart';

abstract class AccountCustomerDataSource {
  Future<Map<String, dynamic>> login(String email, String password);
  Future<Map<String, dynamic>> register(String name, String email, String password);
  Future<void> forgotPassword(String email);
  Future<Customer> getProfile();
  Future<Customer> updateProfile(Map<String, dynamic> data);
  Future<Map<String, dynamic>> getLoyaltyPoints();
}

class AccountCustomerApiDataSource implements AccountCustomerDataSource {
  final CustomerApi _customerApi;
  final SharedPreferenceHelper _prefs;

  AccountCustomerApiDataSource(this._customerApi, this._prefs);

  @override
  Future<Map<String, dynamic>> login(String email, String password) {
    return _customerApi.login(email, password);
  }

  @override
  Future<Map<String, dynamic>> register(String name, String email, String password) {
    return _customerApi.register(name, email, password);
  }

  @override
  Future<void> forgotPassword(String email) {
    return _customerApi.forgotPassword(email);
  }

  @override
  Future<Customer> getProfile() async {
    try {
      // Get the stored customer ID (set during login)
      final customerId = await _prefs.customerId;
      print('🔵 [AccountCustomerApiDataSource.getProfile] Stored customer ID: $customerId');
      
      if (customerId == null || customerId.isEmpty) {
        print('❌ [AccountCustomerApiDataSource.getProfile] Customer ID is null or empty!');
        throw Exception('Customer ID not found. User may not be logged in.');
      }
      
      print('📞 [AccountCustomerApiDataSource.getProfile] Calling CustomerApi.getProfile($customerId)');
      // Use the new unified endpoint with Prisma include
      final customer = await _customerApi.getProfile();
      print('✅ [AccountCustomerApiDataSource.getProfile] Got customer: ${customer.name}');
      return customer;
    } catch (e) {
      print('❌ [AccountCustomerApiDataSource.getProfile] Error: $e');
      rethrow;
    }
  }

  @override
  Future<Customer> updateProfile(Map<String, dynamic> data) {
    return _customerApi.updateProfile(data);
  }

  @override
  Future<Map<String, dynamic>> getLoyaltyPoints() {
    return _customerApi.getLoyaltyPoints();
  }
}