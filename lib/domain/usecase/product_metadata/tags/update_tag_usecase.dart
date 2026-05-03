import 'package:mobile_ai_erp/core/domain/usecase/use_case.dart';
import 'package:mobile_ai_erp/domain/entity/product_metadata/tag.dart';
import 'package:mobile_ai_erp/domain/repository/product_metadata/product_metadata_repository.dart';

class UpdateTagUseCase extends UseCase<Tag, Tag> {
  final ProductMetadataRepository _repository;

  UpdateTagUseCase(this._repository);

  @override
  Future<Tag> call({required Tag params}) {
    return _repository.saveTag(params);
  }
}
