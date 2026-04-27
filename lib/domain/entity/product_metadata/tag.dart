class Tag {
  const Tag({
    required this.id,
    required this.tenantId,
    required this.name,
    this.description,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String tenantId;
  final String name;
  final String? description;
  final DateTime createdAt;
  final DateTime updatedAt;

  Tag copyWith({
    String? id,
    String? tenantId,
    String? name,
    Object? description = _sentinel,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Tag(
      id: id ?? this.id,
      tenantId: tenantId ?? this.tenantId,
      name: name ?? this.name,
      description: identical(description, _sentinel)
          ? this.description
          : description as String?,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

const Object _sentinel = Object();
