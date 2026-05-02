import 'dart:async';

import 'package:dio/dio.dart';
import 'package:mobile_ai_erp/core/data/network/dio/dio_client.dart';
import 'package:mobile_ai_erp/data/sharedpref/shared_preference_helper.dart';
import 'package:mobile_ai_erp/domain/entity/stock_operations/product_stock.dart';
import 'package:mobile_ai_erp/domain/entity/stock_operations/stock_operation.dart';
import 'package:mobile_ai_erp/domain/entity/stock_operations/warehouse.dart';
import 'package:mobile_ai_erp/domain/repository/stock_operations/stock_operations_repository.dart';

class StockOperationsRepositoryImpl extends StockOperationsRepository {
  StockOperationsRepositoryImpl(this._dioClient, this._sharedPrefsHelper);

  static const String _defaultBaseUrl = String.fromEnvironment(
    'ERP_API_BASE_URL',
    defaultValue: 'http://localhost:5000',
  );
  static const String _defaultTenantId = String.fromEnvironment(
    'ERP_TENANT_ID',
    defaultValue: '',
  );

  final DioClient _dioClient;
  final SharedPreferenceHelper _sharedPrefsHelper;

  @override
  Future<List<Warehouse>> getWarehouses() async {
    final response = await _getPaginated('/erp/warehouses', pageSize: 100);

    return response
        .map(
          (item) => Warehouse(
            id: item['id'] as String,
            name: item['name'] as String? ?? '-',
            location: item['address'] as String? ?? '',
          ),
        )
        .toList(growable: false);
  }

  @override
  Future<List<ProductStock>> getProductStocks() async {
    final response = await _getPaginated(
      '/erp/stock-levels/aggregated',
      pageSize: 100,
    );

    return response
        .map(
          (item) => ProductStock(
            id: '${item['warehouseId']}-${item['productId']}',
            productId: item['productId'] as String,
            productName:
                (item['product'] as Map<String, dynamic>)['name'] as String,
            warehouseId: item['warehouseId'] as String,
            availableQuantity: (item['availableQuantity'] as num).toInt(),
          ),
        )
        .toList(growable: false);
  }

  @override
  Future<List<StockOperation>> getOperations() async {
    final response = await _getPaginated(
      '/erp/stock-operations',
      pageSize: 100,
    );

    return response
        .map((item) => _mapStockOperation(item))
        .toList(growable: false);
  }

  @override
  Future<StockOperation> createTransfer({
    required String sourceWarehouseId,
    required String destinationWarehouseId,
    required String productId,
    required int quantity,
  }) async {
    final response = await _post(
      '/erp/stock-operations/transfers',
      data: <String, dynamic>{
        'sourceWarehouseId': sourceWarehouseId,
        'destinationWarehouseId': destinationWarehouseId,
        'productId': productId,
        'quantity': quantity,
      },
    );

    return _mapTransferResponse(response);
  }

  @override
  Future<StockOperation> approveTransfer({required String transferId}) async {
    final response = await _post(
      '/erp/stock-operations/transfers/$transferId/approve',
    );
    return _mapTransferResponse(response);
  }

  @override
  Future<StockOperation> completeTransfer({required String transferId}) async {
    final response = await _post(
      '/erp/stock-operations/transfers/$transferId/complete',
    );
    return _mapTransferResponse(response);
  }

  @override
  Future<StockOperation> submitDamagedOrExpired({
    required String warehouseId,
    required String productId,
    required int quantity,
    required StockOperationType type,
    String? note,
  }) async {
    final response = await _post(
      '/erp/stock-operations/disposals',
      data: <String, dynamic>{
        'warehouseId': warehouseId,
        'productId': productId,
        'quantity': quantity,
        'type': _serializeType(type),
        if (note != null && note.isNotEmpty) 'note': note,
      },
    );

    return _mapDisposalResponse(response);
  }

  Future<List<Map<String, dynamic>>> _getPaginated(
    String path, {
    required int pageSize,
  }) async {
    final tenantId = await _resolveTenantId();
    final allItems = <Map<String, dynamic>>[];
    var page = 1;
    var totalPages = 1;

    do {
      final response = await _dioClient.dio.getUri(
        _buildUri(
          path,
          queryParameters: <String, String>{
            'page': page.toString(),
            'pageSize': pageSize.toString(),
          },
        ),
        options: Options(headers: _headersForTenant(tenantId)),
      );

      final data = _asMap(response.data);
      final items = (data['data'] as List<dynamic>? ?? const <dynamic>[])
          .map((item) => _asMap(item))
          .toList(growable: false);
      final meta = _asMap(data['meta']);

      allItems.addAll(items);
      totalPages = (meta['totalPages'] as num?)?.toInt() ?? 1;
      page++;
    } while (page <= totalPages);

    return allItems;
  }

  Future<Map<String, dynamic>> _post(
    String path, {
    Map<String, dynamic>? data,
  }) async {
    final tenantId = await _resolveTenantId();

    try {
      final response = await _dioClient.dio.postUri(
        _buildUri(path),
        data: data,
        options: Options(headers: _headersForTenant(tenantId)),
      );

      return _asMap(response.data);
    } on DioException catch (error) {
      throw Exception(_extractErrorMessage(error));
    }
  }

  Uri _buildUri(String path, {Map<String, String>? queryParameters}) {
    final normalizedBase = _defaultBaseUrl.endsWith('/')
        ? _defaultBaseUrl.substring(0, _defaultBaseUrl.length - 1)
        : _defaultBaseUrl;
    final normalizedPath = path.startsWith('/') ? path : '/$path';
    return Uri.parse(
      '$normalizedBase$normalizedPath',
    ).replace(queryParameters: queryParameters);
  }

