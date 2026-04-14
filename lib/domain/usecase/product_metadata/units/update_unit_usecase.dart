import 'package:mobile_ai_erp/core/domain/usecase/use_case.dart';
import 'package:mobile_ai_erp/domain/entity/product_metadata/unit.dart';
import 'package:mobile_ai_erp/domain/repository/product_metadata/product_metadata_repository.dart';

class UpdateUnitUseCase extends UseCase<Unit, Unit> {
  final ProductMetadataRepository _repository;

  UpdateUnitUseCase(this._repository);

  @override
  Future<Unit> call({required Unit params}) {
    return _repository.saveUnit(params);
  }
}
