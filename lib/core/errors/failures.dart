import 'package:equatable/equatable.dart';

/// Base Failure class
/// Represents failures in the application (from exceptions or business logic)
abstract class Failure extends Equatable {
  final String message;
  final String? code;
  
  const Failure(this.message, {this.code});
  
  @override
  List<Object?> get props => [message, code];
  
  @override
  String toString() => 'Failure: $message ${code != null ? '(Code: $code)' : ''}';
}

/// Server Failure - kesalahan dari server
class ServerFailure extends Failure {
  const ServerFailure(String message, {String? code}) 
      : super(message, code: code);
  
  @override
  String toString() => 'ServerFailure: $message ${code != null ? '(Code: $code)' : ''}';
}

/// Cache Failure - kesalahan dari local cache
class CacheFailure extends Failure {
  const CacheFailure(String message, {String? code}) 
      : super(message, code: code);
  
  @override
  String toString() => 'CacheFailure: $message ${code != null ? '(Code: $code)' : ''}';
}

/// Network Failure - kesalahan jaringan
class NetworkFailure extends Failure {
  const NetworkFailure(String message, {String? code}) 
      : super(message, code: code);
  
  @override
  String toString() => 'NetworkFailure: $message ${code != null ? '(Code: $code)' : ''}';
}

/// Authentication Failure - kesalahan autentikasi
class AuthenticationFailure extends Failure {
  const AuthenticationFailure(String message, {String? code}) 
      : super(message, code: code);
  
  @override
  String toString() => 'AuthenticationFailure: $message ${code != null ? '(Code: $code)' : ''}';
}

/// Authorization Failure - kesalahan autorisasi
class AuthorizationFailure extends Failure {
  const AuthorizationFailure(String message, {String? code}) 
      : super(message, code: code);
  
  @override
  String toString() => 'AuthorizationFailure: $message ${code != null ? '(Code: $code)' : ''}';
}

/// Validation Failure - kesalahan validasi
class ValidationFailure extends Failure {
  const ValidationFailure(String message, {String? code}) 
      : super(message, code: code);
  
  @override
  String toString() => 'ValidationFailure: $message ${code != null ? '(Code: $code)' : ''}';
}

/// Not Found Failure - resource tidak ditemukan
class NotFoundFailure extends Failure {
  const NotFoundFailure(String message, {String? code}) 
      : super(message, code: code);
  
  @override
  String toString() => 'NotFoundFailure: $message ${code != null ? '(Code: $code)' : ''}';
}

/// Timeout Failure - operasi timeout
class TimeoutFailure extends Failure {
  const TimeoutFailure(String message, {String? code}) 
      : super(message, code: code);
  
  @override
  String toString() => 'TimeoutFailure: $message ${code != null ? '(Code: $code)' : ''}';
}

/// Parse Failure - kesalahan parsing data
class ParseFailure extends Failure {
  const ParseFailure(String message, {String? code}) 
      : super(message, code: code);
  
  @override
  String toString() => 'ParseFailure: $message ${code != null ? '(Code: $code)' : ''}';
}

/// Storage Failure - kesalahan storage
class StorageFailure extends Failure {
  const StorageFailure(String message, {String? code}) 
      : super(message, code: code);
  
  @override
  String toString() => 'StorageFailure: $message ${code != null ? '(Code: $code)' : ''}';
}

/// Permission Failure - kesalahan permission
class PermissionFailure extends Failure {
  const PermissionFailure(String message, {String? code}) 
      : super(message, code: code);
  
  @override
  String toString() => 'PermissionFailure: $message ${code != null ? '(Code: $code)' : ''}';
}

/// Upload Failure - kesalahan upload
class UploadFailure extends Failure {
  const UploadFailure(String message, {String? code}) 
      : super(message, code: code);
  
  @override
  String toString() => 'UploadFailure: $message ${code != null ? '(Code: $code)' : ''}';
}

/// Download Failure - kesalahan download
class DownloadFailure extends Failure {
  const DownloadFailure(String message, {String? code}) 
      : super(message, code: code);
  
  @override
  String toString() => 'DownloadFailure: $message ${code != null ? '(Code: $code)' : ''}';
}

/// Sync Failure - kesalahan sinkronisasi
class SyncFailure extends Failure {
  const SyncFailure(String message, {String? code}) 
      : super(message, code: code);
  
  @override
  String toString() => 'SyncFailure: $message ${code != null ? '(Code: $code)' : ''}';
}

