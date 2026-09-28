import 'package:flutter/material.dart';

class PurchaseCreateScreen extends StatefulWidget {
  const PurchaseCreateScreen({super.key});

  @override
  State<PurchaseCreateScreen> createState() => _PurchaseCreateScreenState();
}

class _PurchaseCreateScreenState extends State<PurchaseCreateScreen> {
  int _step = 0;

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
              Text('New Purchase', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800, letterSpacing: -0.6)),
              const SizedBox(height: 8),
              Text('A premium purchase workflow for your catering operations.', style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 14.5)),
              const SizedBox(height: 16),
              Row(
                children: [
                  _stepBadge(0, 'Supplier', _step >= 0),
                  const SizedBox(width: 8),
                  _stepBadge(1, 'Items', _step >= 1),
                  const SizedBox(width: 8),
                  _stepBadge(2, 'Info', _step >= 2),
                ],
              ),
              const SizedBox(height: 16),
              if (_step == 0)
                _card(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Step 1 • Choose Supplier', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800)),
                      const SizedBox(height: 10),
                      _buildField('Supplier', 'Fresh Foods PLC'),
                      _buildField('Contact Person', 'Mulu Bekele'),
                      _buildField('Phone', '+251911223344'),
                      const SizedBox(height: 8),
                      SizedBox(width: double.infinity, child: FilledButton(onPressed: () => setState(() => _step = 1), child: const Text('Continue'))),
                    ],
                  ),
                )
              else if (_step == 1)
                _card(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Step 2 • Add Purchase Items', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800)),
                      const SizedBox(height: 10),
                      _itemRow('Chicken Breast', '40', 'Kg', '135', '10', '2000'),
                      const SizedBox(height: 10),
                      _itemRow('Basmati Rice', '25', 'Kg', '95', '0', '2375'),
                      const SizedBox(height: 14),
                      _summaryRow('Subtotal', 'ETB 4,375'),
                      _summaryRow('VAT', 'ETB 1,080'),
                      _summaryRow('Discount', 'ETB 200'),
                      _summaryRow('Grand Total', 'ETB 5,255', isStrong: true),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(child: OutlinedButton(onPressed: () => setState(() => _step = 0), child: const Text('Back'))),
                          const SizedBox(width: 12),
                          Expanded(child: FilledButton(onPressed: () => setState(() => _step = 2), child: const Text('Continue'))),
                        ],
                      ),
                    ],
                  ),
                )
              else
                _card(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Step 3 • Purchase Information', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800)),
                      const SizedBox(height: 10),
                      _buildField('Purchase Number', 'PO-1051'),
                      _buildField('Purchase Date', '24 Jul 2026'),
                      _buildField('Expected Delivery Date', '28 Jul 2026'),
                      _buildField('Notes', 'Urgent for Friday buffet'),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(child: OutlinedButton(onPressed: () => setState(() => _step = 1), child: const Text('Back'))),
                          const SizedBox(width: 12),
                          Expanded(child: FilledButton(onPressed: () {}, child: const Text('Save Purchase'))),
                        ],
                      ),
                      const SizedBox(height: 8),
                      SizedBox(width: double.infinity, child: FilledButton.tonal(onPressed: () {}, child: const Text('Submit Purchase'))),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _stepBadge(int index, String label, bool active) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(color: active ? const Color(0xFFDCEAFE) : Colors.white, borderRadius: BorderRadius.circular(16)),
        child: Center(child: Text(label, style: TextStyle(color: active ? const Color(0xFF1D4ED8) : const Color(0xFF64748B), fontWeight: FontWeight.w700))),
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

  Widget _buildField(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: TextFormField(
        initialValue: value,
        decoration: InputDecoration(labelText: label),
      ),
    );
  }

  Widget _itemRow(String name, String qty, String unit, String price, String vat, String discount) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: const Color(0xFFF8FAFC), borderRadius: BorderRadius.circular(18)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(name, style: const TextStyle(fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(child: _miniField('Qty', qty)),
              const SizedBox(width: 8),
              Expanded(child: _miniField('Unit', unit)),
              const SizedBox(width: 8),
              Expanded(child: _miniField('Price', price)),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(child: _miniField('VAT', vat)),
              const SizedBox(width: 8),
              Expanded(child: _miniField('Discount', discount)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _miniField(String label, String value) {
    return TextFormField(initialValue: value, decoration: InputDecoration(labelText: label, isDense: true));
  }

  Widget _summaryRow(String label, String value, {bool isStrong = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(children: [Expanded(child: Text(label, style: TextStyle(fontWeight: isStrong ? FontWeight.w800 : FontWeight.w600))), Text(value, style: TextStyle(fontWeight: isStrong ? FontWeight.w800 : FontWeight.w600))]),
    );
  }
}
