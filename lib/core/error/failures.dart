import 'package:equatable/equatable.dart';

/// نموذج فشل محايد عن التقنية (لا يعرف Dio أو Hive).
/// تستخدمه طبقات الـ domain / presentation للتعامل مع الأخطاء.
sealed class Failure extends Equatable {
  const Failure(this.message, {this.code});

  final String message;
  final String? code;

  @override
  List<Object?> get props => [message, code];
}

class NetworkFailure extends Failure {
  const NetworkFailure(super.message) : super(code: 'network');
}

class AuthFailure extends Failure {
  const AuthFailure(super.message) : super(code: 'auth');
}

class ValidationFailure extends Failure {
  const ValidationFailure(super.message, {this.fieldErrors})
      : super(code: 'validation');

  final Map<String, List<String>>? fieldErrors;

  @override
  List<Object?> get props => [message, code, fieldErrors];
}

class ServerFailure extends Failure {
  const ServerFailure(super.message) : super(code: 'server');
}

class CacheFailure extends Failure {
  const CacheFailure(super.message) : super(code: 'cache');
}

class UnknownFailure extends Failure {
  const UnknownFailure(super.message) : super(code: 'unknown');
}
