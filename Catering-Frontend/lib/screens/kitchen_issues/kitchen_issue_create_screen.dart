import 'package:flutter/material.dart';

import '../../models/auth_models.dart';
import '../../services/api_repository.dart';
import '../../services/auth_service.dart';
import 'kitchen_issue_models.dart';
import 'kitchen_issue_success_screen.dart';

class _KitchenIssueStoreOption {
  final String id;
  final String name;
  final String code;

  const _KitchenIssueStoreOption({
    required this.id,
    required this.name,
    required this.code,
  });
}

class KitchenIssueCreateScreen extends StatefulWidget {
  final bool isEditing;
  final KitchenIssueViewModel? issue;

  const KitchenIssueCreateScreen({super.key, this.isEditing = false, this.issue});

  @override
  State<KitchenIssueCreateScreen> createState() => _KitchenIssueCreateScreenState();
}

class _KitchenIssueCreateScreenState extends State<KitchenIssueCreateScreen> {
  int _step = 0;
  late String _department;
  late String _kitchen;
  late String _requestedDate;
  late String _approvalNotes;
  List<_KitchenIssueStoreOption> _stores = [];
  _KitchenIssueStoreOption? _store;
  List<KitchenIssueIngredientViewModel> _inventory = [];
  bool _loadingStores = true;
  bool _loadingStock = false;
  bool _saving = false;
  String? _error;
  final TextEditingController _searchController = TextEditingController();

  final List<KitchenIssueIngredientViewModel> _selectedIngredients = [];
  final Map<String, String> _quantities = {};

