import 'package:mobx/mobx.dart';
import 'package:uuid/uuid.dart';
import '../../../domain/entity/supplier/supplier.dart';
import '../../../domain/repository/supplier/supplier_repository.dart';

part 'supplier_store.g.dart';

class SupplierStore = _SupplierStore with _$SupplierStore;

abstract class _SupplierStore with Store {
  final SupplierRepository _repository;
  final _uuid = const Uuid();

  _SupplierStore(this._repository);

  @observable
  ObservableList<Supplier> suppliers = ObservableList();

  @observable
  bool isLoading = false;

  @observable
  String? errorMessage;

  @observable
  String searchQuery = '';

  // productId -> list of supplierIds
  @observable
  ObservableMap<String, ObservableList<String>> productSupplierMap =
      ObservableMap();

  // supplierId -> list of productIds
  @observable
  ObservableMap<String, ObservableList<String>> supplierProductMap =
      ObservableMap();

  @computed
  List<Supplier> get filteredSuppliers {
    if (searchQuery.isEmpty) return suppliers;
    final q = searchQuery.toLowerCase();
    return suppliers
        .where((s) =>
            s.name.toLowerCase().contains(q) ||
            s.contactName.toLowerCase().contains(q) ||
            s.phone.contains(q) ||
            s.email.toLowerCase().contains(q))
        .toList();
  }

  @action
  void setSearchQuery(String query) {
    searchQuery = query;
  }

  @action
  Future<void> fetchSuppliers() async {
    isLoading = true;
    errorMessage = null;
    try {
      final result = await _repository.getAll();
      suppliers = ObservableList.of(result);
    } catch (e) {
      errorMessage = 'Failed to load suppliers.';
    } finally {
      isLoading = false;
    }
  }

  @action
  Future<bool> addSupplier({
    required String name,
    String contactName = '',
    String phone = '',
    String email = '',
    String address = '',
    String notes = '',
  }) async {
    isLoading = true;
    errorMessage = null;
    try {
      final now = DateTime.now();
      final supplier = Supplier(
        id: _uuid.v4(),
        name: name,
        contactName: contactName,
        phone: phone,
        email: email,
        address: address,
        notes: notes,
        isActive: true,
        createdAt: now,
        updatedAt: now,
      );
      await _repository.add(supplier);
      suppliers.add(supplier);
      return true;
    } catch (e) {
      errorMessage = 'Failed to add supplier.';
      return false;
    } finally {
      isLoading = false;
    }
  }

  @action
  Future<bool> updateSupplier(Supplier supplier) async {
    isLoading = true;
    errorMessage = null;
    try {
      final updated = supplier.copyWith(updatedAt: DateTime.now());
      await _repository.update(updated);
      final index = suppliers.indexWhere((s) => s.id == updated.id);
      if (index != -1) suppliers[index] = updated;
      return true;
    } catch (e) {
      errorMessage = 'Failed to update supplier.';
      return false;
    } finally {
      isLoading = false;
    }
  }

  @action
  Future<bool> deleteSupplier(String id) async {
    isLoading = true;
    errorMessage = null;
    try {
      await _repository.delete(id);
      suppliers.removeWhere((s) => s.id == id);
      return true;
    } catch (e) {
      errorMessage = 'Failed to delete supplier.';
      return false;
    } finally {
      isLoading = false;
    }
  }

  @action
  Future<void> toggleActive(Supplier supplier) async {
    await updateSupplier(supplier.copyWith(isActive: !supplier.isActive));
  }

  // ---------- Product–Supplier Mapping ----------

  @action
  Future<void> fetchSuppliersForProduct(String productId) async {
    try {
      final ids = await _repository.getSupplierIdsForProduct(productId);
      productSupplierMap[productId] = ObservableList.of(ids);
    } catch (_) {}
  }

  @action
  Future<void> fetchProductsForSupplier(String supplierId) async {
    try {
      final ids = await _repository.getProductIdsForSupplier(supplierId);
      supplierProductMap[supplierId] = ObservableList.of(ids);
    } catch (_) {}
  }

  @action
  Future<void> linkSupplierToProduct(
      String productId, String supplierId) async {
    await _repository.linkSupplierToProduct(productId, supplierId);
    // Update productSupplierMap
    productSupplierMap.putIfAbsent(productId, () => ObservableList());
    if (!productSupplierMap[productId]!.contains(supplierId)) {
      productSupplierMap[productId]!.add(supplierId);
    }
    // Update supplierProductMap (reverse)
    supplierProductMap.putIfAbsent(supplierId, () => ObservableList());
    if (!supplierProductMap[supplierId]!.contains(productId)) {
      supplierProductMap[supplierId]!.add(productId);
    }
  }

  @action
  Future<void> unlinkSupplierFromProduct(
      String productId, String supplierId) async {
    await _repository.unlinkSupplierFromProduct(productId, supplierId);
    productSupplierMap[productId]?.remove(supplierId);
    supplierProductMap[supplierId]?.remove(productId);
  }

  List<Supplier> getSuppliersForProduct(String productId) {
    final ids = productSupplierMap[productId] ?? [];
    return suppliers.where((s) => ids.contains(s.id)).toList();
  }

  List<Supplier> getUnlinkedSuppliersForProduct(String productId) {
    final ids = productSupplierMap[productId] ?? [];
    return suppliers.where((s) => !ids.contains(s.id) && s.isActive).toList();
  }

  List<String> getProductIdsForSupplier(String supplierId) {
    return supplierProductMap[supplierId]?.toList() ?? [];
  }

  // Mock product list — replace with ProductRepository in Phase 2
  final Map<String, String> allMockProducts = {
    'product_001': 'Laptop Dell XPS 15',
    'product_002': 'Wireless Mouse',
    'product_003': 'USB-C Hub',
    'product_004': 'Mechanical Keyboard',
    'product_005': 'Monitor LG 27"',
  };

  List<MapEntry<String, String>> getUnlinkedProductsForSupplier(
      String supplierId) {
    final linked = supplierProductMap[supplierId] ?? [];
    return allMockProducts.entries
        .where((e) => !linked.contains(e.key))
        .toList();
  }
}
