import 'package:mobile_ai_erp/core/domain/usecase/use_case.dart';
import 'package:mobile_ai_erp/domain/entity/order_tracking/order_tracking_scenario.dart';
import 'package:mobile_ai_erp/domain/repository/order_tracking/order_tracking_repository.dart';

class GetOrderTrackingScenariosUseCase
    extends UseCase<List<OrderTrackingScenario>, DateTime?> {
  final OrderTrackingRepository _orderTrackingRepository;

  GetOrderTrackingScenariosUseCase(this._orderTrackingRepository);

  @override
  List<OrderTrackingScenario> call({required DateTime? params}) {
    return _orderTrackingRepository.getScenarios(now: params);
  }
}
