import 'package:flutter/material.dart';

class OrderPaginationControls extends StatelessWidget {
  const OrderPaginationControls({
    super.key,
    required this.currentPage,
    required this.totalPages,
    required this.onPrevious,
    required this.onNext,
    this.isLoading = false,
  });

  final int currentPage;
  final int totalPages;
  final VoidCallback? onPrevious;
  final VoidCallback? onNext;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    if (totalPages <= 1) return const SizedBox.shrink();

    final colorScheme = Theme.of(context).colorScheme;
    final isFirstPage = currentPage <= 1;
    final isLastPage = currentPage >= totalPages;

    return Padding(
      padding: const EdgeInsets.only(top: 8, bottom: 12),
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainerLow,
            borderRadius: BorderRadius.circular(999),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              _PageButton(
                icon: Icons.chevron_left,
                tooltip: 'Previous page',
                onPressed: !isFirstPage && !isLoading ? onPrevious : null,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Text(
                  '$currentPage / $totalPages',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),
              _PageButton(
                icon: Icons.chevron_right,
                tooltip: 'Next page',
                onPressed: !isLastPage && !isLoading ? onNext : null,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PageButton extends StatelessWidget {
  const _PageButton({
    required this.icon,
    required this.tooltip,
    this.onPressed,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: IconButton(
        constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
        padding: const EdgeInsets.all(8),
        icon: Icon(icon),
        onPressed: onPressed,
      ),
    );
  }
}
