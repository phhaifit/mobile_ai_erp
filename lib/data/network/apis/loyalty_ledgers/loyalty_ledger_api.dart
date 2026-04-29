import 'dart:async';
import 'package:mobile_ai_erp/core/data/network/dio/dio_client.dart';
import 'package:mobile_ai_erp/data/network/constants/endpoints.dart';

class LoyaltyLedgerApi {
  final DioClient _dioClient;

  LoyaltyLedgerApi(this._dioClient);

  /// Get current loyalty point balance
  Future<Map<String, dynamic>> getBalance() async {
    try {
      // Assuming you add this to your Endpoints file, otherwise use the string:
      // '/storefront/account/loyalty-points/balance'
      final res = await _dioClient.dio.get(Endpoints.customerLoyalty + '/balance');
      return res.data;
    } catch (e) {
      print('❌ [LoyaltyLedgerApi.getBalance] Error: $e');
      rethrow;
    }
  }

  /// Get paginated loyalty point history
  Future<Map<String, dynamic>> getHistory(int page, int pageSize) async {
    try {
      // Assuming: Endpoints.customerLoyalty + '/history'
      final res = await _dioClient.dio.get(
        Endpoints.customerLoyalty + '/history',
        queryParameters: {
          'page': page,
          'pageSize': pageSize,
        },
      );
      return res.data;
    } catch (e) {
      print('❌ [LoyaltyLedgerApi.getHistory] Error: $e');
      rethrow;
    }
  }
}