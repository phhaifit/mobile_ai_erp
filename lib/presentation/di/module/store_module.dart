import 'dart:async';

import 'package:mobile_ai_erp/core/stores/error/error_store.dart';
import 'package:mobile_ai_erp/core/stores/form/form_store.dart';
import 'package:mobile_ai_erp/domain/repository/setting/setting_repository.dart';
import 'package:mobile_ai_erp/domain/repository/product_metadata/product_metadata_repository.dart';
import 'package:mobile_ai_erp/domain/repository/user/role_repository.dart';
import 'package:mobile_ai_erp/domain/repository/user/user_repository.dart';
import 'package:mobile_ai_erp/domain/usecase/post/get_post_usecase.dart';
import 'package:mobile_ai_erp/domain/usecase/user/assign_role_to_user_usecase.dart';
import 'package:mobile_ai_erp/domain/usecase/user/create_role_usecase.dart';
import 'package:mobile_ai_erp/domain/usecase/user/update_role_usercase.dart';
// import 'package:mobile_ai_erp/domain/usecase/user/is_logged_in_usecase.dart';
// import 'package:mobile_ai_erp/domain/usecase/user/login_usecase.dart';
// import 'package:mobile_ai_erp/domain/usecase/user/save_login_in_status_usecase.dart';
import 'package:mobile_ai_erp/presentation/home/store/language/language_store.dart';
import 'package:mobile_ai_erp/presentation/home/store/theme/theme_store.dart';
// import 'package:mobile_ai_erp/presentation/login/store/login_store.dart';
import 'package:mobile_ai_erp/presentation/post/store/post_store.dart';
import 'package:mobile_ai_erp/presentation/reports/data/reports_mock_repository.dart';
import 'package:mobile_ai_erp/presentation/reports/store/reports_store.dart';
import 'package:mobile_ai_erp/presentation/product_metadata/store/product_metadata_store.dart';
import 'package:mobile_ai_erp/presentation/user/store/role_store.dart';
import 'package:mobile_ai_erp/presentation/user/store/user_store.dart';

import '../../../di/service_locator.dart';

class StoreModule {
  static Future<void> configureStoreModuleInjection() async {
    // factories:---------------------------------------------------------------
    getIt.registerFactory(() => ErrorStore());
    getIt.registerFactory(() => FormErrorStore());
    getIt.registerFactory(
      () => FormStore(getIt<FormErrorStore>(), getIt<ErrorStore>()),
    );
    getIt.registerLazySingleton(() => ReportsMockRepository());

    // stores:------------------------------------------------------------------
    // getIt.registerSingleton<UserStore>(
    //   UserStore(
    //     getIt<IsLoggedInUseCase>(),
    //     getIt<SaveLoginStatusUseCase>(),
    //     getIt<LoginUseCase>(),
    //     getIt<FormErrorStore>(),
    //     getIt<ErrorStore>(),
    //   ),
    // );
    getIt.registerSingleton<PostStore>(
      PostStore(
        getIt<GetPostUseCase>(),
        getIt<ErrorStore>(),
      ),
    );

    getIt.registerSingleton<ReportsStore>(
      ReportsStore(
        getIt<ReportsMockRepository>(),
        getIt<ErrorStore>(),
      ),
    );

    getIt.registerSingleton<ProductMetadataStore>(
      ProductMetadataStore(
        getIt<ProductMetadataRepository>(),
        getIt<ErrorStore>(),
      ),
    );

    getIt.registerSingleton<ThemeStore>(
      ThemeStore(
        getIt<SettingRepository>(),
        getIt<ErrorStore>(),
      ),
    );

    getIt.registerSingleton<LanguageStore>(
      LanguageStore(
        getIt<SettingRepository>(),
        getIt<ErrorStore>(),
      ),
    );

    getIt.registerSingleton<UserStore>(UserStore(getIt<UserRepository>(),
        getIt<RoleRepository>(), getIt<AssignRoleToUserUseCase>()));

    getIt.registerSingleton<RoleStore>(RoleStore(getIt<RoleRepository>(),
        getIt<CreateRoleUseCase>(), getIt<UpdateRoleUseCase>()));
  }
}
