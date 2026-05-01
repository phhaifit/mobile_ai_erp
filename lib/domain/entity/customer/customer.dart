enum CustomerStatus {
  active('Active'),
  inactive('Inactive'),
  blocked('Blocked');

  const CustomerStatus(this.label);

  final String label;

  static CustomerStatus? fromApiString(String? value) {
    switch (value) {
      case 'active':
        return CustomerStatus.active;
      case 'inactive':
        return CustomerStatus.inactive;
      case 'banned':
      case 'blocked':
        return CustomerStatus.blocked;
      default:
        return null;
    }
  }

  String get apiValue => name;
}

enum CustomerType {
  individual('Individual'),
  business('Business');

  const CustomerType(this.label);

  final String label;
}

class Customer {
  const Customer({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    this.phone,
    this.avatarUrl,
    this.groupId,
    this.notes,
    this.status = CustomerStatus.active,
    this.type = CustomerType.individual,
    required this.createdAt,
    this.updatedAt,
    this.lastSignInAt,
    this.emailVerifiedAt,
  });

  final String id;
  final String firstName;
  final String lastName;
  final String email;
  final String? phone;
  final String? avatarUrl;
  final String? groupId;
  final String? notes;
  final CustomerStatus status;
  final CustomerType type;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final DateTime? lastSignInAt;
  final DateTime? emailVerifiedAt;

  String get fullName {
    final first = firstName.trim();
    final last = lastName.trim();
    if (first.isEmpty) return last;
    if (last.isEmpty) return first;
    return '$first $last';
  }

  String get initials {
    final first = firstName.trim();
    final last = lastName.trim();
    final f = first.isNotEmpty ? first[0].toUpperCase() : '';
    final l = last.isNotEmpty ? last[0].toUpperCase() : '';
    return '$f$l';
  }

  bool get isActive => status == CustomerStatus.active;

  Customer copyWith({
    String? id,
    String? firstName,
    String? lastName,
    String? email,
    Object? phone = _sentinel,
    Object? avatarUrl = _sentinel,
    Object? groupId = _sentinel,
    Object? notes = _sentinel,
    CustomerStatus? status,
    CustomerType? type,
    DateTime? createdAt,
    Object? updatedAt = _sentinel,
    Object? lastSignInAt = _sentinel,
    Object? emailVerifiedAt = _sentinel,
  }) {
    return Customer(
      id: id ?? this.id,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      email: email ?? this.email,
      phone: identical(phone, _sentinel) ? this.phone : phone as String?,
      avatarUrl: identical(avatarUrl, _sentinel)
          ? this.avatarUrl
          : avatarUrl as String?,
      groupId:
          identical(groupId, _sentinel) ? this.groupId : groupId as String?,
      notes: identical(notes, _sentinel) ? this.notes : notes as String?,
      status: status ?? this.status,
      type: type ?? this.type,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: identical(updatedAt, _sentinel)
          ? this.updatedAt
          : updatedAt as DateTime?,
      lastSignInAt: identical(lastSignInAt, _sentinel)
          ? this.lastSignInAt
          : lastSignInAt as DateTime?,
      emailVerifiedAt: identical(emailVerifiedAt, _sentinel)
          ? this.emailVerifiedAt
          : emailVerifiedAt as DateTime?,
    );
  }
}

const Object _sentinel = Object();
