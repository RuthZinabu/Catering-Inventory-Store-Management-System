import 'package:flutter/material.dart';

import 'kitchen_issue_models.dart';

class KitchenIssueDetailScreen extends StatelessWidget {
  final KitchenIssueViewModel issue;

  const KitchenIssueDetailScreen({super.key, required this.issue});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              IconButton(onPressed: () => Navigator.of(context).pop(), icon: const Icon(Icons.arrow_back_rounded), style: IconButton.styleFrom(backgroundColor: Colors.white, padding: const EdgeInsets.all(10))),
              const SizedBox(height: 16),
              Text(issue.number, style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800, letterSpacing: -0.6)),
              const SizedBox(height: 8),
              Text('${issue.department} • ${issue.kitchen}', style: const TextStyle(color: Color(0xFF64748B), fontWeight: FontWeight.w600)),
              const SizedBox(height: 16),
              Container(padding: const EdgeInsets.all(18), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 16, offset: const Offset(0, 8))]), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(children: [Expanded(child: Text('Issue Overview', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700))), Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5), decoration: BoxDecoration(color: _statusColor(issue.status).withOpacity(0.14), borderRadius: BorderRadius.circular(999)), child: Text(issue.status, style: TextStyle(color: _statusColor(issue.status), fontSize: 11, fontWeight: FontWeight.w700)))]),
                const SizedBox(height: 10),
                _row('Requested By', issue.requestedBy),
                _row('Approved By', issue.approvedBy),
                _row('Source Store', issue.store),
                _row('Issue Date', issue.issueDate),
                _row('Items', '${issue.itemsIssued}'),
                _row('Total Quantity', '${issue.totalQuantity}'),
              ])),
              const SizedBox(height: 12),
              Container(padding: const EdgeInsets.all(18), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 16, offset: const Offset(0, 8))]), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('Ingredients Issued', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
                const SizedBox(height: 10),
                ...issue.ingredients.map((ingredient) => Padding(padding: const EdgeInsets.only(bottom: 8), child: Row(children: [Expanded(child: Text(ingredient.name, style: const TextStyle(fontWeight: FontWeight.w600))), Text('${ingredient.quantity} ${ingredient.unit}', style: const TextStyle(color: Color(0xFF64748B)))]))),
              ])),
              const SizedBox(height: 12),
              Container(padding: const EdgeInsets.all(18), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 16, offset: const Offset(0, 8))]), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('Timeline', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
                const SizedBox(height: 10),
                _timelineStep('Request Created', issue.issueDate, true),
                _timelineStep('Approved', issue.issueDate, issue.status == 'Approved' || issue.status == 'Issued'),
                _timelineStep('Ingredients Issued', issue.issueDate, issue.status == 'Issued'),
              ])),
            ],
          ),
        ),
      ),
    );
  }

  Widget _row(String label, String value) {
    return Padding(padding: const EdgeInsets.only(bottom: 8), child: Row(children: [Expanded(child: Text(label, style: const TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF334155)))), Text(value, style: const TextStyle(color: Color(0xFF64748B)))]));
  }

  Widget _timelineStep(String title, String date, bool active) {
    return Row(children: [Container(width: 14, height: 14, decoration: BoxDecoration(color: active ? const Color(0xFF2563EB) : const Color(0xFFE2E8F0), borderRadius: BorderRadius.circular(999))), const SizedBox(width: 12), Expanded(child: Row(children: [Expanded(child: Text(title, style: const TextStyle(fontWeight: FontWeight.w700))), Text(date, style: const TextStyle(color: Color(0xFF64748B)))]))]);
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