/// Conflict Failure - data conflict
class ConflictFailure extends Failure {
  const ConflictFailure(String message, {String? code}) 
      : super(message, code: code);
  
  @override
  String toString() => 'ConflictFailure: $message ${code != null ? '(Code: $code)' : ''}';
}

/// Rate Limit Failure - rate limiting
class RateLimitFailure extends Failure {
  const RateLimitFailure(String message, {String? code}) 
      : super(message, code: code);
  
  @override
  String toString() => 'RateLimitFailure: $message ${code != null ? '(Code: $code)' : ''}';
}

/// Unsupported Failure - operasi tidak didukung
class UnsupportedFailure extends Failure {
  const UnsupportedFailure(String message, {String? code}) 
      : super(message, code: code);
  
  @override
  String toString() => 'UnsupportedFailure: $message ${code != null ? '(Code: $code)' : ''}';
}

/// Platform Specific Failure - platform-specific error
class PlatformSpecificFailure extends Failure {
  const PlatformSpecificFailure(String message, {String? code}) 
      : super(message, code: code);
  
  @override
  String toString() => 'PlatformSpecificFailure: $message ${code != null ? '(Code: $code)' : ''}';
}

/// Unknown Failure - kesalahan tidak diketahui
class UnknownFailure extends Failure {
  const UnknownFailure(String message, {String? code}) 
      : super(message, code: code);
  
  @override
  String toString() => 'UnknownFailure: $message ${code != null ? '(Code: $code)' : ''}';
}

/// Helper to convert exceptions to failures
class FailureConverter {
  /// Convert exception to appropriate failure
  static Failure fromException(Exception exception) {
    // Import exceptions.dart types here
    final exceptionString = exception.toString();
    
    if (exceptionString.contains('ServerException')) {
      return ServerFailure(exception.toString());
    } else if (exceptionString.contains('CacheException')) {
      return CacheFailure(exception.toString());
    } else if (exceptionString.contains('NetworkException')) {
      return NetworkFailure(exception.toString());
    } else if (exceptionString.contains('AuthenticationException')) {
      return AuthenticationFailure(exception.toString());
    } else if (exceptionString.contains('AuthorizationException')) {
      return AuthorizationFailure(exception.toString());
    } else if (exceptionString.contains('ValidationException')) {
      return ValidationFailure(exception.toString());
    } else if (exceptionString.contains('NotFoundException')) {
      return NotFoundFailure(exception.toString());
    } else if (exceptionString.contains('TimeoutException')) {
      return TimeoutFailure(exception.toString());
    } else if (exceptionString.contains('ParseException')) {
      return ParseFailure(exception.toString());
    } else if (exceptionString.contains('StorageException')) {
      return StorageFailure(exception.toString());
    } else if (exceptionString.contains('PermissionException')) {
      return PermissionFailure(exception.toString());
    } else if (exceptionString.contains('UploadException')) {
      return UploadFailure(exception.toString());
    } else if (exceptionString.contains('DownloadException')) {
      return DownloadFailure(exception.toString());
    } else if (exceptionString.contains('SyncException')) {
      return SyncFailure(exception.toString());
    } else if (exceptionString.contains('ConflictException')) {
      return ConflictFailure(exception.toString());
    } else {
      return UnknownFailure(exception.toString());
    }
  }
  
  /// Get user-friendly error message
  static String getUserMessage(Failure failure) {
    if (failure is NetworkFailure) {
      return 'Tidak ada koneksi internet. Silakan cek koneksi Anda.';
    } else if (failure is ServerFailure) {
      return 'Terjadi kesalahan pada server. Silakan coba lagi nanti.';
    } else if (failure is AuthenticationFailure) {
      return 'Gagal masuk. Silakan coba lagi.';
    } else if (failure is ValidationFailure) {
      return failure.message;
    } else if (failure is NotFoundFailure) {
      return 'Data tidak ditemukan.';
    } else if (failure is PermissionFailure) {
      return 'Izin ditolak. Silakan periksa pengaturan izin aplikasi.';
    } else if (failure is StorageFailure || failure is CacheFailure) {
      return 'Gagal menyimpan data. Silakan coba lagi.';
    } else if (failure is UploadFailure) {
      return 'Gagal mengunggah file. Silakan coba lagi.';
    } else if (failure is SyncFailure) {
      return 'Gagal menyinkronkan data. Akan dicoba lagi nanti.';
    } else if (failure is TimeoutFailure) {
      return 'Permintaan timeout. Silakan coba lagi.';
    }
    
    return 'Terjadi kesalahan. Silakan coba lagi.';
  }
}