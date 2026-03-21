import 'package:flutter/material.dart';

class FulfillmentListScreen extends StatefulWidget {
  @override
  State<FulfillmentListScreen> createState() => _FulfillmentListScreenState();
}

class _FulfillmentListScreenState extends State<FulfillmentListScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Order Fulfillment')),
      body: const Center(child: Text('Fulfillment List')),
    );
  }
}
