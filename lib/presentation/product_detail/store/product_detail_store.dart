import 'package:mobile_ai_erp/core/stores/error/error_store.dart';
import 'package:mobile_ai_erp/domain/entity/product_detail/product_detail.dart';
import 'package:mobile_ai_erp/presentation/product_detail/data/mock_product_data.dart';
import 'package:mobx/mobx.dart';

part 'product_detail_store.g.dart';

class ProductDetailStore = _ProductDetailStore with _$ProductDetailStore;

abstract class _ProductDetailStore with Store {
  _ProductDetailStore(this.errorStore);

  final ErrorStore errorStore;

  @observable
  ProductDetail? product;

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
    if (product == null || selectedColorName == null) return [];
    return product!.variants
        .where((v) => v.color?.name == selectedColorName && v.size != null)
        .map((v) => v.size!)
        .toList();
  }

  @computed
  ProductVariant? get selectedVariant {
    if (product == null) return null;
    for (final v in product!.variants) {
      if (v.color?.name == selectedColorName && v.size == selectedSize) {
        return v;
      }
    }
    return null;
  }

  @computed
  double get displayPrice {
    final v = selectedVariant ?? product?.variants.first;
    return v?.effectivePrice ?? 0;
  }

  @computed
  double? get originalPrice {
    final v = selectedVariant ?? product?.variants.first;
    if (v == null || !v.hasDiscount) return null;
    return v.price;
  }

  @computed
  int get discountPercentage {
    final v = selectedVariant ?? product?.variants.first;
    return v?.discountPercentage ?? 0;
  }

  bool isSizeInStock(String size) {
    if (product == null || selectedColorName == null) return false;
    for (final v in product!.variants) {
      if (v.color?.name == selectedColorName && v.size == size) {
        return v.inStock;
      }
    }
    return false;
  }

  bool isSizeLowStock(String size) {
    if (product == null || selectedColorName == null) return false;
    for (final v in product!.variants) {
      if (v.color?.name == selectedColorName && v.size == size) {
        return v.isLowStock;
      }
    }
    return false;
  }

  @action
  void loadProduct(String productId) {
    product = MockProductData.sampleProduct;
    if (availableColors.isNotEmpty) {
      selectedColorName = availableColors.first.name;
    }
    if (availableSizes.isNotEmpty) {
      selectedSize = availableSizes.first;
    }
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
