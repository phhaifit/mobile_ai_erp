import 'dart:async';
import 'package:mobile_ai_erp/core/data/network/dio/dio_client.dart';
import 'package:mobile_ai_erp/data/network/constants/endpoints.dart';
import 'package:mobile_ai_erp/domain/entity/customer/customer.dart';

class CustomerApi {
  final DioClient _dioClient;

  CustomerApi(this._dioClient);

  /// Login customer
  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final res = await _dioClient.dio.post(
        Endpoints.customerLogin,
        data: {'email': email, 'password': password},
      );
      return res.data;
    } catch (e) {
      rethrow;
    }
  }

  /// Register customer
  Future<Map<String, dynamic>> register(String name, String email, String password) async {
    try {
      final res = await _dioClient.dio.post(
        Endpoints.customerRegister,
        data: {'name': name, 'email': email, 'password': password},
      );
      return res.data;
    } catch (e) {
      rethrow;
    }
  }

  /// Forgot password
  Future<void> forgotPassword(String email) async {
    try {
      await _dioClient.dio.post(
        Endpoints.customerForgotPassword,
        data: {'email': email},
      );
    } catch (e) {
      rethrow;
    }
  }

  /// Get customer profile (Token provides identity)
  Future<Customer> getProfile() async {
    try {
      final res = await _dioClient.dio.get(Endpoints.customerProfile);
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
        Endpoints.customerProfile,
        data: data,
      );
      return Customer.fromJson(res.data);
    } catch (e) {
      print('❌ [CustomerApi.updateProfile] Error: $e');
      rethrow;
    }
  }

  // Get loyalty points (NOTE: Backend endpoint needed)
  Future<Map<String, dynamic>> getLoyaltyPoints() async {
    try {
      final res = await _dioClient.dio.get(Endpoints.customerLoyalty);
      return res.data;
    } catch (e) {
      print('❌ [CustomerApi.getLoyaltyPoints] Error: $e');
      rethrow;
    }
  }
}