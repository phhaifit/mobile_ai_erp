import 'package:mobile_ai_erp/presentation/storefront/store/product_listing_store.dart';

class FilterArguments {
  const FilterArguments({
    this.selectedCategories,
    this.selectedBrands,
    this.selectedAttributeValueIds,
    this.searchQuery,
    this.sortOption,
    this.categoryKey,
    this.brandKey,
    this.collectionSlug,
    this.minPrice,
    this.maxPrice,
    this.rating,
    this.availability,
  });

  final List<String>? selectedCategories;
  final List<String>? selectedBrands;
  final List<String>? selectedAttributeValueIds;
  final String? searchQuery;
  final SortOption? sortOption;
  final String? categoryKey;
  final String? brandKey;
  final String? collectionSlug;
  final double? minPrice;
  final double? maxPrice;
  final double? rating;
  final String? availability;
}
