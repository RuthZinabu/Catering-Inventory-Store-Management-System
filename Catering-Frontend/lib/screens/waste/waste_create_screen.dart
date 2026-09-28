import 'package:flutter/material.dart';

import '../../models/inventory_models.dart';
import '../../services/mock_repository.dart';

class WasteCreateScreen extends StatefulWidget {
  final bool isEditing;
  final WasteRecord? record;

  const WasteCreateScreen({super.key, this.isEditing = false, this.record});

  @override
  State<WasteCreateScreen> createState() => _WasteCreateScreenState();
}

class _WasteCreateScreenState extends State<WasteCreateScreen> {
  int _step = 0;

  late String _item;
  late String _category;
  late String _unit;
  late String _quantityText;
  late String _reason;
  late String _recordedBy;
  late String _status;
  late String _notes;
  late String _unitCostText;

  final _notesCtrl = TextEditingController();
  final _qtyCtrl = TextEditingController();
  final _costCtrl = TextEditingController();

  final List<String> _items = const [
    'Chicken Breast','Basmati Rice','Milk Powder','Cooking Oil',
    'Tomatoes','Onions','Beef Sirloin','Green Pepper','Carrot',
    'Yoghurt','Tomato Paste',
  ];
  final List<String> _categories = const [
    'Meat','Dry Food','Dairy','Oil','Vegetables','Canned Goods','Spices',
  ];
  final List<String> _units = const ['Kg','L','g','ml','pcs','Bag'];
  final List<String> _reasons = const [
    'Spoilage','Damaged Packaging','Cooking Overproduction',
    'Expired','Over-ripened','Accidental Spill','Other',
  ];
  final List<String> _staff = const [
    'Selam K.','Alemu B.','Mekdes H.','Dawit T.','Netsanet Y.',
  ];

  @override
  void initState() {
    super.initState();
    if (widget.isEditing && widget.record != null) {
      final r = widget.record!;
      _item = r.item;
      _category = r.category;
      _unit = r.unit;
      _quantityText = r.quantity.toString();
      _reason = r.reason;
      _recordedBy = r.recordedBy;
      _status = r.status;
      _notes = r.notes;
      _unitCostText = '';
    } else {
      _item = 'Chicken Breast';
      _category = 'Meat';
      _unit = 'Kg';
      _quantityText = '';
      _reason = 'Spoilage';
      _recordedBy = 'Selam K.';
      _status = 'Confirmed';
      _notes = '';
      _unitCostText = '';
    }
    _notesCtrl.text = _notes;
    _qtyCtrl.text = _quantityText;
    _costCtrl.text = _unitCostText;
  }

  @override
  void dispose() {
    _notesCtrl.dispose();
    _qtyCtrl.dispose();
    _costCtrl.dispose();
    super.dispose();
  }

