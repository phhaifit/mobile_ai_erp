import 'package:flutter/material.dart';
import 'package:mobile_ai_erp/di/service_locator.dart';
import 'package:mobile_ai_erp/domain/entity/web_builder/cms_page.dart';
import 'package:mobile_ai_erp/domain/entity/web_builder/content_block.dart';
import 'package:mobile_ai_erp/presentation/web_builder/store/cms_page_store.dart';

class CmsPageEditorScreen extends StatefulWidget {
  const CmsPageEditorScreen({super.key});

  @override
  State<CmsPageEditorScreen> createState() => _CmsPageEditorScreenState();
}

class _CmsPageEditorScreenState extends State<CmsPageEditorScreen> {
  final CmsPageStore _store = getIt<CmsPageStore>();
  final _formKey = GlobalKey<FormState>();
  bool _loaded = false;
  bool _isSaving = false;
  bool _isEditMode = false;
  String? _pageId;

  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late TextEditingController _metaTitleController;
  late TextEditingController _metaDescriptionController;
  late TextEditingController _slugController;

  String _selectedType = 'Landing';
  bool _isPublished = false;
  late List<ContentBlock> _blocks;
  bool _seoExpanded = false;

  static const _pageTypes = ['Landing', 'Info', 'Marketing', 'Support'];

  static const _availableBlockTypes = <Map<String, dynamic>>[
    {'type': 'hero', 'title': 'Hero Banner', 'icon': Icons.panorama},
    {'type': 'text', 'title': 'Text Block', 'icon': Icons.text_fields},
    {'type': 'gallery', 'title': 'Image Gallery', 'icon': Icons.photo_library},
    {'type': 'products', 'title': 'Product Showcase', 'icon': Icons.shopping_bag_outlined},
    {'type': 'cta', 'title': 'Call to Action', 'icon': Icons.touch_app_outlined},
  ];

