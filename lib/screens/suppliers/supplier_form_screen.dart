import 'package:flutter/material.dart';

import '../../models/inventory_models.dart';
import '../../services/mock_repository.dart';

class SupplierFormScreen extends StatefulWidget {
  final Supplier? supplier;

  const SupplierFormScreen({super.key, this.supplier});

  @override
  State<SupplierFormScreen> createState() => _SupplierFormScreenState();
}

class _SupplierFormScreenState extends State<SupplierFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _companyController;
  late final TextEditingController _contactController;
  late final TextEditingController _phoneController;
  late final TextEditingController _emailController;
  late final TextEditingController _addressController;
  late final TextEditingController _taxController;
  late final TextEditingController _categoryController;
  late final TextEditingController _registrationController;
  late final TextEditingController _notesController;

  bool _saved = false;

  @override
  void initState() {
    super.initState();
    final supplier = widget.supplier;
    _companyController = TextEditingController(text: supplier?.company ?? '');
    _contactController = TextEditingController(text: supplier?.contactPerson ?? '');
    _phoneController = TextEditingController(text: supplier?.phone ?? '');
    _emailController = TextEditingController(text: supplier?.email ?? '');
    _addressController = TextEditingController(text: supplier?.address ?? '');
    _taxController = TextEditingController(text: supplier?.taxNumber ?? '');
    _categoryController = TextEditingController(text: supplier?.status ?? '');
    _registrationController = TextEditingController(text: supplier?.id ?? '');
    _notesController = TextEditingController(text: supplier?.address ?? '');
  }

  @override
  void dispose() {
    _companyController.dispose();
    _contactController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _addressController.dispose();
    _taxController.dispose();
    _categoryController.dispose();
    _registrationController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.supplier != null;

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
                    IconButton(onPressed: () => Navigator.of(context).pop(), icon: const Icon(Icons.arrow_back_rounded), style: IconButton.styleFrom(backgroundColor: Colors.white, padding: const EdgeInsets.all(10))),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(999)),
                      child: Text(isEditing ? 'Update Supplier' : 'Add Supplier', style: const TextStyle(fontWeight: FontWeight.w700)),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(28), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 16, offset: const Offset(0, 8))]),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(isEditing ? 'Update supplier details' : 'Create a supplier profile', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800)),
                      const SizedBox(height: 10),
                      Text('Keep supplier information up to date with a refined, mobile-first form.', style: Theme.of(context).textTheme.bodyMedium),
                      const SizedBox(height: 18),
                      _buildField('Company Name', _companyController, Icons.business_outlined, validator: _required),
                      _buildField('Contact Person', _contactController, Icons.person_outline_rounded, validator: _required),
                      _buildField('Phone Number', _phoneController, Icons.phone_outlined, validator: _required),
                      _buildField('Email', _emailController, Icons.email_outlined, validator: _email),
                      _buildField('Address', _addressController, Icons.location_on_outlined, validator: _required),
                      _buildField('Tax Number', _taxController, Icons.receipt_long_outlined, validator: _required),
                      _buildField('Supplier Category', _categoryController, Icons.category_outlined, validator: _required),
                      _buildField('Business Registration Number', _registrationController, Icons.badge_outlined),
                      _buildField('Notes', _notesController, Icons.notes_outlined, maxLines: 3),
                      const SizedBox(height: 10),
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(color: const Color(0xFFF8FAFC), borderRadius: BorderRadius.circular(20)),
                        child: Row(
                          children: [
                            const Icon(Icons.upload_file_rounded, color: Color(0xFF2563EB)),
                            const SizedBox(width: 10),
                            Expanded(child: Text('Company Logo Upload', style: const TextStyle(fontWeight: FontWeight.w700))),
                            TextButton(onPressed: () {}, child: const Text('Upload')),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),
                Row(
                  children: [
                    Expanded(child: OutlinedButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancel'))),
                    const SizedBox(width: 12),
                    Expanded(child: FilledButton(onPressed: _submit, child: Text(isEditing ? 'Update Supplier' : 'Save Supplier'))),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildField(String label, TextEditingController controller, IconData icon, {String? Function(String?)? validator, int maxLines = 1}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: controller,
        validator: validator,
        maxLines: maxLines,
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

  String? _email(String? value) {
    final valid = _required(value) == null;
    if (!valid) return 'Required';
    final emailRegex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
    if (!emailRegex.hasMatch(value!)) {
      return 'Enter a valid email';
    }
    return null;
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      setState(() => _saved = true);

      final isEditing = widget.supplier != null;
      if (isEditing) {
        final existing = widget.supplier!;
        final index = MockRepository.suppliers.indexWhere((s) => s.id == existing.id);
        final updated = Supplier(
          id: existing.id,
          name: _contactController.text.trim(),
          company: _companyController.text.trim(),
          contactPerson: _contactController.text.trim(),
          phone: _phoneController.text.trim(),
          email: _emailController.text.trim(),
          address: _addressController.text.trim(),
          taxNumber: _taxController.text.trim(),
          status: _categoryController.text.trim().isEmpty ? existing.status : _categoryController.text.trim(),
          outstandingBalance: existing.outstandingBalance,
        );
        if (index != -1) {
          MockRepository.suppliers[index] = updated;
        }
      } else {
        MockRepository.suppliers.add(
          Supplier(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            name: _contactController.text.trim(),
            company: _companyController.text.trim(),
            contactPerson: _contactController.text.trim(),
            phone: _phoneController.text.trim(),
            email: _emailController.text.trim(),
            address: _addressController.text.trim(),
            taxNumber: _taxController.text.trim(),
            status: 'Active',
            outstandingBalance: 0,
          ),
        );
      }

      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          title: const Text('Supplier saved'),
          content: const Text('The supplier details were saved successfully.'),
          actions: [
            FilledButton(
              onPressed: () => Navigator.of(context).popUntil((route) => route.isFirst),
              child: const Text('Continue'),
            ),
          ],
        ),
      );
    }
  }
}