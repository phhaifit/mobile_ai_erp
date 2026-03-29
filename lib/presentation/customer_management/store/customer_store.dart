import 'package:mobile_ai_erp/core/stores/error/error_store.dart';
import 'package:mobile_ai_erp/domain/entity/customer/address.dart';
import 'package:mobile_ai_erp/domain/entity/customer/customer.dart';
import 'package:mobile_ai_erp/domain/entity/customer/customer_group.dart';
import 'package:mobile_ai_erp/domain/repository/customer/customer_repository.dart';
import 'package:mobx/mobx.dart';

part 'customer_store.g.dart';

class CustomerStore = CustomerStoreBase with _$CustomerStore;

abstract class CustomerStoreBase with Store {
  CustomerStoreBase(this._repository, this.errorStore);

  final CustomerRepository _repository;
  final ErrorStore errorStore;

  @observable
  bool isLoading = false;

  @observable
  bool hasLoadedDashboard = false;

  @observable
  ObservableList<Customer> customers = ObservableList<Customer>();

  @observable
  ObservableList<CustomerGroup> groups = ObservableList<CustomerGroup>();

  @observable
  ObservableMap<String, int> customerCountsByGroup =
      ObservableMap<String, int>();

  @observable
  ObservableList<Address> activeAddresses = ObservableList<Address>();

  @observable
  String? activeCustomerId;

  // ── Dashboard ─────────────────────────────────────────────────────────────

  @action
  Future<void> loadDashboard({bool force = false}) async {
    if (hasLoadedDashboard && !force) return;

    await _runWithLoading(() async {
      final results = await Future.wait<dynamic>(<Future<dynamic>>[
        _repository.getCustomers(),
        _repository.getCustomerGroups(),
      ]);

      customers =
          ObservableList<Customer>.of(results[0] as List<Customer>);
      groups =
          ObservableList<CustomerGroup>.of(results[1] as List<CustomerGroup>);
      customerCountsByGroup = ObservableMap<String, int>.of(
        await _repository.getCustomerCountsByGroup(
          groups.map((g) => g.id).toList(),
        ),
      );
      hasLoadedDashboard = true;
      errorStore.errorMessage = '';
    });
  }

  // ── Customers ─────────────────────────────────────────────────────────────

  @action
  Future<void> saveCustomer(Customer customer) async {
    final saved = await _repository.saveCustomer(customer);
    _upsertCustomer(saved);
    customerCountsByGroup = ObservableMap<String, int>.of(
      await _repository.getCustomerCountsByGroup(
        groups.map((g) => g.id).toList(),
      ),
    );
  }

  @action
  Future<void> deleteCustomer(String customerId) async {
    await _repository.deleteCustomer(customerId);
    customers.removeWhere((c) => c.id == customerId);
    if (activeCustomerId == customerId) {
      activeCustomerId = null;
      activeAddresses.clear();
    }
    customerCountsByGroup = ObservableMap<String, int>.of(
      await _repository.getCustomerCountsByGroup(
        groups.map((g) => g.id).toList(),
      ),
    );
  }

  // ── Addresses ─────────────────────────────────────────────────────────────

  @action
  Future<void> loadAddresses(String customerId) async {
    activeCustomerId = customerId;
    await _runWithLoading(() async {
      final loaded = await _repository.getAddresses(customerId);
      activeAddresses = ObservableList<Address>.of(loaded);
      errorStore.errorMessage = '';
    });
  }

  @action
  Future<void> saveAddress(Address address) async {
    final saved = await _repository.saveAddress(address);
    if (activeCustomerId == saved.customerId) {
      _upsertAddress(saved);
    }
  }

  @action
  Future<void> deleteAddress(String addressId) async {
    await _repository.deleteAddress(addressId);
    activeAddresses.removeWhere((a) => a.id == addressId);
  }

  @action
  Future<void> setDefaultAddress(
      String customerId, String addressId) async {
    await _repository.setDefaultAddress(customerId, addressId);
    if (activeCustomerId == customerId) {
      for (var i = 0; i < activeAddresses.length; i++) {
        final addr = activeAddresses[i];
        activeAddresses[i] = addr.copyWith(isDefault: addr.id == addressId);
      }
    }
  }

  // ── Groups ────────────────────────────────────────────────────────────────

  @action
  Future<void> saveCustomerGroup(CustomerGroup group) async {
    final saved = await _repository.saveCustomerGroup(group);
    _upsertGroup(saved);
    customerCountsByGroup.putIfAbsent(saved.id, () => 0);
  }

  @action
  Future<void> deleteCustomerGroup(String groupId) async {
    await _repository.deleteCustomerGroup(groupId);
    groups.removeWhere((g) => g.id == groupId);
    customerCountsByGroup.remove(groupId);
  }

  // ── Finders ───────────────────────────────────────────────────────────────

  Customer? findCustomerById(String? id) =>
      _findById(customers, id, (c) => c.id);

  CustomerGroup? findGroupById(String? id) =>
      _findById(groups, id, (g) => g.id);

  int customerCountForGroup(String groupId) =>
      customerCountsByGroup[groupId] ?? 0;

  List<Customer> customersInGroup(String groupId) =>
      customers.where((c) => c.groupId == groupId).toList();

  // ── Private helpers ───────────────────────────────────────────────────────

  @action
  Future<void> _runWithLoading(Future<void> Function() callback) async {
    isLoading = true;
    try {
      await callback();
    } catch (error) {
      errorStore.errorMessage = error.toString();
      rethrow;
    } finally {
      isLoading = false;
    }
  }

  @action
  void _upsertCustomer(Customer customer) {
    _upsert<Customer>(
      list: customers,
      item: customer,
      idSelector: (c) => c.id,
      compare: (a, b) =>
          a.fullName.toLowerCase().compareTo(b.fullName.toLowerCase()),
    );
  }

  @action
  void _upsertAddress(Address address) {
    _upsert<Address>(
      list: activeAddresses,
      item: address,
      idSelector: (a) => a.id,
      compare: (a, b) {
        if (a.isDefault && !b.isDefault) return -1;
        if (!a.isDefault && b.isDefault) return 1;
        return a.label.toLowerCase().compareTo(b.label.toLowerCase());
      },
    );
  }

  @action
  void _upsertGroup(CustomerGroup group) {
    _upsert<CustomerGroup>(
      list: groups,
      item: group,
      idSelector: (g) => g.id,
      compare: (a, b) {
        final orderCompare = a.sortOrder.compareTo(b.sortOrder);
        if (orderCompare != 0) return orderCompare;
        return a.name.toLowerCase().compareTo(b.name.toLowerCase());
      },
    );
  }

  @action
  void _upsert<T>({
    required ObservableList<T> list,
    required T item,
    required String Function(T item) idSelector,
    required int Function(T left, T right) compare,
  }) {
    final index =
        list.indexWhere((existing) => idSelector(existing) == idSelector(item));
    if (index >= 0) {
      list[index] = item;
    } else {
      list.add(item);
    }
    final sorted = list.toList()..sort(compare);
    list
      ..clear()
      ..addAll(sorted);
  }

  T? _findById<T>(
    Iterable<T> items,
    String? id,
    String Function(T item) idSelector,
  ) {
    if (id == null || id.isEmpty) return null;
    for (final item in items) {
      if (idSelector(item) == id) return item;
    }
    return null;
  }
}
