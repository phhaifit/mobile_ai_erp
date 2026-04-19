import '../../../domain/entity/address/address.dart';
import '../../../domain/repository/account/address_repository.dart';
import '../../local/datasources/address/address_api_datasource.dart';

class AddressRepositoryImpl implements AddressRepository {
  final AddressApiDataSource _dataSource;

  AddressRepositoryImpl(this._dataSource);

  @override
  Future<List<Address>> getAddresses() => _dataSource.getAddresses();

  @override
  Future<void> addAddress(Address address) => _dataSource.createAddress(address.toJson());

  @override
  Future<void> updateAddress(Address address) => _dataSource.updateAddress(address.id, address.toJson());

  @override
  Future<void> setDefault(String id) => _dataSource.setDefaultAddress(id);

  @override
  Future<void> deleteAddress(String id) => _dataSource.deleteAddress(id);
}