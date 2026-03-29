import 'package:mobile_ai_erp/presentation/storefront/store/product_listing_store.dart';

class FilterArguments {
  const FilterArguments({
    this.selectedCategories,
    this.selectedBrands,
    this.searchQuery,
    this.sortOption,
  });

  final List<String>? selectedCategories;
  final List<String>? selectedBrands;
  final String? searchQuery;
  final SortOption? sortOption;
}