import 'package:flutter/material.dart';

import '../../models/inventory_models.dart';

class WasteDetailScreen extends StatelessWidget {
  final WasteRecord record;

  const WasteDetailScreen({super.key, required this.record});

  @override
  Widget build(BuildContext context) {
    final statusColor = record.status == 'Confirmed'
        ? const Color(0xFF64748B)
        : const Color(0xFFF59E0B);

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
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            record.number,
                            style: Theme.of(context)
                                .textTheme
                                .headlineSmall
                                ?.copyWith(
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: -0.5),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 7),
                          decoration: BoxDecoration(
                            color: statusColor.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Text(record.status,
                              style: TextStyle(
                                  color: statusColor,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 12)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),
                    // Hero banner
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                            colors: [
                              Color(0xFFEF4444),
                              Color(0xFFDC2626)
                            ]),
                        borderRadius: BorderRadius.circular(28),
                        boxShadow: [
                          BoxShadow(
                              color: Colors.red.withOpacity(0.2),
                              blurRadius: 24,
                              offset: const Offset(0, 14))
                        ],
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 60,
                            height: 60,
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(18),
                            ),
                            child: const Icon(
                                Icons.delete_outline_rounded,
                                color: Colors.white,
                                size: 30),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(record.item,
                                    style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w800,
                                        fontSize: 18)),
                                const SizedBox(height: 4),
                                Text(
                                    '${record.category} • ${record.quantity} ${record.unit}',
                                    style: TextStyle(
                                        color:
                                            Colors.white.withOpacity(0.85),
                                        fontSize: 13)),
                              ],
                            ),
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
                                'Quantity',
                                '${record.quantity} ${record.unit}',
                                const Color(0xFFEF4444),
                                Icons.scale_rounded)),
                        const SizedBox(width: 10),
                        Expanded(
                            child: _metricCard(
                                'Est. Loss',
                                'ETB ${record.estimatedCost.toStringAsFixed(0)}',
                                const Color(0xFF7C3AED),
                                Icons.money_off_rounded)),
                        const SizedBox(width: 10),
                        Expanded(
                            child: _metricCard(
                                'Category',
                                record.category,
                                const Color(0xFF2563EB),
                                Icons.category_rounded)),
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
                  _infoCard(context, 'Waste Details', Icons.info_outline_rounded, [
                    _row('Record Number', record.number),
                    _row('Item', record.item),
                    _row('Category', record.category),
                    _row('Quantity',
                        '${record.quantity} ${record.unit}'),
                    _row('Estimated Cost',
                        'ETB ${record.estimatedCost.toStringAsFixed(2)}'),
                    _row('Reason', record.reason),
                  ]),
                  const SizedBox(height: 14),
                  _infoCard(context, 'Responsibility & Date',
                      Icons.person_outline_rounded, [
                    _row('Recorded By', record.recordedBy),
                    _row('Date',
                        '${record.date.day} ${_month(record.date.month)} ${record.date.year}'),
                    _row('Status', record.status),
                  ]),
                  const SizedBox(height: 14),
                  _infoCard(context, 'Notes',
                      Icons.notes_rounded, [
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(record.notes,
                          style: Theme.of(context).textTheme.bodyMedium),
                    ),
                  ]),
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
            Icon(icon, color: const Color(0xFFEF4444), size: 20),
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
          Text(value,
              style: const TextStyle(
                  fontWeight: FontWeight.w700, fontSize: 13)),
        ],
      ),
    );
  }

  String _month(int m) => const [
        '',
        'Jan','Feb','Mar','Apr','May','Jun',
        'Jul','Aug','Sep','Oct','Nov','Dec'
      ][m];
}
