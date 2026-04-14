import 'package:mobile_ai_erp/core/domain/usecase/use_case.dart';
import 'package:mobile_ai_erp/domain/entity/product_metadata/unit.dart';
import 'package:mobile_ai_erp/domain/repository/product_metadata/product_metadata_repository.dart';

class GetUnitByIdUseCase extends UseCase<Unit, String> {
  final ProductMetadataRepository _repository;

  GetUnitByIdUseCase(this._repository);

  @override
  Future<Unit> call({required String params}) {
    return _repository.getUnitById(params);
  }
}
