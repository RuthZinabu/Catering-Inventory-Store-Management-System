import 'package:flutter/material.dart';

import '../../models/inventory_models.dart';
import '../../services/mock_repository.dart';

class UserCreateScreen extends StatefulWidget {
  final bool isEditing;
  final AppUser? user;

  const UserCreateScreen({super.key, this.isEditing = false, this.user});

  @override
  State<UserCreateScreen> createState() => _UserCreateScreenState();
}

class _UserCreateScreenState extends State<UserCreateScreen> {
  int _step = 0;

  late String _name;
  late String _email;
  late String _phone;
  late String _role;
  late String _department;
  late String _status;
  late Set<String> _permissions;

  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();

  final List<String> _roles = const [
    'Admin',
    'Store Manager',
    'Kitchen Supervisor',
    'Chef',
    'Storekeeper',
    'Cashier',
    'Viewer',
  ];

  final List<String> _departments = const [
    'Management',
    'Main Store',
    'Branch 2 Store',
    'Main Kitchen',
    'Prep Kitchen',
    'Satellite Kitchen',
    'Finance',
  ];

  final Map<String, String> _allPermissions = const {
    'inventory': 'Inventory',
    'suppliers': 'Suppliers',
    'purchases': 'Purchases',
    'recipes': 'Recipes',
    'waste': 'Waste',
    'expiry': 'Expiry',
    'users': 'Users',
    'reports': 'Reports',
  };

