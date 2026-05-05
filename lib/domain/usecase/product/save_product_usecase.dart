import 'package:mobile_ai_erp/core/domain/usecase/use_case.dart';
import 'package:mobile_ai_erp/domain/entity/product/product.dart';
import 'package:mobile_ai_erp/domain/repository/product/product_management_repository.dart';

/// Use case for saving a product (creating a new one or updating an existing one)
class SaveProductUseCase extends UseCase<Product, Product> {
  final ProductManagementRepository _repository;

  SaveProductUseCase(this._repository);

  @override
  Future<Product> call({required Product params}) {
    return _repository.saveProduct(params);
  }
}
