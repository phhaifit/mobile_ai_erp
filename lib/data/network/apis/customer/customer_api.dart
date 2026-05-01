import 'package:flutter/foundation.dart';
import 'package:mobile_ai_erp/core/data/network/dio/dio_client.dart';
import 'package:mobile_ai_erp/data/network/apis/customer/dto/address_response.dart';
import 'package:mobile_ai_erp/data/network/apis/customer/dto/customer_detail_response.dart';
import 'package:mobile_ai_erp/data/network/apis/customer/dto/customer_list_response.dart';
import 'package:mobile_ai_erp/data/network/apis/customer/dto/customer_transaction_response.dart';
import 'package:mobile_ai_erp/data/network/constants/endpoints.dart';

class CustomerApi {
  final DioClient _dioClient;

  CustomerApi(this._dioClient);

  Future<CustomerListResponse> getCustomers({
    int page = 1,
    int pageSize = 20,
    String? search,
    String? status,
    String? groupId,
  }) async {
    try {
      final res = await _dioClient.dio.get(
        Endpoints.customers,
        queryParameters: {
          'page': page,
          'pageSize': pageSize,
          if (search != null && search.isNotEmpty) 'search': search,
          if (status != null && status.isNotEmpty) 'status': status,
          if (groupId != null && groupId.isNotEmpty) 'groupId': groupId,
        },
      );
      return CustomerListResponse.fromJson(res.data as Map<String, dynamic>);
    } catch (e) {
      debugPrint('CustomerApi.getCustomers error: $e');
      rethrow;
    }
  }

  Future<CustomerDetailDto> getCustomerById(String id) async {
    try {
      final res = await _dioClient.dio.get(Endpoints.customerById(id));
      return CustomerDetailDto.fromJson(res.data as Map<String, dynamic>);
    } catch (e) {
      debugPrint('CustomerApi.getCustomerById error: $e');
      rethrow;
    }
  }

  Future<CustomerDetailDto> createCustomer(
      Map<String, dynamic> body) async {
    try {
      final res = await _dioClient.dio.post(Endpoints.customers, data: body);
      return CustomerDetailDto.fromJson(res.data as Map<String, dynamic>);
    } catch (e) {
      debugPrint('CustomerApi.createCustomer error: $e');
      rethrow;
    }
  }

  Future<CustomerDetailDto> updateCustomer(
      String id, Map<String, dynamic> body) async {
    try {
      final res = await _dioClient.dio.patch(
        Endpoints.customerById(id),
        data: body,
      );
      return CustomerDetailDto.fromJson(res.data as Map<String, dynamic>);
    } catch (e) {
      debugPrint('CustomerApi.updateCustomer error: $e');
      rethrow;
    }
  }

  Future<void> updateCustomerStatus(String id, String status) async {
    try {
      await _dioClient.dio.patch(
        Endpoints.customerStatus(id),
        data: {'status': status},
      );
    } catch (e) {
      debugPrint('CustomerApi.updateCustomerStatus error: $e');
      rethrow;
    }
  }

  Future<void> deleteCustomer(String id) async {
    try {
      await _dioClient.dio.delete(Endpoints.customerById(id));
    } catch (e) {
      debugPrint('CustomerApi.deleteCustomer error: $e');
      rethrow;
    }
  }

  Future<List<AddressDto>> getAddresses(String customerId) async {
    try {
      final res =
          await _dioClient.dio.get(Endpoints.customerAddresses(customerId));
      final data = res.data;
      if (data is! List<dynamic>) return const [];
      return data
          .whereType<Map<String, dynamic>>()
          .map(AddressDto.fromJson)
          .toList();
    } catch (e) {
      debugPrint('CustomerApi.getAddresses error: $e');
      rethrow;
    }
  }

  Future<AddressDto> createAddress(
      String customerId, Map<String, dynamic> body) async {
    try {
      final res = await _dioClient.dio.post(
        Endpoints.customerAddresses(customerId),
        data: body,
      );
      return AddressDto.fromJson(res.data as Map<String, dynamic>);
    } catch (e) {
      debugPrint('CustomerApi.createAddress error: $e');
      rethrow;
    }
  }

  Future<AddressDto> updateAddress(
      String customerId, String addressId, Map<String, dynamic> body) async {
    try {
      final res = await _dioClient.dio.patch(
        Endpoints.customerAddressById(customerId, addressId),
        data: body,
      );
      return AddressDto.fromJson(res.data as Map<String, dynamic>);
    } catch (e) {
      debugPrint('CustomerApi.updateAddress error: $e');
      rethrow;
    }
  }

  Future<void> deleteAddress(String customerId, String addressId) async {
    try {
      await _dioClient.dio
          .delete(Endpoints.customerAddressById(customerId, addressId));
    } catch (e) {
      debugPrint('CustomerApi.deleteAddress error: $e');
      rethrow;
    }
  }

  Future<void> setDefaultAddress(
      String customerId, String addressId) async {
    try {
      await _dioClient.dio
          .patch(Endpoints.customerAddressDefault(customerId, addressId));
    } catch (e) {
      debugPrint('CustomerApi.setDefaultAddress error: $e');
      rethrow;
    }
  }

  Future<List<CustomerTransactionDto>> getTransactions(
      String customerId) async {
    try {
      final res = await _dioClient.dio
          .get(Endpoints.customerTransactions(customerId));
      final data = res.data;
      if (data is! List<dynamic>) return const [];
      return data
          .whereType<Map<String, dynamic>>()
          .map(CustomerTransactionDto.fromJson)
          .toList();
    } catch (e) {
      debugPrint('CustomerApi.getTransactions error: $e');
      rethrow;
    }
  }
}
