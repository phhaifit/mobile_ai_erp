import 'package:dio/dio.dart';
import 'package:mobile_ai_erp/core/data/network/dio/dio_client.dart';
import 'package:mobile_ai_erp/data/network/dto/shared/paginated_response.dto.dart';
import 'package:mobile_ai_erp/data/repository/product_metadata/product_metadata_network_utils.dart';
import 'package:mobile_ai_erp/domain/entity/product_metadata/brand.dart';
import 'package:mobile_ai_erp/domain/entity/product_metadata/metadata_page.dart';

class BrandApi {
  BrandApi(this._dioClient);

  final DioClient _dioClient;

  Future<MetadataPage<Brand>> getBrands({
    int page = 1,
    int pageSize = 10,
    String? search,
    String? sortBy,
    String? sortOrder,
  }) async {
    try {
      final normalizedPage = page < 1 ? 1 : page;
      final normalizedPageSize = pageSize.clamp(1, 100);
      final queryParams = <String, dynamic>{
        'page': normalizedPage,
        'pageSize': normalizedPageSize,
      };
      if (search != null && search.trim().isNotEmpty) {
        queryParams['search'] = search.trim();
      }
      if (sortBy != null) {
        queryParams['sortBy'] = sortBy;
      }
      if (sortOrder != null) {
        queryParams['sortOrder'] = sortOrder;
      }
      final response = await _dioClient.dio.get<Map<String, dynamic>>(
        erpMetadataPath('/brands'),
        queryParameters: queryParams,
      );
      final pageDto = PaginatedResponseDto.fromJson(
        response.data ?? const <String, dynamic>{},
        pageFallback: normalizedPage,
        pageSizeFallback: normalizedPageSize,
      );
      return MetadataPage<Brand>(
        items: pageDto.data
            .map(_mapBrand)
            .toList(growable: false),
        page: pageDto.page,
        pageSize: pageDto.pageSize,
        totalItems: pageDto.totalItems,
        totalPages: pageDto.totalPages,
      );
    } on DioException catch (error) {
      throw mapMetadataWriteError(error);
    }
  }

  Future<Brand> getBrandById(String brandId) async {
    try {
      final response = await _dioClient.dio.get<Map<String, dynamic>>(
        erpMetadataPath('/brands/$brandId'),
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
    };

    try {
      final response = brand.id.isEmpty
          ? await _dioClient.dio.post<Map<String, dynamic>>(
              erpMetadataPath('/brands'),
              data: encodeMetadataJsonBody(payload),
              options: Options(contentType: Headers.jsonContentType),
            )
          : await _dioClient.dio.patch<Map<String, dynamic>>(
              erpMetadataPath('/brands/${brand.id}'),
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
      await _dioClient.dio.delete<void>(erpMetadataPath('/brands/$brandId'));
    } on DioException catch (error) {
      throw mapMetadataWriteError(error);
    }
  }

  Brand _mapBrand(Map<String, dynamic> json) {
    return Brand(
      id: json['id'] as String? ?? '',
      tenantId: json['tenantId'] as String? ?? '',
      name: json['name'] as String? ?? '',
      description: json['description'] as String?,
      logoUrl: json['logoUrl'] as String?,
      createdAt: parseOptionalMetadataTimestamp(
        json,
        'createdAt',
        contextLabel: 'Brand',
      ),
      updatedAt: parseOptionalMetadataTimestamp(
        json,
        'updatedAt',
        contextLabel: 'Brand',
      ),
    );
  }
}