  Future<String> _resolveTenantId() async {
    final tenantId = await _sharedPrefsHelper.currentTenantId;
    final resolved = (tenantId ?? _defaultTenantId).trim();

    if (resolved.isEmpty) {
      throw StateError(
        'Missing tenant context. Set SharedPreferenceHelper.currentTenantId '
        'or provide --dart-define=ERP_TENANT_ID=<tenant-id>.',
      );
    }

    return resolved;
  }

  Map<String, String> _headersForTenant(String tenantId) {
    return <String, String>{'X-Tenant-Id': tenantId};
  }

  Map<String, dynamic> _asMap(dynamic value) {
    if (value is Map<String, dynamic>) {
      return value;
    }
    if (value is Map) {
      return value.map(
        (key, dynamic mapValue) => MapEntry(key.toString(), mapValue),
      );
    }
    return <String, dynamic>{};
  }

  StockOperation _mapTransferResponse(Map<String, dynamic> item) {
    return StockOperation(
      id: item['id'] as String,
      type: StockOperationType.transfer,
      status: _parseStatus(item['status'] as String?),
      productId: item['productId'] as String,
      productName: item['productName'] as String? ?? '-',
      quantity: (item['quantity'] as num).toInt(),
      sourceWarehouseId: item['sourceWarehouseId'] as String?,
      sourceWarehouseName: item['sourceWarehouseName'] as String?,
      destinationWarehouseId: item['destinationWarehouseId'] as String?,
      destinationWarehouseName: item['destinationWarehouseName'] as String?,
      createdAt: DateTime.parse(item['createdAt'] as String),
      createdBy: item['createdBy'] as String?,
      createdByName: item['createdByName'] as String?,
      approvedBy: item['approvedBy'] as String?,
      approvedByName: item['approvedByName'] as String?,
      completedBy: item['completedBy'] as String?,
      completedByName: item['completedByName'] as String?,
      approvedAt: _parseDate(item['approvedAt']),
      completedAt: _parseDate(item['completedAt']),
      note: item['note'] as String?,
    );
  }

  StockOperation _mapDisposalResponse(Map<String, dynamic> item) {
    return StockOperation(
      id: item['id'] as String,
      type: _parseType(item['type'] as String?),
      status: StockOperationStatus.completed,
      productId: item['productId'] as String,
      productName: item['productName'] as String? ?? '-',
      quantity: (item['quantity'] as num).toInt(),
      sourceWarehouseId: item['warehouseId'] as String?,
      sourceWarehouseName: item['warehouseName'] as String?,
      createdAt: DateTime.parse(item['createdAt'] as String),
      createdBy: item['createdBy'] as String?,
      createdByName: item['createdByName'] as String?,
      completedBy: item['completedBy'] as String?,
      completedByName: item['completedByName'] as String?,
      completedAt: _parseDate(item['completedAt']),
      note: item['note'] as String?,
    );
  }

  StockOperation _mapStockOperation(Map<String, dynamic> item) {
    return StockOperation(
      id: item['id'] as String,
      type: _parseType(item['type'] as String?),
      status: _parseStatus(item['status'] as String?),
      productId: item['productId'] as String,
      productName: item['productName'] as String? ?? '-',
      quantity: (item['quantity'] as num).toInt(),
      sourceWarehouseId: item['sourceWarehouseId'] as String?,
      sourceWarehouseName: item['sourceWarehouseName'] as String?,
      destinationWarehouseId: item['destinationWarehouseId'] as String?,
      destinationWarehouseName: item['destinationWarehouseName'] as String?,
      createdAt: DateTime.parse(item['createdAt'] as String),
      createdBy: item['createdBy'] as String?,
      createdByName: item['createdByName'] as String?,
      approvedBy: item['approvedBy'] as String?,
      approvedByName: item['approvedByName'] as String?,
      completedBy: item['completedBy'] as String?,
      completedByName: item['completedByName'] as String?,
      approvedAt: _parseDate(item['approvedAt']),
      completedAt: _parseDate(item['completedAt']),
      note: item['note'] as String?,
    );
  }

  StockOperationType _parseType(String? value) {
    switch (value) {
      case 'damaged':
        return StockOperationType.damaged;
      case 'expired':
        return StockOperationType.expired;
      case 'transfer':
      default:
        return StockOperationType.transfer;
    }
  }

  String _serializeType(StockOperationType type) {
    switch (type) {
      case StockOperationType.transfer:
        return 'transfer';
      case StockOperationType.damaged:
        return 'damaged';
      case StockOperationType.expired:
        return 'expired';
    }
  }

  StockOperationStatus _parseStatus(String? value) {
    switch (value) {
      case 'approved':
        return StockOperationStatus.approved;
      case 'completed':
        return StockOperationStatus.completed;
      case 'cancelled':
        return StockOperationStatus.cancelled;
      case 'draft':
      default:
        return StockOperationStatus.draft;
    }
  }

  DateTime? _parseDate(dynamic value) {
    if (value is String && value.isNotEmpty) {
      return DateTime.tryParse(value);
    }
    return null;
  }

  String _extractErrorMessage(DioException error) {
    final responseData = error.response?.data;
    final responseMap = _asMap(responseData);

    final message = responseMap['message'];
    if (message is String && message.isNotEmpty) {
      return message;
    }
    if (message is List && message.isNotEmpty) {
      return message.join(', ');
    }

    return error.message ?? 'Unexpected network error.';
  }
}
