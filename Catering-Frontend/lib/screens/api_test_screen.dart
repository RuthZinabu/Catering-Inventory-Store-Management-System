import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../services/user_service.dart';
import '../services/store_service.dart';
import '../services/inventory_service.dart';
import '../utils/error_handler.dart';
import '../widgets/loading_overlay.dart';

/// Screen for testing API endpoints manually
class ApiTestScreen extends StatefulWidget {
  const ApiTestScreen({super.key});

  @override
  State<ApiTestScreen> createState() => _ApiTestScreenState();
}

class _ApiTestScreenState extends State<ApiTestScreen> {
  bool _isLoading = false;
  String _results = '';
  
  final AuthService _authService = AuthService.instance;
  final UserService _userService = UserService.instance;
  final StoreService _storeService = StoreService.instance;
  final InventoryService _inventoryService = InventoryService.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('API Test'),
        backgroundColor: Colors.blue[700],
        foregroundColor: Colors.white,
      ),
      body: LoadingOverlay(
        isLoading: _isLoading,
        message: 'Testing API...',
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'API Integration Test',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Test various API endpoints to verify integration',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 24),
              
              // Test Buttons
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _buildTestButton(
                    'Test Login',
                    _testLogin,
                    Colors.green,
                  ),
                  _buildTestButton(
                    'Get Profile',
                    _testGetProfile,
                    Colors.blue,
                  ),
                  _buildTestButton(
                    'Get Users',
                    _testGetUsers,
                    Colors.orange,
                  ),
                  _buildTestButton(
                    'Get Stores',
                    _testGetStores,
                    Colors.purple,
                  ),
                  _buildTestButton(
                    'Get Items',
                    _testGetItems,
                    Colors.teal,
                  ),
                  _buildTestButton(
                    'Test Logout',
                    _testLogout,
                    Colors.red,
                  ),
                ],
              ),
              
              const SizedBox(height: 24),
              
              Text(
                'Results:',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              
              // Results Display
              Expanded(
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey[300]!),
                  ),
                  child: SingleChildScrollView(
                    child: Text(
                      _results.isEmpty ? 'No tests run yet' : _results,
                      style: const TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 12,
                      ),
                    ),
                  ),
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Clear Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _clearResults,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey[600],
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Clear Results'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTestButton(String label, VoidCallback onPressed, Color color) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
      ),
      child: Text(label),
    );
  }

  void _addResult(String test, String result) {
    setState(() {
      _results += '[${DateTime.now().toString().substring(11, 19)}] $test:\n$result\n\n';
    });
  }

  void _clearResults() {
    setState(() {
      _results = '';
    });
  }

  Future<void> _testLogin() async {
    setState(() => _isLoading = true);
    
    try {
      final success = await _authService.login(
        email: 'admin@cateringinventory.com',
        password: 'password123',
        deviceName: 'Flutter Test App',
      );
      
      _addResult(
        'LOGIN TEST', 
        success ? 'SUCCESS: Login successful' : 'FAILED: Login failed',
      );
      
      if (success && _authService.currentUser != null) {
        final user = _authService.currentUser!;
        _addResult(
          'USER INFO',
          'Name: ${user.name}\nEmail: ${user.email}\nRole: ${user.role}\nStores: ${user.assignedStores.length}',
        );
      }
    } catch (e) {
      _addResult('LOGIN TEST', 'ERROR: ${ErrorHandler.getErrorMessage(e)}');
      ErrorHandler.showErrorSnackBar(context, e);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _testGetProfile() async {
    setState(() => _isLoading = true);
    
    try {
      await _authService.refreshUserProfile();
      final user = _authService.currentUser;
      
      if (user != null) {
        _addResult(
          'GET PROFILE',
          'SUCCESS: Profile loaded\nName: ${user.name}\nEmail: ${user.email}\nRole: ${user.role}',
        );
      } else {
        _addResult('GET PROFILE', 'FAILED: No user data received');
      }
    } catch (e) {
      _addResult('GET PROFILE', 'ERROR: ${ErrorHandler.getErrorMessage(e)}');
      ErrorHandler.showErrorSnackBar(context, e);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _testGetUsers() async {
    setState(() => _isLoading = true);
    
    try {
      final result = await _userService.getAll();
      
      _addResult(
        'GET USERS',
        'SUCCESS: Retrieved ${result.items.length} users\nTotal: ${result.total}\nHas more: ${result.hasNextPage}',
      );
      
      if (result.items.isNotEmpty) {
        final firstUser = result.items.first;
        _addResult(
          'FIRST USER',
          'ID: ${firstUser.id}\nName: ${firstUser.name}\nEmail: ${firstUser.email}',
        );
      }
    } catch (e) {
      _addResult('GET USERS', 'ERROR: ${ErrorHandler.getErrorMessage(e)}');
      ErrorHandler.showErrorSnackBar(context, e);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _testGetStores() async {
    setState(() => _isLoading = true);
    
    try {
      final result = await _storeService.getAll();
      
      _addResult(
        'GET STORES',
        'SUCCESS: Retrieved ${result.items.length} stores\nTotal: ${result.total}\nHas more: ${result.hasNextPage}',
      );
      
      if (result.items.isNotEmpty) {
        final firstStore = result.items.first;
        _addResult(
          'FIRST STORE',
          'ID: ${firstStore.id}\nName: ${firstStore.name}\nCode: ${firstStore.code}',
        );
      }
    } catch (e) {
      _addResult('GET STORES', 'ERROR: ${ErrorHandler.getErrorMessage(e)}');
      ErrorHandler.showErrorSnackBar(context, e);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _testGetItems() async {
    setState(() => _isLoading = true);
    
    try {
      final result = await _inventoryService.getAll();
      
      _addResult(
        'GET ITEMS',
        'SUCCESS: Retrieved ${result.items.length} items\nTotal: ${result.total}\nHas more: ${result.hasNextPage}',
      );
      
      if (result.items.isNotEmpty) {
        final firstItem = result.items.first;
        _addResult(
          'FIRST ITEM',
          'ID: ${firstItem.id}\nName: ${firstItem.name}\nCategory: ${firstItem.category}',
        );
      }
    } catch (e) {
      _addResult('GET ITEMS', 'ERROR: ${ErrorHandler.getErrorMessage(e)}');
      ErrorHandler.showErrorSnackBar(context, e);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _testLogout() async {
    setState(() => _isLoading = true);
    
    try {
      await _authService.logout();
      _addResult('LOGOUT TEST', 'SUCCESS: Logged out successfully');
      
      // Navigate back to login
      if (mounted) {
        Navigator.of(context).pushReplacementNamed('/login');
      }
    } catch (e) {
      _addResult('LOGOUT TEST', 'ERROR: ${ErrorHandler.getErrorMessage(e)}');
      ErrorHandler.showErrorSnackBar(context, e);
    } finally {
      setState(() => _isLoading = false);
    }
  }
}