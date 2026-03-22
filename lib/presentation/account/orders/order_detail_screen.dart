import 'package:flutter/material.dart';
import '../../../../domain/entity/order/order.dart';
import '../../../../di/service_locator.dart';
import '../../../../utils/routes/routes.dart';
import '../store/order_store.dart';
import '../widgets/order_status_badge.dart';

class OrderDetailScreen extends StatelessWidget {
  const OrderDetailScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final order = ModalRoute.of(context)!.settings.arguments as Order;
    final orderStore = getIt<OrderStore>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Order Details'),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Order ID: ${order.id}',
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 16)),
                OrderStatusBadge(status: order.status),
              ],
            ),
            const SizedBox(height: 24),
            const Text('Items',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            const SizedBox(height: 8),
            ...order.items.map((item) => ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Container(
                    width: 50,
                    height: 50,
                    color: Colors.grey.shade200,
                    child: const Icon(Icons.image,
                        color: Colors.grey), // Mock Image
                  ),
                  title: Text(item.productName),
                  subtitle: Text('Qty: ${item.quantity}'),
                  trailing: Text('${item.price.toStringAsFixed(0)} VND'),
                )),
            const Divider(height: 32),
            const Text('Shipping Information',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            const SizedBox(height: 8),
            Text(order.shippingAddress),
            const SizedBox(height: 8),
            Text('Payment Method: ${order.paymentMethod}'),
            const Divider(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Subtotal:'),
                Text(
                    '${(order.totalAmount - order.shippingFee).toStringAsFixed(0)} VND'),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Shipping Fee:'),
                Text('${order.shippingFee.toStringAsFixed(0)} VND'),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Total:',
                    style:
                        TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                Text('${order.totalAmount.toStringAsFixed(0)} VND',
                    style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Colors.blue)),
              ],
            ),
            // 1. Buy Again Button (Always visible)
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: Colors.blue,
                ),
                onPressed: () {
                  orderStore.buyAgain(order);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('Mock: Redirecting to Checkout...')),
                  );
                },
                child: const Text('Buy Again',
                    style: TextStyle(color: Colors.white, fontSize: 16)),
              ),
            ),
            const SizedBox(height: 12),

            // Return / Exchange Button (ONLY visible if Delivered)
            if (order.status == OrderStatus.delivered)
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16)),
                  onPressed: () {
                    Navigator.pushNamed(context, Routes.returnRequest,
                        arguments: order);
                  },
                  child: const Text('Return / Exchange Items',
                      style: TextStyle(color: Colors.red)),
                ),
              ),

            // Cancel Order Button (ONLY visible if Pending)
            if (order.status == OrderStatus.pending)
              SizedBox(
                width: double.infinity,
                child: TextButton(
                  style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16)),
                  onPressed: () async {
                    await orderStore.cancelOrder(order.id);
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text('Order has been canceled.')),
                      );
                      Navigator.pop(context); // Go back to the history list
                    }
                  },
                  child: const Text('Cancel Order',
                      style: TextStyle(color: Colors.grey)),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
