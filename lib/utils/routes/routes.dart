import 'package:mobile_ai_erp/presentation/home/home.dart';
import 'package:mobile_ai_erp/presentation/login/login.dart';
import 'package:mobile_ai_erp/presentation/product/screens/product_list_page.dart';
import 'package:mobile_ai_erp/presentation/product/screens/product_detail_page.dart';
import 'package:flutter/material.dart';
import 'cart_routes.dart';

class Routes {
  Routes._();

  //static variables
  static const String splash = '/splash';
  static const String login = '/login';
  static const String home = '/post';
  static const String productList = '/products';
  static const String productDetail = '/product-detail';

  static final routes = <String, WidgetBuilder>{
    login: (BuildContext context) => LoginScreen(),
    home: (BuildContext context) => HomeScreen(),
    productList: (BuildContext context) => ProductListPage(),
    productDetail: (BuildContext context) => ProductDetailPage(),
    ...CartRoutes.getRoutes(),
  };
}
