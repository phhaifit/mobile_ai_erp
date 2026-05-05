import '../../../core/domain/usecase/use_case.dart';
import 'package:mobile_ai_erp/domain/repository/storefront_account/order_repository.dart';

class ReorderUseCase extends UseCase<Map<String, dynamic>, String> {
  final StorefrontOrderRepository _repository;

  ReorderUseCase(this._repository);

  @override
  Future<Map<String, dynamic>> call({required String params}) {
    return _repository.reorder(params); // params is the orderId
  }
}