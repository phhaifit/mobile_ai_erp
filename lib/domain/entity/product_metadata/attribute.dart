class AttributeSet {
  const AttributeSet({
    required this.id,
    required this.tenantId,
    required this.name,
    this.description,
    this.createdAt,
    this.updatedAt,
    this.values = const <AttributeValue>[],
  });

  final String id;
  final String tenantId;
  final String name;
  final String? description;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final List<AttributeValue> values;

  AttributeSet copyWith({
    String? id,
    String? tenantId,
    String? name,
    Object? description = _sentinel,
    DateTime? createdAt,
    DateTime? updatedAt,
    List<AttributeValue>? values,
  }) {
    return AttributeSet(
      id: id ?? this.id,
      tenantId: tenantId ?? this.tenantId,
      name: name ?? this.name,
      description: identical(description, _sentinel)
          ? this.description
          : description as String?,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      values: values ?? this.values,
    );
  }
}

class AttributeValue {
  const AttributeValue({
    required this.id,
    required this.attributeSetId,
    required this.value,
    this.sortOrder = 0,
    this.createdAt,
  });

  final String id;
  final String attributeSetId;
  final String value;
  final int sortOrder;
  final DateTime? createdAt;

  AttributeValue copyWith({
    String? id,
    String? attributeSetId,
    String? value,
    int? sortOrder,
    DateTime? createdAt,
  }) {
    return AttributeValue(
      id: id ?? this.id,
      attributeSetId: attributeSetId ?? this.attributeSetId,
      value: value ?? this.value,
      sortOrder: sortOrder ?? this.sortOrder,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

const Object _sentinel = Object();
