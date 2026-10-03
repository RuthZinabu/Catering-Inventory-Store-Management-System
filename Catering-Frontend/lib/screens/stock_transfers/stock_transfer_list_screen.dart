import 'package:catering_inventory_store_management_system/widgets/search_bar.dart';
import 'package:flutter/material.dart';
import '../../services/api_repository.dart';

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
  List<StockTransferViewModel> transfers = [];
  bool _loading = true;
  String? _error;

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
      final result = await ApiRepository.instance.getStockTransfers();
      if (!mounted) return;
      setState(() {
        transfers = result;
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
    StockTransferViewModel transfer,
    Future<void> Function(String) action,
  ) async {
    try {
      await action(transfer.id);
      await _load();
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Transfer action failed: $error')),
        );
      }
    }
  }

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

    final pending = filtered.where((t) => t.status == 'pending').length;
    final completed = filtered.where((t) => t.status == 'received').length;
    final totalItems = filtered.fold<int>(0, (sum, transfer) => sum + transfer.items);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 72),
        child: FloatingActionButton.extended(
          onPressed: () async {
            final created = await Navigator.of(context).push<bool>(
              MaterialPageRoute(builder: (_) => const StockTransferCreateScreen()),
            );
            if (created == true) _load();
          },
          icon: const Icon(Icons.add_rounded),
          label: const Text('New Transfer'),
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
                            '$totalItems',
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
                                    child: Text(_statusLabel(transfer.status),
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
                                  if (transfer.status == 'pending') ...[
                                    OutlinedButton.icon(
                                      onPressed: () => _runAction(
                                        transfer,
                                        ApiRepository.instance.approveStockTransfer,
                                      ),
                                      icon: const Icon(Icons.check_circle_outline),
                                      label: const Text('Approve'),
                                    ),
                                    OutlinedButton.icon(
                                      onPressed: () => _runAction(
                                        transfer,
                                        ApiRepository.instance.cancelStockTransfer,
                                      ),
                                      icon: const Icon(Icons.cancel_outlined),
                                      label: const Text('Cancel'),
                                    ),
                                  ],
                                  if (transfer.status == 'approved')
                                    OutlinedButton.icon(
                                      onPressed: () => _runAction(
                                        transfer,
                                        ApiRepository.instance.shipStockTransfer,
                                      ),
                                      icon: const Icon(Icons.local_shipping_outlined),
                                      label: const Text('Dispatch'),
                                    ),
                                  if (transfer.status == 'in_transit')
                                    OutlinedButton.icon(
                                      onPressed: () => _runAction(
                                        transfer,
                                        ApiRepository.instance.receiveStockTransfer,
                                      ),
                                      icon: const Icon(Icons.inventory_outlined),
                                      label: const Text('Receive'),
                                    ),
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
      case 'pending':
        return const Color(0xFFF59E0B);
      case 'approved':
        return const Color(0xFF2563EB);
      case 'in_transit':
        return const Color(0xFF8B5CF6);
      case 'received':
        return const Color(0xFF14B8A6);
      case 'cancelled':
        return const Color(0xFFEF4444);
      default:
        return const Color(0xFFEF4444);
    }
  }

  String _statusLabel(String status) => switch (status) {
        'in_transit' => 'In Transit',
        'received' => 'Received',
        'pending' => 'Pending',
        'approved' => 'Approved',
        'cancelled' => 'Cancelled',
        _ => status,
      };
}
