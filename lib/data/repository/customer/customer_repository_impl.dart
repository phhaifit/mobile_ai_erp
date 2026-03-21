import 'package:mobile_ai_erp/data/local/datasources/customer/customer_datasource.dart';
import 'package:mobile_ai_erp/domain/entity/customer/address.dart';
import 'package:mobile_ai_erp/domain/entity/customer/customer.dart';
import 'package:mobile_ai_erp/domain/entity/customer/customer_group.dart';
import 'package:mobile_ai_erp/domain/repository/customer/customer_repository.dart';

class CustomerRepositoryImpl extends CustomerRepository {
  CustomerRepositoryImpl(this._dataSource);

  final CustomerDataSource _dataSource;

  @override
  Future<List<Customer>> getCustomers() => _dataSource.getCustomers();

  @override
  Future<Customer> saveCustomer(Customer customer) =>
      _dataSource.saveCustomer(customer);

  @override
  Future<void> deleteCustomer(String customerId) =>
      _dataSource.deleteCustomer(customerId);

  @override
  Future<List<Address>> getAddresses(String customerId) =>
      _dataSource.getAddresses(customerId);

  @override
  Future<Address> saveAddress(Address address) =>
      _dataSource.saveAddress(address);

  @override
  Future<void> deleteAddress(String addressId) =>
      _dataSource.deleteAddress(addressId);

  @override
  Future<void> setDefaultAddress(String customerId, String addressId) =>
      _dataSource.setDefaultAddress(customerId, addressId);

  @override
  Future<List<CustomerGroup>> getCustomerGroups() =>
      _dataSource.getCustomerGroups();

  @override
  Future<CustomerGroup> saveCustomerGroup(CustomerGroup group) =>
      _dataSource.saveCustomerGroup(group);

  @override
  Future<void> deleteCustomerGroup(String groupId) =>
      _dataSource.deleteCustomerGroup(groupId);

  @override
  Future<Map<String, int>> getCustomerCountsByGroup(
          List<String> groupIds) =>
      _dataSource.getCustomerCountsByGroup(groupIds);
}
