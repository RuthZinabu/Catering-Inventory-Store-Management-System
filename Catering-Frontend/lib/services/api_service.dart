import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../config/app_config.dart';

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
  static const String _tokenKey = 'api_access_token';
  static const String _storeKey = 'purchase_store_id';

  String? _token;
  String? storeId;

  bool get isAuthenticated => _token != null && _token!.isNotEmpty;

  Future<void> restoreSession() async {
    final preferences = await SharedPreferences.getInstance();
    _token = await const FlutterSecureStorage().read(key: AppConfig.tokenKey) ??
        preferences.getString(_tokenKey);
    storeId = preferences.getString(_storeKey);
  }

  Future<void> selectStore(String value) async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.setString(_storeKey, value);
    storeId = value;
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
    _token = data['access_token'] as String?;
    if (_token == null || _token!.isEmpty) {
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
      throw const ApiException('Your account has no accessible stores.');
    }

    final preferences = await SharedPreferences.getInstance();
    await preferences.setString(_tokenKey, _token!);
    await preferences.setString(_storeKey, stores.first['store_id'] as String? ?? stores.first['id'] as String);
    storeId = stores.first['store_id'] as String? ?? stores.first['id'] as String;
    return {'user': user, 'stores': stores};
  }

  Future<void> logout() async {
    if (isAuthenticated) {
      try {
        await _send('POST', '/auth/logout');
      } finally {
        _token = null;
      }
    }
    final preferences = await SharedPreferences.getInstance();
    await preferences.remove(_tokenKey);
    await preferences.remove(_storeKey);
    storeId = null;
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
    final request = http.MultipartRequest('POST', Uri.parse('$_baseUrl$path'));
    request.headers['Accept'] = 'application/json';
    if (isAuthenticated) request.headers['Authorization'] = 'Bearer $_token';
    request.files.add(http.MultipartFile.fromBytes('logo', bytes, filename: filename));
    final response = await http.Response.fromStream(await request.send());
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
    final headers = <String, String>{'Accept': 'application/json'};
    if (body != null) headers['Content-Type'] = 'application/json';
    if (authenticated && isAuthenticated) {
      headers['Authorization'] = 'Bearer $_token';
    }

    late final http.Response response;
    try {
      switch (method) {
        case 'GET':
          response = await http.get(uri, headers: headers);
          break;
        case 'POST':
          response = await http.post(uri, headers: headers, body: jsonEncode(body));
          break;
        case 'PUT':
          response = await http.put(uri, headers: headers, body: jsonEncode(body));
          break;
        case 'DELETE':
          response = await http.delete(uri, headers: headers);
          break;
        default:
          throw const ApiException('Unsupported API request.');
      }
    } catch (error) {
      if (error is ApiException) rethrow;
      throw ApiException('Could not connect to the API at $_baseUrl.');
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
    return payload;
  }
}
