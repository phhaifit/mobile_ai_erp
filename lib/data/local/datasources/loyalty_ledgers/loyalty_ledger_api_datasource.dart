import 'dart:async';
import 'package:mobile_ai_erp/data/network/apis/loyalty_ledgers/loyalty_ledger_api.dart';

abstract class LoyaltyLedgerDataSource {
  Future<int> getBalance();
  Future<List<dynamic>> getHistory({required int page, required int pageSize});
}

class LoyaltyLedgerApiDataSource implements LoyaltyLedgerDataSource {
  final LoyaltyLedgerApi _loyaltyLedgerApi;

  LoyaltyLedgerApiDataSource(this._loyaltyLedgerApi);

  @override
  Future<int> getBalance() async {
    try {
      final response = await _loyaltyLedgerApi.getBalance();
      return response['balance'] as int;
    } catch (e) {
      print('❌ [LoyaltyLedgerApiDataSource.getBalance] Error: $e');
      rethrow;
    }
  }

  @override
  Future<List<dynamic>> getHistory({required int page, required int pageSize}) async {
    try {
      final response = await _loyaltyLedgerApi.getHistory(page, pageSize);
      return response['data'] as List<dynamic>;
    } catch (e) {
      print('❌ [LoyaltyLedgerApiDataSource.getHistory] Error: $e');
      rethrow;
    }
  }
}