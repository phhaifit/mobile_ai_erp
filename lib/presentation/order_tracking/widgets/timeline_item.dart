import 'package:flutter/material.dart';

class TimelineItem extends StatelessWidget {
  const TimelineItem({
    super.key,
    required this.label,
    required this.dateText,
    required this.isActive,
    required this.isDone,
    required this.showLine,
  });

  final String label;
  final String dateText;
  final bool isActive;
  final bool isDone;
  final bool showLine;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final Color markerColor =
      isDone ? colorScheme.primary : colorScheme.onSurface.withValues(alpha: 0.35);
    final Color titleColor =
      isActive ? colorScheme.onSurface : colorScheme.onSurface.withValues(alpha: 0.8);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        SizedBox(
          width: 28,
          child: Column(
            children: <Widget>[
              Container(
                height: 20,
                width: 20,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isDone ? markerColor : colorScheme.surface,
                  border: Border.all(color: markerColor, width: 2),
                ),
                child: isDone
                    ? Icon(Icons.check, size: 12, color: colorScheme.onPrimary)
                    : null,
              ),
              if (showLine)
                Container(
                  width: 2,
                  height: 34,
                  margin: const EdgeInsets.symmetric(vertical: 2),
                  color: colorScheme.onSurface.withValues(alpha: 0.18),
                ),
            ],
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Container(
            padding: const EdgeInsets.fromLTRB(12, 9, 12, 10),
            margin: const EdgeInsets.only(bottom: 8),
            decoration: BoxDecoration(
              color: isActive
                  ? colorScheme.primary.withValues(alpha: 0.08)
                  : colorScheme.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isActive
                    ? colorScheme.primary.withValues(alpha: 0.35)
                    : colorScheme.onSurface.withValues(alpha: 0.12),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  label,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontWeight:
                            isActive ? FontWeight.w700 : FontWeight.w600,
                        color: titleColor,
                      ),
                ),
                const SizedBox(height: 3),
                Text(
                  dateText,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurface.withValues(alpha: 0.65),
                      ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
