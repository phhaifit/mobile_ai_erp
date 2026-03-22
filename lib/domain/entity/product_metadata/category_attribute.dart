class CategoryAttribute {
  const CategoryAttribute({
    required this.id,
    required this.categoryId,
    required this.attributeId,
    this.isRequired = false,
    this.sortOrder = 0,
  });

  final String id;
  final String categoryId;
  final String attributeId;
  final bool isRequired;
  final int sortOrder;

  CategoryAttribute copyWith({
    String? id,
    String? categoryId,
    String? attributeId,
    bool? isRequired,
    int? sortOrder,
  }) {
    return CategoryAttribute(
      id: id ?? this.id,
      categoryId: categoryId ?? this.categoryId,
      attributeId: attributeId ?? this.attributeId,
      isRequired: isRequired ?? this.isRequired,
      sortOrder: sortOrder ?? this.sortOrder,
    );
  }
}
