import 'package:flutter/material.dart';
import 'package:mobile_ai_erp/domain/entity/product_detail/product_detail.dart';

class StorefrontProductMapper {
  StorefrontProductMapper._();

  static ProductDetail productDetailFromJson(Map<String, dynamic> json) {
    final images = _stringList(json['images']);
    final variantsJson = _mapList(json['variants']);
    final availableStock = _intValue(json['availableStock']);
    final variants = variantsJson
        .map(
          (variantJson) => _variantFromJson(
            variantJson,
            fallbackProductId: _stringValue(json['id']),
            fallbackPrice: _doubleValue(json['price']),
            fallbackOriginalPrice: _nullableDoubleValue(json['originalPrice']),
            fallbackStock: availableStock,
          ),
        )
        .toList();

    return ProductDetail(
      id: _stringValue(json['id']),
      name: _stringValue(json['title']),
      brandId: _nullableStringValue(json['brandId']),
      brandName: _nullableStringValue(json['brand']) ?? 'Unknown brand',
      categoryId: _nullableStringValue(json['categoryId']),
      categoryName: _nullableStringValue(json['category']) ?? 'Uncategorized',
      inStock: json['inStock'] == true,
      isFlashSale: json['isFlashSale'] == true,
      flashSaleFrom: _nullableDateTime(json['flashSaleFrom']),
      flashSaleEndTime: _nullableDateTime(json['flashSaleEndTime']),
      media: images
          .map((url) => ProductMedia(url: url, type: MediaType.image))
          .toList(),
      variants: variants.isNotEmpty
          ? variants
          : [
              ProductVariant(
                id: _stringValue(json['id']),
                sku: _stringValue(json['id']),
                price:
                    _nullableDoubleValue(json['originalPrice']) ??
                    _doubleValue(json['price']),
                salePrice: _salePrice(
                  _nullableDoubleValue(json['originalPrice']),
                  _nullableDoubleValue(json['price']),
                ),
                stockQuantity: availableStock,
              ),
            ],
      descriptionHtml: _nullableStringValue(json['description']) ?? '',
      specifications: _specificationsFromJson(json, variantsJson),
      reviews: const [],
      averageRating: _doubleValue(json['rating']),
      reviewCount: 0,
    );
  }

  static StorefrontProductSummary productSummaryFromJson(
    Map<String, dynamic> json,
  ) {
    return StorefrontProductSummary(
      id: _stringValue(json['id']),
      name: _stringValue(json['title']),
      description: _nullableStringValue(json['description']) ?? '',
      price: _doubleValue(json['price']),
      originalPrice: _nullableDoubleValue(json['originalPrice']),
      imageUrls: _stringList(json['images']),
      rating: _doubleValue(json['rating']),
      brandName: _nullableStringValue(json['brand']),
      categoryName: _nullableStringValue(json['category']),
      inStock: json['inStock'] == true,
      availableStock: _intValue(json['availableStock']),
    );
  }

  static List<StorefrontProductSummary> productSummariesFromPaginatedJson(
    Map<String, dynamic> json,
  ) {
    return _mapList(json['data']).map(productSummaryFromJson).toList();
  }

  static StorefrontCategoryDetail categoryDetailFromJson(
    Map<String, dynamic> json,
  ) {
    return StorefrontCategoryDetail(
      id: _stringValue(json['id']),
      name: _stringValue(json['name']),
      slug: _stringValue(json['slug']),
      description: _nullableStringValue(json['description']),
      breadcrumb: _mapList(
        json['breadcrumb'],
      ).map(_categoryBreadcrumbFromJson).toList(),
    );
  }

  static ProductVariant _variantFromJson(
    Map<String, dynamic> json, {
    required String fallbackProductId,
    required double fallbackPrice,
    required double? fallbackOriginalPrice,
    required int fallbackStock,
  }) {
    final attributes = _attributeMap(_stringList(json['attributes']));
    final colorName = _firstAttributeValue(attributes, const [
      'color',
      'colour',
      'mau sac',
      'màu sắc',
      'mau',
      'màu',
    ]);
    final size = _firstAttributeValue(attributes, const [
      'size',
      'kich thuoc',
      'kích thước',
    ]);
    final sellingPrice =
        _nullableDoubleValue(json['sellingPrice']) ?? fallbackPrice;
    final basePrice =
        _nullableDoubleValue(json['basePrice']) ??
        fallbackOriginalPrice ??
        sellingPrice;

    return ProductVariant(
      id: _nullableStringValue(json['id']) ?? fallbackProductId,
      sku: _nullableStringValue(json['sku']) ?? fallbackProductId,
      color: colorName == null
          ? null
          : ProductColor(name: colorName, color: _colorFromName(colorName)),
      size: size,
      price: basePrice,
      salePrice: _salePrice(basePrice, sellingPrice),
      // TODO(backend): StorefrontVariantDto does not expose per-variant stock yet.
      stockQuantity: fallbackStock,
    );
  }

