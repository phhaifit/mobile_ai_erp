import 'package:mobile_ai_erp/core/domain/usecase/use_case.dart';
import 'package:mobile_ai_erp/domain/entity/product_metadata/attribute.dart';
import 'package:mobile_ai_erp/domain/repository/product_metadata/product_metadata_repository.dart';

class CreateAttributeValueUseCase extends UseCase<AttributeValue, AttributeValue> {
  final ProductMetadataRepository _repository;

  CreateAttributeValueUseCase(this._repository);

  @override
  Future<AttributeValue> call({required AttributeValue params}) {
    return _repository.saveAttributeValue(params);
  }
}
