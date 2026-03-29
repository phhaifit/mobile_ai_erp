import 'package:mobile_ai_erp/core/domain/usecase/use_case.dart';
import 'package:mobile_ai_erp/domain/entity/post_purchase/exchange_request.dart';
import 'package:mobile_ai_erp/domain/repository/post_purchase/post_purchase_repository.dart';

class ExecuteExchangeActionParams {
  ExecuteExchangeActionParams({required this.id, required this.action});

  final String id;
  final ExchangeAction action;
}

class ExecuteExchangeActionUseCase
    extends UseCase<void, ExecuteExchangeActionParams> {
  ExecuteExchangeActionUseCase(this._repository);

  final PostPurchaseRepository _repository;

  @override
  Future<void> call({required params}) {
    return _repository.executeExchangeAction(params.id, params.action);
  }
}
