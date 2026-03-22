import 'package:mobile_ai_erp/data/local/datasources/order_tracking/order_tracking_datasource.dart';
import 'package:mobile_ai_erp/domain/entity/order_tracking/order_tracking_scenario.dart';
import 'package:mobile_ai_erp/domain/repository/order_tracking/order_tracking_repository.dart';

class OrderTrackingRepositoryImpl extends OrderTrackingRepository {
  OrderTrackingRepositoryImpl(this._dataSource);

  final OrderTrackingDataSource _dataSource;

  @override
  List<OrderTrackingScenario> getScenarios({DateTime? now}) {
    return _dataSource.getScenarios(now: now);
  }

  @override
  OrderTrackingScenario? findByOrderId(
    List<OrderTrackingScenario> scenarios,
    String orderId,
  ) {
    return _dataSource.findByOrderId(scenarios, orderId);
  }
}
