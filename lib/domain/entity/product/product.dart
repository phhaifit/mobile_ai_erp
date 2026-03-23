import 'package:mobile_ai_erp/domain/entity/product_metadata/attribute.dart';
import 'package:mobile_ai_erp/domain/entity/product_metadata/brand.dart';
import 'package:mobile_ai_erp/domain/entity/product_metadata/category.dart';
import 'package:mobile_ai_erp/domain/entity/product_metadata/tag.dart';

/// Product entity class. Mainly contains information shown to customers of the store
/// 
/// Currently only used in storefront.
class Product {
  // Core product details
  final String id; // product ID
  final String productName; // name of the product
  final double price; // price for sale //// same as unit price?
  final String currency; // currency display, e.g. USD, CNY
  final double rating; // average rating from customers, between 0 and 5
  final String? imageSource; // URL or local path to product image, can be null if no image available

  // Metadata
  final Category category; // product category //// can this be null?
  final Brand brand; // product brand //// can this be null?
  final List<Tag> tags; // list of tags, can be empty
  final List<Attribute> attributes; // list of attributes, can be empty

  Product({
    required this.id,
    required this.productName,
    required this.price,
    required this.currency,
    required this.rating,
    this.imageSource,
    required this.category,
    required this.brand,
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
}