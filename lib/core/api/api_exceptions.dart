/// استثناءات الـ API — تطابق غلاف الـ Backend `{success, data, error}`.
sealed class ApiException implements Exception {
  const ApiException(this.message, {this.statusCode});

  final String message;
  final int? statusCode;

  @override
  String toString() => '$runtimeType($statusCode): $message';
}

class NetworkException extends ApiException {
  const NetworkException(super.message);
}

class TimeoutException extends ApiException {
  const TimeoutException(super.message);
}

class UnauthorizedException extends ApiException {
  const UnauthorizedException(super.message) : super(statusCode: 401);
}

class ForbiddenException extends ApiException {
  const ForbiddenException(super.message) : super(statusCode: 403);
}

class NotFoundException extends ApiException {
  const NotFoundException(super.message) : super(statusCode: 404);
}

class ValidationException extends ApiException {
  const ValidationException(super.message, {this.errors})
      : super(statusCode: 422);

  final Map<String, List<String>>? errors;
}

class RateLimitException extends ApiException {
  const RateLimitException([super.message = 'تم تجاوز عدد المحاولات المسموح بها'])
      : super(statusCode: 429);
}

class ServerException extends ApiException {
  const ServerException(super.message, {super.statusCode});
}

class UnknownApiException extends ApiException {
  const UnknownApiException(super.message, {super.statusCode});
}
