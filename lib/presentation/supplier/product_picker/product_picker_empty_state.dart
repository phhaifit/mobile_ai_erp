import 'package:flutter/material.dart';

class ProductPickerEmptyState extends StatelessWidget {
  const ProductPickerEmptyState({
    super.key,
    required this.hasSearchQuery,
  });

  final bool hasSearchQuery;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.inventory_2_outlined,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'No products found',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          if (hasSearchQuery)
            Text(
              'Try a different search term',
              style: Theme.of(context).textTheme.bodySmall,
            ),
        ],
      ),
    );
  }
}
