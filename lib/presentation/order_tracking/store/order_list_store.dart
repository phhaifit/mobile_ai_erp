import 'package:mobx/mobx.dart';
import 'package:mobile_ai_erp/core/stores/error/error_store.dart';
import 'package:mobile_ai_erp/data/network/apis/orders/dto/order_list_response.dart';
import 'package:mobile_ai_erp/data/network/apis/orders/order_api.dart';

part 'order_list_store.g.dart';

class OrderListStore = _OrderListStore with _$OrderListStore;

abstract class _OrderListStore with Store {
  _OrderListStore(
    this._orderApi,
    this.errorStore,
  );

  final OrderApi _orderApi;
  final ErrorStore errorStore;

  @observable
  ObservableList<OrderSummaryDto> orders =
      ObservableList<OrderSummaryDto>();

  @observable
  bool isLoading = false;

  @observable
  String? error;

  @observable
  OrderSummaryDto? selectedOrder;

  @observable
  int currentPage = 1;

  @observable
  int totalPages = 1;

  @observable
  int totalItems = 0;

  @observable
  int pageSize = 20;

  @computed
  bool get hasMoreOrders => currentPage < totalPages;

  @action
  Future<void> loadOrders({int page = 1, bool append = false}) async {
    isLoading = true;
    error = null;

    try {
      final response = await _orderApi.getOrders(
        pageSize: 20,
        page: 1,
      );
      orders = ObservableList<OrderSummaryDto>.of(response.data);
    } catch (e) {
      error = 'Failed to load orders. ${e.toString()}';
      errorStore.setErrorMessage(error ?? 'Failed to load orders.');
    } finally {
      isLoading = false;
    }
  }

  @action
  void selectOrder(OrderSummaryDto order) {
    selectedOrder = order;
  }

  @action
  void clearSelected() {
    selectedOrder = null;
  }
}
