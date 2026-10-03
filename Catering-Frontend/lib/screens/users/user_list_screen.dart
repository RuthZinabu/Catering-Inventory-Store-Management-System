import 'package:catering_inventory_store_management_system/widgets/search_bar.dart';
import 'package:flutter/material.dart';

import '../../models/inventory_models.dart';
import '../../services/api_repository.dart';
import 'user_detail_screen.dart';
import 'user_create_screen.dart';

class UserListScreen extends StatefulWidget {
  const UserListScreen({super.key});

  @override
  State<UserListScreen> createState() => _UserListScreenState();
}

class _UserListScreenState extends State<UserListScreen> {
  String searchQuery = '';
  String selectedFilter = 'All';
  List<AppUser> _users = [];
  bool _isLoading = true;
  String? _error;

  final List<String> _filters = const [
    'All',
    'Active',
    'Inactive',
    'Suspended',
  ];

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  Future<void> _loadUsers() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final users = await ApiRepository.instance.getUsers();
      if (mounted) {
        setState(() {
          _users = users;
          _isLoading = false;
        });
      }
    } catch (error) {
      if (mounted) {
        setState(() {
          _error = error.toString();
          _isLoading = false;
        });
      }
    }
  }

  List<AppUser> get _filtered => _users.where((u) {
        final matchFilter =
            selectedFilter == 'All' || u.status == selectedFilter;
        final matchSearch = searchQuery.isEmpty ||
            u.name.toLowerCase().contains(searchQuery.toLowerCase()) ||
            u.email.toLowerCase().contains(searchQuery.toLowerCase()) ||
            u.role.toLowerCase().contains(searchQuery.toLowerCase()) ||
            u.department.toLowerCase().contains(searchQuery.toLowerCase());
        return matchFilter && matchSearch;
      }).toList();

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_error != null) {
      return Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(_error!, textAlign: TextAlign.center),
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: _loadUsers,
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final filtered = _filtered;
    final activeCount = filtered.where((u) => u.status == 'Active').length;
    final inactiveCount = filtered.where((u) => u.status == 'Inactive').length;
    final roles = filtered.map((u) => u.role).toSet().length;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 70),
        child: FloatingActionButton.extended(
          onPressed: () async {
            await Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const UserCreateScreen()),
            );
            if (mounted) _loadUsers();
          },
          backgroundColor: const Color(0xFF0F766E),
          icon: const Icon(Icons.person_add_rounded),
          label: const Text('Add User'),
        ),
      ),
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 18, 20, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            'Users & Roles',
                            style: Theme.of(context)
                                .textTheme
                                .headlineSmall
                                ?.copyWith(
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: -0.6),
                          ),
                        ),
                        IconButton(
                          onPressed: () => Navigator.of(context).pop(),
                          icon: const Icon(Icons.arrow_back_rounded),
                          style: IconButton.styleFrom(
                              backgroundColor: Colors.white,
                              padding: const EdgeInsets.all(10)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Manage team members, roles, permissions and access control.',
                      style: Theme.of(context)
                          .textTheme
                          .bodyMedium
                          ?.copyWith(fontSize: 14.5),
                    ),
                    const SizedBox(height: 16),
                    // Search
                    CateringSearch(
                      hintText: 'Search by name, role or dept...',
                      onChanged: (value) {
                        setState(() => searchQuery = value);
                      },
                    ),
                    const SizedBox(height: 14),
                    // Filter chips
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: _filters.map((f) {
                          final isSelected = f == selectedFilter;
                          return Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: ChoiceChip(
                              label: Text(f),
                              selected: isSelected,
                              onSelected: (_) =>
                                  setState(() => selectedFilter = f),
                              selectedColor: const Color(0xFFCCFBF1),
                              labelStyle: TextStyle(
                                color: isSelected
                                    ? const Color(0xFF0F766E)
                                    : const Color(0xFF475569),
                                fontWeight: FontWeight.w600,
                              ),
                              side: BorderSide.none,
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                    const SizedBox(height: 14),
                    // Summary
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: [
                        _summaryCard(
                            'Total Users',
                            '${filtered.length}',
                            const Color(0xFF0F766E),
                            Icons.people_outline_rounded),
                        _summaryCard(
                            'Active',
                            '$activeCount',
                            const Color(0xFF16A34A),
                            Icons.check_circle_outline_rounded),
                        _summaryCard('Inactive', '$inactiveCount',
                            const Color(0xFF64748B), Icons.person_off_outlined),
                        _summaryCard('Roles', '$roles', const Color(0xFF2563EB),
                            Icons.badge_outlined),
                      ],
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 112),
              sliver: filtered.isEmpty
                  ? SliverToBoxAdapter(child: _emptyState())
                  : SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) => _userCard(context, filtered[index]),
                        childCount: filtered.length,
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _userCard(BuildContext context, AppUser user) {
    final statusColor = _statusColor(user.status);
    final initials = user.name
        .split(' ')
        .take(2)
        .map((p) => p.isNotEmpty ? p[0] : '')
        .join()
        .toUpperCase();

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 18,
              offset: const Offset(0, 10))
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(22),
          onTap: () async {
            await Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => UserDetailScreen(user: user)));
            if (mounted) _loadUsers();
          },
          child: Padding(
            padding: const EdgeInsets.all(2),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CircleAvatar(
                      radius: 28,
                      backgroundColor:
                          const Color(0xFF0F766E).withOpacity(0.15),
                      child: Text(initials,
                          style: const TextStyle(
                              color: Color(0xFF0F766E),
                              fontWeight: FontWeight.w800,
                              fontSize: 16)),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  user.name,
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleMedium
                                      ?.copyWith(fontWeight: FontWeight.w700),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 5),
                                decoration: BoxDecoration(
                                  color: statusColor.withOpacity(0.12),
                                  borderRadius: BorderRadius.circular(999),
                                ),
                                child: Text(user.status,
                                    style: TextStyle(
                                        color: statusColor,
                                        fontSize: 11,
                                        fontWeight: FontWeight.w700)),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(user.email,
                              style: const TextStyle(
                                  color: Color(0xFF64748B),
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500)),
                        ],
                      ),
                    ),
                    PopupMenuButton<String>(
                      onSelected: (v) {
                        if (v == 'view') {
                          Navigator.of(context).push(MaterialPageRoute(
                            builder: (_) => UserDetailScreen(user: user),
                          )).then((_) {
                            if (mounted) _loadUsers();
                          });
                        } else if (v == 'edit') {
                          Navigator.of(context)
                              .push(MaterialPageRoute(
                                builder: (_) => UserCreateScreen(
                                    isEditing: true, user: user),
                              ))
                              .then((_) {
                            if (mounted) _loadUsers();
                          });
                        } else {
                          _deactivateUser(user);
                        }
                      },
                      itemBuilder: (_) => const [
                        PopupMenuItem(
                            value: 'view', child: Text('View Profile')),
                        PopupMenuItem(value: 'edit', child: Text('Edit User')),
                        PopupMenuItem(
                            value: 'deactivate', child: Text('Deactivate')),
                      ],
                      icon: const Icon(Icons.more_vert_rounded,
                          color: Color(0xFF64748B)),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 6,
                  children: [
                               _roleChip(_displayRole(user.role)),
                    _infoChip(user.department),
                    _infoChip('${user.permissions.length} permissions'),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    const Icon(Icons.access_time_rounded,
                        size: 14, color: Color(0xFF64748B)),
                    const SizedBox(width: 4),
                    Text('Last login: ${user.lastLogin}',
                        style: const TextStyle(
                            fontSize: 12,
                            color: Color(0xFF64748B),
                            fontWeight: FontWeight.w500)),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _summaryCard(String title, String value, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(12),
      width: MediaQuery.of(context).size.width > 360 ? 162 : 148,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 14,
              offset: const Offset(0, 8))
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
                color: color.withOpacity(0.14),
                borderRadius: BorderRadius.circular(14)),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(
                        fontWeight: FontWeight.w700, fontSize: 12)),
                const SizedBox(height: 2),
                Text(value,
                    style: const TextStyle(
                        color: Color(0xFF64748B), fontSize: 12)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoChip(String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
          color: const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(999)),
      child: Text(value,
          style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: Color(0xFF334155))),
    );
  }

  Widget _roleChip(String role) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
          color: const Color(0xFFCCFBF1),
          borderRadius: BorderRadius.circular(999)),
      child: Text(role,
          style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: Color(0xFF0F766E))),
    );
  }

  Widget _emptyState() {
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 14,
              offset: const Offset(0, 8))
        ],
      ),
      child: Column(
        children: [
          const Icon(Icons.people_outline_rounded,
              size: 44, color: Color(0xFF64748B)),
          const SizedBox(height: 8),
          Text('No users found',
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(fontWeight: FontWeight.w700)),
          const SizedBox(height: 4),
          Text('Add a team member to get started.',
              style: Theme.of(context).textTheme.bodyMedium),
        ],
      ),
    );
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'Active':
        return const Color(0xFF16A34A);
      case 'Inactive':
        return const Color(0xFF64748B);
      case 'Suspended':
        return const Color(0xFFEF4444);
      default:
        return const Color(0xFF64748B);
    }
  }

  String _displayRole(String role) => role
      .split('_')
      .map((part) => part.isEmpty
          ? part
          : '${part[0].toUpperCase()}${part.substring(1)}')
      .join(' ');

  Future<void> _deactivateUser(AppUser user) async {
    final shouldDeactivate = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Deactivate user?'),
        content: Text(
            '${user.name} will lose access until their account is reactivated.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Deactivate'),
          ),
        ],
      ),
    );
    if (shouldDeactivate != true || !mounted) return;

    try {
      await ApiRepository.instance.updateUser(user.id, {'status': 'Inactive'});
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('User deactivated.')),
      );
      await _loadUsers();
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not deactivate user: $error')),
        );
      }
    }
  }
}
