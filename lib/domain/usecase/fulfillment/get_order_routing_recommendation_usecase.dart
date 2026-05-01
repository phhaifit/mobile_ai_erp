import 'package:mobile_ai_erp/core/domain/usecase/use_case.dart';
import 'package:mobile_ai_erp/domain/entity/fulfillment/shipment_tracking.dart';
import 'package:mobile_ai_erp/domain/repository/fulfillment/fulfillment_repository.dart';

class GetOrderRoutingRecommendationParams {
  final String orderId;
  final bool forceNew;

  GetOrderRoutingRecommendationParams({
    required this.orderId,
    this.forceNew = false,
  });
}

class GetOrderRoutingRecommendationUseCase
    extends UseCase<OrderRoutingRecommendation?, GetOrderRoutingRecommendationParams> {
  final FulfillmentRepository _repository;

  GetOrderRoutingRecommendationUseCase(this._repository);

  @override
  Future<OrderRoutingRecommendation?> call({
    required GetOrderRoutingRecommendationParams params,
  }) {
    return _repository.getOrderRoutingRecommendation(
      params.orderId,
      forceNew: params.forceNew,
    );
  }
}
