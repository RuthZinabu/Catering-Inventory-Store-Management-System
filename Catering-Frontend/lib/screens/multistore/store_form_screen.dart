import 'package:catering_inventory_store_management_system/models/store_repository.dart';
import 'package:flutter/material.dart';
import '../../models/store_model.dart';

class StoreFormScreen extends StatefulWidget {
  final Store? store;
  const StoreFormScreen({super.key, this.store});

  @override
  State<StoreFormScreen> createState() => _StoreFormScreenState();
}

class _StoreFormScreenState extends State<StoreFormScreen> {
  final _formKey = GlobalKey<FormState>();

  final _nameCtrl = TextEditingController();
  final _codeCtrl = TextEditingController();
  final _descriptionCtrl = TextEditingController();
  final _locationCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _managerCtrl = TextEditingController();

  String _selectedType = 'main_warehouse';
  bool _isActive = true;

  @override
  void initState() {
    super.initState();
    if (widget.store != null) {
      final store = widget.store!;
      _nameCtrl.text = store.name;
      _codeCtrl.text = store.code;
      _descriptionCtrl.text = store.description;
      _locationCtrl.text = store.location;
      _phoneCtrl.text = store.phone;
      _emailCtrl.text = store.email;
      _managerCtrl.text = store.manager;
      _selectedType = storeTypes.firstWhere(
        (type) => type['value'] == store.code.split('-')[0],
        orElse: () => storeTypes.first,
      )['value']!;
      _isActive = store.isActive;
    } else {
      // Set default values for new store
      _codeCtrl.text =
          'SW-${DateTime.now().millisecondsSinceEpoch.toString().substring(6, 9)}';
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _codeCtrl.dispose();
    _descriptionCtrl.dispose();
    _locationCtrl.dispose();
    _phoneCtrl.dispose();
    _emailCtrl.dispose();
    _managerCtrl.dispose();
    super.dispose();
  }

  List<Map<String, String>> get storeTypes => Store.storeTypes;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          widget.store != null ? 'Edit Store' : 'Add New Store',
          style: const TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back_rounded),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Store type selection
              Text(
                'Store Type',
                style: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: storeTypes.map((type) {
                  final isSelected = _selectedType == type['value'];
                  return FilterChip(
                    label: Text(type['label']!),
                    selected: isSelected,
                    onSelected: (selected) =>
                        setState(() => _selectedType = type['value']!),
                    backgroundColor: Colors.white,
                    selectedColor: const Color(0xFFE0E7FF),
                    labelStyle: TextStyle(
                      color: isSelected
                          ? const Color(0xFF2563EB)
                          : const Color(0xFF64748B),
                      fontWeight:
                          isSelected ? FontWeight.w600 : FontWeight.normal,
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 24),

              // Basic info
              Text(
                'Basic Information',
                style: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 12),

              // Name
              TextFormField(
                controller: _nameCtrl,
                decoration: InputDecoration(
                  labelText: 'Store Name *',
                  prefixIcon: const Icon(Icons.business),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide:
                        const BorderSide(color: Color(0xFF2563EB), width: 2),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Store name is required';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Code
              TextFormField(
                controller: _codeCtrl,
                decoration: InputDecoration(
                  labelText: 'Store Code *',
                  prefixIcon: const Icon(Icons.tag),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide:
                        const BorderSide(color: Color(0xFF2563EB), width: 2),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Store code is required';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Description
              TextFormField(
                controller: _descriptionCtrl,
                maxLines: 3,
                decoration: InputDecoration(
                  labelText: 'Description',
                  prefixIcon: const Icon(Icons.description),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide:
                        const BorderSide(color: Color(0xFF2563EB), width: 2),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Location
              TextFormField(
                controller: _locationCtrl,
                decoration: InputDecoration(
                  labelText: 'Location / Address',
                  prefixIcon: const Icon(Icons.location_on),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide:
                        const BorderSide(color: Color(0xFF2563EB), width: 2),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Contact info
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _phoneCtrl,
                      decoration: InputDecoration(
                        labelText: 'Phone',
                        prefixIcon: const Icon(Icons.phone),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide:
                              const BorderSide(color: Color(0xFFE2E8F0)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                              color: Color(0xFF2563EB), width: 2),
                        ),
                      ),
                      keyboardType: TextInputType.phone,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _emailCtrl,
                      decoration: InputDecoration(
                        labelText: 'Email',
                        prefixIcon: const Icon(Icons.email),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide:
                              const BorderSide(color: Color(0xFFE2E8F0)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                              color: Color(0xFF2563EB), width: 2),
                        ),
                      ),
                      keyboardType: TextInputType.emailAddress,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Manager
              TextFormField(
                controller: _managerCtrl,
                decoration: InputDecoration(
                  labelText: 'Manager Name',
                  prefixIcon: const Icon(Icons.people),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide:
                        const BorderSide(color: Color(0xFF2563EB), width: 2),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Status
              SwitchListTile(
                title: const Text('Active'),
                subtitle: Text(_isActive
                    ? 'Store is currently active'
                    : 'Store is inactive'),
                value: _isActive,
                onChanged: (value) => setState(() => _isActive = value),
                activeColor: const Color(0xFF16A34A),
              ),
              const SizedBox(height: 40),

              // Save button
              ElevatedButton.icon(
                onPressed: _saveStore,
                icon: const Icon(Icons.save),
                label: Text(
                    widget.store != null ? 'Update Store' : 'Create Store'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2563EB),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _saveStore() {
    if (_formKey.currentState!.validate()) {
      final now = DateTime.now();

      if (widget.store != null) {
        // Update existing store
        final updatedStore = widget.store!.copyWith(
          name: _nameCtrl.text.trim(),
          code: _codeCtrl.text.trim(),
          description: _descriptionCtrl.text.trim(),
          location: _locationCtrl.text.trim(),
          phone: _phoneCtrl.text.trim(),
          email: _emailCtrl.text.trim(),
          manager: _managerCtrl.text.trim(),
          isActive: _isActive,
          updatedAt: now,
        );
        StoreRepository.updateStore(updatedStore);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${updatedStore.name} updated successfully'),
            backgroundColor: const Color(0xFF16A34A),
          ),
        );
      } else {
        // Create new store
        final newStore = Store(
          id: 'STORE-${DateTime.now().millisecondsSinceEpoch}',
          name: _nameCtrl.text.trim(),
          code: _codeCtrl.text.trim(),
          description: _descriptionCtrl.text.trim(),
          location: _locationCtrl.text.trim(),
          phone: _phoneCtrl.text.trim(),
          email: _emailCtrl.text.trim(),
          manager: _managerCtrl.text.trim(),
          isActive: _isActive,
          createdAt: now,
          updatedAt: now,
        );
        StoreRepository.addStore(newStore);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${newStore.name} created successfully'),
            backgroundColor: const Color(0xFF16A34A),
          ),
        );
      }

      Navigator.pop(context);
    }
  }
}
