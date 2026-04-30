import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:mobile_ai_erp/di/service_locator.dart';
import 'package:mobile_ai_erp/presentation/storefront/models/storefront_models.dart';
import 'package:mobile_ai_erp/presentation/storefront/store/product_listing_store.dart';

class SearchFilterBar extends StatefulWidget {
  const SearchFilterBar({
    super.key,
    required this.categories,
    required this.brands,
    required this.attributes,
  });

  final List<StorefrontFacetOption> categories;
  final List<StorefrontFacetOption> brands;
  final List<StorefrontAttributeFacet> attributes;

  @override
  State<SearchFilterBar> createState() => _SearchFilterBarState();
}

class _SearchFilterBarState extends State<SearchFilterBar> {
  final _listingFilters = getIt<ListingFilters>();
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _minPriceController = TextEditingController();
  final TextEditingController _maxPriceController = TextEditingController();

  bool _searchOpen = false;
  bool _filterOpen = false;
  bool _sortOpen = false;

  @override
  void initState() {
    super.initState();
    _syncControllersFromStore();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _minPriceController.dispose();
    _maxPriceController.dispose();
    super.dispose();
  }

  bool get isExpanded => _searchOpen || _filterOpen || _sortOpen;

  void _syncControllersFromStore() {
    _searchController.text = _listingFilters.searchQuery;
    _minPriceController.text =
        _listingFilters.minPriceFilter?.toStringAsFixed(0) ?? '';
    _maxPriceController.text =
        _listingFilters.maxPriceFilter?.toStringAsFixed(0) ?? '';
  }

