import 'package:mobile_ai_erp/core/domain/usecase/use_case.dart';
import 'package:mobile_ai_erp/domain/repository/post_purchase/post_purchase_repository.dart';

class ConvertExchangeToRefundUseCase extends UseCase<void, String> {
  final PostPurchaseRepository _repository;

  ConvertExchangeToRefundUseCase(this._repository);

  @override
  Future<void> call({required params}) {
    return _repository.convertExchangeToRefund(params);
  }
}
