import 'package:flutter/material.dart';
import '../../models/stock_models.dart';
import '../../services/api_repository.dart';

class FoodStockFormScreen extends StatefulWidget {
  final FoodStockItem? item;
  const FoodStockFormScreen({super.key, this.item});

  @override
  State<FoodStockFormScreen> createState() => _FoodStockFormScreenState();
}

class _FoodStockFormScreenState extends State<FoodStockFormScreen> {
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
    } else {
      _categoryCtrl.text = 'Food';
      _unitCtrl.text = 'Kg';
    }
  }

  @override
  void dispose() {
    _codeCtrl.dispose();
    _nameCtrl.dispose();
    _categoryCtrl.dispose();
    _unitCtrl.dispose();
    _supplierCtrl.dispose();
    _locationCtrl.dispose();
    _descriptionCtrl.dispose();
    _purchasePriceCtrl.dispose();
    _quantityCtrl.dispose();
    _minQtyCtrl.dispose();
    _maxQtyCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 18, 20, 12),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.arrow_back_rounded,
                        color: Color(0xFF2563EB)),
                  ),
                  Expanded(
                    child: Text(
                      _isEditMode ? 'Edit Food Item' : 'New Food Item',
                      style: Theme.of(context)
                          .textTheme
                          .titleLarge
                          ?.copyWith(fontWeight: FontWeight.w700),
                    ),
                  ),
                  const SizedBox(width: 48),
                ],
              ),
            ),
            // Step progress indicator
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildStepIndicator(0, 'Basic Info', true),
                  _buildStepIndicator(1, 'Inventory', true),
                ],
              ),
            ),
            Expanded(
              child: Stepper(
                currentStep: _currentStep,
                type: StepperType.vertical,
                controlsBuilder: (context, details) {
                  return Row(
                    children: [
                      if (_currentStep > 0)
                        Expanded(
                          child: ElevatedButton(
                            onPressed: details.onStepCancel,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF64748B),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: const Text('Back',
                                style: TextStyle(color: Colors.white)),
                          ),
                        ),
                      if (_currentStep < 1)
                        Expanded(
                          child: ElevatedButton(
                            onPressed: details.onStepContinue,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF2563EB),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: const Text('Next',
                                style: TextStyle(color: Colors.white)),
                          ),
                        ),
                    ],
                  );
                },
                onStepContinue: () {
                  if (_currentStep < 1) {
                    setState(() => _currentStep++);
                  } else {
                    _submitForm();
                  }
                },
                onStepCancel: () {
                  if (_currentStep > 0) {
                    setState(() => _currentStep--);
                  }
                },
                steps: [
                  Step(
                    title: const Text('Basic Info'),
                    content: _buildBasicInfoStep(),
                    isActive: _currentStep >= 0,
                    state: _currentStep >= 0
                        ? StepState.indexed
                        : StepState.disabled,
                  ),
                  Step(
                    title: const Text('Inventory'),
                    content: _buildInventoryStep(),
                    isActive: _currentStep >= 1,
                    state: _currentStep >= 1
                        ? StepState.indexed
                        : StepState.disabled,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStepIndicator(int step, String label, bool isActive) {
    final isCompleted = _currentStep > step;
    final isCurrent = _currentStep == step;

    return Expanded(
      child: Column(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: isCompleted
                  ? const Color(0xFF16A34A)
                  : isCurrent
                      ? const Color(0xFF2563EB)
                      : const Color(0xFFE2E8F0),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(
              isCompleted ? Icons.check_rounded : Icons.info_rounded,
              color: Colors.white,
              size: 16,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: isCurrent ? FontWeight.w600 : FontWeight.w500,
              color:
                  isCurrent ? const Color(0xFF2563EB) : const Color(0xFF64748B),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBasicInfoStep() {
    return Form(
      key: _formKey1,
      child: Column(
        children: [
          _buildTextField(
              _codeCtrl, 'Item Code', 'e.g., F-001', Icons.tag_rounded),
          _buildTextField(
              _nameCtrl, 'Item Name', 'e.g., Rice', Icons.title_rounded),
          _buildTextField(_categoryCtrl, 'Category', 'e.g., Grains',
              Icons.category_rounded),
          _buildTextField(_unitCtrl, 'Unit', 'e.g., Kg, Pcs', Icons.speed),
          _buildTextField(_supplierCtrl, 'Supplier', 'e.g., Local Vendor',
              Icons.person_rounded),
          _buildTextField(_locationCtrl, 'Location', 'e.g., Warehouse A',
              Icons.location_on_rounded),
          _buildTextField(_descriptionCtrl, 'Description',
              'Item description...', Icons.description_rounded),
        ],
      ),
    );
  }

  Widget _buildInventoryStep() {
    return Form(
      key: _formKey2,
      child: Column(
        children: [
          _buildTextField(_purchasePriceCtrl, 'Purchase Price', '0.00',
              Icons.price_change_rounded,
              keyboardType: TextInputType.number),
          _buildTextField(
              _quantityCtrl, 'Quantity', '0', Icons.inventory_rounded,
              keyboardType: TextInputType.number),
          _buildTextField(
              _minQtyCtrl, 'Min Stock Level', '10', Icons.warning_rounded,
              keyboardType: TextInputType.number),
          _buildTextField(
              _maxQtyCtrl, 'Max Stock Level', '100', Icons.auto_awesome_rounded,
              keyboardType: TextInputType.number),
        ],
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label,
      String hint, IconData icon,
      {TextInputType keyboardType = TextInputType.text}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          prefixIcon: Icon(icon, color: const Color(0xFF64748B)),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFF2563EB), width: 2),
          ),
        ),
      ),
    );
  }

  void _submitForm() {
    if (_currentStep == 0) {
      if (_formKey1.currentState!.validate()) {
        setState(() => _currentStep++);
      }
    } else if (_currentStep == 1) {
      if (_formKey2.currentState!.validate()) {
        setState(() => _currentStep++);
      }
    } else {
      final code = _codeCtrl.text.trim();
      final name = _nameCtrl.text.trim();
      final category = _categoryCtrl.text.trim();
      final unit = _unitCtrl.text.trim();
      final supplier = _supplierCtrl.text.trim();
      final location = _locationCtrl.text.trim();
      final description = _descriptionCtrl.text.trim();
      final purchasePrice = double.tryParse(_purchasePriceCtrl.text) ?? 0;
      final quantity = double.tryParse(_quantityCtrl.text) ?? 0;
      final minQuantity = double.tryParse(_minQtyCtrl.text) ?? 0;
      final maxQuantity = double.tryParse(_maxQtyCtrl.text) ?? 0;

      final item = FoodStockItem(
        id: _isEditMode
            ? widget.item!.id
            : DateTime.now().millisecondsSinceEpoch.toString(),
        code: code,
        name: name,
        category: category,
        unit: unit,
        purchasePrice: purchasePrice,
        quantity: quantity,
        minQuantity: minQuantity,
        maxQuantity: maxQuantity,
        location: location,
        supplier: supplier,
        status: 'Healthy',
        description: description,
        lastUpdated: DateTime.now(),
        expiryDate: null,
        batchNumber: '',
        requiresRefrigeration: false,
      );

      // TODO: Replace with actual API calls when food stock endpoints are implemented
      if (_isEditMode) {
        // Update food stock item via API
        // await ApiRepository.instance.updateFoodStock(widget.item!.id, item.toJson());
      } else {
        // Create food stock item via API
        // await ApiRepository.instance.createFoodStock(item.toJson());
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_isEditMode
              ? 'Item updated successfully'
              : 'Item added successfully'),
          backgroundColor: const Color(0xFF16A34A),
        ),
      );

      Navigator.of(context).pop();
    }
  }
}
