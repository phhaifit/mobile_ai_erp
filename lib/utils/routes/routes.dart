import 'package:mobile_ai_erp/presentation/home/home.dart';
import 'package:mobile_ai_erp/presentation/login/login.dart';
import 'package:mobile_ai_erp/presentation/web_builder/web_builder_dashboard.dart';
import 'package:mobile_ai_erp/presentation/web_builder/store_settings/store_settings_screen.dart';
import 'package:mobile_ai_erp/presentation/web_builder/theme_engine/theme_list_screen.dart';
import 'package:mobile_ai_erp/presentation/web_builder/theme_engine/theme_detail_screen.dart';
import 'package:mobile_ai_erp/presentation/web_builder/cms_pages/cms_page_list_screen.dart';
import 'package:mobile_ai_erp/presentation/web_builder/cms_pages/cms_page_editor_screen.dart';
import 'package:mobile_ai_erp/presentation/order_tracking/order_tracking.dart';
import 'package:mobile_ai_erp/presentation/reports/reports_analytics.dart';
import 'package:mobile_ai_erp/presentation/order_fulfillment/fulfillment_detail.dart';
import 'package:mobile_ai_erp/presentation/order_fulfillment/fulfillment_list.dart';
import 'package:mobile_ai_erp/presentation/order_fulfillment/order_tracking.dart';
import 'package:mobile_ai_erp/presentation/order_fulfillment/packaging.dart';
import 'package:mobile_ai_erp/presentation/order_fulfillment/print_label.dart';
import 'package:mobile_ai_erp/presentation/post_purchase/post_purchase_dashboard.dart';
import 'package:mobile_ai_erp/presentation/post_purchase/issue_detail_screen.dart';
import 'package:mobile_ai_erp/presentation/post_purchase/return_detail_screen.dart';
import 'package:flutter/material.dart';

class Routes {
  Routes._();

  static const String splash = '/splash';
  static const String login = '/login';
  static const String home = '/post';
  static const String webBuilder = '/web-builder';
  static const String storeSettings = '/web-builder/store-settings';
  static const String themeList = '/web-builder/themes';
  static const String themeDetail = '/web-builder/themes/detail';
  static const String cmsPageList = '/web-builder/cms-pages';
  static const String cmsPageEditor = '/web-builder/cms-pages/editor';
  static const String orderTracking = OrderTrackingNavigation.routeName;
  static const String reports = '/reports';
  static const String fulfillment = '/fulfillment';
  static const String fulfillmentDetail = '/fulfillment/detail';
  static const String fulfillmentTracking = '/fulfillment/tracking';
  static const String fulfillmentPackaging = '/fulfillment/packaging';
  static const String fulfillmentPrintLabel = '/fulfillment/print-label';
  static const String postPurchase = '/post-purchase';
  static const String postPurchaseIssueDetail = '/post-purchase/issue';
  static const String postPurchaseReturnDetail = '/post-purchase/return';

  static final routes = <String, WidgetBuilder>{
    login: (BuildContext context) => LoginScreen(),
    home: (BuildContext context) => HomeScreen(),
    webBuilder: (BuildContext context) => const WebBuilderDashboard(),
    storeSettings: (BuildContext context) => const StoreSettingsScreen(),
    themeList: (BuildContext context) => const ThemeListScreen(),
    themeDetail: (BuildContext context) => const ThemeDetailScreen(),
    cmsPageList: (BuildContext context) => const CmsPageListScreen(),
    cmsPageEditor: (BuildContext context) => const CmsPageEditorScreen(),
    orderTracking: OrderTrackingNavigation.buildScreen,
    reports: (BuildContext context) => ReportsAnalyticsScreen(),
    fulfillment: (BuildContext context) => FulfillmentListScreen(),
    fulfillmentDetail: (BuildContext context) => FulfillmentDetailScreen(),
    fulfillmentTracking: (BuildContext context) => FulfillmentTrackingScreen(),
    fulfillmentPackaging: (BuildContext context) => PackagingScreen(),
    fulfillmentPrintLabel: (BuildContext context) => PrintLabelScreen(),
    postPurchase: (BuildContext context) => const PostPurchaseDashboardScreen(),
    postPurchaseIssueDetail: (BuildContext context) => const IssueDetailScreen(),
    postPurchaseReturnDetail: (BuildContext context) =>
        const ReturnDetailScreen(),
  };
}
