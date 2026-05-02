import 'package:mobile_ai_erp/data/network/apis/common/pagination_meta.dart';

class CustomerDto {
  final String id;
  final String name;
  final String status;
  final String createdAt;
  final String? phone;
  final String? email;
  final String? groupId;
  final String? updatedAt;

  CustomerDto({
    required this.id,
    required this.name,
    required this.status,
    required this.createdAt,
    this.phone,
    this.email,
    this.groupId,
    this.updatedAt,
  });

  factory CustomerDto.fromJson(Map<String, dynamic> json) {
    return CustomerDto(
      id: json['id'] as String,
      name: json['name'] as String,
      status: json['status'] as String,
      createdAt: json['createdAt'] as String,
      phone: json['phone'] as String?,
      email: json['email'] as String?,
      groupId: json['groupId'] as String?,
      updatedAt: json['updatedAt'] as String?,
    );
  }
}

class CustomerListResponse {
  final List<CustomerDto> data;
  final PaginationMeta meta;

  CustomerListResponse({required this.data, required this.meta});

  factory CustomerListResponse.fromJson(Map<String, dynamic> json) {
    return CustomerListResponse(
      data: (json['data'] as List<dynamic>)
          .map((e) => CustomerDto.fromJson(e as Map<String, dynamic>))
          .toList(),
      meta: PaginationMeta.fromJson(json['meta'] as Map<String, dynamic>),
    );
  }
}
