import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:mobile_ai_erp/di/service_locator.dart';
import 'package:mobile_ai_erp/domain/entity/web_builder/cms_page.dart';
import 'package:mobile_ai_erp/presentation/web_builder/store/cms_page_store.dart';
import 'package:mobile_ai_erp/utils/routes/routes.dart';

class CmsPageListScreen extends StatefulWidget {
  const CmsPageListScreen({super.key});

  @override
  State<CmsPageListScreen> createState() => _CmsPageListScreenState();
}

class _CmsPageListScreenState extends State<CmsPageListScreen> {
  final CmsPageStore _store = getIt<CmsPageStore>();
  String _selectedFilter = 'All';

  static const _filters = ['All', 'Published', 'Draft'];

  @override
  void initState() {
    super.initState();
    _store.getPages();
  }

  List<CmsPage> get _filteredPages {
    final pages = _store.pageList?.pages ?? [];
    if (_selectedFilter == 'All') return pages;
    return pages.where((p) => p.status == _selectedFilter).toList();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('CMS Pages'),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).pushNamed(Routes.cmsPageEditor);
        },
        child: const Icon(Icons.add),
      ),
      body: Observer(
        builder: (_) {
          if (_store.loading) {
            return const Center(child: CircularProgressIndicator());
          }

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildFilterChips(theme),
              Expanded(
                child: _filteredPages.isEmpty
                    ? _buildEmptyState(theme)
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: _filteredPages.length,
                        itemBuilder: (context, index) {
                          return _buildPageCard(context, _filteredPages[index]);
                        },
                      ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildFilterChips(ThemeData theme) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: _filters.map((filter) {
          final isSelected = _selectedFilter == filter;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilterChip(
              label: Text(filter),
              selected: isSelected,
              onSelected: (_) {
                setState(() => _selectedFilter = filter);
              },
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildPageCard(BuildContext context, CmsPage page) {
    final theme = Theme.of(context);
    final isPublished = page.status == 'Published';

    return Card(
      elevation: Theme.of(context).brightness == Brightness.dark ? 2 : 1,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          Navigator.of(context).pushNamed(
            Routes.cmsPageEditor,
            arguments: page.id,
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      page.title ?? '',
                      style: theme.textTheme.titleMedium,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  _buildStatusBadge(theme, isPublished),
                  _buildPopupMenu(context, page),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                page.description ?? '',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.textTheme.bodyMedium?.color
                      ?.withValues(alpha: 0.6),
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  _buildTypeBadge(theme, page.type ?? ''),
                  const Spacer(),
                  Icon(
                    Icons.schedule,
                    size: 14,
                    color: theme.textTheme.bodySmall?.color
                        ?.withValues(alpha: 0.5),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    _formatDate(page.lastModified ?? DateTime.now()),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.textTheme.bodySmall?.color
                          ?.withValues(alpha: 0.5),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusBadge(ThemeData theme, bool isPublished) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: (isPublished ? Colors.green : Colors.orange)
            .withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        isPublished ? 'Published' : 'Draft',
        style: theme.textTheme.labelSmall?.copyWith(
          color: isPublished ? Colors.green : Colors.orange,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildTypeBadge(ThemeData theme, String type) {
    final iconMap = <String, IconData>{
      'Landing': Icons.home_outlined,
      'Info': Icons.info_outline,
      'Marketing': Icons.campaign_outlined,
      'Support': Icons.help_outline,
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            iconMap[type] ?? Icons.article_outlined,
            size: 14,
            color: theme.colorScheme.primary,
          ),
          const SizedBox(width: 4),
          Text(
            type,
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPopupMenu(BuildContext context, CmsPage page) {
    return PopupMenuButton<String>(
      icon: const Icon(Icons.more_vert, size: 20),
      onSelected: (value) {
        switch (value) {
          case 'edit':
            Navigator.of(context).pushNamed(
              Routes.cmsPageEditor,
              arguments: page.id,
            );
            break;
          case 'duplicate':
            final duplicated = CmsPage(
              id: DateTime.now().millisecondsSinceEpoch.toString(),
              title: '${page.title} (Copy)',
              description: page.description,
              type: page.type,
              status: 'Draft',
              lastModified: DateTime.now(),
              isPublished: false,
              blocks: page.blocks,
              metaTitle: page.metaTitle,
              metaDescription: page.metaDescription,
              slug: page.slug != null ? '${page.slug}-copy' : null,
            );
            _store.savePage(duplicated);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('"${page.title}" duplicated'),
                behavior: SnackBarBehavior.floating,
              ),
            );
            break;
          case 'delete':
            _showDeleteDialog(context, page);
            break;
        }
      },
      itemBuilder: (context) => [
        const PopupMenuItem(value: 'edit', child: Text('Edit')),
        const PopupMenuItem(value: 'duplicate', child: Text('Duplicate')),
        const PopupMenuItem(
          value: 'delete',
          child: Text('Delete', style: TextStyle(color: Colors.red)),
        ),
      ],
    );
  }

  void _showDeleteDialog(BuildContext context, CmsPage page) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Page'),
        content: Text('Are you sure you want to delete "${page.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              _store.deletePage(page.id!);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('"${page.title}" deleted'),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.article_outlined,
            size: 64,
            color: theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.3),
          ),
          const SizedBox(height: 16),
          Text(
            'No pages found',
            style: theme.textTheme.titleMedium?.copyWith(
              color: theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.5),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Try changing the filter or create a new page',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.4),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }
}
