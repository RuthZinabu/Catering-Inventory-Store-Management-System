import 'package:flutter/material.dart';

import 'kitchen_issue_detail_screen.dart';
import 'kitchen_issue_models.dart';

class KitchenIssueSuccessScreen extends StatelessWidget {
  final KitchenIssueViewModel issue;

  const KitchenIssueSuccessScreen({super.key, required this.issue});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FB),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 24),
          child: Column(children: [
            const Spacer(),
            Container(padding: const EdgeInsets.all(24), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(28), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 16, offset: const Offset(0, 8))]), child: Column(children: [
              Container(width: 76, height: 76, decoration: BoxDecoration(color: const Color(0xFFDCEAFE), borderRadius: BorderRadius.circular(999)), child: const Icon(Icons.check_circle_rounded, size: 40, color: Color(0xFF2563EB))),
              const SizedBox(height: 16),
              Text('Kitchen Issue Completed Successfully', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800)),
              const SizedBox(height: 8),
              Text('The ingredients were issued through the kitchen workflow and are ready for service.', style: Theme.of(context).textTheme.bodyMedium),
              const SizedBox(height: 16),
              Wrap(spacing: 8, runSpacing: 8, children: [
                _chip(issue.number),
                _chip(issue.department),
                _chip(issue.kitchen),
              ]),
              const SizedBox(height: 16),
              Row(children: [Expanded(child: OutlinedButton(onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => KitchenIssueDetailScreen(issue: issue))), child: const Text('View Issue'))), const SizedBox(width: 10), Expanded(child: FilledButton(onPressed: () => Navigator.of(context).popUntil((route) => route.isFirst), child: const Text('Done')))]),
            ])),
            const Spacer(),
          ]),
        ),
      ),
    );
  }

  Widget _chip(String label) {
    return Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6), decoration: BoxDecoration(color: const Color(0xFFF8FAFC), borderRadius: BorderRadius.circular(999)), child: Text(label, style: const TextStyle(fontWeight: FontWeight.w600)));
  }
}
