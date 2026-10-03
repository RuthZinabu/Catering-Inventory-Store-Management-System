/// Custom exceptions for API errors
class ApiException implements Exception {
  final String message;
  final int? statusCode;
  final String? errorCode;
  final Map<String, dynamic>? errors;

  const ApiException({
    required this.message,
    this.statusCode,
    this.errorCode,
    this.errors,
  });

  @override
  String toString() {
    return 'ApiException: $message (Status: $statusCode, Code: $errorCode)';
  }
}

/// Network connectivity exception
class NetworkException extends ApiException {
  const NetworkException({String? message})
      : super(message: message ?? 'No internet connection');
}

/// Authentication/Authorization exceptions
class AuthenticationException extends ApiException {
  const AuthenticationException({String? message})
      : super(
          message: message ?? 'Authentication failed',
          statusCode: 401,
        );
}

class AuthorizationException extends ApiException {
  const AuthorizationException({String? message})
      : super(
          message: message ?? 'Access denied',
          statusCode: 403,
        );
}

/// Validation exception for 422 errors
class ValidationException extends ApiException {
  const ValidationException({
    String? message,
    Map<String, dynamic>? errors,
  }) : super(
          message: message ?? 'Validation failed',
          statusCode: 422,
          errors: errors,
        );

  /// Get field-specific error messages
  List<String> getFieldErrors(String field) {
    if (errors == null || !errors!.containsKey(field)) return [];
    
    final fieldErrors = errors![field];
    if (fieldErrors is List) {
      return fieldErrors.map((e) => e.toString()).toList();
    }
    return [fieldErrors.toString()];
  }
  
  /// Get all error messages as a flat list
  List<String> get allErrors {
    if (errors == null) return [message];
    
    final List<String> allErrorMessages = [];
    errors!.forEach((key, value) {
      if (value is List) {
        allErrorMessages.addAll(value.map((e) => e.toString()));
      } else {
        allErrorMessages.add(value.toString());
      }
    });
    
    return allErrorMessages.isEmpty ? [message] : allErrorMessages;
  }
}

/// Server error exception
class ServerException extends ApiException {
  const ServerException({String? message})
      : super(
          message: message ?? 'Server error occurred',
          statusCode: 500,
        );
}

/// Rate limit exception
class RateLimitException extends ApiException {
  const RateLimitException({String? message})
      : super(
          message: message ?? 'Too many requests. Please try again later.',
          statusCode: 429,
        );
}

/// Resource not found exception
class NotFoundException extends ApiException {
  const NotFoundException({String? message})
      : super(
          message: message ?? 'Resource not found',
          statusCode: 404,
        );
}

/// Timeout exception
class TimeoutException extends ApiException {
  const TimeoutException({String? message})
      : super(message: message ?? 'Request timeout');
}