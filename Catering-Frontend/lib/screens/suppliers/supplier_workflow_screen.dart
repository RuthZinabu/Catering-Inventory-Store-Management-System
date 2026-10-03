import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../models/inventory_models.dart';
import '../../services/api_service.dart';

class SupplierListScreen extends StatefulWidget {
  const SupplierListScreen({super.key});

  @override
  State<SupplierListScreen> createState() => _SupplierListScreenState();
}

class _SupplierListScreenState extends State<SupplierListScreen> {
  final _search = TextEditingController();
  List<Supplier> _suppliers = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final response = await ApiClient.instance.get('/suppliers?per_page=100');
      final rows = (response['data'] as Map)['suppliers'] as List? ?? const [];
      if (!mounted) return;
      setState(() {
        _suppliers = rows
            .map((row) =>
                Supplier.fromJson(Map<String, dynamic>.from(row as Map)))
            .toList();
        _loading = false;
      });
    } on ApiException catch (error) {
      if (mounted)
        setState(() {
          _loading = false;
          _error = error.message;
        });
    }
  }

  List<Supplier> get _filtered {
    final query = _search.text.trim().toLowerCase();
    if (query.isEmpty) return _suppliers;
    return _suppliers
        .where((supplier) =>
            supplier.company.toLowerCase().contains(query) ||
            supplier.contactPerson.toLowerCase().contains(query) ||
            supplier.phone.toLowerCase().contains(query) ||
            supplier.taxNumber.toLowerCase().contains(query))
        .toList();
  }

  Future<void> _openForm([Supplier? supplier]) async {
    final changed = await Navigator.of(context).push<bool>(MaterialPageRoute(
      builder: (_) => SupplierFormScreen(supplier: supplier),
    ));
    if (changed == true) _load();
  }

  Future<void> _delete(Supplier supplier) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete supplier?'),
        content: Text('Delete ${supplier.company}?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel')),
          FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Delete')),
        ],
      ),
    );
    if (confirmed != true) return;
    try {
      await ApiClient.instance.delete('/suppliers/${supplier.id}');
      _load();
    } on ApiException catch (error) {
      if (mounted)
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(error.message)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final suppliers = _filtered;
    final active =
        suppliers.where((supplier) => supplier.status == 'Active').length;
    final outstanding = suppliers.fold<double>(
        0, (sum, supplier) => sum + supplier.outstandingBalance);
    return Scaffold(
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 72),
        child: FloatingActionButton.extended(
          onPressed: () => _openForm(),
          icon: const Icon(Icons.add),
          label: const Text('New Supplier'),
        ),
      ),
      body: SafeArea(
        child: Column(children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Suppliers',
                  style: Theme.of(context).textTheme.headlineSmall),
              const SizedBox(height: 6),
              const Text('Supplier records used by purchase orders.'),
              const SizedBox(height: 16),
              TextField(
                controller: _search,
                onChanged: (_) => setState(() {}),
                decoration: InputDecoration(
                  hintText: 'Search supplier, contact, or phone',
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: _search.text.isEmpty
                      ? null
                      : IconButton(
                          onPressed: () => setState(_search.clear),
                          icon: const Icon(Icons.close)),
                ),
              ),
              const SizedBox(height: 12),
              Wrap(spacing: 10, runSpacing: 8, children: [
                _summary('Suppliers', '${suppliers.length}'),
                _summary('Active', '$active'),
                _summary(
                    'Outstanding', 'ETB ${outstanding.toStringAsFixed(2)}'),
              ]),
            ]),
          ),
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : _error != null
                    ? Center(
                        child: Padding(
                            padding: const EdgeInsets.all(24),
                            child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(_error!, textAlign: TextAlign.center),
                                  const SizedBox(height: 12),
                                  OutlinedButton.icon(
                                      onPressed: _load,
                                      icon: const Icon(Icons.refresh),
                                      label: const Text('Retry'))
                                ])))
                    : suppliers.isEmpty
                        ? const Center(child: Text('No suppliers found.'))
                        : RefreshIndicator(
                            onRefresh: _load,
                            child: ListView.separated(
                              padding: const EdgeInsets.fromLTRB(20, 4, 20, 96),
                              itemCount: suppliers.length,
                              separatorBuilder: (_, __) =>
                                  const SizedBox(height: 10),
                              itemBuilder: (context, index) =>
                                  _supplierTile(suppliers[index]),
                            ),
                          ),
          ),
        ]),
      ),
    );
  }

  Widget _supplierTile(Supplier supplier) => Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            border: Border.all(color: Theme.of(context).dividerColor),
            borderRadius: BorderRadius.circular(12)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Expanded(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                  Text(supplier.company,
                      style: Theme.of(context).textTheme.titleMedium),
                  Text(supplier.contactPerson),
                ])),
            Chip(
                label: Text(supplier.status),
                visualDensity: VisualDensity.compact),
          ]),
          const SizedBox(height: 6),
          Text('${supplier.phone}  •  ${supplier.email}'),
          if (supplier.category.isNotEmpty)
            Text('Category: ${supplier.category}'),
          const SizedBox(height: 6),
          Wrap(spacing: 2, children: [
            TextButton.icon(
              onPressed: () => Navigator.of(context).push(MaterialPageRoute(
                  builder: (_) => SupplierDetailScreen(supplier: supplier))),
              icon: const Icon(Icons.visibility_outlined),
              label: const Text('Details'),
            ),
            TextButton.icon(
                onPressed: () => _openForm(supplier),
                icon: const Icon(Icons.edit_outlined),
                label: const Text('Update')),
            IconButton(
                tooltip: 'Delete supplier',
                onPressed: () => _delete(supplier),
                icon: const Icon(Icons.delete_outline)),
          ]),
        ]),
      );

  Widget _summary(String title, String value) => Container(
        constraints: const BoxConstraints(minWidth: 110),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
        decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(10)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title, style: Theme.of(context).textTheme.bodySmall),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w700))
        ]),
      );
}

