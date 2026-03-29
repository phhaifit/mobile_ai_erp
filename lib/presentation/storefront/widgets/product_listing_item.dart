import 'package:flutter/material.dart';
import 'package:mobile_ai_erp/domain/entity/product/product.dart';
import 'package:mobile_ai_erp/utils/routes/routes.dart';

/// Widget for a product shown in homepage, product listing page (with or without search/filters), brand and collection landing pages
/// 
/// Product information provided by parent widget
class ProductListingItem extends StatelessWidget {
  const ProductListingItem({
    super.key,
    required this.productListing,
  });

  final Product productListing;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final imageSize = 120.0;

    return Card(
      color: colorScheme.surface,
      margin: EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8.0),
        side: BorderSide(color: Colors.black87, width: 1),
      ),
      child: InkWell(
        onTap: () {
          Navigator.of(context).pushNamed(Routes.productDetail, arguments: productListing.id);
        },
        child: Padding(
          padding: EdgeInsets.all(12.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Product Image
              ClipRRect(
                borderRadius: BorderRadius.circular(6.0),
                child: productListing.imageSource != null 
                  ? Image.network(
                      productListing.imageSource!,
                      width: imageSize,
                      height: imageSize,
                      fit: BoxFit.cover,
                    )
                  : Image.network(
                      'https://picsum.photos/250?image=9',
                      width: imageSize,
                      height: imageSize,
                      fit: BoxFit.cover,
                    ),
              ),
              SizedBox(width: 16.0),
              // Product Details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  spacing: 8.0,
                  children: [
                    // Product Name
                    Text(
                      productListing.productName,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    // Category and Brand
                    Row(
                      spacing: 8.0,
                      children: [
                        Flexible(
                          child: Text(
                            productListing.category.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 13,
                              color: colorScheme.onSurface.withOpacity(0.7),
                            ),
                          ),
                        ),
                        Text('•', style: TextStyle(color: colorScheme.onSurface.withOpacity(0.5))),
                        Flexible(
                          child: Text(
                            productListing.brand.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 13,
                              color: colorScheme.onSurface.withOpacity(0.7),
                            ),
                          ),
                        ),
                      ],
                    ),
                    // Rating
                    Row(
                      children: [
                        Icon(Icons.star, size: 16, color: Colors.amber),
                        SizedBox(width: 4.0),
                        Text(
                          productListing.rating.toStringAsFixed(1),
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                            color: colorScheme.onSurface,
                          ),
                        ),
                      ],
                    ),
                    // Price Row
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      spacing: 4.0,
                      children: [
                        Text(
                          productListing.price.toString(),
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                            color: colorScheme.primary,
                          ),
                        ),
                        Text(
                          productListing.currency,
                          style: TextStyle(
                            fontSize: 12,
                            color: colorScheme.onSurface.withOpacity(0.7),
                          ),
                        ),
                      ],
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