import 'package:flutter/material.dart';

import '../models/inventory_models.dart';
import '../services/api_repository.dart';
import '../widgets/loading_error_widgets.dart';

class InventoryCreateScreen extends StatefulWidget {
  final String? initialBarcode;

  const InventoryCreateScreen({super.key, this.initialBarcode});

  @override
  State<InventoryCreateScreen> createState() => _InventoryCreateScreenState();
}

class _InventoryCreateScreenState extends State<InventoryCreateScreen> {
  final _formKey = GlobalKey<FormState>();
  String _itemType = 'food';

  final _codeController = TextEditingController();
  final _nameController = TextEditingController();
  final _categoryController = TextEditingController();
  final _unitController = TextEditingController();
  final _purchasePriceController = TextEditingController();
  final _internalCostController = TextEditingController();
  final _minStockController = TextEditingController();
  final _maxStockController = TextEditingController();
  final _stockOnHandController = TextEditingController();
  final _reorderPointController = TextEditingController();
  final _descriptionController = TextEditingController();

  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _codeController.text = widget.initialBarcode ?? '';
  }

  @override
  void dispose() {
    _codeController.dispose();
    _nameController.dispose();
    _categoryController.dispose();
    _unitController.dispose();
    _purchasePriceController.dispose();
    _internalCostController.dispose();
    _minStockController.dispose();
    _maxStockController.dispose();
    _stockOnHandController.dispose();
    _reorderPointController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.arrow_back_rounded),
                      style: IconButton.styleFrom(
                          backgroundColor: Colors.white,
                          padding: const EdgeInsets.all(10)),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(999)),
                      child: const Text('Add Item',
                          style: TextStyle(fontWeight: FontWeight.w700)),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(28),
                    boxShadow: [
                      BoxShadow(
                          color: Colors.black.withOpacity(0.04),
                          blurRadius: 16,
                          offset: const Offset(0, 8))
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Create an inventory item',
                          style: Theme.of(context)
                              .textTheme
                              .titleLarge
                              ?.copyWith(fontWeight: FontWeight.w800)),
                      const SizedBox(height: 10),
                      Text(
                          'Add a new item to stock so it can be tracked and replenished.',
                          style: Theme.of(context).textTheme.bodyMedium),
                      const SizedBox(height: 18),
                      _buildField(
                          'Item Code', _codeController, Icons.qr_code_2_rounded,
                          validator: _required),
                      _buildField('Item Name', _nameController,
                          Icons.inventory_2_outlined,
                          validator: _required),
                      _buildField('Category', _categoryController,
                          Icons.category_outlined,
                          validator: _required),
                      DropdownButtonFormField<String>(
                        value: _itemType,
                        decoration: const InputDecoration(labelText: 'Item Type'),
                        items: const [
                          DropdownMenuItem(value: 'food', child: Text('Food')),
                          DropdownMenuItem(value: 'catering', child: Text('Catering')),
                          DropdownMenuItem(value: 'electronics', child: Text('Electronics')),
                        ],
                        onChanged: (value) {
                          if (value != null) setState(() => _itemType = value);
                        },
                      ),
                      _buildField('Unit (e.g. Kg, Bag, Litre)', _unitController,
                          Icons.straighten_outlined,
                          validator: _required),
                      Row(
                        children: [
                          Expanded(
                              child: _buildField('Purchase Price',
                                  _purchasePriceController, Icons.sell_outlined,
                                  validator: _requiredNumber,
                                  keyboardType: TextInputType.number)),
                          const SizedBox(width: 12),
                          Expanded(
                              child: _buildField(
                                  'Internal Cost',
                                  _internalCostController,
                                  Icons.attach_money_rounded,
                                  validator: _requiredNumber,
                                  keyboardType: TextInputType.number)),
                        ],
                      ),
                      Row(
                        children: [
                          Expanded(
                              child: _buildField('Min Stock',
                                  _minStockController, Icons.south_rounded,
                                  validator: _requiredInt,
                                  keyboardType: TextInputType.number)),
                          const SizedBox(width: 12),
                          Expanded(
                              child: _buildField('Max Stock',
                                  _maxStockController, Icons.north_rounded,
                                  validator: _requiredInt,
                                  keyboardType: TextInputType.number)),
                        ],
                      ),
                      Row(
                        children: [
                          Expanded(
                              child: _buildField(
                                  'Stock On Hand',
                                  _stockOnHandController,
                                  Icons.inventory_outlined,
                                  validator: _requiredInt,
                                  keyboardType: TextInputType.number)),
                          const SizedBox(width: 12),
                          Expanded(
                              child: _buildField(
                                  'Reorder Point',
                                  _reorderPointController,
                                  Icons.notifications_active_outlined,
                                  validator: _requiredInt,
                                  keyboardType: TextInputType.number)),
                        ],
                      ),
                      _buildField('Description', _descriptionController,
                          Icons.notes_outlined,
                          maxLines: 3),
                    ],
                  ),
                ),
                const SizedBox(height: 18),
                Row(
                  children: [
                    Expanded(
                        child: OutlinedButton(
                            onPressed: () => Navigator.of(context).pop(),
                            child: const Text('Cancel'))),
                    const SizedBox(width: 12),
                    Expanded(
                        child: FilledButton(
                            onPressed: _isSubmitting ? null : _submit,
                            child: _isSubmitting
                                ? const SizedBox(
                                    height: 16,
                                    width: 16,
                                    child: CircularProgressIndicator(
                                        strokeWidth: 2),
                                  )
                                : const Text('Save Item'))),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildField(
    String label,
    TextEditingController controller,
    IconData icon, {
    String? Function(String?)? validator,
    int maxLines = 1,
    TextInputType? keyboardType,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: controller,
        validator: validator,
        maxLines: maxLines,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: const Color(0xFF2563EB)),
        ),
      ),
    );
  }

  String? _required(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Required';
    }
    return null;
  }

  String? _requiredNumber(String? value) {
    final requiredError = _required(value);
    if (requiredError != null) return requiredError;
    if (double.tryParse(value!.trim()) == null) return 'Enter a valid number';
    return null;
  }

  String? _requiredInt(String? value) {
    final requiredError = _required(value);
    if (requiredError != null) return requiredError;
    if (int.tryParse(value!.trim()) == null)
      return 'Enter a valid whole number';
    return null;
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isSubmitting = true;
    });

    try {
      final stockOnHand = int.parse(_stockOnHandController.text.trim());
      final minStock = int.parse(_minStockController.text.trim());
      final reorderPoint = int.parse(_reorderPointController.text.trim());

      final newItem = InventoryItem(
        id: '', // API will assign ID
        code: _codeController.text.trim(),
        name: _nameController.text.trim(),
        category: _categoryController.text.trim(),
        unit: _unitController.text.trim(),
        purchasePrice: double.parse(_purchasePriceController.text.trim()),
        internalCost: double.parse(_internalCostController.text.trim()),
        minStock: minStock,
        maxStock: int.parse(_maxStockController.text.trim()),
        description: _descriptionController.text.trim(),
        stockOnHand: stockOnHand,
        reorderPoint: reorderPoint,
        isActive: true, // Set new items as active by default
        itemType: _itemType,
      );

      // Call the API to create the item
      final createdItem =
          await ApiRepository.instance.createInventoryItem(newItem);

      if (mounted) {
        // Show success dialog
        showDialog(
          context: context,
          builder: (_) => AlertDialog(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
            title: const Text('Item added'),
            content: Text(
                '${createdItem.name} was added to inventory successfully.'),
            actions: [
              FilledButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  Navigator.of(context).pop(true);
                },
                child: const Text('Continue'),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        // Show error dialog
        showDialog(
          context: context,
          builder: (_) => AlertDialog(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
            title: const Text('Error'),
            content: Text('Failed to create item: ${e.toString()}'),
            actions: [
              FilledButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('OK'),
              ),
            ],
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }
}
