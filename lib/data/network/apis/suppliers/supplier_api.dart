import 'package:mobile_ai_erp/core/data/network/dio/dio_client.dart';
import 'package:mobile_ai_erp/data/network/constants/endpoints.dart';

class SupplierApi {
  final DioClient _dioClient;

  SupplierApi(this._dioClient);

  Future<dynamic> getSuppliers({
    String search = '',
    int page = 1,
    int pageSize = 20,
  }) async {
    final response = await _dioClient.dio.get(
      Endpoints.suppliers,
      queryParameters: {
        'search': search,
        'page': page,
        'pageSize': pageSize,
      },
    );
    return response.data;
  }

  Future<dynamic> getSupplierById(String id) async {
    final response = await _dioClient.dio.get('${Endpoints.suppliers}/$id');
    return response.data;
  }

  Future<dynamic> createSupplier(Map<String, dynamic> payload) async {
    final response = await _dioClient.dio.post(
      Endpoints.suppliers,
      data: payload,
    );
    return response.data;
  }

  Future<dynamic> updateSupplier(String id, Map<String, dynamic> payload) async {
    final response = await _dioClient.dio.patch(
      '${Endpoints.suppliers}/$id',
      data: payload,
    );
    return response.data;
  }

  Future<void> deleteSupplier(String id) async {
    await _dioClient.dio.delete('${Endpoints.suppliers}/$id');
  }

  Future<dynamic> getProducts({
    String search = '',
    int page = 1,
    int pageSize = 20,
  }) async {
    final response = await _dioClient.dio.get(
      Endpoints.products,
      queryParameters: {
        'search': search,
        'page': page,
        'pageSize': pageSize,
      },
    );
    return response.data;
  }
}
