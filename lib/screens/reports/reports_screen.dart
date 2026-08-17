import 'package:flutter/material.dart';
import '../../services/mock_repository.dart';

// ════════════════════════════════════════════════════════════════════════════
//  ReportsScreen
// ════════════════════════════════════════════════════════════════════════════

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});
  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  String _period = 'Weekly';

  static const _kpiData = [
    _KpiChip('Total Items', '1,284', '+12 vs last week', Color(0xFF2563EB), Icons.inventory_2_rounded),
    _KpiChip('Inv. Value', 'ETB 48.2K', '+3.2% vs last month', Color(0xFF0F766E), Icons.account_balance_wallet_outlined),
    _KpiChip('Movements', '347', '-8% vs last week', Color(0xFF7C3AED), Icons.swap_vert_rounded),
    _KpiChip('Expiring Soon', '23', '+5 in next 7 days', Color(0xFFB45309), Icons.event_busy_outlined),
    _KpiChip('Waste / Week', 'ETB 1,240', '-2% vs last week', Color(0xFFEF4444), Icons.delete_outline_rounded),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FB),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) => SizedBox(
            height: constraints.maxHeight,
            child: CustomScrollView(
              slivers: [
                SliverToBoxAdapter(child: _buildHeader(context)),
                SliverToBoxAdapter(child: _buildKpiStrip()),
                SliverToBoxAdapter(child: _buildPeriodFilter()),
                SliverToBoxAdapter(child: _buildGridSection(context)),
                SliverToBoxAdapter(child: _buildInsightBanner(context)),
                SliverToBoxAdapter(child: _buildFooter()),
                const SliverToBoxAdapter(child: SizedBox(height: 100)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ── Header ──────────────────────────────────────────────────────────────
  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Reports',
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(fontWeight: FontWeight.w800, letterSpacing: -0.6)),
                  const SizedBox(height: 3),
                  Row(children: [
                    const Icon(Icons.circle, size: 7, color: Color(0xFF16A34A)),
                    const SizedBox(width: 5),
                    Text('Daily · Weekly · Monthly',
                        style: Theme.of(context).textTheme.bodySmall
                            ?.copyWith(color: const Color(0xFF64748B), fontSize: 12)),
                  ]),
                ],
              ),
            ),
          ]),
          const SizedBox(height: 12),
          Row(children: [
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04),
                      blurRadius: 10, offset: const Offset(0, 4))],
                ),
                child: Row(children: [
                  const Icon(Icons.calendar_today_outlined, size: 15, color: Color(0xFF64748B)),
                  const SizedBox(width: 8),
                  Text('Aug 10 – Aug 16, 2026',
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600,
                          color: Color(0xFF334155))),
                  const Spacer(),
                  const Icon(Icons.expand_more_rounded, size: 16, color: Color(0xFF94A3B8)),
                ]),
              ),
            ),
            const SizedBox(width: 8),
            _headerAction(Icons.upload_rounded, 'Export', const Color(0xFF2563EB)),
            const SizedBox(width: 8),
            _headerAction(Icons.refresh_rounded, 'Refresh', const Color(0xFF64748B)),
          ]),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _headerAction(IconData icon, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(icon, size: 14, color: color),
        const SizedBox(width: 5),
        Text(label, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: color)),
      ]),
    );
  }
