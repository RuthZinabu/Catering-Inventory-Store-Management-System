import 'dart:io';
import 'package:flutter/foundation.dart';

enum Environment { development, staging, production }

class AppConfig {
  static Environment _environment = Environment.development;
  static const String _apiBaseUrlOverride = String.fromEnvironment(
    'API_BASE_URL',
  );

  static Environment get environment => _environment;

  static void setEnvironment(Environment env) {
    _environment = env;
  }

  // API Configuration with platform-specific URLs
  static String get apiBaseUrl {
    switch (_environment) {
      case Environment.development:
        return _getDevelopmentApiUrl();
      case Environment.staging:
        return 'https://staging-api.cateringinventory.com/api';
      case Environment.production:
        return 'https://api.cateringinventory.com/api';
    }
  }

  /// Get platform-specific development API URL
  static String _getDevelopmentApiUrl() {
    if (kIsWeb) {
      // Flutter Web - use localhost/127.0.0.1 for development
      return 'http://127.0.0.1:8000/api';
    } else if (Platform.isAndroid) {
      // Android emulator uses 10.0.2.2 to access host machine
      // For physical Android device, replace with your LAN IP
      return 'http://10.0.2.2:8000/api';
    } else if (Platform.isIOS) {
      // iOS Simulator can use localhost
      // For physical iOS device, replace with your LAN IP
      return 'http://localhost:8000/api';
    } else {
      // Desktop platforms (Windows, macOS, Linux)
      return 'http://127.0.0.1:8000/api';
    }
  }

  /// Set custom API URL for development (useful for physical devices)
  static String? _customApiUrl;

  static void setCustomApiUrl(String url) {
    _customApiUrl = url;
  }

  static void clearCustomApiUrl() {
    _customApiUrl = null;
  }

  /// Get the effective API URL (custom override or default)
  static String get effectiveApiUrl {
    if (_customApiUrl != null) return _customApiUrl!;
    return _apiBaseUrlOverride.isNotEmpty ? _apiBaseUrlOverride : apiBaseUrl;
  }

  // Timeout Configuration
  static const Duration connectTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);
  static const Duration sendTimeout = Duration(seconds: 30);

  // Token Configuration
  static const String tokenKey = 'auth_token';
  static const String refreshTokenKey = 'refresh_token';
  static const String userKey = 'user_data';

  // App Configuration
  static const String appName = 'Catering Inventory Management';
  static const String appVersion = '1.0.0';

  // Debug Configuration
  static bool get isDebug => _environment == Environment.development;
  static bool get enableLogging => _environment != Environment.production;

  // Platform Information
  static String get platformName {
    if (kIsWeb) {
      return 'Web';
    } else if (Platform.isAndroid) {
      return 'Android';
    } else if (Platform.isIOS) {
      return 'iOS';
    } else if (Platform.isWindows) {
      return 'Windows';
    } else if (Platform.isMacOS) {
      return 'macOS';
    } else if (Platform.isLinux) {
      return 'Linux';
    } else {
      return 'Unknown';
    }
  }

  // Pagination
  static const int defaultPageSize = 15;
  static const int maxPageSize = 100;

  // Cache Configuration
  static const Duration cacheValidDuration = Duration(minutes: 5);
  static const Duration offlineDataRetention = Duration(days: 7);

  // Development URLs for different scenarios
  static const Map<String, String> developmentUrls = {
    'local': 'http://127.0.0.1:8000/api',
    'android_emulator': 'http://10.0.2.2:8000/api',
    'ios_simulator': 'http://localhost:8000/api',
    // Example LAN IP (replace with your computer's actual IP)
    'physical_device': 'http://192.168.1.100:8000/api',
  };
}
