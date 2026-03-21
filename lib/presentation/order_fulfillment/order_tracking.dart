import 'package:flutter/material.dart';

class OrderTrackingScreen extends StatefulWidget {
  @override
  State<OrderTrackingScreen> createState() => _OrderTrackingScreenState();
}

class _OrderTrackingScreenState extends State<OrderTrackingScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Order Tracking')),
      body: const Center(child: Text('Order Tracking')),
    );
  }
}
