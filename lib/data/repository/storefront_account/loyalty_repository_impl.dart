import '../../../domain/entity/loyalty_ledgers/loyalty_ledger.dart';
import '../../../domain/repository/account/loyalty_ledger_repository.dart';
import '../../local/datasources/loyalty_ledgers/loyalty_ledger_api_datasource.dart';

class LoyaltyRepositoryImpl implements LoyaltyLedgerRepository {
  final LoyaltyLedgerDataSource _dataSource;

  LoyaltyRepositoryImpl(this._dataSource);

  @override
  Future<int> getBalance() async {
    return await _dataSource.getBalance();
  }

  @override
  Future<List<LoyaltyLedger>> getHistory({int page = 1, int pageSize = 20}) async {
    final rawData = await _dataSource.getHistory(page: page, pageSize: pageSize);
    return rawData.map((json) => LoyaltyLedger.fromJson(json)).toList();
  }
}