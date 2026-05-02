import 'package:flutter/material.dart';
import '../../../../domain/entity/order/order.dart';

class OrderStatusBadge extends StatelessWidget {
  final OrderStatus status;

  const OrderStatusBadge({
    super.key,
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    Color bgColor;
    String text;

    switch (status) {
      case OrderStatus.delivered:
        bgColor = Colors.green.shade100;
        text = 'Delivered';
      case OrderStatus.pending:
        bgColor = Colors.orange.shade100;
        text = 'Pending';
      case OrderStatus.processing:
        bgColor = Colors.amber.shade100;
        text = 'Processing';
      case OrderStatus.confirmed:
        bgColor = Colors.teal.shade100;
        text = 'Confirmed';
      case OrderStatus.shipped:
        bgColor = Colors.blue.shade100;
        text = 'Shipped';
      case OrderStatus.canceled:
        bgColor = Colors.red.shade100;
        text = 'Canceled';
      case OrderStatus.returned:
        bgColor = Colors.purple.shade100;
        text = 'Returned';
    }

    return Chip(
      label: Text(text,
          style: TextStyle(
              color: Colors.black, fontSize: 12)),
      backgroundColor: bgColor,
      visualDensity: VisualDensity.compact,
    );
  }
}
