import 'package:mobile_ai_erp/domain/entity/product_metadata/attribute.dart';
import 'package:mobile_ai_erp/domain/entity/product_metadata/brand.dart';
import 'package:mobile_ai_erp/domain/entity/product_metadata/category.dart';
import 'package:mobile_ai_erp/domain/entity/product_metadata/tag.dart';

/// Product entity class. Mainly contains information shown to customers of the store
/// 
/// Currently only used in storefront.
class Product {
  // Core product details
  final String id;
  final String productName;
  final double price; // same as unit price?
  final String currency;
  final double rating;
  final String? imageSource;

  // Metadata
  final Category category; // can this be null?
  final Brand brand; // can this be null?
  final List<Tag> tags;
  final List<Attribute> attributes;

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