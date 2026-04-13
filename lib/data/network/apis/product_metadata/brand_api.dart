import 'package:dio/dio.dart';
import 'package:mobile_ai_erp/core/data/network/dio/dio_client.dart';
import 'package:mobile_ai_erp/data/repository/product_metadata/product_metadata_network_utils.dart';
import 'package:mobile_ai_erp/domain/entity/product_metadata/brand.dart';
import 'package:mobile_ai_erp/domain/entity/product_metadata/metadata_page.dart';

class BrandApi {
  BrandApi(this._dioClient);

  final DioClient _dioClient;

  Future<MetadataPage<Brand>> getBrands({
    int page = 1,
    int pageSize = 20,
    String? search,
    bool includeInactive = false,
  }) async {
    try {
      final normalizedPage = page < 1 ? 1 : page;
      final normalizedPageSize = pageSize.clamp(1, 100);
      final response = await _dioClient.dio.get<Map<String, dynamic>>(
        '/brands',
        queryParameters: <String, dynamic>{
          'page': normalizedPage,
          'pageSize': normalizedPageSize,
          if (search != null && search.trim().isNotEmpty)
            'search': search.trim(),
          'includeInactive': includeInactive,
        },
      );
      final data =
          response.data?['data'] as List<dynamic>? ?? const <dynamic>[];
      final meta =
          response.data?['meta'] as Map<String, dynamic>? ??
          const <String, dynamic>{};
      return MetadataPage<Brand>(
        items: data
            .map((item) => _mapBrand(item as Map<String, dynamic>))
            .toList(growable: false),
        page: meta['page'] as int? ?? normalizedPage,
        pageSize: meta['pageSize'] as int? ?? normalizedPageSize,
        totalItems: meta['totalItems'] as int? ?? data.length,
        totalPages: meta['totalPages'] as int? ?? (data.isEmpty ? 0 : 1),
      );
    } on DioException catch (error) {
      throw mapMetadataWriteError(error);
    }
  }

  Future<Brand> getBrandById(String brandId) async {
    try {
      final response = await _dioClient.dio.get<Map<String, dynamic>>(
        '/brands/$brandId',
      );
      return _mapBrand(response.data ?? const <String, dynamic>{});
    } on DioException catch (error) {
      throw mapMetadataWriteError(error);
    }
  }

  Future<Brand> saveBrand(Brand brand) async {
    final payload = <String, dynamic>{
      'name': sanitizeMetadataJsonText(brand.name),
      'description': sanitizeNullableMetadataJsonText(brand.description),
      'logoUrl': sanitizeNullableMetadataJsonText(brand.logoUrl),
      if (brand.id.isNotEmpty) 'isActive': brand.isActive,
    }..removeWhere((key, value) => value == null);

    try {
      final response = brand.id.isEmpty
          ? await _dioClient.dio.post<Map<String, dynamic>>(
              '/brands',
              data: encodeMetadataJsonBody(payload),
              options: Options(contentType: Headers.jsonContentType),
            )
          : await _dioClient.dio.patch<Map<String, dynamic>>(
              '/brands/${brand.id}',
              data: encodeMetadataJsonBody(payload),
              options: Options(contentType: Headers.jsonContentType),
            );
      return _mapBrand(response.data ?? <String, dynamic>{});
    } on DioException catch (error) {
      throw mapMetadataWriteError(error);
    }
  }

  Future<void> deleteBrand(String brandId) async {
    try {
      await _dioClient.dio.delete<void>('/brands/$brandId');
    } on DioException catch (error) {
      throw mapMetadataWriteError(error);
    }
  }

  Brand _mapBrand(Map<String, dynamic> json) {
    if (json['createdAt'] == null) {
      throw FormatException('Brand response missing required field: createdAt');
    }
    if (json['updatedAt'] == null) {
      throw FormatException('Brand response missing required field: updatedAt');
    }
    return Brand(
      id: json['id'] as String? ?? '',
      tenantId: json['tenantId'] as String? ?? '',
      name: json['name'] as String? ?? '',
      description: json['description'] as String?,
      logoUrl: json['logoUrl'] as String?,
      isActive: json['isActive'] as bool? ?? true,
      createdAt: parseRequiredMetadataTimestamp(
        json,
        'createdAt',
        contextLabel: 'Brand',
      ),
      updatedAt: parseRequiredMetadataTimestamp(
        json,
        'updatedAt',
        contextLabel: 'Brand',
      ),
    );
  }
}
