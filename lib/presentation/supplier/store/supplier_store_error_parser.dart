import 'package:dio/dio.dart';

String parseSupplierStoreError(dynamic error) {
  if (error is DioException) {
    final data = error.response?.data;
    if (data is Map<String, dynamic>) {
      final message = data['message'];
      if (message is String) return message;
      if (message is List) return message.join(', ');
      final errorObj = data['error'];
      if (errorObj is Map<String, dynamic>) {
        final nestedMessage = errorObj['message'];
        if (nestedMessage is String) return nestedMessage;
        if (nestedMessage is List) return nestedMessage.join(', ');
      }
    }
    if (data is String && data.isNotEmpty) return data;
    switch (error.response?.statusCode) {
      case 400:
        return 'Invalid request. Please check your input.';
      case 401:
        return 'Session expired. Please log in again.';
      case 403:
        return 'You do not have permission to perform this action.';
      case 404:
        return 'Supplier not found.';
      case 409:
        return 'Cannot complete this action due to a conflict.';
      default:
        return 'An unexpected error occurred. Please try again.';
    }
  }
  return error.toString();
}
