import 'package:mobile_ai_erp/core/domain/usecase/use_case.dart';
import 'package:mobile_ai_erp/domain/entity/product_metadata/category.dart';
import 'package:mobile_ai_erp/domain/repository/product_metadata/product_metadata_repository.dart';

class GetCategoryTreeUseCase extends UseCase<List<Category>, void> {
  final ProductMetadataRepository _repository;

  GetCategoryTreeUseCase(this._repository);

  @override
  Future<List<Category>> call({required params}) {
    return _repository.getCategoryTree();
  }
}
