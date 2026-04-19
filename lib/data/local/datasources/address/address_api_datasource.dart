import 'dart:async';

import 'package:mobile_ai_erp/data/network/apis/address/address_api.dart';
import 'package:mobile_ai_erp/domain/entity/address/address.dart';

abstract class AddressDataSource {
  Future<List<Address>> getAddresses();
  Future<Address> createAddress(Map<String, dynamic> data);
  Future<Address> updateAddress(String id, Map<String, dynamic> data);
  Future<void> deleteAddress(String id);
  Future<void> setDefaultAddress(String id);
}

class AddressApiDataSource implements AddressDataSource {
  final AddressApi _addressApi;

  AddressApiDataSource(this._addressApi);

  @override
  Future<List<Address>> getAddresses() {
    return _addressApi.getAddresses();
  }

  @override
  Future<Address> createAddress(Map<String, dynamic> data) {
    return _addressApi.createAddress(data);
  }

  @override
  Future<Address> updateAddress(String id, Map<String, dynamic> data) {
    return _addressApi.updateAddress(id, data);
  }

  @override
  Future<void> deleteAddress(String id) {
    return _addressApi.deleteAddress(id);
  }

  @override
  Future<void> setDefaultAddress(String id) {
    return _addressApi.setDefaultAddress(id);
  }
}