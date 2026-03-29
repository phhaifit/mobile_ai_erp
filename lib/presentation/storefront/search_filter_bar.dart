import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:mobile_ai_erp/di/service_locator.dart';
import 'package:mobile_ai_erp/domain/entity/product_metadata/brand.dart';
import 'package:mobile_ai_erp/domain/entity/product_metadata/category.dart';
import 'package:mobile_ai_erp/presentation/storefront/store/product_listing_store.dart';

class SearchFilterBar extends StatefulWidget {
  final List<Category> categories;
  final List<Brand> brands;

  const SearchFilterBar({super.key, required this.categories, required this.brands});

  @override
  State<SearchFilterBar> createState() => _SearchFilterBarState();
}

class _SearchFilterBarState extends State<SearchFilterBar> {
  bool _searchOpen = false; // expands search bar
  bool _filterOpen = false; // expands filter options
  bool _sortOpen = false; // expands sorting options
  bool _chatOpen = false; // expands chat options
  final _listingFilters = getIt<ListingFilters>();
  late TextEditingController _chatInputController;

  @override
  void initState() {
    super.initState();
    _chatInputController = TextEditingController();
  }

  @override
  void dispose() {
    _chatInputController.dispose();
    super.dispose();
  }

  bool get isExpanded => _searchOpen || _filterOpen || _sortOpen || _chatOpen;


  Widget _buildExpandedContent() {
    if (_searchOpen) {
      return _buildSearchContent();
    } else if (_filterOpen) {
      return _buildFilterContent();
    } else if (_sortOpen) {
      return _buildSortContent();
    } else if (_chatOpen) {
      return _buildChatContent();
    }
    return const SizedBox.shrink();
  }

