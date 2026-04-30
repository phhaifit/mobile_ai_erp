import 'package:flutter/material.dart';
import 'package:mobile_ai_erp/utils/routes/routes.dart';
import 'package:mobile_ai_erp/presentation/storefront/widgets/storefront_ui.dart';

class ProductCardSmall extends StatelessWidget {
  const ProductCardSmall({
    super.key,
    required this.productId,
    required this.productName,
    this.imageSource,
  });

  final String productId;
  final String productName;
  final String? imageSource;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return SizedBox(
      width: 196,
      child: Card(
        clipBehavior: Clip.antiAlias,
        margin: EdgeInsets.zero,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: BorderSide(
            color: colorScheme.outlineVariant.withValues(alpha: 0.28),
          ),
        ),
        child: InkWell(
          onTap: () {
            Navigator.of(
              context,
            ).pushNamed(Routes.productDetail, arguments: productId);
          },
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Stack(
                children: [
                  StorefrontNetworkImage(
                    imageUrl: imageSource,
                    width: 196,
                    height: 188,
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(24),
                    ),
                  ),
                  Positioned(
                    top: 12,
                    left: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.92),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        'Discover',
                        style: theme.textTheme.labelLarge?.copyWith(
                          fontSize: 11,
                          color: colorScheme.primary,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(14, 14, 14, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      productName,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: colorScheme.onSurface,
                        height: 1.35,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Tap to view product details',
                      style: theme.textTheme.bodySmall?.copyWith(
                        fontSize: 12,
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
