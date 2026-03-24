import 'package:mobile_ai_erp/core/domain/usecase/use_case.dart';
import 'package:mobile_ai_erp/domain/entity/post_purchase/return_exchange_request.dart';
import 'package:mobile_ai_erp/domain/repository/post_purchase/post_purchase_repository.dart';

class GetReturnListUseCase extends UseCase<List<ReturnExchangeRequest>, void> {
  final PostPurchaseRepository _repository;

  GetReturnListUseCase(this._repository);

  @override
  Future<List<ReturnExchangeRequest>> call({required params}) {
    return _repository.getReturns();
  }
}
