import 'package:mobile_ai_erp/domain/entity/inventory_audit_outbound/audit_line.dart';
import 'package:mobile_ai_erp/domain/entity/inventory_audit_outbound/audit_record.dart';
import 'package:mobile_ai_erp/domain/entity/inventory_audit_outbound/inventory_item.dart';
import 'package:mobile_ai_erp/domain/entity/inventory_audit_outbound/inventory_warehouse.dart';
import 'package:mobile_ai_erp/domain/entity/inventory_audit_outbound/outbound_record.dart';
import 'package:mobile_ai_erp/domain/repository/inventory_audit_outbound/inventory_audit_outbound_repository.dart';

class MockInventoryAuditOutboundRepository
    extends InventoryAuditOutboundRepository {
  final List<InventoryWarehouse> _warehouses = const [
    InventoryWarehouse(id: 'wh-01', name: 'Main Warehouse', location: 'Campus A'),
    InventoryWarehouse(id: 'wh-02', name: 'North Warehouse', location: 'District 7'),
    InventoryWarehouse(id: 'wh-03', name: 'Outlet Warehouse', location: 'Thu Duc'),
  ];

  List<InventoryItem> _inventory = const [
    InventoryItem(
      warehouseId: 'wh-01',
      productId: 'p-01',
      productName: 'A4 Paper Box',
      systemQty: 120,
    ),
    InventoryItem(
      warehouseId: 'wh-01',
      productId: 'p-02',
      productName: 'Ink Cartridge',
      systemQty: 40,
    ),
    InventoryItem(
      warehouseId: 'wh-01',
      productId: 'p-03',
      productName: 'Label Roll',
      systemQty: 65,
    ),
    InventoryItem(
      warehouseId: 'wh-02',
      productId: 'p-01',
      productName: 'A4 Paper Box',
      systemQty: 90,
    ),
    InventoryItem(
      warehouseId: 'wh-02',
      productId: 'p-03',
      productName: 'Label Roll',
      systemQty: 75,
    ),
    InventoryItem(
      warehouseId: 'wh-03',
      productId: 'p-02',
      productName: 'Ink Cartridge',
      systemQty: 15,
    ),
  ];

  final List<AuditRecord> _auditRecords = [];
  final List<OutboundRecord> _outboundRecords = [];

  int _auditIdCounter = 1;
  int _outboundIdCounter = 1;

  @override
  Future<List<InventoryWarehouse>> getWarehouses() async {
    return List<InventoryWarehouse>.unmodifiable(_warehouses);
  }

  @override
  Future<List<InventoryItem>> getInventoryByWarehouse(String warehouseId) async {
    final items = _inventory
        .where((item) => item.warehouseId == warehouseId)
        .toList(growable: false)
      ..sort((a, b) => a.productName.compareTo(b.productName));

    return List<InventoryItem>.unmodifiable(items);
  }

  @override
  Future<AuditRecord> saveAuditSession({
    required String warehouseId,
    required List<AuditLine> lines,
  }) async {
    final warehouse = _findWarehouse(warehouseId);

    for (final line in lines) {
      _updateSystemQuantity(
        warehouseId: warehouseId,
        productId: line.productId,
        productName: line.productName,
        newQuantity: line.physicalQty,
        unit: line.unit,
      );
    }

    final mismatchCount = lines.where((line) => line.discrepancy != 0).length;

    final record = AuditRecord(
      id: 'audit-${_auditIdCounter.toString().padLeft(3, '0')}',
      warehouseId: warehouseId,
      warehouseName: warehouse.name,
      createdAt: DateTime.now(),
      lines: List<AuditLine>.unmodifiable(lines),
      totalMismatchCount: mismatchCount,
    );

    _auditIdCounter++;
    _auditRecords.add(record);
    return record;
  }

  @override
  Future<List<AuditRecord>> getAuditRecords() async {
    final records = List<AuditRecord>.from(_auditRecords)
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return List<AuditRecord>.unmodifiable(records);
  }

  @override
  Future<OutboundRecord> submitOutbound({
    required String warehouseId,
    required String productId,
    required int quantity,
    String? note,
  }) async {
    if (quantity <= 0) {
      throw Exception('Outbound quantity must be greater than zero.');
    }

    final warehouse = _findWarehouse(warehouseId);
    final item = _findInventoryItem(warehouseId, productId);
    if (item == null) {
      throw Exception('Product not found in selected warehouse.');
    }

    if (quantity > item.systemQty) {
      throw Exception('Outbound quantity exceeds available stock.');
    }

    _updateSystemQuantity(
      warehouseId: warehouseId,
      productId: productId,
      productName: item.productName,
      newQuantity: item.systemQty - quantity,
      unit: item.unit,
    );

    final record = OutboundRecord(
      id: 'out-${_outboundIdCounter.toString().padLeft(3, '0')}',
      warehouseId: warehouseId,
      warehouseName: warehouse.name,
      productId: productId,
      productName: item.productName,
      quantity: quantity,
      note: note,
      createdAt: DateTime.now(),
    );

    _outboundIdCounter++;
    _outboundRecords.add(record);
    return record;
  }

  @override
  Future<List<OutboundRecord>> getOutboundRecords() async {
    final records = List<OutboundRecord>.from(_outboundRecords)
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return List<OutboundRecord>.unmodifiable(records);
  }

  InventoryWarehouse _findWarehouse(String warehouseId) {
    return _warehouses.firstWhere(
      (warehouse) => warehouse.id == warehouseId,
      orElse: () => throw Exception('Warehouse not found.'),
    );
  }

  InventoryItem? _findInventoryItem(String warehouseId, String productId) {
    try {
      return _inventory.firstWhere(
        (item) => item.warehouseId == warehouseId && item.productId == productId,
      );
    } catch (_) {
      return null;
    }
  }

  void _updateSystemQuantity({
    required String warehouseId,
    required String productId,
    required String productName,
    required int newQuantity,
    required String unit,
  }) {
    final existing = _findInventoryItem(warehouseId, productId);

    if (existing == null) {
      _inventory = [
        ..._inventory,
        InventoryItem(
          warehouseId: warehouseId,
          productId: productId,
          productName: productName,
          systemQty: newQuantity,
          unit: unit,
        ),
      ];
      return;
    }

    _inventory = _inventory
        .map(
          (item) => item.warehouseId == warehouseId && item.productId == productId
              ? item.copyWith(systemQty: newQuantity)
              : item,
        )
        .toList(growable: false);
  }
}
