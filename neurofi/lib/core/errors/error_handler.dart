import 'package:dio/dio.dart';
import 'app_exceptions.dart';

class ErrorHandler {
  static AppException handle(dynamic error) {
    if (error is DioException) {
      return _handleDioError(error);
    }
    if (error is AppException) {
      return error;
    }
    return AppException(error.toString());
  }

  static AppException _handleDioError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return TimeoutException();

      case DioExceptionType.connectionError:
        return NetworkException();

      case DioExceptionType.badResponse:
        return _handleStatusCode(error.response?.statusCode, error.response?.data);

      default:
        return AppException('An unexpected error occurred.');
    }
  }

  static AppException _handleStatusCode(int? statusCode, dynamic data) {
    final message = _extractMessage(data);

    switch (statusCode) {
      case 400:
        return ValidationException(message ?? 'Invalid request. Please check your input.');
      case 401:
        return AppException(
          message ?? 'Invalid credentials. Please check your email and password.',
          statusCode: 401,
        );
      case 403:
        return AppException('You do not have permission to perform this action.', statusCode: 403);
      case 404:
        return AppException(message ?? 'Resource not found.', statusCode: 404);
      case 409:
        return AppException(message ?? 'Conflict. Resource already exists.', statusCode: 409);
      case 422:
        return ValidationException(message ?? 'Validation failed.');
      case 500:
      case 502:
      case 503:
        return ServerException();
      default:
        return AppException(message ?? 'Something went wrong.', statusCode: statusCode);
    }
  }

  static String? _extractMessage(dynamic data) {
    if (data == null) return null;
    if (data is Map) {
      return data['message']?.toString() ?? data['error']?.toString();
    }
    return data.toString();
  }

  static String toUserMessage(dynamic error) {
    final exception = handle(error);
    return exception.message;
  }
}
