enum CategoryStatus { active, inactive }

class Category {
  const Category({
    required this.id,
    required this.tenantId,
    required this.name,
    required this.slug,
    this.parentId,
    this.parentName,
    this.level = 0,
    this.description,
    this.status = CategoryStatus.active,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String tenantId;
  final String name;
  final String slug;
  final String? parentId;
  final String? parentName;
  final int level;
  final String? description;
  final CategoryStatus status;
  final DateTime createdAt;
  final DateTime updatedAt;

  bool get isActive => status == CategoryStatus.active;

  Category copyWith({
    String? id,
    String? tenantId,
    String? name,
    String? slug,
    Object? parentId = _sentinel,
    Object? parentName = _sentinel,
    int? level,
    Object? description = _sentinel,
    CategoryStatus? status,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Category(
      id: id ?? this.id,
      tenantId: tenantId ?? this.tenantId,
      name: name ?? this.name,
      slug: slug ?? this.slug,
      parentId:
          identical(parentId, _sentinel) ? this.parentId : parentId as String?,
      parentName: identical(parentName, _sentinel)
          ? this.parentName
          : parentName as String?,
      level: level ?? this.level,
      description: identical(description, _sentinel)
          ? this.description
          : description as String?,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

const Object _sentinel = Object();
