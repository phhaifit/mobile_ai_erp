import 'package:flutter/material.dart';

/// Widget for selecting product quantity with increment/decrement buttons
class QuantitySelector extends StatelessWidget {
  final int currentQuantity;
  final int maxQuantity;
  final int minQuantity;
  final ValueChanged<int> onQuantityChanged;
  final bool enabled;
  final double size;
  final Color? activeColor;
  final Color? disabledColor;

  const QuantitySelector({
    Key? key,
    required this.currentQuantity,
    required this.maxQuantity,
    this.minQuantity = 1,
    required this.onQuantityChanged,
    this.enabled = true,
    this.size = 36,
    this.activeColor,
    this.disabledColor,
  }) : super(key: key);

  bool get canDecrement => currentQuantity > minQuantity && enabled;
  bool get canIncrement => currentQuantity < maxQuantity && enabled;

  void _handleDecrement() {
    if (canDecrement) {
      onQuantityChanged(currentQuantity - 1);
    }
  }

  void _handleIncrement() {
    if (canIncrement) {
      onQuantityChanged(currentQuantity + 1);
    }
  }

  Color get _buttonColor => enabled
      ? (activeColor ?? Colors.blue[600]!)
      : (disabledColor ?? Colors.grey[300]!);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Decrement button
          SizedBox(
            width: size,
            height: size,
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: _handleDecrement,
                child: Icon(
                  Icons.remove,
                  size: 16,
                  color: canDecrement ? _buttonColor : Colors.grey[400],
                ),
              ),
            ),
          ),
          // Quantity display
          Container(
            width: 50,
            height: size,
            decoration: BoxDecoration(
              border: Border(
                left: BorderSide(color: Colors.grey[300]!),
                right: BorderSide(color: Colors.grey[300]!),
              ),
            ),
            child: Center(
              child: Text(
                currentQuantity.toString(),
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          // Increment button
          SizedBox(
            width: size,
            height: size,
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: _handleIncrement,
                child: Icon(
                  Icons.add,
                  size: 16,
                  color: canIncrement ? _buttonColor : Colors.grey[400],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Compact quantity selector (minimal design)
class CompactQuantitySelector extends StatelessWidget {
  final int currentQuantity;
  final int maxQuantity;
  final ValueChanged<int> onChanged;

  const CompactQuantitySelector({
    Key? key,
    required this.currentQuantity,
    required this.maxQuantity,
    required this.onChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        GestureDetector(
          onTap:
              currentQuantity > 1 ? () => onChanged(currentQuantity - 1) : null,
          child: Icon(
            Icons.remove_circle_outline,
            size: 20,
            color: currentQuantity > 1 ? Colors.blue : Colors.grey,
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Text(
            currentQuantity.toString(),
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
        ),
        GestureDetector(
          onTap: currentQuantity < maxQuantity
              ? () => onChanged(currentQuantity + 1)
              : null,
          child: Icon(
            Icons.add_circle_outline,
            size: 20,
            color: currentQuantity < maxQuantity ? Colors.blue : Colors.grey,
          ),
        ),
      ],
    );
  }
}
