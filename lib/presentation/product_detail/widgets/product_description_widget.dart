import 'package:flutter/material.dart';

class ProductDescriptionWidget extends StatelessWidget {
  final String descriptionHtml;
  final bool isExpanded;
  final VoidCallback onToggle;

  const ProductDescriptionWidget({
    super.key,
    required this.descriptionHtml,
    required this.isExpanded,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final plainText = _stripHtmlTags(descriptionHtml);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Description',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            IconButton(
              onPressed: onToggle,
              icon: AnimatedRotation(
                turns: isExpanded ? 0.5 : 0,
                duration: const Duration(milliseconds: 200),
                child: const Icon(Icons.keyboard_arrow_down, size: 24),
              ),
              visualDensity: VisualDensity.compact,
            ),
          ],
        ),
        const SizedBox(height: 4),
        AnimatedCrossFade(
          firstChild: _CollapsedText(text: plainText, theme: theme),
          secondChild: _ExpandedText(
            text: plainText,
            theme: theme,
            colorScheme: colorScheme,
          ),
          crossFadeState:
              isExpanded ? CrossFadeState.showSecond : CrossFadeState.showFirst,
          duration: const Duration(milliseconds: 250),
        ),
        Align(
          alignment: Alignment.centerLeft,
          child: TextButton(
            onPressed: onToggle,
            style: TextButton.styleFrom(
              padding: EdgeInsets.zero,
              minimumSize: const Size(0, 32),
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: Text(
              isExpanded ? 'Read Less' : 'Read More',
              style: TextStyle(
                color: colorScheme.primary,
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
          ),
        ),
      ],
    );
  }

  static String _stripHtmlTags(String html) {
    return html
        .replaceAll(RegExp(r'<br\s*/?>'), '\n')
        .replaceAll(RegExp(r'</?(p|div|h[1-6]|li)(\s[^>]*)?>'), '\n')
        .replaceAll(RegExp(r'</(ul|ol)>'), '\n')
        .replaceAll(RegExp(r'<li(\s[^>]*)?>'), '  • ')
        .replaceAll(RegExp(r'<[^>]+>'), '')
        .replaceAll(RegExp(r'\n{3,}'), '\n\n')
        .trim();
  }
}

class _CollapsedText extends StatelessWidget {
  final String text;
  final ThemeData theme;

  const _CollapsedText({required this.text, required this.theme});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      maxLines: 4,
      overflow: TextOverflow.ellipsis,
      style: theme.textTheme.bodyMedium?.copyWith(
        height: 1.5,
        color: theme.colorScheme.onSurface.withValues(alpha: 0.75),
      ),
    );
  }
}

class _ExpandedText extends StatelessWidget {
  final String text;
  final ThemeData theme;
  final ColorScheme colorScheme;

  const _ExpandedText({
    required this.text,
    required this.theme,
    required this.colorScheme,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: theme.textTheme.bodyMedium?.copyWith(
        height: 1.5,
        color: colorScheme.onSurface.withValues(alpha: 0.75),
      ),
    );
  }
}
