import 'package:mobx/mobx.dart';
import '../../../../domain/entity/order/order.dart';
import '../../../../domain/repository/account/order_repository.dart';

part 'order_store.g.dart';

class OrderStore = _OrderStore with _$OrderStore;

abstract class _OrderStore with Store {
  final OrderRepository _repository; // Changed type and name

  _OrderStore(this._repository);

  @observable
  ObservableList<Order> orders = ObservableList<Order>();

  @observable
  bool isLoading = false;

  @action
  Future<void> fetchOrders({String? status}) async {
    isLoading = true;
    final data = await _repository.getOrderHistory(status: status);
    orders = ObservableList.of(data);
    isLoading = false;
  }

  @action
  Future<Order> getOrderDetails(String orderId) async {
    isLoading = true;
    final order = await _repository.getOrderDetails(orderId);
    isLoading = false;
    return order;
  }

  @action
  Future<void> cancelOrder(String orderId) async {
    isLoading = true;
    await _repository.cancelOrder(orderId);
    await fetchOrders(); // Refresh orders
    isLoading = false;
  }

  @action
  Future<void> submitReturnRequest(String orderId, String reason) async {
    isLoading = true;
    await _repository.submitReturnRequest(orderId, {'reason': reason});
    isLoading = false;
  }

  @action
  Future<void> reorder(String orderId) async {
    isLoading = true;
    final result = await _repository.reorder(orderId);
    // Handle reorder result, e.g., navigate to cart or checkout
    print('Reorder result: $result');
    isLoading = false;
  }

  @action
  void buyAgain(Order order) {
    // Phase 1 Mock Action: Feature 14 (Checkout) integration placeholder.
    // In the UI, calling this will trigger a Snackbar saying "Redirecting to Checkout..."
    print('Mock: Redirecting to Checkout with items from ${order.id}');
  }
}
