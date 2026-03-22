class AttributeOption {
  const AttributeOption({
    required this.id,
    required this.attributeId,
    required this.value,
    this.sortOrder = 0,
  });

  final String id;
  final String attributeId;
  final String value;
  final int sortOrder;

  AttributeOption copyWith({
    String? id,
    String? attributeId,
    String? value,
    int? sortOrder,
  }) {
    return AttributeOption(
      id: id ?? this.id,
      attributeId: attributeId ?? this.attributeId,
      value: value ?? this.value,
      sortOrder: sortOrder ?? this.sortOrder,
    );
  }
}
