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
      color: Colors.red,
      padding: EdgeInsets.only(left: 10.0, right: 10.0, top: 5.0, bottom: 5.0),
      margin: EdgeInsets.only(bottom: 10.0),
      height: MediaQuery.of(context).size.height * 0.2,
      alignment: Alignment.centerLeft,
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
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
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