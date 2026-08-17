import 'package:flutter/material.dart';

import '../../models/inventory_models.dart';
import '../../services/mock_repository.dart';

class RecipeCreateScreen extends StatefulWidget {
  final bool isEditing;
  final RecipeItem? recipe;

  const RecipeCreateScreen({super.key, this.isEditing = false, this.recipe});

  @override
  State<RecipeCreateScreen> createState() => _RecipeCreateScreenState();
}

class _RecipeCreateScreenState extends State<RecipeCreateScreen> {
  int _step = 0;

  late String _name;
  late String _category;
  late String _description;
  late String _prepTime;
  late String _servingsText;
  late String _sellingPriceText;
  late String _status;

  // Ingredients being built
  final List<Map<String, String>> _ingredients = [];
  final _nameCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _prepCtrl = TextEditingController();
  final _servingsCtrl = TextEditingController();
  final _priceCtrl = TextEditingController();

  final List<String> _categories = const [
    'Main Course',
    'Dessert',
    'Beverage',
    'Appetizer',
    'Salad',
    'Soup',
  ];

  final List<String> _availableIngredients = const [
    'Chicken Breast',
    'Basmati Rice',
    'Beef Sirloin',
    'Onion',
    'Tomato',
    'Green Pepper',
    'Carrot',
    'Green Peas',
    'Cooking Oil',
    'Milk Powder',
    'Sugar',
    'Mixed Spices',
    'Spiced Butter',
    'Vanilla Essence',
    'Mango',
    'Papaya',
  ];

  final List<String> _units = const ['Kg', 'L', 'g', 'ml', 'pcs', 'Bag'];

  @override
  void initState() {
    super.initState();
    if (widget.isEditing && widget.recipe != null) {
      final r = widget.recipe!;
      _name = r.name;
      _category = r.category;
      _description = r.description;
      _prepTime = r.prepTime;
      _servingsText = r.servings.toString();
      _sellingPriceText = r.sellingPrice.toStringAsFixed(0);
      _status = r.status;
      _ingredients.addAll(r.ingredients.map((i) => {
            'name': i.name,
            'qty': i.quantity.toString(),
            'unit': i.unit,
            'unitCost': i.unitCost.toString(),
          }));
    } else {
      _name = '';
      _category = 'Main Course';
      _description = '';
      _prepTime = '30 min';
      _servingsText = '10';
      _sellingPriceText = '';
      _status = 'Active';
    }
    _nameCtrl.text = _name;
    _descCtrl.text = _description;
    _prepCtrl.text = _prepTime;
    _servingsCtrl.text = _servingsText;
    _priceCtrl.text = _sellingPriceText;
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _descCtrl.dispose();
    _prepCtrl.dispose();
    _servingsCtrl.dispose();
    _priceCtrl.dispose();
    super.dispose();
  }

