import 'package:mobile_ai_erp/core/domain/usecase/use_case.dart';
import 'package:mobile_ai_erp/domain/entity/product_metadata/attribute.dart';
import 'package:mobile_ai_erp/domain/repository/product_metadata/product_metadata_repository.dart';

class UpdateAttributeSetUseCase extends UseCase<AttributeSet, AttributeSet> {
  final ProductMetadataRepository _repository;

  UpdateAttributeSetUseCase(this._repository);

  @override
  Future<AttributeSet> call({required AttributeSet params}) {
    return _repository.saveAttributeSet(params);
  }
}