  IconData _iconForBlockType(String? type) {
    switch (type) {
      case 'hero': return Icons.panorama;
      case 'text': return Icons.text_fields;
      case 'gallery': return Icons.photo_library;
      case 'products': return Icons.shopping_bag_outlined;
      case 'cta': return Icons.touch_app_outlined;
      default: return Icons.extension;
    }
  }

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController();
    _descriptionController = TextEditingController();
    _metaTitleController = TextEditingController();
    _metaDescriptionController = TextEditingController();
    _slugController = TextEditingController();
    _blocks = [
      ContentBlock(type: 'hero', title: 'Hero Banner'),
      ContentBlock(type: 'text', title: 'Text Block'),
      ContentBlock(type: 'gallery', title: 'Image Gallery'),
    ];
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_loaded) {
      _pageId = ModalRoute.of(context)?.settings.arguments as String?;
      if (_pageId != null) {
        _loadPage(_pageId!);
      }
      _loaded = true;
    }
  }

  Future<void> _loadPage(String id) async {
    await _store.getPageById(id);
    final data = _store.selectedPage;
    if (data != null && mounted) {
      setState(() {
        _isEditMode = true;
        _titleController.text = data.title ?? '';
        _descriptionController.text = data.description ?? '';
        _selectedType = data.type ?? 'Landing';
        _isPublished = data.isPublished ?? false;
        _blocks = List.from(data.blocks ?? []);
        _metaTitleController.text = data.metaTitle ?? '';
        _metaDescriptionController.text = data.metaDescription ?? '';
        _slugController.text = data.slug ?? '';
      });
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _metaTitleController.dispose();
    _metaDescriptionController.dispose();
    _slugController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditMode ? 'Edit Page' : 'Create Page'),
        actions: [
          if (_isSaving)
            const Padding(
              padding: EdgeInsets.only(right: 16),
              child: Center(
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
            )
          else
            TextButton(
              onPressed: _handleSave,
              child: const Text('Save'),
            ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _buildPageInfoSection(theme),
            const SizedBox(height: 24),
            _buildContentBlocksSection(theme),
            const SizedBox(height: 24),
            _buildSeoSection(theme),
            const SizedBox(height: 80),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomBar(theme),
    );
  }

  Widget _buildPageInfoSection(ThemeData theme) {
    return Card(
      elevation: Theme.of(context).brightness == Brightness.dark ? 2 : 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Page Information', style: theme.textTheme.titleMedium),
            const SizedBox(height: 16),
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Page Title',
                hintText: 'Enter page title',
                prefixIcon: Icon(Icons.title),
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Title is required';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Description',
                hintText: 'Brief description of this page',
                prefixIcon: Icon(Icons.description_outlined),
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              initialValue: _selectedType,
              decoration: const InputDecoration(
                labelText: 'Page Type',
                prefixIcon: Icon(Icons.category_outlined),
                border: OutlineInputBorder(),
              ),
              items: _pageTypes
                  .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                  .toList(),
              onChanged: (value) {
                if (value != null) setState(() => _selectedType = value);
              },
            ),
            const SizedBox(height: 16),
            SwitchListTile(
              title: const Text('Published'),
              subtitle: Text(
                _isPublished
                    ? 'Page is visible to customers'
                    : 'Page is saved as draft',
              ),
              value: _isPublished,
              onChanged: (value) => setState(() => _isPublished = value),
              contentPadding: EdgeInsets.zero,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContentBlocksSection(ThemeData theme) {
    return Card(
      elevation: Theme.of(context).brightness == Brightness.dark ? 2 : 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text('Content Sections',
                      style: theme.textTheme.titleMedium),
                ),
                Text(
                  '${_blocks.length} blocks',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.textTheme.bodySmall?.color
                        ?.withValues(alpha: 0.5),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ReorderableListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _blocks.length,
              onReorder: (oldIndex, newIndex) {
                setState(() {
                  if (newIndex > oldIndex) newIndex--;
                  final block = _blocks.removeAt(oldIndex);
                  _blocks.insert(newIndex, block);
                });
              },
              itemBuilder: (context, index) {
                final block = _blocks[index];
                return _buildBlockTile(theme, block, index);
              },
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () => _showAddBlockSheet(context),
                icon: const Icon(Icons.add),
                label: const Text('Add Section'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBlockTile(ThemeData theme, ContentBlock block, int index) {
    return Container(
      key: ValueKey('${block.type}_$index'),
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        border: Border.all(
          color: theme.dividerColor.withValues(alpha: 0.3),
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        leading: Icon(_iconForBlockType(block.type), color: theme.colorScheme.primary),
        title: Text(block.title ?? ''),
        subtitle: Text(
          (block.type ?? '').toUpperCase(),
          style: theme.textTheme.labelSmall?.copyWith(
            color: theme.colorScheme.primary.withValues(alpha: 0.6),
          ),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.delete_outline, size: 20),
              onPressed: () {
                setState(() => _blocks.removeAt(index));
              },
              color: Colors.red.withValues(alpha: 0.7),
            ),
            ReorderableDragStartListener(
              index: index,
              child: const Icon(Icons.drag_handle, size: 20),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddBlockSheet(BuildContext context) {
    final theme = Theme.of(context);

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Add Content Section',
                  style: theme.textTheme.titleMedium),
              const SizedBox(height: 16),
              ..._availableBlockTypes.map((blockData) {
                return ListTile(
                  leading: Icon(blockData['icon'] as IconData, color: theme.colorScheme.primary),
                  title: Text(blockData['title'] as String),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  onTap: () {
                    setState(() => _blocks.add(ContentBlock(
                      type: blockData['type'] as String,
                      title: blockData['title'] as String,
                    )));
                    Navigator.of(ctx).pop();
                  },
                );
              }),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSeoSection(ThemeData theme) {
    return Card(
      elevation: Theme.of(context).brightness == Brightness.dark ? 2 : 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      clipBehavior: Clip.antiAlias,
      child: ExpansionTile(
        title: Text('SEO Settings', style: theme.textTheme.titleMedium),
        leading: const Icon(Icons.search),
        initiallyExpanded: _seoExpanded,
        onExpansionChanged: (expanded) {
          setState(() => _seoExpanded = expanded);
        },
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Column(
              children: [
                TextFormField(
                  controller: _metaTitleController,
                  decoration: const InputDecoration(
                    labelText: 'Meta Title',
                    hintText: 'SEO title for search engines',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _metaDescriptionController,
                  decoration: const InputDecoration(
                    labelText: 'Meta Description',
                    hintText: 'Brief description for search results',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 2,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _slugController,
                  decoration: const InputDecoration(
                    labelText: 'URL Slug',
                    hintText: 'e.g. about-us',
                    prefixIcon: Icon(Icons.link),
                    border: OutlineInputBorder(),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomBar(ThemeData theme) {
    return SafeArea(
      child: Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        border: Border(
          top: BorderSide(color: theme.dividerColor.withValues(alpha: 0.3)),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton.icon(
              onPressed: _handlePreview,
              icon: const Icon(Icons.visibility_outlined),
              label: const Text('Preview'),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: FilledButton.icon(
              onPressed: _isSaving ? null : _handleSave,
              icon: _isSaving
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Icons.save_outlined),
              label: Text(_isSaving ? 'Saving...' : 'Save'),
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ),
    ),
    );
  }

  void _handlePreview() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Preview will be available in Phase 2'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    final page = CmsPage(
      id: _pageId ?? DateTime.now().millisecondsSinceEpoch.toString(),
      title: _titleController.text,
      description: _descriptionController.text,
      type: _selectedType,
      status: _isPublished ? 'Published' : 'Draft',
      lastModified: DateTime.now(),
      isPublished: _isPublished,
      blocks: _blocks,
      metaTitle: _metaTitleController.text,
      metaDescription: _metaDescriptionController.text,
      slug: _slugController.text,
    );

    await _store.savePage(page);

    if (!mounted) return;
    setState(() => _isSaving = false);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          _isEditMode ? 'Page updated successfully' : 'Page created successfully',
        ),
        behavior: SnackBarBehavior.floating,
      ),
    );

    Navigator.of(context).pop();
  }
}
