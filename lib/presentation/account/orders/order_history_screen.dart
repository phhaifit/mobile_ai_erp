import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import '../../../../domain/entity/order/order.dart';
import '../../../../di/service_locator.dart';
import '../../../../utils/routes/routes.dart';
import '../store/order_store.dart';
import '../widgets/order_item_card_widget.dart';

class OrderHistoryScreen extends StatefulWidget {
  const OrderHistoryScreen({super.key});

  @override
  State<OrderHistoryScreen> createState() => _OrderHistoryScreenState();
}

class _OrderHistoryScreenState extends State<OrderHistoryScreen> {
  final OrderStore _orderStore = getIt<OrderStore>();

  @override
  void initState() {
    super.initState();
    _orderStore.fetchOrders();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 9, // 🚀 UPDATED from 6 to 9
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Order History'),
          elevation: 0,
          bottom: const TabBar(
            isScrollable: true,
            indicatorColor: Colors.blue,
            labelColor: Colors.blue,
            unselectedLabelColor: Colors.grey,
            tabs: [
              Tab(text: 'All'),
              Tab(text: 'Pending'),
              Tab(text: 'Confirmed'),
              Tab(text: 'Packing'),    // 🚀 NEW
              Tab(text: 'Shipping'),
              Tab(text: 'Delivered'),
              Tab(text: 'Success'),    // 🚀 NEW
              Tab(text: 'Cancelled'),
              Tab(text: 'Returned'),   // 🚀 NEW
            ],
          ),
        ),
        body: Observer(
          builder: (_) {
            if (_orderStore.isLoading && _orderStore.orders.isEmpty) {
              return const Center(child: CircularProgressIndicator());
            }

            return TabBarView(
              children: [
                _buildOrderList(null), // All
                _buildOrderList(OrderStatus.pending),
                _buildOrderList(OrderStatus.confirmed),
                _buildOrderList(OrderStatus.packing),
                _buildOrderList(OrderStatus.shipping),
                _buildOrderList(OrderStatus.delivered),
                _buildOrderList(OrderStatus.success),
                _buildOrderList(OrderStatus.cancelled),
                _buildOrderList(OrderStatus.returned),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildOrderList(OrderStatus? filterStatus) {
    // Filter the orders based on the tab's status. If null, show all.
    final filteredOrders = _orderStore.orders.where((order) {
      if (filterStatus == null) return true;
      return order.status == filterStatus;
    }).toList();

    if (filteredOrders.isEmpty) {
      return const Center(child: Text('No orders found in this category.'));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: filteredOrders.length,
      itemBuilder: (context, index) {
        final order = filteredOrders[index];
        return OrderItemCardWidget(
          order: order,
          onTap: () {
            Navigator.pushNamed(context, Routes.orderDetail, arguments: order);
          },
        );
      },
    );
  }
}
