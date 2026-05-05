import 'package:flutter/material.dart';
import 'package:mobile_ai_erp/constants/strings.dart';
import 'package:mobile_ai_erp/di/service_locator.dart';
import 'package:mobile_ai_erp/domain/entity/product_metadata/tag.dart';
import 'package:mobile_ai_erp/domain/usecase/product_metadata/tags/get_tags_usecase.dart';

class TagSelectModal extends StatefulWidget {
  final List<String> initialSelectedTagIds;
  final ValueChanged<List<String>> onTagsSelected;

  const TagSelectModal({
    super.key,
    required this.initialSelectedTagIds,
    required this.onTagsSelected,
  });

  @override
  State<TagSelectModal> createState() => _TagSelectModalState();
}

class _TagSelectModalState extends State<TagSelectModal> {
  late final GetTagsUseCase _getTagsUseCase;
  
  int _currentPage = 1;
  final int _pageSize = 20;
  int _totalPages = 1;

  late Set<String> _selectedTagIds;

  List<Tag> _currentTags = [];
  bool _isLoading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _getTagsUseCase = getIt<GetTagsUseCase>();
    _selectedTagIds = Set.from(widget.initialSelectedTagIds);
    _loadTags();
  }

  Future<void> _loadTags() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final result = await _getTagsUseCase.call(
        params: GetTagsParams(
          page: _currentPage,
          pageSize: _pageSize,
        ),
      );

      setState(() {
        _currentTags = result.items;
        _totalPages = result.totalPages;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Failed to load tags: $e';
        _isLoading = false;
      });
    }
  }

  void _goToPage(int page) {
    if (page >= 1 && page <= _totalPages && page != _currentPage) {
      setState(() {
        _currentPage = page;
      });
      _loadTags();
    }
  }

  void _toggleTag(String tagId) {
    setState(() {
      if (_selectedTagIds.contains(tagId)) {
        _selectedTagIds.remove(tagId);
      } else {
        _selectedTagIds.add(tagId);
      }
    });
  }

  void _clearSelection() {
    setState(() {
      _selectedTagIds.clear();
    });
  }

  void _confirm() {
    widget.onTagsSelected(_selectedTagIds.toList());
    Navigator.of(context).pop();
  }

  void _cancel() {
    Navigator.of(context).pop();
  }

  List<int> _getPaginationPages() {
    if (_totalPages <= 5) {
      return List.generate(_totalPages, (i) => i + 1);
    }

    final pages = <int>[];

    if (_currentPage <= 3) {
      pages.addAll([1, 2, 3, 4, 5]);
    } else if (_currentPage >= _totalPages - 2) {
      pages.addAll([
        _totalPages - 4,
        _totalPages - 3,
        _totalPages - 2,
        _totalPages - 1,
        _totalPages,
      ]);
    } else {
      pages.addAll([
        _currentPage - 2,
        _currentPage - 1,
        _currentPage,
        _currentPage + 1,
        _currentPage + 2,
      ]);
    }

    return pages;
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: EdgeInsets.all(16),
      child: Container(
        constraints: BoxConstraints(
          maxWidth: 600,
          maxHeight: MediaQuery.of(context).size.height * 0.8,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header with selected items count
            Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    ProductStrings.selectTagsTitle,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  SizedBox(height: 12),
                  Container(
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      _selectedTagIds.isEmpty
                          ? ProductStrings.noTagsSelectedText
                          : '${ProductStrings.selectedTagsLabel}: ${_selectedTagIds.length} selected',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            Divider(height: 1),

            // Tags grid
            Expanded(
              child: _isLoading
                  ? Center(child: CircularProgressIndicator())
                  : _error != null
                      ? Center(
                          child: Padding(
                            padding: EdgeInsets.all(16),
                            child: Text(
                              _error!,
                              textAlign: TextAlign.center,
                              style: TextStyle(color: Colors.red),
                            ),
                          ),
                        )
                      : _currentTags.isEmpty
                          ? Center(
                              child: Text(ProductStrings.noTagsMessage),
                            )
                          : GridView.builder(
                              padding: EdgeInsets.all(16),
                              gridDelegate:
                                  SliverGridDelegateWithFixedCrossAxisCount(
                                childAspectRatio: 2.5,
                                crossAxisCount:
                                    MediaQuery.of(context).size.width > 600
                                        ? 3
                                        : 2,
                                crossAxisSpacing: 12,
                                mainAxisSpacing: 12,
                              ),
                              itemCount: _currentTags.length,
                              itemBuilder: (context, index) {
                                final tag = _currentTags[index];
                                final isSelected = _selectedTagIds.contains(tag.id);

                                return GestureDetector(
                                  onTap: () => _toggleTag(tag.id),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                        color: isSelected
                                            ? Theme.of(context).primaryColor
                                            : Colors.grey[300]!,
                                        width: isSelected ? 2 : 1,
                                      ),
                                      borderRadius:
                                          BorderRadius.circular(8),
                                    ),
                                    child: Material(
                                      color: isSelected
                                          ? Theme.of(context)
                                              .primaryColor
                                              .withOpacity(0.1)
                                          : Colors.transparent,
                                      child: InkWell(
                                        onTap: () => _toggleTag(tag.id),
                                        child: Padding(
                                          padding: EdgeInsets.all(12),
                                          child: Row(
                                            children: [
                                              Checkbox(
                                                value: isSelected,
                                                onChanged: (_) => _toggleTag(tag.id),
                                              ),
                                              Expanded(
                                                child: Text(
                                                  tag.name,
                                                  style: TextStyle(
                                                    fontWeight: isSelected
                                                        ? FontWeight.bold
                                                        : FontWeight.normal,
                                                  ),
                                                  maxLines: 2,
                                                  overflow: TextOverflow.ellipsis,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
            ),

            Divider(height: 1),

            // Pagination controls
            Padding(
              padding: EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Previous button
                  TextButton(
                    onPressed: _currentPage > 1
                        ? () => _goToPage(_currentPage - 1)
                        : null,
                    child: Text('Previous'),
                  ),
                  SizedBox(width: 12),

                  // Page numbers
                  ..._getPaginationPages().map((page) {
                    final isCurrentPage = page == _currentPage;
                    return Padding(
                      padding: EdgeInsets.symmetric(horizontal: 4),
                      child: TextButton(
                        style: TextButton.styleFrom(
                          backgroundColor: isCurrentPage
                              ? Theme.of(context).primaryColor
                              : Colors.transparent,
                        ),
                        onPressed: () => _goToPage(page),
                        child: Text(
                          '$page',
                          style: TextStyle(
                            color: isCurrentPage
                                ? Colors.white
                                : Theme.of(context).primaryColor,
                            fontWeight: isCurrentPage
                                ? FontWeight.bold
                                : FontWeight.normal,
                          ),
                        ),
                      ),
                    );
                  }),

                  SizedBox(width: 12),

                  // Next button
                  TextButton(
                    onPressed: _currentPage < _totalPages
                        ? () => _goToPage(_currentPage + 1)
                        : null,
                    child: Text('Next'),
                  ),
                ],
              ),
            ),

            Divider(height: 1),

            // Action buttons
            Padding(
              padding: EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _clearSelection,
                      child: Text('Clear'),
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _cancel,
                      child: Text('Cancel'),
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _confirm,
                      child: Text('Confirm'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
