import 'package:flutter/material.dart';
import '../../../domain/entity/storefront_order/order.dart';

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
        break;
      case OrderStatus.confirmed:
        bgColor = Colors.blue.shade100;
        text = 'Confirmed';
        break;
      case OrderStatus.packing:
        bgColor = Colors.blue.shade100;
        text = 'Packing';
        break;
      case OrderStatus.shipping:
        bgColor = Colors.blue.shade100;
        text = 'Shipping';
        break;
      case OrderStatus.cancelled:
        bgColor = Colors.red.shade100;
        text = 'Cancelled';
        break;
      case OrderStatus.returned:
        bgColor = Colors.purple.shade100;
        text = 'Returned';
        break;
      case OrderStatus.success:
        bgColor = Colors.green.shade200;
        text = 'Success';
        break;
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
