import 'package:flutter/material.dart';

class GoodsReceivingScreen extends StatefulWidget {
  const GoodsReceivingScreen({super.key});

  @override
  State<GoodsReceivingScreen> createState() => _GoodsReceivingScreenState();
}

class _GoodsReceivingScreenState extends State<GoodsReceivingScreen> {
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
              Text('Goods Receiving', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800, letterSpacing: -0.6)),
              const SizedBox(height: 8),
              Text('Record deliveries and verify stock with a premium receiving workflow.', style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 14.5)),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 16, offset: const Offset(0, 8))]),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Step ${_step + 1} / 5', style: const TextStyle(fontWeight: FontWeight.w700, color: Color(0xFF2563EB))),
                    const SizedBox(height: 8),
                    if (_step == 0)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Receive Delivery', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800)),
                          const SizedBox(height: 10),
                          _buildField('Supplier', 'Fresh Foods PLC'),
                          _buildField('Purchase Number', 'PO-1048'),
                          _buildField('Delivery Date', '24 Jul 2026'),
                          _buildField('Driver Name', 'Alemu Bekele'),
                          _buildField('Vehicle Number', 'ET-2234'),
                          const SizedBox(height: 8),
                          SizedBox(width: double.infinity, child: FilledButton(onPressed: () => setState(() => _step = 1), child: const Text('Continue'))),
                        ],
                      )
                    else if (_step == 1)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Verify Quantity', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800)),
                          const SizedBox(height: 10),
                          _itemVerification('Chicken Breast', '40', 'Shortage 2'),
                          const SizedBox(height: 8),
                          _itemVerification('Basmati Rice', '25', 'Complete'),
                          const SizedBox(height: 8),
                          SizedBox(width: double.infinity, child: FilledButton(onPressed: () => setState(() => _step = 2), child: const Text('Continue'))),
                        ],
                      )
                    else if (_step == 2)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Verify Quality', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800)),
                          const SizedBox(height: 10),
                          _qualityRow('Chicken Breast', 'Accepted'),
                          const SizedBox(height: 8),
                          _qualityRow('Basmati Rice', 'Damaged'),
                          const SizedBox(height: 8),
                          SizedBox(width: double.infinity, child: FilledButton(onPressed: () => setState(() => _step = 3), child: const Text('Continue'))),
                        ],
                      )
                    else if (_step == 3)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Update Stock', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800)),
                          const SizedBox(height: 10),
                          _summaryRow('Items Accepted', '5'),
                          _summaryRow('Items Rejected', '1'),
                          _summaryRow('Stock to be Updated', '8'),
                          _summaryRow('Warehouse Location', 'Cold Room'),
                          const SizedBox(height: 8),
                          SizedBox(width: double.infinity, child: FilledButton(onPressed: () => setState(() => _step = 4), child: const Text('Continue'))),
                        ],
                      )
                    else
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Generate GRN', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800)),
                          const SizedBox(height: 10),
                          _summaryRow('GRN Number', 'GRN-2089'),
                          _summaryRow('Purchase Number', 'PO-1048'),
                          _summaryRow('Supplier', 'Fresh Foods PLC'),
                          _summaryRow('Received By', 'Alemu Bekele'),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(child: OutlinedButton(onPressed: () {}, child: const Text('Download GRN'))),
                              const SizedBox(width: 8),
                              Expanded(child: FilledButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Done'))),
                            ],
                          ),
                        ],
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildField(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: TextFormField(initialValue: value, decoration: InputDecoration(labelText: label)),
    );
  }

  Widget _itemVerification(String item, String qty, String note) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: const Color(0xFFF8FAFC), borderRadius: BorderRadius.circular(18)),
      child: Row(
        children: [
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(item, style: const TextStyle(fontWeight: FontWeight.w700)), Text(note, style: const TextStyle(color: Color(0xFF64748B), fontSize: 12))])),
          const SizedBox(width: 10),
          Text(qty, style: const TextStyle(fontWeight: FontWeight.w800)),
        ],
      ),
    );
  }

  Widget _qualityRow(String item, String status) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: const Color(0xFFF8FAFC), borderRadius: BorderRadius.circular(18)),
      child: Row(
        children: [
          Expanded(child: Text(item, style: const TextStyle(fontWeight: FontWeight.w700))),
          Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6), decoration: BoxDecoration(color: const Color(0xFFDCEAFE), borderRadius: BorderRadius.circular(999)), child: Text(status, style: const TextStyle(color: Color(0xFF2563EB), fontWeight: FontWeight.w700, fontSize: 11))),
        ],
      ),
    );
  }

  Widget _summaryRow(String label, String value) {
    return Padding(padding: const EdgeInsets.only(bottom: 8), child: Row(children: [Expanded(child: Text(label, style: const TextStyle(fontWeight: FontWeight.w600))), Text(value, style: const TextStyle(fontWeight: FontWeight.w700))]));
  }
}
