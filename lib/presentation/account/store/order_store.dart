import 'package:mobx/mobx.dart';
import '../../../domain/entity/storefront_order/order.dart';
import '../../../domain/entity/storefront_order/return_request.dart';
import '../../../domain/usecase/storefront_order/get_order_history_usecase.dart';
import '../../../domain/usecase/storefront_order/get_order_details_usecase.dart';
import '../../../domain/usecase/storefront_order/cancel_order_usecase.dart';
import '../../../domain/usecase/storefront_order/submit_return_request_usecase.dart';
import '../../../domain/usecase/storefront_order/reorder_usecase.dart';
import '../../../domain/usecase/storefront_order/confirm_order_usecase.dart';

part 'order_store.g.dart';

class OrderStore = _OrderStore with _$OrderStore;

abstract class _OrderStore with Store {
  final GetOrderHistoryUseCase _getOrderHistory;
  final GetOrderDetailsUseCase _getOrderDetails;
  final CancelOrderUseCase _cancelOrder;
  final SubmitReturnRequestUseCase _submitReturnRequest;
  final ReorderUseCase _reorder;
  final ConfirmOrderUsecase _confirmOrder;

  _OrderStore(
    this._getOrderHistory,
    this._getOrderDetails,
    this._cancelOrder,
    this._submitReturnRequest,
    this._reorder,
    this._confirmOrder,
  );

  @observable
  ObservableList<StorefrontOrder> orders = ObservableList<StorefrontOrder>();

  @observable
  StorefrontOrder? currentOrderDetails;

  @observable
  bool isLoading = false;

  @action
  Future<void> fetchOrders({String? status, int? page, int? pageSize}) async {
    try {
      // Only show full loading spinner on initial load
      if (page == null || page == 1) isLoading = true; 
      
      final data = await _getOrderHistory.call(
        params: GetOrderHistoryParams(status: status, page: page, pageSize: pageSize),
      );
      
      if (page != null && page > 1) {
        // Append to existing list for infinite scrolling
        orders.addAll(data);
      } else {
        // Fresh load (page 1)
        orders = ObservableList.of(data);
      }
    } catch (e) {
      print('❌ [OrderStore.fetchOrders] Error: $e');
    } finally {
      isLoading = false;
    }
  }

  @action
  Future<StorefrontOrder?> getOrderDetails(String orderId) async {
    try {
      isLoading = true;
      final order = await _getOrderDetails.call(params: orderId);
      currentOrderDetails = order;
      return order;
    } catch (e) {
      print('❌ [OrderStore.getOrderDetails] Error: $e');
      return null;
    } finally {
      isLoading = false;
    }
  }

  @action
  Future<void> cancelOrder(String orderId) async {
    try {
      isLoading = true;
      await _cancelOrder.call(params: orderId);
      await fetchOrders(); 
    } catch (e) {
      print('❌ [OrderStore.cancelOrder] Error: $e');
      rethrow;
    } finally {
      isLoading = false;
    }
  }

  @action
  Future<void> submitReturnRequest(String orderId, SubmitReturnPayload payload) async {
    try {
      isLoading = true;
      await _submitReturnRequest.call(
        params: SubmitReturnParams(orderId: orderId, payload: payload),
      );
    } catch (e) {
      print('❌ [OrderStore.submitReturnRequest] Error: $e');
      rethrow;
    } finally {
      isLoading = false;
    }
  }

  @action
  Future<String?> reorder(String orderId) async {
    try {
      isLoading = true;
      final result = await _reorder.call(params: orderId);
      return result['cartId'] as String?;
    } catch (e) {
      print('❌ [OrderStore.reorder] Error: $e');
      rethrow;
    } finally {
      isLoading = false;
    }
  }

  @action
  Future<void> confirmOrder(String orderId) async {
    try {
      isLoading = true;
      await _confirmOrder.call(params: orderId);
      return;
    } catch (e) {
      print('❌ [OrderStore.confirmOrder] Error: $e');
      rethrow;
    } finally {
      isLoading = false;
    }
  }
}