  @override
  void initState() {
    super.initState();
    if (widget.isEditing && widget.user != null) {
      final u = widget.user!;
      _name = u.name;
      _email = u.email;
      _phone = u.phone;
      _role = u.role;
      _department = u.department;
      _status = u.status;
      _permissions = Set.from(u.permissions);
    } else {
      _name = '';
      _email = '';
      _phone = '';
      _role = 'Storekeeper';
      _department = 'Main Store';
      _status = 'Active';
      _permissions = {};
    }
    _nameCtrl.text = _name;
    _emailCtrl.text = _email;
    _phoneCtrl.text = _phone;
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FB),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              IconButton(
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(Icons.arrow_back_rounded),
                style: IconButton.styleFrom(
                    backgroundColor: Colors.white,
                    padding: const EdgeInsets.all(10)),
              ),
              const SizedBox(height: 16),
              Text(
                widget.isEditing ? 'Edit User' : 'Add User',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w800, letterSpacing: -0.6),
              ),
              const SizedBox(height: 6),
              Text(
                'Configure team member access, role and module permissions.',
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium
                    ?.copyWith(fontSize: 14.5),
              ),
              const SizedBox(height: 16),
              // Steps
              Row(
                children: [
                  Expanded(
                      child: _stepBadge(0, 'Profile', _step >= 0)),
                  const SizedBox(width: 8),
                  Expanded(
                      child: _stepBadge(1, 'Role', _step >= 1)),
                  const SizedBox(width: 8),
                  Expanded(
                      child:
                          _stepBadge(2, 'Permissions', _step >= 2)),
                  const SizedBox(width: 8),
                  Expanded(
                      child: _stepBadge(3, 'Review', _step >= 3)),
                ],
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                        color: Colors.black.withOpacity(0.04),
                        blurRadius: 16,
                        offset: const Offset(0, 8))
                  ],
                ),
                child: _buildStep(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStep() {
    switch (_step) {
      case 0:
        return _stepProfile();
      case 1:
        return _stepRole();
      case 2:
        return _stepPermissions();
      default:
        return _stepReview();
    }
  }

  Widget _stepProfile() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _title('Step 1 • Personal Info'),
        _field('Full Name', _nameCtrl, onChanged: (v) => _name = v),
        _field('Email Address', _emailCtrl,
            keyboardType: TextInputType.emailAddress,
            onChanged: (v) => _email = v),
        _field('Phone Number', _phoneCtrl,
            keyboardType: TextInputType.phone,
            onChanged: (v) => _phone = v),
        _nav(
          onBack: () => Navigator.of(context).pop(),
          backLabel: 'Cancel',
          onNext: _name.trim().isEmpty || _email.trim().isEmpty
              ? null
              : () => setState(() => _step = 1),
        ),
      ],
    );
  }

  Widget _stepRole() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _title('Step 2 • Role & Department'),
        _dropdown('Role', _role, _roles,
            (v) => setState(() => _role = v!)),
        _dropdown('Department', _department, _departments,
            (v) => setState(() => _department = v!)),
        _dropdown('Account Status', _status,
            ['Active', 'Inactive', 'Suspended'],
            (v) => setState(() => _status = v!)),
        // Role description hint
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
              color: const Color(0xFFF0FDF4),
              borderRadius: BorderRadius.circular(14)),
          child: Row(
            children: [
              const Icon(Icons.info_outline_rounded,
                  color: Color(0xFF0F766E), size: 18),
              const SizedBox(width: 8),
              Expanded(
                child: Text(_roleHint(_role),
                    style: const TextStyle(
                        color: Color(0xFF0F766E),
                        fontSize: 12,
                        fontWeight: FontWeight.w600)),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        _nav(
          onBack: () => setState(() => _step = 0),
          onNext: () => setState(() => _step = 2),
        ),
      ],
    );
  }

  Widget _stepPermissions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _title('Step 3 • Module Permissions'),
        const Text(
            'Choose which modules this user can access.',
            style: TextStyle(color: Color(0xFF64748B), fontSize: 13)),
        const SizedBox(height: 12),
        ..._allPermissions.entries.map((entry) {
          final isSelected = _permissions.contains(entry.key);
          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: InkWell(
              borderRadius: BorderRadius.circular(14),
              onTap: () => setState(() {
                isSelected
                    ? _permissions.remove(entry.key)
                    : _permissions.add(entry.key);
              }),
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 14, vertical: 12),
                decoration: BoxDecoration(
                  color: isSelected
                      ? const Color(0xFFCCFBF1)
                      : const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: isSelected
                        ? const Color(0xFF0F766E).withOpacity(0.4)
                        : Colors.transparent,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                        isSelected
                            ? Icons.check_box_rounded
                            : Icons.check_box_outline_blank_rounded,
                        color: isSelected
                            ? const Color(0xFF0F766E)
                            : const Color(0xFFCBD5E1),
                        size: 22),
                    const SizedBox(width: 12),
                    Text(entry.value,
                        style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 14,
                            color: isSelected
                                ? const Color(0xFF0F766E)
                                : const Color(0xFF334155))),
                  ],
                ),
              ),
            ),
          );
        }),
        const SizedBox(height: 4),
        _nav(
          onBack: () => setState(() => _step = 1),
          onNext: _permissions.isEmpty
              ? null
              : () => setState(() => _step = 3),
        ),
      ],
    );
  }

  Widget _stepReview() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _title('Step 4 • Review & Confirm'),
        _reviewBlock('Personal Info', [
          _reviewRow('Name', _name),
          _reviewRow('Email', _email),
          _reviewRow('Phone', _phone),
        ]),
        const SizedBox(height: 12),
        _reviewBlock('Role & Access', [
          _reviewRow('Role', _role),
          _reviewRow('Department', _department),
          _reviewRow('Status', _status),
        ]),
        const SizedBox(height: 12),
        _reviewBlock('Permissions (${_permissions.length})', [
          Wrap(
            spacing: 8,
            runSpacing: 6,
            children: _permissions
                .map((p) => Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                          color: const Color(0xFFCCFBF1),
                          borderRadius: BorderRadius.circular(999)),
                      child: Text(
                          _allPermissions[p] ?? p,
                          style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF0F766E))),
                    ))
                .toList(),
          ),
        ]),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
                child: OutlinedButton(
                    onPressed: () => setState(() => _step = 2),
                    child: const Text('Back'))),
            const SizedBox(width: 12),
            Expanded(
                child: FilledButton(
                    onPressed: _save,
                    style: FilledButton.styleFrom(
                        backgroundColor: const Color(0xFF0F766E)),
                    child: Text(widget.isEditing
                        ? 'Update User'
                        : 'Create User'))),
          ],
        ),
      ],
    );
  }

  void _save() {
    final newUser = AppUser(
      id: widget.user?.id ??
          'u${DateTime.now().millisecondsSinceEpoch}',
      name: _name,
      email: _email,
      phone: _phone,
      role: _role,
      department: _department,
      status: _status,
      createdAt: widget.user?.createdAt ?? DateTime.now(),
      lastLogin: widget.user?.lastLogin ?? 'Never',
      permissions: _permissions.toList(),
    );

    if (widget.isEditing) {
      final idx = MockRepository.appUsers
          .indexWhere((u) => u.id == widget.user!.id);
      if (idx >= 0) MockRepository.appUsers[idx] = newUser;
    } else {
      MockRepository.appUsers.add(newUser);
    }

    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(widget.isEditing
          ? 'User updated successfully.'
          : 'User created successfully.'),
      backgroundColor: const Color(0xFF0F766E),
    ));
    Navigator.of(context).pop();
  }

  // ── helpers ──────────────────────────────────────────────────────────────

  Widget _title(String text) => Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Text(text,
            style: Theme.of(context)
                .textTheme
                .titleLarge
                ?.copyWith(fontWeight: FontWeight.w800)),
      );

  Widget _field(String label, TextEditingController ctrl,
      {TextInputType keyboardType = TextInputType.text,
      required ValueChanged<String> onChanged}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: TextFormField(
        controller: ctrl,
        keyboardType: keyboardType,
        decoration: InputDecoration(labelText: label),
        onChanged: onChanged,
      ),
    );
  }

  Widget _dropdown(String label, String value, List<String> options,
      ValueChanged<String?> onChanged) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: DropdownButtonFormField<String>(
        value: value,
        decoration: InputDecoration(labelText: label),
        items: options
            .map((o) => DropdownMenuItem(value: o, child: Text(o)))
            .toList(),
        onChanged: onChanged,
      ),
    );
  }

  Widget _nav(
      {required VoidCallback? onNext,
      required VoidCallback onBack,
      String backLabel = 'Back'}) {
    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Row(
        children: [
          Expanded(
              child: OutlinedButton(
                  onPressed: onBack, child: Text(backLabel))),
          const SizedBox(width: 12),
          Expanded(
              child: FilledButton(
                  onPressed: onNext,
                  style: FilledButton.styleFrom(
                      backgroundColor: const Color(0xFF0F766E)),
                  child: const Text('Next'))),
        ],
      ),
    );
  }

  Widget _stepBadge(int index, String label, bool active) {
    return Container(
      padding:
          const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      decoration: BoxDecoration(
        color: active
            ? const Color(0xFFCCFBF1)
            : const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 20,
            height: 20,
            decoration: BoxDecoration(
                color: active
                    ? const Color(0xFF0F766E)
                    : const Color(0xFFCBD5E1),
                borderRadius: BorderRadius.circular(999)),
            alignment: Alignment.center,
            child: Text('${index + 1}',
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.w700)),
          ),
          const SizedBox(width: 6),
          Flexible(
            child: Text(label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                    color: active
                        ? const Color(0xFF0F766E)
                        : const Color(0xFF64748B),
                    fontWeight: FontWeight.w700,
                    fontSize: 11)),
          ),
        ],
      ),
    );
  }

  Widget _reviewBlock(String title, List<Widget> rows) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
          color: const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(18)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: const TextStyle(
                  fontWeight: FontWeight.w800, fontSize: 13)),
          const SizedBox(height: 8),
          ...rows,
        ],
      ),
    );
  }

  Widget _reviewRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          Expanded(
              child: Text(label,
                  style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF475569),
                      fontSize: 13))),
          Text(value,
              style: const TextStyle(
                  fontWeight: FontWeight.w700, fontSize: 13)),
        ],
      ),
    );
  }

  String _roleHint(String role) {
    switch (role) {
      case 'Admin':
        return 'Full access to all modules and settings.';
      case 'Store Manager':
        return 'Manages inventory, suppliers and stock movements.';
      case 'Kitchen Supervisor':
        return 'Oversees kitchen issues and recipe management.';
      case 'Chef':
        return 'Access to recipes and waste recording.';
      case 'Storekeeper':
        return 'Handles daily stock movements and transfers.';
      case 'Cashier':
        return 'Processes purchases and views financial reports.';
      default:
        return 'Read-only access to assigned modules.';
    }
  }
}
