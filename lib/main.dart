import 'dart:async';

import 'package:mobile_ai_erp/constants/env.dart';
import 'package:mobile_ai_erp/di/service_locator.dart';
import 'package:mobile_ai_erp/presentation/my_app.dart';
import 'package:mobile_ai_erp/presentation/customer_app.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  await setPreferredOrientations();
  await ServiceLocator.configureDependencies();
  
  if (Env.isCustomerApp) {
    runApp(const CustomerApp());
  } else {
    runApp(const MyApp());
  }
}

Future<void> setPreferredOrientations() {
  return SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
    DeviceOrientation.landscapeRight,
    DeviceOrientation.landscapeLeft,
  ]);
}
