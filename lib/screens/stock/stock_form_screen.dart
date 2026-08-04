import 'package:flutter/material.dart';
import '../../models/stock_models.dart';
import '../../services/mock_repository.dart';

class StockFormScreen extends StatefulWidget {
  final StockItem? item;
  const StockFormScreen({super.key, this.item});

  @override
  State<StockFormScreen> createState() => _StockFormScreenState();
}

class _StockFormScreenState extends State<StockFormScreen> {
  int _currentStep = 0;
  bool get _isEditMode => widget.item != null;

  // Step 1 controllers
  final _codeCtrl = TextEditingController();
  final _nameCtrl = TextEditingController();
  final _categoryCtrl = TextEditingController();
  final _unitCtrl = TextEditingController();
  final _supplierCtrl = TextEditingController();
  final _locationCtrl = TextEditingController();
  final _descriptionCtrl = TextEditingController();

  // Step 2 controllers
  final _purchasePriceCtrl = TextEditingController();
  final _quantityCtrl = TextEditingController();
  final _minQtyCtrl = TextEditingController();
  final _maxQtyCtrl = TextEditingController();

  final _formKey1 = GlobalKey<FormState>();
  final _formKey2 = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    if (_isEditMode) {
      final item = widget.item!;
      _codeCtrl.text = item.code;
      _nameCtrl.text = item.name;
      _categoryCtrl.text = item.category;
      _unitCtrl.text = item.unit;
      _supplierCtrl.text = item.supplier;
      _locationCtrl.text = item.location;
      _descriptionCtrl.text = item.description;
      _purchasePriceCtrl.text = item.purchasePrice.toStringAsFixed(2);
      _quantityCtrl.text = item.quantity.toStringAsFixed(0);
      _minQtyCtrl.text = item.minQuantity.toStringAsFixed(0);
      _maxQtyCtrl.text = item.maxQuantity.toStringAsFixed(0);
    }
  }

  @override
  void dispose() {
    _codeCtrl.dispose(); _nameCtrl.dispose(); _categoryCtrl.dispose();
    _unitCtrl.dispose(); _supplierCtrl.dispose(); _locationCtrl.dispose();
    _descriptionCtrl.dispose(); _purchasePriceCtrl.dispose();
    _quantityCtrl.dispose(); _minQtyCtrl.dispose(); _maxQtyCtrl.dispose();
    super.dispose();
  }

  void _save() {
    if (!_isEditMode) {
      final newItem = FoodStockItem(
        id: 'fs${DateTime.now().millisecondsSinceEpoch}',
        code: _codeCtrl.text.trim().isEmpty ? 'FS-NEW' : _codeCtrl.text.trim(),
        name: _nameCtrl.text.trim(),
        category: _categoryCtrl.text.trim().isEmpty ? 'Other' : _categoryCtrl.text.trim(),
        unit: _unitCtrl.text.trim().isEmpty ? 'Pcs' : _unitCtrl.text.trim(),
        purchasePrice: double.tryParse(_purchasePriceCtrl.text) ?? 0,
        quantity: double.tryParse(_quantityCtrl.text) ?? 0,
        minQuantity: double.tryParse(_minQtyCtrl.text) ?? 0,
        maxQuantity: double.tryParse(_maxQtyCtrl.text) ?? 100,
        location: _locationCtrl.text.trim(),
        supplier: _supplierCtrl.text.trim(),
        status: 'Healthy',
        description: _descriptionCtrl.text.trim(),
        lastUpdated: DateTime.now(),
        batchNumber: 'BT-NEW',
      );
      MockRepository.foodStock.add(newItem);
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Item added')));
    } else {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Item updated')));
    }
    Navigator.of(context).pop();
  }

  InputDecoration _inputDec(String label, {String? hint}) => InputDecoration(
        labelText: label,
        hintText: hint,
        labelStyle: const TextStyle(color: Color(0xFF64748B), fontSize: 13),
        hintStyle: const TextStyle(color: Color(0xFFCBD5E1), fontSize: 13),
        filled: true,
        fillColor: const Color(0xFFF8FAFC),
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide.none),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      );

  Widget _card(Widget child) => Container(
        width: double.infinity,
        padding: const EdgeInsets.all(18),
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(22),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 18,
                offset: const Offset(0, 10))
          ],
        ),
        child: child,
      );

  Widget _reviewRow(String label, String value) => Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Row(
          children: [
            Expanded(
                child: Text(label,
                    style: const TextStyle(
                        fontSize: 13,
                        color: Color(0xFF64748B),
                        fontWeight: FontWeight.w600))),
            Text(value,
                style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFF10162B),
                    fontWeight: FontWeight.w700)),
          ],
        ),
      );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FB),
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: [
                          BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 10,
                              offset: const Offset(0, 4))
                        ],
                      ),
                      child: const Icon(Icons.arrow_back_ios_new_rounded,
                          size: 18, color: Color(0xFF10162B)),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Text(
                    _isEditMode ? 'Edit Item' : 'Add New Item',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF10162B),
                        letterSpacing: -0.4),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            // Step indicator
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: Row(
                children: List.generate(3, (i) {
                  final labels = ['Basic Info', 'Stock & Pricing', 'Review'];
                  final active = i == _currentStep;
                  final done = i < _currentStep;
                  final color = active || done
                      ? const Color(0xFF2563EB)
                      : const Color(0xFFE2E8F0);
                  return Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(right: 6),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 24, height: 24,
                                decoration: BoxDecoration(
                                    color: color,
                                    shape: BoxShape.circle),
                                child: Center(
                                  child: done
                                      ? const Icon(Icons.check_rounded,
                                          size: 14, color: Colors.white)
                                      : Text('${i + 1}',
                                          style: TextStyle(
                                              fontSize: 11,
                                              fontWeight: FontWeight.w700,
                                              color: active
                                                  ? Colors.white
                                                  : const Color(0xFF94A3B8))),
                                ),
                              ),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(labels[i],
                                    style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w600,
                                        color: active
                                            ? const Color(0xFF2563EB)
                                            : const Color(0xFF94A3B8))),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                }),
              ),
            ),
            // Step content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 112),
                child: _currentStep == 0
                    ? _buildStep1()
                    : _currentStep == 1
                        ? _buildStep2()
                        : _buildStep3(),
              ),
            ),
            // Nav buttons
            Container(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                      color: Colors.black.withOpacity(0.06),
                      blurRadius: 12,
                      offset: const Offset(0, -4))
                ],
              ),
              child: Row(
                children: [
                  if (_currentStep > 0)
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () =>
                            setState(() => _currentStep--),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          side: const BorderSide(color: Color(0xFFE2E8F0)),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14)),
                        ),
                        child: const Text('Back',
                            style: TextStyle(
                                color: Color(0xFF475569),
                                fontWeight: FontWeight.w600)),
                      ),
                    ),
                  if (_currentStep > 0) const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton(
                      onPressed: () {
                        if (_currentStep < 2) {
                          setState(() => _currentStep++);
                        } else {
                          _save();
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2563EB),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14)),
                        elevation: 0,
                      ),
                      child: Text(
                          _currentStep < 2
                              ? 'Continue'
                              : _isEditMode
                                  ? 'Save Changes'
                                  : 'Add Item',
                          style: const TextStyle(
                              fontWeight: FontWeight.w700, fontSize: 15)),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStep1() {
    return Form(
      key: _formKey1,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _card(Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Item Details',
                  style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                      color: Color(0xFF10162B))),
              const SizedBox(height: 14),
              TextField(controller: _codeCtrl, decoration: _inputDec('Item Code', hint: 'e.g. FS-001')),
              const SizedBox(height: 12),
              TextField(controller: _nameCtrl, decoration: _inputDec('Item Name', hint: 'e.g. Chicken Breast')),
              const SizedBox(height: 12),
              TextField(controller: _categoryCtrl, decoration: _inputDec('Category', hint: 'e.g. Meat, Dairy, Oil')),
              const SizedBox(height: 12),
              TextField(controller: _unitCtrl, decoration: _inputDec('Unit', hint: 'e.g. Kg, Pcs, L')),
            ],
          )),
          _card(Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Logistics',
                  style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                      color: Color(0xFF10162B))),
              const SizedBox(height: 14),
              TextField(controller: _supplierCtrl, decoration: _inputDec('Supplier')),
              const SizedBox(height: 12),
              TextField(controller: _locationCtrl, decoration: _inputDec('Location', hint: 'e.g. Main Store – Shelf A1')),
              const SizedBox(height: 12),
              TextField(
                controller: _descriptionCtrl,
                decoration: _inputDec('Description'),
                maxLines: 3,
              ),
            ],
          )),
        ],
      ),
    );
  }

  Widget _buildStep2() {
    return Form(
      key: _formKey2,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _card(Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Pricing',
                  style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                      color: Color(0xFF10162B))),
              const SizedBox(height: 14),
              TextField(
                controller: _purchasePriceCtrl,
                decoration: _inputDec('Purchase Price (ETB)'),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
              ),
            ],
          )),
          _card(Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Stock Levels',
                  style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                      color: Color(0xFF10162B))),
              const SizedBox(height: 14),
              TextField(
                controller: _quantityCtrl,
                decoration: _inputDec('Current Quantity'),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _minQtyCtrl,
                decoration: _inputDec('Minimum Quantity'),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _maxQtyCtrl,
                decoration: _inputDec('Maximum Quantity'),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
              ),
            ],
          )),
        ],
      ),
    );
  }

  Widget _buildStep3() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _card(Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Review Details',
                style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                    color: Color(0xFF10162B))),
            const SizedBox(height: 14),
            _reviewRow('Code', _codeCtrl.text.isEmpty ? '—' : _codeCtrl.text),
            _reviewRow('Name', _nameCtrl.text.isEmpty ? '—' : _nameCtrl.text),
            _reviewRow('Category', _categoryCtrl.text.isEmpty ? '—' : _categoryCtrl.text),
            _reviewRow('Unit', _unitCtrl.text.isEmpty ? '—' : _unitCtrl.text),
            _reviewRow('Supplier', _supplierCtrl.text.isEmpty ? '—' : _supplierCtrl.text),
            _reviewRow('Location', _locationCtrl.text.isEmpty ? '—' : _locationCtrl.text),
          ],
        )),
        _card(Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Stock & Pricing',
                style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                    color: Color(0xFF10162B))),
            const SizedBox(height: 14),
            _reviewRow('Purchase Price',
                'ETB ${_purchasePriceCtrl.text.isEmpty ? "0.00" : _purchasePriceCtrl.text}'),
            _reviewRow('Quantity',
                '${_quantityCtrl.text.isEmpty ? "0" : _quantityCtrl.text} ${_unitCtrl.text}'),
            _reviewRow('Min Qty', _minQtyCtrl.text.isEmpty ? '—' : _minQtyCtrl.text),
            _reviewRow('Max Qty', _maxQtyCtrl.text.isEmpty ? '—' : _maxQtyCtrl.text),
          ],
        )),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF2563EB).withOpacity(0.06),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
                color: const Color(0xFF2563EB).withOpacity(0.2), width: 1),
          ),
          child: Row(
            children: [
              const Icon(Icons.info_outline_rounded,
                  color: Color(0xFF2563EB), size: 18),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  _isEditMode
                      ? 'Saving will update this item in the inventory.'
                      : 'This item will be added to the Food stock category.',
                  style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF2563EB),
                      fontWeight: FontWeight.w500),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
