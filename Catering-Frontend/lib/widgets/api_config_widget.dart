import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../config/app_config.dart';
import '../services/api/api_client.dart';

/// Widget to display and configure API settings for development and testing.
///
/// This widget allows developers to:
/// - View current API base URL
/// - Switch between different API endpoints (localhost, production, etc.)
/// - Test API connectivity
/// - Quickly toggle between development and production environments
///
/// Useful for testing the app with different backend servers without rebuilding.
class ApiConfigWidget extends StatefulWidget {
  const ApiConfigWidget({super.key});

  @override
  State<ApiConfigWidget> createState() => _ApiConfigWidgetState();
}

class _ApiConfigWidgetState extends State<ApiConfigWidget> {
  final TextEditingController _urlController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _urlController.text = AppConfig.effectiveApiUrl;
  }

  @override
  void dispose() {
    _urlController.dispose();
    super.dispose();
  }

  Future<void> _updateApiUrl() async {
    final newUrl = _urlController.text.trim();
    try {
      if (newUrl.isEmpty) {
        throw const FormatException('Enter an API URL.');
      }
      if (newUrl == AppConfig.apiBaseUrl) {
        await AppConfig.clearCustomApiUrl();
      } else {
        await AppConfig.setCustomApiUrl(newUrl);
      }
      ApiClient.instance.dio.options.baseUrl = AppConfig.effectiveApiUrl;
      if (!mounted) return;
      final isDefault = newUrl == AppConfig.apiBaseUrl;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            isDefault ? 'Using default API URL' : 'API URL saved: $newUrl',
          ),
          backgroundColor: isDefault ? Colors.blue : Colors.green,
        ),
      );
    } on FormatException catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error.message)),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not save the API URL. Try again.')),
      );
    }
    if (mounted) setState(() {});
  }

  Future<void> _resetToDefault() async {
    try {
      await AppConfig.clearCustomApiUrl();
      ApiClient.instance.dio.options.baseUrl = AppConfig.effectiveApiUrl;
      if (!mounted) return;
      _urlController.text = AppConfig.effectiveApiUrl;
      setState(() {});
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Reset to default API URL'),
          backgroundColor: Colors.blue,
        ),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not reset the API URL. Try again.')),
      );
    }
  }

  void _copyToClipboard(String text) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Copied: $text'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.settings, color: Colors.blue),
                const SizedBox(width: 8),
                Text(
                  'API Configuration',
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Current Configuration
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Current Configuration:',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                  const SizedBox(height: 8),
                  _buildInfoRow('Platform', AppConfig.platformName),
                  _buildInfoRow('Environment', AppConfig.environment.name),
                  _buildInfoRow('Default URL', AppConfig.apiBaseUrl),
                  _buildInfoRow('Current URL', AppConfig.effectiveApiUrl),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // URL Configuration
            Text(
              'Custom API URL (for development):',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),

            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _urlController,
                    decoration: const InputDecoration(
                      hintText: 'Enter custom API URL',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.link),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _updateApiUrl,
                  child: const Text('Update'),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Quick Settings
            Text(
              'Quick Settings:',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),

            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: AppConfig.developmentUrls.entries.map((entry) {
                return ElevatedButton(
                  onPressed: () async {
                    _urlController.text = entry.value;
                    await _updateApiUrl();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppConfig.effectiveApiUrl == entry.value
                        ? Colors.blue
                        : null,
                    foregroundColor: AppConfig.effectiveApiUrl == entry.value
                        ? Colors.white
                        : null,
                  ),
                  child: Text(entry.key.replaceAll('_', ' ').toUpperCase()),
                );
              }).toList(),
            ),

            const SizedBox(height: 12),

            Row(
              children: [
                ElevatedButton.icon(
                  onPressed: _resetToDefault,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Reset to Default'),
                ),
                const SizedBox(width: 8),
                OutlinedButton.icon(
                  onPressed: () => _copyToClipboard(AppConfig.effectiveApiUrl),
                  icon: const Icon(Icons.copy),
                  label: const Text('Copy URL'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () => _copyToClipboard(value),
              child: Text(
                value,
                style: const TextStyle(
                  fontFamily: 'monospace',
                  color: Colors.blue,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
