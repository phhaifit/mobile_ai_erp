import 'package:dio/dio.dart';
import 'package:mobile_ai_erp/core/data/network/models/api_error_response.dart';
import 'package:mobile_ai_erp/domain/entity/user/user.dart';
import 'package:mobile_ai_erp/domain/entity/user/user_status.dart';

abstract class UserRemoteDataSource {
  Future<List<User>> getUsers();
  Future<User> getUserById(String id);
  Future<User> createUser(User user);
  Future<User> updateUser(String id, User user);
  Future<void> deleteUser(String id);
}

class UserRemoteDataSourceImpl implements UserRemoteDataSource {
  final Dio _dio;

  UserRemoteDataSourceImpl(this._dio);

  @override
  Future<List<User>> getUsers() async {
    try {
      final response = await _dio.get('/users');
      
      if (response.statusCode == 200) {
        final data = response.data;
        
        if (data is List) {
          return data.map((json) => User.fromJson(json)).toList();
        } else if (data is Map<String, dynamic>) {
          // Handle wrapped response format
          final wrappedData = data['data'];
          if (wrappedData is List) {
            return wrappedData.map((json) => User.fromJson(json)).toList();
          } else if (wrappedData is Map<String, dynamic>) {
            return [User.fromJson(wrappedData)];
          } else {
            throw ApiException(
              ApiErrorResponse(
                success: false,
                error: ApiError(
                  code: 'INVALID_RESPONSE_FORMAT',
                  message: 'Invalid data format in wrapped response',
                  details: [],
                ),
                timestamp: DateTime.now().toIso8601String(),
                path: response.requestOptions.path,
              ),
            );
          }
        } else {
          throw ApiException(
            ApiErrorResponse(
              success: false,
              error: ApiError(
                code: 'INVALID_RESPONSE_FORMAT',
                message: 'Unexpected response format: ${data.runtimeType}',
                details: [],
              ),
              timestamp: DateTime.now().toIso8601String(),
              path: response.requestOptions.path,
            ),
          );
        }
      } else {
        throw _handleApiError(response);
      }
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  @override
  Future<User> getUserById(String id) async {
    try {
      final response = await _dio.get('/users/$id');
      
      if (response.statusCode == 200) {
        final data = response.data;
        
        if (data is Map<String, dynamic> && data['data'] != null) {
          // Wrapped response format
          final userData = data['data'];
          if (userData is Map<String, dynamic>) {
            return User.fromJson(userData);
          } else {
            throw ApiException(
              ApiErrorResponse(
                success: false,
                error: ApiError(
                  code: 'USER_NOT_FOUND',
                  message: 'User not found or invalid response format',
                  details: [],
                ),
                timestamp: DateTime.now().toIso8601String(),
                path: response.requestOptions.path,
              ),
            );
          }
        } else if (data is Map<String, dynamic>) {
          // Direct user object response
          return User.fromJson(data);
        } else {
          throw ApiException(
            ApiErrorResponse(
              success: false,
              error: ApiError(
                code: 'USER_NOT_FOUND',
                message: 'User not found or invalid response format',
                details: [],
              ),
              timestamp: DateTime.now().toIso8601String(),
              path: response.requestOptions.path,
            ),
          );
        }
      } else {
        throw _handleApiError(response);
      }
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  @override
  Future<User> createUser(User user) async {
    try {
      final response = await _dio.post(
        '/users',
        data: {
          'data': {
            'name': user.name,
            'email': user.email,
            'password': user.password,
            'role_id': user.roleId,
            'is_active': user.isActive,
          }
        },
      );
      
      if (response.statusCode == 201 || response.statusCode == 200) {
        final data = response.data;
        
        if (data is Map<String, dynamic> && data['data'] != null) {
          // Wrapped response format (backward compatibility)
          final userData = data['data'];
          if (userData is Map<String, dynamic>) {
            return User.fromJson(userData);
          } else {
            throw ApiException(
              ApiErrorResponse(
                success: false,
                error: ApiError(
                  code: 'INVALID_RESPONSE_FORMAT',
                  message: 'Invalid user data format in response',
                  details: [],
                ),
                timestamp: DateTime.now().toIso8601String(),
                path: response.requestOptions.path,
              ),
            );
          }
        } else if (data is Map<String, dynamic>) {
          // Direct user object response
          return User.fromJson(data);
        } else {
          throw ApiException(
            ApiErrorResponse(
              success: false,
              error: ApiError(
                code: 'INVALID_RESPONSE_FORMAT',
                message: 'Unexpected response format: ${data.runtimeType}',
                details: [],
              ),
              timestamp: DateTime.now().toIso8601String(),
              path: response.requestOptions.path,
            ),
          );
        }
      } else {
        throw _handleApiError(response);
      }
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  @override
  Future<User> updateUser(String id, User user) async {
    try {
      final response = await _dio.patch(
        '/users/$id',
        data: {
          'data': {
            'name': user.name,
            'email': user.email,
            'role_id': user.roleId,
            'is_active': user.isActive,
          }
        },
      );
      
      if (response.statusCode == 200) {
        final data = response.data;
        
        if (data is Map<String, dynamic> && data['data'] != null) {
          // Wrapped response format (backward compatibility)
          final userData = data['data'];
          if (userData is Map<String, dynamic>) {
            return User.fromJson(userData);
          } else {
            throw ApiException(
              ApiErrorResponse(
                success: false,
                error: ApiError(
                  code: 'INVALID_RESPONSE_FORMAT',
                  message: 'Invalid user data format in response',
                  details: [],
                ),
                timestamp: DateTime.now().toIso8601String(),
                path: response.requestOptions.path,
              ),
            );
          }
        } else if (data is Map<String, dynamic>) {
          // Direct user object response
          return User.fromJson(data);
        } else {
          throw ApiException(
            ApiErrorResponse(
              success: false,
              error: ApiError(
                code: 'INVALID_RESPONSE_FORMAT',
                message: 'Unexpected response format: ${data.runtimeType}',
                details: [],
              ),
              timestamp: DateTime.now().toIso8601String(),
              path: response.requestOptions.path,
            ),
          );
        }
      } else {
        throw _handleApiError(response);
      }
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  @override
  Future<void> deleteUser(String id) async {
    try {
      final response = await _dio.delete('/users/$id');
      
      if (response.statusCode == 200 || response.statusCode == 204) {
        return;
      } else {
        throw _handleApiError(response);
      }
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  ApiException _handleApiError(Response response) {
    try {
      final apiErrorResponse = ApiErrorResponse.fromJson(response.data);
      return ApiException(apiErrorResponse);
    } catch (e) {
      return ApiException(
        ApiErrorResponse(
          success: false,
          error: ApiError(
            code: 'UNKNOWN_ERROR',
            message: 'An unknown error occurred',
            details: [],
          ),
          timestamp: DateTime.now().toIso8601String(),
          path: response.requestOptions.path,
        ),
      );
    }
  }

  ApiException _handleDioError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
        return ApiException(
          ApiErrorResponse(
            success: false,
            error: ApiError(
              code: 'CONNECTION_TIMEOUT',
              message: 'Connection timeout. Please check your internet connection.',
              details: [],
            ),
            timestamp: DateTime.now().toIso8601String(),
            path: error.requestOptions.path,
          ),
        );
      case DioExceptionType.receiveTimeout:
        return ApiException(
          ApiErrorResponse(
            success: false,
            error: ApiError(
              code: 'RECEIVE_TIMEOUT',
              message: 'Server timeout. Please try again.',
              details: [],
            ),
            timestamp: DateTime.now().toIso8601String(),
            path: error.requestOptions.path,
          ),
        );
      case DioExceptionType.cancel:
        return ApiException(
          ApiErrorResponse(
            success: false,
            error: ApiError(
              code: 'REQUEST_CANCELLED',
              message: 'Request was cancelled.',
              details: [],
            ),
            timestamp: DateTime.now().toIso8601String(),
            path: error.requestOptions.path,
          ),
        );
      case DioExceptionType.connectionError:
        return ApiException(
          ApiErrorResponse(
            success: false,
            error: ApiError(
              code: 'CONNECTION_ERROR',
              message: 'No internet connection. Please check your network.',
              details: [],
            ),
            timestamp: DateTime.now().toIso8601String(),
            path: error.requestOptions.path,
          ),
        );
      default:
        return ApiException(
          ApiErrorResponse(
            success: false,
            error: ApiError(
              code: 'NETWORK_ERROR',
              message: 'Network error occurred. Please try again.',
              details: [],
            ),
            timestamp: DateTime.now().toIso8601String(),
            path: error.requestOptions.path,
          ),
        );
    }
  }
}
