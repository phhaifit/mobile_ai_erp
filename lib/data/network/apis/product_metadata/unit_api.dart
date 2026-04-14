import 'package:dio/dio.dart';
import 'package:mobile_ai_erp/core/data/network/dio/dio_client.dart';
import 'package:mobile_ai_erp/data/repository/product_metadata/product_metadata_network_utils.dart';
import 'package:mobile_ai_erp/domain/entity/product_metadata/unit.dart';
import 'package:mobile_ai_erp/domain/entity/product_metadata/metadata_page.dart';

class UnitApi {
  UnitApi(this._dioClient);

  final DioClient _dioClient;

  Future<MetadataPage<Unit>> getUnits({
    int page = 1,
    int pageSize = 10,
    String? search,
    bool includeInactive = false,
    String? sortBy,
    String? sortOrder,
  }) async {
    try {
      final normalizedPage = page < 1 ? 1 : page;
      final normalizedPageSize = pageSize.clamp(1, 100);
      final queryParams = <String, dynamic>{
        'page': normalizedPage,
        'pageSize': normalizedPageSize,
        'includeInactive': includeInactive,
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
        '/units',
        queryParameters: queryParams,
      );
      final data =
          response.data?['data'] as List<dynamic>? ?? const <dynamic>[];
      final meta =
          response.data?['meta'] as Map<String, dynamic>? ??
          const <String, dynamic>{};
      return MetadataPage<Unit>(
        items: data
            .map((item) => _mapUnit(item as Map<String, dynamic>))
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

  Future<Unit> getUnitById(String unitId) async {
    try {
      final response = await _dioClient.dio.get<Map<String, dynamic>>(
        '/units/$unitId',
      );
      return _mapUnit(response.data ?? const <String, dynamic>{});
    } on DioException catch (error) {
      throw mapMetadataWriteError(error);
    }
  }

  Future<Unit> saveUnit(Unit unit) async {
    final payload = <String, dynamic>{
      'name': sanitizeMetadataJsonText(unit.name),
      'symbol': sanitizeNullableMetadataJsonText(unit.symbol),
      'description': sanitizeNullableMetadataJsonText(unit.description),
      if (unit.id.isNotEmpty) 'isActive': unit.isActive,
    };

    try {
      final response = unit.id.isEmpty
          ? await _dioClient.dio.post<Map<String, dynamic>>(
              '/units',
              data: encodeMetadataJsonBody(payload),
              options: Options(contentType: Headers.jsonContentType),
            )
          : await _dioClient.dio.patch<Map<String, dynamic>>(
              '/units/${unit.id}',
              data: encodeMetadataJsonBody(payload),
              options: Options(contentType: Headers.jsonContentType),
            );
      return _mapUnit(response.data ?? <String, dynamic>{});
    } on DioException catch (error) {
      throw mapMetadataWriteError(error);
    }
  }

  Future<void> deleteUnit(String unitId) async {
    try {
      await _dioClient.dio.delete<void>('/units/$unitId');
    } on DioException catch (error) {
      throw mapMetadataWriteError(error);
    }
  }

  Unit _mapUnit(Map<String, dynamic> json) {
    if (json['createdAt'] == null) {
      throw FormatException('Unit response missing required field: createdAt');
    }
    if (json['updatedAt'] == null) {
      throw FormatException('Unit response missing required field: updatedAt');
    }
    return Unit(
      id: json['id'] as String? ?? '',
      tenantId: json['tenantId'] as String? ?? '',
      name: json['name'] as String? ?? '',
      symbol: json['symbol'] as String?,
      description: json['description'] as String?,
      isActive: json['isActive'] as bool? ?? true,
      createdAt: parseRequiredMetadataTimestamp(
        json,
        'createdAt',
        contextLabel: 'Unit',
      ),
      updatedAt: parseRequiredMetadataTimestamp(
        json,
        'updatedAt',
        contextLabel: 'Unit',
      ),
    );
  }
}
