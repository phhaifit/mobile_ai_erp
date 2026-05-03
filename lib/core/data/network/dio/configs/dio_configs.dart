import 'package:dio/dio.dart';

const _kDefaultReceiveTimeout = 10000;
const _kDefaultConnectionTimeout = 10000;

class DioConfigs {
  final String baseUrl;
  final int receiveTimeout;
  final int connectionTimeout;
  final bool followRedirects;
  final ValidateStatus? validateStatus;

  const DioConfigs({
    required this.baseUrl,
    this.receiveTimeout = _kDefaultReceiveTimeout,
    this.connectionTimeout = _kDefaultConnectionTimeout,
    this.validateStatus,
    this.followRedirects = false,
  });
}
