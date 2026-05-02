class ApiErrorResponse {
  final bool success;
  final ApiError error;
  final String timestamp;
  final String path;

  const ApiErrorResponse({
    required this.success,
    required this.error,
    required this.timestamp,
    required this.path,
  });

  factory ApiErrorResponse.fromJson(Map<String, dynamic> json) {
    return ApiErrorResponse(
      success: json['success'] ?? false,
      error: ApiError.fromJson(json['error'] ?? {}),
      timestamp: json['timestamp'] ?? '',
      path: json['path'] ?? '',
    );
  }
}

class ApiError {
  final String code;
  final String message;
  final List<String> details;

  const ApiError({
    required this.code,
    required this.message,
    required this.details,
  });

  factory ApiError.fromJson(Map<String, dynamic> json) {
    return ApiError(
      code: json['code'] ?? 'UNKNOWN_ERROR',
      message: json['message'] ?? 'An unknown error occurred',
      details: List<String>.from(json['details'] ?? []),
    );
  }
}

class ApiException implements Exception {
  final ApiErrorResponse errorResponse;
  final String userFriendlyMessage;

  ApiException(this.errorResponse) : userFriendlyMessage = _getUserFriendlyMessage(errorResponse);

  static String _getUserFriendlyMessage(ApiErrorResponse error) {
    switch (error.error.code) {
      case 'INTERNAL_SERVER_ERROR':
        return 'Server error occurred. Please try again later.';
      case 'NOT_FOUND':
        return 'The requested resource was not found.';
      case 'UNAUTHORIZED':
        return 'You are not authorized to perform this action.';
      case 'FORBIDDEN':
        return 'You do not have permission to perform this action.';
      case 'VALIDATION_ERROR':
        return error.error.details.isNotEmpty 
            ? error.error.details.first 
            : error.error.message;
      case 'TENANT_NOT_FOUND':
        return 'Tenant not found. Please check your tenant configuration.';
      case 'ROLE_NOT_FOUND':
        return 'Role not found.';
      case 'ROLE_ALREADY_EXISTS':
        return 'A role with this name already exists.';
      case 'USER_NOT_FOUND':
        return 'User not found.';
      case 'USER_ALREADY_HAS_ROLE':
        return 'User already has this role assigned.';
      default:
        return error.error.message;
    }
  }

  @override
  String toString() => userFriendlyMessage;
}
