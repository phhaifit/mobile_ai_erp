import 'package:flutter/material.dart';
import 'package:mobile_ai_erp/domain/entity/product/product.dart';

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

    return Card(
      color: colorScheme.surface,
      margin: EdgeInsets.all(10.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8.0),
        side: BorderSide(color: Colors.black87, width: 1),
      ),
      child: Padding(
        padding: EdgeInsets.only(left: 10.0, right: 10.0, top: 5.0, bottom: 5.0), 
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            productListing.imageSource != null ? 
              Image.network(
                productListing.imageSource!,
                width: MediaQuery.of(context).size.width * 0.15,
                height: MediaQuery.of(context).size.height * 0.15,
              ) : 
              Image.network(
                'https://picsum.photos/250?image=9',
                width: MediaQuery.of(context).size.width * 0.15,
                height: MediaQuery.of(context).size.height * 0.15,
              ), // placeholder image, replace with "no image" asset
            Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              spacing: 5.0,
              children: [
                Text(
                  productListing.productName,
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: colorScheme.onSurface),
                ),
                Row(
                  children: [
                    Text(
                      productListing.category.name,
                      style: TextStyle(fontSize: 16, color: colorScheme.onSurface),
                    ),
                    Text(
                      productListing.brand.name,
                      style: TextStyle(fontSize: 16, color: colorScheme.onSurface),
                    )
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  spacing: 10.0,
                  children: [
                    Text(
                      productListing.rating.toString(),
                      style: TextStyle(fontSize: 16, color: colorScheme.onSurface),
                    ), // temporary until rating image is available
                    Text(
                      productListing.price.toString(),
                      style: TextStyle(fontSize: 20, color: colorScheme.onSurface ),
                    ),
                    Text(
                      productListing.currency,
                      style: TextStyle(fontSize: 14, color: colorScheme.onSurface),
                    )
                  ],
                )
              ]
            )
          ],
        )
      ),
    );
  }

}