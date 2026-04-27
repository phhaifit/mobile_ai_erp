class StorefrontPaginatedResponse<T> {
  const StorefrontPaginatedResponse({
    required this.data,
    required this.page,
    required this.pageSize,
    required this.totalItems,
    required this.totalPages,
  });

  final List<T> data;
  final int page;
  final int pageSize;
  final int totalItems;
  final int totalPages;

  bool get hasMore => page < totalPages;
}

class StorefrontProduct {
  const StorefrontProduct({
    required this.id,
    required this.title,
    required this.description,
    required this.price,
    required this.originalPrice,
    required this.images,
    required this.tags,
    required this.rating,
    required this.brand,
    required this.brandId,
    required this.category,
    required this.categoryId,
    required this.isFlashSale,
    required this.flashSaleFrom,
    required this.flashSaleEndTime,
    required this.inStock,
    required this.availableStock,
    required this.highlights,
  });

  final String id;
  final String title;
  final String? description;
  final double price;
  final double? originalPrice;
  final List<String> images;
  final List<String> tags;
  final double rating;
  final String? brand;
  final String? brandId;
  final String? category;
  final String? categoryId;
  final bool isFlashSale;
  final String? flashSaleFrom;
  final String? flashSaleEndTime;
  final bool inStock;
  final int availableStock;
  final Map<String, String?> highlights;

  factory StorefrontProduct.fromJson(Map<String, dynamic> json) {
    return StorefrontProduct(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      description: json['description'] as String?,
      price: (json['price'] as num?)?.toDouble() ?? 0,
      originalPrice: (json['originalPrice'] as num?)?.toDouble(),
      images: (json['images'] as List<dynamic>? ?? const [])
          .map((item) => item.toString())
          .toList(),
      tags: (json['tags'] as List<dynamic>? ?? const [])
          .map((item) => item.toString())
          .toList(),
      rating: (json['rating'] as num?)?.toDouble() ?? 0,
      brand: json['brand'] as String?,
      brandId: json['brandId'] as String?,
      category: json['category'] as String?,
      categoryId: json['categoryId'] as String?,
      isFlashSale: json['isFlashSale'] == true,
      flashSaleFrom: json['flashSaleFrom'] as String?,
      flashSaleEndTime: json['flashSaleEndTime'] as String?,
      inStock: json['inStock'] == true,
      availableStock: (json['availableStock'] as num?)?.toInt() ?? 0,
      highlights: ((json['highlights'] as Map<String, dynamic>?) ?? const {})
          .map((key, value) => MapEntry(key, value?.toString())),
    );
  }
}

class StorefrontVariant {
  const StorefrontVariant({
    required this.id,
    required this.sku,
    required this.sellingPrice,
    required this.basePrice,
    required this.weight,
    required this.attributes,
  });

  final String id;
  final String sku;
  final double? sellingPrice;
  final double? basePrice;
  final double? weight;
  final List<String> attributes;

  factory StorefrontVariant.fromJson(Map<String, dynamic> json) {
    return StorefrontVariant(
      id: json['id'] as String? ?? '',
      sku: json['sku'] as String? ?? '',
      sellingPrice: (json['sellingPrice'] as num?)?.toDouble(),
      basePrice: (json['basePrice'] as num?)?.toDouble(),
      weight: (json['weight'] as num?)?.toDouble(),
      attributes: (json['attributes'] as List<dynamic>? ?? const [])
          .map((item) => item.toString())
          .toList(),
    );
  }
}

class StorefrontProductDetail extends StorefrontProduct {
  const StorefrontProductDetail({
    required super.id,
    required super.title,
    required super.description,
    required super.price,
    required super.originalPrice,
    required super.images,
    required super.tags,
    required super.rating,
    required super.brand,
    required super.brandId,
    required super.category,
    required super.categoryId,
    required super.isFlashSale,
    required super.flashSaleFrom,
    required super.flashSaleEndTime,
    required super.inStock,
    required super.availableStock,
    required super.highlights,
    required this.variants,
  });

  final List<StorefrontVariant> variants;

