import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:mobile_ai_erp/di/service_locator.dart';
import 'package:mobile_ai_erp/presentation/storefront/models/storefront_models.dart';
import 'package:mobile_ai_erp/presentation/storefront/store/product_listing_store.dart';
import 'package:mobile_ai_erp/presentation/storefront/widgets/storefront_ui.dart';

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

  void _syncControllersFromStore() {
    _searchController.text = _listingFilters.searchQuery;
    _minPriceController.text =
        _listingFilters.minPriceFilter?.toStringAsFixed(0) ?? '';
    _maxPriceController.text =
        _listingFilters.maxPriceFilter?.toStringAsFixed(0) ?? '';
  }

  Future<void> _applySearch() async {
    _listingFilters.commitSearchQuery(_searchController.text.trim());
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

  Future<void> _showStorefrontSheet({
    required String title,
    required Widget child,
  }) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        final bottomInset = MediaQuery.of(context).viewInsets.bottom;
        return Padding(
          padding: EdgeInsets.only(bottom: bottomInset),
          child: Container(
            decoration: const BoxDecoration(
              color: Color(0xFFF7F4EF),
              borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
            ),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 18, 20, 24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 44,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.black12,
                        borderRadius: BorderRadius.circular(999),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    title,
                    style: Theme.of(
                      context,
                    ).textTheme.headlineMedium?.copyWith(fontSize: 24),
                  ),
                  const SizedBox(height: 16),
                  Flexible(
                    child: SingleChildScrollView(
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: child,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildQuickAction({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
    String? badge,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    return Expanded(
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
          backgroundColor: Colors.white,
          side: BorderSide(
            color: colorScheme.outlineVariant.withValues(alpha: 0.35),
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 18, color: colorScheme.primary),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                label,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.labelLarge?.copyWith(
                  color: colorScheme.onSurface,
                ),
              ),
            ),
            if (badge != null) ...[
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: colorScheme.primary,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  badge,
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: Colors.white,
                    fontSize: 11,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChipGroup({
    required String title,
    required List<Widget> children,
  }) {
    if (children.isEmpty) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 10),
          Wrap(spacing: 10, runSpacing: 10, children: children),
        ],
      ),
    );
  }

  Widget _buildSheetTextField({
    required TextEditingController controller,
    required String label,
    String? helperText,
  }) {
    return TextField(
      controller: controller,
      keyboardType: TextInputType.number,
      decoration: InputDecoration(
        labelText: label,
        helperText: helperText,
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
  }

  Future<void> _openSearchSheet() async {
    _syncControllersFromStore();
    await _showStorefrontSheet(
      title: 'Search products',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Search by product name, brand or category.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Search the storefront',
              prefixIcon: const Icon(Icons.search),
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(18),
              ),
            ),
            textInputAction: TextInputAction.search,
            onSubmitted: (_) async {
              await _applySearch();
              if (mounted) {
                Navigator.of(context).pop();
              }
            },
          ),
          const SizedBox(height: 18),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: () async {
                await _applySearch();
                if (mounted) {
                  Navigator.of(context).pop();
                }
              },
              icon: const Icon(Icons.travel_explore),
              label: const Text('Search now'),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _openFilterSheet() async {
    _syncControllersFromStore();
    await _showStorefrontSheet(
      title: 'Filter results',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Refine by category, brand, attributes, stock and price.',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),
              TextButton(
                onPressed: () async {
                  await _resetAllFilters();
                  if (mounted) {
                    Navigator.of(context).pop();
                  }
                },
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
                    label: Text('${category.name} (${category.count})'),
                    selected: _listingFilters.categoryFilter.contains(
                      category.discoveryKey,
                    ),
                    onSelected: (_) =>
                        _listingFilters.toggleCategoryFilter(
                          category.discoveryKey,
                        ),
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
                    label: Text('${brand.name} (${brand.count})'),
                    selected: _listingFilters.brandFilter.contains(
                      brand.discoveryKey,
                    ),
                    onSelected: (_) =>
                        _listingFilters.toggleBrandFilter(brand.discoveryKey),
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
                  selected:
                      _listingFilters.availabilityFilter == 'out_of_stock',
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
          if (widget.attributes.isNotEmpty)
            for (final attribute in widget.attributes)
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
          Text('Price range', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _buildSheetTextField(
                  controller: _minPriceController,
                  label: 'Min price',
                  helperText: _listingFilters.availableMinPrice > 0
                      ? storefrontCurrency(_listingFilters.availableMinPrice)
                      : null,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildSheetTextField(
                  controller: _maxPriceController,
                  label: 'Max price',
                  helperText: _listingFilters.availableMaxPrice > 0
                      ? storefrontCurrency(_listingFilters.availableMaxPrice)
                      : null,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: () async {
                await _applyAdvancedFilters();
                if (mounted) {
                  Navigator.of(context).pop();
                }
              },
              icon: const Icon(Icons.tune),
              label: const Text('Apply filters'),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _openSortSheet() async {
    await _showStorefrontSheet(
      title: 'Sort products',
      child: Observer(
        builder: (_) => RadioGroup<SortOption>(
          groupValue: _listingFilters.sortOption,
          onChanged: (selected) async {
            _listingFilters.setSortOption(selected);
            await _listingFilters.updateProducts();
            if (mounted) {
              Navigator.of(context).pop();
            }
          },
          child: Column(
            children: [
              for (final option in const <(String, SortOption)>[
                ('Relevance', SortOption.relevance),
                ('Most popular', SortOption.popular),
                ('Newest first', SortOption.timeDesc),
                ('Oldest first', SortOption.timeAsc),
                ('Name A-Z', SortOption.nameAsc),
                ('Name Z-A', SortOption.nameDesc),
                ('Price low to high', SortOption.priceAsc),
                ('Price high to low', SortOption.priceDesc),
                ('Highest rated', SortOption.rating),
              ])
                RadioListTile<SortOption>(
                  value: option.$2,
                  contentPadding: EdgeInsets.zero,
                  title: Text(option.$1),
                ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
        child: Observer(
          builder: (_) => StorefrontSurface(
            margin: EdgeInsets.zero,
            padding: const EdgeInsets.all(14),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    _buildQuickAction(
                      icon: Icons.search,
                      label: _listingFilters.hasSearchText
                          ? 'Search active'
                          : 'Search',
                      onPressed: _openSearchSheet,
                      badge: _listingFilters.hasSearchText ? '1' : null,
                    ),
                    const SizedBox(width: 10),
                    _buildQuickAction(
                      icon: Icons.tune,
                      label: 'Filters',
                      onPressed: _openFilterSheet,
                      badge: _listingFilters.activeFilterCount > 0
                          ? _listingFilters.activeFilterCount.toString()
                          : null,
                    ),
                    const SizedBox(width: 10),
                    _buildQuickAction(
                      icon: Icons.swap_vert,
                      label: 'Sort',
                      onPressed: _openSortSheet,
                    ),
                  ],
                ),
                if (_listingFilters.hasSearchText ||
                    _listingFilters.activeFilterCount > 0) ...[
                  const SizedBox(height: 12),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        if (_listingFilters.hasSearchText)
                          StorefrontTag(
                            label: 'Query: ${_listingFilters.searchQuery}',
                            icon: Icons.search,
                          ),
                        if (_listingFilters.activeFilterCount > 0)
                          StorefrontTag(
                            label:
                                '${_listingFilters.activeFilterCount} filters applied',
                            icon: Icons.filter_alt_outlined,
                            backgroundColor: const Color(0xFFFCE7DF),
                          ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
