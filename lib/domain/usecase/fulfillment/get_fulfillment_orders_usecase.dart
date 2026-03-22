import 'package:mobile_ai_erp/core/domain/usecase/use_case.dart';
import 'package:mobile_ai_erp/domain/entity/fulfillment/fulfillment_order.dart';
import 'package:mobile_ai_erp/domain/repository/fulfillment/fulfillment_repository.dart';

class GetFulfillmentOrdersUseCase
    extends UseCase<List<FulfillmentOrder>, void> {
  final FulfillmentRepository _repository;

  GetFulfillmentOrdersUseCase(this._repository);

  @override
  Future<List<FulfillmentOrder>> call({required params}) {
    return _repository.getOrders();
  }
}
