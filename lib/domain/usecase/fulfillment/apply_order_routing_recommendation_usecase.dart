import 'package:mobile_ai_erp/core/domain/usecase/use_case.dart';
import 'package:mobile_ai_erp/domain/entity/fulfillment/shipment_tracking.dart';
import 'package:mobile_ai_erp/domain/repository/fulfillment/fulfillment_repository.dart';

class ApplyOrderRoutingRecommendationParams {
  final String orderId;
  final String decisionId;
  final String? selectedOptionId;

  ApplyOrderRoutingRecommendationParams({
    required this.orderId,
    required this.decisionId,
    this.selectedOptionId,
  });
}

class ApplyOrderRoutingRecommendationUseCase
    extends UseCase<OrderRoutingApplyResult, ApplyOrderRoutingRecommendationParams> {
  final FulfillmentRepository _repository;

  ApplyOrderRoutingRecommendationUseCase(this._repository);

  @override
  Future<OrderRoutingApplyResult> call({
    required ApplyOrderRoutingRecommendationParams params,
  }) {
    return _repository.applyOrderRoutingRecommendation(
      params.orderId,
      decisionId: params.decisionId,
      selectedOptionId: params.selectedOptionId,
    );
  }
}
