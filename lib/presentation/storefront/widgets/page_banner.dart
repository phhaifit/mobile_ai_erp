import 'package:flutter/material.dart';

class PageBanner extends StatelessWidget {
  const PageBanner({super.key, required this.imageSource, required this.heading});

  final String? imageSource;
  final String heading;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      margin: EdgeInsets.all(5.0),
      decoration: imageSource != null
        ? BoxDecoration(
            image: DecorationImage(image: NetworkImage(imageSource!), fit: BoxFit.cover),
          )
        : null,
      color: imageSource == null ? colorScheme.surface : null, // fallback color if no image
      alignment: Alignment.center,
      child: Text(
        heading, 
        // style: TextStyle(
        //   fontSize: 36.0, 
        //   color: colorScheme.onSurface, 
        //   backgroundColor: colorScheme.surface
        // )
        style: theme.textTheme.headlineLarge
      ),
    );
  }
}