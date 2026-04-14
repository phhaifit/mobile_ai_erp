import 'package:mobile_ai_erp/core/domain/usecase/use_case.dart';
import 'package:mobile_ai_erp/domain/entity/product_metadata/metadata_page.dart';
import 'package:mobile_ai_erp/domain/entity/product_metadata/unit.dart';
import 'package:mobile_ai_erp/domain/repository/product_metadata/product_metadata_repository.dart';

class GetUnitsUseCase extends UseCase<MetadataPage<Unit>, GetUnitsParams> {
  final ProductMetadataRepository _repository;

  GetUnitsUseCase(this._repository);

  @override
  Future<MetadataPage<Unit>> call({required GetUnitsParams params}) {
    return _repository.getUnits(
      page: params.page,
      pageSize: params.pageSize,
      search: params.search,
      includeInactive: params.includeInactive,
      sortBy: params.sortBy,
      sortOrder: params.sortOrder,
    );
  }
}

class GetUnitsParams {
  const GetUnitsParams({
    this.page = 1,
    this.pageSize = 10,
    this.search,
    this.includeInactive = false,
    this.sortBy,
    this.sortOrder,
  });

  final int page;
  final int pageSize;
  final String? search;
  final bool includeInactive;
  final String? sortBy;
  final String? sortOrder;
}
