import 'package:mobile_ai_erp/domain/entity/customer/address.dart';
import 'package:mobile_ai_erp/domain/entity/customer/customer.dart';
import 'package:mobile_ai_erp/domain/entity/customer/customer_group.dart';
import 'package:mobile_ai_erp/domain/entity/customer/customer_validation_exception.dart';

class CustomerDataSource {
  final List<CustomerGroup> _groups = <CustomerGroup>[
    CustomerGroup(
      id: 'group_vip',
      name: 'VIP',
      description: 'High-value customers with premium benefits.',
      colorHex: '#6A1B9A',
      createdAt: DateTime(2023, 1, 1),
      updatedAt: DateTime(2023, 1, 1),
    ),
    CustomerGroup(
      id: 'group_wholesale',
      name: 'Wholesale',
      description: 'Business customers purchasing in bulk.',
      colorHex: '#1565C0',
      createdAt: DateTime(2023, 1, 1),
      updatedAt: DateTime(2023, 1, 1),
    ),
    CustomerGroup(
      id: 'group_retail',
      name: 'Retail',
      description: 'Standard retail customers.',
      colorHex: '#2E7D32',
      createdAt: DateTime(2023, 1, 1),
      updatedAt: DateTime(2023, 1, 1),
    ),
    CustomerGroup(
      id: 'group_new',
      name: 'New Customers',
      description: 'Customers who joined in the last 30 days.',
      colorHex: '#EF6C00',
      createdAt: DateTime(2023, 1, 1),
      updatedAt: DateTime(2023, 1, 1),
    ),
  ];

  final List<Customer> _customers = <Customer>[
    Customer(
      id: 'cust_alice',
      firstName: 'Alice',
      lastName: 'Johnson',
      email: 'alice.johnson@example.com',
      phone: '+1-555-0101',
      groupId: 'group_vip',
      status: CustomerStatus.active,
      type: CustomerType.individual,
      createdAt: DateTime(2024, 1, 15),
    ),
    Customer(
      id: 'cust_bob',
      firstName: 'Bob',
      lastName: 'Smith',
      email: 'bob.smith@example.com',
      phone: '+1-555-0102',
      groupId: 'group_wholesale',
      status: CustomerStatus.active,
      type: CustomerType.business,
      notes: 'Prefers invoice payment. Contact via email only.',
      createdAt: DateTime(2024, 2, 3),
    ),
    Customer(
      id: 'cust_carol',
      firstName: 'Carol',
      lastName: 'Williams',
      email: 'carol.w@example.com',
      phone: '+1-555-0103',
      groupId: 'group_retail',
      status: CustomerStatus.active,
      type: CustomerType.individual,
      createdAt: DateTime(2024, 3, 20),
    ),
    Customer(
      id: 'cust_david',
      firstName: 'David',
      lastName: 'Lee',
      email: 'david.lee@example.com',
      groupId: 'group_new',
      status: CustomerStatus.active,
      type: CustomerType.individual,
      createdAt: DateTime(2025, 11, 1),
    ),
    Customer(
      id: 'cust_enterprise',
      firstName: 'Tech',
      lastName: 'Corp Ltd',
      email: 'procurement@techcorp.example.com',
      phone: '+1-555-0200',
      groupId: 'group_wholesale',
      status: CustomerStatus.active,
      type: CustomerType.business,
      notes: 'Net-30 payment terms. Main contact: Jane Doe.',
      createdAt: DateTime(2023, 8, 10),
    ),
    Customer(
      id: 'cust_inactive',
      firstName: 'Mark',
      lastName: 'Brown',
      email: 'mark.brown@example.com',
      status: CustomerStatus.deactivated,
      type: CustomerType.individual,
      createdAt: DateTime(2023, 5, 5),
    ),
  ];