  Widget _expandedContainer({required List<Widget> contents})
  {
    final contentsWithBlankBox = [
      ...contents,
      SizedBox(height: 16), // blank box for scrollability and clickability
    ];
    
    return Container(
      color: Colors.blue[100],
      constraints: BoxConstraints(maxHeight: 350),
      padding: EdgeInsets.all(10.0),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: contentsWithBlankBox,
        ),
      ),
    );
  }

  Widget _buildSearchContent() {
    return _expandedContainer(
      contents: [
        TextField(
          controller: TextEditingController(text: _listingFilters.searchQuery),
          decoration: InputDecoration(
            hintText: 'Search products...',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            prefixIcon: const Icon(Icons.search),
          ),
          onChanged: (value) {
            _listingFilters.setSearchQuery(value);
            _listingFilters.updateProducts();
          },
        ),
      ],
    );
  }

  Widget _buildFilterContent() {
    return _expandedContainer(
      contents: [
        Text(
          'Filters',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 12),
        Text(
          'Categories',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 3.0,
          runSpacing: 3.0,
          children: [
            for (var category in widget.categories)
              Observer(builder: (_) => FilterChip(
                  label: Text(category.name),
                  selected: _listingFilters.categoryFilter.contains(category.id),
                  onSelected: (selected) {
                      _listingFilters.toggleCategoryFilter(category.id);
                      _listingFilters.updateProducts();
                  },
                )
              ),
          ],
        ),
        const SizedBox(height: 12),
        Text(
          'Brands',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 3.0,
          runSpacing: 3.0,
          children: [
            for (var brand in widget.brands)             
              Observer(builder: (_) => FilterChip(
                label: Text(brand.name),
                selected: _listingFilters.brandFilter.contains(brand.id),
                onSelected: (selected) {
                  _listingFilters.toggleBrandFilter(brand.id);
                  _listingFilters.updateProducts();
                },
            )
            )
          ]
        )
      ],
    );
  }

  Widget _buildSortContent() {
    return _expandedContainer(
      contents: [
        Text(
          'Sort by',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 12),
        Observer(builder: (_) => RadioGroup<SortOption>(
          groupValue: _listingFilters.sortOption,
          onChanged: (value) {
            _listingFilters.setSortOption(value);
            _listingFilters.updateProducts();
          },
          child: Column(
            children: [
              ListTile(title: Text('Recommended'), leading: Radio<SortOption>(value: SortOption.relevance)),
              ListTile(title: Text('Most Popular'), leading: Radio<SortOption>(value: SortOption.popular)),
              ListTile(title: Text('Newest Arrivals'), leading: Radio<SortOption>(value: SortOption.timeDesc)),
              ListTile(title: Text('Oldest Arrivals'), leading: Radio<SortOption>(value: SortOption.timeAsc)),
              ListTile(title: Text('Name: A-Z'), leading: Radio<SortOption>(value: SortOption.nameAsc)),
              ListTile(title: Text('Name: Z-A'), leading: Radio<SortOption>(value: SortOption.nameDesc)),
              ListTile(title: Text('Price: Low to High'), leading: Radio<SortOption>(value: SortOption.priceAsc)),
              ListTile(title: Text('Price: High to Low'), leading: Radio<SortOption>(value: SortOption.priceDesc)),
              ListTile(title: Text('Rating'), leading: Radio<SortOption>(value: SortOption.rating)),
              ],
            )
          ),
        )
      ],
    );
  }

  Widget _buildChatContent() {
    return _expandedContainer(
      contents: [
        Text(
          'AI Assistant',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 12),
        Text(
          'Describe what you\'re looking for and let AI help you find it.',
          style: Theme.of(context).textTheme.bodySmall,
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _chatInputController,
          decoration: InputDecoration(
            hintText: 'Tell AI what product you want...',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            suffixIcon: IconButton(
              icon: Icon(Icons.send),
              onPressed: _handleAIChatMock,
            ),
          ),
          onSubmitted: (_) => _handleAIChatMock(),
          maxLines: 3,
          minLines: 1,
        ),
      ],
    );
  }

  void _handleAIChatMock() {
    final prompt = _chatInputController.text.trim();
    if (prompt.isEmpty) return;

    // Mock AI results
    if (widget.categories.isNotEmpty) {
      _listingFilters.toggleCategoryFilter(widget.categories.first.id);
    }
    _listingFilters.setSortOption(SortOption.popular);
    _listingFilters.setSearchQuery('Product');
    _listingFilters.updateProducts();

    // Clear input and close the chat panel
    _chatInputController.clear();
    setState(() {
      _chatOpen = false;
    });

    // Show success toast
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('AI has set search filters for you'),
        behavior: SnackBarBehavior.floating,
        duration: Duration(seconds: 3),
      ),
    );
  }

  // options in the bottom bar
  Widget bottomBarButton (void Function() onPressed, bool isVisible, Icon icon) {
    return IconButton(
      onPressed: onPressed,
      icon: Badge( // shows red badge if there are active filters/search query
        isLabelVisible: isVisible,
        label: Text('!', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.red,
        child: icon
      )
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      alignment: Alignment.bottomCenter,
      children: [
          // if (isExpanded) SizedBox(height: 350), // reserve space for expanded content
          Container(
          height: kBottomNavigationBarHeight,
          color: Colors.red[100],//colorScheme.surface,
          // elevation: 8,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Row(
              children: [
                Observer(builder: (_) => bottomBarButton(() {
                    setState(() {
                        _filterOpen = !_filterOpen;
                        _searchOpen = false;
                        _sortOpen = false;
                        _chatOpen = false;
                      });
                    }, 
                    _listingFilters.categoryFilter.isNotEmpty || _listingFilters.brandFilter.isNotEmpty,
                    Icon(Icons.filter_list_alt)
                  )
                ),
                Observer(builder: (_) => bottomBarButton(() {
                    setState(() {
                      _searchOpen = !_searchOpen;
                      _filterOpen = false;
                      _sortOpen = false;
                      _chatOpen = false;
                    });
                  }, 
                  _listingFilters.searchQuery.isNotEmpty, 
                  Icon(Icons.search)
                )
                ),
                bottomBarButton(() {
                    setState(() {
                      _sortOpen = !_sortOpen;
                      _searchOpen = false;
                      _filterOpen = false;
                      _chatOpen = false;
                    });
                  }, 
                  false, // no badge for sort
                  Icon(Icons.sort)
                ),
                bottomBarButton(() {
                    setState(() {
                      _chatOpen = !_chatOpen;
                      _searchOpen = false;
                      _filterOpen = false;
                      _sortOpen = false;
                    });
                  }, 
                  false, // no badge for AI chat
                  Icon(Icons.smart_toy)
                ),
              ],
            ),
          ),
        ),
        if (isExpanded) SizedBox(height: 500),
        Positioned(
          left: 0,
          right: 0,
          bottom: kBottomNavigationBarHeight,
          child: Padding(
              padding: const EdgeInsets.only(), // add if needed
              child: SingleChildScrollView(child: _buildExpandedContent()),
            ),
        )
      ]
    );
  }
}