  double get _computedFoodCost => _ingredients.fold(0.0, (sum, i) {
        final qty = double.tryParse(i['qty'] ?? '') ?? 0;
        final cost = double.tryParse(i['unitCost'] ?? '') ?? 0;
        return sum + (qty * cost);
      });

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
                style: IconButton.styleFrom(
                    backgroundColor: Colors.white,
                    padding: const EdgeInsets.all(10)),
              ),
              const SizedBox(height: 16),
              Text(
                widget.isEditing ? 'Edit Recipe' : 'Create Recipe',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w800, letterSpacing: -0.6),
              ),
              const SizedBox(height: 6),
              Text('Define dish details, ingredients and food cost calculation.',
                  style:
                      Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 14.5)),
              const SizedBox(height: 16),
              // Step indicators
              Row(
                children: [
                  Expanded(child: _stepBadge(0, 'Details', _step >= 0)),
                  const SizedBox(width: 8),
                  Expanded(child: _stepBadge(1, 'Ingredients', _step >= 1)),
                  const SizedBox(width: 8),
                  Expanded(child: _stepBadge(2, 'Pricing', _step >= 2)),
                  const SizedBox(width: 8),
                  Expanded(child: _stepBadge(3, 'Review', _step >= 3)),
                ],
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                        color: Colors.black.withOpacity(0.04),
                        blurRadius: 16,
                        offset: const Offset(0, 8))
                  ],
                ),
                child: _buildStep(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStep() {
    switch (_step) {
      case 0:
        return _stepDetails();
      case 1:
        return _stepIngredients();
      case 2:
        return _stepPricing();
      default:
        return _stepReview();
    }
  }

  Widget _stepDetails() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Step 1 • Recipe Details',
            style: Theme.of(context)
                .textTheme
                .titleLarge
                ?.copyWith(fontWeight: FontWeight.w800)),
        const SizedBox(height: 12),
        _field('Recipe Name', controller: _nameCtrl,
            onChanged: (v) => _name = v),
        _dropdown('Category', _category, _categories,
            (v) => setState(() => _category = v!)),
        _field('Description', controller: _descCtrl,
            maxLines: 3, onChanged: (v) => _description = v),
        _field('Preparation Time (e.g. 30 min)',
            controller: _prepCtrl, onChanged: (v) => _prepTime = v),
        _field('Number of Servings',
            controller: _servingsCtrl,
            keyboardType: TextInputType.number,
            onChanged: (v) => _servingsText = v),
        _dropdown('Status', _status, ['Active', 'Inactive'],
            (v) => setState(() => _status = v!)),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
                child: OutlinedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Cancel'))),
            const SizedBox(width: 12),
            Expanded(
                child: FilledButton(
                    onPressed: _name.trim().isEmpty
                        ? null
                        : () => setState(() => _step = 1),
                    child: const Text('Next'))),
          ],
        ),
      ],
    );
  }

  Widget _stepIngredients() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Step 2 • Add Ingredients',
            style: Theme.of(context)
                .textTheme
                .titleLarge
                ?.copyWith(fontWeight: FontWeight.w800)),
        const SizedBox(height: 12),
        if (_ingredients.isNotEmpty) ...[
          ..._ingredients.asMap().entries.map((entry) {
            final i = entry.key;
            final ing = entry.value;
            return Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(16)),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(ing['name'] ?? '',
                            style: const TextStyle(fontWeight: FontWeight.w700)),
                        Text(
                            '${ing['qty']} ${ing['unit']} • ETB ${ing['unitCost']}/unit',
                            style: const TextStyle(
                                color: Color(0xFF64748B), fontSize: 12)),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete_outline_rounded,
                        color: Color(0xFFEF4444)),
                    onPressed: () =>
                        setState(() => _ingredients.removeAt(i)),
                  ),
                ],
              ),
            );
          }),
          const Divider(height: 20),
        ],
        _addIngredientForm(),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
              color: const Color(0xFFDCFCE7),
              borderRadius: BorderRadius.circular(14)),
          child: Row(
            children: [
              const Icon(Icons.calculate_rounded, color: Color(0xFF16A34A)),
              const SizedBox(width: 8),
              Text(
                  'Computed food cost: ETB ${_computedFoodCost.toStringAsFixed(2)}',
                  style: const TextStyle(
                      fontWeight: FontWeight.w700, color: Color(0xFF16A34A))),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
                child: OutlinedButton(
                    onPressed: () => setState(() => _step = 0),
                    child: const Text('Back'))),
            const SizedBox(width: 12),
            Expanded(
                child: FilledButton(
                    onPressed: _ingredients.isEmpty
                        ? null
                        : () => setState(() => _step = 2),
                    child: const Text('Next'))),
          ],
        ),
      ],
    );
  }

  // Inline add-ingredient form state
  String _ingName = 'Chicken Breast';
  String _ingUnit = 'Kg';
  final _ingQtyCtrl = TextEditingController();
  final _ingCostCtrl = TextEditingController();

  Widget _addIngredientForm() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF0FDF4),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFBBF7D0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Add Ingredient',
              style: TextStyle(fontWeight: FontWeight.w700)),
          const SizedBox(height: 10),
          DropdownButtonFormField<String>(
            value: _ingName,
            decoration: const InputDecoration(labelText: 'Ingredient'),
            items: _availableIngredients
                .map((n) => DropdownMenuItem(value: n, child: Text(n)))
                .toList(),
            onChanged: (v) => setState(() => _ingName = v!),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                  child: TextFormField(
                controller: _ingQtyCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Quantity'),
              )),
              const SizedBox(width: 10),
              Expanded(
                  child: DropdownButtonFormField<String>(
                value: _ingUnit,
                decoration: const InputDecoration(labelText: 'Unit'),
                items: _units
                    .map((u) => DropdownMenuItem(value: u, child: Text(u)))
                    .toList(),
                onChanged: (v) => setState(() => _ingUnit = v!),
              )),
            ],
          ),
          const SizedBox(height: 10),
          TextFormField(
            controller: _ingCostCtrl,
            keyboardType: TextInputType.number,
            decoration:
                const InputDecoration(labelText: 'Unit Cost (ETB)', suffixText: 'ETB'),
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: () {
                if (_ingQtyCtrl.text.isEmpty || _ingCostCtrl.text.isEmpty) {
                  return;
                }
                setState(() {
                  _ingredients.add({
                    'name': _ingName,
                    'qty': _ingQtyCtrl.text,
                    'unit': _ingUnit,
                    'unitCost': _ingCostCtrl.text,
                  });
                  _ingQtyCtrl.clear();
                  _ingCostCtrl.clear();
                });
              },
              icon: const Icon(Icons.add_rounded),
              label: const Text('Add to Recipe'),
              style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFF16A34A)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _stepPricing() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Step 3 • Pricing',
            style: Theme.of(context)
                .textTheme
                .titleLarge
                ?.copyWith(fontWeight: FontWeight.w800)),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(16)),
          child: Row(
            children: [
              const Icon(Icons.shopping_basket_rounded,
                  color: Color(0xFF2563EB)),
              const SizedBox(width: 10),
              Text(
                  'Computed food cost: ETB ${_computedFoodCost.toStringAsFixed(2)}',
                  style: const TextStyle(fontWeight: FontWeight.w700)),
            ],
          ),
        ),
        const SizedBox(height: 12),
        _field('Selling Price (ETB)',
            controller: _priceCtrl,
            keyboardType: TextInputType.number,
            onChanged: (v) {
              setState(() => _sellingPriceText = v);
            }),
        if (_sellingPriceText.isNotEmpty) ...[
          const SizedBox(height: 8),
          Builder(builder: (_) {
            final sell = double.tryParse(_sellingPriceText) ?? 0;
            final pct = sell > 0 ? (_computedFoodCost / sell) * 100 : 0.0;
            final color = pct > 40
                ? const Color(0xFFEF4444)
                : pct > 30
                    ? const Color(0xFFF59E0B)
                    : const Color(0xFF16A34A);
            return Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: color.withOpacity(0.08),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: color.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  Icon(Icons.percent_rounded, color: color),
                  const SizedBox(width: 10),
                  Text(
                      'Food cost ratio: ${pct.toStringAsFixed(1)}% ${pct <= 30 ? '✓ Good' : pct <= 40 ? '⚠ High' : '✗ Too High'}',
                      style: TextStyle(
                          fontWeight: FontWeight.w700, color: color)),
                ],
              ),
            );
          }),
        ],
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
                child: OutlinedButton(
                    onPressed: () => setState(() => _step = 1),
                    child: const Text('Back'))),
            const SizedBox(width: 12),
            Expanded(
                child: FilledButton(
                    onPressed: _sellingPriceText.isEmpty
                        ? null
                        : () => setState(() => _step = 3),
                    child: const Text('Review'))),
          ],
        ),
      ],
    );
  }

  Widget _stepReview() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Step 4 • Review & Save',
            style: Theme.of(context)
                .textTheme
                .titleLarge
                ?.copyWith(fontWeight: FontWeight.w800)),
        const SizedBox(height: 12),
        _reviewBlock('Recipe Info', [
          _reviewRow('Name', _name),
          _reviewRow('Category', _category),
          _reviewRow('Prep Time', _prepTime),
          _reviewRow('Servings', _servingsText),
          _reviewRow('Status', _status),
        ]),
        const SizedBox(height: 12),
        _reviewBlock('Ingredients (${_ingredients.length})', [
          ..._ingredients.map((ing) => _reviewRow(
              ing['name'] ?? '',
              '${ing['qty']} ${ing['unit']} @ ETB ${ing['unitCost']}'))
        ]),
        const SizedBox(height: 12),
        _reviewBlock('Pricing', [
          _reviewRow('Food Cost',
              'ETB ${_computedFoodCost.toStringAsFixed(2)}'),
          _reviewRow('Selling Price', 'ETB $_sellingPriceText'),
          _reviewRow(
              'Food Cost %',
              () {
                final sell = double.tryParse(_sellingPriceText) ?? 0;
                final pct = sell > 0
                    ? (_computedFoodCost / sell) * 100
                    : 0.0;
                return '${pct.toStringAsFixed(1)}%';
              }()),
        ]),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
                child: OutlinedButton(
                    onPressed: () => setState(() => _step = 2),
                    child: const Text('Back'))),
            const SizedBox(width: 12),
            Expanded(
                child: FilledButton(
                    onPressed: _save,
                    style: FilledButton.styleFrom(
                        backgroundColor: const Color(0xFF16A34A)),
                    child: Text(
                        widget.isEditing ? 'Update Recipe' : 'Save Recipe'))),
          ],
        ),
      ],
    );
  }

  void _save() {
    final ingList = _ingredients
        .map((ing) => RecipeIngredient(
              name: ing['name'] ?? '',
              quantity: double.tryParse(ing['qty'] ?? '') ?? 0,
              unit: ing['unit'] ?? 'Kg',
              unitCost: double.tryParse(ing['unitCost'] ?? '') ?? 0,
            ))
        .toList();

    final newRecipe = RecipeItem(
      id: widget.recipe?.id ?? 'ri${DateTime.now().millisecondsSinceEpoch}',
      name: _name,
      category: _category,
      description: _description,
      servings: int.tryParse(_servingsText) ?? 1,
      prepTime: _prepTime,
      sellingPrice: double.tryParse(_sellingPriceText) ?? 0,
      status: _status,
      ingredients: ingList,
    );

    if (widget.isEditing) {
      final idx = MockRepository.recipeItems
          .indexWhere((r) => r.id == widget.recipe!.id);
      if (idx >= 0) MockRepository.recipeItems[idx] = newRecipe;
    } else {
      MockRepository.recipeItems.add(newRecipe);
    }

    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(widget.isEditing
          ? 'Recipe updated successfully.'
          : 'Recipe saved successfully.'),
      backgroundColor: const Color(0xFF16A34A),
    ));
    Navigator.of(context).pop();
  }

  // ── helpers ──────────────────────────────────────────────────────────────

  Widget _field(String label,
      {TextEditingController? controller,
      int maxLines = 1,
      TextInputType keyboardType = TextInputType.text,
      required ValueChanged<String> onChanged}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: TextFormField(
        controller: controller,
        maxLines: maxLines,
        keyboardType: keyboardType,
        decoration: InputDecoration(labelText: label),
        onChanged: onChanged,
      ),
    );
  }

  Widget _dropdown(String label, String value, List<String> options,
      ValueChanged<String?> onChanged) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: DropdownButtonFormField<String>(
        value: value,
        decoration: InputDecoration(labelText: label),
        items: options
            .map((o) => DropdownMenuItem(value: o, child: Text(o)))
            .toList(),
        onChanged: onChanged,
      ),
    );
  }

  Widget _stepBadge(int index, String label, bool active) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      decoration: BoxDecoration(
        color: active ? const Color(0xFFDCFCE7) : const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              color:
                  active ? const Color(0xFF16A34A) : const Color(0xFFCBD5E1),
              borderRadius: BorderRadius.circular(999),
            ),
            alignment: Alignment.center,
            child: Text('${index + 1}',
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.w700)),
          ),
          const SizedBox(width: 6),
          Flexible(
            child: Text(label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                    color: active
                        ? const Color(0xFF16A34A)
                        : const Color(0xFF64748B),
                    fontWeight: FontWeight.w700,
                    fontSize: 11)),
          ),
        ],
      ),
    );
  }

  Widget _reviewBlock(String title, List<Widget> rows) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
          color: const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(18)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13)),
          const SizedBox(height: 8),
          ...rows,
        ],
      ),
    );
  }

  Widget _reviewRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          Expanded(
              child: Text(label,
                  style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF475569),
                      fontSize: 13))),
          Text(value,
              style: const TextStyle(
                  fontWeight: FontWeight.w700, fontSize: 13)),
        ],
      ),
    );
  }
}
