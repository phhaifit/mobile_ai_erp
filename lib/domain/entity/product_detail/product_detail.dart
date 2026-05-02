import 'package:flutter/material.dart';

enum MediaType { image, video }

class ProductMedia {
  final String url;
  final String? thumbnailUrl;
  final MediaType type;

  const ProductMedia({
    required this.url,
    this.thumbnailUrl,
    required this.type,
  });
}

class ProductDetail {
  final String id;
  final String name;
  final String? brandId;
  final String brandName;
  final String? categoryId;
  final String categoryName;
  final bool inStock;
  final bool isFlashSale;
  final DateTime? flashSaleFrom;
  final DateTime? flashSaleEndTime;
  final List<ProductMedia> media;
  final List<ProductVariant> variants;
  final String descriptionHtml;
  final List<ProductSpecification> specifications;
  final List<ProductReview> reviews;
  final double averageRating;
  final int reviewCount;

  const ProductDetail({
    required this.id,
    required this.name,
    this.brandId,
    required this.brandName,
    this.categoryId,
    required this.categoryName,
    required this.inStock,
    required this.isFlashSale,
    this.flashSaleFrom,
    this.flashSaleEndTime,
    required this.media,
    required this.variants,
    required this.descriptionHtml,
    required this.specifications,
    required this.reviews,
    required this.averageRating,
    required this.reviewCount,
  });
}

class ProductVariant {
  final String id;
  final String sku;
  final ProductColor? color;
  final String? size;
  final double price;
  final double? salePrice;
  final int stockQuantity;

  const ProductVariant({
    required this.id,
    required this.sku,
    this.color,
    this.size,
    required this.price,
    this.salePrice,
    required this.stockQuantity,
  });

  bool get inStock => stockQuantity > 0;
  bool get isLowStock => stockQuantity > 0 && stockQuantity <= 5;
  double get effectivePrice => salePrice ?? price;
  bool get hasDiscount => salePrice != null && salePrice! < price;

  int get discountPercentage {
    if (!hasDiscount) return 0;
    return (((price - salePrice!) / price) * 100).round();
  }
}

class ProductColor {
  final String name;
  final Color color;

  const ProductColor({required this.name, required this.color});
}

class ProductSpecification {
  final String name;
  final String value;

  const ProductSpecification({required this.name, required this.value});
}

class ProductReview {
  final String id;
  final String userName;
  final String? userAvatarUrl;
  final double rating;
  final String comment;
  final DateTime date;
  final List<String>? imageUrls;

  const ProductReview({
    required this.id,
    required this.userName,
    this.userAvatarUrl,
    required this.rating,
    required this.comment,
    required this.date,
    this.imageUrls,
  });
}

class StorefrontProductSummary {
  final String id;
  final String name;
  final String description;
  final double price;
  final double? originalPrice;
  final List<String> imageUrls;
  final double rating;
  final String? brandName;
  final String? categoryName;
  final bool inStock;
  final int availableStock;

  const StorefrontProductSummary({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    this.originalPrice,
    required this.imageUrls,
    required this.rating,
    this.brandName,
    this.categoryName,
    required this.inStock,
    required this.availableStock,
  });
}

class StorefrontCategoryBreadcrumb {
  final String id;
  final String name;
  final String slug;

  const StorefrontCategoryBreadcrumb({
    required this.id,
    required this.name,
    required this.slug,
  });
}

class StorefrontCategoryDetail {
  final String id;
  final String name;
  final String slug;
  final String? description;
  final List<StorefrontCategoryBreadcrumb> breadcrumb;

  const StorefrontCategoryDetail({
    required this.id,
    required this.name,
    required this.slug,
    this.description,
    required this.breadcrumb,
  });
}

class ProductDetailPageData {
  final ProductDetail product;
  final List<StorefrontProductSummary> relatedProducts;
  final List<StorefrontProductSummary> brandProducts;
  final StorefrontCategoryDetail? categoryDetail;

  const ProductDetailPageData({
    required this.product,
    required this.relatedProducts,
    required this.brandProducts,
    this.categoryDetail,
  });
}
