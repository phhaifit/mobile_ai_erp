import 'package:flutter/material.dart';
import '../../../../domain/entity/order/order.dart';

class OrderStatusBadge extends StatelessWidget {
  final OrderStatus status;

  const OrderStatusBadge({Key? key, required this.status}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Color bgColor;
    String text;

    switch (status) {
      case OrderStatus.delivered:
        bgColor = Colors.green.shade100;
        text = 'Delivered';
        break;
      case OrderStatus.pending:
        bgColor = Colors.orange.shade100;
        text = 'Pending';
        break;
      case OrderStatus.shipped:
        bgColor = Colors.blue.shade100;
        text = 'Shipped';
        break;
      case OrderStatus.canceled:
        bgColor = Colors.red.shade100;
        text = 'Canceled';
        break;
      case OrderStatus.returned:
        bgColor = Colors.purple.shade100;
        text = 'Returned';
        break;
    }

    return Chip(
      label: Text(text,
          style: TextStyle(
              color: bgColor.withOpacity(1.0).withBlue(150), fontSize: 12)),
      backgroundColor: bgColor,
      visualDensity: VisualDensity.compact,
    );
  }
}
