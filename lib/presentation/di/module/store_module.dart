import 'dart:async';

import 'package:mobile_ai_erp/core/stores/error/error_store.dart';
import 'package:mobile_ai_erp/core/stores/form/form_store.dart';
import 'package:mobile_ai_erp/domain/repository/customer/customer_repository.dart';
import 'package:mobile_ai_erp/core/stores/supplier/supplier_store.dart';
import 'package:mobile_ai_erp/domain/repository/setting/setting_repository.dart';
import 'package:mobile_ai_erp/domain/repository/stock_operations/stock_operations_repository.dart';
import 'package:mobile_ai_erp/domain/usecase/order_tracking/find_order_tracking_scenario_usecase.dart';
import 'package:mobile_ai_erp/domain/usecase/order_tracking/get_order_tracking_scenarios_usecase.dart';
import 'package:mobile_ai_erp/domain/usecase/post/get_post_usecase.dart';
import 'package:mobile_ai_erp/domain/repository/product_metadata/product_metadata_repository.dart';
import 'package:mobile_ai_erp/domain/repository/supplier/supplier_repository.dart';
import 'package:mobile_ai_erp/domain/usecase/fulfillment/add_package_usecase.dart';
import 'package:mobile_ai_erp/domain/usecase/fulfillment/get_fulfillment_order_detail_usecase.dart';
import 'package:mobile_ai_erp/domain/usecase/fulfillment/get_fulfillment_orders_usecase.dart';
import 'package:mobile_ai_erp/domain/usecase/fulfillment/update_fulfillment_status_usecase.dart';
import 'package:mobile_ai_erp/domain/usecase/fulfillment/update_package_usecase.dart';
import 'package:mobile_ai_erp/domain/usecase/fulfillment/update_picked_quantity_usecase.dart';
import 'package:mobile_ai_erp/domain/usecase/user/is_logged_in_usecase.dart';
import 'package:mobile_ai_erp/domain/usecase/user/login_usecase.dart';
import 'package:mobile_ai_erp/domain/usecase/user/save_login_in_status_usecase.dart';
import 'package:mobile_ai_erp/presentation/stock_operations/store/stock_operations_store.dart';
import 'package:mobile_ai_erp/domain/usecase/web_builder/apply_web_theme_usecase.dart';
import 'package:mobile_ai_erp/domain/usecase/web_builder/delete_cms_page_usecase.dart';
import 'package:mobile_ai_erp/domain/usecase/web_builder/get_cms_page_by_id_usecase.dart';
import 'package:mobile_ai_erp/domain/usecase/web_builder/get_cms_pages_usecase.dart';
import 'package:mobile_ai_erp/domain/usecase/web_builder/get_store_settings_usecase.dart';
import 'package:mobile_ai_erp/domain/usecase/web_builder/get_web_theme_by_id_usecase.dart';
import 'package:mobile_ai_erp/domain/usecase/web_builder/get_web_themes_usecase.dart';
import 'package:mobile_ai_erp/domain/usecase/web_builder/save_cms_page_usecase.dart';
import 'package:mobile_ai_erp/domain/usecase/web_builder/save_store_settings_usecase.dart';
import 'package:mobile_ai_erp/presentation/product_detail/store/product_detail_store.dart';
import 'package:mobile_ai_erp/presentation/customer_management/store/customer_store.dart';
import 'package:mobile_ai_erp/presentation/home/store/language/language_store.dart';
import 'package:mobile_ai_erp/presentation/home/store/theme/theme_store.dart';
import 'package:mobile_ai_erp/presentation/login/store/login_store.dart';
import 'package:mobile_ai_erp/presentation/post/store/post_store.dart';
import 'package:mobile_ai_erp/presentation/product_metadata/store/product_metadata_store.dart';
import 'package:mobile_ai_erp/presentation/order_tracking/store/order_tracking_store.dart';
import 'package:mobile_ai_erp/presentation/reports/data/reports_mock_repository.dart';
import 'package:mobile_ai_erp/presentation/reports/store/reports_store.dart';
import 'package:mobile_ai_erp/presentation/web_builder/store/cms_page_store.dart';
import 'package:mobile_ai_erp/presentation/web_builder/store/store_settings_store.dart';
import 'package:mobile_ai_erp/presentation/web_builder/store/web_theme_store.dart';
import 'package:mobile_ai_erp/presentation/order_fulfillment/store/fulfillment_store.dart';

