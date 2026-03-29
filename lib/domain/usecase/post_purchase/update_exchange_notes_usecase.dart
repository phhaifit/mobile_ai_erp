import 'package:mobile_ai_erp/core/domain/usecase/use_case.dart';
import 'package:mobile_ai_erp/domain/repository/post_purchase/post_purchase_repository.dart';

class UpdateExchangeNotesParams {
  UpdateExchangeNotesParams({required this.id, required this.notes});

  final String id;
  final String notes;
}

class UpdateExchangeNotesUseCase
    extends UseCase<void, UpdateExchangeNotesParams> {
  UpdateExchangeNotesUseCase(this._repository);

  final PostPurchaseRepository _repository;

  @override
  Future<void> call({required params}) {
    return _repository.updateExchangeNotes(params.id, params.notes);
  }
}
