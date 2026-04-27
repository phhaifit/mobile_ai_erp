import 'package:mobile_ai_erp/core/domain/usecase/use_case.dart';
import 'package:mobile_ai_erp/domain/entity/product_metadata/brand_image.dart';
import 'package:mobile_ai_erp/domain/repository/product_metadata/product_metadata_repository.dart';

class GetBrandImageUseCase extends UseCase<BrandImage?, String> {
  final ProductMetadataRepository _repository;

  GetBrandImageUseCase(this._repository);

  @override
  Future<BrandImage?> call({required String params}) {
    return _repository.getBrandImage(params);
  }
}
