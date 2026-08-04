import 'package:catering_inventory_store_management_system/widgets/search_bar.dart';
import 'package:flutter/material.dart';
import '../../models/inventory_models.dart';
import '../../services/mock_repository.dart';
import 'expiry_detail_screen.dart';

class ExpiryListScreen extends StatefulWidget {
  const ExpiryListScreen({super.key});

  @override
  State<ExpiryListScreen> createState() => _ExpiryListScreenState();
}

class _ExpiryListScreenState extends State<ExpiryListScreen> {
  String searchQuery = '';
  String selectedFilter = 'All';

  final List<String> _filters = const [
    'All',
    'Expired',
    'Expiring Soon',
    'OK',
  ];

  List<ExpiryItem> get _items => MockRepository.expiryItems;

  List<ExpiryItem> get _filtered => _items.where((item) {
        final matchFilter =
            selectedFilter == 'All' || item.status == selectedFilter;
        final matchSearch = searchQuery.isEmpty ||
            item.item.toLowerCase().contains(searchQuery.toLowerCase()) ||
            item.category.toLowerCase().contains(searchQuery.toLowerCase()) ||
            item.batchNumber.toLowerCase().contains(searchQuery.toLowerCase());
        return matchFilter && matchSearch;
      }).toList();

  int _daysUntil(DateTime date) => date.difference(DateTime.now()).inDays;

  @override
  Widget build(BuildContext context) {
    final filtered = _filtered;
    final expiredCount = filtered.where((i) => i.status == 'Expired').length;
    final expiringSoonCount =
        filtered.where((i) => i.status == 'Expiring Soon').length;
    final okCount = filtered.where((i) => i.status == 'OK').length;

    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FB),
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
                            'Expiry Tracking',
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
                      'Monitor batch expiry dates and take action before loss.',
                      style: Theme.of(context)
                          .textTheme
                          .bodyMedium
                          ?.copyWith(fontSize: 14.5),
                    ),
                    const SizedBox(height: 16),
                    // Search
                    CateringSearch(
                      hintText: 'Search items or batch...',
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
                              selectedColor: _filterAccent(f).withOpacity(0.15),
                              labelStyle: TextStyle(
                                color: isSelected
                                    ? _filterAccent(f)
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
                        _summaryCard('Expired', '$expiredCount',
                            const Color(0xFFEF4444), Icons.event_busy_outlined),
                        _summaryCard('Expiring Soon', '$expiringSoonCount',
                            const Color(0xFFF59E0B), Icons.access_time_rounded),
                        _summaryCard('OK', '$okCount', const Color(0xFF16A34A),
                            Icons.check_circle_outline_rounded),
                        _summaryCard(
                            'Total Batches',
                            '${filtered.length}',
                            const Color(0xFF7C3AED),
                            Icons.inventory_2_outlined),
                      ],
                    ),
                    const SizedBox(height: 16),
                    // Alert banner if any expired
                    if (expiredCount > 0)
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFEE2E2),
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(color: const Color(0xFFFCA5A5)),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.warning_amber_rounded,
                                color: Color(0xFFEF4444)),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                '$expiredCount item${expiredCount > 1 ? 's' : ''} have already expired. Take immediate action.',
                                style: const TextStyle(
                                    color: Color(0xFFEF4444),
                                    fontWeight: FontWeight.w700,
                                    fontSize: 13),
                              ),
                            ),
                          ],
                        ),
                      ),
                    if (expiredCount > 0) const SizedBox(height: 14),
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
                        (context, index) =>
                            _expiryCard(context, filtered[index]),
                        childCount: filtered.length,
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _expiryCard(BuildContext context, ExpiryItem item) {
    final color = _statusColor(item.status);
    final days = item.expiryDate.difference(DateTime.now()).inDays;
    final daysLabel = days < 0
        ? '${days.abs()} days ago'
        : days == 0
            ? 'Today'
            : 'in $days days';

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
        border: item.status == 'Expired'
            ? Border.all(color: const Color(0xFFFCA5A5), width: 1.5)
            : item.status == 'Expiring Soon'
                ? Border.all(color: const Color(0xFFFDE68A), width: 1.5)
                : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(22),
          onTap: () => Navigator.of(context).push(MaterialPageRoute(
              builder: (_) => ExpiryDetailScreen(item: item))),
          child: Padding(
            padding: const EdgeInsets.all(2),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Icon(Icons.event_busy_outlined,
                          color: color, size: 26),
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
                                  item.item,
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
                                  color: color.withOpacity(0.12),
                                  borderRadius: BorderRadius.circular(999),
                                ),
                                child: Text(item.status,
                                    style: TextStyle(
                                        color: color,
                                        fontSize: 11,
                                        fontWeight: FontWeight.w700)),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text('Batch: ${item.batchNumber}',
                              style: const TextStyle(
                                  color: Color(0xFF64748B),
                                  fontWeight: FontWeight.w600,
                                  fontSize: 12)),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 6,
                  children: [
                    _infoChip(item.category),
                    _infoChip('${item.quantity} ${item.unit}'),
                    _infoChip(item.location),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Icon(
                        item.status == 'Expired'
                            ? Icons.event_busy_outlined
                            : Icons.event_available_outlined,
                        size: 14,
                        color: color),
                    const SizedBox(width: 5),
                    Text('Expires: ${_fmt(item.expiryDate)} ($daysLabel)',
                        style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: color)),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => Navigator.of(context).push(
                            MaterialPageRoute(
                                builder: (_) =>
                                    ExpiryDetailScreen(item: item))),
                        icon: const Icon(Icons.visibility_rounded, size: 16),
                        label: const Text('View Details'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    if (item.status != 'OK')
                      Expanded(
                        child: FilledButton.icon(
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                              content:
                                  Text('${item.item} marked for disposal.'),
                              backgroundColor: const Color(0xFFEF4444),
                            ));
                          },
                          icon: const Icon(Icons.delete_outline_rounded,
                              size: 16),
                          label: const Text('Dispose'),
                          style: FilledButton.styleFrom(
                              backgroundColor: const Color(0xFFEF4444)),
                        ),
                      ),
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
          const Icon(Icons.event_busy_outlined,
              size: 44, color: Color(0xFF64748B)),
          const SizedBox(height: 8),
          Text('No expiry records found',
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(fontWeight: FontWeight.w700)),
          const SizedBox(height: 4),
          Text('All batches are within safe limits.',
              style: Theme.of(context).textTheme.bodyMedium),
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
      case 'OK':
        return const Color(0xFF16A34A);
      default:
        return const Color(0xFF64748B);
    }
  }

  Color _filterAccent(String f) {
    switch (f) {
      case 'Expired':
        return const Color(0xFFEF4444);
      case 'Expiring Soon':
        return const Color(0xFFF59E0B);
      case 'OK':
        return const Color(0xFF16A34A);
      default:
        return const Color(0xFF7C3AED);
    }
  }

  String _fmt(DateTime d) => '${d.day} ${_month(d.month)} ${d.year}';

  String _month(int m) => const [
        '',
        'Jan',
        'Feb',
        'Mar',
        'Apr',
        'May',
        'Jun',
        'Jul',
        'Aug',
        'Sep',
        'Oct',
        'Nov',
        'Dec'
      ][m];
}
