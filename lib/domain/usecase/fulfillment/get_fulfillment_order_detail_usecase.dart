import 'package:mobile_ai_erp/core/domain/usecase/use_case.dart';
import 'package:mobile_ai_erp/domain/entity/fulfillment/fulfillment_order.dart';
import 'package:mobile_ai_erp/domain/repository/fulfillment/fulfillment_repository.dart';

class GetFulfillmentOrderDetailUseCase
    extends UseCase<FulfillmentOrder?, String> {
  final FulfillmentRepository _repository;

  GetFulfillmentOrderDetailUseCase(this._repository);

  @override
  Future<FulfillmentOrder?> call({required String params}) {
    return _repository.getOrderById(params);
  }
}
