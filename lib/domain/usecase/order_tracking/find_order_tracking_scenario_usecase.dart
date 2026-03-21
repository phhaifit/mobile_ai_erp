import 'package:mobile_ai_erp/core/domain/usecase/use_case.dart';
import 'package:mobile_ai_erp/domain/entity/order_tracking/order_tracking_scenario.dart';
import 'package:mobile_ai_erp/domain/repository/order_tracking/order_tracking_repository.dart';

class FindOrderTrackingScenarioParams {
  FindOrderTrackingScenarioParams({
    required this.scenarios,
    required this.orderId,
  });

  final List<OrderTrackingScenario> scenarios;
  final String orderId;
}

class FindOrderTrackingScenarioUseCase
    extends UseCase<OrderTrackingScenario?, FindOrderTrackingScenarioParams> {
  final OrderTrackingRepository _orderTrackingRepository;

  FindOrderTrackingScenarioUseCase(this._orderTrackingRepository);

  @override
  OrderTrackingScenario? call({
    required FindOrderTrackingScenarioParams params,
  }) {
    return _orderTrackingRepository.findByOrderId(
      params.scenarios,
      params.orderId,
    );
  }
}
