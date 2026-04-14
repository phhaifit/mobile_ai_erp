import 'package:mobile_ai_erp/core/domain/usecase/use_case.dart';
import 'package:mobile_ai_erp/domain/entity/product_metadata/metadata_page.dart';
import 'package:mobile_ai_erp/domain/entity/product_metadata/tag.dart';
import 'package:mobile_ai_erp/domain/repository/product_metadata/product_metadata_repository.dart';

class GetTagsUseCase extends UseCase<MetadataPage<Tag>, GetTagsParams> {
  final ProductMetadataRepository _repository;

  GetTagsUseCase(this._repository);

  @override
  Future<MetadataPage<Tag>> call({required GetTagsParams params}) {
    return _repository.getTags(
      page: params.page,
      pageSize: params.pageSize,
      search: params.search,
      includeInactive: params.includeInactive,
      sortBy: params.sortBy,
      sortOrder: params.sortOrder,
    );
  }
}

class GetTagsParams {
  const GetTagsParams({
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
