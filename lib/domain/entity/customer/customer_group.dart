enum CustomerGroupStatus {
  active('Active'),
  archived('Archived');

  const CustomerGroupStatus(this.label);

  final String label;
}

class CustomerGroup {
  const CustomerGroup({
    required this.id,
    required this.name,
    this.description,
    this.colorHex,
    this.memberCount = 0,
    this.status = CustomerGroupStatus.active,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String name;
  final String? description;
  final String? colorHex;
  final int memberCount;
  final CustomerGroupStatus status;
  final DateTime createdAt;
  final DateTime updatedAt;

  bool get isActive => status == CustomerGroupStatus.active;

  CustomerGroup copyWith({
    String? id,
    String? name,
    Object? description = _sentinel,
    Object? colorHex = _sentinel,
    int? memberCount,
    CustomerGroupStatus? status,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return CustomerGroup(
      id: id ?? this.id,
      name: name ?? this.name,
      description: identical(description, _sentinel)
          ? this.description
          : description as String?,
      colorHex: identical(colorHex, _sentinel)
          ? this.colorHex
          : colorHex as String?,
      memberCount: memberCount ?? this.memberCount,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

const Object _sentinel = Object();
