import 'package:mobile_ai_erp/core/domain/usecase/use_case.dart';
import 'package:mobile_ai_erp/domain/entity/product_metadata/brand_image.dart';
import 'package:mobile_ai_erp/domain/repository/product_metadata/product_metadata_repository.dart';

class UploadBrandImageUseCase
    extends UseCase<BrandImage, UploadBrandImageParams> {
  final ProductMetadataRepository _repository;

  UploadBrandImageUseCase(this._repository);

  @override
  Future<BrandImage> call({required UploadBrandImageParams params}) {
    return _repository.uploadBrandImage(params.brandId, params.file);
  }
}

class UploadBrandImageParams {
  const UploadBrandImageParams({required this.brandId, required this.file});

  final String brandId;
  final dynamic file;
}
