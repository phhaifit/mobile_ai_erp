import 'package:flutter/material.dart';
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
import 'package:mobile_ai_erp/presentation/product_metadata/navigation/product_metadata_navigator.dart';
import 'package:mobile_ai_erp/presentation/product_metadata/navigation/product_metadata_route_args.dart';
import 'package:mobile_ai_erp/presentation/product_metadata/tags/tag_detail.dart';
import 'package:mobile_ai_erp/presentation/product_metadata/tags/tag_form.dart';
import 'package:mobile_ai_erp/presentation/product_metadata/tags/tags_screen.dart';
import 'package:mobile_ai_erp/presentation/product_metadata/units/unit_detail.dart';
import 'package:mobile_ai_erp/presentation/product_metadata/units/unit_form.dart';
import 'package:mobile_ai_erp/presentation/product_metadata/units/units_screen.dart';

class ProductMetadataRoutes {
  ProductMetadataRoutes._();

  static bool isMetadataRoute(String? name) {
    return name?.startsWith('/product-metadata/') ?? false;
  }

  static Route<dynamic>? onGenerateRoute(RouteSettings settings) {
    final args = settings.arguments;

    switch (settings.name) {
      case ProductMetadataNavigator.productMetadataHomeRoute:
        return MaterialPageRoute(
          settings: settings,
          builder: (context) => const ProductMetadataHomeScreen(),
        );

      case ProductMetadataNavigator.categoriesRoute:
        return MaterialPageRoute(
          settings: settings,
          builder: (context) => ProductMetadataCategoriesScreen(
            args: args is CategoriesArgs ? args : null,
          ),
        );

      case ProductMetadataNavigator.categoryFormRoute:
        return MaterialPageRoute(
          settings: settings,
          builder: (context) => ProductMetadataCategoryFormScreen(
            args: args is CategoryFormArgs ? args : null,
          ),
        );

      case ProductMetadataNavigator.categoryDetailRoute:
        return _buildMetadataRoute<CategoryDetailArgs>(
          settings: settings,
          builder: (args) => ProductMetadataCategoryDetailScreen(args: args),
          fallbackBuilder: () => ProductMetadataCategoriesScreen(),
        );

      case ProductMetadataNavigator.attributesRoute:
        return MaterialPageRoute(
          settings: settings,
          builder: (context) => ProductMetadataAttributesScreen(
            args: args is AttributesArgs ? args : const AttributesArgs(),
          ),
        );

      case ProductMetadataNavigator.attributeFormRoute:
        return MaterialPageRoute(
          settings: settings,
          builder: (context) => ProductMetadataAttributeFormScreen(
            args: args is AttributeFormArgs ? args : const AttributeFormArgs(),
          ),
        );

      case ProductMetadataNavigator.attributeDetailRoute:
        return _buildMetadataRoute<AttributeDetailArgs>(
          settings: settings,
          builder: (args) => ProductMetadataAttributeDetailScreen(args: args),
          fallbackBuilder: () => const ProductMetadataAttributesScreen(),
        );

      case ProductMetadataNavigator.attributeOptionsRoute:
        return _buildMetadataRoute<AttributeOptionsArgs>(
          settings: settings,
          builder: (args) => ProductMetadataAttributeOptionsScreen(args: args),
          fallbackBuilder: () => const ProductMetadataAttributesScreen(),
        );

      case ProductMetadataNavigator.attributeOptionFormRoute:
        return _buildMetadataRoute<AttributeOptionFormArgs>(
          settings: settings,
          builder: (args) => ProductMetadataAttributeOptionFormScreen(args: args),
          fallbackBuilder: () => const ProductMetadataAttributesScreen(),
        );

      case ProductMetadataNavigator.brandsRoute:
        return MaterialPageRoute(
          settings: settings,
          builder: (context) => const ProductMetadataBrandsScreen(),
        );

      case ProductMetadataNavigator.brandFormRoute:
        return MaterialPageRoute(
          settings: settings,
          builder: (context) => ProductMetadataBrandFormScreen(
            args: args is BrandFormArgs ? args : null,
          ),
        );

      case ProductMetadataNavigator.brandDetailRoute:
        return _buildMetadataRoute<BrandDetailArgs>(
          settings: settings,
          builder: (args) => ProductMetadataBrandDetailScreen(args: args),
          fallbackBuilder: () => const ProductMetadataBrandsScreen(),
        );

      case ProductMetadataNavigator.tagsRoute:
        return MaterialPageRoute(
          settings: settings,
          builder: (context) => const ProductMetadataTagsScreen(),
        );

      case ProductMetadataNavigator.tagFormRoute:
        return MaterialPageRoute(
          settings: settings,
          builder: (context) => ProductMetadataTagFormScreen(
            args: args is TagFormArgs ? args : null,
          ),
        );

      case ProductMetadataNavigator.tagDetailRoute:
        return _buildMetadataRoute<TagDetailArgs>(
          settings: settings,
          builder: (args) => ProductMetadataTagDetailScreen(args: args),
          fallbackBuilder: () => const ProductMetadataTagsScreen(),
        );

      case ProductMetadataNavigator.unitsRoute:
        return MaterialPageRoute(
          settings: settings,
          builder: (context) => const ProductMetadataUnitsScreen(),
        );

      case ProductMetadataNavigator.unitFormRoute:
        return MaterialPageRoute(
          settings: settings,
          builder: (context) => ProductMetadataUnitFormScreen(
            args: args is UnitFormArgs ? args : null,
          ),
        );

      case ProductMetadataNavigator.unitDetailRoute:
        return _buildMetadataRoute<UnitDetailArgs>(
          settings: settings,
          builder: (args) => ProductMetadataUnitDetailScreen(args: args),
          fallbackBuilder: () => const ProductMetadataUnitsScreen(),
        );

      default:
        return null;
    }
  }

  /// Helper to build routes with hot restart fallback support.
  static Route<dynamic>? _buildMetadataRoute<T>({
    required RouteSettings settings,
    required Widget Function(T) builder,
    required Widget Function() fallbackBuilder,
  }) {
    final args = settings.arguments;

    // Support for hot restart/refresh where arguments are lost
    if (args == null) {
      return MaterialPageRoute(
        settings: settings,
        builder: (context) => fallbackBuilder(),
      );
    }

    // Type-safe argument passing
    if (args is T) {
      return MaterialPageRoute(
        settings: settings,
        builder: (context) => builder(args as T),
      );
    }

    // Allow framework to catch invalid argument types
    return null;
  }
}

