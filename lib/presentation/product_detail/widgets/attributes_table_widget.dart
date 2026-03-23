import 'package:flutter/material.dart';
import 'package:mobile_ai_erp/domain/entity/product_detail/product_detail.dart';

class AttributesTableWidget extends StatelessWidget {
  final List<ProductSpecification> specifications;

  const AttributesTableWidget({super.key, required this.specifications});

  @override
  Widget build(BuildContext context) {
    if (specifications.isEmpty) return const SizedBox.shrink();

    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Specifications',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: colorScheme.onSurface.withValues(alpha: 0.1),
            ),
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            children: List.generate(specifications.length, (index) {
              final spec = specifications[index];
              final isEven = index.isEven;
              return Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: isEven
                      ? colorScheme.secondary.withValues(alpha: 0.3)
                      : colorScheme.surface,
                  border: index < specifications.length - 1
                      ? Border(
                          bottom: BorderSide(
                            color:
                                colorScheme.onSurface.withValues(alpha: 0.06),
                          ),
                        )
                      : null,
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: 130,
                      child: Text(
                        spec.name,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color:
                              colorScheme.onSurface.withValues(alpha: 0.55),
                          fontWeight: FontWeight.w500,
                          fontSize: 13,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Text(
                        spec.value,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }),
          ),
        ),
      ],
    );
  }
}
