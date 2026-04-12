import 'package:flutter/material.dart';

class MetadataSecondaryDetails extends StatelessWidget {
  const MetadataSecondaryDetails({
    super.key,
    required this.lines,
  });

  final List<String> lines;

  @override
  Widget build(BuildContext context) {
    if (lines.isEmpty) {
      return const SizedBox.shrink();
    }

    final color = Theme.of(context).colorScheme.onSurfaceVariant;
    final textStyle = Theme.of(context).textTheme.labelSmall?.copyWith(
          color: color,
          fontWeight: FontWeight.w400,
        );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        for (var index = 0; index < lines.length; index++) ...<Widget>[
          Text(
            lines[index],
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: textStyle,
          ),
          if (index < lines.length - 1) ...<Widget>[
            const SizedBox(height: 4),
            Divider(
              height: 1,
              thickness: 0.6,
              color: color.withValues(alpha: 0.24),
            ),
            const SizedBox(height: 4),
          ],
        ],
      ],
    );
  }
}