  factory StorefrontProductDetail.fromJson(Map<String, dynamic> json) {
    final base = StorefrontProduct.fromJson(json);
    return StorefrontProductDetail(
      id: base.id,
      title: base.title,
      description: base.description,
      price: base.price,
      originalPrice: base.originalPrice,
      images: base.images,
      tags: base.tags,
      rating: base.rating,
      brand: base.brand,
      brandId: base.brandId,
      category: base.category,
      categoryId: base.categoryId,
      isFlashSale: base.isFlashSale,
      flashSaleFrom: base.flashSaleFrom,
      flashSaleEndTime: base.flashSaleEndTime,
      inStock: base.inStock,
      availableStock: base.availableStock,
      highlights: base.highlights,
      variants: (json['variants'] as List<dynamic>? ?? const [])
          .whereType<Map<String, dynamic>>()
          .map(StorefrontVariant.fromJson)
          .toList(),
    );
  }
}

class StorefrontFacetOption {
  const StorefrontFacetOption({
    required this.id,
    required this.name,
    required this.count,
    this.slug,
  });

  final String id;
  final String name;
  final int count;
  final String? slug;

  factory StorefrontFacetOption.fromJson(Map<String, dynamic> json) {
    return StorefrontFacetOption(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      count: (json['count'] as num?)?.toInt() ?? 0,
      slug: json['slug'] as String?,
    );
  }
}

class StorefrontAttributeFacet {
  const StorefrontAttributeFacet({
    required this.attributeSetId,
    required this.attributeSetName,
    required this.values,
  });

  final String attributeSetId;
  final String attributeSetName;
  final List<StorefrontFacetOption> values;

  factory StorefrontAttributeFacet.fromJson(Map<String, dynamic> json) {
    return StorefrontAttributeFacet(
      attributeSetId: json['attributeSetId'] as String? ?? '',
      attributeSetName: json['attributeSetName'] as String? ?? '',
      values: (json['values'] as List<dynamic>? ?? const [])
          .whereType<Map<String, dynamic>>()
          .map(StorefrontFacetOption.fromJson)
          .toList(),
    );
  }
}

class StorefrontFacets {
  const StorefrontFacets({
    required this.brands,
    required this.categories,
    required this.minPrice,
    required this.maxPrice,
    required this.inStockCount,
    required this.outOfStockCount,
    required this.ratings,
    required this.attributes,
  });

  final List<StorefrontFacetOption> brands;
  final List<StorefrontFacetOption> categories;
  final double minPrice;
  final double maxPrice;
  final int inStockCount;
  final int outOfStockCount;
  final List<int> ratings;
  final List<StorefrontAttributeFacet> attributes;

  factory StorefrontFacets.fromJson(Map<String, dynamic> json) {
    final priceRange = json['priceRange'] as Map<String, dynamic>? ?? const {};
    final availability =
        json['availability'] as Map<String, dynamic>? ?? const {};
    return StorefrontFacets(
      brands: (json['brands'] as List<dynamic>? ?? const [])
          .whereType<Map<String, dynamic>>()
          .map(StorefrontFacetOption.fromJson)
          .toList(),
      categories: (json['categories'] as List<dynamic>? ?? const [])
          .whereType<Map<String, dynamic>>()
          .map(StorefrontFacetOption.fromJson)
          .toList(),
      minPrice: (priceRange['min'] as num?)?.toDouble() ?? 0,
      maxPrice: (priceRange['max'] as num?)?.toDouble() ?? 0,
      inStockCount: (availability['inStock'] as num?)?.toInt() ?? 0,
      outOfStockCount: (availability['outOfStock'] as num?)?.toInt() ?? 0,
      ratings: (json['ratings'] as List<dynamic>? ?? const [])
          .map((item) => (item as num).toInt())
          .toList(),
      attributes: (json['attributes'] as List<dynamic>? ?? const [])
          .whereType<Map<String, dynamic>>()
          .map(StorefrontAttributeFacet.fromJson)
          .toList(),
    );
  }
}

class StorefrontCategorySummary {
  const StorefrontCategorySummary({
    required this.id,
    required this.name,
    required this.slug,
  });

  final String id;
  final String name;
  final String slug;

  factory StorefrontCategorySummary.fromJson(Map<String, dynamic> json) {
    return StorefrontCategorySummary(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      slug: json['slug'] as String? ?? '',
    );
  }
}

