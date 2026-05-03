import 'package:flutter/material.dart';

String getOrderCodeFromDetail(Map<String, dynamic>? detail, String fallback) {
  if (detail == null) return fallback;
  return (detail['code'] ?? detail['orderCode'] ?? detail['id'] ?? fallback)
      .toString();
}

String getOrderStatusFromDetail(Map<String, dynamic>? detail) {
  if (detail == null) return 'unknown';
  return (detail['status'] ?? detail['state'] ?? 'unknown').toString();
}

String getTotalPriceFromDetail(Map<String, dynamic>? detail) {
  if (detail == null) return '0';
  final price =
      detail['totalPrice'] ?? detail['total'] ?? detail['totalAmount'];
  return price?.toString() ?? '0';
}

int getItemsCountFromDetail(Map<String, dynamic>? detail) {
  if (detail == null) return 0;
  final dynamic items =
      detail['items'] ?? detail['orderItems'] ?? detail['products'];
  if (items is List) return items.length;

  final dynamic count =
      detail['itemsCount'] ?? detail['items_count'] ?? detail['totalItems'];
  if (count is num) return count.toInt();
  if (count is String) return int.tryParse(count) ?? 0;
  return 0;
}

String getCustomerNameFromDetail(Map<String, dynamic>? detail) {
  if (detail == null) return 'Unknown';
  final dynamic customer = detail['customer'];
  if (customer is Map<String, dynamic>) {
    return (customer['name'] ?? customer['fullName'] ?? 'Unknown').toString();
  }
  return (detail['customerName'] ?? detail['customer'] ?? 'Unknown').toString();
}

String getDeliveryInfoFromDetail(Map<String, dynamic>? detail) {
  if (detail == null) return '';
  final dynamic shipping =
      detail['shippingAddress'] ?? detail['deliveryAddress'];
  if (shipping is Map<String, dynamic>) {
    final String line1 =
        (shipping['addressLine1'] ??
                shipping['line1'] ??
                shipping['address'] ??
                '')
            .toString();
    final String city = (shipping['city'] ?? shipping['province'] ?? '')
        .toString();
    return [line1, city].where((e) => e.isNotEmpty).join(', ');
  }
  final String fallback =
      (detail['shippingAddress'] ?? detail['deliveryAddress'] ?? '').toString();
  return fallback;
}

DateTime? getOrderCreatedAtFromDetail(Map<String, dynamic>? detail) {
  if (detail == null) return null;
  final raw =
      detail['createdAt'] ?? detail['created_at'] ?? detail['createdDate'];
  if (raw is String && raw.isNotEmpty) return DateTime.tryParse(raw);
  if (raw is DateTime) return raw;
  return null;
}

Color statusColorFromString(String status, ColorScheme colorScheme) {
  switch (status.toLowerCase()) {
    case 'pending':
      return Colors.orange;
    case 'confirmed':
    case 'packed':
    case 'shipped':
    case 'shipping':
    case 'in_transit':
      return Colors.blue;
    case 'delivered':
      return Colors.green;
    case 'cancelled':
    case 'canceled':
    case 'failed':
      return colorScheme.error;
    default:
      return Colors.grey;
  }
}