  static List<ProductSpecification> _specificationsFromJson(
    Map<String, dynamic> productJson,
    List<Map<String, dynamic>> variantsJson,
  ) {
    final specs = <ProductSpecification>[
      if (_nullableStringValue(productJson['brand']) != null)
        ProductSpecification(
          name: 'Brand',
          value: _nullableStringValue(productJson['brand'])!,
        ),
      if (_nullableStringValue(productJson['category']) != null)
        ProductSpecification(
          name: 'Category',
          value: _nullableStringValue(productJson['category'])!,
        ),
      if (_stringList(productJson['tags']).isNotEmpty)
        ProductSpecification(
          name: 'Tags',
          value: _stringList(productJson['tags']).join(', '),
        ),
      ProductSpecification(
        name: 'Available stock',
        value: _intValue(productJson['availableStock']).toString(),
      ),
    ];

    final seen = specs.map((spec) => spec.name).toSet();
    for (final variantJson in variantsJson) {
      for (final attribute in _stringList(variantJson['attributes'])) {
        final parts = attribute.split(':');
        if (parts.length < 2) continue;
        final name = parts.first.trim();
        final value = parts.sublist(1).join(':').trim();
        if (name.isEmpty || value.isEmpty || seen.contains(name)) continue;
        specs.add(ProductSpecification(name: name, value: value));
        seen.add(name);
      }
    }

    return specs;
  }

  static StorefrontCategoryBreadcrumb _categoryBreadcrumbFromJson(
    Map<String, dynamic> json,
  ) {
    return StorefrontCategoryBreadcrumb(
      id: _stringValue(json['id']),
      name: _stringValue(json['name']),
      slug: _stringValue(json['slug']),
    );
  }

  static Map<String, String> _attributeMap(List<String> attributes) {
    final map = <String, String>{};
    for (final attribute in attributes) {
      final parts = attribute.split(':');
      if (parts.length < 2) continue;
      final key = _normalize(parts.first);
      final value = parts.sublist(1).join(':').trim();
      if (key.isNotEmpty && value.isNotEmpty) {
        map[key] = value;
      }
    }
    return map;
  }

  static String? _firstAttributeValue(
    Map<String, String> attributes,
    List<String> keys,
  ) {
    for (final key in keys) {
      final value = attributes[_normalize(key)];
      if (value != null && value.isNotEmpty) return value;
    }
    return null;
  }

  static String _normalize(String value) {
    return value.trim().toLowerCase();
  }

  static Color _colorFromName(String colorName) {
    switch (_normalize(colorName)) {
      case 'black':
      case 'den':
      case 'đen':
        return const Color(0xFF212121);
      case 'white':
      case 'trang':
        return const Color(0xFFFAFAFA);
      case 'red':
      case 'do':
      case 'đỏ':
        return const Color(0xFFC62828);
      case 'blue':
      case 'navy':
      case 'xanh':
        return const Color(0xFF1A237E);
      case 'green':
        return const Color(0xFF2E7D32);
      case 'yellow':
        return const Color(0xFFFBC02D);
      case 'gray':
      case 'grey':
      case 'xam':
      case 'xám':
        return const Color(0xFF757575);
      default:
        return Colors.grey;
    }
  }

  static double? _salePrice(double? originalPrice, double? sellingPrice) {
    if (originalPrice == null || sellingPrice == null) return null;
    return sellingPrice < originalPrice ? sellingPrice : null;
  }

  static String _stringValue(dynamic value) {
    return _nullableStringValue(value) ?? '';
  }

  static String? _nullableStringValue(dynamic value) {
    if (value == null) return null;
    final stringValue = value.toString();
    return stringValue.isEmpty ? null : stringValue;
  }

  static double _doubleValue(dynamic value) {
    return _nullableDoubleValue(value) ?? 0;
  }

  static double? _nullableDoubleValue(dynamic value) {
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value);
    return null;
  }

  static DateTime? _nullableDateTime(dynamic value) {
    if (value == null) return null;
    if (value is DateTime) return value;
    if (value is String) return DateTime.tryParse(value);
    return null;
  }

  static int _intValue(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }

  static List<String> _stringList(dynamic value) {
    if (value is List) {
      return value
          .where((item) => item != null)
          .map((item) => item.toString())
          .toList();
    }
    return const [];
  }

  static List<Map<String, dynamic>> _mapList(dynamic value) {
    if (value is List) {
      return value
          .whereType<Map>()
          .map((item) => Map<String, dynamic>.from(item))
          .toList();
    }
    return const [];
  }
}
