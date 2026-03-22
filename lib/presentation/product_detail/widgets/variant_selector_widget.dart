import 'package:flutter/material.dart';
import 'package:mobile_ai_erp/domain/entity/product_detail/product_detail.dart';

class VariantSelectorWidget extends StatelessWidget {
  final List<ProductColor> availableColors;
  final String? selectedColorName;
  final List<String> availableSizes;
  final String? selectedSize;
  final bool Function(String size) isSizeInStock;
  final bool Function(String size) isSizeLowStock;
  final ValueChanged<String> onColorSelected;
  final ValueChanged<String> onSizeSelected;

  const VariantSelectorWidget({
    super.key,
    required this.availableColors,
    required this.selectedColorName,
    required this.availableSizes,
    required this.selectedSize,
    required this.isSizeInStock,
    required this.isSizeLowStock,
    required this.onColorSelected,
    required this.onSizeSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (availableColors.isNotEmpty) ...[
          _buildSectionLabel(context, 'Color', selectedColorName),
          const SizedBox(height: 10),
          _buildColorRow(context),
          const SizedBox(height: 20),
        ],
        if (availableSizes.isNotEmpty) ...[
          _buildSectionLabel(context, 'Size', null),
          const SizedBox(height: 10),
          _buildSizeRow(context),
        ],
      ],
    );
  }

  Widget _buildSectionLabel(BuildContext context, String label, String? value) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Text(
          label,
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        if (value != null) ...[
          const SizedBox(width: 8),
          Text(
            value,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildColorRow(BuildContext context) {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: availableColors.map((color) {
        final isSelected = color.name == selectedColorName;
        return _ColorSwatch(
          color: color,
          isSelected: isSelected,
          onTap: () => onColorSelected(color.name),
        );
      }).toList(),
    );
  }

  Widget _buildSizeRow(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: availableSizes.map((size) {
        final inStock = isSizeInStock(size);
        final lowStock = isSizeLowStock(size);
        final isSelected = size == selectedSize;
        return _SizeChip(
          size: size,
          isSelected: isSelected,
          inStock: inStock,
          lowStock: lowStock,
          onTap: inStock ? () => onSizeSelected(size) : null,
        );
      }).toList(),
    );
  }
}

class _ColorSwatch extends StatelessWidget {
  final ProductColor color;
  final bool isSelected;
  final VoidCallback onTap;

  const _ColorSwatch({
    required this.color,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isLight = ThemeData.estimateBrightnessForColor(color.color) ==
        Brightness.light;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: color.color,
          border: Border.all(
            color: isSelected
                ? colorScheme.primary
                : colorScheme.onSurface.withValues(alpha: 0.2),
            width: isSelected ? 2.5 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: colorScheme.primary.withValues(alpha: 0.3),
                    blurRadius: 8,
                    spreadRadius: 1,
                  )
                ]
              : null,
        ),
        child: isSelected
            ? Icon(
                Icons.check,
                size: 20,
                color: isLight ? Colors.black87 : Colors.white,
              )
            : null,
      ),
    );
  }
}

class _SizeChip extends StatelessWidget {
  final String size;
  final bool isSelected;
  final bool inStock;
  final bool lowStock;
  final VoidCallback? onTap;

  const _SizeChip({
    required this.size,
    required this.isSelected,
    required this.inStock,
    required this.lowStock,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final theme = Theme.of(context);

    Color backgroundColor;
    Color textColor;
    Color borderColor;

    if (!inStock) {
      backgroundColor = colorScheme.surface;
      textColor = colorScheme.onSurface.withValues(alpha: 0.3);
      borderColor = colorScheme.onSurface.withValues(alpha: 0.1);
    } else if (isSelected) {
      backgroundColor = colorScheme.primary;
      textColor = colorScheme.onPrimary;
      borderColor = colorScheme.primary;
    } else {
      backgroundColor = colorScheme.surface;
      textColor = colorScheme.onSurface;
      borderColor = colorScheme.onSurface.withValues(alpha: 0.25);
    }

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        constraints: const BoxConstraints(minWidth: 56),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: borderColor, width: isSelected ? 2 : 1),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              size,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: textColor,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                decoration: inStock ? null : TextDecoration.lineThrough,
              ),
            ),
            if (lowStock && inStock)
              Padding(
                padding: const EdgeInsets.only(top: 2),
                child: Text(
                  'Low stock',
                  style: theme.textTheme.labelSmall?.copyWith(
                    fontSize: 9,
                    color: Colors.orange.shade700,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
