import 'package:flutter/material.dart';

import 'stock_transfer_models.dart';

class StockTransferDetailScreen extends StatelessWidget {
  final StockTransferViewModel transfer;

  const StockTransferDetailScreen({super.key, required this.transfer});

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
              Text(transfer.number, style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800, letterSpacing: -0.6)),
              const SizedBox(height: 8),
              Text('${transfer.fromStore} → ${transfer.toStore}', style: const TextStyle(color: Color(0xFF64748B), fontWeight: FontWeight.w600)),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 16, offset: const Offset(0, 8))]),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Transfer Overview', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
                    const SizedBox(height: 10),
                    _row('Transfer Date', transfer.date),
                    _row('Person Responsible', transfer.person),
                    _row('Status', _statusLabel(transfer.status)),
                    _row('Items', '${transfer.items}'),
                    _row('Total Quantity', '${transfer.quantity}'),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 16, offset: const Offset(0, 8))]),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Transfer Items', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
                    const SizedBox(height: 10),
                    ...transfer.lines.map((line) => Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('${line.name} (${line.code})', style: const TextStyle(fontWeight: FontWeight.w700)),
                              const SizedBox(height: 3),
                              Text(
                                'Requested ${line.quantityRequested} ${line.unit} · Shipped ${line.quantityShipped} · Received ${line.quantityReceived}',
                                style: const TextStyle(color: Color(0xFF64748B)),
                              ),
                            ],
                          ),
                        )),
                    if (transfer.notes.isNotEmpty) ...[
                      const Divider(),
                      _row('Notes', transfer.notes),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _row(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(children: [Expanded(child: Text(label, style: const TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF334155)))), Text(value, style: const TextStyle(color: Color(0xFF64748B)))]),
    );
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
