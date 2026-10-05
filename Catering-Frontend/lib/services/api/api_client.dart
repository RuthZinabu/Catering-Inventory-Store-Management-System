import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../config/app_config.dart';
import 'api_exception.dart';
import 'api_response.dart';

class ApiClient {
  static ApiClient? _instance;
  static const int _maxCachedGetResponses = 100;
  late final Dio _dio;
  late final FlutterSecureStorage _secureStorage;
  String? _authToken;
  final Map<String, _CachedGetResponse> _getCache = {};

  ApiClient._internal() {
    _secureStorage = const FlutterSecureStorage();
    _initializeDio();
  }

  static ApiClient get instance {
    _instance ??= ApiClient._internal();
    return _instance!;
  }

  Dio get dio => _dio;

  void _initializeDio() {
    _dio = Dio(
      BaseOptions(
        baseUrl: AppConfig.effectiveApiUrl,
        connectTimeout: AppConfig.connectTimeout,
        receiveTimeout: AppConfig.receiveTimeout,
        sendTimeout: AppConfig.sendTimeout,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    // Add auth interceptor
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: _onRequest,
        onResponse: _onResponse,
        onError: _onError,
      ),
    );
  }

  /// Add authorization header to requests
  Future<void> _onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    // Add auth token if available
    if (_authToken != null) {
      options.headers['Authorization'] = 'Bearer $_authToken';
    }

    // Add device information for auth requests
    if (options.path.contains('/auth/')) {
      options.data ??= <String, dynamic>{};
      if (options.data is Map<String, dynamic>) {
        options.data['device_name'] ??= await _getDeviceName();
      }
    }

