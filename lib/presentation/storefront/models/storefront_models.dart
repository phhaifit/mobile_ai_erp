String _stringValue(
  Map<String, dynamic> json,
  List<String> keys, {
  String fallback = '',
}) {
  for (final key in keys) {
    final value = json[key];
    if (value is String && value.trim().isNotEmpty) {
      return value.trim();
    }
  }
  return fallback;
}

String? _nullableStringValue(Map<String, dynamic> json, List<String> keys) {
  for (final key in keys) {
    final value = json[key];
    if (value is String && value.trim().isNotEmpty) {
      return value.trim();
    }
  }
  return null;
}

double _doubleValue(
  Map<String, dynamic> json,
  List<String> keys, {
  double fallback = 0,
}) {
  for (final key in keys) {
    final value = json[key];
    if (value is num) {
      return value.toDouble();
    }
    if (value is String) {
      final parsed = double.tryParse(value);
      if (parsed != null) {
        return parsed;
      }
    }
  }
  return fallback;
}

double? _nullableDoubleValue(Map<String, dynamic> json, List<String> keys) {
  for (final key in keys) {
    final value = json[key];
    if (value is num) {
      return value.toDouble();
    }
    if (value is String) {
      final parsed = double.tryParse(value);
      if (parsed != null) {
        return parsed;
      }
    }
  }
  return null;
}

int _intValue(
  Map<String, dynamic> json,
  List<String> keys, {
  int fallback = 0,
}) {
  for (final key in keys) {
    final value = json[key];
    if (value is num) {
      return value.toInt();
    }
    if (value is String) {
      final parsed = int.tryParse(value);
      if (parsed != null) {
        return parsed;
      }
    }
  }
  return fallback;
}

bool _boolValue(
  Map<String, dynamic> json,
  List<String> keys, {
  bool fallback = false,
}) {
  for (final key in keys) {
    final value = json[key];
    if (value is bool) {
      return value;
    }
    if (value is num) {
      return value != 0;
    }
    if (value is String) {
      final normalized = value.trim().toLowerCase();
      if (normalized == 'true' ||
          normalized == '1' ||
          normalized == 'in_stock') {
        return true;
      }
      if (normalized == 'false' ||
          normalized == '0' ||
          normalized == 'out_of_stock') {
        return false;
      }
    }
  }
  return fallback;
}

List<String> _stringList(dynamic value) {
  if (value is! List) {
    return const [];
  }
  return value
      .map((item) {
        if (item is String) {
          return item;
        }
        if (item is Map<String, dynamic>) {
          return _stringValue(item, const ['name', 'title', 'slug', 'value']);
        }
        return item.toString();
      })
      .where((item) => item.isNotEmpty)
      .toList();
}

List<String> _imageList(dynamic value) {
  if (value is! List) {
    return const [];
  }
  return value
      .map((item) {
        if (item is String) {
          return item;
        }
        if (item is Map<String, dynamic>) {
          return _stringValue(item, const ['url', 'imageUrl', 'src', 'path']);
        }
        return '';
      })
      .where((item) => item.isNotEmpty)
      .toList();
}

List<String> _attributeList(dynamic value) {
  if (value is! List) {
    return const [];
  }
  return value
      .map((item) {
        if (item is String) {
          return item;
        }
        if (item is Map<String, dynamic>) {
          final name = _stringValue(item, const ['name', 'attribute', 'label']);
          final option = _stringValue(item, const [
            'value',
            'option',
            'optionName',
          ]);
          return option.isEmpty ? name : '$name:$option';
        }
        return item.toString();
      })
      .where((item) => item.isNotEmpty)
      .toList();
}

