import 'package:catering_inventory_store_management_system/widgets/search_bar.dart';
import 'package:flutter/material.dart';

import '../../services/api_repository.dart';
import 'kitchen_issue_create_screen.dart';
import 'kitchen_issue_detail_screen.dart';
import 'kitchen_issue_models.dart';

class KitchenIssueListScreen extends StatefulWidget {
  const KitchenIssueListScreen({super.key});

  @override
  State<KitchenIssueListScreen> createState() => _KitchenIssueListScreenState();
}

class _KitchenIssueListScreenState extends State<KitchenIssueListScreen> {
  String searchQuery = '';
  bool _loading = true;
  String? _error;
  List<KitchenIssueViewModel> issues = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final records = await ApiRepository.instance.getKitchenIssues();
      if (!mounted) return;
      setState(() {
        issues = records;
        _loading = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _error = error.toString();
        _loading = false;
      });
    }
  }

  Future<void> _runAction(
    KitchenIssueViewModel issue,
    Future<void> Function(String) action,
  ) async {
    try {
      await action(issue.id);
      await _load();
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Kitchen issue action failed: $error')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final filtered = issues.where((issue) {
      final query = searchQuery.toLowerCase();
      return query.isEmpty ||
          issue.number.toLowerCase().contains(query) ||
          issue.department.toLowerCase().contains(query) ||
          issue.kitchen.toLowerCase().contains(query) ||
          issue.status.toLowerCase().contains(query);
    }).toList();

    final pending =
        filtered.where((issue) => issue.status == 'Pending Approval').length;
    final issued = filtered.where((issue) => issue.status == 'Issued').length;
    final departments =
        filtered.map((issue) => issue.department).toSet().length;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 72),
        child: FloatingActionButton.extended(
          onPressed: () async {
            final created = await Navigator.of(context).push<bool>(
              MaterialPageRoute(builder: (_) => const KitchenIssueCreateScreen()),
            );
            if (created == true) _load();
          },
          icon: const Icon(Icons.add_rounded),
          label: const Text('New Kitchen Issue'),
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
                    Text('Kitchen Issues',
                        style: Theme.of(context)
                            .textTheme
                            .headlineSmall
                            ?.copyWith(
                                fontWeight: FontWeight.w800,
                                letterSpacing: -0.6)),
                    const SizedBox(height: 8),
                    Text(
                        'Issue ingredients to kitchens with approval-ready tracking flows.',
                        style: Theme.of(context)
                            .textTheme
                            .bodyMedium
                            ?.copyWith(fontSize: 14.5)),
                    const SizedBox(height: 16),
                    CateringSearch(
                      hintText: 'Search issues...',
                      onChanged: (value) {
                        setState(() => searchQuery = value);
                      },
                    ),
                    const SizedBox(height: 16),
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: [
                        _summaryCard(
                            'Total Issues Today',
                            '${filtered.length}',
                            const Color(0xFF2563EB),
                            Icons.assignment_turned_in_rounded),
                        _summaryCard('Ingredients Issued', '$issued',
                            const Color(0xFF14B8A6), Icons.kitchen_rounded),
                        _summaryCard(
                            'Pending Approvals',
                            '$pending',
                            const Color(0xFFF59E0B),
                            Icons.pending_actions_rounded),
                        _summaryCard('Departments Served', '$departments',
                            const Color(0xFF8B5CF6), Icons.business_outlined),
                      ],
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 112),
              sliver: _loading
                  ? const SliverToBoxAdapter(
                      child: Padding(
                        padding: EdgeInsets.all(32),
                        child: Center(child: CircularProgressIndicator()),
                      ),
                    )
                  : _error != null
                      ? SliverToBoxAdapter(
                          child: Column(
                            children: [
                              Text(_error!, textAlign: TextAlign.center),
                              const SizedBox(height: 12),
                              OutlinedButton.icon(
                                onPressed: _load,
                                icon: const Icon(Icons.refresh),
                                label: const Text('Retry'),
                              ),
                            ],
                          ),
                        )
                      : filtered.isEmpty
                          ? const SliverToBoxAdapter(
                              child: Padding(
                                padding: EdgeInsets.all(24),
                                child: Center(child: Text('No kitchen issues found.')),
                              ),
                            )
                          : SliverList(
                delegate: SliverChildBuilderDelegate((context, index) {
                  final issue = filtered[index];
                  return Container(
                    margin: const EdgeInsets.only(bottom: 13),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(22),
                        boxShadow: [
                          BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 16,
                              offset: const Offset(0, 10))
                        ]),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                                child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                  Text(issue.number,
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleMedium
                                          ?.copyWith(
                                              fontWeight: FontWeight.w700)),
                                  const SizedBox(height: 4),
                                  Text('${issue.department} • ${issue.kitchen}',
                                      style: const TextStyle(
                                          color: Color(0xFF64748B),
                                          fontWeight: FontWeight.w600))
                                ])),
                            Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 5),
                                decoration: BoxDecoration(
                                    color: _statusColor(issue.status)
                                        .withOpacity(0.14),
                                    borderRadius: BorderRadius.circular(999)),
                                child: Text(issue.status,
                                    style: TextStyle(
                                        color: _statusColor(issue.status),
                                        fontSize: 11,
                                        fontWeight: FontWeight.w700))),
                            PopupMenuButton<String>(
                              onSelected: (value) {
                                if (value == 'view') {
                                  Navigator.of(context).push(MaterialPageRoute(
                                      builder: (_) => KitchenIssueDetailScreen(
                                          issue: issue)));
                                } else if (value == 'approve') {
                                  _runAction(
                                    issue,
                                    (id) => ApiRepository.instance.approveKitchenIssue(id),
                                  );
                                } else if (value == 'issue') {
                                  _runAction(
                                    issue,
                                    ApiRepository.instance.issueKitchenIssue,
                                  );
                                } else if (value == 'cancel') {
                                  _runAction(
                                    issue,
                                    ApiRepository.instance.cancelKitchenIssue,
                                  );
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                          content: Text(
                                              'Issue note ready for print.')));
                                }
                              },
                              itemBuilder: (_) => [
                                const PopupMenuItem(value: 'view', child: Text('View Details')),
                                if (issue.status == 'Pending Approval') ...[
                                  const PopupMenuItem(value: 'approve', child: Text('Approve')),
                                  const PopupMenuItem(value: 'cancel', child: Text('Cancel Issue')),
                                ],
                                if (issue.status == 'Approved') ...[
                                  const PopupMenuItem(value: 'issue', child: Text('Issue Stock')),
                                  const PopupMenuItem(value: 'cancel', child: Text('Cancel Issue')),
                                ],
                                const PopupMenuItem(value: 'print', child: Text('Print Issue Note')),
                              ],
                              icon: const Icon(Icons.more_vert_rounded,
                                  color: Color(0xFF64748B)),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Wrap(spacing: 8, runSpacing: 6, children: [
                          _infoChip('Requested ${issue.requestedBy}'),
                          _infoChip('Approved ${issue.approvedBy}'),
                          _infoChip('Date ${issue.issueDate}'),
                        ]),
                        const SizedBox(height: 10),
                        Wrap(spacing: 8, runSpacing: 6, children: [
                          _infoChip('Items ${issue.itemsIssued}'),
                          _infoChip('Qty ${issue.totalQuantity}'),
                        ]),
                        const SizedBox(height: 10),
                        SizedBox(
                            width: double.infinity,
                            child: OutlinedButton.icon(
                                onPressed: () => Navigator.of(context).push(
                                    MaterialPageRoute(
                                        builder: (_) =>
                                            KitchenIssueDetailScreen(
                                                issue: issue))),
                                icon: const Icon(Icons.visibility_rounded),
                                label: const Text('View Full Issue'))),
                      ],
                    ),
                  );
                }, childCount: filtered.length),
              ),
            ),
          ],
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
          ]),
      child: Row(
        children: [
          Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                  color: color.withOpacity(0.14),
                  borderRadius: BorderRadius.circular(14)),
              child: Icon(icon, color: color, size: 20)),
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
                    style:
                        const TextStyle(color: Color(0xFF64748B), fontSize: 12))
              ])),
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

  Color _statusColor(String status) {
    switch (status) {
      case 'Pending Approval':
        return const Color(0xFFF59E0B);
      case 'Approved':
        return const Color(0xFF2563EB);
      case 'Issued':
        return const Color(0xFF14B8A6);
      case 'Cancelled':
        return const Color(0xFFEF4444);
      default:
        return const Color(0xFF64748B);
    }
  }
}
