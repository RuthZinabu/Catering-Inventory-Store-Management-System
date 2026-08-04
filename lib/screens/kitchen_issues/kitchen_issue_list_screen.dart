import 'package:catering_inventory_store_management_system/widgets/search_bar.dart';
import 'package:flutter/material.dart';

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
  final List<KitchenIssueViewModel> issues = [
    KitchenIssueViewModel(
      number: 'KI-2001',
      department: 'Banquet Hall',
      kitchen: 'Main Kitchen',
      requestedBy: 'Selam K.',
      approvedBy: 'Alemu B.',
      issueDate: '24 Jul 2026',
      status: 'Pending Approval',
      itemsIssued: 4,
      totalQuantity: 28,
      ingredients: [
        KitchenIssueIngredientViewModel(
            name: 'Chicken Breast',
            category: 'Meat',
            unit: 'Kg',
            availableStock: 80,
            quantity: 12),
        KitchenIssueIngredientViewModel(
            name: 'Rice',
            category: 'Dry Food',
            unit: 'Kg',
            availableStock: 60,
            quantity: 16),
      ],
    ),
    KitchenIssueViewModel(
      number: 'KI-2002',
      department: 'Branch 2',
      kitchen: 'Satellite Kitchen',
      requestedBy: 'Mekdes H.',
      approvedBy: 'Dawit T.',
      issueDate: '23 Jul 2026',
      status: 'Approved',
      itemsIssued: 3,
      totalQuantity: 21,
      ingredients: [
        KitchenIssueIngredientViewModel(
            name: 'Onions',
            category: 'Vegetables',
            unit: 'Kg',
            availableStock: 45,
            quantity: 9),
      ],
    ),
    KitchenIssueViewModel(
      number: 'KI-2003',
      department: 'Executive Lounge',
      kitchen: 'Prep Kitchen',
      requestedBy: 'Netsanet Y.',
      approvedBy: 'Sara M.',
      issueDate: '22 Jul 2026',
      status: 'Issued',
      itemsIssued: 2,
      totalQuantity: 14,
      ingredients: [
        KitchenIssueIngredientViewModel(
            name: 'Milk',
            category: 'Dairy',
            unit: 'L',
            availableStock: 30,
            quantity: 8),
      ],
    ),
  ];

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
      backgroundColor: const Color(0xFFF4F6FB),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.of(context).push(MaterialPageRoute(
            builder: (_) => const KitchenIssueCreateScreen())),
        icon: const Icon(Icons.add_rounded),
        label: const Text('New Kitchen Issue'),
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
              sliver: SliverList(
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
                                } else if (value == 'update') {
                                  Navigator.of(context)
                                      .push(MaterialPageRoute(
                                          builder: (_) =>
                                              KitchenIssueCreateScreen(
                                                  isEditing: true,
                                                  issue: issue)))
                                      .then((_) => setState(() {}));
                                } else if (value == 'cancel') {
                                  setState(() => issue.status = 'Cancelled');
                                  ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                          content: Text(
                                              'Issue marked as cancelled.')));
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                          content: Text(
                                              'Issue note ready for print.')));
                                }
                              },
                              itemBuilder: (_) => const [
                                PopupMenuItem(
                                    value: 'view', child: Text('View Details')),
                                PopupMenuItem(
                                    value: 'update',
                                    child: Text('Update Issue')),
                                PopupMenuItem(
                                    value: 'print',
                                    child: Text('Print Issue Note')),
                                PopupMenuItem(
                                    value: 'cancel',
                                    child: Text('Cancel Issue')),
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
