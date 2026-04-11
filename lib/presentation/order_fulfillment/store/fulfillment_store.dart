import 'package:mobile_ai_erp/core/stores/error/error_store.dart';
import 'package:mobile_ai_erp/domain/entity/fulfillment/fulfillment_order.dart';
import 'package:mobile_ai_erp/domain/entity/fulfillment/fulfillment_status.dart';
import 'package:mobile_ai_erp/domain/usecase/fulfillment/get_fulfillment_order_detail_usecase.dart';
import 'package:mobile_ai_erp/domain/usecase/fulfillment/get_fulfillment_orders_usecase.dart';
import 'package:mobile_ai_erp/domain/usecase/fulfillment/update_fulfillment_status_usecase.dart';
import 'package:mobx/mobx.dart';

part 'fulfillment_store.g.dart';

class FulfillmentStore = _FulfillmentStore with _$FulfillmentStore;

abstract class _FulfillmentStore with Store {
  final GetFulfillmentOrdersUseCase _getOrdersUseCase;
  final GetFulfillmentOrderDetailUseCase _getOrderDetailUseCase;
  final UpdateFulfillmentStatusUseCase _updateStatusUseCase;
  final ErrorStore errorStore;

  _FulfillmentStore(
    this._getOrdersUseCase,
    this._getOrderDetailUseCase,
    this._updateStatusUseCase,
    this.errorStore,
  );

  @observable
  ObservableList<FulfillmentOrder> orderList = ObservableList<FulfillmentOrder>();

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
        params: UpdateFulfillmentStatusParams(
          orderId: orderId,
          status: status,
        ),
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
}