  double get _estimatedCost {
    final qty = double.tryParse(_quantityText) ?? 0;
    final cost = double.tryParse(_unitCostText) ?? 0;
    return qty * cost;
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
              IconButton(
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(Icons.arrow_back_rounded),
                style: IconButton.styleFrom(
                    backgroundColor: Colors.white,
                    padding: const EdgeInsets.all(10)),
              ),
              const SizedBox(height: 16),
              Text(
                widget.isEditing ? 'Edit Waste Record' : 'Record Waste',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w800, letterSpacing: -0.6),
              ),
              const SizedBox(height: 6),
              Text(
                'Log spoilage, damage or overproduction for cost tracking.',
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium
                    ?.copyWith(fontSize: 14.5),
              ),
              const SizedBox(height: 16),
              // Steps
              Row(
                children: [
                  Expanded(child: _stepBadge(0, 'Item', _step >= 0)),
                  const SizedBox(width: 8),
                  Expanded(child: _stepBadge(1, 'Quantity', _step >= 1)),
                  const SizedBox(width: 8),
                  Expanded(child: _stepBadge(2, 'Details', _step >= 2)),
                  const SizedBox(width: 8),
                  Expanded(child: _stepBadge(3, 'Review', _step >= 3)),
                ],
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                        color: Colors.black.withOpacity(0.04),
                        blurRadius: 16,
                        offset: const Offset(0, 8))
                  ],
                ),
                child: _buildStep(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStep() {
    switch (_step) {
      case 0:
        return _stepItem();
      case 1:
        return _stepQuantity();
      case 2:
        return _stepDetails();
      default:
        return _stepReview();
    }
  }

  Widget _stepItem() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _stepTitle('Step 1 • Select Item'),
        _dropdown('Item', _item, _items, (v) => setState(() => _item = v!)),
        _dropdown('Category', _category, _categories,
            (v) => setState(() => _category = v!)),
        _dropdown('Unit', _unit, _units, (v) => setState(() => _unit = v!)),
        _nav(onBack: () => Navigator.of(context).pop(),
            backLabel: 'Cancel',
            onNext: () => setState(() => _step = 1)),
      ],
    );
  }

  Widget _stepQuantity() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _stepTitle('Step 2 • Quantity & Cost'),
        Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: TextFormField(
            controller: _qtyCtrl,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
                labelText: 'Quantity Wasted',
                suffixText: _unit),
            onChanged: (v) => setState(() => _quantityText = v),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: TextFormField(
            controller: _costCtrl,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
                labelText: 'Unit Cost (ETB)',
                suffixText: 'ETB'),
            onChanged: (v) => setState(() => _unitCostText = v),
          ),
        ),
        if (_quantityText.isNotEmpty && _unitCostText.isNotEmpty)
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
                color: const Color(0xFFFEE2E2),
                borderRadius: BorderRadius.circular(14)),
            child: Row(
              children: [
                const Icon(Icons.money_off_rounded,
                    color: Color(0xFFEF4444)),
                const SizedBox(width: 8),
                Text(
                    'Estimated loss: ETB ${_estimatedCost.toStringAsFixed(2)}',
                    style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        color: Color(0xFFEF4444))),
              ],
            ),
          ),
        const SizedBox(height: 12),
        _nav(
            onBack: () => setState(() => _step = 0),
            onNext: _quantityText.isEmpty
                ? null
                : () => setState(() => _step = 2)),
      ],
    );
  }

  Widget _stepDetails() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _stepTitle('Step 3 • Reason & Details'),
        _dropdown('Waste Reason', _reason, _reasons,
            (v) => setState(() => _reason = v!)),
        _dropdown('Recorded By', _recordedBy, _staff,
            (v) => setState(() => _recordedBy = v!)),
        _dropdown('Status', _status, ['Confirmed', 'Pending Review'],
            (v) => setState(() => _status = v!)),
        Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: TextFormField(
            controller: _notesCtrl,
            maxLines: 3,
            decoration: const InputDecoration(labelText: 'Notes'),
            onChanged: (v) => _notes = v,
          ),
        ),
        _nav(
            onBack: () => setState(() => _step = 1),
            onNext: () => setState(() => _step = 3)),
      ],
    );
  }

  Widget _stepReview() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _stepTitle('Step 4 • Review & Confirm'),
        _reviewBlock('Item Info', [
          _reviewRow('Item', _item),
          _reviewRow('Category', _category),
          _reviewRow('Unit', _unit),
        ]),
        const SizedBox(height: 12),
        _reviewBlock('Waste Details', [
          _reviewRow('Quantity', '$_quantityText $_unit'),
          _reviewRow('Est. Loss', 'ETB ${_estimatedCost.toStringAsFixed(2)}'),
          _reviewRow('Reason', _reason),
          _reviewRow('Recorded By', _recordedBy),
          _reviewRow('Status', _status),
        ]),
        if (_notes.isNotEmpty) ...[
          const SizedBox(height: 12),
          _reviewBlock('Notes', [
            Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(_notes,
                    style: const TextStyle(
                        color: Color(0xFF475569), fontSize: 13))),
          ]),
        ],
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
                child: OutlinedButton(
                    onPressed: () => setState(() => _step = 2),
                    child: const Text('Back'))),
            const SizedBox(width: 12),
            Expanded(
                child: FilledButton(
                    onPressed: _save,
                    style: FilledButton.styleFrom(
                        backgroundColor: const Color(0xFFEF4444)),
                    child: Text(widget.isEditing
                        ? 'Update Record'
                        : 'Confirm Waste'))),
          ],
        ),
      ],
    );
  }

  void _save() {
    final newRecord = WasteRecord(
      id: widget.record?.id ??
          'w${DateTime.now().millisecondsSinceEpoch}',
      number: widget.record?.number ??
          'WS-${3000 + MockRepository.wasteRecords.length + 1}',
      item: _item,
      category: _category,
      unit: _unit,
      quantity: double.tryParse(_quantityText) ?? 0,
      estimatedCost: _estimatedCost,
      reason: _reason,
      recordedBy: _recordedBy,
      date: DateTime.now(),
      status: _status,
      notes: _notes,
    );

    if (widget.isEditing) {
      final idx = MockRepository.wasteRecords
          .indexWhere((r) => r.id == widget.record!.id);
      if (idx >= 0) MockRepository.wasteRecords[idx] = newRecord;
    } else {
      MockRepository.wasteRecords.add(newRecord);
    }

    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(widget.isEditing
          ? 'Waste record updated.'
          : 'Waste recorded successfully.'),
      backgroundColor: const Color(0xFFEF4444),
    ));
    Navigator.of(context).pop();
  }

  // ── helpers ──────────────────────────────────────────────────────────────

  Widget _stepTitle(String text) => Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Text(text,
            style: Theme.of(context)
                .textTheme
                .titleLarge
                ?.copyWith(fontWeight: FontWeight.w800)),
      );

  Widget _dropdown(String label, String value, List<String> options,
      ValueChanged<String?> onChanged) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: DropdownButtonFormField<String>(
        value: value,
        decoration: InputDecoration(labelText: label),
        items: options
            .map((o) => DropdownMenuItem(value: o, child: Text(o)))
            .toList(),
        onChanged: onChanged,
      ),
    );
  }

  Widget _nav(
      {required VoidCallback? onNext,
      required VoidCallback onBack,
      String backLabel = 'Back'}) {
    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Row(
        children: [
          Expanded(
              child: OutlinedButton(
                  onPressed: onBack, child: Text(backLabel))),
          const SizedBox(width: 12),
          Expanded(
              child: FilledButton(
                  onPressed: onNext,
                  style: FilledButton.styleFrom(
                      backgroundColor: const Color(0xFFEF4444)),
                  child: const Text('Next'))),
        ],
      ),
    );
  }

  Widget _stepBadge(int index, String label, bool active) {
    return Container(
      padding:
          const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      decoration: BoxDecoration(
        color: active
            ? const Color(0xFFFEE2E2)
            : const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 20,
            height: 20,
            decoration: BoxDecoration(
                color: active
                    ? const Color(0xFFEF4444)
                    : const Color(0xFFCBD5E1),
                borderRadius: BorderRadius.circular(999)),
            alignment: Alignment.center,
            child: Text('${index + 1}',
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.w700)),
          ),
          const SizedBox(width: 6),
          Flexible(
            child: Text(label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                    color: active
                        ? const Color(0xFFEF4444)
                        : const Color(0xFF64748B),
                    fontWeight: FontWeight.w700,
                    fontSize: 11)),
          ),
        ],
      ),
    );
  }

  Widget _reviewBlock(String title, List<Widget> rows) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
          color: const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(18)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: const TextStyle(
                  fontWeight: FontWeight.w800, fontSize: 13)),
          const SizedBox(height: 8),
          ...rows,
        ],
      ),
    );
  }

  Widget _reviewRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          Expanded(
              child: Text(label,
                  style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF475569),
                      fontSize: 13))),
          Text(value,
              style: const TextStyle(
                  fontWeight: FontWeight.w700, fontSize: 13)),
        ],
      ),
    );
  }
}
