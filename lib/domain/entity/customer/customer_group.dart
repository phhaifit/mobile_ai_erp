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
    this.sortOrder = 0,
    this.status = CustomerGroupStatus.active,
  });

  final String id;
  final String name;
  final String? description;
  final String? colorHex;
  final int sortOrder;
  final CustomerGroupStatus status;

  bool get isActive => status == CustomerGroupStatus.active;

  CustomerGroup copyWith({
    String? id,
    String? name,
    Object? description = _sentinel,
    Object? colorHex = _sentinel,
    int? sortOrder,
    CustomerGroupStatus? status,
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
      sortOrder: sortOrder ?? this.sortOrder,
      status: status ?? this.status,
    );
  }
}

const Object _sentinel = Object();
