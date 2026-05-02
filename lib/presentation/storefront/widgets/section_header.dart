import 'package:flutter/material.dart';
import 'package:mobile_ai_erp/presentation/storefront/classes/filter_arguments.dart';

class SectionHeader extends StatelessWidget {
  const SectionHeader({
    super.key,
    required this.headingText,
    this.linkText,
    this.linkDestination,
    this.filterArguments,
    this.subheadingText,
  });

  final String headingText;
  final String? linkText;
  final String? linkDestination;
  final FilterArguments? filterArguments;
  final String? subheadingText;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  headingText,
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontSize: 24,
                    color: colorScheme.onSurface,
                  ),
                ),
                if (subheadingText != null) ...[
                  const SizedBox(height: 6),
                  Text(
                    subheadingText!,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (linkText != null && linkDestination != null)
            Padding(
              padding: const EdgeInsets.only(left: 12),
              child: FilledButton.tonal(
                onPressed: () {
                  Navigator.of(
                    context,
                  ).pushNamed(linkDestination!, arguments: filterArguments);
                },
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 14,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                ),
                child: Text(linkText!),
              ),
            ),
        ],
      ),
    );
  }
}
