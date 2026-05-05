import 'package:mobx/mobx.dart';
import '../../../domain/entity/loyalty_ledgers/loyalty_ledger.dart';
import '../../../domain/usecase/loyalty_ledgers/get_loyalty_balance_usecase.dart';
import '../../../domain/usecase/loyalty_ledgers/get_loyalty_history_usecase.dart';

part 'loyalty_store.g.dart';

class LoyaltyStore = _LoyaltyStore with _$LoyaltyStore;

abstract class _LoyaltyStore with Store {
  final GetLoyaltyBalanceUseCase _getBalance;
  final GetLoyaltyHistoryUseCase _getHistory;

  _LoyaltyStore(this._getBalance, this._getHistory);

  @observable
  int balance = 0;

  @observable
  ObservableList<LoyaltyLedger> history = ObservableList<LoyaltyLedger>();

  @observable
  bool isLoading = false;

  @observable
  bool hasReachedMax = false;

  @action
  Future<void> fetchBalance() async {
    try {
      final newBalance = await _getBalance.call();
      balance = newBalance;
    } catch (e) {
      print('❌ [LoyaltyStore.fetchBalance] Error: $e');
    }
  }

  @action
  Future<void> fetchHistory({int page = 1, int pageSize = 20}) async {
    try {
      if (page == 1) {
        isLoading = true;
        history.clear();
        hasReachedMax = false;
      }

      final data = await _getHistory.call(
        params: {'page': page, 'pageSize': pageSize},
      );

      if (data.isEmpty || data.length < pageSize) {
        hasReachedMax = true;
      }

      history.addAll(data);
    } catch (e) {
      print('❌ [LoyaltyStore.fetchHistory] Error: $e');
    } finally {
      isLoading = false;
    }
  }
}