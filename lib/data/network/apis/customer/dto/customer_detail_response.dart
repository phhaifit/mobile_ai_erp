class CustomerDetailDto {
  final String id;
  final String name;
  final String status;
  final String createdAt;
  final String? phone;
  final String? email;
  final String? groupId;
  final String? updatedAt;
  final String? lastSignInAt;
  final String? emailVerifiedAt;
  final String? notes;
  final String? avatarUrl;
  final List<Map<String, dynamic>> transactions;

  CustomerDetailDto({
    required this.id,
    required this.name,
    required this.status,
    required this.createdAt,
    this.phone,
    this.email,
    this.groupId,
    this.updatedAt,
    this.lastSignInAt,
    this.emailVerifiedAt,
    this.notes,
    this.avatarUrl,
    this.transactions = const [],
  });

  factory CustomerDetailDto.fromJson(Map<String, dynamic> json) {
    return CustomerDetailDto(
      id: json['id'] as String,
      name: json['name'] as String,
      status: json['status'] as String,
      createdAt: json['createdAt'] as String,
      phone: json['phone'] as String?,
      email: json['email'] as String?,
      groupId: json['groupId'] as String?,
      updatedAt: json['updatedAt'] as String?,
      lastSignInAt: json['lastSignInAt'] as String?,
      emailVerifiedAt: json['emailVerifiedAt'] as String?,
      notes: json['notes'] as String?,
      avatarUrl: json['avatarUrl'] as String?,
      transactions: json['transactions'] != null
          ? List<Map<String, dynamic>>.from(
              json['transactions'] as List<dynamic>,
            )
          : [],
    );
  }
}
