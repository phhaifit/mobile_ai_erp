import 'package:mobile_ai_erp/core/stores/error/error_store.dart';
import 'package:mobile_ai_erp/domain/entity/order_tracking/order_tracking_scenario.dart';
import 'package:mobile_ai_erp/domain/usecase/order_tracking/find_order_tracking_scenario_usecase.dart';
import 'package:mobile_ai_erp/domain/usecase/order_tracking/get_order_tracking_scenarios_usecase.dart';
import 'package:mobx/mobx.dart';

part 'order_tracking_store.g.dart';

class OrderTrackingStore = _OrderTrackingStore with _$OrderTrackingStore;

abstract class _OrderTrackingStore with Store {
  _OrderTrackingStore(
    this._getOrderTrackingScenariosUseCase,
    this._findOrderTrackingScenarioUseCase,
    this.errorStore,
  );

  final GetOrderTrackingScenariosUseCase _getOrderTrackingScenariosUseCase;
  final FindOrderTrackingScenarioUseCase _findOrderTrackingScenarioUseCase;
  final ErrorStore errorStore;

  @observable
  ObservableList<OrderTrackingScenario> scenarios =
      ObservableList<OrderTrackingScenario>();

  @observable
  OrderTrackingScenario? selectedScenario;

  @action
  void loadScenarios({DateTime? now}) {
    final String? previousSelectedOrderId = selectedScenario?.orderId;

    scenarios = ObservableList<OrderTrackingScenario>.of(
      _getOrderTrackingScenariosUseCase.call(params: now),
    );

    if (scenarios.isEmpty) {
      selectedScenario = null;
      return;
    }

    if (previousSelectedOrderId == null) {
      selectedScenario = scenarios.first;
      return;
    }

    selectedScenario = scenarios.firstWhere(
      (OrderTrackingScenario item) =>
          item.orderId.toLowerCase() == previousSelectedOrderId.toLowerCase(),
      orElse: () => scenarios.first,
    );
  }

  @action
  void selectScenario(OrderTrackingScenario scenario) {
    selectedScenario = scenario;
  }

  OrderTrackingScenario? findByOrderId(String orderId) {
    return _findOrderTrackingScenarioUseCase.call(
      params: FindOrderTrackingScenarioParams(
        scenarios: scenarios.toList(),
        orderId: orderId,
      ),
    );
  }
}
