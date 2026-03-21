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
    final Color markerColor =
        isDone ? Theme.of(context).colorScheme.primary : Colors.grey.shade400;
    final Color titleColor = isActive ? const Color(0xFF0F172A) : const Color(0xFF334155);

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
                  color: isDone ? markerColor : Colors.white,
                  border: Border.all(color: markerColor, width: 2),
                ),
                child: isDone
                    ? const Icon(Icons.check, size: 12, color: Colors.white)
                    : null,
              ),
              if (showLine)
                Container(
                  width: 2,
                  height: 34,
                  margin: const EdgeInsets.symmetric(vertical: 2),
                  color: Colors.grey.shade300,
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
              color: isActive ? const Color(0xFFF1F8F7) : const Color(0xFFF8FAFA),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isActive ? const Color(0xFF99D5CE) : const Color(0xFFE5E7EB),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  label,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontWeight: isActive ? FontWeight.w700 : FontWeight.w600,
                        color: titleColor,
                      ),
                ),
                const SizedBox(height: 3),
                Text(
                  dateText,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: const Color(0xFF64748B),
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