class SupplierFormScreen extends StatefulWidget {
  final Supplier? supplier;

  const SupplierFormScreen({super.key, this.supplier});

  @override
  State<SupplierFormScreen> createState() => _SupplierFormScreenState();
}

class _SupplierFormScreenState extends State<SupplierFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _company;
  late final TextEditingController _contact;
  late final TextEditingController _phone;
  late final TextEditingController _email;
  late final TextEditingController _address;
  late final TextEditingController _tax;
  late final TextEditingController _category;
  late final TextEditingController _registration;
  late final TextEditingController _notes;
  late final TextEditingController _paymentTerms;
  late final TextEditingController _creditLimit;
  final _picker = ImagePicker();
  XFile? _logo;
  String? _savedSupplierId;
  String _status = 'Active';
  String? _error;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final supplier = widget.supplier;
    _savedSupplierId = supplier?.id;
    _company = TextEditingController(text: supplier?.company ?? '');
    _contact = TextEditingController(text: supplier?.contactPerson ?? '');
    _phone = TextEditingController(text: supplier?.phone ?? '');
    _email = TextEditingController(text: supplier?.email ?? '');
    _address = TextEditingController(text: supplier?.address ?? '');
    _tax = TextEditingController(text: supplier?.taxNumber ?? '');
    _category = TextEditingController(text: supplier?.category ?? '');
    _registration =
        TextEditingController(text: supplier?.registrationNumber ?? '');
    _notes = TextEditingController(text: supplier?.notes ?? '');
    _paymentTerms = TextEditingController(text: supplier?.paymentTerms ?? '');
    _creditLimit =
        TextEditingController(text: supplier?.creditLimit?.toString() ?? '');
    _status = supplier?.status ?? 'Active';
  }

  @override
  void dispose() {
    for (final controller in [
      _company,
      _contact,
      _phone,
      _email,
      _address,
      _tax,
      _category,
      _registration,
      _notes,
      _paymentTerms,
      _creditLimit
    ]) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> _pickLogo() async {
    final image =
        await _picker.pickImage(source: ImageSource.gallery, imageQuality: 85);
    if (image != null) setState(() => _logo = image);
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _saving = true;
      _error = null;
    });
    final payload = <String, dynamic>{
      'name': _company.text.trim(),
      'company': _company.text.trim(),
      'contact_person': _contact.text.trim(),
      'phone': _phone.text.trim(),
      'email': _email.text.trim(),
      'address': _address.text.trim(),
      'tax_number': _tax.text.trim(),
      'category': _category.text.trim(),
      'registration_number':
          _registration.text.trim().isEmpty ? null : _registration.text.trim(),
      'notes': _notes.text.trim().isEmpty ? null : _notes.text.trim(),
      'status': _status,
      'payment_terms':
          _paymentTerms.text.trim().isEmpty ? null : _paymentTerms.text.trim(),
      'credit_limit': _creditLimit.text.trim().isEmpty
          ? null
          : double.tryParse(_creditLimit.text),
    };
    try {
      final response = _savedSupplierId == null
          ? await ApiClient.instance.post('/suppliers', payload)
          : await ApiClient.instance
              .put('/suppliers/$_savedSupplierId', payload);
      final saved = Map<String, dynamic>.from(response['data'] as Map);
      _savedSupplierId = saved['id'].toString();
      if (_logo != null) {
        await ApiClient.instance.uploadFile('/suppliers/${saved['id']}/logo',
            await _logo!.readAsBytes(), _logo!.name);
      }
      if (mounted) Navigator.of(context).pop(true);
    } on ApiException catch (error) {
      if (mounted)
        setState(() {
          _saving = false;
          _error = error.message;
        });
    }
  }

  @override
  Widget build(BuildContext context) {
    final editing = widget.supplier != null;
    return Scaffold(
      appBar: AppBar(title: Text(editing ? 'Update Supplier' : 'New Supplier')),
      body: Form(
        key: _formKey,
        child: ListView(padding: const EdgeInsets.all(20), children: [
          _field('Company Name', _company, required: true),
          _field('Contact Person', _contact, required: true),
          _field('Phone Number', _phone,
              required: true, keyboard: TextInputType.phone),
          _field('Email', _email,
              required: true,
              keyboard: TextInputType.emailAddress,
              email: true),
          _field('Address', _address, required: true),
          _field('Tax Number', _tax, required: true),
          _field('Supplier Category', _category, required: true),
          _field('Business Registration Number', _registration),
          DropdownButtonFormField<String>(
            value: _status,
            decoration: const InputDecoration(labelText: 'Status'),
            items: const ['Active', 'Pending', 'Inactive']
                .map((value) =>
                    DropdownMenuItem(value: value, child: Text(value)))
                .toList(),
            onChanged: (value) => setState(() => _status = value ?? 'Active'),
          ),
          const SizedBox(height: 10),
          _field('Payment Terms', _paymentTerms),
          _field('Credit Limit', _creditLimit,
              keyboard: const TextInputType.numberWithOptions(decimal: true)),
          _field('Notes', _notes, lines: 3),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: _pickLogo,
            icon: const Icon(Icons.upload_file_outlined),
            label: Text(_logo?.name ??
                (widget.supplier?.logoPath.isNotEmpty == true
                    ? 'Replace supplier logo'
                    : 'Choose supplier logo')),
          ),
          if (_error != null) ...[
            const SizedBox(height: 12),
            Text(_error!,
                style: TextStyle(color: Theme.of(context).colorScheme.error)),
          ],
          const SizedBox(height: 20),
          FilledButton(
            onPressed: _saving ? null : _submit,
            child: _saving
                ? const CircularProgressIndicator()
                : Text(editing ? 'Update Supplier' : 'Save Supplier'),
          ),
        ]),
      ),
    );
  }

  Widget _field(
    String label,
    TextEditingController controller, {
    bool required = false,
    bool email = false,
    int lines = 1,
    TextInputType? keyboard,
  }) =>
      Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: TextFormField(
          controller: controller,
          maxLines: lines,
          keyboardType: keyboard,
          decoration: InputDecoration(labelText: label),
          validator: (value) {
            final text = value?.trim() ?? '';
            if (required && text.isEmpty) return 'Required';
            if (email &&
                text.isNotEmpty &&
                !RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(text))
              return 'Enter a valid email';
            if (label == 'Credit Limit' &&
                text.isNotEmpty &&
                (double.tryParse(text) == null || double.parse(text) < 0))
              return 'Enter a non-negative amount';
            return null;
          },
        ),
      );
}

