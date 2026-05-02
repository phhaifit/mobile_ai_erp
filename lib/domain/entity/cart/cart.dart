import 'package:mobile_ai_erp/domain/entity/cart/cart_item.dart';

class Cart {
  final String id;
  final String tenantId;
  final String customerId;
  final String subtotal;
  final int totalItems;
  final List<CartItem> items;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Cart({
    required this.id,
    required this.tenantId,
    required this.customerId,
    required this.subtotal,
    required this.totalItems,
    required this.items,
    required this.createdAt,
    required this.updatedAt,
  });

  Cart copyWith({
    String? id,
    String? tenantId,
    String? customerId,
    String? subtotal,
    int? totalItems,
    List<CartItem>? items,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Cart(
      id: id ?? this.id,
      tenantId: tenantId ?? this.tenantId,
      customerId: customerId ?? this.customerId,
      subtotal: subtotal ?? this.subtotal,
      totalItems: totalItems ?? this.totalItems,
      items: items ?? this.items,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() {
    return 'Cart(id: $id, totalItems: $totalItems, subtotal: $subtotal)';
  }
}
