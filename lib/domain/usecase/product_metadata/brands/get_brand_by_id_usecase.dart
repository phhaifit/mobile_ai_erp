import 'package:mobile_ai_erp/core/domain/usecase/use_case.dart';
import 'package:mobile_ai_erp/domain/entity/product_metadata/brand.dart';
import 'package:mobile_ai_erp/domain/repository/product_metadata/product_metadata_repository.dart';

class GetBrandByIdUseCase extends UseCase<Brand, String> {
  final ProductMetadataRepository _repository;

  GetBrandByIdUseCase(this._repository);

  @override
  Future<Brand> call({required String params}) {
    return _repository.getBrandById(params);
  }
}
