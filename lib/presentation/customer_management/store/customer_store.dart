import 'package:mobile_ai_erp/core/stores/error/error_store.dart';
import 'package:mobile_ai_erp/domain/entity/customer/address.dart';
import 'package:mobile_ai_erp/domain/entity/customer/customer.dart';
import 'package:mobile_ai_erp/domain/entity/customer/customer_group.dart';
import 'package:mobile_ai_erp/domain/entity/customer/customer_order.dart';
import 'package:mobile_ai_erp/domain/usecase/customer/add_segment_members_usecase.dart';
import 'package:mobile_ai_erp/domain/usecase/customer/delete_customer_address_usecase.dart';
import 'package:mobile_ai_erp/domain/usecase/customer/delete_customer_group_usecase.dart';
import 'package:mobile_ai_erp/domain/usecase/customer/delete_customer_usecase.dart';
import 'package:mobile_ai_erp/domain/usecase/customer/get_customer_addresses_usecase.dart';
import 'package:mobile_ai_erp/domain/usecase/customer/get_customer_detail_usecase.dart';
import 'package:mobile_ai_erp/domain/usecase/customer/get_customer_groups_usecase.dart';
import 'package:mobile_ai_erp/domain/usecase/customer/get_customer_transactions_usecase.dart';
import 'package:mobile_ai_erp/domain/usecase/customer/get_customers_usecase.dart';
import 'package:mobile_ai_erp/domain/usecase/customer/get_segment_members_usecase.dart';
import 'package:mobile_ai_erp/domain/usecase/customer/remove_segment_members_usecase.dart';
import 'package:mobile_ai_erp/domain/usecase/customer/save_customer_address_usecase.dart';
import 'package:mobile_ai_erp/domain/usecase/customer/save_customer_group_usecase.dart';
import 'package:mobile_ai_erp/domain/usecase/customer/save_customer_usecase.dart';
import 'package:mobile_ai_erp/domain/usecase/customer/set_default_address_usecase.dart';
import 'package:mobx/mobx.dart';

part 'customer_store.g.dart';

class CustomerStore = CustomerStoreBase with _$CustomerStore;

abstract class CustomerStoreBase with Store {
  CustomerStoreBase(
    this._getCustomersUseCase,
    this._getCustomerDetailUseCase,
    this._saveCustomerUseCase,
    this._deleteCustomerUseCase,
    this._getCustomerGroupsUseCase,
    this._saveCustomerGroupUseCase,
    this._deleteCustomerGroupUseCase,
    this._getCustomerAddressesUseCase,
    this._saveCustomerAddressUseCase,
    this._deleteCustomerAddressUseCase,
    this._setDefaultAddressUseCase,
    this._getCustomerTransactionsUseCase,
    this._getSegmentMembersUseCase,
    this._addSegmentMembersUseCase,
    this._removeSegmentMembersUseCase,
    this.errorStore,
  );

  final GetCustomersUseCase _getCustomersUseCase;
  final GetCustomerDetailUseCase _getCustomerDetailUseCase;
  final SaveCustomerUseCase _saveCustomerUseCase;
  final DeleteCustomerUseCase _deleteCustomerUseCase;
  final GetCustomerGroupsUseCase _getCustomerGroupsUseCase;
  final SaveCustomerGroupUseCase _saveCustomerGroupUseCase;
  final DeleteCustomerGroupUseCase _deleteCustomerGroupUseCase;
  final GetCustomerAddressesUseCase _getCustomerAddressesUseCase;
  final SaveCustomerAddressUseCase _saveCustomerAddressUseCase;
  final DeleteCustomerAddressUseCase _deleteCustomerAddressUseCase;
  final SetDefaultAddressUseCase _setDefaultAddressUseCase;
  final GetCustomerTransactionsUseCase _getCustomerTransactionsUseCase;
  final GetSegmentMembersUseCase _getSegmentMembersUseCase;
  final AddSegmentMembersUseCase _addSegmentMembersUseCase;
  final RemoveSegmentMembersUseCase _removeSegmentMembersUseCase;
  final ErrorStore errorStore;

  // ── State ─────────────────────────────────────────────────────────────────

  @observable
  bool isLoading = false;

  @observable
  ObservableList<Customer> customers = ObservableList<Customer>();

  @observable
  int currentPage = 1;

  @observable
  int totalPages = 1;

  @observable
  int totalItems = 0;

  @observable
  ObservableList<CustomerGroup> groups = ObservableList<CustomerGroup>();

  @observable
  int groupCurrentPage = 1;

  @observable
  int groupTotalPages = 1;

  @observable
  int groupTotalItems = 0;

