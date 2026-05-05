import 'dart:async';

import 'package:mobile_ai_erp/data/network/apis/storefront_customer/customer_api.dart';
import 'package:mobile_ai_erp/data/sharedpref/shared_preference_helper.dart';
import 'package:mobile_ai_erp/domain/entity/storefront_customer/storefront_customer.dart';

abstract class AccountCustomerDataSource {
  Future<Map<String, dynamic>> login(String email, String password);
  Future<Map<String, dynamic>> register(String name, String email, String password);
  Future<void> forgotPassword(String email);
  Future<StorefrontCustomer> getProfile();
  Future<StorefrontCustomer> updateProfile(Map<String, dynamic> data);
}

class AccountCustomerApiDataSource implements AccountCustomerDataSource {
  final StorefrontCustomerApi _customerApi;
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
  Future<StorefrontCustomer> getProfile() async {
    try {
      // Get the stored customer ID (set during login)
      final customerId = await _prefs.getCustomerId();
      print('🔵 [AccountCustomerApiDataSource.getProfile] Stored customer ID: $customerId');
      
      if (customerId == null || customerId.isEmpty) {
        print('❌ [AccountCustomerApiDataSource.getProfile] Customer ID is null or empty!');
        throw Exception('Customer ID not found. User may not be logged in.');
      }
      
      print('📞 [AccountCustomerApiDataSource.getProfile] Calling StorefrontCustomerApi.getProfile($customerId)');
      // Use the new unified endpoint with Prisma include
      final customer = await _customerApi.getProfile();
      print('✅ [AccountCustomerApiDataSource.getProfile] Got customer: ${customer.firstName} ${customer.lastName}');
      return customer;
    } catch (e) {
      print('❌ [AccountCustomerApiDataSource.getProfile] Error: $e');
      rethrow;
    }
  }

  @override
  Future<StorefrontCustomer> updateProfile(Map<String, dynamic> data) {
    return _customerApi.updateProfile(data);
  }
}