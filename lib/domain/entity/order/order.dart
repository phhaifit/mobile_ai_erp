import 'package:decimal/decimal.dart';

enum OrderStatus { 
  pending, 
  confirmed, 
  packing, 
  shipping, 
  delivered, 
  cancelled, 
  returned 
}

class OrderItem {
  final String id;
  final String productId;
  final String productName;
  final String sku;
  final int quantity;
  final Decimal unitPrice;
  final Decimal discountAmount;
  final Decimal taxRate;
  final Decimal taxAmount;
  final Decimal totalPrice;

  OrderItem({
    required this.id,
    required this.productId,
    required this.productName,
    required this.sku,
    required this.quantity,
    required this.unitPrice,
    Decimal? discountAmount,
    Decimal? taxRate,
    Decimal? taxAmount,
    required this.totalPrice,
  })  : discountAmount = discountAmount ?? Decimal.parse('0'),
        taxRate = taxRate ?? Decimal.parse('0'),
        taxAmount = taxAmount ?? Decimal.parse('0');

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'productId': productId,
      'product_id': productId,
      'productName': productName,
      'product_name': productName,
      'sku': sku,
      'quantity': quantity,
      'unitPrice': unitPrice.toString(),
      'unit_price': unitPrice.toString(),
      'discountAmount': discountAmount.toString(),
      'discount_amount': discountAmount.toString(),
      'taxRate': taxRate.toString(),
      'tax_rate': taxRate.toString(),
      'taxAmount': taxAmount.toString(),
      'tax_amount': taxAmount.toString(),
      'totalPrice': totalPrice.toString(),
      'total_price': totalPrice.toString(),
    };
  }

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    return OrderItem(
      id: json['id'] ?? '',
      productId: json['productId'] ?? json['product_id'] ?? '',
      productName: json['productName'] ?? json['product_name'] ?? '',
      sku: json['sku'] ?? '',
      quantity: json['quantity'] ?? 0,
      unitPrice: Decimal.parse((json['unitPrice'] ?? json['unit_price'] ?? '0').toString()),
      discountAmount: Decimal.parse((json['discountAmount'] ?? json['discount_amount'] ?? '0').toString()),
      taxRate: Decimal.parse((json['taxRate'] ?? json['tax_rate'] ?? '0').toString()),
      taxAmount: Decimal.parse((json['taxAmount'] ?? json['tax_amount'] ?? '0').toString()),
      totalPrice: Decimal.parse((json['totalPrice'] ?? json['total_price'] ?? '0').toString()),
    );
  }
}

class Order {
  final String id;
  final OrderStatus status;
  final DateTime createdAt;
  final Decimal totalAmount;
  final Decimal shippingFee;
  final String shippingAddress;
  final String? shippingProvince;
  final String? shippingDistrict;
  final String? shippingWard;
  final String code;
  final List<OrderItem> items;

  Order({
    required this.id,
    required this.status,
    required this.createdAt,
    required this.totalAmount,
    required this.shippingFee,
    required this.shippingAddress,
    this.shippingProvince,
    this.shippingDistrict,
    this.shippingWard,
    required this.code,
    required this.items,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'status': status.name,
      'createdAt': createdAt.toIso8601String(),
      'totalAmount': totalAmount.toString(),
      'shippingFee': shippingFee.toString(),
      'shippingAddress': shippingAddress,
      'shippingProvince': shippingProvince,
      'shippingDistrict': shippingDistrict,
      'shippingWard': shippingWard,
      'code': code,
      'items': items.map((item) => item.toJson()).toList(),
    };
  }

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      id: json['id'] ?? '',
      status: _parseOrderStatus(json['status']),
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : json['created_at'] != null ? DateTime.parse(json['created_at']) : DateTime.now(),
      totalAmount: Decimal.parse((json['totalAmount'] ?? json['total_amount'] ?? '0').toString()),
      shippingFee: Decimal.parse((json['shippingFee'] ?? json['shipping_fee'] ?? '0').toString()),
      shippingAddress: json['shippingAddress'] ?? json['shipping_address'] ?? '',
      shippingProvince: json['shippingProvince'] ?? json['shipping_province'],
      shippingDistrict: json['shippingDistrict'] ?? json['shipping_district'],
      shippingWard: json['shippingWard'] ?? json['shipping_ward'],
      code: json['code'] ?? '',
      items: (json['orderItems'] ?? json['order_items'] ?? json['items'] as List<dynamic>?)
              ?.map((item) => OrderItem.fromJson(item as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  static OrderStatus _parseOrderStatus(dynamic status) {
    if (status == null) return OrderStatus.pending;
    final statusStr = status.toString().toLowerCase();
    return OrderStatus.values.firstWhere(
      (e) => e.name.toLowerCase() == statusStr,
      orElse: () => OrderStatus.pending,
    );
  }
}
