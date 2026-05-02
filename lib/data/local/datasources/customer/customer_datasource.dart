import 'package:mobile_ai_erp/domain/entity/customer/address.dart';
import 'package:mobile_ai_erp/domain/entity/customer/customer.dart';
import 'package:mobile_ai_erp/domain/entity/customer/customer_group.dart';
import 'package:mobile_ai_erp/domain/entity/customer/customer_validation_exception.dart';

class CustomerDataSource {
  final List<CustomerGroup> _groups = <CustomerGroup>[
    const CustomerGroup(
      id: 'group_vip',
      name: 'VIP',
      description: 'High-value customers with premium benefits.',
      colorHex: '#6A1B9A',
      sortOrder: 10,
    ),
    const CustomerGroup(
      id: 'group_wholesale',
      name: 'Wholesale',
      description: 'Business customers purchasing in bulk.',
      colorHex: '#1565C0',
      sortOrder: 20,
    ),
    const CustomerGroup(
      id: 'group_retail',
      name: 'Retail',
      description: 'Standard retail customers.',
      colorHex: '#2E7D32',
      sortOrder: 30,
    ),
    const CustomerGroup(
      id: 'group_new',
      name: 'New Customers',
      description: 'Customers who joined in the last 30 days.',
      colorHex: '#EF6C00',
      sortOrder: 40,
    ),
  ];

  final List<Customer> _customers = <Customer>[
    Customer(
      id: 'cust_alice',
      name: 'Alice Johnson',
      email: 'alice.johnson@example.com',
      phone: '+1-555-0101',
      status: CustomerStatus.active,
      createdAt: DateTime(2024, 1, 15),
    ),
    Customer(
      id: 'cust_bob',
      name: 'Bob Smith',
      email: 'bob.smith@example.com',
      phone: '+1-555-0102',
      status: CustomerStatus.active,
      createdAt: DateTime(2024, 2, 3),
    ),
    Customer(
      id: 'cust_carol',
      name: 'Carol Williams',
      email: 'carol.w@example.com',
      phone: '+1-555-0103',
      status: CustomerStatus.active,
      createdAt: DateTime(2024, 3, 20),
    ),
    Customer(
      id: 'cust_david',
      name: 'David Lee',
      email: 'david.lee@example.com',
      status: CustomerStatus.active,
      createdAt: DateTime(2025, 11, 1),
    ),
    Customer(
      id: 'cust_enterprise',
      name: 'Tech Corp Ltd',
      email: 'procurement@techcorp.example.com',
      phone: '+1-555-0200',
      status: CustomerStatus.active,
      createdAt: DateTime(2023, 8, 10),
    ),
    Customer(
      id: 'cust_inactive',
      name: 'Mark Brown',
      email: 'mark.brown@example.com',
      status: CustomerStatus.pending_verification,
      createdAt: DateTime(2023, 5, 5),
    ),
  ];

  final List<Address> _addresses = <Address>[
    Address(
      id: 'addr_alice_office',
      customerId: 'cust_alice',
      label: 'Office',
      type: AddressType.billing,
      street: '456 Fifth Ave, Suite 800',
      city: 'New York',
      state: 'NY',
      countryCode: 'US',
      postalCode: '10018',
    ),
    Address(
      id: 'addr_bob_hq',
      customerId: 'cust_bob',
      label: 'Headquarters',
      type: AddressType.both,
      street: '789 Industrial Blvd',
      city: 'Chicago',
      state: 'IL',
      countryCode: 'US',
      postalCode: '60601',
      isDefault: true,
    ),
    Address(
      id: 'addr_carol_home',
      customerId: 'cust_carol',
      label: 'Home',
      type: AddressType.both,
      street: '22 Oak Lane',
      city: 'Austin',
      state: 'TX',
      countryCode: 'US',
      postalCode: '73301',
      isDefault: true,
    ),
    Address(
      id: 'addr_enterprise_billing',
      customerId: 'cust_enterprise',
      label: 'Billing',
      type: AddressType.billing,
      street: '1 Tech Park Drive',
      city: 'San Jose',
      state: 'CA',
      countryCode: 'US',
      postalCode: '95101',
      isDefault: true,
    ),
    Address(
      id: 'addr_enterprise_shipping',
      customerId: 'cust_enterprise',
      label: 'Warehouse',
      type: AddressType.shipping,
      street: '500 Commerce Way',
      city: 'Fremont',
      state: 'CA',
      countryCode: 'US',
      postalCode: '94536',
    ),
  ];

  // ── Groups ────────────────────────────────────────────────────────────────

  Future<List<CustomerGroup>> getCustomerGroups() async =>
      _sortByOrderThenName(_groups, (g) => g.name, (g) => g.sortOrder);

  Future<CustomerGroup> saveCustomerGroup(CustomerGroup group) async {
    final name = group.name.trim();
    if (name.isEmpty) {
      throw const CustomerValidationException('Group name is required.');
    }

    final groupId = group.id.trim();
    final hasDuplicateName = _groups.any(
      (existing) =>
          existing.id != groupId &&
          _normalize(existing.name) == _normalize(name),
    );
    if (hasDuplicateName) {
      throw const CustomerValidationException('Group names must be unique.');
    }

    final saved = group.copyWith(
      id: groupId.isEmpty ? _generateId('group') : groupId,
      name: name,
      description: _normalizeNullable(group.description),
      colorHex: _normalizeNullable(group.colorHex),
    );
    _upsertById(_groups, saved, (g) => g.id);
    return saved;
  }

