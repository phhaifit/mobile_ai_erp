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
    this.childrenCount,
    this.description,
    this.status = CategoryStatus.active,
    this.createdAt,
    this.updatedAt,
  });

  final String id;
  final String tenantId;
  final String name;
  final String slug;
  final String? parentId;
  final String? parentName;
  final int level;
  final int? childrenCount;
  final String? description;
  final CategoryStatus status;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  bool get isActive => status == CategoryStatus.active;

  Category copyWith({
    String? id,
    String? tenantId,
    String? name,
    String? slug,
    Object? parentId = _sentinel,
    Object? parentName = _sentinel,
    int? level,
    Object? childrenCount = _sentinel,
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
      childrenCount: identical(childrenCount, _sentinel)
          ? this.childrenCount
          : childrenCount as int?,
      description: identical(description, _sentinel)
          ? this.description
          : description as String?,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'] as String,
      tenantId: json['tenant_id'] as String,
      name: json['name'] as String,
      slug: json['slug'] as String,
      parentId: json['parent_id'] as String?,
      status: (json['status'] as String? ?? 'active') == 'active'
          ? CategoryStatus.active
          : CategoryStatus.inactive,
      description: json['description'] as String?,
    );
  }
}

const Object _sentinel = Object();
