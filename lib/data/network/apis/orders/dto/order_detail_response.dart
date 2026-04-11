/// DTO for the full order in detail view (maps from BE OrderView).
class OrderDto {
  final String id;
  final String code;
  final String status;
  final String paymentStatus;
  final OrderCustomerDto? customer;
  final String? shippingName;
  final String? shippingPhone;
  final String? shippingAddress;
  final String? shippingProvince;
  final String? shippingDistrict;
  final String? shippingWard;
  final String subtotal;
  final String discountAmount;
  final String taxAmount;
  final String shippingFee;
  final String totalAmount;
  final String? note;
  final String source;
  final String createdAt;
  final String updatedAt;

  OrderDto({
    required this.id,
    required this.code,
    required this.status,
    required this.paymentStatus,
    this.customer,
    this.shippingName,
    this.shippingPhone,
    this.shippingAddress,
    this.shippingProvince,
    this.shippingDistrict,
    this.shippingWard,
    required this.subtotal,
    required this.discountAmount,
    required this.taxAmount,
    required this.shippingFee,
    required this.totalAmount,
    this.note,
    required this.source,
    required this.createdAt,
    required this.updatedAt,
  });

  factory OrderDto.fromJson(Map<String, dynamic> json) {
    return OrderDto(
      id: json['id'] as String,
      code: json['code'] as String,
      status: json['status'] as String,
      paymentStatus: json['paymentStatus'] as String,
      customer: json['customer'] != null
          ? OrderCustomerDto.fromJson(json['customer'] as Map<String, dynamic>)
          : null,
      shippingName: json['shippingName'] as String?,
      shippingPhone: json['shippingPhone'] as String?,
      shippingAddress: json['shippingAddress'] as String?,
      shippingProvince: json['shippingProvince'] as String?,
      shippingDistrict: json['shippingDistrict'] as String?,
      shippingWard: json['shippingWard'] as String?,
      subtotal: json['subtotal'] as String,
      discountAmount: json['discountAmount'] as String,
      taxAmount: json['taxAmount'] as String,
      shippingFee: json['shippingFee'] as String,
      totalAmount: json['totalAmount'] as String,
      note: json['note'] as String?,
      source: json['source'] as String,
      createdAt: json['createdAt'] as String,
      updatedAt: json['updatedAt'] as String,
    );
  }
}

/// Customer info embedded in an order.
class OrderCustomerDto {
  final String id;
  final String name;
  final String? email;
  final String? phone;

  OrderCustomerDto({
    required this.id,
    required this.name,
    this.email,
    this.phone,
  });

  factory OrderCustomerDto.fromJson(Map<String, dynamic> json) {
    return OrderCustomerDto(
      id: json['id'] as String,
      name: json['name'] as String,
      email: json['email'] as String?,
      phone: json['phone'] as String?,
    );
  }
}

/// DTO for an order item (maps from BE OrderItemView).
class OrderItemDto {
  final String id;
  final String productId;
  final String? variantId;
  final String productName;
  final String sku;
  final int quantity;
  final String unitPrice;
  final String totalPrice;

  OrderItemDto({
    required this.id,
    required this.productId,
    this.variantId,
    required this.productName,
    required this.sku,
    required this.quantity,
    required this.unitPrice,
    required this.totalPrice,
  });

  factory OrderItemDto.fromJson(Map<String, dynamic> json) {
    return OrderItemDto(
      id: json['id'] as String,
      productId: json['productId'] as String,
      variantId: json['variantId'] as String?,
      productName: json['productName'] as String,
      sku: json['sku'] as String,
      quantity: json['quantity'] as int,
      unitPrice: json['unitPrice'] as String,
      totalPrice: json['totalPrice'] as String,
    );
  }
}

/// DTO for order status change log (maps from BE OrderStatusLogView).
class OrderStatusLogDto {
  final String id;
  final String? oldStatus;
  final String newStatus;
  final String? note;
  final String changedAt;
  final OrderActorDto? changedBy;

  OrderStatusLogDto({
    required this.id,
    this.oldStatus,
    required this.newStatus,
    this.note,
    required this.changedAt,
    this.changedBy,
  });

  factory OrderStatusLogDto.fromJson(Map<String, dynamic> json) {
    return OrderStatusLogDto(
      id: json['id'] as String,
      oldStatus: json['oldStatus'] as String?,
      newStatus: json['newStatus'] as String,
      note: json['note'] as String?,
      changedAt: json['changedAt'] as String,
      changedBy: json['changedBy'] != null
          ? OrderActorDto.fromJson(json['changedBy'] as Map<String, dynamic>)
          : null,
    );
  }
}

/// Actor who changed the order status.
class OrderActorDto {
  final String id;
  final String name;
  final String email;

  OrderActorDto({
    required this.id,
    required this.name,
    required this.email,
  });

  factory OrderActorDto.fromJson(Map<String, dynamic> json) {
    return OrderActorDto(
      id: json['id'] as String,
      name: json['name'] as String,
      email: json['email'] as String,
    );
  }
}

/// Top-level response for GET /orders/{id}.
class OrderDetailResponse {
  final OrderDto order;
  final List<OrderItemDto> items;
  final List<OrderStatusLogDto> statusLogs;

  OrderDetailResponse({
    required this.order,
    required this.items,
    required this.statusLogs,
  });

  factory OrderDetailResponse.fromJson(Map<String, dynamic> json) {
    return OrderDetailResponse(
      order: OrderDto.fromJson(json['order'] as Map<String, dynamic>),
      items: (json['items'] as List<dynamic>)
          .map((e) => OrderItemDto.fromJson(e as Map<String, dynamic>))
          .toList(),
      statusLogs: (json['statusLogs'] as List<dynamic>)
          .map((e) => OrderStatusLogDto.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}
