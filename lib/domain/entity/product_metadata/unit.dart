class Unit {
  const Unit({
    required this.id,
    required this.tenantId,
    required this.name,
    this.symbol,
    this.description,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String tenantId;
  final String name;
  final String? symbol;
  final String? description;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  Unit copyWith({
    String? id,
    String? tenantId,
    String? name,
    Object? symbol = _sentinel,
    Object? description = _sentinel,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Unit(
      id: id ?? this.id,
      tenantId: tenantId ?? this.tenantId,
      name: name ?? this.name,
      symbol: identical(symbol, _sentinel) ? this.symbol : symbol as String?,
      description: identical(description, _sentinel)
          ? this.description
          : description as String?,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

const Object _sentinel = Object();
