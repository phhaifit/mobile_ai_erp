import 'dart:async';

import 'package:mobile_ai_erp/data/local/datasources/post/post_datasource.dart';
import 'package:mobile_ai_erp/data/local/datasources/product_metadata/product_metadata_datasource.dart';
import 'package:mobile_ai_erp/data/network/apis/posts/post_api.dart';
import 'package:mobile_ai_erp/data/repository/post/post_repository_impl.dart';
import 'package:mobile_ai_erp/data/repository/product_metadata/product_metadata_repository_impl.dart';
import 'package:mobile_ai_erp/data/repository/setting/setting_repository_impl.dart';
import 'package:mobile_ai_erp/data/repository/user/user_repository_impl.dart';
import 'package:mobile_ai_erp/data/sharedpref/shared_preference_helper.dart';
import 'package:mobile_ai_erp/domain/repository/post/post_repository.dart';
import 'package:mobile_ai_erp/domain/repository/product_metadata/product_metadata_repository.dart';
import 'package:mobile_ai_erp/domain/repository/setting/setting_repository.dart';
import 'package:mobile_ai_erp/domain/repository/user/user_repository.dart';
import 'package:mobile_ai_erp/domain/repository/account/address_repository.dart';
import 'package:mobile_ai_erp/domain/repository/account/order_repository.dart';
import 'package:mobile_ai_erp/data/repository/account/address_repository_impl.dart';
import 'package:mobile_ai_erp/data/repository/account/order_repository_impl.dart';
import 'package:mobile_ai_erp/data/local/datasources/account/address_mock_datasource.dart';
import 'package:mobile_ai_erp/data/local/datasources/account/order_mock_datasource.dart';

import '../../../di/service_locator.dart';

class RepositoryModule {
  static Future<void> configureRepositoryModuleInjection() async {
    // repository:--------------------------------------------------------------
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
    getIt.registerLazySingleton<AddressRepository>(
        () => AddressRepositoryImpl(getIt<AddressMockDataSource>()));
        
    getIt.registerLazySingleton<OrderRepository>(
        () => OrderRepositoryImpl(getIt<OrderMockDataSource>()));
  }
}
