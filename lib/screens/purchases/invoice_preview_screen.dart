import 'package:flutter/material.dart';

class InvoicePreviewScreen extends StatelessWidget {
  const InvoicePreviewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FB),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              IconButton(onPressed: () => Navigator.of(context).pop(), icon: const Icon(Icons.arrow_back_rounded), style: IconButton.styleFrom(backgroundColor: Colors.white, padding: const EdgeInsets.all(10))),
              const SizedBox(height: 16),
              Text('Invoice Preview', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800, letterSpacing: -0.6)),
              const SizedBox(height: 8),
              Text('A polished invoice experience for purchase documentation.', style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 14.5)),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 16, offset: const Offset(0, 8))]),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(children: [Expanded(child: Text('Supplier', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700))), Text('Fresh Foods PLC')]),
                    const SizedBox(height: 8),
                    Row(children: [Expanded(child: Text('Purchase', style: const TextStyle(fontWeight: FontWeight.w600))), Text('PO-1048')]),
                    const SizedBox(height: 12),
                    _row('Items', '2'),
                    _row('Subtotal', 'ETB 4,375'),
                    _row('VAT', 'ETB 1,080'),
                    _row('Discount', 'ETB 200'),
                    _row('Grand Total', 'ETB 5,255', isStrong: true),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(child: OutlinedButton(onPressed: () {}, child: const Text('Download PDF'))),
                        const SizedBox(width: 10),
                        Expanded(child: FilledButton(onPressed: () {}, child: const Text('Print'))),
                      ],
                    ),
                    const SizedBox(height: 8),
                    SizedBox(width: double.infinity, child: OutlinedButton(onPressed: () {}, child: const Text('Share'))),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _row(String label, String value, {bool isStrong = false}) {
    return Padding(padding: const EdgeInsets.only(bottom: 8), child: Row(children: [Expanded(child: Text(label, style: TextStyle(fontWeight: isStrong ? FontWeight.w800 : FontWeight.w600))), Text(value, style: TextStyle(fontWeight: isStrong ? FontWeight.w800 : FontWeight.w600))]));
  }
}
