import 'package:mobile_ai_erp/core/domain/usecase/use_case.dart';
import 'package:mobile_ai_erp/domain/repository/product_metadata/product_metadata_repository.dart';

class DeleteAttributeValueParams {
  final String attributeSetId;
  final String valueId;

  DeleteAttributeValueParams({
    required this.attributeSetId,
    required this.valueId,
  });
}

class DeleteAttributeValueUseCase extends UseCase<void, DeleteAttributeValueParams> {
  final ProductMetadataRepository _repository;

  DeleteAttributeValueUseCase(this._repository);

  @override
  Future<void> call({required DeleteAttributeValueParams params}) {
    return _repository.deleteAttributeValue(params.attributeSetId, params.valueId);
  }
}
