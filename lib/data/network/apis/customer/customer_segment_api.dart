import 'package:flutter/foundation.dart';
import 'package:mobile_ai_erp/core/data/network/dio/dio_client.dart';
import 'package:mobile_ai_erp/data/network/apis/customer/dto/customer_segment_list_response.dart';
import 'package:mobile_ai_erp/data/network/apis/customer/dto/customer_segment_member_response.dart';
import 'package:mobile_ai_erp/data/network/constants/endpoints.dart';

class CustomerSegmentApi {
  final DioClient _dioClient;

  CustomerSegmentApi(this._dioClient);

  Future<CustomerSegmentListResponse> getSegments({
    int page = 1,
    int pageSize = 20,
    String? search,
    String? sortBy,
    String? sortOrder,
  }) async {
    try {
      final res = await _dioClient.dio.get(
        Endpoints.customerSegments,
        queryParameters: {
          'page': page,
          'pageSize': pageSize,
          if (search != null && search.isNotEmpty) 'search': search,
          if (sortBy != null && sortBy.isNotEmpty) 'sortBy': sortBy,
          if (sortOrder != null && sortOrder.isNotEmpty) 'sortOrder': sortOrder,
        },
      );
      return CustomerSegmentListResponse.fromJson(
          res.data as Map<String, dynamic>);
    } catch (e) {
      debugPrint('CustomerSegmentApi.getSegments error: $e');
      rethrow;
    }
  }

  Future<CustomerSegmentDto> getSegmentById(String id) async {
    try {
      final res =
          await _dioClient.dio.get(Endpoints.customerSegmentById(id));
      return CustomerSegmentDto.fromJson(res.data as Map<String, dynamic>);
    } catch (e) {
      debugPrint('CustomerSegmentApi.getSegmentById error: $e');
      rethrow;
    }
  }

  Future<CustomerSegmentDto> createSegment(
      Map<String, dynamic> body) async {
    try {
      final res = await _dioClient.dio.post(
        Endpoints.customerSegments,
        data: body,
      );
      return CustomerSegmentDto.fromJson(res.data as Map<String, dynamic>);
    } catch (e) {
      debugPrint('CustomerSegmentApi.createSegment error: $e');
      rethrow;
    }
  }

  Future<CustomerSegmentDto> updateSegment(
      String id, Map<String, dynamic> body) async {
    try {
      final res = await _dioClient.dio.patch(
        Endpoints.customerSegmentById(id),
        data: body,
      );
      return CustomerSegmentDto.fromJson(res.data as Map<String, dynamic>);
    } catch (e) {
      debugPrint('CustomerSegmentApi.updateSegment error: $e');
      rethrow;
    }
  }

  Future<void> deleteSegment(String id) async {
    try {
      await _dioClient.dio.delete(Endpoints.customerSegmentById(id));
    } catch (e) {
      debugPrint('CustomerSegmentApi.deleteSegment error: $e');
      rethrow;
    }
  }

  Future<CustomerSegmentMemberListResponse> getMembers(
    String id, {
    int page = 1,
    int pageSize = 20,
  }) async {
    try {
      final res = await _dioClient.dio.get(
        Endpoints.customerSegmentMembers(id),
        queryParameters: {'page': page, 'pageSize': pageSize},
      );
      return CustomerSegmentMemberListResponse.fromJson(
          res.data as Map<String, dynamic>);
    } catch (e) {
      debugPrint('CustomerSegmentApi.getMembers error: $e');
      rethrow;
    }
  }

  Future<void> addMembers(String id, List<String> customerIds) async {
    try {
      await _dioClient.dio.post(
        Endpoints.customerSegmentMembers(id),
        data: {'customerIds': customerIds},
      );
    } catch (e) {
      debugPrint('CustomerSegmentApi.addMembers error: $e');
      rethrow;
    }
  }

  Future<void> removeMembers(String id, List<String> customerIds) async {
    try {
      await _dioClient.dio.delete(
        Endpoints.customerSegmentMembers(id),
        data: {'customerIds': customerIds},
      );
    } catch (e) {
      debugPrint('CustomerSegmentApi.removeMembers error: $e');
      rethrow;
    }
  }
}