  @observable
  ObservableList<Address> activeAddresses = ObservableList<Address>();

  @observable
  String? activeCustomerId;

  @observable
  ObservableList<CustomerOrder> activeTransactions =
      ObservableList<CustomerOrder>();

  @observable
  ObservableList<Customer> segmentMembers = ObservableList<Customer>();

  @observable
  String? activeGroupId;

  @observable
  int segmentMembersCurrentPage = 1;

  @observable
  int segmentMembersTotalPages = 1;

  // ── Computed ──────────────────────────────────────────────────────────────

  @computed
  bool get hasMoreCustomers => currentPage < totalPages;

  @computed
  bool get hasMoreGroups => groupCurrentPage < groupTotalPages;

  @computed
  bool get hasMoreSegmentMembers =>
      segmentMembersCurrentPage < segmentMembersTotalPages;

  // ── Customers ─────────────────────────────────────────────────────────────

  @action
  Future<void> loadCustomers({
    int page = 1,
    String? search,
    String? status,
    String? groupId,
    String? sortBy,
    String? sortOrder,
    bool append = false,
  }) async {
    await _runWithLoading(() async {
      final result = await _getCustomersUseCase.call(
        params: GetCustomersParams(
          page: page,
          search: search,
          status: status,
          groupId: groupId,
          sortBy: sortBy,
          sortOrder: sortOrder,
        ),
      );
      if (append) {
        customers.addAll(result.data);
      } else {
        customers = ObservableList<Customer>.of(result.data);
      }
      currentPage = result.meta.page;
      totalPages = result.meta.totalPages;
      totalItems = result.meta.totalItems;
    });
  }

  @action
  Future<void> loadMoreCustomers({
    String? search,
    String? status,
    String? groupId,
    String? sortBy,
    String? sortOrder,
  }) async {
    if (!hasMoreCustomers || isLoading) return;
    await loadCustomers(
      page: currentPage + 1,
      search: search,
      status: status,
      groupId: groupId,
      sortBy: sortBy,
      sortOrder: sortOrder,
      append: true,
    );
  }

  @action
  Future<void> saveCustomer(Customer customer) async {
    final saved = await _saveCustomerUseCase.call(params: customer);
    _upsertCustomer(saved);
    await _refreshGroupMemberCounts();
  }

  @action
  Future<void> deleteCustomer(String customerId) async {
    await _deleteCustomerUseCase.call(params: customerId);
    customers.removeWhere((c) => c.id == customerId);
    totalItems = (totalItems - 1).clamp(0, totalItems);
    if (activeCustomerId == customerId) {
      activeCustomerId = null;
      activeAddresses.clear();
      activeTransactions.clear();
    }
    await _refreshGroupMemberCounts();
  }

  @action
  Future<void> deactivateCustomer(String customerId) async {
    final customer = findCustomerById(customerId);
    if (customer == null) return;

    final deactivatedCustomer = customer.copyWith(
      status: CustomerStatus.deactivated,
    );
    await saveCustomer(deactivatedCustomer);
  }

  @action
  Future<void> loadCustomerDetail(String customerId) async {
    await _runWithLoading(() async {
      final customer = await _getCustomerDetailUseCase.call(params: customerId);
      if (customer != null) _upsertCustomer(customer);
    });
  }

  // ── Addresses ─────────────────────────────────────────────────────────────

  @action
  Future<void> loadAddresses(String customerId) async {
    activeCustomerId = customerId;
    await _runWithLoading(() async {
      final loaded = await _getCustomerAddressesUseCase.call(
        params: customerId,
      );
      activeAddresses = ObservableList<Address>.of(loaded);
    });
  }

  @action
  Future<void> saveAddress(Address address) async {
    final saved = await _saveCustomerAddressUseCase.call(params: address);
    if (activeCustomerId == saved.customerId) {
      _upsertAddress(saved);
    }
  }

  @action
  Future<void> deleteAddress(String customerId, String addressId) async {
    await _deleteCustomerAddressUseCase.call(
      params: DeleteCustomerAddressParams(
        customerId: customerId,
        addressId: addressId,
      ),
    );
    activeAddresses.removeWhere((a) => a.id == addressId);
  }

  @action
  Future<void> setDefaultAddress(String customerId, String addressId) async {
    await _setDefaultAddressUseCase.call(
      params: SetDefaultAddressParams(
        customerId: customerId,
        addressId: addressId,
      ),
    );
    if (activeCustomerId == customerId) {
      for (var i = 0; i < activeAddresses.length; i++) {
        final addr = activeAddresses[i];
        activeAddresses[i] = addr.copyWith(isDefault: addr.id == addressId);
      }
    }
  }

