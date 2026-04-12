import 'package:dio/dio.dart';
import 'package:mobile_ai_erp/core/data/network/dio/dio_client.dart';
import 'package:mobile_ai_erp/data/repository/product_metadata/product_metadata_network_utils.dart';
import 'package:mobile_ai_erp/domain/entity/product_metadata/attribute.dart';
import 'package:mobile_ai_erp/domain/entity/product_metadata/metadata_page.dart';

class AttributeSetApi {
  AttributeSetApi(this._dioClient);

  final DioClient _dioClient;

  Future<MetadataPage<AttributeSet>> getAttributeSets({
    int page = 1,
    int pageSize = 20,
    String? search,
  }) async {
    try {
      final normalizedPage = page < 1 ? 1 : page;
      final normalizedPageSize = pageSize.clamp(1, 100);
      final response = await _dioClient.dio.get<Map<String, dynamic>>(
        '/attribute-sets',
        queryParameters: <String, dynamic>{
          'page': normalizedPage,
          'pageSize': normalizedPageSize,
          if (search != null && search.trim().isNotEmpty) 'search': search.trim(),
        },
      );
      final data = response.data?['data'] as List<dynamic>? ?? const <dynamic>[];
      final meta = response.data?['meta'] as Map<String, dynamic>? ?? const <String, dynamic>{};
      return MetadataPage<AttributeSet>(
        items: data
            .map((item) => _mapAttributeSet(item as Map<String, dynamic>))
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

  Future<AttributeSet> getAttributeSetById(String attributeSetId) async {
    try {
      final response = await _dioClient.dio
          .get<Map<String, dynamic>>('/attribute-sets/$attributeSetId');
      return _mapAttributeSet(response.data ?? const <String, dynamic>{});
    } on DioException catch (error) {
      throw mapMetadataWriteError(error);
    }
  }

  Future<List<AttributeValue>> getAllAttributeValues() async {
    try {
      final response = await _dioClient.dio.get<List<dynamic>>('/attribute-sets/values/all');
      final data = response.data ?? const <dynamic>[];
      return data
          .map((item) => _mapAttributeValue(item as Map<String, dynamic>))
          .toList(growable: false);
    } on DioException catch (error) {
      throw mapMetadataWriteError(error);
    }
  }

  Future<AttributeSet> saveAttributeSet(AttributeSet attributeSet) async {
    final payload = <String, dynamic>{
      'name': sanitizeMetadataJsonText(attributeSet.name),
      'description': sanitizeNullableMetadataJsonText(attributeSet.description),
    }..removeWhere((key, value) => value == null);

    try {
      final response = attributeSet.id.isEmpty
          ? await _dioClient.dio.post<Map<String, dynamic>>(
              '/attribute-sets',
              data: encodeMetadataJsonBody(payload),
              options: Options(contentType: Headers.jsonContentType),
            )
          : await _dioClient.dio.patch<Map<String, dynamic>>(
              '/attribute-sets/${attributeSet.id}',
              data: encodeMetadataJsonBody(payload),
              options: Options(contentType: Headers.jsonContentType),
            );
      return _mapAttributeSet(response.data ?? <String, dynamic>{});
    } on DioException catch (error) {
      throw mapMetadataWriteError(error);
    }
  }

  Future<void> deleteAttributeSet(String attributeSetId) async {
    try {
      await _dioClient.dio.delete<void>('/attribute-sets/$attributeSetId');
    } on DioException catch (error) {
      throw mapMetadataWriteError(error);
    }
  }

  Future<AttributeValue> saveAttributeValue(
      AttributeValue attributeValue) async {
    // Attribute values are persisted by patching the parent attribute set's
    // `values` array.
    try {
      final payload = <String, dynamic>{
        'values': <Map<String, dynamic>>[
          {
            if (attributeValue.id.isNotEmpty) 'id': attributeValue.id,
            'value': sanitizeMetadataJsonText(attributeValue.value),
            'sortOrder': attributeValue.sortOrder,
          }
        ]
      };
      final response = await _dioClient.dio.patch<Map<String, dynamic>>(
        '/attribute-sets/${attributeValue.attributeSetId}',
        data: encodeMetadataJsonBody(payload),
        options: Options(contentType: Headers.jsonContentType),
      );
      final values = response.data?['values'] as List<dynamic>? ?? const <dynamic>[];
      
      final mappedValues = values
          .map((item) => _mapAttributeValue(item as Map<String, dynamic>))
          .toList();
      
      // For updates (has ID): match by ID (most reliable)
      // For creates (no ID): match by value AND verify it has an ID (server-assigned)
      if (attributeValue.id.isNotEmpty) {
        // Update case: ID must exist in response
        AttributeValue? savedValue;
        try {
          savedValue = mappedValues.firstWhere((val) => val.id == attributeValue.id);
        } catch (e) {
          // Not found in response
        }
        if (savedValue == null) {
          throw StateError(
            'Updated AttributeValue with ID ${attributeValue.id} not found in server response. '
            'This may indicate a server-side issue or data corruption.',
          );
        }
        return savedValue;
      } else {
        // Create case: must find value in response AND it must have been assigned a server ID
        AttributeValue? savedValue;
        try {
          savedValue = mappedValues.firstWhere(
            (val) => val.value == attributeValue.value && val.id.isNotEmpty,
          );
        } catch (e) {
          // Not found in response
        }
        if (savedValue == null) {
          throw StateError(
            'Created AttributeValue with value "${attributeValue.value}" not found in server response '
            'or was not assigned a server ID. This indicates a server-side issue or failed persistence.',
          );
        }
        return savedValue;
      }
    } on DioException catch (error) {
      throw mapMetadataWriteError(error);
    }
  }

  /// Remove an attribute value from an attribute set.
  ///
  /// (READ-MODIFY-WRITE pattern):
  /// 1. GET /attribute-sets/{attributeSetId} to fetch current values array
  /// 2. Filter out the value with matching optionId
  /// 3. PATCH /attribute-sets/{attributeSetId} with updated values array
  Future<void> deleteAttributeOption(String attributeSetId, String optionId) async {
    try {
      final getResponse = await _dioClient.dio.get<Map<String, dynamic>>(
        '/attribute-sets/$attributeSetId',
      );

      final attributeSet = getResponse.data ?? const <String, dynamic>{};
      final currentValues =
          attributeSet['values'] as List<dynamic>? ?? const <dynamic>[];

      final updatedValues = currentValues
          .whereType<Map<String, dynamic>>()
          .where((value) => (value['id'] as String? ?? '') != optionId)
          .map(
            (value) => <String, dynamic>{
              if ((value['id'] as String? ?? '').isNotEmpty)
                'id': value['id'] as String,
              'value': sanitizeMetadataJsonText(value['value'] as String? ?? ''),
              'sortOrder': value['sortOrder'] as int? ?? 0,
            },
          )
          .toList();

      final payload = <String, dynamic>{'values': updatedValues};

      await _dioClient.dio.patch<Map<String, dynamic>>(
        '/attribute-sets/$attributeSetId',
        data: encodeMetadataJsonBody(payload),
        options: Options(contentType: Headers.jsonContentType),
      );
    } on DioException catch (error) {
      throw mapMetadataWriteError(error);
    }
  }

  AttributeSet _mapAttributeSet(Map<String, dynamic> json) {
    if (json['createdAt'] == null) {
      throw FormatException('AttributeSet response missing required field: createdAt');
    }
    return AttributeSet(
      id: json['id'] as String? ?? '',
      tenantId: json['tenantId'] as String? ?? '',
      name: json['name'] as String? ?? '',
      description: json['description'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      values: (json['values'] as List<dynamic>?)
              ?.map((v) => _mapAttributeValue(v as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  AttributeValue _mapAttributeValue(Map<String, dynamic> json) {
    if (json['createdAt'] == null) {
      throw FormatException('AttributeValue response missing required field: createdAt');
    }
    return AttributeValue(
      id: json['id'] as String? ?? '',
      attributeSetId: json['attributeSetId'] as String? ?? '',
      value: json['value'] as String? ?? '',
      sortOrder: json['sortOrder'] as int? ?? 0,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }
}
