import 'package:flutter/material.dart';

class StockTransferCreateScreen extends StatefulWidget {
  const StockTransferCreateScreen({super.key});

  @override
  State<StockTransferCreateScreen> createState() => _StockTransferCreateScreenState();
}

class _StockTransferCreateScreenState extends State<StockTransferCreateScreen> {
  int _step = 0;

  Widget _stepBadge(int index, String label, bool active) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: active ? const Color(0xFFDCEAFE) : const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        children: [
          Container(
            width: 20,
            height: 20,
            decoration: BoxDecoration(color: active ? const Color(0xFF2563EB) : const Color(0xFFCBD5E1), borderRadius: BorderRadius.circular(999)),
            alignment: Alignment.center,
            child: Text('${index + 1}', style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w700)),
          ),
          const SizedBox(width: 8),
          Text(label, style: TextStyle(color: active ? const Color(0xFF2563EB) : const Color(0xFF64748B), fontWeight: FontWeight.w700, fontSize: 12)),
        ],
      ),
    );
  }

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
              Text('New Stock Transfer', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800, letterSpacing: -0.6)),
              const SizedBox(height: 8),
              Text('Move inventory between catering locations with a premium mobile workflow.', style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 14.5)),
              const SizedBox(height: 16),
              Row(
                children: [
                  _stepBadge(0, 'Locations', _step >= 0),
                  const SizedBox(width: 8),
                  _stepBadge(1, 'Items', _step >= 1),
                  const SizedBox(width: 8),
                  _stepBadge(2, 'Details', _step >= 2),
                ],
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 16, offset: const Offset(0, 8))]),
                child: _buildStepContent(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStepContent() {
    switch (_step) {
      case 0:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Step 1 • Select Locations', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800)),
            const SizedBox(height: 10),
            _buildField('Transfer Number', 'TR-1004'),
            _buildField('From Store', 'Main Store'),
            _buildField('To Store', 'Branch2 Store'),
            const SizedBox(height: 8),
            SizedBox(width: double.infinity, child: FilledButton(onPressed: () => setState(() => _step = 1), child: const Text('Next'))),
          ],
        );
      case 1:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Step 2 • Select Items', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800)),
            const SizedBox(height: 10),
            _selectItemCard('Chicken Breast', 'Meat', '48 Kg', 'Available'),
            const SizedBox(height: 8),
            _selectItemCard('Basmati Rice', 'Dry Food', '14 Kg', 'Available'),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(child: OutlinedButton(onPressed: () => setState(() => _step = 0), child: const Text('Back'))),
                const SizedBox(width: 12),
                Expanded(child: FilledButton(onPressed: () => setState(() => _step = 2), child: const Text('Next'))),
              ],
            ),
          ],
        );
      case 2:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Step 3 • Enter Quantities', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800)),
            const SizedBox(height: 10),
            _quantityCard('Chicken Breast', '48 Kg', '8 Kg', 'Kg'),
            const SizedBox(height: 8),
            _quantityCard('Basmati Rice', '14 Kg', '6 Kg', 'Kg'),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(child: OutlinedButton(onPressed: () => setState(() => _step = 1), child: const Text('Back'))),
                const SizedBox(width: 12),
                Expanded(child: FilledButton(onPressed: () => setState(() => _step = 3), child: const Text('Next'))),
              ],
            ),
          ],
        );
      case 3:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Step 4 • Transfer Details', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800)),
            const SizedBox(height: 10),
            _buildField('Transfer Date', '24 Jul 2026'),
            _buildField('Person Responsible', 'Alemu Bekele'),
            _buildField('Notes', 'Urgent for branch service'),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(child: OutlinedButton(onPressed: () => setState(() => _step = 2), child: const Text('Back'))),
                const SizedBox(width: 12),
                Expanded(child: FilledButton(onPressed: () => setState(() => _step = 4), child: const Text('Review'))),
              ],
            ),
          ],
        );
      default:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Step 5 • Review & Confirm', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800)),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: const Color(0xFFF8FAFC), borderRadius: BorderRadius.circular(18)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _summaryRow('Transfer Number', 'TR-1004'),
                  _summaryRow('From Store', 'Main Store'),
                  _summaryRow('To Store', 'Branch2 Store'),
                  _summaryRow('Transfer Date', '24 Jul 2026'),
                  _summaryRow('Person Responsible', 'Alemu Bekele'),
                  const SizedBox(height: 8),
                  const Divider(),
                  const SizedBox(height: 8),
                  _summaryRow('Items', '2'),
                  _summaryRow('Total Quantity', '14 Kg'),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(child: OutlinedButton(onPressed: () => setState(() => _step = 3), child: const Text('Back'))),
                const SizedBox(width: 12),
                Expanded(child: FilledButton(onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const StockTransferSuccessScreen())), child: const Text('Complete Transfer'))),
              ],
            ),
          ],
        );
    }
  }

  Widget _buildField(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: TextFormField(initialValue: value, decoration: InputDecoration(labelText: label)),
    );
  }

  Widget _selectItemCard(String name, String category, String stock, String availability) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: const Color(0xFFF8FAFC), borderRadius: BorderRadius.circular(18)),
      child: Row(
        children: [
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(name, style: const TextStyle(fontWeight: FontWeight.w700)), Text(category, style: const TextStyle(color: Color(0xFF64748B), fontSize: 12))])),
          const SizedBox(width: 10),
          Text(stock, style: const TextStyle(fontWeight: FontWeight.w700)),
          const SizedBox(width: 10),
          Icon(Icons.check_circle_outline_rounded, color: availability == 'Available' ? const Color(0xFF14B8A6) : const Color(0xFF64748B)),
        ],
      ),
    );
  }

  Widget _quantityCard(String name, String currentStock, String quantity, String unit) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: const Color(0xFFF8FAFC), borderRadius: BorderRadius.circular(18)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(name, style: const TextStyle(fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          Text('Current stock: $currentStock', style: const TextStyle(color: Color(0xFF64748B), fontSize: 12)),
          const SizedBox(height: 8),
          TextFormField(initialValue: quantity, decoration: InputDecoration(labelText: 'Quantity to Transfer', suffixText: unit)),
        ],
      ),
    );
  }

  Widget _summaryRow(String label, String value) {
    return Padding(padding: const EdgeInsets.only(bottom: 6), child: Row(children: [Expanded(child: Text(label, style: const TextStyle(fontWeight: FontWeight.w600))), Text(value, style: const TextStyle(fontWeight: FontWeight.w700))]));
  }
}