  Widget _expandedContainer({required List<Widget> children}) {
    return Material(
      elevation: 8,
      color: Colors.white,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxHeight: 360),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: children,
          ),
        ),
      ),
    );
  }

  Future<void> _applySearch() async {
    _listingFilters.setSearchQuery(_searchController.text.trim());
    await _listingFilters.updateProducts();
  }

  Future<void> _applyAdvancedFilters() async {
    final minPrice = double.tryParse(_minPriceController.text.trim());
    final maxPrice = double.tryParse(_maxPriceController.text.trim());
    _listingFilters.setPriceRange(min: minPrice, max: maxPrice);
    await _listingFilters.updateProducts();
  }

  Future<void> _resetAllFilters() async {
    _listingFilters.resetFilters();
    _syncControllersFromStore();
    await _listingFilters.updateProducts();
  }

  Widget _buildSearchContent() {
    return _expandedContainer(
      children: [
        Text(
          'Search storefront',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _searchController,
          decoration: InputDecoration(
            hintText: 'Search by product name, brand or category',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            prefixIcon: const Icon(Icons.search),
            suffixIcon: IconButton(
              icon: const Icon(Icons.send),
              onPressed: _applySearch,
            ),
          ),
          onSubmitted: (_) => _applySearch(),
          onChanged: _listingFilters.setSearchQuery,
        ),
      ],
    );
  }

  Widget _buildFilterChipGroup({
    required String title,
    required List<Widget> children,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: Theme.of(context).textTheme.titleSmall),
        const SizedBox(height: 8),
        Wrap(spacing: 8, runSpacing: 8, children: children),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildFilterContent() {
    return _expandedContainer(
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                'Filters',
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
            TextButton(
              onPressed: _resetAllFilters,
              child: const Text('Clear all'),
            ),
          ],
        ),
        const SizedBox(height: 12),
        _buildFilterChipGroup(
          title: 'Categories',
          children: [
            for (final category in widget.categories)
              Observer(
                builder: (_) => FilterChip(
                  label: Text(category.name),
                  selected: _listingFilters.categoryFilter.contains(
                    category.id,
                  ),
                  onSelected: (_) =>
                      _listingFilters.toggleCategoryFilter(category.id),
                ),
              ),
          ],
        ),
        _buildFilterChipGroup(
          title: 'Brands',
          children: [
            for (final brand in widget.brands)
              Observer(
                builder: (_) => FilterChip(
                  label: Text(brand.name),
                  selected: _listingFilters.brandFilter.contains(brand.id),
                  onSelected: (_) =>
                      _listingFilters.toggleBrandFilter(brand.id),
                ),
              ),
          ],
        ),
        _buildFilterChipGroup(
          title: 'Availability',
          children: [
            Observer(
              builder: (_) => FilterChip(
                label: Text('In stock (${_listingFilters.inStockCount})'),
                selected: _listingFilters.availabilityFilter == 'in_stock',
                onSelected: (_) => _listingFilters.setAvailabilityFilter(
                  _listingFilters.availabilityFilter == 'in_stock'
                      ? null
                      : 'in_stock',
                ),
              ),
            ),
            Observer(
              builder: (_) => FilterChip(
                label: Text(
                  'Out of stock (${_listingFilters.outOfStockCount})',
                ),
                selected: _listingFilters.availabilityFilter == 'out_of_stock',
                onSelected: (_) => _listingFilters.setAvailabilityFilter(
                  _listingFilters.availabilityFilter == 'out_of_stock'
                      ? null
                      : 'out_of_stock',
                ),
              ),
            ),
          ],
        ),
        _buildFilterChipGroup(
          title: 'Rating',
          children: [
            for (final rating
                in _listingFilters.availableRatings.isNotEmpty
                    ? _listingFilters.availableRatings
                    : [5, 4, 3, 2, 1])
              Observer(
                builder: (_) => FilterChip(
                  label: Text('$rating★ & up'),
                  selected: _listingFilters.ratingFilter == rating.toDouble(),
                  onSelected: (_) => _listingFilters.setRatingFilter(
                    _listingFilters.ratingFilter == rating.toDouble()
                        ? null
                        : rating.toDouble(),
                  ),
                ),
              ),
          ],
        ),
        Text('Price range', style: Theme.of(context).textTheme.titleSmall),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _minPriceController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Min',
                  helperText: _listingFilters.availableMinPrice > 0
                      ? 'From ${_listingFilters.availableMinPrice.toStringAsFixed(0)}'
                      : null,
                  border: const OutlineInputBorder(),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: TextField(
                controller: _maxPriceController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Max',
                  helperText: _listingFilters.availableMaxPrice > 0
                      ? 'To ${_listingFilters.availableMaxPrice.toStringAsFixed(0)}'
                      : null,
                  border: const OutlineInputBorder(),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        for (final attribute in widget.attributes) ...[
          _buildFilterChipGroup(
            title: attribute.attributeSetName,
            children: [
              for (final value in attribute.values)
                Observer(
                  builder: (_) => FilterChip(
                    label: Text(value.name),
                    selected: _listingFilters.attributeValueFilter.contains(
                      value.id,
                    ),
                    onSelected: (_) =>
                        _listingFilters.toggleAttributeFilter(value.id),
                  ),
                ),
            ],
          ),
        ],
        SizedBox(
          width: double.infinity,
          child: FilledButton(
            onPressed: _applyAdvancedFilters,
            child: const Text('Apply filters'),
          ),
        ),
      ],
    );
  }

  Widget _buildSortTile(String label, SortOption value) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(label),
      leading: Radio<SortOption>(value: value),
      onTap: () async {
        _listingFilters.setSortOption(value);
        await _listingFilters.updateProducts();
      },
    );
  }

  Widget _buildSortContent() {
    return _expandedContainer(
      children: [
        Text('Sort products', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 12),
        Observer(
          builder: (_) => RadioGroup<SortOption>(
            groupValue: _listingFilters.sortOption,
            onChanged: (selected) async {
              _listingFilters.setSortOption(selected);
              await _listingFilters.updateProducts();
            },
            child: Column(
              children: [
                _buildSortTile('Relevance', SortOption.relevance),
                _buildSortTile('Most popular', SortOption.popular),
                _buildSortTile('Newest first', SortOption.timeDesc),
                _buildSortTile('Oldest first', SortOption.timeAsc),
                _buildSortTile('Name A-Z', SortOption.nameAsc),
                _buildSortTile('Name Z-A', SortOption.nameDesc),
                _buildSortTile('Price low to high', SortOption.priceAsc),
                _buildSortTile('Price high to low', SortOption.priceDesc),
                _buildSortTile('Highest rated', SortOption.rating),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildExpandedContent() {
    if (_searchOpen) {
      return _buildSearchContent();
    }
    if (_filterOpen) {
      return _buildFilterContent();
    }
    if (_sortOpen) {
      return _buildSortContent();
    }
    return const SizedBox.shrink();
  }

  Widget _bottomBarButton({
    required VoidCallback onPressed,
    required bool isVisible,
    required IconData icon,
    required String tooltip,
  }) {
    return IconButton(
      onPressed: onPressed,
      tooltip: tooltip,
      icon: Badge(
        isLabelVisible: isVisible,
        label: const Text('!'),
        child: Icon(icon),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      alignment: Alignment.bottomCenter,
      children: [
        Container(
          height: kBottomNavigationBarHeight,
          color: Theme.of(context).colorScheme.surface,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Row(
              children: [
                Observer(
                  builder: (_) => _bottomBarButton(
                    onPressed: () {
                      _syncControllersFromStore();
                      setState(() {
                        _filterOpen = !_filterOpen;
                        _searchOpen = false;
                        _sortOpen = false;
                      });
                    },
                    isVisible: _listingFilters.hasAnyFilters,
                    icon: Icons.filter_list_alt,
                    tooltip: 'Filters',
                  ),
                ),
                Observer(
                  builder: (_) => _bottomBarButton(
                    onPressed: () {
                      _syncControllersFromStore();
                      setState(() {
                        _searchOpen = !_searchOpen;
                        _filterOpen = false;
                        _sortOpen = false;
                      });
                    },
                    isVisible: _listingFilters.hasSearchText,
                    icon: Icons.search,
                    tooltip: 'Search',
                  ),
                ),
                _bottomBarButton(
                  onPressed: () {
                    setState(() {
                      _sortOpen = !_sortOpen;
                      _searchOpen = false;
                      _filterOpen = false;
                    });
                  },
                  isVisible: false,
                  icon: Icons.sort,
                  tooltip: 'Sort',
                ),
              ],
            ),
          ),
        ),
        if (isExpanded) const SizedBox(height: 420),
        Positioned(
          left: 0,
          right: 0,
          bottom: kBottomNavigationBarHeight,
          child: _buildExpandedContent(),
        ),
      ],
    );
  }
}
