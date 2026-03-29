import 'package:flutter/material.dart';
import 'package:mobile_ai_erp/di/service_locator.dart';
import 'package:mobile_ai_erp/presentation/home/home.dart';
import 'package:mobile_ai_erp/presentation/inventory_audit_outbound/inventory_audit_screen.dart';
import 'package:mobile_ai_erp/presentation/inventory_audit_outbound/inventory_audit_summary_screen.dart';
import 'package:mobile_ai_erp/presentation/inventory_audit_outbound/inventory_outbound_history_screen.dart';
import 'package:mobile_ai_erp/presentation/inventory_audit_outbound/inventory_outbound_screen.dart';
import 'package:mobile_ai_erp/presentation/login/login.dart';
import 'package:mobile_ai_erp/presentation/storefront/product_listing_page.dart';
import 'package:mobile_ai_erp/presentation/storefront/storefront_home_page.dart';
import 'package:mobile_ai_erp/presentation/storefront/categories_landing_page.dart';
import 'package:mobile_ai_erp/presentation/storefront/brands_landing_page.dart';
import 'package:mobile_ai_erp/presentation/stock_operations/stock_operations_screen.dart';
import 'package:mobile_ai_erp/presentation/web_builder/web_builder_dashboard.dart';
import 'package:mobile_ai_erp/presentation/web_builder/store_settings/store_settings_screen.dart';
import 'package:mobile_ai_erp/presentation/web_builder/theme_engine/theme_list_screen.dart';
import 'package:mobile_ai_erp/presentation/web_builder/theme_engine/theme_detail_screen.dart';
import 'package:mobile_ai_erp/presentation/web_builder/cms_pages/cms_page_list_screen.dart';
import 'package:mobile_ai_erp/presentation/web_builder/cms_pages/cms_page_editor_screen.dart';
import 'package:mobile_ai_erp/presentation/product_detail/product_detail_screen.dart';
import 'package:mobile_ai_erp/presentation/order_tracking/order_tracking.dart';
import 'package:mobile_ai_erp/presentation/reports/reports_analytics.dart';
import 'package:mobile_ai_erp/presentation/account/profile/profile_dashboard_screen.dart';
import 'package:mobile_ai_erp/presentation/account/address/address_book_screen.dart';
import 'package:mobile_ai_erp/presentation/account/address/address_form_screen.dart';
import 'package:mobile_ai_erp/presentation/account/orders/order_history_screen.dart';
import 'package:mobile_ai_erp/presentation/account/orders/order_detail_screen.dart';
import 'package:mobile_ai_erp/presentation/account/orders/return_request_screen.dart';
import 'package:mobile_ai_erp/presentation/order_fulfillment/fulfillment_detail.dart';
import 'package:mobile_ai_erp/presentation/order_fulfillment/fulfillment_list.dart';
import 'package:mobile_ai_erp/presentation/order_fulfillment/order_tracking.dart';
import 'package:mobile_ai_erp/presentation/order_fulfillment/packaging.dart';
import 'package:mobile_ai_erp/presentation/order_fulfillment/print_label.dart';
import 'package:mobile_ai_erp/presentation/order_tracking/order_tracking.dart';
import 'package:mobile_ai_erp/presentation/product_detail/product_detail_screen.dart';
import 'package:mobile_ai_erp/presentation/reports/reports_analytics.dart';
import 'package:mobile_ai_erp/presentation/stock_operations/stock_operations_screen.dart';
import 'package:mobile_ai_erp/presentation/user/home/user_home.dart';
import 'package:mobile_ai_erp/presentation/user/store/role_store.dart';
import 'package:mobile_ai_erp/presentation/user/store/user_store.dart';
import 'package:mobile_ai_erp/presentation/web_builder/cms_pages/cms_page_editor_screen.dart';
import 'package:mobile_ai_erp/presentation/web_builder/cms_pages/cms_page_list_screen.dart';
import 'package:mobile_ai_erp/presentation/web_builder/store_settings/store_settings_screen.dart';
import 'package:mobile_ai_erp/presentation/web_builder/theme_engine/theme_detail_screen.dart';
import 'package:mobile_ai_erp/presentation/web_builder/theme_engine/theme_list_screen.dart';
import 'package:mobile_ai_erp/presentation/web_builder/web_builder_dashboard.dart';
import 'cart_routes.dart';
import 'package:mobile_ai_erp/presentation/product/screens/product_list_page.dart';


class Routes {
  Routes._();