Map<String, String?> _highlightMap(dynamic value) {
  if (value is Map<String, dynamic>) {
    return value.map((key, item) => MapEntry(key, item?.toString()));
  }
  return const {};
}

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
    final brandData = json['brand'];
    final categoryData = json['category'];
    final brandMap = brandData is Map<String, dynamic> ? brandData : null;
    final categoryMap = categoryData is Map<String, dynamic>
        ? categoryData
        : null;
    final availableStock = _intValue(json, const [
      'availableStock',
      'stockQuantity',
      'stock',
    ]);
    return StorefrontProduct(
      id: _stringValue(json, const ['id', 'productId', 'slug']),
      title: _stringValue(json, const ['title', 'name', 'productName']),
      description: _nullableStringValue(json, const [
        'description',
        'shortDescription',
      ]),
      price: _doubleValue(json, const [
        'price',
        'sellingPrice',
        'currentPrice',
      ]),
      originalPrice: _nullableDoubleValue(json, const [
        'originalPrice',
        'basePrice',
        'listPrice',
      ]),
      images: _imageList(json['images'] ?? json['imageUrls'] ?? json['media']),
      tags: _stringList(json['tags']),
      rating: _doubleValue(json, const ['rating', 'averageRating']),
      brand: brandMap != null
          ? _nullableStringValue(brandMap, const ['name', 'title'])
          : _nullableStringValue(json, const ['brand', 'brandName']),
      brandId:
          _nullableStringValue(json, const ['brandId']) ??
          (brandMap != null
              ? _nullableStringValue(brandMap, const ['id'])
              : null),
      category: categoryMap != null
          ? _nullableStringValue(categoryMap, const ['name', 'title'])
          : _nullableStringValue(json, const ['category', 'categoryName']),
      categoryId:
          _nullableStringValue(json, const ['categoryId']) ??
          (categoryMap != null
              ? _nullableStringValue(categoryMap, const ['id'])
              : null),
      isFlashSale: _boolValue(json, const ['isFlashSale']),
      flashSaleFrom: _nullableStringValue(json, const [
        'flashSaleFrom',
        'flashSaleStartTime',
      ]),
      flashSaleEndTime: _nullableStringValue(json, const [
        'flashSaleEndTime',
        'flashSaleTo',
      ]),
      inStock: _boolValue(json, const [
        'inStock',
      ], fallback: availableStock > 0),
      availableStock: availableStock,
      highlights: _highlightMap(json['highlights']),
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
      id: _stringValue(json, const ['id', 'variantId', 'sku']),
      sku: _stringValue(json, const ['sku', 'code']),
      sellingPrice: _nullableDoubleValue(json, const ['sellingPrice', 'price']),
      basePrice: _nullableDoubleValue(json, const [
        'basePrice',
        'originalPrice',
      ]),
      weight: _nullableDoubleValue(json, const ['weight']),
      attributes: _attributeList(json['attributes']),
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

  String get discoveryKey => slug?.trim().isNotEmpty == true ? slug! : id;

  factory StorefrontFacetOption.fromJson(Map<String, dynamic> json) {
    return StorefrontFacetOption(
      id: _stringValue(json, const ['id', 'value', 'slug', 'name']),
      name: _stringValue(json, const ['name', 'label', 'title', 'value']),
      count: _intValue(json, const ['count', 'productCount']),
      slug: _nullableStringValue(json, const ['slug']),
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
      attributeSetId: _stringValue(json, const [
        'attributeSetId',
        'id',
        'attributeId',
      ]),
      attributeSetName: _stringValue(json, const [
        'attributeSetName',
        'name',
        'title',
      ]),
      values:
          (json['values'] as List<dynamic>? ??
                  json['options'] as List<dynamic>? ??
                  const [])
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

  const StorefrontFacets.empty()
    : brands = const [],
      categories = const [],
      minPrice = 0,
      maxPrice = 0,
      inStockCount = 0,
      outOfStockCount = 0,
      ratings = const [],
      attributes = const [];

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
          .map((item) {
            if (item is num) {
              return item.toInt();
            }
            if (item is Map<String, dynamic>) {
              return _intValue(item, const ['value', 'rating']);
            }
            return int.tryParse(item.toString()) ?? 0;
          })
          .where((value) => value > 0)
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
      id: _stringValue(json, const ['id', 'categoryId', 'slug']),
      name: _stringValue(json, const ['name', 'title', 'slug']),
      slug: _stringValue(json, const ['slug', 'id', 'categoryId']),
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
      id: _stringValue(json, const ['id', 'categoryId', 'slug']),
      name: _stringValue(json, const ['name', 'title', 'slug']),
      slug: _stringValue(json, const ['slug', 'id', 'categoryId']),
      description: _nullableStringValue(json, const ['description']),
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

  factory StorefrontCategoryDetail.fallback(String categoryKey) {
    return StorefrontCategoryDetail(
      id: categoryKey,
      name: categoryKey,
      slug: categoryKey,
      description: null,
      parentId: null,
      breadcrumb: const [],
      children: const [],
    );
  }

  factory StorefrontCategoryDetail.fromJson(Map<String, dynamic> json) {
    return StorefrontCategoryDetail(
      id: _stringValue(json, const ['id', 'categoryId', 'slug']),
      name: _stringValue(json, const ['name', 'title', 'slug']),
      slug: _stringValue(json, const ['slug', 'id', 'categoryId']),
      description: _nullableStringValue(json, const ['description']),
      parentId: _nullableStringValue(json, const ['parentId']),
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
      id: _stringValue(json, const ['id', 'brandId', 'slug']),
      name: _stringValue(json, const ['name', 'title', 'slug']),
      description: _nullableStringValue(json, const ['description']),
      logoUrl: _nullableStringValue(json, const ['logoUrl', 'imageUrl']),
      slug: _stringValue(json, const ['slug', 'id', 'brandId']),
      productCount: _intValue(json, const ['productCount', 'count']),
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
      id: _stringValue(json, const ['id', 'slug', 'tagId', 'value']),
      name: _stringValue(json, const ['name', 'title', 'slug', 'value']),
      slug: _stringValue(json, const ['slug', 'value', 'id']),
      description: _nullableStringValue(json, const ['description']),
      productCount: _intValue(json, const ['productCount', 'count']),
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

  const StorefrontHomeData.empty()
    : banners = const [],
      featuredProducts = const [],
      newArrivals = const [],
      popularProducts = const [],
      featuredBrands = const [],
      featuredCategories = const [],
      collections = const [];

  factory StorefrontHomeData.fromJson(Map<String, dynamic> json) {
    return StorefrontHomeData(
      banners: _imageList(json['banners']),
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
      if (categoryId != null && categoryId!.isNotEmpty)
        'categoryId': categoryId,
      if (brandId != null && brandId!.isNotEmpty) 'brandId': brandId,
      if (minPrice != null) 'minPrice': minPrice,
      if (maxPrice != null) 'maxPrice': maxPrice,
      if (rating != null) 'rating': rating,
      if (availability != null && availability!.isNotEmpty)
        'availability': availability,
      if (attributeValueIds.isNotEmpty) 'attributeValueIds': attributeValueIds,
      if (collection != null && collection!.isNotEmpty)
        'collection': collection,
      if (featured != null) 'featured': featured,
      'includeHighlights': includeHighlights,
    };
  }
}
