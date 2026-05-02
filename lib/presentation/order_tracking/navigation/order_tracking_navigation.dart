import 'package:flutter/material.dart';
import 'package:mobile_ai_erp/presentation/order_tracking/home/order_tracking_screen.dart';
import 'package:mobile_ai_erp/presentation/order_tracking/list/order_list_screen.dart';

class OrderTrackingNavigation {
  OrderTrackingNavigation._();

  static const String routeName = '/order-tracking';

  static Widget buildScreen(BuildContext context) {
    // Check if orderId is provided in route arguments
    final Object? args = ModalRoute.of(context)?.settings.arguments;
    if (args is Map<String, dynamic> && args.containsKey('orderId')) {
      // Show detail screen with order ID
      return const OrderTrackingScreen();
    }
    // Show list screen if no orderId provided
    return const OrderListScreen();
  }
}
