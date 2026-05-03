import 'dart:async';
import 'package:mobile_ai_erp/core/data/network/dio/dio_client.dart';
import 'package:mobile_ai_erp/data/network/constants/endpoints.dart';
import 'package:mobile_ai_erp/domain/entity/customer/customer.dart';

class StorefrontCustomerApi {
  final DioClient _dioClient;

  StorefrontCustomerApi(this._dioClient);

  /// Login customer
  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final res = await _dioClient.dio.post(
        Endpoints.storefrontCustomerLogin,
        data: {'email': email, 'password': password},
      );
      return res.data;
    } catch (e) {
      print('❌ [CustomerApi.login] Error: $e');
      rethrow;
    }
  }

  /// Register customer
  Future<Map<String, dynamic>> register(String name, String email, String password) async {
    try {
      final res = await _dioClient.dio.post(
        Endpoints.storefrontCustomerRegister,
        data: {'name': name, 'email': email, 'password': password},
      );
      return res.data;
    } catch (e) {
      print('❌ [CustomerApi.register] Error: $e');
      rethrow;
    }
  }

  /// Forgot password
  Future<void> forgotPassword(String email) async {
    try {
      await _dioClient.dio.post(
        Endpoints.storefrontCustomerForgotPassword,
        data: {'email': email},
      );
    } catch (e) {
      print('❌ [CustomerApi.forgotPassword] Error: $e');
      rethrow;
    }
  }

  /// Get customer profile (Token provides identity)
  Future<Customer> getProfile() async {
    try {
      final res = await _dioClient.dio.get(Endpoints.storefrontCustomerProfile);
      return Customer.fromJson(res.data);
    } catch (e) {
      print('❌ [CustomerApi.getProfile] Error: $e');
      rethrow;
    }
  }

  /// Update customer profile
  Future<Customer> updateProfile(Map<String, dynamic> data) async {
    try {
      final res = await _dioClient.dio.patch(
        Endpoints.storefrontCustomerProfile,
        data: data,
      );
      return Customer.fromJson(res.data);
    } catch (e) {
      print('❌ [CustomerApi.updateProfile] Error: $e');
      rethrow;
    }
  }
}