import 'package:flutter/material.dart';
import 'package:mobile_ai_erp/core/utils/price_formatter.dart';
import 'package:mobile_ai_erp/domain/entity/cart/cart_item.dart';
import 'stock_warning_badge.dart';
import 'quantity_selector.dart';

class CartItemCard extends StatelessWidget {
  final CartItem item;
  final VoidCallback onRemove;
  final Function(int) onQuantityChanged;
  final VoidCallback? onTap;
  final bool showStockWarning;
  final bool isSelected;
  final ValueChanged<bool>? onSelectChanged;
  final VoidCallback? onMoveToWishlist;

  const CartItemCard({
    Key? key,
    required this.item,
    required this.onRemove,
    required this.onQuantityChanged,
    this.onTap,
    this.showStockWarning = true,
    this.isSelected = false,
    this.onSelectChanged,
    this.onMoveToWishlist,
  }) : super(key: key);

  static const Color _accentRed = Color(0xFFC63D2F);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isCompact = constraints.maxWidth < 700;

        return Card(
          elevation: 1,
          margin: const EdgeInsets.symmetric(vertical: 8),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: GestureDetector(
            onTap: onTap,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: isSelected
                    ? Border.all(color: Colors.blue[600]!, width: 2)
                    : null,
              ),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: isCompact
                    ? _buildCompactContent(context)
                    : _buildWideContent(context),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildWideContent(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (onSelectChanged != null)
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: Checkbox(
              value: isSelected,
              onChanged: (value) => onSelectChanged!(value ?? false),
              activeColor: _accentRed,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
        _buildImage(80),
        const SizedBox(width: 12),
        Expanded(child: _buildInfoContent(compact: false)),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            _buildRemoveButton(),
            if (onMoveToWishlist != null) ...[
              const SizedBox(height: 8),
              _buildMoveToWishlistButton(),
            ],
            const SizedBox(height: 10),
            QuantitySelector(
              currentQuantity: item.quantity,
              maxQuantity: item.availableStock,
              onQuantityChanged: onQuantityChanged,
              size: 28,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildCompactContent(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (onSelectChanged != null)
              Padding(
                padding: const EdgeInsets.only(right: 8, top: 2),
                child: Checkbox(
                  value: isSelected,
                  onChanged: (value) => onSelectChanged!(value ?? false),
                  activeColor: _accentRed,
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  visualDensity: VisualDensity.compact,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            _buildImage(72),
            const SizedBox(width: 10),
            Expanded(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: _buildInfoContent(compact: true)),
                  const SizedBox(width: 8),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      _buildRemoveButton(),
                      if (onMoveToWishlist != null) ...[
                        const SizedBox(height: 6),
                        _buildMoveToWishlistButton(compact: true),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(child: _buildPriceSection(compact: true)),
            const SizedBox(width: 12),
            Flexible(
              child: Align(
                alignment: Alignment.centerRight,
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: QuantitySelector(
                    currentQuantity: item.quantity,
                    maxQuantity: item.availableStock,
                    onQuantityChanged: onQuantityChanged,
                    size: 26,
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildImage(double size) {
    final imageUrl = item.thumbnailUrl ?? '';

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: Colors.grey[100],
      ),
      child: imageUrl.isNotEmpty
          ? ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) =>
                    _buildImagePlaceholder(),
              ),
            )
          : _buildImagePlaceholder(),
    );
  }

  Widget _buildInfoContent({required bool compact}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          item.productName,
          style: TextStyle(
            fontSize: compact ? 13 : 14,
            fontWeight: FontWeight.w600,
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 4),
        if ((item.variantSummary ?? '').isNotEmpty)
          Text(
            item.variantSummary!,
            style: TextStyle(
              fontSize: compact ? 11.5 : 12,
              color: Colors.grey[600],
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        if (item.attributes.isNotEmpty) ...[
          const SizedBox(height: 4),
          Wrap(
            spacing: 6,
            runSpacing: 4,
            children: item.attributes.map((attr) {
              return Text(
                '${attr.label}: ${attr.value}',
                style: TextStyle(
                  fontSize: compact ? 11 : 12,
                  color: Colors.grey[600],
                ),
              );
            }).toList(),
          ),
        ],
        const SizedBox(height: 8),
        if (showStockWarning)
          StockWarningBadge(
            isOutOfStock: !item.isAvailable,
            isLowStock: item.stockWarning && item.isAvailable,
            availableStock: item.availableStock,
            size: compact ? 11 : 12,
          ),
        if (!compact) ...[
          const SizedBox(height: 8),
          _buildPriceSection(compact: false),
        ],
      ],
    );
  }

  Widget _buildPriceSection({required bool compact}) {
    final lineTotal = PriceFormatter.formatPrice(
      double.tryParse(item.lineTotal) ?? 0,
    );
    final hasOriginalPrice =
        item.originalPrice != null &&
        item.originalPrice != item.unitPrice &&
        item.originalPrice!.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          lineTotal,
          style: TextStyle(
            fontSize: compact ? 13 : 14,
            fontWeight: FontWeight.bold,
            color: Colors.blue,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        if (hasOriginalPrice)
          Text(
            'Original: ${PriceFormatter.formatPrice(double.tryParse(item.originalPrice!) ?? 0)}',
            style: TextStyle(
              fontSize: compact ? 11 : 12,
              color: Colors.grey[600],
              decoration: TextDecoration.lineThrough,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
      ],
    );
  }

  Widget _buildRemoveButton() {
    return Tooltip(
      message: 'Remove from cart',
      child: IconButton(
        onPressed: onRemove,
        icon: const Icon(Icons.delete_outline, color: _accentRed, size: 20),
        padding: EdgeInsets.zero,
        constraints: const BoxConstraints(),
        visualDensity: VisualDensity.compact,
      ),
    );
  }

  Widget _buildImagePlaceholder() {
    return Container(
      color: Colors.grey[100],
      child: Icon(Icons.image_not_supported_outlined, color: Colors.grey[400]),
    );
  }

  Widget _buildMoveToWishlistButton({bool compact = false}) {
    if (onMoveToWishlist == null) return const SizedBox.shrink();

    return TextButton.icon(
      onPressed: onMoveToWishlist,
      style: TextButton.styleFrom(
        padding: EdgeInsets.zero,
        minimumSize: Size.zero,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        visualDensity: VisualDensity.compact,
      ),
      icon: Icon(
        Icons.favorite_border,
        size: compact ? 16 : 18,
        color: Colors.grey[700],
      ),
      label: Text(
        'Save for later',
        style: TextStyle(
          fontSize: compact ? 11 : 12,
          color: Colors.grey[700],
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}

class CompactCartItemCard extends StatelessWidget {
  final CartItem item;
  final VoidCallback onRemove;
  final Function(int) onQuantityChanged;

  const CompactCartItemCard({
    Key? key,
    required this.item,
    required this.onRemove,
    required this.onQuantityChanged,
  }) : super(key: key);

  static const Color _accentRed = Color(0xFFC63D2F);

  @override
  Widget build(BuildContext context) {
    final imageUrl = item.thumbnailUrl ?? '';

    return ListTile(
      leading: Container(
        width: 50,
        height: 50,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(4),
          color: Colors.grey[100],
        ),
        child: imageUrl.isNotEmpty
            ? ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: Image.network(imageUrl, fit: BoxFit.cover),
              )
            : Icon(Icons.image, color: Colors.grey[400]),
      ),
      title: Text(
        item.productName,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Text(
        PriceFormatter.formatPrice(double.tryParse(item.lineTotal) ?? 0),
        style: const TextStyle(fontWeight: FontWeight.w600),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          CompactQuantitySelector(
            currentQuantity: item.quantity,
            maxQuantity: item.availableStock,
            onChanged: onQuantityChanged,
          ),
          IconButton(
            onPressed: onRemove,
            icon: const Icon(Icons.close, color: _accentRed, size: 20),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        ],
      ),
    );
  }
}
