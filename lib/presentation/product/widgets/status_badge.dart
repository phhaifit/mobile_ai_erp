import 'package:flutter/material.dart';
import 'package:mobile_ai_erp/domain/entity/product/product_status.dart';

class StatusBadge extends StatelessWidget {
  final ProductStatus status;

  const StatusBadge({Key? key, required this.status}) : super(key: key);

  Color get _backgroundColor {
    switch (status) {
      case ProductStatus.NEW:
        return Colors.blue[100] ?? Colors.blue;
      case ProductStatus.ACTIVE:
        return Colors.green[100] ?? Colors.green;
      case ProductStatus.OUT_OF_STOCK:
        return Colors.orange[100] ?? Colors.orange;
      case ProductStatus.DISCONTINUED:
        return Colors.red[100] ?? Colors.red;
    }
  }

  Color get _textColor {
    switch (status) {
      case ProductStatus.NEW:
        return Colors.blue[700] ?? Colors.blue;
      case ProductStatus.ACTIVE:
        return Colors.green[700] ?? Colors.green;
      case ProductStatus.OUT_OF_STOCK:
        return Colors.orange[700] ?? Colors.orange;
      case ProductStatus.DISCONTINUED:
        return Colors.red[700] ?? Colors.red;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: _backgroundColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        status.displayName,
        style: TextStyle(
          color: _textColor,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
