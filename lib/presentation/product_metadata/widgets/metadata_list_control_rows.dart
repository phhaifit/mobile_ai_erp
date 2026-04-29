import 'package:flutter/material.dart';
import 'package:mobile_ai_erp/presentation/product_metadata/widgets/metadata_action_buttons.dart';
import 'package:mobile_ai_erp/presentation/product_metadata/widgets/metadata_search_sheet.dart';

class MetadataTabletListControls extends StatelessWidget {
  const MetadataTabletListControls({
    super.key,
    required this.searchController,
    required this.onSearchChanged,
    required this.searchHint,
    required this.hasActiveFilter,
    required this.hasCustomSort,
    this.viewSwitchIcon,
    this.viewSwitchTooltip,
    this.onSwitchView,
    this.onOpenFilter,
    this.onOpenSort,
  });

  final TextEditingController searchController;
  final ValueChanged<String> onSearchChanged;
  final String searchHint;
  final bool hasActiveFilter;
  final bool hasCustomSort;
  final IconData? viewSwitchIcon;
  final String? viewSwitchTooltip;
  final VoidCallback? onSwitchView;
  final VoidCallback? onOpenFilter;
  final VoidCallback? onOpenSort;

  @override
  Widget build(BuildContext context) => Row(
    children: <Widget>[
      Expanded(child: MetadataSearchField(searchController: searchController, searchHint: searchHint, showHelperText: false, onSearchChanged: onSearchChanged)),
      if (onSwitchView != null && viewSwitchIcon != null) ...<Widget>[
        const SizedBox(width: 12),
        MetadataToolbarButton(icon: viewSwitchIcon!, label: viewSwitchTooltip ?? 'Switch view', isActive: false, onPressed: onSwitchView!),
      ],
      if (onOpenFilter != null) ...<Widget>[
        const SizedBox(width: 12),
        MetadataToolbarButton(icon: Icons.filter_list_outlined, label: 'Filter', isActive: hasActiveFilter, onPressed: onOpenFilter!),
      ],
      if (onOpenSort != null) ...<Widget>[
        const SizedBox(width: 12),
        MetadataToolbarButton(icon: Icons.sort_outlined, label: 'Sort', isActive: hasCustomSort, onPressed: onOpenSort!),
      ],
    ],
  );
}

class MetadataCompactListControls extends StatelessWidget {
  const MetadataCompactListControls({
    super.key,
    required this.searchController,
    required this.onSearchChanged,
    required this.searchHint,
    required this.resultLabel,
    required this.resultLabelStyle,
    required this.hasActiveFilter,
    required this.hasCustomSort,
    this.viewSwitchIcon,
    this.viewSwitchTooltip,
    this.onSwitchView,
    this.onOpenFilter,
    this.onOpenSort,
  });

  final TextEditingController searchController;
  final ValueChanged<String> onSearchChanged;
  final String searchHint;
  final String resultLabel;
  final TextStyle? resultLabelStyle;
  final bool hasActiveFilter;
  final bool hasCustomSort;
  final IconData? viewSwitchIcon;
  final String? viewSwitchTooltip;
  final VoidCallback? onSwitchView;
  final VoidCallback? onOpenFilter;
  final VoidCallback? onOpenSort;

  @override
  Widget build(BuildContext context) => Row(
    children: <Widget>[
      Expanded(child: Text(resultLabel, style: resultLabelStyle)),
      ValueListenableBuilder<TextEditingValue>(
        valueListenable: searchController,
        builder: (context, value, _) => MetadataActionIconButton(
          icon: Icons.search,
          tooltip: 'Search',
          isActive: value.text.trim().isNotEmpty,
          onPressed: () => MetadataSearchSheet.show(context, searchController: searchController, searchHint: searchHint, onSearchChanged: onSearchChanged),
        ),
      ),
      if (onSwitchView != null && viewSwitchIcon != null) MetadataActionIconButton(icon: viewSwitchIcon!, tooltip: viewSwitchTooltip ?? 'Switch view', isActive: false, onPressed: onSwitchView!),
      if (onOpenFilter != null) MetadataActionIconButton(icon: Icons.filter_list_outlined, tooltip: 'Filter', isActive: hasActiveFilter, onPressed: onOpenFilter!),
      if (onOpenSort != null) MetadataActionIconButton(icon: Icons.sort_outlined, tooltip: 'Sort', isActive: hasCustomSort, onPressed: onOpenSort!),
    ],
  );
}
