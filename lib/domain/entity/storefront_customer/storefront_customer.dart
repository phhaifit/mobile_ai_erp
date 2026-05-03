import '../storefront_order/order.dart';

enum CustomerStatus {
  pendingVerification('Pending verification'),
  active('Active'),
  suspended('Suspended'),
  deactivated('Deactivated');

  const CustomerStatus(this.label);

  final String label;

  static CustomerStatus? fromApiString(String? value) {
    switch (value) {
      case 'pending_verification':
        return CustomerStatus.pendingVerification;
      case 'active':
        return CustomerStatus.active;
      case 'suspended':
        return CustomerStatus.suspended;
      case 'deactivated':
        return CustomerStatus.deactivated;
      default:
        return null;
    }
  }

  String get apiValue {
    switch (this) {
      case CustomerStatus.pendingVerification:
        return 'pending_verification';
      default:
        return name;
    }
  }
}

enum CustomerType {
  individual('Individual'),
  business('Business');

  const CustomerType(this.label);

  final String label;
}

class StorefrontCustomer {
  const StorefrontCustomer({
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
    this.transactions = const [],
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
  final List<StorefrontOrder> transactions;

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

  bool get isActive =>
      status == CustomerStatus.active ||
      status == CustomerStatus.pendingVerification;

  StorefrontCustomer copyWith({
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
    List<StorefrontOrder>? transactions,
  }) {
    return StorefrontCustomer(
      id: id ?? this.id,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      email: email ?? this.email,
      phone: identical(phone, _sentinel) ? this.phone : phone as String?,
      avatarUrl: identical(avatarUrl, _sentinel)
          ? this.avatarUrl
          : avatarUrl as String?,
      groupId: identical(groupId, _sentinel)
          ? this.groupId
          : groupId as String?,
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
      transactions: transactions ?? this.transactions,
    );
  }

  factory StorefrontCustomer.fromJson(Map<String, dynamic> json) {
    return StorefrontCustomer(
      id: json['id']?.toString() ?? '',
      firstName: json['firstName'] ?? json['first_name'] ?? '',
      lastName: json['lastName'] ?? json['last_name'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'],
      avatarUrl: json['avatarUrl'] ?? json['avatar_url'],
      groupId: json['groupId'] ?? json['group_id'],
      notes: json['notes'],
      status: CustomerStatus.fromApiString(json['status']) ?? CustomerStatus.active,
      type: (json['type'] == 'business' || json['type'] == 'Business') 
          ? CustomerType.business 
          : CustomerType.individual,
      createdAt: json['createdAt'] != null 
          ? DateTime.parse(json['createdAt'])
          : json['created_at'] != null 
              ? DateTime.parse(json['created_at'])
              : DateTime.now(),
      updatedAt: json['updatedAt'] != null 
          ? DateTime.parse(json['updatedAt'])
          : json['updated_at'] != null 
              ? DateTime.parse(json['updated_at'])
              : null,
      lastSignInAt: json['lastSignInAt'] != null 
          ? DateTime.parse(json['lastSignInAt'])
          : json['last_sign_in_at'] != null 
              ? DateTime.parse(json['last_sign_in_at'])
              : null,
      emailVerifiedAt: json['emailVerifiedAt'] != null 
          ? DateTime.parse(json['emailVerifiedAt'])
          : json['email_verified_at'] != null 
              ? DateTime.parse(json['email_verified_at'])
              : null,
      transactions: (json['transactions'] as List<dynamic>?)
              ?.map((e) => StorefrontOrder.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
      'phone': phone,
      'avatarUrl': avatarUrl,
      'groupId': groupId,
      'notes': notes,
      'status': status.apiValue,
      'type': type == CustomerType.business ? 'business' : 'individual',
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'lastSignInAt': lastSignInAt?.toIso8601String(),
      'emailVerifiedAt': emailVerifiedAt?.toIso8601String(),
      'transactions': transactions.map((e) => e.toJson()).toList(),
    };
  }
}

const Object _sentinel = Object();