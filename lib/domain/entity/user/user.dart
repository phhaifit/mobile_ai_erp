import 'package:mobile_ai_erp/domain/entity/user/user_status.dart';
import 'package:json_annotation/json_annotation.dart';

part 'user.g.dart';

@JsonSerializable()
class User {
  final int id;
  final String name;
  final String email;
  final String phone;
  final UserStatus status;
  final int roleId;
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
    required this.roleId,
    this.ssoId,
    this.tenantId,
    this.tenantName,
  });

  User copyWith({
    String? name,
    String? email,
    String? phone,
    UserStatus? status,
    int? roleId,
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
      roleId: roleId ?? this.roleId,
      ssoId: ssoId ?? this.ssoId,
      tenantId: tenantId ?? this.tenantId,
      tenantName: tenantName ?? this.tenantName,
    );
  }
}
