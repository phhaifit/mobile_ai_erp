import 'package:mobile_ai_erp/domain/entity/cart/wishlist_item.dart';

class Wishlist {
  final String id;
  final String tenantId;
  final String customerId;
  final int totalItems;
  final List<WishlistItem> items;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Wishlist({
    required this.id,
    required this.tenantId,
    required this.customerId,
    required this.totalItems,
    required this.items,
    required this.createdAt,
    required this.updatedAt,
  });

  Wishlist copyWith({
    String? id,
    String? tenantId,
    String? customerId,
    int? totalItems,
    List<WishlistItem>? items,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Wishlist(
      id: id ?? this.id,
      tenantId: tenantId ?? this.tenantId,
      customerId: customerId ?? this.customerId,
      totalItems: totalItems ?? this.totalItems,
      items: items ?? this.items,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() {
    return 'Wishlist(id: $id, totalItems: $totalItems)';
  }
}