class StorefrontCategoryTreeNode extends StorefrontCategorySummary {
  const StorefrontCategoryTreeNode({
    required super.id,
    required super.name,
    required super.slug,
    required this.description,
    required this.children,
  });

  final String? description;
  final List<StorefrontCategoryTreeNode> children;

  factory StorefrontCategoryTreeNode.fromJson(Map<String, dynamic> json) {
    return StorefrontCategoryTreeNode(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      slug: json['slug'] as String? ?? '',
      description: json['description'] as String?,
      children: (json['children'] as List<dynamic>? ?? const [])
          .whereType<Map<String, dynamic>>()
          .map(StorefrontCategoryTreeNode.fromJson)
          .toList(),
    );
  }
}

class StorefrontCategoryDetail extends StorefrontCategorySummary {
  const StorefrontCategoryDetail({
    required super.id,
    required super.name,
    required super.slug,
    required this.description,
    required this.parentId,
    required this.breadcrumb,
    required this.children,
  });

  final String? description;
  final String? parentId;
  final List<StorefrontCategorySummary> breadcrumb;
  final List<StorefrontCategorySummary> children;

  factory StorefrontCategoryDetail.fromJson(Map<String, dynamic> json) {
    return StorefrontCategoryDetail(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      slug: json['slug'] as String? ?? '',
      description: json['description'] as String?,
      parentId: json['parentId'] as String?,
      breadcrumb: (json['breadcrumb'] as List<dynamic>? ?? const [])
          .whereType<Map<String, dynamic>>()
          .map(StorefrontCategorySummary.fromJson)
          .toList(),
      children: (json['children'] as List<dynamic>? ?? const [])
          .whereType<Map<String, dynamic>>()
          .map(StorefrontCategorySummary.fromJson)
          .toList(),
    );
  }
}

class StorefrontBrand {
  const StorefrontBrand({
    required this.id,
    required this.name,
    required this.description,
    required this.logoUrl,
    required this.slug,
    required this.productCount,
    required this.featuredProducts,
  });

  final String id;
  final String name;
  final String? description;
  final String? logoUrl;
  final String slug;
  final int productCount;
  final List<StorefrontProduct> featuredProducts;

  factory StorefrontBrand.fromJson(Map<String, dynamic> json) {
    return StorefrontBrand(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      description: json['description'] as String?,
      logoUrl: json['logoUrl'] as String?,
      slug: json['slug'] as String? ?? '',
      productCount: (json['productCount'] as num?)?.toInt() ?? 0,
      featuredProducts: (json['featuredProducts'] as List<dynamic>? ?? const [])
          .whereType<Map<String, dynamic>>()
          .map(StorefrontProduct.fromJson)
          .toList(),
    );
  }
}

class StorefrontCollection {
  const StorefrontCollection({
    required this.id,
    required this.name,
    required this.slug,
    required this.description,
    required this.productCount,
    required this.featuredProducts,
  });

  final String id;
  final String name;
  final String slug;
  final String? description;
  final int productCount;
  final List<StorefrontProduct> featuredProducts;

  factory StorefrontCollection.fromJson(Map<String, dynamic> json) {
    return StorefrontCollection(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      slug: json['slug'] as String? ?? '',
      description: json['description'] as String?,
      productCount: (json['productCount'] as num?)?.toInt() ?? 0,
      featuredProducts: (json['featuredProducts'] as List<dynamic>? ?? const [])
          .whereType<Map<String, dynamic>>()
          .map(StorefrontProduct.fromJson)
          .toList(),
    );
  }
}

class StorefrontHomeData {
  const StorefrontHomeData({
    required this.banners,
    required this.featuredProducts,
    required this.newArrivals,
    required this.popularProducts,
    required this.featuredBrands,
    required this.featuredCategories,
    required this.collections,
  });

  final List<String> banners;
  final List<StorefrontProduct> featuredProducts;
  final List<StorefrontProduct> newArrivals;
  final List<StorefrontProduct> popularProducts;
  final List<StorefrontBrand> featuredBrands;
  final List<StorefrontCategorySummary> featuredCategories;
  final List<StorefrontCollection> collections;

