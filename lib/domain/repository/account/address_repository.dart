import '../../entity/address/address.dart';

abstract class AddressRepository {
  Future<List<Address>> getAddresses();
  Future<void> addAddress(Address address);
  Future<void> updateAddress(Address address);
  Future<void> setDefault(String id);
}