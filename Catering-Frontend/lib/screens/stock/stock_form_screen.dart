import 'package:flutter/material.dart';
import '../../models/stock_models.dart';
import '../../services/api_repository.dart';

class StockFormScreen extends StatefulWidget {
  final StockItem? item;
  final String? category;
  final String? subtype;
  const StockFormScreen({super.key, this.item, this.category, this.subtype});

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

  // Step 3 controllers (Electronics-specific)
  final _brandCtrl = TextEditingController();
  final _modelCtrl = TextEditingController();
  final _warrantyCtrl = TextEditingController();
  final _maintenanceCtrl = TextEditingController();
  final _assetTagCtrl = TextEditingController();

  // Step 4 controllers (Catering-specific) - Removed: quantityPerUnit not in model

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

      // If it's an electronics item, populate electronics fields
      if (item is ElectronicsStockItem) {
        _brandCtrl.text = item.brand;
        _modelCtrl.text = item.model;
        _warrantyCtrl.text = item.warrantyStatus;
        _maintenanceCtrl.text = item.lastMaintenanceDate!.toIso8601String();
        _assetTagCtrl.text = item.assetTag;
      }

      // If it's a catering item, no additional fields to populate
      if (item is CateringStockItem) {
        // Catering items don't have additional fields beyond base StockItem
      }
    } else {
      // Set defaults based on category selection
      if (widget.category == 'electronics') {
        _categoryCtrl.text = 'Electronics';
        _unitCtrl.text = 'Pcs';
      } else if (widget.category == 'catering') {
        _categoryCtrl.text =
            widget.subtype == 'permanent' ? 'Permanent Assets' : 'Consumables';
        _unitCtrl.text = 'Pcs';
      } else {
        _categoryCtrl.text = 'Food';
        _unitCtrl.text = 'Kg';
      }
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
    _brandCtrl.dispose();
    _modelCtrl.dispose();
    _warrantyCtrl.dispose();
    _maintenanceCtrl.dispose();
    _assetTagCtrl.dispose();
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
                      _isEditMode ? 'Edit Stock Item' : 'New Stock Item',
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
                  if (_isItemCategory('electronics') ||
                      _isItemCategory('catering'))
                    _buildStepIndicator(2, 'Details', true),
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
                            onPressed: details.onStepContinue,
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
                      if (_currentStep < 2)
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
                  if (_currentStep < 2) {
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
                  // Step 1: Basic Information
                  Step(
                    title: const Text('Basic Info'),
                    content: _buildBasicInfoStep(),
                    isActive: _currentStep >= 0,
                    state: _currentStep >= 0
                        ? StepState.indexed
                        : StepState.disabled,
                  ),
                  // Step 2: Inventory Details
                  Step(
                    title: const Text('Inventory'),
                    content: _buildInventoryStep(),
                    isActive: _currentStep >= 1,
                    state: _currentStep >= 1
                        ? StepState.indexed
                        : StepState.disabled,
                  ),
                  if (_isItemCategory('electronics'))
                    // Step 3: Electronics Details
                    Step(
                      title: const Text('Details'),
                      content: _buildElectronicsStep(),
                      isActive: _currentStep >= 2,
                      state: _currentStep >= 2
                          ? StepState.indexed
                          : StepState.disabled,
                    ),
                  if (_isItemCategory('catering'))
                    // Step 3: Catering Details
                    Step(
                      title: const Text('Details'),
                      content: _buildCateringStep(),
                      isActive: _currentStep >= 2,
                      state: _currentStep >= 2
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

  bool _isItemCategory(String category) {
    if (widget.category != null) return widget.category == category;
    if (_isEditMode && widget.item != null) {
      if (category == 'food') return widget.item is FoodStockItem;
      if (category == 'catering') return widget.item is CateringStockItem;
      if (category == 'electronics') return widget.item is ElectronicsStockItem;
    }
    return false;
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

  Widget _buildElectronicsStep() {
    return Column(
      children: [
        _buildTextField(
            _brandCtrl, 'Brand', 'e.g., Samsung', Icons.business_rounded),
        _buildTextField(
            _modelCtrl, 'Model', 'e.g., XYZ-123', Icons.desktop_windows),
        _buildTextField(_warrantyCtrl, 'Warranty Status', 'Active/Expired',
            Icons.shield_rounded),
        _buildTextField(_maintenanceCtrl, 'Last Maintenance', '2026-01-01',
            Icons.build_rounded),
        _buildTextField(_assetTagCtrl, 'Asset Tag', 'e.g., ASSET-001',
            Icons.barcode_reader),
      ],
    );
  }

  Widget _buildCateringStep() {
    return Column(
      children: [
        DropdownButtonFormField<String>(
          decoration: InputDecoration(
            prefixIcon:
                const Icon(Icons.food_bank_rounded, color: Color(0xFF64748B)),
            labelText: 'Subtype',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          value: widget.subtype ?? 'permanent',
          items: const [
            DropdownMenuItem(
                value: 'permanent', child: Text('Permanent Assets')),
            DropdownMenuItem(value: 'temporary', child: Text('Consumables')),
          ],
          onChanged: (value) {},
        ),
      ],
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
      // Create or update the item
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

      if (_isItemCategory('electronics')) {
        final item = ElectronicsStockItem(
          id: _isEditMode
              ? widget.item!.id
              : DateTime.now().millisecondsSinceEpoch.toString(),
          code: code,
          name: name,
          category: category,
          unit: unit,
          supplier: supplier,
          location: location,
          description: description,
          purchasePrice: purchasePrice,
          quantity: quantity,
          minQuantity: minQuantity,
          maxQuantity: maxQuantity,
          status: 'Healthy',
          lastUpdated: DateTime.now(),
          brand: _brandCtrl.text.trim(),
          model: _modelCtrl.text.trim(),
          serialNumber: _assetTagCtrl.text.trim(),
          maintenanceStatus: 'OK',
          assetTag: _assetTagCtrl.text.trim(),
        );

        // TODO: Replace with actual API calls when electronics stock endpoints are implemented
        if (_isEditMode) {
          // Update electronics stock item via API
          // await ApiRepository.instance.updateElectronicsStock(widget.item!.id, item.toJson());
        } else {
          // Create electronics stock item via API
          // await ApiRepository.instance.createElectronicsStock(item.toJson());
        }
      } else if (_isItemCategory('catering')) {
        final subtype = widget.subtype ?? 'permanent';
        final item = CateringStockItem(
          id: _isEditMode
              ? widget.item!.id
              : DateTime.now().millisecondsSinceEpoch.toString(),
          code: code,
          name: name,
          category: category,
          unit: unit,
          supplier: supplier,
          location: location,
          description: description,
          purchasePrice: purchasePrice,
          quantity: quantity,
          minQuantity: minQuantity,
          maxQuantity: maxQuantity,
          status: 'Healthy',
          lastUpdated: DateTime.now(),
          subtype: subtype == 'permanent'
              ? CateringSubtype.permanent
              : CateringSubtype.temporary,
        );

        // TODO: Replace with actual API calls when catering stock endpoints are implemented
        if (_isEditMode) {
          // Update catering stock item via API
          // await ApiRepository.instance.updateCateringStock(widget.item!.id, item.toJson());
        } else {
          // Create catering stock item via API
          // await ApiRepository.instance.createCateringStock(item.toJson());
        }
      } else {
        // Food item
        final item = FoodStockItem(
          id: _isEditMode
              ? widget.item!.id
              : DateTime.now().millisecondsSinceEpoch.toString(),
          code: code,
          name: name,
          category: category,
          unit: unit,
          supplier: supplier,
          location: location,
          description: description,
          purchasePrice: purchasePrice,
          quantity: quantity,
          minQuantity: minQuantity,
          maxQuantity: maxQuantity,
          status: 'Healthy',
          lastUpdated: DateTime.now(),
          expiryDate: null,
          batchNumber: '',
        );

        // TODO: Replace with actual API calls when food stock endpoints are implemented
        if (_isEditMode) {
          // Update food stock item via API
          // await ApiRepository.instance.updateFoodStock(widget.item!.id, item.toJson());
        } else {
          // Create food stock item via API
          // await ApiRepository.instance.createFoodStock(item.toJson());
        }
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
