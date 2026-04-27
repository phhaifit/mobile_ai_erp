import 'package:dio/dio.dart';
import 'package:mobile_ai_erp/core/data/network/dio/dio_client.dart';
import 'package:mobile_ai_erp/data/repository/product_metadata/product_metadata_network_utils.dart';
import 'package:mobile_ai_erp/domain/entity/product_metadata/tag.dart';
import 'package:mobile_ai_erp/domain/entity/product_metadata/metadata_page.dart';

class TagApi {
  TagApi(this._dioClient);

  final DioClient _dioClient;

  Future<MetadataPage<Tag>> getTags({
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
        '/tags',
        queryParameters: queryParams,
      );
      final data =
          response.data?['data'] as List<dynamic>? ?? const <dynamic>[];
      final meta =
          response.data?['meta'] as Map<String, dynamic>? ??
          const <String, dynamic>{};
      return MetadataPage<Tag>(
        items: data
            .map((item) => _mapTag(item as Map<String, dynamic>))
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

  Future<Tag> getTagById(String tagId) async {
    try {
      final response = await _dioClient.dio.get<Map<String, dynamic>>(
        '/tags/$tagId',
      );
      return _mapTag(response.data ?? const <String, dynamic>{});
    } on DioException catch (error) {
      throw mapMetadataWriteError(error);
    }
  }

  Future<Tag> saveTag(Tag tag) async {
    final payload = <String, dynamic>{
      'name': sanitizeMetadataJsonText(tag.name),
      'description': sanitizeNullableMetadataJsonText(tag.description),
    };

    try {
      final response = tag.id.isEmpty
          ? await _dioClient.dio.post<Map<String, dynamic>>(
              '/tags',
              data: encodeMetadataJsonBody(payload),
              options: Options(contentType: Headers.jsonContentType),
            )
          : await _dioClient.dio.patch<Map<String, dynamic>>(
              '/tags/${tag.id}',
              data: encodeMetadataJsonBody(payload),
              options: Options(contentType: Headers.jsonContentType),
            );
      return _mapTag(response.data ?? <String, dynamic>{});
    } on DioException catch (error) {
      throw mapMetadataWriteError(error);
    }
  }

  Future<void> deleteTag(String tagId) async {
    try {
      await _dioClient.dio.delete<void>('/tags/$tagId');
    } on DioException catch (error) {
      throw mapMetadataWriteError(error);
    }
  }

  Tag _mapTag(Map<String, dynamic> json) {
    return Tag(
      id: json['id'] as String? ?? '',
      tenantId: json['tenantId'] as String? ?? '',
      name: json['name'] as String? ?? '',
      description: json['description'] as String?,
      createdAt: parseOptionalMetadataTimestamp(
        json,
        'createdAt',
        contextLabel: 'Tag',
      ),
      updatedAt: parseOptionalMetadataTimestamp(
        json,
        'updatedAt',
        contextLabel: 'Tag',
      ),
    );
  }
}
