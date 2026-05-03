import 'package:mobile_ai_erp/data/network/apis/product_metadata/attribute_set_api.dart';
import 'package:mobile_ai_erp/data/network/apis/product_metadata/brand_api.dart';
import 'package:mobile_ai_erp/data/network/apis/product_metadata/brand_image_api.dart';
import 'package:mobile_ai_erp/data/network/apis/product_metadata/category_api.dart';
import 'package:mobile_ai_erp/data/network/apis/product_metadata/tag_api.dart';

class MetadataApiClient {
  MetadataApiClient({
    required this.brands,
    required this.brandImages,
    required this.categories,
    required this.tags,
    required this.attributeSets,
  });

  final BrandApi brands;
  final BrandImageApi brandImages;
  final CategoryApi categories;
  final TagApi tags;
  final AttributeSetApi attributeSets;
}
