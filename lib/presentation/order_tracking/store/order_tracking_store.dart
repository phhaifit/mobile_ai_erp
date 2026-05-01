import 'dart:async';

import 'package:mobile_ai_erp/core/stores/error/error_store.dart';
import 'package:mobile_ai_erp/data/network/apis/orders/orders_api.dart';
import 'package:mobile_ai_erp/data/network/constants/endpoints.dart';
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
    this._ordersApi,
    this.errorStore,
  );

  final GetOrderTrackingScenariosUseCase _getOrderTrackingScenariosUseCase;
  final FindOrderTrackingScenarioUseCase _findOrderTrackingScenarioUseCase;
  final OrdersApi _ordersApi;
  final ErrorStore errorStore;

  @observable
  ObservableList<OrderTrackingScenario> scenarios =
      ObservableList<OrderTrackingScenario>();

  @observable
  OrderTrackingScenario? selectedScenario;

  @observable
  Map<String, dynamic>? orderDetail;

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
      final String? secretKey = _resolveHeaderValue(Endpoints.erpSecretKey);
      final String? tenantId = _resolveHeaderValue(Endpoints.erpTenantId);

      final detail = await _ordersApi.getOrderDetail(
        orderId,
        secretKey: secretKey,
        tenantId: tenantId,
      );

      if (detail.isEmpty) {
        if (!silent) {
          errorMessage = 'Order detail not found.';
          errorStore.setErrorMessage(
            errorMessage ?? 'Order detail not found.',
          );
        }
        return;
      }

      orderDetail = detail;
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
    Map<String, dynamic> detail,
    String fallbackOrderId,
  ) {
    final String orderId = (detail['id'] ?? detail['orderId'] ?? fallbackOrderId)
        .toString();
    final String code =
        detail['code']?.toString() ?? detail['orderCode']?.toString() ?? orderId;
    final String status = detail['status']?.toString() ?? 'pending';
    final DateTime now = DateTime.now();
    final DateTime createdAt =
      _parseDate(detail['createdAt'] ?? detail['created_at']) ?? now;
    final DateTime updatedAt =
      _parseDate(detail['updatedAt'] ?? detail['updated_at']) ?? now;

    final ShipmentStage currentStage = _mapStatusToStage(status);
    final List<TrackingTimelineStep> steps =
        _buildTimelineSteps(currentStage, createdAt, updatedAt);

    return OrderTrackingScenario(
      scenarioName: code,
      orderId: orderId,
      trackingNumber: detail['trackingNumber']?.toString() ?? code,
      carrierName: detail['carrierName']?.toString() ?? 'Mock Carrier',
      carrierTrackingUrl:
          detail['carrierTrackingUrl']?.toString() ?? 'https://example.com',
      estimatedDeliveryDate:
          _parseDate(detail['estimatedDeliveryDate']) ?? now.add(
            const Duration(days: 2),
          ),
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
      case 'confirmed':
      case 'pending':
        return ShipmentStage.confirmed;
      case 'packed':
        return ShipmentStage.packed;
      case 'shipped':
      case 'shipping':
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
      TrackingTimelineStep(stage: ShipmentStage.confirmed, timestamp: createdAt),
    ];

    if (currentStage.index >= ShipmentStage.packed.index) {
      steps.add(
        TrackingTimelineStep(stage: ShipmentStage.packed, timestamp: updatedAt),
      );
    }

    if (currentStage.index >= ShipmentStage.shipped.index) {
      steps.add(
        TrackingTimelineStep(stage: ShipmentStage.shipped, timestamp: updatedAt),
      );
    }

    if (currentStage.index >= ShipmentStage.delivered.index) {
      steps.add(
        TrackingTimelineStep(stage: ShipmentStage.delivered, timestamp: updatedAt),
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

  String getOrderCode(Map<String, dynamic>? detail) {
    if (detail == null) return 'N/A';
    return (detail['code'] ?? detail['orderCode'] ?? detail['id'] ?? 'N/A')
        .toString();
  }

  String getOrderStatus(Map<String, dynamic>? detail) {
    if (detail == null) return 'unknown';
    return (detail['status'] ?? detail['state'] ?? 'unknown').toString();
  }

  String getTotalPrice(Map<String, dynamic>? detail) {
    if (detail == null) return '0';
    final price = detail['totalPrice'] ?? detail['total'] ?? detail['totalAmount'];
    return price?.toString() ?? '0';
  }

  int getItemsCount(Map<String, dynamic>? detail) {
    if (detail == null) return 0;
    final dynamic items = detail['items'] ?? detail['orderItems'] ?? detail['products'];
    if (items is List) {
      return items.length;
    }
    final dynamic count = detail['itemsCount'] ?? detail['items_count'] ?? detail['totalItems'];
    if (count is num) {
      return count.toInt();
    }
    if (count is String) {
      return int.tryParse(count) ?? 0;
    }
    return 0;
  }

  String getCustomerName(Map<String, dynamic>? detail) {
    if (detail == null) return 'Unknown';
    final dynamic customer = detail['customer'];
    if (customer is Map<String, dynamic>) {
      return (customer['name'] ?? customer['fullName'] ?? 'Unknown').toString();
    }
    return (detail['customerName'] ?? detail['customer'] ?? 'Unknown').toString();
  }

  String getDeliveryInfo(Map<String, dynamic>? detail) {
    if (detail == null) return '';
    final dynamic shipping = detail['shippingAddress'] ?? detail['deliveryAddress'];
    if (shipping is Map<String, dynamic>) {
      final String line1 = (shipping['addressLine1'] ??
              shipping['line1'] ??
              shipping['address'] ??
              '')
          .toString();
      final String city = (shipping['city'] ?? shipping['province'] ?? '').toString();
      return [line1, city].where((e) => e.isNotEmpty).join(', ');
    }
    final String fallback =
        (detail['shippingAddress'] ?? detail['deliveryAddress'] ?? '').toString();
    return fallback;
  }

  DateTime? getOrderCreatedAt(Map<String, dynamic>? detail) {
    if (detail == null) return null;
    final raw = detail['createdAt'] ?? detail['created_at'] ?? detail['createdDate'];
    if (raw is String && raw.isNotEmpty) {
      return DateTime.tryParse(raw);
    }
    if (raw is DateTime) {
      return raw;
    }
    return null;
  }

  String? _resolveHeaderValue(String value) {
    final String trimmed = value.trim();
    if (trimmed.isEmpty) {
      return null;
    }
    return trimmed;
  }
}
