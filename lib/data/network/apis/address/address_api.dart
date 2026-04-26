import 'dart:async';
import 'package:mobile_ai_erp/core/data/network/dio/dio_client.dart';
import 'package:mobile_ai_erp/data/network/constants/endpoints.dart';
import 'package:mobile_ai_erp/domain/entity/address/address.dart';

class AddressApi {
  final DioClient _dioClient;

  AddressApi(this._dioClient);

  /// Get customer addresses (Securely fetches only the logged-in user's addresses)
  Future<List<Address>> getAddresses() async {
    try {
      final res = await _dioClient.dio.get(Endpoints.customerAddresses);
      // Ensure we map the list properly
      final List data = res.data ?? [];
      return data.map((e) => Address.fromJson(e)).toList();
    } catch (e) {
      print('❌ [AddressApi.getAddresses] Error: $e');
      rethrow;
    }
  }

  /// Create address
  Future<Address> createAddress(Map<String, dynamic> data) async {
    try {
      final res = await _dioClient.dio.post(
        Endpoints.customerAddresses,
        data: data,
      );
      return Address.fromJson(res.data);
    } catch (e) {
      rethrow;
    }
  }

  /// Update address
  Future<Address> updateAddress(String id, Map<String, dynamic> data) async {
    try {
      final res = await _dioClient.dio.patch(
        '${Endpoints.customerAddresses}/$id',
        data: data,
      );
      return Address.fromJson(res.data);
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
  Future<Address> setDefaultAddress(String id) async {
    try {
      // Our backend is built to recognize is_default in the standard update payload
      return await updateAddress(id, {'is_default': true});
    } catch (e) {
      rethrow;
    }
  }
}