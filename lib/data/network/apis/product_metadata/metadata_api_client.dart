import 'package:mobile_ai_erp/data/network/apis/product_metadata/attribute_set_api.dart';
import 'package:mobile_ai_erp/data/network/apis/product_metadata/brand_api.dart';
import 'package:mobile_ai_erp/data/network/apis/product_metadata/category_api.dart';
import 'package:mobile_ai_erp/data/network/apis/product_metadata/tag_api.dart';
import 'package:mobile_ai_erp/data/network/apis/product_metadata/unit_api.dart';

/// Aggregates all product metadata API clients into a single facade.
/// 
/// This reduces coupling in the repository layer by consolidating
/// multiple API dependencies into one. New metadata types can be added
/// by extending this class without modifying dependent code.
class MetadataApiClient {
  MetadataApiClient({
    required this.brands,
    required this.categories,
    required this.tags,
    required this.units,
    required this.attributeSets,
  });

  final BrandApi brands;
  final CategoryApi categories;
  final TagApi tags;
  final UnitApi units;
  final AttributeSetApi attributeSets;
}
