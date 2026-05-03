import 'package:flutter/material.dart';
import 'package:mobile_ai_erp/domain/entity/product_metadata/category.dart';

class CategoriesLevelHeader extends StatelessWidget {
  const CategoriesLevelHeader({
    super.key,
    required this.path,
    required this.onNavigateToLevel,
    this.hasActiveFilter = false,
    this.onOpenFilter,
  });

  final List<Category> path;
  final ValueChanged<String?> onNavigateToLevel;
  final bool hasActiveFilter;
  final VoidCallback? onOpenFilter;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textStyle = theme.textTheme.titleMedium?.copyWith(
      color: theme.colorScheme.primary,
      fontWeight: FontWeight.bold,
    );

    final filterFn = onOpenFilter;
    return LayoutBuilder(
      builder: (context, constraints) {
        final showTextButton = constraints.maxWidth >= 720;
        return Row(
          children: <Widget>[
            Expanded(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(children: _breadcrumbItems(textStyle)),
              ),
            ),
            if (filterFn != null) ...[
              const SizedBox(width: 12),
              showTextButton
                  ? _HeaderFilterButton(hasActiveFilter: hasActiveFilter, onOpenFilter: filterFn)
                  : IconButton(
                      onPressed: filterFn,
                      icon: const Icon(Icons.filter_list_outlined),
                      tooltip: 'Filter',
                      color: hasActiveFilter ? theme.colorScheme.primary : null,
                    ),
            ],
          ],
        );
      },
    );
  }
  List<Widget> _breadcrumbItems(TextStyle? textStyle) {
    final visiblePath = path.length > 3 ? path.sublist(path.length - 3) : path;
    return <Widget>[
      _BreadcrumbButton(label: 'Root', onTap: () => onNavigateToLevel(null), textStyle: textStyle),
      if (path.length > 3) ...<Widget>[
        const _BreadcrumbSeparator(),
        const Text('...'),
      ],
      for (final category in visiblePath) ...<Widget>[
        const _BreadcrumbSeparator(),
        _BreadcrumbButton(label: category.name, onTap: () => onNavigateToLevel(category.id), textStyle: textStyle),
      ],
    ];
  }
}

class _HeaderFilterButton extends StatelessWidget {
  const _HeaderFilterButton({required this.hasActiveFilter, required this.onOpenFilter});
  final bool hasActiveFilter;
  final VoidCallback onOpenFilter;
  @override
  Widget build(BuildContext context) {
    if (hasActiveFilter) {
      return FilledButton.tonalIcon(onPressed: onOpenFilter, icon: const Icon(Icons.filter_list_outlined), label: const Text('Filter'));
    }
    return OutlinedButton.icon(onPressed: onOpenFilter, icon: const Icon(Icons.filter_list_outlined), label: const Text('Filter'));
  }
}

class _BreadcrumbButton extends StatelessWidget {
  const _BreadcrumbButton({required this.label, required this.onTap, required this.textStyle});
  final String label;
  final VoidCallback onTap;
  final TextStyle? textStyle;
  @override
  Widget build(BuildContext context) => TextButton(
    onPressed: onTap,
    style: TextButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 4)),
    child: Text(label, style: textStyle),
  );
}

class _BreadcrumbSeparator extends StatelessWidget {
  const _BreadcrumbSeparator();
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 4),
    child: Icon(Icons.chevron_right, size: 20, color: Theme.of(context).colorScheme.outlineVariant),
  );
}
