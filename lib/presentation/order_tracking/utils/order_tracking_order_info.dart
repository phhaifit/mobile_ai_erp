import 'package:mobile_ai_erp/data/network/apis/orders/dto/order_detail_response.dart';
import 'package:mobile_ai_erp/data/network/apis/orders/dto/order_list_response.dart';

class OrderInfo {
  const OrderInfo({
    required this.id,
    required this.code,
    required this.status,
    required this.totalPrice,
    required this.customerName,
    required this.itemsCount,
    required this.deliveryInfo,
    required this.createdAt,
  });

  final String id;
  final String code;
  final String status;
  final String totalPrice;
  final String customerName;
  final int itemsCount;
  final String deliveryInfo;
  final DateTime? createdAt;
}

class OrderInfoMapper {
  static OrderInfo fromSummary(OrderSummaryDto order) {
    return OrderInfo(
      id: order.id,
      code: order.code,
      status: order.status,
      totalPrice: order.totalAmount,
      customerName: order.customerName ?? 'Unknown',
      itemsCount: order.totalItems,
      deliveryInfo: '',
      createdAt: DateTime.tryParse(order.createdAt),
    );
  }

  static OrderInfo fromDetail(OrderDetailResponse detail) {
    final OrderDto order = detail.order;
    final List<String> deliveryParts = [
      order.shippingAddress,
      order.shippingDistrict,
      order.shippingProvince,
    ].whereType<String>().where((value) => value.isNotEmpty).toList();

    return OrderInfo(
      id: order.id,
      code: order.code,
      status: order.status,
      totalPrice: order.totalAmount,
      customerName: order.customer?.name ?? 'Unknown',
      itemsCount: detail.items.length,
      deliveryInfo: deliveryParts.join(', '),
      createdAt: DateTime.tryParse(order.createdAt),
    );
  }
}
