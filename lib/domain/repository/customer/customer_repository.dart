import 'package:mobile_ai_erp/domain/entity/customer/address.dart';
import 'package:mobile_ai_erp/domain/entity/customer/customer.dart';
import 'package:mobile_ai_erp/domain/entity/customer/customer_group.dart';

abstract class CustomerRepository {
  // Customers
  Future<List<Customer>> getCustomers();
  Future<Customer> saveCustomer(Customer customer);
  Future<void> deleteCustomer(String customerId);

  // Addresses
  Future<List<Address>> getAddresses(String customerId);
  Future<Address> saveAddress(Address address);
  Future<void> deleteAddress(String addressId);
  Future<void> setDefaultAddress(String customerId, String addressId);

  // Customer Groups
  Future<List<CustomerGroup>> getCustomerGroups();
  Future<CustomerGroup> saveCustomerGroup(CustomerGroup group);
  Future<void> deleteCustomerGroup(String groupId);

  // Dashboard stats
  Future<Map<String, int>> getCustomerCountsByGroup(List<String> groupIds);
}
