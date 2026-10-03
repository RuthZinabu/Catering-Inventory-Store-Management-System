import 'package:flutter/material.dart';

import '../services/api_service.dart';

class AuthenticationScreen extends StatefulWidget {
  final VoidCallback onAuthenticated;

  const AuthenticationScreen({super.key, required this.onAuthenticated});

  @override
  State<AuthenticationScreen> createState() => _AuthenticationScreenState();
}

class _AuthenticationScreenState extends State<AuthenticationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _busy = false;
  String? _error;
  List<Map<String, dynamic>> _stores = [];
  String? _selectedStoreId;
  bool _chooseStore = false;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _signIn() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      final session = await ApiClient.instance.login(
        email: _email.text.trim(),
        password: _password.text,
      );
      final stores = List<Map<String, dynamic>>.from(session['stores'] as List);
      if (!mounted) return;
      setState(() {
        _busy = false;
        _stores = stores;
        _selectedStoreId = stores.first['store_id']?.toString() ?? stores.first['id']?.toString();
        _chooseStore = stores.length > 1;
      });
      if (stores.length == 1) widget.onAuthenticated();
    } on ApiException catch (error) {
      if (mounted) setState(() {
        _busy = false;
        _error = error.message;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text('Catering Control', style: Theme.of(context).textTheme.headlineSmall),
                  const SizedBox(height: 8),
                  const Text('Sign in to manage purchasing and inventory.'),
                  const SizedBox(height: 24),
                  TextFormField(
                    controller: _email,
                    keyboardType: TextInputType.emailAddress,
                    autofillHints: const [AutofillHints.username],
                    decoration: const InputDecoration(labelText: 'Email'),
                    validator: (value) => value == null || !value.contains('@') ? 'Enter a valid email' : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _password,
                    obscureText: true,
                    autofillHints: const [AutofillHints.password],
                    decoration: const InputDecoration(labelText: 'Password'),
                    validator: (value) => value == null || value.isEmpty ? 'Enter your password' : null,
                  ),
                  if (_chooseStore) ...[
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      value: _selectedStoreId,
                      decoration: const InputDecoration(labelText: 'Destination Store'),
                      items: _stores.map((store) {
                        final id = store['store_id']?.toString() ?? store['id'].toString();
                        final name = store['store_name'] as String? ?? store['name'] as String? ?? id;
                        return DropdownMenuItem(value: id, child: Text(name));
                      }).toList(),
                      onChanged: (value) => setState(() => _selectedStoreId = value),
                    ),
                    const SizedBox(height: 12),
                    FilledButton(
                      onPressed: _busy || _selectedStoreId == null
                          ? null
                          : () async {
                              await ApiClient.instance.selectStore(_selectedStoreId!);
                              if (mounted) widget.onAuthenticated();
                            },
                      child: const Text('Continue'),
                    ),
                  ],
                  if (_error != null) ...[
                    const SizedBox(height: 12),
                    Text(_error!, style: TextStyle(color: Theme.of(context).colorScheme.error)),
                  ],
                  const SizedBox(height: 20),
                  if (!_chooseStore)
                    FilledButton(
                      onPressed: _busy ? null : _signIn,
                      child: _busy
                          ? const SizedBox.square(dimension: 20, child: CircularProgressIndicator(strokeWidth: 2))
                          : const Text('Sign In'),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
