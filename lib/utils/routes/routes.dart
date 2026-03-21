import 'package:flutter/material.dart';
import 'package:mobile_ai_erp/presentation/home/home.dart';
import 'package:mobile_ai_erp/presentation/login/login.dart';
import 'package:mobile_ai_erp/presentation/stock_operations/stock_operations_screen.dart';

class Routes {
  Routes._();

  static const String splash = '/splash';
  static const String login = '/login';
  static const String home = '/post';
  static const String stockOperations = '/stock-operations';

  static final routes = <String, WidgetBuilder>{
    login: (BuildContext context) => LoginScreen(),
    home: (BuildContext context) => HomeScreen(),
    stockOperations: (BuildContext context) => const StockOperationsScreen(),
  };
}
