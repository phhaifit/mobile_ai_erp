import 'package:flutter/material.dart';
import 'package:mobile_ai_erp/domain/entity/product_metadata/brand.dart';
import 'package:mobile_ai_erp/domain/repository/product_metadata/product_metadata_repository.dart';
import 'package:mobile_ai_erp/di/service_locator.dart';

class BrandSelectModal extends StatefulWidget {
  final String? initialBrandId;
  final String? initialBrandName;
  final ValueChanged<String?> onBrandSelected;

  const BrandSelectModal({
    super.key,
    required this.initialBrandId,
    required this.initialBrandName,
    required this.onBrandSelected,
  });

  @override
  State<BrandSelectModal> createState() => _BrandSelectModalState();
}

class _BrandSelectModalState extends State<BrandSelectModal> {
  late final ProductMetadataRepository _repository;
  
  int _currentPage = 1;
  final int _pageSize = 20;
  int _totalPages = 1;
  
  late String? _selectedBrandId;
  late String? _selectedBrandName;
  
  List<Brand> _currentBrands = [];
  bool _isLoading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _repository = getIt<ProductMetadataRepository>();
    _selectedBrandId = widget.initialBrandId;
    _selectedBrandName = widget.initialBrandName;
    _loadBrands();
  }

  Future<void> _loadBrands() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final response = await _repository.getBrands(
        page: _currentPage,
        pageSize: _pageSize,
      );
      
      setState(() {
        _currentBrands = response.brands;
        _totalPages = response.meta.totalPages;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Failed to load brands: $e';
        _isLoading = false;
      });
    }
  }

  void _goToPage(int page) {
    if (page >= 1 && page <= _totalPages && page != _currentPage) {
      setState(() {
        _currentPage = page;
      });
      _loadBrands();
    }
  }

  void _selectBrand(Brand brand) {
    setState(() {
      _selectedBrandId = brand.id;
      _selectedBrandName = brand.name;
    });
  }

  void _removeBrand() {
    setState(() {
      _selectedBrandId = null;
      _selectedBrandName = null;
    });
  }

  void _confirm() {
    widget.onBrandSelected(_selectedBrandId);
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
            // Header with selected brand
            Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Select Brand',
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
                      'Selected brand: ${_selectedBrandName ?? "No brand selected"}',
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

            // Brands grid
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
                      : _currentBrands.isEmpty
                          ? Center(
                              child: Text('No brands available'),
                            )
                          : GridView.builder(
                              padding: EdgeInsets.all(16),
                              gridDelegate:
                                  SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount:
                                    MediaQuery.of(context).size.width > 600
                                        ? 3
                                        : 2,
                                crossAxisSpacing: 12,
                                mainAxisSpacing: 12,
                              ),
                              itemCount: _currentBrands.length,
                              itemBuilder: (context, index) {
                                final brand = _currentBrands[index];
                                final isSelected =
                                    _selectedBrandId == brand.id;

                                return GestureDetector(
                                  onTap: () => _selectBrand(brand),
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
                                        onTap: () => _selectBrand(brand),
                                        child: Center(
                                          child: Padding(
                                            padding: EdgeInsets.all(12),
                                            child: Text(
                                              brand.name,
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
            if (_totalPages > 1)
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
                      onPressed: _removeBrand,
                      child: Text('Remove brand'),
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
