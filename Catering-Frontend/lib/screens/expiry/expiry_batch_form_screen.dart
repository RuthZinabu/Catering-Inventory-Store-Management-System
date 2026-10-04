import 'package:flutter/material.dart';

import '../../models/inventory_models.dart';
import '../../services/api_repository.dart';
import '../../services/api_service.dart';

class ExpiryBatchFormScreen extends StatefulWidget {
  const ExpiryBatchFormScreen({super.key});

  @override
  State<ExpiryBatchFormScreen> createState() => _ExpiryBatchFormScreenState();
}

class _ExpiryBatchFormScreenState extends State<ExpiryBatchFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _quantity = TextEditingController();
  final _lotNumber = TextEditingController();
  final _expiryDate = TextEditingController();
  List<InventoryItem> _items = [];
  String? _itemId;
  String? _error;
  bool _loading = true;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _loadItems();
  }

  @override
  void dispose() {
    _quantity.dispose();
    _lotNumber.dispose();
    _expiryDate.dispose();
    super.dispose();
  }

  Future<void> _loadItems() async {
    try {
      final items = await ApiRepository.instance.getInventoryItems();
      if (!mounted) return;
      setState(() {
        _items = items.where((item) => item.isActive != false).toList();
        _loading = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _error = error.toString();
        _loading = false;
      });
    }
  }

  Future<void> _pickExpiryDate() async {
    final initial = DateTime.tryParse(_expiryDate.text) ?? DateTime.now();
    final date = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (date != null) _expiryDate.text = _formatDate(date);
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final storeId = ApiClient.instance.storeId;
    if (storeId == null) {
      setState(() => _error = 'Select a store before recording a batch.');
      return;
    }
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      await ApiRepository.instance.createInventoryBatch({
        'store_id': storeId,
        'item_id': _itemId,
        'expires_on': _expiryDate.text,
        'quantity': double.parse(_quantity.text),
        'lot_number': _lotNumber.text.trim().isEmpty ? null : _lotNumber.text.trim(),
      });
      if (mounted) Navigator.of(context).pop(true);
    } on ApiException catch (error) {
      if (mounted) {
        setState(() {
          _saving = false;
          _error = error.message;
        });
      }
    } catch (error) {
      if (mounted) {
        setState(() {
          _saving = false;
          _error = error.toString();
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Track Expiry Batch')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  const Text(
                    'Assign expiry details to stock already on hand. The quantity must not exceed the untracked stock at the selected store.',
                  ),
                  const SizedBox(height: 20),
                  if (_items.isEmpty)
                    Text(_error ?? 'No inventory items are available.')
                  else
                    DropdownButtonFormField<String>(
                      value: _itemId,
                      isExpanded: true,
                      decoration: const InputDecoration(labelText: 'Inventory item'),
                      items: _items
                          .map((item) => DropdownMenuItem(
                                value: item.id,
                                child: Text('${item.name} • ${item.unit}', overflow: TextOverflow.ellipsis),
                              ))
                          .toList(),
                      onChanged: (value) => setState(() => _itemId = value),
                      validator: (value) => value == null ? 'Choose an item.' : null,
                    ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _quantity,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    decoration: const InputDecoration(labelText: 'Quantity to track'),
                    validator: (value) {
                      final quantity = double.tryParse(value ?? '');
                      return quantity == null || quantity <= 0 ? 'Enter a quantity above zero.' : null;
                    },
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _expiryDate,
                    readOnly: true,
                    decoration: const InputDecoration(
                      labelText: 'Expiry date',
                      suffixIcon: Icon(Icons.calendar_today_outlined),
                    ),
                    onTap: _pickExpiryDate,
                    validator: (value) => value == null || value.isEmpty ? 'Select an expiry date.' : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _lotNumber,
                    decoration: const InputDecoration(labelText: 'Batch / lot number (optional)'),
                  ),
                  if (_error != null) ...[
                    const SizedBox(height: 12),
                    Text(_error!, style: TextStyle(color: Theme.of(context).colorScheme.error)),
                  ],
                  const SizedBox(height: 20),
                  FilledButton(
                    onPressed: _saving || _items.isEmpty ? null : _save,
                    child: _saving
                        ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                        : const Text('Save Batch'),
                  ),
                ],
              ),
            ),
    );
  }
}

String _formatDate(DateTime date) =>
    '${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';