import 'package:mobile_ai_erp/domain/entity/order_tracking/order_tracking_scenario.dart';

abstract class OrderTrackingRepository {
  List<OrderTrackingScenario> getScenarios({DateTime? now});

  OrderTrackingScenario? findByOrderId(
    List<OrderTrackingScenario> scenarios,
    String orderId,
  );
}
