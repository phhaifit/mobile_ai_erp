class Brand {
  const Brand({
    required this.id,
    required this.tenantId,
    required this.name,
    this.description,
    this.logoUrl,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String tenantId;
  final String name;
  final String? description;
  final String? logoUrl;
  final DateTime createdAt;
  final DateTime updatedAt;

  Brand copyWith({
    String? id,
    String? tenantId,
    String? name,
    Object? description = _sentinel,
    Object? logoUrl = _sentinel,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Brand(
      id: id ?? this.id,
      tenantId: tenantId ?? this.tenantId,
      name: name ?? this.name,
      description: identical(description, _sentinel)
          ? this.description
          : description as String?,
      logoUrl:
          identical(logoUrl, _sentinel) ? this.logoUrl : logoUrl as String?,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

const Object _sentinel = Object();
