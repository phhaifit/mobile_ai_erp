import 'package:mobile_ai_erp/core/domain/usecase/use_case.dart';
import 'package:mobile_ai_erp/domain/entity/product_metadata/attribute.dart';
import 'package:mobile_ai_erp/domain/entity/product_metadata/metadata_page.dart';
import 'package:mobile_ai_erp/domain/repository/product_metadata/product_metadata_repository.dart';

class GetAttributeSetsUseCase
    extends UseCase<MetadataPage<AttributeSet>, GetAttributeSetsParams> {
  final ProductMetadataRepository _repository;

  GetAttributeSetsUseCase(this._repository);

  @override
  Future<MetadataPage<AttributeSet>> call({
    required GetAttributeSetsParams params,
  }) {
    return _repository.getAttributeSets(
      page: params.page,
      pageSize: params.pageSize,
      search: params.search,
      sortBy: params.sortBy,
      sortOrder: params.sortOrder,
    );
  }
}

class GetAttributeSetsParams {
  const GetAttributeSetsParams({
    this.page = 1,
    this.pageSize = 10,
    this.search,
    this.sortBy,
    this.sortOrder,
  });

  final int page;
  final int pageSize;
  final String? search;
  final String? sortBy;
  final String? sortOrder;
}
