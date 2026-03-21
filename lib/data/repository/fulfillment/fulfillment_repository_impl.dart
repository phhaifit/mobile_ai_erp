import 'dart:async';

import 'package:mobile_ai_erp/domain/entity/fulfillment/fulfillment_item.dart';
import 'package:mobile_ai_erp/domain/entity/fulfillment/fulfillment_order.dart';
import 'package:mobile_ai_erp/domain/entity/fulfillment/fulfillment_status.dart';
import 'package:mobile_ai_erp/domain/entity/fulfillment/package_info.dart';
import 'package:mobile_ai_erp/domain/entity/fulfillment/package_item.dart';
import 'package:mobile_ai_erp/domain/entity/fulfillment/tracking_event.dart';
import 'package:mobile_ai_erp/domain/repository/fulfillment/fulfillment_repository.dart';

class FulfillmentRepositoryImpl extends FulfillmentRepository {
  final List<FulfillmentOrder> _orders = _generateMockOrders();

  @override
  Future<List<FulfillmentOrder>> getOrders() async {
    await Future.delayed(const Duration(milliseconds: 500));
    return List.unmodifiable(_orders);
  }

  @override
  Future<FulfillmentOrder?> getOrderById(String id) async {
    await Future.delayed(const Duration(milliseconds: 300));
    try {
      return _orders.firstWhere((o) => o.id == id);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> updateOrderStatus(String id, FulfillmentStatus status) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final order = _orders.firstWhere((o) => o.id == id);
    order.status = status;
    order.updatedAt = DateTime.now();
    order.trackingEvents.add(TrackingEvent(
      id: 'evt-${DateTime.now().millisecondsSinceEpoch}',
      status: status,
      description: 'Order status updated to ${status.displayName}',
      timestamp: DateTime.now(),
      updatedBy: 'System',
    ));
  }

  @override
  Future<void> updateItemPickedQty(
      String orderId, String itemId, int qty) async {
    await Future.delayed(const Duration(milliseconds: 200));
    final order = _orders.firstWhere((o) => o.id == orderId);
    final item = order.items.firstWhere((i) => i.id == itemId);
    item.pickedQuantity = qty;
    order.updatedAt = DateTime.now();
  }

  @override
  Future<void> addPackage(String orderId, PackageInfo package) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final order = _orders.firstWhere((o) => o.id == orderId);
    order.packages.add(package);
    for (final pkgItem in package.items) {
      final item = order.items.firstWhere((i) => i.id == pkgItem.itemId);
      item.packedQuantity += pkgItem.quantity;
    }
    order.updatedAt = DateTime.now();
  }

