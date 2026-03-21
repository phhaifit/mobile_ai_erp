import 'package:flutter/material.dart';

class FulfillmentDetailScreen extends StatefulWidget {
  @override
  State<FulfillmentDetailScreen> createState() =>
      _FulfillmentDetailScreenState();
}

class _FulfillmentDetailScreenState extends State<FulfillmentDetailScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Order Detail')),
      body: const Center(child: Text('Order Detail')),
    );
  }
}
