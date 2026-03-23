import '../../../domain/entity/supplier/supplier.dart';
import '../../../domain/repository/supplier/supplier_repository.dart';

class SupplierMockRepository implements SupplierRepository {
  final List<Supplier> _suppliers = _seedSuppliers();

  // productId -> Set<supplierId>
  final Map<String, Set<String>> _productSupplierMap = {
    'product_001': {'sup_001', 'sup_003'},
    'product_002': {'sup_002'},
    'product_003': {'sup_001', 'sup_004'},
  };

  static List<Supplier> _seedSuppliers() {
    final now = DateTime.now();
    return [
      Supplier(
        id: 'sup_001',
        name: 'Alpha Trading Co.',
        contactName: 'Nguyen Van A',
        phone: '0901234567',
        email: 'alpha@trading.vn',
        address: '123 Le Loi, Q1, HCMC',
        notes: 'Main electronics supplier',
        isActive: true,
        createdAt: now.subtract(const Duration(days: 60)),
        updatedAt: now.subtract(const Duration(days: 5)),
      ),
      Supplier(
        id: 'sup_002',
        name: 'Beta Supplies Ltd.',
        contactName: 'Tran Thi B',
        phone: '0912345678',
        email: 'beta@supplies.vn',
        address: '456 Nguyen Hue, Q1, HCMC',
        notes: 'Office stationery & accessories',
        isActive: true,
        createdAt: now.subtract(const Duration(days: 45)),
        updatedAt: now.subtract(const Duration(days: 10)),
      ),
      Supplier(
        id: 'sup_003',
        name: 'Gamma Logistics',
        contactName: 'Le Van C',
        phone: '0923456789',
        email: 'gamma@logistics.vn',
        address: '789 Cach Mang Thang 8, Q3, HCMC',
        notes: '',
        isActive: false,
        createdAt: now.subtract(const Duration(days: 90)),
        updatedAt: now.subtract(const Duration(days: 30)),
      ),
      Supplier(
        id: 'sup_004',
        name: 'Delta Components',
        contactName: 'Pham Thi D',
        phone: '0934567890',
        email: 'delta@components.vn',
        address: '321 Dien Bien Phu, Binh Thanh, HCMC',
        notes: 'Hardware & components specialist',
        isActive: true,
        createdAt: now.subtract(const Duration(days: 20)),
        updatedAt: now.subtract(const Duration(days: 1)),
      ),
      Supplier(
        id: 'sup_005',
        name: 'Epsilon Raw Materials',
        contactName: 'Hoang Van E',
        phone: '0945678901',
        email: 'epsilon@raw.vn',
        address: '654 Vo Thi Sau, Q3, HCMC',
        notes: 'Raw material imports',
        isActive: true,
        createdAt: now.subtract(const Duration(days: 15)),
        updatedAt: now,
      ),
    ];
  }

  @override
  Future<List<Supplier>> getAll() async {
    await Future.delayed(const Duration(milliseconds: 400));
    return List.unmodifiable(_suppliers);
  }

  @override
  Future<Supplier?> getById(String id) async {
    await Future.delayed(const Duration(milliseconds: 200));
    try {
      return _suppliers.firstWhere((s) => s.id == id);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> add(Supplier supplier) async {
    await Future.delayed(const Duration(milliseconds: 300));
    _suppliers.add(supplier);
  }

  @override
  Future<void> update(Supplier supplier) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final index = _suppliers.indexWhere((s) => s.id == supplier.id);
    if (index != -1) {
      _suppliers[index] = supplier;
    }
  }

  @override
  Future<void> delete(String id) async {
    await Future.delayed(const Duration(milliseconds: 300));
    _suppliers.removeWhere((s) => s.id == id);
    // Remove all mappings for this supplier
    for (final key in _productSupplierMap.keys) {
      _productSupplierMap[key]?.remove(id);
    }
  }

  @override
  Future<List<String>> getSupplierIdsForProduct(String productId) async {
    await Future.delayed(const Duration(milliseconds: 200));
    return (_productSupplierMap[productId] ?? {}).toList();
  }

  @override
  Future<void> linkSupplierToProduct(
      String productId, String supplierId) async {
    await Future.delayed(const Duration(milliseconds: 200));
    _productSupplierMap.putIfAbsent(productId, () => {}).add(supplierId);
  }

  @override
  Future<void> unlinkSupplierFromProduct(
      String productId, String supplierId) async {
    await Future.delayed(const Duration(milliseconds: 200));
    _productSupplierMap[productId]?.remove(supplierId);
  }

  @override
  Future<List<String>> getProductIdsForSupplier(String supplierId) async {
    await Future.delayed(const Duration(milliseconds: 200));
    return _productSupplierMap.entries
        .where((e) => e.value.contains(supplierId))
        .map((e) => e.key)
        .toList();
  }
}
