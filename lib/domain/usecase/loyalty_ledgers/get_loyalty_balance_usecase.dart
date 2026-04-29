import '../../repository/account/loyalty_ledger_repository.dart';

class GetLoyaltyBalanceUseCase {
  final LoyaltyLedgerRepository _repository;

  GetLoyaltyBalanceUseCase(this._repository);

  Future<int> call() async {
    return await _repository.getBalance();
  }
}