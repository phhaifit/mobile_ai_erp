import 'package:json_annotation/json_annotation.dart';

part 'get_customer_profile_dto.g.dart';

@JsonSerializable()
class GetCustomerProfileDto {
  final String id;
  final String name;
  final String email;
  final String? phone;
  final String status;

  @JsonKey(name: 'created_at')
  final String createdAt;

  const GetCustomerProfileDto({
    required this.id,
    required this.name,
    required this.email,
    this.phone,
    required this.status,
    required this.createdAt,
  });

  factory GetCustomerProfileDto.fromJson(Map<String, dynamic> json) =>
      _$GetCustomerProfileDtoFromJson(json);

  Map<String, dynamic> toJson() => _$GetCustomerProfileDtoToJson(this);
}