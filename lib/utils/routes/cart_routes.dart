import 'package:flutter/material.dart';
import 'package:mobile_ai_erp/presentation/cart/screens/cart_screen.dart';

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

  /// Build checkout screen (placeholder - implement based on your requirements)
  static Widget _buildCheckoutScreen(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Checkout'),
        centerTitle: true,
      ),
      body: const Center(
        child: Text('Checkout Screen - To be implemented'),
      ),
    );
  }

  /// Build order confirmation screen (placeholder - implement based on your requirements)
  static Widget _buildOrderConfirmationScreen(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Order Confirmation'),
        centerTitle: true,
      ),
      body: const Center(
        child: Text('Order Confirmation Screen - To be implemented'),
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
