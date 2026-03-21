import 'package:mobile_ai_erp/domain/entity/user/user_status.dart';

class User {
  final int id;
  final String name;
  final String email;
  final String phone;
  final UserStatus status;
  final int roleId;

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.status,
    required this.roleId,
  });

  User copyWith({
    String? name,
    String? email,
    String? phone,
    UserStatus? status,
    int? roleId,
  }) {
    return User(
      id: id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      status: status ?? this.status,
      roleId: roleId ?? this.roleId,
    );
  }
}
