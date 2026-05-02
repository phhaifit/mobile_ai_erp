// import 'dart:developer';

// import 'package:dio/dio.dart';
// import 'package:dio_cache_interceptor/dio_cache_interceptor.dart';
// import 'package:mobile_ai_erp/core/data/network/dio/configs/dio_configs.dart';
// import 'package:mobile_ai_erp/core/data/network/dio/dio_client.dart';
// import 'package:mobile_ai_erp/data/network/constants/endpoints.dart';

// class BrandApi {
//   final DioClient _dioClient;

//   BrandApi()
//     : _dioClient = DioClient(
//         dioConfigs: DioConfigs(baseUrl: Endpoints.baseUrl),
//       ) {
//     _addInterceptors();
//   }
//   BrandApi.customClient(this._dioClient) {
//     _addInterceptors();
//   }

//   void _addInterceptors() {
//     _dioClient.addInterceptors([
//       DioCacheInterceptor(
//         options: CacheOptions(
//           store: MemCacheStore(),
//           maxStale: const Duration(minutes: 5),
//         ),
//       ),
//       InterceptorsWrapper(
//         onRequest: (options, handler) {
//           options.headers['Authorization'] = 'Bearer test';
//           options.headers['X-Tenant-Id'] = 'test';
//           return handler.next(options);
//         },
//       ),
//     ]);
//   }

//   Future<Map<String, dynamic>> getBrands(
//     Map<String, String>? queryParameters,
//   ) async {
//     try {
//       final response = await _dioClient.dio.get(
//         Endpoints.brandsUrl,
//         queryParameters: queryParameters,
//       );
//       return response.data as Map<String, dynamic>;
//     } catch (e) {
//       rethrow;
//     }
//   }
// }
