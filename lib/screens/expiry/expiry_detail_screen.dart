import 'package:flutter/material.dart';

import '../../models/inventory_models.dart';

class ExpiryDetailScreen extends StatelessWidget {
  final ExpiryItem item;

  const ExpiryDetailScreen({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    final color = _statusColor(item.status);
    final days = item.expiryDate.difference(DateTime.now()).inDays;
    final daysLabel = days < 0
        ? '${days.abs()} days overdue'
        : days == 0
            ? 'Expires today!'
            : 'Expires in $days days';

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
                            item.item,
                            style: Theme.of(context)
                                .textTheme
                                .headlineSmall
                                ?.copyWith(
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: -0.5),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 7),
                          decoration: BoxDecoration(
                            color: color.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Text(item.status,
                              style: TextStyle(
                                  color: color,
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
                        gradient: LinearGradient(
                            colors: [color, color.withOpacity(0.75)]),
                        borderRadius: BorderRadius.circular(28),
                        boxShadow: [
                          BoxShadow(
                              color: color.withOpacity(0.22),
                              blurRadius: 24,
                              offset: const Offset(0, 14))
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 56,
                                height: 56,
                                decoration: BoxDecoration(
                                  color:
                                      Colors.white.withOpacity(0.18),
                                  borderRadius:
                                      BorderRadius.circular(18),
                                ),
                                child: const Icon(
                                    Icons.event_busy_outlined,
                                    color: Colors.white,
                                    size: 28),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    Text(item.item,
                                        style: const TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.w800,
                                            fontSize: 18)),
                                    Text(
                                        '${item.category} • Batch ${item.batchNumber}',
                                        style: TextStyle(
                                            color: Colors.white
                                                .withOpacity(0.85),
                                            fontSize: 13)),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 14),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 10),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.18),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: Row(
                              children: [
                                const Icon(
                                    Icons.access_time_rounded,
                                    color: Colors.white,
                                    size: 18),
                                const SizedBox(width: 8),
                                Text(daysLabel,
                                    style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w800,
                                        fontSize: 14)),
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
                                '${item.quantity} ${item.unit}',
                                const Color(0xFF7C3AED),
                                Icons.scale_rounded)),
                        const SizedBox(width: 10),
                        Expanded(
                            child: _metricCard(
                                'Expiry Date',
                                _fmt(item.expiryDate),
                                color,
                                Icons.event_outlined)),
                        const SizedBox(width: 10),
                        Expanded(
                            child: _metricCard(
                                'Days Left',
                                days >= 0
                                    ? '$days days'
                                    : '${days.abs()} late',
                                color,
                                Icons.timer_outlined)),
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
                  _infoCard(context, 'Batch Details',
                      Icons.inventory_2_outlined, [
                    _row('Item Name', item.item),
                    _row('Category', item.category),
                    _row('Quantity',
                        '${item.quantity} ${item.unit}'),
                    _row('Batch Number', item.batchNumber),
                    _row('Location', item.location),
                  ]),
                  const SizedBox(height: 14),
                  _infoCard(
                      context, 'Expiry Status', Icons.event_busy_outlined, [
                    _row('Expiry Date', _fmt(item.expiryDate)),
                    _row('Status', item.status),
                    _row(
                        'Days Until Expiry',
                        days >= 0
                            ? '$days days'
                            : '${days.abs()} days overdue'),
                  ]),
                  const SizedBox(height: 14),
                  if (item.status != 'OK')
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
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(children: [
                            const Icon(Icons.task_alt_rounded,
                                color: Color(0xFF7C3AED), size: 20),
                            const SizedBox(width: 8),
                            Text('Recommended Actions',
                                style: Theme.of(context)
                                    .textTheme
                                    .titleMedium
                                    ?.copyWith(
                                        fontWeight: FontWeight.w700)),
                          ]),
                          const SizedBox(height: 12),
                          if (item.status == 'Expired') ...[
                            _actionTile(
                                Icons.delete_outline_rounded,
                                const Color(0xFFEF4444),
                                'Dispose item',
                                'Remove from inventory immediately.'),
                            _actionTile(
                                Icons.note_add_outlined,
                                const Color(0xFF64748B),
                                'Record as waste',
                                'Log to Waste Management module.'),
                          ] else ...[
                            _actionTile(
                                Icons.local_shipping_outlined,
                                const Color(0xFFF59E0B),
                                'Priority issue to kitchen',
                                'Use before expiry date.'),
                            _actionTile(
                                Icons.notifications_outlined,
                                const Color(0xFF2563EB),
                                'Notify kitchen team',
                                'Alert supervisors to consume soon.'),
                          ],
                        ],
                      ),
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
            Icon(icon, color: const Color(0xFF7C3AED), size: 20),
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

  Widget _actionTile(
      IconData icon, Color color, String title, String subtitle) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
                color: color.withOpacity(0.12),
                borderRadius: BorderRadius.circular(12)),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(
                        fontWeight: FontWeight.w700, fontSize: 13)),
                Text(subtitle,
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
      case 'Expired':
        return const Color(0xFFEF4444);
      case 'Expiring Soon':
        return const Color(0xFFF59E0B);
      default:
        return const Color(0xFF16A34A);
    }
  }

  String _fmt(DateTime d) =>
      '${d.day} ${_month(d.month)} ${d.year}';

  String _month(int m) => const [
        '',
        'Jan','Feb','Mar','Apr','May','Jun',
        'Jul','Aug','Sep','Oct','Nov','Dec'
      ][m];
}
