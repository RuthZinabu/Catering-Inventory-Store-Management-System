import 'package:flutter/material.dart';

import 'models/auth_models.dart';
import 'providers/auth_provider.dart';
import 'screens/auth/login_screen.dart';
import 'screens/api_test_screen.dart';
import 'screens/api_config_screen.dart';
import 'app.dart';
import 'config/app_config.dart';
import 'utils/connectivity_manager.dart';
import 'services/api_repository.dart';

/// Main app wrapper that handles authentication flow and initialization
class AppWrapper extends StatefulWidget {
  const AppWrapper({super.key});

  @override
  State<AppWrapper> createState() => _AppWrapperState();
}

class _AppWrapperState extends State<AppWrapper> {
  late final AuthProvider _authProvider;
  bool _isInitializing = true;

  @override
  void initState() {
    super.initState();

    // Set environment (can be changed based on build config)
    // AppConfig.setEnvironment(Environment.development);

    _authProvider = AuthProvider();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    try {
      // Initialize API repository
      // All data operations now use API services directly

      // Check if user is already authenticated
      await _authProvider.checkAuthStatus();
    } catch (e) {
      // Handle initialization error
      debugPrint('App initialization error: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isInitializing = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _authProvider.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppConfig.appName,
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: ConnectivityListener(
        child: _buildBody(),
      ),
      routes: {
        '/login': (context) => const LoginScreen(),
        '/main': (context) => const CateringInventoryApp(),
        '/api-test': (context) => const ApiTestScreen(),
        '/api-config': (context) => const ApiConfigScreen(),
      },
    );
  }

  Widget _buildBody() {
    if (_isInitializing) {
      return const InitializationScreen();
    }

    return ListenableBuilder(
      listenable: _authProvider,
      builder: (context, child) {
        switch (_authProvider.state) {
          case AuthState.loading:
            return const InitializationScreen();

          case AuthState.authenticated:
            return const CateringInventoryApp();

          case AuthState.unauthenticated:
          case AuthState.error:
            return const LoginScreen();

          case AuthState.initial:
          default:
            return const LoginScreen();
        }
      },
    );
  }
}

/// Loading screen shown during app initialization
class InitializationScreen extends StatelessWidget {
  const InitializationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // App Logo/Icon
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Icon(
                Icons.restaurant_menu,
                size: 64,
                color: Colors.blue[700],
              ),
            ),
            const SizedBox(height: 32),

            // App Name
            Text(
              AppConfig.appName,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.blue[700],
                  ),
            ),
            const SizedBox(height: 8),

            Text(
              'Version ${AppConfig.appVersion}',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[600],
                  ),
            ),

            const SizedBox(height: 48),

            // Loading indicator
            const CircularProgressIndicator(),
            const SizedBox(height: 16),

            Text(
              'Initializing...',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[600],
                  ),
            ),

            // Debug API Config button (only in development)
            if (AppConfig.isDebug) ...[
              const SizedBox(height: 32),
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.of(context).pushNamed('/api-config');
                },
                icon: const Icon(Icons.settings),
                label: const Text('API Config'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey[600],
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
