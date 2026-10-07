/// Example implementations of LogoLoadingTransition in different contexts.
/// 
/// This file demonstrates various use cases for the logo loading animation.
/// Copy these examples and adapt them to your needs.

import 'package:flutter/material.dart';
import 'logo_loading_transition.dart';

/// Example 1: Full-screen loading page
class FullScreenLoadingExample extends StatelessWidget {
  const FullScreenLoadingExample({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const LogoLoadingTransition(
              size: 140,
              duration: Duration(milliseconds: 2200),
            ),
            const SizedBox(height: 32),
            Text(
              'Loading your data...',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Example 2: Dialog with loading animation
class LoadingDialogExample extends StatelessWidget {
  const LoadingDialogExample({super.key});

  static Future<void> show(BuildContext context) {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const LoadingDialogExample(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const LogoLoadingTransition(
              size: 80,
              duration: Duration(milliseconds: 2000),
            ),
            const SizedBox(height: 16),
            Text(
              'Processing...',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[700],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Please wait',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[500],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Example 3: Button with loading state
class LoadingButtonExample extends StatefulWidget {
  const LoadingButtonExample({super.key});

  @override
  State<LoadingButtonExample> createState() => _LoadingButtonExampleState();
}

class _LoadingButtonExampleState extends State<LoadingButtonExample> {
  bool _isLoading = false;

  Future<void> _handleSubmit() async {
    setState(() => _isLoading = true);

    // Simulate API call
    await Future.delayed(const Duration(seconds: 2));

    if (mounted) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Action completed!')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: _isLoading ? null : _handleSubmit,
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF1B5E20),
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      child: _isLoading
          ? const SizedBox(
              width: 100,
              child: LogoLoadingTransition(
                size: 24,
                duration: Duration(milliseconds: 1800),
              ),
            )
          : const Text(
              'Submit',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
    );
  }
}

/// Example 4: Card with loading state
class LoadingCardExample extends StatelessWidget {
  final bool isLoading;
  final Widget? child;

  const LoadingCardExample({
    super.key,
    this.isLoading = false,
    this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Container(
        height: 200,
        padding: const EdgeInsets.all(16),
        child: isLoading
            ? const Center(
                child: LogoLoadingTransition(
                  size: 60,
                  duration: Duration(milliseconds: 2000),
                ),
              )
            : child ?? const Center(child: Text('No content')),
      ),
    );
  }
}

/// Example 5: List view with loading indicator
class LoadingListExample extends StatefulWidget {
  const LoadingListExample({super.key});

  @override
  State<LoadingListExample> createState() => _LoadingListExampleState();
}

class _LoadingListExampleState extends State<LoadingListExample> {
  bool _isLoading = true;
  List<String> _items = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);

    // Simulate API call
    await Future.delayed(const Duration(seconds: 2));

    if (mounted) {
      setState(() {
        _items = List.generate(10, (index) => 'Item ${index + 1}');
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Loading List Example'),
      ),
      body: _isLoading
          ? const Center(
              child: LogoLoadingTransition(
                size: 100,
                duration: Duration(milliseconds: 2200),
              ),
            )
          : RefreshIndicator(
              onRefresh: _loadData,
              child: ListView.builder(
                itemCount: _items.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    leading: CircleAvatar(
                      child: Text('${index + 1}'),
                    ),
                    title: Text(_items[index]),
                    subtitle: Text('Subtitle for ${_items[index]}'),
                  );
                },
              ),
            ),
    );
  }
}

/// Example 6: Splash screen
class SplashScreenExample extends StatefulWidget {
  const SplashScreenExample({super.key});

  @override
  State<SplashScreenExample> createState() => _SplashScreenExampleState();
}

class _SplashScreenExampleState extends State<SplashScreenExample> {
  @override
  void initState() {
    super.initState();
    _navigateToHome();
  }

  Future<void> _navigateToHome() async {
    await Future.delayed(const Duration(seconds: 3));
    if (mounted) {
      Navigator.pushReplacementNamed(context, '/home');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const LogoLoadingTransition(
              size: 160,
              duration: Duration(milliseconds: 2500),
            ),
            const SizedBox(height: 48),
            Text(
              'Catering Inventory',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF1B5E20),
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'Management System',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: const Color(0xFF1B5E20).withOpacity(0.7),
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Example 7: Inline loading in a row
class InlineLoadingExample extends StatelessWidget {
  const InlineLoadingExample({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'Processing',
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[700],
          ),
        ),
        const SizedBox(width: 8),
        const LogoLoadingTransition(
          size: 20,
          duration: Duration(milliseconds: 1500),
        ),
      ],
    );
  }
}

/// Example 8: Overlay loading (covers entire screen)
class LoadingOverlayExample extends StatelessWidget {
  final bool isLoading;
  final Widget child;

  const LoadingOverlayExample({
    super.key,
    required this.isLoading,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        if (isLoading)
          Container(
            color: Colors.black.withOpacity(0.5),
            child: const Center(
              child: Card(
                margin: EdgeInsets.all(32),
                child: Padding(
                  padding: EdgeInsets.all(32),
                  child: LogoLoadingTransition(
                    size: 80,
                    duration: Duration(milliseconds: 2000),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

/// Example usage in a demo screen
class LogoLoadingExamplesScreen extends StatelessWidget {
  const LogoLoadingExamplesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Logo Loading Examples'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildExampleTile(
            context,
            'Full Screen Loading',
            'Shows loading animation centered on screen',
            () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const FullScreenLoadingExample(),
              ),
            ),
          ),
          _buildExampleTile(
            context,
            'Loading Dialog',
            'Modal dialog with loading animation',
            () => LoadingDialogExample.show(context),
          ),
          _buildExampleTile(
            context,
            'Loading Button',
            'Button with integrated loading state',
            () => _showExampleDialog(
              context,
              const LoadingButtonExample(),
            ),
          ),
          _buildExampleTile(
            context,
            'Loading Card',
            'Card component with loading state',
            () => _showExampleDialog(
              context,
              const LoadingCardExample(isLoading: true),
            ),
          ),
          _buildExampleTile(
            context,
            'Loading List',
            'List view with loading indicator',
            () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const LoadingListExample(),
              ),
            ),
          ),
          _buildExampleTile(
            context,
            'Inline Loading',
            'Small loading indicator in a row',
            () => _showExampleDialog(
              context,
              const Center(child: InlineLoadingExample()),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExampleTile(
    BuildContext context,
    String title,
    String subtitle,
    VoidCallback onTap,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: onTap,
      ),
    );
  }

  void _showExampleDialog(BuildContext context, Widget content) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: SizedBox(
          height: 250,
          child: content,
        ),
      ),
    );
  }
}
