import 'package:mobile_ai_erp/core/domain/usecase/use_case.dart';
import 'package:mobile_ai_erp/domain/entity/product_metadata/category.dart';
import 'package:mobile_ai_erp/domain/entity/product_metadata/metadata_page.dart';
import 'package:mobile_ai_erp/domain/repository/product_metadata/product_metadata_repository.dart';

class GetCategoriesUseCase extends UseCase<MetadataPage<Category>, GetCategoriesParams> {
  final ProductMetadataRepository _repository;

  GetCategoriesUseCase(this._repository);

  @override
  Future<MetadataPage<Category>> call({required GetCategoriesParams params}) {
    return _repository.getCategories(
      page: params.page,
      pageSize: params.pageSize,
      search: params.search,
      sortBy: params.sortBy,
      sortOrder: params.sortOrder,
      status: params.status,
    );
  }
}

class GetCategoriesParams {
  final int page;
  final int pageSize;
  final String? search;
  final String? sortBy;
  final String? sortOrder;
  final CategoryStatus? status;

  GetCategoriesParams({
    this.page = 1,
    this.pageSize = 10,
    this.search,
    this.sortBy,
    this.sortOrder,
    this.status,
  });
}
