import 'package:flutter/material.dart';

import 'kitchen_issue_models.dart';
import 'kitchen_issue_success_screen.dart';

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
  late String _requestedBy;
  late String _approvedBy;
  late String _status;
  late String _requestedDate;
  late String _approvalNotes;
  late String _issueNumber;
  final TextEditingController _searchController = TextEditingController();

  final List<KitchenIssueIngredientViewModel> _inventory = [
    KitchenIssueIngredientViewModel(name: 'Chicken Breast', category: 'Meat', unit: 'Kg', availableStock: 80, quantity: 0),
    KitchenIssueIngredientViewModel(name: 'Basmati Rice', category: 'Dry Food', unit: 'Kg', availableStock: 60, quantity: 0),
    KitchenIssueIngredientViewModel(name: 'Onions', category: 'Vegetables', unit: 'Kg', availableStock: 45, quantity: 0),
    KitchenIssueIngredientViewModel(name: 'Cooking Oil', category: 'Pantry', unit: 'L', availableStock: 24, quantity: 0),
    KitchenIssueIngredientViewModel(name: 'Milk', category: 'Dairy', unit: 'L', availableStock: 30, quantity: 0),
  ];

  final List<KitchenIssueIngredientViewModel> _selectedIngredients = [];
  final Map<String, String> _quantities = {};

  @override
  void initState() {
    super.initState();
    if (widget.isEditing && widget.issue != null) {
      _department = widget.issue!.department;
      _kitchen = widget.issue!.kitchen;
      _requestedBy = widget.issue!.requestedBy;
      _approvedBy = widget.issue!.approvedBy;
      _status = widget.issue!.status;
      _requestedDate = widget.issue!.issueDate;
      _approvalNotes = 'Updated for current service window';
      _issueNumber = widget.issue!.number;
      _selectedIngredients.addAll(
        widget.issue!.ingredients.map(
          (ingredient) => KitchenIssueIngredientViewModel(
            name: ingredient.name,
            category: ingredient.category,
            unit: ingredient.unit,
            availableStock: ingredient.availableStock,
            quantity: ingredient.quantity,
          ),
        ),
      );
      for (final ingredient in _selectedIngredients) {
        _quantities[ingredient.name] = ingredient.quantity.toString();
      }
    } else {
      _department = 'Banquet Hall';
      _kitchen = 'Main Kitchen';
      _requestedBy = 'Selam K.';
      _approvedBy = 'Alemu B.';
      _status = 'Pending Approval';
      _requestedDate = '24 Jul 2026';
      _approvalNotes = 'Urgent for evening service';
      _issueNumber = 'KI-2004';
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FB),
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
            _buildDropdown('Department / Branch', _department, ['Banquet Hall', 'Branch 2', 'Executive Lounge'], (value) => setState(() => _department = value!)),
            _buildDropdown('Kitchen', _kitchen, ['Main Kitchen', 'Satellite Kitchen', 'Prep Kitchen'], (value) => setState(() => _kitchen = value!)),
            _buildTextField('Requested By', _requestedBy, (value) => setState(() => _requestedBy = value)),
            _buildTextField('Requested Date', _requestedDate, (value) => setState(() => _requestedDate = value)),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: const Color(0xFFF8FAFC), borderRadius: BorderRadius.circular(18)),
              child: Row(
                children: [
                  const Icon(Icons.auto_awesome_rounded, color: Color(0xFF2563EB)),
                  const SizedBox(width: 8),
                  Expanded(child: Text('Issue Number: $_issueNumber', style: const TextStyle(fontWeight: FontWeight.w700))),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(child: OutlinedButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancel'))),
                const SizedBox(width: 12),
                Expanded(child: FilledButton(onPressed: () => setState(() => _step = 1), child: const Text('Next'))),
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
            _infoRow('Requested By', _requestedBy),
            _buildDropdown('Approved By', _approvedBy, ['Alemu B.', 'Dawit T.', 'Sara M.'], (value) => setState(() => _approvedBy = value!)),
            _buildTextField('Approval Notes', _approvalNotes, (value) => setState(() => _approvalNotes = value)),
            _buildDropdown('Status', _status, ['Pending Approval', 'Approved', 'Issued'], (value) => setState(() => _status = value!)),
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
            ...filtered.map((item) {
              final selected = _selectedIngredients.any((ingredient) => ingredient.name == item.name);
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
                                name: item.name,
                                category: item.category,
                                unit: item.unit,
                                availableStock: item.availableStock,
                                quantity: 0,
                              ));
                            } else {
                              _selectedIngredients.removeWhere((ingredient) => ingredient.name == item.name);
                              _quantities.remove(item.name);
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
              final quantity = _quantities[ingredient.name] ?? '';
              final parsed = int.tryParse(quantity) ?? 0;
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
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(labelText: 'Quantity to Issue', suffixText: ingredient.unit),
                        onChanged: (value) => setState(() => _quantities[ingredient.name] = value),
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
                  Expanded(child: Text('Running total: ${_totalQuantity()} ${_selectedIngredients.isEmpty ? 'units' : _selectedIngredients.first.unit}', style: const TextStyle(fontWeight: FontWeight.w700))),
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
                  _reviewRow('Issue Number', _issueNumber),
                  _reviewRow('Department', _department),
                  _reviewRow('Kitchen', _kitchen),
                  _reviewRow('Requested By', _requestedBy),
                  _reviewRow('Approved By', _approvedBy),
                  _reviewRow('Date', _requestedDate),
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
                            Text('${_quantities[ingredient.name] ?? '0'} ${ingredient.unit}', style: const TextStyle(color: Color(0xFF64748B))),
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
                    onPressed: () {
                      final issue = KitchenIssueViewModel(
                        number: _issueNumber,
                        department: _department,
                        kitchen: _kitchen,
                        requestedBy: _requestedBy,
                        approvedBy: _approvedBy,
                        issueDate: _requestedDate,
                        status: _status,
                        itemsIssued: _selectedIngredients.length,
                        totalQuantity: _totalQuantity(),
                        ingredients: _selectedIngredients.map((ingredient) => KitchenIssueIngredientViewModel(
                          name: ingredient.name,
                          category: ingredient.category,
                          unit: ingredient.unit,
                          availableStock: ingredient.availableStock,
                          quantity: int.tryParse(_quantities[ingredient.name] ?? '0') ?? 0,
                        )).toList(),
                      );
                      Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => KitchenIssueSuccessScreen(issue: issue)));
                    },
                    child: const Text('Issue Ingredients'),
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
    if (_selectedIngredients.isEmpty) return false;
    for (final ingredient in _selectedIngredients) {
      final parsed = int.tryParse(_quantities[ingredient.name] ?? '') ?? 0;
      if (parsed <= 0 || parsed > ingredient.availableStock) return false;
    }
    return true;
  }

  int _totalQuantity() {
    int total = 0;
    for (final ingredient in _selectedIngredients) {
      total += int.tryParse(_quantities[ingredient.name] ?? '') ?? 0;
    }
    return total;
  }
}
