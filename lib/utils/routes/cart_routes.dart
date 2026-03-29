import 'package:flutter/material.dart';
import 'package:mobile_ai_erp/presentation/cart/screens/cart_screen.dart';
import 'package:mobile_ai_erp/presentation/checkout/screens/checkout_screen.dart';
import 'package:mobile_ai_erp/domain/entity/checkout/checkout_item.dart';

/// Cart feature routes configuration
class CartRoutes {
  /// Route name for cart screen
  static const String cartScreen = '/cart';

  /// Route name for checkout screen
  static const String checkout = '/checkout';

  /// Route name for order confirmation screen
  static const String orderConfirmation = '/order-confirmation';

  /// Route name for cart with drawer
  static const String cartWithDrawer = '/cart-drawer';

  /// Generate cart routes
  static Map<String, WidgetBuilder> getRoutes() {
    return {
      cartScreen: (context) => const CartScreen(),
      cartWithDrawer: (context) => const CartScreenWithDrawer(),
      checkout: (context) => _buildCheckoutScreen(context),
      orderConfirmation: (context) => _buildOrderConfirmationScreen(context),
    };
  }

  /// Build checkout screen from cart data
  static Widget _buildCheckoutScreen(BuildContext context) {
    // Get arguments passed from cart
    final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    
    // Extract checkout items from cart data
    List<CheckoutItem> checkoutItems = [];
    String? customerId;
    String? appliedCouponCode;
    
    if (args != null) {
      final cartData = args['cartData'] as Map<String, dynamic>?;
      if (cartData != null) {
        final items = cartData['items'] as List<dynamic>? ?? [];
        checkoutItems = items
            .map((item) => CheckoutItem.fromCheckoutData(item as Map<String, dynamic>))
            .toList();
        customerId = cartData['userId'] as String?;
        // Extract couponCode from cartData (single source of truth)
        appliedCouponCode = cartData['couponCode'] as String?;
      }
    }

    return CheckoutScreen(
      items: checkoutItems,
      customerId: customerId,
      appliedCouponCode: appliedCouponCode,
    );
  }

  /// Build order confirmation screen
  static Widget _buildOrderConfirmationScreen(BuildContext context) {
    final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Order Confirmation'),
        centerTitle: true,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.check_circle_outline,
              size: 80,
              color: Colors.green,
            ),
            const SizedBox(height: 24),
            const Text(
              'Order Placed Successfully!',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            if (args != null) ...[
              Text(
                'Order ID: ${args['orderId'] ?? "N/A"}',
                style: const TextStyle(fontSize: 16, color: Colors.grey),
              ),
            ],
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Continue Shopping'),
            ),
          ],
        ),
      ),
    );
  }

  /// Navigate to cart screen
  static Future<dynamic> navigateToCart(BuildContext context) {
    return Navigator.of(context).pushNamed(cartScreen);
  }

  /// Navigate to cart with drawer
  static Future<dynamic> navigateToCartWithDrawer(BuildContext context) {
    return Navigator.of(context).pushNamed(cartWithDrawer);
  }

  /// Navigate to checkout screen
  static Future<dynamic> navigateToCheckout(
    BuildContext context, {
    Map<String, dynamic>? arguments,
  }) {
    return Navigator.of(context).pushNamed(
      checkout,
      arguments: arguments,
    );
  }

  /// Navigate to order confirmation screen
  static Future<dynamic> navigateToOrderConfirmation(
    BuildContext context, {
    Map<String, dynamic>? arguments,
  }) {
    return Navigator.of(context).pushNamed(
      orderConfirmation,
      arguments: arguments,
    );
  }

  /// Navigate to cart with replacement (replaces current route)
  static Future<dynamic> replaceWithCart(BuildContext context) {
    return Navigator.of(context).pushReplacementNamed(cartScreen);
  }

  /// Navigate and remove all routes until cart screen
  static Future<dynamic> navigateToCartAndClearStack(BuildContext context) {
    return Navigator.of(context).pushNamedAndRemoveUntil(
      cartScreen,
      (Route<dynamic> route) => false,
    );
  }
}
