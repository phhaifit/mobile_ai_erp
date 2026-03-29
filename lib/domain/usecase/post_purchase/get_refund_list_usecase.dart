import 'package:mobile_ai_erp/core/domain/usecase/use_case.dart';
import 'package:mobile_ai_erp/domain/entity/post_purchase/refund_request.dart';
import 'package:mobile_ai_erp/domain/repository/post_purchase/post_purchase_repository.dart';

class GetRefundListUseCase extends UseCase<List<RefundRequest>, void> {
  GetRefundListUseCase(this._repository);

  final PostPurchaseRepository _repository;

  @override
  Future<List<RefundRequest>> call({required params}) {
    return _repository.getRefunds();
  }
}
