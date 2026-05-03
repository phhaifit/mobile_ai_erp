import 'package:mobile_ai_erp/core/domain/usecase/use_case.dart';
import 'package:mobile_ai_erp/domain/repository/product_metadata/product_metadata_repository.dart';

class DeleteCategoryUseCase extends UseCase<void, String> {
  final ProductMetadataRepository _repository;

  DeleteCategoryUseCase(this._repository);

  @override
  Future<void> call({required String params}) {
    return _repository.deleteCategory(params);
  }
}
