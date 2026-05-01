import 'package:dio/dio.dart';
import 'package:mobile_ai_erp/data/network/apis/customer/customer_api.dart';
import 'package:mobile_ai_erp/data/network/apis/customer/customer_segment_api.dart';
import 'package:mobile_ai_erp/data/network/apis/customer/dto/address_response.dart';
import 'package:mobile_ai_erp/data/network/apis/customer/dto/customer_detail_response.dart';
import 'package:mobile_ai_erp/data/network/apis/customer/dto/customer_segment_list_response.dart';
import 'package:mobile_ai_erp/data/network/apis/customer/dto/customer_segment_member_response.dart';
import 'package:mobile_ai_erp/data/network/apis/customer/dto/customer_transaction_response.dart';
import 'package:mobile_ai_erp/domain/entity/customer/address.dart';
import 'package:mobile_ai_erp/domain/entity/customer/customer.dart';
import 'package:mobile_ai_erp/domain/entity/customer/customer_group.dart';
import 'package:mobile_ai_erp/domain/entity/customer/customer_transaction.dart';
import 'package:mobile_ai_erp/domain/repository/customer/customer_repository.dart';

class CustomerRepositoryImpl extends CustomerRepository {
  CustomerRepositoryImpl(this._customerApi, this._segmentApi);

  final CustomerApi _customerApi;
  final CustomerSegmentApi _segmentApi;

  // ─── Customers ────────────────────────────────────────────────────────────

  @override
  Future<CustomerListResult> getCustomers({
    int page = 1,
    int pageSize = 20,
    String? search,
    String? status,
    String? groupId,
  }) async {
    final response = await _customerApi.getCustomers(
      page: page,
      pageSize: pageSize,
      search: search,
      status: status,
      groupId: groupId,
    );
    return CustomerListResult(
      data: response.data.map(_mapCustomerDtoToEntity).toList(),
      meta: response.meta,
    );
  }

