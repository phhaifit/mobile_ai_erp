import 'package:mobile_ai_erp/core/utils/parse_utils.dart';

enum OrderStatus {
  pending,
  processing,
  confirmed,
  shipped,
  delivered,
  canceled,
  returned;

  static OrderStatus fromString(String? value) {
    return OrderStatus.values.firstWhere(
      (e) => e.name == value,
      orElse: () => OrderStatus.pending,
    );
  }
}

enum PaymentStatus {
  unpaid,
  pending,
  partial,
  completed,
  failed,
  refunded;

  static PaymentStatus fromString(String? value) {
    return PaymentStatus.values.firstWhere(
      (e) => e.name == value,
      orElse: () => PaymentStatus.unpaid,
    );
  }
}

class OrderStatusLog {
  final String id;
  final String? oldStatus;
  final String newStatus;
  final String? note;
  final DateTime createdAt;

  OrderStatusLog({
    required this.id,
    this.oldStatus,
    required this.newStatus,
    this.note,
    required this.createdAt,
  });

  factory OrderStatusLog.fromJson(Map<String, dynamic> json) {
    return OrderStatusLog(
      id: json['id'] as String,
      oldStatus: json['oldStatus'] as String?,
      newStatus: json['newStatus'] as String,
      note: json['note'] as String?,
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString()) ?? DateTime.now()
          : DateTime.now(),
    );
  }
}

class OrderItem {
  final String id;
  final String productId;
  final String? productName;
  final String? sku;
  final int quantity;
  final double unitPrice;
  final double totalPrice;
  final String imageUrl;

  OrderItem({
    required this.id,
    required this.productId,
    this.productName,
    this.sku,
    required this.quantity,
    required this.unitPrice,
    required this.totalPrice,
    this.imageUrl = '',
  });

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    return OrderItem(
      id: json['id'] as String? ?? '',
      productId: json['productId'] as String,
      productName: json['productName'] as String?,
      sku: json['sku'] as String?,
      quantity: json['quantity'] as int? ?? 0,
      unitPrice: parseDouble(json['unitPrice']),
      totalPrice: parseDouble(json['totalPrice']),
    );
  }

  /// Convenience getter for display that falls back to product ID.
  String get displayName => productName ?? 'Product';

  /// Backward-compatible alias: [unitPrice].
  double get price => unitPrice;
}

class Order {
  final String id;
  final String? code;
  final OrderStatus status;
  final PaymentStatus paymentStatus;
  final DateTime date;
  final double subtotal;
  final double discountAmount;
  final double totalAmount;
  final double shippingFee;
  final String shippingAddress;
  final String paymentMethod;
  final String? customerName;
  final String? customerPhone;
  final String? customerNote;
  final String? source;
  final List<OrderItem> items;
  final List<OrderStatusLog> statusLogs;

  Order({
    required this.id,
    this.code,
    required this.status,
    this.paymentStatus = PaymentStatus.pending,
    required this.date,
    this.subtotal = 0,
    this.discountAmount = 0,
    required this.totalAmount,
    this.shippingFee = 0,
    this.shippingAddress = '',
    this.paymentMethod = '',
    this.customerName,
    this.customerPhone,
    this.customerNote,
    this.source,
    required this.items,
    this.statusLogs = const [],
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      id: json['id'] as String,
      code: json['code'] as String?,
      status: OrderStatus.fromString(json['status'] as String?),
      paymentStatus: PaymentStatus.fromString(json['paymentStatus'] as String?),
      date: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString()) ?? DateTime.now()
          : DateTime.now(),
      subtotal: parseDouble(json['subtotal']),
      discountAmount: parseDouble(json['discountAmount']),
      totalAmount: parseDouble(json['totalPrice']),
      shippingFee: parseDouble(json['shippingFee']),
      shippingAddress: json['customerAddress'] as String? ?? '',
      paymentMethod: json['paymentMethod'] as String? ?? '',
      customerName: json['customerName'] as String?,
      customerPhone: json['customerPhone'] as String?,
      customerNote: json['customerNote'] as String?,
      source: json['source'] as String?,
      items: (json['items'] as List<dynamic>?)
              ?.map((e) => OrderItem.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      statusLogs: (json['statusLogs'] as List<dynamic>?)
              ?.map((e) => OrderStatusLog.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  Order copyWith({
    String? id,
    String? code,
    OrderStatus? status,
    PaymentStatus? paymentStatus,
    DateTime? date,
    double? subtotal,
    double? discountAmount,
    double? totalAmount,
    double? shippingFee,
    String? shippingAddress,
    String? paymentMethod,
    String? customerName,
    String? customerPhone,
    String? customerNote,
    String? source,
    List<OrderItem>? items,
    List<OrderStatusLog>? statusLogs,
  }) {
    return Order(
      id: id ?? this.id,
      code: code ?? this.code,
      status: status ?? this.status,
      paymentStatus: paymentStatus ?? this.paymentStatus,
      date: date ?? this.date,
      subtotal: subtotal ?? this.subtotal,
      discountAmount: discountAmount ?? this.discountAmount,
      totalAmount: totalAmount ?? this.totalAmount,
      shippingFee: shippingFee ?? this.shippingFee,
      shippingAddress: shippingAddress ?? this.shippingAddress,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      customerName: customerName ?? this.customerName,
      customerPhone: customerPhone ?? this.customerPhone,
      customerNote: customerNote ?? this.customerNote,
      source: source ?? this.source,
      items: items ?? this.items,
      statusLogs: statusLogs ?? this.statusLogs,
    );
  }
}

