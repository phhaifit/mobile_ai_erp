import 'dart:async';
import 'package:mobile_ai_erp/core/data/network/dio/dio_client.dart';
import 'package:mobile_ai_erp/data/network/constants/endpoints.dart';
import 'package:mobile_ai_erp/domain/entity/storefront_address/storefront_address.dart';

class StorefrontAddressApi {
  final DioClient _dioClient;

  StorefrontAddressApi(this._dioClient);

  /// Get customer addresses (Securely fetches only the logged-in user's addresses)
  Future<List<StorefrontAddress>> getAddresses() async {
    try {
      final res = await _dioClient.dio.get(Endpoints.customerAddresses);
      // Ensure we map the list properly
      final List data = res.data ?? [];
      return data.map((e) => StorefrontAddress.fromJson(e)).toList();
    } catch (e) {
      print('❌ [StorefrontAddressApi.getAddresses] Error: $e');
      rethrow;
    }
  }

  /// Create address
  Future<StorefrontAddress> createAddress(Map<String, dynamic> data) async {
    try {
      final res = await _dioClient.dio.post(
        Endpoints.customerAddresses,
        data: data,
      );
      return StorefrontAddress.fromJson(res.data);
    } catch (e) {
      print('❌ [StorefrontAddressApi.createAddress] Error: $e');
      rethrow;
    }
  }

  /// Update address
  Future<StorefrontAddress> updateAddress(String id, Map<String, dynamic> data) async {
    try {
      final res = await _dioClient.dio.patch(
        '${Endpoints.customerAddresses}/$id',
        data: data,
      );
      return StorefrontAddress.fromJson(res.data);
    } catch (e) {
      rethrow;
    }
  }

  /// Delete address
  Future<void> deleteAddress(String id) async {
    try {
      await _dioClient.dio.delete('${Endpoints.customerAddresses}/$id');
    } catch (e) {
      rethrow;
    }
  }

  /// Set default address
  Future<StorefrontAddress> setDefaultAddress(String id) async {
    try {
      // Our backend is built to recognize isDefault in the standard update payload
      return await updateAddress(id, {'isDefault': true});
    } catch (e) {
      rethrow;
    }
  }
}