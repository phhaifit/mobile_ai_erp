import '../../../domain/entity/address/address.dart';
import '../../../domain/repository/account/address_repository.dart';
import '../../network/apis/storefront/addresses_api.dart';

class AddressRepositoryImpl implements AddressRepository {
  final AddressesApi _api;

  AddressRepositoryImpl(this._api);

  @override
  Future<List<Address>> getAddresses() => _api.getAddresses();

  @override
  Future<void> addAddress(Address address) => _api.createAddress(address);

  @override
  Future<void> updateAddress(Address address) =>
      _api.updateAddress(address.id, address);

  @override
  Future<void> setDefault(String id) => _api.setDefault(id);

  @override
  Future<void> deleteAddress(String id) => _api.deleteAddress(id);
}
