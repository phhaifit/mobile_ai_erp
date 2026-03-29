import 'package:mobile_ai_erp/core/domain/usecase/use_case.dart';
import 'package:mobile_ai_erp/domain/entity/post_purchase/order_complaint_candidate.dart';
import 'package:mobile_ai_erp/domain/repository/post_purchase/post_purchase_repository.dart';

class GetOrderPoolUseCase extends UseCase<List<OrderComplaintCandidate>, void> {
  GetOrderPoolUseCase(this._repository);

  final PostPurchaseRepository _repository;

  @override
  Future<List<OrderComplaintCandidate>> call({required params}) {
    return _repository.getOrderPool();
  }
}
