import 'dart:async';

import 'package:mobile_ai_erp/data/network/apis/customer/customer_api.dart';
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

  AccountCustomerApiDataSource(this._customerApi);

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
  Future<Customer> getProfile() {
    return _customerApi.getProfile();
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