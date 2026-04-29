import 'package:flutter/material.dart';

class SupplierListControls extends StatelessWidget {
  const SupplierListControls({
    super.key,
    required this.searchController,
    required this.onSearchChanged,
    required this.resultLabel,
    required this.hasCustomSort,
    required this.onOpenFilter,
    required this.onOpenSort,
  });

  final TextEditingController searchController;
  final ValueChanged<String> onSearchChanged;
  final String resultLabel;
  final bool hasCustomSort;
  final VoidCallback onOpenFilter;
  final VoidCallback onOpenSort;

  @override
  Widget build(BuildContext context) {
    final labelStyle = Theme.of(context).textTheme.labelSmall?.copyWith(
          color: Theme.of(context)
              .colorScheme
              .onSurfaceVariant
              .withValues(alpha: 0.74),
          fontWeight: FontWeight.w500,
        );

    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth >= 720;
        if (isWide) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(child: _SearchField(controller: searchController, onChanged: onSearchChanged)),
                  const SizedBox(width: 12),
                  _ToolbarButton(
                    icon: Icons.filter_list_outlined,
                    label: 'Filter',
                    onPressed: onOpenFilter,
                  ),
                  const SizedBox(width: 12),
                  _ToolbarButton(
                    icon: Icons.sort_outlined,
                    label: 'Sort',
                    onPressed: onOpenSort,
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(resultLabel, style: labelStyle),
            ],
          );
        }

        return Row(
          children: [
            Expanded(child: Text(resultLabel, style: labelStyle)),
            ValueListenableBuilder<TextEditingValue>(
              valueListenable: searchController,
              builder: (_, value, _) => _ActionButton(
                icon: Icons.search,
                tooltip: 'Search',
                onPressed: () => _openSearchSheet(context),
              ),
            ),
            _ActionButton(
              icon: Icons.filter_list_outlined,
              tooltip: 'Filter',
              onPressed: onOpenFilter,
            ),
            _ActionButton(
              icon: Icons.sort_outlined,
              tooltip: 'Sort',
              onPressed: onOpenSort,
            ),
          ],
        );
      },
    );
  }

  Future<void> _openSearchSheet(BuildContext context) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (context) => Padding(
        padding: EdgeInsets.fromLTRB(
          16,
          16,
          16,
          16 + MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Search suppliers', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 12),
            _SearchField(
              controller: searchController,
              onChanged: onSearchChanged,
              hintText: 'Search by name, code, phone or email',
            ),
          ],
        ),
      ),
    );
  }
}

class _SearchField extends StatelessWidget {
  const _SearchField({
    required this.controller,
    required this.onChanged,
    this.hintText = 'Search by name, code, phone or email',
  });

  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final String hintText;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<TextEditingValue>(
      valueListenable: controller,
      builder: (_, _, _) => TextField(
        controller: controller,
        onChanged: onChanged,
        decoration: InputDecoration(
          hintText: hintText,
          hintMaxLines: 2,
          prefixIcon: const Icon(Icons.search),
          border: const OutlineInputBorder(),
          suffixIcon: controller.text.trim().isEmpty
              ? null
              : IconButton(
                  onPressed: () {
                    controller.clear();
                    onChanged('');
                  },
                  icon: const Icon(Icons.close),
                ),
        ),
      ),
    );
  }
}

class _ToolbarButton extends StatelessWidget {
  const _ToolbarButton({
    required this.icon,
    required this.label,
    required this.onPressed,
  });

  final IconData icon;
  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(onPressed: onPressed, icon: Icon(icon), label: Text(label));
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.icon,
    required this.tooltip,
    required this.onPressed,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback onPressed;
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(left: 8),
      child: Material(
        color: colorScheme.secondaryContainer,
        borderRadius: BorderRadius.circular(14),
        child: IconButton(
          onPressed: onPressed,
          tooltip: tooltip,
          icon: Icon(
            icon,
            color: colorScheme.onSecondaryContainer,
          ),
        ),
      ),
    );
  }
}
