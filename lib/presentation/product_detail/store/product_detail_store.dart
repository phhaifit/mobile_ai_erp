import 'package:flutter/material.dart';
import 'package:mobile_ai_erp/core/stores/error/error_store.dart';
import 'package:mobile_ai_erp/domain/repository/storefront/storefront_repository.dart';
import 'package:mobile_ai_erp/domain/entity/product_detail/product_detail.dart';
import 'package:mobx/mobx.dart';

part 'product_detail_store.g.dart';

class ProductDetailStore = _ProductDetailStore with _$ProductDetailStore;

abstract class _ProductDetailStore with Store {
  _ProductDetailStore(this._repository, this.errorStore);

  final StorefrontRepository _repository;
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

  @observable
  bool isLoading = false;

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
  Future<void> loadProduct(String productId) async {
    isLoading = true;
    errorStore.errorMessage = '';
    try {
      final remote = await _repository.getProductDetail(productId);
      product = _mapProductDetail(remote);
      if (availableColors.isNotEmpty) {
        selectedColorName = availableColors.first.name;
      }
      if (availableSizes.isNotEmpty) {
        selectedSize = availableSizes.first;
      }
    } catch (error) {
      errorStore.errorMessage = error.toString();
    } finally {
      isLoading = false;
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

  ProductDetail _mapProductDetail(dynamic remote) {
    final variants = (remote.variants as List<dynamic>? ?? const []);
    final hasColorDimension = variants.any(
      (variant) => (variant.attributes as List<dynamic>).any(
        (attribute) => attribute.toString().toLowerCase().startsWith('color:'),
      ),
    );
    final hasSizeDimension = variants.any(
      (variant) => (variant.attributes as List<dynamic>).any(
        (attribute) => attribute.toString().toLowerCase().startsWith('size:'),
      ),
    );

    return ProductDetail(
      id: remote.id as String,
      name: remote.title as String,
      brandName: remote.brand as String? ?? 'Unknown brand',
      categoryName: remote.category as String? ?? 'Uncategorized',
      media: (remote.images as List<String>)
          .map((url) => ProductMedia(url: url, type: MediaType.image))
          .toList(),
      variants: variants
          .map((item) => _mapVariant(item, hasColorDimension, hasSizeDimension))
          .cast<ProductVariant>()
          .toList(),
      descriptionHtml: remote.description as String? ?? '',
      specifications: [
        ProductSpecification(
          name: 'Brand',
          value: remote.brand as String? ?? 'Unknown',
        ),
        ProductSpecification(
          name: 'Category',
          value: remote.category as String? ?? 'Uncategorized',
        ),
        ProductSpecification(
          name: 'Availability',
          value: remote.inStock == true ? 'In stock' : 'Out of stock',
        ),
      ],
      reviews: const [],
      averageRating: (remote.rating as num?)?.toDouble() ?? 0,
      reviewCount: 0,
    );
  }

  ProductVariant _mapVariant(
    dynamic variant,
    bool hasColorDimension,
    bool hasSizeDimension,
  ) {
    final attributes = (variant.attributes as List<dynamic>? ?? const [])
        .map((item) => item.toString())
        .toList();
    final colorValue = _extractAttribute(attributes, 'color');
    final sizeValue = _extractAttribute(attributes, 'size');
    final effectiveVariantId =
        variant.id as String? ?? variant.sku as String? ?? 'default';
    final effectiveSku = variant.sku as String? ?? effectiveVariantId;
    return ProductVariant(
      id: effectiveVariantId,
      sku: effectiveSku,
      color: hasColorDimension && colorValue != null
          ? ProductColor(name: colorValue, color: _colorFromName(colorValue))
          : (!hasColorDimension
                ? const ProductColor(name: 'Default', color: Color(0xFF424242))
                : null),
      size: hasSizeDimension ? sizeValue : 'Default',
      price:
          (variant.basePrice as num?)?.toDouble() ??
          (variant.sellingPrice as num?)?.toDouble() ??
          0,
      salePrice: (variant.sellingPrice as num?)?.toDouble(),
      stockQuantity: 20,
    );
  }

  String? _extractAttribute(List<String> attributes, String key) {
    for (final attribute in attributes) {
      final parts = attribute.split(':');
      if (parts.length < 2) {
        continue;
      }
      if (parts.first.trim().toLowerCase() == key.toLowerCase()) {
        return parts.sublist(1).join(':').trim();
      }
    }
    return null;
  }

  Color _colorFromName(String value) {
    switch (value.toLowerCase()) {
      case 'black':
        return const Color(0xFF212121);
      case 'white':
        return const Color(0xFFFFFFFF);
      case 'red':
        return const Color(0xFFC62828);
      case 'blue':
        return const Color(0xFF1565C0);
      case 'green':
        return const Color(0xFF2E7D32);
      default:
        return const Color(0xFF757575);
    }
  }
}
