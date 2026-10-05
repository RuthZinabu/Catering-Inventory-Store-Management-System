import 'package:flutter/material.dart';

import '../models/auth_models.dart';
import '../services/auth_service.dart';
import '../theme/app_colors.dart';
import '../utils/error_handler.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _passwordFormKey = GlobalKey<FormState>();
  final _currentPassword = TextEditingController();
  final _newPassword = TextEditingController();
  final _confirmPassword = TextEditingController();

  bool _showCurrentPassword = false;
  bool _showNewPassword = false;
  bool _showConfirmPassword = false;
  bool _changingPassword = false;
  bool _loggingOut = false;
  String? _passwordFeedback;
  bool _passwordChanged = false;

  @override
  void dispose() {
    _currentPassword.dispose();
    _newPassword.dispose();
    _confirmPassword.dispose();
    super.dispose();
  }

  Future<void> _changePassword() async {
    if (!_passwordFormKey.currentState!.validate()) return;

    setState(() {
      _changingPassword = true;
      _passwordFeedback = null;
    });

    try {
      await AuthService.instance.changePassword(
        currentPassword: _currentPassword.text,
        newPassword: _newPassword.text,
        newPasswordConfirmation: _confirmPassword.text,
      );
      _currentPassword.clear();
      _newPassword.clear();
      _confirmPassword.clear();
      if (!mounted) return;
      setState(() {
        _passwordChanged = true;
        _passwordFeedback = 'Your password has been updated.';
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _passwordChanged = false;
        _passwordFeedback = ErrorHandler.getErrorMessage(error);
      });
    } finally {
      if (mounted) setState(() => _changingPassword = false);
    }
  }

  Future<void> _logout() async {
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sign out?'),
        content: const Text('You will need to sign in again to use the app.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Sign out'),
          ),
        ],
      ),
    );
    if (shouldLogout != true || !mounted) return;

    setState(() => _loggingOut = true);
    try {
      // AppWrapper observes this auth-state change and displays the login page.
      await AuthService.instance.logout();
    } catch (_) {
      if (!mounted) return;
      setState(() => _loggingOut = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Unable to sign out. Please try again.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = AuthService.instance.currentUser;
    final name = user?.name.trim().isNotEmpty == true ? user!.name.trim() : 'User';
    final initial = name == 'User' ? 'U' : name[0].toUpperCase();

    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.darkGreen,
                borderRadius: BorderRadius.circular(24),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: AppColors.accentGold,
                    child: Text(
                      initial,
                      style: const TextStyle(
                        color: AppColors.darkGreen,
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          name,
                          style: Theme.of(context)
                              .textTheme
                              .titleLarge
                              ?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                              ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          user?.email ?? '',
                          style: const TextStyle(color: Colors.white70),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Account details',
                        style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 14),
                    _detailRow('Role', _displayRole(user?.role)),
                    const SizedBox(height: 10),
                    Text('Assigned stores',
                        style: Theme.of(context).textTheme.bodyMedium),
                    const SizedBox(height: 8),
                    if (user == null || user.assignedStores.isEmpty)
                      const Text('No stores assigned')
                    else
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: user.assignedStores
                            .map((store) => Chip(label: Text(store.storeName)))
                            .toList(),
                      ),
                  ],
                ),
              ),
            ),
            if (user?.isAdmin == true) ...[
              const SizedBox(height: 16),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(18),
                  child: Form(
                    key: _passwordFormKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Change password',
                            style: Theme.of(context).textTheme.titleMedium),
                        const SizedBox(height: 6),
                        const Text(
                          'For security, enter your current password first.',
                        ),
                        const SizedBox(height: 16),
                        _passwordField(
                          controller: _currentPassword,
                          label: 'Current password',
                          obscure: !_showCurrentPassword,
                          onToggle: () => setState(() =>
                              _showCurrentPassword = !_showCurrentPassword),
                          validator: (value) => value == null || value.isEmpty
                              ? 'Enter your current password'
                              : null,
                        ),
                        const SizedBox(height: 12),
                        _passwordField(
                          controller: _newPassword,
                          label: 'New password',
                          obscure: !_showNewPassword,
                          onToggle: () =>
                              setState(() => _showNewPassword = !_showNewPassword),
                          validator: (value) {
                            if (value == null || value.length < 8) {
                              return 'Use at least 8 characters';
                            }
                            if (value == _currentPassword.text) {
                              return 'Choose a password different from the current one';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 12),
                        _passwordField(
                          controller: _confirmPassword,
                          label: 'Confirm new password',
                          obscure: !_showConfirmPassword,
                          onToggle: () => setState(() =>
                              _showConfirmPassword = !_showConfirmPassword),
                          validator: (value) => value != _newPassword.text
                              ? 'Passwords do not match'
                              : null,
                        ),
                        if (_passwordFeedback != null) ...[
                          const SizedBox(height: 12),
                          Text(
                            _passwordFeedback!,
                            style: TextStyle(
                              color: _passwordChanged
                                  ? AppColors.accentGreen
                                  : Theme.of(context).colorScheme.error,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                        const SizedBox(height: 16),
                        SizedBox(
                          width: double.infinity,
                          child: FilledButton(
                            onPressed:
                                _changingPassword ? null : _changePassword,
                            child: _changingPassword
                                ? const SizedBox.square(
                                    dimension: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  )
                                : const Text('Update password'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
            const SizedBox(height: 24),
            OutlinedButton.icon(
              onPressed: _loggingOut ? null : _logout,
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.errorRed,
                side: const BorderSide(color: AppColors.errorRed),
              ),
              icon: _loggingOut
                  ? const SizedBox.square(
                      dimension: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.logout_rounded),
              label: Text(_loggingOut ? 'Signing out…' : 'Sign out'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _detailRow(String label, String value) {
    return Row(
      children: [
        SizedBox(width: 72, child: Text(label)),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              color: AppColors.darkGreen,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }

  Widget _passwordField({
    required TextEditingController controller,
    required String label,
    required bool obscure,
    required VoidCallback onToggle,
    required String? Function(String?) validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscure,
      autocorrect: false,
      enableSuggestions: false,
      textInputAction: TextInputAction.next,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: const Icon(Icons.lock_outline_rounded),
        suffixIcon: IconButton(
          tooltip: obscure ? 'Show password' : 'Hide password',
          onPressed: onToggle,
          icon: Icon(obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined),
        ),
      ),
      validator: validator,
    );
  }

  String _displayRole(String? role) {
    if (role == null || role.isEmpty) return 'Unknown';
    return role
        .split('_')
        .map((part) => '${part[0].toUpperCase()}${part.substring(1)}')
        .join(' ');
  }
}
