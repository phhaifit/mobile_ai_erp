import 'package:dio/dio.dart';

import 'configs/dio_configs.dart';

class DioClient {
  final DioConfigs dioConfigs;
  final Dio _dio;

  DioClient({required this.dioConfigs})
      : _dio = Dio()
    ..options.baseUrl = dioConfigs.baseUrl
    ..options.followRedirects = dioConfigs.followRedirects
    ..options.connectTimeout = Duration(milliseconds: dioConfigs.connectionTimeout)
    ..options.receiveTimeout = Duration(milliseconds: dioConfigs.receiveTimeout)
  {
    if (dioConfigs.validateStatus != null) {
      _dio.options.validateStatus = dioConfigs.validateStatus!;
    }
  }

  Dio get dio => _dio;

  Dio addInterceptors(Iterable<Interceptor> interceptors) {
    return _dio..interceptors.addAll(interceptors);
  }
}