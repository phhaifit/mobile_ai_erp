import 'package:flutter/material.dart';
import 'package:mobile_ai_erp/presentation/account/address/address_book_screen.dart';
import 'package:mobile_ai_erp/presentation/account/address/address_form_screen.dart';
import 'package:mobile_ai_erp/presentation/account/orders/order_detail_screen.dart';
import 'package:mobile_ai_erp/presentation/account/orders/order_history_screen.dart';
import 'package:mobile_ai_erp/presentation/account/orders/return_request_screen.dart';
import 'package:mobile_ai_erp/presentation/account/profile/profile_dashboard_screen.dart';
import 'package:mobile_ai_erp/presentation/checkout/screens/checkout_screen.dart';
import 'package:mobile_ai_erp/presentation/checkout/screens/checkout_test_screen.dart';
import 'package:mobile_ai_erp/presentation/product/screens/product_list_page.dart';
import 'package:mobile_ai_erp/presentation/product_detail/product_detail_screen.dart';
import 'package:mobile_ai_erp/presentation/storefront/brands_landing_page.dart';
import 'package:mobile_ai_erp/presentation/storefront/categories_landing_page.dart';
import 'package:mobile_ai_erp/presentation/storefront/collections_landing_page.dart';
import 'package:mobile_ai_erp/presentation/storefront/product_listing_page.dart';
import 'package:mobile_ai_erp/presentation/storefront/storefront_home_page.dart';
import 'cart_routes.dart';

/// Routes for customer-facing features: storefront, cart, checkout, and profile
class CustomerRoutes {
  CustomerRoutes._();

  // Storefront routes
  static const String storeHome = '/storefront';
  static const String storefrontLegacyHome = '/stockfront';
  static const String storefrontProductListing = '/storefront/product-listing';
  static const String categoriesLanding = '/storefront/categories';
  static const String brandsLanding = '/storefront/brands';
  static const String collectionsLanding = '/storefront/collections';

  // Checkout routes
  static const String checkout = '/checkout';
  static const String checkoutTest = '/checkout-test';

  // Customer profile & account routes
  static const String profileDashboard = '/profile';
  static const String addressBook = '/address_book';
  static const String addressForm = '/address_form';
  static const String orderHistory = '/order_history';
  static const String orderDetail = '/order_detail';
  static const String returnRequest = '/return_request';

  // Product routes
  static const String productList = '/products';
  static const String productDetail = '/product-detail';

  /// Get all customer routes
  static final routes = <String, WidgetBuilder>{
    storeHome: (BuildContext context) => StorefrontHomePage(),
    storefrontLegacyHome: (BuildContext context) => StorefrontHomePage(),
    storefrontProductListing: (BuildContext context) => ProductListingScreen(),
    categoriesLanding: (BuildContext context) => const CategoriesLandingPage(),
    brandsLanding: (BuildContext context) => const BrandsLandingPage(),
    collectionsLanding: (BuildContext context) => const CollectionsLandingPage(),
    checkoutTest: (BuildContext context) => const CheckoutTestScreen(),
    productList: (BuildContext context) => const ProductListPage(),
    productDetail: (BuildContext context) => const ProductDetailScreen(),
    profileDashboard: (BuildContext context) => ProfileDashboardScreen(),
    addressBook: (BuildContext context) => const AddressBookScreen(),
    addressForm: (BuildContext context) => const AddressFormScreen(),
    orderHistory: (BuildContext context) => const OrderHistoryScreen(),
    orderDetail: (BuildContext context) => const OrderDetailScreen(),
    returnRequest: (BuildContext context) => const ReturnRequestScreen(),
    ...CartRoutes.getRoutes(),
  };

  /// Navigate to checkout screen with items
  static void navigateToCheckout(
    BuildContext context, {
    required dynamic items,
    String? customerId,
  }) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) =>
            CheckoutScreen(items: items, customerId: customerId),
      ),
    );
  }

  /// Handle dynamic routes for customer app
  static Route<dynamic>? onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      default:
        return null;
    }
  }
}
