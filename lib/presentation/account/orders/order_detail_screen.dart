import 'package:flutter/material.dart';
import '../../../utils/routes/cart_routes.dart';
import '../../../../domain/entity/order/order.dart';
import '../../../../di/service_locator.dart';
import '../../../../utils/routes/routes.dart';
import '../../../../utils/formatters/currency_utils.dart';
import '../store/order_store.dart';
import '../widgets/order_status_badge.dart';

class OrderDetailScreen extends StatelessWidget {
  const OrderDetailScreen({super.key});

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
                  trailing: Text(CurrencyUtils.format(item.unitPrice)),
                )),
            const Divider(height: 32),
            const Text('Shipping Information',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            const SizedBox(height: 8),
            Text(order.shippingAddress),
            const SizedBox(height: 8),
            if (order.shippingProvince != null)
              Text('${order.shippingProvince}, ${order.shippingDistrict}, ${order.shippingWard}'),
            const Divider(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Subtotal:'),
                Text(CurrencyUtils.format(order.totalAmount - order.shippingFee)),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Shipping Fee:'),
                Text(CurrencyUtils.format(order.shippingFee)),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Total:',
                    style:
                        TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                Text(
                  CurrencyUtils.format(order.totalAmount),
                  style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Colors.blue),
                ),
              ],
            ),
            // 1. Buy Again Button (Always visible)
            const SizedBox(height: 32),
            
            // LOGIC 1: Success, Cancelled, Returned -> Buy Again
            if (order.status == OrderStatus.success || 
                order.status == OrderStatus.cancelled || 
                order.status == OrderStatus.returned)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: Colors.blue,
                  ),
                  onPressed: () async {
                    try {
                      await orderStore.reorder(order.id);
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Items added to your cart!')),
                        );
                        Navigator.pushNamed(context, CartRoutes.cartScreen);
                      }
                    } catch (e) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Failed to reorder: $e')),
                        );
                      }
                    }
                  },
                  child: const Text('Buy Again', style: TextStyle(color: Colors.white, fontSize: 16)),
                ),
              ),

            // LOGIC 2: Delivered -> Confirm Success OR Return
            if (order.status == OrderStatus.delivered) ...[
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: Colors.green,
                  ),
                  onPressed: () async {
                    try {
                      // 1. Show a loading indicator or just disable the button (optional)
                      // 2. Call the store
                      await orderStore.confirmOrder(order.id);
                      
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Order successfully confirmed! Thank you!')),
                        );
                        // Pop back to the Order History screen so it refreshes
                        Navigator.pop(context);
                      }
                    } catch (e) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Failed to confirm order: $e')),
                        );
                      }
                    }
                  },
                  child: const Text('Confirm Received', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
                  onPressed: () {
                    Navigator.pushNamed(context, Routes.returnRequest, arguments: order);
                  },
                  child: const Text('Return / Exchange Items', style: TextStyle(color: Colors.red)),
                ),
              ),
            ],

            if (order.status == OrderStatus.pending || order.status == OrderStatus.confirmed)
              SizedBox(
                width: double.infinity,
                child: TextButton(
                  style: TextButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
                  onPressed: () {
                    // Navigate to the new cancellation screen and pass the order
                    Navigator.pushNamed(context, Routes.cancelOrder, arguments: order);
                  },
                  child: const Text('Cancel Order', style: TextStyle(color: Color.fromARGB(255, 217, 97, 97), fontSize: 16)),
                ),
              ),
            // LOGIC 4: Packing, Shipping -> No buttons (Intentionally blank)
          ],
        ),
      ),
    );
  }
}
