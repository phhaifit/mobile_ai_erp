import 'package:mobile_ai_erp/core/domain/usecase/use_case.dart';
import 'package:mobile_ai_erp/domain/entity/product_metadata/tag.dart';
import 'package:mobile_ai_erp/domain/repository/product_metadata/product_metadata_repository.dart';

class GetTagByIdUseCase extends UseCase<Tag, String> {
  final ProductMetadataRepository _repository;

  GetTagByIdUseCase(this._repository);

  @override
  Future<Tag> call({required String params}) {
    return _repository.getTagById(params);
  }
}
