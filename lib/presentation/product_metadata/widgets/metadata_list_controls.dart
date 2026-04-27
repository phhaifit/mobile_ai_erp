import 'package:flutter/material.dart';
import 'package:mobile_ai_erp/presentation/product_metadata/widgets/metadata_list_control_rows.dart';

class MetadataListControls extends StatelessWidget {
  const MetadataListControls({
    super.key,
    required this.searchController,
    required this.onSearchChanged,
    required this.searchHint,
    required this.resultLabel,
    this.hasActiveFilter = false,
    this.hasCustomSort = false,
    this.onOpenFilter,
    this.onOpenSort,
  });

  final TextEditingController searchController;
  final ValueChanged<String> onSearchChanged;
  final String searchHint;
  final String resultLabel;
  final bool hasActiveFilter;
  final bool hasCustomSort;
  final VoidCallback? onOpenFilter;
  final VoidCallback? onOpenSort;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final resultLabelStyle = theme.textTheme.labelSmall?.copyWith(
      color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.74),
      fontWeight: FontWeight.w500,
      letterSpacing: 0.1,
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        final isTablet = constraints.maxWidth >= 720;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            if (isTablet)
              MetadataTabletListControls(
                searchController: searchController,
                onSearchChanged: onSearchChanged,
                searchHint: searchHint,
                hasActiveFilter: hasActiveFilter,
                hasCustomSort: hasCustomSort,
                onOpenFilter: onOpenFilter,
                onOpenSort: onOpenSort,
              )
            else
              MetadataCompactListControls(
                searchController: searchController,
                onSearchChanged: onSearchChanged,
                searchHint: searchHint,
                resultLabel: resultLabel,
                resultLabelStyle: resultLabelStyle,
                hasActiveFilter: hasActiveFilter,
                hasCustomSort: hasCustomSort,
                onOpenFilter: onOpenFilter,
                onOpenSort: onOpenSort,
              ),
            if (isTablet) ...<Widget>[
              const SizedBox(height: 12),
              Text(
                resultLabel,
                style: resultLabelStyle,
              ),
            ],
          ],
        );
      },
    );
  }
}
