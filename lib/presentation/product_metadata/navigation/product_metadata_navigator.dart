import 'package:mobile_ai_erp/presentation/product_metadata/attribute_sets/attribute_options_screen.dart';
import 'package:mobile_ai_erp/presentation/product_metadata/attribute_sets/attribute_detail.dart';
import 'package:mobile_ai_erp/presentation/product_metadata/attribute_sets/attributes_screen.dart';
import 'package:mobile_ai_erp/presentation/product_metadata/brands/brand_detail.dart';
import 'package:mobile_ai_erp/presentation/product_metadata/brands/brand_form.dart';
import 'package:mobile_ai_erp/presentation/product_metadata/brands/brands_screen.dart';
import 'package:mobile_ai_erp/presentation/product_metadata/categories/category_detail.dart';
import 'package:mobile_ai_erp/presentation/product_metadata/categories/categories_screen.dart';
import 'package:mobile_ai_erp/presentation/product_metadata/categories/category_form.dart';
import 'package:mobile_ai_erp/presentation/product_metadata/home/product_metadata_home.dart';
import 'package:mobile_ai_erp/presentation/product_metadata/navigation/product_metadata_route_args.dart';
import 'package:mobile_ai_erp/presentation/product_metadata/tags/tag_detail.dart';
import 'package:mobile_ai_erp/presentation/product_metadata/tags/tag_form.dart';
import 'package:mobile_ai_erp/presentation/product_metadata/tags/tags_screen.dart';
import 'package:flutter/material.dart';

class ProductMetadataNavigator {
  ProductMetadataNavigator._();

  static Future<T?> openProductMetadataHome<T>(BuildContext context) {
    return _push<T>(context, const ProductMetadataHomeScreen());
  }

  static Future<T?> openCategories<T>(
    BuildContext context, {
    CategoriesArgs? args,
  }) {
    return _push<T>(context, ProductMetadataCategoriesScreen(args: args));
  }

  static Future<T?> openCategoryForm<T>(
    BuildContext context, {
    CategoryFormArgs? args,
  }) {
    return _push<T>(context, ProductMetadataCategoryFormScreen(args: args));
  }

  static Future<T?> openCategoryDetail<T>(
    BuildContext context, {
    required CategoryDetailArgs args,
  }) {
    return _push<T>(context, ProductMetadataCategoryDetailScreen(args: args));
  }

  static Future<T?> openAttributes<T>(
    BuildContext context, {
    AttributesArgs args = const AttributesArgs(),
  }) {
    return _push<T>(context, ProductMetadataAttributesScreen(args: args));
  }

  static Future<T?> openAttributeForm<T>(
    BuildContext context, {
    AttributeFormArgs args = const AttributeFormArgs(),
  }) {
    return _push<T>(context, ProductMetadataAttributeFormScreen(args: args));
  }

  static Future<T?> openAttributeDetail<T>(
    BuildContext context, {
    required AttributeDetailArgs args,
  }) {
    return _push<T>(context, ProductMetadataAttributeDetailScreen(args: args));
  }

  static Future<T?> openAttributeOptions<T>(
    BuildContext context, {
    required AttributeOptionsArgs args,
  }) {
    return _push<T>(context, ProductMetadataAttributeOptionsScreen(args: args));
  }

  static Future<T?> openAttributeOptionForm<T>(
    BuildContext context, {
    required AttributeOptionFormArgs args,
  }) {
    return _push<T>(
      context,
      ProductMetadataAttributeOptionFormScreen(args: args),
    );
  }

  static Future<T?> openBrands<T>(BuildContext context) {
    return _push<T>(context, const ProductMetadataBrandsScreen());
  }

  static Future<T?> openBrandForm<T>(
    BuildContext context, {
    BrandFormArgs? args,
  }) {
    return _push<T>(context, ProductMetadataBrandFormScreen(args: args));
  }

  static Future<T?> openBrandDetail<T>(
    BuildContext context, {
    required BrandDetailArgs args,
  }) {
    return _push<T>(context, ProductMetadataBrandDetailScreen(args: args));
  }

  static Future<T?> openTags<T>(BuildContext context) {
    return _push<T>(context, const ProductMetadataTagsScreen());
  }

  static Future<T?> openTagForm<T>(
    BuildContext context, {
    TagFormArgs? args,
  }) {
    return _push<T>(context, ProductMetadataTagFormScreen(args: args));
  }

  static Future<T?> openTagDetail<T>(
    BuildContext context, {
    required TagDetailArgs args,
  }) {
    return _push<T>(context, ProductMetadataTagDetailScreen(args: args));
  }

  static Future<T?> _push<T>(BuildContext context, Widget screen) {
    return Navigator.push<T>(
      context,
      MaterialPageRoute<T>(
        builder: (_) => screen,
      ),
    );
  }
}
