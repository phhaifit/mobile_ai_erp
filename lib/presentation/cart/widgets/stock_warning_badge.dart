import 'package:flutter/material.dart';

/// Badge widget to display stock status with visual indicators
class StockWarningBadge extends StatelessWidget {
  final bool isOutOfStock;
  final bool isLowStock;
  final int? availableStock;
  final double? size;
  final EdgeInsets? padding;

  const StockWarningBadge({
    Key? key,
    this.isOutOfStock = false,
    this.isLowStock = false,
    this.availableStock,
    this.size,
    this.padding,
  }) : super(key: key);

  /// Get badge color based on stock status
  Color get _badgeColor {
    if (isOutOfStock) return Colors.red[600]!;
    if (isLowStock) return Colors.orange[600]!;
    return Colors.green[600]!;
  }

  /// Get badge text label
  String get _badgeLabel {
    if (isOutOfStock) return 'Out of Stock';
    if (isLowStock && availableStock != null) {
      return 'Only $availableStock left';
    }
    return 'In Stock';
  }

  /// Get badge icon
  IconData get _badgeIcon {
    if (isOutOfStock) return Icons.error_outline;
    if (isLowStock) return Icons.warning_amber;
    return Icons.check_circle_outline;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding:
          padding ?? const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: _badgeColor.withOpacity(0.15),
        border: Border.all(color: _badgeColor, width: 1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(_badgeIcon, color: _badgeColor, size: size ?? 14),
          const SizedBox(width: 4),
          Flexible(
            child: Text(
              _badgeLabel,
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
              style: TextStyle(
                color: _badgeColor,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Compact stock status indicator (dot only)
class StockStatusIndicator extends StatelessWidget {
  final bool isOutOfStock;
  final bool isLowStock;
  final double size;

  const StockStatusIndicator({
    Key? key,
    this.isOutOfStock = false,
    this.isLowStock = false,
    this.size = 8,
  }) : super(key: key);

  Color get _indicatorColor {
    if (isOutOfStock) return Colors.red[600]!;
    if (isLowStock) return Colors.orange[600]!;
    return Colors.green[600]!;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(color: _indicatorColor, shape: BoxShape.circle),
    );
  }
}
