import 'dart:io';

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
    return Container(
      padding: EdgeInsets.only(left: 10.0, right: 10.0, top: 5.0, bottom: 5.0),
      child: Row(
        children: [
          productListing.imageSource != null ? 
            Image.network(
              productListing.imageSource!,
            ) : 
            Image.network('https://picsum.photos/250?image=9'), // placeholder image, replace with "no image" asset
          Column(
            children: [
              Text(
                productListing.productName,
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
              ),
              Row(
                children: [
                  Text(
                    productListing.category.name,
                    style: TextStyle(fontSize: 16),
                  ),
                  Text(
                    productListing.brand.name,
                    style: TextStyle(fontSize: 16),
                  )
                ],
              ),
              Row(
                children: [
                  Text(
                    productListing.rating.toString(),
                    style: TextStyle(fontSize: 16),
                  ), // temporary until rating image is available
                  Text(
                    productListing.price.toString(),
                    style: TextStyle(fontSize: 20),
                  ),
                  Text(
                    productListing.currency,
                    style: TextStyle(fontSize: 14),
                  )
                ],
              )
            ]
          )
        ],
      ),
    );
  }

}