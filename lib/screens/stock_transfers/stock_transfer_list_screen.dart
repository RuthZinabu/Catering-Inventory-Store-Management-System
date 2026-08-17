import 'package:catering_inventory_store_management_system/widgets/search_bar.dart';
import 'package:flutter/material.dart';

import 'stock_transfer_create_screen.dart';
import 'stock_transfer_detail_screen.dart';
import 'stock_transfer_models.dart';

class StockTransferListScreen extends StatefulWidget {
  const StockTransferListScreen({super.key});

  @override
  State<StockTransferListScreen> createState() =>
      _StockTransferListScreenState();
}

class _StockTransferListScreenState extends State<StockTransferListScreen> {
  String searchQuery = '';

  final List<StockTransferViewModel> transfers = const [
    StockTransferViewModel(
      number: 'TR-1001',
      fromStore: 'Main Store',
      toStore: 'Branch2 Store',
      items: 4,
      quantity: 48,
      date: '24 Jul 2026',
      person: 'Alemu Bekele',
      status: 'Pending',
    ),
    StockTransferViewModel(
      number: 'TR-1002',
      fromStore: 'Main Store',
      toStore: 'Branch1 Store',
      items: 3,
      quantity: 21,
      date: '22 Jul 2026',
      person: 'Selam Tadesse',
      status: 'In Transit',
    ),
    StockTransferViewModel(
      number: 'TR-1003',
      fromStore: 'Branch1 Store',
      toStore: 'Main Store',
      items: 2,
      quantity: 16,
      date: '20 Jul 2026',
      person: 'Mekdes Hailu',
      status: 'Completed',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final filtered = transfers.where((transfer) {
      final query = searchQuery.toLowerCase();
      return query.isEmpty ||
          transfer.number.toLowerCase().contains(query) ||
          transfer.fromStore.toLowerCase().contains(query) ||
          transfer.toStore.toLowerCase().contains(query) ||
          transfer.status.toLowerCase().contains(query);
    }).toList();

    final pending = filtered.where((t) => t.status == 'Pending').length;
    final completed = filtered.where((t) => t.status == 'Completed').length;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.of(context).push(MaterialPageRoute(
            builder: (_) => const StockTransferCreateScreen())),
        icon: const Icon(Icons.add_rounded),
        label: const Text('New Transfer'),
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
                    Text('Stock Transfers',
                        style: Theme.of(context)
                            .textTheme
                            .headlineSmall
                            ?.copyWith(
                                fontWeight: FontWeight.w800,
                                letterSpacing: -0.6)),
                    const SizedBox(height: 8),
                    Text(
                        'Move stock between locations with clear status and audit-ready flows.',
                        style: Theme.of(context)
                            .textTheme
                            .bodyMedium
                            ?.copyWith(fontSize: 14.5)),
                    const SizedBox(height: 16),
                    CateringSearch(
                      hintText: 'Search transfers...',
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
                            'Total Transfers Today',
                            '${filtered.length}',
                            const Color(0xFF2563EB),
                            Icons.swap_horiz_rounded),
                        _summaryCard(
                            'Pending Transfers',
                            '$pending',
                            const Color(0xFFF59E0B),
                            Icons.pending_actions_rounded),
                        _summaryCard(
                            'Completed Transfers',
                            '$completed',
                            const Color(0xFF14B8A6),
                            Icons.check_circle_rounded),
                        _summaryCard(
                            'Total Items Transferred',
                            '84',
                            const Color(0xFF8B5CF6),
                            Icons.inventory_2_outlined),
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
                  ? SliverToBoxAdapter(
                      child: Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(24),
                            boxShadow: [
                              BoxShadow(
                                  color: Colors.black.withOpacity(0.04),
                                  blurRadius: 16,
                                  offset: const Offset(0, 8))
                            ]),
                        child: Column(
                          children: [
                            const Icon(Icons.swap_horiz_rounded,
                                size: 44, color: Color(0xFF64748B)),
                            const SizedBox(height: 8),
                            Text('No transfers found',
                                style: Theme.of(context)
                                    .textTheme
                                    .titleMedium
                                    ?.copyWith(fontWeight: FontWeight.w700)),
                            const SizedBox(height: 4),
                            Text(
                                'Create a new transfer to move stock between stores.',
                                style: Theme.of(context).textTheme.bodyMedium),
                          ],
                        ),
                      ),
                    )
                  : SliverList(
                      delegate: SliverChildBuilderDelegate((context, index) {
                        final transfer = filtered[index];
                        return Container(
                          margin: const EdgeInsets.only(bottom: 14),
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
                                        Text(transfer.number,
                                            style: Theme.of(context)
                                                .textTheme
                                                .titleMedium
                                                ?.copyWith(
                                                    fontWeight:
                                                        FontWeight.w700)),
                                        const SizedBox(height: 4),
                                        Text(
                                            '${transfer.fromStore} → ${transfer.toStore}',
                                            style: const TextStyle(
                                                color: Color(0xFF64748B),
                                                fontWeight: FontWeight.w600)),
                                      ],
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8, vertical: 5),
                                    decoration: BoxDecoration(
                                        color: _statusColor(transfer.status)
                                            .withOpacity(0.14),
                                        borderRadius:
                                            BorderRadius.circular(999)),
                                    child: Text(transfer.status,
                                        style: TextStyle(
                                            color:
                                                _statusColor(transfer.status),
                                            fontSize: 11,
                                            fontWeight: FontWeight.w700)),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Wrap(
                                spacing: 8,
                                runSpacing: 6,
                                children: [
                                  _infoChip('Items ${transfer.items}'),
                                  _infoChip('Qty ${transfer.quantity}'),
                                  _infoChip('Date ${transfer.date}'),
                                  _infoChip('By ${transfer.person}'),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: [
                                  OutlinedButton.icon(
                                      onPressed: () => Navigator.of(context)
                                          .push(MaterialPageRoute(
                                              builder: (_) =>
                                                  StockTransferDetailScreen(
                                                      transfer: transfer))),
                                      icon:
                                          const Icon(Icons.visibility_rounded),
                                      label: const Text('View Details')),
                                  OutlinedButton.icon(
                                      onPressed: () {},
                                      icon: const Icon(Icons.edit_rounded),
                                      label: const Text('Update Transfer')),
                                  OutlinedButton.icon(
                                      onPressed: () {},
                                      icon: const Icon(Icons.print_rounded),
                                      label: const Text('Print Transfer Note')),
                                ],
                              ),
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
      width: MediaQuery.of(context).size.width > 360 ? 162 : 150,
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
              ]))
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
      case 'Pending':
        return const Color(0xFFF59E0B);
      case 'In Transit':
        return const Color(0xFF2563EB);
      case 'Completed':
        return const Color(0xFF14B8A6);
      default:
        return const Color(0xFFEF4444);
    }
  }
}