  @override
  Future<void> updatePackage(String orderId, PackageInfo package) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final order = _orders.firstWhere((o) => o.id == orderId);
    final idx = order.packages.indexWhere((p) => p.id == package.id);
    if (idx != -1) {
      order.packages[idx] = package;
    }
    order.updatedAt = DateTime.now();
  }

  static List<FulfillmentOrder> _generateMockOrders() {
    final now = DateTime.now();
    return [
      FulfillmentOrder(
        id: 'ORD-001',
        customerName: 'Nguyen Van A',
        customerPhone: '0901234567',
        shippingAddress: '123 Le Loi, District 1, Ho Chi Minh City',
        channel: 'Website',
        status: FulfillmentStatus.pending,
        createdAt: now.subtract(const Duration(hours: 2)),
        totalAmount: 1250000,
        items: [
          FulfillmentItem(
            id: 'ITM-001-1',
            productName: 'Wireless Bluetooth Headphones',
            sku: 'WBH-100',
            quantity: 2,
            unitPrice: 450000,
          ),
          FulfillmentItem(
            id: 'ITM-001-2',
            productName: 'USB-C Charging Cable 2m',
            sku: 'UCC-200',
            quantity: 3,
            unitPrice: 75000,
          ),
          FulfillmentItem(
            id: 'ITM-001-3',
            productName: 'Phone Case - iPhone 15',
            sku: 'PC-IP15',
            quantity: 1,
            unitPrice: 125000,
          ),
        ],
        trackingEvents: [
          TrackingEvent(
            id: 'evt-001-1',
            status: FulfillmentStatus.pending,
            description: 'Order received from website',
            timestamp: now.subtract(const Duration(hours: 2)),
            updatedBy: 'System',
          ),
        ],
      ),
      FulfillmentOrder(
        id: 'ORD-002',
        customerName: 'Tran Thi B',
        customerPhone: '0912345678',
        shippingAddress: '456 Nguyen Hue, District 3, Ho Chi Minh City',
        channel: 'Shopee',
        status: FulfillmentStatus.picking,
        createdAt: now.subtract(const Duration(hours: 5)),
        totalAmount: 2800000,
        items: [
          FulfillmentItem(
            id: 'ITM-002-1',
            productName: 'Mechanical Keyboard RGB',
            sku: 'MKB-300',
            quantity: 1,
            pickedQuantity: 1,
            unitPrice: 1500000,
          ),
          FulfillmentItem(
            id: 'ITM-002-2',
            productName: 'Gaming Mouse Pad XL',
            sku: 'GMP-400',
            quantity: 1,
            unitPrice: 350000,
          ),
          FulfillmentItem(
            id: 'ITM-002-3',
            productName: 'Webcam 1080p',
            sku: 'WC-500',
            quantity: 1,
            unitPrice: 950000,
          ),
        ],
        trackingEvents: [
          TrackingEvent(
            id: 'evt-002-1',
            status: FulfillmentStatus.pending,
            description: 'Order synced from Shopee',
            timestamp: now.subtract(const Duration(hours: 5)),
            updatedBy: 'System',
          ),
          TrackingEvent(
            id: 'evt-002-2',
            status: FulfillmentStatus.picking,
            description: 'Picker assigned: Warehouse Staff A',
            timestamp: now.subtract(const Duration(hours: 3)),
            location: 'Warehouse A',
            updatedBy: 'Manager',
          ),
        ],
      ),
      FulfillmentOrder(
        id: 'ORD-003',
        customerName: 'Le Van C',
        customerPhone: '0923456789',
        shippingAddress: '789 Vo Van Tan, Binh Thanh, Ho Chi Minh City',
        channel: 'Lazada',
        status: FulfillmentStatus.packing,
        createdAt: now.subtract(const Duration(hours: 8)),
        totalAmount: 5600000,
        items: [
          FulfillmentItem(
            id: 'ITM-003-1',
            productName: '27" Monitor 4K IPS',
            sku: 'MON-600',
            quantity: 1,
            pickedQuantity: 1,
            packedQuantity: 0,
            unitPrice: 4500000,
          ),
          FulfillmentItem(
            id: 'ITM-003-2',
            productName: 'HDMI Cable 3m',
            sku: 'HDM-700',
            quantity: 2,
            pickedQuantity: 2,
            packedQuantity: 0,
            unitPrice: 150000,
          ),
          FulfillmentItem(
            id: 'ITM-003-3',
            productName: 'Monitor Stand Adjustable',
            sku: 'MST-800',
            quantity: 1,
            pickedQuantity: 1,
            packedQuantity: 0,
            unitPrice: 650000,
          ),
        ],
        trackingEvents: [
          TrackingEvent(
            id: 'evt-003-1',
            status: FulfillmentStatus.pending,
            description: 'Order synced from Lazada',
            timestamp: now.subtract(const Duration(hours: 8)),
            updatedBy: 'System',
          ),
          TrackingEvent(
            id: 'evt-003-2',
            status: FulfillmentStatus.picking,
            description: 'All items picked',
            timestamp: now.subtract(const Duration(hours: 6)),
            location: 'Warehouse B',
            updatedBy: 'Warehouse Staff B',
          ),
          TrackingEvent(
            id: 'evt-003-3',
            status: FulfillmentStatus.packing,
            description: 'Packing in progress',
            timestamp: now.subtract(const Duration(hours: 4)),
            location: 'Packing Station 2',
            updatedBy: 'Warehouse Staff B',
          ),
        ],
      ),
      FulfillmentOrder(
        id: 'ORD-004',
        customerName: 'Pham Thi D',
        customerPhone: '0934567890',
        shippingAddress: '321 Cach Mang Thang Tam, District 10, Ho Chi Minh City',
        channel: 'Facebook',
        status: FulfillmentStatus.shipped,
        createdAt: now.subtract(const Duration(days: 1)),
        totalAmount: 890000,
        items: [
          FulfillmentItem(
            id: 'ITM-004-1',
            productName: 'Portable Bluetooth Speaker',
            sku: 'PBS-900',
            quantity: 1,
            pickedQuantity: 1,
            packedQuantity: 1,
            shippedQuantity: 1,
            unitPrice: 650000,
          ),
          FulfillmentItem(
            id: 'ITM-004-2',
            productName: 'AUX Cable 1.5m',
            sku: 'AUX-101',
            quantity: 2,
            pickedQuantity: 2,
            packedQuantity: 2,
            shippedQuantity: 2,
            unitPrice: 45000,
          ),
          FulfillmentItem(
            id: 'ITM-004-3',
            productName: 'Carrying Pouch',
            sku: 'CP-102',
            quantity: 1,
            pickedQuantity: 1,
            packedQuantity: 1,
            shippedQuantity: 1,
            unitPrice: 150000,
          ),
        ],
        packages: [
          PackageInfo(
            id: 'PKG-004-1',
            orderId: 'ORD-004',
            label: 'Package 1',
            weight: 1.2,
            length: 25,
            width: 20,
            height: 15,
            trackingNumber: 'GHN-9876543210',
            items: [
              PackageItem(
                  itemId: 'ITM-004-1',
                  productName: 'Portable Bluetooth Speaker',
                  quantity: 1),
              PackageItem(
                  itemId: 'ITM-004-2',
                  productName: 'AUX Cable 1.5m',
                  quantity: 2),
              PackageItem(
                  itemId: 'ITM-004-3',
                  productName: 'Carrying Pouch',
                  quantity: 1),
            ],
          ),
        ],
        trackingEvents: [
          TrackingEvent(
            id: 'evt-004-1',
            status: FulfillmentStatus.pending,
            description: 'Order placed via Facebook',
            timestamp: now.subtract(const Duration(days: 1)),
            updatedBy: 'System',
          ),
          TrackingEvent(
            id: 'evt-004-2',
            status: FulfillmentStatus.picking,
            description: 'Items being picked',
            timestamp: now.subtract(const Duration(hours: 20)),
            location: 'Warehouse A',
            updatedBy: 'Warehouse Staff C',
          ),
          TrackingEvent(
            id: 'evt-004-3',
            status: FulfillmentStatus.packed,
            description: 'All items packed in 1 package',
            timestamp: now.subtract(const Duration(hours: 18)),
            location: 'Packing Station 1',
            updatedBy: 'Warehouse Staff C',
          ),
          TrackingEvent(
            id: 'evt-004-4',
            status: FulfillmentStatus.shipped,
            description: 'Handed to GHN for delivery',
            timestamp: now.subtract(const Duration(hours: 12)),
            location: 'Shipping Dock',
            updatedBy: 'Logistics',
          ),
        ],
      ),
      FulfillmentOrder(
        id: 'ORD-005',
        customerName: 'Hoang Van E',
        customerPhone: '0945678901',
        shippingAddress: '555 Hai Ba Trung, District 1, Ho Chi Minh City',
        channel: 'Website',
        status: FulfillmentStatus.partiallyDelivered,
        createdAt: now.subtract(const Duration(days: 2)),
        totalAmount: 3200000,
        notes: 'Customer requested split delivery',
        items: [
          FulfillmentItem(
            id: 'ITM-005-1',
            productName: 'Wireless Earbuds Pro',
            sku: 'WEP-110',
            quantity: 2,
            pickedQuantity: 2,
            packedQuantity: 2,
            shippedQuantity: 1,
            unitPrice: 1200000,
          ),
          FulfillmentItem(
            id: 'ITM-005-2',
            productName: 'Earbuds Case Cover',
            sku: 'ECC-111',
            quantity: 2,
            pickedQuantity: 2,
            packedQuantity: 2,
            shippedQuantity: 1,
            unitPrice: 80000,
          ),
          FulfillmentItem(
            id: 'ITM-005-3',
            productName: 'USB-C Earbuds Adapter',
            sku: 'UEA-112',
            quantity: 2,
            pickedQuantity: 2,
            packedQuantity: 2,
            shippedQuantity: 2,
            unitPrice: 320000,
          ),
        ],
        packages: [
          PackageInfo(
            id: 'PKG-005-1',
            orderId: 'ORD-005',
            label: 'Package 1 (Delivered)',
            weight: 0.5,
            length: 15,
            width: 10,
            height: 8,
            trackingNumber: 'GHTK-1234567890',
            items: [
              PackageItem(
                  itemId: 'ITM-005-1',
                  productName: 'Wireless Earbuds Pro',
                  quantity: 1),
              PackageItem(
                  itemId: 'ITM-005-2',
                  productName: 'Earbuds Case Cover',
                  quantity: 1),
              PackageItem(
                  itemId: 'ITM-005-3',
                  productName: 'USB-C Earbuds Adapter',
                  quantity: 2),
            ],
          ),
          PackageInfo(
            id: 'PKG-005-2',
            orderId: 'ORD-005',
            label: 'Package 2 (Pending)',
            weight: 0.3,
            length: 12,
            width: 8,
            height: 6,
            trackingNumber: 'GHTK-0987654321',
            items: [
              PackageItem(
                  itemId: 'ITM-005-1',
                  productName: 'Wireless Earbuds Pro',
                  quantity: 1),
              PackageItem(
                  itemId: 'ITM-005-2',
                  productName: 'Earbuds Case Cover',
                  quantity: 1),
            ],
          ),
        ],
        trackingEvents: [
          TrackingEvent(
            id: 'evt-005-1',
            status: FulfillmentStatus.pending,
            description: 'Order placed on website',
            timestamp: now.subtract(const Duration(days: 2)),
            updatedBy: 'System',
          ),
          TrackingEvent(
            id: 'evt-005-2',
            status: FulfillmentStatus.picking,
            description: 'Items picked',
            timestamp: now.subtract(const Duration(days: 1, hours: 20)),
            location: 'Warehouse A',
            updatedBy: 'Warehouse Staff A',
          ),
          TrackingEvent(
            id: 'evt-005-3',
            status: FulfillmentStatus.packed,
            description: 'Split into 2 packages per customer request',
            timestamp: now.subtract(const Duration(days: 1, hours: 16)),
            location: 'Packing Station 3',
            updatedBy: 'Warehouse Staff A',
          ),
          TrackingEvent(
            id: 'evt-005-4',
            status: FulfillmentStatus.partiallyDelivered,
            description: 'Package 1 delivered, Package 2 in transit',
            timestamp: now.subtract(const Duration(hours: 6)),
            location: 'Customer Address',
            updatedBy: 'GHTK',
          ),
        ],
      ),
      FulfillmentOrder(
        id: 'ORD-006',
        customerName: 'Vo Thi F',
        customerPhone: '0956789012',
        shippingAddress: '88 Phan Xich Long, Phu Nhuan, Ho Chi Minh City',
        channel: 'Shopee',
        status: FulfillmentStatus.delivered,
        createdAt: now.subtract(const Duration(days: 3)),
        totalAmount: 750000,
        items: [
          FulfillmentItem(
            id: 'ITM-006-1',
            productName: 'Laptop Stand Aluminum',
            sku: 'LSA-201',
            quantity: 1,
            pickedQuantity: 1,
            packedQuantity: 1,
            shippedQuantity: 1,
            unitPrice: 550000,
          ),
          FulfillmentItem(
            id: 'ITM-006-2',
            productName: 'Screen Cleaning Kit',
            sku: 'SCK-202',
            quantity: 1,
            pickedQuantity: 1,
            packedQuantity: 1,
            shippedQuantity: 1,
            unitPrice: 200000,
          ),
        ],
        packages: [
          PackageInfo(
            id: 'PKG-006-1',
            orderId: 'ORD-006',
            label: 'Package 1',
            weight: 2.0,
            length: 40,
            width: 30,
            height: 10,
            trackingNumber: 'SPX-5555555555',
            items: [
              PackageItem(
                  itemId: 'ITM-006-1',
                  productName: 'Laptop Stand Aluminum',
                  quantity: 1),
              PackageItem(
                  itemId: 'ITM-006-2',
                  productName: 'Screen Cleaning Kit',
                  quantity: 1),
            ],
          ),
        ],
        trackingEvents: [
          TrackingEvent(
            id: 'evt-006-1',
            status: FulfillmentStatus.pending,
            description: 'Order synced from Shopee',
            timestamp: now.subtract(const Duration(days: 3)),
            updatedBy: 'System',
          ),
          TrackingEvent(
            id: 'evt-006-2',
            status: FulfillmentStatus.picking,
            description: 'Items picked',
            timestamp: now.subtract(const Duration(days: 2, hours: 20)),
            location: 'Warehouse B',
            updatedBy: 'Warehouse Staff D',
          ),
          TrackingEvent(
            id: 'evt-006-3',
            status: FulfillmentStatus.packed,
            description: 'Packed and ready for shipment',
            timestamp: now.subtract(const Duration(days: 2, hours: 16)),
            location: 'Packing Station 1',
            updatedBy: 'Warehouse Staff D',
          ),
          TrackingEvent(
            id: 'evt-006-4',
            status: FulfillmentStatus.shipped,
            description: 'Shipped via Shopee Express',
            timestamp: now.subtract(const Duration(days: 2, hours: 10)),
            location: 'Shipping Dock',
            updatedBy: 'Logistics',
          ),
          TrackingEvent(
            id: 'evt-006-5',
            status: FulfillmentStatus.delivered,
            description: 'Delivered successfully',
            timestamp: now.subtract(const Duration(days: 1, hours: 6)),
            location: 'Customer Address',
            updatedBy: 'SPX',
          ),
        ],
      ),
      FulfillmentOrder(
        id: 'ORD-007',
        customerName: 'Dang Van G',
        customerPhone: '0967890123',
        shippingAddress: '12 Nguyen Trai, District 5, Ho Chi Minh City',
        channel: 'Lazada',
        status: FulfillmentStatus.pending,
        createdAt: now.subtract(const Duration(minutes: 30)),
        totalAmount: 4150000,
        items: [
          FulfillmentItem(
            id: 'ITM-007-1',
            productName: 'Smart Watch Series 5',
            sku: 'SW5-301',
            quantity: 1,
            unitPrice: 3500000,
          ),
          FulfillmentItem(
            id: 'ITM-007-2',
            productName: 'Watch Band Silicone',
            sku: 'WBS-302',
            quantity: 2,
            unitPrice: 180000,
          ),
          FulfillmentItem(
            id: 'ITM-007-3',
            productName: 'Screen Protector Watch',
            sku: 'SPW-303',
            quantity: 1,
            unitPrice: 290000,
          ),
        ],
        trackingEvents: [
          TrackingEvent(
            id: 'evt-007-1',
            status: FulfillmentStatus.pending,
            description: 'Order synced from Lazada',
            timestamp: now.subtract(const Duration(minutes: 30)),
            updatedBy: 'System',
          ),
        ],
      ),
    ];
  }
}
