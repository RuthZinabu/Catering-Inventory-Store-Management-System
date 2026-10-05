import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../config/app_config.dart';
import '../models/auth_models.dart';
import 'api/api_client.dart';
import 'api/api_exception.dart';
import 'api/api_response.dart';
import 'api_service.dart' as legacy_api;

class AuthService extends ChangeNotifier {
  static AuthService? _instance;
  static AuthService get instance {
    _instance ??= AuthService._internal();
    return _instance!;
  }

  AuthService._internal() {
    _init();
  }

  final ApiClient _apiClient = ApiClient.instance;
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  AuthState _state = AuthState.initial;
  AuthUser? _currentUser;
  String? _errorMessage;

  // Getters
  AuthState get state => _state;
  AuthUser? get currentUser => _currentUser;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _state == AuthState.authenticated && _currentUser != null;
  bool get isLoading => _state == AuthState.loading;

  /// Initialize auth service - check for existing token
  Future<void> _init() async {
    try {
      final token = await _apiClient.getAuthToken();
      if (token != null) {
        // Try to get user profile to validate token
        await _loadUserProfile();
      } else {
        _setState(AuthState.unauthenticated);
      }
    } catch (e) {
      _setState(AuthState.unauthenticated);
    }
  }

  /// Login with email and password
  Future<bool> login({
    required String email,
    required String password,
    String? deviceName,
  }) async {
    try {
      _setState(AuthState.loading);
      _errorMessage = null;

      final loginRequest = LoginRequest(
        email: email,
        password: password,
        deviceName: deviceName ?? 'Mobile Device',
      );

      final response = await _apiClient.post<Map<String, dynamic>>(
        '/auth/login',
        data: loginRequest.toJson(),
      );

      if (response.isSuccess && response.data != null) {
        final authResponse = AuthResponse.fromJson(response.data!);
        
        // Store token and user data
        await _apiClient.setAuthToken(authResponse.accessToken);
        await legacy_api.ApiClient.instance.synchronizeAuthToken(
          authResponse.accessToken,
          resetStore: true,
        );
        await _storeUserData(authResponse.user);
        
        _currentUser = authResponse.user;
        _setState(AuthState.authenticated);
        
        return true;
      } else {
        _errorMessage = response.message ?? 'Login failed';
        _setState(AuthState.error);
        return false;
      }
    } on ApiException catch (e) {
      _errorMessage = e.message;
      _setState(AuthState.error);
      return false;
    } catch (e) {
      _errorMessage = 'An unexpected error occurred';
      _setState(AuthState.error);
      return false;
    }
  }

  /// Logout and clear all stored data
  Future<void> logout() async {
    try {
      _setState(AuthState.loading);

      // Call logout endpoint if we have a token
      if (await _apiClient.getAuthToken() != null) {
        try {
          await _apiClient.post('/auth/logout');
        } catch (e) {
          // Ignore logout endpoint errors - continue with local logout
        }
      }

      // Clear all stored data
      await _clearUserData();
      
      _currentUser = null;
      _errorMessage = null;
      _setState(AuthState.unauthenticated);
      
    } catch (e) {
      // Even if logout fails, clear local data
      await _clearUserData();
      _currentUser = null;
      _setState(AuthState.unauthenticated);
    }
  }

  /// Refresh the authentication token
  Future<bool> refreshToken() async {
    try {
      final response = await _apiClient.post<Map<String, dynamic>>(
        '/auth/refresh',
      );

      if (response.isSuccess && response.data != null) {
        final refreshResponse = RefreshTokenResponse.fromJson(response.data!);
        await _apiClient.setAuthToken(refreshResponse.accessToken);
        await legacy_api.ApiClient.instance
            .synchronizeAuthToken(refreshResponse.accessToken);
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  /// Load user profile from API
  Future<void> _loadUserProfile() async {
    try {
      _setState(AuthState.loading);

      final response = await _apiClient.get<Map<String, dynamic>>('/auth/profile');

      if (response.isSuccess && response.data != null) {
        _currentUser = AuthUser.fromJson(response.data!);
        await _storeUserData(_currentUser!);
        _setState(AuthState.authenticated);
      } else {
        await _clearUserData();
        _setState(AuthState.unauthenticated);
      }
    } on AuthenticationException {
      await _clearUserData();
      _setState(AuthState.unauthenticated);
    } catch (e) {
      _errorMessage = 'Failed to load user profile';
      _setState(AuthState.error);
    }
  }

  /// Store user data securely
  Future<void> _storeUserData(AuthUser user) async {
    final userData = json.encode(user.toJson());
    await _secureStorage.write(key: AppConfig.userKey, value: userData);
  }

  /// Load user data from secure storage
  Future<AuthUser?> _loadStoredUserData() async {
    try {
      final userData = await _secureStorage.read(key: AppConfig.userKey);
      if (userData != null) {
        final userJson = json.decode(userData);
        return AuthUser.fromJson(userJson);
      }
    } catch (e) {
      // If stored data is corrupted, clear it
      await _secureStorage.delete(key: AppConfig.userKey);
    }
    return null;
  }

  /// Clear all user data
  Future<void> _clearUserData() async {
    await _apiClient.clearTokens();
    await legacy_api.ApiClient.instance.clearLocalSession();
  }

  /// Set authentication state
  void _setState(AuthState newState) {
    if (_state != newState) {
      _state = newState;
      notifyListeners();
    }
  }

  /// Check if user has permission
  bool hasPermission(String permission) {
    return _currentUser?.hasPermission(permission) ?? false;
  }

  /// Check if user has any of the given permissions
  bool hasAnyPermission(List<String> permissions) {
    return _currentUser?.hasAnyPermission(permissions) ?? false;
  }

  /// Check if user can access store
  bool canAccessStore(String storeId) {
    return _currentUser?.canAccessStore(storeId) ?? false;
  }

  /// Get user's accessible stores
  List<AssignedStore> get accessibleStores {
    return _currentUser?.assignedStores ?? [];
  }

  /// Get user's managed stores
  List<AssignedStore> get managedStores {
    return _currentUser?.managedStores ?? [];
  }

  /// Check authentication status without making API calls
  Future<bool> checkAuthStatus() async {
    final token = await _apiClient.getAuthToken();
    final userData = await _loadStoredUserData();
    
    if (token != null && userData != null) {
      _currentUser = userData;
      _setState(AuthState.authenticated);
      return true;
    } else {
      _setState(AuthState.unauthenticated);
      return false;
    }
  }

  /// Force refresh user profile
  Future<void> refreshUserProfile() async {
    if (isAuthenticated) {
      await _loadUserProfile();
    }
  }

  /// Clear error message
  void clearError() {
    if (_errorMessage != null) {
      _errorMessage = null;
      notifyListeners();
    }
  }

  /// Update user profile (after profile changes)
  Future<void> updateUserProfile(AuthUser updatedUser) async {
    _currentUser = updatedUser;
    await _storeUserData(updatedUser);
    notifyListeners();
  }
}