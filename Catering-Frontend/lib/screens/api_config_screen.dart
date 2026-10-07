import 'package:flutter/material.dart';
import '../config/app_config.dart';
import '../widgets/api_config_widget.dart';
import '../services/api/api_client.dart';
import '../utils/error_handler.dart';

/// Screen for API configuration and testing during development.
///
/// This screen provides a UI for:
/// - Viewing and changing the API base URL
/// - Testing API connectivity
/// - Switching between localhost and production endpoints
/// - Quick access to predefined API URLs (localhost, emulator, production)
///
/// Access this screen by:
/// 1. Enabling debug mode (AppConfig.isDebug = true)
/// 2. Tapping "API Config" button on initialization screen
/// 3. Or navigating to '/api-config' route
///
/// Useful for testing with different backend servers without rebuilding the app.
class ApiConfigScreen extends StatefulWidget {
  const ApiConfigScreen({super.key});

  @override
  State<ApiConfigScreen> createState() => _ApiConfigScreenState();
}

class _ApiConfigScreenState extends State<ApiConfigScreen> {
  bool _isTestingConnection = false;
  String? _testResult;
  Color _testResultColor = Colors.grey;

  Future<void> _testApiConnection() async {
    setState(() {
      _isTestingConnection = true;
      _testResult = null;
    });

    try {
      // Test basic connectivity to the API
      final response = await ApiClient.instance.dio.get('/health');

      if (response.statusCode == 200) {
        setState(() {
          _testResult = 'API connection successful! ✓';
          _testResultColor = Colors.green;
        });
      } else {
        setState(() {
          _testResult = 'API responded with status: ${response.statusCode}';
          _testResultColor = Colors.orange;
        });
      }
    } catch (error) {
      setState(() {
        _testResult =
            'Connection failed: ${ErrorHandler.getErrorMessage(error)}';
        _testResultColor = Colors.red;
      });
    } finally {
      setState(() {
        _isTestingConnection = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('API Configuration'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // API Configuration Widget
            const ApiConfigWidget(),

            // Connection Test Section
            Card(
              margin: const EdgeInsets.all(16),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.network_check, color: Colors.green),
                        const SizedBox(width: 8),
                        Text(
                          'Connection Test',
                          style:
                              Theme.of(context).textTheme.titleLarge?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Test connectivity to the Laravel API:',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton.icon(
                      onPressed:
                          _isTestingConnection ? null : _testApiConnection,
                      icon: _isTestingConnection
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.play_arrow),
                      label: Text(_isTestingConnection
                          ? 'Testing...'
                          : 'Test Connection'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                        minimumSize: const Size(double.infinity, 48),
                      ),
                    ),
                    if (_testResult != null) ...[
                      const SizedBox(height: 16),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: _testResultColor.withOpacity(0.1),
                          border: Border.all(color: _testResultColor),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          _testResult!,
                          style: TextStyle(
                            color: _testResultColor,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),

            // Platform-Specific Instructions
            Card(
              margin: const EdgeInsets.all(16),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.info, color: Colors.blue),
                        const SizedBox(width: 8),
                        Text(
                          'Platform Setup Guide',
                          style:
                              Theme.of(context).textTheme.titleLarge?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _buildInstructionSection(
                      'Flutter Web (Chrome)',
                      'Uses http://127.0.0.1:8000/api automatically.\nCORS is configured for localhost origins.',
                      Icons.web,
                      Colors.blue,
                    ),
                    _buildInstructionSection(
                      'Android Emulator',
                      'Uses http://10.0.2.2:8000/api to access host machine.\nNo CORS restrictions for native apps.',
                      Icons.phone_android,
                      Colors.green,
                    ),
                    _buildInstructionSection(
                      'iOS Simulator',
                      'Uses http://localhost:8000/api.\nNo CORS restrictions for native apps.',
                      Icons.phone_iphone,
                      Colors.grey,
                    ),
                    _buildInstructionSection(
                      'Physical Devices',
                      'Configure your computer\'s LAN IP address.\nReplace 192.168.1.100 with your actual IP.',
                      Icons.devices,
                      Colors.orange,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInstructionSection(
    String title,
    String description,
    IconData icon,
    Color color,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 12,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
