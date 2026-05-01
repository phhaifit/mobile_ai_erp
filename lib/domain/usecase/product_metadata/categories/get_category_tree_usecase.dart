import 'package:mobile_ai_erp/core/domain/usecase/use_case.dart';
import 'package:mobile_ai_erp/domain/entity/product_metadata/category.dart';
import 'package:mobile_ai_erp/domain/repository/product_metadata/product_metadata_repository.dart';

class GetCategoryTreeUseCase
    extends UseCase<List<Category>, GetCategoryTreeParams> {
  GetCategoryTreeUseCase(this._repository);

  final ProductMetadataRepository _repository;

  @override
  Future<List<Category>> call({required GetCategoryTreeParams params}) {
    return _repository.getCategoryTree(status: params.status);
  }
}

class GetCategoryTreeParams {
  const GetCategoryTreeParams({this.status});

  final CategoryStatus? status;
}
