import 'package:decimal/decimal.dart';
import '../../../../domain/entity/storefront_order/order.dart';

class OrderMockDataSource {
  final List<StorefrontOrder> _mockOrders = [
    StorefrontOrder(
      id: 'ORD-2026-001',
      status: OrderStatus.delivered,
      createdAt: DateTime.now().subtract(const Duration(days: 5)),
      totalAmount: Decimal.parse('1250000'),
      shippingFee: Decimal.parse('30000'),
      shippingAddress: '227 Nguyen Van Cu',
      code: 'ORD-2026-001',
      shippingProvince: 'Ho Chi Minh',
      shippingDistrict: 'District 1',
      shippingWard: 'Ward 1',
      items: [
        OrderItem(
            id: 'item_1',
            productId: 'p_101',
            productName: 'Mechanical Keyboard',
            sku: 'KB-001',
            quantity: 1,
            unitPrice: Decimal.parse('1250000'),
            totalPrice: Decimal.parse('1250000')),
      ],
    ),
    StorefrontOrder(
      id: 'ORD-2026-002',
      status: OrderStatus.pending,
      createdAt: DateTime.now().subtract(const Duration(hours: 2)),
      totalAmount: Decimal.parse('450000'),
      shippingFee: Decimal.parse('15000'),
      shippingAddress: '227 Nguyen Van Cu',
      code: 'ORD-2026-002',
      shippingProvince: 'Ho Chi Minh',
      shippingDistrict: 'District 1',
      shippingWard: 'Ward 2',
      items: [
        OrderItem(
            id: 'item_2',
            productId: 'p_102',
            productName: 'Wireless Mouse',
            sku: 'MS-001',
            quantity: 1,
            unitPrice: Decimal.parse('450000'),
            totalPrice: Decimal.parse('450000')),
      ],
    ),
  ];

  Future<List<StorefrontOrder>> getOrderHistory() async {
    await Future.delayed(const Duration(milliseconds: 1000));
    return _mockOrders;
  }
}
