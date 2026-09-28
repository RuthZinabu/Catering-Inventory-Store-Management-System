import 'package:catering_inventory_store_management_system/widgets/search_bar.dart';
import 'package:flutter/material.dart';

import 'purchase_detail_screen.dart';
import 'purchase_create_screen.dart';
import 'goods_receiving_screen.dart';
import 'purchase_return_screen.dart';
import 'invoice_preview_screen.dart';
import 'purchase_models.dart';

class PurchaseListScreen extends StatefulWidget {
  const PurchaseListScreen({super.key});

  @override
  State<PurchaseListScreen> createState() => _PurchaseListScreenState();
}

class _PurchaseListScreenState extends State<PurchaseListScreen> {
  String searchQuery = '';

  final List<PurchaseViewModel> purchases = [
    const PurchaseViewModel(
      number: 'PO-1048',
      supplier: 'Fresh Foods PLC',
      date: '24 Jul 2026',
      items: 14,
      amount: 'ETB 54,000',
      expectedDelivery: '28 Jul 2026',
      status: 'Pending',
      paymentStatus: 'Pending',
    ),
    const PurchaseViewModel(
      number: 'PO-1049',
      supplier: 'Urban Pantry',
      date: '22 Jul 2026',
      items: 8,
      amount: 'ETB 23,750',
      expectedDelivery: '26 Jul 2026',
      status: 'Approved',
      paymentStatus: 'Partially Paid',
    ),
    const PurchaseViewModel(
      number: 'PO-1050',
      supplier: 'North Star Supply',
      date: '20 Jul 2026',
      items: 6,
      amount: 'ETB 18,900',
      expectedDelivery: '24 Jul 2026',
      status: 'Received',
      paymentStatus: 'Paid',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final filtered = purchases.where((purchase) {
      final query = searchQuery.toLowerCase();
      return query.isEmpty ||
          purchase.number.toLowerCase().contains(query) ||
          purchase.supplier.toLowerCase().contains(query) ||
          purchase.status.toLowerCase().contains(query);
    }).toList();

    final pendingDeliveries = filtered
        .where((p) => p.status == 'Pending' || p.status == 'Approved')
        .length;
    final goodsReceivedToday =
        filtered.where((p) => p.status == 'Received').length;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 70),
        child: FloatingActionButton.extended(
          onPressed: () async {
            await Navigator.of(context).push(MaterialPageRoute(
                builder: (_) => const PurchaseCreateScreen()));
            if (mounted) setState(() {});
          },
          icon: const Icon(Icons.add_rounded),
          label: const Text('New'),
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
                    Text('Purchases',
                        style: Theme.of(context)
                            .textTheme
                            .headlineSmall
                            ?.copyWith(
                                fontWeight: FontWeight.w800,
                                letterSpacing: -0.6)),
                    const SizedBox(height: 8),
                    Text(
                        'Manage purchase flows, receiving, and supplier payments.',
                        style: Theme.of(context)
                            .textTheme
                            .bodyMedium
                            ?.copyWith(fontSize: 14.5)),
                    const SizedBox(height: 16),
                    CateringSearch(
                      hintText: 'Search purchases...',
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
                            'Total Purchases',
                            '${filtered.length}',
                            const Color(0xFF2563EB),
                            Icons.receipt_long_outlined),
                        _summaryCard(
                            'Pending Deliveries',
                            '$pendingDeliveries',
                            const Color(0xFFF59E0B),
                            Icons.local_shipping_outlined),
                        _summaryCard(
                            'Goods Received Today',
                            '$goodsReceivedToday',
                            const Color(0xFF14B8A6),
                            Icons.inventory_2_outlined),
                        _summaryCard(
                            'Total Purchase Value',
                            'ETB 96k',
                            const Color(0xFF8B5CF6),
                            Icons.account_balance_wallet_rounded),
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
                            const Icon(Icons.receipt_long_outlined,
                                size: 44, color: Color(0xFF64748B)),
                            const SizedBox(height: 8),
                            Text('No purchases found',
                                style: Theme.of(context)
                                    .textTheme
                                    .titleMedium
                                    ?.copyWith(fontWeight: FontWeight.w700)),
                            const SizedBox(height: 4),
                            Text(
                                'Try a different search term or create a new purchase.',
                                style: Theme.of(context).textTheme.bodyMedium),
                          ],
                        ),
                      ),
                    )
                  : SliverList(
                      delegate: SliverChildBuilderDelegate((context, index) {
                        final purchase = filtered[index];
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
                                        Text(purchase.number,
                                            style: Theme.of(context)
                                                .textTheme
                                                .titleMedium
                                                ?.copyWith(
                                                    fontWeight:
                                                        FontWeight.w700)),
                                        const SizedBox(height: 4),
                                        Text(purchase.supplier,
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
                                        color: _statusColor(purchase.status)
                                            .withOpacity(0.14),
                                        borderRadius:
                                            BorderRadius.circular(999)),
                                    child: Text(purchase.status,
                                        style: TextStyle(
                                            color:
                                                _statusColor(purchase.status),
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
                                  _infoChip('Date ${purchase.date}'),
                                  _infoChip('Items ${purchase.items}'),
                                  _infoChip(
                                      'Delivery ${purchase.expectedDelivery}'),
                                ],
                              ),
                              const SizedBox(height: 10),
                              Text(purchase.amount,
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleLarge
                                      ?.copyWith(
                                          fontWeight: FontWeight.w800,
                                          color: const Color(0xFF0F172A))),
                              const SizedBox(height: 10),
                              Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: [
                                  OutlinedButton.icon(
                                      onPressed: () => Navigator.of(context)
                                          .push(MaterialPageRoute(
                                              builder: (_) =>
                                                  PurchaseDetailScreen(
                                                      purchase: purchase))),
                                      icon:
                                          const Icon(Icons.visibility_rounded),
                                      label: const Text('View Details')),
                                  OutlinedButton.icon(
                                      onPressed: () {},
                                      icon: const Icon(Icons.edit_rounded),
                                      label: const Text('Update Purchase')),
                                  OutlinedButton.icon(
                                      onPressed: () => Navigator.of(context)
                                          .push(MaterialPageRoute(
                                              builder: (_) =>
                                                  const GoodsReceivingScreen())),
                                      icon: const Icon(
                                          Icons.move_to_inbox_rounded),
                                      label: const Text('Receive Goods')),
                                  OutlinedButton.icon(
                                      onPressed: () => Navigator.of(context)
                                          .push(MaterialPageRoute(
                                              builder: (_) =>
                                                  const InvoicePreviewScreen())),
                                      icon: const Icon(Icons.print_rounded),
                                      label: const Text('Print Invoice')),
                                  OutlinedButton.icon(
                                      onPressed: () => Navigator.of(context)
                                          .push(MaterialPageRoute(
                                              builder: (_) =>
                                                  const PurchaseReturnScreen())),
                                      icon: const Icon(
                                          Icons.keyboard_return_rounded),
                                      label: const Text('Return Purchase')),
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
      width: MediaQuery.of(context).size.width > 360 ? 160 : 150,
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
      case 'Approved':
        return const Color(0xFF2563EB);
      case 'Received':
        return const Color(0xFF14B8A6);
      default:
        return const Color(0xFFEF4444);
    }
  }
}
