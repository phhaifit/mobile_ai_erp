import 'package:mobile_ai_erp/core/stores/error/error_store.dart';
import 'package:mobile_ai_erp/domain/entity/fulfillment/fulfillment_order.dart';
import 'package:mobile_ai_erp/domain/entity/fulfillment/fulfillment_status.dart';
import 'package:mobile_ai_erp/domain/entity/fulfillment/shipment_tracking.dart';
import 'package:mobile_ai_erp/domain/entity/fulfillment/tracking_event.dart';
import 'package:mobile_ai_erp/domain/usecase/fulfillment/create_or_link_shipment_usecase.dart';
import 'package:mobile_ai_erp/domain/usecase/fulfillment/apply_order_routing_recommendation_usecase.dart';
import 'package:mobile_ai_erp/domain/usecase/fulfillment/create_shipment_print_attempt_usecase.dart';
import 'package:mobile_ai_erp/domain/usecase/fulfillment/create_shipment_print_job_usecase.dart';
import 'package:mobile_ai_erp/domain/usecase/fulfillment/get_fulfillment_order_detail_usecase.dart';
import 'package:mobile_ai_erp/domain/usecase/fulfillment/get_fulfillment_orders_usecase.dart';
import 'package:mobile_ai_erp/domain/usecase/fulfillment/get_order_routing_recommendation_usecase.dart';
import 'package:mobile_ai_erp/domain/usecase/fulfillment/get_order_shipments_tracking_usecase.dart';
import 'package:mobile_ai_erp/domain/usecase/fulfillment/get_shipment_label_artifacts_usecase.dart';
import 'package:mobile_ai_erp/domain/usecase/fulfillment/get_shipment_print_jobs_usecase.dart';
import 'package:mobile_ai_erp/domain/usecase/fulfillment/get_shipment_tracking_usecase.dart';
import 'package:mobile_ai_erp/domain/usecase/fulfillment/update_fulfillment_status_usecase.dart';
import 'package:mobx/mobx.dart';

part 'fulfillment_store.g.dart';

class FulfillmentStore = _FulfillmentStore with _$FulfillmentStore;

abstract class _FulfillmentStore with Store {
  final GetFulfillmentOrdersUseCase _getOrdersUseCase;
  final GetFulfillmentOrderDetailUseCase _getOrderDetailUseCase;
  final UpdateFulfillmentStatusUseCase _updateStatusUseCase;
  final CreateOrLinkShipmentUseCase _createOrLinkShipmentUseCase;
  final GetOrderRoutingRecommendationUseCase
  _getOrderRoutingRecommendationUseCase;
  final ApplyOrderRoutingRecommendationUseCase
  _applyOrderRoutingRecommendationUseCase;
  final GetShipmentTrackingUseCase _getShipmentTrackingUseCase;
  final GetOrderShipmentsTrackingUseCase _getOrderShipmentsTrackingUseCase;
  final GetShipmentLabelArtifactsUseCase _getShipmentLabelArtifactsUseCase;
  final GetShipmentPrintJobsUseCase _getShipmentPrintJobsUseCase;
  final CreateShipmentPrintJobUseCase _createShipmentPrintJobUseCase;
  final CreateShipmentPrintAttemptUseCase _createShipmentPrintAttemptUseCase;
  final ErrorStore errorStore;

  _FulfillmentStore(
    this._getOrdersUseCase,
    this._getOrderDetailUseCase,
    this._updateStatusUseCase,
    this._createOrLinkShipmentUseCase,
    this._getOrderRoutingRecommendationUseCase,
    this._applyOrderRoutingRecommendationUseCase,
    this._getShipmentTrackingUseCase,
    this._getOrderShipmentsTrackingUseCase,
    this._getShipmentLabelArtifactsUseCase,
    this._getShipmentPrintJobsUseCase,
    this._createShipmentPrintJobUseCase,
    this._createShipmentPrintAttemptUseCase,
    this.errorStore,
  );

  @observable
  ObservableList<FulfillmentOrder> orderList =
      ObservableList<FulfillmentOrder>();

  @observable
  FulfillmentOrder? selectedOrder;

  @observable
  FulfillmentStatus? statusFilter;

  @observable
  bool isLoadingOrders = false;

  @observable
  bool isLoadingDetail = false;

