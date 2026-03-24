import 'package:mobile_ai_erp/core/domain/usecase/use_case.dart';
import 'package:mobile_ai_erp/domain/repository/post_purchase/post_purchase_repository.dart';

class UpdateReturnNotesParams {
  UpdateReturnNotesParams({required this.id, required this.notes});

  final String id;
  final String notes;
}

class UpdateReturnNotesUseCase extends UseCase<void, UpdateReturnNotesParams> {
  final PostPurchaseRepository _repository;

  UpdateReturnNotesUseCase(this._repository);

  @override
  Future<void> call({required params}) {
    return _repository.updateReturnNotes(params.id, params.notes);
  }
}