  // ── Transactions ──────────────────────────────────────────────────────────

  @action
  Future<void> loadCustomerTransactions(String customerId) async {
    await _runWithLoading(() async {
      final transactions = await _getCustomerTransactionsUseCase.call(
        params: customerId,
      );
      activeTransactions = ObservableList<CustomerOrder>.of(transactions);
    });
  }

  // ── Groups ────────────────────────────────────────────────────────────────
  @action
  Future<void> loadGroups({
    int page = 1,
    String? search,
    String? sortBy,
    String? sortOrder,
    bool append = false,
  }) async {
    await _runWithLoading(() async {
      final result = await _getCustomerGroupsUseCase.call(
        params: GetCustomerGroupsParams(
          page: page,
          search: search,
          sortBy: sortBy,
          sortOrder: sortOrder,
        ),
      );

      if (append) {
        groups.addAll(result.data);
      } else {
        groups = ObservableList<CustomerGroup>.of(result.data);
      }

      groupCurrentPage = result.meta.page;
      groupTotalPages = result.meta.totalPages;
      groupTotalItems = result.meta.totalItems;
    });
  }

  @action
  Future<void> saveCustomerGroup(CustomerGroup group) async {
    final saved = await _saveCustomerGroupUseCase.call(params: group);
    _upsertGroup(saved);
  }

  @action
  Future<void> deleteCustomerGroup(String groupId) async {
    await _deleteCustomerGroupUseCase.call(params: groupId);
    groups.removeWhere((g) => g.id == groupId);
    if (activeGroupId == groupId) {
      activeGroupId = null;
      segmentMembers.clear();
    }
  }

  // ── Segment members ───────────────────────────────────────────────────────

  @action
  Future<void> loadSegmentMembers(String groupId, {int page = 1}) async {
    activeGroupId = groupId;
    await _runWithLoading(() async {
      final result = await _getSegmentMembersUseCase.call(
        params: GetSegmentMembersParams(groupId: groupId, page: page),
      );
      if (page == 1) {
        segmentMembers = ObservableList<Customer>.of(result.data);
      } else {
        segmentMembers.addAll(result.data);
      }
      segmentMembersCurrentPage = result.meta.page;
      segmentMembersTotalPages = result.meta.totalPages;
    });
  }

  @action
  Future<void> addSegmentMembers(
    String groupId,
    List<String> customerIds,
  ) async {
    await _addSegmentMembersUseCase.call(
      params: AddSegmentMembersParams(
        groupId: groupId,
        customerIds: customerIds,
      ),
    );
    // Re-fetch members and refresh group to get updated memberCount
    await loadSegmentMembers(groupId);
    await _refreshGroupById(groupId);
  }

  @action
  Future<void> removeSegmentMembers(
    String groupId,
    List<String> customerIds,
  ) async {
    await _removeSegmentMembersUseCase.call(
      params: RemoveSegmentMembersParams(
        groupId: groupId,
        customerIds: customerIds,
      ),
    );
    await loadSegmentMembers(groupId);
    await _refreshGroupById(groupId);
  }

  // ── Finders ───────────────────────────────────────────────────────────────

  Customer? findCustomerById(String? id) =>
      _findById(customers, id, (c) => c.id);

  CustomerGroup? findGroupById(String? id) =>
      _findById(groups, id, (g) => g.id);

  int customerCountForGroup(String groupId) {
    final group = groups.where((g) => g.id == groupId).firstOrNull;
    return group?.memberCount ?? 0;
  }

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

  Future<void> _refreshGroupById(String groupId) async {
    try {
      final result = await _getCustomerGroupsUseCase.call(
        params: const GetCustomerGroupsParams(pageSize: 100),
      );
      final updated = result.data.where((g) => g.id == groupId).firstOrNull;
      if (updated != null) _upsertGroup(updated);
    } catch (_) {
      // Non-critical refresh — ignore failures
    }
  }

  Future<void> _refreshGroupMemberCounts() async {
    if (groups.isEmpty) return;
    try {
      final result = await _getCustomerGroupsUseCase.call(
        params: GetCustomerGroupsParams(
          page: groupCurrentPage,
          pageSize: groups.length.clamp(1, 100),
        ),
      );
      for (final updated in result.data) {
        _upsertGroup(updated);
      }
    } catch (_) {
      // Non-critical refresh — ignore failures
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
      compare: (a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()),
    );
  }

  @action
  void _upsert<T>({
    required ObservableList<T> list,
    required T item,
    required String Function(T item) idSelector,
    required int Function(T left, T right) compare,
  }) {
    final index = list.indexWhere(
      (existing) => idSelector(existing) == idSelector(item),
    );
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
