import 'dart:async';

import 'package:mobile_ai_erp/core/stores/error/error_store.dart';
import 'package:mobile_ai_erp/data/network/apis/orders/dto/order_detail_response.dart';
import 'package:mobile_ai_erp/data/network/apis/orders/order_api.dart';
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
    this._orderApi,
    this.errorStore,
  );

  final GetOrderTrackingScenariosUseCase _getOrderTrackingScenariosUseCase;
  final FindOrderTrackingScenarioUseCase _findOrderTrackingScenarioUseCase;
  final OrderApi _orderApi;
  final ErrorStore errorStore;

  @observable
  ObservableList<OrderTrackingScenario> scenarios =
      ObservableList<OrderTrackingScenario>();

  @observable
  OrderTrackingScenario? selectedScenario;

  @observable
  OrderDetailResponse? orderDetail;

  @observable
  DateTime? lastUpdatedAt;

  @observable
  bool isLoading = false;

  @observable
  bool isPolling = false;

  @observable
  String? errorMessage;

  Timer? _pollingTimer;
  String? _currentOrderId;

  @action
  Future<void> loadOrderDetail(String orderId, {bool silent = false}) async {
    if (!silent) {
      isLoading = true;
      errorMessage = null;
    }

    try {
      final detail = await _orderApi.getOrderDetail(orderId);

      orderDetail = detail;
      // Clear any previous error state when we successfully load detail,
      // even for silent polling, so the UI can recover from earlier failures.
      errorMessage = null;
      errorStore.setErrorMessage('');
      lastUpdatedAt = DateTime.now();
      final scenario = _mapOrderDetailToScenario(detail, orderId);
      scenarios = ObservableList<OrderTrackingScenario>.of([scenario]);
      selectedScenario = scenario;
    } catch (e) {
      if (!silent) {
        errorMessage = 'Failed to load order detail: ${e.toString()}';
        errorStore.setErrorMessage(errorMessage ?? '');
      }
    } finally {
      if (!silent) {
        isLoading = false;
      }
    }
  }

  @action
  void startRealtimeTracking(String orderId) {
    if (orderId.trim().isEmpty) {
      return;
    }

    if (_currentOrderId == orderId && isPolling) {
      // If we're already polling this order but previously encountered an error,
      // allow an immediate retry so the user-triggered retry isn't ignored.
      if (errorMessage != null && errorMessage!.isNotEmpty) {
        loadOrderDetail(orderId);
      }
      return;
    }

    stopRealtimeTracking();
    _currentOrderId = orderId;
    isPolling = true;
    loadOrderDetail(orderId);

    _pollingTimer = Timer.periodic(const Duration(seconds: 5), (_) {
      if (_currentOrderId == null || _currentOrderId!.isEmpty) {
        return;
      }
      loadOrderDetail(_currentOrderId!, silent: true);
    });
  }

  @action
  void stopRealtimeTracking() {
    _pollingTimer?.cancel();
    _pollingTimer = null;
    isPolling = false;
  }

  void dispose() {
    stopRealtimeTracking();
  }

  OrderTrackingScenario? findByOrderId(String orderId) {
    return _findOrderTrackingScenarioUseCase.call(
      params: FindOrderTrackingScenarioParams(
        scenarios: scenarios.toList(),
        orderId: orderId,
      ),
    );
  }

  OrderTrackingScenario _mapOrderDetailToScenario(
    OrderDetailResponse detail,
    String fallbackOrderId,
  ) {
    final OrderDto order = detail.order;
    final String orderId = order.id.isNotEmpty ? order.id : fallbackOrderId;
    final String code = order.code.isNotEmpty ? order.code : orderId;
    final String status = order.status.isNotEmpty ? order.status : 'pending';
    final DateTime now = DateTime.now();
    final DateTime createdAt = _parseDate(order.createdAt) ?? now;
    final DateTime updatedAt = _parseDate(order.updatedAt) ?? now;

    final ShipmentStage currentStage = _mapStatusToStage(status);
    final List<TrackingTimelineStep> steps = _buildTimelineSteps(
      currentStage,
      createdAt,
      updatedAt,
    );

    return OrderTrackingScenario(
      scenarioName: code,
      orderId: orderId,
      trackingNumber: code,
      carrierName: 'Mock Carrier',
      carrierTrackingUrl:
          'https://example.com',
      estimatedDeliveryDate:
          now.add(const Duration(days: 2)),
      lastUpdatedAt: updatedAt,
      timelineSteps: steps,
      currentStage: currentStage,
      deliveryAlertType: _mapAlertType(status),
      deliveryAlertMessage: _mapAlertMessage(status),
      returnExchangeStage: ReturnExchangeStage.none,
    );
  }

  ShipmentStage _mapStatusToStage(String status) {
    switch (status.toLowerCase()) {
      case 'new':
      case 'pending':
        return ShipmentStage.confirmed;
      case 'packing':
      case 'packed':
      case 'shipping':
        return ShipmentStage.packed;
      case 'partially_shipped':
      case 'shipped':
      case 'in_transit':
        return ShipmentStage.shipped;
      case 'delivered':
        return ShipmentStage.delivered;
      default:
        return ShipmentStage.confirmed;
    }
  }

  List<TrackingTimelineStep> _buildTimelineSteps(
    ShipmentStage currentStage,
    DateTime createdAt,
    DateTime updatedAt,
  ) {
    final List<TrackingTimelineStep> steps = [
      TrackingTimelineStep(
        stage: ShipmentStage.confirmed,
        timestamp: createdAt,
      ),
    ];

    if (currentStage.index >= ShipmentStage.packed.index) {
      steps.add(
        TrackingTimelineStep(stage: ShipmentStage.packed, timestamp: updatedAt),
      );
    }

    if (currentStage.index >= ShipmentStage.shipped.index) {
      steps.add(
        TrackingTimelineStep(
          stage: ShipmentStage.shipped,
          timestamp: updatedAt,
        ),
      );
    }

    if (currentStage.index >= ShipmentStage.delivered.index) {
      steps.add(
        TrackingTimelineStep(
          stage: ShipmentStage.delivered,
          timestamp: updatedAt,
        ),
      );
    }

    return steps;
  }

  DeliveryAlertType _mapAlertType(String status) {
    switch (status.toLowerCase()) {
      case 'cancelled':
      case 'canceled':
      case 'failed':
        return DeliveryAlertType.failed;
      default:
        return DeliveryAlertType.none;
    }
  }

  String _mapAlertMessage(String status) {
    switch (status.toLowerCase()) {
      case 'cancelled':
      case 'canceled':
        return 'Order was cancelled.';
      case 'failed':
        return 'Delivery failed.';
      default:
        return '';
    }
  }

  DateTime? _parseDate(dynamic value) {
    if (value == null) return null;
    if (value is DateTime) return value;
    if (value is String) {
      return DateTime.tryParse(value);
    }
    return null;
  }
}
