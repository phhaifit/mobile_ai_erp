import 'package:mobile_ai_erp/core/domain/usecase/use_case.dart';
import 'package:mobile_ai_erp/domain/entity/product_metadata/brand.dart';
import 'package:mobile_ai_erp/domain/repository/product_metadata/product_metadata_repository.dart';

class CreateBrandUseCase extends UseCase<Brand, Brand> {
  final ProductMetadataRepository _repository;

  CreateBrandUseCase(this._repository);

  @override
  Future<Brand> call({required Brand params}) {
    return _repository.saveBrand(params);
  }
}
