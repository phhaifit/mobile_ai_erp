class PaginatedResponseDto {
  final List<Map<String, dynamic>> data;
  final int page;
  final int pageSize;
  final int totalItems;
  final int totalPages;

  PaginatedResponseDto({
    required this.data,
    required this.page,
    required this.pageSize,
    required this.totalItems,
    required this.totalPages,
  });

  factory PaginatedResponseDto.fromJson(
    Map<String, dynamic> json, {
    required int pageFallback,
    required int pageSizeFallback,
  }) {
    final rawData = (json['data'] as List<dynamic>? ?? [])
        .cast<Map<String, dynamic>>();
    final meta = json['meta'] as Map<String, dynamic>?;
    return PaginatedResponseDto(
      data: rawData,
      page: _parseInt(meta?['page'], pageFallback),
      pageSize: _parseInt(meta?['pageSize'], pageSizeFallback),
      totalItems: _parseInt(meta?['totalItems'], rawData.length),
      totalPages: _parseInt(meta?['totalPages'], 1),
    );
  }

  static int _parseInt(dynamic value, int fallback) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value) ?? fallback;
    return fallback;
  }
}
