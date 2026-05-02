import 'dart:async';

import 'package:mobile_ai_erp/data/network/apis/storefront_address/address_api.dart';
import 'package:mobile_ai_erp/data/sharedpref/shared_preference_helper.dart';
import 'package:mobile_ai_erp/domain/entity/storefront_address/storefront_address.dart';

abstract class AddressDataSource {
  Future<List<StorefrontAddress>> getAddresses();
  Future<StorefrontAddress> createAddress(Map<String, dynamic> data);
  Future<StorefrontAddress> updateAddress(String id, Map<String, dynamic> data);
  Future<void> deleteAddress(String id);
  Future<void> setDefaultAddress(String id);
}

class AddressApiDataSource implements AddressDataSource {
  final StorefrontAddressApi _addressApi;
  final SharedPreferenceHelper _prefs;

  AddressApiDataSource(this._addressApi, this._prefs);

  @override
  Future<List<StorefrontAddress>> getAddresses() async {
    try {
      // Get the stored customer ID (set during login)
      final customerId = await _prefs.customerId;
      print('🔵 [AddressApiDataSource.getAddresses] Stored customer ID: $customerId');
      
      if (customerId == null || customerId.isEmpty) {
        print('❌ [AddressApiDataSource.getAddresses] Customer ID is null or empty!');
        throw Exception('Customer ID not found. User may not be logged in.');
      }
      
      print('📞 [AddressApiDataSource.getAddresses] Calling AddressApi.getAddressesFromCustomer($customerId)');
      // Use the new unified endpoint with Prisma include
      final addresses = await _addressApi.getAddresses();
      print('✅ [AddressApiDataSource.getAddresses] Got ${addresses.length} addresses');
      return addresses;
    } catch (e) {
      print('❌ [AddressApiDataSource.getAddresses] Error: $e');
      rethrow;
    }
  }

  @override
  Future<StorefrontAddress> createAddress(Map<String, dynamic> data) {
    return _addressApi.createAddress(data);
  }

  @override
  Future<StorefrontAddress> updateAddress(String id, Map<String, dynamic> data) {
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