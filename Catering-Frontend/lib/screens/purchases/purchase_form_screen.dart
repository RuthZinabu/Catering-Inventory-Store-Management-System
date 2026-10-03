import 'package:flutter/material.dart';

import '../../services/api_service.dart';
import 'purchase_models.dart';

class PurchaseFormScreen extends StatefulWidget {
  final PurchaseViewModel? purchase;

  const PurchaseFormScreen({super.key, this.purchase});

  @override
  State<PurchaseFormScreen> createState() => _PurchaseFormScreenState();
}

class _PurchaseFormScreenState extends State<PurchaseFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _number = TextEditingController();
  final _orderDate = TextEditingController();
  final _deliveryDate = TextEditingController();
  final _notes = TextEditingController();
  final List<_PurchaseLineForm> _lines = [];
  List<Map<String, dynamic>> _suppliers = [];
  List<Map<String, dynamic>> _catalog = [];
  String? _supplierId;
  String? _error;
  bool _loading = true;
  bool _saving = false;

  bool get _editing => widget.purchase != null;

  @override
  void initState() {
    super.initState();
    final purchase = widget.purchase;
    _number.text = purchase?.number ?? '';
    _orderDate.text = purchase?.date ?? _today();
    _deliveryDate.text = purchase?.expectedDelivery ?? '';
    _notes.text = purchase?.notes ?? '';
    _supplierId = purchase?.supplierId;
    for (final line in purchase?.items ?? const <PurchaseLineViewModel>[]) {
      _lines.add(_PurchaseLineForm.fromModel(line));
    }
    _loadOptions();
  }

  @override
  void dispose() {
    _number.dispose();
    _orderDate.dispose();
    _deliveryDate.dispose();
    _notes.dispose();
    for (final line in _lines) {
      line.dispose();
    }
    super.dispose();
  }

  Future<void> _loadOptions() async {
    try {
      final supplierResponse = await ApiClient.instance.get('/suppliers?per_page=100');
      final itemResponse = await ApiClient.instance.get('/items?per_page=100');
      if (!mounted) return;
      setState(() {
        _suppliers = List<Map<String, dynamic>>.from(
          ((supplierResponse['data'] as Map)['suppliers'] as List? ?? const [])
              .map((entry) => Map<String, dynamic>.from(entry as Map)),
        ).where((supplier) => supplier['status'] == 'Active').toList();
        _catalog = List<Map<String, dynamic>>.from(
          ((itemResponse['data'] as Map)['items'] as List? ?? const [])
              .map((entry) => Map<String, dynamic>.from(entry as Map)),
        );
        _loading = false;
        if (_supplierId != null && !_suppliers.any((row) => row['id'] == _supplierId)) {
          _supplierId = null;
        }
      });
    } on ApiException catch (error) {
      if (mounted) setState(() {
        _loading = false;
        _error = error.message;
      });
    }
  }

  Future<void> _save(String status) async {
    if (!_formKey.currentState!.validate()) return;
    if (_lines.isEmpty) {
      setState(() => _error = 'Add at least one item to the purchase order.');
      return;
    }
    final storeId = ApiClient.instance.storeId;
    if (storeId == null) {
      setState(() => _error = 'No destination store is selected for this session.');
      return;
    }

    setState(() {
      _saving = true;
      _error = null;
    });
    final payload = <String, dynamic>{
      'supplier_id': _supplierId,
      'destination_store_id': storeId,
      'order_date': _orderDate.text.trim(),
      'expected_delivery_date': _deliveryDate.text.trim().isEmpty ? null : _deliveryDate.text.trim(),
      'status': status,
      'notes': _notes.text.trim().isEmpty ? null : _notes.text.trim(),
      'items': _lines.map((line) => line.toJson()).toList(),
    };
    if (_number.text.trim().isNotEmpty) payload['number'] = _number.text.trim();

    try {
      if (_editing) {
        await ApiClient.instance.put('/purchase-orders/${widget.purchase!.id}', payload);
      } else {
        await ApiClient.instance.post('/purchase-orders', payload);
      }
      if (mounted) Navigator.of(context).pop(true);
    } on ApiException catch (error) {
      if (mounted) setState(() {
        _saving = false;
        _error = error.message;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final subtotal = _lines.fold<double>(0, (sum, line) => sum + line.quantityValue * line.unitPriceValue);
    final vat = _lines.fold<double>(0, (sum, line) => sum + line.vatAmount);
    final discount = _lines.fold<double>(0, (sum, line) => sum + line.discountAmount);

    return Scaffold(
      appBar: AppBar(title: Text(_editing ? 'Update Purchase' : 'New Purchase')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
                children: [
                  DropdownButtonFormField<String>(
                    value: _supplierId,
                    decoration: const InputDecoration(labelText: 'Supplier'),
                    items: _suppliers
                        .map((supplier) => DropdownMenuItem<String>(
                              value: supplier['id'] as String,
                              child: Text(supplier['company'] as String? ?? supplier['name'] as String? ?? ''),
                            ))
                        .toList(),
                    onChanged: (value) => setState(() => _supplierId = value),
                    validator: (value) => value == null ? 'Select a supplier' : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _number,
                    decoration: const InputDecoration(labelText: 'Purchase Number (optional)'),
                  ),
                  const SizedBox(height: 12),
                  Row(children: [
                    Expanded(child: _dateField(_orderDate, 'Purchase Date')),
                    const SizedBox(width: 12),
                    Expanded(child: _dateField(_deliveryDate, 'Expected Delivery')),
                  ]),
                  const SizedBox(height: 20),
                  Row(children: [
                    Expanded(child: Text('Items', style: Theme.of(context).textTheme.titleLarge)),
                    IconButton(
                      onPressed: _catalog.isEmpty ? null : _addLine,
                      tooltip: 'Add item',
                      icon: const Icon(Icons.add_circle_outline),
                    ),
                  ]),
                  if (_catalog.isEmpty)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 12),
                      child: Text('No active inventory items are available.'),
                    ),
                  for (var index = 0; index < _lines.length; index++)
                    _lineEditor(index),
                  const SizedBox(height: 12),
                  _amountRow('Subtotal', subtotal),
                  _amountRow('VAT', vat),
                  _amountRow('Discount', discount),
                  _amountRow('Total', subtotal + vat - discount, strong: true),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _notes,
                    maxLines: 3,
                    decoration: const InputDecoration(labelText: 'Notes'),
                  ),
                  if (_error != null) ...[
                    const SizedBox(height: 12),
                    Text(_error!, style: TextStyle(color: Theme.of(context).colorScheme.error)),
                  ],
                  const SizedBox(height: 20),
                  Row(children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: _saving ? null : () => _save('Draft'),
                        child: const Text('Save Draft'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: FilledButton(
                        onPressed: _saving ? null : () => _save('Pending'),
                        child: _saving
                            ? const SizedBox.square(dimension: 20, child: CircularProgressIndicator(strokeWidth: 2))
                            : Text(_editing ? 'Update Purchase' : 'Submit Purchase'),
                      ),
                    ),
                  ]),
                ],
              ),
            ),
    );
  }

  Widget _dateField(TextEditingController controller, String label) {
    return TextFormField(
      controller: controller,
      readOnly: true,
      decoration: InputDecoration(labelText: label, suffixIcon: const Icon(Icons.calendar_today_outlined)),
      validator: label == 'Purchase Date' ? (value) => value == null || value.isEmpty ? 'Required' : null : null,
      onTap: () async {
        final initial = DateTime.tryParse(controller.text) ?? DateTime.now();
        final date = await showDatePicker(
          context: context,
          initialDate: initial,
          firstDate: DateTime(2000),
          lastDate: DateTime(2100),
        );
        if (date != null) controller.text = _dateString(date);
      },
    );
  }

  Widget _lineEditor(int index) {
    final line = _lines[index];
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(color: Theme.of(context).colorScheme.surface, borderRadius: BorderRadius.circular(12)),
        child: Column(children: [
          Row(children: [
            Expanded(
              child: DropdownButtonFormField<String>(
                value: line.itemId,
                decoration: const InputDecoration(labelText: 'Inventory Item'),
                items: _catalog
                    .map((item) => DropdownMenuItem<String>(
                          value: item['id'] as String,
                          child: Text('${item['name']} (${item['unit']})'),
                        ))
                    .toList(),
                onChanged: (value) {
                  final selected = _catalog.firstWhere((item) => item['id'] == value);
                  setState(() {
                    line.itemId = value;
                    line.unit = selected['unit'] as String? ?? '';
                    line.unitPrice.text = '${selected['default_purchase_price'] ?? 0}';
                  });
                },
                validator: (value) => value == null ? 'Select an item' : null,
              ),
            ),
            IconButton(
              tooltip: 'Remove item',
              onPressed: () => setState(() {
                _lines.removeAt(index).dispose();
              }),
              icon: const Icon(Icons.delete_outline),
            ),
          ]),
          const SizedBox(height: 8),
          Row(children: [
            Expanded(child: _numericField(line.quantity, 'Quantity', decimal: true)),
            const SizedBox(width: 8),
            Expanded(child: _readOnlyField(line.unit, 'Unit')),
            const SizedBox(width: 8),
            Expanded(child: _numericField(line.unitPrice, 'Unit Price', decimal: true)),
          ]),
          const SizedBox(height: 8),
          Row(children: [
            Expanded(child: _numericField(line.vat, 'VAT Amount', decimal: true, optional: true)),
            const SizedBox(width: 8),
            Expanded(child: _numericField(line.discount, 'Discount', decimal: true, optional: true)),
          ]),
        ]),
      ),
    );
  }

  Widget _numericField(TextEditingController controller, String label, {required bool decimal, bool optional = false}) {
    return TextFormField(
      controller: controller,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      decoration: InputDecoration(labelText: label, isDense: true),
      onChanged: (_) => setState(() {}),
      validator: (value) {
        if ((value == null || value.trim().isEmpty) && optional) return null;
        final number = double.tryParse(value ?? '');
        if (number == null || number < 0 || (!optional && number == 0)) return 'Enter a valid amount';
        return null;
      },
    );
  }

  Widget _readOnlyField(String value, String label) => TextFormField(
        initialValue: value,
        readOnly: true,
        decoration: InputDecoration(labelText: label, isDense: true),
      );

  Widget _amountRow(String label, double value, {bool strong = false}) => Padding(
        padding: const EdgeInsets.only(bottom: 6),
        child: Row(children: [
          Expanded(child: Text(label, style: TextStyle(fontWeight: strong ? FontWeight.w800 : FontWeight.w600))),
          Text('ETB ${value.toStringAsFixed(2)}', style: TextStyle(fontWeight: strong ? FontWeight.w800 : FontWeight.w600)),
        ]),
      );

  void _addLine() => setState(() => _lines.add(_PurchaseLineForm()));

  String _today() => _dateString(DateTime.now());

  String _dateString(DateTime value) =>
      '${value.year.toString().padLeft(4, '0')}-${value.month.toString().padLeft(2, '0')}-${value.day.toString().padLeft(2, '0')}';
}

