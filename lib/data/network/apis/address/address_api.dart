import 'dart:async';

import 'package:mobile_ai_erp/core/data/network/dio/dio_client.dart';
import 'package:mobile_ai_erp/data/network/constants/endpoints.dart';
import 'package:mobile_ai_erp/domain/entity/address/address.dart';

class AddressApi {
  final DioClient _dioClient;

  AddressApi(this._dioClient);

  /// Get customer addresses
  Future<List<Address>> getAddresses() async {
    try {
      final res = await _dioClient.dio.get(Endpoints.customerAddresses);
      final List data = res.data['data'] ?? res.data;
      return data.map((e) => Address.fromJson(e)).toList();
    } catch (e) {
      throw e;
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
      throw e;
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
      throw e;
    }
  }

  /// Delete address
  Future<void> deleteAddress(String id) async {
    try {
      await _dioClient.dio.delete('${Endpoints.customerAddresses}/$id');
    } catch (e) {
      throw e;
    }
  }

  /// Set default address
  Future<void> setDefaultAddress(String id) async {
    try {
      await _dioClient.dio.patch('${Endpoints.customerAddresses}/$id/default');
    } catch (e) {
      throw e;
    }
  }
}