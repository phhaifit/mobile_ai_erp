import '../../../domain/entity/storefront_address/storefront_address.dart';
import '../../../domain/repository/account/address_repository.dart';
import '../../local/datasources/storefront_address/address_api_datasource.dart';

class AddressRepositoryImpl implements StorefrontAddressRepository {
  final AddressApiDataSource _dataSource;

  AddressRepositoryImpl(this._dataSource);

  @override
  Future<List<StorefrontAddress>> getAddresses() => _dataSource.getAddresses();

  @override
  Future<void> addAddress(StorefrontAddress address) => _dataSource.createAddress(address.toJson());

  @override
  Future<void> updateAddress(StorefrontAddress address) => _dataSource.updateAddress(address.id, address.toJson());

  @override
  Future<void> setDefault(String id) => _dataSource.setDefaultAddress(id);

  @override
  Future<void> deleteAddress(String id) => _dataSource.deleteAddress(id);
}