import 'package:flutter/material.dart';
import 'package:mobile_ai_erp/presentation/order_tracking/home/order_tracking_screen.dart';

class OrderTrackingNavigation {
  OrderTrackingNavigation._();

  static const String routeName = '/order-tracking';

  static Widget buildScreen(BuildContext context) {
    return const OrderTrackingScreen();
  }
}
