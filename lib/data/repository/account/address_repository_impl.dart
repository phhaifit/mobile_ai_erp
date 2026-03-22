import '../../../domain/entity/address/address.dart';
import '../../../domain/repository/account/address_repository.dart';
import '../../local/datasources/account/address_mock_datasource.dart';

class AddressRepositoryImpl implements AddressRepository {
  final AddressMockDataSource _dataSource;

  AddressRepositoryImpl(this._dataSource);

  @override
  Future<List<Address>> getAddresses() => _dataSource.getAddresses();

  @override
  Future<void> addAddress(Address address) => _dataSource.addAddress(address);

  @override
  Future<void> updateAddress(Address address) => _dataSource.updateAddress(address);

  @override
  Future<void> setDefault(String id) => _dataSource.setDefault(id);
}