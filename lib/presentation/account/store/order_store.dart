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
  Future<void> fetchOrders() async {
    isLoading = true;
    final data = await _repository.getOrderHistory(); // Use _repository here
    orders = ObservableList.of(data);
    isLoading = false;
  }

  @action
  void buyAgain(Order order) {
    // Phase 1 Mock Action: Feature 14 (Checkout) integration placeholder.
    // In the UI, calling this will trigger a Snackbar saying "Redirecting to Checkout..."
    print('Mock: Redirecting to Checkout with items from ${order.id}');
  }

  @action
  Future<void> submitReturnRequest(String orderId, String reason) async {
    isLoading = true;
    await Future.delayed(const Duration(seconds: 1)); // Mock API call
    print('Mock: Return request submitted for $orderId - Reason: $reason');
    isLoading = false;
  }

  @action
  Future<void> cancelOrder(String orderId) async {
    isLoading = true;
    await Future.delayed(const Duration(seconds: 1)); // Mock API delay

    // Find the order and update its status locally for the mock UI
    final index = orders.indexWhere((o) => o.id == orderId);
    if (index != -1) {
      final oldOrder = orders[index];
      // Create a new order object with the canceled status
      orders[index] = Order(
        id: oldOrder.id,
        status: OrderStatus.canceled,
        date: oldOrder.date,
        totalAmount: oldOrder.totalAmount,
        shippingFee: oldOrder.shippingFee,
        shippingAddress: oldOrder.shippingAddress,
        paymentMethod: oldOrder.paymentMethod,
        items: oldOrder.items,
      );
    }
    isLoading = false;
  }
}
