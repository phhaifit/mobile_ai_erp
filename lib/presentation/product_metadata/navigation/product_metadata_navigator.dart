import 'package:mobile_ai_erp/presentation/product_metadata/attribute_sets/attribute_sets_form.dart';
import 'package:mobile_ai_erp/presentation/product_metadata/attribute_sets/attribute_values_screen.dart';
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

  static const String productMetadataHomeRoute = '/product-metadata/home';
  static const String categoriesRoute = '/product-metadata/categories';
  static const String categoryFormRoute = '/product-metadata/categories/form';
  static const String categoryDetailRoute =
      '/product-metadata/categories/detail';
  static const String attributesRoute = '/product-metadata/attributes';
  static const String attributeFormRoute = '/product-metadata/attributes/form';
  static const String attributeDetailRoute =
      '/product-metadata/attributes/detail';
  static const String attributeOptionsRoute =
      '/product-metadata/attributes/options';
  static const String attributeOptionFormRoute =
      '/product-metadata/attributes/options/form';
  static const String brandsRoute = '/product-metadata/brands';
  static const String brandFormRoute = '/product-metadata/brands/form';
  static const String brandDetailRoute = '/product-metadata/brands/detail';
  static const String tagsRoute = '/product-metadata/tags';
  static const String tagFormRoute = '/product-metadata/tags/form';
  static const String tagDetailRoute = '/product-metadata/tags/detail';
  static Future<T?> openProductMetadataHome<T>(BuildContext context) {
    return _push<T>(
      context,
      const ProductMetadataHomeScreen(),
      routeName: productMetadataHomeRoute,
    );
  }

  static Future<T?> openCategories<T>(
    BuildContext context, {
    CategoriesArgs? args,
  }) {
    return _push<T>(
      context,
      ProductMetadataCategoriesScreen(args: args),
      routeName: categoriesRoute,
    );
  }

  static Future<T?> openCategoryForm<T>(
    BuildContext context, {
    CategoryFormArgs? args,
  }) {
    return _push<T>(
      context,
      ProductMetadataCategoryFormScreen(args: args),
      routeName: categoryFormRoute,
    );
  }

  static Future<T?> openCategoryDetail<T>(
    BuildContext context, {
    required CategoryDetailArgs args,
  }) {
    return _push<T>(
      context,
      ProductMetadataCategoryDetailScreen(args: args),
      routeName: categoryDetailRoute,
    );
  }

  static Future<T?> openAttributes<T>(
    BuildContext context, {
    AttributesArgs args = const AttributesArgs(),
  }) {
    return _push<T>(
      context,
      ProductMetadataAttributesScreen(args: args),
      routeName: attributesRoute,
    );
  }

  static Future<T?> openAttributeForm<T>(
    BuildContext context, {
    AttributeFormArgs args = const AttributeFormArgs(),
  }) {
    return _push<T>(
      context,
      ProductMetadataAttributeFormScreen(args: args),
      routeName: attributeFormRoute,
    );
  }

  static Future<T?> openAttributeDetail<T>(
    BuildContext context, {
    required AttributeDetailArgs args,
  }) {
    return _push<T>(
      context,
      ProductMetadataAttributeDetailScreen(args: args),
      routeName: attributeDetailRoute,
    );
  }

  static Future<T?> openAttributeOptions<T>(
    BuildContext context, {
    required AttributeOptionsArgs args,
  }) {
    return _push<T>(
      context,
      ProductMetadataAttributeOptionsScreen(args: args),
      routeName: attributeOptionsRoute,
    );
  }

  static Future<T?> openAttributeOptionForm<T>(
    BuildContext context, {
    required AttributeOptionFormArgs args,
  }) {
    return _push<T>(
      context,
      ProductMetadataAttributeOptionFormScreen(args: args),
      routeName: attributeOptionFormRoute,
    );
  }

  static Future<T?> openBrands<T>(BuildContext context) {
    return _push<T>(
      context,
      const ProductMetadataBrandsScreen(),
      routeName: brandsRoute,
    );
  }

  static Future<T?> openBrandForm<T>(
    BuildContext context, {
    BrandFormArgs? args,
  }) {
    return _push<T>(
      context,
      ProductMetadataBrandFormScreen(args: args),
      routeName: brandFormRoute,
    );
  }

  static Future<T?> openBrandDetail<T>(
    BuildContext context, {
    required BrandDetailArgs args,
  }) {
    return _push<T>(
      context,
      ProductMetadataBrandDetailScreen(args: args),
      routeName: brandDetailRoute,
    );
  }

  static Future<T?> openTags<T>(BuildContext context) {
    return _push<T>(
      context,
      const ProductMetadataTagsScreen(),
      routeName: tagsRoute,
    );
  }

  static Future<T?> openTagForm<T>(
    BuildContext context, {
    TagFormArgs? args,
  }) {
    return _push<T>(
      context,
      ProductMetadataTagFormScreen(args: args),
      routeName: tagFormRoute,
    );
  }

  static Future<T?> openTagDetail<T>(
    BuildContext context, {
    required TagDetailArgs args,
  }) {
    return _push<T>(
      context,
      ProductMetadataTagDetailScreen(args: args),
      routeName: tagDetailRoute,
    );
  }

  static Future<T?> _push<T>(
    BuildContext context,
    Widget screen, {
    required String routeName,
  }) {
    return Navigator.push<T>(
      context,
      MaterialPageRoute<T>(
        settings: RouteSettings(name: routeName),
        builder: (_) => screen,
      ),
    );
  }
}
