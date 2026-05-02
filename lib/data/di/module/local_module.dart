import 'dart:async';

import 'package:mobile_ai_erp/constants/env.dart';
import 'package:mobile_ai_erp/data/local/datasources/product/mock_product_datasource.dart';
import 'package:mobile_ai_erp/core/data/local/sembast/sembast_client.dart';
import 'package:mobile_ai_erp/data/local/constants/db_constants.dart';
import 'package:mobile_ai_erp/data/local/datasources/post/post_datasource.dart';
import 'package:mobile_ai_erp/data/sharedpref/shared_preference_helper.dart';
import 'package:mobile_ai_erp/data/sharedpref/customer_shared_preference_helper.dart';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mobile_ai_erp/data/local/datasources/account/address_mock_datasource.dart';
import 'package:mobile_ai_erp/data/local/datasources/account/order_mock_datasource.dart';

import '../../../di/service_locator.dart';

class LocalModule {
  static const String _appModeKey = 'app_mode_is_customer_app';

  static Future<void> configureLocalModuleInjection() async {
    // preference manager:------------------------------------------------------
    getIt.registerSingletonAsync<SharedPreferences>(
        SharedPreferences.getInstance);
    
    final sharedPreferences = await getIt.getAsync<SharedPreferences>();
    
    // Check if app mode has changed and clear preferences if it has
    final storedIsCustomerApp = sharedPreferences.getBool(_appModeKey);
    if (storedIsCustomerApp != null && storedIsCustomerApp != Env.isCustomerApp) {
      await sharedPreferences.clear();
    }
    
    // Store the current app mode
    await sharedPreferences.setBool(_appModeKey, Env.isCustomerApp);
    
    // Register appropriate SharedPreferenceHelper based on app mode
    if (Env.isCustomerApp) {
      getIt.registerSingleton<CustomerSharedPreferenceHelper>(
        CustomerSharedPreferenceHelper(sharedPreferences),
      );
      getIt.registerSingleton<SharedPreferenceHelper>(
        getIt<CustomerSharedPreferenceHelper>()
      );
    } else {
      getIt.registerSingleton<SharedPreferenceHelper>(
        SharedPreferenceHelper(sharedPreferences),
      );
    }

    // database:----------------------------------------------------------------

    getIt.registerSingletonAsync<SembastClient>(
      () async => SembastClient.provideDatabase(
        databaseName: DBConstants.DB_NAME,
        databasePath: kIsWeb
            ? "/assets/db"
            : (await getApplicationDocumentsDirectory()).path,
      ),
    );

    // data sources:------------------------------------------------------------
    getIt.registerSingleton(
        PostDataSource(await getIt.getAsync<SembastClient>()));

    getIt.registerLazySingleton<AddressMockDataSource>(
        () => AddressMockDataSource());
    getIt.registerLazySingleton<OrderMockDataSource>(
        () => OrderMockDataSource());

    getIt.registerLazySingleton<MockProductDataSource>(
      () => MockProductDataSource());
  }
}