  Future<void> deleteCustomerGroup(String groupId) async {
    _groups.removeWhere((g) => g.id == groupId);
  }

  // ── Customers ─────────────────────────────────────────────────────────────

  Future<List<Customer>> getCustomers() async =>
      List<Customer>.from(_customers)
        ..sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));

  Future<Customer> saveCustomer(Customer customer) async {
    final name = customer.name.trim();
    final email = customer.email.trim().toLowerCase();

    if (name.isEmpty) {
      throw const CustomerValidationException('Customer name is required.');
    }
    if (email.isEmpty) {
      throw const CustomerValidationException('Email is required.');
    }
    if (!_isValidEmail(email)) {
      throw const CustomerValidationException('Enter a valid email address.');
    }

    final customerId = customer.id.trim();
    final hasDuplicateEmail = _customers.any(
      (existing) =>
          existing.id != customerId &&
          existing.email.toLowerCase() == email,
    );
    if (hasDuplicateEmail) {
      throw const CustomerValidationException(
          'A customer with this email already exists.');
    }

    final saved = customer.copyWith(
      id: customerId.isEmpty ? _generateId('cust') : customerId,
      name: name,
      email: email,
      phone: _normalizeNullable(customer.phone),
      avatarUrl: _normalizeNullable(customer.avatarUrl),
    );
    _upsertById(_customers, saved, (c) => c.id);
    return saved;
  }

  Future<void> deleteCustomer(String customerId) async {
    _customers.removeWhere((c) => c.id == customerId);
  }

  // ── Addresses ─────────────────────────────────────────────────────────────

  Future<List<Address>> getAddresses() async {
    return List<Address>.from(_addresses)
      ..sort((a, b) {
        if (a.isDefault && !b.isDefault) return -1;
        if (!a.isDefault && b.isDefault) return 1;
        return a.label.toLowerCase().compareTo(b.label.toLowerCase());
      });
  }

  Future<Address> saveAddress(Address address) async {
    final label = address.label.trim();
    final street = address.street.trim();
    final city = address.city.trim();
    final country = address.countryCode.trim().toUpperCase();
    final addressStr = address.label.trim();

    if (addressStr.isEmpty) {
      throw const CustomerValidationException('Address is required.');
    }

    final addressId = address.id.trim();

    final saved = address.copyWith(
      id: addressId.isEmpty ? _generateId('addr') : addressId,
      label: label,
      street: street,
      city: city,
      countryCode: country,
      state: _normalizeNullable(address.state),
      postalCode: _normalizeNullable(address.postalCode),
    );
    _upsertById(_addresses, saved, (a) => a.id);
    return saved;
  }

  Future<void> deleteAddress(String addressId) async {
    _addresses.removeWhere((a) => a.id == addressId);
  }

  Future<void> setDefaultAddress(String addressId) async {
    for (var i = 0; i < _addresses.length; i++) {
      _addresses[i] = _addresses[i].copyWith(isDefault: _addresses[i].id == addressId);
    }
  }

  // ── Helpers ───────────────────────────────────────────────────────────────

  String _normalize(String value) => value.trim().toLowerCase();

  String? _normalizeNullable(String? value) {
    final trimmed = value?.trim();
    return trimmed == null || trimmed.isEmpty ? null : trimmed;
  }

  bool _isValidEmail(String email) {
    return RegExp(r'^[a-zA-Z0-9._%+\-]+@[a-zA-Z0-9.\-]+\.[a-zA-Z]{2,}$')
        .hasMatch(email);
  }

  String _generateId(String prefix) =>
      '${prefix}_${DateTime.now().microsecondsSinceEpoch}';

  void _upsertById<T>(
    List<T> items,
    T value,
    String Function(T item) idSelector,
  ) {
    final index =
        items.indexWhere((item) => idSelector(item) == idSelector(value));
    if (index >= 0) {
      items[index] = value;
    } else {
      items.add(value);
    }
  }

  List<T> _sortByOrderThenName<T>(
    List<T> source,
    String Function(T item) nameSelector,
    int Function(T item) sortOrderSelector,
  ) {
    final items = List<T>.from(source);
    items.sort((left, right) {
      final orderCompare =
          sortOrderSelector(left).compareTo(sortOrderSelector(right));
      if (orderCompare != 0) return orderCompare;
      return nameSelector(left)
          .toLowerCase()
          .compareTo(nameSelector(right).toLowerCase());
    });
    return items;
  }

  Future<Map<String, int>> getCustomerCountsByGroup(List<String> groupIds) async {
    final result = <String, int>{};
    for (final groupId in groupIds) {
      // Since Customer model doesn't have a groupId field,
      // return 0 for all groups
      result[groupId] = 0;
    }
    return result;
  }

  CustomerGroup? findGroupById(String? groupId) {
    if (groupId == null) return null;
    try {
      return _groups.firstWhere((g) => g.id == groupId);
    } catch (e) {
      return null;
    }
  }

  Customer? findCustomerById(String customerId) {
    try {
      return _customers.firstWhere((c) => c.id == customerId);
    } catch (e) {
      return null;
    }
  }

  Address? findAddressById(String addressId) {
    try {
      return _addresses.firstWhere((a) => a.id == addressId);
    } catch (e) {
      return null;
    }
  }
}

const _sentinel = Object();
