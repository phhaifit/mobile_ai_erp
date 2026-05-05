import '../../repository/storefront_account/loyalty_ledger_repository.dart';
import '../../entity/loyalty_ledgers/loyalty_ledger.dart';

class GetLoyaltyHistoryUseCase {
  final LoyaltyLedgerRepository _repository;

  GetLoyaltyHistoryUseCase(this._repository);

  Future<List<LoyaltyLedger>> call({required Map<String, dynamic> params}) async {
    final page = params['page'] ?? 1;
    final pageSize = params['pageSize'] ?? 20;
    return await _repository.getHistory(page: page, pageSize: pageSize);
  }
}