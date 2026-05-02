import 'package:json_annotation/json_annotation.dart';

part 'customer.g.dart';

@JsonSerializable()
class Customer {
  final String id;
  final String email;
  final String? firstName;
  final String? lastName;
  final String status; // 'pending_verification' | 'active' | 'suspended'
  @JsonKey(name: 'emailVerifiedAt')
  final DateTime? emailVerifiedAt;
  @JsonKey(name: 'lastSignInAt')
  final DateTime? lastSignInAt;
  final String? profileImage;

  Customer({
    required this.id,
    required this.email,
    this.firstName,
    this.lastName,
    required this.status,
    this.emailVerifiedAt,
    this.lastSignInAt,
    this.profileImage,
  });

  bool get isEmailVerified => emailVerifiedAt != null;
  bool get isActive => status == 'active';
  bool get isSuspended => status == 'suspended';

  factory Customer.fromJson(Map<String, dynamic> json) =>
      _$CustomerFromJson(json);

  Map<String, dynamic> toJson() => _$CustomerToJson(this);
}
