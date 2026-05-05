class Brand {
  const Brand({
    required this.id,
    required this.tenantId,
    required this.name,
    this.description,
    this.logoUrl,
    this.createdAt,
    this.updatedAt,
  });

  final String id;
  final String tenantId;
  final String name;
  final String? description;
  final String? logoUrl;
  final DateTime? createdAt;
  final DateTime? updatedAt;

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

  factory Brand.fromJson(Map<String, dynamic> json) {
    return Brand(
      id: json['id'] as String,
      tenantId: json['tenant_id'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      logoUrl: json['logoUrl'] as String?,
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at']) : null,
      updatedAt: json['updated_at'] != null ? DateTime.parse(json['updated_at']) : null,
    );
  }
}

const Object _sentinel = Object();
