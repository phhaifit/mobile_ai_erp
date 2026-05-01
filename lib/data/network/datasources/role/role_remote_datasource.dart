import 'package:dio/dio.dart';
import 'package:mobile_ai_erp/domain/entity/user/role.dart';
import 'package:mobile_ai_erp/core/data/network/models/api_error_response.dart';

abstract class RoleRemoteDataSource {
  Future<List<Role>> getRoles();
  Future<Role> getRoleById(String id);
  Future<Role> createRole(Role role);
  Future<Role> updateRole(String id, Role role);
  Future<void> deleteRole(String id);
}

class RoleRemoteDataSourceImpl implements RoleRemoteDataSource {
  final Dio _dio;

  RoleRemoteDataSourceImpl({required Dio dio}) : _dio = dio;

  @override
  Future<List<Role>> getRoles() async {
    try {
      final response = await _dio.get('/roles');
      
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        return data.map((json) => Role.fromJson(json)).toList();
      } else {
        throw _handleApiError(response);
      }
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  @override
  Future<Role> getRoleById(String id) async {
    try {
      final response = await _dio.get('/roles/$id');
      
      if (response.statusCode == 200) {
        return Role.fromJson(response.data);
      } else {
        throw _handleApiError(response);
      }
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  @override
  Future<Role> createRole(Role role) async {
    try {
      final response = await _dio.post(
        '/roles',
        data: {
          'data': {
            'name': role.name,
            'description': role.description,
          }
        },
      );
      
      if (response.statusCode == 201 || response.statusCode == 200) {
        return Role.fromJson(response.data);
      } else {
        throw _handleApiError(response);
      }
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  @override
  Future<Role> updateRole(String id, Role role) async {
    try {
      final response = await _dio.patch(
        '/roles/$id',
        data: {
          'data': {
            'name': role.name,
            'description': role.description,
          }
        },
      );
      
      if (response.statusCode == 200) {
        return Role.fromJson(response.data);
      } else {
        throw _handleApiError(response);
      }
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  @override
  Future<void> deleteRole(String id) async {
    try {
      final response = await _dio.delete('/roles/$id');
      
      if (response.statusCode != 200) {
        throw _handleApiError(response);
      }
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  ApiException _handleApiError(Response response) {
    try {
      final errorResponse = ApiErrorResponse.fromJson(response.data);
      return ApiException(errorResponse);
    } catch (e) {
      return ApiException(ApiErrorResponse(
        success: false,
        error: ApiError(
          code: 'UNKNOWN_ERROR',
          message: 'Failed to ${response.requestOptions.method} role: ${response.statusCode}',
          details: [],
        ),
        timestamp: DateTime.now().toIso8601String(),
        path: response.requestOptions.path,
      ));
    }
  }

  ApiException _handleDioError(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
        return ApiException(ApiErrorResponse(
          success: false,
          error: ApiError(
            code: 'CONNECTION_TIMEOUT',
            message: 'Connection timeout. Please check your internet connection.',
            details: [],
          ),
          timestamp: DateTime.now().toIso8601String(),
          path: e.requestOptions.path,
        ));
      case DioExceptionType.receiveTimeout:
        return ApiException(ApiErrorResponse(
          success: false,
          error: ApiError(
            code: 'RECEIVE_TIMEOUT',
            message: 'Server response timeout. Please try again.',
            details: [],
          ),
          timestamp: DateTime.now().toIso8601String(),
          path: e.requestOptions.path,
        ));
      case DioExceptionType.badResponse:
        return _handleApiError(e.response!);
      case DioExceptionType.cancel:
        return ApiException(ApiErrorResponse(
          success: false,
          error: ApiError(
            code: 'REQUEST_CANCELLED',
            message: 'Request was cancelled.',
            details: [],
          ),
          timestamp: DateTime.now().toIso8601String(),
          path: e.requestOptions.path,
        ));
      case DioExceptionType.unknown:
        return ApiException(ApiErrorResponse(
          success: false,
          error: ApiError(
            code: 'NETWORK_ERROR',
            message: 'Network error: ${e.message}',
            details: [],
          ),
          timestamp: DateTime.now().toIso8601String(),
          path: e.requestOptions.path,
        ));
      default:
        return ApiException(ApiErrorResponse(
          success: false,
          error: ApiError(
            code: 'UNKNOWN_ERROR',
            message: 'An unexpected error occurred: ${e.message}',
            details: [],
          ),
          timestamp: DateTime.now().toIso8601String(),
          path: e.requestOptions.path,
        ));
    }
  }
}
