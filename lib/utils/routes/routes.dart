import 'package:mobile_ai_erp/presentation/home/home.dart';
import 'package:mobile_ai_erp/presentation/login/login.dart';
import 'package:mobile_ai_erp/presentation/reports/reports_analytics.dart';
import 'package:mobile_ai_erp/presentation/account/profile/profile_dashboard_screen.dart';
import 'package:mobile_ai_erp/presentation/account/address/address_book_screen.dart';
import 'package:mobile_ai_erp/presentation/account/address/address_form_screen.dart';
import 'package:mobile_ai_erp/presentation/account/orders/order_history_screen.dart';
import 'package:mobile_ai_erp/presentation/account/orders/order_detail_screen.dart';
import 'package:mobile_ai_erp/presentation/account/orders/return_request_screen.dart';
import 'package:flutter/material.dart';


class Routes {
  Routes._();

  // static variables
  static const String splash = '/splash';
  static const String login = '/login';
  static const String home = '/post';
  static const String reports = '/reports';

  static const String profileDashboard = '/profile';
  static const String addressBook = '/address_book';
  static const String addressForm = '/address_form';
  static const String orderHistory = '/order_history';
  static const String orderDetail = '/order_detail';
  static const String returnRequest = '/return_request';

  static final routes = <String, WidgetBuilder>{
    login: (BuildContext context) => LoginScreen(),
    home: (BuildContext context) => HomeScreen(),
    reports: (BuildContext context) => ReportsAnalyticsScreen(),

    profileDashboard: (BuildContext context) => ProfileDashboardScreen(),
    addressBook: (BuildContext context) => const AddressBookScreen(),
    addressForm: (BuildContext context) => const AddressFormScreen(),
    orderHistory: (BuildContext context) => const OrderHistoryScreen(),
    orderDetail: (BuildContext context) => const OrderDetailScreen(),
    returnRequest: (BuildContext context) => const ReturnRequestScreen(),
  };

}
