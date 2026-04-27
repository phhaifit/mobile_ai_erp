/// DTO for a single order in list view (maps from BE OrderSummaryView).
class OrderSummaryDto {
  final String id;
  final String code;
  final String status;
  final String paymentStatus;
  final String? customerName;
  final String totalAmount;
  final String createdAt;

  OrderSummaryDto({
    required this.id,
    required this.code,
    required this.status,
    required this.paymentStatus,
    this.customerName,
    required this.totalAmount,
    required this.createdAt,
  });

  factory OrderSummaryDto.fromJson(Map<String, dynamic> json) {
    return OrderSummaryDto(
      id: json['id'] as String,
      code: json['code'] as String,
      status: json['status'] as String,
      paymentStatus: json['paymentStatus'] as String,
      customerName: json['customerName'] as String?,
      totalAmount: json['totalPrice'] as String,
      createdAt: json['createdAt'] as String,
    );
  }
}

/// Pagination metadata from the BE response.
class PaginationMeta {
  final int page;
  final int pageSize;
  final int totalItems;
  final int totalPages;

  PaginationMeta({
    required this.page,
    required this.pageSize,
    required this.totalItems,
    required this.totalPages,
  });

  factory PaginationMeta.fromJson(Map<String, dynamic> json) {
    return PaginationMeta(
      page: json['page'] as int,
      pageSize: json['pageSize'] as int,
      totalItems: json['totalItems'] as int,
      totalPages: json['totalPages'] as int,
    );
  }
}

/// Top-level response for GET /orders.
class OrderListResponse {
  final List<OrderSummaryDto> data;
  final PaginationMeta meta;

  OrderListResponse({required this.data, required this.meta});

  factory OrderListResponse.fromJson(Map<String, dynamic> json) {
    return OrderListResponse(
      data: (json['data'] as List<dynamic>)
          .map((e) => OrderSummaryDto.fromJson(e as Map<String, dynamic>))
          .toList(),
      meta: PaginationMeta.fromJson(json['meta'] as Map<String, dynamic>),
    );
  }
}
