import 'package:mobile_ai_erp/core/stores/error/error_store.dart';
import 'package:mobile_ai_erp/domain/entity/product_detail/product_detail.dart';
import 'package:mobile_ai_erp/domain/repository/product/product_detail_repository.dart';
import 'package:mobx/mobx.dart';

part 'product_detail_store.g.dart';

class ProductDetailStore = _ProductDetailStore with _$ProductDetailStore;

abstract class _ProductDetailStore with Store {
  _ProductDetailStore(this._repository, this.errorStore);

  final ProductDetailRepository _repository;
  final ErrorStore errorStore;

  @observable
  ProductDetail? product;

  @observable
  ObservableList<StorefrontProductSummary> relatedProducts =
      ObservableList<StorefrontProductSummary>();

  @observable
  ObservableList<StorefrontProductSummary> brandProducts =
      ObservableList<StorefrontProductSummary>();

  @observable
  StorefrontCategoryDetail? categoryDetail;

  @observable
  bool isLoading = false;

  @observable
  String? errorMessage;

  @observable
  String? selectedColorName;

  @observable
  String? selectedSize;

  @observable
  int currentImageIndex = 0;

  @observable
  bool isDescriptionExpanded = false;

  @computed
  List<ProductColor> get availableColors {
    if (product == null) return [];
    final seen = <String>{};
    final colors = <ProductColor>[];
    for (final v in product!.variants) {
      if (v.color != null && seen.add(v.color!.name)) {
        colors.add(v.color!);
      }
    }
    return colors;
  }

  @computed
  List<String> get availableSizes {
    if (product == null) return [];
    final seen = <String>{};
    return product!.variants
        .where(
          (v) =>
              (selectedColorName == null ||
                  v.color?.name == selectedColorName) &&
              v.size != null &&
              seen.add(v.size!),
        )
        .map((v) => v.size!)
        .toList();
  }

  @computed
  ProductVariant? get selectedVariant {
    if (product == null) return null;
    if (product!.variants.isEmpty) return null;
    final hasColors = availableColors.isNotEmpty;
    final hasSizes = availableSizes.isNotEmpty;
    for (final v in product!.variants) {
      final colorMatches =
          !hasColors ||
          selectedColorName == null ||
          v.color?.name == selectedColorName;
      final sizeMatches =
          !hasSizes || selectedSize == null || v.size == selectedSize;
      if (colorMatches && sizeMatches) {
        return v;
      }
    }
    return product!.variants.first;
  }

  @computed
  double get displayPrice {
    final v = selectedVariant ?? (product?.variants.isNotEmpty == true ? product!.variants.first : null);
    return v?.effectivePrice ?? 0;
  }

  @computed
  double? get originalPrice {
    final v = selectedVariant ?? (product?.variants.isNotEmpty == true ? product!.variants.first : null);
    if (v == null || !v.hasDiscount) return null;
    return v.price;
  }

  @computed
  int get discountPercentage {
    final v = selectedVariant ?? (product?.variants.isNotEmpty == true ? product!.variants.first : null);
    return v?.discountPercentage ?? 0;
  }

  bool isSizeInStock(String size) {
    if (product == null) return false;
    for (final v in product!.variants) {
      final colorMatches =
          selectedColorName == null || v.color?.name == selectedColorName;
      if (colorMatches && v.size == size) {
        return v.inStock;
      }
    }
    return false;
  }

  bool isSizeLowStock(String size) {
    if (product == null) return false;
    for (final v in product!.variants) {
      final colorMatches =
          selectedColorName == null || v.color?.name == selectedColorName;
      if (colorMatches && v.size == size) {
        return v.isLowStock;
      }
    }
    return false;
  }

  @action
  Future<void> loadProduct(String productId) async {
    isLoading = true;
    errorMessage = null;
    product = null;
    relatedProducts.clear();
    brandProducts.clear();
    categoryDetail = null;
    currentImageIndex = 0;

    try {
      final data = await _repository.getProductDetailPage(productId);
      product = data.product;
      relatedProducts = ObservableList.of(data.relatedProducts);
      brandProducts = ObservableList.of(data.brandProducts);
      categoryDetail = data.categoryDetail;
      selectedColorName = availableColors.isNotEmpty
          ? availableColors.first.name
          : null;
      selectedSize = availableSizes.isNotEmpty ? availableSizes.first : null;
    } catch (error) {
      final message = error.toString();
      errorMessage = message;
      errorStore.setErrorMessage(message);
    } finally {
      isLoading = false;
    }
  }

  @action
  void setLoadError(String message) {
    isLoading = false;
    product = null;
    errorMessage = message;
    errorStore.setErrorMessage(message);
  }

  @action
  void selectColor(String colorName) {
    selectedColorName = colorName;
    final sizes = availableSizes;
    selectedSize = sizes.isNotEmpty ? sizes.first : null;
  }

  @action
  void selectSize(String size) {
    selectedSize = size;
  }

  @action
  void setImageIndex(int index) {
    currentImageIndex = index;
  }

  @action
  void toggleDescription() {
    isDescriptionExpanded = !isDescriptionExpanded;
  }
}
