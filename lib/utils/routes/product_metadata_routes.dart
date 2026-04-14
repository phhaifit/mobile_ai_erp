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
        if (args is CategoryDetailArgs) {
          return MaterialPageRoute(
            settings: settings,
            builder: (context) => ProductMetadataCategoryDetailScreen(args: args),
          );
        }
        return null;

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
        if (args is AttributeDetailArgs) {
          return MaterialPageRoute(
            settings: settings,
            builder: (context) => ProductMetadataAttributeDetailScreen(args: args),
          );
        }
        return null;

      case ProductMetadataNavigator.attributeOptionsRoute:
        if (args is AttributeOptionsArgs) {
          return MaterialPageRoute(
            settings: settings,
            builder: (context) => ProductMetadataAttributeOptionsScreen(args: args),
          );
        }
        return null;

      case ProductMetadataNavigator.attributeOptionFormRoute:
        if (args is AttributeOptionFormArgs) {
          return MaterialPageRoute(
            settings: settings,
            builder: (context) => ProductMetadataAttributeOptionFormScreen(args: args),
          );
        }
        return null;

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
        if (args is BrandDetailArgs) {
          return MaterialPageRoute(
            settings: settings,
            builder: (context) => ProductMetadataBrandDetailScreen(args: args),
          );
        }
        return null;

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
        if (args is TagDetailArgs) {
          return MaterialPageRoute(
            settings: settings,
            builder: (context) => ProductMetadataTagDetailScreen(args: args),
          );
        }
        return null;

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
        if (args is UnitDetailArgs) {
          return MaterialPageRoute(
            settings: settings,
            builder: (context) => ProductMetadataUnitDetailScreen(args: args),
          );
        }
        return null;

      default:
        return null;
    }
  }
}
