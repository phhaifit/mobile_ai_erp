import 'package:flutter/material.dart';
import 'package:mobile_ai_erp/utils/routes/routes.dart';

class _DashboardSection {
  final String title;
  final String subtitle;
  final IconData icon;
  final String route;
  final Color color;

  const _DashboardSection({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.route,
    required this.color,
  });
}

class WebBuilderDashboard extends StatelessWidget {
  const WebBuilderDashboard({super.key});

  static const _sections = <_DashboardSection>[
    _DashboardSection(
      title: 'Store Settings',
      subtitle: 'Configure your store name, logo, contact info and business details',
      icon: Icons.storefront_outlined,
      route: Routes.storeSettings,
      color: Color(0xFF4CAF50),
    ),
    _DashboardSection(
      title: 'Themes',
      subtitle: 'Browse, preview and customize storefront themes',
      icon: Icons.palette_outlined,
      route: Routes.themeList,
      color: Color(0xFF2196F3),
    ),
    _DashboardSection(
      title: 'CMS Pages',
      subtitle: 'Create and manage custom pages like About, FAQ, Terms of Service',
      icon: Icons.article_outlined,
      route: Routes.cmsPageList,
      color: Color(0xFFFF9800),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Web Builder'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header section
            _buildHeader(theme),
            const SizedBox(height: 24),
            // Section cards
            LayoutBuilder(
              builder: (context, constraints) {
                final crossAxisCount = constraints.maxWidth > 800
                    ? 3
                    : constraints.maxWidth > 500
                        ? 2
                        : 1;
                return GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: crossAxisCount,
                    mainAxisExtent: 200,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                  ),
                  itemCount: _sections.length,
                  itemBuilder: (context, index) {
                    return _buildSectionCard(
                      context,
                      _sections[index],
                      isDark,
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Manage Your Storefront',
          style: theme.textTheme.headlineMedium,
        ),
        const SizedBox(height: 8),
        Text(
          'Configure settings, customize themes, and create pages for your online store.',
          style: theme.textTheme.bodyLarge?.copyWith(
            color: theme.textTheme.bodyLarge?.color?.withValues(alpha: 0.7),
          ),
        ),
      ],
    );
  }

  Widget _buildSectionCard(
    BuildContext context,
    _DashboardSection section,
    bool isDark,
  ) {
    final theme = Theme.of(context);

    return Card(
      elevation: isDark ? 2 : 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => Navigator.of(context).pushNamed(section.route),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Icon with colored background
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: section.color.withValues(alpha: isDark ? 0.2 : 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  section.icon,
                  color: section.color,
                  size: 28,
                ),
              ),
              const SizedBox(height: 16),
              // Title
              Text(
                section.title,
                style: theme.textTheme.titleLarge,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 6),
              // Subtitle
              Expanded(
                child: Text(
                  section.subtitle,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.6),
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              // Arrow indicator
              Align(
                alignment: Alignment.bottomRight,
                child: Icon(
                  Icons.arrow_forward_rounded,
                  size: 20,
                  color: section.color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