class SupplierDetailScreen extends StatefulWidget {
  final Supplier supplier;

  const SupplierDetailScreen({super.key, required this.supplier});

  @override
  State<SupplierDetailScreen> createState() => _SupplierDetailScreenState();
}

class _SupplierDetailScreenState extends State<SupplierDetailScreen> {
  Map<String, dynamic>? _details;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final response =
          await ApiClient.instance.get('/suppliers/${widget.supplier.id}');
      if (mounted)
        setState(() =>
            _details = Map<String, dynamic>.from(response['data'] as Map));
    } on ApiException catch (error) {
      if (mounted) setState(() => _error = error.message);
    }
  }

  @override
  Widget build(BuildContext context) {
    final supplier = widget.supplier;
    final orders = _details?['purchase_orders'] as List? ?? const [];
    return Scaffold(
      appBar: AppBar(title: Text(supplier.company)),
      body: ListView(padding: const EdgeInsets.all(20), children: [
        Text(supplier.contactPerson,
            style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 12),
        _row('Status', supplier.status),
        _row('Category', supplier.category),
        _row('Phone', supplier.phone),
        _row('Email', supplier.email),
        _row('Address', supplier.address),
        _row('Tax Number', supplier.taxNumber),
        _row('Registration Number', supplier.registrationNumber),
        _row('Payment Terms', supplier.paymentTerms),
        _row(
            'Credit Limit',
            supplier.creditLimit == null
                ? 'Not set'
                : 'ETB ${supplier.creditLimit!.toStringAsFixed(2)}'),
        _row('Outstanding Balance',
            'ETB ${supplier.outstandingBalance.toStringAsFixed(2)}'),
        if (supplier.notes.isNotEmpty) _row('Notes', supplier.notes),
        const Divider(height: 28),
        Text('Purchase Orders', style: Theme.of(context).textTheme.titleMedium),
        if (_error != null) Text(_error!),
        if (_details == null && _error == null)
          const Padding(
              padding: EdgeInsets.all(12), child: LinearProgressIndicator()),
        if (_details != null && orders.isEmpty)
          const Text('No purchase orders for this supplier.'),
        for (final value in orders)
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(value['number'] as String? ?? ''),
            subtitle: Text('${value['order_date']} • ${value['status']}'),
            trailing: Text('ETB ${value['total_amount']}'),
          ),
      ]),
    );
  }

  Widget _row(String label, String value) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Row(children: [
          Expanded(
              child: Text(label,
                  style: const TextStyle(fontWeight: FontWeight.w600))),
          Text(value)
        ]),
      );
}