  @override
  Future<Customer?> getCustomerById(String id) async {
    try {
      final dto = await _customerApi.getCustomerById(id);
      return _mapCustomerDetailToEntity(dto);
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) return null;
      rethrow;
    }
  }

  @override
  Future<Customer> saveCustomer(Customer customer) async {
    final body = _buildCustomerBody(customer);
    final CustomerDetailDto dto;
    if (customer.id.isEmpty) {
      dto = await _customerApi.createCustomer(body);
    } else {
      dto = await _customerApi.updateCustomer(customer.id, body);
    }
    return _mapCustomerDetailToEntity(dto);
  }

  @override
  Future<void> deleteCustomer(String customerId) async {
    await _customerApi.deleteCustomer(customerId);
  }

  // ─── Addresses ────────────────────────────────────────────────────────────

  @override
  Future<List<Address>> getAddresses(String customerId) async {
    final dtos = await _customerApi.getAddresses(customerId);
    return dtos.map(_mapAddressToEntity).toList();
  }

  @override
  Future<Address> saveAddress(Address address) async {
    final body = _buildAddressBody(address);
    final AddressDto dto;
    if (address.id.isEmpty) {
      dto = await _customerApi.createAddress(address.customerId, body);
    } else {
      dto = await _customerApi.updateAddress(
          address.customerId, address.id, body);
    }
    return _mapAddressToEntity(dto);
  }

  @override
  Future<void> deleteAddress(String customerId, String addressId) async {
    await _customerApi.deleteAddress(customerId, addressId);
  }

  @override
  Future<void> setDefaultAddress(
      String customerId, String addressId) async {
    await _customerApi.setDefaultAddress(customerId, addressId);
  }

  // ─── Groups / Segments ────────────────────────────────────────────────────

  @override
  Future<CustomerGroupListResult> getCustomerGroups({
    int page = 1,
    int pageSize = 20,
    String? search,
    String? sortBy,
    String? sortOrder,
  }) async {
    final response = await _segmentApi.getSegments(
      page: page,
      pageSize: pageSize,
      search: search,
      sortBy: sortBy,
      sortOrder: sortOrder,
    );
    return CustomerGroupListResult(
      data: response.data.map(_mapSegmentToEntity).toList(),
      meta: response.meta,
    );
  }

  @override
  Future<CustomerGroup> saveCustomerGroup(CustomerGroup group) async {
    final body = _buildSegmentBody(group);
    final CustomerSegmentDto dto;
    if (group.id.isEmpty) {
      dto = await _segmentApi.createSegment(body);
    } else {
      dto = await _segmentApi.updateSegment(group.id, body);
    }
    return _mapSegmentToEntity(dto);
  }

  @override
  Future<void> deleteCustomerGroup(String groupId) async {
    await _segmentApi.deleteSegment(groupId);
  }

  // ─── Segment members ──────────────────────────────────────────────────────

  @override
  Future<CustomerMemberListResult> getSegmentMembers(
    String groupId, {
    int page = 1,
    int pageSize = 20,
  }) async {
    final response = await _segmentApi.getMembers(
      groupId,
      page: page,
      pageSize: pageSize,
    );
    return CustomerMemberListResult(
      data: response.data.map(_mapMemberToEntity).toList(),
      meta: response.meta,
    );
  }

  @override
  Future<void> addSegmentMembers(
      String groupId, List<String> customerIds) async {
    await _segmentApi.addMembers(groupId, customerIds);
  }

  @override
  Future<void> removeSegmentMembers(
      String groupId, List<String> customerIds) async {
    await _segmentApi.removeMembers(groupId, customerIds);
  }

  // ─── Transactions ─────────────────────────────────────────────────────────

  @override
  Future<List<CustomerTransaction>> getCustomerTransactions(
      String customerId) async {
    final dtos = await _customerApi.getTransactions(customerId);
    return dtos.map(_mapTransactionToEntity).toList();
  }

  // ─── Mappers ──────────────────────────────────────────────────────────────

  Customer _mapCustomerDtoToEntity(dynamic dto) {
    final name = (dto.name as String?) ?? '';
    final parts = name.trim().split(' ');
    final firstName = parts.first;
    final lastName = parts.length > 1 ? parts.skip(1).join(' ') : '';
    return Customer(
      id: dto.id as String,
      firstName: firstName,
      lastName: lastName,
      email: (dto.email as String?) ?? '',
      phone: dto.phone as String?,
      groupId: dto.groupId as String?,
      status: CustomerStatus.fromApiString(dto.status as String?) ??
          CustomerStatus.active,
      createdAt: DateTime.parse(dto.createdAt as String),
      updatedAt: _tryParseDate(dto.updatedAt as String?),
    );
  }

  Customer _mapCustomerDetailToEntity(CustomerDetailDto dto) {
    final parts = dto.name.trim().split(' ');
    final firstName = parts.first;
    final lastName = parts.length > 1 ? parts.skip(1).join(' ') : '';
    return Customer(
      id: dto.id,
      firstName: firstName,
      lastName: lastName,
      email: dto.email ?? '',
      phone: dto.phone,
      groupId: dto.groupId,
      notes: dto.notes,
      avatarUrl: dto.avatarUrl,
      status: CustomerStatus.fromApiString(dto.status) ?? CustomerStatus.active,
      createdAt: DateTime.parse(dto.createdAt),
      updatedAt: _tryParseDate(dto.updatedAt),
      lastSignInAt: _tryParseDate(dto.lastSignInAt),
      emailVerifiedAt: _tryParseDate(dto.emailVerifiedAt),
    );
  }

  Customer _mapMemberToEntity(CustomerSegmentMemberDto dto) {
    final parts = dto.name.trim().split(' ');
    final firstName = parts.first;
    final lastName = parts.length > 1 ? parts.skip(1).join(' ') : '';
    return Customer(
      id: dto.id,
      firstName: firstName,
      lastName: lastName,
      email: dto.email ?? '',
      phone: dto.phone,
      status: CustomerStatus.fromApiString(dto.status) ?? CustomerStatus.active,
      createdAt: DateTime.parse(dto.createdAt),
      lastSignInAt: _tryParseDate(dto.lastSignInAt),
      emailVerifiedAt: _tryParseDate(dto.emailVerifiedAt),
    );
  }

  Address _mapAddressToEntity(AddressDto dto) {
    return Address(
      id: dto.id,
      customerId: dto.customerId,
      label: dto.label,
      street: dto.street,
      city: dto.city,
      countryCode: dto.countryCode,
      type: _parseAddressType(dto.type),
      state: dto.state,
      postalCode: dto.postalCode,
      isDefault: dto.isDefault,
    );
  }

  CustomerGroup _mapSegmentToEntity(CustomerSegmentDto dto) {
    final now = DateTime.now();
    return CustomerGroup(
      id: dto.id,
      name: dto.name,
      description: dto.description,
      colorHex: dto.color,
      memberCount: dto.memberCount,
      createdAt: _tryParseDate(dto.createdAt) ?? now,
      updatedAt: _tryParseDate(dto.updatedAt) ?? now,
    );
  }

  CustomerTransaction _mapTransactionToEntity(CustomerTransactionDto dto) {
    return CustomerTransaction(
      id: dto.id,
      orderId: dto.orderId,
      status: dto.status,
      amount: double.tryParse(dto.amount) ?? 0,
      createdAt: DateTime.parse(dto.createdAt),
    );
  }

  // ─── Request builders ─────────────────────────────────────────────────────

  Map<String, dynamic> _buildCustomerBody(Customer c) {
    final body = <String, dynamic>{'name': c.fullName};
    if (c.email.isNotEmpty) body['email'] = c.email;
    body['phone'] = c.phone;
    if (c.groupId != null) body['groupId'] = c.groupId;
    if (c.notes != null) body['notes'] = c.notes;
    body['status'] = c.status.apiValue;
    return body;
  }

  Map<String, dynamic> _buildAddressBody(Address a) {
    return <String, dynamic>{
      'label': a.label,
      'street': a.street,
      'city': a.city,
      'countryCode': a.countryCode,
      'isDefault': a.isDefault,
      'type': a.type.name,
      if (a.state != null) 'state': a.state,
      if (a.postalCode != null) 'postalCode': a.postalCode,
    };
  }

  Map<String, dynamic> _buildSegmentBody(CustomerGroup g) {
    return <String, dynamic>{
      'name': g.name,
      'description': g.description,
      'color': g.colorHex,
    };
  }

  // ─── Utilities ────────────────────────────────────────────────────────────

  DateTime? _tryParseDate(String? input) {
    if (input == null || input.isEmpty) return null;
    return DateTime.tryParse(input);
  }

  AddressType _parseAddressType(String? value) {
    switch (value) {
      case 'shipping':
        return AddressType.shipping;
      case 'billing':
        return AddressType.billing;
      default:
        return AddressType.both;
    }
  }
}
