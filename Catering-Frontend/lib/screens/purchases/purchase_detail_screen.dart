import 'package:flutter/material.dart';

import 'purchase_models.dart';

class PurchaseDetailScreen extends StatelessWidget {
  final PurchaseViewModel purchase;

  const PurchaseDetailScreen({super.key, required this.purchase});

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
              Text(purchase.number, style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800, letterSpacing: -0.6)),
              const SizedBox(height: 8),
              Text(purchase.supplier, style: const TextStyle(color: Color(0xFF64748B), fontWeight: FontWeight.w600)),
              const SizedBox(height: 16),
              _card(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Purchase Summary', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
                    const SizedBox(height: 10),
                    _row('Purchase Date', purchase.date),
                    _row('Expected Delivery', purchase.expectedDelivery),
                    _row('Status', purchase.status),
                    _row('Payment Status', purchase.paymentStatus),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              _card(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Invoice Preview', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(color: const Color(0xFFF8FAFC), borderRadius: BorderRadius.circular(18)),
                      child: Column(
                        children: [
                          _row('Subtotal', 'ETB 4,375'),
                          _row('VAT', 'ETB 1,080'),
                          _row('Discount', 'ETB 200'),
                          _row('Grand Total', purchase.amount, isStrong: true),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              _card(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Timeline', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
                    const SizedBox(height: 10),
                    _timelineStep('Purchase Created', '24 Jul 2026', true),
                    _timelineStep('Approved', '25 Jul 2026', true),
                    _timelineStep('Goods Received', '27 Jul 2026', purchase.status == 'Received'),
                    _timelineStep('Completed', '28 Jul 2026', purchase.status == 'Received'),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _card({required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 16, offset: const Offset(0, 8))]),
      child: child,
    );
  }

  Widget _row(String label, String value, {bool isStrong = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(children: [Expanded(child: Text(label, style: TextStyle(fontWeight: isStrong ? FontWeight.w800 : FontWeight.w600, color: const Color(0xFF334155)))), Text(value, style: TextStyle(fontWeight: isStrong ? FontWeight.w800 : FontWeight.w600, color: const Color(0xFF64748B)))]),
    );
  }

  Widget _timelineStep(String title, String date, bool active) {
    return Row(
      children: [
        Container(width: 14, height: 14, decoration: BoxDecoration(color: active ? const Color(0xFF2563EB) : const Color(0xFFE2E8F0), borderRadius: BorderRadius.circular(999))),
        const SizedBox(width: 12),
        Expanded(child: Row(children: [Expanded(child: Text(title, style: const TextStyle(fontWeight: FontWeight.w700))), Text(date, style: const TextStyle(color: Color(0xFF64748B)))])),
      ],
    );
  }
}
