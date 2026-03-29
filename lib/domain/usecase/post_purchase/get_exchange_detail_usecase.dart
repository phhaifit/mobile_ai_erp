import 'package:mobile_ai_erp/core/domain/usecase/use_case.dart';
import 'package:mobile_ai_erp/domain/entity/post_purchase/exchange_request.dart';
import 'package:mobile_ai_erp/domain/repository/post_purchase/post_purchase_repository.dart';

class GetExchangeDetailUseCase extends UseCase<ExchangeRequest?, String> {
  GetExchangeDetailUseCase(this._repository);

  final PostPurchaseRepository _repository;

  @override
  Future<ExchangeRequest?> call({required params}) {
    return _repository.getExchangeById(params);
  }
}
