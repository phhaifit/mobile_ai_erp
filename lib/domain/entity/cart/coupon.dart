class Coupon {
  final String code;
  final String? name;
  final String? description;
  final String discountType;
  final String discountValue;
  final String? minOrderAmount;
  final int? maxUses;
  final int usedCount;
  final DateTime? validFrom;
  final DateTime? validTo;
  final bool isActive;

  const Coupon({
    required this.code,
    this.name,
    this.description,
    required this.discountType,
    required this.discountValue,
    this.minOrderAmount,
    this.maxUses,
    required this.usedCount,
    this.validFrom,
    this.validTo,
    required this.isActive,
  });

  Coupon copyWith({
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
  }) {
    return Coupon(
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
    );
  }

  @override
  String toString() {
    return 'Coupon(code: $code, discountType: $discountType, discountValue: $discountValue, isActive: $isActive)';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Coupon && runtimeType == other.runtimeType && code == other.code;

  @override
  int get hashCode => code.hashCode;
}
