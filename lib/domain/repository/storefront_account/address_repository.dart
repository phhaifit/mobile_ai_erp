import '../../entity/storefront_address/storefront_address.dart';

abstract class StorefrontAddressRepository {
  Future<List<StorefrontAddress>> getAddresses();
  Future<void> addAddress(StorefrontAddress address);
  Future<void> updateAddress(StorefrontAddress address);
  Future<void> setDefault(String id);
  Future<void> deleteAddress(String id);
}