import 'package:mobile_ai_erp/core/domain/usecase/use_case.dart';
import 'package:mobile_ai_erp/domain/entity/product_metadata/attribute.dart';
import 'package:mobile_ai_erp/domain/repository/product_metadata/product_metadata_repository.dart';

class GetAttributeSetByIdUseCase extends UseCase<AttributeSet, String> {
  final ProductMetadataRepository _repository;

  GetAttributeSetByIdUseCase(this._repository);

  @override
  Future<AttributeSet> call({required String params}) {
    return _repository.getAttributeSetById(params);
  }
}
