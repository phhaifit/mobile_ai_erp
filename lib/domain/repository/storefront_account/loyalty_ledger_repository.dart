import '../../entity/loyalty_ledgers/loyalty_ledger.dart';

abstract class LoyaltyLedgerRepository {
  Future<int> getBalance();
  Future<List<LoyaltyLedger>> getHistory({int page = 1, int pageSize = 20});
}