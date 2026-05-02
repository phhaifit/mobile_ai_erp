import 'package:mobile_ai_erp/domain/entity/product_metadata/attribute.dart';
import 'package:mobile_ai_erp/domain/entity/product_metadata/brand.dart';
import 'package:mobile_ai_erp/domain/entity/product_metadata/category.dart';
import 'package:mobile_ai_erp/domain/entity/product_metadata/tag.dart';
import 'package:mobile_ai_erp/domain/entity/product/product_status.dart';

/// Product entity class. Mainly contains information shown to customers of the store
/// Used in storefront pages
class Product {
  final int? id;
  final String name;
  final String sku;
  final double price;
  final String currency; // currency display, e.g. USD, CNY
  final double rating; // average rating from customers, between 0 and 5
  final String description;
  final ProductStatus status;
  final int categoryId;
  final int brandId;
  final List<int> tagIds;
  final List<String> imageUrls;
  final DateTime? createdAt;

  // Metadata (currently may overlap with above fields)
  final Category? category; // product category //// can this be null?
  final Brand? brand; // product brand //// can this be null?
  final List<Tag> tags; // list of tags, can be empty
  final List<Attribute> attributes; // list of attributes, can be empty



  Product({
    this.id,
    required this.name,
    required this.sku,
    required this.price,
    required this.currency,
    required this.rating,
    required this.description,
    required this.status,
    required this.categoryId,
    required this.brandId,
    required this.tagIds,
    required this.imageUrls,
    this.createdAt,

    this.category,
    this.brand,
    this.tags = const <Tag>[],
    this.attributes = const <Attribute>[],
  }) {
    // Validation
    if (price < 0) {
      throw ArgumentError('Price cannot be negative');
    }
    if (rating < 0 || rating > 5) {
      throw ArgumentError('Rating must be between 0 and 5');
    }
  }

  factory Product.fromMap(Map<String, dynamic> json) => Product(
        id: json["id"],
        name: json["name"] ?? "",
        sku: json["sku"] ?? "",
        price: (json["price"] as num?)?.toDouble() ?? 0.0,
        currency: json["currency"] ?? "USD",
        rating: (json["rating"] as num?)?.toDouble() ?? 0.0,
        description: json["description"] ?? "",
        status: productStatusFromValue(json["status"] ?? 2),
        categoryId: json["categoryId"] ?? 0,
        brandId: json["brandId"] ?? 0,
        tagIds: List<int>.from(json["tagIds"] ?? []),
        imageUrls: List<String>.from(json["imageUrls"] ?? []),
        createdAt: json["createdAt"] != null 
            ? DateTime.parse(json["createdAt"] as String)
            : null,
      );

  Map<String, dynamic> toMap() => {
        "id": id,
        "name": name,
        "sku": sku,
        "price": price,
        "description": description,
        "status": status.value,
        "categoryId": categoryId,
        "brandId": brandId,
        "tagIds": tagIds,
        "imageUrls": imageUrls,
        "createdAt": createdAt?.toIso8601String(),
      };

  Product copyWith({
    int? id,
    String? name,
    String? sku,
    double? price,
    String? currency,
    double? rating,
    String? description,
    ProductStatus? status,
    int? categoryId,
    int? brandId,
    List<int>? tagIds,
    List<String>? imageUrls,
    DateTime? createdAt,
  }) {
    return Product(
      id: id ?? this.id,
      name: name ?? this.name,
      sku: sku ?? this.sku,
      price: price ?? this.price,
      currency: currency ?? this.currency,
      rating: rating ?? this.rating,
      description: description ?? this.description,
      status: status ?? this.status,
      categoryId: categoryId ?? this.categoryId,
      brandId: brandId ?? this.brandId,
      tagIds: tagIds ?? this.tagIds,
      imageUrls: imageUrls ?? this.imageUrls,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
