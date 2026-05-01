enum SupplierProductsFilter {
  all('All suppliers'),
  hasProducts('Has linked products'),
  noProducts('No linked products');

  const SupplierProductsFilter(this.label);

  final String label;

  bool? get hasProductsValue => switch (this) {
        SupplierProductsFilter.hasProducts => true,
        SupplierProductsFilter.noProducts => false,
        SupplierProductsFilter.all => null,
      };
}

enum SupplierSortOption {
  defaultOrder('Default order');

  const SupplierSortOption(this.label);

  final String label;
}
