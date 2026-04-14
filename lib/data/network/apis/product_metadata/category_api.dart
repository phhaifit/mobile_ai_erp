import 'package:dio/dio.dart';
import 'package:mobile_ai_erp/core/data/network/dio/dio_client.dart';
import 'package:mobile_ai_erp/data/repository/product_metadata/product_metadata_network_utils.dart';
import 'package:mobile_ai_erp/domain/entity/product_metadata/category.dart';
import 'package:mobile_ai_erp/domain/entity/product_metadata/metadata_page.dart';

class CategoryApi {
  CategoryApi(this._dioClient);

  final DioClient _dioClient;

  Future<MetadataPage<Category>> getCategories({
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
        '/categories',
        queryParameters: queryParams,
      );
      final data =
          response.data?['data'] as List<dynamic>? ?? const <dynamic>[];
      final meta =
          response.data?['meta'] as Map<String, dynamic>? ??
          const <String, dynamic>{};
      return MetadataPage<Category>(
        items: data
            .map((item) => _mapCategory(item as Map<String, dynamic>))
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

  Future<List<Category>> getCategoryTree() async {
    try {
      final response = await _dioClient.dio.get<List<dynamic>>(
        '/categories/tree',
      );
      final data = response.data ?? const <dynamic>[];
      final List<Category> flattened = [];

      void traverse(List<dynamic> nodes) {
        for (final node in nodes) {
          final item = node as Map<String, dynamic>;
          flattened.add(_mapCategory(item));
          final children = item['children'] as List<dynamic>?;
          if (children != null && children.isNotEmpty) {
            traverse(children);
          }
        }
      }

      traverse(data);
      return flattened;
    } on DioException catch (error) {
      throw mapMetadataWriteError(error);
    }
  }

  Future<Category> getCategoryById(String categoryId) async {
    try {
      final response = await _dioClient.dio.get<Map<String, dynamic>>(
        '/categories/$categoryId',
      );
      return _mapCategory(response.data ?? const <String, dynamic>{});
    } on DioException catch (error) {
      throw mapMetadataWriteError(error);
    }
  }

  Future<Category> saveCategory(Category category) async {
    final payload = <String, dynamic>{
      'name': sanitizeMetadataJsonText(category.name),
      'slug': sanitizeMetadataJsonText(category.slug),
      'description': sanitizeNullableMetadataJsonText(category.description),
      'parentId': category.parentId,
    };

    try {
      final response = category.id.isEmpty
          ? await _dioClient.dio.post<Map<String, dynamic>>(
              '/categories',
              data: encodeMetadataJsonBody(payload),
              options: Options(contentType: Headers.jsonContentType),
            )
          : await _dioClient.dio.patch<Map<String, dynamic>>(
              '/categories/${category.id}',
              data: encodeMetadataJsonBody(payload),
              options: Options(contentType: Headers.jsonContentType),
            );
      return _mapCategory(response.data ?? <String, dynamic>{});
    } on DioException catch (error) {
      throw mapMetadataWriteError(error);
    }
  }

  Future<void> deleteCategory(String categoryId) async {
    try {
      await _dioClient.dio.delete<void>('/categories/$categoryId');
    } on DioException catch (error) {
      throw mapMetadataWriteError(error);
    }
  }

  Category _mapCategory(Map<String, dynamic> json) {
    if (json['createdAt'] == null) {
      throw FormatException(
        'Category response missing required field: createdAt',
      );
    }
    if (json['updatedAt'] == null) {
      throw FormatException(
        'Category response missing required field: updatedAt',
      );
    }
    return Category(
      id: json['id'] as String? ?? '',
      tenantId: json['tenantId'] as String? ?? '',
      parentId: json['parentId'] as String?,
      name: json['name'] as String? ?? '',
      slug: json['slug'] as String? ?? '',
      description: json['description'] as String?,
      createdAt: parseRequiredMetadataTimestamp(
        json,
        'createdAt',
        contextLabel: 'Category',
      ),
      updatedAt: parseRequiredMetadataTimestamp(
        json,
        'updatedAt',
        contextLabel: 'Category',
      ),
    );
  }
}