import '../../../di/service_locator.dart';

class StoreModule {
  static Future<void> configureStoreModuleInjection() async {
    getIt.registerFactory(() => ErrorStore());
    getIt.registerFactory(() => FormErrorStore());
    getIt.registerFactory(
      () => FormStore(getIt<FormErrorStore>(), getIt<ErrorStore>()),
    );
    getIt.registerLazySingleton(() => ReportsMockRepository());

    getIt.registerSingleton<UserStore>(
      UserStore(
        getIt<IsLoggedInUseCase>(),
        getIt<SaveLoginStatusUseCase>(),
        getIt<LoginUseCase>(),
        getIt<FormErrorStore>(),
        getIt<ErrorStore>(),
      ),
    );

    getIt.registerSingleton<PostStore>(
      PostStore(getIt<GetPostUseCase>(), getIt<ErrorStore>()),
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

    getIt.registerSingleton<CustomerStore>(
      CustomerStore(
        getIt<CustomerRepository>(),
        getIt<ErrorStore>(),
      ),
    );

    getIt.registerSingleton<OrderTrackingStore>(
      OrderTrackingStore(
        getIt<GetOrderTrackingScenariosUseCase>(),
        getIt<FindOrderTrackingScenarioUseCase>(),
        getIt<ErrorStore>(),
      ),
    );

    getIt.registerSingleton<ThemeStore>(
      ThemeStore(getIt<SettingRepository>(), getIt<ErrorStore>()),
    );

    getIt.registerSingleton<LanguageStore>(
      LanguageStore(getIt<SettingRepository>(), getIt<ErrorStore>()),
    );

    getIt.registerSingleton<StockOperationsStore>(
      StockOperationsStore(getIt<StockOperationsRepository>()),
    );

    getIt.registerLazySingleton<SupplierStore>(
      () => SupplierStore(getIt<SupplierRepository>()),
    );

    // web_builder stores:------------------------------------------------------
    getIt.registerSingleton<CmsPageStore>(
      CmsPageStore(
        getIt<GetCmsPagesUseCase>(),
        getIt<GetCmsPageByIdUseCase>(),
        getIt<SaveCmsPageUseCase>(),
        getIt<DeleteCmsPageUseCase>(),
        getIt<ErrorStore>(),
      ),
    );

    getIt.registerSingleton<WebThemeStore>(
      WebThemeStore(
        getIt<GetWebThemesUseCase>(),
        getIt<GetWebThemeByIdUseCase>(),
        getIt<ApplyWebThemeUseCase>(),
        getIt<ErrorStore>(),
      ),
    );

    getIt.registerSingleton<StoreSettingsStore>(
      StoreSettingsStore(
        getIt<GetStoreSettingsUseCase>(),
        getIt<SaveStoreSettingsUseCase>(),
        getIt<ErrorStore>(),
      ),
    );

    getIt.registerFactory<ProductDetailStore>(
      () => ProductDetailStore(getIt<ErrorStore>()),
    );

    getIt.registerSingleton<FulfillmentStore>(
      FulfillmentStore(
        getIt<GetFulfillmentOrdersUseCase>(),
        getIt<GetFulfillmentOrderDetailUseCase>(),
        getIt<UpdateFulfillmentStatusUseCase>(),
        getIt<UpdatePickedQuantityUseCase>(),
        getIt<AddPackageUseCase>(),
        getIt<UpdatePackageUseCase>(),
        getIt<ErrorStore>(),
      ),
    );
  }
}