  // static variables
  static const String splash = '/splash';
  static const String login = '/login';
  static const String home = '/post';
  static const String stockOperations = '/stock-operations';
  static const String inventoryAudit = '/inventory-audit';
  static const String inventoryAuditSummary = '/inventory-audit-summary';
  static const String inventoryOutbound = '/inventory-outbound';
  static const String inventoryOutboundHistory = '/inventory-outbound-history';
  static const String webBuilder = '/web-builder';
  static const String storeSettings = '/web-builder/store-settings';
  static const String themeList = '/web-builder/themes';
  static const String themeDetail = '/web-builder/themes/detail';
  static const String cmsPageList = '/web-builder/cms-pages';
  static const String cmsPageEditor = '/web-builder/cms-pages/editor';
  static const String orderTracking = OrderTrackingNavigation.routeName;
  static const String reports = '/reports';
  static const String users = '/users';
  static const String productList = '/products';
  static const String productDetail = '/product-detail';
  static const String fulfillment = '/fulfillment';
  static const String fulfillmentDetail = '/fulfillment/detail';
  static const String fulfillmentTracking = '/fulfillment/tracking';
  static const String fulfillmentPackaging = '/fulfillment/packaging';
  static const String fulfillmentPrintLabel = '/fulfillment/print-label';
  static const String storeHome = '/storefront';
  static const String storefrontProductListing = '/storefront/product-listing';
  static const String categoriesLanding = '/storefront/categories';
  static const String brandsLanding = '/storefront/brands';
  static const String productDetail = '/storefront/product-detail';

  static const String profileDashboard = '/profile';
  static const String addressBook = '/address_book';
  static const String addressForm = '/address_form';
  static const String orderHistory = '/order_history';
  static const String orderDetail = '/order_detail';
  static const String returnRequest = '/return_request';

  static final routes = <String, WidgetBuilder>{
    login: (BuildContext context) => LoginScreen(),
    home: (BuildContext context) => HomeScreen(),
    stockOperations: (BuildContext context) => const StockOperationsScreen(),
    inventoryAudit: (BuildContext context) => const InventoryAuditScreen(),
    inventoryAuditSummary: (BuildContext context) =>
        const InventoryAuditSummaryScreen(),
    inventoryOutbound: (BuildContext context) => const InventoryOutboundScreen(),
    inventoryOutboundHistory: (BuildContext context) =>
        const InventoryOutboundHistoryScreen(),
    webBuilder: (BuildContext context) => const WebBuilderDashboard(),
    storeSettings: (BuildContext context) => const StoreSettingsScreen(),
    themeList: (BuildContext context) => const ThemeListScreen(),
    themeDetail: (BuildContext context) => const ThemeDetailScreen(),
    cmsPageList: (BuildContext context) => const CmsPageListScreen(),
    cmsPageEditor: (BuildContext context) => const CmsPageEditorScreen(),
    orderTracking: OrderTrackingNavigation.buildScreen,
    ...CartRoutes.getRoutes(),
    reports: (BuildContext context) => ReportsAnalyticsScreen(),
    profileDashboard: (BuildContext context) => ProfileDashboardScreen(),
    addressBook: (BuildContext context) => const AddressBookScreen(),
    addressForm: (BuildContext context) => const AddressFormScreen(),
    orderHistory: (BuildContext context) => const OrderHistoryScreen(),
    orderDetail: (BuildContext context) => const OrderDetailScreen(),
    returnRequest: (BuildContext context) => const ReturnRequestScreen(),
    users: (BuildContext context) => UserManagementScreen(
      userStore: getIt<UserStore>(),
      roleStore: getIt<RoleStore>(),
    ),
    productList: (BuildContext context) => ProductListPage(),
    productDetail: (BuildContext context) => const ProductDetailScreen(),
    fulfillment: (BuildContext context) => FulfillmentListScreen(),
    fulfillmentDetail: (BuildContext context) => FulfillmentDetailScreen(),
    fulfillmentTracking: (BuildContext context) => FulfillmentTrackingScreen(),
    fulfillmentPackaging: (BuildContext context) => PackagingScreen(),
    fulfillmentPrintLabel: (BuildContext context) => PrintLabelScreen(),
    storeHome: (BuildContext context) => StorefrontHomePage(),
    storefrontProductListing: (BuildContext context) => ProductListingScreen(),
    categoriesLanding: (BuildContext context) => const CategoriesLandingPage(),
    brandsLanding: (BuildContext context) => const BrandsLandingPage(),
    productDetail: (BuildContext context) => Text("Product detail page")
  };

}
