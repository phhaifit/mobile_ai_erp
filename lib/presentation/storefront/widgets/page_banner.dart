import 'package:flutter/material.dart';
import 'package:mobile_ai_erp/presentation/storefront/widgets/storefront_ui.dart';

class PageBanner extends StatelessWidget {
  const PageBanner({
    super.key,
    required this.imageSource,
    required this.heading,
    this.subheading,
    this.tags = const [],
  });

  final String? imageSource;
  final String heading;
  final String? subheading;
  final List<String> tags;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: colorScheme.primary.withValues(alpha: 0.16),
            blurRadius: 36,
            offset: const Offset(0, 18),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(32),
        child: Stack(
          children: [
            StorefrontNetworkImage(
              imageUrl: imageSource,
              width: double.infinity,
              height: 320,
              borderRadius: BorderRadius.zero,
            ),
            Container(
              height: 320,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    const Color(0xFF241E30).withValues(alpha: 0.18),
                    const Color(0xFF241E30).withValues(alpha: 0.76),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
            Positioned.fill(
              child: Padding(
                padding: const EdgeInsets.all(28),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    StorefrontTag(
                      label: 'Storefront discovery',
                      icon: Icons.auto_awesome,
                      backgroundColor: Colors.white.withValues(alpha: 0.18),
                      foregroundColor: Colors.white,
                    ),
                    const SizedBox(height: 18),
                    Text(
                      heading,
                      style: theme.textTheme.headlineMedium?.copyWith(
                        fontSize: 30,
                        height: 1.15,
                        color: Colors.white,
                      ),
                    ),
                    if (subheading != null) ...[
                      const SizedBox(height: 10),
                      Text(
                        subheading!,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: Colors.white.withValues(alpha: 0.86),
                          height: 1.5,
                        ),
                      ),
                    ],
                    if (tags.isNotEmpty) ...[
                      const SizedBox(height: 18),
                      Wrap(
                        spacing: 10,
                        runSpacing: 10,
                        children: tags
                            .map(
                              (tag) => StorefrontTag(
                                label: tag,
                                backgroundColor: Colors.white,
                                foregroundColor: colorScheme.onSurface,
                              ),
                            )
                            .toList(),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
