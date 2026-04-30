import 'package:mobile_ai_erp/domain/entity/user/user_status.dart';
import 'package:json_annotation/json_annotation.dart';

part 'user.g.dart';

@JsonSerializable()
class User {
  final String id;
  final String name;
  final String email;
  final String? phone;
  final UserStatus? status;
  final String role;
  final String? ssoId;
  final String? tenantId;
  final String? tenantName;

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);
  Map<String, dynamic> toJson() => _$UserToJson(this);

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.status,
    required this.role,
    this.ssoId,
    this.tenantId,
    this.tenantName,
  });

  User copyWith({
    String? name,
    String? email,
    String? phone,
    UserStatus? status,
    String? role,
    String? ssoId,
    String? tenantId,
    String? tenantName,
  }) {
    return User(
      id: id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      status: status ?? this.status,
      role: role ?? this.role,
      ssoId: ssoId ?? this.ssoId,
      tenantId: tenantId ?? this.tenantId,
      tenantName: tenantName ?? this.tenantName,
    );
  }
}
