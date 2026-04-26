enum CategoryStatus {
  active('Active'),
  archived('Archived');

  const CategoryStatus(this.label);

  final String label;
}

class Category {
  const Category({
    required this.id,
    required this.name,
    required this.code,
    required this.slug,
    this.parentId,
    this.sortOrder = 0,
    this.status = CategoryStatus.active,
    this.description,
    this.coverImageUrl,
  });

  final String id;
  final String name;
  final String code; // not in db design, remove from model when refactoring
  final String slug;
  final String? parentId;
  final int sortOrder; // what is sort order
  final CategoryStatus status;
  final String? description;
  final String? coverImageUrl; // not in db design, remove from model when refactoring

  bool get isActive => status == CategoryStatus.active;

  Category copyWith({
    String? id,
    String? name,
    String? code,
    String? slug,
    Object? parentId = _sentinel,
    int? sortOrder,
    CategoryStatus? status,
    Object? description = _sentinel,
    Object? coverImageUrl = _sentinel,
  }) {
    return Category(
      id: id ?? this.id,
      name: name ?? this.name,
      code: code ?? this.code,
      slug: slug ?? this.slug,
      parentId:
          identical(parentId, _sentinel) ? this.parentId : parentId as String?,
      sortOrder: sortOrder ?? this.sortOrder,
      status: status ?? this.status,
      description: identical(description, _sentinel)
          ? this.description
          : description as String?,
      coverImageUrl: identical(coverImageUrl, _sentinel)
          ? this.coverImageUrl
          : coverImageUrl as String?,
    );
  }

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'] as String,
      name: json['name'] as String,
      code: "", // not in db design, remove from model when refactoring
      slug: json['slug'] as String,
      parentId: json['parent_id'] as String?,
      sortOrder: 0, 
      status: (json['is_active'] as bool? ?? true)
          ? CategoryStatus.active
          : CategoryStatus.archived,
      description: json['description'] as String?,
      coverImageUrl: null, // not in db design, remove from model when refactoring
    );
  }
}

const Object _sentinel = Object();