  @observable
  bool success = false;

  @computed
  List<FulfillmentOrder> get filteredOrders {
    if (statusFilter == null) return orderList.toList();
    return orderList.where((o) => o.status == statusFilter).toList();
  }

  @action
  Future<void> getOrders() async {
    isLoadingOrders = true;
    try {
      final orders = await _getOrdersUseCase.call(params: null);
      orderList = ObservableList.of(orders);
      success = true;
    } catch (e) {
      errorStore.errorMessage = e.toString();
    } finally {
      isLoadingOrders = false;
    }
  }

  @action
  Future<void> getOrderDetail(String orderId) async {
    isLoadingDetail = true;
    try {
      selectedOrder = await _getOrderDetailUseCase.call(params: orderId);
      success = true;
    } catch (e) {
      errorStore.errorMessage = e.toString();
    } finally {
      isLoadingDetail = false;
    }
  }

  @action
  Future<void> updateStatus(String orderId, FulfillmentStatus status) async {
    try {
      await _updateStatusUseCase.call(
        params: UpdateFulfillmentStatusParams(orderId: orderId, status: status),
      );
      await getOrderDetail(orderId);
      await getOrders();
    } catch (e) {
      errorStore.errorMessage = e.toString();
    }
  }

  @action
  void setStatusFilter(FulfillmentStatus? status) {
    statusFilter = status;
  }

  Future<ShipmentTrackingInfo?> getShipmentTracking(
    String orderId, {
    bool refresh = false,
  }) async {
    try {
      final shipment = await _getShipmentTrackingUseCase.call(
        params: GetShipmentTrackingParams(orderId: orderId, refresh: refresh),
      );

      if (refresh) {
        // Keep detail and list in sync after carrier refresh/webhook reconciliation.
        await getOrderDetail(orderId);
        await getOrders();
      }

      if (shipment != null) {
        _mergeCarrierTrackingEvents(shipment);
      }

      return shipment;
    } catch (e) {
      errorStore.errorMessage = e.toString();
      return null;
    }
  }

  Future<ShipmentTrackingInfo?> createOrLinkShipment(
    String orderId, {
    List<CreateShipmentItemAllocation> items = const [],
  }) async {
    try {
      final shipment = await _createOrLinkShipmentUseCase.call(
        params: CreateOrLinkShipmentParams(orderId: orderId, items: items),
      );

      final refreshed = await getShipmentTracking(orderId, refresh: true);
      return refreshed ?? shipment;
    } catch (e) {
      errorStore.errorMessage = e.toString();
      return null;
    }
  }

  Future<OrderRoutingRecommendation?> getOrderRoutingRecommendation(
    String orderId, {
    bool forceNew = false,
  }) async {
    try {
      return await _getOrderRoutingRecommendationUseCase.call(
        params: GetOrderRoutingRecommendationParams(
          orderId: orderId,
          forceNew: forceNew,
        ),
      );
    } catch (e) {
      errorStore.errorMessage = e.toString();
      return null;
    }
  }

  Future<OrderRoutingApplyResult?> applyOrderRoutingRecommendation(
    String orderId, {
    required String decisionId,
    String? selectedOptionId,
  }) async {
    try {
      return await _applyOrderRoutingRecommendationUseCase.call(
        params: ApplyOrderRoutingRecommendationParams(
          orderId: orderId,
          decisionId: decisionId,
          selectedOptionId: selectedOptionId,
        ),
      );
    } catch (e) {
      errorStore.errorMessage = e.toString();
      return null;
    }
  }

  Future<List<ShipmentTrackingInfo>> getOrderShipmentBatches(
    String orderId, {
    bool refresh = false,
  }) async {
    try {
      final response = await _getOrderShipmentsTrackingUseCase.call(
        params: GetOrderShipmentsTrackingParams(
          orderId: orderId,
          refresh: refresh,
        ),
      );

      final shipments = response?.shipments ?? const <ShipmentTrackingInfo>[];

      if (refresh) {
        await getOrderDetail(orderId);
        await getOrders();
      }

      for (final shipment in shipments) {
        _mergeCarrierTrackingEvents(shipment);
      }

      return shipments;
    } catch (e) {
      errorStore.errorMessage = e.toString();
      return const <ShipmentTrackingInfo>[];
    }
  }

