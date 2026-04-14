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
        '/attribute-sets',
        queryParameters: queryParams,
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

    if (attributeSet.values.isNotEmpty || attributeSet.id.isNotEmpty) {
      // For create, send values if present. For update, ALWAYS send values to ensure deletes sync properly.
      payload['values'] = attributeSet.values.map((v) => {
        if (v.id.isNotEmpty) 'id': v.id,
        'value': sanitizeMetadataJsonText(v.value),
        'sortOrder': v.sortOrder,
      }).toList();
    }

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
    try {
      // Fetch current attribute set to get existing values
      final getResponse = await _dioClient.dio.get<Map<String, dynamic>>(
        '/attribute-sets/${attributeValue.attributeSetId}',
      );
      final currentAttributeSet = getResponse.data ?? const <String, dynamic>{};
      final currentValuesData = currentAttributeSet['values'] as List<dynamic>? ?? const <dynamic>[];
      
      final currentValues = currentValuesData
          .whereType<Map<String, dynamic>>()
          .map((v) => _mapAttributeValue(v))
          .toList();

      List<AttributeValue> updatedValues;
      if (attributeValue.id.isNotEmpty) {
        // Update case: replace existing value by ID
        updatedValues = currentValues.map((v) {
          return v.id == attributeValue.id ? attributeValue : v;
        }).toList();
      } else {
        // Create case: append new value
        updatedValues = [...currentValues, attributeValue];
      }

      final payload = <String, dynamic>{
        'values': updatedValues.map((v) => {
          if (v.id.isNotEmpty) 'id': v.id,
          'value': sanitizeMetadataJsonText(v.value),
          'sortOrder': v.sortOrder,
        }).toList()
      };

      final response = await _dioClient.dio.patch<Map<String, dynamic>>(
        '/attribute-sets/${attributeValue.attributeSetId}',
        data: encodeMetadataJsonBody(payload),
        options: Options(contentType: Headers.jsonContentType),
      );

      final returnedValues = response.data?['values'] as List<dynamic>? ?? const <dynamic>[];
      final mappedReturnedValues = returnedValues
          .map((item) => _mapAttributeValue(item as Map<String, dynamic>))
          .toList();
      
      if (attributeValue.id.isNotEmpty) {
        return mappedReturnedValues.firstWhere(
          (val) => val.id == attributeValue.id,
          orElse: () => throw StateError('Updated value not found in response'),
        );
      } else {
        // For creates, match by value and lack of ID in the original (or just find the one that didn't have an ID before)
        // More robust: find the one that exists in updated but matched the new value
        return mappedReturnedValues.lastWhere(
          (val) => val.value == attributeValue.value,
          orElse: () => throw StateError('Created value not found in response'),
        );
      }
    } on DioException catch (error) {
      throw mapMetadataWriteError(error);
    }
  }

  /// Remove an attribute value from an attribute set.
  ///
  /// Delete an attribute value via read-modify-write pattern:
  /// 1. GET /attribute-sets/{attributeSetId} to fetch current values array
  /// 2. Filter out the value with matching valueId
  /// 3. PATCH /attribute-sets/{attributeSetId} with updated values array
  Future<void> deleteAttributeValue(String attributeSetId, String valueId) async {
    try {
      final getResponse = await _dioClient.dio.get<Map<String, dynamic>>(
        '/attribute-sets/$attributeSetId',
      );

      final attributeSet = getResponse.data ?? const <String, dynamic>{};
      final currentValues =
          attributeSet['values'] as List<dynamic>? ?? const <dynamic>[];

      final updatedValues = currentValues
          .whereType<Map<String, dynamic>>()
          .where((value) => (value['id'] as String? ?? '') != valueId)
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
