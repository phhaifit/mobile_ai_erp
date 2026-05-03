import 'package:mobile_ai_erp/core/domain/usecase/use_case.dart';
import 'package:mobile_ai_erp/domain/entity/product_metadata/category.dart';
import 'package:mobile_ai_erp/domain/repository/product_metadata/product_metadata_repository.dart';

class CreateCategoryUseCase extends UseCase<Category, Category> {
  final ProductMetadataRepository _repository;

  CreateCategoryUseCase(this._repository);

  @override
  Future<Category> call({required Category params}) {
    return _repository.saveCategory(params);
  }
}
