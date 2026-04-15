import 'package:mobile_ai_erp/domain/entity/user/user_status.dart';

class User {
  final String id;
  final String tenantId;
  final String? ssoId;
  final String name;
  final String email;
  final String password;
  final String roleId;
  final bool isActive;
  final DateTime? createdAt;
  final DateTime? deletedAt;

  User({
    required this.id,
    required this.tenantId,
    this.ssoId,
    required this.name,
    required this.email,
    required this.password,
    required this.roleId,
    required this.isActive,
    this.createdAt,
    this.deletedAt,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as String,
      tenantId: json['tenant_id'] as String,
      ssoId: json['sso_id'] as String?,
      name: json['name'] as String,
      email: json['email'] as String,
      password: json['password'] as String,
      roleId: json['role_id'] as String,
      isActive: json['is_active'] as bool,
      createdAt: json['created_at'] != null 
          ? DateTime.parse(json['created_at'] as String)
          : null,
      deletedAt: json['deleted_at'] != null 
          ? DateTime.parse(json['deleted_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'tenant_id': tenantId,
      'sso_id': ssoId,
      'name': name,
      'email': email,
      'password': password,
      'role_id': roleId,
      'is_active': isActive,
      'created_at': createdAt?.toIso8601String(),
      'deleted_at': deletedAt?.toIso8601String(),
    };
  }

  User copyWith({
    String? id,
    String? tenantId,
    String? ssoId,
    String? name,
    String? email,
    String? password,
    String? roleId,
    bool? isActive,
    DateTime? createdAt,
    DateTime? deletedAt,
  }) {
    return User(
      id: id ?? this.id,
      tenantId: tenantId ?? this.tenantId,
      ssoId: ssoId ?? this.ssoId,
      name: name ?? this.name,
      email: email ?? this.email,
      password: password ?? this.password,
      roleId: roleId ?? this.roleId,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      deletedAt: deletedAt ?? this.deletedAt,
    );
  }

  // Helper method to get status for backward compatibility
  UserStatus get status => isActive ? UserStatus.active : UserStatus.inactive;
}
