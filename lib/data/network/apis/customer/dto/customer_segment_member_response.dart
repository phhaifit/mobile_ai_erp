import 'package:mobile_ai_erp/data/network/apis/common/pagination_meta.dart';

class CustomerSegmentMemberDto {
  final String id;
  final String name;
  final String tenantId;
  final String status;
  final String createdAt;
  final String? phone;
  final String? email;
  final String? googleId;
  final String? emailVerifiedAt;
  final String? lastSignInAt;

  CustomerSegmentMemberDto({
    required this.id,
    required this.name,
    required this.tenantId,
    required this.status,
    required this.createdAt,
    this.phone,
    this.email,
    this.googleId,
    this.emailVerifiedAt,
    this.lastSignInAt,
  });

  factory CustomerSegmentMemberDto.fromJson(Map<String, dynamic> json) {
    return CustomerSegmentMemberDto(
      id: json['id'] as String,
      name: json['name'] as String,
      tenantId: json['tenantId'] as String,
      status: json['status'] as String,
      createdAt: json['createdAt'] as String,
      phone: json['phone'] as String?,
      email: json['email'] as String?,
      googleId: json['googleId'] as String?,
      emailVerifiedAt: json['emailVerifiedAt'] as String?,
      lastSignInAt: json['lastSignInAt'] as String?,
    );
  }
}

class CustomerSegmentMemberListResponse {
  final List<CustomerSegmentMemberDto> data;
  final PaginationMeta meta;

  CustomerSegmentMemberListResponse({required this.data, required this.meta});

  factory CustomerSegmentMemberListResponse.fromJson(
      Map<String, dynamic> json) {
    return CustomerSegmentMemberListResponse(
      data: (json['data'] as List<dynamic>)
          .map((e) =>
              CustomerSegmentMemberDto.fromJson(e as Map<String, dynamic>))
          .toList(),
      meta: PaginationMeta.fromJson(json['meta'] as Map<String, dynamic>),
    );
  }
}
