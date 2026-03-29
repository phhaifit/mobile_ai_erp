import 'package:mobile_ai_erp/core/domain/usecase/use_case.dart';
import 'package:mobile_ai_erp/domain/repository/post_purchase/post_purchase_repository.dart';

class UpdateIssueNotesParams {
  UpdateIssueNotesParams({required this.id, required this.notes});

  final String id;
  final String notes;
}

class UpdateIssueNotesUseCase extends UseCase<void, UpdateIssueNotesParams> {
  final PostPurchaseRepository _repository;

  UpdateIssueNotesUseCase(this._repository);

  @override
  Future<void> call({required params}) {
    return _repository.updateIssueNotes(params.id, params.notes);
  }
}