  final List<Address> _addresses = <Address>[
    const Address(
      id: 'addr_alice_home',
      customerId: 'cust_alice',
      label: 'Home',
      type: AddressType.home,
      street: '123 Maple Street',
      city: 'New York',
      state: 'NY',
      countryCode: 'US',
      postalCode: '10001',
      isDefault: true,
    ),
    const Address(
      id: 'addr_alice_office',
      customerId: 'cust_alice',
      label: 'Office',
      type: AddressType.office,
      street: '456 Fifth Ave, Suite 800',
      city: 'New York',
      state: 'NY',
      countryCode: 'US',
      postalCode: '10018',
    ),
    const Address(
      id: 'addr_bob_hq',
      customerId: 'cust_bob',
      label: 'Headquarters',
      type: AddressType.home,
      street: '789 Industrial Blvd',
      city: 'Chicago',
      state: 'IL',
      countryCode: 'US',
      postalCode: '60601',
      isDefault: true,
    ),
    const Address(
      id: 'addr_carol_home',
      customerId: 'cust_carol',
      label: 'Home',
      type: AddressType.home,
      street: '22 Oak Lane',
      city: 'Austin',
      state: 'TX',
      countryCode: 'US',
      postalCode: '73301',
      isDefault: true,
    ),
    const Address(
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
    const Address(
      id: 'addr_enterprise_shipping',
      customerId: 'cust_enterprise',
      label: 'Warehouse',
      type: AddressType.warehouse,
      street: '500 Commerce Way',
      city: 'Fremont',
      state: 'CA',
      countryCode: 'US',
      postalCode: '94536',
    ),
  ];

  // ── Groups ────────────────────────────────────────────────────────────────

  Future<List<CustomerGroup>> getCustomerGroups() async =>
      List<CustomerGroup>.from(_groups)
        ..sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));

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
    final hasMembers = _customers.any((c) => c.groupId == groupId);
    if (hasMembers) {
      throw const CustomerValidationException(
        'Reassign or remove customers from this group first.',
      );
    }
    _groups.removeWhere((g) => g.id == groupId);
  }

  // ── Customers ─────────────────────────────────────────────────────────────

  Future<List<Customer>> getCustomers() async => List<Customer>.from(_customers)
    ..sort(
      (a, b) => a.fullName.toLowerCase().compareTo(b.fullName.toLowerCase()),
    );

  Future<Customer> saveCustomer(Customer customer) async {
    final firstName = customer.firstName.trim();
    final lastName = customer.lastName.trim();
    final email = customer.email.trim().toLowerCase();

    if (firstName.isEmpty && lastName.isEmpty) {
      throw const CustomerValidationException(
        'First name or last name is required.',
      );
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
          existing.id != customerId && existing.email.toLowerCase() == email,
    );
    if (hasDuplicateEmail) {
      throw const CustomerValidationException(
        'A customer with this email already exists.',
      );
    }

    if (customer.groupId != null) {
      final groupExists = _groups.any((g) => g.id == customer.groupId);
      if (!groupExists) {
        throw const CustomerValidationException('Selected group not found.');
      }
    }

    final saved = customer.copyWith(
      id: customerId.isEmpty ? _generateId('cust') : customerId,
      firstName: firstName,
      lastName: lastName,
      email: email,
      phone: _normalizeNullable(customer.phone),
      avatarUrl: _normalizeNullable(customer.avatarUrl),
      groupId: _normalizeNullable(customer.groupId),
      notes: _normalizeNullable(customer.notes),
    );
    _upsertById(_customers, saved, (c) => c.id);
    return saved;
  }

  Future<void> deleteCustomer(String customerId) async {
    _addresses.removeWhere((a) => a.customerId == customerId);
    _customers.removeWhere((c) => c.id == customerId);
  }

  // ── Addresses ─────────────────────────────────────────────────────────────

  Future<List<Address>> getAddresses(String customerId) async {
    final list = _addresses.where((a) => a.customerId == customerId).toList()
      ..sort((a, b) {
        if (a.isDefault && !b.isDefault) return -1;
        if (!a.isDefault && b.isDefault) return 1;
        return a.label.toLowerCase().compareTo(b.label.toLowerCase());
      });
    return list;
  }

  Future<Address> saveAddress(Address address) async {
    final label = address.label.trim();
    final street = address.street.trim();
    final city = address.city.trim();
    final country = address.countryCode.trim().toUpperCase();

    if (label.isEmpty) {
      throw const CustomerValidationException('Address label is required.');
    }
    if (street.isEmpty) {
      throw const CustomerValidationException('Street is required.');
    }
    if (city.isEmpty) {
      throw const CustomerValidationException('City is required.');
    }
    if (country.isEmpty) {
      throw const CustomerValidationException('Country is required.');
    }

    final customerExists = _customers.any((c) => c.id == address.customerId);
    if (!customerExists) {
      throw const CustomerValidationException('Customer not found.');
    }

    final addressId = address.id.trim();
    final hasDuplicateLabel = _addresses.any(
      (existing) =>
          existing.id != addressId &&
          existing.customerId == address.customerId &&
          _normalize(existing.label) == _normalize(label),
    );
    if (hasDuplicateLabel) {
      throw const CustomerValidationException(
        'Address labels must be unique for this customer.',
      );
    }

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

  Future<void> setDefaultAddress(String customerId, String addressId) async {
    for (var i = 0; i < _addresses.length; i++) {
      final addr = _addresses[i];
      if (addr.customerId != customerId) continue;
      _addresses[i] = addr.copyWith(isDefault: addr.id == addressId);
    }
  }

  // ── Dashboard ─────────────────────────────────────────────────────────────

  Future<Map<String, int>> getCustomerCountsByGroup(
    List<String> groupIds,
  ) async {
    final counts = <String, int>{for (final id in groupIds) id: 0};
    for (final customer in _customers) {
      final gid = customer.groupId;
      if (gid != null && counts.containsKey(gid)) {
        counts[gid] = (counts[gid] ?? 0) + 1;
      }
    }
    return counts;
  }

  // ── Helpers ───────────────────────────────────────────────────────────────

  String _normalize(String value) => value.trim().toLowerCase();

  String? _normalizeNullable(String? value) {
    final trimmed = value?.trim();
    return trimmed == null || trimmed.isEmpty ? null : trimmed;
  }

  bool _isValidEmail(String email) {
    return RegExp(
      r'^[a-zA-Z0-9._%+\-]+@[a-zA-Z0-9.\-]+\.[a-zA-Z]{2,}$',
    ).hasMatch(email);
  }

  String _generateId(String prefix) =>
      '${prefix}_${DateTime.now().microsecondsSinceEpoch}';

  void _upsertById<T>(
    List<T> items,
    T value,
    String Function(T item) idSelector,
  ) {
    final index = items.indexWhere(
      (item) => idSelector(item) == idSelector(value),
    );
    if (index >= 0) {
      items[index] = value;
    } else {
      items.add(value);
    }
  }
}