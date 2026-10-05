import 'dart:async' as async;
import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../config/app_config.dart';
import 'api/api_response_cache.dart';

class ApiException implements Exception {
  final String message;

  const ApiException(this.message);

  @override
  String toString() => message;
}

class ApiClient {
  ApiClient._();

  static final ApiClient instance = ApiClient._();
  static const String _baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://localhost:8000/api',
  );
  static const String _legacyTokenKey = 'api_access_token';
  static const String _storeKey = 'purchase_store_id';
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  final ApiResponseCache<String> _getCache = ApiResponseCache<String>(
    validDuration: AppConfig.cacheValidDuration,
  );

  String? _token;
  String? storeId;

  bool get isAuthenticated => _token != null && _token!.isNotEmpty;

  Future<void> restoreSession() async {
    final preferences = await SharedPreferences.getInstance();
    _token = await _secureStorage.read(key: AppConfig.tokenKey);
    final legacyToken = preferences.getString(_legacyTokenKey);
    if (_token == null && legacyToken != null) {
      _token = legacyToken;
      await _secureStorage.write(key: AppConfig.tokenKey, value: legacyToken);
    }
    if (legacyToken != null) {
      await preferences.remove(_legacyTokenKey);
    }
    storeId = preferences.getString(_storeKey);
  }

  Future<void> selectStore(String value) async {
    final preferences = await SharedPreferences.getInstance();
    if (storeId != value) _getCache.clear();
    await preferences.setString(_storeKey, value);
    storeId = value;
  }

  /// Keep the legacy HTTP client aligned with the app's shared auth session.
  Future<void> synchronizeAuthToken(
    String? token, {
    bool resetStore = false,
  }) async {
    final tokenChanged = _token != token;
    if (tokenChanged) _getCache.clear();
    _token = token;
    if (tokenChanged && resetStore) {
      storeId = null;
      final preferences = await SharedPreferences.getInstance();
      await preferences.remove(_storeKey);
    }
  }

  /// Clear legacy in-memory and preference state after app-wide logout.
  Future<void> clearLocalSession() async {
    _token = null;
    storeId = null;
    _getCache.clear();
    final preferences = await SharedPreferences.getInstance();
    await preferences.remove(_legacyTokenKey);
    await preferences.remove(_storeKey);
  }

  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    final response = await _send(
      'POST',
      '/auth/login',
      body: {
        'email': email,
        'password': password,
        'device_name': 'Catering Inventory Flutter App',
      },
      authenticated: false,
    );
    final data = Map<String, dynamic>.from(response['data'] as Map);
    final newToken = data['access_token'] as String?;
    if (_token != newToken) _getCache.clear();
    _token = newToken;
    if (_token == null || _token!.isEmpty) {
      _token = null;
      await _secureStorage.delete(key: AppConfig.tokenKey);
      throw const ApiException('The server did not return an access token.');
    }

    final user = Map<String, dynamic>.from(data['user'] as Map);
    var stores = List<Map<String, dynamic>>.from(
      (user['assigned_stores'] as List? ?? const []).map(
        (store) => Map<String, dynamic>.from(store as Map),
      ),
    );
    if (stores.isEmpty) {
      final storeData = await _send('GET', '/stores?active=true');
      stores = List<Map<String, dynamic>>.from(
        ((storeData['data'] as Map)['stores'] as List? ?? const []).map(
          (store) => Map<String, dynamic>.from(store as Map),
        ),
      );
    }
    if (stores.isEmpty) {
      _token = null;
      await clearLocalSession();
      await _secureStorage.delete(key: AppConfig.tokenKey);
      throw const ApiException('Your account has no accessible stores.');
    }

    final preferences = await SharedPreferences.getInstance();
    await _secureStorage.write(key: AppConfig.tokenKey, value: _token!);
    await preferences.remove(_legacyTokenKey);
    final selectedStoreId =
        stores.first['store_id'] as String? ?? stores.first['id'] as String;
    if (storeId != selectedStoreId) _getCache.clear();
    await preferences.setString(_storeKey, selectedStoreId);
    storeId = selectedStoreId;
    return {'user': user, 'stores': stores};
  }

  Future<void> logout() async {
    try {
      if (isAuthenticated) {
        await _send('POST', '/auth/logout');
      }
    } catch (_) {
      // Continue clearing local credentials even if the server is unreachable.
    } finally {
      _token = null;
      _getCache.clear();
      await _secureStorage.delete(key: AppConfig.tokenKey);
      await _secureStorage.delete(key: AppConfig.refreshTokenKey);
      final preferences = await SharedPreferences.getInstance();
      await preferences.remove(_legacyTokenKey);
      await preferences.remove(_storeKey);
      storeId = null;
    }
  }

  Future<Map<String, dynamic>> get(String path) => _send('GET', path);

  Future<Map<String, dynamic>> post(String path, Map<String, dynamic> body) =>
      _send('POST', path, body: body);

  Future<Map<String, dynamic>> put(String path, Map<String, dynamic> body) =>
      _send('PUT', path, body: body);

  Future<void> delete(String path) async {
    await _send('DELETE', path);
  }

  Future<Map<String, dynamic>> uploadFile(String path, List<int> bytes, String filename) async {
    _getCache.clear();
    final request = http.MultipartRequest('POST', Uri.parse('$_baseUrl$path'));
    request.headers['Accept'] = 'application/json';
    if (isAuthenticated) request.headers['Authorization'] = 'Bearer $_token';
    request.files.add(http.MultipartFile.fromBytes('logo', bytes, filename: filename));
    late final http.Response response;
    try {
      final streamedResponse =
          await request.send().timeout(AppConfig.requestTimeout);
      response = await http.Response.fromStream(streamedResponse)
          .timeout(AppConfig.requestTimeout);
    } on async.TimeoutException {
      throw const ApiException(AppConfig.requestTimeoutMessage);
    } catch (_) {
      throw const ApiException(
        'Could not reach the server. Check your connection and try again.',
      );
    }
    if (response.statusCode == 408 || response.statusCode == 504) {
      throw const ApiException(AppConfig.requestTimeoutMessage);
    }
    Map<String, dynamic> payload;
    try {
      payload = Map<String, dynamic>.from(jsonDecode(response.body) as Map);
    } catch (_) {
      throw ApiException('The server returned an invalid response (${response.statusCode}).');
    }
    if (response.statusCode < 200 || response.statusCode >= 300 || payload['success'] == false) {
      throw ApiException(payload['message'] as String? ?? 'File upload failed (${response.statusCode}).');
    }
    return payload;
  }

  Future<Map<String, dynamic>> _send(
    String method,
    String path, {
    Map<String, dynamic>? body,
    bool authenticated = true,
  }) async {
    if (authenticated && !isAuthenticated) {
      await restoreSession();
    }

    final uri = Uri.parse('$_baseUrl$path');
    final cacheKey = uri.toString();
    final cacheable = method == 'GET' && authenticated && !_isCacheablePath(path);
    if (cacheable) {
      final cachedBody = _getCache.get(cacheKey);
      if (cachedBody != null) {
        try {
          return Map<String, dynamic>.from(jsonDecode(cachedBody) as Map);
        } catch (_) {
          _getCache.remove(cacheKey);
        }
      }
    }
    if (method != 'GET') _getCache.clear();

    final headers = <String, String>{'Accept': 'application/json'};
    if (body != null) headers['Content-Type'] = 'application/json';
    if (authenticated && isAuthenticated) {
      headers['Authorization'] = 'Bearer $_token';
    }

    late final http.Response response;
    try {
      switch (method) {
        case 'GET':
          response = await http
              .get(uri, headers: headers)
              .timeout(AppConfig.requestTimeout);
          break;
        case 'POST':
          response = await http
              .post(uri, headers: headers, body: jsonEncode(body))
              .timeout(AppConfig.requestTimeout);
          break;
        case 'PUT':
          response = await http
              .put(uri, headers: headers, body: jsonEncode(body))
              .timeout(AppConfig.requestTimeout);
          break;
        case 'DELETE':
          response = await http
              .delete(uri, headers: headers)
              .timeout(AppConfig.requestTimeout);
          break;
        default:
          throw const ApiException('Unsupported API request.');
      }
    } on async.TimeoutException {
      throw const ApiException(AppConfig.requestTimeoutMessage);
    } catch (error) {
      if (error is ApiException) rethrow;
      throw const ApiException(
        'Could not reach the server. Check your connection and try again.',
      );
    }

    if (response.statusCode == 408 || response.statusCode == 504) {
      throw const ApiException(AppConfig.requestTimeoutMessage);
    }

    Map<String, dynamic> payload;
    try {
      payload = Map<String, dynamic>.from(jsonDecode(response.body) as Map);
    } catch (_) {
      throw ApiException('The server returned an invalid response (${response.statusCode}).');
    }
    if (response.statusCode < 200 || response.statusCode >= 300 || payload['success'] == false) {
      final errors = payload['errors'];
      final detail = errors is Map
          ? errors.values.expand((value) => value is List ? value : [value]).join('\n')
          : null;
      throw ApiException((detail == null || detail.isEmpty)
          ? (payload['message'] as String? ?? 'Request failed (${response.statusCode}).')
          : detail);
    }

    if (cacheable) {
      try {
        _getCache.put(cacheKey, jsonEncode(payload));
      } on Object {
        // Only JSON responses can be cached; successful requests still return normally.
      }
    }
    return payload;
  }

  bool _isCacheablePath(String path) =>
      path.toLowerCase().contains('/auth/') ||
      path.toLowerCase().contains('/users');
}
