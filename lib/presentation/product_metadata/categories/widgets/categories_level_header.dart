import 'package:flutter/material.dart';
import 'package:mobile_ai_erp/domain/entity/product_metadata/category.dart';

class CategoriesLevelHeader extends StatelessWidget {
  const CategoriesLevelHeader({
    super.key,
    required this.path,
    required this.onNavigateToLevel,
  });

  final List<Category> path;
  final ValueChanged<String?> onNavigateToLevel;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textStyle = theme.textTheme.titleMedium?.copyWith(
      color: theme.colorScheme.primary,
      fontWeight: FontWeight.bold,
    );

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: <Widget>[
          TextButton(
            onPressed: () => onNavigateToLevel(null),
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 4),
            ),
            child: Text('Root', style: textStyle),
          ),
          for (final category in path) ...<Widget>[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Icon(
                Icons.chevron_right,
                size: 20,
                color: Colors.grey.shade400,
              ),
            ),
            TextButton(
              onPressed: () => onNavigateToLevel(category.id),
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 4),
              ),
              child: Text(category.name, style: textStyle),
            ),
          ],
        ],
      ),
    );
  }
}
