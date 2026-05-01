import 'package:mobile_ai_erp/core/domain/usecase/use_case.dart';
import 'package:mobile_ai_erp/domain/entity/product_metadata/attribute.dart';
import 'package:mobile_ai_erp/domain/repository/product_metadata/product_metadata_repository.dart';

class GetAttributeValuesUseCase extends UseCase<List<AttributeValue>, String> {
  final ProductMetadataRepository _repository;

  GetAttributeValuesUseCase(this._repository);

  @override
  Future<List<AttributeValue>> call({required String params}) {
    return _repository.getAttributeValues(params);
  }
}
