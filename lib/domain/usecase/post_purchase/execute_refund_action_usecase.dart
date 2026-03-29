import 'package:mobile_ai_erp/core/domain/usecase/use_case.dart';
import 'package:mobile_ai_erp/domain/entity/post_purchase/refund_request.dart';
import 'package:mobile_ai_erp/domain/repository/post_purchase/post_purchase_repository.dart';

class ExecuteRefundActionParams {
  ExecuteRefundActionParams({required this.id, required this.action});

  final String id;
  final RefundAction action;
}

class ExecuteRefundActionUseCase
    extends UseCase<void, ExecuteRefundActionParams> {
  ExecuteRefundActionUseCase(this._repository);

  final PostPurchaseRepository _repository;

  @override
  Future<void> call({required params}) {
    return _repository.executeRefundAction(params.id, params.action);
  }
}
