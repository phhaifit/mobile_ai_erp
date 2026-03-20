import 'package:flutter/material.dart';

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
              Row(
                children: <Widget>[
                  Expanded(
                    child: TextField(
                      controller: searchController,
                      onChanged: onSearchChanged,
                      decoration: _searchDecoration(
                        searchHint: searchHint,
                        showHelperText: false,
                      ),
                    ),
                  ),
                  if (onOpenFilter != null) ...<Widget>[
                    const SizedBox(width: 12),
                    _ToolbarButton(
                      icon: Icons.filter_list_outlined,
                      label: 'Filter',
                      isActive: hasActiveFilter,
                      onPressed: onOpenFilter!,
                    ),
                  ],
                  if (onOpenSort != null) ...<Widget>[
                    const SizedBox(width: 12),
                    _ToolbarButton(
                      icon: Icons.sort_outlined,
                      label: 'Sort',
                      isActive: hasCustomSort,
                      onPressed: onOpenSort!,
                    ),
                  ],
                ],
              )
            else
              Row(
                children: <Widget>[
                  Expanded(
                    child: Text(
                      resultLabel,
                      style: resultLabelStyle,
                    ),
                  ),
                  _ActionIconButton(
                    icon: Icons.search,
                    tooltip: 'Search',
                    isActive: searchController.text.trim().isNotEmpty,
                    onPressed: () => _openSearchSheet(context),
                  ),
                  if (onOpenFilter != null)
                    _ActionIconButton(
                      icon: Icons.filter_list_outlined,
                      tooltip: 'Filter',
                      isActive: hasActiveFilter,
                      onPressed: onOpenFilter!,
                    ),
                  if (onOpenSort != null)
                    _ActionIconButton(
                      icon: Icons.sort_outlined,
                      tooltip: 'Sort',
                      isActive: hasCustomSort,
                      onPressed: onOpenSort!,
                    ),
                ],
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

  Future<void> _openSearchSheet(BuildContext context) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return Padding(
          padding: EdgeInsets.fromLTRB(
            16,
            16,
            16,
            16 + MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                'Search',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: searchController,
                autofocus: true,
                onChanged: onSearchChanged,
                decoration: _searchDecoration(
                  searchHint: searchHint,
                  showHelperText: true,
                  onClear: () {
                    searchController.clear();
                    onSearchChanged('');
                    Navigator.of(context).pop();
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  InputDecoration _searchDecoration({
    required String searchHint,
    required bool showHelperText,
    VoidCallback? onClear,
  }) {
    return InputDecoration(
      hintText: showHelperText ? 'Search' : searchHint,
      hintMaxLines: 2,
      helperText: showHelperText ? searchHint : null,
      helperMaxLines: 3,
      prefixIcon: const Icon(Icons.search),
      border: const OutlineInputBorder(),
      suffixIcon: searchController.text.isEmpty
          ? null
          : IconButton(
              onPressed: onClear ??
                  () {
                    searchController.clear();
                    onSearchChanged('');
                  },
              icon: const Icon(Icons.close),
              tooltip: 'Clear search',
            ),
    );
  }
}

class _ToolbarButton extends StatelessWidget {
  const _ToolbarButton({
    required this.icon,
    required this.label,
    required this.isActive,
    required this.onPressed,
  });

  final IconData icon;
  final String label;
  final bool isActive;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    if (isActive) {
      return FilledButton.tonalIcon(
        onPressed: onPressed,
        icon: Icon(icon),
        label: Text(label),
      );
    }

    return OutlinedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon),
      label: Text(label),
    );
  }
}

class _ActionIconButton extends StatelessWidget {
  const _ActionIconButton({
    required this.icon,
    required this.tooltip,
    required this.isActive,
    required this.onPressed,
  });

  final IconData icon;
  final String tooltip;
  final bool isActive;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(left: 8),
      child: Material(
        color: isActive
            ? colorScheme.secondaryContainer
            : colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(14),
        child: IconButton(
          tooltip: tooltip,
          onPressed: onPressed,
          icon: Icon(
            icon,
            color: isActive
                ? colorScheme.onSecondaryContainer
                : colorScheme.onSurfaceVariant,
          ),
        ),
      ),
    );
  }
}
