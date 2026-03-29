import 'package:mobile_ai_erp/core/domain/usecase/use_case.dart';
import 'package:mobile_ai_erp/domain/entity/post_purchase/refund_request.dart';
import 'package:mobile_ai_erp/domain/repository/post_purchase/post_purchase_repository.dart';

class GetRefundDetailUseCase extends UseCase<RefundRequest?, String> {
  GetRefundDetailUseCase(this._repository);

  final PostPurchaseRepository _repository;

  @override
  Future<RefundRequest?> call({required params}) {
    return _repository.getRefundById(params);
  }
}
