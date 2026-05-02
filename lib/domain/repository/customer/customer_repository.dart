import 'package:mobile_ai_erp/data/network/apis/common/pagination_meta.dart';
import 'package:mobile_ai_erp/domain/entity/customer/address.dart';
import 'package:mobile_ai_erp/domain/entity/customer/customer.dart';
import 'package:mobile_ai_erp/domain/entity/customer/customer_group.dart';
import 'package:mobile_ai_erp/domain/entity/customer/customer_order.dart';

class CustomerListResult {
  final List<Customer> data;
  final PaginationMeta meta;
  const CustomerListResult({required this.data, required this.meta});
}

class CustomerGroupListResult {
  final List<CustomerGroup> data;
  final PaginationMeta meta;
  const CustomerGroupListResult({required this.data, required this.meta});
}

class CustomerMemberListResult {
  final List<Customer> data;
  final PaginationMeta meta;
  const CustomerMemberListResult({required this.data, required this.meta});
}

abstract class CustomerRepository {
  // Customers
  Future<CustomerListResult> getCustomers({
    int page = 1,
    int pageSize = 5,
    String? search,
    String? status,
    String? groupId,
    String? sortBy,
    String? sortOrder,
  });
  Future<Customer?> getCustomerById(String id);
  Future<Customer> saveCustomer(Customer customer);
  Future<void> deleteCustomer(String customerId);

  // Addresses
  Future<List<Address>> getAddresses(String customerId);
  Future<Address> saveAddress(Address address);
  Future<void> deleteAddress(String customerId, String addressId);
  Future<void> setDefaultAddress(String customerId, String addressId);

  // Customer Groups / Segments
  Future<CustomerGroupListResult> getCustomerGroups({
    int page = 1,
    int pageSize = 5,
    String? search,
    String? sortBy,
    String? sortOrder,
  });
  Future<CustomerGroup> saveCustomerGroup(CustomerGroup group);
  Future<void> deleteCustomerGroup(String groupId);

  // Segment members
  Future<CustomerMemberListResult> getSegmentMembers(
    String groupId, {
    int page = 1,
    int pageSize = 20,
  });
  Future<void> addSegmentMembers(String groupId, List<String> customerIds);
  Future<void> removeSegmentMembers(String groupId, List<String> customerIds);

  // Transaction history
  Future<List<CustomerOrder>> getCustomerTransactions(String customerId);
}