    handler.next(options);
  }

  /// Handle successful responses
  Future<void> _onResponse(
    Response response,
    ResponseInterceptorHandler handler,
  ) async {
    handler.next(response);
  }

  /// Handle errors and convert to custom exceptions
  Future<void> _onError(
    DioException error,
    ErrorInterceptorHandler handler,
  ) async {
    ApiException apiException;

    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        apiException = const TimeoutException();
        break;

      case DioExceptionType.badResponse:
        apiException = _handleBadResponse(error);
        break;

      case DioExceptionType.cancel:
        apiException = const ApiException(message: 'Request was cancelled');
        break;

      case DioExceptionType.connectionError:
        if (error.error is SocketException) {
          apiException = const NetworkException();
        } else {
          apiException = ApiException(
            message: 'Connection error: ${error.message}',
          );
        }
        break;

      case DioExceptionType.unknown:
      default:
        apiException = ApiException(
          message: error.message ?? 'Unknown error occurred',
        );
        break;
    }

    // Handle authentication errors with automatic token refresh
    if (apiException is AuthenticationException &&
      !error.requestOptions.path.endsWith('/auth/refresh')) {
      final refreshed = await _tryRefreshToken();
      if (refreshed) {
        // Retry the original request
        try {
          final retryResponse = await _dio.request(
            error.requestOptions.path,
            options: Options(
              method: error.requestOptions.method,
              headers: error.requestOptions.headers,
            ),
            data: error.requestOptions.data,
            queryParameters: error.requestOptions.queryParameters,
          );
          handler.resolve(retryResponse);
          return;
        } catch (e) {
          // If retry fails, proceed with original error
        }
      }
    }

    handler.reject(DioException(
      requestOptions: error.requestOptions,
      error: apiException,
      type: DioExceptionType.unknown,
    ));
  }

  /// Handle bad response errors (4xx, 5xx)
  ApiException _handleBadResponse(DioException error) {
    final response = error.response;
    final statusCode = response?.statusCode ?? 0;
    final responseData = response?.data;

    String message = 'An error occurred';
    Map<String, dynamic>? errors;

    // Extract message and errors from Laravel response format
    if (responseData is Map<String, dynamic>) {
      message = responseData['message'] ?? message;
      errors = responseData['errors'];
    }

    switch (statusCode) {
      case 401:
        return AuthenticationException(message: message);
      case 403:
        return AuthorizationException(message: message);
      case 404:
        return NotFoundException(message: message);
      case 422:
        return ValidationException(message: message, errors: errors);
      case 429:
        return RateLimitException(message: message);
      case >= 500:
        return ServerException(message: message);
      default:
        return ApiException(
          message: message,
          statusCode: statusCode,
          errors: errors,
        );
    }
  }

  /// Set authentication token
  Future<void> setAuthToken(String? token) async {
    if (_authToken != token) {
      _getCache.clear();
    }
    _authToken = token;
    if (token != null) {
      await _secureStorage.write(key: AppConfig.tokenKey, value: token);
    } else {
      await _secureStorage.delete(key: AppConfig.tokenKey);
    }
  }

  /// Get stored authentication token
  Future<String?> getAuthToken() async {
    _authToken ??= await _secureStorage.read(key: AppConfig.tokenKey);
    return _authToken;
  }

  /// Try to refresh the authentication token
  Future<bool> _tryRefreshToken() async {
    try {
      final response = await _dio.post('/auth/refresh');
      final apiResponse = ApiResponse.fromJson(response.data, null);

      if (apiResponse.isSuccess && apiResponse.data != null) {
        final newToken = apiResponse.data['access_token'];
        await setAuthToken(newToken);
        return true;
      }
    } catch (e) {
      // Refresh failed, clear tokens
      await clearTokens();
    }
    return false;
  }

  /// Clear all stored tokens
  Future<void> clearTokens() async {
    _authToken = null;
    _getCache.clear();
    await _secureStorage.delete(key: AppConfig.tokenKey);
    await _secureStorage.delete(key: AppConfig.refreshTokenKey);
    await _secureStorage.delete(key: AppConfig.userKey);
  }

  /// Get device name for authentication
  Future<String> _getDeviceName() async {
    try {
      if (kIsWeb) {
        return 'Web Browser';
      } else if (Platform.isAndroid) {
        return 'Android Device';
      } else if (Platform.isIOS) {
        return 'iOS Device';
      } else if (Platform.isWindows) {
        return 'Windows Device';
      } else if (Platform.isMacOS) {
        return 'macOS Device';
      } else if (Platform.isLinux) {
        return 'Linux Device';
      } else {
        return 'Unknown Device';
      }
    } catch (e) {
      return kIsWeb ? 'Web Browser' : 'Mobile Device';
    }
  }

  /// Check network connectivity
  Future<bool> get isConnected async {
    if (kIsWeb) {
      // For web, we can't check network connectivity directly
      // Just return true and let the API calls handle network errors
      return true;
    }

    try {
      final result = await InternetAddress.lookup('google.com');
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } on SocketException catch (_) {
      return false;
    }
  }

  /// Generic GET request
  Future<ApiResponse<T>> get<T>(
    String endpoint, {
    Map<String, dynamic>? queryParameters,
    T Function(dynamic)? fromJson,
  }) async {
    try {
      final cacheKey = _getCacheKey(endpoint, queryParameters);
      final cacheable = _isCacheableGet(endpoint);
      if (cacheable) {
        final cached = _getCache[cacheKey];
        if (cached != null) {
          if (DateTime.now().difference(cached.fetchedAt) <
              AppConfig.cacheValidDuration) {
            final cachedData =
                jsonDecode(cached.jsonBody) as Map<String, dynamic>;
            return ApiResponse<T>.fromJson(cachedData, fromJson);
          }
          _getCache.remove(cacheKey);
        }
      }

      final response = await _dio.get(
        endpoint,
        queryParameters: queryParameters,
      );
      if (cacheable && response.data is Map) {
        try {
          _getCache[cacheKey] = _CachedGetResponse(
            jsonEncode(response.data),
            DateTime.now(),
          );
          while (_getCache.length > _maxCachedGetResponses) {
            _getCache.remove(_getCache.keys.first);
          }
        } on Object {
          // A non-JSON response should not prevent the API call from succeeding.
        }
      }
      return ApiResponse<T>.fromJson(response.data, fromJson);
    } on DioException catch (e) {
      if (e.error is ApiException) {
        throw e.error as ApiException;
      }
      rethrow;
    }
  }

  /// Generic POST request
  Future<ApiResponse<T>> post<T>(
    String endpoint, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    T Function(dynamic)? fromJson,
  }) async {
    try {
      final response = await _dio.post(
        endpoint,
        data: data,
        queryParameters: queryParameters,
      );
      _getCache.clear();
      return ApiResponse<T>.fromJson(response.data, fromJson);
    } on DioException catch (e) {
      if (e.error is ApiException) {
        throw e.error as ApiException;
      }
      rethrow;
    }
  }

  /// Generic PUT request
  Future<ApiResponse<T>> put<T>(
    String endpoint, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    T Function(dynamic)? fromJson,
  }) async {
    try {
      final response = await _dio.put(
        endpoint,
        data: data,
        queryParameters: queryParameters,
      );
      _getCache.clear();
      return ApiResponse<T>.fromJson(response.data, fromJson);
    } on DioException catch (e) {
      if (e.error is ApiException) {
        throw e.error as ApiException;
      }
      rethrow;
    }
  }

  /// Generic DELETE request
  Future<ApiResponse<T>> delete<T>(
    String endpoint, {
    Map<String, dynamic>? queryParameters,
    T Function(dynamic)? fromJson,
  }) async {
    try {
      final response = await _dio.delete(
        endpoint,
        queryParameters: queryParameters,
      );
      _getCache.clear();
      return ApiResponse<T>.fromJson(response.data, fromJson);
    } on DioException catch (e) {
      if (e.error is ApiException) {
        throw e.error as ApiException;
      }
      rethrow;
    }
  }

  bool _isCacheableGet(String endpoint) {
    final normalized = endpoint.toLowerCase();
    return !normalized.contains('/auth/') && !normalized.contains('/users');
  }

  String _getCacheKey(
    String endpoint,
    Map<String, dynamic>? queryParameters,
  ) {
    final normalizedParameters =
        _normalizeCacheValue(queryParameters ?? const {});
    return '$endpoint|${jsonEncode(normalizedParameters)}';
  }

  dynamic _normalizeCacheValue(dynamic value) {
    if (value is Map) {
      final entries = value.entries.toList()
        ..sort((a, b) => a.key.toString().compareTo(b.key.toString()));
      return {
        for (final entry in entries)
          entry.key.toString(): _normalizeCacheValue(entry.value),
      };
    }
    if (value is Iterable) {
      return value.map(_normalizeCacheValue).toList();
    }
    if (value is DateTime) return value.toIso8601String();
    if (value == null || value is String || value is num || value is bool) {
      return value;
    }
    return value.toString();
  }
}

class _CachedGetResponse {
  final String jsonBody;
  final DateTime fetchedAt;

  const _CachedGetResponse(this.jsonBody, this.fetchedAt);
}
