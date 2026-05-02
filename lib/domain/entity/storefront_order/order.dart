import 'package:decimal/decimal.dart';

enum OrderStatus { pending, confirmed, packing, shipping, delivered, success, cancelled, returned }

class OrderItem {
  final String id;
  final String productId;
  final String productName;
  final String? productImageUrl; // Added to show images in UI
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
    this.productImageUrl,
    required this.sku,
    required this.quantity,
    required this.unitPrice,
    Decimal? discountAmount,
    Decimal? taxRate,
    Decimal? taxAmount,
    required this.totalPrice,
  })  : discountAmount = discountAmount ?? Decimal.zero,
        taxRate = taxRate ?? Decimal.zero,
        taxAmount = taxAmount ?? Decimal.zero;

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    // Safely extract the nested product data from Prisma
    final productData = json['products'] as Map<String, dynamic>?;
    
    // Extract the primary image URL
    String? imageUrl;
    if (productData != null && productData['product_images'] != null) {
      final images = productData['product_images'] as List;
      if (images.isNotEmpty) {
        imageUrl = images[0]['url'] as String?;
      }
    }

    return OrderItem(
      id: json['id'] ?? '',
      productId: json['product_id'] ?? json['productId'] ?? '',
      // Prioritize the nested product data, fallback to flat json
      productName: productData?['name'] ?? json['productName'] ?? json['product_name'] ?? '',
      productImageUrl: imageUrl,
      sku: productData?['sku'] ?? json['sku'] ?? '',
      quantity: json['quantity'] ?? 1,
      // Use tryParse to prevent crashes on bad data, defaulting to zero
      unitPrice: Decimal.tryParse((json['unit_price'] ?? json['unitPrice'] ?? '0').toString()) ?? Decimal.zero,
      discountAmount: Decimal.tryParse((json['discount_amount'] ?? json['discountAmount'] ?? '0').toString()) ?? Decimal.zero,
      taxRate: Decimal.tryParse((json['tax_rate'] ?? json['taxRate'] ?? '0').toString()) ?? Decimal.zero,
      taxAmount: Decimal.tryParse((json['tax_amount'] ?? json['taxAmount'] ?? '0').toString()) ?? Decimal.zero,
      totalPrice: Decimal.tryParse((json['total_price'] ?? json['totalPrice'] ?? '0').toString()) ?? Decimal.zero,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'productId': productId,
      'productName': productName,
      'productImageUrl': productImageUrl,
      'sku': sku,
      'quantity': quantity,
      'unitPrice': unitPrice.toString(),
      'discountAmount': discountAmount.toString(),
      'taxRate': taxRate.toString(),
      'taxAmount': taxAmount.toString(),
      'totalPrice': totalPrice.toString(),
    };
  }
}

class StorefrontOrder {
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
  
  // Added relations for the Order Details view
  final List<dynamic> payments;
  final List<dynamic> outboundReceipts;
  final List<dynamic> returnRequests;

  StorefrontOrder({
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
    this.payments = const [],
    this.outboundReceipts = const [],
    this.returnRequests = const [],
  });

  factory StorefrontOrder.fromJson(Map<String, dynamic> json) {
    // 1. Bulletproof parsing for the items list
    List<OrderItem> parsedItems = [];
    final itemsData = json['items'] ?? json['order_items'] ?? json['orderItems'];
    
    if (itemsData != null && itemsData is List) {
      // Explicitly mapping to OrderItem and casting the list prevents the dynamic type error
      parsedItems = itemsData
          .map((item) => OrderItem.fromJson(item as Map<String, dynamic>))
          .toList()
          .cast<OrderItem>();
    }

    // 2. Return the safely parsed Order
    return StorefrontOrder(
      id: json['id'] ?? '',
      status: _parseOrderStatus(json['status']),
      createdAt: json['createdAt'] != null 
          ? DateTime.parse(json['createdAt']) 
          : json['created_at'] != null 
              ? DateTime.parse(json['created_at']) 
              : DateTime.now(),
      
      // Mapped to match your actual backend payload keys
      totalAmount: Decimal.tryParse((json['totalPrice'] ?? json['total_price'] ?? json['totalAmount'] ?? '0').toString()) ?? Decimal.zero,
      shippingFee: Decimal.tryParse((json['shippingFee'] ?? json['shipping_fee'] ?? '0').toString()) ?? Decimal.zero,
      shippingAddress: json['customerAddress'] ?? json['shippingAddress'] ?? json['shipping_address'] ?? '',
      
      shippingProvince: json['shippingProvince'] ?? json['shipping_province'],
      shippingDistrict: json['shippingDistrict'] ?? json['shipping_district'],
      shippingWard: json['shippingWard'] ?? json['shipping_ward'],
      code: json['code'] ?? '',
      
      // 🚀 Inject the safely parsed list here
      items: parsedItems,
      
      payments: json['payments'] != null ? List.from(json['payments']) : [],
      outboundReceipts: json['outbound_receipts'] != null ? List.from(json['outbound_receipts']) : [],
      returnRequests: json['return_requests'] != null ? List.from(json['return_requests']) : [],
    );
  }

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

  static OrderStatus _parseOrderStatus(dynamic status) {
    if (status == null) return OrderStatus.pending;
    final statusStr = status.toString().toLowerCase();
    switch (statusStr) {
      case 'confirmed': return OrderStatus.confirmed;
      case 'packing': return OrderStatus.packing;
      case 'shipping': return OrderStatus.shipping;
      case 'delivered': return OrderStatus.delivered;
      case 'success': return OrderStatus.success;
      case 'cancelled': return OrderStatus.cancelled;
      case 'returned': return OrderStatus.returned;
      case 'pending':
      default:
        return OrderStatus.pending;
    }
  }
}