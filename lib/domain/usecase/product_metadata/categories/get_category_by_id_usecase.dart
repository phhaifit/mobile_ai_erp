import 'package:mobile_ai_erp/core/domain/usecase/use_case.dart';
import 'package:mobile_ai_erp/domain/entity/product_metadata/category.dart';
import 'package:mobile_ai_erp/domain/repository/product_metadata/product_metadata_repository.dart';

class GetCategoryByIdUseCase extends UseCase<Category, String> {
  final ProductMetadataRepository _repository;

  GetCategoryByIdUseCase(this._repository);

  @override
  Future<Category> call({required String params}) {
    return _repository.getCategoryById(params);
  }
}
