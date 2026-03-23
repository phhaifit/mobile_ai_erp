import 'package:mobile_ai_erp/presentation/home/home.dart';
import 'package:mobile_ai_erp/presentation/login/login.dart';
import 'package:mobile_ai_erp/presentation/reports/reports_analytics.dart';
import 'package:flutter/material.dart';
import 'package:mobile_ai_erp/presentation/user/home/user_home.dart';
import 'package:mobile_ai_erp/di/service_locator.dart';
import 'package:mobile_ai_erp/presentation/user/store/role_store.dart';
import 'package:mobile_ai_erp/presentation/user/store/user_store.dart';

class Routes {
  Routes._();

  //static variables
  static const String splash = '/splash';
  static const String login = '/login';
  static const String home = '/post';
  static const String reports = '/reports';
  static const String users = '/users';

  static final routes = <String, WidgetBuilder>{
    login: (BuildContext context) => LoginScreen(),
    home: (BuildContext context) => HomeScreen(),
    reports: (BuildContext context) => ReportsAnalyticsScreen(),
    users: (BuildContext context) => UserManagementScreen(
          userStore: getIt<UserStore>(),
          roleStore: getIt<RoleStore>(),
        ),
  };
}
