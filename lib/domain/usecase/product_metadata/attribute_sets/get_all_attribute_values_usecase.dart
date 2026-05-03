import 'package:mobile_ai_erp/core/domain/usecase/use_case.dart';
import 'package:mobile_ai_erp/domain/entity/product_metadata/attribute.dart';
import 'package:mobile_ai_erp/domain/repository/product_metadata/product_metadata_repository.dart';

class GetAllAttributeValuesUseCase extends UseCase<List<AttributeValue>, void> {
  final ProductMetadataRepository _repository;

  GetAllAttributeValuesUseCase(this._repository);

  @override
  Future<List<AttributeValue>> call({required void params}) {
    return _repository.getAllAttributeValues();
  }
}
