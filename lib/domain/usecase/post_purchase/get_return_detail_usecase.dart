import 'package:mobile_ai_erp/core/domain/usecase/use_case.dart';
import 'package:mobile_ai_erp/domain/entity/post_purchase/return_exchange_request.dart';
import 'package:mobile_ai_erp/domain/repository/post_purchase/post_purchase_repository.dart';

class GetReturnDetailUseCase extends UseCase<ReturnExchangeRequest?, String> {
  final PostPurchaseRepository _repository;

  GetReturnDetailUseCase(this._repository);

  @override
  Future<ReturnExchangeRequest?> call({required params}) {
    return _repository.getReturnById(params);
  }
}
