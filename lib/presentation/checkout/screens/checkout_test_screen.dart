import 'package:flutter/material.dart';
import 'package:mobile_ai_erp/domain/entity/checkout/checkout_item.dart';
import 'package:mobile_ai_erp/utils/routes/routes.dart';

/// A screen to launch checkout for development/testing purposes
/// Provides a unified checkout flow that works for both guest and logged-in users
class CheckoutTestScreen extends StatelessWidget {
  const CheckoutTestScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Checkout'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.shopping_cart_checkout,
                size: 80,
                color: Colors.blue,
              ),
              const SizedBox(height: 24),
              const Text(
                'Start Checkout',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              const Text(
                'Proceed to checkout with sample items.\n'
                'You can enter your delivery address during checkout.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: Colors.grey),
              ),
              const SizedBox(height: 32),
              ElevatedButton.icon(
                onPressed: () => _startCheckout(context),
                icon: const Icon(Icons.arrow_forward),
                label: const Text('Proceed to Checkout'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 16,
                  ),
                ),
              ),
              const SizedBox(height: 48),
              const Divider(),
              const SizedBox(height: 16),
              const Text(
                'Test Information',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 12),
              _buildInfoItem(Icons.local_shipping, 'Sample shipping methods available'),
              _buildInfoItem(Icons.payment, 'Multiple payment options (COD, Bank, E-wallet)'),
              _buildInfoItem(Icons.confirmation_number, 'Test coupons: SAVE10, FREESHIP, DISCOUNT20'),
              _buildInfoItem(Icons.location_on, 'AI-powered smart address parsing'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoItem(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 18, color: Colors.blue),
          const SizedBox(width: 8),
          Text(text, style: const TextStyle(fontSize: 13)),
        ],
      ),
    );
  }

  void _startCheckout(BuildContext context) {
    final items = _createSampleItems();
    Routes.navigateToCheckout(context, items: items);
  }

  List<CheckoutItem> _createSampleItems() {
    return [
      const CheckoutItem(
        id: 'item-1',
        productId: 'prod-001',
        productName: 'Wireless Bluetooth Headphones',
        sku: 'WBH-001',
        quantity: 1,
        unitPrice: 79.99,
        imageUrl: 'https://example.com/headphones.jpg',
        variantInfo: {'Color': 'Black', 'Size': 'One Size'},
        weight: 0.5,
      ),
      const CheckoutItem(
        id: 'item-2',
        productId: 'prod-002',
        productName: 'USB-C Charging Cable (3-pack)',
        sku: 'USBC-003',
        quantity: 2,
        unitPrice: 14.99,
        imageUrl: 'https://example.com/cable.jpg',
        variantInfo: {'Length': '6ft'},
        weight: 0.2,
      ),
      const CheckoutItem(
        id: 'item-3',
        productId: 'prod-003',
        productName: 'Phone Case - Premium Leather',
        sku: 'PC-PL-001',
        quantity: 1,
        unitPrice: 29.99,
        imageUrl: 'https://example.com/case.jpg',
        variantInfo: {'Color': 'Brown', 'Model': 'iPhone 15 Pro'},
        weight: 0.1,
      ),
    ];
  }
}
