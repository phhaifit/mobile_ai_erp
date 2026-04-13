import 'package:mobile_ai_erp/core/domain/usecase/use_case.dart';
import 'package:mobile_ai_erp/domain/entity/product_metadata/brand.dart';
import 'package:mobile_ai_erp/domain/entity/product_metadata/metadata_page.dart';
import 'package:mobile_ai_erp/domain/repository/product_metadata/product_metadata_repository.dart';

class GetBrandsUseCase
    extends UseCase<MetadataPage<Brand>, GetBrandsParams> {
  final ProductMetadataRepository _repository;

  GetBrandsUseCase(this._repository);

  @override
  Future<MetadataPage<Brand>> call({required GetBrandsParams params}) {
    return _repository.getBrands(
      page: params.page,
      pageSize: params.pageSize,
      search: params.search,
      includeInactive: params.includeInactive,
    );
  }
}

class GetBrandsParams {
  const GetBrandsParams({
    this.page = 1,
    this.pageSize = 20,
    this.search,
    this.includeInactive = false,
  });

  final int page;
  final int pageSize;
  final String? search;
  final bool includeInactive;
}
