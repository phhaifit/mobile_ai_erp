enum TagStatus {
  active('Active'),
  reviewRequired('Review required'),
  archived('Archived');

  const TagStatus(this.label);

  final String label;
}

class Tag {
  const Tag({
    required this.id,
    required this.name,
    this.description,
    this.colorHex,
    this.sortOrder = 0,
    this.status = TagStatus.active,
  });

  final String id;
  final String name;
  final String? description;
  final String? colorHex;
  final int sortOrder;
  final TagStatus status;

  bool get isActive => status == TagStatus.active;

  Tag copyWith({
    String? id,
    String? name,
    Object? description = _sentinel,
    Object? colorHex = _sentinel,
    int? sortOrder,
    TagStatus? status,
  }) {
    return Tag(
      id: id ?? this.id,
      name: name ?? this.name,
      description: identical(description, _sentinel)
          ? this.description
          : description as String?,
      colorHex:
          identical(colorHex, _sentinel) ? this.colorHex : colorHex as String?,
      sortOrder: sortOrder ?? this.sortOrder,
      status: status ?? this.status,
    );
  }
}

const Object _sentinel = Object();
