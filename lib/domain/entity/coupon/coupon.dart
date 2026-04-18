class Coupon {
  final String id;
  final String tenantId;
  final String code;
  final String name;
  final String? description;
  final String discountType;
  final String discountValue;
  final String minOrderAmount;
  final int? maxUses;
  final int usedCount;
  final DateTime validFrom;
  final DateTime validTo;
  final bool isActive;
  final DateTime? createdAt;

  const Coupon({
    required this.id,
    required this.tenantId,
    required this.code,
    required this.name,
    this.description,
    required this.discountType,
    required this.discountValue,
    required this.minOrderAmount,
    this.maxUses,
    required this.usedCount,
    required this.validFrom,
    required this.validTo,
    required this.isActive,
    this.createdAt,
  });

  Coupon copyWith({
    String? id,
    String? tenantId,
    String? code,
    String? name,
    String? description,
    String? discountType,
    String? discountValue,
    String? minOrderAmount,
    int? maxUses,
    int? usedCount,
    DateTime? validFrom,
    DateTime? validTo,
    bool? isActive,
    DateTime? createdAt,
  }) {
    return Coupon(
      id: id ?? this.id,
      tenantId: tenantId ?? this.tenantId,
      code: code ?? this.code,
      name: name ?? this.name,
      description: description ?? this.description,
      discountType: discountType ?? this.discountType,
      discountValue: discountValue ?? this.discountValue,
      minOrderAmount: minOrderAmount ?? this.minOrderAmount,
      maxUses: maxUses ?? this.maxUses,
      usedCount: usedCount ?? this.usedCount,
      validFrom: validFrom ?? this.validFrom,
      validTo: validTo ?? this.validTo,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
