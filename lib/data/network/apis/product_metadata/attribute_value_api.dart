import 'package:dio/dio.dart';
import 'package:mobile_ai_erp/core/data/network/dio/dio_client.dart';
import 'package:mobile_ai_erp/data/repository/product_metadata/product_metadata_network_utils.dart';
import 'package:mobile_ai_erp/domain/entity/product_metadata/attribute.dart';

class AttributeValueApi {
  AttributeValueApi(this._dioClient);

  final DioClient _dioClient;

  Future<AttributeValue> saveAttributeValue(AttributeValue value) async {
    try {
      final current = await _fetchValues(value.attributeSetId);
      final List<AttributeValue> updated;
      if (value.id.isNotEmpty) {
        updated = current.map((v) => v.id == value.id ? value : v).toList();
      } else {
        updated = [...current, value];
      }
      final response = await _dioClient.dio.patch<Map<String, dynamic>>(
        '/attribute-sets/${value.attributeSetId}',
        data: encodeMetadataJsonBody({'values': _toPayload(updated)}),
        options: Options(contentType: Headers.jsonContentType),
      );
      final returned = (response.data?['values'] as List<dynamic>? ?? [])
          .map((e) => _mapValue(e as Map<String, dynamic>))
          .toList();
      if (value.id.isNotEmpty) {
        return returned.firstWhere((v) => v.id == value.id,
            orElse: () => throw StateError('Updated value not found in response'));
      }
      return returned.lastWhere((v) => v.value == value.value,
          orElse: () => throw StateError('Created value not found in response'));
    } on DioException catch (e) {
      throw mapMetadataWriteError(e);
    }
  }

  Future<void> deleteAttributeValue(String attributeSetId, String valueId) async {
    try {
      final current = await _fetchValues(attributeSetId);
      final updated = current.where((v) => v.id != valueId).toList();
      await _dioClient.dio.patch<Map<String, dynamic>>(
        '/attribute-sets/$attributeSetId',
        data: encodeMetadataJsonBody({'values': _toPayload(updated)}),
        options: Options(contentType: Headers.jsonContentType),
      );
    } on DioException catch (e) {
      throw mapMetadataWriteError(e);
    }
  }

  Future<List<AttributeValue>> _fetchValues(String attributeSetId) async {
    final response = await _dioClient.dio.get<Map<String, dynamic>>(
      '/attribute-sets/$attributeSetId',
    );
    return ((response.data?['values'] as List<dynamic>?) ?? [])
        .whereType<Map<String, dynamic>>()
        .map(_mapValue)
        .toList();
  }

  List<Map<String, dynamic>> _toPayload(List<AttributeValue> values) =>
      values.map((v) => <String, dynamic>{
        if (v.id.isNotEmpty) 'id': v.id,
        'value': sanitizeMetadataJsonText(v.value),
        'sortOrder': v.sortOrder,
      }).toList();

  AttributeValue _mapValue(Map<String, dynamic> json) {
    if (json['createdAt'] == null) {
      throw FormatException('AttributeValue response missing required field: createdAt');
    }
    return AttributeValue(
      id: json['id'] as String? ?? '',
      attributeSetId: json['attributeSetId'] as String? ?? '',
      value: json['value'] as String? ?? '',
      sortOrder: json['sortOrder'] as int? ?? 0,
      createdAt: parseRequiredMetadataTimestamp(json, 'createdAt', contextLabel: 'AttributeValue'),
    );
  }
}
