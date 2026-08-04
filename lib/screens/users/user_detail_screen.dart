import 'package:flutter/material.dart';

import '../../models/inventory_models.dart';
import 'user_create_screen.dart';

class UserDetailScreen extends StatelessWidget {
  final AppUser user;

  const UserDetailScreen({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    final statusColor = _statusColor(user.status);
    final initials = user.name
        .split(' ')
        .take(2)
        .map((p) => p.isNotEmpty ? p[0] : '')
        .join()
        .toUpperCase();

    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FB),
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 18, 20, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        IconButton(
                          onPressed: () => Navigator.of(context).pop(),
                          icon: const Icon(Icons.arrow_back_rounded),
                          style: IconButton.styleFrom(
                              backgroundColor: Colors.white,
                              padding: const EdgeInsets.all(10)),
                        ),
                        const Spacer(),
                        FilledButton.icon(
                          onPressed: () =>
                              Navigator.of(context).push(MaterialPageRoute(
                            builder: (_) => UserCreateScreen(
                                isEditing: true, user: user),
                          )),
                          icon: const Icon(Icons.edit_rounded, size: 16),
                          label: const Text('Edit'),
                          style: FilledButton.styleFrom(
                              backgroundColor: const Color(0xFF0F766E),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 10)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),
                    // Profile banner
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                            colors: [
                              Color(0xFF0F766E),
                              Color(0xFF0D9488)
                            ]),
                        borderRadius: BorderRadius.circular(28),
                        boxShadow: [
                          BoxShadow(
                              color: const Color(0xFF0F766E)
                                  .withOpacity(0.22),
                              blurRadius: 24,
                              offset: const Offset(0, 14))
                        ],
                      ),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 34,
                            backgroundColor:
                                Colors.white.withOpacity(0.2),
                            child: Text(initials,
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w800,
                                    fontSize: 22)),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment:
                                  CrossAxisAlignment.start,
                              children: [
                                Text(user.name,
                                    style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w800,
                                        fontSize: 20)),
                                const SizedBox(height: 4),
                                Text(user.role,
                                    style: TextStyle(
                                        color:
                                            Colors.white.withOpacity(0.9),
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600)),
                                const SizedBox(height: 2),
                                Text(user.department,
                                    style: TextStyle(
                                        color:
                                            Colors.white.withOpacity(0.75),
                                        fontSize: 13)),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 7),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: Text(user.status,
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 12)),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 18),
                    // Metric row
                    Row(
                      children: [
                        Expanded(
                            child: _metricCard(
                                'Permissions',
                                '${user.permissions.length}',
                                const Color(0xFF2563EB),
                                Icons.lock_outline_rounded)),
                        const SizedBox(width: 10),
                        Expanded(
                            child: _metricCard(
                                'Status',
                                user.status,
                                statusColor,
                                Icons.circle_outlined)),
                        const SizedBox(width: 10),
                        Expanded(
                            child: _metricCard(
                                'Member Since',
                                '${user.createdAt.year}',
                                const Color(0xFF7C3AED),
                                Icons.calendar_today_outlined)),
                      ],
                    ),
                    const SizedBox(height: 18),
                  ],
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  _infoCard(context, 'Contact Information',
                      Icons.contact_page_outlined, [
                    _row('Full Name', user.name),
                    _row('Email', user.email),
                    _row('Phone', user.phone),
                  ]),
                  const SizedBox(height: 14),
                  _infoCard(
                      context, 'Role & Department', Icons.badge_outlined, [
                    _row('Role', user.role),
                    _row('Department', user.department),
                    _row('Status', user.status),
                    _row('Member Since',
                        '${user.createdAt.day} ${_month(user.createdAt.month)} ${user.createdAt.year}'),
                    _row('Last Login', user.lastLogin),
                  ]),
                  const SizedBox(height: 14),
                  _infoCard(
                    context,
                    'Module Permissions (${user.permissions.length})',
                    Icons.lock_outline_rounded,
                    [
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: user.permissions
                            .map((p) => _permChip(p))
                            .toList(),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  // Audit trail placeholder
                  _infoCard(
                    context,
                    'Recent Activity',
                    Icons.history_rounded,
                    [
                      _activityRow(Icons.login_rounded,
                          const Color(0xFF2563EB),
                          'Logged in', user.lastLogin),
                      _activityRow(
                          Icons.inventory_2_outlined,
                          const Color(0xFF16A34A),
                          'Updated inventory',
                          '23 Jul 2026, 14:30'),
                      _activityRow(
                          Icons.receipt_long,
                          const Color(0xFF7C3AED),
                          'Created purchase order',
                          '22 Jul 2026, 10:15'),
                    ],
                  ),
                  const SizedBox(height: 80),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _metricCard(
      String title, String value, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(14),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
                color: color.withOpacity(0.12),
                borderRadius: BorderRadius.circular(11)),
            child: Icon(icon, color: color, size: 17),
          ),
          const SizedBox(height: 10),
          Text(value,
              style: TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 13,
                  color: color)),
          const SizedBox(height: 2),
          Text(title,
              style: const TextStyle(
                  color: Color(0xFF64748B),
                  fontSize: 11,
                  fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  Widget _infoCard(BuildContext context, String title, IconData icon,
      List<Widget> children) {
    return Container(
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Icon(icon, color: const Color(0xFF0F766E), size: 20),
            const SizedBox(width: 8),
            Text(title,
                style: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(fontWeight: FontWeight.w700)),
          ]),
          const SizedBox(height: 12),
          ...children,
        ],
      ),
    );
  }

  Widget _permChip(String perm) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
          color: const Color(0xFFCCFBF1),
          borderRadius: BorderRadius.circular(999)),
      child: Text(_capitalize(perm),
          style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: Color(0xFF0F766E))),
    );
  }

  Widget _activityRow(
      IconData icon, Color color, String title, String time) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
                color: color.withOpacity(0.12),
                borderRadius: BorderRadius.circular(12)),
            child: Icon(icon, color: color, size: 17),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(
                        fontWeight: FontWeight.w700, fontSize: 13)),
                Text(time,
                    style: const TextStyle(
                        color: Color(0xFF64748B), fontSize: 12)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _row(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 9),
      child: Row(
        children: [
          Expanded(
              child: Text(label,
                  style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF475569),
                      fontSize: 13))),
          Flexible(
            child: Text(value,
                textAlign: TextAlign.right,
                style: const TextStyle(
                    fontWeight: FontWeight.w700, fontSize: 13)),
          ),
        ],
      ),
    );
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'Active':
        return const Color(0xFF16A34A);
      case 'Suspended':
        return const Color(0xFFEF4444);
      default:
        return const Color(0xFF64748B);
    }
  }

  String _capitalize(String s) =>
      s.isEmpty ? s : s[0].toUpperCase() + s.substring(1);

  String _month(int m) => const [
        '',
        'Jan','Feb','Mar','Apr','May','Jun',
        'Jul','Aug','Sep','Oct','Nov','Dec'
      ][m];
}
