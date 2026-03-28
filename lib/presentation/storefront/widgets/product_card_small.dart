import 'package:flutter/material.dart';

class ProductCardSmall extends StatelessWidget {
  const ProductCardSmall({super.key, required this.productId, required this.productName, this.imageSource});

  final String productId;
  final String productName;
  final String? imageSource;

  @override 
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return SizedBox(
      width: 300,
      height: 400,
      child: Card(
        child: Column(
          spacing: 10.0,
          children: [
            Image.network(imageSource ?? 'https://picsum.photos/250?image=9'), // placeholder image, replace with "no image" asset
            Text(productName, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: colorScheme.onSurface),),
          ]
        ),
      )
    );
  }
}