class StockTransferSuccessScreen extends StatelessWidget {
  const StockTransferSuccessScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 24),
          child: Column(
            children: [
              const Spacer(),
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(28), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 16, offset: const Offset(0, 8))]),
                child: Column(
                  children: [
                    Container(width: 72, height: 72, decoration: BoxDecoration(color: const Color(0xFFDCEAFE), borderRadius: BorderRadius.circular(999)), child: const Icon(Icons.check_circle_rounded, size: 38, color: Color(0xFF2563EB))),
                    const SizedBox(height: 16),
                    Text('Stock Transfer Completed Successfully', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800)),
                    const SizedBox(height: 8),
                    Text('Transfer TR-1004 was created and routed to Branch2 Store.', style: Theme.of(context).textTheme.bodyMedium),
                    const SizedBox(height: 16),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _chip('TR-1004'),
                        _chip('Main Store'),
                        _chip('Branch2 Store'),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(child: OutlinedButton(onPressed: () => Navigator.of(context).popUntil((route) => route.isFirst), child: const Text('Done'))),
                        const SizedBox(width: 10),
                        Expanded(child: FilledButton(onPressed: () {}, child: const Text('Print Transfer Note'))),
                      ],
                    ),
                  ],
                ),
              ),
              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _chip(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(color: const Color(0xFFF8FAFC), borderRadius: BorderRadius.circular(999)),
      child: Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
    );
  }
}