  Future<List<ShipmentLabelArtifact>> getShipmentLabelArtifacts(
    String orderId,
    String shipmentId,
  ) async {
    try {
      return await _getShipmentLabelArtifactsUseCase.call(
        params: GetShipmentLabelArtifactsParams(
          orderId: orderId,
          shipmentId: shipmentId,
        ),
      );
    } catch (e) {
      errorStore.errorMessage = e.toString();
      return const <ShipmentLabelArtifact>[];
    }
  }

  Future<List<ShipmentPrintJob>> getShipmentPrintJobs(
    String orderId,
    String shipmentId,
  ) async {
    try {
      return await _getShipmentPrintJobsUseCase.call(
        params: GetShipmentPrintJobsParams(
          orderId: orderId,
          shipmentId: shipmentId,
        ),
      );
    } catch (e) {
      errorStore.errorMessage = e.toString();
      return const <ShipmentPrintJob>[];
    }
  }

  Future<ShipmentPrintJob?> createShipmentPrintJob(
    String orderId,
    String shipmentId, {
    String? artifactId,
    String artifactType = 'shipping_label',
    String format = 'pdf',
    String? printerName,
    String? printerCode,
    int copies = 1,
    Map<String, dynamic>? payload,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      return await _createShipmentPrintJobUseCase.call(
        params: CreateShipmentPrintJobParams(
          orderId: orderId,
          shipmentId: shipmentId,
          artifactId: artifactId,
          artifactType: artifactType,
          format: format,
          printerName: printerName,
          printerCode: printerCode,
          copies: copies,
          payload: payload,
          metadata: metadata,
        ),
      );
    } catch (e) {
      errorStore.errorMessage = e.toString();
      return null;
    }
  }

  Future<ShipmentPrintJob?> createShipmentPrintAttempt(
    String orderId,
    String shipmentId,
    String printJobId, {
    required String status,
    String? spoolJobId,
    String? errorCode,
    String? errorMessage,
    int? durationMs,
    Map<String, dynamic>? printerResponse,
  }) async {
    try {
      return await _createShipmentPrintAttemptUseCase.call(
        params: CreateShipmentPrintAttemptParams(
          orderId: orderId,
          shipmentId: shipmentId,
          printJobId: printJobId,
          status: status,
          spoolJobId: spoolJobId,
          errorCode: errorCode,
          errorMessage: errorMessage,
          durationMs: durationMs,
          printerResponse: printerResponse,
        ),
      );
    } catch (e) {
      errorStore.errorMessage = e.toString();
      return null;
    }
  }

  void _mergeCarrierTrackingEvents(ShipmentTrackingInfo shipment) {
    final current = selectedOrder;
    if (current == null || current.id != shipment.orderId) {
      return;
    }

    final mergedEvents = <String, TrackingEvent>{
      for (final event in current.trackingEvents) event.id: event,
    };

    for (final event in shipment.events) {
      final status = _mapShipmentStatusToFulfillment(event.status);
      final notes = <String>[
        '[${shipment.provider.toUpperCase()}] ${event.status}',
        if (event.description != null && event.description!.isNotEmpty)
          event.description!,
        if (event.location != null && event.location!.isNotEmpty)
          event.location!,
      ];

      mergedEvents['carrier:${event.id}'] = TrackingEvent(
        id: 'carrier:${event.id}',
        newStatus: status,
        note: notes.join(' • '),
        changedAt: event.eventTime,
        changedByName: '${shipment.provider.toUpperCase()} Carrier',
      );
    }

    final sortedEvents = mergedEvents.values.toList()
      ..sort((a, b) => b.changedAt.compareTo(a.changedAt));

    selectedOrder = current.copyWith(trackingEvents: sortedEvents);
  }

  FulfillmentStatus _mapShipmentStatusToFulfillment(String status) {
    switch (status.toLowerCase()) {
      case 'delivered':
        return FulfillmentStatus.delivered;
      case 'returned':
        return FulfillmentStatus.returned;
      case 'failed':
        return FulfillmentStatus.cancelled;
      case 'processing':
      case 'pending':
      case 'created':
      case 'linked':
      case 'in_transit':
      default:
        return FulfillmentStatus.shipping;
    }
  }
}
