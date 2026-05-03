import 'package:json_annotation/json_annotation.dart';

part 'get_tenant_dto.g.dart';

@JsonSerializable()
class GetTenantDto {
  final String id;
  final String name;
  final String subdomain;
  final String plan;
  final bool is_active;
  final String? customDomain;

  GetTenantDto({
    required this.id,
    required this.name,
    required this.subdomain,
    required this.plan,
    required this.is_active,
    required this.customDomain,
  });

  factory GetTenantDto.fromJson(Map<String, dynamic> json) =>
      _$GetTenantDtoFromJson(json);

  Map<String, dynamic> toJson() => _$GetTenantDtoToJson(this);
}
