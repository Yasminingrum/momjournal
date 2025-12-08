/// Custom Exceptions
/// Defines custom exception classes for error handling

/// Base exception class
abstract class AppException implements Exception {
  final String message;
  final String? code;
  final dynamic details;
  
  const AppException(this.message, {this.code, this.details});
  
  @override
  String toString() => 'AppException: $message ${code != null ? '(Code: $code)' : ''}';
}

/// Server Exception - untuk error dari server/backend
class ServerException extends AppException {
  const ServerException(
    String message, {
    String? code,
    dynamic details,
  }) : super(message, code: code, details: details);
  
  @override
  String toString() => 'ServerException: $message ${code != null ? '(Code: $code)' : ''}';
}

/// Cache Exception - untuk error dari local storage
class CacheException extends AppException {
  const CacheException(
    String message, {
    String? code,
    dynamic details,
  }) : super(message, code: code, details: details);
  
  @override
  String toString() => 'CacheException: $message ${code != null ? '(Code: $code)' : ''}';
}

/// Network Exception - untuk error jaringan
class NetworkException extends AppException {
  const NetworkException(
    String message, {
    String? code,
    dynamic details,
  }) : super(message, code: code, details: details);
  
  @override
  String toString() => 'NetworkException: $message ${code != null ? '(Code: $code)' : ''}';
}

/// Authentication Exception - untuk error autentikasi
class AuthenticationException extends AppException {
  const AuthenticationException(
    String message, {
    String? code,
    dynamic details,
  }) : super(message, code: code, details: details);
  
  @override
  String toString() => 'AuthenticationException: $message ${code != null ? '(Code: $code)' : ''}';
}

/// Authorization Exception - untuk error autorisasi
class AuthorizationException extends AppException {
  const AuthorizationException(
    String message, {
    String? code,
    dynamic details,
  }) : super(message, code: code, details: details);
  
  @override
  String toString() => 'AuthorizationException: $message ${code != null ? '(Code: $code)' : ''}';
}

/// Validation Exception - untuk error validasi input
class ValidationException extends AppException {
  const ValidationException(
    String message, {
    String? code,
    dynamic details,
  }) : super(message, code: code, details: details);
  
  @override
  String toString() => 'ValidationException: $message ${code != null ? '(Code: $code)' : ''}';
}

/// Not Found Exception - untuk resource yang tidak ditemukan
class NotFoundException extends AppException {
  const NotFoundException(
    String message, {
    String? code,
    dynamic details,
  }) : super(message, code: code, details: details);
  
  @override
  String toString() => 'NotFoundException: $message ${code != null ? '(Code: $code)' : ''}';
}

/// Timeout Exception - untuk timeout operations
class TimeoutException extends AppException {
  const TimeoutException(
    String message, {
    String? code,
    dynamic details,
  }) : super(message, code: code, details: details);
  
  @override
  String toString() => 'TimeoutException: $message ${code != null ? '(Code: $code)' : ''}';
}

/// Parse Exception - untuk error parsing data
class ParseException extends AppException {
  const ParseException(
    String message, {
    String? code,
    dynamic details,
  }) : super(message, code: code, details: details);
  
  @override
  String toString() => 'ParseException: $message ${code != null ? '(Code: $code)' : ''}';
}

/// Storage Exception - untuk error storage (file system, database)
class StorageException extends AppException {
  const StorageException(
    String message, {
    String? code,
    dynamic details,
  }) : super(message, code: code, details: details);
  
  @override
  String toString() => 'StorageException: $message ${code != null ? '(Code: $code)' : ''}';
}

/// Permission Exception - untuk error permissions
class PermissionException extends AppException {
  const PermissionException(
    String message, {
    String? code,
    dynamic details,
  }) : super(message, code: code, details: details);
  
  @override
  String toString() => 'PermissionException: $message ${code != null ? '(Code: $code)' : ''}';
}

/// Upload Exception - untuk error upload file
class UploadException extends AppException {
  const UploadException(
    String message, {
    String? code,
    dynamic details,
  }) : super(message, code: code, details: details);
  
  @override
  String toString() => 'UploadException: $message ${code != null ? '(Code: $code)' : ''}';
}

/// Download Exception - untuk error download file
class DownloadException extends AppException {
  const DownloadException(
    String message, {
    String? code,
    dynamic details,
  }) : super(message, code: code, details: details);
  
  @override
  String toString() => 'DownloadException: $message ${code != null ? '(Code: $code)' : ''}';
}

/// Sync Exception - untuk error sinkronisasi data
class SyncException extends AppException {
  const SyncException(
    String message, {
    String? code,
    dynamic details,
  }) : super(message, code: code, details: details);
  
  @override
  String toString() => 'SyncException: $message ${code != null ? '(Code: $code)' : ''}';
}

/// Conflict Exception - untuk data conflicts (saat sync)
class ConflictException extends AppException {
  const ConflictException(
    String message, {
    String? code,
    dynamic details,
  }) : super(message, code: code, details: details);
  
  @override
  String toString() => 'ConflictException: $message ${code != null ? '(Code: $code)' : ''}';
}

/// Rate Limit Exception - untuk rate limiting
class RateLimitException extends AppException {
  const RateLimitException(
    String message, {
    String? code,
    dynamic details,
  }) : super(message, code: code, details: details);
  
  @override
  String toString() => 'RateLimitException: $message ${code != null ? '(Code: $code)' : ''}';
}

/// Unsupported Exception - untuk operasi yang tidak didukung
class UnsupportedException extends AppException {
  const UnsupportedException(
    String message, {
    String? code,
    dynamic details,
  }) : super(message, code: code, details: details);
  
  @override
  String toString() => 'UnsupportedException: $message ${code != null ? '(Code: $code)' : ''}';
}

/// Platform Exception - untuk error platform-specific
class PlatformSpecificException extends AppException {
  const PlatformSpecificException(
    String message, {
    String? code,
    dynamic details,
  }) : super(message, code: code, details: details);
  
  @override
  String toString() => 'PlatformSpecificException: $message ${code != null ? '(Code: $code)' : ''}';
}