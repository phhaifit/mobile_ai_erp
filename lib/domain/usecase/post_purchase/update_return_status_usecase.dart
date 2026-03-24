import 'package:mobile_ai_erp/core/domain/usecase/use_case.dart';
import 'package:mobile_ai_erp/domain/entity/post_purchase/return_exchange_request.dart';
import 'package:mobile_ai_erp/domain/repository/post_purchase/post_purchase_repository.dart';

class UpdateReturnStatusParams {
  UpdateReturnStatusParams({required this.id, required this.status});

  final String id;
  final ReturnStatus status;
}

class UpdateReturnStatusUseCase
    extends UseCase<void, UpdateReturnStatusParams> {
  final PostPurchaseRepository _repository;

  UpdateReturnStatusUseCase(this._repository);

  @override
  Future<void> call({required params}) {
    return _repository.updateReturnStatus(params.id, params.status);
  }
}
