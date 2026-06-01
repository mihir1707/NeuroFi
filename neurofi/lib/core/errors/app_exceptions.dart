class AppException implements Exception {
  final String message;
  final int? statusCode;

  AppException(this.message, {this.statusCode});

  @override
  String toString() => message;
}

class NetworkException extends AppException {
  NetworkException() : super('No internet connection. Please check your network.');
}

class UnauthorizedException extends AppException {
  UnauthorizedException() : super('Session expired. Please login again.', statusCode: 401);
}

class NotFoundException extends AppException {
  NotFoundException(String resource) : super('$resource not found.', statusCode: 404);
}

class ValidationException extends AppException {
  ValidationException(String message) : super(message, statusCode: 422);
}

class ServerException extends AppException {
  ServerException() : super('Server error. Please try again later.', statusCode: 500);
}

class TimeoutException extends AppException {
  TimeoutException() : super('Request timed out. Please try again.');
}