  @override
  void initState() {
    super.initState();
    _department = widget.issue?.department ?? 'Banquet Hall';
    _kitchen = widget.issue?.kitchen ?? 'Main Kitchen';
    _requestedDate = widget.issue?.issueDate ??
        DateTime.now().toIso8601String().split('T').first;
    _approvalNotes = widget.issue?.notes ?? '';
    _loadStores();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadStores() async {
    try {
      final user = AuthService.instance.currentUser;
      final stores = user?.isAdmin == true
          ? (await ApiRepository.instance.getStores(active: true))
              .map((store) => _KitchenIssueStoreOption(
                    id: store.id,
                    name: store.name,
                    code: store.code,
                  ))
              .toList()
          : AuthService.instance.accessibleStores
              .map((store) => _KitchenIssueStoreOption(
                    id: store.storeId,
                    name: store.storeName,
                    code: store.storeCode,
                  ))
              .toList();
      if (!mounted) return;
      setState(() {
        _stores = stores;
        _store = stores.isEmpty
            ? null
            : stores.firstWhere(
                (store) => store.id == widget.issue?.storeId,
                orElse: () => stores.first,
              );
        _loadingStores = false;
      });
      if (_store != null) await _loadInventory(_store!.id);
    } catch (error) {
      if (mounted) {
        setState(() {
          _loadingStores = false;
          _error = error.toString();
        });
      }
    }
  }

  Future<void> _loadInventory(String storeId) async {
    setState(() {
      _loadingStock = true;
      _inventory = [];
      _selectedIngredients.clear();
      _quantities.clear();
    });
    try {
      final inventory = await ApiRepository.instance.getKitchenIssueStock(storeId);
      if (mounted) {
        setState(() {
          _inventory = inventory;
          _loadingStock = false;
          _error = null;
        });
      }
    } catch (error) {
      if (mounted) {
        setState(() {
          _loadingStock = false;
          _error = error.toString();
        });
      }
    }
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
                style: IconButton.styleFrom(backgroundColor: Colors.white, padding: const EdgeInsets.all(10)),
              ),
              const SizedBox(height: 16),
              Text(
                widget.isEditing ? 'Update Kitchen Issue' : 'Create Kitchen Issue',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800, letterSpacing: -0.6),
              ),
              const SizedBox(height: 8),
              Text('A premium, guided workflow for issuing ingredients to kitchens.', style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 14.5)),
              const SizedBox(height: 16),
              if (_error != null) ...[
                Text(_error!, style: TextStyle(color: Theme.of(context).colorScheme.error)),
                const SizedBox(height: 10),
              ],
              Row(
                children: [
                  Expanded(child: _stepBadge(0, 'Request', _step >= 0)),
                  const SizedBox(width: 8),
                  Expanded(child: _stepBadge(1, 'Approval', _step >= 1)),
                  const SizedBox(width: 8),
                  Expanded(child: _stepBadge(2, 'Ingredients', _step >= 2)),
                  const SizedBox(width: 8),
                  Expanded(child: _stepBadge(3, 'Quantities', _step >= 3)),
                  const SizedBox(width: 8),
                  Expanded(child: _stepBadge(4, 'Review', _step >= 4)),
                ],
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 16, offset: const Offset(0, 8))],
                ),
                child: _buildStepContent(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStepContent() {
    switch (_step) {
      case 0:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Step 1 • Request Information', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800)),
            const SizedBox(height: 10),
            if (_loadingStores)
              const Center(child: CircularProgressIndicator())
            else
              DropdownButtonFormField<_KitchenIssueStoreOption>(
                value: _store,
                decoration: const InputDecoration(labelText: 'Source Store'),
                items: _stores
                    .map((store) => DropdownMenuItem(
                          value: store,
                          child: Text('${store.name} (${store.code})'),
                        ))
                    .toList(),
                onChanged: (store) {
                  if (store == null) return;
                  setState(() => _store = store);
                  _loadInventory(store.id);
                },
              ),
            _buildDropdown('Department / Branch', _department, ['Banquet Hall', 'Branch 2', 'Executive Lounge'], (value) => setState(() => _department = value!)),
            _buildDropdown('Kitchen', _kitchen, ['Main Kitchen', 'Satellite Kitchen', 'Prep Kitchen'], (value) => setState(() => _kitchen = value!)),
            _buildTextField('Requested Date', _requestedDate, (value) => setState(() => _requestedDate = value)),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: const Color(0xFFF8FAFC), borderRadius: BorderRadius.circular(18)),
              child: Row(
                children: [
                  const Icon(Icons.verified_user_outlined, color: Color(0xFF2563EB)),
                  const SizedBox(width: 8),
                  const Expanded(child: Text('Requester identity and issue number are recorded by the server.', style: TextStyle(fontWeight: FontWeight.w700))),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(child: OutlinedButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancel'))),
                const SizedBox(width: 12),
                Expanded(child: FilledButton(onPressed: _store == null ? null : () => setState(() => _step = 1), child: const Text('Next'))),
              ],
            ),
          ],
        );
      case 1:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Step 2 • Approval', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800)),
            const SizedBox(height: 10),
            _infoRow('Requested By', AuthService.instance.currentUser?.name ?? 'Signed-in user'),
            _buildTextField('Request Notes', _approvalNotes, (value) => setState(() => _approvalNotes = value)),
            const Padding(
              padding: EdgeInsets.only(bottom: 10),
              child: Text('New requests start pending. Stock changes only after an authorized user approves and issues the request.'),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(child: OutlinedButton(onPressed: () => setState(() => _step = 0), child: const Text('Back'))),
                const SizedBox(width: 12),
                Expanded(child: FilledButton(onPressed: () => setState(() => _step = 2), child: const Text('Next'))),
              ],
            ),
          ],
        );
      case 2:
        final filtered = _inventory.where((item) {
          final query = _searchController.text.toLowerCase();
          return query.isEmpty || item.name.toLowerCase().contains(query) || item.category.toLowerCase().contains(query);
        }).toList();
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Step 3 • Select Ingredients', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800)),
            const SizedBox(height: 10),
            TextField(controller: _searchController, onChanged: (_) => setState(() {}), decoration: const InputDecoration(hintText: 'Search inventory')),
            const SizedBox(height: 10),
            if (_loadingStock)
              const Center(child: CircularProgressIndicator())
            else if (_inventory.isEmpty)
              const Text('No stock is available at the selected store.')
            else
            ...filtered.map((item) {
              final selected = _selectedIngredients.any((ingredient) => ingredient.itemId == item.itemId);
              return Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(color: const Color(0xFFF8FAFC), borderRadius: BorderRadius.circular(18)),
                  child: Row(
                    children: [
                      Container(
                        width: 46,
                        height: 46,
                        decoration: BoxDecoration(color: const Color(0xFFDCEAFE), borderRadius: BorderRadius.circular(14)),
                        child: const Icon(Icons.inventory_2_outlined, color: Color(0xFF2563EB)),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(item.name, style: const TextStyle(fontWeight: FontWeight.w700)),
                            Text('${item.category} • ${item.availableStock} ${item.unit}', style: const TextStyle(color: Color(0xFF64748B), fontSize: 12)),
                          ],
                        ),
                      ),
                      Checkbox(
                        value: selected,
                        onChanged: (value) {
                          setState(() {
                            if (value == true) {
                              _selectedIngredients.add(KitchenIssueIngredientViewModel(
                                itemId: item.itemId,
                                name: item.name,
                                category: item.category,
                                unit: item.unit,
                                availableStock: item.availableStock,
                                quantity: 0,
                              ));
                            } else {
                              _selectedIngredients.removeWhere((ingredient) => ingredient.itemId == item.itemId);
                              _quantities.remove(item.itemId);
                            }
                          });
                        },
                      ),
                    ],
                  ),
                ),
              );
            }),
            if (_selectedIngredients.isNotEmpty) ...[
              const SizedBox(height: 10),
              const Text('Selected ingredients', style: TextStyle(fontWeight: FontWeight.w700)),
              const SizedBox(height: 6),
              ..._selectedIngredients.map((ingredient) => Text('• ${ingredient.name}', style: const TextStyle(color: Color(0xFF64748B)))),
            ],
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(child: OutlinedButton(onPressed: () => setState(() => _step = 1), child: const Text('Back'))),
                const SizedBox(width: 12),
                Expanded(child: FilledButton(onPressed: _selectedIngredients.isEmpty ? null : () => setState(() => _step = 3), child: const Text('Next'))),
              ],
            ),
          ],
        );
      case 3:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Step 4 • Enter Quantities', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800)),
            const SizedBox(height: 10),
            ..._selectedIngredients.map((ingredient) {
              final quantity = _quantities[ingredient.itemId] ?? '';
              final parsed = double.tryParse(quantity) ?? 0;
              final isValid = parsed <= ingredient.availableStock && parsed > 0;
              return Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(color: const Color(0xFFF8FAFC), borderRadius: BorderRadius.circular(18)),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(ingredient.name, style: const TextStyle(fontWeight: FontWeight.w700)),
                      const SizedBox(height: 4),
                      Text('Available stock: ${ingredient.availableStock} ${ingredient.unit}', style: const TextStyle(color: Color(0xFF64748B), fontSize: 12)),
                      const SizedBox(height: 8),
                      TextFormField(
                        initialValue: quantity,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        decoration: InputDecoration(labelText: 'Quantity to Issue', suffixText: ingredient.unit),
                        onChanged: (value) => setState(() => _quantities[ingredient.itemId] = value),
                      ),
                      if (!isValid && quantity.isNotEmpty) ...[
                        const SizedBox(height: 6),
                        Text('Requested quantity exceeds available stock.', style: TextStyle(color: Colors.red.shade600, fontSize: 12)),
                      ],
                    ],
                  ),
                ),
              );
            }),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: const Color(0xFFF8FAFC), borderRadius: BorderRadius.circular(18)),
              child: Row(
                children: [
                  const Icon(Icons.calculate_rounded, color: Color(0xFF2563EB)),
                  const SizedBox(width: 8),
                  Expanded(child: Text('Selected items: ${_selectedIngredients.length} · Total requested: ${_totalQuantity().toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.w700))),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(child: OutlinedButton(onPressed: () => setState(() => _step = 2), child: const Text('Back'))),
                const SizedBox(width: 12),
                Expanded(child: FilledButton(onPressed: _canReview() ? () => setState(() => _step = 4) : null, child: const Text('Review'))),
              ],
            ),
          ],
        );
      default:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Step 5 • Review & Confirm', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800)),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: const Color(0xFFF8FAFC), borderRadius: BorderRadius.circular(18)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Issue Information', style: TextStyle(fontWeight: FontWeight.w800)),
                  const SizedBox(height: 8),
                  _reviewRow('Source Store', _store?.name ?? ''),
                  _reviewRow('Department', _department),
                  _reviewRow('Kitchen', _kitchen),
                  _reviewRow('Date', _requestedDate),
                  _reviewRow('Status', 'Pending Approval'),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: const Color(0xFFF8FAFC), borderRadius: BorderRadius.circular(18)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Ingredients', style: TextStyle(fontWeight: FontWeight.w800)),
                  const SizedBox(height: 8),
                  ..._selectedIngredients.map((ingredient) => Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Row(
                          children: [
                            Expanded(child: Text(ingredient.name, style: const TextStyle(fontWeight: FontWeight.w600))),
                            Text('${_quantities[ingredient.itemId] ?? '0'} ${ingredient.unit}', style: const TextStyle(color: Color(0xFF64748B))),
                          ],
                        ),
                      )),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: const Color(0xFFF8FAFC), borderRadius: BorderRadius.circular(18)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Workflow', style: TextStyle(fontWeight: FontWeight.w800)),
                  const SizedBox(height: 8),
                  Row(children: [const Icon(Icons.storefront_rounded, color: Color(0xFF2563EB)), const SizedBox(width: 8), const Text('Store')]),
                  const SizedBox(height: 6),
                  const Padding(padding: EdgeInsets.only(left: 14), child: Text('↓')),
                  const SizedBox(height: 6),
                  Row(children: [const Icon(Icons.kitchen_rounded, color: Color(0xFF2563EB)), const SizedBox(width: 8), const Text('Kitchen')]),
                  const SizedBox(height: 6),
                  const Padding(padding: EdgeInsets.only(left: 14), child: Text('↓')),
                  const SizedBox(height: 6),
                  Row(children: [const Icon(Icons.restaurant_rounded, color: Color(0xFF2563EB)), const SizedBox(width: 8), const Text('Cooking')]),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(child: OutlinedButton(onPressed: () => setState(() => _step = 3), child: const Text('Back'))),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton(
                    onPressed: _saving || !_canReview() ? null : _submitRequest,
                    child: Text(_saving ? 'Submitting…' : 'Submit for Approval'),
                  ),
                ),
              ],
            ),
          ],
        );
    }
  }

  Widget _stepBadge(int index, String label, bool active) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      decoration: BoxDecoration(color: active ? const Color(0xFFDCEAFE) : const Color(0xFFF8FAFC), borderRadius: BorderRadius.circular(999)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 20,
            height: 20,
            decoration: BoxDecoration(color: active ? const Color(0xFF2563EB) : const Color(0xFFCBD5E1), borderRadius: BorderRadius.circular(999)),
            alignment: Alignment.center,
            child: Text('${index + 1}', style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w700)),
          ),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(color: active ? const Color(0xFF2563EB) : const Color(0xFF64748B), fontWeight: FontWeight.w700, fontSize: 11),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDropdown(String label, String value, List<String> options, ValueChanged<String?> onChanged) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: DropdownButtonFormField<String>(
        value: value,
        decoration: InputDecoration(labelText: label),
        items: options.map((option) => DropdownMenuItem(value: option, child: Text(option))).toList(),
        onChanged: onChanged,
      ),
    );
  }

  Widget _buildTextField(String label, String value, ValueChanged<String> onChanged) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: TextFormField(initialValue: value, decoration: InputDecoration(labelText: label), onChanged: onChanged),
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Expanded(child: Text(label, style: const TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF334155)))),
          Text(value, style: const TextStyle(color: Color(0xFF64748B))),
        ],
      ),
    );
  }

  Widget _reviewRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          Expanded(child: Text(label, style: const TextStyle(fontWeight: FontWeight.w600))),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }

  bool _canReview() {
    if (_store == null || _selectedIngredients.isEmpty) return false;
    for (final ingredient in _selectedIngredients) {
      final parsed = double.tryParse(_quantities[ingredient.itemId] ?? '') ?? 0;
      if (parsed <= 0 || parsed > ingredient.availableStock) return false;
    }
    return true;
  }

  double _totalQuantity() {
    double total = 0;
    for (final ingredient in _selectedIngredients) {
      total += double.tryParse(_quantities[ingredient.itemId] ?? '') ?? 0;
    }
    return total;
  }

  Future<void> _submitRequest() async {
    if (!_canReview()) return;
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      final issue = await ApiRepository.instance.createKitchenIssue({
        'store_id': _store!.id,
        'department': _department,
        'kitchen': _kitchen,
        'requested_date': _requestedDate,
        'notes': _approvalNotes.trim(),
        'items': _selectedIngredients.map((ingredient) => {
              'item_id': ingredient.itemId,
              'quantity_requested': double.parse(_quantities[ingredient.itemId]!),
            }).toList(),
      });
      if (!mounted) return;
      Navigator.of(context).pushReplacement<bool, bool>(
        MaterialPageRoute<bool>(
          builder: (_) => KitchenIssueSuccessScreen(issue: issue),
        ),
        result: true,
      );
    } catch (error) {
      if (mounted) setState(() => _error = error.toString());
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }
}
