import 'package:mobile_ai_erp/core/domain/usecase/use_case.dart';
import 'package:mobile_ai_erp/domain/entity/product/product.dart';
import 'package:mobile_ai_erp/domain/entity/shared/paginated_result.dart';
import 'package:mobile_ai_erp/domain/repository/product/product_management_repository.dart';

class GetProductsUseCase
    extends UseCase<PaginatedResult<Product>, GetProductsParams> {
  final ProductManagementRepository _repository;

  GetProductsUseCase(this._repository);

  @override
  Future<PaginatedResult<Product>> call({required GetProductsParams params}) {
    return _repository.getProductsPage(
      page: params.page,
      pageSize: params.pageSize,
    );
  }
}

class GetProductsParams {
  const GetProductsParams({
    this.page = 1,
    this.pageSize = 10,
  });

  final int page;
  final int pageSize;
}
