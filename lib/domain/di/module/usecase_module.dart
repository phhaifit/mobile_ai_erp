import 'dart:async';

import 'package:mobile_ai_erp/domain/repository/post/post_repository.dart';
import 'package:mobile_ai_erp/domain/repository/order_tracking/order_tracking_repository.dart';
import 'package:mobile_ai_erp/domain/repository/user/user_repository.dart';
import 'package:mobile_ai_erp/domain/usecase/order_tracking/find_order_tracking_scenario_usecase.dart';
import 'package:mobile_ai_erp/domain/usecase/order_tracking/get_order_tracking_scenarios_usecase.dart';
import 'package:mobile_ai_erp/domain/usecase/post/delete_post_usecase.dart';
import 'package:mobile_ai_erp/domain/usecase/post/find_post_by_id_usecase.dart';
import 'package:mobile_ai_erp/domain/usecase/post/get_post_usecase.dart';
import 'package:mobile_ai_erp/domain/usecase/post/insert_post_usecase.dart';
import 'package:mobile_ai_erp/domain/usecase/post/udpate_post_usecase.dart';
import 'package:mobile_ai_erp/domain/usecase/user/is_logged_in_usecase.dart';
import 'package:mobile_ai_erp/domain/usecase/user/login_usecase.dart';
import 'package:mobile_ai_erp/domain/usecase/user/save_login_in_status_usecase.dart';

import '../../../di/service_locator.dart';

class UseCaseModule {
  static Future<void> configureUseCaseModuleInjection() async {
    // user:--------------------------------------------------------------------
    getIt.registerSingleton<IsLoggedInUseCase>(
      IsLoggedInUseCase(getIt<UserRepository>()),
    );
    getIt.registerSingleton<SaveLoginStatusUseCase>(
      SaveLoginStatusUseCase(getIt<UserRepository>()),
    );
    getIt.registerSingleton<LoginUseCase>(
      LoginUseCase(getIt<UserRepository>()),
    );

    // post:--------------------------------------------------------------------
    getIt.registerSingleton<GetPostUseCase>(
      GetPostUseCase(getIt<PostRepository>()),
    );
    getIt.registerSingleton<FindPostByIdUseCase>(
      FindPostByIdUseCase(getIt<PostRepository>()),
    );
    getIt.registerSingleton<InsertPostUseCase>(
      InsertPostUseCase(getIt<PostRepository>()),
    );
    getIt.registerSingleton<UpdatePostUseCase>(
      UpdatePostUseCase(getIt<PostRepository>()),
    );
    getIt.registerSingleton<DeletePostUseCase>(
      DeletePostUseCase(getIt<PostRepository>()),
    );

    // order tracking:----------------------------------------------------------
    getIt.registerSingleton<GetOrderTrackingScenariosUseCase>(
      GetOrderTrackingScenariosUseCase(getIt<OrderTrackingRepository>()),
    );
    getIt.registerSingleton<FindOrderTrackingScenarioUseCase>(
      FindOrderTrackingScenarioUseCase(getIt<OrderTrackingRepository>()),
    );
  }
}
