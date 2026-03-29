class Strings {
  Strings._();

  //General
  static const String appName = "Boilerplate Project";
  static const String cancel = "Cancel";
  static const String delete = "Delete";
  static const String submit = "Submit";
}

/// Namespace class for product-related string constants
class ProductStrings {
  ProductStrings._();

  // Screen titles
  static const String screenTitle = "Products";
  static const String screenDescription = "Products management";
  static const String detailTitle = "Product Detail";
  static const String createTitle = "Create Product";
  static const String editTitle = "Edit Product";
  static const String filterTitle = "Filter Products";

  // Form field labels
  static const String name = "Product Name";
  static const String sku = "SKU";
  static const String price = "Price";
  static const String description = "Description";
  static const String status = "Status";
  static const String category = "Category";
  static const String brand = "Brand";
  static const String tags = "Tags";

  // Status labels
  static const String statusNew = "New";
  static const String statusActive = "Active";
  static const String statusOutOfStock = "Out of Stock";
  static const String statusDiscontinued = "Discontinued";

  // Detail screen labels
  static const String details = "Details";
  static const String created = "Created";
  static const String skuLabel = "SKU";

  // Messages and placeholders
  static const String noProductsFound = "No products found";
  static const String productNotFound = "Product not found";
  static const String searchPlaceholder = "Search products...";
  static const String noneValue = "None";

  // Delete dialog
  static const String deleteTitle = "Delete Product";
  static const String deleteConfirm = "Are you sure you want to delete this product?";
  static const String deleteMessage = "Are you sure you want to delete";

  // Filter actions
  static const String clear = "Clear";
  static const String apply = "Apply";
  static const String all = "All";

  // FAB tooltip
  static const String createTooltip = "Create Product";
  static const String refreshTooltip = "Refresh Products";

  // Form button labels
  static const String createButton = "Create";
  static const String updateButton = "Update";

  // Category & Brand field labels with required indicator
  static const String categoryRequired = "Category *";
  static const String brandRequired = "Brand *";
}
