import 'dart:async';

import 'package:mobile_ai_erp/data/local/datasources/customer/customer_datasource.dart';
import 'package:mobile_ai_erp/data/local/datasources/post/post_datasource.dart';
import 'package:mobile_ai_erp/data/local/datasources/product_metadata/product_metadata_datasource.dart';
import 'package:mobile_ai_erp/data/network/apis/posts/post_api.dart';
import 'package:mobile_ai_erp/data/repository/customer/customer_repository_impl.dart';
import 'package:mobile_ai_erp/data/repository/post/post_repository_impl.dart';
import 'package:mobile_ai_erp/data/repository/product_metadata/product_metadata_repository_impl.dart';
import 'package:mobile_ai_erp/data/repository/setting/setting_repository_impl.dart';
import 'package:mobile_ai_erp/data/repository/user/user_repository_impl.dart';
import 'package:mobile_ai_erp/data/sharedpref/shared_preference_helper.dart';
import 'package:mobile_ai_erp/domain/repository/customer/customer_repository.dart';
import 'package:mobile_ai_erp/domain/repository/post/post_repository.dart';
import 'package:mobile_ai_erp/domain/repository/product_metadata/product_metadata_repository.dart';
import 'package:mobile_ai_erp/domain/repository/setting/setting_repository.dart';
import 'package:mobile_ai_erp/domain/repository/user/user_repository.dart';

import '../../../di/service_locator.dart';

class RepositoryModule {
  static Future<void> configureRepositoryModuleInjection() async {
    // repository:--------------------------------------------------------------
    getIt.registerSingleton<CustomerDataSource>(CustomerDataSource());

    getIt.registerSingleton<CustomerRepository>(
      CustomerRepositoryImpl(getIt<CustomerDataSource>()),
    );

    getIt.registerSingleton<SettingRepository>(SettingRepositoryImpl(
      getIt<SharedPreferenceHelper>(),
    ));

    getIt.registerSingleton<UserRepository>(UserRepositoryImpl(
      getIt<SharedPreferenceHelper>(),
    ));

    getIt.registerSingleton<PostRepository>(PostRepositoryImpl(
      getIt<PostApi>(),
      getIt<PostDataSource>(),
    ));

    getIt.registerSingleton<ProductMetadataDataSource>(
        ProductMetadataDataSource());
    getIt.registerSingleton<ProductMetadataRepository>(
        ProductMetadataRepositoryImpl(
      getIt<ProductMetadataDataSource>(),
    ));
  }
}
