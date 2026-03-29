import 'package:mobile_ai_erp/core/domain/usecase/use_case.dart';
import 'package:mobile_ai_erp/domain/repository/post_purchase/post_purchase_repository.dart';

class UpdateRefundNotesParams {
  UpdateRefundNotesParams({required this.id, required this.notes});

  final String id;
  final String notes;
}

class UpdateRefundNotesUseCase extends UseCase<void, UpdateRefundNotesParams> {
  UpdateRefundNotesUseCase(this._repository);

  final PostPurchaseRepository _repository;

  @override
  Future<void> call({required params}) {
    return _repository.updateRefundNotes(params.id, params.notes);
  }
}
