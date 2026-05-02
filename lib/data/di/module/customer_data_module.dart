import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:mobile_ai_erp/core/data/network/dio/dio_client.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mobile_ai_erp/data/network/apis/customer/customer_auth_api.dart';
import 'package:mobile_ai_erp/data/local/preferences/customer_auth/auth_preferences.dart';
import 'package:mobile_ai_erp/data/repository/customer_auth_repository_impl.dart';
import 'package:mobile_ai_erp/domain/repository/customer_auth_repository.dart';

class CustomerDataModule {
  static void setup(GetIt getIt) {
    // APIs
    getIt.registerSingleton<CustomerAuthApi>(
      CustomerAuthApi(dio: getIt<DioClient>().dio),
    );

    // Preferences
    getIt.registerSingleton<AuthPreferences>(
      AuthPreferences(sharedPreferences: getIt<SharedPreferences>()),
    );

    // Repositories
    getIt.registerSingleton<CustomerAuthRepository>(
      CustomerAuthRepositoryImpl(api: getIt()),
    );
  }
}