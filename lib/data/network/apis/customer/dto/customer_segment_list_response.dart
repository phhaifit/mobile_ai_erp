import 'package:mobile_ai_erp/data/network/apis/common/pagination_meta.dart';

class CustomerSegmentDto {
  final String id;
  final String name;
  final String createdAt;
  final String updatedAt;
  final String? description;
  final String? color;
  final int memberCount;

  CustomerSegmentDto({
    required this.id,
    required this.name,
    required this.createdAt,
    required this.updatedAt,
    this.description,
    this.color,
    required this.memberCount,
  });

  factory CustomerSegmentDto.fromJson(Map<String, dynamic> json) {
    return CustomerSegmentDto(
      id: json['id'] as String,
      name: json['name'] as String,
      createdAt: json['createdAt'] as String,
      updatedAt: json['updatedAt'] as String,
      description: json['description'] as String?,
      color: json['color'] as String?,
      memberCount: json['memberCount'] as int? ?? 0,
    );
  }
}

class CustomerSegmentListResponse {
  final List<CustomerSegmentDto> data;
  final PaginationMeta meta;

  CustomerSegmentListResponse({required this.data, required this.meta});

  factory CustomerSegmentListResponse.fromJson(Map<String, dynamic> json) {
    return CustomerSegmentListResponse(
      data: (json['data'] as List<dynamic>)
          .map((e) => CustomerSegmentDto.fromJson(e as Map<String, dynamic>))
          .toList(),
      meta: PaginationMeta.fromJson(json['meta'] as Map<String, dynamic>),
    );
  }
}