  factory StorefrontHomeData.fromJson(Map<String, dynamic> json) {
    return StorefrontHomeData(
      banners: (json['banners'] as List<dynamic>? ?? const [])
          .map((item) => item.toString())
          .toList(),
      featuredProducts: (json['featuredProducts'] as List<dynamic>? ?? const [])
          .whereType<Map<String, dynamic>>()
          .map(StorefrontProduct.fromJson)
          .toList(),
      newArrivals: (json['newArrivals'] as List<dynamic>? ?? const [])
          .whereType<Map<String, dynamic>>()
          .map(StorefrontProduct.fromJson)
          .toList(),
      popularProducts: (json['popularProducts'] as List<dynamic>? ?? const [])
          .whereType<Map<String, dynamic>>()
          .map(StorefrontProduct.fromJson)
          .toList(),
      featuredBrands: (json['featuredBrands'] as List<dynamic>? ?? const [])
          .whereType<Map<String, dynamic>>()
          .map(StorefrontBrand.fromJson)
          .toList(),
      featuredCategories:
          (json['featuredCategories'] as List<dynamic>? ?? const [])
              .whereType<Map<String, dynamic>>()
              .map(StorefrontCategorySummary.fromJson)
              .toList(),
      collections: (json['collections'] as List<dynamic>? ?? const [])
          .whereType<Map<String, dynamic>>()
          .map(StorefrontCollection.fromJson)
          .toList(),
    );
  }
}

class StorefrontProductQuery {
  const StorefrontProductQuery({
    this.page = 1,
    this.pageSize = 12,
    this.search,
    this.sortBy,
    this.categoryId,
    this.brandId,
    this.minPrice,
    this.maxPrice,
    this.rating,
    this.availability,
    this.attributeValueIds = const [],
    this.collection,
    this.featured,
    this.includeHighlights = false,
  });

  final int page;
  final int pageSize;
  final String? search;
  final String? sortBy;
  final String? categoryId;
  final String? brandId;
  final double? minPrice;
  final double? maxPrice;
  final double? rating;
  final String? availability;
  final List<String> attributeValueIds;
  final String? collection;
  final bool? featured;
  final bool includeHighlights;

  StorefrontProductQuery copyWith({
    int? page,
    int? pageSize,
    String? search,
    String? sortBy,
    String? categoryId,
    String? brandId,
    double? minPrice,
    double? maxPrice,
    double? rating,
    String? availability,
    List<String>? attributeValueIds,
    String? collection,
    bool? featured,
    bool? includeHighlights,
  }) {
    return StorefrontProductQuery(
      page: page ?? this.page,
      pageSize: pageSize ?? this.pageSize,
      search: search ?? this.search,
      sortBy: sortBy ?? this.sortBy,
      categoryId: categoryId ?? this.categoryId,
      brandId: brandId ?? this.brandId,
      minPrice: minPrice ?? this.minPrice,
      maxPrice: maxPrice ?? this.maxPrice,
      rating: rating ?? this.rating,
      availability: availability ?? this.availability,
      attributeValueIds: attributeValueIds ?? this.attributeValueIds,
      collection: collection ?? this.collection,
      featured: featured ?? this.featured,
      includeHighlights: includeHighlights ?? this.includeHighlights,
    );
  }

  Map<String, dynamic> toQueryParameters() {
    return <String, dynamic>{
      'page': page,
      'pageSize': pageSize,
      if (search != null && search!.trim().isNotEmpty) 'search': search!.trim(),
      if (sortBy != null && sortBy!.isNotEmpty) 'sortBy': sortBy,
      if (categoryId != null && categoryId!.isNotEmpty) 'categoryId': categoryId,
      if (brandId != null && brandId!.isNotEmpty) 'brandId': brandId,
      if (minPrice != null) 'minPrice': minPrice,
      if (maxPrice != null) 'maxPrice': maxPrice,
      if (rating != null) 'rating': rating,
      if (availability != null && availability!.isNotEmpty)
        'availability': availability,
      if (attributeValueIds.isNotEmpty) 'attributeValueIds': attributeValueIds,
      if (collection != null && collection!.isNotEmpty) 'collection': collection,
      if (featured != null) 'featured': featured,
      'includeHighlights': includeHighlights,
    };
  }
}
