import 'package:json_annotation/json_annotation.dart';
import 'package:mobile_ai_erp/domain/entity/customer_auth/customer_auth_entities.dart';

part 'customer_model.g.dart';

@JsonSerializable()
class CustomerModel extends Customer {
  CustomerModel({
    required String id,
    required String email,
    String? firstName,
    String? lastName,
    required String status,
    DateTime? emailVerifiedAt,
    DateTime? lastSignInAt,
    String? profileImage,
  }) : super(
    id: id,
    email: email,
    firstName: firstName,
    lastName: lastName,
    status: status,
    emailVerifiedAt: emailVerifiedAt,
    lastSignInAt: lastSignInAt,
    profileImage: profileImage,
  );

  factory CustomerModel.fromJson(Map<String, dynamic> json) =>
      _$CustomerModelFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$CustomerModelToJson(this);

  // Convert from domain entity to model
  factory CustomerModel.fromEntity(Customer customer) {
    return CustomerModel(
      id: customer.id,
      email: customer.email,
      firstName: customer.firstName,
      lastName: customer.lastName,
      status: customer.status,
      emailVerifiedAt: customer.emailVerifiedAt,
      lastSignInAt: customer.lastSignInAt,
      profileImage: customer.profileImage,
    );
  }

  // Convert to domain entity
  Customer toEntity() {
    return Customer(
      id: id,
      email: email,
      firstName: firstName,
      lastName: lastName,
      status: status,
      emailVerifiedAt: emailVerifiedAt,
      lastSignInAt: lastSignInAt,
      profileImage: profileImage,
    );
  }
}
