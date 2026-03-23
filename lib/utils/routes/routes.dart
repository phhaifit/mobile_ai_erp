import 'package:flutter/material.dart';
import 'package:mobile_ai_erp/presentation/home/home.dart';
import 'package:mobile_ai_erp/presentation/login/login.dart';
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
import 'package:mobile_ai_erp/presentation/order_fulfillment/fulfillment_detail.dart';
import 'package:mobile_ai_erp/presentation/order_fulfillment/fulfillment_list.dart';
import 'package:mobile_ai_erp/presentation/order_fulfillment/order_tracking.dart';
import 'package:mobile_ai_erp/presentation/order_fulfillment/packaging.dart';
import 'package:mobile_ai_erp/presentation/order_fulfillment/print_label.dart';
import 'package:mobile_ai_erp/presentation/user/home/user_home.dart';
import 'package:mobile_ai_erp/di/service_locator.dart';
import 'package:mobile_ai_erp/presentation/user/store/role_store.dart';
import 'package:mobile_ai_erp/presentation/user/store/user_store.dart';
import 'cart_routes.dart';
import 'package:mobile_ai_erp/presentation/product/screens/product_list_page.dart';

class Routes {
  Routes._();

  static const String splash = '/splash';
  static const String login = '/login';
  static const String home = '/post';
  static const String stockOperations = '/stock-operations';
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

  static final routes = <String, WidgetBuilder>{
    login: (BuildContext context) => LoginScreen(),
    home: (BuildContext context) => HomeScreen(),
    stockOperations: (BuildContext context) => const StockOperationsScreen(),
    webBuilder: (BuildContext context) => const WebBuilderDashboard(),
    storeSettings: (BuildContext context) => const StoreSettingsScreen(),
    themeList: (BuildContext context) => const ThemeListScreen(),
    themeDetail: (BuildContext context) => const ThemeDetailScreen(),
    cmsPageList: (BuildContext context) => const CmsPageListScreen(),
    cmsPageEditor: (BuildContext context) => const CmsPageEditorScreen(),
    orderTracking: OrderTrackingNavigation.buildScreen,
    ...CartRoutes.getRoutes(),
    reports: (BuildContext context) => ReportsAnalyticsScreen(),
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
  };
}
