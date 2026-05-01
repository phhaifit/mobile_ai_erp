import 'package:flutter/material.dart';

/// A reusable paginated selection modal that works with any item type
class PaginatedSelectionModal<T> extends StatefulWidget {
  final String? initialSelectionId;
  final String? initialSelectionName;
  final String title;
  final String selectedLabel;
  final String noItemsMessage;
  final String noSelectionText;
  final Future<(List<T>, int)> Function(int page, int pageSize) fetchItems;
  final String Function(T item) getItemId;
  final String Function(T item) getItemName;
  final ValueChanged<String?> onSelectionChanged;

  const PaginatedSelectionModal({
    super.key,
    required this.initialSelectionId,
    required this.initialSelectionName,
    required this.title,
    required this.selectedLabel,
    required this.noItemsMessage,
    required this.noSelectionText,
    required this.fetchItems,
    required this.getItemId,
    required this.getItemName,
    required this.onSelectionChanged,
  });

  @override
  State<PaginatedSelectionModal<T>> createState() =>
      _PaginatedSelectionModalState<T>();
}

class _PaginatedSelectionModalState<T>
    extends State<PaginatedSelectionModal<T>> {
  int _currentPage = 1;
  final int _pageSize = 20;
  int _totalPages = 1;

  late String? _selectedItemId;
  late String? _selectedItemName;

  List<T> _currentItems = [];
  bool _isLoading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _selectedItemId = widget.initialSelectionId;
    _selectedItemName = widget.initialSelectionName;
    _loadItems();
  }

  Future<void> _loadItems() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final (items, totalPages) =
          await widget.fetchItems(_currentPage, _pageSize);

      setState(() {
        _currentItems = items;
        _totalPages = totalPages;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Failed to load items: $e';
        _isLoading = false;
      });
    }
  }

  void _goToPage(int page) {
    if (page >= 1 && page <= _totalPages && page != _currentPage) {
      setState(() {
        _currentPage = page;
      });
      _loadItems();
    }
  }

  void _selectItem(T item) {
    setState(() {
      _selectedItemId = widget.getItemId(item);
      _selectedItemName = widget.getItemName(item);
    });
  }

  void _removeSelection() {
    setState(() {
      _selectedItemId = null;
      _selectedItemName = null;
    });
  }

  void _confirm() {
    widget.onSelectionChanged(_selectedItemId);
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
            // Header with selected item
            Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.title,
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
                      _selectedItemName == null 
                      ? widget.noSelectionText
                      : '${widget.selectedLabel}: $_selectedItemName',
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

            // Items grid
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
                      : _currentItems.isEmpty
                          ? Center(
                              child: Text(widget.noItemsMessage),
                            )
                          : GridView.builder(
                              padding: EdgeInsets.all(16),
                              
                              gridDelegate:
                                  SliverGridDelegateWithFixedCrossAxisCount(
                                childAspectRatio: 2.0,
                                crossAxisCount:
                                    MediaQuery.of(context).size.width > 600
                                        ? 3
                                        : 2,
                                crossAxisSpacing: 12,
                                mainAxisSpacing: 12,
                              ),
                              itemCount: _currentItems.length,
                              itemBuilder: (context, index) {
                                final item = _currentItems[index];
                                final itemId = widget.getItemId(item);
                                final itemName = widget.getItemName(item);
                                final isSelected = _selectedItemId == itemId;

                                return GestureDetector(
                                  onTap: () => _selectItem(item),
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
                                      color: Colors.transparent,
                                      child: InkWell(
                                        onTap: () => _selectItem(item),
                                        child: Center(
                                          child: Padding(
                                            padding: EdgeInsets.all(12),
                                            child: Text(
                                              itemName,
                                              textAlign: TextAlign.center,
                                              style: TextStyle(
                                                fontWeight: isSelected
                                                    ? FontWeight.bold
                                                    : FontWeight.normal,
                                              ),
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                            ),
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
            // if (_totalPages > 1)
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
                    }).toList(),

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
                      onPressed: _removeSelection,
                      child: Text('Remove'),
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
