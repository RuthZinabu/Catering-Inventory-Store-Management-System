import 'package:flutter/material.dart';

import '../models/auth_models.dart';
import '../services/auth_service.dart';

/// Authentication provider for state management
class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService.instance;

  AuthProvider() {
    // Listen to auth service changes
    _authService.addListener(_onAuthServiceChanged);
  }

  @override
  void dispose() {
    _authService.removeListener(_onAuthServiceChanged);
    super.dispose();
  }

  void _onAuthServiceChanged() {
    notifyListeners();
  }

  // Delegate getters to auth service
  AuthState get state => _authService.state;
  AuthUser? get currentUser => _authService.currentUser;
  String? get errorMessage => _authService.errorMessage;
  bool get isAuthenticated => _authService.isAuthenticated;
  bool get isLoading => _authService.isLoading;
  List<AssignedStore> get accessibleStores => _authService.accessibleStores;
  List<AssignedStore> get managedStores => _authService.managedStores;

  // Delegate methods to auth service
  Future<bool> login({
    required String email,
    required String password,
    String? deviceName,
  }) async {
    return await _authService.login(
      email: email,
      password: password,
      deviceName: deviceName,
    );
  }

  Future<void> logout() async {
    await _authService.logout();
  }

  Future<bool> refreshToken() async {
    return await _authService.refreshToken();
  }

  bool hasPermission(String permission) {
    return _authService.hasPermission(permission);
  }

  bool hasAnyPermission(List<String> permissions) {
    return _authService.hasAnyPermission(permissions);
  }

  bool canAccessStore(String storeId) {
    return _authService.canAccessStore(storeId);
  }

  Future<bool> checkAuthStatus() async {
    return await _authService.checkAuthStatus();
  }

  Future<void> refreshUserProfile() async {
    await _authService.refreshUserProfile();
  }

  void clearError() {
    _authService.clearError();
  }

  Future<void> updateUserProfile(AuthUser updatedUser) async {
    await _authService.updateUserProfile(updatedUser);
  }
}