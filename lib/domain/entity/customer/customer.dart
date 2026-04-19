enum CustomerStatus {
  pending_verification('Pending Verification'),
  active('Active'),
  suspended('Suspended');

  const CustomerStatus(this.label);

  final String label;
}

class Customer {
  const Customer({
    required this.id,
    required this.name,
    required this.email,
    this.phone,
    this.avatarUrl,
    this.status = CustomerStatus.active,
    required this.createdAt,
  });

  final String id;
  final String name;
  final String email;
  final String? phone;
  final String? avatarUrl;
  final CustomerStatus status;
  final DateTime createdAt;

  String get fullName => name;

  String get initials {
    final parts = name.trim().split(' ');
    if (parts.isEmpty) return '?';
    if (parts.length == 1) {
      return parts[0].isNotEmpty ? parts[0][0].toUpperCase() : '?';
    }
    return '${parts[0][0]}${parts[parts.length - 1][0]}'.toUpperCase();
  }

  bool get isActive => status == CustomerStatus.active;

  Customer copyWith({
    String? id,
    String? name,
    String? email,
    Object? phone = _sentinel,
    Object? avatarUrl = _sentinel,
    CustomerStatus? status,
    DateTime? createdAt,
  }) {
    return Customer(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: identical(phone, _sentinel) ? this.phone : phone as String?,
      avatarUrl: identical(avatarUrl, _sentinel)
          ? this.avatarUrl
          : avatarUrl as String?,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'avatarUrl': avatarUrl,
      'status': status.name,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory Customer.fromJson(Map<String, dynamic> json) {
    return Customer(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'],
      avatarUrl: json['avatarUrl'] ?? json['avatar_url'],
      status: _parseStatus(json['status']),
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : json['created_at'] != null
              ? DateTime.parse(json['created_at'])
              : DateTime.now(),
    );
  }

  static CustomerStatus _parseStatus(dynamic status) {
    if (status == null) return CustomerStatus.active;
    final statusStr = status.toString().toLowerCase();
    return CustomerStatus.values.firstWhere(
      (e) => e.name.toLowerCase() == statusStr,
      orElse: () => CustomerStatus.active,
    );
  }
}

const Object _sentinel = Object();