class _PurchaseLineForm {
  String? itemId;
  String unit = '';
  final quantity = TextEditingController(text: '1');
  final unitPrice = TextEditingController(text: '0');
  final vat = TextEditingController(text: '0');
  final discount = TextEditingController(text: '0');

  double get quantityValue => double.tryParse(quantity.text) ?? 0;
  double get unitPriceValue => double.tryParse(unitPrice.text) ?? 0;
  double get vatAmount => double.tryParse(vat.text) ?? 0;
  double get discountAmount => double.tryParse(discount.text) ?? 0;

  factory _PurchaseLineForm.fromModel(PurchaseLineViewModel model) {
    return _PurchaseLineForm()
      ..itemId = model.itemId
      ..unit = model.unit
      ..quantity.text = model.quantity.toString()
      ..unitPrice.text = model.unitPrice.toString()
      ..vat.text = model.vatAmount.toString()
      ..discount.text = model.discountAmount.toString();
  }

  Map<String, dynamic> toJson() => {
        'item_id': itemId,
        'quantity': quantityValue,
        'unit_price': unitPriceValue,
        'vat_amount': vatAmount,
        'discount_amount': discountAmount,
      };

  void dispose() {
    quantity.dispose();
    unitPrice.dispose();
    vat.dispose();
    discount.dispose();
  }
}
